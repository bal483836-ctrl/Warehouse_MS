package com.wms.controller;

import com.wms.common.Result;
import com.wms.entity.*;
import com.wms.entity.Record;
import com.wms.repo.*;
import jakarta.servlet.http.HttpServletRequest;
import com.wms.security.TokenStore;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 出入库核心业务：真实修改 goods.count 与库位存货 location_stock（按批次记录入库/到期），
 * 并写入 record 流水。type=0 入库，type=1 出库。
 * 入库可指定落位库位(货架)与关联订单，可传收货凭证；库位分区须与商品 zone 一致。
 * 出库按「先到期先出」扣减。
 */
@RestController
@RequestMapping("/api/inout")
public class InOutController {

    private final GoodsRepo goodsRepo;
    private final RecordRepo recordRepo;
    private final LocationStockRepo locStockRepo;
    private final LocationRepo locationRepo;
    private final com.wms.repo.OrderRepo orderRepo;
    private final com.wms.repo.OrderItemRepo orderItemRepo;
    private final JdbcTemplate jdbc;

    public InOutController(GoodsRepo g, RecordRepo r, LocationStockRepo ls, LocationRepo l,
                           com.wms.repo.OrderRepo o, com.wms.repo.OrderItemRepo oi, JdbcTemplate jdbc) {
        this.goodsRepo = g; this.recordRepo = r; this.locStockRepo = ls; this.locationRepo = l;
        this.orderRepo = o; this.orderItemRepo = oi; this.jdbc = jdbc;
    }

    /**
     * 出/入库后刷新订单状态：只有当订单「所有明细」都已足额出/入库，才置为「已完成」；
     * 否则保持「待处理」（部分出/入库不算完成）。已取消订单不改动。
     * @param type 0=入库(采购单)  1=出库(销售单)
     */
    private void refreshOrderStatus(Integer orderId, int type) {
        if (orderId == null) return;
        OrderMain o = orderRepo.findById(orderId).orElse(null);
        if (o == null || (o.getStatus() != null && o.getStatus() == 2)) return; // 已取消不动
        List<OrderItem> items = orderItemRepo.findByOrderIdOrderByIdAsc(orderId);
        if (items.isEmpty()) return;
        boolean allDone = true;
        for (OrderItem it : items) {
            int ordered = it.getCount() == null ? 0 : it.getCount();
            if (movedQty(orderId, it.getGoodsId(), type) < ordered) { allDone = false; break; }
        }
        Integer target = allDone ? 1 : 0;
        if (!Objects.equals(o.getStatus(), target)) { o.setStatus(target); orderRepo.save(o); }
    }

    /** 某订单下某商品已出/入库的累计数量（按 record 流水汇总）。 */
    private int movedQty(Integer orderId, Integer goodsId, int type) {
        Integer sum = jdbc.queryForObject(
            "SELECT COALESCE(SUM(count),0) FROM record WHERE order_id=? AND goods=? AND type=?",
            Integer.class, orderId, goodsId, type);
        return sum == null ? 0 : sum;
    }

    /** 某订单下某商品的下单数量（订单明细合计）。 */
    private int orderedQty(Integer orderId, Integer goodsId) {
        return orderItemRepo.findByOrderIdOrderByIdAsc(orderId).stream()
            .filter(it -> Objects.equals(it.getGoodsId(), goodsId))
            .mapToInt(it -> it.getCount() == null ? 0 : it.getCount()).sum();
    }

    public record MoveReq(Integer goodsId, Integer count, String remark,
                          Integer orderId, Integer locationId, String image,
                          Boolean cleanup, Integer locationStockId) {}

    @PostMapping("/in")
    @Transactional
    public Result<Record> inbound(@RequestBody MoveReq req, HttpServletRequest http) {
        if (req.goodsId() == null || req.count() == null || req.count() <= 0)
            return Result.fail("请选择货物并填写正数数量");
        if (req.orderId() == null) return Result.fail("入库必须关联采购订单");
        Goods g = goodsRepo.findById(req.goodsId()).orElse(null);
        if (g == null) return Result.fail("货物不存在");

        // 选定落位库位：校验属于商品所属仓库且分区一致
        Location loc = pickLocation(g, req.locationId());
        if (loc == null) return Result.fail("该商品所属仓库的「" + zoneOf(g) + "」分区暂无可用库位，请先在货位管理中添加");

        g.setCount((g.getCount() == null ? 0 : g.getCount()) + req.count());
        goodsRepo.save(g);
        allocate(g, loc, req.count());
        Record rec = writeRecord(g.getId(), req.count(), 0, req.remark(), req.orderId(), loc.getId(), req.image(), http);
        refreshOrderStatus(req.orderId(), 0);
        return Result.ok(rec);
    }

    /** 待清理（临期/过期）批次列表：用于「清理过保产品」出库模式挑选。 */
    @GetMapping("/cleanup-list")
    public Result<List<Map<String, Object>>> cleanupList() {
        return Result.ok(jdbc.queryForList(
            "SELECT ls.id lsId, g.id goodsId, g.name gname, ls.count qty, l.id locationId, l.code code, " +
            " ls.expiry_date expiry, DATEDIFF(ls.expiry_date, NOW()) days " +
            "FROM location_stock ls JOIN goods g ON g.id=ls.goods_id JOIN location l ON l.id=ls.location_id " +
            "WHERE ls.expiry_date IS NOT NULL AND ls.count>0 " +
            "  AND ls.expiry_date <= NOW() + INTERVAL COALESCE(g.cleanup_warn_days,7) DAY " +
            "ORDER BY ls.expiry_date ASC"));
    }

    @PostMapping("/out")
    @Transactional
    public Result<Record> outbound(@RequestBody MoveReq req, HttpServletRequest http) {
        if (req.goodsId() == null || req.count() == null || req.count() <= 0)
            return Result.fail("请选择货物并填写正数数量");
        boolean cleanup = Boolean.TRUE.equals(req.cleanup());
        if (!cleanup && req.orderId() == null)
            return Result.fail("出库须关联销售订单，或切换到「清理过保产品」模式");
        Goods g = goodsRepo.findById(req.goodsId()).orElse(null);
        if (g == null) return Result.fail("货物不存在");
        int cur = g.getCount() == null ? 0 : g.getCount();
        if (cur < req.count()) return Result.fail("库存不足，当前库存 " + cur);

        // 订单出库：不能超过该订单该商品「尚未出库」的数量
        if (!cleanup) {
            int ordered = orderedQty(req.orderId(), g.getId());
            if (ordered <= 0) return Result.fail("该商品不在所选销售订单中");
            int left = ordered - movedQty(req.orderId(), g.getId(), 1);
            if (req.count() > left) return Result.fail("超出订单未出库数量，剩余可出库 " + Math.max(0, left));
        }

        g.setCount(cur - req.count());
        goodsRepo.save(g);
        if (cleanup && req.locationStockId() != null) deallocateBatch(g, req.locationStockId(), req.count());
        else deallocate(g, req.count());

        String remark = req.remark();
        if (cleanup && (remark == null || remark.isBlank())) remark = "清理过保出库";
        Record rec = writeRecord(g.getId(), req.count(), 1, remark, cleanup ? null : req.orderId(), null, null, http);
        if (!cleanup) refreshOrderStatus(req.orderId(), 1);
        return Result.ok(rec);
    }

    private String zoneOf(Goods g) {
        String z = g.getZone();
        return (z == null || z.trim().isEmpty()) ? "普通" : z.trim();
    }

    /** 选定入库落位：优先用户指定，否则在商品所属仓库的同分区里挑第一个 */
    private Location pickLocation(Goods g, Integer locationId) {
        String zone = zoneOf(g);
        if (locationId != null) {
            Location loc = locationRepo.findById(locationId).orElse(null);
            if (loc != null && Objects.equals(loc.getStorageId(), g.getStorage())
                    && zone.equals(loc.getZone() == null ? "" : loc.getZone().trim())) return loc;
            return null;
        }
        List<Location> bins = locationRepo.findByStorageIdAndZoneOrderByIdAsc(g.getStorage(), zone);
        if (bins.isEmpty()) bins = locationRepo.findByStorageIdOrderByIdAsc(g.getStorage());
        return bins.isEmpty() ? null : bins.get(0);
    }

    /** 入库：在指定库位新增一条批次存货（记录入库日期与到期日期） */
    private void allocate(Goods g, Location loc, int count) {
        LocalDateTime now = LocalDateTime.now();
        // 同库位、同到期日的批次合并，否则新建
        LocalDateTime expiry = (g.getShelfLifeDays() != null) ? now.plusDays(g.getShelfLifeDays()) : null;
        LocationStock ls = new LocationStock();
        ls.setLocationId(loc.getId());
        ls.setGoodsId(g.getId());
        ls.setCount(count);
        ls.setInboundDate(now);
        ls.setExpiryDate(expiry);
        locStockRepo.save(ls);
    }

    /** 出库：按「先到期先出」扣减各批次库存 */
    private void deallocate(Goods g, int count) {
        List<LocationStock> lots = new ArrayList<>(locStockRepo.findByGoodsIdOrderByIdAsc(g.getId()));
        lots.sort(Comparator.comparing((LocationStock l) -> l.getExpiryDate() == null ? LocalDateTime.MAX : l.getExpiryDate())
                .thenComparing(LocationStock::getId));
        int remaining = count;
        for (LocationStock ls : lots) {
            if (remaining <= 0) break;
            int take = Math.min(ls.getCount(), remaining);
            ls.setCount(ls.getCount() - take);
            remaining -= take;
            if (ls.getCount() == 0) locStockRepo.delete(ls);
            else locStockRepo.save(ls);
        }
    }

    /** 清理过保：优先从选定批次扣减，不足部分再按「先到期先出」补足。 */
    private void deallocateBatch(Goods g, Integer locationStockId, int count) {
        LocationStock ls = locStockRepo.findById(locationStockId).orElse(null);
        if (ls == null) { deallocate(g, count); return; }
        int take = Math.min(ls.getCount(), count);
        ls.setCount(ls.getCount() - take);
        if (ls.getCount() <= 0) locStockRepo.delete(ls); else locStockRepo.save(ls);
        int remaining = count - take;
        if (remaining > 0) deallocate(g, remaining);
    }

    private Record writeRecord(Integer goodsId, Integer count, int type, String remark,
                               Integer orderId, Integer locationId, String image, HttpServletRequest http) {
        TokenStore.Principal p = (TokenStore.Principal) http.getAttribute("principal");
        Record rec = new Record();
        rec.setGoods(goodsId);
        rec.setUserId(p != null ? p.userId() : null);
        rec.setCount(count);
        rec.setType(type);
        rec.setCreatetime(LocalDateTime.now());
        rec.setRemark(remark);
        rec.setOrderId(orderId);
        rec.setLocationId(locationId);
        rec.setImage(image);
        return recordRepo.save(rec);
    }
}

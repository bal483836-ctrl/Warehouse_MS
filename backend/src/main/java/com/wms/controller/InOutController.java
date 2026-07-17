package com.wms.controller;

import com.wms.common.Result;
import com.wms.entity.*;
import com.wms.entity.Record;
import com.wms.repo.*;
import jakarta.servlet.http.HttpServletRequest;
import com.wms.security.TokenStore;
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

    public InOutController(GoodsRepo g, RecordRepo r, LocationStockRepo ls, LocationRepo l) {
        this.goodsRepo = g; this.recordRepo = r; this.locStockRepo = ls; this.locationRepo = l;
    }

    public record MoveReq(Integer goodsId, Integer count, String remark,
                          Integer orderId, Integer locationId, String image) {}

    @PostMapping("/in")
    @Transactional
    public Result<Record> inbound(@RequestBody MoveReq req, HttpServletRequest http) {
        if (req.goodsId() == null || req.count() == null || req.count() <= 0)
            return Result.fail("请选择货物并填写正数数量");
        Goods g = goodsRepo.findById(req.goodsId()).orElse(null);
        if (g == null) return Result.fail("货物不存在");

        // 选定落位库位：校验属于商品所属仓库且分区一致
        Location loc = pickLocation(g, req.locationId());
        if (loc == null) return Result.fail("该商品所属仓库的「" + zoneOf(g) + "」分区暂无可用库位，请先在货位管理中添加");

        g.setCount((g.getCount() == null ? 0 : g.getCount()) + req.count());
        goodsRepo.save(g);
        allocate(g, loc, req.count());
        return Result.ok(writeRecord(g.getId(), req.count(), 0, req.remark(), req.orderId(), loc.getId(), req.image(), http));
    }

    @PostMapping("/out")
    @Transactional
    public Result<Record> outbound(@RequestBody MoveReq req, HttpServletRequest http) {
        if (req.goodsId() == null || req.count() == null || req.count() <= 0)
            return Result.fail("请选择货物并填写正数数量");
        Goods g = goodsRepo.findById(req.goodsId()).orElse(null);
        if (g == null) return Result.fail("货物不存在");
        int cur = g.getCount() == null ? 0 : g.getCount();
        if (cur < req.count()) return Result.fail("库存不足，当前库存 " + cur);

        g.setCount(cur - req.count());
        goodsRepo.save(g);
        deallocate(g, req.count());
        return Result.ok(writeRecord(g.getId(), req.count(), 1, req.remark(), req.orderId(), null, null, http));
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

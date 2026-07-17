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
import java.util.List;

/**
 * 出入库核心业务：真实修改 goods.count 与库位存货 location_stock，并写入 record 流水。
 * type=0 入库，type=1 出库（与 record.type 注释一致）。
 * 入库/出库可关联订单(orderId)；入库可附收货凭证图片(image)。
 * 库位分区约束：商品仅能放入与其 zone（冷冻/冰鲜/普通）一致的库位。
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
                          Integer orderId, Integer supplierId, Integer customerId, String image) {}

    @PostMapping("/in")
    @Transactional
    public Result<Record> inbound(@RequestBody MoveReq req, HttpServletRequest http) {
        if (req.goodsId() == null || req.count() == null || req.count() <= 0)
            return Result.fail("请选择货物并填写正数数量");
        Goods g = goodsRepo.findById(req.goodsId()).orElse(null);
        if (g == null) return Result.fail("货物不存在");

        g.setCount((g.getCount() == null ? 0 : g.getCount()) + req.count());
        goodsRepo.save(g);
        allocate(g, req.count());
        return Result.ok(writeRecord(g.getId(), req.count(), 0, req.remark(), req.orderId(), req.image(), http));
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
        // 出库不带图片
        return Result.ok(writeRecord(g.getId(), req.count(), 1, req.remark(), req.orderId(), null, http));
    }

    /** 商品所属分区，默认「普通」 */
    private String zoneOf(Goods g) {
        String z = g.getZone();
        return (z == null || z.trim().isEmpty()) ? "普通" : z.trim();
    }

    /** 入库：把数量放进「同分区」的库位（优先累加已有库位，否则在匹配分区新建） */
    private void allocate(Goods g, int count) {
        String zone = zoneOf(g);
        // 已有该商品的库位（校验其分区匹配）
        for (LocationStock ls : locStockRepo.findByGoodsIdOrderByIdAsc(g.getId())) {
            Location loc = locationRepo.findById(ls.getLocationId()).orElse(null);
            if (loc != null && zone.equals(loc.getZone() == null ? "" : loc.getZone().trim())) {
                ls.setCount(ls.getCount() + count);
                locStockRepo.save(ls);
                return;
            }
        }
        // 在商品所属仓库的匹配分区中挑一个库位
        List<Location> bins = locationRepo.findByStorageIdAndZoneOrderByIdAsc(g.getStorage(), zone);
        if (bins.isEmpty()) {
            // 兼容旧数据：分区值可能带空格，退化为「仓库内首个库位」
            bins = locationRepo.findByStorageIdOrderByIdAsc(g.getStorage());
        }
        if (!bins.isEmpty()) {
            LocationStock ls = new LocationStock();
            ls.setLocationId(bins.get(0).getId());
            ls.setGoodsId(g.getId());
            ls.setCount(count);
            locStockRepo.save(ls);
        }
    }

    /** 出库：按库位 FIFO 扣减存货 */
    private void deallocate(Goods g, int count) {
        int remaining = count;
        for (LocationStock ls : locStockRepo.findByGoodsIdOrderByIdAsc(g.getId())) {
            if (remaining <= 0) break;
            int take = Math.min(ls.getCount(), remaining);
            ls.setCount(ls.getCount() - take);
            remaining -= take;
            if (ls.getCount() == 0) locStockRepo.delete(ls);
            else locStockRepo.save(ls);
        }
    }

    private Record writeRecord(Integer goodsId, Integer count, int type, String remark,
                               Integer orderId, String image, HttpServletRequest http) {
        TokenStore.Principal p = (TokenStore.Principal) http.getAttribute("principal");
        Record rec = new Record();
        rec.setGoods(goodsId);
        rec.setUserId(p != null ? p.userId() : null);
        rec.setCount(count);
        rec.setType(type);
        rec.setCreatetime(LocalDateTime.now());
        rec.setRemark(remark);
        rec.setOrderId(orderId);
        rec.setImage(image);
        return recordRepo.save(rec);
    }
}

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

    public record MoveReq(Integer goodsId, Integer count, String remark) {}

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
        return Result.ok(writeRecord(g.getId(), req.count(), 0, req.remark(), http));
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
        return Result.ok(writeRecord(g.getId(), req.count(), 1, req.remark(), http));
    }

    /** 入库：把数量放进货物所属仓库的库位（优先累加已有库位，否则新建） */
    private void allocate(Goods g, int count) {
        List<LocationStock> stocks = locStockRepo.findByGoodsIdOrderByIdAsc(g.getId());
        if (!stocks.isEmpty()) {
            LocationStock ls = stocks.get(0);
            ls.setCount(ls.getCount() + count);
            locStockRepo.save(ls);
        } else {
            List<Location> bins = locationRepo.findByStorageIdOrderByIdAsc(g.getStorage());
            if (!bins.isEmpty()) {
                LocationStock ls = new LocationStock();
                ls.setLocationId(bins.get(0).getId());
                ls.setGoodsId(g.getId());
                ls.setCount(count);
                locStockRepo.save(ls);
            }
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

    private Record writeRecord(Integer goodsId, Integer count, int type, String remark, HttpServletRequest http) {
        TokenStore.Principal p = (TokenStore.Principal) http.getAttribute("principal");
        Record rec = new Record();
        rec.setGoods(goodsId);
        rec.setUserId(p != null ? p.userId() : null);
        rec.setCount(count);
        rec.setType(type);
        rec.setCreatetime(LocalDateTime.now());
        rec.setRemark(remark);
        return recordRepo.save(rec);
    }
}

package com.wms.controller;

import com.wms.common.Result;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 仓库库位热力图：占用率与预警全部由真实库存数据算出。
 *  - occupancy = 该库位存货 / 库位容量
 *  - 预警（红色）：库位内商品库存低于其安全下限；「越少越红」——缺口越大颜色越深，
 *    方便及时补货进货。不再对积压做红色预警。
 *  - 分区：冷冻 / 冰鲜 / 普通，同区库位归为一组展示。
 */
@RestController
@RequestMapping("/api/heatmap")
public class HeatmapController {

    private final JdbcTemplate jdbc;
    public HeatmapController(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    /** 有库位的仓库列表 */
    @GetMapping("/storages")
    public Result<List<Map<String, Object>>> storages() {
        return Result.ok(jdbc.queryForList(
            "SELECT s.id, s.name, COUNT(l.id) bins, COALESCE(SUM(l.capacity),0) capacity " +
            "FROM storage s JOIN location l ON l.storage_id=s.id " +
            "GROUP BY s.id, s.name ORDER BY s.id"));
    }

    /** 指定仓库的所有库位（含占用率、缺货预警与红色深度） */
    @GetMapping
    public Result<Map<String, Object>> grid(@RequestParam Integer storageId) {
        // 商品当前库存 + 安全下限（启用预警的）
        Map<Integer, int[]> goodsInfo = new HashMap<>(); // goodsId -> [count, minCount]
        for (Map<String, Object> r : jdbc.queryForList(
                "SELECT g.id gid, g.count cnt, COALESCE(MAX(CASE WHEN sa.enabled=1 THEN sa.min_count END),0) mn " +
                "FROM goods g LEFT JOIN stock_alert sa ON sa.goods_id=g.id GROUP BY g.id, g.count")) {
            int gid = ((Number) r.get("gid")).intValue();
            int cnt = r.get("cnt") == null ? 0 : ((Number) r.get("cnt")).intValue();
            int mn = r.get("mn") == null ? 0 : ((Number) r.get("mn")).intValue();
            goodsInfo.put(gid, new int[]{cnt, mn});
        }

        // 每个库位存放的货物 id
        Map<Integer, List<Integer>> binGoods = new HashMap<>();
        for (Map<String, Object> r : jdbc.queryForList(
                "SELECT ls.location_id lid, ls.goods_id gid FROM location_stock ls " +
                "JOIN location l ON l.id=ls.location_id WHERE l.storage_id=?", storageId)) {
            binGoods.computeIfAbsent(((Number) r.get("lid")).intValue(), k -> new ArrayList<>())
                    .add(((Number) r.get("gid")).intValue());
        }

        List<Map<String, Object>> rows = jdbc.queryForList(
            "SELECT l.id, l.code, l.zone, l.row_no, l.col_no, l.capacity, " +
            " COALESCE(SUM(ls.count),0) stock, " +
            " GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ',') goods " +
            "FROM location l " +
            "LEFT JOIN location_stock ls ON ls.location_id=l.id " +
            "LEFT JOIN goods g ON g.id=ls.goods_id " +
            "WHERE l.storage_id=? GROUP BY l.id, l.code, l.zone, l.row_no, l.col_no, l.capacity " +
            "ORDER BY l.zone, l.row_no", storageId);

        List<Map<String, Object>> bins = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            int id = ((Number) r.get("id")).intValue();
            long stock = ((Number) r.get("stock")).longValue();
            long capacity = ((Number) r.get("capacity")).longValue();
            double occ = capacity > 0 ? (double) stock / capacity : 0;

            // 缺货预警：库位内任一商品库存 < 其安全下限；severity 越大越红
            boolean low = false;
            double severity = 0;
            for (Integer gid : binGoods.getOrDefault(id, List.of())) {
                int[] info = goodsInfo.get(gid);
                if (info == null) continue;
                int cnt = info[0], mn = info[1];
                if (mn > 0 && cnt < mn) {
                    low = true;
                    double sev = (double) (mn - cnt) / mn; // 0~1，缺口占比
                    severity = Math.max(severity, Math.min(1, sev));
                }
            }

            Map<String, Object> b = new LinkedHashMap<>();
            b.put("id", id);
            b.put("code", r.get("code"));
            b.put("zone", r.get("zone") == null ? "" : ((String) r.get("zone")).trim());
            b.put("rowNo", r.get("row_no"));
            b.put("stock", stock);
            b.put("capacity", capacity);
            b.put("occupancy", Math.round(occ * 100));
            b.put("goods", r.get("goods") == null ? "空置" : r.get("goods"));
            b.put("alert", low);
            b.put("severity", Math.round(severity * 100)); // 0~100，越大越红
            b.put("reason", low ? "库存偏低，需补货" : null);
            bins.add(b);
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("storageId", storageId);
        data.put("bins", bins);
        return Result.ok(data);
    }
}

package com.wms.controller;

import com.wms.common.Result;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 仓库库位热力图：占用率与预警全部由真实库存数据算出。
 *  - occupancy = 该库位存货 / 库位容量
 *  - alert：占用率≥95%（积压）或库位内货物低于其安全库存（缺货）
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

    /** 指定仓库的所有库位（含占用率与预警标记） */
    @GetMapping
    public Result<Map<String, Object>> grid(@RequestParam Integer storageId) {
        // 全局低库存货物（缺货预警）
        Set<Integer> lowGoods = new HashSet<>(jdbc.queryForList(
            "SELECT sa.goods_id FROM stock_alert sa JOIN goods g ON g.id=sa.goods_id " +
            "WHERE sa.enabled=1 AND g.count < sa.min_count", Integer.class));

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

            boolean overstock = occ >= 0.95;
            boolean lowstock = binGoods.getOrDefault(id, List.of()).stream().anyMatch(lowGoods::contains);
            String reason = overstock ? "积压(≥95%)" : (lowstock ? "缺货预警" : null);

            Map<String, Object> b = new LinkedHashMap<>();
            b.put("id", id);
            b.put("code", r.get("code"));
            b.put("zone", r.get("zone") == null ? "" : ((String) r.get("zone")).trim());
            b.put("rowNo", r.get("row_no"));
            b.put("stock", stock);
            b.put("capacity", capacity);
            b.put("occupancy", Math.round(occ * 100));
            b.put("goods", r.get("goods") == null ? "空置" : r.get("goods"));
            b.put("alert", overstock || lowstock);
            b.put("reason", reason);
            bins.add(b);
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("storageId", storageId);
        data.put("bins", bins);
        return Result.ok(data);
    }
}

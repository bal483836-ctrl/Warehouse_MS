package com.wms.controller;

import com.wms.common.Result;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/** 图表统计：KPI、出入库趋势、分类占比，全部基于真实库表聚合。 */
@RestController
@RequestMapping("/api/stats")
public class StatsController {

    private final JdbcTemplate jdbc;
    public StatsController(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @GetMapping("/kpi")
    public Result<Map<String, Object>> kpi() {
        Map<String, Object> m = new LinkedHashMap<>();
        Long totalStock = jdbc.queryForObject("SELECT COALESCE(SUM(count),0) FROM goods", Long.class);
        Long todayIn = jdbc.queryForObject(
            "SELECT COALESCE(SUM(count),0) FROM record WHERE type=0 AND DATE(createtime)=CURDATE()", Long.class);
        Long todayOut = jdbc.queryForObject(
            "SELECT COALESCE(SUM(count),0) FROM record WHERE type=1 AND DATE(createtime)=CURDATE()", Long.class);
        Long alertCount = jdbc.queryForObject(
            "SELECT COUNT(*) FROM stock_alert sa JOIN goods g ON g.id=sa.goods_id " +
            "WHERE sa.enabled=1 AND g.count < sa.min_count", Long.class);
        Long stock = jdbc.queryForObject("SELECT COALESCE(SUM(count),0) FROM location_stock", Long.class);
        Long cap = jdbc.queryForObject("SELECT COALESCE(SUM(capacity),0) FROM location", Long.class);
        int usage = (cap != null && cap > 0) ? (int) Math.round(stock * 100.0 / cap) : 0;
        // 过保质期 / 临期预警 商品数（按商品去重）
        Long expired = jdbc.queryForObject(
            "SELECT COUNT(DISTINCT goods_id) FROM location_stock WHERE expiry_date IS NOT NULL AND count>0 AND expiry_date < NOW()", Long.class);
        Long expiring = jdbc.queryForObject(
            "SELECT COUNT(DISTINCT ls.goods_id) FROM location_stock ls JOIN goods g ON g.id=ls.goods_id " +
            "WHERE ls.expiry_date IS NOT NULL AND ls.count>0 AND ls.expiry_date >= NOW() " +
            "AND ls.expiry_date <= NOW() + INTERVAL COALESCE(g.cleanup_warn_days,7) DAY", Long.class);
        // 待入库 = 未完成采购单；待出库 = 未完成销售单
        Long pendingIn = jdbc.queryForObject("SELECT COUNT(*) FROM orders WHERE type=0 AND status=0", Long.class);
        Long pendingOut = jdbc.queryForObject("SELECT COUNT(*) FROM orders WHERE type=1 AND status=0", Long.class);

        m.put("totalStock", totalStock);
        m.put("todayIn", todayIn);
        m.put("todayOut", todayOut);
        m.put("alertCount", alertCount);
        m.put("usage", usage);
        m.put("expired", expired);
        m.put("expiring", expiring);
        m.put("pendingIn", pendingIn);
        m.put("pendingOut", pendingOut);
        return Result.ok(m);
    }

    /** 库存容量图：每个仓库的已用容量单位 vs 总容量（按商品 pieces_per_cap 折算） */
    @GetMapping("/capacity")
    public Result<List<Map<String, Object>>> capacity() {
        return Result.ok(jdbc.queryForList(
            "SELECT s.name name, COALESCE(SUM(l.capacity),0) capacity, " +
            " COALESCE(SUM(u.used),0) used FROM storage s " +
            "JOIN location l ON l.storage_id=s.id " +
            "LEFT JOIN (SELECT ls.location_id lid, SUM(ls.count/GREATEST(COALESCE(g.pieces_per_cap,1),1)) used " +
            "           FROM location_stock ls JOIN goods g ON g.id=ls.goods_id GROUP BY ls.location_id) u " +
            "  ON u.lid=l.id " +
            "GROUP BY s.id, s.name HAVING capacity>0 ORDER BY s.id"));
    }

    @GetMapping("/trend")
    public Result<Map<String, Object>> trend() {
        // 按月聚合真实 record 数据，取最近 12 个有数据的月份
        List<Map<String, Object>> rows = jdbc.queryForList(
            "SELECT DATE_FORMAT(createtime,'%Y-%m') ym, " +
            " SUM(CASE WHEN type=0 THEN count ELSE 0 END) inbound, " +
            " SUM(CASE WHEN type=1 THEN count ELSE 0 END) outbound " +
            "FROM record WHERE createtime IS NOT NULL GROUP BY ym ORDER BY ym");
        int from = Math.max(0, rows.size() - 12);
        List<String> labels = new ArrayList<>();
        List<Object> inbound = new ArrayList<>();
        List<Object> outbound = new ArrayList<>();
        for (Map<String, Object> r : rows.subList(from, rows.size())) {
            labels.add((String) r.get("ym"));
            inbound.add(r.get("inbound"));
            outbound.add(r.get("outbound"));
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("labels", labels);
        m.put("inbound", inbound);
        m.put("outbound", outbound);
        return Result.ok(m);
    }

    @GetMapping("/category")
    public Result<List<Map<String, Object>>> category() {
        List<Map<String, Object>> rows = jdbc.queryForList(
            "SELECT gt.name name, COALESCE(SUM(g.count),0) value " +
            "FROM goodstype gt LEFT JOIN goods g ON g.goodsType=gt.id " +
            "GROUP BY gt.id, gt.name HAVING value > 0 ORDER BY value DESC");
        return Result.ok(rows);
    }

    /** 低库存商品（当前库存 < 安全下限），用于预警看板 */
    @GetMapping("/lowstock")
    public Result<List<Map<String, Object>>> lowstock() {
        List<Map<String, Object>> rows = jdbc.queryForList(
            "SELECT g.id, g.name, g.count, sa.min_count minCount, s.name storageName " +
            "FROM stock_alert sa " +
            "JOIN goods g ON g.id = sa.goods_id " +
            "LEFT JOIN storage s ON s.id = g.storage " +
            "WHERE sa.enabled = 1 AND g.count < sa.min_count " +
            "ORDER BY (sa.min_count - g.count) DESC");
        return Result.ok(rows);
    }
}

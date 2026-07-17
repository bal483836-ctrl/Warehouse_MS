package com.wms.controller;

import com.wms.common.Result;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 详情/档案接口：商品详情与出入库/库存历史折线（周/月/季/年）、
 * 供应商所供商品、客户销售订单及明细。全部基于真实库表聚合。
 */
@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    private final JdbcTemplate jdbc;
    public ProfileController(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    /** 商品详情：基础信息 + 安全下限 + 供应商名单 */
    @GetMapping("/goods/{id}")
    public Result<Map<String, Object>> goods(@PathVariable Integer id) {
        List<Map<String, Object>> gs = jdbc.queryForList("SELECT * FROM goods WHERE id=?", id);
        if (gs.isEmpty()) return Result.fail(404, "商品不存在");
        Map<String, Object> g = new LinkedHashMap<>(gs.get(0));
        Integer minCount = jdbc.queryForObject(
            "SELECT COALESCE(MAX(CASE WHEN enabled=1 THEN min_count END),0) FROM stock_alert WHERE goods_id=?",
            Integer.class, id);
        g.put("minCount", minCount == null ? 0 : minCount);
        List<String> suppliers = jdbc.queryForList(
            "SELECT DISTINCT s.name FROM supplier s WHERE s.id IN (" +
            "  SELECT o.supplier_id FROM orders o JOIN order_item oi ON oi.order_id=o.id WHERE o.type=0 AND oi.goods_id=? " +
            "  UNION SELECT gb.supplier_id FROM goods_batch gb WHERE gb.goods_id=?)", String.class, id, id);
        g.put("suppliers", suppliers);
        return Result.ok(g);
    }

    /** 商品出入库/库存历史折线：period = week/month/quarter/year */
    @GetMapping("/goods/{id}/history")
    public Result<Map<String, Object>> history(@PathVariable Integer id,
                                               @RequestParam(defaultValue = "month") String period) {
        String keyExpr, labelExpr; int limit;
        switch (period) {
            case "week":
                keyExpr = "YEARWEEK(createtime,3)";
                labelExpr = "DATE_FORMAT(MIN(createtime),'%m/%d')"; limit = 8; break;
            case "quarter":
                keyExpr = "CONCAT(YEAR(createtime),QUARTER(createtime))";
                labelExpr = "CONCAT(YEAR(MIN(createtime)),'Q',QUARTER(MIN(createtime)))"; limit = 8; break;
            case "year":
                keyExpr = "YEAR(createtime)";
                labelExpr = "DATE_FORMAT(MIN(createtime),'%Y')"; limit = 5; break;
            default:
                period = "month";
                keyExpr = "DATE_FORMAT(createtime,'%Y%m')";
                labelExpr = "DATE_FORMAT(MIN(createtime),'%Y-%m')"; limit = 12;
        }
        List<Map<String, Object>> rows = jdbc.queryForList(
            "SELECT " + keyExpr + " k, " + labelExpr + " lbl, " +
            " SUM(CASE WHEN type=0 THEN count ELSE 0 END) inb, " +
            " SUM(CASE WHEN type=1 THEN count ELSE 0 END) outb " +
            "FROM record WHERE goods=? AND createtime IS NOT NULL GROUP BY k ORDER BY k", id);
        int from = Math.max(0, rows.size() - limit);
        rows = rows.subList(from, rows.size());

        int n = rows.size();
        List<String> labels = new ArrayList<>();
        long[] inb = new long[n], outb = new long[n], stock = new long[n];
        for (int i = 0; i < n; i++) {
            labels.add(String.valueOf(rows.get(i).get("lbl")));
            inb[i] = num(rows.get(i).get("inb"));
            outb[i] = num(rows.get(i).get("outb"));
        }
        // 以当前库存为基准，向前回推每个周期末的库存
        Long cur = jdbc.queryForObject("SELECT COALESCE(count,0) FROM goods WHERE id=?", Long.class, id);
        long running = cur == null ? 0 : cur;
        for (int i = n - 1; i >= 0; i--) { stock[i] = running; running -= (inb[i] - outb[i]); }

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("period", period);
        m.put("labels", labels);
        m.put("inbound", boxed(inb));
        m.put("outbound", boxed(outb));
        m.put("stock", boxed(stock));
        return Result.ok(m);
    }

    /** 供应商所供商品（采购订单 + 批次记录推导） */
    @GetMapping("/supplier/{id}/goods")
    public Result<List<Map<String, Object>>> supplierGoods(@PathVariable Integer id) {
        return Result.ok(jdbc.queryForList(
            "SELECT g.id, g.name, g.count, g.zone, g.image, " +
            " COALESCE(MAX(CASE WHEN sa.enabled=1 THEN sa.min_count END),0) minCount " +
            "FROM goods g LEFT JOIN stock_alert sa ON sa.goods_id=g.id " +
            "WHERE g.id IN (" +
            "  SELECT oi.goods_id FROM orders o JOIN order_item oi ON oi.order_id=o.id WHERE o.type=0 AND o.supplier_id=? " +
            "  UNION SELECT gb.goods_id FROM goods_batch gb WHERE gb.supplier_id=?) " +
            "GROUP BY g.id ORDER BY g.id", id, id));
    }

    /** 客户的所有销售订单 + 每单明细 */
    @GetMapping("/customer/{id}/orders")
    public Result<List<Map<String, Object>>> customerOrders(@PathVariable Integer id) {
        List<Map<String, Object>> orders = jdbc.queryForList(
            "SELECT id, order_no orderNo, status, total_amount totalAmount, order_time orderTime " +
            "FROM orders WHERE type=1 AND customer_id=? ORDER BY id DESC", id);
        for (Map<String, Object> o : orders) {
            Object oid = o.get("id");
            o.put("items", jdbc.queryForList(
                "SELECT oi.goods_id goodsId, g.name goodsName, oi.count, oi.price " +
                "FROM order_item oi LEFT JOIN goods g ON g.id=oi.goods_id WHERE oi.order_id=? ORDER BY oi.id", oid));
        }
        return Result.ok(orders);
    }

    private static long num(Object o) { return o == null ? 0 : ((Number) o).longValue(); }
    private static List<Long> boxed(long[] a) { List<Long> l = new ArrayList<>(); for (long v : a) l.add(v); return l; }
}

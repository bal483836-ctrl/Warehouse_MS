package com.wms.controller;

import com.wms.common.Result;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 系统提示（右上角铃铛）：由真实数据实时生成——
 *  - 补货提示：库存低于安全下限的商品，需进货
 *  - 清理提示：临近/超过保质期的货位批次，需清理
 */
@RestController
@RequestMapping("/api/notices")
public class NoticeController {

    private final JdbcTemplate jdbc;
    public NoticeController(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @GetMapping
    public Result<List<Map<String, Object>>> notices() {
        List<Map<String, Object>> list = new ArrayList<>();

        // 1) 补货提示
        for (Map<String, Object> r : jdbc.queryForList(
                "SELECT g.id, g.name, g.count, sa.min_count minc " +
                "FROM stock_alert sa JOIN goods g ON g.id=sa.goods_id " +
                "WHERE sa.enabled=1 AND g.count < sa.min_count ORDER BY (sa.min_count-g.count) DESC")) {
            Map<String, Object> n = new LinkedHashMap<>();
            n.put("type", "restock");
            n.put("level", "warn");
            n.put("goodsId", r.get("id"));
            n.put("title", "补货提示");
            n.put("text", "「" + r.get("name") + "」库存 " + r.get("count") + "，低于安全下限 " + r.get("minc") + "，需及时进货");
            list.add(n);
        }

        // 2) 清理提示（临期/过期批次）
        for (Map<String, Object> r : jdbc.queryForList(
                "SELECT g.id gid, g.name gname, ls.count qty, l.code code, ls.expiry_date expiry, " +
                " DATEDIFF(ls.expiry_date, NOW()) days " +
                "FROM location_stock ls JOIN goods g ON g.id=ls.goods_id JOIN location l ON l.id=ls.location_id " +
                "WHERE ls.expiry_date IS NOT NULL AND ls.count>0 " +
                "  AND ls.expiry_date <= NOW() + INTERVAL COALESCE(g.cleanup_warn_days,7) DAY " +
                "ORDER BY ls.expiry_date ASC")) {
            long days = r.get("days") == null ? 0 : ((Number) r.get("days")).longValue();
            Map<String, Object> n = new LinkedHashMap<>();
            n.put("type", "cleanup");
            n.put("level", days < 0 ? "crit" : "warn");
            n.put("goodsId", r.get("gid"));
            String when = days < 0 ? ("已过期 " + (-days) + " 天") : (days == 0 ? "今日到期" : ("将于 " + days + " 天后到期"));
            n.put("title", "清理提示");
            n.put("text", "货位 " + r.get("code") + " 的「" + r.get("gname") + "」(" + r.get("qty") + ") " + when + "，需清理");
            list.add(n);
        }
        return Result.ok(list);
    }
}

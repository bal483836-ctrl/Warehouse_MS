package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.common.Result;
import com.wms.entity.Location;
import com.wms.repo.LocationRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/location")
public class LocationController extends BaseController<Location> {
    private final LocationRepo repo;
    private final JdbcTemplate jdbc;
    public LocationController(LocationRepo repo, JdbcTemplate jdbc) { this.repo = repo; this.jdbc = jdbc; }
    @Override protected JpaRepository<Location, Integer> repo() { return repo; }

    /** 货位看板：每个库位的容量、已存商品明细、已用量、剩余容量 */
    @GetMapping("/board")
    public Result<List<Map<String, Object>>> board() {
        List<Map<String, Object>> locs = jdbc.queryForList(
            "SELECT l.id, l.code, l.name, l.zone, l.capacity, s.name storageName " +
            "FROM location l LEFT JOIN storage s ON s.id=l.storage_id ORDER BY s.name, l.zone, l.row_no");
        // 每个库位存了什么（商品名 + 数量 + 到期日）
        Map<Integer, List<Map<String, Object>>> items = new HashMap<>();
        Map<Integer, Double> usedUnits = new HashMap<>();   // 折算后的容量占用
        for (Map<String, Object> r : jdbc.queryForList(
                "SELECT ls.location_id lid, g.name gname, SUM(ls.count) qty, MIN(ls.expiry_date) expiry, " +
                " SUM(ls.count/GREATEST(COALESCE(g.pieces_per_cap,1),1)) units " +
                "FROM location_stock ls JOIN goods g ON g.id=ls.goods_id " +
                "GROUP BY ls.location_id, g.name")) {
            int lid = ((Number) r.get("lid")).intValue();
            long qty = ((Number) r.get("qty")).longValue();
            double units = r.get("units") == null ? 0 : ((Number) r.get("units")).doubleValue();
            Map<String, Object> it = new LinkedHashMap<>();
            it.put("name", r.get("gname"));
            it.put("qty", qty);
            it.put("expiry", r.get("expiry"));
            items.computeIfAbsent(lid, k -> new ArrayList<>()).add(it);
            usedUnits.merge(lid, units, Double::sum);
        }
        for (Map<String, Object> l : locs) {
            int id = ((Number) l.get("id")).intValue();
            long cap = l.get("capacity") == null ? 0 : ((Number) l.get("capacity")).longValue();
            long u = Math.round(usedUnits.getOrDefault(id, 0.0));
            l.put("items", items.getOrDefault(id, List.of()));
            l.put("used", u);
            l.put("remain", Math.max(0, cap - u));
            l.put("usage", cap > 0 ? Math.round(u * 100.0 / cap) : 0);
        }
        return Result.ok(locs);
    }
}

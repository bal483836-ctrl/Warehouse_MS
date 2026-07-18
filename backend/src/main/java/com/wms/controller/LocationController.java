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

    /** 分区编码前缀：用于自动生成库位编码。 */
    private String zonePrefix(String zone) {
        String z = (zone == null) ? "" : zone.trim();
        switch (z) {
            case "冷冻": return "LD";
            case "冰鲜": return "BX";
            case "普通": return "PT";
            default:     return "QT"; // 其它/未分区
        }
    }

    /**
     * 根据「所属仓库 + 分区」自动推算下一个库位编码（避免与现有编码冲突），
     * 同时给出建议的「排/列」。前端新建库位时选好仓库与分区即自动带出。
     * 编码格式：{分区前缀}-{仓库id}-{两位序号}，如 PT-2-03。
     */
    @GetMapping("/next-code")
    public Result<Map<String, Object>> nextCode(@RequestParam Integer storageId,
                                                @RequestParam(required = false) String zone) {
        String z = (zone == null || zone.trim().isEmpty()) ? "普通" : zone.trim();
        Map<String, Object> m = new LinkedHashMap<>();
        m.putAll(suggestCode(storageId, z));
        return Result.ok(m);
    }

    private Map<String, Object> suggestCode(Integer storageId, String zone) {
        String prefix = zonePrefix(zone);
        Integer cnt = jdbc.queryForObject(
            "SELECT COUNT(*) FROM location WHERE storage_id=? AND COALESCE(TRIM(zone),'')=?",
            Integer.class, storageId, zone);
        int seq = (cnt == null ? 0 : cnt) + 1;
        String code;
        while (true) {
            code = String.format("%s-%d-%02d", prefix, storageId == null ? 0 : storageId, seq);
            Integer exists = jdbc.queryForObject("SELECT COUNT(*) FROM location WHERE code=?", Integer.class, code);
            if (exists == null || exists == 0) break;
            seq++;
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("code", code);
        m.put("zone", zone);
        m.put("rowNo", seq);
        m.put("colNo", 1);
        return m;
    }

    /** 新增库位：编码/排/列/容量为空时自动补齐（编码按仓库+分区自动生成）。 */
    @Override
    @PostMapping
    public Result<Location> create(@RequestBody Location loc) {
        if (loc.getZone() == null || loc.getZone().trim().isEmpty()) loc.setZone("普通");
        if (loc.getCapacity() == null) loc.setCapacity(500);
        if (loc.getCode() == null || loc.getCode().trim().isEmpty()) {
            Map<String, Object> s = suggestCode(loc.getStorageId(), loc.getZone().trim());
            loc.setCode((String) s.get("code"));
            if (loc.getRowNo() == null) loc.setRowNo((Integer) s.get("rowNo"));
            if (loc.getColNo() == null) loc.setColNo((Integer) s.get("colNo"));
        }
        if (loc.getName() == null || loc.getName().trim().isEmpty())
            loc.setName(loc.getZone().trim() + "区-" + loc.getCode());
        return Result.ok(repo.save(loc));
    }

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

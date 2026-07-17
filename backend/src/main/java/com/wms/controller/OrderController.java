package com.wms.controller;

import com.wms.common.Result;
import com.wms.entity.OrderItem;
import com.wms.entity.OrderMain;
import com.wms.repo.OrderItemRepo;
import com.wms.repo.OrderRepo;
import com.wms.security.TokenStore;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 订单管理：采购订单(type=0) 与 销售订单(type=1)。
 * 采购订单关联供应商；销售订单面向门店/买家(toC)，记录买家与经手账号。
 * 销售订单不可删除，只能「取消」（需填原因）。
 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepo orderRepo;
    private final OrderItemRepo itemRepo;
    private final JdbcTemplate jdbc;

    public OrderController(OrderRepo orderRepo, OrderItemRepo itemRepo, JdbcTemplate jdbc) {
        this.orderRepo = orderRepo;
        this.itemRepo = itemRepo;
        this.jdbc = jdbc;
    }

    public record OrderReq(String orderNo, Integer type, Integer supplierId, Integer customerId,
                           String buyer, Integer status, LocalDateTime orderTime, String remark,
                           List<OrderItem> items) {}
    public record CancelReq(String reason) {}

    /** 列表（可按 type 过滤），含明细数量、买家/经手/供应商名 */
    @GetMapping
    public Result<List<Map<String, Object>>> list(@RequestParam(required = false) Integer type) {
        List<OrderMain> orders = (type == null) ? orderRepo.findAll() : orderRepo.findByTypeOrderByIdDesc(type);
        orders.sort((a, b) -> b.getId() - a.getId());
        Map<Integer, String> users = userNames();
        List<Map<String, Object>> out = new ArrayList<>();
        for (OrderMain o : orders) {
            List<OrderItem> items = itemRepo.findByOrderIdOrderByIdAsc(o.getId());
            Map<String, Object> m = toMap(o);
            m.put("items", items);
            m.put("itemCount", items.size());
            m.put("totalQty", items.stream().mapToInt(i -> i.getCount() == null ? 0 : i.getCount()).sum());
            m.put("operatorName", o.getOperatorId() == null ? null : users.get(o.getOperatorId()));
            out.add(m);
        }
        return Result.ok(out);
    }

    @GetMapping("/{id}")
    public Result<Map<String, Object>> get(@PathVariable Integer id) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.fail(404, "订单不存在");
        Map<String, Object> m = toMap(o);
        m.put("items", itemRepo.findByOrderIdOrderByIdAsc(id));
        m.put("operatorName", o.getOperatorId() == null ? null : userNames().get(o.getOperatorId()));
        return Result.ok(m);
    }

    @PostMapping
    @Transactional
    public Result<OrderMain> create(@RequestBody OrderReq req, HttpServletRequest http) {
        OrderMain o = new OrderMain();
        apply(o, req);
        if (o.getOrderNo() == null || o.getOrderNo().isBlank()) o.setOrderNo(genNo(req.type()));
        if (o.getOrderTime() == null) o.setOrderTime(LocalDateTime.now());
        if (o.getStatus() == null) o.setStatus(0);
        TokenStore.Principal p = (TokenStore.Principal) http.getAttribute("principal");
        if (o.getOperatorId() == null && p != null) o.setOperatorId(p.userId());
        o = orderRepo.save(o);
        saveItems(o, req.items());
        return Result.ok(o);
    }

    @PutMapping("/{id}")
    @Transactional
    public Result<OrderMain> update(@PathVariable Integer id, @RequestBody OrderReq req) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.fail(404, "订单不存在");
        if (o.getStatus() != null && o.getStatus() == 2) return Result.fail("订单已取消，不能修改");
        apply(o, req);
        o = orderRepo.save(o);
        if (req.items() != null) { itemRepo.deleteByOrderId(id); saveItems(o, req.items()); }
        return Result.ok(o);
    }

    /** 取消订单（需填原因），状态置为已取消 */
    @PostMapping("/{id}/cancel")
    @Transactional
    public Result<OrderMain> cancel(@PathVariable Integer id, @RequestBody CancelReq req) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.fail(404, "订单不存在");
        if (req == null || req.reason() == null || req.reason().trim().isEmpty())
            return Result.fail("请填写取消原因");
        o.setStatus(2);
        o.setCancelReason(req.reason().trim());
        o.setCancelTime(LocalDateTime.now());
        return Result.ok(orderRepo.save(o));
    }

    /** 删除：销售订单不可删除（只能取消） */
    @DeleteMapping("/{id}")
    @Transactional
    public Result<Void> delete(@PathVariable Integer id) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.ok();
        if (o.getType() != null && o.getType() == 1) return Result.fail("销售订单不可删除，请使用「取消」");
        itemRepo.deleteByOrderId(id);
        orderRepo.deleteById(id);
        return Result.ok();
    }

    /* ---------- helpers ---------- */
    private void apply(OrderMain o, OrderReq req) {
        if (req.orderNo() != null) o.setOrderNo(req.orderNo());
        if (req.type() != null) o.setType(req.type());
        o.setSupplierId(req.supplierId());
        o.setCustomerId(req.customerId());
        o.setBuyer(req.buyer());
        if (req.status() != null) o.setStatus(req.status());
        if (req.orderTime() != null) o.setOrderTime(req.orderTime());
        o.setRemark(req.remark());
    }

    private void saveItems(OrderMain o, List<OrderItem> items) {
        BigDecimal total = BigDecimal.ZERO;
        if (items != null) {
            for (OrderItem it : items) {
                if (it.getGoodsId() == null || it.getCount() == null) continue;
                it.setId(null);
                it.setOrderId(o.getId());
                BigDecimal price = it.getPrice() == null ? BigDecimal.ZERO : it.getPrice();
                total = total.add(price.multiply(BigDecimal.valueOf(it.getCount())));
                itemRepo.save(it);
            }
        }
        o.setTotalAmount(total);
        orderRepo.save(o);
    }

    private Map<Integer, String> userNames() {
        Map<Integer, String> m = new HashMap<>();
        for (Map<String, Object> r : jdbc.queryForList("SELECT id, name FROM sys_user"))
            m.put(((Number) r.get("id")).intValue(), (String) r.get("name"));
        return m;
    }

    private String genNo(Integer type) {
        String prefix = (type != null && type == 1) ? "SO" : "PO";
        return prefix + new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
    }

    private Map<String, Object> toMap(OrderMain o) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", o.getId());
        m.put("orderNo", o.getOrderNo());
        m.put("type", o.getType());
        m.put("supplierId", o.getSupplierId());
        m.put("customerId", o.getCustomerId());
        m.put("buyer", o.getBuyer());
        m.put("operatorId", o.getOperatorId());
        m.put("status", o.getStatus());
        m.put("totalAmount", o.getTotalAmount());
        m.put("orderTime", o.getOrderTime());
        m.put("cancelReason", o.getCancelReason());
        m.put("cancelTime", o.getCancelTime());
        m.put("remark", o.getRemark());
        return m;
    }
}

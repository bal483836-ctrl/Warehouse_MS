package com.wms.controller;

import com.wms.common.Result;
import com.wms.entity.OrderItem;
import com.wms.entity.OrderMain;
import com.wms.repo.OrderItemRepo;
import com.wms.repo.OrderRepo;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 订单管理：采购订单(type=0) 与 销售订单(type=1)。
 * 一张订单含多条明细(order_item)，打通 供应商→采购入库→订单→客户→销售出库 链路。
 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepo orderRepo;
    private final OrderItemRepo itemRepo;

    public OrderController(OrderRepo orderRepo, OrderItemRepo itemRepo) {
        this.orderRepo = orderRepo;
        this.itemRepo = itemRepo;
    }

    /** 提交体：订单主信息 + 明细行 */
    public record OrderReq(String orderNo, Integer type, Integer supplierId, Integer customerId,
                           Integer status, LocalDateTime orderTime, String remark, List<OrderItem> items) {}

    /** 列表（可按 type 过滤：0采购 / 1销售），返回每单明细数量与合计 */
    @GetMapping
    public Result<List<Map<String, Object>>> list(@RequestParam(required = false) Integer type) {
        List<OrderMain> orders = (type == null) ? orderRepo.findAll() : orderRepo.findByTypeOrderByIdDesc(type);
        orders.sort((a, b) -> b.getId() - a.getId());
        List<Map<String, Object>> out = new ArrayList<>();
        for (OrderMain o : orders) {
            List<OrderItem> items = itemRepo.findByOrderIdOrderByIdAsc(o.getId());
            Map<String, Object> m = toMap(o);
            m.put("itemCount", items.size());
            m.put("totalQty", items.stream().mapToInt(i -> i.getCount() == null ? 0 : i.getCount()).sum());
            out.add(m);
        }
        return Result.ok(out);
    }

    /** 单条订单（含明细） */
    @GetMapping("/{id}")
    public Result<Map<String, Object>> get(@PathVariable Integer id) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.fail(404, "订单不存在");
        Map<String, Object> m = toMap(o);
        m.put("items", itemRepo.findByOrderIdOrderByIdAsc(id));
        return Result.ok(m);
    }

    /** 某订单的明细 */
    @GetMapping("/{id}/items")
    public Result<List<OrderItem>> items(@PathVariable Integer id) {
        return Result.ok(itemRepo.findByOrderIdOrderByIdAsc(id));
    }

    @PostMapping
    @Transactional
    public Result<OrderMain> create(@RequestBody OrderReq req) {
        OrderMain o = new OrderMain();
        apply(o, req);
        if (o.getOrderNo() == null || o.getOrderNo().isBlank()) o.setOrderNo(genNo(req.type()));
        if (o.getOrderTime() == null) o.setOrderTime(LocalDateTime.now());
        if (o.getStatus() == null) o.setStatus(0);
        o = orderRepo.save(o);
        saveItems(o, req.items());
        return Result.ok(o);
    }

    @PutMapping("/{id}")
    @Transactional
    public Result<OrderMain> update(@PathVariable Integer id, @RequestBody OrderReq req) {
        OrderMain o = orderRepo.findById(id).orElse(null);
        if (o == null) return Result.fail(404, "订单不存在");
        apply(o, req);
        o = orderRepo.save(o);
        if (req.items() != null) { itemRepo.deleteByOrderId(id); saveItems(o, req.items()); }
        return Result.ok(o);
    }

    @DeleteMapping("/{id}")
    @Transactional
    public Result<Void> delete(@PathVariable Integer id) {
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
        m.put("status", o.getStatus());
        m.put("totalAmount", o.getTotalAmount());
        m.put("orderTime", o.getOrderTime());
        m.put("remark", o.getRemark());
        return m;
    }
}

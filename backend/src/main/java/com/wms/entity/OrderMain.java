package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * 订单主表：打通「供应商 → 采购入库 → 订单 → 客户 → 销售出库」链路。
 * type=0 采购订单（关联供应商，配合入库）；type=1 销售订单（关联客户，配合出库）。
 */
@Data
@Entity
@Table(name = "orders")
public class OrderMain {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "order_no")
    private String orderNo;
    /** 0 采购订单，1 销售订单 */
    @Column(name = "type")
    private Integer type;
    @Column(name = "supplier_id")
    private Integer supplierId;
    @Column(name = "customer_id")
    private Integer customerId;
    /** 0 待处理，1 已完成，2 已取消 */
    @Column(name = "status")
    private Integer status;
    @Column(name = "total_amount")
    private java.math.BigDecimal totalAmount;
    @Column(name = "order_time")
    private java.time.LocalDateTime orderTime;
    @Column(name = "remark")
    private String remark;
}

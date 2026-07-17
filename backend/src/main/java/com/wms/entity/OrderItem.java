package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

/** 订单明细：一张订单包含多条商品行。 */
@Data
@Entity
@Table(name = "order_item")
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "order_id")
    private Integer orderId;
    @Column(name = "goods_id")
    private Integer goodsId;
    @Column(name = "count")
    private Integer count;
    @Column(name = "price")
    private java.math.BigDecimal price;
    @Column(name = "remark")
    private String remark;
}

package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "stock_alert")
public class StockAlert {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "goods_id")
    private Integer goodsId;
    @Column(name = "min_count")
    private Integer minCount;
    @Column(name = "max_count")
    private Integer maxCount;
    @Column(name = "enabled")
    private Integer enabled;
    @Column(name = "remark")
    private String remark;
}

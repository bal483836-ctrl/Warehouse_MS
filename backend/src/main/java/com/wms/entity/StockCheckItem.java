package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "stock_check_item")
public class StockCheckItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "check_id")
    private Integer checkId;
    @Column(name = "goods_id")
    private Integer goodsId;
    @Column(name = "system_count")
    private Integer systemCount;
    @Column(name = "actual_count")
    private Integer actualCount;
    @Column(name = "diff_count")
    private Integer diffCount;
    @Column(name = "remark")
    private String remark;
}

package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "goods_batch")
public class GoodsBatch {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "goods_id")
    private Integer goodsId;
    @Column(name = "batch_no")
    private String batchNo;
    @Column(name = "supplier_id")
    private Integer supplierId;
    @Column(name = "production_date")
    private java.time.LocalDate productionDate;
    @Column(name = "expiry_date")
    private java.time.LocalDate expiryDate;
    @Column(name = "count")
    private Integer count;
    @Column(name = "remark")
    private String remark;
    @Column(name = "create_time")
    private java.time.LocalDateTime createTime;
}

package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "stock_check")
public class StockCheck {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "check_no")
    private String checkNo;
    @Column(name = "storage_id")
    private Integer storageId;
    @Column(name = "user_id")
    private Integer userId;
    @Column(name = "status")
    private Integer status;
    @Column(name = "check_time")
    private java.time.LocalDateTime checkTime;
    @Column(name = "remark")
    private String remark;
}

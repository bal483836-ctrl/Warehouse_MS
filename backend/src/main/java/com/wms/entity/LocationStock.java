package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "location_stock")
public class LocationStock {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "location_id")
    private Integer locationId;
    @Column(name = "goods_id")
    private Integer goodsId;
    @Column(name = "count")
    private Integer count;
    @Column(name = "inbound_date")
    private java.time.LocalDateTime inboundDate;
    @Column(name = "expiry_date")
    private java.time.LocalDateTime expiryDate;
}

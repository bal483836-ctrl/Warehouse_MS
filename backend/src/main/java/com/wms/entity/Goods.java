package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "goods")
public class Goods {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    @Column(name = "storage")
    private Integer storage;
    @Column(name = "goodsType")
    private Integer goodsType;
    @Column(name = "count")
    private Integer count;
    @Column(name = "remark")
    private String remark;
}

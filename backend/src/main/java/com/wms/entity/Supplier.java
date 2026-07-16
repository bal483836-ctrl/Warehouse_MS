package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "supplier")
public class Supplier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    @Column(name = "contact")
    private String contact;
    @Column(name = "phone")
    private String phone;
    @Column(name = "email")
    private String email;
    @Column(name = "address")
    private String address;
    @Column(name = "remark")
    private String remark;
    @Column(name = "del_flag")
    private Integer delFlag;
    @Column(name = "create_time")
    private java.time.LocalDateTime createTime;
    @Column(name = "create_by")
    private String createBy;
    @Column(name = "update_time")
    private java.time.LocalDateTime updateTime;
    @Column(name = "update_by")
    private String updateBy;
}

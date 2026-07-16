package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_user")
public class SysUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    @Column(name = "number")
    private String number;
    @Column(name = "password")
    private String password;
    @Column(name = "salt")
    private String salt;
    @Column(name = "age")
    private Integer age;
    @Column(name = "sex")
    private String sex;
    @Column(name = "phone")
    private String phone;
    @Column(name = "locked")
    private Integer locked;
    @Column(name = "loginsign")
    private Integer loginsign;
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

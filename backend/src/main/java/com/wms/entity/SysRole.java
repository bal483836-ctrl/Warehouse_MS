package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_role")
public class SysRole {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    @Column(name = "description")
    private String description;
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

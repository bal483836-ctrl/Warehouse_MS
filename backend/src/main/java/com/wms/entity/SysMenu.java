package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_menu")
public class SysMenu {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    @Column(name = "parent_id")
    private Integer parentId;
    @Column(name = "code")
    private String code;
    @Column(name = "icon")
    private String icon;
    @Column(name = "url")
    private String url;
    @Column(name = "type")
    private Integer type;
    @Column(name = "description")
    private String description;
    @Column(name = "sort")
    private Integer sort;
    @Column(name = "is_hidden_menu")
    private Integer isHiddenMenu;
    @Column(name = "is_option_menu")
    private Integer isOptionMenu;
    @Column(name = "component")
    private String component;
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

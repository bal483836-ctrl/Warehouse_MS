package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_notice")
public class SysNotice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "title")
    private String title;
    @Column(name = "content")
    private String content;
    @Column(name = "type")
    private Integer type;
    @Column(name = "status")
    private Integer status;
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

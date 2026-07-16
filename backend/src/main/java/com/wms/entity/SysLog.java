package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_log")
public class SysLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "content")
    private String content;
    @Column(name = "ip_addr")
    private String ipAddr;
    @Column(name = "user_id")
    private String userId;
    @Column(name = "create_time")
    private java.time.LocalDateTime createTime;
    @Column(name = "data")
    private String data;
    @Column(name = "methods")
    private String methods;
    @Column(name = "result")
    private String result;
    @Column(name = "duration")
    private Integer duration;
}

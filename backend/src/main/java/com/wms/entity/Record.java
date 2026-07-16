package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "record")
public class Record {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "goods")
    private Integer goods;
    @Column(name = "user_id")
    private Integer userId;
    @Column(name = "count")
    private Integer count;
    @Column(name = "createtime")
    private java.time.LocalDateTime createtime;
    @Column(name = "remark")
    private String remark;
    @Column(name = "type")
    private Integer type;
}

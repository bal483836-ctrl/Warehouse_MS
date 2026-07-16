package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "location")
public class Location {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "storage_id")
    private Integer storageId;
    @Column(name = "code")
    private String code;
    @Column(name = "name")
    private String name;
    @Column(name = "remark")
    private String remark;
    @Column(name = "zone")
    private String zone;
    @Column(name = "row_no")
    private Integer rowNo;
    @Column(name = "col_no")
    private Integer colNo;
    @Column(name = "capacity")
    private Integer capacity;
}

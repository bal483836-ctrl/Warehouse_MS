package com.wms.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "goodstype")
public class Goodstype {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;
    @Column(name = "name")
    private String name;
    /** 该分类商品默认放入的仓库 */
    @Column(name = "storage_id")
    private Integer storageId;
    @Column(name = "remark")
    private String remark;
}

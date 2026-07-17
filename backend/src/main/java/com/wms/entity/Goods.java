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
    /** 存储分区：冷冻 / 冰鲜 / 普通，决定该商品只能放入同分区库位 */
    @Column(name = "zone")
    private String zone;
    /** 商品图片（data URL 或相对路径），Batch3 详情页使用 */
    @Column(name = "image")
    private String image;
    /** 保质期天数（空=不易过期） */
    @Column(name = "shelf_life_days")
    private Integer shelfLifeDays;
    /** 到期前多少天预警清理 */
    @Column(name = "cleanup_warn_days")
    private Integer cleanupWarnDays;
    @Column(name = "remark")
    private String remark;
}

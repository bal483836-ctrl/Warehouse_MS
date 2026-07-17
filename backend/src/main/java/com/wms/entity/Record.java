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
    /** 关联订单id（采购/销售订单），打通 供应商→入库→订单→客户→出库 链路 */
    @Column(name = "order_id")
    private Integer orderId;
    /** 入库单据/收货凭证图片（data URL 或相对路径），仅入库可选填 */
    @Column(name = "image")
    private String image;
}

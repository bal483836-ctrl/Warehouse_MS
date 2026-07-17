package com.wms.entity;

import lombok.*;
import lombok.experimental.Accessors;
import java.io.Serializable;
import java.util.Date;

/** 出入库流水实体，对应 record 表。type：0 入库，1 出库。 */
@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)
public class Record implements Serializable {
    private Integer id;
    private Integer goods;       // 货品 id
    private Integer userId;      // 操作人 id
    private Integer count;       // 数量
    private Date createtime;     // 操作时间
    private String remark;
    private Integer type;        // 0 入库 / 1 出库

    // 非数据库字段：展示用
    private String goodsName;
    private String userName;
}

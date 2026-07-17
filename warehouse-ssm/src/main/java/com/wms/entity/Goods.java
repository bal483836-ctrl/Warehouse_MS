package com.wms.entity;

import lombok.*;
import lombok.experimental.Accessors;
import java.io.Serializable;

/** 商品实体，对应 goods 表。 */
@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)
public class Goods implements Serializable {
    private Integer id;
    private String name;
    private Integer storage;     // 所属仓库 id
    private Integer goodsType;   // 分类 id
    private Integer count;       // 库存数量
    private String remark;

    // 非数据库字段：关联查询出的仓库名、分类名，用于列表/详情展示
    private String storageName;
    private String goodsTypeName;
}

package com.wms.entity;

import lombok.*;
import lombok.experimental.Accessors;
import java.io.Serializable;

/** 商品分类实体，对应 goodstype 表。 */
@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)
public class Goodstype implements Serializable {
    private Integer id;
    private String name;
    private String remark;
}

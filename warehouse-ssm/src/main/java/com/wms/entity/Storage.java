package com.wms.entity;

import lombok.*;
import lombok.experimental.Accessors;
import java.io.Serializable;

/** 仓库实体，对应 storage 表。 */
@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)
public class Storage implements Serializable {
    private Integer id;
    private String name;
    private String remark;
}

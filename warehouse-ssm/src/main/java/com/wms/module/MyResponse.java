package com.wms.module;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;

/** 统一业务返回对象（对应参考项目 MyResponse）。 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Accessors(chain = true)
public class MyResponse implements Serializable {
    private Integer code = 200;        // 响应码
    private String msg = "";           // 处理结果消息
    private Boolean success = false;   // 业务是否成功
    private Object tag;                // 返回的数据对象
}

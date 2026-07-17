package com.wms.entity;

import lombok.*;
import lombok.experimental.Accessors;
import java.io.Serializable;

/** 用户实体，对应 sys_user 表（登录用）。 */
@Data @AllArgsConstructor @NoArgsConstructor @Accessors(chain = true)
public class SysUser implements Serializable {
    private Integer id;
    private String name;
    private String number;   // 登录账号
    private String password; // 散列后的密码
    private String salt;     // 盐
    private Integer age;
    private String sex;
    private String phone;
    private Integer locked;  // 是否锁定 1是0否
    private Integer loginsign;
    private Integer delFlag;
}

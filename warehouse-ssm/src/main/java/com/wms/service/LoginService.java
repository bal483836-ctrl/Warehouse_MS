package com.wms.service;

import com.wms.module.MyResponse;

public interface LoginService {
    /** 登录：校验账号、锁定状态、加盐散列密码。 */
    MyResponse login(String number, String password);
}

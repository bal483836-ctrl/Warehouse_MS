package com.wms.service.impl;

import com.wms.dao.SysUserDao;
import com.wms.entity.SysUser;
import com.wms.module.MyResponse;
import com.wms.service.LoginService;
import com.wms.utils.MD5Util;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@Slf4j
public class LoginServiceImpl implements LoginService {

    @Autowired
    private SysUserDao sysUserDao;

    @Override
    public MyResponse login(String number, String password) {
        log.info("=========LoginServiceImpl=========login=========");
        MyResponse result = new MyResponse();
        SysUser user = sysUserDao.selectByNumber(number);
        if (user == null || user.getId() == null) {
            result.setMsg("用户名或密码错误");
            return result;
        }
        if (user.getDelFlag() != null && user.getDelFlag() == 1) {
            result.setMsg("账号已删除");
            return result;
        }
        if (user.getLocked() != null && user.getLocked() == 1) {
            result.setMsg("账号已被锁定，请联系管理员");
            return result;
        }
        String hashed = MD5Util.hashPassword(password, user.getSalt());
        if (hashed.equalsIgnoreCase(user.getPassword())) {
            result.setMsg("登录成功");
            result.setSuccess(true);
            result.setTag(user);
        } else {
            result.setMsg("用户名或密码错误");
        }
        return result;
    }
}

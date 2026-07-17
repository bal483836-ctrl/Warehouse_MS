package com.wms.dao;

import com.wms.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import static com.wms.util.common.WmsConstants.USER_TABLE;

/** 用户 DAO（登录用）。 */
@Mapper
public interface SysUserDao {
    @Select("select * from " + USER_TABLE + " where number = #{number}")
    SysUser selectByNumber(String number);
}

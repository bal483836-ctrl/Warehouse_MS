package com.wms.utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/** 口令散列工具：方案 md5(md5(password) + salt)，与 sys_user 表已有数据一致。 */
public class MD5Util {

    public static String md5(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] d = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /** 加盐散列：md5(md5(明文密码) + 盐) */
    public static String hashPassword(String rawPassword, String salt) {
        return md5(md5(rawPassword) + salt);
    }
}

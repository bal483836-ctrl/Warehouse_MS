package com.wms.common;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class Md5Util {
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

    /** 系统口令散列方案：md5(md5(password) + salt) */
    public static String hashPassword(String rawPassword, String salt) {
        return md5(md5(rawPassword) + salt);
    }
}

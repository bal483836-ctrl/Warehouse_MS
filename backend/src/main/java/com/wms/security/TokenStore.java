package com.wms.security;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/** 简单的内存 token 存储：token -> 用户信息 */
@Component
public class TokenStore {
    public record Principal(Integer userId, String name, String number) {}

    private final Map<String, Principal> tokens = new ConcurrentHashMap<>();

    public String issue(Principal p) {
        String token = UUID.randomUUID().toString().replace("-", "");
        tokens.put(token, p);
        return token;
    }

    public Principal resolve(String token) {
        return token == null ? null : tokens.get(token);
    }

    public void revoke(String token) {
        if (token != null) tokens.remove(token);
    }
}

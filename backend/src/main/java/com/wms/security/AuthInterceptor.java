package com.wms.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.common.Result;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/** 校验请求头中的 token（登录接口与静态资源放行） */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final TokenStore tokenStore;
    private final ObjectMapper mapper = new ObjectMapper();

    public AuthInterceptor(TokenStore tokenStore) { this.tokenStore = tokenStore; }

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse resp, Object handler) throws Exception {
        String token = req.getHeader("token");
        if (token == null) token = req.getHeader("Authorization");
        TokenStore.Principal p = tokenStore.resolve(token);
        if (p == null) {
            resp.setStatus(401);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(mapper.writeValueAsString(Result.fail(401, "未登录或登录已过期")));
            return false;
        }
        req.setAttribute("principal", p);
        return true;
    }
}

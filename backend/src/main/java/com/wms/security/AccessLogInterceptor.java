package com.wms.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 操作日志：对写操作(POST/PUT/DELETE)真实落库到 sys_log，
 * 使「操作日志」页面显示真实可用的操作记录。
 */
@Component
public class AccessLogInterceptor implements HandlerInterceptor {

    private final JdbcTemplate jdbc;
    public AccessLogInterceptor(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse resp, Object handler) {
        req.setAttribute("_reqStart", System.currentTimeMillis());
        return true;
    }

    private static final Map<String, String> RES = Map.ofEntries(
        Map.entry("goods", "商品档案"), Map.entry("goodstype", "商品分类"), Map.entry("orders", "订单"),
        Map.entry("supplier", "供应商"), Map.entry("customer", "客户"), Map.entry("location", "货位"),
        Map.entry("stock_alert", "预警阈值"), Map.entry("inout", "出入库"), Map.entry("sys_notice", "系统公告"),
        Map.entry("sys_user", "用户"), Map.entry("sys_role", "角色"), Map.entry("storage", "仓库"),
        Map.entry("goods_batch", "批次"));

    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse resp, Object handler, Exception ex) {
        try {
            String m = req.getMethod();
            if (!("POST".equals(m) || "PUT".equals(m) || "DELETE".equals(m))) return;
            String uri = req.getRequestURI();
            if (uri == null || !uri.startsWith("/api/") || uri.startsWith("/api/auth/login")) return;

            String[] seg = uri.substring(5).split("/"); // after /api/
            String res = seg.length > 0 ? RES.getOrDefault(seg[0], seg[0]) : uri;
            String action;
            if (uri.contains("/inout/in")) action = "入库";
            else if (uri.contains("/inout/out")) action = "出库";
            else if (uri.endsWith("/cancel")) action = "取消订单";
            else if (uri.endsWith("/changePassword")) action = "修改密码";
            else if (uri.equals("/api/auth/logout")) action = "退出登录";
            else action = ("POST".equals(m) ? "新增" : "PUT".equals(m) ? "修改" : "删除") + res;

            Object p = req.getAttribute("principal");
            String user = "";
            if (p instanceof TokenStore.Principal pr) user = pr.number();

            String ip = req.getHeader("X-Forwarded-For");
            if (ip == null || ip.isBlank()) ip = req.getRemoteAddr();

            Long start = (Long) req.getAttribute("_reqStart");
            int dur = start == null ? 0 : (int) (System.currentTimeMillis() - start);

            jdbc.update(
                "INSERT INTO sys_log(content, ip_addr, user_id, create_time, methods, result, duration) VALUES(?,?,?,?,?,?,?)",
                cut(action, 128), cut(ip, 255), cut(user, 32), LocalDateTime.now(),
                cut(m + " " + uri, 200), String.valueOf(resp.getStatus()), dur);
        } catch (Exception ignore) { /* 日志失败不影响主流程 */ }
    }

    private static String cut(String s, int n) { return s == null ? null : (s.length() > n ? s.substring(0, n) : s); }
}

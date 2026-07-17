package com.wms.filter;

import com.wms.utils.ReaderXml;
import lombok.extern.slf4j.Slf4j;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/** 登录过滤器：未登录访问 *.do/*.action 时跳回登录页（白名单在 URL_List.xml）。 */
@WebFilter(value = {"*.do", "*.action"})
@Slf4j
public class LoginFilter implements Filter {

    private List<String> urls = null;

    @Override
    public void init(FilterConfig filterConfig) {
        urls = ReaderXml.getList();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String uri = req.getRequestURI();
        if (urls.contains(uri)) {
            chain.doFilter(req, resp);
            return;
        }
        Object login = req.getSession().getAttribute("loginUser");
        if (login == null) {
            resp.setCharacterEncoding("utf-8");
            resp.setContentType("text/html;charset=utf8");
            PrintWriter writer = resp.getWriter();
            writer.write("<script>");
            writer.write("alert('您尚未登录，即将跳转到登录页面');");
            writer.write("window.top.location.href='/login.jsp';");
            writer.write("</script>");
            writer.flush();
            writer.close();
            return;
        }
        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {}
}

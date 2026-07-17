package com.wms.controller;

import com.wms.entity.SysUser;
import com.wms.module.MyResponse;
import com.wms.service.LoginService;
import com.wf.captcha.SpecCaptcha;
import com.wf.captcha.base.Captcha;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.*;
import java.io.IOException;
import java.io.PrintWriter;

@Controller
@RequestMapping("/login")
@Slf4j
public class LoginController {

    @Autowired
    private LoginService loginService;

    /** 登录 /login/login.do */
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String login(@RequestParam("userName") String userName,
                        @RequestParam("password") String password,
                        @RequestParam("code") String verCode,
                        HttpServletRequest request) {
        log.info("=========LoginController=========login=========");
        Object captcha = request.getSession().getAttribute("captcha");
        if (captcha == null || verCode == null || !captcha.toString().equals(verCode.trim().toLowerCase())) {
            request.setAttribute("msg", "验证码不正确");
            return "login";
        }
        MyResponse result = loginService.login(userName, password);
        if (result.getSuccess()) {
            SysUser user = (SysUser) result.getTag();
            request.getSession().setAttribute("loginUser", user);
            return "main";
        } else {
            request.setAttribute("msg", result.getMsg());
            return "login";
        }
    }

    /** 验证码图片 /login/captcha.do */
    @RequestMapping("/captcha")
    public void captcha(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("image/gif");
        response.setHeader("Pragma", "No-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.setDateHeader("Expires", 0);
        SpecCaptcha specCaptcha = new SpecCaptcha(130, 48, 4);
        specCaptcha.setFont(new Font("Verdana", Font.PLAIN, 32));
        specCaptcha.setCharType(Captcha.TYPE_ONLY_NUMBER);
        request.getSession().setAttribute("captcha", specCaptcha.text().toLowerCase());
        specCaptcha.out(response.getOutputStream());
    }

    /** 退出 /login/logOut.do */
    @RequestMapping("/logOut")
    public void logOut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().invalidate();
        response.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf8");
        PrintWriter writer = response.getWriter();
        writer.write("<script>");
        writer.write("alert('成功退出系统，欢迎再次使用！');");
        writer.write("window.top.location.href='/login.jsp';");
        writer.write("</script>");
        writer.flush();
        writer.close();
    }
}

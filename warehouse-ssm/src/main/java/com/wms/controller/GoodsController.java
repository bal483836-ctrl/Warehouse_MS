package com.wms.controller;

import com.wms.entity.Goods;
import com.wms.module.MyResponse;
import com.wms.service.WmsService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@Controller
@RequestMapping("/goods")
@Slf4j
public class GoodsController {

    @Autowired
    private WmsService wmsService;

    @RequestMapping("/list")
    public String list(@RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                       @RequestParam(value = "size", defaultValue = "5") int size,
                       HttpServletRequest request) {
        PageHelper.startPage(pageNum, size);
        PageInfo<Goods> pageInfo = new PageInfo<>(wmsService.findAllGoods());
        request.setAttribute("page", pageInfo);
        request.setAttribute("str", buildPageBar(pageInfo.getPages(), pageNum, "/goods/list.do"));
        return "goods/list";
    }

    @RequestMapping("/detail")
    public String detail(@RequestParam("id") int id, HttpServletRequest request) {
        request.setAttribute("goods", wmsService.findGoodsById(id));
        return "goods/detail";
    }

    @RequestMapping("/gotoAdd")
    public String gotoAdd(HttpServletRequest request) {
        request.setAttribute("storageList", wmsService.findAllStorage());
        request.setAttribute("typeList", wmsService.findAllType());
        return "goods/add";
    }

    @RequestMapping("/add")
    public void add(@ModelAttribute Goods goods, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.addGoods(goods).getMsg(), "/goods/list.do");
    }

    @RequestMapping("/deleteById")
    public void deleteById(@RequestParam("id") int id, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.removeGoods(id).getMsg(), "/goods/list.do");
    }

    @RequestMapping("/gotoModify")
    public String gotoModify(@RequestParam("id") int id, HttpServletRequest request) {
        request.setAttribute("goods", wmsService.findGoodsById(id));
        request.setAttribute("storageList", wmsService.findAllStorage());
        request.setAttribute("typeList", wmsService.findAllType());
        return "goods/modify";
    }

    @RequestMapping("/doModify")
    public void doModify(@ModelAttribute Goods goods, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.modifyGoods(goods).getMsg(), "/goods/list.do");
    }

    /** 分页条 HTML */
    static String buildPageBar(int pages, int cur, String url) {
        StringBuilder sb = new StringBuilder("<ul class=\"pagination\">");
        for (int i = 1; i <= pages; i++) {
            sb.append("<li class=\"page-item ").append(cur == i ? "active" : "")
              .append("\"><a class=\"page-link\" href=\"").append(url).append("?pageNum=").append(i)
              .append("\">").append(i).append("</a></li>");
        }
        return sb.append("</ul>").toString();
    }

    /** 弹窗提示并返回列表页 */
    static void writeScript(HttpServletResponse response, String msg, String back) throws IOException {
        response.setCharacterEncoding("utf-8");
        response.setContentType("text/html;charset=utf8");
        PrintWriter w = response.getWriter();
        w.write("<script>alert('" + msg + "，返回列表页面！');window.location.href='" + back + "'</script>");
        w.flush();
        w.close();
    }
}

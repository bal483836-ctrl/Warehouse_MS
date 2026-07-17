package com.wms.controller;

import com.wms.entity.Record;
import com.wms.entity.SysUser;
import com.wms.service.WmsService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static com.wms.controller.GoodsController.buildPageBar;
import static com.wms.controller.GoodsController.writeScript;

@Controller
@RequestMapping("/record")
@Slf4j
public class RecordController {

    @Autowired
    private WmsService wmsService;

    /** 出入库流水列表 */
    @RequestMapping("/list")
    public String list(@RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                       @RequestParam(value = "size", defaultValue = "8") int size,
                       HttpServletRequest request) {
        PageHelper.startPage(pageNum, size);
        PageInfo<Record> pageInfo = new PageInfo<>(wmsService.findAllRecord());
        request.setAttribute("page", pageInfo);
        request.setAttribute("str", buildPageBar(pageInfo.getPages(), pageNum, "/record/list.do"));
        return "record/list";
    }

    /** 出入库操作页（携带商品列表） */
    @RequestMapping("/gotoInout")
    public String gotoInout(HttpServletRequest request) {
        request.setAttribute("goodsList", wmsService.findAllGoods());
        return "record/inout";
    }

    /** 入库 */
    @RequestMapping("/inbound")
    public void inbound(@RequestParam("goodsId") int goodsId,
                        @RequestParam("count") int count,
                        @RequestParam(value = "remark", required = false) String remark,
                        HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = currentUserId(request);
        writeScript(response, wmsService.inbound(goodsId, count, userId, remark).getMsg(), "/record/gotoInout.do");
    }

    /** 出库 */
    @RequestMapping("/outbound")
    public void outbound(@RequestParam("goodsId") int goodsId,
                         @RequestParam("count") int count,
                         @RequestParam(value = "remark", required = false) String remark,
                         HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = currentUserId(request);
        writeScript(response, wmsService.outbound(goodsId, count, userId, remark).getMsg(), "/record/gotoInout.do");
    }

    private int currentUserId(HttpServletRequest request) {
        SysUser u = (SysUser) request.getSession().getAttribute("loginUser");
        return u != null && u.getId() != null ? u.getId() : 0;
    }
}

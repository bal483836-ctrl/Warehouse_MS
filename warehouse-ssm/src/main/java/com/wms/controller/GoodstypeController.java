package com.wms.controller;

import com.wms.entity.Goodstype;
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

import static com.wms.controller.GoodsController.buildPageBar;
import static com.wms.controller.GoodsController.writeScript;

@Controller
@RequestMapping("/goodstype")
@Slf4j
public class GoodstypeController {

    @Autowired
    private WmsService wmsService;

    @RequestMapping("/list")
    public String list(@RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                       @RequestParam(value = "size", defaultValue = "5") int size,
                       HttpServletRequest request) {
        PageHelper.startPage(pageNum, size);
        PageInfo<Goodstype> pageInfo = new PageInfo<>(wmsService.findAllType());
        request.setAttribute("page", pageInfo);
        request.setAttribute("str", buildPageBar(pageInfo.getPages(), pageNum, "/goodstype/list.do"));
        return "goodstype/list";
    }

    @RequestMapping("/gotoAdd")
    public String gotoAdd() { return "goodstype/add"; }

    @RequestMapping("/add")
    public void add(@ModelAttribute Goodstype type, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.addType(type).getMsg(), "/goodstype/list.do");
    }

    @RequestMapping("/deleteById")
    public void deleteById(@RequestParam("id") int id, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.removeType(id).getMsg(), "/goodstype/list.do");
    }

    @RequestMapping("/gotoModify")
    public String gotoModify(@RequestParam("id") int id, HttpServletRequest request) {
        request.setAttribute("goodstype", wmsService.findTypeById(id));
        return "goodstype/modify";
    }

    @RequestMapping("/doModify")
    public void doModify(@ModelAttribute Goodstype type, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.modifyType(type).getMsg(), "/goodstype/list.do");
    }
}

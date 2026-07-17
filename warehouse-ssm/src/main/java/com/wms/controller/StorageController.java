package com.wms.controller;

import com.wms.entity.Storage;
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
@RequestMapping("/storage")
@Slf4j
public class StorageController {

    @Autowired
    private WmsService wmsService;

    @RequestMapping("/list")
    public String list(@RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
                       @RequestParam(value = "size", defaultValue = "5") int size,
                       HttpServletRequest request) {
        PageHelper.startPage(pageNum, size);
        PageInfo<Storage> pageInfo = new PageInfo<>(wmsService.findAllStorage());
        request.setAttribute("page", pageInfo);
        request.setAttribute("str", buildPageBar(pageInfo.getPages(), pageNum, "/storage/list.do"));
        return "storage/list";
    }

    @RequestMapping("/gotoAdd")
    public String gotoAdd() { return "storage/add"; }

    @RequestMapping("/add")
    public void add(@ModelAttribute Storage storage, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.addStorage(storage).getMsg(), "/storage/list.do");
    }

    @RequestMapping("/deleteById")
    public void deleteById(@RequestParam("id") int id, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.removeStorage(id).getMsg(), "/storage/list.do");
    }

    @RequestMapping("/gotoModify")
    public String gotoModify(@RequestParam("id") int id, HttpServletRequest request) {
        request.setAttribute("storage", wmsService.findStorageById(id));
        return "storage/modify";
    }

    @RequestMapping("/doModify")
    public void doModify(@ModelAttribute Storage storage, HttpServletResponse response) throws IOException {
        writeScript(response, wmsService.modifyStorage(storage).getMsg(), "/storage/list.do");
    }
}

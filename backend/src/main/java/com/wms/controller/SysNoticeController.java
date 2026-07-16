package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysNotice;
import com.wms.repo.SysNoticeRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_notice")
public class SysNoticeController extends BaseController<SysNotice> {
    private final SysNoticeRepo repo;
    public SysNoticeController(SysNoticeRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysNotice, Integer> repo() { return repo; }
}

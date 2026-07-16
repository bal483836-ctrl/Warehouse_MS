package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysLog;
import com.wms.repo.SysLogRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_log")
public class SysLogController extends BaseController<SysLog> {
    private final SysLogRepo repo;
    public SysLogController(SysLogRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysLog, Integer> repo() { return repo; }
}

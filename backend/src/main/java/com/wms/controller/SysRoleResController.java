package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysRoleRes;
import com.wms.repo.SysRoleResRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_role_res")
public class SysRoleResController extends BaseController<SysRoleRes> {
    private final SysRoleResRepo repo;
    public SysRoleResController(SysRoleResRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysRoleRes, Integer> repo() { return repo; }
}

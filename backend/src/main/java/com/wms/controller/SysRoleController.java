package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysRole;
import com.wms.repo.SysRoleRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_role")
public class SysRoleController extends BaseController<SysRole> {
    private final SysRoleRepo repo;
    public SysRoleController(SysRoleRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysRole, Integer> repo() { return repo; }
}

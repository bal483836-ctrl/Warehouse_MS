package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysUserRole;
import com.wms.repo.SysUserRoleRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_user_role")
public class SysUserRoleController extends BaseController<SysUserRole> {
    private final SysUserRoleRepo repo;
    public SysUserRoleController(SysUserRoleRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysUserRole, Integer> repo() { return repo; }
}

package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysUser;
import com.wms.repo.SysUserRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_user")
public class SysUserController extends BaseController<SysUser> {
    private final SysUserRepo repo;
    public SysUserController(SysUserRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysUser, Integer> repo() { return repo; }
}

package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.SysMenu;
import com.wms.repo.SysMenuRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sys_menu")
public class SysMenuController extends BaseController<SysMenu> {
    private final SysMenuRepo repo;
    public SysMenuController(SysMenuRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<SysMenu, Integer> repo() { return repo; }
}

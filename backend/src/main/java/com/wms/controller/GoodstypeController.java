package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Goodstype;
import com.wms.repo.GoodstypeRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goodstype")
public class GoodstypeController extends BaseController<Goodstype> {
    private final GoodstypeRepo repo;
    public GoodstypeController(GoodstypeRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Goodstype, Integer> repo() { return repo; }
}

package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Goods;
import com.wms.repo.GoodsRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goods")
public class GoodsController extends BaseController<Goods> {
    private final GoodsRepo repo;
    public GoodsController(GoodsRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Goods, Integer> repo() { return repo; }
}

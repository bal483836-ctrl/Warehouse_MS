package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.GoodsBatch;
import com.wms.repo.GoodsBatchRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goods_batch")
public class GoodsBatchController extends BaseController<GoodsBatch> {
    private final GoodsBatchRepo repo;
    public GoodsBatchController(GoodsBatchRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<GoodsBatch, Integer> repo() { return repo; }
}

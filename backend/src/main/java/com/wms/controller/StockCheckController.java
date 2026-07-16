package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.StockCheck;
import com.wms.repo.StockCheckRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stock_check")
public class StockCheckController extends BaseController<StockCheck> {
    private final StockCheckRepo repo;
    public StockCheckController(StockCheckRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<StockCheck, Integer> repo() { return repo; }
}

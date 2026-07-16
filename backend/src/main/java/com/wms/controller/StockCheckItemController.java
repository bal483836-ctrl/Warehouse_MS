package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.StockCheckItem;
import com.wms.repo.StockCheckItemRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stock_check_item")
public class StockCheckItemController extends BaseController<StockCheckItem> {
    private final StockCheckItemRepo repo;
    public StockCheckItemController(StockCheckItemRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<StockCheckItem, Integer> repo() { return repo; }
}

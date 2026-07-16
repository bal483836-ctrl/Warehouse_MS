package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.StockAlert;
import com.wms.repo.StockAlertRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/stock_alert")
public class StockAlertController extends BaseController<StockAlert> {
    private final StockAlertRepo repo;
    public StockAlertController(StockAlertRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<StockAlert, Integer> repo() { return repo; }
}

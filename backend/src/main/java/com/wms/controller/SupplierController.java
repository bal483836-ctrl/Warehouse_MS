package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Supplier;
import com.wms.repo.SupplierRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/supplier")
public class SupplierController extends BaseController<Supplier> {
    private final SupplierRepo repo;
    public SupplierController(SupplierRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Supplier, Integer> repo() { return repo; }
}

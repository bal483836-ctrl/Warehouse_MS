package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Storage;
import com.wms.repo.StorageRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/storage")
public class StorageController extends BaseController<Storage> {
    private final StorageRepo repo;
    public StorageController(StorageRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Storage, Integer> repo() { return repo; }
}

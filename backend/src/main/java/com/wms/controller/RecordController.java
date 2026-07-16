package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Record;
import com.wms.repo.RecordRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/record")
public class RecordController extends BaseController<Record> {
    private final RecordRepo repo;
    public RecordController(RecordRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Record, Integer> repo() { return repo; }
}

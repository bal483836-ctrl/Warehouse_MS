package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Location;
import com.wms.repo.LocationRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/location")
public class LocationController extends BaseController<Location> {
    private final LocationRepo repo;
    public LocationController(LocationRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Location, Integer> repo() { return repo; }
}

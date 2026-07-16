package com.wms.repo;

import com.wms.entity.Location;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LocationRepo extends JpaRepository<Location, Integer> {
    List<Location> findByStorageIdOrderByIdAsc(Integer storageId);
}

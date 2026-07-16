package com.wms.repo;

import com.wms.entity.Storage;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StorageRepo extends JpaRepository<Storage, Integer> {
}

package com.wms.repo;

import com.wms.entity.GoodsBatch;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GoodsBatchRepo extends JpaRepository<GoodsBatch, Integer> {
}

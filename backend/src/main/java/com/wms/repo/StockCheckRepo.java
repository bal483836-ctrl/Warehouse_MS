package com.wms.repo;

import com.wms.entity.StockCheck;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockCheckRepo extends JpaRepository<StockCheck, Integer> {
}

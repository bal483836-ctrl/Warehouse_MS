package com.wms.repo;

import com.wms.entity.StockCheckItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StockCheckItemRepo extends JpaRepository<StockCheckItem, Integer> {
}

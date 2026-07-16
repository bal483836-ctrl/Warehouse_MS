package com.wms.repo;

import com.wms.entity.StockAlert;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StockAlertRepo extends JpaRepository<StockAlert, Integer> {
    Optional<StockAlert> findByGoodsId(Integer goodsId);
}

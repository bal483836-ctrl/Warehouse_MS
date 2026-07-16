package com.wms.repo;

import com.wms.entity.LocationStock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LocationStockRepo extends JpaRepository<LocationStock, Integer> {
    List<LocationStock> findByGoodsIdOrderByIdAsc(Integer goodsId);
}

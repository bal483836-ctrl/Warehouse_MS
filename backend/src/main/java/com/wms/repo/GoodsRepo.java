package com.wms.repo;

import com.wms.entity.Goods;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GoodsRepo extends JpaRepository<Goods, Integer> {
}

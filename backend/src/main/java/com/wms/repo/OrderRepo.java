package com.wms.repo;

import com.wms.entity.OrderMain;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderRepo extends JpaRepository<OrderMain, Integer> {
    List<OrderMain> findByTypeOrderByIdDesc(Integer type);
    List<OrderMain> findByCustomerIdOrderByIdDesc(Integer customerId);
    List<OrderMain> findBySupplierIdOrderByIdDesc(Integer supplierId);
}

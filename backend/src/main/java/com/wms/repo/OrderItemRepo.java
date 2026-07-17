package com.wms.repo;

import com.wms.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderItemRepo extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findByOrderIdOrderByIdAsc(Integer orderId);
    void deleteByOrderId(Integer orderId);
}

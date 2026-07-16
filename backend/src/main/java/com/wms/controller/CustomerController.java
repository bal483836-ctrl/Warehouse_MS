package com.wms.controller;

import com.wms.common.BaseController;
import com.wms.entity.Customer;
import com.wms.repo.CustomerRepo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer")
public class CustomerController extends BaseController<Customer> {
    private final CustomerRepo repo;
    public CustomerController(CustomerRepo repo) { this.repo = repo; }
    @Override protected JpaRepository<Customer, Integer> repo() { return repo; }
}

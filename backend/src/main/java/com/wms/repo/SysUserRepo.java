package com.wms.repo;

import com.wms.entity.SysUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SysUserRepo extends JpaRepository<SysUser, Integer> {
    Optional<SysUser> findByNumber(String number);
}

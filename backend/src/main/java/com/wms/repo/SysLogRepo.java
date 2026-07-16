package com.wms.repo;

import com.wms.entity.SysLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SysLogRepo extends JpaRepository<SysLog, Integer> {
}

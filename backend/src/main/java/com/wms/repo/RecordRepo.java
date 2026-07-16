package com.wms.repo;

import com.wms.entity.Record;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RecordRepo extends JpaRepository<Record, Integer> {
}

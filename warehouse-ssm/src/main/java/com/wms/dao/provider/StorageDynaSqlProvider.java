package com.wms.dao.provider;

import com.wms.entity.Storage;
import org.apache.ibatis.jdbc.SQL;

import static com.wms.util.common.WmsConstants.STORAGE_TABLE;

/** 仓库动态 SQL。 */
public class StorageDynaSqlProvider {
    public String insert(final Storage s) {
        return new SQL() {{
            INSERT_INTO(STORAGE_TABLE);
            if (s.getName() != null && !s.getName().equals("")) VALUES("name", "#{name}");
            if (s.getRemark() != null) VALUES("remark", "#{remark}");
        }}.toString();
    }
    public String update(final Storage s) {
        return new SQL() {{
            UPDATE(STORAGE_TABLE);
            if (s.getName() != null && !s.getName().equals("")) SET("name = #{name}");
            if (s.getRemark() != null) SET("remark = #{remark}");
            WHERE("id = #{id}");
        }}.toString();
    }
}

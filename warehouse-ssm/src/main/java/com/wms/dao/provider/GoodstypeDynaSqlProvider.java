package com.wms.dao.provider;

import com.wms.entity.Goodstype;
import org.apache.ibatis.jdbc.SQL;

import static com.wms.util.common.WmsConstants.GOODSTYPE_TABLE;

/** 商品分类动态 SQL。 */
public class GoodstypeDynaSqlProvider {
    public String insert(final Goodstype t) {
        return new SQL() {{
            INSERT_INTO(GOODSTYPE_TABLE);
            if (t.getName() != null && !t.getName().equals("")) VALUES("name", "#{name}");
            if (t.getRemark() != null) VALUES("remark", "#{remark}");
        }}.toString();
    }
    public String update(final Goodstype t) {
        return new SQL() {{
            UPDATE(GOODSTYPE_TABLE);
            if (t.getName() != null && !t.getName().equals("")) SET("name = #{name}");
            if (t.getRemark() != null) SET("remark = #{remark}");
            WHERE("id = #{id}");
        }}.toString();
    }
}

package com.wms.dao.provider;

import com.wms.entity.Goods;
import org.apache.ibatis.jdbc.SQL;

import static com.wms.util.common.WmsConstants.GOODS_TABLE;

/** 商品动态 SQL。 */
public class GoodsDynaSqlProvider {
    public String insert(final Goods g) {
        return new SQL() {{
            INSERT_INTO(GOODS_TABLE);
            if (g.getName() != null && !g.getName().equals("")) VALUES("name", "#{name}");
            if (g.getStorage() != null) VALUES("storage", "#{storage}");
            if (g.getGoodsType() != null) VALUES("goodsType", "#{goodsType}");
            VALUES("count", g.getCount() != null ? "#{count}" : "0");
            if (g.getRemark() != null) VALUES("remark", "#{remark}");
        }}.toString();
    }
    public String update(final Goods g) {
        return new SQL() {{
            UPDATE(GOODS_TABLE);
            if (g.getName() != null && !g.getName().equals("")) SET("name = #{name}");
            if (g.getStorage() != null) SET("storage = #{storage}");
            if (g.getGoodsType() != null) SET("goodsType = #{goodsType}");
            if (g.getCount() != null) SET("count = #{count}");
            if (g.getRemark() != null) SET("remark = #{remark}");
            WHERE("id = #{id}");
        }}.toString();
    }
}

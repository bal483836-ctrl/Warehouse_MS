package com.wms.dao;

import com.wms.dao.provider.GoodstypeDynaSqlProvider;
import com.wms.entity.Goodstype;
import org.apache.ibatis.annotations.*;

import java.util.List;

import static com.wms.util.common.WmsConstants.GOODSTYPE_TABLE;

/** 商品分类 DAO。 */
@Mapper
public interface GoodstypeDao {
    @Select("select * from " + GOODSTYPE_TABLE + " order by id")
    List<Goodstype> selectAll();

    @Select("select * from " + GOODSTYPE_TABLE + " where id = #{id}")
    Goodstype selectById(int id);

    @Select("select * from " + GOODSTYPE_TABLE + " where name = #{name}")
    Goodstype selectByName(String name);

    @Delete("delete from " + GOODSTYPE_TABLE + " where id = #{id}")
    int deleteById(int id);

    @InsertProvider(type = GoodstypeDynaSqlProvider.class, method = "insert")
    int save(Goodstype goodstype);

    @UpdateProvider(type = GoodstypeDynaSqlProvider.class, method = "update")
    int update(Goodstype goodstype);
}

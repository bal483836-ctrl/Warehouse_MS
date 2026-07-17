package com.wms.dao;

import com.wms.dao.provider.GoodsDynaSqlProvider;
import com.wms.entity.Goods;
import org.apache.ibatis.annotations.*;

import java.util.List;

import static com.wms.util.common.WmsConstants.GOODS_TABLE;

/** 商品 DAO：列表/详情左连接仓库、分类表附带名称。 */
@Mapper
public interface GoodsDao {

    @Select("select g.*, s.name as storageName, t.name as goodsTypeName "
            + "from " + GOODS_TABLE + " g "
            + "left join storage s on g.storage = s.id "
            + "left join goodstype t on g.goodsType = t.id "
            + "order by g.id")
    List<Goods> selectAll();

    @Select("select g.*, s.name as storageName, t.name as goodsTypeName "
            + "from " + GOODS_TABLE + " g "
            + "left join storage s on g.storage = s.id "
            + "left join goodstype t on g.goodsType = t.id "
            + "where g.id = #{id}")
    Goods selectById(int id);

    @Select("select * from " + GOODS_TABLE + " where name = #{name}")
    Goods selectByName(String name);

    // 修改时校验：除自身外是否有重名
    @Select("select * from " + GOODS_TABLE + " where id != #{id} and name = #{name}")
    List<Goods> selectNameUnique(Goods goods);

    // 某仓库/分类下是否还有商品（删除前判断）
    @Select("select * from " + GOODS_TABLE + " where storage = #{storageId}")
    List<Goods> selectByStorage(int storageId);

    @Select("select * from " + GOODS_TABLE + " where goodsType = #{typeId}")
    List<Goods> selectByType(int typeId);

    @Delete("delete from " + GOODS_TABLE + " where id = #{id}")
    int deleteById(int id);

    @InsertProvider(type = GoodsDynaSqlProvider.class, method = "insert")
    int save(Goods goods);

    @UpdateProvider(type = GoodsDynaSqlProvider.class, method = "update")
    int update(Goods goods);

    // 出入库：调整库存数量（delta 可正可负）
    @Update("update " + GOODS_TABLE + " set count = count + #{delta} where id = #{id}")
    int updateCount(@Param("id") int id, @Param("delta") int delta);
}

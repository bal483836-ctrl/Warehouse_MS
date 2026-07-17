package com.wms.dao;

import com.wms.dao.provider.StorageDynaSqlProvider;
import com.wms.entity.Storage;
import org.apache.ibatis.annotations.*;

import java.util.List;

import static com.wms.util.common.WmsConstants.STORAGE_TABLE;

/** 仓库 DAO。 */
@Mapper
public interface StorageDao {
    @Select("select * from " + STORAGE_TABLE + " order by id")
    List<Storage> selectAll();

    @Select("select * from " + STORAGE_TABLE + " where id = #{id}")
    Storage selectById(int id);

    @Select("select * from " + STORAGE_TABLE + " where name = #{name}")
    Storage selectByName(String name);

    @Delete("delete from " + STORAGE_TABLE + " where id = #{id}")
    int deleteById(int id);

    @InsertProvider(type = StorageDynaSqlProvider.class, method = "insert")
    int save(Storage storage);

    @UpdateProvider(type = StorageDynaSqlProvider.class, method = "update")
    int update(Storage storage);
}

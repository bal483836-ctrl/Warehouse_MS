package com.wms.dao;

import com.wms.entity.Record;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;

import java.util.List;

import static com.wms.util.common.WmsConstants.RECORD_TABLE;

/** 出入库流水 DAO。 */
@Mapper
public interface RecordDao {

    @Select("select r.*, g.name as goodsName, u.name as userName "
            + "from " + RECORD_TABLE + " r "
            + "left join goods g on r.goods = g.id "
            + "left join sys_user u on r.user_id = u.id "
            + "order by r.id desc")
    List<Record> selectAll();

    @Insert("insert into " + RECORD_TABLE + " (goods, user_id, count, createtime, remark, type) "
            + "values (#{goods}, #{userId}, #{count}, now(), #{remark}, #{type})")
    @Options(useGeneratedKeys = true, keyColumn = "id", keyProperty = "id")
    int save(Record record);
}

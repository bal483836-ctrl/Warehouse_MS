package com.wms.service;

import com.wms.entity.Goods;
import com.wms.entity.Goodstype;
import com.wms.entity.Record;
import com.wms.entity.Storage;
import com.wms.module.MyResponse;

import java.util.List;

/**
 * 业务逻辑门面组件（对应参考项目 HrmService）。
 * 封装仓库、分类、商品、出入库多个 DAO，向上提供仓库管理的业务功能。
 */
public interface WmsService {
    // 仓库
    List<Storage> findAllStorage();
    Storage findStorageById(int id);
    MyResponse addStorage(Storage storage);
    MyResponse modifyStorage(Storage storage);
    MyResponse removeStorage(int id);

    // 商品分类
    List<Goodstype> findAllType();
    Goodstype findTypeById(int id);
    MyResponse addType(Goodstype type);
    MyResponse modifyType(Goodstype type);
    MyResponse removeType(int id);

    // 商品
    List<Goods> findAllGoods();
    Goods findGoodsById(int id);
    MyResponse addGoods(Goods goods);
    MyResponse modifyGoods(Goods goods);
    MyResponse removeGoods(int id);

    // 出入库
    List<Record> findAllRecord();
    MyResponse inbound(int goodsId, int count, int userId, String remark);
    MyResponse outbound(int goodsId, int count, int userId, String remark);
}

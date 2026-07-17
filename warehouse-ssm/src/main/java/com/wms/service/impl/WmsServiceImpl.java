package com.wms.service.impl;

import com.wms.dao.*;
import com.wms.entity.Goods;
import com.wms.entity.Goodstype;
import com.wms.entity.Record;
import com.wms.entity.Storage;
import com.wms.module.MyResponse;
import com.wms.service.WmsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@Slf4j
public class WmsServiceImpl implements WmsService {

    @Autowired private StorageDao storageDao;
    @Autowired private GoodstypeDao goodstypeDao;
    @Autowired private GoodsDao goodsDao;
    @Autowired private RecordDao recordDao;

    // ================= 仓库 =================
    @Override public List<Storage> findAllStorage() { return storageDao.selectAll(); }
    @Override public Storage findStorageById(int id) { return storageDao.selectById(id); }

    @Override
    public MyResponse addStorage(Storage storage) {
        MyResponse r = new MyResponse();
        if (storageDao.selectByName(storage.getName()) != null) {
            r.setMsg("仓库名已存在，不能新建");
            return r;
        }
        r.setSuccess(storageDao.save(storage) == 1);
        r.setMsg(r.getSuccess() ? "仓库创建成功" : "仓库创建失败");
        return r;
    }

    @Override
    public MyResponse modifyStorage(Storage storage) {
        MyResponse r = new MyResponse();
        r.setSuccess(storageDao.update(storage) == 1);
        r.setMsg(r.getSuccess() ? "仓库修改成功" : "仓库修改失败");
        return r;
    }

    @Override
    public MyResponse removeStorage(int id) {
        MyResponse r = new MyResponse();
        List<Goods> goods = goodsDao.selectByStorage(id);
        if (goods != null && goods.size() > 0) {
            r.setMsg("该仓库下还有商品，不能删除");
            return r;
        }
        r.setSuccess(storageDao.deleteById(id) == 1);
        r.setMsg(r.getSuccess() ? "仓库删除成功" : "仓库删除失败");
        return r;
    }

    // ================= 商品分类 =================
    @Override public List<Goodstype> findAllType() { return goodstypeDao.selectAll(); }
    @Override public Goodstype findTypeById(int id) { return goodstypeDao.selectById(id); }

    @Override
    public MyResponse addType(Goodstype type) {
        MyResponse r = new MyResponse();
        if (goodstypeDao.selectByName(type.getName()) != null) {
            r.setMsg("分类名已存在，不能新建");
            return r;
        }
        r.setSuccess(goodstypeDao.save(type) == 1);
        r.setMsg(r.getSuccess() ? "分类创建成功" : "分类创建失败");
        return r;
    }

    @Override
    public MyResponse modifyType(Goodstype type) {
        MyResponse r = new MyResponse();
        r.setSuccess(goodstypeDao.update(type) == 1);
        r.setMsg(r.getSuccess() ? "分类修改成功" : "分类修改失败");
        return r;
    }

    @Override
    public MyResponse removeType(int id) {
        MyResponse r = new MyResponse();
        List<Goods> goods = goodsDao.selectByType(id);
        if (goods != null && goods.size() > 0) {
            r.setMsg("该分类下还有商品，不能删除");
            return r;
        }
        r.setSuccess(goodstypeDao.deleteById(id) == 1);
        r.setMsg(r.getSuccess() ? "分类删除成功" : "分类删除失败");
        return r;
    }

    // ================= 商品 =================
    @Override public List<Goods> findAllGoods() { return goodsDao.selectAll(); }
    @Override public Goods findGoodsById(int id) { return goodsDao.selectById(id); }

    @Override
    public MyResponse addGoods(Goods goods) {
        MyResponse r = new MyResponse();
        if (goodsDao.selectByName(goods.getName()) != null) {
            r.setMsg("商品名已存在，不能新建");
            return r;
        }
        r.setSuccess(goodsDao.save(goods) == 1);
        r.setMsg(r.getSuccess() ? "商品创建成功" : "商品创建失败");
        return r;
    }

    @Override
    public MyResponse modifyGoods(Goods goods) {
        MyResponse r = new MyResponse();
        List<Goods> dup = goodsDao.selectNameUnique(goods);
        if (dup != null && dup.size() > 0) {
            r.setMsg("商品名已被占用，不能修改");
            return r;
        }
        r.setSuccess(goodsDao.update(goods) == 1);
        r.setMsg(r.getSuccess() ? "商品修改成功" : "商品修改失败");
        return r;
    }

    @Override
    public MyResponse removeGoods(int id) {
        MyResponse r = new MyResponse();
        r.setSuccess(goodsDao.deleteById(id) == 1);
        r.setMsg(r.getSuccess() ? "商品删除成功" : "商品删除失败");
        return r;
    }

    // ================= 出入库 =================
    @Override public List<Record> findAllRecord() { return recordDao.selectAll(); }

    @Override
    public MyResponse inbound(int goodsId, int count, int userId, String remark) {
        MyResponse r = new MyResponse();
        if (count <= 0) { r.setMsg("入库数量必须为正数"); return r; }
        Goods g = goodsDao.selectById(goodsId);
        if (g == null) { r.setMsg("商品不存在"); return r; }
        goodsDao.updateCount(goodsId, count);
        recordDao.save(new Record().setGoods(goodsId).setUserId(userId).setCount(count).setType(0).setRemark(remark));
        r.setSuccess(true);
        r.setMsg("入库成功");
        return r;
    }

    @Override
    public MyResponse outbound(int goodsId, int count, int userId, String remark) {
        MyResponse r = new MyResponse();
        if (count <= 0) { r.setMsg("出库数量必须为正数"); return r; }
        Goods g = goodsDao.selectById(goodsId);
        if (g == null) { r.setMsg("商品不存在"); return r; }
        int cur = g.getCount() == null ? 0 : g.getCount();
        if (cur < count) { r.setMsg("库存不足，当前库存 " + cur); return r; }
        goodsDao.updateCount(goodsId, -count);
        recordDao.save(new Record().setGoods(goodsId).setUserId(userId).setCount(count).setType(1).setRemark(remark));
        r.setSuccess(true);
        r.setMsg("出库成功");
        return r;
    }
}

package com.wms.common;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 通用 CRUD 控制器基类，所有实体的增删改查复用此逻辑。
 * 所有表主键均为 Integer id。
 */
public abstract class BaseController<T> {

    protected abstract JpaRepository<T, Integer> repo();

    /** 列表（全部） */
    @GetMapping
    public Result<List<T>> list() {
        return Result.ok(repo().findAll());
    }

    /** 单条 */
    @GetMapping("/{id}")
    public Result<T> get(@PathVariable Integer id) {
        return repo().findById(id).map(Result::ok).orElseGet(() -> Result.fail(404, "记录不存在"));
    }

    /** 新增 */
    @PostMapping
    public Result<T> create(@RequestBody T entity) {
        return Result.ok(repo().save(entity));
    }

    /** 修改 */
    @PutMapping("/{id}")
    public Result<T> update(@PathVariable Integer id, @RequestBody T entity) {
        return Result.ok(repo().save(entity));
    }

    /** 删除 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Integer id) {
        repo().deleteById(id);
        return Result.ok();
    }
}

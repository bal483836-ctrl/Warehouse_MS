-- ============================================================
-- 小明智库 · Batch 5 增量脚本：分类关联仓库 + 商品容量占比 + 双角色
-- ------------------------------------------------------------
--  1) goodstype 增加 storage_id：商品分类指定放到哪种仓库
--  2) goods 增加 pieces_per_cap：多少件该商品占 1 个库位容量（默认 1）
--  3) 角色简化为两类：超级管理员(admin) / 操作员（仅销售订单+出入库+个人资料）
--     演示账号：admin/admin123（超级管理员）、test/123456（操作员）
--  依赖：batch4 已执行。适用：MySQL 8.0+ / MariaDB 10.x
-- ============================================================
USE ahut_base;
SET FOREIGN_KEY_CHECKS=0;

-- 1. 商品分类 → 所属仓库
ALTER TABLE `goodstype` ADD COLUMN `storage_id` int DEFAULT NULL COMMENT '该分类商品默认放入的仓库';
UPDATE `goodstype` SET `storage_id`=10 WHERE name='日用品';
UPDATE `goodstype` SET `storage_id`=2  WHERE name='数码产品';
UPDATE `goodstype` SET `storage_id`=3  WHERE name='食品';
UPDATE `goodstype` SET `storage_id`=5  WHERE name IN ('冷冻品','水果','蔬菜');

-- 2. 商品容量占比：多少件占 1 库位容量
ALTER TABLE `goods` ADD COLUMN `pieces_per_cap` int DEFAULT 1 COMMENT '多少件占1个库位容量';
UPDATE `goods` SET `pieces_per_cap`=1 WHERE `pieces_per_cap` IS NULL;
-- 示例：小件商品密度更高
UPDATE `goods` SET `pieces_per_cap`=10 WHERE id=13;  -- 牙膏 10件占1容量
UPDATE `goods` SET `pieces_per_cap`=5  WHERE id=8;   -- AD钙 5件占1容量

-- 3. 双角色：把历史 user 角色改为「操作员」
UPDATE `sys_role` SET `name`='操作员', `description`='仅可操作销售订单、出入库、个人资料' WHERE id=3;
UPDATE `sys_role` SET `description`='超级管理员，可见全部功能' WHERE id=1;
-- test 用户已映射角色3（sys_user_role: user_id=2 -> role_id=3），登录即为操作员

SET FOREIGN_KEY_CHECKS=1;

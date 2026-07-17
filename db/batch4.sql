-- ============================================================
-- 小明智库 · Batch 4 增量脚本：保质期/清理预警 + 销售订单(买家/取消) + 货位记录
-- ------------------------------------------------------------
--  1) goods 增加 shelf_life_days(保质期天数) + cleanup_warn_days(清理预警提前天数)
--  2) location_stock 增加 inbound_date(入库日期) + expiry_date(到期日期)  —— 按批次追踪
--  3) record 增加 location_id(入库记录的货架位置)
--  4) orders 增加 buyer(买家) + operator_id(经手账号) + cancel_reason/cancel_time(取消)
--  5) 取消独立「批次/保质期」模块：保质期并入商品档案；入库时落位并算到期
--  依赖：batch2/batch3 已执行。
--  适用：MySQL 8.0+ / MariaDB 10.x
-- ============================================================
USE ahut_base;
SET FOREIGN_KEY_CHECKS=0;

-- 1. goods：保质期 + 清理预警提前天数
ALTER TABLE `goods` ADD COLUMN `shelf_life_days` int DEFAULT NULL COMMENT '保质期天数(空=不易过期)';
ALTER TABLE `goods` ADD COLUMN `cleanup_warn_days` int DEFAULT 7 COMMENT '到期前多少天预警清理';

UPDATE `goods` SET `shelf_life_days`=10,  `cleanup_warn_days`=3  WHERE id=5;   -- 葡萄
UPDATE `goods` SET `shelf_life_days`=12,  `cleanup_warn_days`=3  WHERE id=6;   -- 西红柿
UPDATE `goods` SET `shelf_life_days`=30,  `cleanup_warn_days`=5  WHERE id=7;   -- 皮皮虾(冷冻)
UPDATE `goods` SET `shelf_life_days`=180, `cleanup_warn_days`=15 WHERE id=12;  -- 旺仔牛奶
UPDATE `goods` SET `shelf_life_days`=270, `cleanup_warn_days`=30 WHERE id=8;   -- AD钙
UPDATE `goods` SET `shelf_life_days`=730, `cleanup_warn_days`=30 WHERE id=4;   -- 洁面乳
UPDATE `goods` SET `shelf_life_days`=1095,`cleanup_warn_days`=30 WHERE id=13;  -- 牙膏
-- iPhone14(1) / iPad(11) 无保质期，保持 NULL

-- 2. location_stock：批次入库/到期日
ALTER TABLE `location_stock` ADD COLUMN `inbound_date` datetime DEFAULT NULL COMMENT '入库日期';
ALTER TABLE `location_stock` ADD COLUMN `expiry_date` datetime DEFAULT NULL COMMENT '到期日期';

-- 给生鲜类库存补入库/到期日（制造两条临期清理预警：葡萄/西红柿）
UPDATE `location_stock` SET `inbound_date`='2026-07-09 09:00:00', `expiry_date`='2026-07-19 00:00:00' WHERE goods_id=5;  -- 葡萄 距今2天
UPDATE `location_stock` SET `inbound_date`='2026-07-08 09:00:00', `expiry_date`='2026-07-20 00:00:00' WHERE goods_id=6;  -- 西红柿 距今3天
UPDATE `location_stock` SET `inbound_date`='2026-06-25 09:00:00', `expiry_date`='2026-07-25 00:00:00' WHERE goods_id=7;  -- 皮皮虾 距今8天
UPDATE `location_stock` SET `inbound_date`='2026-06-10 09:00:00', `expiry_date`='2026-12-07 00:00:00' WHERE goods_id=12; -- 旺仔牛奶
UPDATE `location_stock` SET `inbound_date`='2026-07-01 09:00:00', `expiry_date`='2027-02-26 00:00:00' WHERE goods_id=8;  -- AD钙
UPDATE `location_stock` SET `inbound_date`='2026-07-01 09:00:00', `expiry_date`='2028-07-01 00:00:00' WHERE goods_id=4;  -- 洁面乳
UPDATE `location_stock` SET `inbound_date`='2026-07-16 09:00:00', `expiry_date`='2029-07-16 00:00:00' WHERE goods_id=13; -- 牙膏

-- 3. record：入库落位（货架/库位）
ALTER TABLE `record` ADD COLUMN `location_id` int DEFAULT NULL COMMENT '入库落位的库位id';

-- 4. orders：买家 + 经手账号 + 取消原因/时间
ALTER TABLE `orders` ADD COLUMN `buyer` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '买家(销售单)';
ALTER TABLE `orders` ADD COLUMN `operator_id` int DEFAULT NULL COMMENT '经手账号(sys_user.id)';
ALTER TABLE `orders` ADD COLUMN `cancel_reason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '取消原因';
ALTER TABLE `orders` ADD COLUMN `cancel_time` datetime DEFAULT NULL COMMENT '取消时间';

-- 销售单补买家/经手人（沿用原 customer 名作为买家）
UPDATE `orders` SET `buyer`='城东连锁超市', `operator_id`=1 WHERE id=3;
UPDATE `orders` SET `buyer`='校园便利店',   `operator_id`=1 WHERE id=4;
-- 再补两张贴近门店零售的销售单
INSERT INTO `orders` (order_no,type,supplier_id,customer_id,status,total_amount,order_time,remark,buyer,operator_id)
 VALUES ('SO20260717084500',1,NULL,NULL,0,33.00,'2026-07-17 08:45:00','门店散客','散客·王先生',1);
SET @so1 = LAST_INSERT_ID();
INSERT INTO `order_item` (order_id,goods_id,count,price,remark) VALUES (@so1,5,3,8.00,'葡萄'),(@so1,6,1,6.00,'西红柿');
INSERT INTO `orders` (order_no,type,supplier_id,customer_id,status,total_amount,order_time,remark,buyer,operator_id)
 VALUES ('SO20260717093000',1,NULL,NULL,1,55.00,'2026-07-17 09:30:00','门店散客','散客·李女士',1);
SET @so2 = LAST_INSERT_ID();
INSERT INTO `order_item` (order_id,goods_id,count,price,remark) VALUES (@so2,12,10,5.50,'旺仔牛奶');

SET FOREIGN_KEY_CHECKS=1;

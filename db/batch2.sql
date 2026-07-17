-- ============================================================
-- 库智 WMS · Batch 2 增量脚本：订单链路 + 库位分区
-- ------------------------------------------------------------
--  1) goods 增加 zone(冷冻/冰鲜/普通) + image 列
--  2) record 增加 order_id(关联订单) + image(收货凭证) 列
--  3) orders 订单主表 + order_item 订单明细表（打通 供应商→采购入库→订单→客户→销售出库）
--  4) 库位按 冷冻/冰鲜/普通 分区重建，商品放入对应分区；库存偏低库位「越少越红」
--  依赖：基础表(goods/record/storage/location/location_stock/supplier/customer/stock_alert)已建。
--  适用：MySQL 8.0+ / MariaDB 10.x
-- ============================================================
USE ahut_base;
SET FOREIGN_KEY_CHECKS=0;

-- ------------------------------------------------------------
-- 1. goods：存储分区 + 商品图片
-- ------------------------------------------------------------
ALTER TABLE `goods` ADD COLUMN `zone` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '普通' COMMENT '存储分区:冷冻/冰鲜/普通';
ALTER TABLE `goods` ADD COLUMN `image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '商品图片(dataURL或路径)';

-- 分区归类：皮皮虾冷冻、葡萄/西红柿冰鲜，其余普通
UPDATE `goods` SET `zone`='冷冻' WHERE id IN (7);
UPDATE `goods` SET `zone`='冰鲜' WHERE id IN (5,6);
UPDATE `goods` SET `zone`='普通' WHERE id IN (1,4,8,11,12,13);
-- 皮皮虾并入「生鲜仓库」的冷冻分区，形成三分区演示
UPDATE `goods` SET `storage`=5 WHERE id=7;
UPDATE `storage` SET `name`='生鲜仓库', `remark`='冷冻/冰鲜/普通三分区生鲜仓' WHERE id=5;

-- ------------------------------------------------------------
-- 2. record：关联订单 + 收货凭证图片
-- ------------------------------------------------------------
ALTER TABLE `record` ADD COLUMN `order_id` int DEFAULT NULL COMMENT '关联订单id';
ALTER TABLE `record` ADD COLUMN `image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '入库收货凭证图片';

-- ------------------------------------------------------------
-- 3. orders 订单主表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '订单号',
  `type` int NOT NULL DEFAULT '0' COMMENT '类型:0采购,1销售',
  `supplier_id` int DEFAULT NULL COMMENT '供应商id(采购单)',
  `customer_id` int DEFAULT NULL COMMENT '客户id(销售单)',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态:0待处理,1已完成,2已取消',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单金额',
  `order_time` datetime DEFAULT NULL COMMENT '下单时间',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_type` (`type`), KEY `idx_supplier` (`supplier_id`), KEY `idx_customer` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='订单主表';

INSERT INTO `orders` VALUES (1,'PO20260710090001',0,1,NULL,1,1799000.00,'2026-07-10 09:00:00','数码采购单，已入库');
INSERT INTO `orders` VALUES (2,'PO20260712083000',0,2,NULL,1,4200.00,'2026-07-12 08:30:00','生鲜采购单');
INSERT INTO `orders` VALUES (3,'SO20260715141000',1,NULL,1,0,880.00,'2026-07-15 14:10:00','城东连锁超市销售单');
INSERT INTO `orders` VALUES (4,'SO20260716103000',1,NULL,2,1,720.00,'2026-07-16 10:30:00','校园便利店销售单');

-- ------------------------------------------------------------
-- 4. order_item 订单明细
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` int NOT NULL COMMENT '订单id',
  `goods_id` int NOT NULL COMMENT '商品id',
  `count` int NOT NULL DEFAULT '0' COMMENT '数量',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='订单明细表';

INSERT INTO `order_item` VALUES (1,1,1,200,5999.00,'iPhone14');
INSERT INTO `order_item` VALUES (2,1,11,100,5999.00,'iPad Air5');
INSERT INTO `order_item` VALUES (3,2,5,300,8.00,'葡萄');
INSERT INTO `order_item` VALUES (4,2,6,300,6.00,'西红柿');
INSERT INTO `order_item` VALUES (5,3,12,100,5.50,'旺仔牛奶');
INSERT INTO `order_item` VALUES (6,3,13,50,6.60,'牙膏');
INSERT INTO `order_item` VALUES (7,4,4,80,9.00,'洁面乳');

-- 已完成的采购单回填入库流水的订单关联（示例）
UPDATE `record` SET `order_id`=1, `remark`='采购入库(单号PO20260710090001)' WHERE id=18;

-- ------------------------------------------------------------
-- 5. 库位分区重建：冷冻 / 冰鲜 / 普通
--    仅保留有商品的仓库(2数码/3食品/5生鲜/10日用)，精简库位数量
-- ------------------------------------------------------------
DELETE FROM `location_stock`;
DELETE FROM `location`;
ALTER TABLE `location` MODIFY COLUMN `zone` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '分区:冷冻/冰鲜/普通';

-- 仓库2 数码仓库：普通 ×8
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity) VALUES
 (1,2,'普-2-01','普通1排','普通',1,1,500),(2,2,'普-2-02','普通2排','普通',2,1,500),
 (3,2,'普-2-03','普通3排','普通',3,1,500),(4,2,'普-2-04','普通4排','普通',4,1,500),
 (5,2,'普-2-05','普通5排','普通',5,1,500),(6,2,'普-2-06','普通6排','普通',6,1,500),
 (7,2,'普-2-07','普通7排','普通',7,1,500),(8,2,'普-2-08','普通8排','普通',8,1,500);

-- 仓库3 食品仓库：普通 ×6
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity) VALUES
 (9,3,'普-3-01','普通1排','普通',1,1,500),(10,3,'普-3-02','普通2排','普通',2,1,500),
 (11,3,'普-3-03','普通3排','普通',3,1,500),(12,3,'普-3-04','普通4排','普通',4,1,500),
 (13,3,'普-3-05','普通5排','普通',5,1,500),(14,3,'普-3-06','普通6排','普通',6,1,500);

-- 仓库5 生鲜仓库：冷冻 ×3 + 冰鲜 ×4 + 普通 ×3（三分区演示）
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity) VALUES
 (15,5,'冻-5-01','冷冻1排','冷冻',1,1,500),(16,5,'冻-5-02','冷冻2排','冷冻',2,1,500),
 (17,5,'冻-5-03','冷冻3排','冷冻',3,1,500),
 (18,5,'鲜-5-01','冰鲜1排','冰鲜',1,2,500),(19,5,'鲜-5-02','冰鲜2排','冰鲜',2,2,500),
 (20,5,'鲜-5-03','冰鲜3排','冰鲜',3,2,500),(21,5,'鲜-5-04','冰鲜4排','冰鲜',4,2,500),
 (22,5,'普-5-01','普通1排','普通',1,3,500),(23,5,'普-5-02','普通2排','普通',2,3,500),
 (24,5,'普-5-03','普通3排','普通',3,3,500);

-- 仓库10 日用品仓库：普通 ×6
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity) VALUES
 (25,10,'普-10-01','普通1排','普通',1,1,500),(26,10,'普-10-02','普通2排','普通',2,1,500),
 (27,10,'普-10-03','普通3排','普通',3,1,500),(28,10,'普-10-04','普通4排','普通',4,1,500),
 (29,10,'普-10-05','普通5排','普通',5,1,500),(30,10,'普-10-06','普通6排','普通',6,1,500);

-- 库位存货放置（同分区）：牙膏/AD钙偏低 → 红色预警
INSERT INTO `location_stock`(location_id,goods_id,count) VALUES
 (1,1,500),(2,1,210),           -- iPhone14 710
 (3,11,500),(4,11,300),         -- iPad 800
 (9,8,400),                     -- AD钙 400（低于安全下限800，红）
 (10,12,500),(11,12,500),(12,12,500),(13,12,50), -- 旺仔牛奶 1550
 (15,7,500),                    -- 皮皮虾 500（冷冻区）
 (18,5,500),(19,5,300),         -- 葡萄 800（冰鲜区）
 (20,6,500),(21,6,401),         -- 西红柿 901（冰鲜区）
 (25,4,500),(26,4,500),(27,4,82), -- 洁面乳 1082
 (28,13,90);                    -- 牙膏 90（低于安全下限120，红）

-- 预警阈值微调：制造深浅不同的红色（越少越红）
UPDATE `stock_alert` SET `min_count`=120 WHERE goods_id=13;                 -- 牙膏 90/120 轻度
INSERT INTO `stock_alert` (goods_id,min_count,max_count,enabled,remark)
 VALUES (8,800,3000,1,'AD钙安全库存(演示低库存预警)');                       -- AD钙 400/800 中度

SET FOREIGN_KEY_CHECKS=1;

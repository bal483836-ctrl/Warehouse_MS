-- ============================================================
-- 小明智库 · 数据库结构修复脚本（幂等，可重复执行，不动已有数据）
-- ------------------------------------------------------------
-- 适用场景：报错 Unknown column（如 ls.expiry_date / g.zone / o.buyer 等），
--   说明当前库缺少 Batch2/3/4 的增量列或表。本脚本逐项检测缺失并补齐：
--   已存在的列/表一律跳过，绝不删除或修改任何数据。
-- 用法：mysql -uroot -p ahut_base < db/repair_schema.sql
-- ============================================================
USE ahut_base;

-- 工具：列不存在则执行 ALTER
DELIMITER $$
DROP PROCEDURE IF EXISTS add_col $$
CREATE PROCEDURE add_col(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl_text TEXT)
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col) THEN
    SET @s = ddl_text; PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
  END IF;
END $$
DELIMITER ;

-- ---------- Batch2：goods / record ----------
CALL add_col('goods',  'zone',  'ALTER TABLE `goods` ADD COLUMN `zone` varchar(10) DEFAULT ''普通'' COMMENT ''存储分区:冷冻/冰鲜/普通''');
CALL add_col('goods',  'image', 'ALTER TABLE `goods` ADD COLUMN `image` mediumtext COMMENT ''商品图片(dataURL或路径)''');
CALL add_col('record', 'order_id', 'ALTER TABLE `record` ADD COLUMN `order_id` int DEFAULT NULL COMMENT ''关联订单id''');
CALL add_col('record', 'image',    'ALTER TABLE `record` ADD COLUMN `image` mediumtext COMMENT ''入库收货凭证图片''');

-- ---------- Batch2：orders / order_item（仅缺表时创建，不插演示数据） ----------
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `type` int NOT NULL DEFAULT '0' COMMENT '类型:0采购,1销售',
  `supplier_id` int DEFAULT NULL COMMENT '供应商id(采购单)',
  `customer_id` int DEFAULT NULL COMMENT '客户id(历史兼容)',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态:0待处理,1已完成,2已取消',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单金额',
  `order_time` datetime DEFAULT NULL COMMENT '下单时间',
  `remark` varchar(1000) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`), KEY `idx_supplier` (`supplier_id`), KEY `idx_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='订单主表';

CREATE TABLE IF NOT EXISTS `order_item` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `order_id` int NOT NULL COMMENT '订单id',
  `goods_id` int NOT NULL COMMENT '商品id',
  `count` int NOT NULL DEFAULT '0' COMMENT '数量',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT '单价',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`), KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='订单明细表';

CREATE TABLE IF NOT EXISTS `location_stock` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `location_id` int NOT NULL COMMENT '库位id',
  `goods_id` int NOT NULL COMMENT '货品id',
  `count` int NOT NULL DEFAULT 0 COMMENT '该库位存放数量',
  PRIMARY KEY(`id`), KEY `idx_loc`(`location_id`), KEY `idx_goods`(`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='库位存货表';

-- ---------- Batch3：supplier ----------
CALL add_col('supplier', 'image', 'ALTER TABLE `supplier` ADD COLUMN `image` mediumtext COMMENT ''供应商图片(dataURL或路径)''');

-- ---------- Batch4：保质期 / 批次到期 / 落位 / 销售单买家与取消 ----------
CALL add_col('goods', 'shelf_life_days',   'ALTER TABLE `goods` ADD COLUMN `shelf_life_days` int DEFAULT NULL COMMENT ''保质期天数(空=不易过期)''');
CALL add_col('goods', 'cleanup_warn_days', 'ALTER TABLE `goods` ADD COLUMN `cleanup_warn_days` int DEFAULT 7 COMMENT ''到期前多少天预警清理''');
CALL add_col('location_stock', 'inbound_date', 'ALTER TABLE `location_stock` ADD COLUMN `inbound_date` datetime DEFAULT NULL COMMENT ''入库日期''');
CALL add_col('location_stock', 'expiry_date',  'ALTER TABLE `location_stock` ADD COLUMN `expiry_date` datetime DEFAULT NULL COMMENT ''到期日期''');
CALL add_col('record', 'location_id', 'ALTER TABLE `record` ADD COLUMN `location_id` int DEFAULT NULL COMMENT ''入库落位的库位id''');
CALL add_col('orders', 'buyer',         'ALTER TABLE `orders` ADD COLUMN `buyer` varchar(100) DEFAULT NULL COMMENT ''买家(销售单)''');
CALL add_col('orders', 'operator_id',   'ALTER TABLE `orders` ADD COLUMN `operator_id` int DEFAULT NULL COMMENT ''经手账号(sys_user.id)''');
CALL add_col('orders', 'cancel_reason', 'ALTER TABLE `orders` ADD COLUMN `cancel_reason` varchar(500) DEFAULT NULL COMMENT ''取消原因''');
CALL add_col('orders', 'cancel_time',   'ALTER TABLE `orders` ADD COLUMN `cancel_time` datetime DEFAULT NULL COMMENT ''取消时间''');
CALL add_col('location', 'zone',     'ALTER TABLE `location` ADD COLUMN `zone` varchar(10) DEFAULT NULL COMMENT ''分区:冷冻/冰鲜/普通''');
CALL add_col('location', 'row_no',   'ALTER TABLE `location` ADD COLUMN `row_no` int DEFAULT NULL COMMENT ''排''');
CALL add_col('location', 'col_no',   'ALTER TABLE `location` ADD COLUMN `col_no` int DEFAULT NULL COMMENT ''列''');
CALL add_col('location', 'capacity', 'ALTER TABLE `location` ADD COLUMN `capacity` int DEFAULT 500 COMMENT ''库位容量''');

DROP PROCEDURE IF EXISTS add_col;

-- ---------- 温和回填（只补空值，不覆盖已有数据） ----------
UPDATE `goods` SET `zone`='普通' WHERE `zone` IS NULL OR `zone`='';
UPDATE `goods` SET `cleanup_warn_days`=7 WHERE `cleanup_warn_days` IS NULL;
UPDATE `location` SET `zone`='普通' WHERE `zone` IS NULL OR `zone`='';
UPDATE `location` SET `capacity`=500 WHERE `capacity` IS NULL;
-- 旧存货批次补时间：入库按现在计，有保质期的按保质期推算到期（保证清理预警可用）
UPDATE `location_stock` ls JOIN `goods` g ON g.id=ls.goods_id
   SET ls.`inbound_date`=NOW(),
       ls.`expiry_date`=IF(g.`shelf_life_days` IS NULL, NULL, NOW() + INTERVAL g.`shelf_life_days` DAY)
 WHERE ls.`inbound_date` IS NULL;

SELECT '✔ 结构修复完成：缺失列/表已补齐，已有数据未做删除或覆盖' AS result;

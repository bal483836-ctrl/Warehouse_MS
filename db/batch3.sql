-- ============================================================
-- 库智 WMS · Batch 3 增量脚本：详情页 + 配图 + 关系数据
-- ------------------------------------------------------------
--  1) supplier 增加 image 列（供应商图片/Logo）
--  2) 补充采购订单，使「日化用品批发商」也关联所供日用品，丰富供应商详情
--  说明：商品图片列 goods.image 已在 batch2.sql 建立；本脚本仅补供应商图片与关系数据。
--  依赖：batch2.sql 已执行（orders / order_item / goods.image 等已存在）。
--  适用：MySQL 8.0+ / MariaDB 10.x
-- ============================================================
USE ahut_base;
SET FOREIGN_KEY_CHECKS=0;

-- 1. supplier：图片列
ALTER TABLE `supplier` ADD COLUMN `image` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '供应商图片(dataURL或路径)';

-- 2. 补充「日化用品批发商(id=3)」的采购订单，供应 洁面乳/牙膏
INSERT INTO `orders` (id,order_no,type,supplier_id,customer_id,status,total_amount,order_time,remark)
 VALUES (5,'PO20260708093000',0,3,NULL,1,1296.00,'2026-07-08 09:30:00','日化用品采购单');
INSERT INTO `order_item` (id,order_id,goods_id,count,price,remark) VALUES
 (8,5,4,100,9.00,'洁面乳'),
 (9,5,13,60,6.60,'牙膏');

SET FOREIGN_KEY_CHECKS=1;

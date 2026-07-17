/*
==========================================================================
 仓库管理系统 —— 功能扩展脚本 (ahut_base_extend.sql)
 --------------------------------------------------------------------------
 在原有 10 张表基础上扩展 8 张新表 + 对应菜单与权限，新增以下功能模块：
   1. 供应商管理  supplier
   2. 客户管理    customer
   3. 批次/保质期 goods_batch
   4. 库存预警    stock_alert
   5. 库存盘点    stock_check + stock_check_item
   6. 货位管理    location
   7. 系统公告    sys_notice
 说明：沿用原库 utf8mb3 编码与逻辑外键（无硬 FK 约束）风格。
       依赖 ahut_base_clean.sql 已建立的 goods / storage / sys_user 等表。
 适用：MySQL 8.0+   数据库：ahut_base
==========================================================================
*/

SET FOREIGN_KEY_CHECKS=0;

-- ==========================================================================
-- 1. 供应商表 supplier —— 记录货物来源单位
-- ==========================================================================
DROP TABLE IF EXISTS `supplier`;
CREATE TABLE `supplier` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '供应商名称',
  `contact` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '邮箱',
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '地址',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='供应商表';

INSERT INTO `supplier` VALUES ('1', '苹果中国供应链', '张伟', '13800000001', 'apple@example.com', '上海市浦东新区', '数码产品主供货商', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `supplier` VALUES ('2', '鲜果直供农场', '李娜', '13800000002', 'fruit@example.com', '山东省烟台市', '果蔬生鲜供货', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `supplier` VALUES ('3', '日化用品批发商', '王强', '13800000003', 'daily@example.com', '广州市白云区', '日用品供货', '0', '2026-07-16 09:00:00', '1', null, null);

-- ==========================================================================
-- 2. 客户表 customer —— 记录出库去向单位/个人
-- ==========================================================================
DROP TABLE IF EXISTS `customer`;
CREATE TABLE `customer` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '客户名称',
  `contact` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '邮箱',
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='客户表';

INSERT INTO `customer` VALUES ('1', '城东连锁超市', '赵敏', '13900000001', 'east@example.com', '合肥市瑶海区', '大客户', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `customer` VALUES ('2', '校园便利店', '孙丽', '13900000002', 'campus@example.com', '马鞍山市花山区', '零售客户', '0', '2026-07-16 09:00:00', '1', null, null);

-- ==========================================================================
-- 3. 商品批次表 goods_batch —— 生产日期 / 保质期追踪（面向食品、冷冻、果蔬）
-- ==========================================================================
DROP TABLE IF EXISTS `goods_batch`;
CREATE TABLE `goods_batch` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `goods_id` int NOT NULL COMMENT '货品id（关联 goods.id）',
  `batch_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '批次号',
  `supplier_id` int DEFAULT NULL COMMENT '供应商id（关联 supplier.id）',
  `production_date` date DEFAULT NULL COMMENT '生产日期',
  `expiry_date` date DEFAULT NULL COMMENT '到期/保质日期',
  `count` int DEFAULT NULL COMMENT '批次数量',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='商品批次表';

INSERT INTO `goods_batch` VALUES ('1', '5', 'B20260701-GRAPE', '2', '2026-07-01', '2026-07-20', '800', '果蔬批次，注意保鲜', '2026-07-16 09:00:00');
INSERT INTO `goods_batch` VALUES ('2', '12', 'B20260610-MILK', '3', '2026-06-10', '2026-12-10', '1550', '常温奶', '2026-07-16 09:00:00');
INSERT INTO `goods_batch` VALUES ('3', '1', 'B20260615-IP14', '1', '2026-06-15', null, '710', '数码无保质期', '2026-07-16 09:00:00');

-- ==========================================================================
-- 4. 库存预警设置表 stock_alert —— 设置每种货物的安全库存区间
-- ==========================================================================
DROP TABLE IF EXISTS `stock_alert`;
CREATE TABLE `stock_alert` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `goods_id` int NOT NULL COMMENT '货品id（关联 goods.id）',
  `min_count` int DEFAULT '0' COMMENT '最低库存阈值（低于则缺货预警）',
  `max_count` int DEFAULT NULL COMMENT '最高库存阈值（高于则积压预警）',
  `enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用预警（1:是，0:否）',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='库存预警设置表';

INSERT INTO `stock_alert` VALUES ('1', '13', '100', '2000', '1', '牙膏安全库存');
INSERT INTO `stock_alert` VALUES ('2', '5', '200', '1500', '1', '葡萄易损耗，设较高下限');
INSERT INTO `stock_alert` VALUES ('3', '7', '100', '1000', '1', '皮皮虾水产预警');

-- ==========================================================================
-- 5a. 盘点单主表 stock_check —— 一次盘点任务
-- ==========================================================================
DROP TABLE IF EXISTS `stock_check`;
CREATE TABLE `stock_check` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `check_no` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '盘点单号',
  `storage_id` int DEFAULT NULL COMMENT '仓库id（关联 storage.id）',
  `user_id` int DEFAULT NULL COMMENT '盘点人id（关联 sys_user.id）',
  `status` int NOT NULL DEFAULT '0' COMMENT '状态：0进行中，1已完成',
  `check_time` datetime DEFAULT NULL COMMENT '盘点时间',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='盘点单表';

INSERT INTO `stock_check` VALUES ('1', 'PD20260716-001', '5', '1', '1', '2026-07-16 10:30:00', '果蔬仓库月度盘点');

-- ==========================================================================
-- 5b. 盘点明细表 stock_check_item —— 记录系统库存 vs 实盘数量差异
-- ==========================================================================
DROP TABLE IF EXISTS `stock_check_item`;
CREATE TABLE `stock_check_item` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `check_id` int NOT NULL COMMENT '盘点单id（关联 stock_check.id）',
  `goods_id` int NOT NULL COMMENT '货品id（关联 goods.id）',
  `system_count` int DEFAULT NULL COMMENT '系统库存数量',
  `actual_count` int DEFAULT NULL COMMENT '实盘数量',
  `diff_count` int DEFAULT NULL COMMENT '差异（实盘-系统）',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='盘点明细表';

INSERT INTO `stock_check_item` VALUES ('1', '1', '5', '800', '795', '-5', '损耗5个');
INSERT INTO `stock_check_item` VALUES ('2', '1', '6', '901', '901', '0', '一致');

-- ==========================================================================
-- 6. 货位表 location —— 仓库内货架/库位细分
-- ==========================================================================
DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `storage_id` int NOT NULL COMMENT '所属仓库id（关联 storage.id）',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '库位编码',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '库位名称',
  `zone` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '库区',
  `row_no` int DEFAULT NULL COMMENT '排',
  `col_no` int DEFAULT NULL COMMENT '列',
  `capacity` int DEFAULT '500' COMMENT '库位容量',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='货位表';

INSERT INTO `location` (`id`,`storage_id`,`code`,`name`,`remark`) VALUES ('1', '2', 'A-01-01', '数码仓A区1排1位', '存放手机');
INSERT INTO `location` (`id`,`storage_id`,`code`,`name`,`remark`) VALUES ('2', '5', 'B-02-03', '果蔬仓B区2排3位', '存放水果');
INSERT INTO `location` (`id`,`storage_id`,`code`,`name`,`remark`) VALUES ('3', '10', 'C-01-01', '日用品仓C区1排1位', '存放洗护');

-- ==========================================================================
-- 7. 系统公告表 sys_notice —— 内部通知/公告发布
-- ==========================================================================
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '公告标题',
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '公告内容',
  `type` int DEFAULT '0' COMMENT '类型：0通知，1公告',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态：0草稿，1已发布',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='系统公告表';

INSERT INTO `sys_notice` VALUES ('1', '系统上线通知', '仓库管理系统正式上线，请各位管理员及时维护基础数据。', '1', '1', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_notice` VALUES ('2', '果蔬仓盘点提醒', '本周五进行果蔬仓库月度盘点，请提前整理库位。', '0', '1', '0', '2026-07-16 09:10:00', '1', null, null);

-- ==========================================================================
-- 8. 菜单挂载 —— 将新功能加入 sys_menu 菜单树（parent_id=1 根菜单下）
--    每个模块：父级 Layout(菜单) + 子级 页面(*.vue)
-- ==========================================================================
INSERT INTO `sys_menu` VALUES ('32', '供应商管理', '1', 'supplier', 'el-icon-s-shop', '/supplier', '0', '', '77', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('33', '供应商管理', '32', 'supplier/home', '', '/supplier', '0', '', '0', '0', '0', 'SupplierManage.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('34', '客户管理', '1', 'customer', 'el-icon-user-solid', '/customer', '0', '', '76', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('35', '客户管理', '34', 'customer/home', '', '/customer', '0', '', '0', '0', '0', 'CustomerManage.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('36', '批次管理', '1', 'batch', 'el-icon-date', '/batch', '0', '', '75', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('37', '批次管理', '36', 'batch/home', '', '/batch', '0', '', '0', '0', '0', 'BatchManage.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('38', '库存预警', '1', 'stockAlert', 'el-icon-warning', '/stockAlert', '0', '', '74', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('39', '库存预警', '38', 'stockAlert/home', '', '/stockAlert', '0', '', '0', '0', '0', 'StockAlert.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('40', '库存盘点', '1', 'stockCheck', 'el-icon-s-claim', '/stockCheck', '0', '', '73', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('41', '库存盘点', '40', 'stockCheck/home', '', '/stockCheck', '0', '', '0', '0', '0', 'StockCheck.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('42', '货位管理', '1', 'location', 'el-icon-map-location', '/location', '0', '', '72', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('43', '货位管理', '42', 'location/home', '', '/location', '0', '', '0', '0', '0', 'LocationManage.vue', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('44', '系统公告', '1', 'notice', 'el-icon-bell', '/notice', '0', '', '71', '0', '0', 'Layout', '0', '2026-07-16 09:00:00', '1', null, null);
INSERT INTO `sys_menu` VALUES ('45', '系统公告', '44', 'notice/home', '', '/notice', '0', '', '0', '0', '0', 'NoticeManage.vue', '0', '2026-07-16 09:00:00', '1', null, null);

-- ==========================================================================
-- 9. 权限授予 —— 将新菜单授权给 admin 角色(role_id=1)，res_type=2(资源/菜单权限)
-- ==========================================================================
INSERT INTO `sys_role_res` VALUES ('57', '1', '32', '2');
INSERT INTO `sys_role_res` VALUES ('58', '1', '33', '2');
INSERT INTO `sys_role_res` VALUES ('59', '1', '34', '2');
INSERT INTO `sys_role_res` VALUES ('60', '1', '35', '2');
INSERT INTO `sys_role_res` VALUES ('61', '1', '36', '2');
INSERT INTO `sys_role_res` VALUES ('62', '1', '37', '2');
INSERT INTO `sys_role_res` VALUES ('63', '1', '38', '2');
INSERT INTO `sys_role_res` VALUES ('64', '1', '39', '2');
INSERT INTO `sys_role_res` VALUES ('65', '1', '40', '2');
INSERT INTO `sys_role_res` VALUES ('66', '1', '41', '2');
INSERT INTO `sys_role_res` VALUES ('67', '1', '42', '2');
INSERT INTO `sys_role_res` VALUES ('68', '1', '43', '2');
INSERT INTO `sys_role_res` VALUES ('69', '1', '44', '2');
INSERT INTO `sys_role_res` VALUES ('70', '1', '45', '2');

SET FOREIGN_KEY_CHECKS=1;

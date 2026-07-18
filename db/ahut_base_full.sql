-- ============================================================
-- 小明智库 完整数据库脚本（一次性导入，以 root 运行）
-- 适用 MySQL 8.0+ / MariaDB 10.x
-- ============================================================
CREATE DATABASE IF NOT EXISTS ahut_base DEFAULT CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'wms'@'localhost' IDENTIFIED BY 'wms123456';
CREATE USER IF NOT EXISTS 'wms'@'127.0.0.1' IDENTIFIED BY 'wms123456';
GRANT ALL PRIVILEGES ON ahut_base.* TO 'wms'@'localhost';
GRANT ALL PRIVILEGES ON ahut_base.* TO 'wms'@'127.0.0.1';
FLUSH PRIVILEGES;
USE ahut_base;

-- 1. 基础表结构与数据
/*
Navicat MySQL Data Transfer

Source Server         : StuScored
Source Server Version : 80033
Source Host           : localhost:3306
Source Database       : ahut_base

Target Server Type    : MYSQL
Target Server Version : 80033
File Encoding         : 65001

Date: 2024-07-13 12:54:35
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '货名',
  `storage` int NOT NULL COMMENT '仓库',
  `goodsType` int NOT NULL COMMENT '分类',
  `count` int DEFAULT NULL COMMENT '数量',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES ('1', 'iPhone14', '2', '2', '710', '货物不可以挤压');
INSERT INTO `goods` VALUES ('4', '洁面乳', '10', '1', '1082', '货物不可以挤压');
INSERT INTO `goods` VALUES ('5', '葡萄', '5', '5', '800', '货物不可以挤压');
INSERT INTO `goods` VALUES ('6', '西红柿', '5', '6', '901', '货物不可以挤压');
INSERT INTO `goods` VALUES ('7', '皮皮虾', '4', '4', '500', '货物不可以挤压');
INSERT INTO `goods` VALUES ('8', 'AD钙', '3', '3', '400', '货物不可以挤压');
INSERT INTO `goods` VALUES ('11', 'iPad Air5', '2', '2', '800', '货物不可以挤压');
INSERT INTO `goods` VALUES ('12', '旺仔牛奶', '3', '3', '1550', '');
INSERT INTO `goods` VALUES ('13', '牙膏', '10', '1', '90', '');

-- ----------------------------
-- Table structure for goodstype
-- ----------------------------
DROP TABLE IF EXISTS `goodstype`;
CREATE TABLE `goodstype` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '分类名',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of goodstype
-- ----------------------------
INSERT INTO `goodstype` VALUES ('1', '日用品', '日常生活用品');
INSERT INTO `goodstype` VALUES ('2', '数码产品', '数码产品');
INSERT INTO `goodstype` VALUES ('3', '食品', '食品');
INSERT INTO `goodstype` VALUES ('4', '冷冻品', '冷冻食品');
INSERT INTO `goodstype` VALUES ('5', '水果', '水果产品');
INSERT INTO `goodstype` VALUES ('6', '蔬菜', '蔬菜产品');
INSERT INTO `goodstype` VALUES ('8', '测试1', '测试122');

-- ----------------------------
-- Table structure for record
-- ----------------------------
DROP TABLE IF EXISTS `record`;
CREATE TABLE `record` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `goods` int NOT NULL COMMENT '货品id',
  `user_id` int DEFAULT NULL COMMENT '操作人id',
  `count` int DEFAULT NULL COMMENT '数量',
  `createtime` datetime DEFAULT NULL COMMENT '操作时间',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  `type` int DEFAULT NULL COMMENT '操作类型，入库0，出库1',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of record
-- ----------------------------
INSERT INTO `record` VALUES ('20', '1', '1', '3', '2024-06-27 20:23:51', '', '1');
INSERT INTO `record` VALUES ('21', '13', '1', '66', '2024-06-27 20:24:54', '', '1');
INSERT INTO `record` VALUES ('22', '1', '1', '-55', '2024-06-27 20:25:07', '', '2');
INSERT INTO `record` VALUES ('23', '1', '1', '12', '2024-06-27 23:44:59', '', '1');
INSERT INTO `record` VALUES ('24', '5', '1', '100', '2024-06-27 00:17:07', '新入库葡萄数量100', '1');
INSERT INTO `record` VALUES ('25', '5', '1', '100', '2024-06-28 00:23:06', '新入库葡萄100', '1');
INSERT INTO `record` VALUES ('26', '6', '1', '100', '2024-06-28 00:30:21', '新入库西红柿100', '1');
INSERT INTO `record` VALUES ('27', '13', '1', '12', '2024-06-28 00:35:28', '新入库牙膏12', '1');
INSERT INTO `record` VALUES ('28', '4', '1', '13', '2024-06-28 00:37:25', '新入库洁面乳13', '1');
INSERT INTO `record` VALUES ('29', '4', '1', '10', '2024-06-28 00:39:06', '新入库洁面乳10', '1');
INSERT INTO `record` VALUES ('30', '1', '1', '190', '2024-06-28 00:41:00', '', '1');
INSERT INTO `record` VALUES ('31', '1', '1', '12', '2024-06-28 00:42:41', '', '1');
INSERT INTO `record` VALUES ('32', '1', '1', '22', '2024-06-28 00:43:30', '', '1');
INSERT INTO `record` VALUES ('33', '1', '1', '11', '2024-06-28 00:44:15', '', '1');
INSERT INTO `record` VALUES ('34', '4', '1', '12', '2024-06-28 00:49:01', '', '1');
INSERT INTO `record` VALUES ('35', '1', '1', '12', '2024-06-28 00:49:33', '', '1');
INSERT INTO `record` VALUES ('36', '1', '1', '11', '2024-06-28 00:50:27', '', '1');
INSERT INTO `record` VALUES ('37', '1', '1', '100', '2024-06-28 11:02:21', '入库数码产品100', '1');
INSERT INTO `record` VALUES ('38', '1', '1', '50', '2024-06-28 11:03:13', '入库数码产品50', '1');
INSERT INTO `record` VALUES ('39', '1', '1', '10', '2024-06-28 11:04:59', '', '1');
INSERT INTO `record` VALUES ('40', '1', '1', '-48', '2024-06-28 11:06:31', '出库48,剩余700', '2');
INSERT INTO `record` VALUES ('41', '1', null, '9', '2024-07-13 12:22:55', '入库iPhone14一共9台', '1');

-- ----------------------------
-- Table structure for storage
-- ----------------------------
DROP TABLE IF EXISTS `storage`;
CREATE TABLE `storage` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '仓库名',
  `remark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of storage
-- ----------------------------
INSERT INTO `storage` VALUES ('2', '数码仓库', '用于数码产品');
INSERT INTO `storage` VALUES ('3', '食品仓库', '用于存放食品');
INSERT INTO `storage` VALUES ('4', '冷冻仓库', '用于存放冷冻食品');
INSERT INTO `storage` VALUES ('5', '果蔬仓库', '用于存放水果和蔬菜');
INSERT INTO `storage` VALUES ('6', '服装仓库', '用于存放服装');
INSERT INTO `storage` VALUES ('7', '水产仓库', '用于存放水产品');
INSERT INTO `storage` VALUES ('10', '日用品仓库', '用于存放日用品仓库1');
INSERT INTO `storage` VALUES ('14', '测试', '测试666');

-- ----------------------------
-- Table structure for sys_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `content` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '操作内容',
  `ip_addr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'ip地址',
  `user_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '用户id',
  `create_time` datetime DEFAULT NULL COMMENT '操作时间',
  `data` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '参数',
  `methods` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '调用方法路径',
  `result` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '调用结果',
  `duration` int DEFAULT NULL COMMENT '耗时 毫秒',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2630 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='日志表';

-- ----------------------------
-- Records of sys_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '菜单名称',
  `parent_id` int DEFAULT NULL COMMENT '上级id',
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '编码',
  `icon` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '图标',
  `url` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '目标地址',
  `type` int DEFAULT NULL COMMENT '菜单类型 0 菜单 1页面 2 资源',
  `description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '菜单说明',
  `sort` int DEFAULT NULL COMMENT '排序序号',
  `is_hidden_menu` tinyint(1) DEFAULT '0' COMMENT '是否隐藏菜单',
  `is_option_menu` tinyint(1) DEFAULT '0' COMMENT '是否子菜单下拉',
  `component` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '前端组件路径',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='菜单表';

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES ('1', '根菜单', '0', 'ROOT', '', '', '0', '', '0', '0', '0', 'ROOT', '0', '2023-03-13 11:29:18', '5fc79154b5224c2d830edfab61f516bc', '2023-03-13 17:58:19', '5fc79154b5224c2d830edfab61f516bc');
INSERT INTO `sys_menu` VALUES ('8', '基本信息管理', '1', 'setting', 'el-icon-setting', '/setting', '0', '', '99', '0', '0', 'Layout', '0', '2024-07-09 22:01:21', '1', '2024-07-09 22:48:32', '1');
INSERT INTO `sys_menu` VALUES ('9', '菜单管理', '8', 'menu', '', '/setting/menu', '0', '', '98', '0', '0', 'setting/menu/Index.vue', '0', '2024-07-09 22:03:11', '1', '2024-07-09 23:49:46', '1');
INSERT INTO `sys_menu` VALUES ('10', '角色管理', '8', 'role', '', '/setting/role', '0', '', '97', '0', '0', 'setting/role/Index.vue', '0', '2024-07-09 22:33:42', '1', '2024-07-09 23:49:51', '1');
INSERT INTO `sys_menu` VALUES ('13', '用户管理', '1', 'user', 'el-icon-user', '/user', '0', '', '98', '0', '0', 'Layout', '1', '2024-07-09 22:50:15', '1', '2024-07-09 23:49:34', '1');
INSERT INTO `sys_menu` VALUES ('16', '操作日志', '1', 'logs', 'el-icon-document', '/logs', '0', '', '96', '0', '0', 'Layout', '0', '2024-07-10 01:24:56', '1', '2024-07-12 13:32:20', '1');
INSERT INTO `sys_menu` VALUES ('17', '操作日志', '16', 'logs/home', 'el-icon-document', '/logs', '0', '', '0', '0', '0', 'logs/Index.vue', '0', '2024-07-10 01:31:43', '1', null, null);
INSERT INTO `sys_menu` VALUES ('18', '出入库管理', '1', 'goods', '', '/goods', '0', '', '80', '0', '0', 'Layout', '0', '2024-07-12 10:29:42', '1', '2024-07-12 13:19:34', '1');
INSERT INTO `sys_menu` VALUES ('19', '出入库管理', '18', 'goods/home', '', '/goods', '0', '', '0', '0', '0', 'GoodsManage.vue', '0', '2024-07-12 11:12:43', '1', '2024-07-12 11:31:20', '1');
INSERT INTO `sys_menu` VALUES ('20', '库存记录', '1', 'records', '', '/records', '0', '', '79', '0', '0', 'Layout', '0', '2024-07-12 13:14:01', '1', '2024-07-12 13:14:45', '1');
INSERT INTO `sys_menu` VALUES ('21', '库存记录', '20', 'records/home', '', '/records', '0', '', '0', '0', '0', 'RecordManage.vue', '0', '2024-07-12 13:16:12', '1', '2024-07-12 13:16:43', '1');
INSERT INTO `sys_menu` VALUES ('22', '仓库管理', '1', 'storage', '', '/storage', '0', '', '82', '0', '0', 'Layout', '0', '2024-07-12 13:33:34', '1', null, null);
INSERT INTO `sys_menu` VALUES ('23', '仓库管理', '22', 'storage/home', '', '/storage', '0', '', '0', '0', '0', 'StorageManage.vue', '0', '2024-07-12 13:34:40', '1', null, null);
INSERT INTO `sys_menu` VALUES ('24', '商品分类管理', '1', 'goodsType', '', '/goodsType', '0', '', '81', '0', '0', 'Layout', '0', '2024-07-12 14:03:07', '1', null, null);
INSERT INTO `sys_menu` VALUES ('25', '商品分类管理', '24', 'goodsType/home', '', '/goodsType', '0', '', '0', '0', '0', 'GoodstypeManage.vue', '0', '2024-07-12 14:04:13', '1', null, null);
INSERT INTO `sys_menu` VALUES ('26', '图表统计', '1', 'chart', '', '/chart', '0', '', '78', '0', '0', 'Layout', '0', '2024-07-12 14:47:15', '1', null, null);
INSERT INTO `sys_menu` VALUES ('27', '图表统计', '26', 'chart/home', '', '/chart', '0', '', '0', '0', '0', 'StatisticsChart.vue', '0', '2024-07-12 14:48:08', '1', null, null);
INSERT INTO `sys_menu` VALUES ('28', '个人中心', '1', 'userInformation', '', '/userInformation', '0', '', '83', '0', '0', 'Layout', '0', '2024-07-12 15:58:28', '1', '2024-07-12 15:58:59', '1');
INSERT INTO `sys_menu` VALUES ('29', '个人中心', '28', 'userInformation/home', '', '/userInformation', '0', '', '0', '0', '0', 'UserInformation.vue', '0', '2024-07-12 16:00:21', '1', '2024-07-12 16:55:56', '1');
INSERT INTO `sys_menu` VALUES ('30', '用户管理', '1', 'userManage', '', '/userManage', '0', '', '84', '0', '0', 'Layout', '1', '2024-07-12 17:21:58', '1', '2024-07-12 19:37:26', '1');
INSERT INTO `sys_menu` VALUES ('31', '用户管理', '8', 'userManage/home', '', '/setting/userManage', '0', '', '0', '0', '0', 'UserManage.vue', '0', '2024-07-12 17:23:06', '1', '2024-07-12 19:36:50', '1');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='系统角色表';

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES ('1', 'admin', '超级管理员', '0', '2024-07-09 17:22:16', 'admin', null, null);
INSERT INTO `sys_role` VALUES ('2', 'testasda', 'asdadasda', '1', '2024-07-10 19:27:25', '1', '2024-07-10 19:31:08', '1');
INSERT INTO `sys_role` VALUES ('3', 'user', '用户', '0', '2024-07-10 19:31:29', '1', '2024-07-12 15:49:43', '1');

-- ----------------------------
-- Table structure for sys_role_res
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_res`;
CREATE TABLE `sys_role_res` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_id` int NOT NULL COMMENT '角色id',
  `res_id` int NOT NULL COMMENT '资源id',
  `res_type` int NOT NULL COMMENT '资源类型 0 菜单 1 页面 2 资源',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='角色资源表';

-- ----------------------------
-- Records of sys_role_res
-- ----------------------------
INSERT INTO `sys_role_res` VALUES ('1', '1', '1', '2');
INSERT INTO `sys_role_res` VALUES ('2', '1', '8', '2');
INSERT INTO `sys_role_res` VALUES ('3', '1', '9', '2');
INSERT INTO `sys_role_res` VALUES ('4', '1', '10', '2');
INSERT INTO `sys_role_res` VALUES ('5', '1', '1', '2');
INSERT INTO `sys_role_res` VALUES ('6', '1', '1', '2');
INSERT INTO `sys_role_res` VALUES ('7', '1', '1', '2');
INSERT INTO `sys_role_res` VALUES ('8', '1', '8', '2');
INSERT INTO `sys_role_res` VALUES ('9', '1', '9', '2');
INSERT INTO `sys_role_res` VALUES ('10', '1', '10', '2');
INSERT INTO `sys_role_res` VALUES ('11', '1', '16', '2');
INSERT INTO `sys_role_res` VALUES ('12', '1', '17', '2');
INSERT INTO `sys_role_res` VALUES ('18', '3', '1', '2');
INSERT INTO `sys_role_res` VALUES ('22', '1', '17', '2');
INSERT INTO `sys_role_res` VALUES ('23', '1', '17', '2');
INSERT INTO `sys_role_res` VALUES ('24', '1', '17', '2');
INSERT INTO `sys_role_res` VALUES ('29', '3', '1', '2');
INSERT INTO `sys_role_res` VALUES ('31', '1', '18', '2');
INSERT INTO `sys_role_res` VALUES ('32', '1', '19', '2');
INSERT INTO `sys_role_res` VALUES ('33', '1', '20', '2');
INSERT INTO `sys_role_res` VALUES ('34', '1', '21', '2');
INSERT INTO `sys_role_res` VALUES ('35', '1', '22', '2');
INSERT INTO `sys_role_res` VALUES ('36', '1', '23', '2');
INSERT INTO `sys_role_res` VALUES ('37', '1', '24', '2');
INSERT INTO `sys_role_res` VALUES ('38', '1', '25', '2');
INSERT INTO `sys_role_res` VALUES ('39', '1', '26', '2');
INSERT INTO `sys_role_res` VALUES ('40', '1', '27', '2');
INSERT INTO `sys_role_res` VALUES ('41', '3', '22', '2');
INSERT INTO `sys_role_res` VALUES ('42', '3', '23', '2');
INSERT INTO `sys_role_res` VALUES ('43', '3', '24', '2');
INSERT INTO `sys_role_res` VALUES ('44', '3', '25', '2');
INSERT INTO `sys_role_res` VALUES ('45', '3', '18', '2');
INSERT INTO `sys_role_res` VALUES ('46', '3', '19', '2');
INSERT INTO `sys_role_res` VALUES ('47', '3', '20', '2');
INSERT INTO `sys_role_res` VALUES ('48', '3', '21', '2');
INSERT INTO `sys_role_res` VALUES ('49', '3', '26', '2');
INSERT INTO `sys_role_res` VALUES ('50', '3', '27', '2');
INSERT INTO `sys_role_res` VALUES ('51', '1', '28', '2');
INSERT INTO `sys_role_res` VALUES ('52', '1', '29', '2');
INSERT INTO `sys_role_res` VALUES ('53', '3', '28', '2');
INSERT INTO `sys_role_res` VALUES ('54', '3', '29', '2');
INSERT INTO `sys_role_res` VALUES ('55', '1', '30', '2');
INSERT INTO `sys_role_res` VALUES ('56', '1', '31', '2');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '姓名',
  `number` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '登录账号',
  `password` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '密码',
  `salt` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '密码盐',
  `age` int DEFAULT NULL COMMENT '年龄',
  `sex` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '性别 1:男，0：女',
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '电话',
  `locked` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否锁定（1:是，0:否）',
  `loginsign` tinyint(1) NOT NULL DEFAULT '1' COMMENT '登录标识（是否初次登录,1:是，0:否）',
  `del_flag` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已删除（1:是，0:否）',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `create_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '创建人',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '更新人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='用户表';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES ('1', '超级管理员', 'admin', '8646cd866b032b3e16ecab52c9d415fe', 'df8a31e62f414170a320c64933441af4', null, '1', '123456789', '0', '0', '0', '2023-07-26 07:15:50', 'system', '2023-12-18 17:38:31', null);
INSERT INTO `sys_user` VALUES ('2', '测试用户', 'test', '0c6b056a405cb6d19a60c4e8e7bf437b', '0ea87dc28eeb4fffb8e6e8e8093adecb', null, '0', '12345678910', '0', '0', '0', '2023-07-26 07:15:50', 'system', '2024-07-13 12:31:07', '2');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int NOT NULL COMMENT '用户id',
  `role_id` int NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='用户角色表';

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES ('1', '1', '1');
INSERT INTO `sys_user_role` VALUES ('2', '2', '3');
INSERT INTO `sys_user_role` VALUES ('3', '5', '3');

-- 2. 扩展业务表
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

-- 3. 库位热力图模型
-- heatmap real-data model: bins with capacity + physical stock placement
-- 注：zone/row_no/col_no/capacity 列已在 ahut_base_extend.sql 的 location 建表中定义
DELETE FROM `location`;
DROP TABLE IF EXISTS `location_stock`;
CREATE TABLE `location_stock`(
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `location_id` int NOT NULL COMMENT '库位id',
  `goods_id` int NOT NULL COMMENT '货品id',
  `count` int NOT NULL DEFAULT 0 COMMENT '该库位存放数量',
  PRIMARY KEY(`id`), KEY `idx_loc`(`location_id`), KEY `idx_goods`(`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='库位存货表';
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(1,2,'A-2-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(2,2,'A-2-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(3,2,'A-2-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(4,2,'A-2-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(5,2,'A-2-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(6,2,'A-2-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(7,2,'A-2-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(8,2,'A-2-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(9,2,'B-2-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(10,2,'B-2-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(11,2,'B-2-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(12,2,'B-2-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(13,2,'B-2-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(14,2,'B-2-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(15,2,'B-2-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(16,2,'B-2-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(17,2,'C-2-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(18,2,'C-2-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(19,2,'C-2-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(20,2,'C-2-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(21,2,'C-2-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(22,2,'C-2-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(23,2,'C-2-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(24,2,'C-2-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(25,2,'D-2-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(26,2,'D-2-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(27,2,'D-2-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(28,2,'D-2-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(29,2,'D-2-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(30,2,'D-2-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(31,2,'D-2-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(32,2,'D-2-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(33,3,'A-3-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(34,3,'A-3-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(35,3,'A-3-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(36,3,'A-3-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(37,3,'A-3-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(38,3,'A-3-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(39,3,'A-3-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(40,3,'A-3-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(41,3,'B-3-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(42,3,'B-3-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(43,3,'B-3-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(44,3,'B-3-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(45,3,'B-3-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(46,3,'B-3-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(47,3,'B-3-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(48,3,'B-3-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(49,3,'C-3-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(50,3,'C-3-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(51,3,'C-3-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(52,3,'C-3-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(53,3,'C-3-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(54,3,'C-3-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(55,3,'C-3-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(56,3,'C-3-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(57,3,'D-3-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(58,3,'D-3-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(59,3,'D-3-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(60,3,'D-3-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(61,3,'D-3-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(62,3,'D-3-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(63,3,'D-3-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(64,3,'D-3-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(65,4,'A-4-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(66,4,'A-4-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(67,4,'A-4-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(68,4,'A-4-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(69,4,'A-4-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(70,4,'A-4-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(71,4,'A-4-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(72,4,'A-4-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(73,4,'B-4-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(74,4,'B-4-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(75,4,'B-4-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(76,4,'B-4-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(77,4,'B-4-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(78,4,'B-4-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(79,4,'B-4-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(80,4,'B-4-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(81,4,'C-4-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(82,4,'C-4-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(83,4,'C-4-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(84,4,'C-4-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(85,4,'C-4-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(86,4,'C-4-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(87,4,'C-4-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(88,4,'C-4-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(89,4,'D-4-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(90,4,'D-4-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(91,4,'D-4-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(92,4,'D-4-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(93,4,'D-4-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(94,4,'D-4-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(95,4,'D-4-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(96,4,'D-4-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(97,5,'A-5-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(98,5,'A-5-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(99,5,'A-5-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(100,5,'A-5-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(101,5,'A-5-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(102,5,'A-5-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(103,5,'A-5-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(104,5,'A-5-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(105,5,'B-5-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(106,5,'B-5-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(107,5,'B-5-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(108,5,'B-5-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(109,5,'B-5-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(110,5,'B-5-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(111,5,'B-5-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(112,5,'B-5-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(113,5,'C-5-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(114,5,'C-5-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(115,5,'C-5-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(116,5,'C-5-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(117,5,'C-5-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(118,5,'C-5-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(119,5,'C-5-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(120,5,'C-5-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(121,5,'D-5-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(122,5,'D-5-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(123,5,'D-5-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(124,5,'D-5-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(125,5,'D-5-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(126,5,'D-5-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(127,5,'D-5-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(128,5,'D-5-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(129,6,'A-6-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(130,6,'A-6-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(131,6,'A-6-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(132,6,'A-6-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(133,6,'A-6-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(134,6,'A-6-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(135,6,'A-6-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(136,6,'A-6-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(137,6,'B-6-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(138,6,'B-6-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(139,6,'B-6-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(140,6,'B-6-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(141,6,'B-6-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(142,6,'B-6-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(143,6,'B-6-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(144,6,'B-6-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(145,6,'C-6-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(146,6,'C-6-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(147,6,'C-6-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(148,6,'C-6-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(149,6,'C-6-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(150,6,'C-6-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(151,6,'C-6-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(152,6,'C-6-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(153,6,'D-6-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(154,6,'D-6-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(155,6,'D-6-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(156,6,'D-6-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(157,6,'D-6-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(158,6,'D-6-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(159,6,'D-6-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(160,6,'D-6-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(161,7,'A-7-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(162,7,'A-7-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(163,7,'A-7-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(164,7,'A-7-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(165,7,'A-7-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(166,7,'A-7-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(167,7,'A-7-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(168,7,'A-7-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(169,7,'B-7-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(170,7,'B-7-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(171,7,'B-7-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(172,7,'B-7-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(173,7,'B-7-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(174,7,'B-7-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(175,7,'B-7-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(176,7,'B-7-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(177,7,'C-7-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(178,7,'C-7-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(179,7,'C-7-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(180,7,'C-7-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(181,7,'C-7-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(182,7,'C-7-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(183,7,'C-7-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(184,7,'C-7-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(185,7,'D-7-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(186,7,'D-7-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(187,7,'D-7-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(188,7,'D-7-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(189,7,'D-7-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(190,7,'D-7-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(191,7,'D-7-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(192,7,'D-7-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(193,10,'A-10-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(194,10,'A-10-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(195,10,'A-10-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(196,10,'A-10-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(197,10,'A-10-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(198,10,'A-10-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(199,10,'A-10-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(200,10,'A-10-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(201,10,'B-10-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(202,10,'B-10-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(203,10,'B-10-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(204,10,'B-10-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(205,10,'B-10-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(206,10,'B-10-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(207,10,'B-10-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(208,10,'B-10-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(209,10,'C-10-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(210,10,'C-10-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(211,10,'C-10-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(212,10,'C-10-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(213,10,'C-10-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(214,10,'C-10-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(215,10,'C-10-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(216,10,'C-10-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(217,10,'D-10-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(218,10,'D-10-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(219,10,'D-10-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(220,10,'D-10-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(221,10,'D-10-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(222,10,'D-10-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(223,10,'D-10-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(224,10,'D-10-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(225,14,'A-14-01','A区1排',' A',1,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(226,14,'A-14-02','A区2排',' A',2,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(227,14,'A-14-03','A区3排',' A',3,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(228,14,'A-14-04','A区4排',' A',4,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(229,14,'A-14-05','A区5排',' A',5,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(230,14,'A-14-06','A区6排',' A',6,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(231,14,'A-14-07','A区7排',' A',7,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(232,14,'A-14-08','A区8排',' A',8,1,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(233,14,'B-14-01','B区1排',' B',1,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(234,14,'B-14-02','B区2排',' B',2,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(235,14,'B-14-03','B区3排',' B',3,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(236,14,'B-14-04','B区4排',' B',4,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(237,14,'B-14-05','B区5排',' B',5,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(238,14,'B-14-06','B区6排',' B',6,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(239,14,'B-14-07','B区7排',' B',7,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(240,14,'B-14-08','B区8排',' B',8,2,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(241,14,'C-14-01','C区1排',' C',1,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(242,14,'C-14-02','C区2排',' C',2,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(243,14,'C-14-03','C区3排',' C',3,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(244,14,'C-14-04','C区4排',' C',4,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(245,14,'C-14-05','C区5排',' C',5,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(246,14,'C-14-06','C区6排',' C',6,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(247,14,'C-14-07','C区7排',' C',7,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(248,14,'C-14-08','C区8排',' C',8,3,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(249,14,'D-14-01','D区1排',' D',1,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(250,14,'D-14-02','D区2排',' D',2,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(251,14,'D-14-03','D区3排',' D',3,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(252,14,'D-14-04','D区4排',' D',4,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(253,14,'D-14-05','D区5排',' D',5,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(254,14,'D-14-06','D区6排',' D',6,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(255,14,'D-14-07','D区7排',' D',7,4,500,NULL);
INSERT INTO `location`(id,storage_id,code,name,zone,row_no,col_no,capacity,remark) VALUES(256,14,'D-14-08','D区8排',' D',8,4,500,NULL);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(1,27,1,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(2,6,1,210);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(3,216,4,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(4,218,4,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(5,200,4,82);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(6,125,5,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(7,118,5,300);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(8,118,6,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(9,104,6,401);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(10,89,7,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(11,45,8,400);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(12,26,11,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(13,12,11,300);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(14,40,12,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(15,54,12,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(16,57,12,500);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(17,58,12,50);
INSERT INTO `location_stock`(id,location_id,goods_id,count) VALUES(18,210,13,90);

-- 4. 出入库流水种子（精简）
DELETE FROM record;
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(1,12,1,249,'2026-02-25 16:28:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(2,13,1,78,'2026-02-06 17:30:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(3,5,1,144,'2026-02-10 11:05:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(4,13,1,192,'2026-03-02 18:25:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(5,12,1,219,'2026-03-20 11:39:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(6,1,1,46,'2026-03-02 09:12:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(7,6,1,37,'2026-04-25 16:20:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(8,12,1,245,'2026-04-07 17:14:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(9,7,1,31,'2026-04-22 10:29:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(10,7,1,171,'2026-05-03 13:20:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(11,6,1,103,'2026-05-01 10:36:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(12,4,1,57,'2026-05-10 15:04:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(13,1,1,30,'2026-06-07 12:59:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(14,1,1,126,'2026-06-23 15:26:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(15,4,1,191,'2026-06-07 13:21:00','销售出库',1);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(16,4,1,115,'2026-07-01 15:48:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(17,4,1,93,'2026-07-12 10:00:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(18,1,1,234,'2026-07-08 11:43:00','采购入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(19,1,1,120,'2026-07-16 13:12:00','新到货入库',0);
INSERT INTO record(id,goods,user_id,count,createtime,remark,type) VALUES(20,5,1,60,'2026-07-16 12:32:00','门店出货',1);

-- 5. 重置演示口令
-- 将演示用户口令重置为已知值（散列方案：md5(md5(password)+salt)）
--   admin / admin123
--   test  / 123456
UPDATE sys_user SET password='c7e30b41bb106648f5332384471f9918' WHERE number='admin';
UPDATE sys_user SET password='aface005fbff7f7cf4ba5404cfc52ad9' WHERE number='test';


-- ============================================================
-- 4. Batch 2 增量：订单链路 + 库位分区（详见 db/batch2.sql）
-- ============================================================
-- ============================================================
-- 小明智库 · Batch 2 增量脚本：订单链路 + 库位分区
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
ALTER TABLE `goods` ADD COLUMN `image` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '商品图片(dataURL或路径)';

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
ALTER TABLE `record` ADD COLUMN `image` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT '入库收货凭证图片';

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


-- ============================================================
-- 5. Batch 3 增量：详情页配图 + 关系数据（详见 db/batch3.sql）
-- ============================================================
-- ============================================================
-- 小明智库 · Batch 3 增量脚本：详情页 + 配图 + 关系数据
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


-- ============================================================
-- 6. Batch 3 配图：内置矢量图路径（详见 db/batch3_images.sql）
-- ============================================================
-- ============================================================
-- 小明智库 · Batch 3 配图脚本：为商品/供应商填充内置矢量图
-- ------------------------------------------------------------
--  图片文件位于后端静态资源 static/img/goods/*.svg、static/img/suppliers/*.svg，
--  随 jar 一起发布，按路径引用（不占用大体积 dataURL）。
--  用户也可在「商品档案 / 供应商」表单中上传本地图片覆盖。
--  依赖：batch3.sql 已执行（goods.image / supplier.image 列已存在）。
-- ============================================================
USE ahut_base;

UPDATE `goods` SET `image`='/img/goods/1.jpg'  WHERE id=1;
UPDATE `goods` SET `image`='/img/goods/4.jpg'  WHERE id=4;
UPDATE `goods` SET `image`='/img/goods/5.jpg'  WHERE id=5;
UPDATE `goods` SET `image`='/img/goods/6.jpg'  WHERE id=6;
UPDATE `goods` SET `image`='/img/goods/7.jpg'  WHERE id=7;
UPDATE `goods` SET `image`='/img/goods/8.jpg'  WHERE id=8;
UPDATE `goods` SET `image`='/img/goods/11.jpg' WHERE id=11;
UPDATE `goods` SET `image`='/img/goods/12.jpg' WHERE id=12;
UPDATE `goods` SET `image`='/img/goods/13.jpg' WHERE id=13;

UPDATE `supplier` SET `image`='/img/suppliers/1.jpg' WHERE id=1;
UPDATE `supplier` SET `image`='/img/suppliers/2.jpg' WHERE id=2;
UPDATE `supplier` SET `image`='/img/suppliers/3.jpg' WHERE id=3;


-- ============================================================
-- 7. Batch 4 增量：保质期/清理预警 + 销售订单买家/取消 + 货位记录（详见 db/batch4.sql）
-- ============================================================
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


-- ============================================================
-- 8. Batch 5 增量：分类关联仓库 + 商品容量占比 + 双角色（详见 db/batch5.sql）
-- ============================================================
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

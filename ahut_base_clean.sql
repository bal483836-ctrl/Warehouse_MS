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

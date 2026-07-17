#!/usr/bin/env bash
# 一键初始化数据库：建库建用户 + 加载表结构与全部种子数据
# 用法：bash db/init_db.sh   （需要本机已运行 MySQL/MariaDB，且有 root 访问）
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DB=ahut_base
MYSQL="sudo mariadb"     # 如用 mysql，请改为: mysql -uroot -p<你的密码>

echo "==> 创建数据库与应用账号"
$MYSQL <<SQL
CREATE DATABASE IF NOT EXISTS $DB DEFAULT CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'wms'@'localhost' IDENTIFIED BY 'wms123456';
CREATE USER IF NOT EXISTS 'wms'@'127.0.0.1' IDENTIFIED BY 'wms123456';
GRANT ALL PRIVILEGES ON $DB.* TO 'wms'@'localhost';
GRANT ALL PRIVILEGES ON $DB.* TO 'wms'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

echo "==> 加载表结构与基础数据（18 张表）"
$MYSQL $DB < "$ROOT_DIR/ahut_base_clean.sql"
$MYSQL $DB < "$ROOT_DIR/ahut_base_extend.sql"

echo "==> 加载库位热力图模型 + 库位存货"
$MYSQL $DB < "$ROOT_DIR/db/heatmap_seed.sql"

echo "==> 加载出入库流水种子数据"
$MYSQL $DB < "$ROOT_DIR/db/record_seed.sql"

echo "==> 加载 Batch2：订单链路 + 库位分区"
$MYSQL $DB < "$ROOT_DIR/db/batch2.sql"

echo "==> 加载 Batch3：详情页配图 + 关系数据"
$MYSQL $DB < "$ROOT_DIR/db/batch3.sql"

echo "==> 重置演示口令（admin/admin123, test/123456）"
$MYSQL $DB < "$ROOT_DIR/db/reseed_passwords.sql"

echo "✅ 数据库初始化完成：$DB（18 张业务表 + 库位模型）"

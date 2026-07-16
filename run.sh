#!/usr/bin/env bash
# 构建并启动仓库管理系统后端（内置前端静态资源）
# 前置：已执行 db/init_db.sh 初始化数据库，且 MySQL/MariaDB 正在运行
set -e
cd "$(dirname "$0")/backend"
echo "==> Maven 打包"
mvn -q -B package -DskipTests
echo "==> 启动服务 http://localhost:8080  （登录：admin/admin123）"
java -jar target/warehouse-ms-1.0.0.jar

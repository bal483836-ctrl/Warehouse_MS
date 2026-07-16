# 库智 WMS · 仓库管理系统（Spring Boot + MySQL + Vue 风格前端）

按高级 UI 原型实现的**可运行、可测试**的仓库管理系统。所有逻辑均连接真实数据库，
出入库、库存、库位热力图全部由真实数据驱动。

## 技术栈

| 层 | 技术 |
| --- | --- |
| 后端 | Java 17 · Spring Boot 3.3 · Spring Data JPA |
| 数据库 | MySQL 8 / MariaDB 10.11（`ahut_base`，18 张业务表 + 库位模型） |
| 前端 | 原生 SPA（深蓝高级主题）· 手写 SVG 图表 · 由 Spring Boot 静态资源托管 |
| 鉴权 | 账号 + 盐值散列 `md5(md5(pwd)+salt)` + 内存 Token |

## 目录

```
backend/
├── pom.xml
├── src/main/java/com/wms/
│   ├── entity/        18+1 个 JPA 实体（按真实表结构生成）
│   ├── repo/          Spring Data 仓库
│   ├── controller/    18 个通用 CRUD + Auth/InOut/Stats/Heatmap
│   ├── common/        Result、BaseController、Md5Util
│   ├── config/        CORS、拦截器、Jackson
│   └── security/      Token 存储与鉴权拦截器
├── src/main/resources/
│   ├── application.yml
│   └── static/        login.html · index.html · app.js · app.css（前端）
└── test.sh            集成测试（对运行中的服务断言真实结果）
```

## 快速开始

```bash
# 1) 初始化数据库（需本机 MySQL/MariaDB 运行中）
bash db/init_db.sh

# 2) 构建并启动
bash run.sh
# 打开 http://localhost:8080  ，登录 admin / admin123
```

演示账号：`admin / admin123`（超级管理员）、`test / 123456`（测试用户）

## 核心 API

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/api/auth/login` | 登录（真实盐值散列校验）|
| GET | `/api/stats/kpi` | KPI：总库存/今日出入库/预警/仓位使用率（真实聚合）|
| GET | `/api/stats/trend` `/category` | 出入库趋势、分类占比 |
| GET | `/api/heatmap/storages` `?storageId=` | 库位热力图（占用率与预警来自真实库存）|
| POST | `/api/inout/in` `/out` | 出入库（事务：改 `goods.count` + 库位存货 + 写流水）|
| GET/POST/PUT/DELETE | `/api/{表名}` | 18 张表的通用增删改查 |

## 真实逻辑要点

- **出入库**：`@Transactional` 中同时更新 `goods.count`、按 FIFO 调整 `location_stock`、写入 `record` 流水；出库超量返回「库存不足」。
- **库位热力图**：占用率 = 库位存货 / 容量；预警 = 占用率≥95%（积压）或货物低于 `stock_alert` 安全库存（缺货）——全部由 SQL 实时算出。
- **KPI/图表**：均为对真实库表的聚合查询，非写死数据。

## 测试

```bash
bash backend/test.sh     # 18 项集成测试，全部通过
```

覆盖：登录/错误口令/未授权拦截、KPI 与库存一致性、热力图与 `location_stock` 一致性、
仓库表 CRUD 全流程、出入库真实改库存 + 库位同步 + 超量拦截。

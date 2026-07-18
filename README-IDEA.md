# 小明智库 · IntelliJ IDEA 运行指南

超市 / 日用仓库进销存系统（Spring Boot 3 + MySQL 8 + 原生前端）。

## 一、环境要求
- JDK 17 及以上
- Maven 3.8+（或用 IDEA 内置 Maven）
- MySQL 8.0+（或 MariaDB 10.x），本机已启动

## 二、导入 IDEA
1. 解压本包。
2. IntelliJ IDEA → File → Open… → 选中 **`backend`** 目录（里面有 `pom.xml`）。
   - 也可以直接把 `backend` 文件夹拖进 IDEA 窗口。
3. IDEA 会自动识别 Maven 工程并下载依赖（首次需联网，稍等）。

## 三、初始化数据库（只需一次）
用 root 执行仓库根目录 `db/ahut_base_full.sql`（一次性建库 + 建账号 + 导入全部表和演示数据）：

```bash
mysql -uroot -p < db/ahut_base_full.sql
```
> 也可以用 IDEA 的 Database 工具、Navicat、Workbench 打开该 SQL 全部执行。
> 脚本会自动创建库 `ahut_base`、账号 `wms / wms123456` 并导入 Batch1–3 全部数据。

如果你想用自己的 root 账号连库，改 `backend/src/main/resources/application.yml` 里的
`username / password` 即可。

## 四、运行
- 方式一：打开 `backend/src/main/java/com/wms/WmsApplication.java`，点 `main` 方法左侧绿色三角运行。
- 方式二：IDEA Maven 面板执行 `spring-boot:run`，或终端 `cd backend && mvn spring-boot:run`。

启动后浏览器打开：http://localhost:8080

登录：**admin / admin123**　或　**test / 123456**

## 五、功能一览
- 运营总览：KPI、出入库趋势、分类占比、近期流水
- 预警看板 + 右上角铃铛：实时「补货提示」（低于安全下限）与「清理提示」（临期/过期批次）
- 出入库操作：入库需选落位库位（分区须匹配）、可关联订单、可传收货凭证；出库先到期先出
- 采购订单：多明细，关联供应商，可删除
- 销售订单：外卖式卡片（订单号/买家/经手账号/商品明细/时间/状态）；**不可删除，只能取消**（需填原因）
- 商品档案：图片卡片 + 库存(低则红)，点开看详情 + 出入库/库存历史折线（周/月/季/年）；含保质期与清理预警设置；**编辑不改库存**（库存由出入库管理）
- 货位管理：按分区看板，显示容量 / 已存商品与数量 / 剩余容量
- 供应商：图片 + 所供商品，可下钻到商品详情
- 操作日志：写操作真实落库可查
- 个人资料：姓名 / ID / 账号 + 修改密码

> 全站为「就地视图 + 面包屑返回」，尽量不用弹窗；仅删除确认与订单取消原因用小对话框。

## 六、商品/供应商图片
- 系统内「商品档案 / 供应商」编辑表单可**直接上传本地图片**（自动压缩存库）。
- 或把真实照片按 id 命名放进 `backend/src/main/resources/static/img/goods/<id>.jpg`、
  `.../suppliers/<id>.jpg`（对照 `static/img/README.md`），缺图自动回退内置矢量图。

## 常见问题
- **Unknown column（如 ls.expiry_date / g.zone / o.buyer）**：数据库结构是旧版本（缺增量列）。
  执行升级脚本即可，**不会丢失已有数据**：`mysql -uroot -p ahut_base < db/repair_schema.sql`，然后重启后端。
- **Unknown database 'ahut_base'**：第三步 SQL 没导入，重新执行。
- **Access denied**：`application.yml` 的账号密码与数据库不一致。
- **端口占用**：改 `application.yml` 的 `server.port`。
- **今日出入库为 0**：确认 `application.yml` 时区为 Asia/Shanghai（脚本已默认）。

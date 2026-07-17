# 在 IntelliJ IDEA 上部署运行（本地 MySQL 8）

> 本项目后端在 `backend/` 目录（Spring Boot + Maven），前端已内置于后端静态资源，
> 启动后端即可访问完整系统。数据库用你本机的 MySQL 8。

---

## 0. 准备环境

| 需要 | 说明 |
| --- | --- |
| JDK 17 或更高 | Spring Boot 3 要求 |
| MySQL 8.0（或 MariaDB 10） | 本机安装并启动，默认端口 3306 |
| IntelliJ IDEA | 社区版即可（内置 Maven）|
| Navicat / MySQL Workbench | 可选，用于导入 SQL（也可用 IDEA 自带数据库工具）|

---

## 1. 初始化数据库（只需一次）

用 **root** 执行仓库根目录的一键脚本 **`db/ahut_base_full.sql`**（已包含建库、建账号、
18 张表结构与数据、库位模型、流水、演示口令）。任选一种方式：

**方式 A：命令行**
```bash
mysql -uroot -p < db/ahut_base_full.sql
```

**方式 B：Navicat / Workbench**
新建连接 → 打开 `db/ahut_base_full.sql` → 全部执行。

执行后会自动创建：
- 数据库 `ahut_base`（19 张表：18 业务表 + 库位存货表）
- 应用账号 `wms / wms123456`（`application.yml` 默认用它）
- 演示用户：`admin / admin123`、`test / 123456`

> 若你不想用 wms 账号，也可跳过它，直接在第 3 步把 `application.yml` 改成你的 root 账号密码。

---

## 2. 用 IDEA 打开项目

1. IDEA → **File → Open** → 选择本仓库的 **`backend`** 目录（含 `pom.xml`）→ OK。
2. IDEA 识别为 Maven 工程后会自动下载依赖（右下角进度，首次约 1–2 分钟）。
3. **File → Project Structure → Project** → SDK 选 **JDK 17+**，Language level 17。
4. 如依赖没自动下载：右侧 **Maven** 面板 → 点刷新（Reload All Maven Projects）。

---

## 3. 配置数据库连接

打开 `backend/src/main/resources/application.yml`，核对 `spring.datasource`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/ahut_base?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&useSSL=false
    username: wms          # 或改成你的 root
    password: wms123456    # 或改成你的 root 密码
```

要点：
- **serverTimezone** 已预置为 `Asia/Shanghai`（与本机 MySQL 时区一致，「今日入库/出库」才准）。
  若你的 MySQL 服务器用别的时区，改成对应值即可。
- 端口/账号密码按你的实际情况改。

---

## 4. 运行

- 找到 `backend/src/main/java/com/wms/WmsApplication.java` → 点主方法左侧绿色 ▶ → **Run 'WmsApplication'**。
- 或 IDEA 右侧 Maven 面板 → `warehouse-ms → Plugins → spring-boot → spring-boot:run`。

控制台出现 `Started WmsApplication in x seconds` 即启动成功。

---

## 5. 访问

浏览器打开 **http://localhost:8080** → 登录 **admin / admin123**。

- 运营总览：KPI、出入库趋势、分类占比、仓库库位热力图
- 出入库操作、18 张表的增删改查、库位热力图均连真实数据库

---

## 常见问题

| 现象 | 处理 |
| --- | --- |
| `Access denied for user 'wms'` | 数据库没初始化或账号没建，重跑第 1 步；或把 `application.yml` 改成 root |
| `Unknown database 'ahut_base'` | 第 1 步没执行成功，重新导入 `db/ahut_base_full.sql` |
| 中文乱码 | 确认库为 `utf8mb4`，JDBC url 带 `characterEncoding=utf8`（已配好）|
| 「今日入库/出库」为 0 或不对 | 把 `serverTimezone` 改成 `Asia/Shanghai` 后重启 |
| 8080 被占用 | 改 `application.yml` 的 `server.port` |
| 端口打开是白页/404 | 确认从 `backend` 目录启动（静态页在 `resources/static`），访问根路径会跳登录页 `/login.html` |

---

## 打成 jar 部署（可选）

```bash
cd backend
mvn clean package -DskipTests
java -jar target/warehouse-ms-1.0.0.jar
```
生成的 `target/warehouse-ms-1.0.0.jar` 可直接部署到任意装有 JDK 17 的服务器（连同一个可访问的 MySQL）。

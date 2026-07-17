# 库智 WMS · SSM 版（Spring MVC + Spring + MyBatis + JSP）

按传统 **SSM + JSP** 三层结构重构的仓库管理系统，打成 **war 部署到 Tomcat**。
结构对照参考项目（controller / service / service.impl / dao(+provider) / entity / module / util / filter）。

## 技术栈

| 层 | 技术 |
| --- | --- |
| 表现层 | Spring MVC 4.2（XML 配置）+ JSP + JSTL |
| 业务层 | Service 门面（WmsService）+ 接口/实现分离 |
| 持久层 | MyBatis 3.4（注解式 DAO + SQL Provider 动态 SQL）+ PageHelper 分页 |
| 数据库 | MySQL 8（`ahut_base`），Druid 连接池 |
| 其他 | easy-captcha 图形验证码、LoginFilter 登录过滤、Lombok |
| 打包 | war → 部署到 Tomcat 9（**注意：Spring 4 用 javax，必须 Tomcat 9，不能用 Tomcat 10**） |

## 目录结构

```
warehouse-ssm/
├── pom.xml                     (war 打包)
├── db/ahut_base_full.sql       一键建库脚本
└── src/main/
    ├── java/com/wms/
    │   ├── controller/         LoginController / GoodsController / StorageController / GoodstypeController / RecordController
    │   ├── service/            WmsService、LoginService（接口）
    │   ├── service/impl/       WmsServiceImpl、LoginServiceImpl
    │   ├── dao/                GoodsDao / StorageDao / GoodstypeDao / RecordDao / SysUserDao（@Mapper）
    │   ├── dao/provider/       动态 SQL 提供类（SQL 构建器）
    │   ├── entity/             Goods / Storage / Goodstype / Record / SysUser
    │   ├── module/             MyResponse（统一返回）
    │   ├── util/common/        WmsConstants（表名常量）
    │   ├── utils/              MD5Util、ReaderXml
    │   └── filter/             LoginFilter
    ├── resources/              applicationContext.xml、springmvc-config.xml、mybatis-config.xml、db.properties、URL_List.xml、logback.xml
    └── webapp/
        ├── WEB-INF/web.xml
        ├── css/  login.jsp  main.jsp
        ├── goods/  (list/add/modify/detail.jsp)
        ├── storage/  goodstype/  (list/add/modify.jsp)
        └── record/  (list.jsp  inout.jsp)
```

## 功能模块

- **登录**：账号+密码+图形验证码，盐值散列 `md5(md5(密码)+盐)` 校验 `sys_user`；LoginFilter 拦截未登录访问。
- **商品档案**：增删改查（列表左连接仓库、分类显示名称，PageHelper 分页，重名校验）。
- **仓库管理 / 商品分类**：增删改查（删除前校验是否被商品引用）。
- **出入库操作**：入库/出库，事务内改 `goods.count` 并写 `record` 流水，出库超量拦截。
- **出入库记录**：流水列表（连接商品名、操作人）。

## 在 IDEA 中部署运行

1. **导数据库**（用 root 执行）：`mysql -uroot -p < db/ahut_base_full.sql`
   （建库 `ahut_base` + 账号 `wms/wms123456` + 全部表和数据）
2. **打开工程**：IDEA → Open → 选 `warehouse-ssm` 目录，等 Maven 下依赖。
3. **配置数据库**：按需修改 `src/main/resources/db.properties`（默认 `wms/wms123456`，可改成你的 root）。
4. **配置 Tomcat 9**：Run → Edit Configurations → + → Tomcat Server → Local
   - Deployment 里添加 `warehouse-ssm:war exploded`
   - **Application context 设为 `/`**（JSP 里用了 `/xxx` 绝对路径，必须部署到根上下文）
5. **启动**，浏览器打开 `http://localhost:8080/login.jsp`，登录 **admin / admin123**（或 test / 123456）。

## 命令行打 war

```bash
mvn clean package
# 生成 target/warehouse-ssm.war → 拷到 Tomcat9/webapps/ROOT.war（根上下文）
```

> 已在 Tomcat 9 实测：登录页、验证码、登录过滤、商品/仓库/分类 CRUD、出入库、分页均连真实数据库正常运行。

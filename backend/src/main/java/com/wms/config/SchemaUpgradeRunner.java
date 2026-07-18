package com.wms.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * 启动时自动补齐旧库缺失的增量列/表（幂等，可重复执行，绝不删除或覆盖已有数据）。
 * <p>
 * 等价于手工执行 {@code db/repair_schema.sql}，但随应用启动自动完成，
 * 避免旧版数据库因缺列（如 {@code location_stock.expiry_date}、{@code location.capacity}）
 * 导致 “货位管理 / 运营总览” 报 Unknown column 或前端读不到 totalStock。
 */
@Component
@Order(1)
public class SchemaUpgradeRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(SchemaUpgradeRunner.class);

    private final JdbcTemplate jdbc;

    public SchemaUpgradeRunner(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Override
    public void run(ApplicationArguments args) {
        try {
            upgrade();
            log.info("✔ 数据库结构自检完成：缺失列/表已补齐，已有数据未做删除或覆盖");
        } catch (Exception e) {
            // 结构自检失败不应阻断启动；记录告警，业务接口仍会按需报错提示
            log.warn("数据库结构自检失败（可手工执行 db/repair_schema.sql）：{}", e.getMessage());
        }
    }

    private void upgrade() {
        // ---------- 缺表则创建（不插演示数据） ----------
        jdbc.execute("CREATE TABLE IF NOT EXISTS `orders` (" +
            "`id` int NOT NULL AUTO_INCREMENT, `order_no` varchar(50) NOT NULL, " +
            "`type` int NOT NULL DEFAULT 0, `supplier_id` int DEFAULT NULL, " +
            "`customer_id` int DEFAULT NULL, `status` int NOT NULL DEFAULT 0, " +
            "`total_amount` decimal(12,2) DEFAULT 0.00, `order_time` datetime DEFAULT NULL, " +
            "`remark` varchar(1000) DEFAULT NULL, PRIMARY KEY(`id`), " +
            "KEY `idx_type`(`type`), KEY `idx_supplier`(`supplier_id`), KEY `idx_customer`(`customer_id`)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='订单主表'");
        jdbc.execute("CREATE TABLE IF NOT EXISTS `order_item` (" +
            "`id` int NOT NULL AUTO_INCREMENT, `order_id` int NOT NULL, `goods_id` int NOT NULL, " +
            "`count` int NOT NULL DEFAULT 0, `price` decimal(10,2) DEFAULT 0.00, " +
            "`remark` varchar(500) DEFAULT NULL, PRIMARY KEY(`id`), KEY `idx_order`(`order_id`)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='订单明细表'");
        jdbc.execute("CREATE TABLE IF NOT EXISTS `location_stock` (" +
            "`id` int NOT NULL AUTO_INCREMENT, `location_id` int NOT NULL, `goods_id` int NOT NULL, " +
            "`count` int NOT NULL DEFAULT 0, PRIMARY KEY(`id`), " +
            "KEY `idx_loc`(`location_id`), KEY `idx_goods`(`goods_id`)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='库位存货表'");

        // ---------- Batch2：goods / record ----------
        addCol("goods",  "zone",     "ALTER TABLE `goods` ADD COLUMN `zone` varchar(10) DEFAULT '普通' COMMENT '存储分区:冷冻/冰鲜/普通'");
        addCol("goods",  "image",    "ALTER TABLE `goods` ADD COLUMN `image` mediumtext COMMENT '商品图片(dataURL或路径)'");
        addCol("record", "order_id", "ALTER TABLE `record` ADD COLUMN `order_id` int DEFAULT NULL COMMENT '关联订单id'");
        addCol("record", "image",    "ALTER TABLE `record` ADD COLUMN `image` mediumtext COMMENT '入库收货凭证图片'");

        // ---------- Batch3：supplier ----------
        addCol("supplier", "image", "ALTER TABLE `supplier` ADD COLUMN `image` mediumtext COMMENT '供应商图片(dataURL或路径)'");

        // ---------- Batch4：保质期 / 批次到期 / 落位 / 销售单买家与取消 ----------
        addCol("goods", "shelf_life_days",   "ALTER TABLE `goods` ADD COLUMN `shelf_life_days` int DEFAULT NULL COMMENT '保质期天数(空=不易过期)'");
        addCol("goods", "cleanup_warn_days", "ALTER TABLE `goods` ADD COLUMN `cleanup_warn_days` int DEFAULT 7 COMMENT '到期前多少天预警清理'");
        addCol("location_stock", "inbound_date", "ALTER TABLE `location_stock` ADD COLUMN `inbound_date` datetime DEFAULT NULL COMMENT '入库日期'");
        addCol("location_stock", "expiry_date",  "ALTER TABLE `location_stock` ADD COLUMN `expiry_date` datetime DEFAULT NULL COMMENT '到期日期'");
        addCol("record", "location_id", "ALTER TABLE `record` ADD COLUMN `location_id` int DEFAULT NULL COMMENT '入库落位的库位id'");
        addCol("orders", "buyer",         "ALTER TABLE `orders` ADD COLUMN `buyer` varchar(100) DEFAULT NULL COMMENT '买家(销售单)'");
        addCol("orders", "operator_id",   "ALTER TABLE `orders` ADD COLUMN `operator_id` int DEFAULT NULL COMMENT '经手账号(sys_user.id)'");
        addCol("orders", "cancel_reason", "ALTER TABLE `orders` ADD COLUMN `cancel_reason` varchar(500) DEFAULT NULL COMMENT '取消原因'");
        addCol("orders", "cancel_time",   "ALTER TABLE `orders` ADD COLUMN `cancel_time` datetime DEFAULT NULL COMMENT '取消时间'");
        addCol("location", "zone",     "ALTER TABLE `location` ADD COLUMN `zone` varchar(10) DEFAULT NULL COMMENT '分区:冷冻/冰鲜/普通'");
        addCol("location", "row_no",   "ALTER TABLE `location` ADD COLUMN `row_no` int DEFAULT NULL COMMENT '排'");
        addCol("location", "col_no",   "ALTER TABLE `location` ADD COLUMN `col_no` int DEFAULT NULL COMMENT '列'");
        addCol("location", "capacity", "ALTER TABLE `location` ADD COLUMN `capacity` int DEFAULT 500 COMMENT '库位容量'");

        // ---------- Batch5：分类关联仓库 + 商品容量占比 ----------
        addCol("goodstype", "storage_id",    "ALTER TABLE `goodstype` ADD COLUMN `storage_id` int DEFAULT NULL COMMENT '该分类默认仓库'");
        addCol("goods",     "pieces_per_cap", "ALTER TABLE `goods` ADD COLUMN `pieces_per_cap` int DEFAULT 1 COMMENT '多少件占1库位容量'");

        // ---------- 温和回填（只补空值，不覆盖已有数据） ----------
        safeUpdate("UPDATE `goods` SET `pieces_per_cap`=1 WHERE `pieces_per_cap` IS NULL");
        safeUpdate("UPDATE `goods` SET `zone`='普通' WHERE `zone` IS NULL OR `zone`=''");
        safeUpdate("UPDATE `goods` SET `cleanup_warn_days`=7 WHERE `cleanup_warn_days` IS NULL");
        safeUpdate("UPDATE `location` SET `zone`='普通' WHERE `zone` IS NULL OR `zone`=''");
        safeUpdate("UPDATE `location` SET `capacity`=500 WHERE `capacity` IS NULL");
        // 旧存货批次补时间：入库按现在计，有保质期的按保质期推算到期
        safeUpdate("UPDATE `location_stock` ls JOIN `goods` g ON g.id=ls.goods_id " +
            "SET ls.`inbound_date`=NOW(), " +
            "    ls.`expiry_date`=IF(g.`shelf_life_days` IS NULL, NULL, NOW() + INTERVAL g.`shelf_life_days` DAY) " +
            "WHERE ls.`inbound_date` IS NULL");
    }

    /** 列不存在则执行 ALTER；已存在则跳过。 */
    private void addCol(String table, String col, String ddl) {
        try {
            Integer exists = jdbc.queryForObject(
                "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?",
                Integer.class, table, col);
            if (exists != null && exists == 0) {
                jdbc.execute(ddl);
                log.info("补齐缺失列：{}.{}", table, col);
            }
        } catch (Exception e) {
            log.warn("补齐列 {}.{} 失败：{}", table, col, e.getMessage());
        }
    }

    /** 回填语句，失败不影响后续步骤。 */
    private void safeUpdate(String sql) {
        try {
            jdbc.update(sql);
        } catch (Exception e) {
            log.warn("回填执行失败：{}", e.getMessage());
        }
    }
}

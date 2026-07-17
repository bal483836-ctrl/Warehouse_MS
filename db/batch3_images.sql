-- ============================================================
-- 库智 WMS · Batch 3 配图脚本：为商品/供应商填充内置矢量图
-- ------------------------------------------------------------
--  图片文件位于后端静态资源 static/img/goods/*.svg、static/img/suppliers/*.svg，
--  随 jar 一起发布，按路径引用（不占用大体积 dataURL）。
--  用户也可在「商品档案 / 供应商」表单中上传本地图片覆盖。
--  依赖：batch3.sql 已执行（goods.image / supplier.image 列已存在）。
-- ============================================================
USE ahut_base;

UPDATE `goods` SET `image`='/img/goods/1.svg'  WHERE id=1;
UPDATE `goods` SET `image`='/img/goods/4.svg'  WHERE id=4;
UPDATE `goods` SET `image`='/img/goods/5.svg'  WHERE id=5;
UPDATE `goods` SET `image`='/img/goods/6.svg'  WHERE id=6;
UPDATE `goods` SET `image`='/img/goods/7.svg'  WHERE id=7;
UPDATE `goods` SET `image`='/img/goods/8.svg'  WHERE id=8;
UPDATE `goods` SET `image`='/img/goods/11.svg' WHERE id=11;
UPDATE `goods` SET `image`='/img/goods/12.svg' WHERE id=12;
UPDATE `goods` SET `image`='/img/goods/13.svg' WHERE id=13;

UPDATE `supplier` SET `image`='/img/suppliers/1.svg' WHERE id=1;
UPDATE `supplier` SET `image`='/img/suppliers/2.svg' WHERE id=2;
UPDATE `supplier` SET `image`='/img/suppliers/3.svg' WHERE id=3;

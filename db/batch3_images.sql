-- ============================================================
-- 库智 WMS · Batch 3 配图脚本：为商品/供应商填充内置矢量图
-- ------------------------------------------------------------
--  优先使用真实照片：static/img/goods/<商品id>.jpg、static/img/suppliers/<供应商id>.jpg
--  （把真实产品照按 id 命名放入这两个目录即可，前端自动加载；
--    若某张 .jpg 不存在，会自动回退到同名 .svg 矢量图，绝不裂图）。
--  也可在「商品档案 / 供应商」表单中直接上传本地图片覆盖。
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

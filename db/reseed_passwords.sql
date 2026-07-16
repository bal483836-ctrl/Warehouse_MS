-- 将演示用户口令重置为已知值（散列方案：md5(md5(password)+salt)）
--   admin / admin123
--   test  / 123456
UPDATE sys_user SET password='c7e30b41bb106648f5332384471f9918' WHERE number='admin';
UPDATE sys_user SET password='aface005fbff7f7cf4ba5404cfc52ad9' WHERE number='test';

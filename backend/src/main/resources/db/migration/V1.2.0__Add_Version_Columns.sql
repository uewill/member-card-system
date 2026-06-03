-- =====================================================
-- V1.2.0__Add_Version_Columns.sql
-- 添加 version 乐观锁字段到 t_member_card 表
-- =====================================================

-- 添加 version 字段用于 MyBatis-Plus 乐观锁
ALTER TABLE t_member_card ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';

-- 同步添加 version 字段到其他可能需要并发控制的表
ALTER TABLE t_member ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';
ALTER TABLE t_consume_order ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';
ALTER TABLE t_recharge_order ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';
ALTER TABLE t_package_template ADD COLUMN version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号';

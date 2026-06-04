-- =============================================
-- Member Card System - Database Schema
-- Compatible with H2 (MySQL mode) and MySQL
-- =============================================

-- 租户表
CREATE TABLE IF NOT EXISTS tenant (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL COMMENT '公司名称',
    industry_tag VARCHAR(100) COMMENT '行业标签',
    admin_contact VARCHAR(100) COMMENT '管理员联系人',
    admin_phone VARCHAR(20) COMMENT '管理员电话',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending/approved/rejected/disabled',
    payment_methods VARCHAR(500) COMMENT '支持的支付方式JSON',
    points_enabled TINYINT DEFAULT 0 COMMENT '是否启用积分',
    version_limit INT DEFAULT 0 COMMENT '版本限制',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 门店表
CREATE TABLE IF NOT EXISTS store (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(200) NOT NULL COMMENT '门店名称',
    address VARCHAR(500) COMMENT '地址',
    phone VARCHAR(20) COMMENT '电话',
    business_hours VARCHAR(100) COMMENT '营业时间',
    status VARCHAR(20) NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled/disabled',
    allowed_card_usage VARCHAR(500) COMMENT '允许使用的卡类型JSON',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 员工表
CREATE TABLE IF NOT EXISTS employee (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(100) NOT NULL COMMENT '姓名',
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    password_hash VARCHAR(200) NOT NULL COMMENT '密码哈希',
    role VARCHAR(50) NOT NULL COMMENT '角色: store_manager/cashier/service_staff',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '状态: active/resigned',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 员工-门店关联表（多对多）
CREATE TABLE IF NOT EXISTS employee_store (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL COMMENT '员工ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    CONSTRAINT uk_employee_store UNIQUE (employee_id, store_id)
);

-- 服务项目表
CREATE TABLE IF NOT EXISTS service_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(200) NOT NULL COMMENT '服务名称',
    category VARCHAR(100) COMMENT '分类',
    price DECIMAL(10,2) NOT NULL COMMENT '单价',
    duration INT COMMENT '时长(分钟)',
    purchasable_alone TINYINT DEFAULT 1 COMMENT '是否可单独购买',
    status VARCHAR(20) NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled/disabled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 套餐模板表
CREATE TABLE IF NOT EXISTS package_template (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(200) NOT NULL COMMENT '套餐名称',
    type VARCHAR(50) NOT NULL COMMENT '类型: times_card/value_card/hybrid_card',
    service_items_json VARCHAR(2000) COMMENT '包含的服务项目JSON',
    service_counts_json VARCHAR(1000) COMMENT '服务次数JSON',
    principal_amount DECIMAL(10,2) NOT NULL COMMENT '本金金额',
    bonus_amount DECIMAL(10,2) DEFAULT 0 COMMENT '赠送金额',
    selling_price DECIMAL(10,2) NOT NULL COMMENT '售价',
    validity_type VARCHAR(20) NOT NULL COMMENT '有效期类型: days/fixed_date',
    validity_days INT COMMENT '有效天数',
    expiry_date DATE COMMENT '固定到期日',
    allow_transfer TINYINT DEFAULT 0 COMMENT '是否允许转卡',
    allow_discount_combo TINYINT DEFAULT 0 COMMENT '是否允许折扣组合',
    status VARCHAR(20) NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled/disabled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 会员表
CREATE TABLE IF NOT EXISTS member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(100) NOT NULL COMMENT '姓名',
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    birthday DATE COMMENT '生日',
    tags_json VARCHAR(500) COMMENT '标签JSON',
    source_channel VARCHAR(100) COMMENT '来源渠道',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 会员卡实例表
CREATE TABLE IF NOT EXISTS member_card (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    package_snapshot_json VARCHAR(2000) COMMENT '套餐快照JSON',
    type VARCHAR(50) NOT NULL COMMENT '卡类型: times_card/value_card/hybrid_card',
    remaining_counts_json VARCHAR(1000) COMMENT '剩余次数JSON',
    principal_balance DECIMAL(10,2) DEFAULT 0 COMMENT '本金余额',
    bonus_balance DECIMAL(10,2) DEFAULT 0 COMMENT '赠送余额',
    expiry_date DATE COMMENT '到期日',
    status VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT '状态: active/expired/depleted/frozen/transferred',
    card_no VARCHAR(50) NOT NULL COMMENT '卡号',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 消费订单表
CREATE TABLE IF NOT EXISTS consume_order (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '总金额',
    actual_paid DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    payment_methods_json VARCHAR(500) COMMENT '支付方式JSON',
    employee_id BIGINT COMMENT '操作员工ID',
    status VARCHAR(20) NOT NULL DEFAULT 'normal' COMMENT '状态: normal/cancelled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 消费明细表
CREATE TABLE IF NOT EXISTS consume_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    service_item_id BIGINT COMMENT '服务项目ID',
    card_id BIGINT COMMENT '使用的卡ID',
    deduction_type VARCHAR(20) COMMENT '扣减类型: count/balance',
    deduction_count INT DEFAULT 0 COMMENT '扣减次数',
    deduction_amount DECIMAL(10,2) DEFAULT 0 COMMENT '扣减金额',
    before_snapshot_json VARCHAR(1000) COMMENT '扣减前快照JSON',
    after_snapshot_json VARCHAR(1000) COMMENT '扣减后快照JSON',
    employee_ratio_json VARCHAR(500) COMMENT '员工业绩分配比例JSON',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 支付记录表
CREATE TABLE IF NOT EXISTS payment_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    order_id BIGINT COMMENT '关联订单ID',
    type VARCHAR(50) NOT NULL COMMENT '类型: sell_card/recharge/consume_diff',
    payment_method VARCHAR(50) NOT NULL COMMENT '支付方式: wechat/alipay/cash/card_deduction',
    amount DECIMAL(10,2) NOT NULL COMMENT '金额',
    card_deductions_json VARCHAR(500) COMMENT '卡扣减明细JSON',
    cash_amount DECIMAL(10,2) DEFAULT 0 COMMENT '现金金额',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 充值赠送规则表
CREATE TABLE IF NOT EXISTS recharge_rule (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    min_amount DECIMAL(10,2) NOT NULL COMMENT '最低充值金额',
    bonus_amount DECIMAL(10,2) NOT NULL COMMENT '赠送金额',
    bonus_type VARCHAR(20) NOT NULL COMMENT '赠送类型: fixed/ratio',
    bonus_ratio DECIMAL(5,2) DEFAULT 0 COMMENT '赠送比例(%)',
    status VARCHAR(20) NOT NULL DEFAULT 'enabled' COMMENT '状态: enabled/disabled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 业绩记录表
CREATE TABLE IF NOT EXISTS performance_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    employee_id BIGINT NOT NULL COMMENT '员工ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    date DATE NOT NULL COMMENT '日期',
    service_count INT DEFAULT 0 COMMENT '服务次数',
    service_amount DECIMAL(10,2) DEFAULT 0 COMMENT '服务金额',
    commission DECIMAL(10,2) DEFAULT 0 COMMENT '提成',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 初始化数据
-- =============================================

-- 1. 租户：美丽人生美容会所
INSERT INTO tenant (id, company_name, industry_tag, admin_contact, admin_phone, status, payment_methods, points_enabled, version_limit)
VALUES (1, '美丽人生美容会所', '美容', '张经理', '13800138000', 'approved',
        '["wechat","alipay","cash"]', 1, 10);

-- 2. 门店：旗舰店
INSERT INTO store (id, tenant_id, name, address, phone, business_hours, status, allowed_card_usage)
VALUES (1, 1, '旗舰店', '北京市朝阳区建国路88号', '010-88886666', '09:00-21:00', 'enabled',
        '["times_card","value_card","hybrid_card"]');

-- 3. 员工：管理员（密码 123456 的 bcrypt 哈希）
INSERT INTO employee (id, tenant_id, name, phone, password_hash, role, status)
VALUES (1, 1, '管理员', '13800138000',
        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'store_manager', 'active');

INSERT INTO employee (id, tenant_id, name, phone, password_hash, role, status)
VALUES (2, 1, '小李', '13900139001',
        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'service_staff', 'active');

INSERT INTO employee (id, tenant_id, name, phone, password_hash, role, status)
VALUES (3, 1, '小王', '13900139002',
        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'cashier', 'active');

-- 员工-门店关联
INSERT INTO employee_store (employee_id, store_id) VALUES (1, 1);
INSERT INTO employee_store (employee_id, store_id) VALUES (2, 1);
INSERT INTO employee_store (employee_id, store_id) VALUES (3, 1);

-- 4. 服务项目（6个）
INSERT INTO service_item (id, tenant_id, name, category, price, duration, purchasable_alone, status) VALUES
(1, 1, '面部护理', '面部', 198.00, 60, 1, 'enabled'),
(2, 1, '精油按摩', '身体', 268.00, 90, 1, 'enabled'),
(3, 1, '头部护理', '头部', 128.00, 45, 1, 'enabled'),
(4, 1, '美甲', '手部', 88.00, 30, 1, 'enabled'),
(5, 1, '脱毛', '身体', 168.00, 30, 1, 'enabled'),
(6, 1, '身体SPA', '身体', 388.00, 120, 1, 'enabled');

-- 5. 套餐模板（4个）
INSERT INTO package_template (id, tenant_id, name, type, service_items_json, service_counts_json,
    principal_amount, bonus_amount, selling_price, validity_type, validity_days, allow_transfer, allow_discount_combo, status) VALUES
(1, 1, '面部护理10次卡', 'times_card',
    '[{"serviceItemId":1,"name":"面部护理","price":198}]',
    '{"1":10}',
    1980.00, 0, 1980.00, 'days', 365, 0, 0, 'enabled'),
(2, 1, 'VIP储值卡', 'value_card',
    '[]',
    '{}',
    2500.00, 300.00, 2500.00, 'days', 730, 0, 1, 'enabled'),
(3, 1, '综合护理混合卡', 'hybrid_card',
    '[{"serviceItemId":1,"name":"面部护理","price":198},{"serviceItemId":2,"name":"精油按摩","price":268},{"serviceItemId":3,"name":"头部护理","price":128}]',
    '{"1":5,"2":3,"3":5}',
    2880.00, 0, 2880.00, 'days', 365, 0, 0, 'enabled'),
(4, 1, '体验套餐3次', 'times_card',
    '[{"serviceItemId":1,"name":"面部护理","price":198},{"serviceItemId":3,"name":"头部护理","price":128}]',
    '{"1":2,"3":1}',
    199.00, 0, 199.00, 'days', 90, 0, 0, 'enabled');

-- 6. 会员（5个）
INSERT INTO member (id, tenant_id, name, phone, birthday, tags_json, source_channel) VALUES
(1, 1, '王芳', '13800001111', '1990-05-15', '["VIP"]', '线上推广'),
(2, 1, '刘洋', '13800002222', '1988-11-20', '[]', '朋友推荐'),
(3, 1, '陈静', '13800003333', '1995-03-08', '["VIP"]', '线下活动'),
(4, 1, '李娜', '13800004444', '1992-07-22', '[]', '自然到店'),
(5, 1, '张伟', '13800005555', '1985-09-10', '[]', '线上推广');

-- 7. 会员卡实例（6张，含不同状态）
INSERT INTO member_card (id, tenant_id, member_id, package_snapshot_json, type, remaining_counts_json,
    principal_balance, bonus_balance, expiry_date, status, card_no) VALUES
(1, 1, 1,
    '{"packageId":1,"name":"面部护理10次卡","type":"times_card","principalAmount":1980}',
    'times_card', '{"1":8}', 0, 0,
    DATEADD('YEAR', 1, CURRENT_DATE), 'active', 'MC20240001'),
(2, 1, 1,
    '{"packageId":2,"name":"VIP储值卡","type":"value_card","principalAmount":2500,"bonusAmount":300}',
    'value_card', '{}', 1800.00, 200.00,
    DATEADD('YEAR', 2, CURRENT_DATE), 'active', 'MC20240002'),
(3, 1, 2,
    '{"packageId":3,"name":"综合护理混合卡","type":"hybrid_card","principalAmount":2880}',
    'hybrid_card', '{"1":3,"2":1,"3":4}', 0, 0,
    DATEADD('YEAR', 1, CURRENT_DATE), 'active', 'MC20240003'),
(4, 1, 3,
    '{"packageId":1,"name":"面部护理10次卡","type":"times_card","principalAmount":1980}',
    'times_card', '{"1":0}', 0, 0,
    DATEADD('YEAR', 1, CURRENT_DATE), 'depleted', 'MC20240004'),
(5, 1, 4,
    '{"packageId":4,"name":"体验套餐3次","type":"times_card","principalAmount":199}',
    'times_card', '{"1":1,"3":1}', 0, 0,
    DATEADD('DAY', -10, CURRENT_DATE), 'expired', 'MC20240005'),
(6, 1, 5,
    '{"packageId":2,"name":"VIP储值卡","type":"value_card","principalAmount":2500,"bonusAmount":300}',
    'value_card', '{}', 2500.00, 300.00,
    DATEADD('YEAR', 2, CURRENT_DATE), 'active', 'MC20240006');

-- 8. 充值赠送规则（4条）
INSERT INTO recharge_rule (id, tenant_id, min_amount, bonus_amount, bonus_type, bonus_ratio, status) VALUES
(1, 1, 1000.00, 50.00, 'fixed', 0, 'enabled'),
(2, 1, 2000.00, 200.00, 'fixed', 0, 'enabled'),
(3, 1, 3000.00, 0, 'ratio', 10.00, 'enabled'),
(4, 1, 5000.00, 0, 'ratio', 15.00, 'enabled');

-- 9. 消费订单和明细
INSERT INTO consume_order (id, tenant_id, store_id, member_id, total_amount, actual_paid, payment_methods_json, employee_id, status) VALUES
(1, 1, 1, 1, 198.00, 0.00, '["card_deduction"]', 2, 'normal'),
(2, 1, 1, 1, 268.00, 68.00, '["card_deduction","cash"]', 2, 'normal'),
(3, 1, 1, 2, 466.00, 0.00, '["card_deduction"]', 3, 'normal'),
(4, 1, 1, 3, 198.00, 0.00, '["card_deduction"]', 2, 'normal');

INSERT INTO consume_detail (id, tenant_id, order_id, service_item_id, card_id, deduction_type, deduction_count, deduction_amount, before_snapshot_json, after_snapshot_json, employee_ratio_json) VALUES
(1, 1, 1, 1, 1, 'count', 1, 0, '{"1":9}', '{"1":8}', '{"2":1.0}'),
(2, 1, 2, 2, 2, 'balance', 0, 200.00, '{"principal":2000,"bonus":200}', '{"principal":1800,"bonus":200}', '{"2":1.0}'),
(3, 1, 3, 1, 3, 'count', 1, 0, '{"1":4,"2":2,"3":5}', '{"1":3,"2":1,"3":5}', '{"3":1.0}'),
(4, 1, 3, 2, 3, 'count', 1, 0, '{"1":3,"2":2,"3":5}', '{"1":3,"2":1,"3":5}', '{"3":1.0}'),
(5, 1, 4, 1, 4, 'count', 1, 0, '{"1":1}', '{"1":0}', '{"2":1.0}');

-- 10. 支付记录
INSERT INTO payment_record (id, tenant_id, store_id, order_id, type, payment_method, amount, card_deductions_json, cash_amount) VALUES
(1, 1, 1, 1, 'consume_diff', 'card_deduction', 0.00, '[{"cardId":1,"amount":0,"count":1}]', 0),
(2, 1, 1, 2, 'consume_diff', 'card_deduction', 200.00, '[{"cardId":2,"amount":200}]', 0),
(3, 1, 1, 2, 'consume_diff', 'cash', 68.00, '[]', 68.00),
(4, 1, 1, NULL, 'sell_card', 'wechat', 1980.00, '[]', 0),
(5, 1, 1, NULL, 'sell_card', 'alipay', 2880.00, '[]', 0),
(6, 1, 1, NULL, 'sell_card', 'cash', 199.00, '[]', 0),
(7, 1, 1, NULL, 'recharge', 'wechat', 2500.00, '[]', 0),
(8, 1, 1, NULL, 'recharge', 'alipay', 2500.00, '[]', 0);

-- 11. 业绩记录
INSERT INTO performance_record (id, tenant_id, employee_id, store_id, date, service_count, service_amount, commission) VALUES
(1, 1, 2, 1, CURRENT_DATE - 1, 3, 664.00, 66.40),
(2, 1, 3, 1, CURRENT_DATE - 1, 1, 466.00, 46.60),
(3, 1, 2, 1, CURRENT_DATE, 2, 466.00, 46.60);

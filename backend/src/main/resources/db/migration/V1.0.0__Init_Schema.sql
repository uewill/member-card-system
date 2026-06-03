-- =====================================================
-- V1.0.0__Init_Schema.sql
-- 通用多租户次卡会员管理系统 - 核心表结构初始化
-- =====================================================

-- 1. 租户表（平台级，不含 tenant_id）
CREATE TABLE IF NOT EXISTS sys_tenant (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '租户ID',
    company_name VARCHAR(100) NOT NULL COMMENT '公司名称',
    industry VARCHAR(50) COMMENT '行业标签',
    admin_phone VARCHAR(20) NOT NULL COMMENT '管理员手机号',
    admin_name VARCHAR(50) COMMENT '管理员姓名',
    status TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_admin_phone (admin_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户表';

-- 2. 全局字典表（平台级，不含 tenant_id）
CREATE TABLE IF NOT EXISTS sys_global_dict (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '字典ID',
    dict_type VARCHAR(50) NOT NULL COMMENT '字典类型',
    dict_key VARCHAR(50) NOT NULL COMMENT '字典键',
    dict_value VARCHAR(100) NOT NULL COMMENT '字典值',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_type_key (dict_type, dict_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='全局字典表';

-- 初始化行业分类字典
INSERT INTO sys_global_dict (dict_type, dict_key, dict_value, sort_order) VALUES
('INDUSTRY', 'HAIRCUT', '美发', 1),
('INDUSTRY', 'BEAUTY', '美容', 2),
('INDUSTRY', 'NAIL', '美甲', 3),
('INDUSTRY', 'FITNESS', '健身', 4),
('INDUSTRY', 'CAR_WASH', '洗车', 5),
('INDUSTRY', 'EDUCATION', '教育培训', 6);

-- 3. 门店表（租户级）
CREATE TABLE IF NOT EXISTS t_store (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '门店ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_name VARCHAR(100) NOT NULL COMMENT '门店名称',
    address VARCHAR(200) COMMENT '地址',
    phone VARCHAR(20) COMMENT '联系电话',
    business_hours VARCHAR(100) COMMENT '营业时间',
    status TINYINT DEFAULT 1 COMMENT '状态：1-正常，0-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='门店表';

-- 4. 用户/员工表（租户级）
CREATE TABLE IF NOT EXISTS t_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_id BIGINT COMMENT '所属门店ID（可空，平台管理员无门店）',
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    name VARCHAR(50) COMMENT '姓名',
    password VARCHAR(100) NOT NULL COMMENT '密码（加密）',
    role VARCHAR(20) NOT NULL COMMENT '角色：TENANT_ADMIN/STORE_MANAGER/CASHIER/SERVICE_STAFF/MEMBER',
    status TINYINT DEFAULT 1 COMMENT '状态：1-在职，0-离职',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tenant_phone (tenant_id, phone),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_store_id (store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户/员工表';

-- 5. 会员表（租户级）
CREATE TABLE IF NOT EXISTS t_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会员ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    name VARCHAR(50) COMMENT '姓名',
    birthday DATE COMMENT '生日',
    tags VARCHAR(200) COMMENT '标签（JSON数组）',
    source_channel VARCHAR(50) COMMENT '来源渠道',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tenant_phone (tenant_id, phone),
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

-- 6. 服务项目表（租户级）
CREATE TABLE IF NOT EXISTS t_service_item (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '服务项目ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    category VARCHAR(50) COMMENT '分类',
    name VARCHAR(100) NOT NULL COMMENT '服务名称',
    price DECIMAL(10,2) NOT NULL COMMENT '单次价格',
    duration INT COMMENT '服务时长（分钟）',
    can_single_purchase TINYINT DEFAULT 1 COMMENT '是否可单独购买',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务项目表';

-- 7. 次卡套餐模板表（租户级）
CREATE TABLE IF NOT EXISTS t_package_template (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '套餐模板ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(100) NOT NULL COMMENT '套餐名称',
    type VARCHAR(20) NOT NULL COMMENT '类型：COUNT/VALUE/MIXED',
    -- 套餐配置（JSON格式存储绑定服务项目及次数/金额）
    config JSON NOT NULL COMMENT '套餐配置JSON',
    sale_price DECIMAL(10,2) NOT NULL COMMENT '售价',
    validity_days INT COMMENT '有效期天数（NULL表示固定截止日期）',
    validity_end_date DATE COMMENT '固定截止日期',
    allow_transfer TINYINT DEFAULT 0 COMMENT '是否允许转赠',
    allow_combine TINYINT DEFAULT 1 COMMENT '是否允许与其他优惠同享',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='次卡套餐模板表';

-- 8. 会员卡实例表（租户级）
CREATE TABLE IF NOT EXISTS t_member_card (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '卡实例ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    template_id BIGINT NOT NULL COMMENT '套餐模板ID',
    -- 模板快照（JSON格式，购买时冻结）
    template_snapshot JSON NOT NULL COMMENT '模板快照JSON',
    -- 剩余次数（JSON格式，按服务项目记录）
    remaining_counts JSON COMMENT '剩余次数JSON',
    -- 储值余额
    balance_principal DECIMAL(10,2) DEFAULT 0 COMMENT '本金余额',
    balance_gift DECIMAL(10,2) DEFAULT 0 COMMENT '赠送余额',
    valid_from DATE NOT NULL COMMENT '生效日期',
    valid_to DATE NOT NULL COMMENT '到期日期',
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/EXPIRED/USED_UP/FROZEN/TRANSFERRED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员卡实例表';

-- 9. 消费订单表（租户级）
CREATE TABLE IF NOT EXISTS t_consume_order (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    order_no VARCHAR(50) NOT NULL COMMENT '订单号',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '总金额',
    paid_amount DECIMAL(10,2) NOT NULL COMMENT '实付金额',
    -- 支付方式明细（JSON格式）
    payment_detail JSON COMMENT '支付方式明细JSON',
    status VARCHAR(20) DEFAULT 'COMPLETED' COMMENT '状态：COMPLETED/CANCELLED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_order_no (order_no),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_store_id (store_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消费订单表';

-- 10. 消费明细表（租户级）
CREATE TABLE IF NOT EXISTS t_consume_detail (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '明细ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    order_id BIGINT NOT NULL COMMENT '订单ID',
    service_item_id BIGINT NOT NULL COMMENT '服务项目ID',
    service_item_name VARCHAR(100) COMMENT '服务项目名称（快照）',
    service_staff_id BIGINT COMMENT '服务人员ID',
    service_staff_name VARCHAR(50) COMMENT '服务人员姓名（快照）',
    -- 业绩分摊比例（多员工协作时使用）
    performance_ratio DECIMAL(5,2) DEFAULT 1.00 COMMENT '业绩分摊比例',
    -- 扣减的卡实例ID
    card_id BIGINT COMMENT '扣减的卡实例ID',
    -- 扣减类型：COUNT/VALUE
    deduct_type VARCHAR(20) COMMENT '扣减类型',
    -- 扣减前/后快照
    deduct_before VARCHAR(100) COMMENT '扣减前数值',
    deduct_after VARCHAR(100) COMMENT '扣减后数值',
    deduct_amount DECIMAL(10,2) COMMENT '扣减金额',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消费明细表';

-- 11. 充值/购卡订单表（租户级）
CREATE TABLE IF NOT EXISTS t_recharge_order (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '充值订单ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    store_id BIGINT NOT NULL COMMENT '门店ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    order_no VARCHAR(50) NOT NULL COMMENT '订单号',
    -- 订单类型：PURCHASE/RECHARGE
    order_type VARCHAR(20) NOT NULL COMMENT '订单类型',
    template_id BIGINT COMMENT '套餐模板ID（购卡时）',
    card_id BIGINT COMMENT '充值目标卡ID（充值时）',
    amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    gift_amount DECIMAL(10,2) DEFAULT 0 COMMENT '赠送金额',
    payment_method VARCHAR(20) COMMENT '支付方式：WECHAT/ALIPAY/CASH',
    payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '支付状态：PENDING/SUCCESS/FAILED/CLOSED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_order_no (order_no),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值/购卡订单表';

-- 12. 操作日志表（租户级）
CREATE TABLE IF NOT EXISTS t_operation_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    member_id BIGINT COMMENT '会员ID',
    operator_id BIGINT COMMENT '操作人ID',
    operator_name VARCHAR(50) COMMENT '操作人姓名',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_detail JSON COMMENT '操作详情JSON',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 13. 套餐赠送规则表（租户级）
CREATE TABLE IF NOT EXISTS t_gift_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '规则ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    min_amount DECIMAL(10,2) NOT NULL COMMENT '最低充值金额',
    max_amount DECIMAL(10,2) COMMENT '最高充值金额（NULL表示无上限）',
    gift_amount DECIMAL(10,2) NOT NULL COMMENT '赠送金额',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='赠送规则表';

-- 14. 积分记录表（租户级）
CREATE TABLE IF NOT EXISTS t_points_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    points INT NOT NULL COMMENT '积分变动（正为增加，负为减少）',
    balance_after INT NOT NULL COMMENT '变动后余额',
    source VARCHAR(50) COMMENT '来源：CONSUME/EXCHANGE/GIFT',
    related_order_id BIGINT COMMENT '关联订单ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分记录表';

-- 15. 优惠券表（租户级）
CREATE TABLE IF NOT EXISTS t_coupon (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '优惠券ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    type VARCHAR(20) NOT NULL COMMENT '类型：DISCOUNT/FULL_REDUCTION',
    -- 优惠配置（折扣比例或满减金额）
    config JSON NOT NULL COMMENT '优惠配置JSON',
    -- 适用范围（服务项目ID列表）
    applicable_items JSON COMMENT '适用服务项目JSON',
    valid_from DATE COMMENT '生效日期',
    valid_to DATE COMMENT '到期日期',
    total_count INT COMMENT '发行总量',
    used_count INT DEFAULT 0 COMMENT '已使用数量',
    status TINYINT DEFAULT 1 COMMENT '状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 16. 会员优惠券领取表（租户级）
CREATE TABLE IF NOT EXISTS t_member_coupon (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '领取记录ID',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    member_id BIGINT NOT NULL COMMENT '会员ID',
    coupon_id BIGINT NOT NULL COMMENT '优惠券ID',
    status VARCHAR(20) DEFAULT 'UNUSED' COMMENT '状态：UNUSED/USED/EXPIRED',
    used_order_id BIGINT COMMENT '使用的订单ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_member_id (member_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员优惠券领取表';

-- 17. 行业模板表（平台级）
CREATE TABLE IF NOT EXISTS sys_industry_template (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    industry VARCHAR(50) NOT NULL COMMENT '行业',
    -- 服务项目模板（JSON格式）
    service_items JSON NOT NULL COMMENT '服务项目模板JSON',
    -- 套餐模板（JSON格式）
    package_templates JSON COMMENT '套餐模板JSON',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_industry (industry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行业模板表';
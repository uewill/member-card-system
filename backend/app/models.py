from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Store(Base):
    __tablename__ = "stores"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    address = Column(String(255), default="")
    phone = Column(String(20), default="")
    business_hours = Column(String(100), default="")
    status = Column(String(20), default="营业中")

    staff = relationship("Staff", back_populates="store", lazy="selectin")
    members = relationship("Member", back_populates="store", lazy="selectin")
    card_types = relationship("CardType", back_populates="store", lazy="selectin")
    products = relationship("Product", back_populates="store", lazy="selectin")
    bonus_rules = relationship("BonusRule", back_populates="store", lazy="selectin")
    print_templates = relationship("PrintTemplate", back_populates="store", lazy="selectin")


class Staff(Base):
    __tablename__ = "staff"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(50), nullable=False)
    role = Column(String(20), default="staff")
    phone = Column(String(20), default="")
    status = Column(String(20), default="在职")
    created_at = Column(DateTime, default=datetime.utcnow)

    store = relationship("Store", back_populates="staff")


class Member(Base):
    __tablename__ = "members"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(50), nullable=False)
    phone = Column(String(20), nullable=False)
    level = Column(String(20), default="普通")
    balance = Column(Float, default=0.0)
    points = Column(Integer, default=0)
    total_spent = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)

    store = relationship("Store", back_populates="members")
    cards = relationship("MemberCard", back_populates="member", lazy="selectin")
    verify_records = relationship("VerifyRecord", back_populates="member", lazy="selectin")
    recharge_records = relationship("RechargeRecord", back_populates="member", lazy="selectin")


class CardType(Base):
    __tablename__ = "card_types"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), nullable=False)
    times = Column(Integer, default=0)
    amount = Column(Float, default=0.0)
    price = Column(Float, default=0.0)
    validity_days = Column(Integer, default=365)
    services = Column(Text, default="")
    status = Column(String(20), default="启用")

    store = relationship("Store", back_populates="card_types")
    cards = relationship("MemberCard", back_populates="card_type", lazy="selectin")


class MemberCard(Base):
    __tablename__ = "member_cards"

    id = Column(Integer, primary_key=True, index=True)
    member_id = Column(Integer, ForeignKey("members.id"), nullable=False)
    card_type_id = Column(Integer, ForeignKey("card_types.id"), nullable=True)
    card_no = Column(String(50), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), nullable=False)
    total_times = Column(Integer, default=0)
    used_times = Column(Integer, default=0)
    balance = Column(Float, default=0.0)
    price = Column(Float, default=0.0)
    valid_start = Column(DateTime, default=datetime.utcnow)
    valid_end = Column(DateTime, nullable=True)
    status = Column(String(20), default="正常")

    member = relationship("Member", back_populates="cards")
    card_type = relationship("CardType", back_populates="cards")
    verify_records = relationship("VerifyRecord", back_populates="card", lazy="selectin")


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(100), nullable=False)
    category = Column(String(50), nullable=False)
    price = Column(Float, default=0.0)
    description = Column(Text, default="")
    status = Column(String(20), default="上架")

    store = relationship("Store", back_populates="products")


class BonusRule(Base):
    __tablename__ = "bonus_rules"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    min_amount = Column(Float, default=0.0)
    bonus_amount = Column(Float, default=0.0)
    bonus_type = Column(String(20), default="固定")
    bonus_ratio = Column(Float, default=0.0)
    validity_days = Column(Integer, default=365)
    status = Column(String(20), default="启用")

    store = relationship("Store", back_populates="bonus_rules")


class VerifyRecord(Base):
    __tablename__ = "verify_records"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    member_id = Column(Integer, ForeignKey("members.id"), nullable=False)
    card_id = Column(Integer, ForeignKey("member_cards.id"), nullable=True)
    service_name = Column(String(100), default="")
    times_used = Column(Integer, default=1)
    before_times = Column(Integer, default=0)
    after_times = Column(Integer, default=0)
    staff_id = Column(Integer, ForeignKey("staff.id"), nullable=True)
    staff_name = Column(String(50), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    member = relationship("Member", back_populates="verify_records")
    card = relationship("MemberCard", back_populates="verify_records")


class RechargeRecord(Base):
    __tablename__ = "recharge_records"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    member_id = Column(Integer, ForeignKey("members.id"), nullable=False)
    amount = Column(Float, default=0.0)
    bonus_amount = Column(Float, default=0.0)
    total_amount = Column(Float, default=0.0)
    pay_method = Column(String(20), default="现金")
    staff_id = Column(Integer, ForeignKey("staff.id"), nullable=True)
    staff_name = Column(String(50), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    member = relationship("Member", back_populates="recharge_records")


class PrintTemplate(Base):
    __tablename__ = "print_templates"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), default="receipt")
    protocol = Column(String(20), default="ESC")
    template_json = Column(Text, default="{}")
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    store = relationship("Store", back_populates="print_templates")


# 员工角色变更日志
class EmployeeRoleChangeLog(Base):
    __tablename__ = "employee_role_change_logs"
    id = Column(Integer, primary_key=True, index=True)
    staff_id = Column(Integer, ForeignKey("staff.id"))
    old_role = Column(String(50))
    new_role = Column(String(50))
    changed_by = Column(Integer, ForeignKey("staff.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

# 会员操作日志
class MemberOperationLog(Base):
    __tablename__ = "member_operation_logs"
    id = Column(Integer, primary_key=True, index=True)
    member_id = Column(Integer, ForeignKey("members.id"))
    operation_type = Column(String(20))  # 消费/充值/购买/转赠/过期
    amount_change = Column(Float, default=0)
    count_change = Column(Integer, default=0)
    operator_id = Column(Integer, nullable=True)
    operator_name = Column(String(50), default="")
    description = Column(Text, default="")
    created_at = Column(DateTime, default=datetime.utcnow)

# 卡状态变更日志
class CardStatusChangeLog(Base):
    __tablename__ = "card_status_change_logs"
    id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("member_cards.id"))
    old_status = Column(String(20))
    new_status = Column(String(20))
    changed_by = Column(Integer, nullable=True)
    reason = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

# 卡扣减快照
class CardDeductionSnapshot(Base):
    __tablename__ = "card_deduction_snapshots"
    id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("member_cards.id"))
    verify_record_id = Column(Integer, nullable=True)
    before_count = Column(Integer, default=0)
    after_count = Column(Integer, default=0)
    before_balance = Column(Float, default=0)
    after_balance = Column(Float, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

# 消费订单
class ConsumeOrder(Base):
    __tablename__ = "consume_orders"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    member_id = Column(Integer, ForeignKey("members.id"), nullable=False)
    total_amount = Column(Float, default=0)
    actual_paid = Column(Float, default=0)
    payment_method = Column(String(20), default="卡扣")
    status = Column(String(20), default="已完成")  # 已完成/已撤销
    operator_id = Column(Integer, ForeignKey("staff.id"), nullable=True)
    service_items = Column(Text, default="[]")  # JSON: 服务项目列表
    card_id = Column(Integer, ForeignKey("member_cards.id"), nullable=True)
    deduction_type = Column(String(20), default="次数")  # 次数/余额
    deduction_count = Column(Integer, default=0)
    deduction_amount = Column(Float, default=0)
    cancel_reason = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    cancelled_at = Column(DateTime, nullable=True)

# 支付订单
class PaymentOrder(Base):
    __tablename__ = "payment_orders"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    member_id = Column(Integer, ForeignKey("members.id"), nullable=False)
    order_type = Column(String(20), default="售卖开卡")  # 售卖开卡/储值充值/消费补齐
    amount = Column(Float, default=0)
    payment_method = Column(String(20), default="现金")
    status = Column(String(20), default="已支付")  # 待支付/已支付/已关闭/已退款
    transaction_no = Column(String(100), default="")
    paid_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# 优惠券
class Coupon(Base):
    __tablename__ = "coupons"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), default="满减券")  # 满减券/折扣券
    discount_value = Column(Float, default=0)
    min_amount = Column(Float, default=0)
    total_count = Column(Integer, default=100)
    used_count = Column(Integer, default=0)
    valid_from = Column(String(20), default="")
    valid_until = Column(String(20), default="")
    status = Column(String(20), default="启用")
    created_at = Column(DateTime, default=datetime.utcnow)

# 积分规则
class PointsRule(Base):
    __tablename__ = "points_rules"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    earn_ratio = Column(Float, default=1.0)  # 每消费N元积1分
    status = Column(String(20), default="启用")
    created_at = Column(DateTime, default=datetime.utcnow)

# 消息模板
class MessageTemplate(Base):
    __tablename__ = "message_templates"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    name = Column(String(100), nullable=False)
    type = Column(String(20), default="卡到期提醒")  # 卡到期提醒/生日祝福/活动通知
    channel = Column(String(20), default="短信")
    content = Column(Text, default="")
    status = Column(String(20), default="启用")
    created_at = Column(DateTime, default=datetime.utcnow)

# 营销设置
class MarketingSettings(Base):
    __tablename__ = "marketing_settings"
    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("stores.id"), nullable=False)
    points_enabled = Column(Boolean, default=True)
    coupon_enabled = Column(Boolean, default=True)
    message_enabled = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# 角色
class Role(Base):
    __tablename__ = "roles"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    code = Column(String(50), unique=True, nullable=False)  # PLATFORM_ADMIN/MERCHANT_ADMIN/STORE_MANAGER/CASHIER/SERVICE_STAFF/MEMBER
    description = Column(String(255), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

# 权限
class Permission(Base):
    __tablename__ = "permissions"
    id = Column(Integer, primary_key=True, index=True)
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=False)
    menu_id = Column(Integer, nullable=True)
    api_path = Column(String(200), default="")
    method = Column(String(10), default="GET")
    created_at = Column(DateTime, default=datetime.utcnow)

# 审计日志
class AuditLog(Base):
    __tablename__ = "audit_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    action = Column(String(100), default="")
    resource_type = Column(String(50), default="")
    resource_id = Column(Integer, nullable=True)
    ip_address = Column(String(50), default="")
    result = Column(String(20), default="成功")
    description = Column(Text, default="")
    created_at = Column(DateTime, default=datetime.utcnow)

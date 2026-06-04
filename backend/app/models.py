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

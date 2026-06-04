from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ResponseModel(BaseModel):
    code: int = 200
    message: str = "success"
    data: Optional[dict] = None


def success_response(data=None, message="success"):
    return {"code": 200, "message": message, "data": data}


def error_response(message="error", code=400):
    return {"code": code, "message": message, "data": None}


# Store
class StoreBase(BaseModel):
    name: str
    address: Optional[str] = ""
    phone: Optional[str] = ""
    business_hours: Optional[str] = ""
    status: Optional[str] = "营业中"


class StoreCreate(StoreBase):
    pass


class StoreUpdate(StoreBase):
    pass


class StoreOut(StoreBase):
    id: int

    class Config:
        from_attributes = True


# Staff
class StaffBase(BaseModel):
    store_id: int
    username: str
    name: str
    role: Optional[str] = "staff"
    phone: Optional[str] = ""
    status: Optional[str] = "在职"


class StaffCreate(StaffBase):
    password: str


class StaffUpdate(BaseModel):
    name: Optional[str] = None
    role: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None


class StaffOut(StaffBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class StaffLogin(BaseModel):
    username: str
    password: str


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


# Member
class MemberBase(BaseModel):
    store_id: int
    name: str
    phone: str
    level: Optional[str] = "普通"
    balance: Optional[float] = 0.0
    points: Optional[int] = 0
    total_spent: Optional[float] = 0.0


class MemberCreate(MemberBase):
    pass


class MemberUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    level: Optional[str] = None
    balance: Optional[float] = None
    points: Optional[int] = None
    total_spent: Optional[float] = None


class MemberOut(MemberBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class MemberDetailOut(MemberOut):
    cards: List["MemberCardOut"] = []
    verify_records: List["VerifyRecordOut"] = []
    recharge_records: List["RechargeRecordOut"] = []


# CardType
class CardTypeBase(BaseModel):
    store_id: int
    name: str
    type: str
    times: Optional[int] = 0
    amount: Optional[float] = 0.0
    price: Optional[float] = 0.0
    validity_days: Optional[int] = 365
    services: Optional[str] = ""
    status: Optional[str] = "启用"


class CardTypeCreate(CardTypeBase):
    pass


class CardTypeUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    times: Optional[int] = None
    amount: Optional[float] = None
    price: Optional[float] = None
    validity_days: Optional[int] = None
    services: Optional[str] = None
    status: Optional[str] = None


class CardTypeOut(CardTypeBase):
    id: int

    class Config:
        from_attributes = True


# MemberCard
class MemberCardBase(BaseModel):
    member_id: int
    card_type_id: Optional[int] = None
    card_no: str
    name: str
    type: str
    total_times: Optional[int] = 0
    used_times: Optional[int] = 0
    balance: Optional[float] = 0.0
    price: Optional[float] = 0.0
    valid_start: Optional[datetime] = None
    valid_end: Optional[datetime] = None
    status: Optional[str] = "正常"


class MemberCardCreate(MemberCardBase):
    pass


class MemberCardUpdate(BaseModel):
    name: Optional[str] = None
    total_times: Optional[int] = None
    used_times: Optional[int] = None
    balance: Optional[float] = None
    price: Optional[float] = None
    valid_end: Optional[datetime] = None
    status: Optional[str] = None


class MemberCardOut(MemberCardBase):
    id: int

    class Config:
        from_attributes = True


class VerifyCardRequest(BaseModel):
    service_name: str
    times_used: Optional[int] = 1
    staff_id: Optional[int] = None
    staff_name: Optional[str] = ""


class RechargeCardRequest(BaseModel):
    amount: float
    pay_method: Optional[str] = "现金"
    staff_id: Optional[int] = None
    staff_name: Optional[str] = ""


# Product
class ProductBase(BaseModel):
    store_id: int
    name: str
    category: str
    price: Optional[float] = 0.0
    description: Optional[str] = ""
    status: Optional[str] = "上架"


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None
    status: Optional[str] = None


class ProductOut(ProductBase):
    id: int

    class Config:
        from_attributes = True


# BonusRule
class BonusRuleBase(BaseModel):
    store_id: int
    min_amount: Optional[float] = 0.0
    bonus_amount: Optional[float] = 0.0
    bonus_type: Optional[str] = "固定"
    bonus_ratio: Optional[float] = 0.0
    validity_days: Optional[int] = 365
    status: Optional[str] = "启用"


class BonusRuleCreate(BonusRuleBase):
    pass


class BonusRuleUpdate(BaseModel):
    min_amount: Optional[float] = None
    bonus_amount: Optional[float] = None
    bonus_type: Optional[str] = None
    bonus_ratio: Optional[float] = None
    validity_days: Optional[int] = None
    status: Optional[str] = None


class BonusRuleOut(BonusRuleBase):
    id: int

    class Config:
        from_attributes = True


# VerifyRecord
class VerifyRecordBase(BaseModel):
    store_id: int
    member_id: int
    card_id: Optional[int] = None
    service_name: Optional[str] = ""
    times_used: Optional[int] = 1
    before_times: Optional[int] = 0
    after_times: Optional[int] = 0
    staff_id: Optional[int] = None
    staff_name: Optional[str] = ""


class VerifyRecordOut(VerifyRecordBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# RechargeRecord
class RechargeRecordBase(BaseModel):
    store_id: int
    member_id: int
    amount: Optional[float] = 0.0
    bonus_amount: Optional[float] = 0.0
    total_amount: Optional[float] = 0.0
    pay_method: Optional[str] = "现金"
    staff_id: Optional[int] = None
    staff_name: Optional[str] = ""


class RechargeRecordOut(RechargeRecordBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# PrintTemplate
class PrintTemplateBase(BaseModel):
    store_id: int
    name: str
    type: Optional[str] = "receipt"
    protocol: Optional[str] = "ESC"
    template_json: Optional[str] = "{}"
    is_default: Optional[bool] = False


class PrintTemplateCreate(PrintTemplateBase):
    pass


class PrintTemplateUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    protocol: Optional[str] = None
    template_json: Optional[str] = None
    is_default: Optional[bool] = None


class PrintTemplateOut(PrintTemplateBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# Performance
class PerformanceSummary(BaseModel):
    today_verify_count: int
    today_verify_amount: float
    today_recharge_amount: float
    week_verify_count: int
    week_recharge_amount: float
    month_verify_count: int
    month_recharge_amount: float


class StaffPerformance(BaseModel):
    staff_id: int
    staff_name: str
    verify_count: int
    recharge_amount: float
    total_amount: float

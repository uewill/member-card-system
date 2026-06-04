from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import Coupon, PointsRule, MessageTemplate, MarketingSettings
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class CouponCreate(BaseModel):
    name: str
    type: str = "满减券"
    discount_value: float = 0
    min_amount: float = 0
    total_count: int = 100
    valid_from: str = ""
    valid_until: str = ""

class CouponUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    discount_value: Optional[float] = None
    min_amount: Optional[float] = None
    total_count: Optional[int] = None
    valid_from: Optional[str] = None
    valid_until: Optional[str] = None
    status: Optional[str] = None

class PointsRuleUpdate(BaseModel):
    earn_ratio: Optional[float] = None
    status: Optional[str] = None

class MessageTemplateCreate(BaseModel):
    name: str
    type: str = "卡到期提醒"
    channel: str = "短信"
    content: str = ""

@router.get("/coupons")
async def list_coupons(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    coupons = db.query(Coupon).order_by(Coupon.id.desc()).all()
    return {"code": 200, "message": "success", "data": [{"id": c.id, "name": c.name, "type": c.type, "discount_value": c.discount_value, "min_amount": c.min_amount, "total_count": c.total_count, "used_count": c.used_count, "valid_from": c.valid_from, "valid_until": c.valid_until, "status": c.status} for c in coupons]}

@router.post("/coupons")
async def create_coupon(data: CouponCreate, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    c = Coupon(store_id=staff.store_id, name=data.name, type=data.type, discount_value=data.discount_value, min_amount=data.min_amount, total_count=data.total_count, valid_from=data.valid_from, valid_until=data.valid_until)
    db.add(c)
    db.commit()
    db.refresh(c)
    return {"code": 200, "message": "success", "data": {"id": c.id, "name": c.name}}

@router.put("/coupons/{coupon_id}")
async def update_coupon(coupon_id: int, data: CouponUpdate, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    c = db.query(Coupon).filter(Coupon.id == coupon_id).first()
    if not c:
        raise HTTPException(404, "优惠券不存在")
    for k, v in data.dict(exclude_unset=True).items():
        setattr(c, k, v)
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": c.id}}

@router.get("/points-config")
async def get_points_config(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    rule = db.query(PointsRule).filter(PointsRule.store_id == staff.store_id).first()
    if not rule:
        rule = PointsRule(store_id=staff.store_id, earn_ratio=1.0)
        db.add(rule)
        db.commit()
        db.refresh(rule)
    return {"code": 200, "message": "success", "data": {"id": rule.id, "earn_ratio": rule.earn_ratio, "status": rule.status}}

@router.put("/points-config")
async def update_points_config(data: PointsRuleUpdate, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    rule = db.query(PointsRule).filter(PointsRule.store_id == staff.store_id).first()
    if not rule:
        rule = PointsRule(store_id=staff.store_id)
        db.add(rule)
    for k, v in data.dict(exclude_unset=True).items():
        setattr(rule, k, v)
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": rule.id}}

@router.get("/message-config")
async def get_message_config(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    templates = db.query(MessageTemplate).filter(MessageTemplate.store_id == staff.store_id).all()
    settings = db.query(MarketingSettings).filter(MarketingSettings.store_id == staff.store_id).first()
    if not settings:
        settings = MarketingSettings(store_id=staff.store_id)
        db.add(settings)
        db.commit()
    return {"code": 200, "message": "success", "data": {"templates": [{"id": t.id, "name": t.name, "type": t.type, "channel": t.channel, "content": t.content, "status": t.status} for t in templates], "settings": {"points_enabled": settings.points_enabled, "coupon_enabled": settings.coupon_enabled, "message_enabled": settings.message_enabled}}}

@router.get("/settings")
async def get_marketing_settings(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    settings = db.query(MarketingSettings).filter(MarketingSettings.store_id == staff.store_id).first()
    if not settings:
        settings = MarketingSettings(store_id=staff.store_id)
        db.add(settings)
        db.commit()
        db.refresh(settings)
    return {"code": 200, "message": "success", "data": {"points_enabled": settings.points_enabled, "coupon_enabled": settings.coupon_enabled, "message_enabled": settings.message_enabled}}

@router.put("/settings")
async def update_marketing_settings(data: dict, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    settings = db.query(MarketingSettings).filter(MarketingSettings.store_id == staff.store_id).first()
    if not settings:
        settings = MarketingSettings(store_id=staff.store_id)
        db.add(settings)
    if "points_enabled" in data: settings.points_enabled = data["points_enabled"]
    if "coupon_enabled" in data: settings.coupon_enabled = data["coupon_enabled"]
    if "message_enabled" in data: settings.message_enabled = data["message_enabled"]
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": settings.id}}

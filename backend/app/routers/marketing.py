from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff

router = APIRouter()

@router.get("/coupons")
async def list_coupons(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """优惠券列表"""
    return {"code": 200, "message": "success", "data": [
        {"id": 1, "name": "新客满200减30", "type": "满减券", "min_amount": 200, "discount_amount": 30, "validity_end": "2026-12-31", "status": "启用"},
        {"id": 2, "name": "VIP 8折券", "type": "折扣券", "min_amount": 100, "discount_rate": 0.8, "validity_end": "2026-12-31", "status": "启用"},
        {"id": 3, "name": "生日专属5折", "type": "折扣券", "min_amount": 0, "discount_rate": 0.5, "validity_end": "2026-12-31", "status": "停用"},
    ]}

@router.get("/points-config")
async def get_points_config(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """积分配置"""
    return {"code": 200, "message": "success", "data": {
        "enabled": True,
        "points_per_yuan": 1
    }}

@router.get("/message-config")
async def get_message_config(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """消息推送配置"""
    return {"code": 200, "message": "success", "data": {
        "expiry_reminder": {"enabled": True, "days_before": 7},
        "birthday_greeting": {"enabled": True, "with_coupon": True},
        "activity_notification": {"enabled": False}
    }}

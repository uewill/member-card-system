from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.database import get_db
from app.models import RechargeRecord
from app.schemas import success_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_recharge_records(
    member_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_staff=Depends(get_current_staff)
):
    query = db.query(RechargeRecord)
    if member_id:
        query = query.filter(RechargeRecord.member_id == member_id)
    records = query.order_by(RechargeRecord.created_at.desc()).all()
    data = []
    for r in records:
        data.append({
            "id": r.id,
            "store_id": r.store_id,
            "member_id": r.member_id,
            "amount": r.amount,
            "bonus_amount": r.bonus_amount,
            "total_amount": r.total_amount,
            "pay_method": r.pay_method,
            "staff_id": r.staff_id,
            "staff_name": r.staff_name,
            "created_at": r.created_at.isoformat() if r.created_at else None
        })
    return success_response(data)

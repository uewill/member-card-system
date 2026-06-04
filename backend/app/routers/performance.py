from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from app.database import get_db
from app.models import VerifyRecord, RechargeRecord, Staff
from app.schemas import success_response
from app.auth import get_current_staff

router = APIRouter()


def get_date_range(period: str):
    now = datetime.utcnow()
    if period == "today":
        start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        end = now
    elif period == "week":
        start = now - timedelta(days=now.weekday())
        start = start.replace(hour=0, minute=0, second=0, microsecond=0)
        end = now
    elif period == "month":
        start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        end = now
    else:
        start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        end = now
    return start, end


@router.get("")
def performance_summary(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    today_start, today_end = get_date_range("today")
    week_start, week_end = get_date_range("week")
    month_start, month_end = get_date_range("month")

    today_verify_count = db.query(VerifyRecord).filter(
        VerifyRecord.created_at >= today_start,
        VerifyRecord.created_at <= today_end
    ).count()

    today_verify_amount = db.query(func.sum(VerifyRecord.times_used)).filter(
        VerifyRecord.created_at >= today_start,
        VerifyRecord.created_at <= today_end
    ).scalar() or 0

    today_recharge = db.query(func.sum(RechargeRecord.amount)).filter(
        RechargeRecord.created_at >= today_start,
        RechargeRecord.created_at <= today_end
    ).scalar() or 0

    week_verify_count = db.query(VerifyRecord).filter(
        VerifyRecord.created_at >= week_start,
        VerifyRecord.created_at <= week_end
    ).count()

    week_recharge = db.query(func.sum(RechargeRecord.amount)).filter(
        RechargeRecord.created_at >= week_start,
        RechargeRecord.created_at <= week_end
    ).scalar() or 0

    month_verify_count = db.query(VerifyRecord).filter(
        VerifyRecord.created_at >= month_start,
        VerifyRecord.created_at <= month_end
    ).count()

    month_recharge = db.query(func.sum(RechargeRecord.amount)).filter(
        RechargeRecord.created_at >= month_start,
        RechargeRecord.created_at <= month_end
    ).scalar() or 0

    return success_response({
        "today_verify_count": today_verify_count,
        "today_verify_amount": float(today_verify_amount),
        "today_recharge_amount": float(today_recharge),
        "week_verify_count": week_verify_count,
        "week_recharge_amount": float(week_recharge),
        "month_verify_count": month_verify_count,
        "month_recharge_amount": float(month_recharge)
    })


@router.get("/staff")
def staff_performance(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    today_start, today_end = get_date_range("today")

    staff_list = db.query(Staff).all()
    data = []
    for s in staff_list:
        verify_count = db.query(VerifyRecord).filter(
            VerifyRecord.staff_id == s.id,
            VerifyRecord.created_at >= today_start,
            VerifyRecord.created_at <= today_end
        ).count()

        recharge_amount = db.query(func.sum(RechargeRecord.amount)).filter(
            RechargeRecord.staff_id == s.id,
            RechargeRecord.created_at >= today_start,
            RechargeRecord.created_at <= today_end
        ).scalar() or 0

        data.append({
            "staff_id": s.id,
            "staff_name": s.name,
            "verify_count": verify_count,
            "recharge_amount": float(recharge_amount),
            "total_amount": float(recharge_amount)
        })

    data.sort(key=lambda x: x["total_amount"], reverse=True)
    return success_response(data)

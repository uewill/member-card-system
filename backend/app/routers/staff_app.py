from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc, case
from app.database import get_db
from app.models import Staff, Member, MemberCard, VerifyRecord, RechargeRecord, Store
from datetime import datetime, timedelta
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

# ===== 员工今日概览 =====
@router.get("/today-overview")
async def today_overview(staff_id: int = Query(...), db: Session = Depends(get_db)):
    staff = db.query(Staff).filter(Staff.id == staff_id).first()
    if not staff:
        raise HTTPException(404, "员工不存在")
    store = db.query(Store).filter(Store.id == staff.store_id).first()

    today = datetime.utcnow().date()
    today_start = datetime.combine(today, datetime.min.time())

    my_verify = db.query(VerifyRecord).filter(VerifyRecord.staff_id == staff_id, VerifyRecord.created_at >= today_start).count()
    my_recharge = db.query(RechargeRecord).filter(RechargeRecord.staff_id == staff_id, RechargeRecord.created_at >= today_start).all()
    my_recharge_amount = sum(r.amount for r in my_recharge)

    total_verify = db.query(VerifyRecord).filter(VerifyRecord.created_at >= today_start).count()
    total_recharge = db.query(RechargeRecord).filter(RechargeRecord.created_at >= today_start).all()
    total_revenue = sum(r.amount + r.bonus_amount for r in total_recharge)

    recent = db.query(VerifyRecord).filter(VerifyRecord.staff_id == staff_id).order_by(desc(VerifyRecord.created_at)).limit(5).all()

    return {"code": 200, "message": "success", "data": {
        "name": staff.name, "role": staff.role, "store_name": store.name if store else "",
        "today_service_count": my_verify, "today_revenue": my_recharge_amount,
        "total_service_count": total_verify, "total_revenue": total_revenue,
        "recent_services": [{"id": r.id, "member_name": "", "service_name": r.service_name, "times_used": r.times_used, "created_at": str(r.created_at)} for r in recent]
    }}

# ===== 员工业绩 =====
@router.get("/performance")
async def staff_performance(staff_id: int = Query(...), period: str = Query("day"), db: Session = Depends(get_db)):
    now = datetime.utcnow()
    if period == "day":
        start = datetime.combine(now.date(), datetime.min.time())
    elif period == "week":
        start = now - timedelta(days=now.weekday())
        start = datetime.combine(start.date(), datetime.min.time())
    else:
        start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    verifies = db.query(VerifyRecord).filter(VerifyRecord.staff_id == staff_id, VerifyRecord.created_at >= start).all()
    recharges = db.query(RechargeRecord).filter(RechargeRecord.staff_id == staff_id, RechargeRecord.created_at >= start).all()

    service_count = len(verifies)
    service_amount = sum(r.times_used * 100 for r in verifies)
    recharge_amount = sum(r.amount for r in recharges)

    # 每日趋势
    daily = []
    for i in range(7 if period == "week" else 1):
        d = start + timedelta(days=i)
        d_end = d + timedelta(days=1)
        d_count = db.query(VerifyRecord).filter(VerifyRecord.staff_id == staff_id, VerifyRecord.created_at >= d, VerifyRecord.created_at < d_end).count()
        daily.append({"date": str(d.date()), "count": d_count})

    return {"code": 200, "message": "success", "data": {
        "service_count": service_count, "service_amount": service_amount,
        "recharge_amount": recharge_amount,
        "daily_trend": daily
    }}

# ===== 服务历史 =====
@router.get("/service-history")
async def service_history(staff_id: int = Query(...), page: int = 1, size: int = 20, start_date: str = None, end_date: str = None, status: str = None, db: Session = Depends(get_db)):
    query = db.query(VerifyRecord).filter(VerifyRecord.staff_id == staff_id)
    if start_date:
        query = query.filter(VerifyRecord.created_at >= datetime.fromisoformat(start_date))
    if end_date:
        query = query.filter(VerifyRecord.created_at <= datetime.fromisoformat(end_date))
    total = query.count()
    records = query.order_by(desc(VerifyRecord.created_at)).offset((page-1)*size).limit(size).all()

    return {"code": 200, "message": "success", "data": {
        "records": [{"id": r.id, "member_id": r.member_id, "service_name": r.service_name, "times_used": r.times_used, "before_times": r.before_times, "after_times": r.after_times, "created_at": str(r.created_at), "status": "已完成"} for r in records],
        "total": total, "page": page, "size": size
    }}

# ===== 服务历史详情 =====
@router.get("/service-history/{order_id}")
async def service_history_detail(order_id: int, db: Session = Depends(get_db)):
    r = db.query(VerifyRecord).filter(VerifyRecord.id == order_id).first()
    if not r:
        raise HTTPException(404, "记录不存在")
    return {"code": 200, "message": "success", "data": {
        "id": r.id, "member_id": r.member_id, "service_name": r.service_name,
        "times_used": r.times_used, "before_times": r.before_times, "after_times": r.after_times,
        "staff_name": r.staff_name, "created_at": str(r.created_at)
    }}

# ===== 员工个人信息 =====
@router.get("/profile")
async def staff_profile(staff_id: int = Query(...), db: Session = Depends(get_db)):
    s = db.query(Staff).filter(Staff.id == staff_id).first()
    if not s:
        raise HTTPException(404, "员工不存在")
    store = db.query(Store).filter(Store.id == s.store_id).first()
    return {"code": 200, "message": "success", "data": {
        "id": s.id, "username": s.username, "name": s.name, "role": s.role,
        "phone": s.phone, "status": s.status, "store_name": store.name if store else ""
    }}

# ===== 业绩排行 =====
@router.get("/performance-rank")
async def performance_rank(period: str = Query("day"), limit: int = 10, db: Session = Depends(get_db)):
    now = datetime.utcnow()
    if period == "day":
        start = datetime.combine(now.date(), datetime.min.time())
    elif period == "week":
        start = now - timedelta(days=now.weekday())
        start = datetime.combine(start.date(), datetime.min.time())
    else:
        start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    staff_list = db.query(Staff).filter(Staff.status == "在职").all()
    result = []
    for s in staff_list:
        count = db.query(VerifyRecord).filter(VerifyRecord.staff_id == s.id, VerifyRecord.created_at >= start).count()
        recharge = db.query(RechargeRecord).filter(RechargeRecord.staff_id == s.id, RechargeRecord.created_at >= start).all()
        amount = sum(r.amount for r in recharge)
        result.append({"id": s.id, "name": s.name, "role": s.role, "service_count": count, "recharge_amount": amount, "total": count * 100 + amount})

    result.sort(key=lambda x: x["total"], reverse=True)
    return {"code": 200, "message": "success", "data": result[:limit]}

# ===== 客户列表 =====
@router.get("/customers")
async def customer_list(staff_id: int = Query(None), keyword: str = None, page: int = 1, size: int = 20, db: Session = Depends(get_db)):
    query = db.query(Member)
    if keyword:
        query = query.filter((Member.name.contains(keyword)) | (Member.phone.contains(keyword)))
    total = query.count()
    members = query.order_by(desc(Member.created_at)).offset((page-1)*size).limit(size).all()

    result = []
    for m in members:
        cards = db.query(MemberCard).filter(MemberCard.member_id == m.id).all()
        result.append({
            "id": m.id, "name": m.name, "phone": m.phone, "level": m.level,
            "balance": m.balance, "points": m.points,
            "card_count": len(cards),
            "cards": [{"id": c.id, "name": c.name, "type": c.type, "total_times": c.total_times, "used_times": c.used_times, "balance": c.balance, "status": c.status} for c in cards]
        })

    return {"code": 200, "message": "success", "data": {"records": result, "total": total}}

# ===== 核销操作 =====
@router.post("/verify-consume")
async def verify_consume(data: dict, db: Session = Depends(get_db)):
    member_id = data.get("member_id")
    card_id = data.get("card_id")
    service_name = data.get("service_name", "")
    times_used = data.get("times_used", 1)
    deduction_type = data.get("deduction_type", "次数")
    staff_id = data.get("staff_id", 1)

    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")
    if card.status != "正常":
        raise HTTPException(400, f"卡状态异常: {card.status}")

    staff = db.query(Staff).filter(Staff.id == staff_id).first()
    before_count = card.total_times - card.used_times
    before_balance = card.balance

    if deduction_type == "次数":
        if before_count < times_used:
            raise HTTPException(400, "剩余次数不足")
        card.used_times += times_used
        after_count = card.total_times - card.used_times
        after_balance = before_balance
        if card.used_times >= card.total_times:
            card.status = "已用完"
    else:
        if card.balance < times_used:
            raise HTTPException(400, "余额不足")
        card.balance -= times_used
        after_count = before_count
        after_balance = card.balance
        if card.balance <= 0:
            card.status = "已用完"

    record = VerifyRecord(
        store_id=1, member_id=member_id, card_id=card_id,
        service_name=service_name, times_used=times_used,
        before_times=before_count, after_times=after_count if deduction_type == "次数" else before_count,
        staff_id=staff_id, staff_name=staff.name if staff else ""
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    return {"code": 200, "message": "success", "data": {
        "id": record.id, "service_name": service_name, "times_used": times_used,
        "before": before_count if deduction_type == "次数" else before_balance,
        "after": after_count if deduction_type == "次数" else after_balance
    }}

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import Optional
from app.database import get_db
from app.models import Member, MemberCard, VerifyRecord, RechargeRecord
from app.schemas import MemberCreate, MemberUpdate, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_members(
    q: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_staff=Depends(get_current_staff)
):
    query = db.query(Member)
    if q:
        query = query.filter(or_(Member.name.contains(q), Member.phone.contains(q)))
    members = query.order_by(Member.created_at.desc()).all()
    data = []
    for m in members:
        data.append({
            "id": m.id,
            "store_id": m.store_id,
            "name": m.name,
            "phone": m.phone,
            "level": m.level,
            "balance": m.balance,
            "points": m.points,
            "total_spent": m.total_spent,
            "created_at": m.created_at.isoformat() if m.created_at else None
        })
    return success_response(data)


@router.post("")
def create_member(data: MemberCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    member = Member(**data.model_dump())
    db.add(member)
    db.commit()
    db.refresh(member)
    return success_response({
        "id": member.id,
        "store_id": member.store_id,
        "name": member.name,
        "phone": member.phone,
        "level": member.level,
        "balance": member.balance,
        "points": member.points,
        "total_spent": member.total_spent,
        "created_at": member.created_at.isoformat() if member.created_at else None
    })


@router.get("/{id}")
def get_member(id: int, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    member = db.query(Member).filter(Member.id == id).first()
    if not member:
        return error_response("会员不存在", 404)
    cards = []
    for c in member.cards:
        cards.append({
            "id": c.id,
            "card_no": c.card_no,
            "name": c.name,
            "type": c.type,
            "total_times": c.total_times,
            "used_times": c.used_times,
            "balance": c.balance,
            "valid_end": c.valid_end.isoformat() if c.valid_end else None,
            "status": c.status
        })
    verify_records = []
    for v in member.verify_records:
        verify_records.append({
            "id": v.id,
            "service_name": v.service_name,
            "times_used": v.times_used,
            "before_times": v.before_times,
            "after_times": v.after_times,
            "staff_name": v.staff_name,
            "created_at": v.created_at.isoformat() if v.created_at else None
        })
    recharge_records = []
    for r in member.recharge_records:
        recharge_records.append({
            "id": r.id,
            "amount": r.amount,
            "bonus_amount": r.bonus_amount,
            "total_amount": r.total_amount,
            "pay_method": r.pay_method,
            "staff_name": r.staff_name,
            "created_at": r.created_at.isoformat() if r.created_at else None
        })
    return success_response({
        "id": member.id,
        "store_id": member.store_id,
        "name": member.name,
        "phone": member.phone,
        "level": member.level,
        "balance": member.balance,
        "points": member.points,
        "total_spent": member.total_spent,
        "created_at": member.created_at.isoformat() if member.created_at else None,
        "cards": cards,
        "verify_records": verify_records,
        "recharge_records": recharge_records
    })


@router.put("/{id}")
def update_member(id: int, data: MemberUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    member = db.query(Member).filter(Member.id == id).first()
    if not member:
        return error_response("会员不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(member, field, value)
    db.commit()
    db.refresh(member)
    return success_response({
        "id": member.id,
        "store_id": member.store_id,
        "name": member.name,
        "phone": member.phone,
        "level": member.level,
        "balance": member.balance,
        "points": member.points,
        "total_spent": member.total_spent,
        "created_at": member.created_at.isoformat() if member.created_at else None
    })

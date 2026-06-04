from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, timedelta
from app.database import get_db
from app.models import MemberCard, VerifyRecord, RechargeRecord, Member
from app.schemas import MemberCardCreate, MemberCardUpdate, VerifyCardRequest, RechargeCardRequest, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_cards(
    member_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_staff=Depends(get_current_staff)
):
    query = db.query(MemberCard)
    if member_id:
        query = query.filter(MemberCard.member_id == member_id)
    cards = query.order_by(MemberCard.id.desc()).all()
    data = []
    for c in cards:
        data.append({
            "id": c.id,
            "member_id": c.member_id,
            "card_type_id": c.card_type_id,
            "card_no": c.card_no,
            "name": c.name,
            "type": c.type,
            "total_times": c.total_times,
            "used_times": c.used_times,
            "balance": c.balance,
            "price": c.price,
            "valid_start": c.valid_start.isoformat() if c.valid_start else None,
            "valid_end": c.valid_end.isoformat() if c.valid_end else None,
            "status": c.status
        })
    return success_response(data)


@router.post("")
def create_card(data: MemberCardCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card = MemberCard(**data.model_dump())
    if card.valid_end is None and card.valid_start:
        card.valid_end = card.valid_start + timedelta(days=365)
    db.add(card)
    db.commit()
    db.refresh(card)
    return success_response({
        "id": card.id,
        "member_id": card.member_id,
        "card_no": card.card_no,
        "name": card.name,
        "type": card.type,
        "total_times": card.total_times,
        "used_times": card.used_times,
        "balance": card.balance,
        "valid_end": card.valid_end.isoformat() if card.valid_end else None,
        "status": card.status
    })


@router.get("/{id}")
def get_card(id: int, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == id).first()
    if not card:
        return error_response("次卡不存在", 404)
    return success_response({
        "id": card.id,
        "member_id": card.member_id,
        "card_type_id": card.card_type_id,
        "card_no": card.card_no,
        "name": card.name,
        "type": card.type,
        "total_times": card.total_times,
        "used_times": card.used_times,
        "balance": card.balance,
        "price": card.price,
        "valid_start": card.valid_start.isoformat() if card.valid_start else None,
        "valid_end": card.valid_end.isoformat() if card.valid_end else None,
        "status": card.status,
        "verify_records": [
            {
                "id": v.id,
                "service_name": v.service_name,
                "times_used": v.times_used,
                "before_times": v.before_times,
                "after_times": v.after_times,
                "staff_name": v.staff_name,
                "created_at": v.created_at.isoformat() if v.created_at else None
            } for v in card.verify_records
        ]
    })


@router.put("/{id}")
def update_card(id: int, data: MemberCardUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == id).first()
    if not card:
        return error_response("次卡不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(card, field, value)
    db.commit()
    db.refresh(card)
    return success_response({
        "id": card.id,
        "member_id": card.member_id,
        "card_no": card.card_no,
        "name": card.name,
        "type": card.type,
        "total_times": card.total_times,
        "used_times": card.used_times,
        "balance": card.balance,
        "valid_end": card.valid_end.isoformat() if card.valid_end else None,
        "status": card.status
    })


@router.post("/{id}/verify")
def verify_card(id: int, data: VerifyCardRequest, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == id).first()
    if not card:
        return error_response("次卡不存在", 404)
    if card.status in ["已用完", "已过期"]:
        return error_response("次卡已用完或已过期", 400)
    if card.type == "次卡":
        if card.used_times + data.times_used > card.total_times:
            return error_response("剩余次数不足", 400)
        before_times = card.total_times - card.used_times
        card.used_times += data.times_used
        after_times = card.total_times - card.used_times
        if card.used_times >= card.total_times:
            card.status = "已用完"
    else:
        before_times = int(card.balance)
        if card.balance < data.times_used:
            return error_response("余额不足", 400)
        card.balance -= data.times_used
        after_times = int(card.balance)
        if card.balance <= 0:
            card.status = "已用完"

    record = VerifyRecord(
        store_id=current_staff.store_id,
        member_id=card.member_id,
        card_id=card.id,
        service_name=data.service_name,
        times_used=data.times_used,
        before_times=before_times,
        after_times=after_times,
        staff_id=data.staff_id or current_staff.id,
        staff_name=data.staff_name or current_staff.name
    )
    db.add(record)
    db.commit()
    db.refresh(card)
    return success_response({
        "id": card.id,
        "used_times": card.used_times,
        "balance": card.balance,
        "status": card.status,
        "record_id": record.id
    })


@router.post("/{id}/recharge")
def recharge_card(id: int, data: RechargeCardRequest, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == id).first()
    if not card:
        return error_response("次卡不存在", 404)
    if card.type == "次卡":
        card.total_times += int(data.amount)
    else:
        card.balance += data.amount
    if card.status in ["已用完"]:
        card.status = "正常"
    record = RechargeRecord(
        store_id=current_staff.store_id,
        member_id=card.member_id,
        amount=data.amount,
        bonus_amount=0,
        total_amount=data.amount,
        pay_method=data.pay_method,
        staff_id=data.staff_id or current_staff.id,
        staff_name=data.staff_name or current_staff.name
    )
    db.add(record)
    db.commit()
    db.refresh(card)
    return success_response({
        "id": card.id,
        "total_times": card.total_times,
        "balance": card.balance,
        "status": card.status,
        "record_id": record.id
    })

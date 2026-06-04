from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import ConsumeOrder, MemberCard, Member, VerifyRecord, Staff
from datetime import datetime

router = APIRouter()

@router.post("/")
async def create_order(data: dict, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    member_id = data.get("member_id")
    card_id = data.get("card_id")
    service_name = data.get("service_name", "")
    deduction_type = data.get("deduction_type", "次数")
    times_used = data.get("times_used", 1)

    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")

    before_count = card.total_times - card.used_times
    before_balance = card.balance

    if deduction_type == "次数":
        card.used_times += times_used
        after_count = card.total_times - card.used_times
        after_balance = before_balance
        if card.used_times >= card.total_times:
            card.status = "已用完"
    else:
        card.balance -= times_used
        after_count = before_count
        after_balance = card.balance
        if card.balance <= 0:
            card.status = "已用完"

    order = ConsumeOrder(
        store_id=card.member.store_id if card.member else 1,
        member_id=member_id,
        total_amount=times_used * 100,
        actual_paid=0,
        payment_method="卡扣",
        status="已完成",
        operator_id=staff.id,
        service_items=f'[{{"name": "{service_name}"}}]',
        card_id=card_id,
        deduction_type=deduction_type,
        deduction_count=times_used,
        deduction_amount=times_used * 100
    )
    db.add(order)
    db.commit()
    db.refresh(order)

    return {"code": 200, "message": "success", "data": {"id": order.id, "status": "已完成"}}

@router.get("/")
async def list_orders(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    orders = db.query(ConsumeOrder).order_by(ConsumeOrder.created_at.desc()).limit(50).all()
    return {"code": 200, "message": "success", "data": [{"id": o.id, "member_id": o.member_id, "total_amount": o.total_amount, "status": o.status, "payment_method": o.payment_method, "service_items": o.service_items, "deduction_type": o.deduction_type, "deduction_count": o.deduction_count, "created_at": str(o.created_at)} for o in orders]}

@router.get("/{order_id}")
async def get_order(order_id: int, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    o = db.query(ConsumeOrder).filter(ConsumeOrder.id == order_id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    return {"code": 200, "message": "success", "data": {"id": o.id, "member_id": o.member_id, "total_amount": o.total_amount, "actual_paid": o.actual_paid, "status": o.status, "payment_method": o.payment_method, "service_items": o.service_items, "card_id": o.card_id, "deduction_type": o.deduction_type, "deduction_count": o.deduction_count, "deduction_amount": o.deduction_amount, "cancel_reason": o.cancel_reason, "created_at": str(o.created_at), "cancelled_at": str(o.cancelled_at) if o.cancelled_at else None}}

@router.post("/{order_id}/cancel")
async def cancel_order(order_id: int, reason: str = "", db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    o = db.query(ConsumeOrder).filter(ConsumeOrder.id == order_id).first()
    if not o:
        raise HTTPException(404, "订单不存在")
    if o.status == "已撤销":
        raise HTTPException(400, "订单已撤销")
    # 回退卡次数/余额
    if o.card_id:
        card = db.query(MemberCard).filter(MemberCard.id == o.card_id).first()
        if card:
            if o.deduction_type == "次数":
                card.used_times = max(0, card.used_times - o.deduction_count)
                if card.status == "已用完":
                    card.status = "正常"
            else:
                card.balance += o.deduction_amount
                if card.status == "已用完":
                    card.status = "正常"
    o.status = "已撤销"
    o.cancel_reason = reason
    o.cancelled_at = datetime.utcnow()
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": o.id, "status": "已撤销"}}

@router.post("/match-card")
async def match_card(data: dict, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    member_id = data.get("member_id")
    service_name = data.get("service_name", "")
    cards = db.query(MemberCard).filter(MemberCard.member_id == member_id, MemberCard.status == "正常").all()
    # 排序策略：先到期优先、次数较少优先
    result = []
    for c in cards:
        item = {"id": c.id, "name": c.name, "type": c.type, "remain_count": c.total_times - c.used_times, "balance": c.balance, "valid_end": str(c.valid_end) if c.valid_end else None}
        result.append(item)
    result.sort(key=lambda x: (x["valid_end"] or "9999")[:10], reverse=False)
    return {"code": 200, "message": "success", "data": result}

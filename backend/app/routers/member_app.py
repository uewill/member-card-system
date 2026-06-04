from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from app.database import get_db
from app.models import Member, MemberCard, CardType, VerifyRecord, RechargeRecord, BonusRule, Product, ConsumeOrder
from datetime import datetime, timedelta
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

# ===== 会员概览 =====
@router.get("/overview")
async def member_overview(member_id: int = Query(...), db: Session = Depends(get_db)):
    member = db.query(Member).filter(Member.id == member_id).first()
    if not member:
        raise HTTPException(404, "会员不存在")
    cards = db.query(MemberCard).filter(MemberCard.member_id == member_id, MemberCard.status == "正常").all()
    total_balance = sum(c.balance for c in cards)
    total_points = member.points
    expiring_cards = sum(1 for c in cards if c.valid_end and (c.valid_end - datetime.utcnow()).days <= 30)
    return {"code": 200, "message": "success", "data": {
        "name": member.name, "phone": member.phone, "level": member.level,
        "balance": member.balance, "points": total_points,
        "total_cards": len(cards), "expiring_cards": expiring_cards,
        "total_spent": member.total_spent
    }}

# ===== 会员卡包 =====
@router.get("/cards")
async def member_cards(member_id: int = Query(...), db: Session = Depends(get_db)):
    cards = db.query(MemberCard).filter(MemberCard.member_id == member_id).order_by(desc(MemberCard.id)).all()
    result = []
    for c in cards:
        result.append({
            "id": c.id, "card_no": c.card_no, "name": c.name, "type": c.type,
            "total_times": c.total_times, "used_times": c.used_times,
            "remain_count": c.total_times - c.used_times,
            "balance": c.balance, "price": c.price,
            "valid_start": str(c.valid_start) if c.valid_start else None,
            "valid_end": str(c.valid_end) if c.valid_end else None,
            "status": c.status
        })
    return {"code": 200, "message": "success", "data": result}

# ===== 消费记录 =====
@router.get("/consume-records")
async def consume_records(member_id: int = Query(...), page: int = 1, size: int = 20, db: Session = Depends(get_db)):
    records = db.query(VerifyRecord).filter(VerifyRecord.member_id == member_id).order_by(desc(VerifyRecord.created_at)).offset((page-1)*size).limit(size).all()
    total = db.query(VerifyRecord).filter(VerifyRecord.member_id == member_id).count()
    return {"code": 200, "message": "success", "data": {
        "records": [{"id": r.id, "service_name": r.service_name, "times_used": r.times_used, "before_times": r.before_times, "after_times": r.after_times, "staff_name": r.staff_name, "created_at": str(r.created_at)} for r in records],
        "total": total, "page": page, "size": size
    }}

@router.get("/consume-records/{order_id}")
async def consume_record_detail(order_id: int, db: Session = Depends(get_db)):
    r = db.query(VerifyRecord).filter(VerifyRecord.id == order_id).first()
    if not r:
        raise HTTPException(404, "记录不存在")
    return {"code": 200, "message": "success", "data": {
        "id": r.id, "service_name": r.service_name, "times_used": r.times_used,
        "before_times": r.before_times, "after_times": r.after_times,
        "staff_name": r.staff_name, "created_at": str(r.created_at)
    }}

# ===== 套餐列表 =====
@router.get("/packages")
async def package_list(db: Session = Depends(get_db)):
    packages = db.query(CardType).filter(CardType.status == "启用").order_by(desc(CardType.id)).all()
    return {"code": 200, "message": "success", "data": [{
        "id": p.id, "name": p.name, "type": p.type, "times": p.times,
        "amount": p.amount, "price": p.price, "validity_days": p.validity_days,
        "services": p.services, "status": p.status
    } for p in packages]}

@router.get("/packages/{template_id}")
async def package_detail(template_id: int, db: Session = Depends(get_db)):
    p = db.query(CardType).filter(CardType.id == template_id).first()
    if not p:
        raise HTTPException(404, "套餐不存在")
    return {"code": 200, "message": "success", "data": {
        "id": p.id, "name": p.name, "type": p.type, "times": p.times,
        "amount": p.amount, "price": p.price, "validity_days": p.validity_days,
        "services": p.services, "status": p.status
    }}

# ===== 购买套餐 =====
@router.post("/purchase")
async def purchase_package(data: dict, db: Session = Depends(get_db)):
    member_id = data.get("member_id")
    template_id = data.get("template_id")
    store_id = data.get("store_id", 1)
    payment_method = data.get("payment_method", "微信")

    template = db.query(CardType).filter(CardType.id == template_id).first()
    if not template:
        raise HTTPException(404, "套餐不存在")
    member = db.query(Member).filter(Member.id == member_id).first()
    if not member:
        raise HTTPException(404, "会员不存在")

    # 生成卡实例
    import random, string
    card_no = ''.join(random.choices(string.digits, k=12))
    now = datetime.utcnow()
    card = MemberCard(
        member_id=member_id, card_type_id=template_id, card_no=card_no,
        name=template.name, type=template.type,
        total_times=template.times, used_times=0,
        balance=template.amount, price=template.price,
        valid_start=now, valid_end=now + timedelta(days=template.validity_days),
        status="正常"
    )
    db.add(card)

    # 创建订单记录
    order = ConsumeOrder(
        store_id=store_id, member_id=member_id,
        total_amount=template.price, actual_paid=template.price,
        payment_method=payment_method, status="已完成",
        service_items=f'[{{"name": "购买{template.name}"}}]',
        deduction_type="购买", deduction_count=0, deduction_amount=0
    )
    db.add(order)
    db.commit()
    db.refresh(card)

    return {"code": 200, "message": "success", "data": {
        "order_no": f"ORD{card.id}{int(now.timestamp())}",
        "card_id": card.id, "card_no": card.card_no,
        "status": "已完成"
    }}

# ===== 支付状态 =====
@router.get("/payment-status/{order_no}")
async def payment_status(order_no: str, db: Session = Depends(get_db)):
    return {"code": 200, "message": "success", "data": {"order_no": order_no, "status": "已完成"}}

# ===== 会员个人信息 =====
@router.get("/profile")
async def member_profile(member_id: int = Query(...), db: Session = Depends(get_db)):
    m = db.query(Member).filter(Member.id == member_id).first()
    if not m:
        raise HTTPException(404, "会员不存在")
    return {"code": 200, "message": "success", "data": {
        "id": m.id, "name": m.name, "phone": m.phone, "level": m.level,
        "balance": m.balance, "points": m.points, "total_spent": m.total_spent,
        "created_at": str(m.created_at)
    }}

@router.put("/profile")
async def update_profile(data: dict, db: Session = Depends(get_db)):
    member_id = data.get("member_id")
    m = db.query(Member).filter(Member.id == member_id).first()
    if not m:
        raise HTTPException(404, "会员不存在")
    if "name" in data: m.name = data["name"]
    if "level" in data: m.level = data["level"]
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": m.id}}

# ===== 消息通知 =====
@router.get("/notifications")
async def notifications(member_id: int = Query(...), page: int = 1, size: int = 20, db: Session = Depends(get_db)):
    # 使用核销记录作为通知数据源
    records = db.query(VerifyRecord).filter(VerifyRecord.member_id == member_id).order_by(desc(VerifyRecord.created_at)).offset((page-1)*size).limit(size).all()
    total = db.query(VerifyRecord).filter(VerifyRecord.member_id == member_id).count()
    result = []
    for i, r in enumerate(records):
        result.append({
            "id": r.id, "type": "消费通知", "title": f"服务完成: {r.service_name}",
            "content": f"扣减{r.times_used}次，操作员: {r.staff_name}",
            "is_read": i > 0, "created_at": str(r.created_at)
        })
    return {"code": 200, "message": "success", "data": {"records": result, "total": total}}

@router.put("/notifications/{notification_id}/read")
async def mark_read(notification_id: int, db: Session = Depends(get_db)):
    return {"code": 200, "message": "success", "data": {"id": notification_id, "is_read": True}}

# ===== 二维码 =====
@router.get("/qrcode")
async def member_qrcode(member_id: int = Query(...), db: Session = Depends(get_db)):
    m = db.query(Member).filter(Member.id == member_id).first()
    if not m:
        raise HTTPException(404, "会员不存在")
    return {"code": 200, "message": "success", "data": {"member_id": member_id, "phone": m.phone, "name": m.name, "qrcode_content": f"MEMBER_{member_id}_{m.phone}"}}

# ===== 充值赠送规则 =====
@router.get("/gift-rules")
async def gift_rules(db: Session = Depends(get_db)):
    rules = db.query(BonusRule).filter(BonusRule.status == "启用").all()
    return {"code": 200, "message": "success", "data": [{
        "id": r.id, "min_amount": r.min_amount, "bonus_amount": r.bonus_amount,
        "bonus_type": r.bonus_type, "bonus_ratio": r.bonus_ratio
    } for r in rules]}

# ===== 充值 =====
@router.post("/recharge")
async def member_recharge(data: dict, db: Session = Depends(get_db)):
    member_id = data.get("member_id")
    card_id = data.get("card_id")
    amount = data.get("amount", 0)
    payment_method = data.get("payment_method", "微信")

    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")

    # 计算赠金
    bonus = 0
    rules = db.query(BonusRule).filter(BonusRule.status == "启用").all()
    for rule in rules:
        if amount >= rule.min_amount:
            if rule.bonus_type == "固定":
                bonus = max(bonus, rule.bonus_amount)
            else:
                bonus = max(bonus, amount * rule.bonus_ratio)

    card.balance += amount + bonus
    if card.status == "已用完":
        card.status = "正常"

    record = RechargeRecord(
        store_id=1, member_id=member_id, amount=amount,
        bonus_amount=bonus, total_amount=amount + bonus,
        pay_method=payment_method
    )
    db.add(record)
    db.commit()

    return {"code": 200, "message": "success", "data": {
        "card_id": card_id, "amount": amount, "bonus": bonus,
        "new_balance": card.balance
    }}

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import MemberCard, Member, CardStatusChangeLog, CardDeductionSnapshot
from datetime import datetime

router = APIRouter()

@router.put("/{card_id}/freeze")
async def freeze_card(card_id: int, reason: str = "", db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")
    if card.status == "已冻结":
        raise HTTPException(400, "卡已冻结")
    log = CardStatusChangeLog(card_id=card_id, old_status=card.status, new_status="已冻结", changed_by=staff.id, reason=reason)
    db.add(log)
    card.status = "已冻结"
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": card.id, "status": "已冻结"}}

@router.put("/{card_id}/unfreeze")
async def unfreeze_card(card_id: int, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")
    if card.status != "已冻结":
        raise HTTPException(400, "卡未冻结")
    log = CardStatusChangeLog(card_id=card_id, old_status=card.status, new_status="正常", changed_by=staff.id)
    db.add(log)
    card.status = "正常"
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": card.id, "status": "正常"}}

@router.put("/{card_id}/transfer")
async def transfer_card(card_id: int, target_member_id: int, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    card = db.query(MemberCard).filter(MemberCard.id == card_id).first()
    if not card:
        raise HTTPException(404, "卡不存在")
    target = db.query(Member).filter(Member.id == target_member_id).first()
    if not target:
        raise HTTPException(404, "目标会员不存在")
    log = CardStatusChangeLog(card_id=card_id, old_status=card.status, new_status="已转赠", changed_by=staff.id, reason=f"转赠给会员{target.name}")
    db.add(log)
    card.status = "已转赠"
    card.member_id = target_member_id
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": card.id, "status": "已转赠", "new_member": target.name}}

@router.get("/{card_id}/deduction-logs")
async def get_deduction_logs(card_id: int, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    logs = db.query(CardDeductionSnapshot).filter(CardDeductionSnapshot.card_id == card_id).order_by(CardDeductionSnapshot.created_at.desc()).all()
    return {"code": 200, "message": "success", "data": [{"id": l.id, "before_count": l.before_count, "after_count": l.after_count, "before_balance": l.before_balance, "after_balance": l.after_balance, "created_at": str(l.created_at)} for l in logs]}

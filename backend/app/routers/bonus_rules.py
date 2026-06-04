from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import BonusRule
from app.schemas import BonusRuleCreate, BonusRuleUpdate, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_bonus_rules(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    rules = db.query(BonusRule).order_by(BonusRule.id.desc()).all()
    data = []
    for r in rules:
        data.append({
            "id": r.id,
            "store_id": r.store_id,
            "min_amount": r.min_amount,
            "bonus_amount": r.bonus_amount,
            "bonus_type": r.bonus_type,
            "bonus_ratio": r.bonus_ratio,
            "validity_days": r.validity_days,
            "status": r.status
        })
    return success_response(data)


@router.post("")
def create_bonus_rule(data: BonusRuleCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    rule = BonusRule(**data.model_dump())
    db.add(rule)
    db.commit()
    db.refresh(rule)
    return success_response({
        "id": rule.id,
        "store_id": rule.store_id,
        "min_amount": rule.min_amount,
        "bonus_amount": rule.bonus_amount,
        "bonus_type": rule.bonus_type,
        "bonus_ratio": rule.bonus_ratio,
        "validity_days": rule.validity_days,
        "status": rule.status
    })


@router.put("/{id}")
def update_bonus_rule(id: int, data: BonusRuleUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    rule = db.query(BonusRule).filter(BonusRule.id == id).first()
    if not rule:
        return error_response("规则不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(rule, field, value)
    db.commit()
    db.refresh(rule)
    return success_response({
        "id": rule.id,
        "store_id": rule.store_id,
        "min_amount": rule.min_amount,
        "bonus_amount": rule.bonus_amount,
        "bonus_type": rule.bonus_type,
        "bonus_ratio": rule.bonus_ratio,
        "validity_days": rule.validity_days,
        "status": rule.status
    })

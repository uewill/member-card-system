from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import CardType
from app.schemas import CardTypeCreate, CardTypeUpdate, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_card_types(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card_types = db.query(CardType).order_by(CardType.id.desc()).all()
    data = []
    for ct in card_types:
        data.append({
            "id": ct.id,
            "store_id": ct.store_id,
            "name": ct.name,
            "type": ct.type,
            "times": ct.times,
            "amount": ct.amount,
            "price": ct.price,
            "validity_days": ct.validity_days,
            "services": ct.services,
            "status": ct.status
        })
    return success_response(data)


@router.post("")
def create_card_type(data: CardTypeCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card_type = CardType(**data.model_dump())
    db.add(card_type)
    db.commit()
    db.refresh(card_type)
    return success_response({
        "id": card_type.id,
        "store_id": card_type.store_id,
        "name": card_type.name,
        "type": card_type.type,
        "times": card_type.times,
        "amount": card_type.amount,
        "price": card_type.price,
        "validity_days": card_type.validity_days,
        "services": card_type.services,
        "status": card_type.status
    })


@router.put("/{id}")
def update_card_type(id: int, data: CardTypeUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    card_type = db.query(CardType).filter(CardType.id == id).first()
    if not card_type:
        return error_response("卡类型不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(card_type, field, value)
    db.commit()
    db.refresh(card_type)
    return success_response({
        "id": card_type.id,
        "store_id": card_type.store_id,
        "name": card_type.name,
        "type": card_type.type,
        "times": card_type.times,
        "amount": card_type.amount,
        "price": card_type.price,
        "validity_days": card_type.validity_days,
        "services": card_type.services,
        "status": card_type.status
    })

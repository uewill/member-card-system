from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Store
from app.schemas import success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def get_settings(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    store = db.query(Store).filter(Store.id == current_staff.store_id).first()
    if not store:
        return error_response("门店不存在", 404)
    return success_response({
        "id": store.id,
        "name": store.name,
        "address": store.address,
        "phone": store.phone,
        "business_hours": store.business_hours,
        "status": store.status
    })


@router.put("")
def update_settings(data: dict, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    store = db.query(Store).filter(Store.id == current_staff.store_id).first()
    if not store:
        return error_response("门店不存在", 404)
    allowed_fields = ["name", "address", "phone", "business_hours", "status"]
    for field, value in data.items():
        if field in allowed_fields:
            setattr(store, field, value)
    db.commit()
    db.refresh(store)
    return success_response({
        "id": store.id,
        "name": store.name,
        "address": store.address,
        "phone": store.phone,
        "business_hours": store.business_hours,
        "status": store.status
    })

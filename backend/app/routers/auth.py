from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Staff
from app.schemas import StaffLogin, success_response, error_response
from app.auth import verify_password, create_access_token, get_current_staff

router = APIRouter()


@router.post("/login")
def login(data: StaffLogin, db: Session = Depends(get_db)):
    staff = db.query(Staff).filter(Staff.username == data.username).first()
    if not staff or not verify_password(data.password, staff.password_hash):
        return error_response("用户名或密码错误", 401)
    token = create_access_token(data={"sub": staff.id})
    return success_response({
        "access_token": token,
        "token_type": "bearer",
        "tenant_id": staff.store_id,
        "staff": {
            "id": staff.id,
            "username": staff.username,
            "name": staff.name,
            "role": staff.role,
            "store_id": staff.store_id
        }
    })


@router.get("/me")
def me(current_staff: Staff = Depends(get_current_staff)):
    return success_response({
        "id": current_staff.id,
        "username": current_staff.username,
        "name": current_staff.name,
        "role": current_staff.role,
        "phone": current_staff.phone,
        "store_id": current_staff.store_id,
        "status": current_staff.status
    })

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import Staff, Store, EmployeeRoleChangeLog
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class StaffCreate(BaseModel):
    username: str
    password: str
    name: str
    role: str = "staff"
    phone: str = ""
    store_id: int

class StaffUpdate(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    status: Optional[str] = None

@router.get("/")
async def list_staff(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    staff_list = db.query(Staff).all()
    return {"code": 200, "message": "success", "data": [{"id": s.id, "username": s.username, "name": s.name, "role": s.role, "phone": s.phone, "status": s.status, "store_id": s.store_id} for s in staff_list]}

@router.get("/{staff_id}")
async def get_staff(staff_id: int, db: Session = Depends(get_db), current = Depends(get_current_staff)):
    s = db.query(Staff).filter(Staff.id == staff_id).first()
    if not s:
        raise HTTPException(404, "员工不存在")
    return {"code": 200, "message": "success", "data": {"id": s.id, "username": s.username, "name": s.name, "role": s.role, "phone": s.phone, "status": s.status, "store_id": s.store_id}}

@router.post("/")
async def create_staff(data: StaffCreate, db: Session = Depends(get_db), current = Depends(get_current_staff)):
    import bcrypt as bcrypt_mod
    existing = db.query(Staff).filter(Staff.username == data.username).first()
    if existing:
        raise HTTPException(400, "用户名已存在")
    pwd_hash = bcrypt_mod.hashpw(data.password.encode('utf-8')[:72], bcrypt_mod.gensalt()).decode('utf-8')
    s = Staff(username=data.username, password_hash=pwd_hash, name=data.name, role=data.role, phone=data.phone, store_id=data.store_id)
    db.add(s)
    db.commit()
    db.refresh(s)
    return {"code": 200, "message": "success", "data": {"id": s.id, "username": s.username, "name": s.name}}

@router.put("/{staff_id}")
async def update_staff(staff_id: int, data: StaffUpdate, db: Session = Depends(get_db), current = Depends(get_current_staff)):
    s = db.query(Staff).filter(Staff.id == staff_id).first()
    if not s:
        raise HTTPException(404, "员工不存在")
    if data.name is not None: s.name = data.name
    if data.phone is not None: s.phone = data.phone
    if data.status is not None: s.status = data.status
    if data.role is not None and data.role != s.role:
        log = EmployeeRoleChangeLog(staff_id=staff_id, old_role=s.role, new_role=data.role, changed_by=current.id)
        db.add(log)
        s.role = data.role
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": s.id}}

@router.put("/{staff_id}/role")
async def change_role(staff_id: int, role: str, db: Session = Depends(get_db), current = Depends(get_current_staff)):
    s = db.query(Staff).filter(Staff.id == staff_id).first()
    if not s:
        raise HTTPException(404, "员工不存在")
    log = EmployeeRoleChangeLog(staff_id=staff_id, old_role=s.role, new_role=role, changed_by=current.id)
    db.add(log)
    s.role = role
    db.commit()
    return {"code": 200, "message": "success", "data": {"id": s.id, "old_role": log.old_role, "new_role": role}}

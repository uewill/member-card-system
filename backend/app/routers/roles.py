from fastapi import APIRouter, Depends, Body
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import Role, Permission, AuditLog
from typing import List

router = APIRouter()

@router.get("/")
async def list_roles(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    roles = db.query(Role).all()
    return {"code": 200, "message": "success", "data": [{"id": r.id, "name": r.name, "code": r.code, "description": r.description} for r in roles]}

@router.get("/{role_id}/permissions")
async def get_role_permissions(role_id: int, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    perms = db.query(Permission).filter(Permission.role_id == role_id).all()
    return {"code": 200, "message": "success", "data": [{"id": p.id, "api_path": p.api_path, "method": p.method} for p in perms]}

@router.put("/{role_id}/permissions")
async def update_role_permissions(role_id: int, permissions: List[dict] = Body(...), db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    db.query(Permission).filter(Permission.role_id == role_id).delete()
    for p in permissions:
        perm = Permission(role_id=role_id, api_path=p.get("api_path", ""), method=p.get("method", "GET"))
        db.add(perm)
    db.commit()
    return {"code": 200, "message": "success", "data": {"role_id": role_id, "count": len(permissions)}}

@router.get("/audit-logs")
async def list_audit_logs(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    logs = db.query(AuditLog).order_by(AuditLog.created_at.desc()).limit(50).all()
    return {"code": 200, "message": "success", "data": [{"id": l.id, "user_id": l.user_id, "action": l.action, "resource_type": l.resource_type, "result": l.result, "created_at": str(l.created_at)} for l in logs]}

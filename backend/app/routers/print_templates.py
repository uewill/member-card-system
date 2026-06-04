from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import PrintTemplate
from app.schemas import PrintTemplateCreate, PrintTemplateUpdate, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_print_templates(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    templates = db.query(PrintTemplate).order_by(PrintTemplate.id.desc()).all()
    data = []
    for t in templates:
        data.append({
            "id": t.id,
            "store_id": t.store_id,
            "name": t.name,
            "type": t.type,
            "protocol": t.protocol,
            "template_json": t.template_json,
            "is_default": t.is_default,
            "created_at": t.created_at.isoformat() if t.created_at else None
        })
    return success_response(data)


@router.post("")
def create_print_template(data: PrintTemplateCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    template = PrintTemplate(**data.model_dump())
    db.add(template)
    db.commit()
    db.refresh(template)
    return success_response({
        "id": template.id,
        "store_id": template.store_id,
        "name": template.name,
        "type": template.type,
        "protocol": template.protocol,
        "template_json": template.template_json,
        "is_default": template.is_default,
        "created_at": template.created_at.isoformat() if template.created_at else None
    })


@router.put("/{id}")
def update_print_template(id: int, data: PrintTemplateUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    template = db.query(PrintTemplate).filter(PrintTemplate.id == id).first()
    if not template:
        return error_response("模板不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(template, field, value)
    db.commit()
    db.refresh(template)
    return success_response({
        "id": template.id,
        "store_id": template.store_id,
        "name": template.name,
        "type": template.type,
        "protocol": template.protocol,
        "template_json": template.template_json,
        "is_default": template.is_default,
        "created_at": template.created_at.isoformat() if template.created_at else None
    })

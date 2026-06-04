from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Product
from app.schemas import ProductCreate, ProductUpdate, success_response, error_response
from app.auth import get_current_staff

router = APIRouter()


@router.get("")
def list_products(db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    products = db.query(Product).order_by(Product.id.desc()).all()
    data = []
    for p in products:
        data.append({
            "id": p.id,
            "store_id": p.store_id,
            "name": p.name,
            "category": p.category,
            "price": p.price,
            "description": p.description,
            "status": p.status
        })
    return success_response(data)


@router.post("")
def create_product(data: ProductCreate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    product = Product(**data.model_dump())
    db.add(product)
    db.commit()
    db.refresh(product)
    return success_response({
        "id": product.id,
        "store_id": product.store_id,
        "name": product.name,
        "category": product.category,
        "price": product.price,
        "description": product.description,
        "status": product.status
    })


@router.put("/{id}")
def update_product(id: int, data: ProductUpdate, db: Session = Depends(get_db), current_staff=Depends(get_current_staff)):
    product = db.query(Product).filter(Product.id == id).first()
    if not product:
        return error_response("商品不存在", 404)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(product, field, value)
    db.commit()
    db.refresh(product)
    return success_response({
        "id": product.id,
        "store_id": product.store_id,
        "name": product.name,
        "category": product.category,
        "price": product.price,
        "description": product.description,
        "status": product.status
    })

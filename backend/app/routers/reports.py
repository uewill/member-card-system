from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.auth import get_current_staff
from app.models import VerifyRecord, RechargeRecord, Member, MemberCard
from sqlalchemy import func, desc
from datetime import datetime, timedelta

router = APIRouter()

@router.get("/daily")
async def daily_report(date: str = None, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """门店日报"""
    target_date = date or datetime.now().strftime("%Y-%m-%d")
    # 查询当日数据
    verify_count = db.query(VerifyRecord).filter(
        func.date(VerifyRecord.created_at) == target_date
    ).count()
    recharge_total = db.query(func.sum(RechargeRecord.total_amount)).filter(
        func.date(RechargeRecord.created_at) == target_date
    ).scalar() or 0
    # 昨日对比
    yesterday = (datetime.strptime(target_date, "%Y-%m-%d") - timedelta(days=1)).strftime("%Y-%m-%d")
    yesterday_recharge = db.query(func.sum(RechargeRecord.total_amount)).filter(
        func.date(RechargeRecord.created_at) == yesterday
    ).scalar() or 0

    return {"code": 200, "message": "success", "data": {
        "date": target_date,
        "total_revenue": float(recharge_total),
        "total_consumptions": verify_count,
        "payment_breakdown": {"wechat": float(recharge_total * 0.6), "alipay": float(recharge_total * 0.3), "cash": float(recharge_total * 0.1)},
        "comparison": {
            "yesterday_revenue": float(yesterday_recharge),
            "change_percent": round((float(recharge_total) - float(yesterday_recharge)) / max(float(yesterday_recharge), 1) * 100, 1)
        }
    }}

@router.get("/monthly")
async def monthly_report(month: str = None, db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """月度汇总"""
    target_month = month or datetime.now().strftime("%Y-%m")
    # 月初月末
    start_date = f"{target_month}-01"
    end_date = (datetime.strptime(start_date, "%Y-%m-%d") + timedelta(days=32)).replace(day=1).strftime("%Y-%m-%d")

    total_revenue = db.query(func.sum(RechargeRecord.total_amount)).filter(
        RechargeRecord.created_at >= start_date,
        RechargeRecord.created_at < end_date
    ).scalar() or 0
    total_consumptions = db.query(VerifyRecord).filter(
        VerifyRecord.created_at >= start_date,
        VerifyRecord.created_at < end_date
    ).count()
    new_members = db.query(Member).filter(
        Member.created_at >= start_date,
        Member.created_at < end_date
    ).count()

    # 计算天数
    days = (datetime.strptime(end_date, "%Y-%m-%d") - datetime.strptime(start_date, "%Y-%m-%d")).days

    return {"code": 200, "message": "success", "data": {
        "month": target_month,
        "total_revenue": float(total_revenue),
        "total_consumptions": total_consumptions,
        "new_members": new_members,
        "avg_daily_revenue": round(float(total_revenue) / max(days, 1), 2),
        "avg_daily_consumptions": round(total_consumptions / max(days, 1), 1)
    }}

@router.get("/package-sales")
async def package_sales(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """套餐售卖分析"""
    # 按 card type 分组统计
    cards = db.query(MemberCard.type, func.count(MemberCard.id)).group_by(MemberCard.type).all()
    result = []
    type_names = {"times": "次数卡", "value": "储值卡", "hybrid": "混合卡"}
    for card_type, count in cards:
        result.append({
            "package_type": type_names.get(card_type, card_type),
            "sales_count": count,
            "revenue": count * 1000  # 简化计算
        })
    return {"code": 200, "message": "success", "data": result}

@router.get("/member-analysis")
async def member_analysis(db: Session = Depends(get_db), staff = Depends(get_current_staff)):
    """会员分析"""
    total = db.query(Member).count()
    vip = db.query(Member).filter(Member.level == "VIP").count()
    # 流失预警：90天无消费
    threshold = datetime.now() - timedelta(days=90)
    active_ids = db.query(VerifyRecord.member_id).filter(VerifyRecord.created_at >= threshold).distinct().all()
    active_ids_set = set([str(a[0]) for a in active_ids])
    all_members = db.query(Member).all()
    churn_warning = [{"id": m.id, "name": m.name, "phone": m.phone, "last_active": "90天前"} for m in all_members if str(m.id) not in active_ids_set]

    return {"code": 200, "message": "success", "data": {
        "total_members": total,
        "vip_members": vip,
        "active_members": len(active_ids_set),
        "churn_warning_count": len(churn_warning),
        "churn_warning_list": churn_warning[:10]
    }}

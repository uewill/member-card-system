from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routers import auth, members, cards, products, card_types, bonus_rules, verify, recharge, performance, settings, print_templates, reports, marketing

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Member Card System API",
    description="会员次卡管理系统后端 API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["认证"])
app.include_router(members.router, prefix="/members", tags=["会员"])
app.include_router(cards.router, prefix="/cards", tags=["次卡"])
app.include_router(products.router, prefix="/products", tags=["商品"])
app.include_router(card_types.router, prefix="/card-types", tags=["卡类型"])
app.include_router(bonus_rules.router, prefix="/bonus-rules", tags=["赠金规则"])
app.include_router(verify.router, prefix="/verify-records", tags=["核销记录"])
app.include_router(recharge.router, prefix="/recharge-records", tags=["充值记录"])
app.include_router(performance.router, prefix="/performance", tags=["业绩统计"])
app.include_router(settings.router, prefix="/settings", tags=["门店设置"])
app.include_router(print_templates.router, prefix="/print-templates", tags=["打印模板"])
app.include_router(reports.router, prefix="/reports", tags=["报表中心"])
app.include_router(marketing.router, prefix="/marketing", tags=["营销工具"])

# /api/v1/ 前缀兼容路由（供 Flutter 前端按 openspec 规范调用）
app.include_router(auth.router, prefix="/api/v1/auth", tags=["认证"])
app.include_router(members.router, prefix="/api/v1/members", tags=["会员"])
app.include_router(cards.router, prefix="/api/v1/cards", tags=["次卡"])
app.include_router(products.router, prefix="/api/v1/products", tags=["商品"])
app.include_router(card_types.router, prefix="/api/v1/card-types", tags=["卡类型"])
app.include_router(bonus_rules.router, prefix="/api/v1/bonus-rules", tags=["赠金规则"])
app.include_router(verify.router, prefix="/api/v1/verify-records", tags=["核销记录"])
app.include_router(recharge.router, prefix="/api/v1/recharge-records", tags=["充值记录"])
app.include_router(performance.router, prefix="/api/v1/performance", tags=["业绩统计"])
app.include_router(settings.router, prefix="/api/v1/settings", tags=["门店设置"])
app.include_router(print_templates.router, prefix="/api/v1/print-templates", tags=["打印模板"])
app.include_router(reports.router, prefix="/api/v1/reports", tags=["报表中心"])
app.include_router(marketing.router, prefix="/api/v1/marketing", tags=["营销工具"])


@app.get("/")
def read_root():
    return {"code": 200, "message": "Member Card System API", "data": {"version": "1.0.0"}}

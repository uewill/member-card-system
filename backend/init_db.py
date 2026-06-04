import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from datetime import datetime, timedelta
from app.database import SessionLocal, engine, Base
from app.models import Store, Staff, Member, CardType, MemberCard, Product, BonusRule, VerifyRecord, RechargeRecord, PrintTemplate, Role, Permission, PointsRule, MarketingSettings, Coupon, MessageTemplate
from app.auth import get_password_hash


def init_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # 1. 门店
        store = Store(
            name="美丽人生旗舰店",
            address="北京市朝阳区建国路88号",
            phone="010-88888888",
            business_hours="09:00-21:00",
            status="营业中"
        )
        db.add(store)
        db.commit()
        db.refresh(store)
        print(f"Store created: {store.name}")

        # 2. 员工
        staff = Staff(
            store_id=store.id,
            username="staff",
            password_hash=get_password_hash("123456"),
            name="管理员",
            role="admin",
            phone="13800138000",
            status="在职"
        )
        db.add(staff)
        db.commit()
        db.refresh(staff)
        print(f"Staff created: {staff.username}")

        # 3. 会员
        members_data = [
            {"name": "张伟", "phone": "13800000001", "level": "VIP", "balance": 500.0, "points": 1000, "total_spent": 5000.0},
            {"name": "李娜", "phone": "13800000002", "level": "普通", "balance": 200.0, "points": 300, "total_spent": 1500.0},
            {"name": "王芳", "phone": "13800000003", "level": "VIP", "balance": 800.0, "points": 2000, "total_spent": 8000.0},
            {"name": "刘洋", "phone": "13800000004", "level": "普通", "balance": 100.0, "points": 100, "total_spent": 500.0},
            {"name": "陈静", "phone": "13800000005", "level": "VIP", "balance": 1200.0, "points": 2500, "total_spent": 12000.0},
        ]
        members = []
        for m_data in members_data:
            member = Member(store_id=store.id, **m_data)
            db.add(member)
            members.append(member)
        db.commit()
        for m in members:
            db.refresh(m)
        print(f"Members created: {len(members)}")

        # 4. 卡类型模板
        card_types_data = [
            {"name": "面部护理10次卡", "type": "次卡", "times": 10, "amount": 0, "price": 1980.0, "validity_days": 365, "services": "面部清洁,面部按摩,面膜护理"},
            {"name": "身体SPA5次卡", "type": "次卡", "times": 5, "amount": 0, "price": 1580.0, "validity_days": 180, "services": "全身SPA,精油按摩"},
            {"name": "储值卡1000", "type": "储值卡", "times": 0, "amount": 1000.0, "price": 1000.0, "validity_days": 365, "services": "全场通用"},
            {"name": "混合卡", "type": "混合卡", "times": 3, "amount": 500.0, "price": 1280.0, "validity_days": 365, "services": "面部护理,身体按摩"},
        ]
        card_types = []
        for ct_data in card_types_data:
            ct = CardType(store_id=store.id, **ct_data)
            db.add(ct)
            card_types.append(ct)
        db.commit()
        for ct in card_types:
            db.refresh(ct)
        print(f"CardTypes created: {len(card_types)}")

        # 5. 商品
        products_data = [
            {"name": "深层清洁面部护理", "category": "服务项目", "price": 298.0, "description": "60分钟深层清洁护理", "status": "上架"},
            {"name": "精油全身按摩", "category": "服务项目", "price": 398.0, "description": "90分钟精油按摩", "status": "上架"},
            {"name": "保湿面膜套装", "category": "商品", "price": 168.0, "description": "10片装保湿面膜", "status": "上架"},
            {"name": "护肤精华套装", "category": "商品", "price": 688.0, "description": "精华液+面霜套装", "status": "上架"},
            {"name": "新娘美容套餐", "category": "套餐", "price": 3888.0, "description": "婚前3个月全套护理", "status": "上架"},
            {"name": "会员尊享套餐", "category": "套餐", "price": 5888.0, "description": "全年不限次基础护理", "status": "上架"},
        ]
        products = []
        for p_data in products_data:
            product = Product(store_id=store.id, **p_data)
            db.add(product)
            products.append(product)
        db.commit()
        print(f"Products created: {len(products)}")

        # 6. 赠金规则
        bonus_rules_data = [
            {"min_amount": 500.0, "bonus_amount": 50.0, "bonus_type": "固定", "bonus_ratio": 0, "validity_days": 365, "status": "启用"},
            {"min_amount": 1000.0, "bonus_amount": 150.0, "bonus_type": "固定", "bonus_ratio": 0, "validity_days": 365, "status": "启用"},
            {"min_amount": 2000.0, "bonus_amount": 0, "bonus_type": "比例", "bonus_ratio": 0.1, "validity_days": 365, "status": "启用"},
            {"min_amount": 5000.0, "bonus_amount": 0, "bonus_type": "比例", "bonus_ratio": 0.15, "validity_days": 730, "status": "启用"},
        ]
        for br_data in bonus_rules_data:
            br = BonusRule(store_id=store.id, **br_data)
            db.add(br)
        db.commit()
        print(f"BonusRules created: {len(bonus_rules_data)}")

        # 7. 次卡
        now = datetime.utcnow()
        cards_data = [
            {"member_id": members[0].id, "card_type_id": card_types[0].id, "card_no": "C20240001", "name": "面部护理10次卡", "type": "次卡", "total_times": 10, "used_times": 3, "balance": 0, "price": 1980.0, "valid_start": now, "valid_end": now + timedelta(days=365), "status": "正常"},
            {"member_id": members[0].id, "card_type_id": card_types[2].id, "card_no": "C20240002", "name": "储值卡1000", "type": "储值卡", "total_times": 0, "used_times": 0, "balance": 650.0, "price": 1000.0, "valid_start": now, "valid_end": now + timedelta(days=365), "status": "正常"},
            {"member_id": members[1].id, "card_type_id": card_types[1].id, "card_no": "C20240003", "name": "身体SPA5次卡", "type": "次卡", "total_times": 5, "used_times": 5, "balance": 0, "price": 1580.0, "valid_start": now, "valid_end": now + timedelta(days=180), "status": "已用完"},
            {"member_id": members[2].id, "card_type_id": card_types[0].id, "card_no": "C20240004", "name": "面部护理10次卡", "type": "次卡", "total_times": 10, "used_times": 1, "balance": 0, "price": 1980.0, "valid_start": now, "valid_end": now + timedelta(days=30), "status": "即将过期"},
            {"member_id": members[3].id, "card_type_id": card_types[3].id, "card_no": "C20240005", "name": "混合卡", "type": "混合卡", "total_times": 3, "used_times": 0, "balance": 500.0, "price": 1280.0, "valid_start": now, "valid_end": now + timedelta(days=365), "status": "正常"},
            {"member_id": members[4].id, "card_type_id": card_types[2].id, "card_no": "C20240006", "name": "储值卡1000", "type": "储值卡", "total_times": 0, "used_times": 0, "balance": 200.0, "price": 1000.0, "valid_start": now, "valid_end": now + timedelta(days=365), "status": "正常"},
        ]
        cards = []
        for c_data in cards_data:
            card = MemberCard(**c_data)
            db.add(card)
            cards.append(card)
        db.commit()
        for c in cards:
            db.refresh(c)
        print(f"MemberCards created: {len(cards)}")

        # 8. 核销记录
        verify_records_data = [
            {"store_id": store.id, "member_id": members[0].id, "card_id": cards[0].id, "service_name": "面部清洁", "times_used": 1, "before_times": 10, "after_times": 9, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=5)},
            {"store_id": store.id, "member_id": members[0].id, "card_id": cards[0].id, "service_name": "面部按摩", "times_used": 1, "before_times": 9, "after_times": 8, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=3)},
            {"store_id": store.id, "member_id": members[0].id, "card_id": cards[0].id, "service_name": "面膜护理", "times_used": 1, "before_times": 8, "after_times": 7, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=1)},
            {"store_id": store.id, "member_id": members[1].id, "card_id": cards[2].id, "service_name": "全身SPA", "times_used": 2, "before_times": 5, "after_times": 3, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=10)},
            {"store_id": store.id, "member_id": members[1].id, "card_id": cards[2].id, "service_name": "精油按摩", "times_used": 3, "before_times": 3, "after_times": 0, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=2)},
            {"store_id": store.id, "member_id": members[2].id, "card_id": cards[3].id, "service_name": "面部清洁", "times_used": 1, "before_times": 10, "after_times": 9, "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=7)},
        ]
        for v_data in verify_records_data:
            vr = VerifyRecord(**v_data)
            db.add(vr)
        db.commit()
        print(f"VerifyRecords created: {len(verify_records_data)}")

        # 9. 充值记录
        recharge_records_data = [
            {"store_id": store.id, "member_id": members[0].id, "amount": 1000.0, "bonus_amount": 150.0, "total_amount": 1150.0, "pay_method": "微信", "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=30)},
            {"store_id": store.id, "member_id": members[0].id, "amount": 500.0, "bonus_amount": 50.0, "total_amount": 550.0, "pay_method": "支付宝", "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=15)},
            {"store_id": store.id, "member_id": members[2].id, "amount": 2000.0, "bonus_amount": 200.0, "total_amount": 2200.0, "pay_method": "银行卡", "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=20)},
            {"store_id": store.id, "member_id": members[4].id, "amount": 5000.0, "bonus_amount": 750.0, "total_amount": 5750.0, "pay_method": "现金", "staff_id": staff.id, "staff_name": staff.name, "created_at": now - timedelta(days=10)},
        ]
        for r_data in recharge_records_data:
            rr = RechargeRecord(**r_data)
            db.add(rr)
        db.commit()
        print(f"RechargeRecords created: {len(recharge_records_data)}")

        # 10. 打印模板
        templates_data = [
            {"store_id": store.id, "name": "默认小票模板", "type": "receipt", "protocol": "ESC", "template_json": '{"header":"美丽人生旗舰店","footer":"谢谢惠顾"}', "is_default": True},
            {"store_id": store.id, "name": "标签模板", "type": "label", "protocol": "TSPL", "template_json": '{"width":40,"height":30}', "is_default": False},
        ]
        for t_data in templates_data:
            pt = PrintTemplate(**t_data)
            db.add(pt)
        db.commit()
        print(f"PrintTemplates created: {len(templates_data)}")

        # 11. 默认角色
        roles_data = [
            {"name": "平台超管", "code": "PLATFORM_ADMIN", "description": "平台超级管理员，拥有所有权限"},
            {"name": "商户管理员", "code": "MERCHANT_ADMIN", "description": "商户管理员，管理门店和员工"},
            {"name": "门店经理", "code": "STORE_MANAGER", "description": "门店经理，管理门店日常运营"},
            {"name": "收银员", "code": "CASHIER", "description": "收银员，负责收银和开卡"},
            {"name": "服务人员", "code": "SERVICE_STAFF", "description": "服务人员，提供服务和核销"},
            {"name": "会员", "code": "MEMBER", "description": "会员，查看自身信息和使用服务"},
        ]
        for r_data in roles_data:
            role = Role(**r_data)
            db.add(role)
        db.commit()
        print(f"Roles created: {len(roles_data)}")

        # 12. 默认积分规则
        points_rule = PointsRule(store_id=store.id, earn_ratio=1.0, status="启用")
        db.add(points_rule)
        db.commit()
        print(f"PointsRule created: earn_ratio=1.0")

        # 13. 默认营销设置
        marketing_settings = MarketingSettings(store_id=store.id, points_enabled=True, coupon_enabled=True, message_enabled=True)
        db.add(marketing_settings)
        db.commit()
        print(f"MarketingSettings created: all enabled")

        # 14. 默认优惠券
        coupons_data = [
            {"store_id": store.id, "name": "新客满200减30", "type": "满减券", "discount_value": 30, "min_amount": 200, "total_count": 100, "valid_from": "2026-01-01", "valid_until": "2026-12-31", "status": "启用"},
            {"store_id": store.id, "name": "VIP 8折券", "type": "折扣券", "discount_value": 0.8, "min_amount": 100, "total_count": 50, "valid_from": "2026-01-01", "valid_until": "2026-12-31", "status": "启用"},
        ]
        for c_data in coupons_data:
            coupon = Coupon(**c_data)
            db.add(coupon)
        db.commit()
        print(f"Coupons created: {len(coupons_data)}")

        # 15. 默认消息模板
        msg_templates_data = [
            {"store_id": store.id, "name": "卡到期提醒", "type": "卡到期提醒", "channel": "短信", "content": "尊敬的会员，您的{card_name}将于{valid_end}到期，请及时使用。", "status": "启用"},
            {"store_id": store.id, "name": "生日祝福", "type": "生日祝福", "channel": "短信", "content": "亲爱的{name}，祝您生日快乐！凭此短信可享生日专属优惠。", "status": "启用"},
        ]
        for t_data in msg_templates_data:
            tmpl = MessageTemplate(**t_data)
            db.add(tmpl)
        db.commit()
        print(f"MessageTemplates created: {len(msg_templates_data)}")

        print("\nDatabase initialized successfully!")
        print(f"Login: username=staff, password=123456")

    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    init_db()

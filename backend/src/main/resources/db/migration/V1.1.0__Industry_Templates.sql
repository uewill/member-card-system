-- =====================================================
-- V1.1.0__Industry_Templates.sql
-- 行业模板初始化数据 - 美发/美容/健身/洗车/教培
-- 插入 sys_industry_template 表
-- =====================================================

-- 1. 美发行业模板
INSERT INTO sys_industry_template (industry, service_items, package_templates) VALUES
('HAIRCUT',
 JSON_ARRAY(
   JSON_OBJECT('category', '基础服务', 'name', '男士洗剪吹', 'price', 38.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '基础服务', 'name', '女士洗剪吹', 'price', 58.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '基础服务', 'name', '儿童理发', 'price', 28.00, 'duration', 20, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '烫染服务', 'name', '烫发（冷烫）', 'price', 280.00, 'duration', 120, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '烫染服务', 'name', '染发（单色）', 'price', 180.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '烫染服务', 'name', '染发（挑染）', 'price', 280.00, 'duration', 120, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '烫染服务', 'name', '烫染一体', 'price', 480.00, 'duration', 180, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '护理服务', 'name', '头皮护理', 'price', 68.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '护理服务', 'name', '深层修复护理', 'price', 128.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '护理服务', 'name', '角质蛋白护理', 'price', 198.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '造型服务', 'name', '精剪造型', 'price', 128.00, 'duration', 40, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '造型服务', 'name', '新娘造型', 'price', 388.00, 'duration', 90, 'canSinglePurchase', 1)
 ),
 JSON_ARRAY(
   JSON_OBJECT('name', '洗剪吹10次卡', 'type', 'COUNT', 'salePrice', 480.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '洗剪吹', 'count', 10))),
   JSON_OBJECT('name', '洗剪吹20次卡', 'type', 'COUNT', 'salePrice', 880.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '洗剪吹', 'count', 20))),
   JSON_OBJECT('name', '烫染护理套餐', 'type', 'COUNT', 'salePrice', 1280.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '染发', 'count', 3), JSON_OBJECT('serviceName', '烫发', 'count', 2), JSON_OBJECT('serviceName', '深层修复护理', 'count', 5))),
   JSON_OBJECT('name', '储值500送100', 'type', 'VALUE', 'salePrice', 500.00, 'validityDays', 730, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '储值本金', 'amount', 500), JSON_OBJECT('serviceName', '赠送金额', 'amount', 100))),
   JSON_OBJECT('name', '储值1000送300', 'type', 'VALUE', 'salePrice', 1000.00, 'validityDays', 730, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '储值本金', 'amount', 1000), JSON_OBJECT('serviceName', '赠送金额', 'amount', 300))),
   JSON_OBJECT('name', '尊享VIP年卡', 'type', 'MIXED', 'salePrice', 2980.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 0,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '精剪造型', 'count', 12), JSON_OBJECT('serviceName', '头皮护理', 'count', 6), JSON_OBJECT('serviceName', '储值本金', 'amount', 500)))
 ));

-- 2. 美容行业模板
INSERT INTO sys_industry_template (industry, service_items, package_templates) VALUES
('BEAUTY',
 JSON_ARRAY(
   JSON_OBJECT('category', '面部护理', 'name', '基础面部清洁', 'price', 98.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '面部护理', 'name', '深层清洁护理', 'price', 168.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '面部护理', 'name', '补水保湿护理', 'price', 198.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '面部护理', 'name', '抗衰老护理', 'price', 328.00, 'duration', 75, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '面部护理', 'name', '美白淡斑护理', 'price', 298.00, 'duration', 75, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '身体护理', 'name', '全身精油SPA', 'price', 388.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '身体护理', 'name', '背部经络疏通', 'price', 198.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '身体护理', 'name', '肩颈调理', 'price', 168.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '仪器项目', 'name', '光子嫩肤', 'price', 580.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '仪器项目', 'name', '射频紧致', 'price', 680.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '仪器项目', 'name', '水光针', 'price', 880.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美甲美睫', 'name', '基础美甲', 'price', 88.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美甲美睫', 'name', '接睫毛', 'price', 168.00, 'duration', 60, 'canSinglePurchase', 1)
 ),
 JSON_ARRAY(
   JSON_OBJECT('name', '面部护理10次卡', 'type', 'COUNT', 'salePrice', 1280.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '深层清洁护理', 'count', 5), JSON_OBJECT('serviceName', '补水保湿护理', 'count', 5))),
   JSON_OBJECT('name', '全身SPA5次卡', 'type', 'COUNT', 'salePrice', 1680.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '全身精油SPA', 'count', 5))),
   JSON_OBJECT('name', '肩颈调理10次卡', 'type', 'COUNT', 'salePrice', 1280.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '肩颈调理', 'count', 10))),
   JSON_OBJECT('name', '储值1000送200', 'type', 'VALUE', 'salePrice', 1000.00, 'validityDays', 730, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '储值本金', 'amount', 1000), JSON_OBJECT('serviceName', '赠送金额', 'amount', 200))),
   JSON_OBJECT('name', '美容全能年卡', 'type', 'MIXED', 'salePrice', 5980.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 0,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '面部护理', 'count', 12), JSON_OBJECT('serviceName', '全身精油SPA', 'count', 4), JSON_OBJECT('serviceName', '储值本金', 'amount', 1000)))
 ));

-- 3. 健身行业模板
INSERT INTO sys_industry_template (industry, service_items, package_templates) VALUES
('FITNESS',
 JSON_ARRAY(
   JSON_OBJECT('category', '团课', 'name', '瑜伽课', 'price', 38.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '团课', 'name', '动感单车', 'price', 38.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '团课', 'name', '搏击操', 'price', 38.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '团课', 'name', '有氧操', 'price', 38.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '私教', 'name', '私教课（单次）', 'price', 280.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '私教', 'name', '体态矫正私教', 'price', 320.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '私教', 'name', '产后恢复私教', 'price', 350.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色项目', 'name', '体测评估', 'price', 68.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色项目', 'name', '运动康复理疗', 'price', 198.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色项目', 'name', '营养咨询', 'price', 128.00, 'duration', 30, 'canSinglePurchase', 1)
 ),
 JSON_ARRAY(
   JSON_OBJECT('name', '团课30次卡', 'type', 'COUNT', 'salePrice', 680.00, 'validityDays', 90, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '团课', 'count', 30))),
   JSON_OBJECT('name', '团课50次卡', 'type', 'COUNT', 'salePrice', 980.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '团课', 'count', 50))),
   JSON_OBJECT('name', '私教10次卡', 'type', 'COUNT', 'salePrice', 2480.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '私教课', 'count', 10))),
   JSON_OBJECT('name', '私教20次卡', 'type', 'COUNT', 'salePrice', 4680.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '私教课', 'count', 20))),
   JSON_OBJECT('name', '年卡（不限次团课）', 'type', 'COUNT', 'salePrice', 2980.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 0,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '团课', 'count', 365))),
   JSON_OBJECT('name', '尊享全能卡', 'type', 'MIXED', 'salePrice', 8880.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 0,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '团课', 'count', 365), JSON_OBJECT('serviceName', '私教课', 'count', 12), JSON_OBJECT('serviceName', '体测评估', 'count', 4)))
 ));

-- 4. 洗车行业模板
INSERT INTO sys_industry_template (industry, service_items, package_templates) VALUES
('CAR_WASH',
 JSON_ARRAY(
   JSON_OBJECT('category', '基础洗车', 'name', '标准洗车（轿车）', 'price', 35.00, 'duration', 20, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '基础洗车', 'name', '标准洗车（SUV）', 'price', 45.00, 'duration', 25, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '基础洗车', 'name', '精致洗车', 'price', 68.00, 'duration', 40, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '打蜡', 'price', 128.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '抛光', 'price', 198.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '镀晶', 'price', 680.00, 'duration', 180, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '内饰深度清洁', 'price', 258.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '空调清洗', 'price', 168.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '美容养护', 'name', '发动机舱清洁', 'price', 128.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色服务', 'name', '臭氧杀菌', 'price', 88.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色服务', 'name', '轮胎养护', 'price', 68.00, 'duration', 30, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色服务', 'name', '玻璃镀膜', 'price', 388.00, 'duration', 60, 'canSinglePurchase', 1)
 ),
 JSON_ARRAY(
   JSON_OBJECT('name', '洗车10次卡（轿车）', 'type', 'COUNT', 'salePrice', 280.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '标准洗车（轿车）', 'count', 10))),
   JSON_OBJECT('name', '洗车20次卡（轿车）', 'type', 'COUNT', 'salePrice', 480.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '标准洗车（轿车）', 'count', 20))),
   JSON_OBJECT('name', '精致洗车10次卡', 'type', 'COUNT', 'salePrice', 520.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '精致洗车', 'count', 10))),
   JSON_OBJECT('name', '养护套餐卡', 'type', 'COUNT', 'salePrice', 1280.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '精致洗车', 'count', 6), JSON_OBJECT('serviceName', '打蜡', 'count', 3), JSON_OBJECT('serviceName', '内饰深度清洁', 'count', 2))),
   JSON_OBJECT('name', '储值500送80', 'type', 'VALUE', 'salePrice', 500.00, 'validityDays', 730, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '储值本金', 'amount', 500), JSON_OBJECT('serviceName', '赠送金额', 'amount', 80)))
 ));

-- 5. 教培行业模板
INSERT INTO sys_industry_template (industry, service_items, package_templates) VALUES
('EDUCATION',
 JSON_ARRAY(
   JSON_OBJECT('category', '学科辅导', 'name', '语文一对一', 'price', 180.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '学科辅导', 'name', '数学一对一', 'price', 200.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '学科辅导', 'name', '英语一对一', 'price', 200.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '学科辅导', 'name', '物理一对一', 'price', 220.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '小班课', 'name', '语文小班（3-6人）', 'price', 88.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '小班课', 'name', '数学小班（3-6人）', 'price', 98.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '小班课', 'name', '英语小班（3-6人）', 'price', 98.00, 'duration', 90, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '兴趣培养', 'name', '美术课', 'price', 68.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '兴趣培养', 'name', '钢琴课', 'price', 150.00, 'duration', 45, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '兴趣培养', 'name', '书法课', 'price', 68.00, 'duration', 60, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色课程', 'name', '作业辅导', 'price', 48.00, 'duration', 120, 'canSinglePurchase', 1),
   JSON_OBJECT('category', '特色课程', 'name', '学习力测评', 'price', 198.00, 'duration', 60, 'canSinglePurchase', 1)
 ),
 JSON_ARRAY(
   JSON_OBJECT('name', '一对一20次卡', 'type', 'COUNT', 'salePrice', 3480.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '一对一课程', 'count', 20))),
   JSON_OBJECT('name', '一对一40次卡', 'type', 'COUNT', 'salePrice', 6480.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '一对一课程', 'count', 40))),
   JSON_OBJECT('name', '小班课30次卡', 'type', 'COUNT', 'salePrice', 2280.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '小班课', 'count', 30))),
   JSON_OBJECT('name', '兴趣课20次卡', 'type', 'COUNT', 'salePrice', 1080.00, 'validityDays', 180, 'allowTransfer', 0, 'allowCombine', 1,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '兴趣课', 'count', 20))),
   JSON_OBJECT('name', '全科年卡', 'type', 'MIXED', 'salePrice', 12800.00, 'validityDays', 365, 'allowTransfer', 0, 'allowCombine', 0,
     'config', JSON_ARRAY(JSON_OBJECT('serviceName', '一对一课程', 'count', 40), JSON_OBJECT('serviceName', '小班课', 'count', 20), JSON_OBJECT('serviceName', '学习力测评', 'count', 4)))
 );

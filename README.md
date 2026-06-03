# 通用多租户次卡会员管理系统

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.18-green.svg)](https://spring.io/projects/spring-boot)
[![Vue.js](https://img.shields.io/badge/Vue.js-3.4-blue.svg)](https://vuejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.16-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 一套完整的通用多租户次卡会员管理系统，支持 SaaS 模式部署，适用于美容美发、健身、教育培训等行业。

## 项目地址

https://github.com/uewill/member-card-system

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                        客户端层                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Web 管理端  │  │   移动端 APP  │  │    PAD 兼容显示   │  │
│  │   (Vue3)     │  │  (Flutter)   │  │   (响应式布局)    │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      API 网关层                              │
│         JWT 认证 │ 权限控制 │ 多租户隔离 │ 限流               │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      业务服务层                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ 租户管理  │ │ 门店管理  │ │ 会员管理  │ │  次卡管理     │   │
│  ├──────────┤ ├──────────┤ ├──────────┤ ├──────────────┤   │
│  │ 消费核销  │ │ 充值管理  │ │ 业绩统计  │ │  营销工具     │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      数据存储层                              │
│              MySQL 8.0 │ Redis │ MinIO (可选)                │
└─────────────────────────────────────────────────────────────┘
```

## 核心功能

### 多租户管理
- SaaS 模式，支持多租户独立运营
- 行级租户隔离，数据安全隔离
- 租户注册、配置、状态管理

### 门店与员工
- 多门店管理，支持连锁经营
- 员工账号、角色、权限分配
- 员工业绩追踪与提成计算

### 会员与次卡
- 会员档案管理（基本信息、消费记录）
- 次卡类型：纯次数卡、储值卡、混合卡
- 购卡、充值、转卡、退卡
- 卡状态实时追踪

### 消费核销
- 扫码/搜索核销
- 最优卡匹配算法（先到期优先）
- 多卡组合支付
- 消费记录查询

### 营销工具
- 积分系统（消费得积分、积分抵扣）
- 优惠券管理（满减、折扣、体验券）
- 赠送规则引擎

### 报表中心
- 日报/月报/年报
- 套餐销售统计
- 会员消费分析
- 员工业绩排行

## 技术栈

| 层级 | 技术 |
|------|------|
| 后端 | Spring Boot 2.7.18, MyBatis Plus, Spring Security, JWT |
| 前端 | Vue 3, TypeScript, Vite, Arco Design Vue |
| 移动端 | Flutter 3.16, Dart 3.2 |
| 数据库 | MySQL 8.0, Redis 7.0 |
| 部署 | Docker, Docker Compose, GitHub Actions |

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/uewill/member-card-system.git
cd member-card-system
```

### 2. 启动基础设施

```bash
docker-compose up -d mysql redis
```

### 3. 启动后端

```bash
cd backend
mvn spring-boot:run
```

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

### 5. 访问系统

- 管理端：http://localhost:5173
- API 文档：http://localhost:8080/swagger-ui.html
- 默认账号：admin / admin123

## 移动端打包

详见 [APK 打包指南](docs/APK_BUILD_GUIDE.md)

```bash
cd mobile
flutter pub get
flutter build apk --release
```

## 项目结构

```
member-card-system/
├── backend/                 # Spring Boot 后端
│   ├── src/main/java/       # Java 源码
│   ├── src/main/resources/  # 配置文件、SQL 迁移
│   └── pom.xml             # Maven 配置
├── frontend/               # Vue3 管理端
│   ├── src/views/          # 页面组件
│   ├── src/api/            # API 接口
│   └── package.json        # NPM 配置
├── mobile/                 # Flutter 移动端
│   ├── lib/features/       # 功能模块
│   └── pubspec.yaml        # Dart 依赖
├── docs/                   # 文档
│   ├── API.md             # API 文档
│   ├── DEPLOYMENT.md      # 部署文档
│   └── APK_BUILD_GUIDE.md # APK 打包指南
├── docker-compose.yml      # Docker 编排
└── .github/workflows/      # CI/CD
```

## 数据库表结构

| 表名 | 说明 |
|------|------|
| sys_tenant | 租户信息 |
| t_store | 门店信息 |
| t_user | 系统用户（员工/管理员） |
| t_member | 会员信息 |
| t_service_item | 服务项目 |
| t_package_template | 套餐模板 |
| t_member_card | 会员卡实例 |
| t_consume_order | 消费订单 |
| t_consume_detail | 消费明细 |
| t_recharge_order | 充值订单 |
| t_gift_rule | 赠送规则 |
| t_points_record | 积分记录 |
| t_coupon | 优惠券 |
| t_member_coupon | 会员优惠券关联 |

## API 文档

完整 API 文档见 [docs/API.md](docs/API.md)

## 部署文档

详细部署方案见 [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

## 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 开源协议

本项目基于 [MIT](LICENSE) 协议开源。

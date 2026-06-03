# 会员管理系统 RESTful API 接口文档

> 基础路径: `/api/v1`
> 认证方式: Bearer Token (JWT)
> 请求格式: `application/json`
> 响应格式: `application/json`

## 通用响应结构

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码，200=成功，其他=失败 |
| message | String | 提示信息 |
| data | Object | 响应数据 |

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

---

## 一、认证模块 `/api/auth`

### 1.1 登录

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/auth/login` |
| 说明 | 用户登录，返回 JWT Token |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | String | 是 | 手机号 |
| password | String | 是 | 密码 |

**请求示例:**
```json
{
  "phone": "13888888888",
  "password": "123456"
}
```

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "userId": 1,
    "tenantId": 1,
    "role": "TENANT_ADMIN",
    "name": "张三"
  }
}
```

### 1.2 登出

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/auth/logout` |
| 说明 | 退出登录，清除 Token |

**请求头:** `Authorization: Bearer {token}`

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

### 1.3 获取当前用户信息

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/auth/info` |
| 说明 | 获取当前登录用户信息 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "userId": 1,
    "tenantId": 1,
    "role": "TENANT_ADMIN",
    "name": "张三",
    "phone": "13888888888",
    "storeId": 1
  }
}
```

---

## 二、租户模块 `/api/tenant`

### 2.1 创建租户

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/tenant` |
| 说明 | 创建新租户（平台管理员操作） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| companyName | String | 是 | 公司名称 |
| industry | String | 否 | 行业标签 |
| adminPhone | String | 是 | 管理员手机号 |
| adminName | String | 否 | 管理员姓名 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "companyName": "某某美发店",
    "industry": "HAIRCUT",
    "adminPhone": "13888888888",
    "adminName": "张三",
    "status": 1,
    "createdAt": "2026-06-01T10:00:00"
  }
}
```

### 2.2 更新租户信息

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/tenant/{id}` |
| 说明 | 更新租户基本信息 |

### 2.3 获取租户详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/tenant/{id}` |
| 说明 | 获取租户详细信息 |

### 2.4 分页查询租户列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/tenant/page` |
| 说明 | 分页查询租户（平台管理员） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | Integer | 否 | 当前页码，默认1 |
| size | Integer | 否 | 每页条数，默认10 |
| companyName | String | 否 | 公司名称（模糊搜索） |
| status | Integer | 否 | 状态筛选 |

### 2.5 审批租户

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/tenant/{id}/approve` |
| 说明 | 审批租户（通过/拒绝） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | Integer | 是 | 审批状态：1-通过，0-拒绝 |

### 2.6 更新租户配置

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/tenant/{id}/config` |
| 说明 | 更新租户配置项 |

### 2.7 启用/停用租户

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/tenant/{id}/status` |
| 说明 | 切换租户启用/停用状态 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | Integer | 是 | 状态：1-启用，0-停用 |

---

## 三、门店模块 `/api/stores`

### 3.1 创建门店

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/stores` |
| 说明 | 创建新门店 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| storeName | String | 是 | 门店名称 |
| address | String | 否 | 地址 |
| phone | String | 否 | 联系电话 |
| businessHours | String | 否 | 营业时间 |

### 3.2 更新门店

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/stores/{id}` |
| 说明 | 更新门店信息 |

### 3.3 获取门店详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/stores/{id}` |
| 说明 | 获取门店详细信息 |

### 3.4 查询门店列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/stores` |
| 说明 | 获取当前租户下所有门店 |

### 3.5 更新门店状态

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/stores/{id}/status` |
| 说明 | 启用/停用门店 |

---

## 四、员工模块 `/api/staff`

### 4.1 创建员工

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/staff` |
| 说明 | 创建员工账号 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | String | 是 | 手机号 |
| name | String | 是 | 姓名 |
| password | String | 是 | 初始密码 |
| role | String | 是 | 角色 |
| storeId | Long | 否 | 所属门店ID |

### 4.2 更新员工信息

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/staff/{id}` |
| 说明 | 更新员工信息 |

### 4.3 查询员工列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/staff` |
| 说明 | 获取员工列表（支持门店筛选） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| storeId | Long | 否 | 门店ID筛选 |
| role | String | 否 | 角色筛选 |
| keyword | String | 否 | 姓名/手机号搜索 |

### 4.4 获取员工详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/staff/{id}` |
| 说明 | 获取员工详细信息 |

### 4.5 员工今日业绩概览

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/staff/today-overview` |
| 说明 | 获取当前员工今日业绩数据 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "staffName": "王师傅",
    "storeName": "旗舰店",
    "todayServiceCount": 8,
    "todayRevenue": 1280.00,
    "todayNewMembers": 2,
    "monthServiceCount": 156,
    "monthRevenue": 24560.00,
    "monthTarget": 30000.00,
    "ranking": 3,
    "totalStaff": 12,
    "recentServices": [
      {
        "id": 1,
        "memberName": "张三",
        "serviceName": "精剪造型",
        "amount": 128.00,
        "time": "14:30"
      }
    ]
  }
}
```

### 4.6 员工业绩详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/staff/performance` |
| 说明 | 获取业绩详情（支持日/周/月切换） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | String | 是 | 周期：day/week/month |
| date | String | 否 | 指定日期（默认今天） |

### 4.7 员工服务历史

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/staff/service-history` |
| 说明 | 获取员工服务历史记录 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |
| status | String | 否 | 状态筛选 |

### 4.8 扫码核销消费

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/staff/verify-consume` |
| 说明 | 员工扫码后执行消费核销 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| memberId | Long | 是 | 会员ID |
| cardId | Long | 是 | 使用的卡实例ID |
| serviceItemId | Long | 是 | 服务项目ID |
| storeId | Long | 是 | 门店ID |
| performanceRatio | BigDecimal | 否 | 业绩分摊比例，默认1.00 |

---

## 五、服务项目模块 `/api/service-items`

### 5.1 创建服务项目

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/service-items` |
| 说明 | 创建服务项目 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | String | 否 | 分类 |
| name | String | 是 | 服务名称 |
| price | BigDecimal | 是 | 单次价格 |
| duration | Integer | 否 | 服务时长（分钟） |
| canSinglePurchase | Integer | 否 | 是否可单独购买，默认1 |

### 5.2 更新服务项目

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/service-items/{id}` |
| 说明 | 更新服务项目信息 |

### 5.3 查询服务项目列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/service-items` |
| 说明 | 获取服务项目列表（支持分类筛选） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | String | 否 | 分类筛选 |
| keyword | String | 否 | 名称搜索 |

### 5.4 获取服务项目详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/service-items/{id}` |
| 说明 | 获取服务项目详情 |

### 5.5 更新服务项目状态

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/service-items/{id}/status` |
| 说明 | 启用/停用服务项目 |

---

## 六、套餐模块 `/api/packages`

### 6.1 创建套餐模板

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/packages` |
| 说明 | 创建次卡套餐模板 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 套餐名称 |
| type | String | 是 | 类型：COUNT/VALUE/MIXED |
| config | String(JSON) | 是 | 套餐配置JSON |
| salePrice | BigDecimal | 是 | 售价 |
| validityDays | Integer | 否 | 有效期天数 |
| validityEndDate | String(Date) | 否 | 固定截止日期 |
| allowTransfer | Integer | 否 | 是否允许转赠，默认0 |
| allowCombine | Integer | 否 | 是否允许与其他优惠同享，默认1 |

**config 示例（次卡）:**
```json
[
  { "serviceName": "洗剪吹", "count": 10 },
  { "serviceName": "护理", "count": 5 }
]
```

**config 示例（储值卡）:**
```json
[
  { "serviceName": "储值本金", "amount": 500 },
  { "serviceName": "赠送金额", "amount": 100 }
]
```

### 6.2 更新套餐模板

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/packages/{id}` |
| 说明 | 更新套餐模板信息 |

### 6.3 查询套餐列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/packages` |
| 说明 | 获取套餐模板列表 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | String | 否 | 类型筛选 |
| status | Integer | 否 | 状态筛选 |

### 6.4 获取套餐详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/packages/{id}` |
| 说明 | 获取套餐模板详情 |

### 6.5 更新套餐状态

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/packages/{id}/status` |
| 说明 | 上架/下架套餐 |

---

## 七、会员模块 `/api/members`

### 7.1 创建会员

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/members` |
| 说明 | 创建会员 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | String | 是 | 手机号 |
| name | String | 否 | 姓名 |
| birthday | String(Date) | 否 | 生日 |
| tags | String(JSON) | 否 | 标签JSON数组 |
| sourceChannel | String | 否 | 来源渠道 |

### 7.2 更新会员信息

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/members/{id}` |
| 说明 | 更新会员信息 |

### 7.3 查询会员列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/members` |
| 说明 | 分页查询会员列表 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认10 |
| keyword | String | 否 | 姓名/手机号搜索 |
| tag | String | 否 | 标签筛选 |

### 7.4 获取会员详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/members/{id}` |
| 说明 | 获取会员详细信息（含卡实例列表） |

### 7.5 会员首页概览（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/overview` |
| 说明 | 获取会员首页概览数据 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "memberName": "张三",
    "phone": "138****8888",
    "totalCards": 3,
    "totalBalance": 1520.00,
    "totalPoints": 860,
    "expiringSoon": 1
  }
}
```

### 7.6 会员卡包列表（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/cards` |
| 说明 | 获取会员名下所有有效卡实例 |

### 7.7 会员消费记录（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/consume-records` |
| 说明 | 获取会员消费记录（按时间倒序） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码，默认1 |
| size | Integer | 否 | 每页条数，默认20 |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

### 7.8 消费记录详情（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/consume-records/{orderId}` |
| 说明 | 获取消费记录详情 |

### 7.9 可购买套餐列表（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/packages` |
| 说明 | 获取当前可购买的套餐列表 |

### 7.10 购买套餐（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/member/purchase` |
| 说明 | 创建购买套餐订单 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| templateId | Long | 是 | 套餐模板ID |
| storeId | Long | 是 | 门店ID |
| paymentMethod | String | 是 | 支付方式：WECHAT/ALIPAY/CASH |

### 7.11 查询支付状态（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/payment-status/{orderNo}` |
| 说明 | 查询订单支付状态 |

### 7.12 会员个人信息（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/profile` |
| 说明 | 获取会员个人信息 |

### 7.13 更新会员个人信息（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/member/profile` |
| 说明 | 更新会员个人信息 |

### 7.14 消息通知列表（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/notifications` |
| 说明 | 获取消息通知列表 |

### 7.15 标记消息已读（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/member/notifications/{id}/read` |
| 说明 | 标记指定消息为已读 |

### 7.16 会员二维码（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/qrcode` |
| 说明 | 获取会员二维码数据（用于出示给员工扫码） |

### 7.17 充值赠送规则（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/member/gift-rules` |
| 说明 | 获取当前充值赠送规则 |

### 7.18 创建充值订单（移动端）

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/member/recharge` |
| 说明 | 创建充值订单 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| cardId | Long | 是 | 充值目标卡ID |
| amount | BigDecimal | 是 | 充值金额 |
| paymentMethod | String | 是 | 支付方式 |

---

## 八、卡实例模块 `/api/cards`

### 8.1 获取卡实例列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/cards` |
| 说明 | 获取卡实例列表（支持会员筛选） |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| memberId | Long | 否 | 会员ID筛选 |
| status | String | 否 | 状态筛选 |
| page | Integer | 否 | 页码 |
| size | Integer | 否 | 每页条数 |

### 8.2 获取卡实例详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/cards/{id}` |
| 说明 | 获取卡实例详情（含剩余次数/余额） |

### 8.3 冻结/解冻卡

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/cards/{id}/freeze` |
| 说明 | 冻结或解冻会员卡 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| action | String | 是 | 操作：FREEZE/UNFREEZE |

### 8.4 卡转赠

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/cards/{id}/transfer` |
| 说明 | 将卡转赠给其他会员 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| targetMemberId | Long | 是 | 目标会员ID |

---

## 九、消费核销模块 `/api/consume`

### 9.1 创建消费订单

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/consume` |
| 说明 | 创建消费核销订单 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| memberId | Long | 是 | 会员ID |
| storeId | Long | 是 | 门店ID |
| items | Array | 是 | 消费明细列表 |

**items 子项:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| serviceItemId | Long | 是 | 服务项目ID |
| cardId | Long | 否 | 扣减的卡实例ID |
| serviceStaffId | Long | 否 | 服务人员ID |
| performanceRatio | BigDecimal | 否 | 业绩分摊比例 |

### 9.2 查询消费订单列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/consume` |
| 说明 | 查询消费订单列表 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | Integer | 否 | 页码 |
| size | Integer | 否 | 每页条数 |
| memberId | Long | 否 | 会员ID筛选 |
| storeId | Long | 否 | 门店ID筛选 |
| startDate | String | 否 | 开始日期 |
| endDate | String | 否 | 结束日期 |

### 9.3 获取消费订单详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/consume/{id}` |
| 说明 | 获取消费订单详情（含明细） |

### 9.4 取消消费订单

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/consume/{id}/cancel` |
| 说明 | 取消消费订单（回退扣减） |

---

## 十、充值模块 `/api/recharge`

### 10.1 创建充值订单

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/recharge` |
| 说明 | 创建充值订单 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| memberId | Long | 是 | 会员ID |
| cardId | Long | 是 | 充值目标卡ID |
| amount | BigDecimal | 是 | 充值金额 |
| giftAmount | BigDecimal | 否 | 赠送金额 |
| paymentMethod | String | 是 | 支付方式 |

### 10.2 查询充值订单列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/recharge` |
| 说明 | 查询充值订单列表 |

### 10.3 获取充值订单详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/recharge/{id}` |
| 说明 | 获取充值订单详情 |

### 10.4 确认收款

| 项目 | 说明 |
|------|------|
| 路径 | PUT `/api/recharge/{id}/confirm` |
| 说明 | 确认线下收款（CASH 支付方式） |

---

## 十一、业绩模块 `/api/performance`

### 11.1 员工业绩汇总

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/performance/summary` |
| 说明 | 获取员工业绩汇总数据 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | String | 是 | 周期：day/week/month |
| date | String | 否 | 指定日期 |
| staffId | Long | 否 | 员工ID（不传则返回所有） |

### 11.2 业绩排行

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/performance/rank` |
| 说明 | 获取业绩排行榜 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| period | String | 是 | 周期：day/week/month |
| limit | Integer | 否 | 排行人数，默认10 |

### 11.3 门店业绩汇总

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/performance/store-summary` |
| 说明 | 获取门店业绩汇总 |

---

## 十二、报表模块 `/api/reports`

### 12.1 营收报表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/reports/revenue` |
| 说明 | 营收统计报表 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| startDate | String | 是 | 开始日期 |
| endDate | String | 是 | 结束日期 |
| groupBy | String | 否 | 分组维度：day/week/month |
| storeId | Long | 否 | 门店ID筛选 |

### 12.2 会员分析报表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/reports/member-analysis` |
| 说明 | 会员增长、活跃度、消费分析 |

### 12.3 套餐销售报表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/reports/package-sales` |
| 说明 | 套餐销售排行、转化率分析 |

### 12.4 服务项目统计

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/reports/service-stats` |
| 说明 | 服务项目消费频次、收入统计 |

---

## 十三、营销工具模块 `/api/marketing`

### 13.1 优惠券管理

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/marketing/coupons` |
| 说明 | 创建优惠券 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | 是 | 优惠券名称 |
| type | String | 是 | 类型：DISCOUNT/FULL_REDUCTION |
| config | String(JSON) | 是 | 优惠配置 |
| applicableItems | String(JSON) | 否 | 适用服务项目ID列表 |
| validFrom | String(Date) | 是 | 生效日期 |
| validTo | String(Date) | 是 | 到期日期 |
| totalCount | Integer | 是 | 发行总量 |

### 13.2 查询优惠券列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/marketing/coupons` |
| 说明 | 查询优惠券列表 |

### 13.3 发放优惠券

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/marketing/coupons/{id}/distribute` |
| 说明 | 向指定会员发放优惠券 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| memberIds | Array[Long] | 是 | 会员ID列表 |

### 13.4 赠送规则管理

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/marketing/gift-rules` |
| 说明 | 创建充值赠送规则 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| minAmount | BigDecimal | 是 | 最低充值金额 |
| maxAmount | BigDecimal | 否 | 最高充值金额 |
| giftAmount | BigDecimal | 是 | 赠送金额 |

### 13.5 查询赠送规则列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/marketing/gift-rules` |
| 说明 | 查询赠送规则列表 |

---

## 十四、行业模板模块 `/api/industry-template`

### 14.1 查询行业列表

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/industry-template/industries` |
| 说明 | 查询所有可用行业模板列表 |

**响应示例:**
```json
{
  "code": 200,
  "data": [
    { "id": 1, "industry": "HAIRCUT", "createdAt": "2026-01-01T00:00:00" },
    { "id": 2, "industry": "BEAUTY", "createdAt": "2026-01-01T00:00:00" },
    { "id": 3, "industry": "FITNESS", "createdAt": "2026-01-01T00:00:00" },
    { "id": 4, "industry": "CAR_WASH", "createdAt": "2026-01-01T00:00:00" },
    { "id": 5, "industry": "EDUCATION", "createdAt": "2026-01-01T00:00:00" }
  ]
}
```

### 14.2 获取行业模板详情

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/industry-template/{industry}` |
| 说明 | 获取指定行业模板详情（含服务项目和套餐模板） |

**路径参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| industry | String | 是 | 行业标识 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "industry": "HAIRCUT",
    "service_items": [
      {
        "category": "基础服务",
        "name": "男士洗剪吹",
        "price": 38.00,
        "duration": 30,
        "canSinglePurchase": 1
      }
    ],
    "package_templates": [
      {
        "name": "洗剪吹10次卡",
        "type": "COUNT",
        "salePrice": 480.00,
        "validityDays": 365,
        "config": [{ "serviceName": "洗剪吹", "count": 10 }]
      }
    ]
  }
}
```

### 14.3 复制模板到租户

| 项目 | 说明 |
|------|------|
| 路径 | POST `/api/industry-template/copy` |
| 说明 | 将行业模板复制到指定租户 |

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| tenantId | Long | 是 | 目标租户ID |
| industry | String | 是 | 行业标识 |

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "tenantId": 1,
    "industry": "HAIRCUT",
    "serviceItemCount": 12,
    "packageTemplateCount": 6
  }
}
```

---

## 全局字典模块 `/api/dict`

### 查询字典

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/dict/{type}` |
| 说明 | 根据字典类型查询字典列表 |

**响应示例:**
```json
{
  "code": 200,
  "data": [
    { "dictKey": "HAIRCUT", "dictValue": "美发", "sortOrder": 1 },
    { "dictKey": "BEAUTY", "dictValue": "美容", "sortOrder": 2 }
  ]
}
```

---

## 平台统计模块 `/api/platform-stats`

### 平台概览统计

| 项目 | 说明 |
|------|------|
| 路径 | GET `/api/platform-stats/overview` |
| 说明 | 获取平台级概览统计（租户数、会员数、营收等） |

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证（Token 无效或过期） |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 数据冲突（如手机号已注册） |
| 500 | 服务器内部错误 |

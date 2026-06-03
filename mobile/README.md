# 会员管理系统 - 移动端

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── core/
│   ├── config/
│   │   └── app_config.dart   # 应用配置
│   └── utils/
│   │   └── responsive_helper.dart  # 响应式布局助手
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── pages/
│   │           └── login_page.dart
│   ├── card/
│   │   └── presentation/
│   │       └── pages/
│   │           └── card_list_page.dart
│   ├── consume/
│   │   └── presentation/
│   │       └── pages/
│   │           └── consume_record_page.dart
│   └── staff/
│       └── presentation/
│           └── pages/
│               └── scan_verify_page.dart
├── shared/
│   ├── models/
│   ├── services/
│   │   ├── api_client.dart
│   │   └── auth_service.dart
│   └── widgets/
```

## 响应式布局

本项目支持手机和 PAD 两种尺寸自适应显示：

- **手机**（宽度 < 600dp）：紧凑布局，适合会员查看卡包、消费记录
- **PAD**（宽度 >= 600dp）：宽松布局，适合收银员核销、门店经理查看报表

使用 `ResponsiveHelper` 类进行响应式适配：

```dart
// 根据设备类型返回不同的值
final spacing = ResponsiveHelper.spacing(context);

// 根据设备类型返回不同的字体大小
final fontSize = ResponsiveHelper.fontSize(context);

// 判断设备类型
if (ResponsiveHelper.isPhone(context)) {
  // 手机布局
} else if (ResponsiveHelper.isPad(context)) {
  // PAD 布局
}
```

## 运行项目

```bash
flutter pub get
flutter run
```
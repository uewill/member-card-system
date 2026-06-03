# APK 打包指南

## 项目地址

https://github.com/uewill/member-card-system

## 环境要求

- Flutter SDK 3.16+
- Dart SDK 3.2+
- Android SDK (API 21-34)
- JDK 17
- Android Studio (推荐) 或 VS Code

---

## 一、环境安装

### 1. 安装 Flutter SDK

```bash
# 国内用户推荐使用清华镜像
git clone https://mirrors.tuna.tsinghua.edu.cn/git/flutter-sdk.git flutter

# 或官方地址
git clone https://github.com/flutter/flutter.git

# 配置环境变量
export PATH="$PATH:`pwd`/flutter/bin"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# 验证安装
flutter doctor
```

### 2. 安装 Android SDK

通过 Android Studio 安装：
1. 下载 Android Studio: https://developer.android.com/studio
2. 打开 SDK Manager → SDK Platforms
3. 勾选：
   - Android SDK Platform 33
   - Android SDK Platform 34
   - Android SDK Build-Tools 33.0.0
   - Android SDK Command-line Tools
4. 配置环境变量：

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
```

### 3. 安装 JDK 17

```bash
# macOS
brew install openjdk@17

# Ubuntu/Debian
sudo apt install openjdk-17-jdk

# 验证
java -version
```

---

## 二、项目配置

### 1. 克隆项目

```bash
git clone https://github.com/uewill/member-card-system.git
cd member-card-system/mobile
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 API 地址

编辑 `lib/core/config/app_config.dart`：

```dart
static const String baseUrl = 'http://你的服务器地址:8080/api/v1';
```

### 4. 配置应用签名（发布包必需）

创建 `android/key.properties`：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=你的别名
storeFile=你的密钥库路径.jks
```

生成签名密钥：

```bash
keytool -genkey -v -keystore ~/member-card-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias membercard
```

---

## 三、打包 APK

### 调试包（Debug）

```bash
flutter build apk --debug
```

输出路径：`build/app/outputs/flutter-apk/app-debug.apk`

### 发布包（Release）

```bash
flutter build apk --release
```

输出路径：`build/app/outputs/flutter-apk/app-release.apk`

### App Bundle（Google Play 上架）

```bash
flutter build appbundle --release
```

输出路径：`build/app/outputs/bundle/release/app-release.aab`

---

## 四、常见问题

### 1. Gradle 下载慢

编辑 `android/build.gradle`：

```gradle
buildscript {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        google()
        mavenCentral()
    }
}
```

### 2. 编译内存不足

```bash
export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=512m"
```

### 3. 多架构 APK

```bash
# 分架构打包（减小体积）
flutter build apk --release --split-per-abi

# 输出：
# app-arm64-v8a-release.apk
# app-armeabi-v7a-release.apk
# app-x86_64-release.apk
```

---

## 五、安装测试

```bash
# 连接手机（开启 USB 调试）
flutter devices

# 安装并运行
flutter run --release

# 或手动安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 六、项目结构

```
mobile/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── core/
│   │   ├── config/app_config.dart   # 全局配置
│   │   └── utils/
│   │       └── responsive_helper.dart  # 响应式适配
│   ├── features/
│   │   ├── auth/                    # 登录认证
│   │   ├── card/                    # 会员卡管理
│   │   ├── member/                  # 会员端
│   │   ├── consume/                 # 消费核销
│   │   └── staff/                   # 员工端
│   └── widgets/                     # 公共组件
├── android/                         # Android 原生配置
├── assets/                          # 图片、字体资源
└── pubspec.yaml                     # 依赖配置
```

---

## 七、后端启动

```bash
cd ../backend

# 方式1：本地启动（需 MySQL + Redis）
mvn spring-boot:run

# 方式2：Docker 启动
docker-compose up -d mysql redis
mvn spring-boot:run

# 方式3：完整 Docker 部署
docker-compose up -d
```

默认 API 地址：`http://localhost:8080/api/v1`

---

## 八、联系方式

如有问题，请提交 Issue：https://github.com/uewill/member-card-system/issues

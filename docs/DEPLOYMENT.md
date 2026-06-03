# 会员管理系统 - 部署文档

## 一、环境要求

### 1.1 服务器环境

| 组件 | 最低版本 | 推荐版本 |
|------|----------|----------|
| 操作系统 | CentOS 7+ / Ubuntu 18.04+ | Ubuntu 22.04 LTS |
| CPU | 2 核 | 4 核+ |
| 内存 | 4 GB | 8 GB+ |
| 磁盘 | 40 GB | 100 GB SSD |

### 1.2 软件依赖

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| Docker | 20.10+ | 容器运行时 |
| Docker Compose | 2.0+ | 容器编排 |
| JDK | 17+ | Java 运行时（非 Docker 部署时） |
| Maven | 3.8+ | Java 构建工具（非 Docker 部署时） |
| Node.js | 18+ | 前端构建（非 Docker 部署时） |
| MySQL | 8.0+ | 数据库 |
| Redis | 7.0+ | 缓存/会话存储 |
| Nginx | 1.20+ | 反向代理（生产环境推荐） |

### 1.3 端口规划

| 服务 | 端口 | 说明 |
|------|------|------|
| Nginx | 80/443 | 前端静态资源 + API 反向代理 |
| Backend | 8080 | Spring Boot 应用 |
| Frontend | 80 | 前端容器（Docker 部署时） |
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存 |

---

## 二、Docker Compose 部署（推荐）

### 2.1 快速部署

```bash
# 1. 克隆项目
git clone https://github.com/uewill/member-card-system.git
cd member-card-system

# 2. 配置环境变量（可选，修改默认密码等）
cp .env.example .env
# 编辑 .env 文件，修改数据库密码、JWT密钥等

# 3. 启动所有服务
docker compose up -d

# 4. 查看服务状态
docker compose ps

# 5. 查看日志
docker compose logs -f backend
```

### 2.2 docker-compose.yml 说明

项目根目录已包含 `docker-compose.yml`，定义了以下服务：

| 服务名 | 镜像/构建 | 说明 |
|--------|-----------|------|
| mysql | mysql:8.0 | 数据库服务 |
| redis | redis:7-alpine | 缓存服务 |
| backend | ./backend (Dockerfile) | 后端 Spring Boot 应用 |
| frontend | ./frontend (Dockerfile) | 前端 Vue.js 应用 |

### 2.3 环境变量配置

在 `docker-compose.yml` 中或通过 `.env` 文件配置以下环境变量：

```yaml
# MySQL 配置
MYSQL_ROOT_PASSWORD: root123        # 数据库 root 密码（生产环境请修改）
MYSQL_DATABASE: member_card        # 数据库名称

# Spring Boot 配置
SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/member_card?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
SPRING_DATASOURCE_USERNAME: root
SPRING_DATASOURCE_PASSWORD: root123
SPRING_DATA_REDIS_HOST: redis
SPRING_DATA_REDIS_PORT: 6379

# JWT 配置（通过 application.yml 配置）
# jwt.secret: your-jwt-secret-key
# jwt.expiration: 86400
```

### 2.4 数据持久化

Docker Compose 已配置数据卷持久化：

```yaml
volumes:
  mysql_data:    # MySQL 数据持久化
  redis_data:    # Redis 数据持久化
```

### 2.5 常用运维命令

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启单个服务
docker compose restart backend

# 查看日志
docker compose logs -f backend
docker compose logs -f mysql

# 进入 MySQL 容器
docker compose exec mysql mysql -uroot -proot123 member_card

# 进入 Redis 容器
docker compose exec redis redis-cli

# 重新构建并启动（代码更新后）
docker compose up -d --build backend
```

---

## 三、Kubernetes 部署

### 3.1 前置条件

- 已有 Kubernetes 集群（v1.24+）
- 已安装 kubectl 命令行工具
- 已配置 kubeconfig

### 3.2 Namespace 创建

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: member-card
  labels:
    app: member-card-system
```

### 3.3 MySQL 部署（使用 StatefulSet 或 Helm）

```bash
# 推荐使用 Helm 安装 MySQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql bitnami/mysql \
  --namespace member-card \
  --set auth.rootPassword=root123 \
  --set auth.database=member_card \
  --set primary.persistence.size=20Gi
```

### 3.4 Redis 部署

```bash
# 推荐使用 Helm 安装 Redis
helm install redis bitnami/redis \
  --namespace member-card \
  --set auth.enabled=false
```

### 3.5 Backend Deployment

```yaml
# backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: member-card-backend
  namespace: member-card
  labels:
    app: member-card-backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: member-card-backend
  template:
    metadata:
      labels:
        app: member-card-backend
    spec:
      containers:
        - name: backend
          image: member-card-backend:latest
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_DATASOURCE_URL
              value: jdbc:mysql://mysql:3306/member_card?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
            - name: SPRING_DATASOURCE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: member-card-secrets
                  key: mysql-username
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: member-card-secrets
                  key: mysql-password
            - name: SPRING_DATA_REDIS_HOST
              value: redis
            - name: SPRING_DATA_REDIS_PORT
              value: "6379"
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: member-card-backend
  namespace: member-card
spec:
  selector:
    app: member-card-backend
  ports:
    - port: 8080
      targetPort: 8080
  type: ClusterIP
```

### 3.6 Frontend Deployment

```yaml
# frontend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: member-card-frontend
  namespace: member-card
  labels:
    app: member-card-frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: member-card-frontend
  template:
    metadata:
      labels:
        app: member-card-frontend
    spec:
      containers:
        - name: frontend
          image: member-card-frontend:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: member-card-frontend
  namespace: member-card
spec:
  selector:
    app: member-card-frontend
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

### 3.7 Ingress 配置

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: member-card-ingress
  namespace: member-card
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - app.example.com
      secretName: member-card-tls
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: member-card-backend
                port:
                  number: 8080
          - path: /
            pathType: Prefix
            backend:
              service:
                name: member-card-frontend
                port:
                  number: 80
```

### 3.8 Secrets 配置

```bash
# 创建密钥
kubectl create secret generic member-card-secrets \
  --namespace member-card \
  --from-literal=mysql-username=root \
  --from-literal=mysql-password=root123 \
  --from-literal=jwt-secret=your-jwt-secret-key
```

### 3.9 K8s 部署命令

```bash
# 1. 创建命名空间
kubectl apply -f namespace.yaml

# 2. 部署 MySQL 和 Redis（Helm）
helm install mysql bitnami/mysql -n member-card ...
helm install redis bitnami/redis -n member-card ...

# 3. 创建密钥
kubectl apply -f secrets.yaml

# 4. 部署后端和前端
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml

# 5. 配置 Ingress
kubectl apply -f ingress.yaml

# 6. 查看部署状态
kubectl get all -n member-card
kubectl get ingress -n member-card
```

---

## 四、环境变量配置

### 4.1 后端配置（application.yml）

```yaml
# application.yml 核心配置
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://${MYSQL_HOST:mysql}:${MYSQL_PORT:3306}/${MYSQL_DATABASE:member_card}?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: ${MYSQL_USERNAME:root}
    password: ${MYSQL_PASSWORD:root123}
    driver-class-name: com.mysql.cj.jdbc.Driver
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

# JWT 配置
jwt:
  secret: ${JWT_SECRET:member-card-default-secret-key}
  expiration: ${JWT_EXPIRATION:86400}

# MyBatis-Plus 配置
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    db-config:
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
```

### 4.2 环境变量清单

| 变量名 | 说明 | 默认值 | 生产环境建议 |
|--------|------|--------|-------------|
| MYSQL_HOST | MySQL 主机地址 | mysql | 实际数据库地址 |
| MYSQL_PORT | MySQL 端口 | 3306 | 3306 |
| MYSQL_DATABASE | 数据库名称 | member_card | member_card |
| MYSQL_USERNAME | 数据库用户名 | root | 创建专用账户 |
| MYSQL_PASSWORD | 数据库密码 | root123 | 强密码 |
| REDIS_HOST | Redis 主机地址 | redis | 实际 Redis 地址 |
| REDIS_PORT | Redis 端口 | 6379 | 6379 |
| JWT_SECRET | JWT 密钥 | (默认值) | 随机强密钥 |
| JWT_EXPIRATION | Token 过期时间(秒) | 86400 | 86400 |
| SPRING_PROFILES_ACTIVE | 运行环境 | dev | prod |

---

## 五、数据库初始化

### 5.1 自动迁移（推荐）

项目使用 Flyway 进行数据库版本管理，应用启动时会自动执行迁移脚本：

```
db/migration/
  V1.0.0__Init_Schema.sql          -- 核心表结构初始化
  V1.1.0__Industry_Templates.sql   -- 行业模板初始化数据
  V1.2.0__Add_Version_Columns.sql  -- 添加乐观锁字段
```

### 5.2 手动初始化（备选）

如果需要手动初始化数据库：

```bash
# 进入 MySQL 容器
docker compose exec mysql mysql -uroot -proot123 member_card

# 按顺序执行 SQL 文件
source /path/to/V1.0.0__Init_Schema.sql;
source /path/to/V1.1.0__Industry_Templates.sql;
source /path/to/V1.2.0__Add_Version_Columns.sql;
```

### 5.3 初始管理员账号

系统启动后需要手动创建初始管理员账号：

```sql
-- 密码为 BCrypt 加密后的值，默认密码: admin123
INSERT INTO t_user (tenant_id, store_id, phone, name, password, role, status)
VALUES (1, NULL, '13800000000', '系统管理员', '\$2a\$10\$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'TENANT_ADMIN', 1);
```

> 注意：请在生产环境中立即修改默认密码。

---

## 六、常见问题排查

### 6.1 后端启动失败

**问题:** 后端容器启动后立即退出

```bash
# 查看后端日志
docker compose logs backend

# 常见原因：
# 1. MySQL 未就绪 -> 等待 MySQL healthcheck 通过
# 2. 数据库连接失败 -> 检查 SPRING_DATASOURCE_URL 配置
# 3. 端口被占用 -> 检查 8080 端口是否被占用
```

**解决方案:**
```bash
# 检查 MySQL 是否就绪
docker compose exec mysql mysqladmin ping -h localhost

# 检查端口占用
netstat -tlnp | grep 8080

# 重启后端
docker compose restart backend
```

### 6.2 数据库连接失败

**问题:** `Communications link failure` 或 `Connection refused`

```bash
# 1. 检查 MySQL 容器状态
docker compose ps mysql

# 2. 检查 MySQL 日志
docker compose logs mysql

# 3. 测试连接
docker compose exec mysql mysql -uroot -proot123 -h 127.0.0.1 member_card

# 4. 检查网络连通性
docker compose exec backend ping mysql
```

### 6.3 Flyway 迁移失败

**问题:** 数据库表已存在或迁移脚本冲突

```bash
# 查看迁移状态
docker compose exec mysql mysql -uroot -proot123 member_card \
  -e "SELECT * FROM flyway_schema_history;"

# 修复: 重建数据库（注意：会丢失数据）
docker compose exec mysql mysql -uroot -proot123 \
  -e "DROP DATABASE member_card; CREATE DATABASE member_card;"
docker compose restart backend
```

### 6.4 前端页面空白

**问题:** 访问前端页面显示空白

```bash
# 1. 检查前端容器状态
docker compose ps frontend

# 2. 查看前端日志
docker compose logs frontend

# 3. 检查 Nginx 配置
docker compose exec frontend cat /etc/nginx/conf.d/default.conf

# 4. 常见原因：API 地址配置错误
#    检查前端构建时的 API_BASE_URL 配置
```

### 6.5 API 返回 401

**问题:** 所有 API 请求返回 401 Unauthorized

```bash
# 1. 确认 Token 是否正确获取
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800000000","password":"admin123"}'

# 2. 确认 Token 是否在请求头中正确传递
curl http://localhost:8080/api/auth/info \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. 检查 JWT 密钥配置是否一致
```

### 6.6 内存不足

**问题:** 容器因 OOM 被杀

```bash
# 查看容器资源使用
docker stats

# 调整 JVM 内存限制
# 在 docker-compose.yml 中添加：
environment:
  JAVA_OPTS: "-Xms256m -Xmx512m"

# 或在 Kubernetes 中调整 resources.limits.memory
```

### 6.7 日志查看

```bash
# Docker Compose 查看所有服务日志
docker compose logs -f

# 只看后端日志（最近100行）
docker compose logs --tail=100 backend

# Kubernetes 查看日志
kubectl logs -f deployment/member-card-backend -n member-card
kubectl logs -f deployment/member-card-backend -n member-card --previous
```

---

## 七、备份与恢复

### 7.1 数据库备份

```bash
# Docker 环境备份
docker compose exec mysql mysqldump -uroot -proot123 member_card > backup_$(date +%Y%m%d).sql

# Kubernetes 环境备份
kubectl exec -it mysql-0 -n member-card -- mysqldump -uroot -proot123 member_card > backup.sql
```

### 7.2 数据库恢复

```bash
# Docker 环境恢复
cat backup.sql | docker compose exec -T mysql mysql -uroot -proot123 member_card

# Kubernetes 环境恢复
cat backup.sql | kubectl exec -i mysql-0 -n member-card -- mysql -uroot -proot123 member_card
```

---

## 八、安全建议

1. **修改默认密码**: 生产环境中务必修改 MySQL root 密码、Redis 密码、JWT 密钥
2. **启用 HTTPS**: 使用 Nginx 配置 SSL 证书，强制 HTTPS 访问
3. **网络隔离**: 数据库和 Redis 不对外暴露端口，仅在内网访问
4. **定期备份**: 设置定时任务，每日自动备份数据库
5. **日志审计**: 开启操作日志记录，定期审计敏感操作
6. **防火墙规则**: 仅开放必要端口（80/443），限制管理端口访问来源

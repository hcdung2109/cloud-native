# Phase 3: API Gateway & Service Exposure

## Mục tiêu
Expose services qua Kong API Gateway với các tính năng:
- Routing & Load Balancing
- Rate Limiting
- CORS support
- Centralized API management

## Kiến trúc

```
┌─────────────────┐
│   Client/User   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│   Kong Gateway (NodePort)       │
│   Port: 30800 (Proxy)           │
│   Port: 30801 (Admin API)       │
│   Port: 30802 (Admin GUI)       │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│   User Service (ClusterIP)      │
│   Port: 8080                    │
└─────────────────────────────────┘
```

## Các thành phần

### 1. Kong Gateway (`07-kong-gateway-deployment.yaml`)
- **Mode**: DB-less (declarative configuration)
- **Image**: kong:3.4
- **Ports**:
  - `8000`: Proxy (exposed as NodePort 30800)
  - `8001`: Admin API (exposed as NodePort 30801)
  - `8002`: Admin GUI (exposed as NodePort 30802)

### 2. Kong Configuration (`08-kong-config.yaml`)
- **ConfigMap**: chứa file `kong.yml` với declarative config
- **Service**: user-service
- **Route**: `/api` → user-service
- **Plugins**:
  - Rate Limiting: 100 requests/minute, 1000 requests/hour
  - CORS: cho phép tất cả origins

### 3. User Service Update
- Đổi từ `NodePort` sang `ClusterIP` (chỉ accessible qua Kong)

## Deployment

### Cách 1: Deploy Phase 3 riêng (nếu đã có Phase 2)
```powershell
cd k8s
.\deploy-phase3.ps1
```

### Cách 2: Deploy toàn bộ từ đầu
```powershell
cd k8s
.\deploy.ps1
.\deploy-phase3.ps1
```

## Testing

### 1. Kiểm tra trạng thái
```powershell
# Xem pods
kubectl get pods -n user-system

# Xem services
kubectl get svc -n user-system

# Xem logs Kong
kubectl logs -f -n user-system -l app=kong-gateway
```

### 2. Chạy test script
```powershell
.\test-phase3.ps1
```

### 3. Test thủ công

**Lưu ý**: Trên Windows với Docker Desktop, NodePort có thể không hoạt động trực tiếp. Sử dụng port-forward hoặc script test:

#### Cách 1: Dùng script test (Khuyến nghị)
```powershell
.\test-kong-api.ps1
```

#### Cách 2: Dùng port-forward
```powershell
# Start port-forward
kubectl port-forward -n user-system svc/kong-gateway 30800:8000 30801:8001

# Trong terminal khác, test API
Invoke-WebRequest -Uri http://localhost:30800/api/users -UseBasicParsing
```

#### Cách 3: Test trực tiếp (nếu NodePort hoạt động)
```powershell
# GET all users
Invoke-WebRequest -Uri http://localhost:30800/api/users -UseBasicParsing

# GET user by ID
Invoke-WebRequest -Uri http://localhost:30800/api/users/1 -UseBasicParsing

# Health check
Invoke-WebRequest -Uri http://localhost:30800/api/actuator/health -UseBasicParsing

# POST create user
$body = @{
    username = "testuser"
    email = "test@example.com"
    fullName = "Test User"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:30800/api/users `
  -Method POST `
  -ContentType "application/json" `
  -Body $body `
  -UseBasicParsing
```

#### Test Kong Admin API
```powershell
# Get Kong status
curl http://localhost:30801/status

# List services
curl http://localhost:30801/services

# List routes
curl http://localhost:30801/routes

# List plugins
curl http://localhost:30801/plugins
```

#### Test Rate Limiting
```powershell
# Gửi nhiều requests liên tiếp
for ($i=1; $i -le 150; $i++) {
    curl http://localhost:30800/api/users
    Start-Sleep -Milliseconds 100
}
# Sau 100 requests sẽ nhận 429 Too Many Requests
```

#### Test CORS
```powershell
# OPTIONS request
curl -X OPTIONS http://localhost:30800/api/users `
  -H "Origin: http://localhost:3000" `
  -H "Access-Control-Request-Method: GET" `
  -v
```

## Truy cập Admin GUI

Mở trình duyệt và truy cập:
```
http://localhost:30802
```

**Lưu ý**: Kong Admin GUI có thể không hoạt động với DB-less mode. Sử dụng Admin API thay thế.

## Cấu hình

### Thay đổi Rate Limiting
Sửa file `08-kong-config.yaml`:
```yaml
plugins:
- name: rate-limiting
  config:
    minute: 100      # Số requests/phút
    hour: 1000       # Số requests/giờ
    policy: local    # local hoặc redis
```

Sau đó apply lại:
```powershell
kubectl apply -f 08-kong-config.yaml
kubectl rollout restart deployment/kong-gateway -n user-system
```

### Thay đổi CORS
Sửa file `08-kong-config.yaml`:
```yaml
plugins:
- name: cors
  config:
    origins:
    - "http://localhost:3000"
    - "https://yourdomain.com"
```

### Thêm route mới
Sửa file `08-kong-config.yaml` và thêm vào phần `services`:
```yaml
services:
- name: another-service
  url: http://another-service.user-system.svc.cluster.local:8080
  routes:
  - name: another-service-route
    paths:
    - /api/v2
```

## Troubleshooting

### Kong Gateway không start
```powershell
# Xem logs
kubectl logs -n user-system -l app=kong-gateway

# Xem events
kubectl describe pod -n user-system -l app=kong-gateway

# Kiểm tra config
kubectl get configmap kong-config -n user-system -o yaml
```

### API không accessible qua Kong
1. Kiểm tra Kong pod đang chạy:
   ```powershell
   kubectl get pods -n user-system -l app=kong-gateway
   ```

2. Kiểm tra user-service đang chạy:
   ```powershell
   kubectl get pods -n user-system -l app=user-service
   ```

3. Test từ trong Kong pod:
   ```powershell
   kubectl exec -it -n user-system deployment/kong-gateway -- curl http://user-service.user-system.svc.cluster.local:8080/api/users
   ```

4. Kiểm tra routes trong Kong:
   ```powershell
   curl http://localhost:30801/routes
   ```

### Rate limiting không hoạt động
- Kiểm tra plugin đã được apply:
  ```powershell
  curl http://localhost:30801/plugins
  ```
- Xem logs Kong để debug:
  ```powershell
  kubectl logs -f -n user-system -l app=kong-gateway
  ```

## Next Steps (Phase 4)
- Integrate Keycloak với Kong
- Setup authentication plugin
- Protect endpoints với JWT

## Tài liệu tham khảo
- [Kong Documentation](https://docs.konghq.com/)
- [Kong DB-less Mode](https://docs.konghq.com/gateway/latest/production/deployment-topologies/db-less-and-declarative-config/)
- [Kong Plugins](https://docs.konghq.com/hub/)

# Objective:

Build a hệ thống quản lý danh sách thành viên with cloud native open source stack

# Microservices List:

- user-service: Managing list user

# Cloud native open source stack:

- Architecture: Event-driven microservices, SAGA pattern
- Containerization: Docker
- Orchestration: Kubernetes (K8s)
- Infrastructure IaC: Terraform / Ansible (Optional)
- Service Mesh: Istio
- Monitoring: Prometheus + Grafana (Metrics & Dashboard)
- Logging: EFK Stack (Elasticsearch, Fluentd/Fluentbit, Kibana)
- Identity Provider (IDP): KeyCloak
- CI/CD:
  - Jenkins (CI Pipelines)
  - GitOps: Helm & ArgoCD (CD/Deployment)
- Message Broker: Kafka
- Database: PostgreSQL
- Cache: Redis
- API Gateway: Kong
- Backend: Java Spring Boot
- Build Tool: Maven
- Frontend: Vuejs

---

# KIẾN TRÚC TỔNG THỂ (High-Level Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│                          USERS/CLIENTS                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     API GATEWAY (Kong)                          │
│              + Authentication (Keycloak Integration)            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICE MESH (Istio)                         │
│        Traffic Management | Security | Observability           │
└────────────────────────────┬────────────────────────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ User Service │    │Future Service│    │Future Service│
│ (Spring Boot)│    │              │    │              │
└──────┬───────┘    └──────────────┘    └──────────────┘
       │
       ├─────────► PostgreSQL (Primary DB)
       ├─────────► Redis (Cache)
       └─────────► Kafka (Event Bus)

┌─────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Prometheus + Grafana (Metrics)                                │
│  EFK Stack (Elasticsearch + Fluentd/Fluentbit + Kibana) (Logs) │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              INFRASTRUCTURE & DEPLOYMENT LAYER                  │
├─────────────────────────────────────────────────────────────────┤
│  Kubernetes Cluster (Orchestration)                            │
│  Docker (Containerization)                                     │
│  Terraform/Ansible (IaC - Optional)                            │
│  Jenkins (CI) + Helm + ArgoCD (GitOps CD)                      │
└─────────────────────────────────────────────────────────────────┘
```

---

# LỘ TRÌNH HỌC CLOUD NATIVE - TỪNG PHASE

## PHASE 1: Foundation & Containerization ✅ COMPLETED
**Mục tiêu**: Hiểu về container và Docker, khởi tạo dự án

**Thành phần cần học**:
- Docker fundamentals
- Dockerfile best practices 
- Docker Compose
- Container networking & volumes

**Steps thực hiện**:
1. ✅ Cài đặt Docker Desktop
2. ✅ Tạo Spring Boot user-service cơ bản (CRUD user)
   - Setup Maven project
   - Create User entity, Repository, Service, Controller
   - Configure PostgreSQL connection
3. ✅ Tạo Dockerfile cho user-service
4. ✅ Tạo docker-compose.yml cho local development:
   - user-service
   - PostgreSQL
   - Redis
5. ✅ Build và chạy service trong container
6. ✅ Test API endpoints

**Deliverables**:
- ✅ user-service chạy trong Docker
- ✅ docker-compose.yml hoạt động
- ✅ API CRUD user hoạt động

**How to Run**:
```powershell
# Start services
docker-compose up --build -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

---

## PHASE 2: Kubernetes Basics
**Mục tiêu**: Deploy application lên Kubernetes cluster

**Thành phần cần học**:
- Kubernetes architecture (Pods, Services, Deployments)
- kubectl commands
- ConfigMaps & Secrets
- Persistent Volumes
- Namespaces

**Steps thực hiện**:
1. Cài đặt Minikube hoặc Kind (local K8s cluster)
2. Cài đặt kubectl
3. Tạo K8s manifests:
   - Namespace: `user-system`
   - Deployment: user-service
   - Service: user-service (ClusterIP)
   - ConfigMap: application config
   - Secret: database credentials
   - PVC: PostgreSQL storage
   - Deployment & Service: PostgreSQL
   - Deployment & Service: Redis
4. Deploy lên K8s cluster
5. Test connectivity giữa các pods

**Deliverables**:
- ✅ Application chạy trên K8s
- ✅ Services communicate với nhau  
- ✅ Data persistent qua restarts

**How to Deploy**:
```powershell
# Deploy to Kubernetes
cd k8s
.\deploy.ps1

# Check status
.\status.ps1

# Test API
.\test-k8s.ps1

# Access: http://localhost:30080/api/users
```

---

## PHASE 3: API Gateway & Service Exposure
**Mục tiêu**: Expose services qua API Gateway

**Thành phần cần học**:
- API Gateway pattern
- Kong Gateway
- Ingress Controller
- Routing & Load Balancing

**Steps thực hiện**:
1. ✅ Deploy Kong Gateway lên K8s (DB-less mode)
2. ✅ Configure Kong với declarative config:
   - Tạo Service trong Kong (user-service)
   - Tạo Routes (/api → user-service)
   - Setup rate limiting (100/min, 1000/hour)
   - Setup CORS (allow all origins)
3. ✅ Đổi user-service từ NodePort sang ClusterIP
4. ✅ Test API qua Kong Gateway

**Deliverables**:
- ✅ Kong Gateway đang chạy
- ✅ API accessible từ external qua Kong (port 30800)
- ✅ Rate limiting hoạt động
- ✅ CORS support

**How to Deploy**:
```powershell
# Deploy Phase 3 (sau khi đã deploy Phase 2)
cd k8s
.\deploy-phase3.ps1

# Test
.\test-phase3.ps1

# Access via Kong Gateway
# http://localhost:30800/api/users
```

---

## PHASE 4: Identity & Security (Keycloak)
**Mục tiêu**: Implement authentication & authorization

**Thành phần cần học**:
- OAuth 2.0 & OpenID Connect
- JWT tokens
- Keycloak administration
- Spring Security integration

**Steps thực hiện**:
1. Deploy Keycloak lên K8s
2. Setup Keycloak:
   - Tạo Realm: `user-system`
   - Tạo Client: `user-service`
   - Tạo Roles: `user`, `admin`
   - Tạo test users
3. Integrate Spring Security với Keycloak:
   - Add dependencies
   - Configure security
   - Protect endpoints
4. Configure Kong với Keycloak plugin
5. Test authentication flow

**Deliverables**:
- ✅ Keycloak running
- ✅ JWT authentication hoạt động
- ✅ Role-based access control

---

## PHASE 5: Event-Driven Architecture (Kafka)
**Mục tiêu**: Implement event-driven communication

**Thành phần cần học**:
- Event-driven architecture
- Apache Kafka
- Spring Kafka
- Event sourcing basics

**Steps thực hiện**:
1. Deploy Kafka + Zookeeper lên K8s
2. Tạo Kafka topics:
   - `user.created`
   - `user.updated`
   - `user.deleted`
3. Implement Kafka producers trong user-service:
   - Publish events khi CRUD operations
4. Implement Kafka consumers:
   - Tạo consumer để log events
5. Test event flow

**Deliverables**:
- ✅ Kafka cluster running
- ✅ Events được publish & consume
- ✅ Async communication hoạt động

---

## PHASE 6: Service Mesh (Istio)
**Mục tiêu**: Implement \d traffic management & security

**Thành phần cần học**:
- Service Mesh concept
- Istio architecture (Control plane, Data plane)
- Virtual Services & Destination Rules
- mTLS
- Traffic management

**Steps thực hiện**:
1. Cài đặt Istio lên K8s cluster
2. Enable sidecar injection cho namespace
3. Configure Istio:
   - Gateway
   - VirtualService
   - DestinationRule
4. Enable mTLS
5. Configure traffic policies:
   - Retry logic
   - Circuit breaker
   - Timeout
6. Test traffic management

**Deliverables**:
- ✅ Istio installed và configured
- ✅ mTLS enabled
- ✅ Traffic policies hoạt động

---

## PHASE 7: Monitoring & Metrics (Prometheus + Grafana)
**Mục tiêu**: Monitor application & infrastructure

**Thành phần cần học**:
- Prometheus metrics
- PromQL
- Grafana dashboards
- Spring Boot Actuator
- Service monitoring

**Steps thực hiện**:
1. Deploy Prometheus lên K8s
2. Deploy Grafana lên K8s
3. Configure Spring Boot Actuator:
   - Add micrometer dependencies
   - Expose metrics endpoint
4. Configure Prometheus scraping:
   - ServiceMonitor cho user-service
   - ServiceMonitor cho Kafka
   - ServiceMonitor cho PostgreSQL
5. Tạo Grafana dashboards:
   - JVM metrics
   - API metrics
   - Database metrics
   - Kafka metrics
6. Setup alerts

**Deliverables**:
- ✅ Prometheus collecting metrics
- ✅ Grafana dashboards visualizing data
- ✅ Alerts configured

---

## PHASE 8: Centralized Logging (EFK Stack)
**Mục tiêu**: Centralize và analyze logs

**Thành phần cần học**:
- Elasticsearch
- Fluentd/Fluentbit
- Kibana
- Log aggregation
- Log parsing

**Steps thực hiện**:
1. Deploy Elasticsearch cluster lên K8s
2. Deploy Fluentd/Fluentbit as DaemonSet
3. Deploy Kibana
4. Configure log collection:
   - Application logs
   - Container logs
   - K8s audit logs
5. Configure Spring Boot logging:
   - JSON format logs
   - Structured logging
6. Tạo Kibana dashboards & visualizations
7. Setup log-based alerts

**Deliverables**:
- ✅ EFK stack running
- ✅ Logs được centralized
- ✅ Kibana dashboards created

---

## PHASE 9: CI/CD Pipeline
**Mục tiêu**: Automate build, test, and deployment

**Thành phần cần học**:
- Jenkins pipelines
- Helm charts
- ArgoCD
- GitOps principles

**Steps thực hiện**:
1. Setup Jenkins:
   - Deploy Jenkins lên K8s
   - Install plugins
2. Tạo Jenkins Pipeline:
   - Checkout code
   - Maven build
   - Unit tests
   - Docker build & push
   - Update Helm values
3. Tạo Helm Chart cho user-service:
   - Templates cho Deployment, Service, ConfigMap, etc.
   - values.yaml
4. Deploy ArgoCD lên K8s
5. Configure ArgoCD:
   - Connect Git repository
   - Create Application
   - Setup auto-sync
6. Test full CI/CD flow

**Deliverables**:
- ✅ Jenkins pipeline hoạt động
- ✅ Helm charts created
- ✅ ArgoCD auto-deploy
- ✅ GitOps workflow implemented

---

## PHASE 10: Infrastructure as Code (Optional)
**Mục tiêu**: Manage infrastructure declaratively

**Thành phần cần học**:
- Terraform basics
- Ansible basics
- Infrastructure provisioning
- Configuration management

**Steps thực hiện**:
1. Tạo Terraform modules:
   - K8s cluster provisioning (if using cloud)
   - Network configuration
   - Storage configuration
2. Hoặc tạo Ansible playbooks:
   - K8s setup
   - Tool installation
3. Version control infrastructure code
4. Test provisioning

**Deliverables**:
- ✅ Infrastructure as code
- ✅ Reproducible environment
- ✅ Documented IaC

---

## PHASE 11: Frontend Integration
**Mục tiêu**: Build Vue.js frontend và integrate với backend

**Thành phần cần học**:
- Vue.js basics
- API integration
- Keycloak JavaScript adapter
- Docker cho frontend

**Steps thực hiện**:
1. Tạo Vue.js project
2. Implement user management UI:
   - User list
   - Create user form
   - Update user form
   - Delete user
3. Integrate với Keycloak:
   - Login/Logout
   - Token management
4. Connect với backend API (qua Kong)
5. Dockerize frontend
6. Deploy lên K8s
7. Setup Ingress cho frontend

**Deliverables**:
- ✅ Vue.js app running
- ✅ Authentication hoạt động
- ✅ Full CRUD từ UI
- ✅ Deployed on K8s

---

# SUMMARY CHECKLIST

## Core Components Status
- [x] Docker & Containerization ✅
- [x] Kubernetes Cluster ✅
- [x] User Service (Spring Boot) ✅
- [x] PostgreSQL Database ✅
- [x] Redis Cache ✅
- [x] Kong API Gateway ✅
- [ ] Keycloak IDP
- [ ] Kafka Message Broker
- [ ] Istio Service Mesh
- [ ] Prometheus + Grafana
- [ ] EFK Stack
- [ ] Jenkins CI
- [ ] Helm + ArgoCD
- [ ] Terraform/Ansible (Optional)
- [ ] Vue.js Frontend

## Skills Gained
- [ ] Container orchestration
- [ ] Microservices architecture
- [ ] Event-driven design
- [ ] Service mesh patterns
- [ ] Observability (monitoring & logging)
- [ ] CI/CD automation
- [ ] GitOps practices
- [ ] Security & identity management
- [ ] Infrastructure as code

---

# NOTES & BEST PRACTICES

1. **Start Simple**: Không cần implement tất cả từ đầu. Đi từng phase.
2. **Document Everything**: Ghi chép lại cấu hình, issues và solutions.
3. **Version Control**: Commit code sau mỗi phase hoàn thành.
4. **Test Incrementally**: Test sau mỗi bước nhỏ, đừng đợi đến cuối.
5. **Resource Management**: Monitor resource usage (CPU, Memory) trên local machine.
6. **Learn by Doing**: Đọc docs và thực hành song song.
7. **Community**: Tham gia communities để hỏi đáp khi gặp vấn đề.

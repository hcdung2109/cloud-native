# Kubernetes Deployment Guide - Phase 2

## 📋 Prerequisites

### 1. **kubectl installed** ✅
```powershell
kubectl version --client
```

### 2. **Kubernetes cluster running**

Choose one option:

#### **Option A: Docker Desktop Kubernetes (Recommended for Windows)**
1. Open Docker Desktop
2. Go to **Settings** → **Kubernetes**
3. Check **Enable Kubernetes**
4. Click **Apply & Restart**
5. Wait for Kubernetes to start (green icon)

#### **Option B: Minikube**
```powershell
# Install Minikube
choco install minikube

# Start cluster
minikube start --driver=docker

# Set context
kubectl config use-context minikube
```

#### **Option C: Kind (Kubernetes in Docker)**
```powershell
# Install Kind
choco install kind

# Create cluster
kind create cluster --name user-system

# Set context
kubectl config use-context kind-user-system
```

---

## 🚀 Quick Start

### 1. **Deploy to Kubernetes**
```powershell
cd k8s
.\deploy.ps1
```

This script will:
- ✅ Build Docker image
- ✅ Apply all K8s manifests
- ✅ Wait for pods to be ready
- ✅ Show deployment status

### 2. **Check Status**
```powershell
.\status.ps1
```

### 3. **Test API**
```powershell
.\test-k8s.ps1
```

### 4. **Access Application**
```
http://localhost:30080/api/users
```

---

## 📁 Kubernetes Manifests

| File | Description |
|------|-------------|
| `00-namespace.yaml` | Creates `user-system` namespace |
| `01-configmap.yaml` | Application configuration (non-sensitive) |
| `02-secret.yaml` | Database credentials (sensitive) |
| `03-postgres-pv.yaml` | Persistent Volume & PVC for PostgreSQL |
| `04-postgres-deployment.yaml` | PostgreSQL Deployment & Service |
| `05-redis-deployment.yaml` | Redis Deployment & Service |
| `06-user-service-deployment.yaml` | User Service Deployment & Service (NodePort) |

---

## 🏗️ Architecture in Kubernetes

```
┌──────────────────────────────────────────────────────┐
│                  user-system Namespace                │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌────────────────┐      ┌────────────────┐         │
│  │  user-service  │      │  user-service  │         │
│  │    (Pod 1)     │      │    (Pod 2)     │         │
│  │   Port: 8080   │      │   Port: 8080   │         │
│  └───────┬────────┘      └───────┬────────┘         │
│          │                       │                   │
│          └───────────┬───────────┘                   │
│                      │                               │
│              ┌───────▼────────┐                      │
│              │  user-service  │                      │
│              │   (Service)    │                      │
│              │ NodePort:30080 │                      │
│              └───────┬────────┘                      │
│                      │                               │
│          ┌───────────┴───────────┐                   │
│          │                       │                   │
│    ┌─────▼──────┐         ┌─────▼──────┐            │
│    │ PostgreSQL │         │   Redis    │            │
│    │  (Pod)     │         │   (Pod)    │            │
│    │ Port: 5432 │         │ Port: 6379 │            │
│    └─────┬──────┘         └────────────┘            │
│          │                                           │
│    ┌─────▼──────┐                                    │
│    │ Postgres   │                                    │
│    │ PVC (5Gi)  │                                    │
│    └────────────┘                                    │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## 🔍 Useful kubectl Commands

### **View Resources**
```powershell
# All resources in namespace
kubectl get all -n user-system

# Pods
kubectl get pods -n user-system
kubectl get pods -n user-system -o wide

# Services
kubectl get svc -n user-system

# Deployments
kubectl get deployments -n user-system

# ConfigMaps and Secrets
kubectl get configmap -n user-system
kubectl get secrets -n user-system

# Persistent Volumes
kubectl get pv
kubectl get pvc -n user-system
```

### **Describe Resources**
```powershell
# Describe pod (detailed info)
kubectl describe pod <pod-name> -n user-system

# Describe service
kubectl describe svc user-service -n user-system
```

### **View Logs**
```powershell
# User service logs (all pods)
kubectl logs -f -n user-system -l app=user-service

# Specific pod logs
kubectl logs -f -n user-system <pod-name>

# Previous pod logs (if crashed)
kubectl logs -p -n user-system <pod-name>

# PostgreSQL logs
kubectl logs -f -n user-system -l app=postgres

# Redis logs
kubectl logs -f -n user-system -l app=redis
```

### **Execute Commands in Pods**
```powershell
# Access PostgreSQL
kubectl exec -it -n user-system <postgres-pod-name> -- psql -U postgres -d cloudnative

# Access Redis
kubectl exec -it -n user-system <redis-pod-name> -- redis-cli

# Shell into pod
kubectl exec -it -n user-system <pod-name> -- /bin/sh
```

### **Port Forwarding**
```powershell
# Forward user-service to localhost:8080
kubectl port-forward -n user-system svc/user-service 8080:8080

# Forward postgres to localhost:5432
kubectl port-forward -n user-system svc/postgres-service 5432:5432

# Access via localhost
curl http://localhost:8080/api/users
```

### **Scale Deployments**
```powershell
# Scale user-service to 3 replicas
kubectl scale deployment user-service -n user-system --replicas=3

# Check replicas
kubectl get deployment user-service -n user-system
```

### **Update Deployments**
```powershell
# Apply changes
kubectl apply -f 06-user-service-deployment.yaml

# Restart deployment (force pod recreation)
kubectl rollout restart deployment/user-service -n user-system

# Check rollout status
kubectl rollout status deployment/user-service -n user-system

# Rollback to previous version
kubectl rollout undo deployment/user-service -n user-system
```

### **Debug Pods**
```powershell
# Get events
kubectl get events -n user-system --sort-by='.lastTimestamp'

# Check pod resource usage
kubectl top pods -n user-system

# Check node resource usage
kubectl top nodes
```

---

## 🧪 Testing Connectivity Between Pods

### **Test from user-service to PostgreSQL**
```powershell
$podName = kubectl get pods -n user-system -l app=user-service -o jsonpath='{.items[0].metadata.name}'
kubectl exec -it -n user-system $podName -- wget -O- postgres-service:5432
```

### **Test from user-service to Redis**
```powershell
$podName = kubectl get pods -n user-system -l app=user-service -o jsonpath='{.items[0].metadata.name}'
kubectl exec -it -n user-system $podName -- wget -O- redis-service:6379
```

### **Verify DNS Resolution**
```powershell
kubectl run -it --rm debug --image=busybox --restart=Never -n user-system -- nslookup postgres-service
kubectl run -it --rm debug --image=busybox --restart=Never -n user-system -- nslookup redis-service
kubectl run -it --rm debug --image=busybox --restart=Never -n user-system -- nslookup user-service
```

---

## 🔧 Troubleshooting

### **Pods not starting?**
```powershell
# Check pod status
kubectl get pods -n user-system

# Describe pod to see events
kubectl describe pod <pod-name> -n user-system

# Check logs
kubectl logs -n user-system <pod-name>
```

### **ImagePullBackOff error?**
```powershell
# Make sure Docker image is built
docker images | findstr user-service

# If using Minikube, load image
minikube image load project7-user-service:latest

# If using Kind, load image
kind load docker-image project7-user-service:latest --name user-system
```

### **CrashLoopBackOff?**
```powershell
# Check logs
kubectl logs -n user-system <pod-name>

# Check previous logs
kubectl logs -p -n user-system <pod-name>

# Check events
kubectl get events -n user-system --sort-by='.lastTimestamp'
```

### **Service not accessible?**
```powershell
# Check service endpoints
kubectl get endpoints -n user-system

# Check if pods are ready
kubectl get pods -n user-system

# Try port-forward
kubectl port-forward -n user-system svc/user-service 8080:8080
```

### **Database connection issues?**
```powershell
# Check if postgres is running
kubectl get pods -n user-system -l app=postgres

# Check postgres logs
kubectl logs -n user-system -l app=postgres

# Verify connectivity
kubectl exec -n user-system <user-service-pod> -- nc -zv postgres-service 5432
```

---

## 🧹 Cleanup

### **Delete everything**
```powershell
cd k8s
.\cleanup.ps1
```

### **Manual cleanup**
```powershell
# Delete namespace (removes all resources)
kubectl delete namespace user-system

# Delete persistent volume
kubectl delete pv postgres-pv
```

---

## 📊 Monitoring & Observability

### **Resource Usage**
```powershell
# Pod resource usage
kubectl top pods -n user-system

# Node resource usage
kubectl top nodes
```

### **Pod Health**
```powershell
# Check pod health status
kubectl get pods -n user-system -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
```

### **Service Endpoints**
```powershell
# Check service endpoints
kubectl get endpoints -n user-system
```

---

## 🎯 Phase 2 Deliverables ✅

- [x] Application deployed on Kubernetes
- [x] Services communicate with each other (ClusterIP)
- [x] Data persists across pod restarts (PVC)
- [x] Health checks configured
- [x] Resource limits set
- [x] Multiple replicas running
- [x] NodePort service for external access

---

## 🚀 Next Steps (Phase 3)

- API Gateway (Kong) deployment
- Ingress Controller
- External access configuration
- Load balancing

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)

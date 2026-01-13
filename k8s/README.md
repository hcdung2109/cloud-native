# Kubernetes Manifests

This directory contains all Kubernetes manifests for deploying the user management system.

## 📁 Files

| File | Description |
|------|-------------|
| `00-namespace.yaml` | Namespace definition |
| `01-configmap.yaml` | Application configuration |
| `02-secret.yaml` | Database credentials |
| `03-postgres-pv.yaml` | PostgreSQL storage (PV & PVC) |
| `04-postgres-deployment.yaml` | PostgreSQL deployment & service |
| `05-redis-deployment.yaml` | Redis deployment & service |
| `06-user-service-deployment.yaml` | User service deployment & service |

## 🚀 Scripts

| Script | Purpose |
|--------|---------|
| `deploy.ps1` | Deploy all resources to K8s |
| `status.ps1` | Check deployment status |
| `test-k8s.ps1` | Test API endpoints |
| `cleanup.ps1` | Delete all resources |

## 📖 Documentation

See `K8S-README.md` in the root directory for complete guide.

## ⚡ Quick Commands

```powershell
# Deploy
.\deploy.ps1

# Check status
.\status.ps1

# Test
.\test-k8s.ps1

# Cleanup
.\cleanup.ps1
```

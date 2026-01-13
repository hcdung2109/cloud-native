# Install Kubernetes Dashboard
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installing Kubernetes Dashboard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Deploy Kubernetes Dashboard
Write-Host "Step 1: Deploying Kubernetes Dashboard..." -ForegroundColor Cyan
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to deploy dashboard" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Dashboard deployed successfully" -ForegroundColor Green

# Step 2: Create admin user
Write-Host ""
Write-Host "Step 2: Creating admin user..." -ForegroundColor Cyan

$adminUserYaml = @"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
"@

$adminUserYaml | kubectl apply -f -

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to create admin user" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Admin user created successfully" -ForegroundColor Green

# Step 3: Get token
Write-Host ""
Write-Host "Step 3: Getting access token..." -ForegroundColor Cyan
Write-Host ""

$token = kubectl -n kubernetes-dashboard create token admin-user

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Access Token (copy this):" -ForegroundColor Yellow
Write-Host $token -ForegroundColor White
Write-Host ""

Write-Host "To access the dashboard:" -ForegroundColor Cyan
Write-Host "1. Run this command in a new terminal:" -ForegroundColor White
Write-Host "   kubectl proxy" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open your browser and go to:" -ForegroundColor White
Write-Host "   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Select 'Token' and paste the token above" -ForegroundColor White
Write-Host ""
Write-Host "To get token again later:" -ForegroundColor Gray
Write-Host "   kubectl -n kubernetes-dashboard create token admin-user" -ForegroundColor Gray

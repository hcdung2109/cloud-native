# Deploy Phase 3: API Gateway & Service Exposure
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Phase 3: Kong API Gateway Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
Write-Host "Checking kubectl..." -ForegroundColor Yellow
try {
    kubectl version --client --short 2>$null | Out-Null
    Write-Host "[OK] kubectl is installed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}

# Check if cluster is running
Write-Host "Checking Kubernetes cluster..." -ForegroundColor Yellow
try {
    kubectl cluster-info | Out-Null
    Write-Host "[OK] Kubernetes cluster is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Kubernetes cluster not available." -ForegroundColor Red
    Write-Host "  Enable Kubernetes in Docker Desktop or start Minikube" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 1: Deploying Kong Gateway..." -ForegroundColor Cyan

$manifests = @(
    "08-kong-config.yaml",
    "07-kong-gateway-deployment.yaml"
)

foreach ($manifest in $manifests) {
    Write-Host "  Applying $manifest..." -ForegroundColor Gray
    kubectl apply -f $manifest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] Failed to apply $manifest" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[OK] Kong Gateway manifests applied successfully" -ForegroundColor Green

Write-Host ""
Write-Host "Step 2: Updating user-service to ClusterIP..." -ForegroundColor Cyan
kubectl apply -f 06-user-service-deployment.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to update user-service" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] User-service updated to ClusterIP" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Waiting for Kong Gateway to be ready..." -ForegroundColor Cyan
Write-Host "  This may take a minute..." -ForegroundColor Gray
Write-Host ""

kubectl wait --for=condition=ready pod -l app=kong-gateway -n user-system --timeout=120s

if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] Kong Gateway pod not ready yet. Checking status..." -ForegroundColor Yellow
    kubectl get pods -n user-system -l app=kong-gateway
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Phase 3 Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Checking pod status:" -ForegroundColor Cyan
kubectl get pods -n user-system

Write-Host ""
Write-Host "Checking services:" -ForegroundColor Cyan
kubectl get svc -n user-system

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Access Information" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Kong Gateway:" -ForegroundColor Yellow
Write-Host "  - Proxy (API):     http://localhost:30800/api/users" -ForegroundColor White
Write-Host "  - Admin API:       http://localhost:30801" -ForegroundColor White
Write-Host "  - Admin GUI:       http://localhost:30802" -ForegroundColor White
Write-Host ""
Write-Host "User Service (via Kong):" -ForegroundColor Yellow
Write-Host "  - GET all users:   http://localhost:30800/api/users" -ForegroundColor White
Write-Host "  - GET user by ID:  http://localhost:30800/api/users/1" -ForegroundColor White
Write-Host "  - Health check:    http://localhost:30800/api/actuator/health" -ForegroundColor White
Write-Host ""
Write-Host "Kong Admin API Examples:" -ForegroundColor Yellow
Write-Host "  - Get services:    curl http://localhost:30801/services" -ForegroundColor Gray
Write-Host "  - Get routes:      curl http://localhost:30801/routes" -ForegroundColor Gray
Write-Host "  - Get plugins:    curl http://localhost:30801/plugins" -ForegroundColor Gray
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Gray
Write-Host "  - Kong logs:      kubectl logs -f -n user-system -l app=kong-gateway" -ForegroundColor Gray
Write-Host "  - Kong status:    kubectl get pods -n user-system -l app=kong-gateway" -ForegroundColor Gray
Write-Host "  - Test API:       .\test-phase3.ps1" -ForegroundColor Gray

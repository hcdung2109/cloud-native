# Deploy to Kubernetes
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploying to Kubernetes" -ForegroundColor Cyan
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
Write-Host "Step 1: Building Docker image..." -ForegroundColor Cyan
cd ..
docker-compose build user-service

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to build Docker image" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Docker image built successfully" -ForegroundColor Green

Write-Host ""
Write-Host "Step 2: Applying Kubernetes manifests..." -ForegroundColor Cyan
cd k8s

$manifests = @(
    "00-namespace.yaml",
    "01-configmap.yaml",
    "02-secret.yaml",
    "03-postgres-pv.yaml",
    "04-postgres-deployment.yaml",
    "05-redis-deployment.yaml",
    "06-user-service-deployment.yaml"
)

foreach ($manifest in $manifests) {
    Write-Host "  Applying $manifest..." -ForegroundColor Gray
    kubectl apply -f $manifest
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] Failed to apply $manifest" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[OK] All manifests applied successfully" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Waiting for deployments to be ready..." -ForegroundColor Cyan
Write-Host "  This may take a few minutes..." -ForegroundColor Gray
Write-Host ""

kubectl wait --for=condition=ready pod -l app=postgres -n user-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis -n user-system --timeout=120s
kubectl wait --for=condition=ready pod -l app=user-service -n user-system --timeout=180s

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Checking pod status:" -ForegroundColor Cyan
kubectl get pods -n user-system

Write-Host ""
Write-Host "Checking services:" -ForegroundColor Cyan
kubectl get svc -n user-system

Write-Host ""
Write-Host "Access the application:" -ForegroundColor Cyan
Write-Host "  - Via NodePort: http://localhost:30080/api/users" -ForegroundColor White
Write-Host "  - Port-forward:  kubectl port-forward -n user-system svc/user-service 8080:8080" -ForegroundColor White

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Gray
Write-Host "  - View logs:     kubectl logs -f -n user-system -l app=user-service" -ForegroundColor Gray
Write-Host "  - Get pods:      kubectl get pods -n user-system" -ForegroundColor Gray
Write-Host "  - Describe pod:  kubectl describe pod [pod-name] -n user-system" -ForegroundColor Gray
Write-Host "  - Delete all:    kubectl delete namespace user-system" -ForegroundColor Gray

# Check Kubernetes deployment status
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Kubernetes Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check namespace
Write-Host "Namespace:" -ForegroundColor Cyan
kubectl get namespace user-system 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Namespace 'user-system' not found" -ForegroundColor Red
    Write-Host "  Run: .\deploy.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n user-system -o wide

Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
kubectl get svc -n user-system

Write-Host ""
Write-Host "Deployments:" -ForegroundColor Cyan
kubectl get deployments -n user-system

Write-Host ""
Write-Host "ConfigMaps:" -ForegroundColor Cyan
kubectl get configmaps -n user-system

Write-Host ""
Write-Host "Secrets:" -ForegroundColor Cyan
kubectl get secrets -n user-system

Write-Host ""
Write-Host "Persistent Volume Claims:" -ForegroundColor Cyan
kubectl get pvc -n user-system

Write-Host ""
Write-Host "Events (last 10):" -ForegroundColor Cyan
kubectl get events -n user-system --sort-by='.lastTimestamp' | Select-Object -Last 10

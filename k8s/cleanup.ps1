# Cleanup Kubernetes resources
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Kubernetes Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will delete all resources in the 'user-system' namespace." -ForegroundColor Yellow
$confirmation = Read-Host "Are you sure? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "Deleting namespace and all resources..." -ForegroundColor Yellow
kubectl delete namespace user-system

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ All resources deleted successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: PersistentVolume may need manual cleanup:" -ForegroundColor Gray
    Write-Host "  kubectl delete pv postgres-pv" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "✗ Failed to delete resources" -ForegroundColor Red
}

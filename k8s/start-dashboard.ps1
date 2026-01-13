# Start Kubernetes Dashboard
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting Kubernetes Dashboard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get token
Write-Host "Getting access token..." -ForegroundColor Yellow
$token = kubectl -n kubernetes-dashboard create token admin-user

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Dashboard not installed yet!" -ForegroundColor Red
    Write-Host "Please run: .\install-dashboard.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Access Token:" -ForegroundColor Green
Write-Host $token -ForegroundColor White
Write-Host ""
Write-Host "Token copied to clipboard!" -ForegroundColor Green
$token | Set-Clipboard

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Starting kubectl proxy..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboard URL:" -ForegroundColor Yellow
Write-Host "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" -ForegroundColor White
Write-Host ""
Write-Host "Opening browser..." -ForegroundColor Gray

# Open browser
Start-Process "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

Write-Host ""
Write-Host "[INFO] Select 'Token' and paste the token (already in clipboard)" -ForegroundColor Cyan
Write-Host "[INFO] Press Ctrl+C to stop the proxy when done" -ForegroundColor Gray
Write-Host ""

# Start proxy (this will block)
kubectl proxy

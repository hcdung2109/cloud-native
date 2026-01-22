# Test Kong API Gateway via Port Forward
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Kong API Gateway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Kong is running
Write-Host "Checking Kong Gateway status..." -ForegroundColor Yellow
$kongPod = kubectl get pods -n user-system -l app=kong-gateway -o jsonpath='{.items[0].metadata.name}' 2>$null
if (-not $kongPod) {
    Write-Host "[ERROR] Kong Gateway pod not found" -ForegroundColor Red
    exit 1
}

$kongStatus = kubectl get pods -n user-system -l app=kong-gateway -o jsonpath='{.items[0].status.phase}' 2>$null
if ($kongStatus -ne "Running") {
    Write-Host "[ERROR] Kong Gateway is not running. Status: $kongStatus" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Kong Gateway is running" -ForegroundColor Green

Write-Host ""
Write-Host "Starting port-forward (Ctrl+C to stop)..." -ForegroundColor Yellow
Write-Host "  Kong Proxy:   http://localhost:30800" -ForegroundColor White
Write-Host "  Kong Admin:   http://localhost:30801" -ForegroundColor White
Write-Host ""

# Start port-forward in background
$job = Start-Job -ScriptBlock {
    kubectl port-forward -n user-system svc/kong-gateway 30800:8000 30801:8001 2>&1 | Out-Null
}

Start-Sleep -Seconds 3

Write-Host "Testing API endpoints..." -ForegroundColor Cyan
Write-Host ""

# Test GET all users
Write-Host "1. Testing GET /api/users..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri http://localhost:30800/api/users -UseBasicParsing -TimeoutSec 10
    Write-Host "   [OK] Status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "   Found $($content.Count) users" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Testing Kong Admin API /status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri http://localhost:30801/status -UseBasicParsing -TimeoutSec 10
    Write-Host "   [OK] Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Testing Kong Admin API /services..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri http://localhost:30801/services -UseBasicParsing -TimeoutSec 10
    Write-Host "   [OK] Status: $($response.StatusCode)" -ForegroundColor Green
    $services = $response.Content | ConvertFrom-Json
    Write-Host "   Found $($services.data.Count) service(s)" -ForegroundColor Gray
} catch {
    Write-Host "   [ERROR] $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Test Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Port-forward is running in background." -ForegroundColor Yellow
Write-Host "To stop port-forward, run: Stop-Job -Id $($job.Id) ; Remove-Job -Id $($job.Id)" -ForegroundColor Gray
Write-Host ""
Write-Host "Manual test commands:" -ForegroundColor Cyan
Write-Host "  Invoke-WebRequest -Uri http://localhost:30800/api/users -UseBasicParsing" -ForegroundColor White
Write-Host "  Invoke-WebRequest -Uri http://localhost:30801/services -UseBasicParsing" -ForegroundColor White

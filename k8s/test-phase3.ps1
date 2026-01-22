# Test Phase 3: Kong API Gateway
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Kong API Gateway" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$kongProxy = "http://localhost:30800"
$kongAdmin = "http://localhost:30801"

Write-Host "Step 1: Checking Kong Gateway status..." -ForegroundColor Yellow
$kongStatus = kubectl get pods -n user-system -l app=kong-gateway -o jsonpath='{.items[0].status.phase}' 2>$null
if ($kongStatus -eq "Running") {
    Write-Host "[OK] Kong Gateway is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Kong Gateway is not running. Status: $kongStatus" -ForegroundColor Red
    Write-Host "  Run: kubectl get pods -n user-system -l app=kong-gateway" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Step 2: Testing Kong Admin API..." -ForegroundColor Yellow
try {
    $adminResponse = Invoke-WebRequest -Uri "$kongAdmin/status" -Method GET -UseBasicParsing -TimeoutSec 5
    if ($adminResponse.StatusCode -eq 200) {
        Write-Host "[OK] Kong Admin API is accessible" -ForegroundColor Green
        Write-Host "  Response: $($adminResponse.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[WARNING] Cannot access Kong Admin API: $_" -ForegroundColor Yellow
    Write-Host "  Make sure port-forward is running or NodePort is accessible" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 3: Testing User Service via Kong Gateway..." -ForegroundColor Yellow

# Test GET all users
Write-Host "  Testing GET /api/users..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "$kongProxy/api/users" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "  [OK] GET /api/users - Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))..." -ForegroundColor Gray
    }
} catch {
    Write-Host "  [ERROR] GET /api/users failed: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "  Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "  Testing GET /api/actuator/health..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "$kongProxy/api/actuator/health" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "  [OK] Health check - Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
    }
} catch {
    Write-Host "  [ERROR] Health check failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 4: Testing CORS..." -ForegroundColor Yellow
try {
    $headers = @{
        "Origin" = "http://localhost:3000"
        "Access-Control-Request-Method" = "GET"
    }
    $response = Invoke-WebRequest -Uri "$kongProxy/api/users" -Method OPTIONS -Headers $headers -UseBasicParsing -TimeoutSec 10
    if ($response.Headers["Access-Control-Allow-Origin"]) {
        Write-Host "  [OK] CORS headers present" -ForegroundColor Green
        Write-Host "  Access-Control-Allow-Origin: $($response.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Gray
    }
} catch {
    Write-Host "  [WARNING] CORS test failed: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 5: Testing Rate Limiting..." -ForegroundColor Yellow
Write-Host "  Sending 5 rapid requests..." -ForegroundColor Gray
$successCount = 0
for ($i = 1; $i -le 5; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "$kongProxy/api/users" -Method GET -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $successCount++
        }
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 429) {
            Write-Host "  [OK] Rate limit triggered on request $i (429 Too Many Requests)" -ForegroundColor Green
        }
    }
    Start-Sleep -Milliseconds 100
}
Write-Host "  Completed $successCount/5 successful requests" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Test Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Manual test commands:" -ForegroundColor Cyan
Write-Host "  curl $kongProxy/api/users" -ForegroundColor White
Write-Host "  curl $kongAdmin/services" -ForegroundColor White
Write-Host "  curl $kongAdmin/routes" -ForegroundColor White

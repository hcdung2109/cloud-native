# Test Kubernetes deployment
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Testing Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get service URL
$nodePort = 30080
$baseUrl = "http://localhost:$nodePort"

Write-Host "Testing API endpoint: $baseUrl/api/users" -ForegroundColor Yellow
Write-Host ""

# Test 1: Health check
Write-Host "Test 1: Health Check" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/actuator/health" -Method GET
    Write-Host "✓ Health check passed" -ForegroundColor Green
    $health | ConvertTo-Json
} catch {
    Write-Host "✗ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Get all users
Write-Host "Test 2: Get All Users" -ForegroundColor Cyan
try {
    $users = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method GET
    Write-Host "✓ Retrieved $($users.Count) users" -ForegroundColor Green
    $users | ConvertTo-Json
} catch {
    Write-Host "✗ Failed to get users: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Create a user
Write-Host "Test 3: Create User" -ForegroundColor Cyan
$newUser = @{
    username = "k8s_test_user"
    email = "k8s@example.com"
    fullName = "Kubernetes Test User"
    phoneNumber = "0999999999"
    active = $true
} | ConvertTo-Json

try {
    $created = Invoke-RestMethod -Uri "$baseUrl/api/users" -Method POST -Body $newUser -ContentType "application/json"
    Write-Host "✓ User created successfully" -ForegroundColor Green
    $created | ConvertTo-Json
    $userId = $created.id
} catch {
    Write-Host "✗ Failed to create user: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Get user by ID
if ($userId) {
    Write-Host "Test 4: Get User by ID" -ForegroundColor Cyan
    try {
        $user = Invoke-RestMethod -Uri "$baseUrl/api/users/$userId" -Method GET
        Write-Host "✓ User retrieved successfully" -ForegroundColor Green
        $user | ConvertTo-Json
    } catch {
        Write-Host "✗ Failed to get user: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Testing Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Check pod logs:" -ForegroundColor Cyan
Write-Host "  kubectl logs -f -n user-system -l app=user-service" -ForegroundColor Gray

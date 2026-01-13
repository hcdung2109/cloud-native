# View logs for User Management System
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Viewing Service Logs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop viewing logs" -ForegroundColor Yellow
Write-Host ""

# Check if a service name is provided
if ($args.Count -gt 0) {
    $serviceName = $args[0]
    Write-Host "Showing logs for: $serviceName" -ForegroundColor Green
    docker-compose logs -f $serviceName
} else {
    Write-Host "Showing logs for all services" -ForegroundColor Green
    Write-Host ""
    Write-Host "Available services:" -ForegroundColor Cyan
    Write-Host "  • user-service" -ForegroundColor White
    Write-Host "  • postgres" -ForegroundColor White
    Write-Host "  • redis" -ForegroundColor White
    Write-Host ""
    Write-Host "To view logs for a specific service, run:" -ForegroundColor Gray
    Write-Host "  .\logs.ps1 <service-name>" -ForegroundColor Gray
    Write-Host ""
    docker-compose logs -f
}

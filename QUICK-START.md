# Quick Start Guide

## 🚀 Start the Application

```powershell
# Start all services
docker-compose up --build -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f user-service
```

## 📊 Sample Users (Auto-Inserted)

After starting, the database will automatically contain these 10 users:

| ID | Username | Email | Password | Active |
|----|----------|-------|----------|--------|
| 1 | admin | admin@cloudnative.com | - | ✅ |
| 2 | john_doe | john.doe@example.com | - | ✅ |
| 3 | jane_smith | jane.smith@example.com | - | ✅ |
| 4 | bob_wilson | bob.wilson@example.com | - | ✅ |
| 5 | alice_johnson | alice.johnson@example.com | - | ✅ |
| 6 | charlie_brown | charlie.brown@example.com | - | ❌ |
| 7 | diana_prince | diana.prince@example.com | - | ✅ |
| 8 | evan_taylor | evan.taylor@example.com | - | ✅ |
| 9 | fiona_green | fiona.green@example.com | - | ✅ |
| 10 | george_miller | george.miller@example.com | - | ❌ |

*Note: Password authentication not implemented in Phase 1*

## 🧪 Test the API

### Get all users:
```powershell
curl http://localhost:8080/api/users
```

### Get user by ID:
```powershell
curl http://localhost:8080/api/users/1
```

### Get user by username:
```powershell
curl http://localhost:8080/api/users/username/admin
```

### Create new user:
```powershell
curl -X POST http://localhost:8080/api/users `
  -H "Content-Type: application/json" `
  -d '{
    "username": "new_user",
    "email": "new@example.com",
    "fullName": "New User",
    "phoneNumber": "0123456789",
    "active": true
  }'
```

### Update user:
```powershell
curl -X PUT http://localhost:8080/api/users/1 `
  -H "Content-Type: application/json" `
  -d '{
    "username": "admin",
    "email": "admin.updated@cloudnative.com",
    "fullName": "System Admin Updated",
    "phoneNumber": "9999999999",
    "active": true
  }'
```

### Delete user:
```powershell
curl -X DELETE http://localhost:8080/api/users/6
```

## 🔌 Connect with Navicat

1. **Create Connection**
   - Connection Name: `CloudNative Local`
   - Host: `localhost`
   - Port: `15432`
   - Database: `cloudnative`
   - Username: `postgres`
   - Password: `postgres`

2. **Test Connection** ✓

3. **View Users Table**
   - Navigate to: **cloudnative** → **public** → **Tables** → **users**
   - Right-click → **Open Table**

## 🗄️ Direct Database Access

```powershell
# Connect to PostgreSQL CLI
docker exec -it user-system-postgres psql -U postgres -d cloudnative

# View all users
SELECT * FROM users;

# Count users
SELECT COUNT(*) FROM users;

# Exit
\q
```

## 📋 View Logs

```powershell
# All services
docker-compose logs -f

# User service only
docker-compose logs -f user-service

# Last 50 lines
docker-compose logs --tail=50 user-service
```

## 🛑 Stop Services

```powershell
# Stop all services
docker-compose down

# Stop and remove data volumes (fresh start)
docker-compose down -v
```

## ✅ Health Check

```powershell
# Check service health
curl http://localhost:8080/actuator/health

# Check all services status
docker-compose ps
```

## 🔄 Reset Everything

```powershell
# Complete reset with fresh sample data
docker-compose down -v
docker-compose up --build -d
```

Wait ~30 seconds, then verify:
```powershell
curl http://localhost:8080/api/users
```

You should see 10 users! 🎉

## 📚 Documentation

- **README.md** - Full project documentation
- **DATABASE-GUIDE.md** - Database operations & SQL queries
- **sample-data.sql** - Manual SQL insert script
- **note.md** - Learning roadmap

## 🆘 Troubleshooting

### Service not starting?
```powershell
docker-compose logs user-service
```

### Database connection error?
```powershell
docker-compose logs postgres
docker exec user-system-postgres pg_isready
```

### Port already in use?
```powershell
netstat -ano | findstr :8080
netstat -ano | findstr :15432
```

### Clear Docker cache and rebuild?
```powershell
docker-compose down -v
docker system prune -f
docker-compose up --build -d
```

## 🎯 Next Steps

- Explore the API endpoints
- View data in Navicat
- Try CRUD operations
- Check Redis cache
- Review Spring Boot logs
- Move to Phase 2 (Kubernetes)

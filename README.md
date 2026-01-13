# User Management System - Phase 1

A cloud-native microservices-based user management system built with Spring Boot, PostgreSQL, and Redis.

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│   User Service      │
│   (Spring Boot)     │
│   Port: 8080        │
└─────┬───────┬───────┘
      │       │
      ▼       ▼
┌──────────┐ ┌────────┐
│PostgreSQL│ │ Redis  │
│Port: 5432│ │Port:   │
└──────────┘ │ 6379   │
             └────────┘
```

## 📦 Components

### User Service
- **Framework**: Spring Boot 3.2.1
- **Java Version**: 17
- **Build Tool**: Maven
- **Features**:
  - RESTful API for user CRUD operations
  - PostgreSQL for persistent storage
  - Redis for caching
  - Input validation
  - Exception handling
  - Health checks & monitoring (Actuator)

### Database (PostgreSQL)
- **Version**: 16-alpine
- **Database**: cloudnative
- **Port**: 15432 (host) → 5432 (container)
- **Credentials**: postgres/postgres

### Cache (Redis)
- **Version**: 7-alpine
- **Port**: 6379
- **Persistence**: AOF (Append Only File)

## 🚀 Getting Started

### Prerequisites

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **PowerShell** (for running scripts)
- Minimum 4GB RAM available for Docker
- Ports 8080, 5432, 6379 available

### Quick Start

1. **Clone or navigate to the project directory**
   ```powershell
   cd "E:\Cloud native\Project7"
   ```

2. **Start all services**
   ```powershell
   docker-compose up --build -d
   ```

3. **Wait for services to be ready** (approximately 30-60 seconds)
   ```powershell
   # Check status
   docker-compose ps
   ```

4. **Test the API**
   ```powershell
   # Check health
   curl http://localhost:8080/actuator/health
   
   # Get all users
   curl http://localhost:8080/api/users
   ```

### Available Scripts

| Script | Description |
|--------|-------------|
| `logs.ps1` | View service logs |

### Start Services

```powershell
# Build and start all services
docker-compose up --build -d

# View status
docker-compose ps
```

### Stop Services

```powershell
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### View Logs

```powershell
# View all logs
.\logs.ps1

# Or use docker-compose directly
docker-compose logs -f

# View specific service logs
.\logs.ps1 user-service
docker-compose logs -f user-service
```

## 📡 API Endpoints

### Base URL
```
http://localhost:8080/api/users
```

### Endpoints

#### 1. Get All Users
```http
GET /api/users
```

**Response:**
```json
[
  {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "phoneNumber": "1234567890",
    "active": true,
    "createdAt": "2024-01-13T10:00:00",
    "updatedAt": "2024-01-13T10:00:00"
  }
]
```

#### 2. Get User by ID
```http
GET /api/users/{id}
```

#### 3. Get User by Username
```http
GET /api/users/username/{username}
```

#### 4. Create User
```http
POST /api/users
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "phoneNumber": "1234567890",
  "active": true
}
```

**Validation Rules:**
- `username`: Required, unique, max 50 characters
- `email`: Required, unique, valid email format, max 100 characters
- `fullName`: Required, max 100 characters
- `phoneNumber`: Optional, max 20 characters
- `active`: Optional, defaults to true

#### 5. Update User
```http
PUT /api/users/{id}
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john.updated@example.com",
  "fullName": "John Doe Updated",
  "phoneNumber": "0987654321",
  "active": true
}
```

#### 6. Delete User
```http
DELETE /api/users/{id}
```

### Health Check
```http
GET /actuator/health
```

### Metrics (Prometheus)
```http
GET /actuator/prometheus
```

## 🔧 Manual Testing with cURL

### Create a user
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "phoneNumber": "1234567890",
    "active": true
  }'
```

### Get all users
```bash
curl http://localhost:8080/api/users
```

### Get user by ID
```bash
curl http://localhost:8080/api/users/1
```

### Update user
```bash
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john.updated@example.com",
    "fullName": "John Doe Updated",
    "phoneNumber": "1111111111",
    "active": true
  }'
```

### Delete user
```bash
curl -X DELETE http://localhost:8080/api/users/1
```

## 🗄️ Database Access

### Using psql
```bash
# From host machine
psql -h localhost -p 15432 -U postgres -d cloudnative

# Or via Docker exec (direct container access)
docker exec -it user-system-postgres psql -U postgres -d cloudnative
```

### Common SQL Commands
```sql
-- List all users
SELECT * FROM users;

-- Count users
SELECT COUNT(*) FROM users;

-- Check user by username
SELECT * FROM users WHERE username = 'john_doe';
```

## 📊 Redis Cache

### Check cache entries
```bash
docker exec -it user-system-redis redis-cli

# Inside redis-cli
KEYS *
GET users::1
TTL users::1
```

## 🐛 Troubleshooting

### Services not starting?

1. **Check Docker is running**
   ```powershell
   docker info
   ```

2. **Check port availability**
   ```powershell
   netstat -ano | findstr :8080
   netstat -ano | findstr :5432
   netstat -ano | findstr :6379
   ```

3. **View logs for errors**
   ```powershell
   .\logs.ps1 user-service
   ```

4. **Restart services**
   ```powershell
   docker-compose down
   docker-compose up --build -d
   ```

### Container keeps restarting?

```powershell
# Check container status
docker-compose ps

# View recent logs
docker-compose logs --tail=50 user-service

# Check health status
docker inspect user-system-service --format='{{.State.Health.Status}}'
```

### Database connection issues?

```powershell
# Verify PostgreSQL is running
docker exec user-system-postgres pg_isready

# Check database exists
docker exec user-system-postgres psql -U postgres -c "\l"
```

### Clear everything and start fresh

```powershell
# Stop and remove all containers, networks, volumes
docker-compose down -v

# Start fresh
docker-compose up --build -d
```

## 📊 Sample Data

The application **automatically inserts 10 sample users** on first startup:
- admin, john_doe, jane_smith, bob_wilson, alice_johnson
- charlie_brown (inactive), diana_prince, evan_taylor, fiona_green, george_miller (inactive)

See `DATABASE-GUIDE.md` for detailed database management instructions.

## 📁 Project Structure

```
Project7/
├── user-service/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/cloudnative/userservice/
│   │   │   │   ├── UserServiceApplication.java
│   │   │   │   ├── controller/
│   │   │   │   │   └── UserController.java
│   │   │   │   ├── entity/
│   │   │   │   │   └── User.java
│   │   │   │   ├── repository/
│   │   │   │   │   └── UserRepository.java
│   │   │   │   ├── service/
│   │   │   │   │   └── UserService.java
│   │   │   │   └── exception/
│   │   │   │       ├── ResourceNotFoundException.java
│   │   │   │       ├── DuplicateResourceException.java
│   │   │   │       └── GlobalExceptionHandler.java
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   ├── Dockerfile
│   ├── .dockerignore
│   └── pom.xml
├── docker-compose.yml
├── init-db.sql
├── logs.ps1
├── README.md
├── .gitignore
└── note.md
```

## ✅ Phase 1 Checklist

- [x] Docker Desktop installed
- [x] Spring Boot user-service created
  - [x] User entity with validation
  - [x] UserRepository (JPA)
  - [x] UserService (business logic)
  - [x] UserController (REST API)
  - [x] Exception handling
  - [x] Redis caching
- [x] PostgreSQL configuration
- [x] Redis integration
- [x] Dockerfile created
- [x] docker-compose.yml created
- [x] Services running in containers
- [x] API endpoints tested
- [x] Docker Compose orchestration configured

## 🎯 Phase 2: Kubernetes Deployment ✅

See `K8S-README.md` for detailed Kubernetes deployment guide.

**Quick Start:**
```powershell
cd k8s
.\deploy.ps1
```

**Access:** http://localhost:30080/api/users

## 🎯 Next Steps (Phase 3)

- [ ] Deploy Kong API Gateway
- [ ] Configure Ingress Controller  
- [ ] Setup routing and load balancing
- [ ] Add rate limiting and CORS

## 📚 Technologies Used

- **Java 17** - Programming language
- **Spring Boot 3.2.1** - Application framework
- **Spring Data JPA** - Data access layer
- **PostgreSQL 16** - Relational database
- **Redis 7** - In-memory cache
- **Maven** - Build tool
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Lombok** - Reduce boilerplate code
- **Spring Boot Actuator** - Monitoring and health checks

## 📝 Notes

- Default credentials are for development only. Change them in production.
- Redis cache TTL is set to 10 minutes
- Database schema is auto-created by Hibernate (ddl-auto: update)
- All services use health checks for proper startup orchestration
- Services are on the same Docker network for internal communication

## 🤝 Contributing

This is a learning project following cloud-native best practices. Feel free to extend it as you progress through the phases!

## 📄 License

This project is for educational purposes.

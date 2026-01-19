# Task Management REST API - Project Plan

**Project Type:** Backend API
**Target:** Node.js REST API with PostgreSQL
**Timeline:** 2 weeks
**Complexity:** Medium

---

## Project Overview

Build a RESTful API for a task management application with user authentication, CRUD operations for tasks, and user management. The API should be production-ready with comprehensive testing and documentation.

## Core Features

### 1. User Authentication
- User registration with email/password
- User login with JWT token generation
- Token-based authentication middleware
- Password hashing with bcrypt
- Session management

### 2. Task Management
- Create tasks with title, description, status, priority, due date
- Read tasks (list all, get by ID, filter by status/priority)
- Update tasks (partial updates supported)
- Delete tasks (soft delete)
- Assign tasks to users
- Mark tasks as complete

### 3. User Management
- User profile CRUD operations
- Change password functionality
- User search and listing
- User roles (admin, member)

## Technical Requirements

### Stack
- **Runtime:** Node.js 18+
- **Framework:** Express.js 4.x
- **Database:** PostgreSQL 14+
- **ORM:** Prisma
- **Authentication:** JWT (jsonwebtoken)
- **Validation:** Joi or Zod
- **Testing:** Jest + Supertest
- **Documentation:** OpenAPI 3.0 (Swagger)

### Architecture
- RESTful API design following best practices
- MVC pattern (Models, Controllers, Routes)
- Service layer for business logic
- Middleware for auth, validation, error handling
- Database migrations with Prisma
- Environment-based configuration

### API Endpoints

**Auth:**
- POST /api/auth/register - Register new user
- POST /api/auth/login - Login user
- POST /api/auth/logout - Logout user
- GET /api/auth/me - Get current user

**Tasks:**
- GET /api/tasks - List tasks (with filtering/pagination)
- POST /api/tasks - Create task
- GET /api/tasks/:id - Get task by ID
- PUT /api/tasks/:id - Update task
- DELETE /api/tasks/:id - Delete task
- PATCH /api/tasks/:id/complete - Mark complete

**Users:**
- GET /api/users - List users (admin only)
- GET /api/users/:id - Get user profile
- PUT /api/users/:id - Update user profile
- DELETE /api/users/:id - Delete user (admin only)

## Quality Requirements

### Testing
- Unit tests for all business logic (>80% coverage)
- Integration tests for API endpoints
- E2E tests for critical flows (auth, task CRUD)
- Test database seeding for consistent testing

### Documentation
- OpenAPI spec with all endpoints documented
- README with setup instructions
- API usage examples
- Database schema documentation

### Security
- Password hashing (bcrypt, salt rounds: 12)
- JWT token expiry (24h access tokens)
- Input validation on all endpoints
- SQL injection prevention (use ORM)
- Rate limiting on auth endpoints
- CORS configuration
- Helmet.js for security headers

### Code Quality
- ESLint configuration
- Prettier for formatting
- TypeScript (optional but recommended)
- Git hooks for linting (husky)
- Consistent error handling
- Logging with appropriate levels

## Database Schema

### Users Table
- id (UUID, primary key)
- email (unique, not null)
- password_hash (not null)
- first_name
- last_name
- role (enum: admin, member)
- created_at
- updated_at

### Tasks Table
- id (UUID, primary key)
- title (not null)
- description (text)
- status (enum: todo, in_progress, done)
- priority (enum: low, medium, high)
- due_date (timestamp)
- assigned_to (UUID, foreign key to users)
- created_by (UUID, foreign key to users)
- created_at
- updated_at
- deleted_at (soft delete)

## Deliverables

1. **Working API** deployed and accessible
2. **PostgreSQL database** with schema and migrations
3. **Test suite** with >80% coverage
4. **API documentation** (OpenAPI/Swagger)
5. **README** with setup and usage instructions
6. **Environment configuration** (.env.example)

## Success Criteria

- [ ] All API endpoints implemented and working
- [ ] User authentication fully functional
- [ ] CRUD operations work correctly
- [ ] All tests passing (>80% coverage)
- [ ] API documentation complete and accurate
- [ ] Security best practices implemented
- [ ] Code is linted and formatted
- [ ] Database migrations work correctly
- [ ] README allows new developer to get started

## Milestones

**Week 1:**
- Database schema and models set up
- User authentication implemented
- Basic task CRUD endpoints working

**Week 2:**
- Advanced features (filtering, assignment)
- Testing complete
- Documentation finished
- Production-ready deployment

---

**Ready for:** `czarina plan 01-rest-api-project.md`

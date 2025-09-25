# Feedback Management System

A comprehensive full-stack feedback management system with role-based access control, analytics dashboard, and responsive design.

## 🚀 Features

### Frontend Features
- **Role-based Authentication**: Customer and Admin roles with JWT-based authentication
- **Customer Dashboard**: Submit, edit, and delete personal feedback
- **Admin Dashboard**: View all feedback, analytics charts, and management tools
- **Interactive Components**: Star ratings, filters, and real-time notifications
- **Responsive Design**: Optimized for mobile, tablet, and desktop devices
- **Professional UI**: Modern design with Tailwind CSS and smooth animations

### Backend Features (API Ready)
- **RESTful APIs**: Complete CRUD operations for users and feedback
- **Authentication**: JWT-based secure authentication system
- **Role-based Access Control**: Different permissions for customers and admins
- **Analytics Endpoint**: Aggregated data for dashboard insights
- **MySQL Integration**: Robust database schema with proper relationships

## 🛠 Tech Stack

### Frontend
- **React 18** with TypeScript
- **Vite** for fast development and building
- **Tailwind CSS** for styling
- **React Router DOM** for client-side routing
- **Chart.js** for analytics visualizations
- **Lucide React** for icons

### Backend
- **Spring Boot** (Java)
- **Spring Security** for authentication
- **Spring Data JPA** for database operations
- **MySQL** database
- **JWT** for token-based authentication

### Deployment
- **GitHub Pages** for frontend hosting
- **Docker** for containerized deployment
- **GitHub Actions** for CI/CD pipeline

## 📁 Project Structure

```
feedback-management-system/
├── src/                          # Frontend React application
│   ├── components/               # Reusable UI components
│   ├── contexts/                 # React contexts (Auth, Toast)
│   ├── pages/                    # Application pages
│   └── main.tsx                  # Application entry point
├── backend/                      # Spring Boot backend
│   ├── src/main/java/com/feedback/
│   │   ├── controller/           # REST controllers
│   │   ├── entity/               # JPA entities
│   │   ├── service/              # Business logic
│   │   └── dto/                  # Data transfer objects
│   └── pom.xml                   # Maven configuration
├── public/                       # Static assets
├── .github/workflows/            # GitHub Actions workflows
├── docker-compose.yml            # Multi-container setup
├── db_init.sql                   # Database initialization
└── README.md                     # Documentation
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v18 or higher)
- Java 11 or higher
- MySQL 8.0
- Docker (optional)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd feedback-management-system
   ```

2. **Frontend Setup**
   ```bash
   npm install
   npm run dev
   ```

3. **Backend Setup**
   ```bash
   cd backend
   # Set up MySQL database using db_init.sql
   # Update application.properties with your database credentials
   mvn spring-boot:run
   ```

4. **Database Setup**
   ```bash
   mysql -u root -p < db_init.sql
   ```

### Docker Deployment

1. **Start all services**
   ```bash
   docker-compose up -d
   ```

2. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080
   - MySQL: localhost:3306

## 🌐 GitHub Pages Deployment

The project is configured for automatic deployment to GitHub Pages:

1. **Push to main/master branch** - GitHub Actions will automatically build and deploy
2. **Access your deployed site** at `https://yourusername.github.io/feedback_management`

### Manual Deployment
```bash
npm run build
npm run deploy
```

## 🎯 Demo Credentials

### Admin Access
- Email: `admin@feedback.com`
- Password: `admin123`

### Customer Access
- Email: Any email address
- Password: `customer123`

## 📱 Usage Guide

### For Customers
1. Sign up or log in with customer credentials
2. Navigate to the feedback page
3. Submit feedback with ratings (1-5 stars) and comments
4. Edit or delete your own feedback
5. View your feedback history

### For Admins
1. Log in with admin credentials
2. Access the admin dashboard
3. View comprehensive analytics and charts
4. Filter feedback by rating or service
5. Manage all feedback entries
6. Monitor system metrics

## 🔧 Configuration

### Frontend Configuration
- **Base URL**: Configure in `vite.config.ts` for GitHub Pages
- **Router**: Basename set to `/feedback_management` for GitHub Pages
- **API Endpoints**: Update in services for backend integration

### Backend Configuration
- **Database**: Configure in `application.properties`
- **JWT Secret**: Update in `application.properties`
- **CORS**: Configure allowed origins in controllers

## 📊 API Endpoints

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User authentication

### Feedback Management
- `GET /api/feedback` - Get all feedback (role-based)
- `POST /api/feedback` - Create new feedback
- `PUT /api/feedback/{id}` - Update feedback
- `DELETE /api/feedback/{id}` - Delete feedback

### Analytics
- `GET /api/analytics` - Get dashboard analytics

## 🔐 Security Features

- JWT-based authentication
- Role-based access control
- Input validation and sanitization
- Secure password handling
- CORS configuration
- SQL injection prevention

## 📈 Performance Features

- Code splitting and lazy loading
- Optimized builds with Vite
- Responsive images and assets
- Database indexing
- Connection pooling
- Caching strategies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

### Common Issues

**Blank page on GitHub Pages refresh**
- Ensure `404.html` is in the `public` directory
- Verify `basename` is set correctly in Router
- Check Vite base configuration

**Backend connection issues**
- Verify MySQL is running and accessible
- Check database credentials in `application.properties`
- Ensure proper CORS configuration

**Build failures**
- Clear node_modules and reinstall dependencies
- Check for TypeScript errors
- Verify all environment variables are set

## 📞 Support

For support and questions, please open an issue in the GitHub repository or contact the development team.

---

Built with ❤️ using React, Spring Boot, and modern web technologies.
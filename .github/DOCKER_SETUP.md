# Docker Hub CI/CD Setup Guide

This guide will help you set up automated Docker image building and pushing to Docker Hub using GitHub Actions.

## 🔧 Prerequisites

1. **Docker Hub Account**: You need a Docker Hub account
2. **GitHub Repository**: Admin access to your GitHub repository
3. **Docker Hub Access Token**: Required for secure authentication

## 🔑 Setting Up Docker Hub Access Token

### Step 1: Create Docker Hub Access Token

1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign in to your account
3. Click on your username in the top right corner
4. Select **"Account Settings"**
5. Go to the **"Security"** tab
6. Click **"New Access Token"**
7. Give it a descriptive name (e.g., "GitHub Actions CI/CD")
8. Set permissions to **"Read, Write, Delete"**
9. Click **"Generate"**
10. **IMPORTANT**: Copy the token immediately - you won't be able to see it again!

### Step 2: Configure GitHub Repository Secrets

1. Go to your GitHub repository
2. Click on **"Settings"** tab
3. In the left sidebar, click **"Secrets and variables"** → **"Actions"**
4. Click **"New repository secret"**
5. Add the following secrets:

#### Required Secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | Used for Docker Hub authentication |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token | Secure token for pushing images |

**Example:**
- Secret Name: `DOCKERHUB_USERNAME`
- Secret Value: `johndoe` (your actual Docker Hub username)

- Secret Name: `DOCKERHUB_TOKEN`
- Secret Value: `dckr_pat_1234567890abcdef...` (your actual access token)

## 🚀 How the Workflow Works

### Trigger Events
The workflow automatically runs on:
- **Push** to `main`, `master`, or `develop` branches
- **Pull Requests** to `main` or `master` branches (build only, no push)
- **Release** publications

### What It Does

1. **Builds Docker Images**: 
   - Frontend (React/Vite app with Nginx)
   - Backend (Spring Boot application)

2. **Multi-Architecture Support**: 
   - Builds for both `linux/amd64` and `linux/arm64`

3. **Smart Tagging**:
   - Branch names (e.g., `main`, `develop`)
   - Pull request numbers (e.g., `pr-123`)
   - Semantic versions for releases (e.g., `v1.2.3`, `1.2`, `1`)
   - `latest` tag for default branch

4. **Security Scanning**: 
   - Runs Trivy vulnerability scans
   - Uploads results to GitHub Security tab

5. **Caching**: 
   - Uses GitHub Actions cache for faster builds

## 📦 Docker Images

After successful builds, your images will be available at:

- **Frontend**: `docker.io/yourusername/yourrepo-frontend:tag`
- **Backend**: `docker.io/yourusername/yourrepo-backend:tag`

### Example Image Names
If your GitHub repository is `johndoe/my-app`, the images will be:
- `johndoe/my-app-frontend:latest`
- `johndoe/my-app-backend:latest`

## 🔄 Using the Images

### Pull and Run Frontend
```bash
docker pull yourusername/yourrepo-frontend:latest
docker run -p 80:80 yourusername/yourrepo-frontend:latest
```

### Pull and Run Backend
```bash
docker pull yourusername/yourrepo-backend:latest
docker run -p 8090:8090 yourusername/yourrepo-backend:latest
```

### Docker Compose Example
```yaml
version: '3.8'
services:
  frontend:
    image: yourusername/yourrepo-frontend:latest
    ports:
      - "3000:80"
  
  backend:
    image: yourusername/yourrepo-backend:latest
    ports:
      - "8090:8090"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
```

## 🛠️ Customization Options

### Modify Trigger Branches
Edit `.github/workflows/docker-build-push.yml`:
```yaml
on:
  push:
    branches: [ main, staging, production ]  # Add your branches
```

### Change Image Names
Edit the environment variables in the workflow:
```yaml
env:
  FRONTEND_IMAGE_NAME: my-custom-frontend-name
  BACKEND_IMAGE_NAME: my-custom-backend-name
```

### Add Environment-Specific Builds
You can create separate workflows for different environments by copying the workflow file and modifying the triggers and image tags.

## 🔍 Monitoring and Troubleshooting

### Check Workflow Status
1. Go to your GitHub repository
2. Click the **"Actions"** tab
3. View the latest workflow runs

### Common Issues

#### 1. Authentication Failed
- **Error**: `unauthorized: authentication required`
- **Solution**: Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are correct

#### 2. Image Not Found
- **Error**: `repository does not exist`
- **Solution**: Make sure the Docker Hub repository exists or enable auto-creation

#### 3. Build Failures
- **Error**: Build step fails
- **Solution**: Check the workflow logs and ensure Dockerfiles are correct

### Viewing Security Scan Results
1. Go to your repository's **"Security"** tab
2. Click **"Code scanning alerts"**
3. Review any vulnerabilities found in your Docker images

## 🎯 Best Practices

1. **Use Specific Tags**: Avoid using `latest` in production
2. **Regular Updates**: Keep base images updated
3. **Security Scanning**: Review and fix security vulnerabilities
4. **Resource Limits**: Set appropriate resource limits in your containers
5. **Environment Variables**: Use secrets for sensitive configuration

## 📞 Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify your Docker Hub credentials
3. Ensure your Dockerfiles build successfully locally
4. Review the workflow file for any syntax errors

Happy deploying! 🚀

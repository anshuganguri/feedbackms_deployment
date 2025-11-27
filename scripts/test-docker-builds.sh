#!/bin/bash

# Test Docker Builds Script
# This script helps you test your Docker builds locally before pushing to GitHub

set -e

echo "🐳 Testing Docker Builds Locally"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running ✓"

# Test Frontend Build
echo ""
print_status "Building Frontend Docker image..."
if docker build -t test-frontend:local ./frontend; then
    print_status "Frontend build successful ✓"
    
    # Test if the image can run
    print_status "Testing Frontend container..."
    CONTAINER_ID=$(docker run -d -p 8080:80 test-frontend:local)
    sleep 3
    
    if curl -f http://localhost:8080 > /dev/null 2>&1; then
        print_status "Frontend container is running and responding ✓"
    else
        print_warning "Frontend container started but may not be responding on port 8080"
    fi
    
    # Cleanup
    docker stop $CONTAINER_ID > /dev/null 2>&1
    docker rm $CONTAINER_ID > /dev/null 2>&1
    print_status "Frontend container cleaned up"
else
    print_error "Frontend build failed ✗"
    exit 1
fi

# Test Backend Build
echo ""
print_status "Building Backend Docker image..."
if docker build -t test-backend:local ./backend; then
    print_status "Backend build successful ✓"
    
    # Test if the image can run (without database for basic test)
    print_status "Testing Backend container..."
    CONTAINER_ID=$(docker run -d -p 8091:8090 -e SPRING_PROFILES_ACTIVE=test test-backend:local)
    sleep 10
    
    if curl -f http://localhost:8091/actuator/health > /dev/null 2>&1 || curl -f http://localhost:8091 > /dev/null 2>&1; then
        print_status "Backend container is running and responding ✓"
    else
        print_warning "Backend container started but may not be responding on port 8091"
        print_warning "This might be expected if the app requires a database connection"
    fi
    
    # Cleanup
    docker stop $CONTAINER_ID > /dev/null 2>&1
    docker rm $CONTAINER_ID > /dev/null 2>&1
    print_status "Backend container cleaned up"
else
    print_error "Backend build failed ✗"
    exit 1
fi

# Image size analysis
echo ""
print_status "Docker Image Sizes:"
echo "==================="
docker images | grep "test-frontend\|test-backend" | head -2

# Cleanup test images
echo ""
print_status "Cleaning up test images..."
docker rmi test-frontend:local test-backend:local > /dev/null 2>&1

echo ""
print_status "🎉 All Docker builds completed successfully!"
print_status "Your images are ready for GitHub Actions deployment."

echo ""
echo "Next steps:"
echo "1. Commit and push your changes to trigger the GitHub Actions workflow"
echo "2. Check the Actions tab in your GitHub repository"
echo "3. Verify images are pushed to Docker Hub"
echo ""
echo "GitHub Actions workflow will be triggered on:"
echo "- Push to main/master/develop branches"
echo "- Pull requests to main/master"
echo "- Release publications"

#!/bin/bash

# Kubernetes Deployment Script for Feedback Management System

set -e

# Default values
BUILD_IMAGES=true
CLEAN_DEPLOY=false
CONTEXT="docker-desktop"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-build) BUILD_IMAGES=false ;;
        --clean) CLEAN_DEPLOY=true ;;
        --context) CONTEXT="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "=================================================="
echo "   KUBERNETES DEPLOYMENT"
echo "   Feedback Management System"
echo "=================================================="
echo "Build Images: $BUILD_IMAGES"
echo "Clean Deploy: $CLEAN_DEPLOY"
echo "Context: $CONTEXT"
echo "Date: $(date)"
echo ""

# Check prerequisites
echo "STEP 1: Checking Prerequisites"
echo "==============================="

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi
echo "✅ kubectl is installed"

# Check Docker
if [ "$BUILD_IMAGES" = true ]; then
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo "❌ Docker is not running"
        exit 1
    fi
    echo "✅ Docker is running"
fi

# Set kubectl context
echo ""
echo "STEP 2: Setting Kubernetes Context"
echo "==================================="
kubectl config use-context "$CONTEXT"
echo "✅ Using context: $CONTEXT"

# Build Docker images
if [ "$BUILD_IMAGES" = true ]; then
    echo ""
    echo "STEP 3: Building Docker Images"
    echo "==============================="
    
    echo "Building backend image..."
    docker build -f Dockerfile.backend -t feedback-backend:latest .
    echo "✅ Backend image built successfully"
    
    echo "Building frontend image..."
    docker build -f Dockerfile.frontend -t feedback-frontend:latest .
    echo "✅ Frontend image built successfully"
fi

# Clean previous deployment
if [ "$CLEAN_DEPLOY" = true ]; then
    echo ""
    echo "STEP 4: Cleaning Previous Deployment"
    echo "====================================="
    kubectl delete namespace feedback-system --ignore-not-found=true
    echo "⏳ Waiting for namespace cleanup..."
    sleep 10
    echo "✅ Previous deployment cleaned"
fi

# Deploy to Kubernetes
echo ""
echo "STEP 5: Deploying to Kubernetes"
echo "==============================="

echo "Creating namespace..."
kubectl apply -f k8s/00-namespace.yaml

echo "Creating MySQL secret..."
kubectl apply -f k8s/01-mysql-secret.yaml

echo "Creating MySQL persistent volume..."
kubectl apply -f k8s/02-mysql-pv.yaml

echo "Deploying MySQL..."
kubectl apply -f k8s/03-mysql-deployment.yaml

echo "Creating backend config..."
kubectl apply -f k8s/04-backend-configmap.yaml

echo "Deploying backend..."
kubectl apply -f k8s/05-backend-deployment.yaml

echo "Creating frontend config..."
kubectl apply -f k8s/06-frontend-configmap.yaml

echo "Deploying frontend..."
kubectl apply -f k8s/07-frontend-deployment.yaml

echo "Creating ingress..."
kubectl apply -f k8s/08-ingress.yaml || echo "⚠️  Failed to create ingress (may not have ingress controller)"

echo "✅ All components deployed successfully"

# Wait for deployments
echo ""
echo "STEP 6: Waiting for Deployments"
echo "==============================="

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n feedback-system || echo "⚠️  MySQL may still be starting"

echo "Waiting for backend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n feedback-system || echo "⚠️  Backend may still be starting"

echo "Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n feedback-system || echo "⚠️  Frontend may still be starting"

# Show deployment status
echo ""
echo "STEP 7: Deployment Status"
echo "=========================="
kubectl get all -n feedback-system

echo ""
echo "Pod Status:"
kubectl get pods -n feedback-system -o wide

echo ""
echo "Service Status:"
kubectl get services -n feedback-system

# Show access information
echo ""
echo "=================================================="
echo "   DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "=================================================="
echo ""
echo "🌐 Access Information:"
echo ""
echo "Frontend (Port Forward): kubectl port-forward service/frontend-service 3000:80 -n feedback-system"
echo "Backend (Port Forward):  kubectl port-forward service/backend-service 8080:9080 -n feedback-system"
echo ""
echo "📋 Useful Commands:"
echo "kubectl get pods -n feedback-system"
echo "kubectl logs -f deployment/backend -n feedback-system"
echo "kubectl logs -f deployment/frontend -n feedback-system"
echo ""
echo "🧹 Cleanup:"
echo "kubectl delete namespace feedback-system"
echo ""

echo "✅ Kubernetes deployment completed successfully!"


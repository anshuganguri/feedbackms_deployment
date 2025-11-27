# Kubernetes Deployment Script for Feedback Management System
param(
    [switch]$BuildImages = $true,
    [switch]$CleanDeploy = $false,
    [string]$Context = "docker-desktop"
)

Write-Host "=================================================="
Write-Host "   KUBERNETES DEPLOYMENT"
Write-Host "   Feedback Management System"
Write-Host "=================================================="
Write-Host "Build Images: $BuildImages"
Write-Host "Clean Deploy: $CleanDeploy"
Write-Host "Context: $Context"
Write-Host "Date: $(Get-Date)"
Write-Host ""

# Check prerequisites
Write-Host "STEP 1: Checking Prerequisites" -ForegroundColor Blue
Write-Host "================================"

# Check kubectl
try {
    kubectl version --client | Out-Null
    Write-Host "✅ kubectl is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl is not installed" -ForegroundColor Red
    exit 1
}

# Check Docker
if ($BuildImages) {
    try {
        docker info | Out-Null
        Write-Host "✅ Docker is running" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker is not running" -ForegroundColor Red
        exit 1
    }
}

# Set kubectl context
Write-Host ""
Write-Host "STEP 2: Setting Kubernetes Context" -ForegroundColor Blue
Write-Host "===================================="
kubectl config use-context $Context
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to set context to $Context" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Using context: $Context" -ForegroundColor Green

# Build Docker images
if ($BuildImages) {
    Write-Host ""
    Write-Host "STEP 3: Building Docker Images" -ForegroundColor Blue
    Write-Host "==============================="
    
    Write-Host "Building backend image..."
    docker build -f Dockerfile.backend -t feedback-backend:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build backend image" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Backend image built successfully" -ForegroundColor Green
    
    Write-Host "Building frontend image..."
    docker build -f Dockerfile.frontend -t feedback-frontend:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to build frontend image" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Frontend image built successfully" -ForegroundColor Green
}

# Clean previous deployment
if ($CleanDeploy) {
    Write-Host ""
    Write-Host "STEP 4: Cleaning Previous Deployment" -ForegroundColor Blue
    Write-Host "====================================="
    kubectl delete namespace feedback-system --ignore-not-found=true
    Write-Host "⏳ Waiting for namespace cleanup..."
    Start-Sleep -Seconds 10
    Write-Host "✅ Previous deployment cleaned" -ForegroundColor Green
}

# Deploy to Kubernetes
Write-Host ""
Write-Host "STEP 5: Deploying to Kubernetes" -ForegroundColor Blue
Write-Host "================================"

Write-Host "Creating namespace..."
kubectl apply -f k8s/00-namespace.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create namespace" -ForegroundColor Red
    exit 1
}

Write-Host "Creating MySQL secret..."
kubectl apply -f k8s/01-mysql-secret.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create MySQL secret" -ForegroundColor Red
    exit 1
}

Write-Host "Creating MySQL persistent volume..."
kubectl apply -f k8s/02-mysql-pv.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create MySQL PV" -ForegroundColor Red
    exit 1
}

Write-Host "Deploying MySQL..."
kubectl apply -f k8s/03-mysql-deployment.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy MySQL" -ForegroundColor Red
    exit 1
}

Write-Host "Creating backend config..."
kubectl apply -f k8s/04-backend-configmap.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create backend config" -ForegroundColor Red
    exit 1
}

Write-Host "Deploying backend..."
kubectl apply -f k8s/05-backend-deployment.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy backend" -ForegroundColor Red
    exit 1
}

Write-Host "Creating frontend config..."
kubectl apply -f k8s/06-frontend-configmap.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create frontend config" -ForegroundColor Red
    exit 1
}

Write-Host "Deploying frontend..."
kubectl apply -f k8s/07-frontend-deployment.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy frontend" -ForegroundColor Red
    exit 1
}

Write-Host "Creating ingress..."
kubectl apply -f k8s/08-ingress.yaml
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Failed to create ingress (may not have ingress controller)" -ForegroundColor Yellow
}

Write-Host "✅ All components deployed successfully" -ForegroundColor Green

# Wait for deployments
Write-Host ""
Write-Host "STEP 6: Waiting for Deployments" -ForegroundColor Blue
Write-Host "==============================="

Write-Host "Waiting for MySQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n feedback-system
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ MySQL is ready" -ForegroundColor Green
} else {
    Write-Host "⚠️  MySQL may still be starting" -ForegroundColor Yellow
}

Write-Host "Waiting for backend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n feedback-system
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend is ready" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend may still be starting" -ForegroundColor Yellow
}

Write-Host "Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n feedback-system
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend is ready" -ForegroundColor Green
} else {
    Write-Host "⚠️  Frontend may still be starting" -ForegroundColor Yellow
}

# Show deployment status
Write-Host ""
Write-Host "STEP 7: Deployment Status" -ForegroundColor Blue
Write-Host "=========================="
kubectl get all -n feedback-system

Write-Host ""
Write-Host "Pod Status:"
kubectl get pods -n feedback-system -o wide

Write-Host ""
Write-Host "Service Status:"
kubectl get services -n feedback-system

# Show access information
Write-Host ""
Write-Host "=================================================="
Write-Host "   DEPLOYMENT COMPLETED SUCCESSFULLY!"
Write-Host "=================================================="
Write-Host ""
Write-Host "🌐 Access Information:" -ForegroundColor Cyan
Write-Host ""

# Get service URLs
$frontendNodePort = kubectl get service frontend-service -n feedback-system -o jsonpath='{.spec.ports[0].nodePort}' 2>$null
$backendNodePort = kubectl get service backend-service -n feedback-system -o jsonpath='{.spec.ports[0].nodePort}' 2>$null

if ($frontendNodePort) {
    Write-Host "Frontend (NodePort): http://localhost:$frontendNodePort"
} else {
    Write-Host "Frontend (Port Forward): kubectl port-forward service/frontend-service 3000:80 -n feedback-system"
}

if ($backendNodePort) {
    Write-Host "Backend (NodePort):  http://localhost:$backendNodePort/backend"
} else {
    Write-Host "Backend (Port Forward):  kubectl port-forward service/backend-service 8080:9080 -n feedback-system"
}

Write-Host ""
Write-Host "📋 Useful Commands:" -ForegroundColor Cyan
Write-Host "kubectl get pods -n feedback-system"
Write-Host "kubectl logs -f deployment/backend -n feedback-system"
Write-Host "kubectl logs -f deployment/frontend -n feedback-system"
Write-Host "kubectl port-forward service/frontend-service 3000:80 -n feedback-system"
Write-Host "kubectl port-forward service/backend-service 8080:9080 -n feedback-system"
Write-Host ""
Write-Host "🧹 Cleanup:" -ForegroundColor Cyan
Write-Host "kubectl delete namespace feedback-system"
Write-Host ""

Write-Host "✅ Kubernetes deployment completed successfully!" -ForegroundColor Green


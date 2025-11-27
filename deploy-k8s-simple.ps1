# Simple Kubernetes Deployment Script
param(
    [switch]$BuildImages = $true,
    [switch]$CleanDeploy = $false
)

Write-Host "=================================================="
Write-Host "   KUBERNETES DEPLOYMENT"
Write-Host "   Feedback Management System"
Write-Host "=================================================="
Write-Host "Build Images: $BuildImages"
Write-Host "Clean Deploy: $CleanDeploy"
Write-Host ""

# Check kubectl
try {
    kubectl version --client | Out-Null
    Write-Host "[OK] kubectl is available" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] kubectl is not installed" -ForegroundColor Red
    exit 1
}

# Check Docker
if ($BuildImages) {
    try {
        docker info | Out-Null
        Write-Host "[OK] Docker is running" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Docker is not running" -ForegroundColor Red
        exit 1
    }
}

# Build images
if ($BuildImages) {
    Write-Host ""
    Write-Host "Building Docker Images..." -ForegroundColor Blue
    
    Write-Host "Building backend image..."
    docker build -f Dockerfile.backend -t feedback-backend:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to build backend image" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Building frontend image..."
    docker build -f Dockerfile.frontend -t feedback-frontend:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to build frontend image" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "[OK] Images built successfully" -ForegroundColor Green
}

# Clean deployment
if ($CleanDeploy) {
    Write-Host ""
    Write-Host "Cleaning previous deployment..." -ForegroundColor Blue
    kubectl delete namespace feedback-system --ignore-not-found=true
    Start-Sleep -Seconds 10
    Write-Host "[OK] Cleanup completed" -ForegroundColor Green
}

# Deploy to Kubernetes
Write-Host ""
Write-Host "Deploying to Kubernetes..." -ForegroundColor Blue

Write-Host "Creating namespace..."
kubectl apply -f k8s/00-namespace.yaml

Write-Host "Creating MySQL secret..."
kubectl apply -f k8s/01-mysql-secret.yaml

Write-Host "Creating MySQL persistent volume..."
kubectl apply -f k8s/02-mysql-pv.yaml

Write-Host "Deploying MySQL..."
kubectl apply -f k8s/03-mysql-deployment.yaml

Write-Host "Creating backend config..."
kubectl apply -f k8s/04-backend-configmap.yaml

Write-Host "Deploying backend..."
kubectl apply -f k8s/05-backend-deployment.yaml

Write-Host "Creating frontend config..."
kubectl apply -f k8s/06-frontend-configmap.yaml

Write-Host "Deploying frontend..."
kubectl apply -f k8s/07-frontend-deployment.yaml

Write-Host "Creating ingress..."
kubectl apply -f k8s/08-ingress.yaml

Write-Host "[OK] All components deployed" -ForegroundColor Green

# Wait for deployments
Write-Host ""
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Blue

Write-Host "Waiting for MySQL..."
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n feedback-system

Write-Host "Waiting for backend..."
kubectl wait --for=condition=available --timeout=300s deployment/backend -n feedback-system

Write-Host "Waiting for frontend..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n feedback-system

# Show status
Write-Host ""
Write-Host "Deployment Status:" -ForegroundColor Blue
kubectl get all -n feedback-system

Write-Host ""
Write-Host "=================================================="
Write-Host "   DEPLOYMENT COMPLETED!"
Write-Host "=================================================="
Write-Host ""
Write-Host "Access your application:" -ForegroundColor Cyan
Write-Host "Frontend: kubectl port-forward service/frontend-service 3000:80 -n feedback-system"
Write-Host "Backend:  kubectl port-forward service/backend-service 8080:9080 -n feedback-system"
Write-Host ""
Write-Host "Then open: http://localhost:3000"
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "kubectl get pods -n feedback-system"
Write-Host "kubectl logs -f deployment/backend -n feedback-system"
Write-Host "kubectl logs -f deployment/frontend -n feedback-system"
Write-Host ""
Write-Host "Cleanup:" -ForegroundColor Cyan
Write-Host "kubectl delete namespace feedback-system"
Write-Host ""


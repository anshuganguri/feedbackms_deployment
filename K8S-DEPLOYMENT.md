# Kubernetes Deployment Guide
## Feedback Management System

This guide provides instructions for deploying the full-stack Feedback Management System to a Kubernetes cluster.

## 📋 Prerequisites

### Required Tools
- **kubectl** - Kubernetes command-line tool
- **Docker** - For building container images
- **Kubernetes Cluster** - One of the following:
  - Docker Desktop with Kubernetes enabled
  - Minikube
  - Kind (Kubernetes in Docker)
  - Cloud provider (GKE, EKS, AKS)
  - On-premises cluster

### Optional Tools
- **Nginx Ingress Controller** - For external access via Ingress
- **cert-manager** - For automatic SSL/TLS certificates

## 🏗️ Architecture

The deployment consists of:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │     MySQL       │
│   (React/Nginx) │◄──►│  (Spring Boot)  │◄──►│   (Database)    │
│                 │    │                 │    │                 │
│ Port: 80        │    │ Port: 9080      │    │ Port: 3306      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ frontend-service│    │ backend-service │    │ mysql-service   │
│ (ClusterIP)     │    │ (ClusterIP)     │    │ (ClusterIP)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲
         │
┌─────────────────┐
│     Ingress     │
│ (External Access)│
└─────────────────┘
```

## 🚀 Quick Start

### 1. Clone and Navigate
```bash
cd D:\deployment
```

### 2. Deploy with PowerShell (Windows)
```powershell
# Build images and deploy
.\deploy-k8s.ps1

# Clean deploy (removes existing deployment first)
.\deploy-k8s.ps1 -CleanDeploy

# Deploy without building images
.\deploy-k8s.ps1 -BuildImages:$false
```

### 3. Deploy with Bash (Linux/macOS)
```bash
# Make script executable
chmod +x deploy-k8s.sh

# Build images and deploy
./deploy-k8s.sh

# Clean deploy
./deploy-k8s.sh --clean

# Deploy without building images
./deploy-k8s.sh --no-build
```

## 📁 Kubernetes Manifests

The `k8s/` directory contains all Kubernetes manifests:

```
k8s/
├── 00-namespace.yaml           # Namespace for the application
├── 01-mysql-secret.yaml        # MySQL credentials (base64 encoded)
├── 02-mysql-pv.yaml           # Persistent Volume for MySQL data
├── 03-mysql-deployment.yaml    # MySQL database deployment & service
├── 04-backend-configmap.yaml   # Backend application configuration
├── 05-backend-deployment.yaml  # Spring Boot backend deployment & service
├── 06-frontend-configmap.yaml  # Frontend Nginx configuration
├── 07-frontend-deployment.yaml # React frontend deployment & service
└── 08-ingress.yaml            # Ingress for external access
```

## 🔧 Manual Deployment

If you prefer to deploy manually:

```bash
# 1. Create namespace
kubectl apply -f k8s/00-namespace.yaml

# 2. Create secrets and configs
kubectl apply -f k8s/01-mysql-secret.yaml
kubectl apply -f k8s/04-backend-configmap.yaml
kubectl apply -f k8s/06-frontend-configmap.yaml

# 3. Create persistent storage
kubectl apply -f k8s/02-mysql-pv.yaml

# 4. Deploy database
kubectl apply -f k8s/03-mysql-deployment.yaml

# 5. Wait for MySQL to be ready
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n feedback-system

# 6. Deploy backend
kubectl apply -f k8s/05-backend-deployment.yaml

# 7. Wait for backend to be ready
kubectl wait --for=condition=available --timeout=300s deployment/backend -n feedback-system

# 8. Deploy frontend
kubectl apply -f k8s/07-frontend-deployment.yaml

# 9. Create ingress (optional)
kubectl apply -f k8s/08-ingress.yaml
```

## 🌐 Accessing the Application

### Option 1: Port Forwarding (Recommended for Development)
```bash
# Access frontend
kubectl port-forward service/frontend-service 3000:80 -n feedback-system

# Access backend API
kubectl port-forward service/backend-service 8080:9080 -n feedback-system
```

Then open:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080/backend

### Option 2: NodePort Services
Modify the services to use `type: NodePort` and access via node IP and assigned port.

### Option 3: Ingress (Requires Ingress Controller)
If you have an Nginx Ingress Controller:
```bash
# Add to /etc/hosts (or equivalent)
echo "127.0.0.1 feedback.local" >> /etc/hosts

# Access via: http://feedback.local
```

## 🔍 Monitoring and Troubleshooting

### Check Deployment Status
```bash
# Overall status
kubectl get all -n feedback-system

# Pod details
kubectl get pods -n feedback-system -o wide

# Service details
kubectl get services -n feedback-system

# Ingress details
kubectl get ingress -n feedback-system
```

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/backend -n feedback-system

# Frontend logs
kubectl logs -f deployment/frontend -n feedback-system

# MySQL logs
kubectl logs -f deployment/mysql -n feedback-system
```

### Debug Pod Issues
```bash
# Describe pod for events
kubectl describe pod <pod-name> -n feedback-system

# Execute into pod
kubectl exec -it <pod-name> -n feedback-system -- /bin/sh

# Check resource usage
kubectl top pods -n feedback-system
```

### Common Issues

#### 1. Images Not Found
If using local images with Minikube:
```bash
# Use Minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild images
docker build -f Dockerfile.backend -t feedback-backend:latest .
docker build -f Dockerfile.frontend -t feedback-frontend:latest .
```

#### 2. Persistent Volume Issues
For local development, ensure the host path exists:
```bash
# Create directory (adjust path as needed)
sudo mkdir -p /mnt/data/mysql
sudo chmod 777 /mnt/data/mysql
```

#### 3. MySQL Connection Issues
Check if MySQL is ready:
```bash
kubectl exec -it deployment/mysql -n feedback-system -- mysql -u root -p
```

## 🔒 Security Considerations

### Production Recommendations

1. **Secrets Management**
   - Use external secret management (HashiCorp Vault, AWS Secrets Manager)
   - Rotate database passwords regularly

2. **Network Policies**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: feedback-network-policy
     namespace: feedback-system
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
     - Egress
   ```

3. **Resource Limits**
   - Set appropriate CPU and memory limits
   - Use Pod Disruption Budgets
   - Configure Horizontal Pod Autoscaler

4. **RBAC**
   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: feedback-service-account
     namespace: feedback-system
   ```

## 📊 Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: feedback-system
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Database Scaling
For production, consider:
- MySQL cluster (Galera, Group Replication)
- Cloud-managed databases (RDS, Cloud SQL)
- Read replicas for read-heavy workloads

## 🧹 Cleanup

### Remove Application
```bash
# Delete namespace (removes all resources)
kubectl delete namespace feedback-system

# Or delete individual components
kubectl delete -f k8s/
```

### Remove Persistent Data
```bash
# Delete persistent volumes
kubectl delete pv mysql-pv

# Clean up host directory (if using hostPath)
sudo rm -rf /mnt/data/mysql
```

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Build and push images
      run: |
        docker build -f Dockerfile.backend -t ${{ secrets.REGISTRY }}/feedback-backend:${{ github.sha }} .
        docker build -f Dockerfile.frontend -t ${{ secrets.REGISTRY }}/feedback-frontend:${{ github.sha }} .
        docker push ${{ secrets.REGISTRY }}/feedback-backend:${{ github.sha }}
        docker push ${{ secrets.REGISTRY }}/feedback-frontend:${{ github.sha }}
    
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/backend backend=${{ secrets.REGISTRY }}/feedback-backend:${{ github.sha }} -n feedback-system
        kubectl set image deployment/frontend frontend=${{ secrets.REGISTRY }}/feedback-frontend:${{ github.sha }} -n feedback-system
```

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager](https://cert-manager.io/)
- [Helm Charts](https://helm.sh/) - For more complex deployments

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review pod logs and events
3. Verify your Kubernetes cluster is healthy
4. Ensure all prerequisites are installed

For development questions, refer to the application documentation in the respective `backend/` and `frontend/` directories.


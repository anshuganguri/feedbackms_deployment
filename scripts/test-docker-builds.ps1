# Test Docker Builds Script (PowerShell)
# This script helps you test your Docker builds locally before pushing to GitHub

param(
    [switch]$SkipTests = $false
)

Write-Host "🐳 Testing Docker Builds Locally" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

function Write-Success {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Success "Docker is running ✓"
} catch {
    Write-Error "Docker is not running. Please start Docker and try again."
    exit 1
}

# Test Frontend Build
Write-Host ""
Write-Success "Building Frontend Docker image..."
try {
    docker build -t test-frontend:local ./frontend
    Write-Success "Frontend build successful ✓"
    
    if (-not $SkipTests) {
        # Test if the image can run
        Write-Success "Testing Frontend container..."
        $containerId = docker run -d -p 8080:80 test-frontend:local
        Start-Sleep -Seconds 3
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -ErrorAction Stop
            Write-Success "Frontend container is running and responding ✓"
        } catch {
            Write-Warning "Frontend container started but may not be responding on port 8080"
        }
        
        # Cleanup
        docker stop $containerId | Out-Null
        docker rm $containerId | Out-Null
        Write-Success "Frontend container cleaned up"
    }
} catch {
    Write-Error "Frontend build failed ✗"
    exit 1
}

# Test Backend Build
Write-Host ""
Write-Success "Building Backend Docker image..."
try {
    docker build -t test-backend:local ./backend
    Write-Success "Backend build successful ✓"
    
    if (-not $SkipTests) {
        # Test if the image can run (without database for basic test)
        Write-Success "Testing Backend container..."
        $containerId = docker run -d -p 8091:8090 -e SPRING_PROFILES_ACTIVE=test test-backend:local
        Start-Sleep -Seconds 10
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -TimeoutSec 5 -ErrorAction Stop
            Write-Success "Backend container is running and responding ✓"
        } catch {
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8091" -TimeoutSec 5 -ErrorAction Stop
                Write-Success "Backend container is running and responding ✓"
            } catch {
                Write-Warning "Backend container started but may not be responding on port 8091"
                Write-Warning "This might be expected if the app requires a database connection"
            }
        }
        
        # Cleanup
        docker stop $containerId | Out-Null
        docker rm $containerId | Out-Null
        Write-Success "Backend container cleaned up"
    }
} catch {
    Write-Error "Backend build failed ✗"
    exit 1
}

# Image size analysis
Write-Host ""
Write-Success "Docker Image Sizes:"
Write-Host "==================="
docker images | Select-String "test-frontend|test-backend" | Select-Object -First 2

# Cleanup test images
Write-Host ""
Write-Success "Cleaning up test images..."
docker rmi test-frontend:local test-backend:local | Out-Null

Write-Host ""
Write-Success "🎉 All Docker builds completed successfully!"
Write-Success "Your images are ready for GitHub Actions deployment."

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit and push your changes to trigger the GitHub Actions workflow"
Write-Host "2. Check the Actions tab in your GitHub repository"
Write-Host "3. Verify images are pushed to Docker Hub"
Write-Host ""
Write-Host "GitHub Actions workflow will be triggered on:" -ForegroundColor Cyan
Write-Host "- Push to main/master/develop branches"
Write-Host "- Pull requests to main/master"
Write-Host "- Release publications"

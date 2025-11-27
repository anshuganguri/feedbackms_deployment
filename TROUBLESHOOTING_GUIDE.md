# 🔧 GitHub Actions Docker CI/CD Troubleshooting Guide

## 🚨 Common Errors and Solutions

### Error 1: "Username and password required"

**Problem**: Docker Hub authentication is failing because secrets are not configured.

**Solution**:
1. **Create Docker Hub Access Token**:
   - Go to [Docker Hub](https://hub.docker.com/)
   - Sign in to your account
   - Click your username → Account Settings
   - Go to Security tab
   - Click "New Access Token"
   - Name it "GitHub Actions CI/CD"
   - Set permissions to "Read, Write, Delete"
   - **COPY THE TOKEN IMMEDIATELY** (you can't see it again!)

2. **Add GitHub Repository Secrets**:
   - Go to your GitHub repository
   - Click Settings tab
   - In left sidebar: Secrets and variables → Actions
   - Click "New repository secret"
   - Add these two secrets:

   | Secret Name | Value |
   |-------------|-------|
   | `DOCKERHUB_USERNAME` | Your Docker Hub username (e.g., `johndoe`) |
   | `DOCKERHUB_TOKEN` | Your Docker Hub access token (starts with `dckr_pat_`) |

### Error 2: "The process '/usr/bin/git' failed with exit code 128"

**Problem**: Git operations are failing due to shallow clone or missing git history.

**Solution**: ✅ **FIXED** - The updated workflow now includes `fetch-depth: 0` to get full git history.

### Error 3: Multi-platform build issues

**Problem**: Building for multiple architectures (ARM64 + AMD64) can be slow or fail.

**Solution**: ✅ **FIXED** - The updated workflow now builds only for `linux/amd64` for faster builds.

## 🔍 How to Verify Your Setup

### Step 1: Check Your Secrets
1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. You should see:
   - ✅ `DOCKERHUB_USERNAME`
   - ✅ `DOCKERHUB_TOKEN`

### Step 2: Test Docker Hub Login Locally
```bash
# Test your credentials locally
docker login
# Enter your Docker Hub username and access token (not password!)
```

### Step 3: Verify Repository Names
Your Docker images will be named:
- `yourusername/yourrepo-frontend:latest`
- `yourusername/yourrepo-backend:latest`

Where:
- `yourusername` = Your Docker Hub username
- `yourrepo` = Your GitHub repository name

## 🚀 What the Fixed Workflow Does

### Key Improvements:
1. **Better Error Messages**: Clear instructions when secrets are missing
2. **Git History**: Full git history with `fetch-depth: 0`
3. **Faster Builds**: Single platform (AMD64) instead of multi-platform
4. **Credential Validation**: Checks secrets before attempting login
5. **Simplified Authentication**: Removed registry parameter that was causing issues

### Workflow Triggers:
- ✅ Push to `main`, `master`, or `develop` branches
- ✅ Pull requests (build only, no push)
- ✅ Release publications

## 📋 Pre-Flight Checklist

Before pushing to GitHub, ensure:

- [ ] Docker Hub account exists
- [ ] Docker Hub access token created
- [ ] `DOCKERHUB_USERNAME` secret added to GitHub
- [ ] `DOCKERHUB_TOKEN` secret added to GitHub
- [ ] Repository name matches expected format
- [ ] Dockerfiles exist in `./frontend/` and `./backend/`

## 🔄 Testing Your Setup

### Option 1: Push to GitHub
```bash
git add .
git commit -m "Fix Docker CI/CD workflow"
git push origin main
```

### Option 2: Test Locally First
```powershell
# Test frontend build
docker build -t test-frontend ./frontend

# Test backend build  
docker build -t test-backend ./backend

# Clean up
docker rmi test-frontend test-backend
```

## 📊 Monitoring Your Workflow

1. **GitHub Actions Tab**: Check workflow status
2. **Actions Logs**: View detailed build logs
3. **Docker Hub**: Verify images are pushed
4. **Security Tab**: Review vulnerability scans (if enabled)

## 🆘 Still Having Issues?

### Check These Common Problems:

1. **Wrong Docker Hub Username**: Must match exactly (case-sensitive)
2. **Expired Access Token**: Create a new one if old
3. **Repository Doesn't Exist**: Docker Hub will auto-create if you have permissions
4. **Network Issues**: GitHub Actions may have temporary connectivity issues
5. **Dockerfile Errors**: Test your Dockerfiles locally first

### Debug Steps:

1. **Check Workflow Logs**:
   - Go to Actions tab in GitHub
   - Click on failed workflow
   - Expand each step to see detailed logs

2. **Verify Secrets**:
   - Settings → Secrets and variables → Actions
   - Secrets should show "Updated X days ago"

3. **Test Docker Hub Access**:
   ```bash
   docker login
   docker push yourusername/test-image:latest
   ```

## 🎯 Success Indicators

When everything works correctly, you'll see:

- ✅ Green checkmarks in GitHub Actions
- ✅ Images appear in your Docker Hub repositories
- ✅ Workflow completes in ~5-10 minutes
- ✅ No authentication errors in logs

## 📞 Need More Help?

If you're still experiencing issues:

1. **Check the workflow logs** for specific error messages
2. **Verify your Docker Hub credentials** by logging in manually
3. **Test your Dockerfiles locally** to ensure they build successfully
4. **Review this guide** to ensure all steps were followed

The updated workflow includes better error messages that will guide you to the exact problem! 🚀

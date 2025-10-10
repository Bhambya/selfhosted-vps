# Renovate Bot Setup for Docker Container Updates

This repository is now configured with Renovate bot to automatically update Docker container versions in your `docker/compose.yml` file.

## What's Configured

### 📋 Files Added
- `renovate.json` - Main Renovate configuration
- `.github/workflows/renovate.yml` - GitHub Actions workflow
- `RENOVATE_SETUP.md` - This setup guide

### 🐳 Docker Services Monitored
The following Docker services will be automatically monitored for updates:

**Critical Services** (updated carefully):
- Redis, PostgreSQL, Traefik, Authelia

**Security Tools**:
- CrowdSec, Traefik CrowdSec Bouncer, WireGuard, Vaultwarden

**Monitoring Tools**:
- Prometheus, Grafana, Node Exporter, cAdvisor, Gatus

**Document Management**:
- Paperless-ngx, Gotenberg, Tika, Stirling PDF, FileBrowser

**Backup & Maintenance**:
- Backrest, Watchtower, Apprise

**Other Services**:
- IT Tools, Linkwarden, Readeck, WhatsApp bot

## 🚀 Setup Instructions

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set expiration and select these scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
4. Copy the generated token

### 2. Add Repository Secret

1. Go to your repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `RENOVATE_TOKEN`
4. Value: Paste your personal access token
5. Click "Add secret"

### 3. Enable GitHub Actions (if not already enabled)

1. Go to your repository → Actions tab
2. If prompted, click "I understand my workflows, go ahead and enable them"

## 📅 Schedule & Behavior

### When Renovate Runs
- **Scheduled**: Every Monday at 6:00 AM UTC
- **Manual**: Can be triggered manually from Actions tab

### Update Grouping
- **Docker images**: Grouped by category (security, monitoring, etc.)
- **Security patches**: Processed immediately when available
- **Major updates**: Require manual review via dependency dashboard

### Pull Request Behavior
- **No auto-merge**: All updates require manual review and approval
- **Labels**: Automatically labeled by category (security, monitoring, etc.)
- **Assignee**: Set to @Bhambya
- **Limit**: Maximum 5 concurrent PRs, 2 per hour

## 🔧 Customization Options

### Modify Update Schedule
Edit `renovate.json` and change the `schedule` field:
```json
"schedule": ["before 6am on monday"]
```

### Enable Auto-merge for Patches
To auto-merge patch updates, modify `renovate.json`:
```json
"patch": {
  "automerge": true
}
```

### Add/Remove Services
Update the `packageRules` section in `renovate.json` to modify which services are grouped together.

## 📊 Monitoring Updates

### Dependency Dashboard
Renovate will create a "Dependency Dashboard" issue in your repository showing:
- Pending updates
- Rate-limited updates  
- Major version updates requiring approval

### Pull Request Format
Each PR will include:
- Changelog links
- Release notes
- Deployment instructions
- Pre-merge checklist

## 🛠️ Deployment Process

When you receive a Renovate PR:

1. **Review the changes** in the PR description
2. **Check release notes** for breaking changes
3. **Test locally** (optional but recommended):
   ```bash
   cd docker
   docker compose pull
   docker compose up -d
   docker compose ps  # Check service health
   ```
4. **Merge the PR** if everything looks good
5. **Deploy to production**:
   ```bash
   git pull origin main
   cd docker
   docker compose pull
   docker compose up -d
   ```

## 🚨 Troubleshooting

### Renovate Not Running
- Check that `RENOVATE_TOKEN` secret is set correctly
- Verify the token has required permissions
- Check GitHub Actions tab for error logs

### Too Many PRs
- Adjust `prConcurrentLimit` in `renovate.json`
- Modify grouping rules to combine more updates

### Missing Updates
- Check if the Docker image name matches the configuration
- Verify the image exists on Docker Hub/registry
- Review Renovate logs in GitHub Actions

## 📚 Additional Resources

- [Renovate Documentation](https://docs.renovatebot.com/)
- [Docker Datasource](https://docs.renovatebot.com/modules/datasource/docker/)
- [Configuration Options](https://docs.renovatebot.com/configuration-options/)

---

🤖 **Renovate is now ready to keep your Docker containers up to date automatically!**

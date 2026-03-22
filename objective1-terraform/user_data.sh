#!/bin/bash
###############################################################
# user_data.sh – Bootstrap script for Amazon Linux 2023
# Installs Nginx and configures /health + /version endpoints
# Templated by Terraform: app_version = ${app_version}
#                         environment = ${environment}
###############################################################
set -euo pipefail

APP_VERSION="${app_version}"
ENVIRONMENT="${environment}"
HOSTNAME_VAL=$(hostname -f)

###############################################################
# 1. System update + Nginx install
###############################################################
dnf update -y
dnf install -y nginx

###############################################################
# 2. Create a minimal web root
###############################################################
WEBROOT="/usr/share/nginx/html"

# Main page
cat > "$WEBROOT/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DevOps Assessment – Web Server</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
    }
    .card {
      background: rgba(255,255,255,0.08);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255,255,255,0.15);
      border-radius: 20px;
      padding: 3rem 4rem;
      text-align: center;
      box-shadow: 0 25px 50px rgba(0,0,0,0.4);
    }
    .badge {
      display: inline-block;
      background: linear-gradient(90deg, #00c6ff, #0072ff);
      border-radius: 999px;
      padding: 6px 18px;
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 2px;
      text-transform: uppercase;
      margin-bottom: 1.5rem;
    }
    h1 { font-size: 2.5rem; font-weight: 800; margin-bottom: 0.5rem; }
    p  { color: rgba(255,255,255,0.65); margin-bottom: 0.3rem; }
    .links { margin-top: 2rem; display: flex; gap: 1rem; justify-content: center; }
    .links a {
      background: rgba(255,255,255,0.12);
      border: 1px solid rgba(255,255,255,0.2);
      color: #fff;
      text-decoration: none;
      padding: 10px 22px;
      border-radius: 10px;
      font-weight: 600;
      transition: background 0.2s;
    }
    .links a:hover { background: rgba(255,255,255,0.22); }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">Live</div>
    <h1>DevOps Assessment</h1>
    <p>Environment: <strong>$ENVIRONMENT</strong></p>
    <p>Version: <strong>v$APP_VERSION</strong></p>
    <p>Host: <strong>$HOSTNAME_VAL</strong></p>
    <div class="links">
      <a href="/health">Health Check</a>
      <a href="/version">Version Info</a>
    </div>
  </div>
</body>
</html>
HTML

###############################################################
# 3. /health endpoint – plain JSON, always 200
###############################################################
mkdir -p "$WEBROOT/health"
cat > "$WEBROOT/health/index.html" <<JSON
{"status":"ok","uptime":"$(awk '{print $1}' /proc/uptime)","timestamp":"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
JSON

###############################################################
# 4. /version endpoint – version metadata as JSON
###############################################################
mkdir -p "$WEBROOT/version"
cat > "$WEBROOT/version/index.html" <<JSON
{
  "version": "$APP_VERSION",
  "environment": "$ENVIRONMENT",
  "server": "nginx",
  "host": "$HOSTNAME_VAL",
  "deployed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

###############################################################
# 5. Nginx config – serve JSON with correct Content-Type
###############################################################
cat > /etc/nginx/conf.d/app.conf <<'NGINX'
server {
    listen       80;
    server_name  _;
    root         /usr/share/nginx/html;
    index        index.html;

    # /health  – return JSON with 200
    location /health {
        default_type application/json;
        try_files /health/index.html =404;
        add_header Cache-Control "no-store";
    }

    # /version – return JSON
    location /version {
        default_type application/json;
        try_files /version/index.html =404;
        add_header Cache-Control "no-store";
    }

    location / {
        try_files $uri $uri/ =404;
    }

    # Hide nginx version
    server_tokens off;
}
NGINX

# Remove default server block shipped with Amazon Linux 2023 nginx package
rm -f /etc/nginx/conf.d/default.conf

###############################################################
# 6. Enable + start Nginx
###############################################################
systemctl enable nginx
systemctl start nginx

echo "Bootstrap complete – Nginx running"

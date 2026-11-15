#!/bin/bash
dnf install -y nginx
echo "Hello from $(hostname)" > /usr/share/nginx/html/index.html
systemctl enable --now nginx
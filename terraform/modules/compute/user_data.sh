#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple index.html
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Coalfire Assessment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .container { max-width: 800px; margin: 0 auto; }
        h1 { color: #333; }
        .info { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Coalfire SRE Assessment - Web Server</h1>
        <div class="info">
            <p><strong>Server Status:</strong> Running</p>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Instance ID:</strong> $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
            <p><strong>Availability Zone:</strong> $(ec2-metadata --availability-zone | cut -d " " -f 2)</p>
            <p><strong>Port:</strong> ${app_port}</p>
        </div>
        <hr>
        <p><small>Last updated: $(date)</small></p>
    </div>
</body>
</html>
EOF

# Configure Apache to listen on custom port if needed (optional)
# sed -i 's/Listen 80/Listen ${app_port}/' /etc/httpd/conf/httpd.conf

# Restart Apache with new configuration
systemctl restart httpd

echo "Apache installation and configuration completed"

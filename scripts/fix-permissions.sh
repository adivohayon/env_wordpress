
chown www-data -R /data #grant write permissions to data directory

useradd staff -g www-data
usermod -aG www-data staff
chown staff:www-data -R /app/wp-content/*

mkdir -p /app/wp-content/uploads/
chown www-data:www-data -R /app/wp-content/uploads/
find /app -type d -exec chmod 755 {} \;  # Change directory permissions rwxr-xr-x
find /app -type f -exec chmod 644 {} \;  # Change file permissions rw-r--r--
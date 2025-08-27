FROM richarvey/nginx-php-fpm:latest

# Copy the application code
COPY . /var/www/html

# Copy nginx configuration
COPY nginx/default.conf /etc/nginx/sites-enabled/default

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Create directory for CA certificate
RUN mkdir -p /etc/ssl/certs

# Copy CA certificate (you'll need to download it from Aiven)
# Download from: https://aiven.io/docs/products/mysql/howto/connect-with-ssl
COPY ca-cert.pem /etc/ssl/certs/ca-cert.pem

# Expose port 80
EXPOSE 80

# Start nginx and php-fpm
CMD ["sh", "-c", "chmod +x deploy.sh && ./deploy.sh && /start.sh"]
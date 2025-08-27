FROM richarvey/nginx-php-fpm:latest

# Copy the application code
COPY . /var/www/html

# Copy nginx configuration
COPY nginx/default.conf /etc/nginx/sites-enabled/default

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Start nginx and php-fpm
CMD ["sh", "-c", "chmod +x deploy.sh && ./deploy.sh && /start.sh"]
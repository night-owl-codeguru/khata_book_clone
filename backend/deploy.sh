#!/usr/bin/env bash

echo "Initializing database schema..."
php init_db.php

echo "Running database migration..."
php migrate.php

echo "Deployment completed successfully!"
#!/usr/bin/env sh
echo "Running db export"
cd /app && bundle exec rake db_export:create
echo "Finished db export"

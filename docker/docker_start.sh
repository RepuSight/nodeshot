#!/bin/bash

set -x 

redis-server &
sleep 3

if [ ! -f /app/first_start ]; then
    python manage.py migrate --noinput --no-initial-data
    python manage.py loaddata initial_data
    python manage.py collectstatic --noinput
    echo "from nodeshot.community.profiles.models import Profile;\
       Profile.objects.create_superuser('admin', '', 'admin')" | ./manage.py shell
    touch /app/first_start
fi

uwsgi --http 0.0.0.0:3031 --chdir /app --static-map /static=/app/static/ \
    --wsgi-file wsgi.py --master --processes 4 --threads 2

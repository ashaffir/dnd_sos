##  References

### Signals
https://www.youtube.com/watch?v=Kc1Q_ayAeQk
https://www.youtube.com/watch?v=T6PyDm79PFo&t=170s

https://docs.djangoproject.com/en/3.0/topics/signals/
https://stackoverflow.com/questions/46614541/using-django-signals-in-channels-consumer-classes

### Channels
https://channels.readthedocs.io/en/latest/tutorial/index.html

Async-sync shit: https://docs.djangoproject.com/en/3.0/topics/async/


### TikTok/Notifiers 
* https://www.youtube.com/watch?v=G_EM5WM_08Q
* https://github.com/arocks/channels-example

### Channels - Chat Tutorial (not used)
https://www.youtube.com/watch?v=RVH05S1qab8

### Taxi App:
https://testdriven.io/courses/real-time-app-with-django-channels-and-angular/part-one-websockets/

### Literature
https://itnext.io/heroku-chatbot-with-celery-websockets-and-redis-340fcd160f06

### Datatables
https://www.youtube.com/watch?v=9S7OFBY9atM
https://datatables.net/

### Modals and Javascript
https://www.youtube.com/watch?v=IIvA-zT8gbA

### ArrayField
https://docs.djangoproject.com/en/3.0/ref/contrib/postgres/fields/

### Built in templates (value|slugify)
https://docs.djangoproject.com/en/3.0/ref/templates/builtins/

### QR Code
https://github.com/dprog-philippe-docourt/django-qr-code

### Model query with date time conditions
https://stackoverflow.com/questions/1317714/how-can-i-filter-a-date-of-a-datetimefield-in-django

### Passwords
https://www.youtube.com/watch?v=qjlZWBbX7-o

### GEO Location:
#### In the chat/templates/room.html
* Get location of the browser/device: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API


## Production Notes

### Server setup: https://www.youtube.com/watch?v=EdK15Qcc3Zs
1) Sources (Git)
2) Supervisor
3) Gunicorn
4) Daphne (https://github.com/django/daphne)
5) Nginx
6) Redis (https://tinyurl.com/y8j73zcg)
7) Postgres


### Websockets issues on production
- https://tinyurl.com/y9oxq4xy (changes added to the .asgi file in the project directory)

### GEO (https://tinyurl.com/y8hegdk8)
* Install GDAL 
** https://tinyurl.com/y7t4aau6, or https://tinyurl.com/y7t4aau6 - on MAC
** https://tinyurl.com/y783ef6b - UNIX (Notice the GDAL version, might not suit the local one)

And, if/when errors in pip install for GDAL...

sudo apt-get install gcc libpq-dev -y
sudo apt-get install python-dev  python-pip -y
sudo apt-get install python3-dev python3-pip python3-venv python3-wheel -y
pip3 install wheel
sudo apt-get install postgresql-10-postgis-scripts

*** brew switch openssl 1.0.2s  - solution to openssl issue after installing GDAL
*** Error in POSTGRES about extension GIS: https://tinyurl.com/yafufges
--
$ psql <db name>
> CREATE EXTENSION postgis;
--
Notice the changes in the DB Engine in settings, to GIS 
--

#### OpenStreet Shape files and other maps downloads: 
http://download.geofabrik.de/

#### To load a shape (*.shp) file for a city/location if NOT using the Open Source Maps API:
ogr2ogr -f "PostgreSQL" PG:"dbname=dndsos user=alfreds" geo/maps/natural_earth_vector/10m_cultural/ne_10m_airports.shp -nln geo_city -append

#### Load initial GIS data to the DB (e.g. businesses) and "Make a Location-Based Web App With Django and GeoDjango": 
https://tinyurl.com/y9rdrqce

** Implemented in different migrations files, e.g. geo/migrations/0002_init_data.py

#### GEOPY for locating coords and addresses (used in e.g order_location) and distances
https://pypi.org/project/geopy/ 





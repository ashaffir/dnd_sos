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
### GEO (https://tinyurl.com/y8hegdk8)
* Install GDAL
** https://pypi.org/project/GDAL/ - UNIX (Notice the GDAL version, might not suit the local one)
** https://tinyurl.com/y7t4aau6 - MAC installation
*** brew switch openssl 1.0.2s  - solution to openssl issue after installing GDAL
*** Error in POSTGRES about extension GIS: https://tinyurl.com/yafufges
--
$ psql <db name>
> CREATE EXTENSION postgis;
--
Notice the changes in the DB Engine in settings, to GIS 
--
#### To load a shape (*.shp) file for a city/location:
ogr2ogr -f "PostgreSQL" PG:"dbname=dndsos user=alfreds" geo/maps/natural_earth_vector/10m_cultural/ne_10m_airports.shp -nln geo_city -append



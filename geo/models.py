from django.db import models
from django.contrib.gis.db import models as geomodels
from django.contrib.gis.db.models import PointField
from django.contrib.postgres.fields import JSONField

from core.models import User, Employee, Employer

class FreelancerLocation(models.Model):
    '''
    Saving all Freelancer's locaitons for mornitorung and statistics
    locaiton = {
        time: datetime
        lat: float
        lon: float
    } 
    '''
    freelancer = models.OneToOneField(User, blank=True, null=True, on_delete=models.CASCADE)
    location = JSONField()


class City(models.Model):
    name = models.CharField(max_length=100, blank=False)
    geometry = geomodels.PointField()

    class Meta:
        # order of drop-down list items
        ordering = ('name',)

        # plural form in admin view
        verbose_name_plural = 'cities'

class Country(models.Model):
    name = models.CharField(max_length=100, blank=False)
    geometry = geomodels.PointField()

    class Meta:
        # order of drop-down list items
        ordering = ('name',)

        # plural form in admin view
        verbose_name_plural = 'countries'


class CityModel(models.Model):
    name = models.CharField(max_length=100)
    city_symbol = models.IntegerField()
    hebrew_name = models.CharField(max_length=100)

    class Meta:
        verbose_name_plural = 'City Models'
    
    def __str__(self):
        return self.hebrew_name

class Street(models.Model):
    country = models.CharField(max_length=100)
    street_id = models.IntegerField()
    city_name = models.CharField(max_length=100)
    city_symbol = models.IntegerField()
    street_name = models.CharField(max_length=100)
    street_symbol = models.IntegerField()

    class Meta:
        verbose_name_plural = 'Streets'
    
    def __str__(self):
        return f"City: {self.city_name} | Street: {self.street_name}"


# Reference: https://www.youtube.com/watch?v=aEivCtavw-I , https://tinyurl.com/y6w37ykr = PDF
class Entry(models.Model):
    point = PointField()
    description = models.CharField(max_length=200, null=True, blank=True)

    @property
    def lat_lng(self):
        return list(getattr(self.point, 'coords', [])[::-1])

# Reference: https://realpython.com/location-based-app-with-geodjango-tutorial/#adding-a-super-user
class BusinessLocation(geomodels.Model):
    # business = models.OneToOneField(Employee, on_delete=models.CASCADE, primary_key=True)
    name = models.CharField(max_length=100)
    location = geomodels.PointField()
    address = models.CharField(max_length=100)
    city = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class UserLocation(geomodels.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE,null=True)
    user_location = geomodels.PointField()

    # def __str__(self):
    #     return self.user_id
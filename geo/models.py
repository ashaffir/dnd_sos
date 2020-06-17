from django.db import models
from django.contrib.gis.db import models as geomodels
from django.contrib.gis.db.models import PointField


class City(models.Model):
    name = models.CharField(max_length=100, blank=False)
    geometry = geomodels.PointField()

    class Meta:
        # order of drop-down list items
        ordering = ('name',)

        # plural form in admin view
        verbose_name_plural = 'cities'


# Reference: https://www.youtube.com/watch?v=aEivCtavw-I , https://tinyurl.com/y6w37ykr = PDF
class Entry(models.Model):
    point = PointField()

    @property
    def lat_lng(self):
        return list(getattr(self.point, 'coords', [])[::-1])
let business_lat;
let business_lng;
let business_address;

// Geo locaiton scripts
function geoFindMe() {

    function success(position) {
        business_lat  = position.coords.latitude;
        business_lng = position.coords.longitude;			  
        console.log(`Latitude: ${business_lat} °, Longitude: ${business_lng} °`);
    }
    
    function error() {
        console.log('Unable to retrieve your location');
    }
    
    if(!navigator.geolocation) {
        console.log('Geolocation is not supported by your browser');
    } else {
        navigator.geolocation.getCurrentPosition(success, error);
    }

}
    
// $(window).on('load',geoFindMe);

function initialize() {
    var mapOptions = {
        center: new google.maps.LatLng(-33.8688, 151.2195),
        zoom: 13,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    // Pickup Address
    var map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);
    var input = document.getElementById('searchTextField');
    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.bindTo('bounds', map);

    var infowindow = new google.maps.InfoWindow();
    var marker = new google.maps.Marker({
        map: map
    });


    google.maps.event.addListener(autocomplete, 'place_changed', function () {
        infowindow.close();
        var place = autocomplete.getPlace();

        if (place.geometry.viewport) {
            map.fitBounds(place.geometry.viewport);
        } else {
            map.setCenter(place.geometry.location);
            map.setZoom(17); // Why 17? Because it looks good.
        }


        var address = '';
        if (place.address_components) {
            address = [(place.address_components[0] && place.address_components[0].short_name || ''), (place.address_components[1] && place.address_components[1].short_name || ''), (place.address_components[2] && place.address_components[2].short_name || '')].join(' ');
        }

        console.log(`LAT: ${place.geometry.location.lat()}`);
        console.log(`LNG: ${place.geometry.location.lng()}`);
        business_lat = place.geometry.location.lat();
        business_lng = place.geometry.location.lng();

        business_address = address;

        infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address + "<br>" + place.geometry.location);
        infowindow.open(map, marker);
    });

}
google.maps.event.addDomListener(window, 'load', initialize);

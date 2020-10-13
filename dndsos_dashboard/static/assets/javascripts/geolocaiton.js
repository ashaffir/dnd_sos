let pickup_lat1;
let pickup_lng1;
let pickup_lat;
let pickup_lng;
let dropoff_lat;
let dropoff_lng;
let pickup_address;
let dropoff_address;

let business_lat;
let business_lng;


// Geo locaiton scripts
function geoFindMe() {

    function success(position) {
        pickup_lat1  = position.coords.latitude;
        pickup_lng1 = position.coords.longitude;			  
        console.log(`Latitude: ${pickup_lat1} °, Longitude: ${pickup_lng1} °`);
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
    var map1 = new google.maps.Map(document.getElementById('map_canvas1'),mapOptions);
    var input1 = document.getElementById('searchTextField1');
    var autocomplete1 = new google.maps.places.Autocomplete(input1);
    autocomplete1.bindTo('bounds', map1);

    var infowindow = new google.maps.InfoWindow();
    var marker = new google.maps.Marker({
        map: map1
    });


    google.maps.event.addListener(autocomplete1, 'place_changed', function () {
        infowindow.close();
        var place = autocomplete1.getPlace();

        if (place.geometry.viewport) {
            map1.fitBounds(place.geometry.viewport);
        } else {
            map1.setCenter(place.geometry.location);
            map1.setZoom(17); // Why 17? Because it looks good.
        }


        var address = '';
        if (place.address_components) {
            address = [(place.address_components[0] && place.address_components[0].short_name || ''), (place.address_components[1] && place.address_components[1].short_name || ''), (place.address_components[2] && place.address_components[2].short_name || '')].join(' ');
        }

        console.log(`LAT: ${place.geometry.location.lat()}`);
        console.log(`LNG: ${place.geometry.location.lng()}`);
        pickup_lat = place.geometry.location.lat();
        pickup_lng = place.geometry.location.lng();

        pickup_address = address;

        infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address + "<br>" + place.geometry.location);
        infowindow.open(map1, marker);
    });

    // Dropoff Address
    var map2 = new google.maps.Map(document.getElementById('map_canvas2'),mapOptions);
    var input2 = document.getElementById('searchTextField2');
    var autocomplete2 = new google.maps.places.Autocomplete(input2);
    autocomplete2.bindTo('bounds', map2);

    var infowindow = new google.maps.InfoWindow();
    var marker = new google.maps.Marker({
        map: map2
    });

    google.maps.event.addListener(autocomplete2, 'place_changed', function () {
        infowindow.close();
        var place = autocomplete2.getPlace();

        if (place.geometry.viewport) {
            map2.fitBounds(place.geometry.viewport);
        } else {
            map2.setCenter(place.geometry.location);
            map2.setZoom(17); // Why 17? Because it looks good.
        }


        var address = '';
        if (place.address_components) {
            address = [(place.address_components[0] && place.address_components[0].short_name || ''), (place.address_components[1] && place.address_components[1].short_name || ''), (place.address_components[2] && place.address_components[2].short_name || '')].join(' ');
        }

        dropoff_lat = place.geometry.location.lat();
        dropoff_lng = place.geometry.location.lng();

        console.log(`LAT: ${place.geometry.location.lat()}`);
        console.log(`LNG: ${place.geometry.location.lng()}`);
        console.log(`ADDRESS: ${address}`);

        dropoff_address = address;

        infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address + "<br>" + place.geometry.location);
        infowindow.open(map1, marker);

    });

}
google.maps.event.addDomListener(window, 'load', initialize);

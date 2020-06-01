//Open business socket
console.log('BUSIENSS ORDER WS READY!')
const businessSocket = new WebSocket(
    'ws://'
    + window.location.host
    + '/ws/orders/'

);    

let user_id = "{{ user.pk }}"
let user_username = "{{ user.username }}"
let user_name = "{{ user.employer.business_name }}"
let user_email = "{{ user.email }}"
let street = "{{ user.employer.street }}"
let building = "{{ user.employer.building_number }}"
let city = "{{ user.employer.city }}"
let pick_up_address = building + ' ' + street + ', ' + city

addOrder = function(e) {
    const street_e = document.querySelector('#street');
    const building_e = document.querySelector('#building');
    const city_e = document.querySelector('#city');
    const notes_e = document.querySelector('#notes');

    const street = street_e.value;
    const building = building_e.value;
    const city = city_e.value;
    const notes = notes_e.value;

    const drop_off_address = building + ' ' + street + ', ' + city

    businessSocket.send(JSON.stringify({
        'type': 'create.order', 
        'data': {
            'event': 'Create Order',
            'business': user_id,
            'business_name': user_name,
            'pick_up_address': pick_up_address,
            'drop_off_address': drop_off_address,
            'notes': notes
        }
    }));

    // Reload only the order table.
    $.ajax({
        url: "{% url 'orders:orders-table' %}",
        success: function(response) {
            $('#ordersTable').html(response);
        }
    })		

    $('#modalAddOrder').modal('hide');
                        
};

/*
*/
// Handing the dispatch (pick-up) of an offer
pickedup = function(id,pup,drop) {
    console.log(`PICKED UP!!`)
    let order_id = id;
    let business_id = "{{ user.pk }}";
    current_order_id = order_id
    
    businessSocket.send(JSON.stringify({
        'type': 'update.order', 
        'data': {
            'event': 'Order Picked Up',
            'order_id': order_id,
            'business': business_id,
            'pick_up_address': pup,
            'drop_off_address': drop,
            'status': 'IN_PROGRESS',
            'city': 'cityPlaceHolder-Pickup'
        }
    }));
    
    // Refresh the table to update the dispached/pickedup order
    $.ajax({
        url: "{% url 'orders:orders-table' %}",
        success: function(response) {
            $('#ordersTable').html(response);
        }
    })		
}

// Handling incoming message about new offer
businessSocket.onmessage = function(e) {
    data = JSON.parse(e.data);
    const data_string = JSON.stringify(e.data);
    console.log(`DATA RECEIVED: ${data.data} ORDER ID: ${data.data.order_id} Freelancer: ${data.data.freelancer}`);

    if (data.data.status == 'STARTED'){
        location.reload()
    }
    // Refresh the table to update the accepted order
    $.ajax({
        url: "{% url 'orders:orders-table' %}",
        success: function(response) {
            $('#ordersTable').html(response);
        }
    })		

    // Refresh the alerts table
    $.ajax({
        url: "{% url 'orders:business-alerts-list' %}",
        success: function(response) {
            $('#businessOrdersAlerts').html(response);
        }
    })		

};

request_freelancer = function(order_id, pick_up_address, drop_off_address, notes){
    console.log('REQUESTING FREELANCER...')
    // Broadcast a request for an excisting order
    businessSocket.send(JSON.stringify({
        'type': 'update.order', 
        'data': {
            'event': 'Request Freelancer',
            'order_id': order_id,
            'business': user_id,
            'business_name': user_name,
            'pick_up_address': pick_up_address,
            'drop_off_address': drop_off_address,
            'notes': notes,
            'status': 'RE_REQUESTED'
        }
    }));


}

// Open the Freelancer Socket
console.log('NEW FREELANCER WS')
const freelancerSocket = new WebSocket(
    'ws://'
    + window.location.host
    + '/ws/orders/'
);

let data;
let current_order_id;
let user_id = '{{ user.pk }}'

// Handling incoming message about new offer from business
freelancerSocket.onmessage = function(e) {
    data = JSON.parse(e.data);
    const data_string = JSON.stringify(e.data);
    console.log(`DATA RECEIVED: ${data.data}`);

    //document.querySelector('#chat-log').value += (data.message + '\n');
    const pick_up_address_e = document.querySelector('#pick_up_address');
    const drop_off_address_e = document.querySelector('#drop_off_address');
    const notes_e = document.querySelector('#notes');
    const order_id = data.data.order_id
    const order_status = data.data.status
    const freelancer = data.data.freelancer

    let pick_up_address = data.data.pick_up_address;
    let drop_off_address = data.data.drop_off_address;
    $("#pick_up_address").html(pick_up_address)
    $("#drop_off_address").html(drop_off_address)
    $("#notes").html(data.data.notes)
    
    if (order_status == 'REQUESTED' && current_order_id != order_id) {
        $("#newOfferAlert").modal("show");
    }

    if (order_status == 'RE_REQUESTED' && current_order_id != order_id) {
        $("#newOfferAlert").modal("show");
    }

    current_order_id = order_id

    console.log(`freelancer: ${freelancer}  user_id: ${user_id}`)

    // When freelancer tries to accept an order that was already allocated
    if (order_status == 'STARTED' && data.data.freelancer != user_id){
        $('#offerRemoved').modal("show");
    } else if (order_status == 'IN_PROGRESS' && freelancer == user_id){
        $.ajax({
            url: "{% url 'orders:deliveries-table' %}",
            success: function(response) {
                $('#deliveriesTable').html(response);
            }
        })			
    } else if (order_status == 'ARCHIVED' && freelancer == user_id){
        $('#offerRemoved').modal("show");
        $.ajax({
            url: "{% url 'orders:deliveries-table' %}",
            success: function(response) {
                $('#deliveriesTable').html(response);
            }
        })								
    }

};

// Handing the acceptance of an offer
$("#accept").click( function() {
    $('#newOfferAlert').modal('hide');
    
    let freelancer_id = "{{ user.pk }}"
    let freelancer_username = "{{ user.username }}"
    let freelancer_name = "{{ user.employee.name }}"
    let freelancer_email = "{{ user.email }}"
    let freelancer_phone = "{{ user.employee.phone }}"
    console.log(`ACCEPTED!!  USERNAME: ${freelancer_username}`)
    
    freelancerSocket.send(JSON.stringify({
        'type': 'update.order', 
        'data': {
            'event': 'Order Accepted',
            'order_id': data.data.order_id,
            'freelancer': freelancer_id,
            'pick_up_address': data.data.pick_up_address,
            'drop_off_address': data.data.drop_off_address,
            'status': 'STARTED',
            'city': 'cityPlaceHolder'
        }
    }));

    // Refresh the table to update the accepted order
    $.ajax({
        url: "{% url 'orders:deliveries-table' %}",
        success: function(response) {
            $('#deliveriesTable').html(response);
        }
    })							
})

// Handing the delivery completion
delivered = function(id,pup,drop) {
    console.log(`DELIVERED!!`)
    let order_id_e = document.querySelector("#orderDelivered");
    let order_id = order_id_e.value;
    let freelancer_id = "{{ user.pk }}";
    let pickup_e = document.querySelector(`#pickupAddress_${order_id}`);
    let dropoff_e = document.querySelector(`#dropoffAddress_${order_id}`);

    current_order_id = order_id

    freelancerSocket.send(JSON.stringify({
        'type': 'update.order', 
        'data': {
            'event': 'Order Delivered',
            'order_id': order_id,
            'freelancer': freelancer_id,
            'pick_up_address': pup,
            'drop_off_address': drop,
            'status': 'COMPLETED',
            'city': 'cityPlaceHolder'
        }
    }));

    if (current_order_id != order_id) {
        $("#newOfferAlert").modal("show");
        current_order_id = order_id
    }
    
    // Refresh the table to update the accepted order
    $.ajax({
        url: "{% url 'orders:deliveries-table' %}",
        success: function(response) {
            $('#deliveriesTable').html(response);
        }
    })		
}
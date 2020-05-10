
function createSocket() {
    const orderID = document.getElementById('order_id').value;
    console.log(`ORDER: ${orderID}`)
    const orderSocket = new WebSocket(
        'ws://'
        + window.location.host
        + '/ws/dashboard/order/'
        + orderID
        + '/'

    );    

    const messageInputDom = document.querySelector('#order_comment');
    const message = messageInputDom.value;
    orderSocket.send(JSON.stringify({
        'message': message,
        'type': 'create.order', 
        'order': message
    }));
    messageInputDom.value = '';
    
    orderSocket.onmessage = function(e) {
        const data = JSON.parse(e.data);
        document.querySelector('#chat-log').value += (data.message + '\n');
    };
    
    orderSocket.onclose = function(e) {
        console.error('Chat socket closed unexpectedly');
    };
    
    document.querySelector('#chat-message-input').focus();
    document.querySelector('#chat-message-input').onkeyup = function(e) {
        if (e.keyCode === 13) {  // enter, return
            document.querySelector('#chat-message-submit').click();
        }
    };
    
    document.querySelector('#chat-message-submit').onclick = function(e) {
        const messageInputDom = document.querySelector('#chat-message-input');
        const message = messageInputDom.value;
        orderSocket.send(JSON.stringify({
            'message': message,
            'type': 'create.order', 
            'order': message
        }));
        messageInputDom.value = '';
    };
  }


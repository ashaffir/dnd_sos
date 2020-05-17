document.addEventListener('DOMContentLoaded', function() {
    const webSocketBridge = new channels.WebSocketBridge();
    const nl = document.querySelector("#notifylist");
    webSocketBridge.connect('/ws/freelancer_notifications/order/22/');
    // const orderID = JSON.parse(document.getElementById('order-name').textContent);
    // webSocketBridge.connect('/ws/dashboard/order/');
    console.log(`EMPLOYEE ALERTS SOCKET READY`)

    webSocketBridge.listen(function(action, stream) {
      console.log("RESPONSE:", action);
      if(action.event == "New Order") {
        var el = document.createElement("li");
        el.innerHTML = `New delivery order <b>${action.orderId}</b> was created!`;
        nl.appendChild(el);
        alert(`
        You have received a new delivery offer!!
        From: ${action.business}
        Deliverying: ${action.delivery_type}
        `);

      }  
    })
    document.ws = webSocketBridge; /* for debugging */
  })

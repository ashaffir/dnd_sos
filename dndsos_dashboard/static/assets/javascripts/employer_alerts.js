
// Notification when the a freelancer accepts an offer
document.addEventListener('DOMContentLoaded', function() {
    const webSocketBridge = new channels.WebSocketBridge();
    const nl = document.querySelector("#notifylist");
    webSocketBridge.connect('/ws/business_notifications/order/');
    // webSocketBridge.connect('/ws/dashboard/order/');


    webSocketBridge.listen(function(action, stream) {
      console.log("RESPONSE:", action);
      if(action.event == "New User") {
        var el = document.createElement("li");
        el.innerHTML = `New user <b>${action.username}</b> has joined!`;
        nl.appendChild(el);
      }  
    })
    document.ws = webSocketBridge; /* for debugging */
    console.log(`EMPLOYER SOCKET READY: /users_notifications/ `)
  })

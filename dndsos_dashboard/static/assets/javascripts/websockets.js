document.addEventListener('DOMContentLoaded', function() {
  const webSocketBridge = new channels.WebSocketBridge();
  const nl = document.querySelector("#notifylist");
  webSocketBridge.connect('/orders_notifications/');
  console.log(`ORDER SOCKET READY`)

  webSocketBridge.listen(function(action, stream) {
    console.log("RESPONSE:", action);
    if(action.event == "New Order") {
        var el = document.createElement("li");
        el.innerHTML = `New order <b>${action.orderId}</b> has been created!`;
        nl.appendChild(el);
      }

  })
  document.ws = webSocketBridge; /* for debugging */
})

document.addEventListener('DOMContentLoaded', function() {
      const webSocketBridge = new channels.WebSocketBridge();
      const nl = document.querySelector("#notifylist");
      webSocketBridge.connect('/users_notifications/');
      console.log(`USER SOCKET READY`)

      webSocketBridge.listen(function(action, stream) {
        console.log("RESPONSE:", action);
        if(action.event == "New User") {
          var el = document.createElement("li");
          el.innerHTML = `New user <b>${action.username}</b> has joined!`;
          nl.appendChild(el);
        }  
      })
      document.ws = webSocketBridge; /* for debugging */
    })

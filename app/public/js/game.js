var socket, host;
host = "ws://localhost:3001";

function connect() {
  try {
    socket = new WebSocket(host);

    addMessage("Socket State: " + socket.readyState);

    socket.onopen = function() {
      addMessage("Socket Status: " + socket.readyState + " (open)");
    }

    socket.onclose = function() {
      addMessage("Socket Status: " + socket.readyState + " (closed)");
    }

    socket.onmessage = function(msg) {
      data = JSON.parse(msg.data)
      addMessage(data['text']);
    }
  } catch(exception) {
    addMessage("Error: " + exception);
  }
}

function addMessage(msg) {
  var chat_log = $('#chat-log');
  chat_log.append("<p>" + msg + "</p>");
  chat_log.scrollTop(chat_log.prop("scrollHeight"));
}

function send() {
  var text = $("#message").val();
  if (text == '') {
    addMessage("Please Enter a Message");
    return;
  }

  try {
    message = {}
    message.text = text
    socket.send(JSON.stringify(message));
  } catch(exception) {
    addMessage("Failed To Send")
  }

  $("#message").val('');
}

$(function() {
  connect();
});

$('#message').keypress(function(event) {
  if (event.keyCode == '13') { send(); }
});

$("#disconnect").click(function() {
  socket.close()
});

$("#join_game").click(function() {
  socket.send(JSON.stringify({'action': 'join_game'}));
});

$('#paper').click(function(){
  socket.send(JSON.stringify({'throw': 'paper'}));
})

$('#rock').click(function(){
  socket.send(JSON.stringify({'throw': 'rock'}));
})

$('#scissors').click(function(){
  socket.send(JSON.stringify({'throw': 'scissors'}));
})

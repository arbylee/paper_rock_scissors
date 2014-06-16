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
      addMessage(msg.data);
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
    socket.send(text);
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

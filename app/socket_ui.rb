class SocketUI
  def message msg, *clients
    clients.each do |client|
      client.ws.send(msg)
    end
  end
end

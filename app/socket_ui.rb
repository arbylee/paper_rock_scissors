require 'json'

class SocketUI
  def message msg, *clients
    data = {'text' => msg}
    self.data(data, *clients)
  end

  def data data, *clients
    clients.each do |client|
      client.ws.send(JSON.dump(data))
    end
  end
end

require 'json'

class SocketUI
  def message msg, *clients
    data = {'text' => msg}
    self.data(data, *clients)
  end

  def client_message msg, from_client, *to_clients
      message("#{from_client.name}: #{msg}", *to_clients)
  end

  def data data, *clients
    clients.each do |client|
      client.ws.send(JSON.dump(data))
    end
  end
end

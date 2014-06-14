  class Lobby
    def initialize ui
      @ui = ui
      @clients = []
    end

    def add_client client
      @clients << client
    end

    def remove_client client
      @clients.delete client
    end

    def message msg
      @clients.each {|c| c.ws.send(msg)}
    end

    def include? client
      @clients.include? client
    end
  end

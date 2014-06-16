require 'json'

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

  def message msg, *clients
    if clients.any?
      @ui.message msg, *clients
    else
      @ui.message msg, *@clients
    end
  end

  def data data, *clients
    if clients.any?
      @ui.data data, *clients
    else
      @ui.data data, *@clients
    end
  end

  def include? client
    @clients.include? client
  end
end

class Game
  attr_reader :clients
  VALID_THROWS = ['rock', 'paper', 'scissors']
  MAX_PLAYERS = 2
  def initialize ui
    @ui = ui
    @clients = []
    @throws = {}
  end

  def add_player client
    @clients << client
  end

  def receive client, msg
    if VALID_THROWS.include? msg
      @throws[client.name] = msg
      @ui.message "Your throw is #{msg}", client
    end
    if @throws.length == @clients.length
      response = "Throws are #{@throws}"
      @throws = {}
      @ui.message(response, *@clients)
    end
  end
end

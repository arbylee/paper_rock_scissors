require 'thin'
require 'em-websocket'
require 'sinatra/base'

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  @clients = []
  @throws = {}
  @lobby = []
  @games = []

  class Client
    attr_reader :name, :ws
    def initialize name, ws
      @name = name
      @ws = ws
    end
  end

  class Game
    attr_reader :clients
    VALID_THROWS = ['rock', 'paper', 'scissors']
    MAX_PLAYERS = 2
    def initialize
      @clients = []
      @throws = {}
    end

    def add_player client
      @clients << client
    end

    def receive client, msg
      if VALID_THROWS.include? msg
        @throws[client.name] = msg
      end
      if @throws.length == @clients.length
        response = "Throws are #{@throws}"
        @throws = {}
        return response
      end
    end
  end

  def handle_lobby_actions client, msg
    if msg == "join"
      open_game = @games.detect{|g| g.clients.size < Game::MAX_PLAYERS}
      if open_game
        open_game.add_player client
        @lobby.delete(client)
      else
        game = Game.new()
        game.add_player(client)
        @lobby.delete(client)
        @games << game
      end
      client.ws.send('Joined a game')
    end
  end

  def handle_game_actions client, msg
    game = @games.detect{|g| g.clients.include?(client)}
    response = game.receive(client, msg)
    if response
      game.clients.each {|cl| cl.ws.send(response)}
    end
  end

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      name = "anon#{rand(9999)}"
      client = Client.new(name, ws)
      @clients << client
      @lobby << client
      ws.send "Connected to #{handshake.path}."
      ws.send "Welcome #{name}"
    end

    ws.onclose do
      ws.send "Closed."
      client = @clients.detect {|c| c.ws == ws}
      @clients.delete client
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"

      client = @clients.detect {|c| c.ws == ws}
      if @lobby.include?(client)
        handle_lobby_actions client, msg
      else
        handle_game_actions client, msg
      end
    end
  end

  App.run! :port => 3000
end

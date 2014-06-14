require 'thin'
require 'em-websocket'
require 'sinatra/base'

require_relative './client.rb'
require_relative './game.rb'
require_relative './lobby.rb'
require_relative './socket_ui.rb'

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  def handle_lobby_actions client, msg
    if msg == "join"
      open_game = @games.detect{|g| g.players.size < Game::MAX_PLAYERS}
      if open_game
        open_game.add_player client
        @lobby.remove_client(client)
        client.ws.send("Joined a game with: #{open_game.players.map{|c| c.name}}")
      else
        game = Game.new(SocketUI.new)
        game.add_player(client)
        @lobby.remove_client(client)
        @games << game
        client.ws.send("Started a new game. Waiting for other players")
      end
    else
      @lobby.message("#{client.name}: #{msg}")
    end
  end

  def handle_game_actions client, msg
    game = @games.detect{|g| g.players.include?(client)}
    game.receive_input(client, msg)
  end

  @clients = []
  @throws = {}
  @lobby = Lobby.new SocketUI.new
  @games = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      name = "anon#{rand(9999)}"
      client = Client.new(name, ws)
      @clients << client
      @lobby.add_client client
      client.ws.send "Connected to #{handshake.path}."
      client.ws.send "Welcome #{name}"
    end

    ws.onclose do
      ws.send "Closed."
      client = @clients.detect {|c| c.ws == ws}
      @clients.delete client
      @lobby.add_client client
      game = @games.detect {|g| g.players.include?(client)}
      game.players.delete client
    end

    ws.onmessage do |msg|
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

require 'json'

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

  def handle_lobby_actions client, data
    action = data['action']
    if action == "join_game"
      open_game = @games.detect{|g| g.players.size < Game::MAX_PLAYERS}
      if open_game
        open_game.add_player client
        @lobby.remove_client(client)
        @lobby.message("Joined a game with: #{open_game.players.map{|c| c.name}}", client)
      else
        game = Game.new(SocketUI.new)
        game.add_player(client)
        @lobby.remove_client(client)
        @games << game
        @lobby.message("Started a new game. Waiting for other players", client)
      end
    end

    msg = data['text']
    if msg
      @lobby.message("#{client.name}: #{msg}")
    end
  end

  def handle_game_actions client, data
    game = @games.detect{|g| g.players.include?(client)}
    game.receive_input(client, data)
  end

  @ui = SocketUI.new
  @clients = []
  @throws = {}
  @lobby = Lobby.new(@ui)
  @games = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      name = "anon#{rand(9999)}"
      client = Client.new(name, ws)
      @clients << client
      @lobby.add_client client
      @lobby.message "Connected to #{handshake.path}.", client
      @lobby.message "Welcome #{name}", client
    end

    ws.onclose do
      client = @clients.detect {|c| c.ws == ws}
      @ui.message("Closed.", client)
      @clients.delete client
      @lobby.add_client client
      game = @games.detect {|g| g.players.include?(client)}
      if game
        game.players.delete client
      end
    end

    ws.onmessage do |raw_data|
      data = JSON.load(raw_data)
      client = @clients.detect {|c| c.ws == ws}
      if @lobby.include?(client)
        handle_lobby_actions client, data
      else
        handle_game_actions client, data
      end
    end
  end

  App.run! :port => 3000
end

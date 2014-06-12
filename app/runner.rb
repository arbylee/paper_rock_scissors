require 'thin'
require 'em-websocket'
require 'sinatra/base'
require_relative './game.rb'

EM.run do
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

  class Client
    attr_reader :name, :ws
    def initialize name, ws
      @name = name
      @ws = ws
    end
  end

  class SocketUI
    def initialize
      @receivers = []
    end

    def add_receiver client
      @receivers << client
    end

    def display msg
      @receivers.each do |client|
        client.ws.send(msg)
      end
    end

    def include? client
      @receivers.include?(client)
    end

    def remove_receiver client
      @receivers.delete client
    end
  end

  def handle_lobby_actions client, msg
    if msg == "join"
      open_game = @games.detect{|g| g.clients.size < Game::MAX_PLAYERS}
      if open_game
        open_game.add_player client
        @lobby.remove_receiver(client)
        client.ws.send("Joined a game with: #{open_game.clients.map{|c| c.name}}")
      else
        game = Game.new(SocketUI.new)
        game.add_player(client)
        @lobby.remove_receiver(client)
        @games << game
        client.ws.send("Started a new game. Waiting for other players")
      end
    else
      @lobby.display("#{client.name}: #{msg}")
    end
  end

  def handle_game_actions client, msg
    game = @games.detect{|g| g.clients.include?(client)}
    game.receive(client, msg)
  end

  @clients = []
  @throws = {}
  @lobby = SocketUI.new
  @games = []


  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
      name = "anon#{rand(9999)}"
      client = Client.new(name, ws)
      @clients << client
      @lobby.add_receiver client
      client.ws.send "Connected to #{handshake.path}."
      client.ws.send "Welcome #{name}"
    end

    ws.onclose do
      ws.send "Closed."
      client = @clients.detect {|c| c.ws == ws}
      @clients.delete client
      @lobby.remove_receiver client
      game = @games.detect {|g| g.clients.include?(client)}
      game.clients.delete client
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

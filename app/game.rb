class Game
  attr_reader :players
  VALID_THROWS = ['rock', 'paper', 'scissors']
  MAX_PLAYERS = 2
  def initialize ui
    @ui = ui
    @players = []
    @throws = {}
  end

  def add_player player
    @players << player
  end

  def receive_input player, msg
    if VALID_THROWS.include? msg
      @throws[player.name] = msg
      @ui.message "Your throw is #{msg}", player
    else
      @ui.message "#{msg} is not a valid throw.  Valid throws include #{VALID_THROWS.join(', ')}", player
    end

    if @throws.length == @players.length
      response = "Throws are #{@throws}"
      @throws = {}
      @ui.message(response, *@players)
    end
  end
end

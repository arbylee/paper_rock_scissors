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

  def receive_input player, data
    msg = data['text']
    if VALID_THROWS.include? msg
      @throws[player.name] = msg
      @ui.message "Your throw is #{msg}", player
    else
      @ui.message "#{msg} is not a valid throw.  Valid throws include #{VALID_THROWS.join(', ')}", player
    end

    if @throws.length == @players.length
      @ui.message(response, *@players)
      @throws.each do |user, symbol|
        @ui.message("#{user} threw #{symbol}", *@players)
      end
      @throws = {}
    end
  end
end

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
    rps_throw = data['throw']

    if rps_throw
      if VALID_THROWS.include? rps_throw
        @throws[player.name] = rps_throw
        @ui.message "Your throw is #{rps_throw}", player
      else
        @ui.message "#{rps_throw} is not a valid throw.  Valid throws include #{VALID_THROWS.join(', ')}", player
      end

      if @throws.length == @players.length
        @throws.each do |user, symbol|
          @ui.message("#{user} threw #{symbol}", *@players)
        end
        @throws = {}
      end
    end

    msg = data['text']
    if msg
      @ui.message("#{player.name}: #{msg}", *@players)
    end

  end
end

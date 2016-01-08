class CardGame
  attr_reader :players
  MAX_PLAYERS = 2

  def initialize ui
    @ui = ui
    @players = []
  end

  def add_player player
    @players << player
  end

  def receive_input player, data
    rps_throw = data['throw']
    if rps_throw
      @ui.message "Your throw is #{rps_throw}", player
    end

    msg = data['text']
    if msg
      @ui.client_message msg, player, *@players
    end

  end
end

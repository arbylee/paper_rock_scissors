class Client
  attr_reader :name, :ws
  def initialize name, ws
    @name = name
    @ws = ws
  end
end

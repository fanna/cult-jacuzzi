class Player
  def initialize
    @player = Gosu::Image.new("./assets/horse.png")
  end

  def draw(pos_x, pos_y)
    @player.draw(pos_x, pos_y, 0)
  end
end

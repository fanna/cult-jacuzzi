class Player
  attr_reader :x, :y

  def initialize(x, y, map)
    @x = x
    @y = y
    @map = map
    @player = Gosu::Image.new("./assets/horse.png")
  end

  def draw
    @player.draw(@x, @y, 0)
  end

  def update(move_x, move_y)
    if move_x > 0 then
      move_x.times { @x += 1 }
    end
    if move_x < 0 then
      (-move_x).times { @x -= 1 }
    end

    if move_y > 0 then
      move_y.times { @y += 1 }
    end
    if move_y < 0 then
      (-move_y).times { @y -= 1 }
    end
  end
end

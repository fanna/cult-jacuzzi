class Player
  attr_reader :x, :y

  def initialize(x, y, map)
    @x = x
    @y = y
    @dir = :left
    @map = map
    @standing, @walk_left_right1, @walk_left_right2 = *Gosu::Image.load_tiles("./assets/test_player.png", 50, 50)

    @cur_image = @standing
  end

  def draw
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor, 1.0)
  end

  def update(move_x, move_y)
    if (move_x == 0 && move_y == 0)
      @cur_image = @standing
    else
      @cur_image = (Gosu::milliseconds / 175 % 2 == 0) ? @walk_left_right1 : @walk_left_right2
    end

    if move_x > 0 then
      @dir = :right
      move_x.times { @x += 1 }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { @x -= 1 }
    end

    if move_y > 0 then
      @dir = :right
      move_y.times { @y += 1 }
    end
    if move_y < 0 then
      @dir = :left
      (-move_y).times { @y -= 1 }
    end
  end
end

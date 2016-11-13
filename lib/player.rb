class Player
  attr_reader :x, :y, :collected_item
  attr_writer :collected_item

  def initialize(x, y, map)
    @x = x
    @y = y
    @dir = :left
    @map = map
    @standing, @walk_left_right1, @walk_left_right2 = *Gosu::Image.load_tiles("./assets/test_player.png", 13, 13)

    @cur_image = @standing
    @collected_item = 0
  end

  def draw
    if @dir == :left then
      offs_x = -8
      factor = 1.0
    else
      offs_x = 8
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 12, 0, factor, 1.0)
  end

  def collide(offs_x, offs_y)
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 12)
  end

  def collect_item(items)
    if items.reject! { |item| Gosu::distance(@x, @y, item.x, item.y) < 10} then
      @collected_item = 1
    end
  end

  def update(move_x, move_y)
    if (move_x == 0 && move_y == 0)
      @cur_image = @standing
    else
      @cur_image = (Gosu::milliseconds / 175 % 2 == 0) ? @walk_left_right1 : @walk_left_right2
    end

    if move_x > 0 then
      @dir = :right
      move_x.times { if collide(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if collide(-1, 0) then @x -= 1 end }
    end

    if move_y > 0 then
      @dir = :right
      move_y.times { if collide(0, 1) then @y += 1 else move_y = 0 end }
    end
    if move_y < 0 then
      @dir = :left
      (-move_y).times { if collide(0, -1) then @y -= 1 else move_y = 0 end }
    end
  end
end

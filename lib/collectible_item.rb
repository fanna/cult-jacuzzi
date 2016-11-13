class CollectibleItem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end

  def draw(offset_x, offset_y)
    x = @x - offset_x
    y = @y - offset_y

    @image.draw_rot(x, y, 0, 300 * Math.sin(Gosu::milliseconds / 100))
  end
end

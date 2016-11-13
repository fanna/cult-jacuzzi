class CollectibleItem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end

  def draw
    @image.draw_rot(@x, @y, 0, 300 * Math.sin(Gosu::milliseconds / 100))
  end
end

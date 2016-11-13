require_relative './tiles.rb'

class Map
  attr_reader :width, :height, :items

  def initialize(filename)
    @tileset = Gosu::Image.load_tiles("./assets/tileset.png", 60, 60, :tileable => true)

    item_img = Gosu::Image.new("./assets/gem.png")
    @items = []

    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        when '$'
          @items.push(CollectibleItem.new(item_img, x * 50 + 25, y * 50 + 25))
          nil
        else
          nil
        end
      end
    end
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, 0)
        end
      end
    end
    @items.each { |c| c.draw }
  end

  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end

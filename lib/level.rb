class Level
  attr_accessor :map

  def initialize(map)
    @map = map
    @processing_map = Marshal.load(Marshal.dump(map))

    paint_regions
  end

  def regions
    return @regions if @regions

    @regions ||= []
    @processing_map.each_with_index do |line, index_y|
      line.each_with_index do |cell, index_x|
        next if cell == -1

        @regions << { value: cell, cells: process_neighbours(index_x, index_y, cell) }
      end
    end
    @regions
  end

  def paint_regions
    material_regions = regions.select { |region| region[:value] != "." }

    count = material_regions.count

    material_regions.sample((count / 2).round).each do |region|
      region[:cells].each do |x, y|
        @map[y][x] = "\""
      end
    end
  end

  def blank_region
    return @blank_region if @blank_region

    blank_regions = regions.select { |region| region[:value] == "." }

    max_index = blank_regions.map { |region| region[:cells].count }.each_with_index.max[1]

    @blank_region = blank_regions[max_index]
  end

  def spawn_point
    x, y = blank_region[:cells].find do |cell|
      x, y = cell

      @map[y - 1][x - 1] == "." && @map[y - 1][x] == "." && @map[y - 1][x + 1] == "." &&
        @map[y][x - 1] == "." && @map[y][x] == "." && @map[y][x + 1] == "." &&
        @map[y + 1][x - 1] == "." && @map[y + 1][x] == "." && @map[y + 1][x + 1] == "."
    end

    x = x * 18 + 7
    y = y * 18 + 20

    [x, y]
  end

  def collectible_items(count = 30)
    item_image = Gosu::Image.new("assets/gem.png")

    blank_region[:cells].sample(30).map do |coords|
      CollectibleItem.new(item_image, coords[0] * 18 + 5, coords[1] * 18 + 5)
    end
  end

  private

  def process_neighbours(x, y, value)
    return [] unless @processing_map[y][x] == value

    # Also ignores framing rows and columns
    return [] if x <= 0 || x >= @processing_map[0].count - 1
    return [] if y <= 0 || y >= @processing_map.count - 1

    @processing_map[y][x] = -1

    group = [[x, y]]

    group += process_neighbours(x, y - 1, value)
    group += process_neighbours(x, y + 1, value)
    group += process_neighbours(x - 1, y, value)
    group += process_neighbours(x + 1, y, value)

    group.to_a.compact.reject { |subgroup| subgroup.empty? }
  rescue NoMethodError
    []
  end
end

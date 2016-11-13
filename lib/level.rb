class Level
  attr_accessor :map

  def initialize(map)
    @map = map
    @processing_map = Marshal.load(Marshal.dump(map))
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

  def blank_region
    return @blank_region if @blank_region

    blank_regions = regions.select { |region| region[:value] == "." }

    max_index = blank_regions.map { |region| region[:cells].count }.each_with_index.max[1]

    @blank_region = blank_regions[max_index]
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

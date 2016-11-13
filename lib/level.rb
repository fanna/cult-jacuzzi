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

require "perlin_noise"

class MapGenerator
  def self.generate
    x = Random.new.rand(50..90)
    y = Random.new.rand(50..90)

    file_path = "assets/test_map.txt"

    level = filled_level(x, y)

    save_level(level.map, file_path)

    level
  end

  def self.save_level(level, path)
    File.open(path, 'w') do |file|
      level.each do |line|
        line_string = ""
        line.each do |field|
          line_string << field
        end
        file.puts(line_string)
      end
    end
  end

  def self.noise(x, y, limit = 0.62)
    n2d = Perlin::Noise.new 2

    max = 10

    x -= 1
    y -= 1

    map = []
    0.step(max, max / y.to_f) do |y|
      line = []
      0.step(max, max / x.to_f) do |x|
        if n2d[x, y] > limit
          line << "#"
        else
          line << "."
        end
      end
      map << line
    end
    map
  end

  def self.filled_level(x, y)
    noise_map = noise(x, y)

    framed_map = framed_level(noise_map)

    Level.new(framed_map)
  end

  def self.framed_level(level)
    x = level[0].count
    y = level.count

    framed_level = []
    level.each_with_index do |line, index_y|
      framed_line = []
      line.each_with_index do |field, index_x|
        if index_x == 0 || index_y == 0 || index_x == x - 1 || index_y == y - 1
          framed_line << "#"
        else
          framed_line << level[index_y][index_x]
        end
      end
      framed_level << framed_line
    end

    framed_level
  end

  def self.blank_level(x, y)
    level = []
    level << ["#"] * x
    (y - 2).times { level << ["#"] +  ["."] * (x-2) + ["#"] }
    level << ["#"] * x
    level
  end
end

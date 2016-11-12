require "perlin_noise"

class MapGenerator
  def self.generate
    x = Random.new.rand(30..70)
    y = Random.new.rand(30..70)

    file_path = "assets/test_map.txt"

    blank_level(file_path, x, y)
  end

  def self.noise(max, step, limit)
    n2d = Perlin::Noise.new 2

    0.step(max, step) do |x|
      line = ""
      0.step(max, step) do |y|
        val = n2d[x, y]
        if val > limit
          line += "#"
        else
          line += "."
        end
      end
      puts line
    end
  end

  def self.blank_level(path, x, y)
    File.open(path, 'w') { |file| file.write("#" * x + "\n") }
    (y - 2).times do
      File.open(path, 'a') { |file| file.write("#" + "." * (x-2) + "#" + "\n") }
    end
    File.open(path, 'a') { |file| file.write("#" * x) }
    File.open(path, 'a') { |file| file.write("#" * x) }
  end
end

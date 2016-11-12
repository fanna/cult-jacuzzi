class MapGenerator
  def self.generate
    x = Random.new.rand(30..70)
    y = Random.new.rand(30..70)

    file_path = "assets/test_map.txt"

    blank_level(file_path, x, y)
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

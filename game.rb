require 'gosu'
require_relative './lib/player.rb'
require_relative './lib/map.rb'
require_relative './lib/wikipedia.rb'
require_relative './lib/four_chan.rb'
require_relative './lib/map_generator'
require_relative './lib/collectible_item.rb'
require_relative './lib/level.rb'

WIDTH = 640
HEIGHT = 640
MOVE_STEP = 2

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT, :fullscreen => false
    self.caption = "Cult Jacuzzi"

    @level = MapGenerator.generate

    @background_image = Gosu::Image.new("./assets/space.png", :tileable => true)
    @text_image = Gosu::Image.new("./assets/black.jpg")
    @map = Map.new("./assets/test_map.txt")

    spawn_x, spawn_y = @level.spawn_point
    @player = Player.new(spawn_x, spawn_y, @map)

    @font = Gosu::Font.new(15, :name => "./assets/font.ttf")
    @text = "TEST"

    @text_background = false

    @camera_x = @camera_y = 0

    @wikipedia = Wikipedia.new
    @four_chan = FourChan.new

    @music = Gosu::Song.new("./assets/music.mp3") rescue nil

    sleep 3
    @music.play(true) rescue nil

    @menu_state = true

    @main_menu= Gosu::Image.new("./assets/main_menu.png")
    @warning_menu= Gosu::Image.new("./assets/warning.png")

    @warning = 0
    @warning_state = true

    @collectible_items = @level.collectible_items

    @sfw = true
  end

  def update
    move_x = 0
    move_y = 0
    move_y -= MOVE_STEP if button_down? Gosu::Button::KbW
    move_y += MOVE_STEP if button_down? Gosu::Button::KbS
    move_x -= MOVE_STEP if button_down? Gosu::Button::KbA
    move_x += MOVE_STEP if button_down? Gosu::Button::KbD
    @player.update(move_x, move_y)
    @player.collect_item(@collectible_items)

    if @player.collected_item == 1
      @text_background = true
      @text = @wikipedia.random_line
      @image = "./" + @four_chan.random_image_path(@sfw)
      @player.collected_item = 0
      @collectible_items << @level.collectible_items(1).first
    else
      nil
    end

    @warning = Gosu::milliseconds

    @camera_x = [[@player.x - WIDTH / 2, 0].max, @map.width * 18 - WIDTH].min
    @camera_y = [[@player.y - HEIGHT / 2, 0].max, @map.height * 18 - HEIGHT].min
  end

  def draw
    @background_image.draw(0, 0, 0)

    Gosu::translate(-@camera_x, -@camera_y) do
      @map.draw
      @player.draw
    end

    if @text_background == true
      @text_image.draw(10, 10, 0)
      @chan_image = Gosu::Image.new(@image)

      line_y = 20
      @text.scan(/.{1,78}/).each do |line|
        @font.draw(line, 30, line_y, 3, 1.0, 1.0, 0xff_000000)
        line_y += 10
      end

      @chan_image.draw(10, 350, 3)
    end

    if @menu_state == true
      @main_menu.draw(0, 0, 0)
    end

    unless @text_background || @menu_state
      @collectible_items.each { |item| item.draw(@camera_x, @camera_y) }
    end

    if @warning > 10 && @warning_state == true
      @warning_menu.draw(0, 0, 0)
    end
  end

  def draw_rotating_background
    angle = Gosu::milliseconds / 50.0
    scale = (Gosu::milliseconds % 1000) / 1000.0

    [1, 0].each do |extra_scale|
      @background_image.draw_rot WIDTH * 0.5, HEIGHT * 0.75, 0, angle, 0.5, 0.5,
        scale + extra_scale, scale + extra_scale
    end
  end

  def button_down(id)
    case id
    when Gosu::Button::KbEscape
      @wikipedia.clean_up
      @four_chan.clean_up
      close
    when Gosu::Button::KbQ
      @text_background = false
    when Gosu::Button::KbG
      @menu_state = false
    when Gosu::Button::KbM
      @sfw = !@sfw
    when Gosu::Button::KbTab
      @warning_state = false
    end
  end
end

GameWindow.new.show if __FILE__ == $0

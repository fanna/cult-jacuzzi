require 'gosu'
require_relative './lib/player.rb'
require_relative './lib/map.rb'
require_relative './lib/wikipedia.rb'

WIDTH = 640
HEIGHT = 640
MOVE_STEP = 5

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Cult Jacuzzi"
    @background_image = Gosu::Image.new("./assets/space.png", :tileable => true)
    @text_image = Gosu::Image.new("./assets/black.jpg")
    @map = Map.new("./assets/map.txt")

    @player = Player.new(100, 100, @map)

    @font = Gosu::Font.new(15)
    @text = "TEST"

    @text_background = false

    @camera_x = @camera_y = 0

    @wikipedia = Wikipedia.new
  end

  def update
    move_x = 0
    move_y = 0
    move_y -= MOVE_STEP if button_down? Gosu::Button::KbW
    move_y += MOVE_STEP if button_down? Gosu::Button::KbS
    move_x -= MOVE_STEP if button_down? Gosu::Button::KbA
    move_x += MOVE_STEP if button_down? Gosu::Button::KbD
    @player.update(move_x, move_y)

    @camera_x = [[@player.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
    @camera_y = [[@player.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min
  end

  def draw
    draw_rotating_background

    Gosu::translate(-@camera_x, -@camera_y) do
      @map.draw
      @player.draw
    end

    if @text_background == true
      @text_image.draw(10, 10, 0)
      @font.draw(@text, 20, 20, 3, 1.0, 1.0, 0xffff00ff)
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
      close
    when Gosu::Button::KbSpace
      @text_background = true
      @text = @wikipedia.random_line
    when Gosu::Button::KbQ
      @text_background = false
    end
  end
end

GameWindow.new.show if __FILE__ == $0

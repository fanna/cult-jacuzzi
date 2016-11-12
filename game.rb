require 'gosu'
require_relative './lib/player.rb'

class GameWindow < Gosu::Window
  def initialize
    super 640, 640
    self.caption = "Cult Jacuzzi"
    @background_image = Gosu::Image.new("./assets/floor.jpg", :tileable => true)
    @player = Player.new

    @pos_x = 100
    @pos_y = 100
  end

  def update
    @pos_y -= 3 if button_down? Gosu::Button::KbW
    @pos_y+= 3 if button_down? Gosu::Button::KbS
    @pos_x -= 3 if button_down? Gosu::Button::KbA
    @pos_x += 3 if button_down? Gosu::Button::KbD
  end

  def draw
    @background_image.draw(0, 0, 0)
    @player.draw(@pos_x, @pos_y)
  end

  def button_down(id)
    case id
    when Gosu::Button::KbEscape then close
    end
  end
end

window = GameWindow.new
window.show

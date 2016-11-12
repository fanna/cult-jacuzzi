require 'gosu'
require_relative './lib/player.rb'
require_relative './lib/wikipedia.rb'

WIDTH = 640
HEIGHT = 640

class GameWindow < Gosu::Window
  def initialize
    super WIDTH, HEIGHT
    self.caption = "Cult Jacuzzi"
    @background_image = Gosu::Image.new("./assets/floor.jpg", :tileable => true)
    @text_image = Gosu::Image.new("./assets/black.jpg")
    @player = Player.new

    @pos_x = 100
    @pos_y = 100

    @font = Gosu::Font.new(15)
    @text = "TEST"

    @text_background = false
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

    if @text_background == true
      @text_image.draw(10, 10, 0)
      @font.draw(@string, 20, 20, 3, 1.0, 1.0, 0xffff00ff)
    end
  end

  def button_down(id)
    case id
    when Gosu::Button::KbEscape
      close
    when Gosu::Button::KbSpace
      @text_background = true
      @text = Wikipedia.random_text
    end
  end
end

window = GameWindow.new
window.show

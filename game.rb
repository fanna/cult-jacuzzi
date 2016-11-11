require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super 800, 600
    self.caption = "Cult Jacuzzi"
  end

  def update
  end

  def draw
  end
end

window = GameWindow.new
window.show

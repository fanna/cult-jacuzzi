require 'gosu'
require 'gl'
require 'glu'
require 'glut'

include Gl
include Glu

class Window < Gosu::Window
  attr_accessor :rotation_angle

  def initialize
    super(800, 600, false)
    self.caption = "Asylum Jam 2016"
    @rotation_angle = 0
    @move_up = 0
    @move_right = 0
    @move_front = -10
    @test= 1.0
  end

  def update
    @rotation_angle += 0.9
    #@y_angle -= 1.5 if button_down? Gosu::Button::KbRight
    #@y_angle += 1.5 if button_down? Gosu::Button::KbLeft

    @move_up += 0.1 if button_down? Gosu::Button::KbW
    @move_up -= 0.1 if button_down? Gosu::Button::KbS
    @move_right += 0.1 if button_down? Gosu::Button::KbD
    @move_right -= 0.1 if button_down? Gosu::Button::KbA
    @move_front -= 0.1 if button_down? Gosu::Button::KbUp
    @move_front += 0.1 if button_down? Gosu::Button::KbDown

    @test_r = rand
    @test_g = rand
    @test_b = rand

    prng = Random.new

    @test_a = prng.rand(1)
    @test_b = prng.rand(1)
    @test_c = prng.rand(1)
  end

  def draw
    gl do
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

      glMatrixMode(GL_PROJECTION)
      glLoadIdentity

      gluPerspective(45.0, width / height, 0.1, 100)

      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity

      glTranslatef(@move_right, @move_up, @move_front)

      glRotatef(1, 0, 1, 0)

      glBegin(GL_TRIANGLES)
      glColor3f(@test_r, @test_g, @test_b)
      glVertex3f(0 ,@test_a, 0)
      glColor3f(@test_r, @test_g, @test_b)
      glVertex3f(@test_a, @test_b, 0)
      glColor3f(@test_r, @test_g, @test_b)
      glVertex3f(@test_b, @test_c, 0)
      glEnd
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = Window.new
window.show

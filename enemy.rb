class Enemy
  attr_reader :en_x, :en_y, :cur_x, :cur_y, :destroyed, :angle, :hitbox_x, :hitbox_y
  attr_accessor :hp
  def initialize(x, y)
    @image = Gosu::Image.new('enemies/Great_White_Anim_A0000.png')
    @en_x, @en_y  = x, y
    @cur_x, @cur_y = x, y
    @vel_x = @vel_y = @angle = 0.0
    @hp = 3
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu.offset_x(@angle, 0.05)
    @vel_y += Gosu.offset_y(@angle, 0.05)
  end

  def move
    @en_x += @vel_x
    @en_y += @vel_y

    @vel_x *= 0.95
    @vel_y *= 0.95

    @hitbox_x = @en_x + (50 * (Math.sin(@angle)))
    @hitbox_y = @en_y + (-50 * (Math.cos(@angle)))

  end

  def patrol
    self.accelerate
    self.move
    if Gosu.distance(@cur_x, @cur_y, @en_x, @en_y) > 100
      @cur_x = @en_x
      @cur_y = @en_y
      @angle -= 180
    end
  end

  def chase(player)
    self.accelerate
    @dest_x = player.x
    @dest_y = player.y
    @hyp = Math.hypot((@dest_x - @en_x), (@dest_y - @en_y))
    if (@dest_y <= @en_y)
      @angle =  (Math.asin((@dest_x - @en_x)/@hyp)) * (180/(Math::PI))
    elsif (@dest_y > @en_y)
      @angle =  180 - (Math.asin((@dest_x - @en_x)/@hyp)) * (180/(Math::PI))
    end
  self.move
  end

  def destroy(bullet)
    @hp -= 1
    if @hp < 1
      @destroyed = true
    else
      @destroyed = false
    end
  end

  def draw
    @image.draw_rot(@en_x, @en_y, 1, @angle)
  end
end

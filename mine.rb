class Mine

  ACCELERATION = 0.6
  FRICTION = 0.2
  attr_reader :x, :y, :cur_x, :cur_y, :destroyed, :angle
  def initialize(map, x, y)
    @image = Gosu::Image.new('enemies/mine_1_small.png')
    @x, @y = x, y
    @angle = @velocity_x = @velocity_y = 0
    @map = map
    @hp = 1
    @destroyed = false
  end

  def accelerate
    @velocity_x += Gosu.offset_x(@angle, ACCELERATION)
    @velocity_y += Gosu.offset_y(@angle, ACCELERATION)
  end

  def move
    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION
  end


  def stalk(player, map)

    if not map.solid?(@x + 20, @y + 20) and not map.solid?(@x - 20, @y - 20)
      if @x - player.x > 0 && (@x - player.x).abs > (@y - player.y).abs
        @angle = 270
      elsif @x - player.x < 0 && (@x - player.x).abs > (@y - player.y).abs
        @angle = 90
      elsif @y - player.y > 0 && (@x - player.x).abs < (@y - player.y).abs
        @angle = 0
      elsif @y - player.y < 0 && (@x - player.x).abs < (@y - player.y).abs
        @angle = 180
      end
    else
      @velocity_y = Gosu.offset_x(@angle - 180, 3)
      @velocity_x = Gosu.offset_y(@angle - 180, 3)
    end
    self.accelerate
    self.move

  end

  def pathfind(map)
    if @angle == 90 || @angle == 270
      @velocity_x = 0
      @angle = 180
      self.accelerate
      self.move
    elsif @angle = 0 || @angle = 180
      @velocity_y = 0
      @angle = 90
      self.accelerate
      self.move
    end
  end

  def destroy(bullet)
    @hp -= 1
    if @hp == 0
      @destroyed = true
    else
      @destroyed = false
    end
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end

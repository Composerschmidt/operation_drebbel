require 'rubygems'
require 'gosu'

require_relative 'bullet'
require_relative 'enemy'
require_relative 'explosion'
require_relative 'mine'

WIDTH, HEIGHT = 800, 800

module Tiles
  Tile_blue_11 = 0
  Tile_blue_5 = 1
  MapTop = 2
  Corner = 3
  MapRight = 4
  Bottom = 5
  MapBottom = 6
  MapLeft = 7
  Rock1 = 8
  Rock2 = 9
  BuildingTop1 = 10
  BuildingTop2 = 11
  Rock3 = 12
  Rock4 = 13
  BuildingBottom1 = 14
  BuildingBottom2 = 15
  Vertical1 = 16
  Vertical2 = 17
  Vertical3 = 20
  Vertical4 = 21



end

class CollectibleCoin
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end

  def draw
    @image.draw_rot(@x, @y, 0, 25 * Math.sin(Gosu.milliseconds / 100.0))
  end
end

class Player

  attr_accessor :score, :health

  ROTATION_SPEED = 2
  ACCELERATION = 1
  FRICTION = 0.6

  attr_reader :x, :y, :angle, :radius

  def initialize(map, x, y)
    @x = x
    @y = y
    @angle = 0
    @image = Gosu::Image.new('images/orange_submarine_nassau_small.png')
    @velocity_x = 0
    @velocity_y = 0
    @radius = 20
    @map = map
    @score = 0
    @health = 100
    @coin_sound = Gosu::Sample.new('audio/coin_3.mp3')

  end

  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 45)
  end
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  def turn_right
    @angle += ROTATION_SPEED
  end

  def turn_left
    @angle -= ROTATION_SPEED
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
    if ((@angle % 360).between?(0, 22) || (@angle % 360).between?(338, 359)) && @map.solid?(@x, @y - 50)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(23, 68) && @map.solid?(@x +25, @y - 25)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(69, 113) && @map.solid?(@x + 50, @y)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(114, 159) && @map.solid?(@x + 25, @y +25)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(160, 205) && @map.solid?(@x, @y + 50)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(206, 250) && @map.solid?(@x - 25, @y +25)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(251, 295) && @map.solid?(@x - 50, @y)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
    if (@angle % 360).between?(296, 337) && @map.solid?(@x -25, @y -25)
      @velocity_x += Gosu.offset_x(@angle - 180, ACCELERATION)
      @velocity_y += Gosu.offset_y(@angle - 180, ACCELERATION)
    end
  end

  def knockback(enemy)
    # @x += Gosu.offset_x(@angle - 180, 50)
    # @y += Gosu.offset_y(@angle - 180, 50)
    @velocity_x += Gosu.offset_x(enemy.angle, 50 * (ACCELERATION))
    @velocity_y += Gosu.offset_y(enemy.angle, 50 * (ACCELERATION))
  end

  def collect_coins(coins)
    coins.reject! do |c|
      (c.x - @x).abs < 50 and (c.y - @y).abs < 50
      if Gosu.distance(@x, @y, c.x, c.y) < 50
        @score += 10
        @coin_sound.play
        true
      else
        false
      end
    end
  end

end

# Map class holds and draws tiles and gems.
class Map
  attr_reader :width, :height, :coins, :tiles

  def initialize(filename)
    # Load 60x60 tiles, 5px overlap in all four directions.
    # @sky = Gosu::Image.new("media/sand_background.png", :tileable => true)
    @tileset = Gosu::Image.load_tiles("images/ut12.png", 64, 64, :tileable => true)

    coin_img = Gosu::Image.new("images/euro.png")
    @coins = []

    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when 'R'
          Tiles::Bottom
        when 'B'
          Tiles::MapRight
        when '$'
          Tiles::Corner
        when 'T'
          Tiles::MapTop
        when 'L'
          Tiles::MapBottom
        when '*'
          Tiles::MapLeft
        when '"'
          Tiles::Tile_blue_5
        when '#'
          Tiles::Tile_blue_11
        when '%'
          Tiles::Rock1
        when '^'
          Tiles::Rock2
        when '&'
          Tiles::Rock3
        when '!'
          Tiles::Rock4
        when 'V'
          Tiles::BuildingTop1
        when 'C'
          Tiles::BuildingTop2
        when 'E'
          Tiles::BuildingBottom1
        when 'Z'
          Tiles::BuildingBottom2
        when 'Y'
          Tiles::Vertical1
        when 'U'
          Tiles::Vertical2
        when 'S'
          Tiles::Vertical3
        when 'M'
          Tiles::Vertical4
        when 'x'
          @coins.push(CollectibleGem.new(coin_img, x * 50, y * 50))
          nil
        else
          nil
        end
      end
    end
  end

  def draw
    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, 0)
        end
      end
    end
    @coins.each { |c| c.draw }
  end

  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end

class OpDrebbel < (Example rescue Gosu::Window)
  def initialize
    super WIDTH, HEIGHT

    self.caption = "O p e r a t i o n : D r e b b e l"

    @sand = Gosu::Image.new("images/sand_background_v4_mod.png", :tileable => true)
    @map = Map.new("images/oDremmel_map.txt")
    @player = Player.new(@map, 800, 600)
    @sub_sound = Gosu::Sample.new('audio/sub_sonar.mp3')
    @sub_sound.play(volume = 1, speed = 1, looping = true)
    @sub_move = Gosu::Sample.new('audio/sub_move.mp3')
    @music = Gosu::Song.new('audio/drubbel_trouble.mp3')
    @music.volume = 60
    @music.play(looping = true)
    @enemies = []
    @enemies.push Enemy.new(160, 120), Enemy.new(1000, 800), Enemy.new(1800, 1020)
    # @enemy.warp(160, 120)
    @mines = []
    @mines.push Mine.new(@map, 200, 400), Mine.new(@map, 250, 250), Mine.new(@map, 300, 350), Mine.new(@map, 400, 450), Mine.new(@map, 100, 150)
    @endscreen = :game
    @underwater_sound = Gosu::Sample.new('audio/underwater_sound.mp3')
    @underwater_sound.play(volume = 1, speed = 1, looping = true)
    @torpedo_sound = Gosu::Sample.new('audio/torpedo.mp3')
    @explosion_soft = Gosu::Sample.new('audio/explosion.mp3')
    @alarm_sound = Gosu::Sample.new('audio/alarm.mp3')
    @skull_crush = Gosu::Sample.new('audio/skull_crush.mp3')
    @subcrash_sound = Gosu::Sample.new('audio/crash.mp3')
    @font = Gosu::Font.new(27)
    @health_font = Gosu::Font.new(27)
    @bullets = []
    @explosions = []

    @camera_x = @camera_y = 0
  end

  def update
    if button_down?(Gosu::KbLeft)
      @player.turn_left

    end
    if button_down?(Gosu::KbRight)
      @player.turn_right

    end
    if button_down?(Gosu::KbUp)
      @player.accelerate
    end
    @bullets.each do |bullet|
      bullet.move
      @mines.each do |mine|
        if Gosu.distance(bullet.x, bullet.y, mine.x, mine.y) < 50
          mine.destroy(bullet)
          @bullets.delete bullet
          @explosions.push Explosion.new(self, bullet.x, bullet.y)
          @explosion_soft.play
          @player.score += 20
        end
        if mine.destroyed == true
          @mines.delete mine
        end
      end
      @enemies.each do |enemy|
        if Gosu.distance(bullet.x, bullet.y, enemy.en_x, enemy.en_y) < 50
          enemy.destroy(bullet)
          @bullets.delete bullet
          @explosions.push Explosion.new(self, bullet.x, bullet.y)
          @explosion_soft.play
          @subcrash_sound.play
          @player.score -= 5
          @skull_crush.play
          enemy.chase(@player)
        end
        if enemy.destroyed == true

          @enemies.delete enemy
        end
      end
    end
    @bullets.dup.each do |bullet|
      if not bullet.onscreen? or @map.solid?(bullet.x, bullet.y)
        @bullets.delete bullet
        @explosions.push Explosion.new(self, bullet.x, bullet.y)
        @explosion_soft.play
      end
    end

    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.finished
    end
    @player.move

    @mines.each do |mine|
      mine.stalk(@player, @map)
      if  Gosu.distance(mine.x, mine.y, @player.x, @player.y) < 35
        @explosions.push Explosion.new(self, mine.x, mine.y)
        @explosion_soft.play
        @mines.delete mine
        @player.health -= 50
        @player.knockback(mine)
      end
    end

    @enemies.each do |enemy|
      if (@player.x - enemy.en_x).between?(-300, 300) || (@player.y - enemy.en_y).between?(-300, -300) and not @map.solid?((enemy.en_x + 25), (enemy.en_y + 25))
        enemy.chase(@player)
      else
        enemy.patrol
      end
      if  Gosu.distance(enemy.hitbox_x, enemy.hitbox_y, @player.x, @player.y) < 35
        @explosions.push Explosion.new(self, enemy.en_x, enemy.en_y)
        @explosion_soft.play
        @player.health -= 5
        @player.knockback(enemy)
        puts enemy.hitbox_x
        puts enemy.en_x
        puts enemy.hitbox_y
        puts enemy.en_y
      end
    end


    @player.collect_coins(@map.coins)
    if @player.collect_coins(@map.coins)
      @coin_sound.play(volume = 1, speed = 1, looping = false)
    end
    # Scrolling follows player
    @camera_x = [[@player.x - WIDTH / 2, 0].max, @map.width * 50 - WIDTH].min
    @camera_y = [[@player.y - HEIGHT / 2, 0].max, @map.height * 50 - HEIGHT].min

  end

  def draw
    @font.draw("S C O R E : #{@player.score}", 20, 20, 1, 1.0, 1.0, Gosu::Color::YELLOW)
    @health_font.draw("H E A L T H : #{@player.health}", 20, 50, 1, 1.0, 1.0, Gosu::Color::YELLOW)
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
      @player.draw
      @enemies.each do | enemy|
        enemy.draw
      end
      @mines.each do |mine|
        mine.draw
      end
      @sand.draw 0,0,-5
      @bullets.each do |bullet|
        bullet.draw
      end
      @explosions.each do |explosion|
        explosion.draw
      end
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::KbSpace
      if @bullets.length < 2
        @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
        @torpedo_sound.play
      end
    else
      super
    end
  end
end

OpDrebbel .new.show

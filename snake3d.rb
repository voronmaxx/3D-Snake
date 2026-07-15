# snake3d.rb
require 'io/console'
require 'timeout'
require 'set'

SIZE = 8

class Snake3D
  def initialize
    @size = SIZE
    center = SIZE / 2
    @snake = [[center, center, center]]
    @dir = [0, 0, 1]
    @next_dir = [0, 0, 1]
    @food = spawn_food
    @score = 0
    @high = 0
    @speed = 0.3
    @game_over = false
    @paused = false
    @running = true
    @input_thread = nil
    run
  end

  def spawn_food
    loop do
      pos = [rand(@size), rand(@size), rand(@size)]
      return pos unless @snake.include?(pos)
    end
  end

  def contains(pos)
    @snake.include?(pos)
  end

  def update
    return if @paused || @game_over
    @dir = @next_dir.dup
    head = @snake.first
    new_head = [
      (head[0] + @dir[0] + @size) % @size,
      (head[1] + @dir[1] + @size) % @size,
      (head[2] + @dir[2] + @size) % @size
    ]
    if contains(new_head)
      @game_over = true
      @high = @score if @score > @high
      return
    end
    @snake.unshift(new_head)
    if new_head == @food
      @score += 1
      @food = spawn_food
      @speed = [0.08, @speed - 0.01].max
    else
      @snake.pop
    end
  end

  def render
    system('clear') || system('cls')
    puts "🐍 3D SNAKE   Score: #{@score}   High: #{@high}   Speed: #{'%.2f' % @speed}s"
    puts "Controls: W/A/S/D/Q/E | Space=pause | R=restart | Esc=quit"
    (@size-1).downto(0) do |y|
      (0...@size).each do |z|
        (0...@size).each do |x|
          pos = [x, y, z]
          ch = '.'
          ch = 'o' if contains(pos)
          ch = 'O' if @snake.first == pos
          ch = '★' if @food == pos
          print "#{ch} "
        end
        puts
      end
    end
    puts "\n⏸️  PAUSED" if @paused
    puts "\n💀 GAME OVER! Press R to restart." if @game_over
  end

  def input_loop
    while @running
      ch = STDIN.getch
      case ch
      when ' ' then @paused = !@paused
      when 'r', 'R'
        if @game_over
          center = @size / 2
          @snake = [[center, center, center]]
          @dir = [0, 0, 1]
          @next_dir = [0, 0, 1]
          @food = spawn_food
          @score = 0
          @speed = 0.3
          @game_over = false
        end
      when "\e" # escape sequence
        c = STDIN.read_nonblock(2) rescue nil
        if c == '[A' then @next_dir = [0, 0, 1]
        elsif c == '[B' then @next_dir = [0, 0, -1]
        elsif c == '[C' then @next_dir = [1, 0, 0]
        elsif c == '[D' then @next_dir = [-1, 0, 0]
        end
      when 'w', 'W' then @next_dir = [0, 0, 1]
      when 's', 'S' then @next_dir = [0, 0, -1]
      when 'a', 'A' then @next_dir = [-1, 0, 0]
      when 'd', 'D' then @next_dir = [1, 0, 0]
      when 'q', 'Q' then @next_dir = [0, 1, 0]
      when 'e', 'E' then @next_dir = [0, -1, 0]
      when "\u0003" then @running = false
      end
    end
  end

  def run
    @input_thread = Thread.new { input_loop }
    while @running && !@game_over
      update
      render
      sleep @speed
    end
    if @game_over
      render
      while @running
        # Wait for restart
      end
    end
  end
end

Snake3D.new

require 'curses'
require 'json'

$log = []

def log!(message)
  $log << [Time.now, message].join(':')
end

def paint_effect(window, attributes)
  window.attron(attributes) if attributes
  yield
  window.attroff(attributes) if attributes
end

class ColourMap
  attr_reader :colour_groups, :colour_pairs

  def initialize(file_path)
    @colour_groups = []
    @colour_pairs  = {}

    # 0 - 16 reserved!
    colour_index = 17
    JSON.parse(File.open(file_path).read).each do |colour_name, colours|
      cg = add_colour_group(colour_name)

      colours.each do |weight, hex|
        cg.add_colour(colour_index, hex, weight)
        colour_index += 1
      end
    end

    create_colour_pairs!
  end

  def add_colour_group(name)
    cg = ColourGroup.new(name)
    @colour_groups << cg
    cg
  end

  def [](name)
    @colour_groups.select {|group| group.name == name}.first
  end

  def pair(foreground, background)
    @colour_pairs[pair_index(foreground, background)]
  end

  private

  def pair_index(foreground, background)
    [foreground, background].map(&:number).join('-')
  end

  def create_colour_pairs!
    all_colours = colour_groups.collect{|group| group.colours}.flatten

    [all_colours, all_colours].reduce() { |acc, n| acc.product(n).map(&:flatten) }.each.with_index(100) do |fg_bg, number|
      fg, bg = fg_bg
      @colour_pairs[pair_index(fg, bg)] = ColourPair.new(number, fg, bg)
    end
  end
end

class ColourGroup
  attr_reader :colours, :name

  def initialize(name)
    @name    = name
    @colours = []
  end

  def add_colour(number, hex, weight)
    @colours << Colour.new(number, hex, weight)
  end

  def [](weight)
    @colours.select {|colour| colour.weight == weight}.first
  end
end

class Colour
  attr_reader :number, :hex, :weight

  def initialize(number, hex, weight)
    @number = number
    @hex    = hex
    @weight = weight

    hex_split = hex.match(/#(..)(..)(..)/)
    @red      = hex_split[1]
    @green    = hex_split[2]
    @blue     = hex_split[3]
    @ncurses  = ncurses
  end

  def rgb
    [@red, @green, @blue].map{|h| h.hex}.map(&:to_i)
  end

  def ncurses
    [@red, @green, @blue].map{|h| h.hex / 0.255}.map(&:to_i)
  end
end

class ColourPair
  attr_reader :number, :foreground, :background

  def initialize(number, foreground, background)
    @number     = number
    @foreground = foreground
    @background = background
  end
end

@colour_map = ColourMap.new('material-colors.json')

begin
  Curses.init_screen

  if Curses.has_colors? && Curses.can_change_color?
    Curses.start_color
    Curses.use_default_colors
  else
    raise
  end

  @colour_map.colour_groups.each do |colour_group|
    colour_group.colours.each do |colour|
      log!("Setting color ##{colour.number} to #{colour.hex} (#{colour.ncurses})")
      init_color = Curses.init_color(colour.number, colour.ncurses[0], colour.ncurses[1], colour.ncurses[2])

      if init_color == false
        log!(".. fail!")
        raise 'init color fail'
      end
      raise if colour.number >= Curses.colors
    end
  end

  @colour_map.colour_pairs.each do |index, pair|
    log!("Setting pair ##{pair.number} to #{pair.foreground.number} (#{pair.background.number})")
    init_pair = Curses.init_pair(pair.number, pair.foreground.number, pair.background.number)
    pair.curses_num = Curses.color_pair(pair.number)

    if init_pair == false
      log!(".. fail!")
      raise 'init pair fail'
    end
    raise if pair.number >= Curses.color_pairs
  end

  Curses.nonl
  Curses.noecho # don't echo keys entered
  Curses.curs_set(0) # invisible cursor

  win = Curses.stdscr

  n = 0

  while(true)
    group   = @colour_map.colour_groups[n]
    name    = group.name
    colours = group.colours

    win.clear
    colours.each.with_index do |colour, index|
      fg = @colour_map['grey']['50']
      bg = @colour_map[name][colour.weight]
      pair = @colour_map.pair(fg, bg)

      paint_effect(win, Curses.color_pair(pair.number)) do
        win.setpos(1+index,1)
        win.addstr("#{name}-#{colour.weight}")
      end
    end

    case win.getch
    when 'n'
      n += 1
    when 'p'
      n -= 1
    else
      break
    end
  end

  win.close
ensure
  Curses.clear # needed to clear the menu/status bar on windows
  Curses.use_default_colors
  Curses.close_screen
end


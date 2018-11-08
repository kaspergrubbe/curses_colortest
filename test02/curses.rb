class NcursesColorManager
  def initialize
  end

  def color_pair(fg_hex, bg_hex)
    fg_color_id = color(fg_hex)
    bg_color_id = color(bg_hex)

    @color_pairs ||= {}
    @color_pairs[[fg_hex, bg_hex]] ||= begin
      @@max_color_pair_id ||= 0
      id = (@@max_color_pair_id += 1)
      pair = Curses.init_pair(id, fg_color_id, bg_color_id)
      raise unless pair
      Curses.color_pair(id)
    end
  end

  private

  def color(hex)
    @colors ||= {}

    @colors[hex] ||= begin
      @@max_color_id ||= 17 # offset

      id = (@@max_color_id += 1)
      color = Curses.init_color(id, *hex_to_1000(hex))
      raise unless color
      id
    end
  end

  def hex_to_1000(hex)
    hex_split = hex.match(/#(..)(..)(..)/)
    [hex_split[1], hex_split[2], hex_split[3]].map{|h| h.hex / 0.255}.map(&:to_i)
  end
end

require 'curses'

begin
  Curses.init_screen

  if Curses.has_colors? && Curses.can_change_color?
    Curses.start_color
    Curses.use_default_colors
  elsif ENV['COLORTERM'] == nil
    raise "Terminal does not support true colors"
  else
    case [Curses.has_colors?, Curses.can_change_color?]
    when [true, false]
      raise "Has colors, can't change them"
    when [false, true]
      raise "No colors, can change them"
    when [false, false]
      raise "No colors, can't change them"
    else
      raise "wat!"
    end
  end

  ncm = NcursesColorManager.new
  plb = ncm.color_pair('#FFFFFF', '#4B8BBE') # python light blue
  pdb = ncm.color_pair('#FFFFFF', '#306998') # python dark blue
  ply = ncm.color_pair('#000000', '#FFE873') # python light yellow
  pdy = ncm.color_pair('#000000', '#FFD43B') # python dark yellow

  background = ncm.color_pair('#FFFFFF', '#363636')
  red    = ncm.color_pair('#FFFFFF', '#FF0054')
  green  = ncm.color_pair('#000000', '#3FE340')
  yellow = ncm.color_pair('#000000', '#FFCC00')
  purple = ncm.color_pair('#FFFFFF', '#9C00FF')
  cyan   = ncm.color_pair('#000000', '#00F0FF')
  orange = ncm.color_pair('#FFFFFF', '#FF6325')

  Curses.nonl
  Curses.noecho # don't echo keys entered
  Curses.curs_set(0) # invisible cursor

  win = Curses.stdscr

  [red, green, yellow, purple, cyan, orange].each do |pair_number|
    attributes = pair_number

    win.attron(attributes)
    win.addstr('lol')
    win.attroff(attributes)
  end

  case win.getch
  when 'n'
    n += 1
  when 'p'
    n -= 1
  else
    # break
  end

  win.close
ensure
  Curses.clear # needed to clear the menu/status bar on windows
  Curses.use_default_colors
  Curses.close_screen
end

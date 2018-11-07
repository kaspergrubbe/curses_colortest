def hex_to_1000(hex)
  hex_split = hex.match(/#(..)(..)(..)/)
  [hex_split[1], hex_split[2], hex_split[3]].map{|h| h.hex / 0.255}.map(&:to_i)
end

white = hex_to_1000('#FFFFFF')
black = hex_to_1000('#000000')

plb = hex_to_1000('#4B8BBE') # python light blue
pdb = hex_to_1000('#306998') # python dark blue
ply = hex_to_1000('#FFE873') # python light yellow
pdy = hex_to_1000('#FFD43B') # python dark yellow

require 'curses'

begin
  Curses.init_screen

  if Curses.has_colors? && Curses.can_change_color?
    Curses.start_color
    Curses.use_default_colors
  else
    case [Curses.has_colors?, Curses.can_change_color?]
    when [true, false]
      raise "Has colors, can't change them"
    when [false, true]
      raise "No colors, can change them"
    when [false, false]
      raise "No colors, can't change them"
    else
      raise "wat"
    end
  end

  colors = []
  pairs  = []

  offset = 17
  [white, black, plb, pdb, ply, pdy].each.with_index(offset) do |c, i|
    init_color = Curses.init_color(i, *c)
    colors << i
  end

  pairs_i = 10
  colors[0..1].each do |fg|
    colors[2..colors.size].each do |bg|
      Curses.init_pair(pairs_i, fg, bg)
      pairs << pairs_i
      pairs_i += 1
    end
  end

  Curses.nonl
  Curses.noecho # don't echo keys entered
  Curses.curs_set(0) # invisible cursor

  win = Curses.stdscr

  pairs.each do |pair_number|
    attributes = Curses.color_pair(pair_number)

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

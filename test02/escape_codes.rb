def hex_to_rgb(hex)
  hex_split = hex.match(/#(..)(..)(..)/)
  [hex_split[1], hex_split[2], hex_split[3]].map(&:hex)
end

def fg(r, g, b)
  "\x1b[38;2;#{r};#{g};#{b}m"
end

def bg(r, g, b)
  "\x1b[48;2;#{r};#{g};#{b}m"
end

def res
  "\x1b[0m"
end

white = hex_to_rgb('#FFFFFF')
black = hex_to_rgb('#000000')

plb = hex_to_rgb('#4B8BBE') # python light blue
pdb = hex_to_rgb('#306998') # python dark blue
ply = hex_to_rgb('#FFE873') # python light yellow
pdy = hex_to_rgb('#FFD43B') # python dark yellow

[plb, pdb, ply, pdy].each do |background|
  [black, white].each do |foreground|
    print "#{bg(*background)}#{fg(*foreground)}lol#{res}"
  end
end
puts

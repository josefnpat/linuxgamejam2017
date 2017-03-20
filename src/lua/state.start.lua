states.start = {}

function states.start:init()
  self.lives = 2
  self.time = 0
  offset = nil
end

function states.start:draw()
  cls()
  print("stealth elf",32,64)
  print("press start",8,80)
  for x = 0,15 do
    for y = 12,15 do
      local sprite = y == 12 and 193 or 192
      spr(sprite,x*8,y*8)
    end
  end
  spr(0,9*8,9*8,2,3)
  spr(212,12*8,9*8,3,3)
  cursor(4,4)
  print("game by @josefnpat")
  print("art by @therickywill")
  print("#linuxgamejam2017")
end

function states.start:update(dt)
  if btn(4) or btn(5) then
    switch_state("game")
  end
end

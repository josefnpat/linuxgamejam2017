states.start = {}

function states.start:init()
  self.lives = 2
  self.time = 0
  offset = nil
  self.checkpoint = nil
end

function states.start:draw()
  cls()
  print("stealth elf",32,64)
  for x = 0,15 do
    for y = 8,9 do
      local sprite = y == 8 and 193 or 192
      spr(sprite,x*8,y*8)
    end
  end
  spr(0,9*8,5*8,2,3)
  spr(212,12*8,5*8,3,3)
  cursor(0,4)
  print("game (mit) by @josefnpat")
  print("art (cc-by3.0) by @therickywill")
  print("#linuxgamejam2017")

  cursor(4,10*8+4)
  print("z|\142 - jump")
  print("\139/\145 - left/right")
  print("\148+x|\151 - use grapple")
  print("\131+x|\151 - use potion")
end

function states.start:update(dt)
  if btn(4) or btn(5) then
    states.game:reset()
    switch_state("game")
  end
end

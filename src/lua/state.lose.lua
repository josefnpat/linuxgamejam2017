states.lose = {}

function states.lose:draw()
  cls()
  print("you lost the game...",8,48)
  spr(2,48,16,2,3)
  spr(112,48+8*3,16,2,3,1)
end

function states.lose:update(dt)
  if btn(5) then
    switch_state("start")
  end
end

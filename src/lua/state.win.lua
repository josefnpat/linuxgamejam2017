states.win = {}

function states.win:draw()
  cls()
  print("you win the game!",8,48)
  print(states.start.time.." seconds",8,64)
  spr(0,48,16,2,3)
  spr(208,64,16,2,3)
end

function states.win:update(dt)
  if btn(5) then
    switch_state("start")
  end
end

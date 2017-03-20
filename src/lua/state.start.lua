states.start = {}

function states.start:init()
  self.lives = 3
  self.time = 0
end

function states.start:draw()
  cls()
  print"press start"
end

function states.start:update(dt)
  if btn(4) or btn(5) then
    switch_state("game")
  end
end

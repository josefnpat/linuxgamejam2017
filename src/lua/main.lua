function _init()
  switch_state("start")
end

function _draw()
  if current_state.draw then
    current_state:draw()
  end
end

function _update()
  if current_state.update then
    current_state:update(1/30)
  end
end

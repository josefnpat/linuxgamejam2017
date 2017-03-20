pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--v%%git_count%%
--a game by @josefnpat and @therickywill

states = {}

function switch_state(target)
  if states[target].init then
    states[target]:init()
  end
  current_state = states[target]
end

_printh = printh
printh = function(msg,file)
  _printh(msg,file or "log.txt")
end

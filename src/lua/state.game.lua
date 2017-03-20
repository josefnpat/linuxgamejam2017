states.game = {}

function states.game:init()

  self.ground = {}

  add(self.ground,{y=120})
  add(self.ground,{y=120})

  self.grapples = {}
  self.enemies = {}
  self.shops = {}
  local cx = 0
  for i = 1,16 do
    add(self.ground,{y=8})
    cx += 8
  end
  add(self.ground,{y=16})
  add(self.ground,{y=16})

  for i = 1,10 do
    local plat_size = flr(rnd()*3)+8
    local plat_height = flr(rnd()*8)*8+8
    for j = 1,plat_size do
      cx += 8
      add(self.ground,{y=plat_height})
    end

    add(self.enemies,{
      x = cx-8,
      y = plat_height,
      dir = 1,
      speed = rnd()*15+15,
      dt = rnd(),
      fast = 1,
    })

    add(self.grapples,{
      x = cx + plat_size/2*8,
      y = plat_height+32,
    })

  end

  add(self.ground,{y=16})
  add(self.ground,{y=16})

  for i = 1,10 do
    add(self.ground,{y=8})
    cx += 8
  end

  add(self.shops,{
    x=cx,
    y=8,
  })

  add(self.ground,{y=128})
  add(self.ground,{y=128})

  self.offset = 0

  self.top = 101
  self.top_left = 70
  self.top_right = 68
  self.left = 86
  self.right = 84
  self.bottom_right = 100
  self.bottom_left = 102
  self.center = 85

  self.players = {}
  for _ = 1,1 do
    add(self.players,{
      x = 3*8,
      y = 8,
      dir = 1,
      speed = 32,
      jumpv = 0,
      dt = 0,
    })
  end

end

function states.game:draw()
  cls()

  local off_player = self.players[1]
  local target_offset = off_player.x + (off_player.dir == 1 and -32 or -96)
  offset = offset or target_offset

  for i = 1,8 do
    if flr(offset) ~= flr(target_offset) then
      if offset > target_offset then
        offset -= 1
      elseif offset < target_offset then
        offset += 1
      end
    end
  end

  for i,v in pairs(self.ground) do
    local x = (i-1)*8
    local y = 128-v.y
    local first = true
    for ny = y,128,8 do
      local tile = nil
      local prev_y = 128
      local next_y = 128
      if self.ground[i-1] then
        prev_y = 128-self.ground[i-1].y
      end
      if self.ground[i+1] then
        next_y = 128-self.ground[i+1].y
      end
      if first then
        if prev_y <= y then
          tile = self.top
        elseif prev_y > y then
          tile = self.top_left
        end
        if next_y > y then
          tile = self.top_right
        end
      else
        tile = self.center
        if next_y > ny then
          tile = self.right
        elseif prev_y > ny then
          tile = self.left
        end
        if next_y == ny then
          tile = self.bottom_right
        end
        if prev_y == ny then
          tile = self.bottom_left
        end
      end
      first = false
      if tile then
        spr(tile,x-offset,ny)
      end
    end
  end

  for _,enemy in pairs(self.enemies) do
    local x,y = enemy.x-8-offset,128-enemy.y-24
    if enemy.dt%0.25 > 0.125 then
      spr(112,x,y,2,3,enemy.dir == -1)
    else
      spr(114,x,y,2,3,enemy.dir == -1)
    end
    if enemy.fast > 1.5 then
      spr(168,x-8,y-16,2,2)
    elseif enemy.fast > 1 then
      spr(170,x-8,y-16,2,2)
    end
  end

  for _,s in pairs(self.shops) do
    local x,y = s.x-8-offset,128-s.y-32
    spr(196,x,y,3,4)
  end

  for _,player in pairs(self.players) do
    local x,y = player.x-8-offset,128-player.y-24
    local sprite = player.dt%0.25 > 0.125 and 14 or 12
    if player.show_item then
      spr(134,x,y-8,1,1)
      sprite = 0
    end
    if player.show_grapple then
      spr(165,x,y-15,2,2)
      sprite = 0
      local cg = player.grapple or self:findNearestGrapple(player)
      if cg then
        cg.highlight = true
        line(player.x-offset,128-player.y-24,
          cg.x-offset,16)
      end
    end
    spr(sprite,x,y,2,3,player.dir == -1)

  end

  for _,grapple in pairs(self.grapples) do
    local x,y = grapple.x-8-offset,0
    spr(160,x,y,2,2)
    if grapple.highlight then
      color(8)
      rect(x-1,y-1,x+17,y+17)
    end
  end

end

function states.game:findNearestGrapple(player)
  local closest = nil
  for _,grapple in pairs(self.grapples) do
    if player.dir == 1 then
      if grapple.x > player.x then
        closest = closest or grapple
        if grapple.x < closest.x then
          closest = grapple
        end
      end
    else
      if grapple.x < player.x then
        closest = closest or grapple
        if grapple.x > closest.x then
          closest = grapple
        end
      end
    end
  end
  return closest
end

function states.game:left_tile(x_raw)
  return flr(x_raw/8)
end

function states.game:right_tile(x_raw)
  return flr(x_raw/8)+2
end

function states.game.distance(a,b)
  if abs(a.x-b.x) < 100 and abs(a.y-b.y) < 100 then
    return sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
  else
    return 100
  end
end

function states.game:update(dt)

  for _,shop in pairs(self.shops) do
    for _,player in pairs(self.players) do
      local distance = self.distance(shop,player) 
      if distance < 8 then
        print"you win"
        stop()
      end
    end
  end

  for _,grapple in pairs(self.grapples) do
    grapple.highlight = false
  end

  for _,enemy in pairs(self.enemies) do
    enemy.dt += dt
    enemy.fast = max(1,enemy.fast-dt)
    local tx = enemy.x + dt*enemy.speed*enemy.dir*enemy.fast
    local tx_height_l = self.ground[flr(tx/8)+1]
    if tx_height_l and tx_height_l.y == enemy.y then
      enemy.x = tx
    else
      enemy.dir = enemy.dir == 1 and -1 or 1
    end
  end

  for i,player in pairs(self.players) do

    for _,enemy in pairs(self.enemies) do
      local distance = self.distance(enemy,player) 
      if distance < 8 then
        print"game over"
        stop()
      end

      if enemy.y == player.y then
        if enemy.dir == 1 then
          if player.x > enemy.x then
            enemy.fast = 2
          else
            enemy.fast = 1
          end
        else
          if player.x < enemy.x then
            enemy.fast = 2
          else
            enemy.fast = 1
          end
        end
      end

    end

    local player_index = i-1

    player.show_grapple = btn(2,player_index) and player.jumpv == 0
    player.show_item = btn(3,player_index)

    local tx,ty = player.x,player.y

    local right_tile = self:right_tile(tx+0.5)
    local right_ground = self.ground[right_tile].y
    local left_tile = self:left_tile(tx-1.5)
    local left_ground = self.ground[left_tile].y

    local iright_tile = self:right_tile(tx-1)
    local iright_ground = self.ground[iright_tile].y
    local ileft_tile = self:left_tile(tx)
    local ileft_ground = self.ground[ileft_tile].y


    if player.show_grapple or player.show_item then
    else

      if player.jumpv == 0 and btn(4,player_index) then
        player.jumpv = 70
      end

      if btn(1,player_index) then
        tx += dt*player.speed
        player.dt += dt
        player.dir = 1
        if right_ground <= player.y then
          player.x = tx
        end
      elseif btn(0,player_index) then
        tx -= dt*player.speed
        player.dt += dt
        player.dir = -1
        if left_ground <= player.y then
          player.x = tx
        end
      else
        player.dt = 0
      end

    end

    player.jumpv = player.jumpv - 128*dt
    ty = player.y + player.jumpv*dt

    if ty > max(ileft_ground,iright_ground) then
      player.y = ty
    else
      if ty < min(ileft_ground,iright_ground) then
        player.y = min(ileft_ground,iright_ground)
      end
      player.y = flr(player.y+0.5)
      player.jumpv = 0
    end

    if player.grapple == nil then
      if player.show_grapple and btn(5,player_index) then
        player.grapple = self:findNearestGrapple(player)
      end
    end

    if btn(5,player_index) then
      if player.grapple then
        player.x = player.grapple.x
        player.y = 128-24
        player.jumpv = 0
      end
    else
      player.grapple = nil
    end

  end
end

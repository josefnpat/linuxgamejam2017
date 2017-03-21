states.game = {}

function states.game:init()

  self.players = {}
  for _ = 1,1 do
    local x,y = 3*8,8
    if states.start.checkpoint then
      x,y = states.start.checkpoint.x,states.start.checkpoint.y
    end
    add(self.players,{
      x=x,y=y,
      dir = 1,
      speed = 32,
      jumpv = 0,
      dt = 0,
      money = 0,
      potion = 0,
    })
  end

end

function states.game:reset()

  self.dt = 0

  self.ground = {}

  local cx = 0
  add(self.ground,{y=120}) cx+=8
  add(self.ground,{y=120}) cx+=8

  self.grapples = {}
  self.bookshelves = {}
  self.enemies = {}
  self.shops = {}
  self.coins = {}
  for i = 1,12 do
    add(self.ground,{y=8}) cx += 8
  end
  add(self.ground,{y=16}) cx+=8
  add(self.ground,{y=16}) cx+=8

  for level = 1,10 do

    for i = 1,5 do -- platforms in each level
      local plat_size = flr(rnd()*8)+13-level
      local plat_height = flr(rnd()*8)*8+8

      add(self.bookshelves,{
        x = cx+2*8,
        y = plat_height,
        w = max(3,flr(plat_size*rnd())-2),
        h = flr(rnd()*4)+3,
      })

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
        x = cx - plat_size/2*8,
        y = plat_height+32,
      })

      for i = 1,2 do
        add(self.coins,{
          x = cx - rnd()*plat_size*8/2,
          y = plat_height,
        })
      end
    end
    add(self.ground,{y=16}) cx+=8
    add(self.ground,{y=16}) cx+=8

    for i = 1,10 do
      add(self.ground,{y=8,grass=true})
      cx += 8
    end

    add(self.grapples,{
      x = cx - 32,
      y = 32,
    })

    add(self.shops,{
      x=cx-32,
      y=8,
    })

    add(self.ground,{y=16}) cx+=8
    add(self.ground,{y=16}) cx+=8

  end

  for i = 1,8 do
    add(self.ground,{y=i*8}) cx+=8
  end

  for i = 1,8 do
    add(self.ground,{y=8*8}) cx+=8
  end

  self.goal = {
    x = cx-32,
    y = 64-8,
  }

  add(self.ground,{y=128}) cx+=8
  add(self.ground,{y=128}) cx+=8

  self.offset = 0

  self.top = 101
  self.top_left = 70
  self.top_right = 68
  self.left = 86
  self.right = 84
  self.bottom_right = 100
  self.bottom_left = 102
  self.center = 85

  self.bs = {
    top = 49,
    top_left = 48,
    top_right = 50,
    left = 64,
    center = 65,
    right = 66,
    bot_left = 80,
    bot = 81,
    bot_right = 82,
  }

end

function states.game:drawBookshelf(bookshelf)
  for x = 1,bookshelf.w do
    for y = 1,bookshelf.h do
      local rx = bookshelf.x-offset+(x-1)*8
      local ry = 128-bookshelf.y-(y)*8
      local sprite = 65
      if y == 1 then
        sprite = self.bs.bot
      end
      if y == bookshelf.h then
        sprite = self.bs.top
      end
      if x == 1 then
        sprite = self.bs.left
      end
      if x == bookshelf.w then
        sprite = self.bs.right
      end

      if x == 1 and y == 1 then
        sprite = self.bs.bot_left
      end
      if x == 1 and y == bookshelf.h then
        sprite = self.bs.top_left
      end

      if x == bookshelf.w and y == 1 then
        sprite = self.bs.bot_right
      end
      if x == bookshelf.w and y == bookshelf.h then
        sprite = self.bs.top_right
      end

      spr(sprite,rx,ry,1,1)
    end
  end

end

function states.game:drawPlax(offset)
  local off = flr(offset%16)
  for _x = 0,9 do
    for _y = 0,8 do
      spr(157,_x*16-off,_y*16,2,2)
    end
  end
end

function states.game:draw()
  cls()

  local off_player = self.players[1]
  local target_offset = off_player.x + (off_player.dir == 1 and -32 or -96)
  offset = offset or target_offset

  self:drawPlax(offset)

  for i = 1,8 do
    if flr(offset) ~= flr(target_offset) then
      if offset > target_offset then
        offset -= 1
      elseif offset < target_offset then
        offset += 1
      end
    end
  end

  local dx = flr(offset/8)
  for i = max(1,dx),min(dx+17,#self.ground) do
    local v = self.ground[i]

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
        if v.grass then
          spr(193,x-offset,ny)
        else
          spr(tile,x-offset,ny)
        end
      end
    end
  end

  for _,bookshelf in pairs(self.bookshelves) do
    self:drawBookshelf(bookshelf)
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

  -- draw goal
  spr(208,self.goal.x-8-offset,128-self.goal.y-32,2,3)

  for _,s in pairs(self.shops) do
    local x,y = s.x-8-offset,128-s.y-32
    local player = self.players[1]
    if player.show_shop then
      if player.shop_attempt ~= nil then
        if player.shop_attempt == true then
          spr(202,x,y,3,4)
        elseif player.shop_attempt == false then
          spr(205,x,y,3,4)
        end
      else
        spr(199,x,y,3,4)
      end
    else
      spr(196,x,y,3,4)
    end
  end

  for _,coin in pairs(self.coins) do
    local sprite = self.dt*4%1 > 0.5 and 189 or 190
    local x,y = coin.x-4-offset,128-coin.y-8
    spr(sprite,x,y,1,1)
  end

  for _,player in pairs(self.players) do

    local x,y = player.x-8-offset,128-player.y-24
    local sprite = player.dt%0.25 > 0.125 and 14 or 12
    if player.show_item then
      if player.potion > 0 then
        spr(134,x,y-8,1,1)
      end
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
    if player.item_dt then
      sprite = 8-2*(flr(player.item_dt*3))
    end
    spr(sprite,x,y,2,3,player.dir == -1)

  end

  for _,grapple in pairs(self.grapples) do
    local x,y = grapple.x-8-offset,0
    spr(160,x,y,2,2)
    if grapple.highlight then
      color(8)
      rect(x+1,y+1,x+14,y+14)
      local sprite = self.dt*4%1 > 0.5 and 77 or 78
      spr(sprite,x+4,y+4,1,1)
      color(7)
    end
  end

  local p = function()
    print("\135"..states.start.lives..
      " \134"..self.players[1].money..
      " \146"..self.players[1].potion)
  end

  cursor(5,5) color(0) p()
  cursor(4,4) color(10) p()
  color(7)

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

  self.dt += dt

  states.start.time += dt

  for _,shop in pairs(self.shops) do
    for _,player in pairs(self.players) do
      local distance = self.distance(shop,player) 
      if distance < 8 then
        states.start.checkpoint = {x=shop.x,y=shop.y}
        if btn(5,player_index) and player.shop_attempt_dt == nil then
          player.shop_attempt_dt = 1
          if player.money >= 4 then
            player.shop_attempt = true
            player.money -= 4
            player.potion += 1
          else
            player.shop_attempt = false
          end
        end
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

    if player.show_item and btn(5,player_index) and player.item_dt == nil and player.potion > 0 then
      player.item_dt = 1
    end

    if player.item_dt then
      player.item_dt -= dt
      if player.item_dt <= 0 then
        player.item_dt = nil
        player.potion -= 1
        states.start.lives += 1
      end
    end

    local gd = self.distance(player,self.goal)
    if self.distance(player,self.goal) < 16 then
      switch_state("win")
      sfx(7,3)
    end

    for _,coin in pairs(self.coins) do
      if self.distance(coin,player) < 4 then
        del(self.coins,coin)
        sfx(3,3)
        player.money += 1
      end
    end

    for _,enemy in pairs(self.enemies) do
      local distance = self.distance(enemy,player) 
      if distance < 8 then
        sfx(6,3)
        if states.start.lives > 0 then
          states.start.lives -= 1
          switch_state("game")
        else
          switch_state("lose")
        end
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

    if player.shop_attempt_dt then
      player.shop_attempt_dt -= dt
      if player.shop_attempt_dt <= 0 then
        player.shop_attempt_dt = nil
        player.shop_attempt = nil
      end
    end

    player.show_grapple = btn(2,player_index) and player.jumpv == 0
    player.show_item = btn(3,player_index)

    player.show_shop = false
    for _,shop in pairs(self.shops) do
      if self.distance(player,shop) < 8 then
        player.show_shop = true
      end
    end

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
        sfx(5,3)
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
        sfx(10,3)
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

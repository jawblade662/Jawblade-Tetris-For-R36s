-- Jawblade Tetris — a pocket-sized rainbow arcade game for PortMaster.
local W, H = 640, 480
local SCALE = 2
local FONT = {
  ["A"]={"01110","10001","10001","11111","10001","10001","10001"}, ["B"]={"11110","10001","10001","11110","10001","10001","11110"},
  ["C"]={"01111","10000","10000","10000","10000","10000","01111"}, ["D"]={"11110","10001","10001","10001","10001","10001","11110"},
  ["E"]={"11111","10000","10000","11110","10000","10000","11111"}, ["F"]={"11111","10000","10000","11110","10000","10000","10000"},
  ["G"]={"01111","10000","10000","10111","10001","10001","01111"}, ["H"]={"10001","10001","10001","11111","10001","10001","10001"},
  ["I"]={"11111","00100","00100","00100","00100","00100","11111"}, ["J"]={"00111","00010","00010","00010","10010","10010","01100"},
  ["K"]={"10001","10010","10100","11000","10100","10010","10001"}, ["L"]={"10000","10000","10000","10000","10000","10000","11111"},
  ["M"]={"10001","11011","10101","10101","10001","10001","10001"}, ["N"]={"10001","11001","10101","10011","10001","10001","10001"},
  ["O"]={"01110","10001","10001","10001","10001","10001","01110"}, ["P"]={"11110","10001","10001","11110","10000","10000","10000"},
  ["Q"]={"01110","10001","10001","10001","10101","10010","01101"}, ["R"]={"11110","10001","10001","11110","10100","10010","10001"},
  ["S"]={"01111","10000","10000","01110","00001","00001","11110"}, ["T"]={"11111","00100","00100","00100","00100","00100","00100"},
  ["U"]={"10001","10001","10001","10001","10001","10001","01110"}, ["V"]={"10001","10001","10001","10001","10001","01010","00100"},
  ["W"]={"10001","10001","10001","10101","10101","10101","01010"}, ["X"]={"10001","10001","01010","00100","01010","10001","10001"},
  ["Y"]={"10001","10001","01010","00100","00100","00100","00100"}, ["Z"]={"11111","00001","00010","00100","01000","10000","11111"},
  ["0"]={"01110","10001","10011","10101","11001","10001","01110"}, ["1"]={"00100","01100","00100","00100","00100","00100","01110"},
  ["2"]={"01110","10001","00001","00010","00100","01000","11111"}, ["3"]={"11110","00001","00001","01110","00001","00001","11110"},
  ["4"]={"00010","00110","01010","10010","11111","00010","00010"}, ["5"]={"11111","10000","10000","11110","00001","00001","11110"},
  ["6"]={"01110","10000","10000","11110","10001","10001","01110"}, ["7"]={"11111","00001","00010","00100","01000","01000","01000"},
  ["8"]={"01110","10001","10001","01110","10001","10001","01110"}, ["9"]={"01110","10001","10001","01111","00001","00001","01110"},
  ["!"]={"00100","00100","00100","00100","00100","00000","00100"}, ["."]={"00000","00000","00000","00000","00000","00110","00110"},
  [":"]={"00000","00110","00110","00000","00110","00110","00000"}, ["-"]={"00000","00000","00000","11111","00000","00000","00000"},
  [" "]={"00000","00000","00000","00000","00000","00000","00000"}
}
local mode, selected, phase = "menu", 1, 0
local cell, bx, by = 20, 176, 38
local board, active, nextKind = {}, nil, nil
local score, lines, level, fallTimer, repeatTimer, gameOver = 0, 0, 1, 0, 0, false
local shapes = {
  I={{{0,1},{1,1},{2,1},{3,1}},{{2,0},{2,1},{2,2},{2,3}}}, O={{{1,0},{2,0},{1,1},{2,1}}},
  T={{{1,0},{0,1},{1,1},{2,1}},{{1,0},{1,1},{2,1},{1,2}},{{0,1},{1,1},{2,1},{1,2}},{{1,0},{0,1},{1,1},{1,2}}},
  S={{{1,0},{2,0},{0,1},{1,1}},{{1,0},{1,1},{2,1},{2,2}}}, Z={{{0,0},{1,0},{1,1},{2,1}},{{2,0},{1,1},{2,1},{1,2}}},
  J={{{0,0},{0,1},{1,1},{2,1}},{{1,0},{2,0},{1,1},{1,2}},{{0,1},{1,1},{2,1},{2,2}},{{1,0},{1,1},{0,2},{1,2}}},
  L={{{2,0},{0,1},{1,1},{2,1}},{{1,0},{1,1},{1,2},{2,2}},{{0,1},{1,1},{2,1},{0,2}},{{0,0},{1,0},{1,1},{1,2}}}
}
local kinds={"I","O","T","S","Z","J","L"}
local function color(h,s,v)
  h=(h%1)*6; local c=v*s; local x=c*(1-math.abs(h%2-1)); local m=v-c
  local r,g,b=0,0,0
  if h<1 then r,g=c,x elseif h<2 then r,g=x,c elseif h<3 then g,b=c,x elseif h<4 then g,b=x,c elseif h<5 then r,b=x,c else r,b=c,x end
  return r+m,g+m,b+m
end
local function rainbow(t) return color(t,0.92,1) end
local function txt(str,x,y,scale,hue,align)
  str=string.upper(str); scale=scale or 2
  local width=#str*6*scale-scale
  if align=="center" then x=x-width/2 end
  for i=1,#str do
    local glyph=FONT[str:sub(i,i)] or FONT[" "]
    for gy=1,7 do for gx=1,5 do if glyph[gy]:sub(gx,gx)=="1" then
      love.graphics.setColor(rainbow(hue+(i*.035)+(gx+gy)*.002))
      love.graphics.rectangle("fill",math.floor(x+(i-1)*6*scale+(gx-1)*scale),math.floor(y+(gy-1)*scale),scale,scale)
    end end end
  end
end
local function bg()
  love.graphics.clear(0.025,0.018,0.075,1)
  -- Moving full-spectrum ribbons, rendered with chunky pixel steps.
  for y=0,H,8 do
    local h=(y/H+phase*.035)%1
    local r,g,b=color(h,.82,.38)
    love.graphics.setColor(r*.7,g*.65,b*.8,.18)
    love.graphics.rectangle("fill",0,y,W,3)
  end
  for i=0,28 do
    local x=(i*83+phase*13)%W; local y=(i*47+math.sin(phase+i)*13)%H
    local r,g,b=rainbow(i/29+phase*.05)
    love.graphics.setColor(r,g,b,.52)
    love.graphics.rectangle("fill",math.floor(x/4)*4,math.floor(y/4)*4,(i%3+1)*2,2)
  end
end
local function panel(x,y,w,h)
  love.graphics.setColor(.07,.045,.16,.95); love.graphics.rectangle("fill",x,y,w,h)
  love.graphics.setColor(rainbow(phase*.06+y*.002)); love.graphics.setLineWidth(2); love.graphics.rectangle("line",x,y,w,h)
end
local function cellsFor(piece)
  local set=shapes[piece.kind]; return set[piece.rot]
end
local function collides(p,dx,dy,rot)
  local cells=shapes[p.kind][rot or p.rot]
  for _,c in ipairs(cells) do
    local x=p.x+c[1]+(dx or 0); local y=p.y+c[2]+(dy or 0)
    if x<1 or x>10 or y>20 then return true end
    if y>=1 and board[y][x] then return true end
  end
  return false
end
local function spawn()
  local kind=nextKind or kinds[love.math.random(#kinds)]; nextKind=kinds[love.math.random(#kinds)]
  active={kind=kind,rot=1,x=4,y=0}
  if collides(active,0,0) then gameOver=true end
end
local function resetGame()
  board={}; for y=1,20 do board[y]={} end
  score,lines,level,fallTimer,gameOver=0,0,1,0,false
  nextKind=nil; spawn(); mode="play"
end
local function lockPiece()
  for _,c in ipairs(cellsFor(active)) do
    local x,y=active.x+c[1],active.y+c[2]
    if y<1 then gameOver=true else board[y][x]=active.kind end
  end
  local cleared=0
  for y=20,1,-1 do
    local full=true; for x=1,10 do if not board[y][x] then full=false; break end end
    if full then table.remove(board,y); table.insert(board,1,{}); cleared=cleared+1; y=y+1 end
  end
  if cleared>0 then lines=lines+cleared; score=score+({0,100,300,500,800})[cleared+1]*level; level=math.floor(lines/10)+1 end
  spawn()
end
local function move(dx,dy)
  if mode~="play" or gameOver then return end
  if not collides(active,dx,dy) then active.x=active.x+dx; active.y=active.y+dy
  elseif dy==1 then lockPiece() end
end
local function rotate(dir)
  if mode~="play" or gameOver then return end
  local n=#shapes[active.kind]; local r=((active.rot-1+dir)%n)+1
  for _,kick in ipairs({0,-1,1,-2,2}) do if not collides(active,kick,0,r) then active.x=active.x+kick; active.rot=r; return end end
end
local function hardDrop()
  if mode~="play" or gameOver then return end
  local n=0; while not collides(active,0,1) do active.y=active.y+1; n=n+1 end
  score=score+n*2; lockPiece()
end
local function action(key)
  if mode=="menu" then
    if key=="up" or key=="down" then selected=3-selected
    elseif key=="return" or key=="space" or key=="z" then if selected==1 then resetGame() else love.event.quit() end end
  elseif mode=="play" then
    if gameOver then if key=="return" or key=="space" or key=="z" then resetGame() elseif key=="escape" or key=="x" then mode="menu" end; return end
    if key=="left" then move(-1,0) elseif key=="right" then move(1,0) elseif key=="down" then move(0,1)
    elseif key=="z" or key=="space" then rotate(1) elseif key=="x" then rotate(-1) elseif key=="return" then hardDrop()
    elseif key=="escape" then mode="menu" end
  end
end
function love.load()
  love.graphics.setDefaultFilter("nearest","nearest"); love.graphics.setBackgroundColor(0.02,0.015,0.06)
  love.window.setMode(W,H,{resizable=false,fullscreen=true,fullscreentype="desktop",vsync=1,msaa=0,highdpi=false})
  love.math.setRandomSeed(os.time())
end
function love.update(dt)
  phase=phase+dt
  if mode=="play" and not gameOver then
    fallTimer=fallTimer+dt; local interval=math.max(.09,.72-(level-1)*.055)
    if fallTimer>=interval then fallTimer=fallTimer-interval; move(0,1) end
    local j=love.joystick.getJoysticks()[1]
    if j then
      local x=j:getGamepadAxis("leftx") or 0
      if math.abs(x)>.55 then repeatTimer=repeatTimer-dt; if repeatTimer<=0 then move(x<0 and -1 or 1,0); repeatTimer=.13 end else repeatTimer=0 end
      local ry=j:getGamepadAxis("righty") or 0; if ry>.7 then move(0,1) end
    end
  end
end
function love.draw()
  local sx,sy=love.graphics.getDimensions(); local scale=math.min(sx/W,sy/H)
  love.graphics.clear(0.01,0.008,0.025,1); love.graphics.push()
  love.graphics.translate((sx-W*scale)/2,(sy-H*scale)/2); love.graphics.scale(scale,scale); bg()
  if mode=="menu" then
    txt("JAWBLADE",320,78,6,phase*.08,"center"); txt("TETRIS",320,146,7,phase*.08+.18,"center")
    txt("A RAINBOW ARCADE GAME",320,213,2,phase*.1+.5,"center")
    for i,label in ipairs({"START","EXIT"}) do
      local y=278+(i-1)*62; panel(234,y,172,42)
      if selected==i then
        love.graphics.setColor(rainbow(phase*.15)); love.graphics.rectangle("fill",241,y+7,4,28)
        txt(label,320,y+13,3,phase*.13,"center")
      else txt(label,320,y+13,3,phase*.13+.4,"center") end
    end
    txt("UP DOWN   A START",320,432,2,phase*.1,"center")
  else
    txt("JAWBLADE TETRIS",320,8,3,phase*.08,"center")
    panel(bx-4,by-4,cell*10+8,cell*20+8)
    -- very subtle rainbow scan through the board
    for y=1,20 do for x=1,10 do
      local px=bx+(x-1)*cell; local py=by+(y-1)*cell; local k=board[y][x]
      love.graphics.setColor(.025,.02,.065,1); love.graphics.rectangle("fill",px+1,py+1,cell-2,cell-2)
      if k then local h=(x*.08+y*.035+phase*.045)%1; local r,g,b=rainbow(h); love.graphics.setColor(r,g,b); love.graphics.rectangle("fill",px+2,py+2,cell-4,cell-4); love.graphics.setColor(1,1,1,.28); love.graphics.rectangle("fill",px+3,py+3,cell-6,3) end
    end end
    if active and not gameOver then
      for _,c in ipairs(cellsFor(active)) do local x,y=active.x+c[1],active.y+c[2]
        if y>=1 then local px=bx+(x-1)*cell; local py=by+(y-1)*cell; local r,g,b=rainbow((phase*.05+x*.075+y*.032)%1); love.graphics.setColor(r,g,b); love.graphics.rectangle("fill",px+2,py+2,cell-4,cell-4); love.graphics.setColor(1,1,1,.45); love.graphics.rectangle("fill",px+3,py+3,cell-6,3) end
      end
    end
    panel(395,58,218,144); txt("NEXT",504,70,2,phase*.1,"center")
    for _,c in ipairs(shapes[nextKind][1]) do local px=465+c[1]*20; local py=111+c[2]*20; local r,g,b=rainbow((phase*.05+c[1]*.1+c[2]*.1)%1); love.graphics.setColor(r,g,b); love.graphics.rectangle("fill",px,py,18,18) end
    panel(395,218,218,118); txt("SCORE",414,234,2,phase*.08); txt(tostring(score),414,258,3,phase*.08+.2)
    txt("LINES",414,292,2,phase*.08+.4); txt(tostring(lines),500,292,2,phase*.08+.6)
    panel(395,350,218,74); txt("LEVEL",414,367,2,phase*.08+.3); txt(tostring(level),520,367,3,phase*.08+.6)
    txt("ARROWS MOVE",504,439,1,phase*.08,"center"); txt("A ROTATE  B DROP",504,455,1,phase*.08+.35,"center")
    if gameOver then
      love.graphics.setColor(0,0,0,.72); love.graphics.rectangle("fill",bx,by+145,200,100)
      txt("GAME OVER",276,220,3,phase*.12,"center"); txt("A RETRY",276,255,2,phase*.12+.4,"center"); txt("B MENU",276,279,2,phase*.12+.7,"center")
    end
  end
  love.graphics.pop()
end
function love.keypressed(key) action(key) end
function love.gamepadpressed(_,button)
  if button=="dpup" then action("up") elseif button=="dpdown" then action("down") elseif button=="dpleft" then action("left") elseif button=="dpright" then action("right")
  elseif button=="a" then action(mode=="play" and "z" or "space") elseif button=="b" then action((mode=="play" and gameOver) and "escape" or (mode=="play" and "return" or "space"))
  elseif button=="start" then action(mode=="menu" and "return" or "escape") elseif button=="back" then action("escape")
  elseif button=="rightshoulder" then action("x") end
end

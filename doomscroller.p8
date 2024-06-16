pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--doomscroller.p8

-------------------------------
-- core functions -------------
-------------------------------

function _init()
	--launch title screen
	init_title()	
end

function _update()
	--game state
	--0=title; 1=game

	if (state==0) update_title()
	if (state==1) update_game()
end

function _draw()
	--game state
	--0=title; 1=game

	if (state==0) draw_title()
	if (state==1) draw_game()
end

-------------------------------
--title functions -------------
-------------------------------
function init_title()
	state=0
	cls(0)    
end

function update_title()
	if (btnp(5)) then
		state=1
		init_game()
	end
end

function draw_title()
	print("doomscroller",38,32,6)
	print("press ❎ to play",30, 48, 6)
end

-------------------------------
--game functions --------------
-------------------------------

function init_game()
	state=1 --gameplay

	map_setup()
	make_player()

	game_win=false
	game_over=false
end

function update_game()
	if (not game_over) then
		update_map()
		move_player()
		check_win_lose()
	else
		if (btnp(5)) extcmd("reset")
	end
end

function draw_game()
	cls()
	if (not game_over) then
		draw_map()
		draw_enemies()
		draw_player()
		if (p.dam) draw_damage()
		draw_hud()
		draw_debug()
	else
		draw_win_lose()
	end

end

-->8
--map code

function map_setup()
	timer=0
	anim_time=30 --30 = 1 sec
	
	solid=0
	door=1
	enemy=2

	init_enemies()
	make_walls()
	place_door()
	--make_floor(1)
end

function make_walls()
	for x=0,127 do
		for y=0,63 do
			if ((x==0) or (x==127)) then
				mset(x,y,2)
			elseif ((y==0) or (y==63)) then
				mset(x,y,2)
			elseif (((rnd(10)) <= 2 ) and ((x>4) or (y>4))) then
				mset(x,y,2)
			end

		end
	end
end

function place_door()
	mset(5,9,3)
end

function make_floor(depth)
	floor={}
	floor.depth=depth
end

function update_map()
	if (timer==anim_time) then
		timer=0
	end
	timer+=1
end

function draw_map()
	mapx=flr(p.x/16)*16
	mapy=flr(p.y/16)*16
	camera(mapx*8,mapy*8)

	map(0,0,0,0,128,64)
end

function is_tile(tile_type,x,y)
	tile=mget(x,y)
	has_flag=fget(tile,tile_type)
	return has_flag
end

function can_move(x,y)
	return not is_tile(solid,x,y)
end

-->8
--player code

function make_player()
	p={}
	p.x=2
	p.y=2
	p.w=8
	p.h=8
	p.hp=5
	p.spr=1
	p.dam=false
	p.dam_anim=0
end

function draw_player()
	spr(p.spr,p.x*p.w,p.y*p.h)
end

function draw_damage()

	p.dam_anim+=7
	if (p.dam_anim<15) then
		spr(16,p.x*p.w,p.y*p.h)
	elseif (p.dam_anim>15) and (p.dam_anim<=30) then
		spr(17,p.x*p.w,p.y*p.h)
	elseif (p.dam_anim>30) and (p.dam_anim<=45) then
		spr(18,p.x*p.w,p.y*p.h)
	elseif (p.dam_anim>45) and (p.dam_anim<=60) then
		spr(19,p.x*p.w,p.y*p.h)
	elseif (p.dam_anim>60) then
		p.dam_anim=0
		p.dam=false
	end

	--p.dam=false
end

function draw_hud()
	hudx=mapx*8
	hudy=mapy*8+119

	rect(hudx,hudy,hudx+127,hudy+8,10)

	spr(48,hudx+2,hudy)
	print(p.hp,hudx+10,hudy+2,10)
end

function draw_debug()
	debugx=mapx*8
	debugy=mapy*8

	rect(debugx,debugy,debugx+22,debugy+8,10)
	print("x="..p.x,debugx+2,debugy+2,8)
	
	rect(debugx+22,debugy,debugx+44,debugy+8,10)
	print("y="..p.y,debugx+24,debugy+2,12)

	rect(debugx+44,debugy,debugx+62,debugy+8,10)
	print("t="..timer,debugx+46,debugy+2,11)

	rect(debugx+62,debugy,debugx+100,debugy+8,10)
	print("dam="..tostr(p.dam),debugx+64,debugy+2,14)
end

function move_player()
	newx=p.x
	newy=p.y

	if (btnp(0)) newx-=1
	if (btnp(1)) newx+=1
	if (btnp(2)) newy-=1
	if (btnp(3)) newy+=1

	interact(newx, newy)

	if (can_move(newx,newy)) then
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,127)
	else
		--sfx(0)
	end
end

function interact(x,y)
	--add code for interactive items

	--take damage from enemies
	if (is_tile(enemy,x,y)) then
		p.hp -= 1
		p.dam=true
		sfx(1)
		--rectfill(0,0,127,127,8)
	end
end

-->8
--enemy code
function init_enemies()
	e={}
	e.x=13
	e.y=2
	e.hp=3
	e.spr=32
	e.h=8
	e.w=2
end

function draw_enemies()
	--spr(e.spr,e.x*e.w,e.y*e.h)
	mset(e.x,e.y,e.spr)
end

-->8
--win/lose code

function check_win_lose()
	if (p.hp == 0) then
		game_win=false
		game_over=true
	end
	if (is_tile(door,p.x,p.y)) then
		game_win=true
		game_over=true
	end
end

function draw_win_lose()
	if (game_win) then
		print("★ you win! ★",37,64,7)
	else
		print("game over! :(",38,64,7)
	end
	print("press ❎ to play again",20,72,5)
end

__gfx__
0000000000666000d111111dd111111ddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006660001515555114444441dd1ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006660001555555114444441dddddd5d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666001555115114444441dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000606660601555555114444041ddd5dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006660001511555114444441dd5ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006060001555555114444441dddddd1d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000606000d111111d14444441dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000800008080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000008008000800008080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000008008000800008080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000800008080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888888080000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000088888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddbdddb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd8dd8dddddddbdd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd8888ddbd3333db0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d882288dd333443d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88822888d433443d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d888888d344333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd8888dd333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd8dd8dddffffffd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd4444dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddd77ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08808800dd7dd7dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880d788887d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880d788787d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800d788887d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000d788887d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000dd7777dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
40404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
__gff__
0001010200000000000000000000000000000000000000000000000000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404030404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
0404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
__sfx__
000100001a0401b0401b0401b0401b0401b0401b0401b040100000e0000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002805023050200501c05019050160501405015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

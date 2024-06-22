pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--picodoom
--doomscroller pico test env

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
	spr(50,59,16)
	print("picodoom",48,32,6)
	print("press ❎ to test",30, 48, 6)
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
		draw_player()
		draw_hud()
	else
		draw_win_lose()
	end

end

-->8
--map code

function map_setup()
	timer=0
	anim_time=30 --30 = 1 sec

	--flags	
	solid=0
	door=1
	enemy=2
	heal=3
end

function update_map()

end

function draw_map()
	mapx=flr(p.x/16)*16
	mapy=flr(p.y/16)*16
	
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
	if (is_tile(heal,x,y)) then
		p.hp+=3
		mset(x,y,0)
		sfx(0)
	end

	--take damage from enemies
	if (is_tile(enemy,x,y)) then
		p.hp -= 1
		p.dam=true
		sfx(1)
		--rectfill(0,0,127,127,8)
	end
end

function draw_hud()
	hudx=mapx*8
	hudy=mapy*8+119

	rect(hudx,hudy,hudx+14,hudy+8,10)

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

	--rect(debugx+44,debugy,debugx+86,debugy+8,10)
	--print("heal="..tostr(is_tile(heal,p.x,p.y)),debugx+46,debugy+2,11)

	--rect(debugx+44,debugy,debugx+62,debugy+8,10)
	--print("t="..timer,debugx+46,debugy+2,11)

	--rect(debugx+62,debugy,debugx+100,debugy+8,10)
	--print("dam="..tostr(p.dam),debugx+64,debugy+2,14)

	rect(debugx+44,debugy,debugx+70,debugy+8,10)
	print("#ent="..tostr(count(ent)),debugx+46,debugy+2,11)

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
00000000000000000111111000800800099999900002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001000000108888880900000090002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700033333301000000188888888900000090002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700003b33b301000000108888880900000092222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000033333301000000108888880900000092222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700033bb3301000000188888888900000090002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000033333301000000108888880900000090002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003003000111111000800800099999900002200000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
08808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010502080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000300000000030000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200030000000000050000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020204020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001a0401b0401b0401b0401b0401b0401b0401b040100000e0000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002805023050200501c05019050160501405015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

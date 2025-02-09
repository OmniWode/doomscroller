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
		draw_player()
		draw_hud()
		draw_log()
		--draw_debug()
	else
		draw_win_lose()
	end

end

-->8
--map code

function map_setup()
	timer=0
	anim_time=30 --30 = 1 sec

	level=0
	room={}
	room.stairx=4
	room.stairy=4
	room.num_enem=3
	room.actors={}

	--flags	
	solid=0
	stair=1
	enemy=2
	heal=3
	win=4
end

function update_map()

end

function draw_map()
	if (level==0) then
		mapx=0
		mapy=0
		mset(mapx+room.stairx,mapy+room.stairy,18)
		cls(11)
	else
		if (level%2==0) then
			cls(2)
		else
			cls(0)
		end

		--clear_room(mapx,mapy) --is this being called too often?
		set_room(mapx,mapy)

	end


	map(mapx,mapy,0,0,16,16)

end


function is_tile(tile_type,x,y)
	tile=mget(x,y)
	has_flag=fget(tile,tile_type)
	return has_flag
end


function can_move(x,y)
	return not is_tile(solid,x,y)
end


function new_level()
	level+=1
	sfx(0)

	--mapx=16
	--mapy=0

	--p.x=18
	--p.y=2

	--clear_room(mapx,mapy)
	reset_room(mapx,mapy)

	if (level%5==1) then
		mapx=0
		mapy=16
	elseif (level%5==2) then
		mapx=16
		mapy=16
	elseif (level%5==3) then
		mapx=32
		mapy=16
	elseif (level%5==4) then
		mapx=48
		mapy=16
	elseif (level%5==0) then
		mapx=64
		mapy=16
	else
		stop("you broke math")
	end

	p.x=mapx+2
	p.y=mapy+2


	--clear_room(mapx,mapy)
	make_room()
end


function make_room()


	room.actors={}

	for i=1,room.num_enem do
		local e=make_enemy()
		add(room.actors,e)
	end

	-- stairs last to make sure an enemy doesn't
	-- spawn on top
	room.stairx=6+flr(rnd(3))
	room.stairy=6+flr(rnd(6))

end

--TO DO: make this smarter
function set_room(mapx,mapy)
	mset(mapx+room.stairx,mapy+room.stairy,18)

	for a in all(room.actors) do
		mset(a.x,a.y,a.spr)
	end

end

-- should mirror set_room!!!!
function reset_room(mapx,mapy)
	mset(mapx+room.stairx,mapy+room.stairy,0)

	for a in all(room.actors) do
		mset(a.x,a.y,0)
	end

end


function clear_room(mapx,mapy)
	for i=1,14 do
		for j=1,14 do
			mset(mapx+i,mapy+j,0)
		end
	end

end

function make_enemy()
	local e={}
	e.x=(4+flr(rnd(5)))+mapx
	if (e.x==room.stairx) e.x-=2

	e.y=(4+flr(rnd(8)))+mapy
	if (e.y==room.stairy) e.y-=2

	e.spr=3
	e.hp=3

	return e
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
	spr(p.spr,(p.x%16)*p.w,(p.y%16)*p.h)
end

function move_player()
	newx=p.x
	newy=p.y

	if (btnp(0)) newx-=1
	if (btnp(1)) newx+=1
	if (btnp(2)) newy-=1
	if (btnp(3)) newy+=1

	--interact(newx, newy)
	
	if (can_move(newx,newy)) then
		p.x=newx
		p.y=newy
	else
		interact(newx, newy)
	end
end

function interact(x,y)
	--take healing potion
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

	--use stairs
	if (is_tile(stair,x,y)) then
		new_level()
		--p.hp+=1
	end

	--win game
		if (is_tile(win,x,y)) then
		game_win=true
		game_over=true
	end
end

function draw_hud()
	hudx=96
	hudy=0

	-- draw frame
	rectfill(hudx,hudy,hudx+31,hudy+63,0)	
	rect(hudx,hudy,hudx+31,hudy+63,8)

	-- player health
	spr(48,hudx+2,hudy+2)
	print(p.hp,hudx+12,hudy+4,10)

	-- current level
	print("lvl="..tostr(level),hudx+2,hudy+12,10)

end

function draw_log()
	logx=96
	logy=64

	-- draw frame
	rectfill(logx,logy,logx+31,logy+63,0)
	rect(logx,logy,logx+31,logy+63,10)
end

function old_draw_hud()
	hudx=0
	hudy=119

	rect(hudx,hudy,hudx+14,hudy+8,10)

	spr(48,hudx+2,hudy)
	print(p.hp,hudx+10,hudy+2,10)

	-- mapx and mapy
	rect(hudx+70,hudy,hudx+100,hudy+8,10)
	print("mapx="..tostr(mapx),hudx+72,hudy+2,10)
	rect(hudx+100,hudy,hudx+127,hudy+8,10)
	print("mapy="..tostr(mapy),hudx+102,hudy+2,10)

	-- number of actors
	--rect(hudx+100,hudy,hudx+127,hudy+8,10)
	--print("#act="..tostr(#room.actors),hudx+102,hudy+2,10)

end

function draw_debug()
	debugx=0
	debugy=0

	-- player location
	rect(debugx,debugy,debugx+22,debugy+8,10)
	print("x="..p.x,debugx+2,debugy+2,8)
	rect(debugx+22,debugy,debugx+44,debugy+8,10)
	print("y="..p.y,debugx+24,debugy+2,12)

	-- current level
	rect(debugx+44,debugy,debugx+70,debugy+8,10)
	print("lvl="..tostr(level),debugx+46,debugy+2,11)

	-- current mapx and mapy 
	--rect(debugx+70,debugy,debugx+100,debugy+8,10)
	--print("mapx="..tostr(mapx),debugx+72,debugy+2,10)
	--rect(debugx+100,debugy,debugx+127,debugy+8,10)
	--print("mapy="..tostr(mapy),debugx+102,debugy+2,10)

	-- current stair location
	rect(debugx+70,debugy,debugx+100,debugy+8,10)
	print("strx="..tostr(room.stairx),debugx+72,debugy+2,10)
	rect(debugx+100,debugy,debugx+127,debugy+8,10)
	print("stry="..tostr(room.stairy),debugx+102,debugy+2,10)
end

-->8
--win/lose code

function check_win_lose()
	if (p.hp == 0) then
		game_win=false
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
000000000008800001111110001001000999999000022000bbbbbbbbbbbbbbbbb333333b00000000000000000000000000000000000000000000000000000000
000000000088880010000001011111109999999900022000bbbbbbbbbbbb3bbb3338333300000000000000000000000000000000000000000000000000000000
007007000666666010000001118118111199999900022000bbbbbb3bbbbbbbbb3333333300000000000000000000000000000000000000000000000000000000
000770000656656010000001011111109999999922222222bbbbbbbbbbbbbbbb3333333300000000000000000000000000000000000000000000000000000000
000770000666666010000001011881109999919922222222bb3bbbbbbbbbbbbb3833333800000000000000000000000000000000000000000000000000000000
007007000665566010000001118118111199999900022000b3bbbbbbbbbbbb5b3333333300000000000000000000000000000000000000000000000000000000
000000000666666010000001011111109999999900022000bbbbbbbbb3bbbbbbbbb44bbb00000000000000000000000000000000000000000000000000000000
000000000060060001111110001001000999999000022000bbbbbbbbbbbbbbbbbbb44bbb00000000000000000000000000000000000000000000000000000000
006660000555555011000000000000000aaaaaa000000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
00666000544444451100000000000000aaaaaaaa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
00666000544444451111000000000000aa0aa0aa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
06666600544445451111000000000000aaaaaaaa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
60666060544445451111110000000000aa0aa0aa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
00666000544444451111110000000000aaa00aaa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
00606000544444451111111100000000aaaaaaaa00000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
006060000555555011111111000000000aaaaaa000000000bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000577777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08808800000000005777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880000000005755755700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880000000005755755700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888800000000005777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000000000005577777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000000000575757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010503080000010000000000000001020300100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0808080808080808080808080000000002020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0816061606060606161606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0806071607070807161606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0806161606060606161606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0806060706160707070607080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0806061607070616060606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0806060706060616161606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0816060608071616070707080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0816160707060606070716080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807070716070706160606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807160606060707070807080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807071607071616070606080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807070808080707071607080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807080716081607161616080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0807161607080707160707080000000002000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808080808080808080000000002020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020000000002020202020202020202020200000000020202020202020202020202000000000202020202020202020202020000000002020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002000000000000020000000002000000020000000000000200000000020000000200000000000002000000000200000002000000000000020000000002000000020000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002000200000000020000000002000000020002020000000200000000020000000200020202000002000000000200000002000202020000020000000002000000020002020200000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000002000000000000020000000002000000020000000000000200000000020000000200000000000002000000000200000002000200000000020000000002000000020002020000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202000202000000000000020000000002020002020000000000000200000000020200020200000000000002000000000202000202000000000000020000000002020002020000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000020000000002000000000000000000000200000000020000000000000000000002000000000200000000000000000000020000000002000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020000000002020202020202020202020200000000020202020202020202020202000000000202020202020202020202020000000002020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001a0401b0401b0401b0401b0401b0401b0401b040100000e0000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002805023050200501c05019050160501405015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

*-----------------------------------------------------------
* Title      : Motorola Magical Maze Murder Mayhem
* Written by : Igor Antonov
* Date       : 29/01/2024
* Description: This could become a great game
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
PLAYER_SPEED EQU 20

* Put program code here

	bsr enableDoubleBuffering
BIGLOOP:
	bsr clearScreen
	bsr processGameInput
	;let's try drawing a 2d triangle
	lea example_triangle, A0
	lea example_triangle+4, A1
	lea example_triangle+8, A2
	bsr render2DWireframeTriangle
	bsr processInteractions
	
	bsr processFov
	
	lea example_map, A1
	bsr drawMap
	

	bsr getPlayerStateStr
	bsr putStr
	bsr repaintScreen
	bra BIGLOOP
	
DEATHLOOP:
	bsr clearScreen
	bsr putStr ; printing cause of death from A1
	bsr repaintScreen
	bra DEATHLOOP
		
	
SIMHALT             ; halt simulator
* Put variables and constants here
processGameInput:
	;CHECK FOR SPACE
	MOVE.B ACTION_BUTTON, D1
	bsr areKeysPressed
	move.b D1, IS_ACTION_PRESSED
	;check for + or -
	move.b #'O', D1
	lsl.l #8, D1
	move.b #'P', D1
	bsr areKeysPressed
	cmp.l #8, fov_distance
	bge .minus
	cmp.b #$FF, D1
	bne .minus
	add.l #1, fov_distance
.minus
	cmp.l #3, fov_distance
	ble .dirmove
	lsr.l #8, D1
	cmp.b #$FF, D1
	bne .dirmove
	sub.l #1, fov_distance
	;CHECK FOR DIRECTIONAL MOVEMENT
.dirmove
	move.b #'W', D1
	LSL.l #8, D1
	move.b #'S', D1
	LSL.l #8, D1
	move.b #'A', D1
	LSL.l #8, D1
	move.b #'D', D1
	bsr areKeysPressed
	cmp.b #$FF, D1
	BNE end_pgi
	add.b #1, player_theta
end_pgi:
	lsr.l #8, d1
	move.b d1, d0
	and #1, d0
	sub.b d0, player_theta
.backwards
	lsr.l #8, d1
	cmp.b #$FF, D1
	bne .forwards
	lea example_map, A1
	move.b player_theta, D1
	bsr sine
	neg.w d1
	asr.w #4, d1
	add.w player_position, d1
	move.w d1, -(SP)
	move.b player_theta, D1
	bsr cosine
	neg.w d1
	asr.w #4, d1
	add.w player_position+4, d1
	move.w d1, d2
	move.w (SP)+, D1 ; nice got the potential positions in registers
	move.w D1, -(SP)
	move.w D2, -(SP)
	add.w #128, D1
	add.w #128, d2
	asr.w #8, D1
	asr.w #8, d2
	bsr isPassable
	cmp.b #$FF, D0
	BNE .backwards_fail
	move.w (SP)+, D2
	move.w (SP)+, D1
	move.w D1, player_position
	move.w D2, player_position+4
	bra .end
.backwards_fail
	add.l #4, SP
	bra .end
.forwards
	lsr.l #8, d1
	cmp.b #$FF, D1
	bne .end
	lea example_map, A1
	move.b player_theta, D1
	bsr sine
	asr.w #4, d1
	add.w player_position, d1
	move.w D1, -(SP)
	move.b player_theta, D1
	bsr cosine
	asr.w #4, d1
	add.w player_position+4, d1
	move.w d1, d2
	move.w (SP)+, D1
	move.w D1, -(SP)
	move.w D2, -(SP)
	add.w #128, d1
	add.w #128, d2
	asr.w #8, d1
	asr.w #8, D2
	cmp.b #$FF, IS_ACTION_PRESSED
	bne .no_action
	bsr processAction
.no_action
	bsr isPassable
	cmp.b #$FF, D0
	bne .forwards_fail
	move.w (SP)+, D2
	move.w (SP)+, D1
	move.w D1, player_position
	move.w D2, player_position+4
	bra .end
.forwards_fail
	add.l #4, SP
.end
	rts

processAction: ;all action is performing by pressing forward and pressing the action button.
	bsr getMapTile
	cmp.b #'+', D0
	bne .not_door
	move.b #'/', D0
	bsr setMapTile 
	bra .end
.not_door
	cmp.b #'`', D0 ; sokoban crate
	bne .not_crate
	bsr canPush
	cmp.b #$FF, D0
	bne .end
	move.b '.', D0
	bsr setMapTile
	bsr getPushLoc
	bsr getMapTile
	bsr getTileAfterPush ; whether it is '.' or ';'
	bsr setMapTile
.not_crate
	cmp.b #';', D0 ; sokoban crate in hole
	bne .not_crateh
	bsr canPush
	cmp.b #$FF, D0
	bne .end
	move.b #',', D0
	bsr setMapTile
	bsr getPushLoc
	bsr getMapTile
	bsr getTileAfterPush ; whether it is '.' or ';'
	bsr setMapTile
.not_crateh
	cmp.b #'t', D0 ; pickaxe
	bne .dig
	move.b #'.', D0
	bsr setMapTile
	move.w #PS_PICKAXE, player_state
	move.w #3, pickaxe_health
	bra .end
.dig
	cmp.b #'#', D0
	bne .end
	cmp.w #PS_PICKAXE, player_state
	bne .end
	move.b #'.', D0
	bsr setMapTile
	sub.w #1, pickaxe_health
	cmp.w #0, pickaxe_health
	bge .end
	move.w #PS_BARE_HANDS, player_state
.end
	rts

canPush: ; args: D1.b - x, D2.b - z, A1 - the map
	move.l D1, -(SP)
	move.l D2, -(SP)
	
	bsr getPushLoc
	bsr isPassable
	
	move.l (SP)+, D2
	move.l (SP)+, D1
	rts

getPushLoc: ;args: D1 - x, D2 - z, A1 - the map
	move.l D3, -(SP)
	move.l D4, -(SP)
	
	move.w player_position, D3
	move.w player_position+4, D4
	add.w #128, D3
	add.w #128, D4
	asr.w #8, D3
	asr.w #8, D4
	
	neg.b d3
	neg.b d4
	add.b d1, d3
	add.b d2, d4 ;now we've got push direction vector (d3, d4)
	
	add.b d3, d1
	add.b d4, d2 ; could be optimised by bitshifting d1, d2 by 1 at the start
	; whatever, we're done here, time to return
	move.l (SP)+, D4
	move.l (SP)+, D3
	rts


getTileAfterPush: ; args: d0.b - tile before crate was pushed onto it
	cmp.b #',', D0
	bne .floor
	move.b #';', D0
	bra .end
.floor
	move.b #'`', D0

.end
	rts
	



processInteractions:
	move.w player_position, d1
	move.w player_position+4, d2
	lea example_map, A1
	add.w #128, d1
	add.w #128, d2
	asr.w #8, D1
	asr.w #8, d2
	bsr getMapTile

	cmp.b #',', D0
	bne .no_crater
	move.w #$40, player_position+2
	bra .spikedeath
.no_crater
	move.w #$80, player_position+2
.spikedeath
	cmp.b #'^', D0
	bne .sliwall_kill
	lea death_spike_message, A1
	bsr killPlayer
.sliwall_kill:
	cmp.b #'#', D0
	bne .osci_spike
	lea death_wall_message, A1
	bsr killPlayer
.osci_spike
	move.w magic_counter, D1
	cmp.b #0, D1
	bge .hide_spike
.show_spike
	move.b #'^', example_map+28
	bra .sliding_wall
.hide_spike
	move.b #'.', example_map+28
.sliding_wall
	move.w magic_counter, d1
	lsr.b #6, D1
	move.b #'.', example_map+42
	move.b #'.', example_map+43
	move.b #'.', example_map+44
	move.b #'.', example_map+45
	lea example_map+42, A1
	and.l #$000000FF, D1
	add.l D1, A1
	move.b #'#', (A1)
.end
	ADD.W #1, magic_counter
	rts
	

areKeysPressed: ;args: D1.l - 4 key codes; returns: d1.l - 4 booleans
	move.b #19, D0
	trap #15
	rts

drawLine: ; draws line from (D1.w, D2.w) to (D3.w, D4.w) 
    move.l #84, D0
    trap #15
    rts
    
enableDoubleBuffering:
    move.l #92, D0
    move.l D1, -(SP)
    move.b #17, D1
    trap #15
    move.l (SP)+, D1
    rts
   
    
repaintScreen:
    move.l #94, D0
    trap #15
    rts
    
clearScreen:
    move.l #11, D0
    move.w D1, -(SP)
    move.w #$FF00, D1
    trap #15
    move.w (SP)+, D1
    rts
    
setPenWidth: ; args: d1 - width
    move.b #93, d0
    trap #15
    rts
    
drawPixel: ; args: d1 - x, d2 - y
    move.b #82, d0
    trap #15
    rts
    
putStr: ;args: (A1) - a null-terminated string
	move.b #14, D0
	trap #15
	rts
    
projectPoint: ;args: a0 - point address, a1 - player position, a2 - point offset; results: d1 - x, d2 - y,
	move.l d7, -(SP)
	move.w 4(a0), d6
	sub.w 4(a1), d6 ; z_point - z_player
	ADD.W 4(A2), D6 ; z_point - z_player + POINT OFFSET
		
	move.w 0(a0), d1 ; x
	sub.w 0(a1), d1 ; x_point - x_player
	ADD.W 0(A2), D1 ; + POINT OFFSET
	;rotation stuff for x axis
	move.w d1, -(SP) ; extra original x1 value ;a
	MOVE.W D1, -(SP) ; b
	move.b player_theta, D1
	bsr cosine
	muls (SP)+, D1 ; b.
	ASR.L #8, D1 ; cos(a) * x1 calculated
	move.w d1, -(SP) ;c
	move.b player_theta, D1
	bsr sine
	muls D6, D1
	ASR.L #8, D1
	NEG.W D1 ;-sin(a) * z1 calculated
	ADD.W (SP)+, D1 ;c.
	move.w D1, D7 ; save d1 to d7
	;end rotation stuff
	;rotation stuff
	move.b player_theta, D1
	bsr cosine
	MULS D1, D6
	ASR.L #8, D6  ; cos(a) * z1  calculated
	MOVE.B player_theta, D1
	bsr sine 
	MULS (SP)+, D1 ; retrieve extra original x1 value here; a.
	asr.l #8, D1 ;sin(b) * x1 calculated
	ADD.w D1, D6
	move.w d7, d1 ; retrieve post-rotation x
	
	and.l #$0000FFFF, D1
	and.l #$0000FFFF, D6
	;end rotation stuff
	;make sure z isn't zero
	cmp.w #1, D6
	bge .all_good
	move.w #1, d6 ; in case it's 0 or lower. a bit glitchy but who gives a shit.
.all_good

	
	muls #SIN_60, D1
	divs D6, D1
	and.l #$0000FFFF, D1
	
	move.w 2(a0), D2 ; y
	sub.w 2(a1), D2 ; y_point- y_player
	ADD.W 2(A2), D2 ; + POINT OFFSET
	
	muls.w #SIN_60, D2
	divs.w D6, D2
	and.l #$0000FFFF, D2
	
	move.l (SP)+, D7
	rts
	
viewportToScreen: ;args; d1 - x, d2 - y, ;results - d1 - x_screen, d2 - y_screen
	muls #SCREEN_WIDTH, D1
	asr.l #1, D1 ; convert from fixed point <<8 to integer
	
	muls #SCREEN_WIDTH, D2
	asr.l #1, D2 ; adjust so it's and integer too
	
	add.w #SCREEN_HCENTER, D1
	neg.w D2
	add.w #SCREEN_VCENTER, D2
	
	rts

killPlayer: ; a1 - message with cause of death
	bra DEATHLOOP

renderPoint:
	bsr projectPoint
	bsr viewportToScreen
	bsr drawPixel
	rts

render2DWireframeTriangle: ;args: A0, A1, A2 - p1, p2, p3
	move.w 0(A0), D1
	move.w 2(A0), D2
	move.w 0(A1), D3
	move.w 2(A1), D4
	bsr drawLine
	move.w 0(A2), D3
	move.w 2(A2), D4
	bsr drawLine
	move.w 0(A1), D1
	move.w 2(A1), D2
	bsr drawLine
	rts

projectAllModelVertices: ;args: A0 - model address, A1 - where to write the points, A2 - OFFSET
	move.l a1, -(SP)
	clr.l D7
	move.b 0(A0), D7 ; vertex number
	sub.b #1, D7
	move.b #0, D6 ; current vertex
	ADD.L #2, A0
.loop
	move.l A1, -(SP)
	lea player_position, A1
	bsr projectPoint
	bsr viewportToScreen
	move.l (SP)+, A1
	move.w D1, 0(A1)
	move.w D2, 2(A1)
	add.l #4, A1
	add.l #6, A0
	DBRA D7, .loop
	move.l (SP)+, A1
	rts

drawAllTriangles: ;args: A0 - model address A1 - projected points, A2 - MODEL OFFSET
	clr.l d7
	clr.l d6
	move.b 1(a0), d7 ; number of triangles
	sub.b #1, D7
	move.b 0(A0), d6 ; number of points
	asl.b #1, d6
	muls #3, d6 ;every point is three words
	add.l #2, A0
	add.l d6, A0 ; now it's the triangle starting address
.loop
	clr.l d1
	clr.l d2
	clr.l d3
	lea 0, a2
	;load p1 address
	move.b 0(A0), D1 ;load point number
	asl.w #2, D1 ; every point is 4 bytes
	add.l A1, D1
	;add point number to point origin address
	;load p2 address
	move.b 1(A0), D2
	asl.w #2, D2 ; every point is 4 bytes
	add.l A1, D2
	;load p3 address
	move.b 2(A0), D3
	asl.w #2, D3 ; every point is 4 bytes
	add.l A1, D3
	
	move.l A0, -(SP)
	move.l A1, -(SP)
	move.l d1, a0
	move.l d2, a1
	move.l d3, a2
	bsr render2DWireframeTriangle
	move.l (SP)+, A1
	move.l (SP)+, A0
	

	add #3, A0 ;let's go on to the next triangle, every triangle is 3 bytes
	DBRA D7, .loop

	rts
	
charToModel: ;args d0.b - map cell char ; returns: A0 - model address
	cmp.b #'#', d0
	beq .wall
	cmp.b #'%', d0
	beq .wall
	cmp.b #'^', d0
	beq .death_spike
	cmp.b #'t', d0
	beq .tv_set

	cmp.b #'+', d0
	beq .closed_door
	cmp.b #'`', d0
	beq .crate
	cmp.b #';', d0
	beq .crateh
	cmp.b #',', d0
	beq .crater
.floor
	lea floor_tile, a0
	bra .end
.death_spike
	lea death_spike, a0
	bra .end
.wall
	lea boring_wall, a0
	bra .end
.closed_door
	lea closed_door, a0
	bra .end
.crate
	lea crate, a0
	bra .end
.crateh
	lea crateh, a0
	bra .end
.crater
	lea crater, a0
	bra .end
.tv_set
	lea tv_set, a0
.end
	rts

isPassable: ;args: d1. b - x, d2.b - z, a1 - the map; returns - D0.b - if passable or not
	bsr getMapTile
	cmp.b #'#', d0
	beq .impassable
	cmp.b #'%', d0
	beq .impassable
	cmp.b #'+', d0
	beq .impassable

	cmp.b #'`', d0
	beq .impassable
	cmp.b #';', d0
	beq .impassable
.passable
	move.b #$FF, D0
	bra .end
.impassable
	move.b #$00, D0
.end
	rts
	
mapModelOffset: ; args: d1.b - x, d2.b - z, A2 - wrere to write offset to; returns A2 - offset address
	asl.w #8, d1
	asl.w #8, d2
	move.w d1, 0(A2)
	move.w d2, 4(A2)
	move.w #0, 2(A2)
	asr.w #8, d1
	asr.w #8, d2
	rts

getMapTile: ; args: d1.b - x, d2.b - z, A1 - the map ; returns: D0.b - map cell char
	move.l d1, -(SP)
	move.l d2, -(SP)
	move.l A1, -(SP)
	and.l #$000000FF, D1
	and.l #$000000FF, D2

	move.w #$FFFF, D0
	lsl.w #MAP_Z_BITSHIFT, D2
	lsr.b #(8-MAP_Z_BITSHIFT), D0
	and.b D0, D1
	add.w D2, D1
	and.l #$0000FFFF, D1
	add.l D1, A1
	move.b (A1), D0
	
	move.l (SP)+, A1
	move.l (SP)+, D2
	move.l (SP)+, D1
	rts

setMapTile: ; args: d1.b - x, d2.b - z, A1 - the map, D0.b - map cell char to set the value to
	move.l d1, -(SP)
	move.l d2, -(SP)
	move.l A1, -(SP)
	move.b D0, -(SP)
	and.l #$000000FF, D1
	and.l #$000000FF, D2

	move.w #$FFFF, D0
	lsl.w #MAP_Z_BITSHIFT, D2
	lsr.b #(8-MAP_Z_BITSHIFT), D0
	and.b D0, D1
	add.w D2, D1
	and.l #$0000FFFF, D1
	add.l D1, A1
	move.b (SP)+, (A1)
	
	move.l (SP)+, A1
	move.l (SP)+, D2
	move.l (SP)+, D1
	rts

drawMap: ;args: A1 - the map
	;init
	clr.l D1
	clr.l D2
	
.loop
	;check if tile is visible
	move.l A1, -(SP)
	lea fov_map, A1
	bsr getMapTile
	move.l (SP)+, A1
	cmp.b #$FF, D0
	bne .continue ; if the square isn't lit, skip it.
	;end fov check
	lea player_position, A6
	move.w 4(A6), D7
	add.w #128, D7
	asr.w #8, D7 ;round player z to an integer
	cmp.b D2, D7 ;if the cell z is equal to players z
	bne .x_ok
.z_ok
	move.w 0(A6), D7
	add.w #128, D7
	asr.w #8, d7
	cmp.b D1, D7
	beq .continue
.x_ok
	;retrieve tile
	bsr getMapTIle 
	;draw model
	bsr charToModel
	move.l A0, A6
	lea $9000, A2 ; model offset for now
	bsr mapModelOffset
	move.l A1, -(SP) ; push map
	move.b d1, -(SP)
	move.b d2, -(SP)
	lea $9100, A1 ; model vertices for now
	move.l A0, -(SP)
	move.l A6, A0
	bsr projectAllModelVertices
	lea $9100, A1
	move.l (SP)+, A0
	move.l A6, A0
	bsr drawAllTriangles
	move.b (SP)+, D2
	move.b (SP)+, D1
	move.l (SP)+, A1 ; pop map
	;update coords
.continue
	add.b #1, d1
	cmp.b #(MAP_SIDE-1), D1
	
	ble .loop

	
	move.b #0, D1 ; x goes to 0 again
	add.b #1, D2 ; z increases
	cmp.b #(MAP_SIDE), D2 ; are we on last row?
	bge .end ; if we finished the last row we end
	
	;goto loop
	bra .loop
.end
	rts

getPlayerStateStr: 
	cmp.w #PS_PICKAXE, player_state
	bne .bare_hands
	lea holding_pickaxe_msg, A1
	bra .end
.bare_hands
	lea bare_handed_msg, A1
.end
	rts
    
	INCLUDE "sin.x68"

    
; constants
example_triangle:
	dc.w 5, 5
	dc.w 120, 5
	dc.w 5, 60

example_model:
num_vertices dc.b 5
num_triangles: dc.b 6
pyramid_vertices:
    dc.w -128, 0, -128
    dc.w -128, 0, 128
    dc.w 128, 0, -128
    dc.w 128, 0, 128
    dc.w 0, $180, 0
pyramid_triangles:
    dc.b 0, 1, 2
    dc.b 2, 3, 1
    dc.b 0, 4, 1
    dc.b 1,4,3
    dc.b 2,4, 3
    dc.b 2, 4, 0
    
boring_wall:
	dc.b 8 ; 8 vertices
	dc.b 8 ;8 tringles
	;vertices (lower)
	dc.w -128, 0, 128
	dc.w 128, 0, 128
	dc.w 128, 0, -128
	dc.w -128, 0, -128
	;also vertices (upper)
	dc.w -128, $180, 128
	dc.w 128, $180, 128
	dc.w 128, $180, -128
	dc.w -128, $180, -128

	;time for triangles
	;frontal face
	dc.b 3, 7, 2
	dc.b 2, 6, 7
	;left face
	dc.b 0, 4, 3
	dc.b 3, 7, 4
	;right face
	dc.b 1, 5, 2
	dc.b 2, 6, 5
	;back face
	dc.b 1, 5, 0
	dc.b 0, 4, 5
	
	
    
floor_tile:
	dc.b 4 ;v
	dc.b 2 ;t
	dc.w -127, 0, 127 ; vertices
	dc.w 127, 0, 127
	dc.w 127, 0, -127
	dc.w -127, 0, -127
	dc.b 0, 1, 2 ; triangles
	dc.b 2, 3, 0
	
death_spike:
	dc.b 5
	dc.b 6	
    dc.w -32, 0, -32
    dc.w -32, 0, 32
    dc.w 32, 0, -32
    dc.w 32, 0, 32
    dc.w 0, $100, 0
    dc.b 0, 1, 2
    dc.b 2, 3, 1
    dc.b 0, 4, 1
    dc.b 1,4,3
    dc.b 2,4, 3
    dc.b 2, 4, 0
    
tv_set:
	dc.b 10
	dc.b 5
	dc.w -64, 0, 0 ;left leg
	dc.w 64, 0, 0 ; right leg
	dc.w 0, 64, 0 ; leg fixture
	dc.w -128, 64, 0 ; lower left corner
	dc.w 128, 64, 0 ;lower right corner
	dc.w 128, 196, 0 ; upper right corner
	dc.w -128, 196, 0 ; upper left corner
	dc.w 0, 196, 0 ; antenna fixture
	dc.w -128, 256, 0 ; left antenna
	dc.w 128, 256, 0 ;right antenna
	dc.b 0, 1, 2 ;legs
	dc.b 3, 4, 5 ;monitor half
	dc.b 5, 6, 3 ;monitor half
	dc.b 9, 7, 7
	dc.b 8, 7, 7
	
	dc.b 0 ; word alignment junk

closed_door:
	dc.b 4
	dc.b 2
	dc.w 0, 0, 128
	dc.w 0, 0, -128
	dc.w 0, $180, 128
	dc.w 0, $180, -128
	dc.b 0, 1, 2
	dc.b 1, 2, 3
	
crate:
	dc.b 8 ; 8 vertices
	dc.b 10 ;8 tringles
	;vertices (lower)
	dc.w -128, 0, 128
	dc.w 128, 0, 128
	dc.w 128, 0, -128
	dc.w -128, 0, -128
	;also vertices (upper)
	dc.w -128, $80, 128
	dc.w 128, $80, 128
	dc.w 128, $80, -128
	dc.w -128, $80, -128

	;time for triangles
	;frontal face
	dc.b 3, 7, 2
	dc.b 2, 6, 7
	;left face
	dc.b 0, 4, 3
	dc.b 3, 7, 4
	;right face
	dc.b 1, 5, 2
	dc.b 2, 6, 5
	;back face
	dc.b 1, 5, 0
	dc.b 0, 4, 5
	;upper face
	dc.b 4, 5, 6
	dc.b 4, 7, 6

crater:
	dc.b 4 ;v
	dc.b 2 ;t
	dc.w -127, -64, 127 ; vertices
	dc.w 127, -64, 127
	dc.w 127, -64, -127
	dc.w -127, -64, -127
	dc.b 0, 1, 2 ; triangles
	dc.b 2, 3, 0
	
crateh:
	dc.b 8 ; 8 vertices
	dc.b 10 ;8 tringles
	;vertices (lower)
	dc.w -128, 0, 128
	dc.w 128, 0, 128
	dc.w 128, 0, -128
	dc.w -128, 0, -128
	;also vertices (upper)
	dc.w -128, $40, 128
	dc.w 128, $40, 128
	dc.w 128, $40, -128
	dc.w -128, $40, -128

	;time for triangles
	;frontal face
	dc.b 3, 7, 2
	dc.b 2, 6, 7
	;left face
	dc.b 0, 4, 3
	dc.b 3, 7, 4
	;right face
	dc.b 1, 5, 2
	dc.b 2, 6, 5
	;back face
	dc.b 1, 5, 0
	dc.b 0, 4, 5
	;upper face
	dc.b 4, 5, 6
	dc.b 4, 7, 6



example_map:
	dc.b '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    dc.b '%...............+.....#........%'
    dc.b '%.t.............#.#.###.#.#####%'
    dc.b '%>.>.>.>.########.#.....#......%'
    dc.b '%.^.^.^.^#......##############.%'
    dc.b '%........#.E..&.#............#.%'
    dc.b '%........#.F..$.#.##########.#.%'
    dc.b '%........#.E..&.#...#....#...#.%'
    dc.b '%#.#######.E..&.###.#..###.###.%'
    dc.b '%..........E..&.#...#...2......%'
    dc.b '%.E.E.E....E..&.#.###.#########%'
    dc.b '%...............#.#...#........%'
    dc.b '%..E..E...#######.#####.######.%'
    dc.b '%.........#v....#............#.%'
    dc.b '%.........#.....#.############.%'
    dc.b '%..E..E...#.....+.#...#...1....%'
    dc.b '%.........#.....#.###.#..###.##%'
    dc.b '%.........#t....#.#...#....#.#.%'
    dc.b '%..E..E...#######.#.#.###..###.%'
    dc.b '%...............#...#...#......%'
    dc.b '%...............##############.%' ;maze lower end
    dc.b '%..E..E..E..E...........####...%'
    dc.b '%......................##..#.##%'
    dc.b '%.................######.,.,..#%'
    dc.b '%...............###..##,`.`...#%' ;idk wtf is this sokoban for, maybe it unlocks a door or gives you an item or smth
    dc.b '%.............###....#..,`.,..#%'
    dc.b '%##.###########_.....+.`,,#.`##%'
    dc.b '%.............###....#..``,,.#.%'
    dc.b '%...............###..#..,``.`#.%'
    dc.b '%...........g.....#####......#.%'
    dc.b '%....................*########.%'
    dc.b '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
   
	
    
;player_position dc.w $1C00,$80,$1600
player_position dc.w $100, $80, $100
player_theta	dc.b $00
player_dirvec	dc.w 1, 0, 0

EXAMPLE_POINT_OFFSET DC.W 0, 0, 3<<8

EXAMPLE_STRING DC.B 'HELLO F   ING WORLD!!!', 0
death_spike_message: dc.b 'You died, got pierced by a spike you stupid kebab!', 0
death_wall_message: dc.b 'You died, choked inside a wall! Go get some fresh air!', 0

holding_pickaxe_msg dc.b 'Holding pickaxe.', 0
bare_handed_msg dc.b 'Bare-handed.', 0

magic_counter dc.w $0000

player_state dc.w $00
pickaxe_health dc.w $00

PS_BARE_HANDS EQU $00
PS_PICKAXE EQU $01

    
SCREEN_WIDTH EQU 640>>7
SCREEN_HEIGHT EQU 480>>5
SCREEN_VCENTER EQU (SCREEN_HEIGHT<<5)/2
SCREEN_HCENTER EQU (SCREEN_WIDTH<<7)/2
MAP_Z_BITSHIFT EQU 5
MAP_SIDE EQU 32

;;; CONTROLS
ACTION_BUTTON DC.B ' '

; control stuff
IS_ACTION_PRESSED DC.B $00

	INCLUDE "fov.x68"

SIN_60 EQU 222 ; in fixed-point rep with <<8, render plane distance from "eye"

    END    START        ; last line of source





























*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

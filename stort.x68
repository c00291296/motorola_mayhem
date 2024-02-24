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
	
	lea example_map, A1
	bsr drawMap
	
	; draw player
	move.w player_position, ship_position
	move.w #(-96), ship_position+2
	move.w player_position+4, ship_position+4
	move.l #$0010AAAA, D1
	bsr setPenColor
	lea spaceship_model, A0
	lea $10000, A1
	lea ship_position, a2
	bsr projectAllModelVertices
	lea spaceship_model, A0
	lea $10000, A1
	lea ship_position, a2

	bsr drawAllTriangles
	
	bsr repaintScreen
	bra BIGLOOP
	
ship_position: dc.w 0, 0, 0
		
	
SIMHALT             ; halt simulator
* Put variables and constants here
processGameInput:
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
	add.w #3, player_position
end_pgi:
	lsr.l #8, d1
	move.b d1, d0
	and #3, d0
	sub.w d0, player_position
	
	lsr.l #8, d1
	move.b d1, d0
	and #3, d0
	sub.w d0, player_position+4
	
	lsr.l #8, d1
	move.b d1, d0
	and #3, d0
	add.w d0, player_position+4
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
    
setPenColor: ;args: D1.L - #$00BBGGRR
	move.b #80, D0
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
    
projectPoint: ;args: a0 - point address, a1 - player position, a2 - point offset; results: d1 - x, d2 - y
	move.w 4(a0), d6
	sub.w 4(a1), d6 ; z_point - z_player
	ADD.W 4(A2), D6 ; z_point - z_player + POINT OFFSET
	
	move.w 0(a0), d1 ; x
	sub.w 0(a1), d1 ; x_point - x_player
	ADD.W 0(A2), D1 ; + POINT OFFSET
	
	muls #SIN_60, D1
	divs D6, D1
	and.l #$0000FFFF, D1
	
	move.w 2(a0), D2 ; y
	sub.w 2(a1), D2 ; y_point- y_player
	ADD.W 2(A2), D2 ; + POINT OFFSET
	
	muls.w #SIN_60, D2
	divs.w D6, D2
	and.l #$0000FFFF, D2
	
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
	move.w player_position+4, -(SP)
	sub.w #$280, player_position+4
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
	move.w (SP)+, player_position+4
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
.floor
	lea floor_tile, a0
	bra .end
.wall
	lea example_model, a0
.end
	rts
	
mapModelOffset: ; args: d1.b - x, d2.b - z, A2 - wrere to write offset to; returns A2 - offset address
	asl.w #8, d1
	asl.w #8, d2
	move.w d1, 0(A2)
	move.w d2, 4(A2)
	asr.w #8, d1
	asr.w #8, d2
	rts

getMapTile: ; args: d1.b - x, d2.b - z, A1 - the map ; returns: D0.b - map cell char
	move.l d1, -(SP)
	move.l d2, -(SP)
	move.l A1, -(SP)

	move.B #$FF, D0
	lsr.b #(8-MAP_Z_BITSHIFT), D0
	and.b D0, D2
	lsl.b #MAP_Z_BITSHIFT, D2
	and.b D0, D1
	add.b D2, D1
	and.l #$000000FF, D1
	add.l D1, A1
	move.b (A1), D0
	
	move.l (SP)+, A1
	move.l (SP)+, D2
	move.l (SP)+, D1
	rts

drawMap: ;args: A1 - the map
	;init
	clr.l D1
	clr.l D2
	move.w player_position+4, D2
	add.w #$800, D2
	asr.w #8, d2
	move.l D1, -(SP)
	move.l #$00404020, D1
	bsr setPenColor
	move.l (SP)+, D1
	move.b #64, .blue_brightness
	
.loop
	;if z < player.z, goto end (stupid FOV for the time being)
	lea player_position, A6
	move.w 4(A6), D7
	asr.w #8, D7 ;round player z to an integer
	add.b #1, D7
	cmp.b D2, D7 ;if the cell z is less or equal to players z
	bgt .continue
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
	sub.b #1, D2 ; z decreases
	;make color brighter
	move.l D1, -(SP)
	move.b #0, D1 ;zero
	lsl.l #8, D1
	add.b #24, .blue_brightness
	move.b .blue_brightness, D1 ;blue
	lsl.l #8, D1
	move.b .blue_brightness, D1 ;green
	lsl.l #8, D1
	move.b #$20, D1 ;red
	bsr setPenColor
	move.l (SP)+, D1
	cmp.b D7, D2 ; are we on last row?
	blt .end ; if we finished the last row we end
	
	;goto loop
	bra .loop
.end
	rts
.blue_brightness dc.b 64
AAA_SHIT: dc.b 0
    
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
    
floor_tile:
	dc.b 4 ;v
	dc.b 2 ;t
	dc.w -127, 0, 127 ; vertices
	dc.w 127, 0, 127
	dc.w 127, 0, -127
	dc.w -127, 0, -127
	dc.b 0, 1, 2 ; triangles
	dc.b 2, 3, 0

spaceship_model:
	dc.b 5
	dc.b 4
	dc.w -128, 128, -128
	dc.w 128, 128, -128
	dc.w 0, 160, -128
	dc.w 0, 96, -128
	dc.w 0, 128, 128 ;pointy end
	dc.b 0, 2, 4
	dc.b 2, 1, 4
	dc.b 1, 3, 4
	dc.b 3, 0, 4

example_map:
	dc.b '####'
	dc.b '....'
	dc.b '....'

	dc.b '....'
	
    
player_position dc.w 0,$80,0

EXAMPLE_POINT_OFFSET DC.W 0, 0, 3<<8
    
SCREEN_WIDTH EQU 640>>7
SCREEN_HEIGHT EQU 480>>5
SCREEN_VCENTER EQU (SCREEN_HEIGHT<<5)/2
SCREEN_HCENTER EQU (SCREEN_WIDTH<<7)/2
MAP_Z_BITSHIFT EQU 2
MAP_SIDE EQU 4

SIN_60 EQU 222 ; in fixed-point rep with <<8, render plane distance from "eye"
    END    START        ; last line of source

















*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

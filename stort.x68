*-----------------------------------------------------------
* Title      : Motorola Magical Maze Murder Mayhem
* Written by : Igor Antonov
* Date       : 29/01/2024
* Description: This could become a great game
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

	bsr enableDoubleBuffering
BIGLOOP:
	bsr clearScreen
	;bsr processGameInput
	sub.w #1, player_position+0
	;let's try draw some vertices
	
	
	lea pyramid_vertices, A0
	lea player_position, A1

	bsr renderPoint
	
	lea pyramid_vertices+6, A0
	bsr renderPoint
	
	lea pyramid_vertices+12, A0
	bsr renderPoint
	
	lea pyramid_vertices+18, A0
	bsr renderPoint
	
	lea pyramid_vertices+24, A0
	bsr renderPoint
	bsr repaintScreen
	bra BIGLOOP
		
	
SIMHALT             ; halt simulator
* Put variables and constants here
processGameInput:
	move.b 'w', D1
	LSL.l #8, D1
	move.b 's', D1
	LSL.l #8, D1
	move.b 'q', D1
	LSL.l #8, D1
	move.b 'e', D1
	bsr areKeysPressed
	move.w #0, D0
	move.b D1, D0
	and.w #1, d0
	add d0, player_position
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
    
projectPoint: ;args: a0 - point address, a1 - player position; results: d1 - x, d2 - y
	move.w 4(a0), d6
	sub.w 4(a1), d6 ; z_point - z_player
	
	move.w 0(a0), d1 ; x
	sub.w 0(a1), d1 ; x_point - x_player
	
	muls #SIN_60, D1
	lsl.l #8, D1
	lsl.l #8, d1
	asr.l #8, D1
	asr.l #8, D1 
	divs D6, D1
	and.l #$0000FFFF, D1
	;asl.w #8, D1
	;lsr.w #8, D1
	
	move.w 2(a0), D2 ; y
	sub.w 2(a1), D2 ; y_point- y_player
	
	lsl.l #8, D2
	lsl.l #8, d2
	asr.l #8, D2
	asr.l #8, D2 
	divs.w D6, D2
	and.l #$0000FFFF, D2
	lsl.w #8, D2
	muls.w #SIN_60, D2
	lsr.w #8, D2
	
	rts
	
viewportToScreen: ;args; d1 - x, d2 - y, ;results - d1 - x_screen, d2 - y_screen
	;muls #SCREEN_WIDTH, D1
	;asr.l #8, D1 ; convert from fixed point <<8 to integer
	
	;muls #SCREEN_HEIGHT, D2
	;asr.l #8, D2 ; adjust so it's and integer too
	
	add.w #SCREEN_HCENTER, D1
	neg.w D2
	add.w #SCREEN_VCENTER, D2
	
	rts
	
renderPoint:
	bsr projectPoint
	bsr viewportToScreen
	bsr drawPixel
	rts
	
    
; constants
example_model:
num_vertices dc.b 5
num_triangles: dc.b 6
pyramid_vertices:
    dc.w -128, 0, 3<<8
    dc.w -128, 0, 4<<8
    dc.w 128, 0, 3<<8
    dc.w 128, 0, 4<<8
    dc.w 0, $180, 7<<7 ;7<<7 is 3.5 in <<8 fixed point arithmetic
pyramid_triangles:
    dc.b 0, 1, 2
    dc.b 2, 3, 0
    dc.b 0, 4, 1
    dc.b 1,4,2
    dc.b 2,4, 3
    dc.b 3, 4, 0
    
player_position dc.w 0,$80,0
    
SCREEN_WIDTH EQU 640>>7
SCREEN_HEIGHT EQU 480>>5
SCREEN_VCENTER EQU (SCREEN_HEIGHT<<5)/2
SCREEN_HCENTER EQU (SCREEN_WIDTH<<7)/2

SIN_60 EQU 222 ; in fixed-point rep with <<8, render plane distance from "eye"
    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

*-----------------------------------------------------------
* Title      : fov.x68
* Written by : Igor Antonow
* Date       : 14/02/2024
* Description: simple fov for the game
*-----------------------------------------------------------

processFov:
	bsr clearFov
	bsr castAllRays
	rts

castAllRays:
	;init
	move.l #NUM_FOV_RAYS-1, D7
	;calculate starting ray
	lea VIEWDIRS, A1
	move.b player_theta, d3
	sub.b #21, d3 ; 30 degrees, half our fov
	asr.b #(8- VIEWDIR_BITS),  d3 ; make it correspond to a ray index
	muls #6, d3 ; each ray is 6 bytes
	add.l d3, A1
.loop
	;cast ray
	bsr castFovRay
	;go on to next ray
	add.l #6, A1
	
	dbra d7, .loop
.end
	rts

castFovRay: ;args: a1 - viewdir vector
	;init
	move.l A1, -(SP)
	move.l D7, -(SP)
	move.l A2, -(SP)
	move.l #(FOV_DISTANCE-1), D7
.loop:
	;add viewdir vec pos to player pos
	move.w player_position, D1
	add.w #128, d1
	move.w player_position+4, D2
	add.w #128, d2
	asr.w #8, d1
	asr.w #8, d2
	add.b (A1)+, D1
	add.b (A1)+, D2
	;check if current cell is passable
	move.l A1, -(SP)
	lea example_map, A1
	bsr isPassable
	move.l (SP)+, A1
	;set fov cell to $FF
	lea fov_map, A2
	and #$000000FF, D1
	add.l D1, A2
	asl.w #MAP_Z_OFFSET, D2
	add.l D2, A2
	asr.w #MAP_Z_OFFSET, D2
	move.b #$FF, (A2)
	;if not passable, end loop
	cmp #0, d0
	beq .end
	;else, keep looping
	dbra D7, .loop
.end
	move.l (SP)+, A2
	move.l (SP)+, D7
	move.l (SP)+, A1
	rts

clearFov: ; clears the fov_map setting all its bytes to $00
	move.l A0, -(SP)
	move.l D7, -(SP)
	lea light_map, A0
	move.w #(MAP_SIDE*MAP_SIDE-1), D7
.loop:
	move.b #$00, (A0)
	add.l #1, A0
	DBRA D7, .loop

	move.l (SP)+, D7
	move.l (SP)+, A0
	rts

fov_map: ds.b MAP_SIDE*MAP_SIDE

VIEWDIRS:
viewdir_0
	dc.b 0, 0
	dc.b 0, 1
	dc.b 0, 2
viewdir_1
	dc.b 0, 0
	dc.b 1, 1
	dc.b 1, 2
viewdir_2
	dc.b 0, 0
	dc.b 1, 1
	dc.b 1, 2
viewdir_3
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 2
viewdir_4
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 2
viewdir_5
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 2
viewdir_6
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 1
viewdir_7
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 1
viewdir_8
	dc.b 0, 0
	dc.b 1, 1
	dc.b 2, 1
viewdir_9
	dc.b 0, 0
	dc.b 1, 0
	dc.b 2, 0
viewdir_10
	dc.b 0, 0
	dc.b 1, 0
	dc.b 2, 0
viewdir_11
	dc.b 0, 0
	dc.b 1, 0
	dc.b 2, -1
viewdir_12
	dc.b 0, 0
	dc.b 1, 0
	dc.b 2, -1
viewdir_13
	dc.b 0, 0
	dc.b 1, 0
	dc.b 2, -1
viewdir_14
	dc.b 0, 0
	dc.b 1, 0
	dc.b 1, -1
viewdir_15
	dc.b 0, 0
	dc.b 1, 0
	dc.b 1, -1
viewdir_16
	dc.b 0, 0
	dc.b 1, -1
	dc.b 1, -2
viewdir_17
	dc.b 0, 0
	dc.b 0, 0
	dc.b 0, -1
viewdir_18
	dc.b 0, 0
	dc.b 0, 0
	dc.b 0, -1
viewdir_19
	dc.b 0, 0
	dc.b 0, 0
	dc.b -1, -1
viewdir_20
	dc.b 0, 0
	dc.b 0, 0
	dc.b -1, -1
viewdir_21
	dc.b 0, 0
	dc.b 0, 0
	dc.b -1, -1
viewdir_22
	dc.b 0, 0
	dc.b 0, 0
	dc.b -1, 0
viewdir_23
	dc.b 0, 0
	dc.b 0, 0
	dc.b -1, 0
viewdir_24
	dc.b 0, 0
	dc.b -1, 0
	dc.b -2, 0
viewdir_25
	dc.b 0, 0
	dc.b 0, 1
	dc.b -1, 1
viewdir_26
	dc.b 0, 0
	dc.b 0, 1
	dc.b -1, 1
viewdir_27
	dc.b 0, 0
	dc.b 0, 1
	dc.b -1, 2
viewdir_28
	dc.b 0, 0
	dc.b 0, 1
	dc.b -1, 2
viewdir_29
	dc.b 0, 0
	dc.b 0, 1
	dc.b -1, 2
viewdir_30
	dc.b 0, 0
	dc.b 0, 1
	dc.b 0, 2
viewdir_31
	dc.b 0, 0
	dc.b 0, 1
	dc.b 0, 2
	
FOV_DISTANCE EQU 3
NUM_FOV_RAYS EQU 6
VIEWDIR_BITS EQU 5


*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

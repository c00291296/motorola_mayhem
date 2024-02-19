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
	move.l #(NUM_FOV_RAYS-1), D7
	;calculate starting ray
	lea VIEWDIRS, A1
	move.b player_theta, d3
	sub.b #60, d3 ; 30 degrees, half our fov
	lsr.b #(8- VIEWDIR_BITS),  d3 ; make it correspond to a ray index
	and #$000000FF, D3
	asl.l #4, d3 ; each ray is 16 bytes
	add.l d3, A1
.loop
	;cast ray
	bsr castFovRay
	;go on to next ray
	add.l #16, A1
	cmp.l #(VIEWDIRS+(63*16)), A1
	ble .skip_wraparound
	lea VIEWDIRS, A1
.skip_wraparound
	dbra d7, .loop
.end
	rts

castFovRay: ;args: a1 - viewdir vector
	;init
	move.l A1, -(SP)
	move.l D7, -(SP)
	move.l A2, -(SP)
	clr.l d1
	clr.l d2
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
	;if not passable, end loop
	cmp.b #0, d0
	beq .end

	;set fov cell to $FF
	lea fov_map, A2
	and #$000000FF, D1
	add.l D1, A2
	move.w D2, -(SP)
	lsl.w #MAP_Z_BITSHIFT, D2
	add.l D2, A2
	move.w (SP)+, D2
	move.b #$FF, (A2)
	;set cells around alight too
	move.b #$FF, 1(A2)
	move.b #$FF, -1(A2)
	move.b #$FF, MAP_SIDE(A2)
	move.b #$FF, -MAP_SIDE(A2)
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
	lea fov_map, A0
	move.w #(MAP_SIDE*MAP_SIDE-1), D7
.loop:
	move.b #$00, (A0)
	add.l #1, A0
	DBRA D7, .loop

	move.l (SP)+, D7
	move.l (SP)+, A0
	rts

fov_protection1: ds.b MAP_SIDE
fov_map: ds.b MAP_SIDE*MAP_SIDE
fov_protection2: ds.b MAP_SIDE

VIEWDIRS:
viewdir_0
        dc.b 0, 1
        dc.b 0, 2
        dc.b 0, 3
        dc.b 0, 4
        dc.b 0, 5
        dc.b 0, 6
        dc.b 0, 7
        dc.b 0, 8
viewdir_1
        dc.b 1, 1
        dc.b 1, 2
        dc.b 1, 3
        dc.b 1, 4
        dc.b 1, 5
        dc.b 1, 6
        dc.b 1, 7
        dc.b 1, 8
viewdir_2
        dc.b 1, 1
        dc.b 1, 2
        dc.b 1, 3
        dc.b 1, 4
        dc.b 1, 5
        dc.b 2, 6
        dc.b 2, 7
        dc.b 2, 8
viewdir_3
        dc.b 1, 1
        dc.b 1, 2
        dc.b 1, 3
        dc.b 2, 4
        dc.b 2, 5
        dc.b 2, 6
        dc.b 3, 7
        dc.b 3, 8
viewdir_4
        dc.b 1, 1
        dc.b 1, 2
        dc.b 2, 3
        dc.b 2, 4
        dc.b 2, 5
        dc.b 3, 6
        dc.b 3, 7
        dc.b 4, 8
viewdir_5
        dc.b 1, 1
        dc.b 1, 2
        dc.b 2, 3
        dc.b 2, 4
        dc.b 3, 5
        dc.b 3, 6
        dc.b 4, 7
        dc.b 4, 8
viewdir_6
        dc.b 1, 1
        dc.b 2, 2
        dc.b 2, 3
        dc.b 3, 4
        dc.b 3, 5
        dc.b 4, 5
        dc.b 4, 6
        dc.b 5, 7
viewdir_7
        dc.b 1, 1
        dc.b 2, 2
        dc.b 2, 3
        dc.b 3, 4
        dc.b 4, 4
        dc.b 4, 5
        dc.b 5, 6
        dc.b 6, 7
viewdir_8
        dc.b 1, 1
        dc.b 2, 2
        dc.b 3, 3
        dc.b 3, 3
        dc.b 4, 4
        dc.b 5, 5
        dc.b 5, 5
        dc.b 6, 6
viewdir_9
        dc.b 1, 1
        dc.b 2, 2
        dc.b 3, 2
        dc.b 4, 3
        dc.b 4, 4
        dc.b 5, 4
        dc.b 6, 5
        dc.b 7, 6
viewdir_10
        dc.b 1, 1
        dc.b 2, 2
        dc.b 3, 2
        dc.b 4, 3
        dc.b 5, 3
        dc.b 5, 4
        dc.b 6, 4
        dc.b 7, 5
viewdir_11
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 2
        dc.b 4, 2
        dc.b 5, 3
        dc.b 6, 3
        dc.b 7, 4
        dc.b 8, 4
viewdir_12
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 2
        dc.b 4, 2
        dc.b 5, 2
        dc.b 6, 3
        dc.b 7, 3
        dc.b 8, 4
viewdir_13
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 1
        dc.b 4, 2
        dc.b 5, 2
        dc.b 6, 2
        dc.b 7, 3
        dc.b 8, 3
viewdir_14
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 1
        dc.b 4, 1
        dc.b 5, 1
        dc.b 6, 2
        dc.b 7, 2
        dc.b 8, 2
viewdir_15
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 1
        dc.b 4, 1
        dc.b 5, 1
        dc.b 6, 1
        dc.b 7, 1
        dc.b 8, 1
viewdir_16
        dc.b 1, 1
        dc.b 2, 1
        dc.b 3, 1
        dc.b 4, 1
        dc.b 5, 1
        dc.b 6, 1
        dc.b 7, 1
        dc.b 8, 1
viewdir_17
        dc.b 1, 0
        dc.b 2, 0
        dc.b 3, 0
        dc.b 4, 0
        dc.b 5, 0
        dc.b 6, 0
        dc.b 7, 0
        dc.b 8, 0
viewdir_18
        dc.b 1, 0
        dc.b 2, 0
        dc.b 3, 0
        dc.b 4, 0
        dc.b 5, 0
        dc.b 6, -1
        dc.b 7, -1
        dc.b 8, -1
viewdir_19
        dc.b 1, 0
        dc.b 2, 0
        dc.b 3, 0
        dc.b 4, -1
        dc.b 5, -1
        dc.b 6, -1
        dc.b 7, -2
        dc.b 8, -2
viewdir_20
        dc.b 1, 0
        dc.b 2, 0
        dc.b 3, -1
        dc.b 4, -1
        dc.b 5, -1
        dc.b 6, -2
        dc.b 7, -2
        dc.b 8, -3
viewdir_21
        dc.b 1, 0
        dc.b 2, 0
        dc.b 3, -1
        dc.b 4, -1
        dc.b 5, -2
        dc.b 6, -2
        dc.b 7, -3
        dc.b 8, -3
viewdir_22
        dc.b 1, 0
        dc.b 2, -1
        dc.b 3, -1
        dc.b 4, -2
        dc.b 5, -2
        dc.b 5, -3
        dc.b 6, -3
        dc.b 7, -4
viewdir_23
        dc.b 1, 0
        dc.b 2, -1
        dc.b 3, -1
        dc.b 4, -2
        dc.b 4, -3
        dc.b 5, -3
        dc.b 6, -4
        dc.b 7, -5
viewdir_24
        dc.b 1, 0
        dc.b 2, -1
        dc.b 3, -2
        dc.b 3, -2
        dc.b 4, -3
        dc.b 5, -4
        dc.b 5, -4
        dc.b 6, -5
viewdir_25
        dc.b 1, 0
        dc.b 2, -1
        dc.b 2, -2
        dc.b 3, -3
        dc.b 4, -3
        dc.b 4, -4
        dc.b 5, -5
        dc.b 6, -6
viewdir_26
        dc.b 1, 0
        dc.b 2, -1
        dc.b 2, -2
        dc.b 3, -3
        dc.b 3, -4
        dc.b 4, -4
        dc.b 4, -5
        dc.b 5, -6
viewdir_27
        dc.b 1, 0
        dc.b 1, -1
        dc.b 2, -2
        dc.b 2, -3
        dc.b 3, -4
        dc.b 3, -5
        dc.b 4, -6
        dc.b 4, -7
viewdir_28
        dc.b 1, 0
        dc.b 1, -1
        dc.b 2, -2
        dc.b 2, -3
        dc.b 2, -4
        dc.b 3, -5
        dc.b 3, -6
        dc.b 4, -7
viewdir_29
        dc.b 1, 0
        dc.b 1, -1
        dc.b 1, -2
        dc.b 2, -3
        dc.b 2, -4
        dc.b 2, -5
        dc.b 3, -6
        dc.b 3, -7
viewdir_30
        dc.b 1, 0
        dc.b 1, -1
        dc.b 1, -2
        dc.b 1, -3
        dc.b 1, -4
        dc.b 2, -5
        dc.b 2, -6
        dc.b 2, -7
viewdir_31
        dc.b 1, 0
        dc.b 1, -1
        dc.b 1, -2
        dc.b 1, -3
        dc.b 1, -4
        dc.b 1, -5
        dc.b 1, -6
        dc.b 1, -7
viewdir_32
        dc.b 1, -1
        dc.b 1, -2
        dc.b 1, -3
        dc.b 1, -4
        dc.b 1, -5
        dc.b 1, -6
        dc.b 1, -7
        dc.b 1, -8
viewdir_33
        dc.b 0, 0
        dc.b 0, -1
        dc.b 0, -2
        dc.b 0, -3
        dc.b 0, -4
        dc.b 0, -5
        dc.b 0, -6
        dc.b 0, -7
viewdir_34
        dc.b 0, 0
        dc.b 0, -1
        dc.b 0, -2
        dc.b 0, -3
        dc.b 0, -4
        dc.b -1, -5
        dc.b -1, -6
        dc.b -1, -7
viewdir_35
        dc.b 0, 0
        dc.b 0, -1
        dc.b 0, -2
        dc.b -1, -3
        dc.b -1, -4
        dc.b -1, -5
        dc.b -2, -6
        dc.b -2, -7
viewdir_36
        dc.b 0, 0
        dc.b 0, -1
        dc.b -1, -2
        dc.b -1, -3
        dc.b -1, -4
        dc.b -2, -5
        dc.b -2, -6
        dc.b -3, -7
viewdir_37
        dc.b 0, 0
        dc.b 0, -1
        dc.b -1, -2
        dc.b -1, -3
        dc.b -2, -4
        dc.b -2, -5
        dc.b -3, -6
        dc.b -3, -7
viewdir_38
        dc.b 0, 0
        dc.b -1, -1
        dc.b -1, -2
        dc.b -2, -3
        dc.b -2, -4
        dc.b -3, -4
        dc.b -3, -5
        dc.b -4, -6
viewdir_39
        dc.b 0, 0
        dc.b -1, -1
        dc.b -1, -2
        dc.b -2, -3
        dc.b -3, -3
        dc.b -3, -4
        dc.b -4, -5
        dc.b -5, -6
viewdir_40
        dc.b 0, 0
        dc.b -1, -1
        dc.b -2, -2
        dc.b -2, -2
        dc.b -3, -3
        dc.b -4, -4
        dc.b -4, -4
        dc.b -5, -5
viewdir_41
        dc.b 0, 0
        dc.b -1, -1
        dc.b -2, -1
        dc.b -3, -2
        dc.b -3, -3
        dc.b -4, -3
        dc.b -5, -4
        dc.b -6, -5
viewdir_42
        dc.b 0, 0
        dc.b -1, -1
        dc.b -2, -1
        dc.b -3, -2
        dc.b -4, -2
        dc.b -4, -3
        dc.b -5, -3
        dc.b -6, -4
viewdir_43
        dc.b 0, 0
        dc.b -1, 0
        dc.b -2, -1
        dc.b -3, -1
        dc.b -4, -2
        dc.b -5, -2
        dc.b -6, -3
        dc.b -7, -3
viewdir_44
        dc.b 0, 0
        dc.b -1, 0
        dc.b -2, -1
        dc.b -3, -1
        dc.b -4, -1
        dc.b -5, -2
        dc.b -6, -2
        dc.b -7, -3
viewdir_45
        dc.b 0, 0
        dc.b -1, 0
        dc.b -2, 0
        dc.b -3, -1
        dc.b -4, -1
        dc.b -5, -1
        dc.b -6, -2
        dc.b -7, -2
viewdir_46
        dc.b 0, 0
        dc.b -1, 0
        dc.b -2, 0
        dc.b -3, 0
        dc.b -4, 0
        dc.b -5, -1
        dc.b -6, -1
        dc.b -7, -1
viewdir_47
        dc.b 0, 0
        dc.b -1, 0
        dc.b -2, 0
        dc.b -3, 0
        dc.b -4, 0
        dc.b -5, 0
        dc.b -6, 0
        dc.b -7, 0
viewdir_48
        dc.b -1, 0
        dc.b -2, 0
        dc.b -3, 0
        dc.b -4, 0
        dc.b -5, 0
        dc.b -6, 0
        dc.b -7, 0
        dc.b -8, 0
viewdir_49
        dc.b 0, 1
        dc.b -1, 1
        dc.b -2, 1
        dc.b -3, 1
        dc.b -4, 1
        dc.b -5, 1
        dc.b -6, 1
        dc.b -7, 1
viewdir_50
        dc.b 0, 1
        dc.b -1, 1
        dc.b -2, 1
        dc.b -3, 1
        dc.b -4, 1
        dc.b -5, 2
        dc.b -6, 2
        dc.b -7, 2
viewdir_51
        dc.b 0, 1
        dc.b -1, 1
        dc.b -2, 1
        dc.b -3, 2
        dc.b -4, 2
        dc.b -5, 2
        dc.b -6, 3
        dc.b -7, 3
viewdir_52
        dc.b 0, 1
        dc.b -1, 1
        dc.b -2, 2
        dc.b -3, 2
        dc.b -4, 2
        dc.b -5, 3
        dc.b -6, 3
        dc.b -7, 4
viewdir_53
        dc.b 0, 1
        dc.b -1, 1
        dc.b -2, 2
        dc.b -3, 2
        dc.b -4, 3
        dc.b -5, 3
        dc.b -6, 4
        dc.b -7, 4
viewdir_54
        dc.b 0, 1
        dc.b -1, 2
        dc.b -2, 2
        dc.b -3, 3
        dc.b -4, 3
        dc.b -4, 4
        dc.b -5, 4
        dc.b -6, 5
viewdir_55
        dc.b 0, 1
        dc.b -1, 2
        dc.b -2, 2
        dc.b -3, 3
        dc.b -3, 4
        dc.b -4, 4
        dc.b -5, 5
        dc.b -6, 6
viewdir_56
        dc.b 0, 1
        dc.b -1, 2
        dc.b -2, 3
        dc.b -2, 3
        dc.b -3, 4
        dc.b -4, 5
        dc.b -4, 5
        dc.b -5, 6
viewdir_57
        dc.b 0, 1
        dc.b -1, 2
        dc.b -1, 3
        dc.b -2, 4
        dc.b -3, 4
        dc.b -3, 5
        dc.b -4, 6
        dc.b -5, 7
viewdir_58
        dc.b 0, 1
        dc.b -1, 2
        dc.b -1, 3
        dc.b -2, 4
        dc.b -2, 5
        dc.b -3, 5
        dc.b -3, 6
        dc.b -4, 7
viewdir_59
        dc.b 0, 1
        dc.b 0, 2
        dc.b -1, 3
        dc.b -1, 4
        dc.b -2, 5
        dc.b -2, 6
        dc.b -3, 7
        dc.b -3, 8
viewdir_60
        dc.b 0, 1
        dc.b 0, 2
        dc.b -1, 3
        dc.b -1, 4
        dc.b -1, 5
        dc.b -2, 6
        dc.b -2, 7
        dc.b -3, 8
viewdir_61
        dc.b 0, 1
        dc.b 0, 2
        dc.b 0, 3
        dc.b -1, 4
        dc.b -1, 5
        dc.b -1, 6
        dc.b -2, 7
        dc.b -2, 8
viewdir_62
        dc.b 0, 1
        dc.b 0, 2
        dc.b 0, 3
        dc.b 0, 4
        dc.b 0, 5
        dc.b -1, 6
        dc.b -1, 7
        dc.b -1, 8
viewdir_63
        dc.b 0, 1
        dc.b 0, 2
        dc.b 0, 3
        dc.b 0, 4
        dc.b 0, 5
        dc.b 0, 6
        dc.b 0, 7
        dc.b 0, 8
	
FOV_DISTANCE EQU 8
NUM_FOV_RAYS EQU 25
VIEWDIR_BITS EQU 6



*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

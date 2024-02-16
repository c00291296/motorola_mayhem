*-----------------------------------------------------------
* Title      : fov.x68
* Written by : Igor Antonow
* Date       : 14/02/2024
* Description: simple fov for the game
*-----------------------------------------------------------

castFovRay:
	;init
	move.l #(FOV_DISTANCE-1), D7
.loop:
	;add viewdir vec pos to player pos
	;check if current cell is passable
	;if not passable, set fov cell to 0 and end loop
	;else, set fov cell to $FF and keep looping
	dbra D7, .loop
	
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


*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~

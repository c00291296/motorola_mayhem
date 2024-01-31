*-----------------------------------------------------------
* Title      : Motorola Magical Maze Murder Mayhem
* Written by : Igor Antonov
* Date       : 29/01/2024
* Description: This could become a great game
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    lea pyramid_triangles, a0
    move.b 2(a0), d1
    move.b #5, d1
    bsr setPenWidth
    move.w #SCREEN_VCENTER, d2
    move.w #SCREEN_HCENTER, d1
    bsr drawPixel
    
    move.b #0, D1
    move.b #0, D2
    move.b #128, D3
    move.b #128, D4
    bsr enableDoubleBuffering
BIGLOOP:
    add.b #1, D1
    add.b #1, D2
    bsr clearScreen
    bsr drawLine
    bsr repaintScreen
    bra BIGLOOP
                               

    SIMHALT             ; halt simulator

* Put variables and constants here

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
    
projectPoint: ;args: a0 - point address, a1 - player position
    move.w (a0)+, d0
    move.w (a0)+, d1
    move.w (a0)+, d2
    
    move.w (a1)+, d3
    move.w (a1)+, d4
    move.
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
    dc.w 0, $180, 7<<7
pyramid_triangles:
    dc.b 0, 1, 2
    dc.b 2, 3, 0
    dc.b 0, 4, 1
    dc.b 1,4,2
    dc.b 2,4, 3
    dc.b 3, 4, 0
    
SCREEN_WIDTH EQU 640
SCREEN_HEIGHT EQU 480
SCREEN_VCENTER EQU SCREEN_HEIGHT/2
SCREEN_HCENTER EQU SCREEN_WIDTH/2

SIN_60 EQU 222 ; in fixed-point rep with <<8
    END    START        ; last line of source





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

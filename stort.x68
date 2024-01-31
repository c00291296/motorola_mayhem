*-----------------------------------------------------------
* Title      : Motorola Magical Maze Murder Mayhem
* Written by : Igor Antonov
* Date       : 29/01/2024
* Description: This could become a great game
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    bsr setPenWidth
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
    
projectPoint: ;args: a0 - point address, a1 - player position
    sub.w d4, d5 ; x0-xp
    sub.w d1, d3 ;z0-zp
    divs d3, d5
    muls d5, d2
    
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
    
    
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

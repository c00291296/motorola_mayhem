*-----------------------------------------------------------
* Title      : Motorola Magical Maze Murder Mayhem
* Written by : Igor Antonov
* Date       : 29/01/2024
* Description: This could become a great game
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
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
    
    
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

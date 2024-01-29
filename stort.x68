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
BIGLOOP:
    add.b #1, D1
    add.b #1, D2
    bsr drawLine
    bra BIGLOOP
                               

    SIMHALT             ; halt simulator

* Put variables and constants here

drawLine: ; draws line from (D1.w, D2.w) to (D3.w, D4.w) 
    move.l #84, D0
    trap #15
    rts
    
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

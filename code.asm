define sysRandom    $fe
define sysLastKey   $ff
define position     $00

LDX #$10
STX position

loop:
  JSR drawShip
  JSR readInput
  JMP loop
  
drawShip:
  LDA #$0E
  LDX position
  STA $05C0, X
  DEX
  STA $05E0, X
  INX
  STA $05E0, X
  INX
  STA $05E0, X
  DEX
  RTS

readInput:
  LDX position
  LDY sysLastKey
;  CPY #$64
;  BEQ goRight
;  CPY #$61
;  BEQ goLeft
;  CPY #$77
;  BEQ shoot
  RTS

;goRight:
;  CPX $#1E ;máximo à direita
   
;goLeft:
;  CPX $#01 ;máximo à esquerda
  

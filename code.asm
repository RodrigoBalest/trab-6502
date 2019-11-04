define sysRandom    $fe
define sysLastKey   $ff

LDX #$10

loop:
  JSR drawShip
  JSR readInput
  JMP loop
  
drawShip:
  LDA #$0E
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
  LDY sysLastKey
  RTS
  

define sysRandom    $fe
define sysLastKey   $ff
define position     $00

LDX #$10
STX position

loop:
  LDA #$00
  JSR drawShip  ;pinta nave de preto
  JSR readInput ;atualiza posição
  LDA #$0E
  JSR drawShip  ;pinta nave de azul
  JMP loop
  
drawShip:
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
  CPY #$64
  BEQ goRight
  CPY #$61
  BEQ goLeft
;  CPY #$77
;  BEQ shoot
  LDX #$00
  STX posicao
  RTS

goRight:
  CPX #$1E ;máximo à direita
  BPL dontGoRight
  INX
  STX position
  dontGoRight:
  RTS
   
goLeft:
  CPX #$02 ;máximo à esquerda
  BMI dontGoLeft
  DEX
  STX position
  dontGoLeft:
  RTS

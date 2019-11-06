define sysRandom    $fe
define sysLastKey   $ff
define position     $00
define shots        $10 ;primeira célula que armazenará os tiros

LDX #$10
STX position

loop:
  LDA #$00
  JSR drawShip  ;pinta nave de preto
  JSR readInput ;atualiza posição
  LDA #$0E
  JSR drawShip  ;pinta nave de azul
  JSR resetInput
  JSR delay
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
  CPY #$44
  BEQ goRight
  CPY #$41
  BEQ goLeft
  CPY #$77
  BEQ shoot
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

shoot:
  LDX #$00
  RTS

delay:
  LDX #$FF
  delayLoop:
  DEX
  CPX #$00
  BNE delayLoop
  RTS

resetInput:
  LDA #0
  STA sysLastKey
  RTS

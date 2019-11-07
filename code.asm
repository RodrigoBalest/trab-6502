define sysRandom    $fe
define sysLastKey   $ff
define position     $00
define shots        $10 ;primeira célula que armazenará os tiros
define temp         $F0

LDX #$10
STX position

loop:
  JSR readInput ;atualiza posição
  LDA #$0E
  JSR drawShip  ;pinta nave de azul
  LDA #$01
  JSR drawShots ;pinta tiros de branco
  JSR resetInput
  JSR delay
  LDA #$00
  JSR drawShip  ;pinta nave de preto
  LDA #$00
  JSR drawShots ;pinta tiros de preto
  JSR updateShots ;movimenta os tiros
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
  LDX #$01
  checkIndexHasShot:
  LDA shots,X
  CMP #$00 ; verifica se há um valor armazenado
  BEQ addShot
  INX
  INX
  CPX #$06 ; max 3 tiros
  BMI checkIndexHasShot
  RTS

addShot:
  LDA #$05
  STA shots,X
  DEX
  LDA position
  ADC #$BF
  STA shots,X
  RTS

drawShots:
  STA temp ;armazena a cor em uma variável temporária
  LDX #$01
  drawNextShot:
  LDA shots,X
  CMP #$00 ;verifica se há um valor armazenado
  BEQ skipDrawShot ;não há tiro para desenhar
  LDA temp ;carrega a cor
  DEX
  STA (shots,X) ;pinta a posição do tiro
  INX
  skipDrawShot:
  INX
  INX
  CPX #$06 ; max 3 tiros
  BMI drawNextShot
  RTS

updateShots:
  LDX #$01
  updateNextShot:
  LDA shots,X
  CMP #$00 ;verifica se há um valor armazenado
  BEQ skipUpdateShot ;não há tiro para atualizar
  JSR updateShot	
  skipUpdateShot:
  INX
  INX
  CPX #$06 ; max 3 tiros
  BMI updateNextShot
  RTS

updateShot:
  DEX
  LDA shots,X
  SBC #$20
  STA shots,X
  INX
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

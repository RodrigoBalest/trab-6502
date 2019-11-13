define sysRandom    $fe
define sysLastKey   $ff
define lastRandom   $E0
define position     $00
define shots        $10 ;primeira célula que armazenará os tiros
define temp         $F0
define temp2        $F1
define temp3        $F2
define enemies      $20 ;primeira célula que armazenará os inimigos
define numShots     $06 ;nº de tiros: deve ser o dobro
define numEnemies   $0a ;nº de inimigos: deve ser o dobro

LDX #$10
STX position
LDA sysRandom
STA lastRandom

loop:
  JSR readInput ;atualiza posição
  LDA #$0E 
  JSR drawShip  ;pinta nave de azul
  LDA #$01
  JSR drawShots ;pinta tiros de branco
  LDA #$0A
  JSR drawEnemies
  JSR resetInput
  JSR delay
  LDA #$00
  JSR drawShip  ;pinta nave de preto
  LDA #$00
  JSR drawShots ;pinta tiros de preto
  JSR updateShots ;movimenta os tiros
  LDA #$00
  JSR drawEnemies
  JSR updateEnemies ;gera/atualiza os inimigos
  JSR generateNewEnemy
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
  CPX #numShots
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
  CPX #numShots ;se não chegou no máximo de tiros, vai para o próximo
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
  CPX #numShots ;se não chegou no máximo de tiros, vai para o próximo
  BMI updateNextShot
  RTS

updateShot:
  DEX
  LDA shots,X
  SEC ;set carry flag
  SBC #$20
  STA shots,X
  INX
  BCC upShot ;se o carry foi limpo, faz o tiro passar para a faixa acima.
  RTS
  upShot:
  DEC shots,X
  LDA shots,X
  CMP #$02
  BMI clearShot ;se saiu da tela, remove o tiro
  RTS
  clearShot:
  LDA #$00
  DEX
  STA shots,X
  INX
  STA shots,X
  RTS

updateEnemies:
  LDX #$01
  updateNextEnemy:
  LDA enemies,X
  CMP #$00 ;verifica se há um valor armazenado
  BEQ skipUpdateEnemy ;não há inimigo para atualizar
  JSR updateEnemy
  JSR checkEnemyWasShot
  skipUpdateEnemy:
  INX
  INX
  CPX #numEnemies
  BMI updateNextEnemy
  RTS

updateEnemy:
  DEX
  LDA enemies,X
  CLC ;clear carry flag
  ADC #$20
  STA enemies,X
  INX
  BCS downEnemy ;se o carry foi limpo, faz o inimigo passar para a faixa abaixo.
  RTS
  downEnemy:
  INC enemies,X
  LDA enemies,X
  CMP #$06
  BPL clearEnemy ;se saiu da tela, remove o inimigo
  RTS
  clearEnemy:
  LDA #$00
  DEX
  STA enemies,X
  INX
  STA enemies,X
  RTS

generateNewEnemy:
  LDA sysRandom
  LSR A ;left shift. Bit 0 vai para o carry
  BCS skipGenerateEnemy ;se carry foi setado, o nº é ímpar. Não será gerado outro inimigo.
  JSR addEnemyToArray
  skipGenerateEnemy:
  LDA sysRandom
  STA lastRandom
  RTS

addEnemyToArray:
  LDX #$01
  checkIndexHasEnemy:
  LDA enemies,X
  CMP #$00 ; verifica se há um valor armazenado
  BEQ addEnemy
  INX
  INX
  CPX #numEnemies
  BMI checkIndexHasEnemy
  RTS

addEnemy:
  LDA #$02
  STA enemies,X
  DEX
  LDA lastRandom
  AND #$1F
  STA enemies,X
  RTS

drawEnemies:
  STA temp ;armazena a cor em uma variável temporária
  LDX #$01
  drawNextEnemy:
  LDA enemies,X
  CMP #$00 ;verifica se há um valor armazenado
  BEQ skipDrawEnemy ;não há inimigo para desenhar
  LDA temp ;carrega a cor
  DEX
  STA (enemies,X) ;pinta a posição do inimigo
  INX
  skipDrawEnemy:
  INX
  INX
  CPX #numEnemies
  BMI drawNextEnemy
  RTS

checkEnemyWasShot:
  STX temp  ;guarda o indice do HB do inimigo para mais tarde
  DEX
  LDA enemies,X ;pega o LB do inimigo
  AND #$1F  ;pega a coluna que o inimigo está
  STA temp2 ;guarda a coluna que o inimigo está
  LDX #$00  ;prepara o índice para percorrermos os tiros
  checkShotHitsEnemy:
  LDA shots,X ;pega o LB do tiro
  CMP #$00
  BEQ checkNextShotHitsEnemy ;se a posição do tiro for 0, ele não existe. Vai para o próximo
  AND #$1F  ;pega a coluna do tiro
  CMP temp2 ;compara com a coluna do inimigo
  BNE checkNextShotHitsEnemy ;se não está na mesma coluna, vai para o próximo tiro
  ;compara HB do tiro e do inimigo
  STX temp2 ;guarda o índice do LB do tiro em temp2
  INX ;vai para o índice do HB do tiro
  LDA shots,X ;pega o HB do tiro
  STA temp3 ;guarda o HB do tiro em temp3
  LDX temp  ;pega o índice do HB do inimigo
  LDA enemies,X ;pega o HB do inimigo
  LDX temp2 ;carrega o índice LB do tiro em X
  CMP temp3 ;compara A com o HB do tiro
  BMI checkNextShotHitsEnemy ;se o HB do inimigo for menor que do tiro, ele não foi atingido. Vai para o próximo
  ;compara LB do tiro e do inimigo
  LDA shots,X ;carrega o LB do tiro
  STA temp3 ;guarda o LB do tiro em temp3
  LDX temp  ;pega o índice do HB do inimigo
  DEX ;pega o índice do LB do inimigo
  LDA enemies,X ;carrega o LB do inimigo
  LDX temp2 ;carrega o índice LB do tiro em X
  CMP temp3 ;compara A com o LB do tiro
  BMI checkNextShotHitsEnemy ;se o HB do inimigo for menor que do tiro, ele não foi atingido. Vai para o próximo
  JSR killEnemy ;se chegamos aqui, o tiro acertou o inimigo
  checkNextShotHitsEnemy:
  INX
  INX
  CPX #numShots
  BMI checkShotHitsEnemy
  LDX temp  ;recupera o HB do inimigo
  RTS

killEnemy:
  ;temp2 contém o índice do LB do tiro
  ;temp contém o índice do HB do inimigo
  LDA #$00
  LDX temp2 ;recupera o índice do LB do tiro
  STA shots,X ;reseta o LB do tiro
  INX
  STA shots,X ;reseta o HB do tiro
  LDX temp ;recupera o índice do HB do inimigo
  STA enemies,X ;reseta o HB do tiro
  DEX
  STA enemies,X ;reseta o LB do tiro
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

end:

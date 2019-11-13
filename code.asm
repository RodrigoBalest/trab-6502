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
  LDX #$01 ;carrega o índice do HB do primeiro inimigo
  updateNextEnemy:
  LDA enemies,X ;carrega o HB do inimigo
  CMP #$00 ;verifica se há um valor armazenado
  BEQ skipUpdateEnemy ;não há inimigo para atualizar
  JSR updateEnemy ;atualiza a posição do inimigo
  JSR checkEnemyWasShot ;checa se um tiro atingiu o inimigo
  JSR checkShipHit ;checa se o inimigo atingiu a nave
  skipUpdateEnemy:
  INX
  INX
  CPX #numEnemies
  BMI updateNextEnemy
  RTS

updateEnemy:
  DEX ;X contém o índice do LB do inimigo
  LDA enemies,X ;carrega o LB do inimigo
  CLC ;clear carry flag
  ADC #$20
  STA enemies,X ;move inimigo uma linha abaixo, somando #$20 ao HB
  INX ;X agora contém o índice do HB do inimigo
  BCS downEnemy ;se o carry foi setado, faz o inimigo passar para a faixa abaixo
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

checkShipHit:
  ;X contém o índice do HB do inimigo que estamos verificando.
  STX temp
  LDA enemies,X
  CMP #$05 ;verifica se o inimigo está na mesma faixa da nave.
  BNE shipWasNotHit
  DEX
  LDA enemies,X ;carrega o LB do inimigo
  STA temp2
  LDA position
  ADC #$BF
  CMP temp2 ;compara a posição da nave com a posição do tiro
  BNE shipWasNotHit
  JMP shipHit ;se chegou aqui, a nave foi atingida
  shipWasNotHit:
  LDX temp
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

shipHit:
  LDA #$01
  LDX #$02
  STA $0245,X
  STA $0246,X
  STA $0247,X
  STA $0249,X
  STA $024A,X
  STA $024B,X
  STA $024D,X
  STA $0251,X
  STA $0253,X
  STA $0254,X
  STA $0255,X
  ;2ª linha
  STA $0265,X
  STA $0269,X
  STA $026B,X
  STA $026D,X
  STA $026E,X
  STA $0270,X
  STA $0271,X
  STA $0273,X
  ;3ª linha
  STA $0285,X
  STA $0289,X
  STA $028B,X
  STA $028D,X
  STA $028F,X
  STA $0291,X
  STA $0293,X
  STA $0294,X
  ;4ª linha
  STA $02A5,X
  STA $02A7,X
  STA $02A9,X
  STA $02AA,X
  STA $02AB,X
  STA $02AD,X
  STA $02A5,X
  STA $02B1,X
  STA $02B3,X
  ;5ª linha
  STA $02C5,X
  STA $02C6,X
  STA $02C7,X
  STA $02C9,X
  STA $02CB,X
  STA $02CD,X
  STA $02D1,X
  STA $02D3,X
  STA $02D4,X
  STA $02D5,X
  ;6ª linha
  STA $0305,X
  STA $0306,X
  STA $0307,X
  STA $0309,X
  STA $030D,X
  STA $030F,X
  STA $0310,X
  STA $0311,X
  STA $0313,X
  STA $0314,X
  ;7ª linha
  STA $0325,X
  STA $0327,X
  STA $0329,X
  STA $032D,X
  STA $032F,X
  STA $0333,X
  STA $0335,X
  ;8ª linha
  STA $0345,X
  STA $0347,X
  STA $0349,X
  STA $034D,X
  STA $034F,X
  STA $0350,X
  STA $0353,X
  STA $0355,X
  ;9ª linha
  STA $0365,X
  STA $0367,X
  STA $036A,X
  STA $036C,X
  STA $036F,X
  STA $0373,X
  STA $0374,X
  ;10ª linha
  STA $0385,X
  STA $0386,X
  STA $0387,X
  STA $038B,X
  STA $038F,X
  STA $0390,X
  STA $0391,X
  STA $0393,X
  STA $0395,X
  ;desenha explosão
  ;LDX #$0E
  LDX #$01
  LDA #$05
  STA position,X ;guarda o HB da posição da nave
  LDA #$C0
  ADC position ;A contém o LB da posição da nave
  STA temp ;salva o centro da explosão
  SBC #$20
  STA temp2 ;salva o LB do topo da explosão
  LDA #$05
  STA temp3 ;salva o HB do topo da explosão
  LDA #$0E
  explodeframe01:
  LDY #$00
  STA (temp2),Y
  LDY #$1F
  STA (temp2),Y
  INY
  INY
  STA (temp2),Y
  LDY #$40
  STA (temp2),Y
  CMP #$00 ;se pintou de preto, vai para o próximo frame
  BEQ preexplodeframe02
  JSR delay
  LDA #$00
  JMP explodeframe01 ;pinta o frame anterior de preto
  preexplodeframe02:
  LDA temp2 ;recupera o topo da explosão
  SBC #$20  ;move para a linha de cima
  STA temp2 ;salva o LB do novo topo da explosão
  LDA #$0E  ;carrega a cor azul
  explodeframe02:
  LDY #$00
  STA (temp2),Y
  LDY #$1F
  STA (temp2),Y
  INY
  INY 
  STA (temp2),Y
  LDY #$3E
  STA (temp2),Y
  INY
  INY
  STA (temp2),Y
  INY
  INY
  STA (temp2),Y
  LDY #$5F
  STA (temp2),Y
  INY
  INY
  STA (temp2),Y
  CMP #$00 ;se pintou de preto, vai para o próximo frame
  BEQ preexplodeframe03
  JSR delay
  LDA #$00
  JMP explodeframe02 ;pinta o frame anterior de preto
  preexplodeframe03:
  LDA temp2 ;recupera o topo da explosão
  SBC #$20  ;move para a linha de cima
  STA temp2 ;salva o LB do novo topo da explosão
  LDA #$0E  ;carrega a cor azul
  explodeframe03:
  LDY #$00
  STA (temp2),Y
  LDY #$1E
  STA (temp2),Y
  LDY #$22
  STA (temp2),Y
  LDY #$5D
  STA (temp2),Y
  LDY #$60
  STA (temp2),Y
  LDY #$63
  STA (temp2),Y
  CMP #$00 ;se pintou de preto, terminou
  BEQ end
  JSR delay
  LDA #$00
  JMP explodeframe03 ;pinta o frame anterior de preto
  JMP end

end:

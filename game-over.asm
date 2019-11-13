define position     $00
define temp         $F0
define temp2        $F1
define temp3        $F2

LDX #$10
STX position
  
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

delay:
  LDX #$FF
  delayLoop:
  DEX
  CPX #$00
  BNE delayLoop
  RTS

end:

	.area text
	.globl _dynamic_dim
_dynamic_dim:
	.byte 32,1
	.byte 7,-1
	.globl _font
_font:
	.byte 95,6
	.byte 59,47
	.byte 'f,'m
	.byte 125,7
	.byte 127,'o
	.byte -33,-122
	.byte -69,-81
	.byte -26,-19
	.byte -3,-121
	.byte -1,-17
	.globl _extender
_extender:
	.byte 0,1
	.byte 3,7
	.byte 15,31
	.byte 63,127
	.byte -1
	.globl _nextdim
_nextdim:
	.word 1
	.word 3
	.word 1
	.word 8
	.word 1
	.word 1
	.word 1
	.word 1
	.word 0
	.area text
	.globl _initialization
_initialization:
	pshx
	tsx
FRAME.79::	; //==10=22=1996==============
; //  frame - old board.
; //==========================
; 
; 
; /////////////////////////////////////////////////////////////////////
; ////board/distribution///////////////////////////////////////////////
; // TO DO -> correct difinitions.
; 
; #define _FIRST_DIGIT_NUMBER_    0  // top board start digit number.
; #define _MIDDLE_DIGIT_NUMBER_   8  // bottom board start digit number.
; #define _LAST_DIGIT_NUMBER_    23
; 
; ////end/board/distribution///////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////
; const unsigned char dynamic_dim[]=
; { ' ' , //===============================
;   0x01, //adjustable - low brightness.
;   0x07, //adjustable - middle brightness.
;   0xff  //===============================
; };
; #define initialdim 1
; #define copreset COPRST=0x55;COPRST=0xAA;if(SCSR&0x80)SCDR=dynamic_dim[dim];
; #define horn_on  if(!mode){PORTA|=0x80;}
; #define horn_off PORTA&=~0x80;
; 
; #include <hc11.h>
; 
; // common data.
; 
; #define _TIMER_ON_  0x80
; unsigned char system_flag;
; 
; unsigned char mode;
; 
; const unsigned char font[]=
; { 0x5f,0x06,0x3b,0x2f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,
;   0xdf,0x86,0xbb,0xaf,0xe6,0xed,0xfd,0x87,0xff,0xef
; };
; const unsigned char extender[]=
; { 0,1,3,7,0xf,0x1f,0x3f,0x7f,0xff
; };
; 
; // global communication data area declarations.
; unsigned char sci_input_buffer;         // buffer for insert of the entered data from sci.
; int           sci_input_counter[2];     // counter of the same appearences.
; unsigned char received;
; unsigned char power_on_restarted;
; 
; // global display data.
; const int nextdim[]=
; { 1,3,1,8,1,1,1,1,0
; };
; int           dim;
; unsigned char *data[_LAST_DIGIT_NUMBER_+1];
; unsigned char *day_time_data[4];
; // data for blinking displays - correspondes to the state machine mode.
; unsigned char blink_character, blink_segments;
; 
; 
; //received symbol set.
; enum
; { _timer_on,_1,_2,_3,_4,_5,_6,_7,_8,_9,_0,
;   _clear,_enter,_home,_possession,_horn,_guest,
;   _home_bonus,_game,_set,_guest_bonus,
;   _home_fouls,_dim,_period,_guest_fouls,
;   _player,_shot,_day,_empty,
;   _1c, _1d, _1e, _timer_off
; };
; 
; //time_out counter
; unsigned no_rx_time;
; 
; //program data.
; unsigned char buffer[4];
; 
; 
; void initialization()
; { sci_input_buffer = 0;
	clra
	clrb
	stab  _sci_input_buffer
FRAME.80::	;   sci_input_counter[0] = 0;
	clra
	clrb
	std  _sci_input_counter
FRAME.81::	;   sci_input_counter[1] = PORTA & 6;
	ldab  4096
	clra
	andb #6
	clra
	std  _sci_input_counter+2
FRAME.83::	; 
;   received = 0;
	clra
	clrb
	stab  _received
FRAME.85::	; 
;   no_rx_time = 0;
	clra
	clrb
	std  _no_rx_time
FRAME.86::	;   dim = initialdim;
	ldd #1
	std  _dim
FRAME.88::	; 
;   system_flag = 0;
	clra
	clrb
	stab  _system_flag
FRAME.90::	; 
;   mode = mode == _day ? _day : 0;
	ldab  _mode
	clra
	cpd #27
	bne  L5
	ldd #27
	std 0,x
	bra  L6
L5:
	clra
	clrb
	std 0,x
L6:
	ldab 1,x
	stab  _mode
FRAME.92::	; 
;   PACTL |= 0x88; // DDRA7 = 1   ==>  PA7, PA3 are output.
	ldab  4134
	orab #136
	stab  4134
FRAME.93::	;   PORTA |= 0x07; // horn off;  PA6,5,4,3 = 0.
	ldab  4096
	orab #7
	stab  4096
FRAME.98::	; 
; 
;   // SPI initialization.
; 
;   PORTD = 0x02;  // ss* - lo,  sck - lo,  mosi - lo.
	ldab #2
	stab  4104
FRAME.99::	;   DDRD  = 0x3e;  // PD5,4,3 - outs.
	ldab #62
	stab  4105
FRAME.100::	;   SPCR  = 0x54;  // spi - master.
	ldab #84
	stab  4136
FRAME.103::	; 
;   // init sci for receive.
;   DDRD &= ~0x01;  // enable receive line.
	ldab  4105
	andb #254
	stab  4105
FRAME.104::	;   BAUD  =  0x33;  // baud rate is equal to 1200 bits per second.
	ldab #51
	stab  4139
FRAME.105::	;   SCCR1 =  0x00;
	clra
	clrb
	stab  4140
FRAME.106::	;   SCCR2 =  0x24;  // RIE,RE bits on.
	ldab #36
	stab  4141
FRAME.111::	; 
; 
;   // timer interrupt initialization.
; 
;   PACTL |= 0x03;               // RTR1=RTR0=1 --> RTI each E/2**16 =   0.032768 sec.
	ldab  4134
	orab #3
	stab  4134
FRAME.112::	;   TMSK2 |= 0x43;               // RTII=1 --> RTI enable. ; clc = e/16
	ldab  4132
	orab #67
	stab  4132
FRAME.115::	; 
;   // for display dynamic dimming mechanizm.
;   SCCR2 |= 0x08;     // sci transmit enable
	ldab  4141
	orab #8
	stab  4141
FRAME.118::	; 
;   // display_blinking mechanism;
;   blink_character = blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
	clra
	clrb
	stab  _blink_character
	pulx
	rts
L2:
	.area bss
L8:
	.blkb 24
	.area text
	.globl _putcharacters
;        i -> 8,x
;  priznak -> 10,x
; begining_digit -> 11,x
;   buffer -> 13,x
_putcharacters:
	tsx
	xgdx
	subd #15
	xgdx
	txs
FRAME.127::	; }
; 
; 
; void putcharacters()
; { int i, begining_digit;
;   static unsigned char intermediate[_LAST_DIGIT_NUMBER_+1];
;   unsigned char priznak, buffer;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L9
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L9:
FRAME.128::	;   begining_digit = PORTE & 8 ? _FIRST_DIGIT_NUMBER_ : _MIDDLE_DIGIT_NUMBER_;
	ldab  4106
	clra
	bitb #8
	beq  L12
	clra
	clrb
	std 6,x
	bra  L13
L12:
	ldd #8
	std 6,x
L13:
	ldd 6,x
	std 11,x
FRAME.129::	;   priznak = 0;
	clra
	clrb
	stab 10,x
FRAME.131::	; 
;   for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
	ldd #23
	std 8,x
L14:
	ldd 8,x
	cpd 11,x
	bge X0
	jmp  L16
X0:
FRAME.132::	;   { if(mode == _day || mode == 100)
	ldab  _mode
	clra
	std 4,x
	cpd #27
	beq  L20
	ldd 4,x
	cpd #100
	bne  L18
L20:
FRAME.133::	;     { if(i<4) buffer = dim ? *(day_time_data[i]) : 0;
	ldd 8,x
	cpd #4
	bge  L21
	ldd  _dim
	std 0,x
	std 2,x
	ldd 0,x
	beq  L24
	ldd #_day_time_data
	pshb
	psha
	ldd 8,x
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldy 0,y
	ldab 0,y
	clra
	std 2,x
L24:
	ldab 3,x
	stab 13,x
	bra  L19
L21:
FRAME.134::	; 	  else    buffer = 0;
	clra
	clrb
	stab 13,x
	bra  L19
L18:
FRAME.136::	; 	}
;     else buffer = dim ? *(data[i]) : 0;
	ldd  _dim
	std 0,x
	std 2,x
	ldd 0,x
	beq  L27
	ldd #_data
	pshb
	psha
	ldd 8,x
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldy 0,y
	ldab 0,y
	clra
	std 2,x
L27:
	ldab 3,x
	stab 13,x
L19:
FRAME.137::	;     if(intermediate[i] != buffer)
	ldab 13,x
	clra
	pshb
	psha
	ldd #L8
	pshb
	psha
	ldd 8,x
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsy
	cpd 0,y
	puly
	beq  L29
FRAME.138::	; 	{ intermediate[i] = buffer;
	ldd #L8
	pshb
	psha
	ldd 8,x
	tsy
	addd 0,y
	puly
	xgdy
	ldab 13,x
	stab 0,y
FRAME.139::	; 	  priznak = 1;
	ldab #1
	stab 10,x
L29:
L15:
	ldd 8,x
	subd #1
	std 8,x
	jmp  L14
L16:
FRAME.143::	; 	} 
;   }
; 
;   if(priznak)
	ldab 10,x
	clra
	cpd #0
	bne X1
	jmp  L31
X1:
FRAME.144::	;   { for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
	ldd #23
	std 8,x
L33:
	ldd 8,x
	cpd 11,x
	blt  L35
FRAME.145::	;     { SPDR = intermediate[i];
	ldd #L8
	pshb
	psha
	ldd 8,x
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4138
L37:
L38:
FRAME.146::	;       while( !(SPSR & 0x80) )
	ldab  4137
	clra
	bitb #128
	bne  L39
FRAME.147::	; 	  { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L37
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
	bra  L37
L39:
L34:
	ldd 8,x
	subd #1
	std 8,x
	bra  L33
L35:
FRAME.150::	; 	  }
;     }
; 	PORTD &= ~0x20;      // SS* - low.
	ldab  4104
	andb #223
	stab  4104
FRAME.151::	;     PORTD |=  0x20;      // SS* - high.
	ldab  4104
	orab #32
	stab  4104
L31:
	xgdx
	addd #15
	xgdx
	txs
	rts
L7:
	.globl _delay
; milliseconds -> 0,x
_delay:
	pshb
	psha
	tsx
FRAME.158::	;   }
; }
; 
; 
; 
; void delay(unsigned int milliseconds)
; { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L46
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L46:
FRAME.159::	;   TOC1 = TCNT + 125*milliseconds ;
	ldy 0,x
	ldd #125
	jsr  __mulu
	pshb
	psha
	ldd  4110
	tsy
	addd 0,y
	puly
	std  4118
FRAME.160::	;   TFLG1 = 0x80;
	ldab #128
	stab  4131
L48:
L49:
FRAME.161::	;   while( !( TFLG1 & 0x80 ) )
	ldab  4131
	clra
	bitb #128
	tsx
	bne  L50
FRAME.162::	;   { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L48
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
	bra  L48
L50:
FRAME.164::	;   }
;   TFLG1 = 0x80;
	ldab #128
	stab  4131
	pulx
	rts
L45:
	.globl _proceed_dim
_proceed_dim:
FRAME.168::	; }
; 
; void proceed_dim()
; { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L54
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L54:
FRAME.169::	;   if( sci_input_buffer == _dim)
	ldab  _sci_input_buffer
	clra
	cpd #22
	bne  L56
FRAME.170::	;   { dim++;
	ldd  _dim
	addd #1
	std  _dim
FRAME.171::	;     dim %= 4;
	ldy #4
	jsr  __modi
	std  _dim
L56:
	tsx
	rts
L53:
	.area bss
L59:
	.blkb 1
L60:
	.blkb 1
L61:
	.blkb 1
L62:
	.blkb 1
	.area text
	.globl _home_score
;     flag -> 4,x
_home_score:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.187::	;   }
; }
; // programma
; 
; //////////////////data*processing//////////////////////////
; 
; #define _NEXT_CHARACTER_   0
; #define _NEXT_TIMER_TICK_  1
; #define _INITIALIZATION_   2
; 
; /////////////////////////////////////////////////////////////////////////////////
; ///////procedures////////////////////////////////////////////////////////////////
; // TO DO -> Enter procedure descriptions here.
; 
; void home_score(unsigned char flag)
; { static unsigned char score, score_10, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.189::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L63
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L63:
FRAME.191::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L65
FRAME.192::	;   { score = 0;
	clra
	clrb
	stab  L59
FRAME.193::	;     score_10 = 0;
	clra
	clrb
	stab  L60
FRAME.194::	;     score_1 = font[0];
	ldab  _font
	stab  L61
FRAME.195::	;     data[4] = &score_10;
	ldd #L60
	std  _data+8
FRAME.196::	; 	data[5] = &score_1;
	ldd #L61
	std  _data+10
	jmp  L66
L65:
FRAME.198::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X2
	jmp  L69
X2:
FRAME.199::	;   { if(!mode && sci_input_buffer == _home)
	ldab  _mode
	clra
	cpd #0
	bne  L71
	ldab  _sci_input_buffer
	clra
	cpd #13
	bne  L71
FRAME.200::	;     { score = (score + 1 ) % 200;
	ldy #200
	ldab  L59
	clra
	addd #1
	jsr  __modi
	stab  L59
FRAME.201::	;       score_10 = score/10 ? font[score / 10] : 0;
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L74
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L74:
	ldab 3,x
	stab  L60
FRAME.202::	; 	  score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L61
	tsx
	jmp  L72
L71:
FRAME.204::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L76
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L76
	ldab #19
	stab  _mode
	jmp  L77
L76:
FRAME.205::	; 	else if(mode == _set && sci_input_buffer == _home)
	ldab  _mode
	clra
	cpd #19
	bne  L78
	ldab  _sci_input_buffer
	clra
	cpd #13
	bne  L78
FRAME.206::	; 	{ mode = _home;
	ldab #13
	stab  _mode
FRAME.207::	; 	  blink_character = 5;
	ldab #5
	stab  _blink_character
FRAME.208::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.209::	; 	  buffer = 0;
	clra
	clrb
	stab  L62
FRAME.210::	;       score_10 = 0;
	clra
	clrb
	stab  L60
FRAME.211::	; 	  score_1 = font[0];
	ldab  _font
	stab  L61
	jmp  L79
L78:
FRAME.213::	; 	}
; 	else if(mode == _home)
	ldab  _mode
	clra
	cpd #13
	beq X3
	jmp  L80
X3:
FRAME.214::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L82
FRAME.215::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.216::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.217::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L85
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L85:
	ldab 3,x
	stab  L60
FRAME.218::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L61
	tsx
	jmp  L83
L82:
FRAME.220::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L87
FRAME.221::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.222::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.223::	; 		score = buffer;
	ldab  L62
	stab  L59
FRAME.224::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L90
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L90:
	ldab 3,x
	stab  L60
FRAME.225::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L59
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L61
	tsx
	jmp  L88
L87:
FRAME.227::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	bge X4
	jmp  L92
X4:
	ldd 2,x
	cpd #10
	ble X5
	jmp  L92
X5:
FRAME.228::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	ldy #10
	ldab  L62
	clra
	ldx #100
	idiv
	jsr  __divi
	cpd #0
	tsx
	beq  L95
	ldab  L62
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	addd #100
	tsx
	std 0,x
	bra  L96
L95:
	ldab  L62
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	tsx
	std 0,x
L96:
	ldab 1,x
	stab  L62
FRAME.229::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L62
	tsy
	addb 0,y
	ins
	stab  L62
FRAME.230::	; 	    score_10 = font[buffer / 10];
	ldd #_font
	pshb
	psha
	ldab  L62
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L60
FRAME.231::	; 		score_1 = font[buffer % 10];
	ldd #_font
	pshb
	psha
	ldab  L62
	clra
	ldx #10
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L61
L92:
L88:
L83:
L80:
L79:
L77:
L72:
L69:
L66:
	tsx
	pulx
	pulx
	pulx
	rts
L58:
	.area bss
L102:
	.blkb 1
L103:
	.blkb 1
L104:
	.blkb 1
L105:
	.blkb 1
	.area text
	.globl _guest_score
;     flag -> 4,x
_guest_score:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.239::	; 	  }
; 	}
;   }
; }
; 
; 
; void guest_score(unsigned char flag)
; { static unsigned char score, score_10, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.241::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L106
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L106:
FRAME.243::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L108
FRAME.244::	;   { score = 0;
	clra
	clrb
	stab  L102
FRAME.245::	;     score_10 = 0;
	clra
	clrb
	stab  L103
FRAME.246::	;     score_1 = font[0];
	ldab  _font
	stab  L104
FRAME.247::	;     data[6] = &score_10;
	ldd #L103
	std  _data+12
FRAME.248::	; 	data[7] = &score_1;
	ldd #L104
	std  _data+14
	jmp  L109
L108:
FRAME.250::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X6
	jmp  L112
X6:
FRAME.251::	;   { if(!mode && sci_input_buffer == _guest)
	ldab  _mode
	clra
	cpd #0
	bne  L114
	ldab  _sci_input_buffer
	clra
	cpd #16
	bne  L114
FRAME.252::	;     { score = (score + 1) % 200;
	ldy #200
	ldab  L102
	clra
	addd #1
	jsr  __modi
	stab  L102
FRAME.253::	;       score_10 = score/10 ? font[score / 10] : 0;
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L117
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L117:
	ldab 3,x
	stab  L103
FRAME.254::	; 	  score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L104
	tsx
	jmp  L115
L114:
FRAME.256::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L119
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L119
	ldab #19
	stab  _mode
	jmp  L120
L119:
FRAME.257::	; 	else if(mode == _set && sci_input_buffer == _guest)
	ldab  _mode
	clra
	cpd #19
	bne  L121
	ldab  _sci_input_buffer
	clra
	cpd #16
	bne  L121
FRAME.258::	; 	{ mode = _guest;
	ldab #16
	stab  _mode
FRAME.259::	; 	  blink_character = 7;
	ldab #7
	stab  _blink_character
FRAME.260::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.261::	; 	  buffer = 0;
	clra
	clrb
	stab  L105
FRAME.262::	;       score_10 = 0;
	clra
	clrb
	stab  L103
FRAME.263::	; 	  score_1 = font[0];
	ldab  _font
	stab  L104
	jmp  L122
L121:
FRAME.265::	; 	}
; 	else if(mode == _guest)
	ldab  _mode
	clra
	cpd #16
	beq X7
	jmp  L123
X7:
FRAME.266::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L125
FRAME.267::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.268::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.269::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L128
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L128:
	ldab 3,x
	stab  L103
FRAME.270::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L104
	tsx
	jmp  L126
L125:
FRAME.272::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L130
FRAME.273::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.274::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.275::	; 		score = buffer;
	ldab  L105
	stab  L102
FRAME.276::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L133
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L133:
	ldab 3,x
	stab  L103
FRAME.277::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L102
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L104
	tsx
	jmp  L131
L130:
FRAME.279::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	bge X8
	jmp  L135
X8:
	ldd 2,x
	cpd #10
	ble X9
	jmp  L135
X9:
FRAME.280::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	ldy #10
	ldab  L105
	clra
	ldx #100
	idiv
	jsr  __divi
	cpd #0
	tsx
	beq  L138
	ldab  L105
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	addd #100
	tsx
	std 0,x
	bra  L139
L138:
	ldab  L105
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	tsx
	std 0,x
L139:
	ldab 1,x
	stab  L105
FRAME.281::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L105
	tsy
	addb 0,y
	ins
	stab  L105
FRAME.282::	; 	    score_10 = font[buffer / 10];
	ldd #_font
	pshb
	psha
	ldab  L105
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L103
FRAME.283::	; 		score_1 = font[buffer % 10];
	ldd #_font
	pshb
	psha
	ldab  L105
	clra
	ldx #10
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L104
L135:
L131:
L126:
L123:
L122:
L120:
L115:
L112:
L109:
	tsx
	pulx
	pulx
	pulx
	rts
L101:
	.area bss
L145:
	.blkb 1
L146:
	.blkb 1
L147:
	.blkb 1
	.area text
	.globl _period
;     flag -> 4,x
_period:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.290::	; 	  }
; 	}
;   }
; }
; 
; void period(unsigned char flag)  //qtr in football.
; { static unsigned char score, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.292::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L148
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L148:
FRAME.294::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L150
FRAME.295::	;   { score = 0;
	clra
	clrb
	stab  L145
FRAME.296::	;     score_1 = 0;
	clra
	clrb
	stab  L146
FRAME.297::	;     data[8] = &score_1;
	ldd #L146
	std  _data+16
	jmp  L151
L150:
FRAME.299::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X10
	jmp  L153
X10:
FRAME.300::	;   { if(!mode && sci_input_buffer == _period)
	ldab  _mode
	clra
	cpd #0
	bne  L155
	ldab  _sci_input_buffer
	clra
	cpd #23
	bne  L155
FRAME.301::	;     { score = (score + 1) % 5;
	ldy #5
	ldab  L145
	clra
	addd #1
	jsr  __modi
	stab  L145
FRAME.302::	;       score_1 = score ? font[score] : 0;
	ldab  L145
	clra
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L158
	ldd #_font
	pshb
	psha
	ldab  L145
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L158:
	ldab 3,x
	stab  L146
	jmp  L156
L155:
FRAME.304::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L160
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L160
	ldab #19
	stab  _mode
	jmp  L161
L160:
FRAME.305::	; 	else if(mode == _set && sci_input_buffer == _period)
	ldab  _mode
	clra
	cpd #19
	bne  L162
	ldab  _sci_input_buffer
	clra
	cpd #23
	bne  L162
FRAME.306::	; 	{ mode = _period;
	ldab #23
	stab  _mode
FRAME.307::	; 	  blink_character = 8;
	ldab #8
	stab  _blink_character
FRAME.308::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.309::	; 	  buffer = 0;
	clra
	clrb
	stab  L147
FRAME.310::	;       score_1 = font[0];
	ldab  _font
	stab  L146
	jmp  L163
L162:
FRAME.312::	; 	}
; 	else if(mode == _period)
	ldab  _mode
	clra
	cpd #23
	beq X11
	jmp  L164
X11:
FRAME.313::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L166
FRAME.314::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.315::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.316::	;         score_1 = score ? font[score] : 0;
	ldab  L145
	clra
	std 0,x
	std 2,x
	ldd 0,x
	beq  L169
	ldd #_font
	pshb
	psha
	ldab  L145
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L169:
	ldab 3,x
	stab  L146
	jmp  L167
L166:
FRAME.318::	;       }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L171
FRAME.319::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.320::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.321::	; 		score = buffer;
	ldab  L147
	stab  L145
FRAME.322::	;         score_1 = score ? font[score] : 0;
	ldab  L145
	clra
	std 0,x
	std 2,x
	ldd 0,x
	beq  L174
	ldd #_font
	pshb
	psha
	ldab  L145
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L174:
	ldab 3,x
	stab  L146
	bra  L172
L171:
FRAME.324::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	blt  L176
	ldd 2,x
	cpd #10
	bgt  L176
FRAME.325::	; 	  { buffer = sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L147
FRAME.326::	; 	    if(buffer > 4) buffer = 0;
	ldab  L147
	clra
	cpd #4
	tsx
	bls  L178
	clra
	clrb
	stab  L147
L178:
FRAME.327::	; 	    score_1 = font[buffer];
	ldd #_font
	pshb
	psha
	ldab  L147
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L146
L176:
L172:
L167:
L164:
L163:
L161:
L156:
L153:
L151:
	pulx
	pulx
	pulx
	rts
L144:
	.area bss
L185:
	.blkb 1
	.area text
	.globl _bonus_possession
;     flag -> 6,x
_bonus_possession:
	pshb
	psha
	pshx
	pshx
	pshx
	tsx
FRAME.334::	; 	  }
; 	}
;   }
; }
; 
; void bonus_possession(unsigned char flag) // possession for football.
; { static unsigned char score;
	ldab 7,x
	stab 6,x
FRAME.336::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L186
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L186:
FRAME.338::	; 
;   if(flag == _INITIALIZATION_)
	ldab 6,x
	clra
	cpd #2
	bne  L188
FRAME.339::	;   { score = 0;
	clra
	clrb
	stab  L185
FRAME.340::	;     data[14] = &score;
	ldd #L185
	std  _data+28
	jmp  L189
L188:
FRAME.342::	;   }
;   else if(flag == _NEXT_CHARACTER_ && !mode)
	ldab 6,x
	clra
	cpd #0
	beq X12
	jmp  L191
X12:
	ldab  _mode
	clra
	cpd #0
	beq X13
	jmp  L191
X13:
FRAME.343::	;   { if(sci_input_buffer == _home_bonus)       score = score & 1 ? score & ~1 : score | 1;
	ldab  _sci_input_buffer
	clra
	cpd #17
	bne  L193
	ldab  L185
	clra
	bitb #1
	beq  L196
	ldab  L185
	clra
	andb #254
	anda #255
	std 4,x
	bra  L197
L196:
	ldab  L185
	clra
	orab #1
	oraa #0
	std 4,x
L197:
	ldab 5,x
	stab  L185
	bra  L194
L193:
FRAME.344::	;     else if(sci_input_buffer == _guest_bonus) score = score & 2 ? score & ~2 : score | 2;
	ldab  _sci_input_buffer
	clra
	cpd #20
	bne  L198
	ldab  L185
	clra
	bitb #2
	beq  L201
	ldab  L185
	clra
	andb #253
	anda #255
	std 2,x
	bra  L202
L201:
	ldab  L185
	clra
	orab #2
	oraa #0
	std 2,x
L202:
	ldab 3,x
	stab  L185
	bra  L199
L198:
FRAME.345::	; 	else if(sci_input_buffer == _possession)  score = score >= 2 ? 1 : 2;
	ldab  _sci_input_buffer
	clra
	cpd #14
	bne  L203
	ldab  L185
	clra
	cpd #2
	blo  L206
	ldd #1
	std 0,x
	bra  L207
L206:
	ldd #2
	std 0,x
L207:
	ldab 1,x
	stab  L185
L203:
L199:
L194:
L191:
L189:
	pulx
	pulx
	pulx
	pulx
	rts
L184:
	.area bss
L209:
	.blkb 1
L210:
	.blkb 1
L211:
	.blkb 1
	.area text
	.globl _home_fouls
;     flag -> 6,x
_home_fouls:
	pshb
	psha
	pshx
	pshx
	pshx
	tsx
FRAME.351::	;   }
; }
; 
; 
; void home_fouls(unsigned char flag)  // home time out for football.
; { static unsigned char score, score_1, buffer;
	ldab 7,x
	stab 6,x
FRAME.353::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L212
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L212:
FRAME.355::	; 
;   if(flag == _INITIALIZATION_)
	ldab 6,x
	clra
	cpd #2
	bne  L214
FRAME.356::	;   { score = 0;
	clra
	clrb
	stab  L209
FRAME.357::	;     score_1 = 0;
	clra
	clrb
	stab  L210
FRAME.358::	;     data[15] = &score_1;
	ldd #L210
	std  _data+30
	jmp  L215
L214:
FRAME.360::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 6,x
	clra
	cpd #0
	beq X14
	jmp  L217
X14:
FRAME.361::	;   { if(!mode && sci_input_buffer == _home_fouls)
	ldab  _mode
	clra
	cpd #0
	bne  L219
	ldab  _sci_input_buffer
	clra
	cpd #21
	bne  L219
FRAME.362::	;     { score = (score + 1) % 20;
	ldy #20
	ldab  L209
	clra
	addd #1
	jsr  __modi
	stab  L209
FRAME.363::	;       score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L209
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L210
	tsx
	jmp  L220
L219:
FRAME.365::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L221
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L221
	ldab #19
	stab  _mode
	jmp  L222
L221:
FRAME.366::	; 	else if(mode == _set && sci_input_buffer == _home_fouls)
	ldab  _mode
	clra
	cpd #19
	bne  L223
	ldab  _sci_input_buffer
	clra
	cpd #21
	bne  L223
FRAME.367::	; 	{ mode = _home_fouls;
	ldab #21
	stab  _mode
FRAME.368::	; 	  blink_character = 15;
	ldab #15
	stab  _blink_character
FRAME.369::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.370::	; 	  buffer = 0;
	clra
	clrb
	stab  L211
FRAME.371::	;       score_1 = font[0];
	ldab  _font
	stab  L210
	jmp  L224
L223:
FRAME.373::	; 	}
; 	else if(mode == _home_fouls)
	ldab  _mode
	clra
	cpd #21
	beq X15
	jmp  L225
X15:
FRAME.374::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L227
FRAME.375::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.376::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.377::	;         score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L209
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L210
	jmp  L228
L227:
FRAME.379::	;       }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L229
FRAME.380::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.381::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.382::	; 		score = buffer;
	ldab  L211
	stab  L209
FRAME.383::	;         score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L209
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L210
	bra  L230
L229:
FRAME.385::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 4,x
	cpd #1
	blt  L231
	ldd 4,x
	cpd #10
	bgt  L231
FRAME.386::	; 	  { buffer = buffer%10 ? 10 : 0;
	ldab  L211
	clra
	ldx #10
	idiv
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L234
	ldd #10
	std 2,x
L234:
	ldab 3,x
	stab  L211
FRAME.387::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L211
	tsy
	addb 0,y
	ins
	stab  L211
FRAME.388::	; 	    score_1 = font[buffer];
	ldd #_font
	pshb
	psha
	ldab  L211
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L210
L231:
L230:
L228:
L225:
L224:
L222:
L220:
L217:
L215:
	tsx
	pulx
	pulx
	pulx
	pulx
	rts
L208:
	.area bss
L239:
	.blkb 1
L240:
	.blkb 1
L241:
	.blkb 1
	.area text
	.globl _guest_fouls
;     flag -> 6,x
_guest_fouls:
	pshb
	psha
	pshx
	pshx
	pshx
	tsx
FRAME.398::	; 	  }
; 	}
;   }
; }
; 
; 
; 
; 
; void guest_fouls(unsigned char flag)   //guest time out for football.
; { static unsigned char score, score_1, buffer;
	ldab 7,x
	stab 6,x
FRAME.400::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L242
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L242:
FRAME.402::	; 
;   if(flag == _INITIALIZATION_)
	ldab 6,x
	clra
	cpd #2
	bne  L244
FRAME.403::	;   { score = 0;
	clra
	clrb
	stab  L239
FRAME.404::	;     score_1 = 0;
	clra
	clrb
	stab  L240
FRAME.405::	;     data[16] = &score_1;
	ldd #L240
	std  _data+32
	jmp  L245
L244:
FRAME.407::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 6,x
	clra
	cpd #0
	beq X16
	jmp  L247
X16:
FRAME.408::	;   { if(!mode && sci_input_buffer == _guest_fouls)
	ldab  _mode
	clra
	cpd #0
	bne  L249
	ldab  _sci_input_buffer
	clra
	cpd #24
	bne  L249
FRAME.409::	;     { score = (score + 1) % 20;
	ldy #20
	ldab  L239
	clra
	addd #1
	jsr  __modi
	stab  L239
FRAME.410::	;       score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L239
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L240
	tsx
	jmp  L250
L249:
FRAME.412::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L251
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L251
	ldab #19
	stab  _mode
	jmp  L252
L251:
FRAME.413::	; 	else if(mode == _set && sci_input_buffer == _guest_fouls)
	ldab  _mode
	clra
	cpd #19
	bne  L253
	ldab  _sci_input_buffer
	clra
	cpd #24
	bne  L253
FRAME.414::	; 	{ mode = _guest_fouls;
	ldab #24
	stab  _mode
FRAME.415::	; 	  blink_character = 16;
	ldab #16
	stab  _blink_character
FRAME.416::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.417::	; 	  buffer = 0;
	clra
	clrb
	stab  L241
FRAME.418::	;       score_1 = font[0];
	ldab  _font
	stab  L240
	jmp  L254
L253:
FRAME.420::	; 	}
; 	else if(mode == _guest_fouls)
	ldab  _mode
	clra
	cpd #24
	beq X17
	jmp  L255
X17:
FRAME.421::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L257
FRAME.422::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.423::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.424::	;         score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L239
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L240
	jmp  L258
L257:
FRAME.426::	;       }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L259
FRAME.427::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.428::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.429::	; 		score = buffer;
	ldab  L241
	stab  L239
FRAME.430::	;         score_1 = font[score];
	ldd #_font
	pshb
	psha
	ldab  L239
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L240
	bra  L260
L259:
FRAME.432::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 4,x
	cpd #1
	blt  L261
	ldd 4,x
	cpd #10
	bgt  L261
FRAME.433::	; 	  { buffer = buffer%10 ? 10 : 0;
	ldab  L241
	clra
	ldx #10
	idiv
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L264
	ldd #10
	std 2,x
L264:
	ldab 3,x
	stab  L241
FRAME.434::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L241
	tsy
	addb 0,y
	ins
	stab  L241
FRAME.435::	; 	    score_1 = font[buffer];
	ldd #_font
	pshb
	psha
	ldab  L241
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L240
L261:
L260:
L258:
L255:
L254:
L252:
L250:
L247:
L245:
	tsx
	pulx
	pulx
	pulx
	pulx
	rts
L238:
	.area bss
L269:
	.blkb 1
L270:
	.blkb 1
L271:
	.blkb 1
	.area text
	.globl _player_foul
;     flag -> 4,x
_player_foul:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.444::	; 	  }
; 	}
;   }
; }
; 
; 
; 
; void player_foul(unsigned char flag) // down for football.
; { static unsigned char score, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.446::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L272
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L272:
FRAME.448::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L274
FRAME.449::	;   { score = 0;
	clra
	clrb
	stab  L269
FRAME.450::	;     score_1 = 0;
	clra
	clrb
	stab  L270
FRAME.451::	;     data[11] = &score_1;
	ldd #L270
	std  _data+22
	jmp  L275
L274:
FRAME.453::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X18
	jmp  L277
X18:
FRAME.454::	;   { if(!mode && sci_input_buffer == _player)
	ldab  _mode
	clra
	cpd #0
	bne  L279
	ldab  _sci_input_buffer
	clra
	cpd #25
	bne  L279
FRAME.455::	;     { score = (score + 1) % 5;
	ldy #5
	ldab  L269
	clra
	addd #1
	jsr  __modi
	stab  L269
FRAME.456::	;       score_1 = score ? font[score] : 0;
	ldab  L269
	clra
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L282
	ldd #_font
	pshb
	psha
	ldab  L269
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L282:
	ldab 3,x
	stab  L270
	jmp  L280
L279:
FRAME.458::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L284
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L284
	ldab #19
	stab  _mode
	jmp  L285
L284:
FRAME.459::	; 	else if(mode == _set && sci_input_buffer == _player)
	ldab  _mode
	clra
	cpd #19
	bne  L286
	ldab  _sci_input_buffer
	clra
	cpd #25
	bne  L286
FRAME.460::	; 	{ mode = _player;
	ldab #25
	stab  _mode
FRAME.461::	; 	  blink_character = 11;
	ldab #11
	stab  _blink_character
FRAME.462::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.463::	; 	  buffer = 0;
	clra
	clrb
	stab  L271
FRAME.464::	;       score_1 = font[0];
	ldab  _font
	stab  L270
	jmp  L287
L286:
FRAME.466::	; 	}
; 	else if(mode == _player)
	ldab  _mode
	clra
	cpd #25
	beq X19
	jmp  L288
X19:
FRAME.467::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L290
FRAME.468::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.469::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.470::	;         score_1 = score ? font[score] : 0;
	ldab  L269
	clra
	std 0,x
	std 2,x
	ldd 0,x
	beq  L293
	ldd #_font
	pshb
	psha
	ldab  L269
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L293:
	ldab 3,x
	stab  L270
	jmp  L291
L290:
FRAME.472::	;       }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L295
FRAME.473::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.474::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.475::	; 		score = buffer;
	ldab  L271
	stab  L269
FRAME.476::	;         score_1 = score ? font[score] : 0;
	ldab  L269
	clra
	std 0,x
	std 2,x
	ldd 0,x
	beq  L298
	ldd #_font
	pshb
	psha
	ldab  L269
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L298:
	ldab 3,x
	stab  L270
	bra  L296
L295:
FRAME.478::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	blt  L300
	ldd 2,x
	cpd #10
	bgt  L300
FRAME.479::	; 	  { buffer = sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L271
FRAME.480::	; 	    if(buffer > 4) buffer = 0;
	ldab  L271
	clra
	cpd #4
	tsx
	bls  L302
	clra
	clrb
	stab  L271
L302:
FRAME.481::	; 	    score_1 = font[buffer];
	ldd #_font
	pshb
	psha
	ldab  L271
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L270
L300:
L296:
L291:
L288:
L287:
L285:
L280:
L277:
L275:
	pulx
	pulx
	pulx
	rts
L268:
	.area bss
L309:
	.blkb 1
L310:
	.blkb 1
L311:
	.blkb 1
L312:
	.blkb 1
	.area text
	.globl _yards_to_go
;     flag -> 4,x
_yards_to_go:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.490::	; 	  }
; 	}
;   }
; }
; 
; 
; 
; void yards_to_go(unsigned char flag)
; { static unsigned char score, score_10, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.492::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L313
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L313:
FRAME.494::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L315
FRAME.495::	;   { score = 0;
	clra
	clrb
	stab  L309
FRAME.496::	;     score_10 = 0;
	clra
	clrb
	stab  L310
FRAME.497::	;     score_1 = font[0];
	ldab  _font
	stab  L311
FRAME.498::	;     data[12] = &score_10;
	ldd #L310
	std  _data+24
FRAME.499::	; 	data[13] = &score_1;
	ldd #L311
	std  _data+26
	jmp  L316
L315:
FRAME.501::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X20
	jmp  L319
X20:
FRAME.502::	;   { if(!mode && sci_input_buffer == _shot)
	ldab  _mode
	clra
	cpd #0
	bne  L321
	ldab  _sci_input_buffer
	clra
	cpd #26
	bne  L321
FRAME.503::	;     { score = (score + 1) % 200;
	ldy #200
	ldab  L309
	clra
	addd #1
	jsr  __modi
	stab  L309
FRAME.504::	;       score_10 = score/10 ? font[score / 10] : 0;
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L324
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L324:
	ldab 3,x
	stab  L310
FRAME.505::	; 	  score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L311
	tsx
	jmp  L322
L321:
FRAME.507::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L326
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L326
	ldab #19
	stab  _mode
	jmp  L327
L326:
FRAME.508::	; 	else if(mode == _set && sci_input_buffer == _shot)
	ldab  _mode
	clra
	cpd #19
	bne  L328
	ldab  _sci_input_buffer
	clra
	cpd #26
	bne  L328
FRAME.509::	; 	{ mode = _shot;
	ldab #26
	stab  _mode
FRAME.510::	; 	  blink_character = 13;
	ldab #13
	stab  _blink_character
FRAME.511::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.512::	; 	  buffer = 0;
	clra
	clrb
	stab  L312
FRAME.513::	;       score_10 = 0;
	clra
	clrb
	stab  L310
FRAME.514::	; 	  score_1 = font[0];
	ldab  _font
	stab  L311
	jmp  L329
L328:
FRAME.516::	; 	}
; 	else if(mode == _shot)
	ldab  _mode
	clra
	cpd #26
	beq X21
	jmp  L330
X21:
FRAME.517::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L332
FRAME.518::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.519::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.520::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L335
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L335:
	ldab 3,x
	stab  L310
FRAME.521::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L311
	tsx
	jmp  L333
L332:
FRAME.523::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L337
FRAME.524::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.525::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.526::	; 		score = buffer;
	ldab  L312
	stab  L309
FRAME.527::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L340
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L340:
	ldab 3,x
	stab  L310
FRAME.528::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L309
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L311
	tsx
	jmp  L338
L337:
FRAME.530::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	bge X22
	jmp  L342
X22:
	ldd 2,x
	cpd #10
	ble X23
	jmp  L342
X23:
FRAME.531::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	ldy #10
	ldab  L312
	clra
	ldx #100
	idiv
	jsr  __divi
	cpd #0
	tsx
	beq  L345
	ldab  L312
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	addd #100
	tsx
	std 0,x
	bra  L346
L345:
	ldab  L312
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	tsx
	std 0,x
L346:
	ldab 1,x
	stab  L312
FRAME.532::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L312
	tsy
	addb 0,y
	ins
	stab  L312
FRAME.533::	; 	    score_10 = font[buffer / 10];
	ldd #_font
	pshb
	psha
	ldab  L312
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L310
FRAME.534::	; 		score_1 = font[buffer % 10];
	ldd #_font
	pshb
	psha
	ldab  L312
	clra
	ldx #10
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L311
L342:
L338:
L333:
L330:
L329:
L327:
L322:
L319:
L316:
	tsx
	pulx
	pulx
	pulx
	rts
L308:
	.area bss
L352:
	.blkb 1
L353:
	.blkb 1
L354:
	.blkb 1
L355:
	.blkb 1
	.area text
	.globl _ball_on
;     flag -> 4,x
_ball_on:
	pshb
	psha
	pshx
	pshx
	tsx
FRAME.543::	; 	  }
; 	}
;   }
; }
; 
; 
; 
; void ball_on(unsigned char flag)
; { static unsigned char score, score_10, score_1, buffer;
	ldab 5,x
	stab 4,x
FRAME.545::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L356
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L356:
FRAME.547::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L358
FRAME.548::	;   { score = 0;
	clra
	clrb
	stab  L352
FRAME.549::	;     score_10 = 0;
	clra
	clrb
	stab  L353
FRAME.550::	;     score_1 = font[0];
	ldab  _font
	stab  L354
FRAME.551::	;     data[9] = &score_10;
	ldd #L353
	std  _data+18
FRAME.552::	; 	data[10] = &score_1;
	ldd #L354
	std  _data+20
	jmp  L359
L358:
FRAME.554::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X24
	jmp  L362
X24:
FRAME.555::	;   { if(!mode && sci_input_buffer == _empty)
	ldab  _mode
	clra
	cpd #0
	bne  L364
	ldab  _sci_input_buffer
	clra
	cpd #28
	bne  L364
FRAME.556::	;     { score =(score + 1) % 200;
	ldy #200
	ldab  L352
	clra
	addd #1
	jsr  __modi
	stab  L352
FRAME.557::	;       score_10 = score/10 ? font[score / 10] : 0;
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L367
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L367:
	ldab 3,x
	stab  L353
FRAME.558::	; 	  score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L354
	tsx
	jmp  L365
L364:
FRAME.560::	; 	}
; 	else if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L369
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L369
	ldab #19
	stab  _mode
	jmp  L370
L369:
FRAME.561::	; 	else if(mode == _set && sci_input_buffer == _empty)
	ldab  _mode
	clra
	cpd #19
	bne  L371
	ldab  _sci_input_buffer
	clra
	cpd #28
	bne  L371
FRAME.562::	; 	{ mode = _empty;
	ldab #28
	stab  _mode
FRAME.563::	; 	  blink_character = 10;
	ldab #10
	stab  _blink_character
FRAME.564::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
FRAME.565::	; 	  buffer = 0;
	clra
	clrb
	stab  L355
FRAME.566::	;       score_10 = 0;
	clra
	clrb
	stab  L353
FRAME.567::	; 	  score_1 = font[0];
	ldab  _font
	stab  L354
	jmp  L372
L371:
FRAME.569::	; 	}
; 	else if(mode == _empty)
	ldab  _mode
	clra
	cpd #28
	beq X25
	jmp  L373
X25:
FRAME.570::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L375
FRAME.571::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.572::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.573::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L378
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L378:
	ldab 3,x
	stab  L353
FRAME.574::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L354
	tsx
	jmp  L376
L375:
FRAME.576::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L380
FRAME.577::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.578::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.579::	; 		score = buffer;
	ldab  L355
	stab  L352
FRAME.580::	;         score_10 = score/10 ? font[score / 10] : 0;
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L383
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	tsx
	std 2,x
L383:
	ldab 3,x
	stab  L353
FRAME.581::	;         score_1 = font[score % 20];
	ldd #_font
	pshb
	psha
	ldab  L352
	clra
	ldx #20
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L354
	tsx
	jmp  L381
L380:
FRAME.583::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	bge X26
	jmp  L385
X26:
	ldd 2,x
	cpd #10
	ble X27
	jmp  L385
X27:
FRAME.584::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	ldy #10
	ldab  L355
	clra
	ldx #100
	idiv
	jsr  __divi
	cpd #0
	tsx
	beq  L388
	ldab  L355
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	addd #100
	tsx
	std 0,x
	bra  L389
L388:
	ldab  L355
	clra
	ldx #10
	idiv
	xgdy
	ldd #10
	jsr  __muli
	tsx
	std 0,x
L389:
	ldab 1,x
	stab  L355
FRAME.585::	; 	    buffer += sci_input_buffer % 10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	pshb
	ldab  L355
	tsy
	addb 0,y
	ins
	stab  L355
FRAME.586::	; 	    score_10 = font[buffer / 10];
	ldd #_font
	pshb
	psha
	ldab  L355
	clra
	ldx #10
	idiv
	xgdx
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L353
FRAME.587::	; 		score_1 = font[buffer % 10];
	ldd #_font
	pshb
	psha
	ldab  L355
	clra
	ldx #10
	idiv
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L354
L385:
L381:
L376:
L373:
L372:
L370:
L365:
L362:
L359:
	tsx
	pulx
	pulx
	pulx
	rts
L351:
	.globl _test_segments
; data_buffer -> 4,x
;        j -> 52,x
;        i -> 53,x
_test_segments:
	tsx
	xgdx
	subd #55
	xgdx
	txs
FRAME.600::	; 	  }
; 	}
;   }
; }
; 
; 
; ///////end/procedures////////////////////////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////////////////
; 
; void test_segments()
; { unsigned char *data_buffer[_LAST_DIGIT_NUMBER_ + 1];
;   unsigned char i,j;
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L395
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L395:
FRAME.602::	; 
;   if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L397
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L397
	ldab #19
	stab  _mode
	jmp  L398
L397:
FRAME.603::	;   else if(mode == _set && sci_input_buffer == _8) mode = _8;
	ldab  _mode
	clra
	cpd #19
	bne  L399
	ldab  _sci_input_buffer
	clra
	cpd #8
	bne  L399
	ldab #8
	stab  _mode
	jmp  L400
L399:
FRAME.604::	;   else if(mode == _8 && sci_input_buffer == _enter)
	ldab  _mode
	clra
	cpd #8
	beq X28
	jmp  L401
X28:
	ldab  _sci_input_buffer
	clra
	cpd #12
	beq X29
	jmp  L401
X29:
FRAME.605::	;   { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data_buffer[i] = data[i];
	clra
	clrb
	stab 53,x
L403:
	ldab 53,x
	clra
	cpd #23
	bhi  L405
	ldab 53,x
	clra
	lsld
	std 2,x
	xgdx
	addd #4
	pshb
	psha
	tsx
	inx
	inx
	ldd 2,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	ldd #_data
	pshb
	psha
	ldd 2,x
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	puly
	std 0,y
L404:
	ldab 53,x
	incb
	stab 53,x
	bra  L403
L405:
FRAME.606::	;     for(j = 0; j < 7; j++)
	clra
	clrb
	stab 52,x
L407:
	ldab 52,x
	clra
	cpd #7
	blo X30
	jmp  L409
X30:
FRAME.607::	;     { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)(extender+8);
	clra
	clrb
	stab 53,x
L411:
	ldab 53,x
	clra
	cpd #23
	bhi  L413
	ldd #_data
	pshb
	psha
	ldab 53,x
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_extender+8
	std 0,y
L412:
	ldab 53,x
	incb
	stab 53,x
	bra  L411
L413:
FRAME.608::	;       putcharacters();
	jsr  _putcharacters
FRAME.609::	; 	  for(i=0;i<3;i++) delay(500);
	clra
	clrb
	tsx
	stab 53,x
L416:
	ldab 53,x
	clra
	cpd #3
	bhs  L418
	ldd #500
	jsr  _delay
L417:
	tsx
	ldab 53,x
	incb
	stab 53,x
	bra  L416
L418:
FRAME.610::	;       for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	clra
	clrb
	stab 53,x
L420:
	ldab 53,x
	clra
	cpd #23
	bhi  L422
	ldd #_data
	pshb
	psha
	ldab 53,x
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_extender
	std 0,y
L421:
	ldab 53,x
	incb
	stab 53,x
	bra  L420
L422:
FRAME.611::	; 	  putcharacters();
	jsr  _putcharacters
FRAME.612::	; 	  for(i=0;i<3;i++) delay(500);
	clra
	clrb
	tsx
	stab 53,x
L424:
	ldab 53,x
	clra
	cpd #3
	bhs  L426
	ldd #500
	jsr  _delay
L425:
	tsx
	ldab 53,x
	incb
	stab 53,x
	bra  L424
L426:
L408:
	ldab 52,x
	incb
	stab 52,x
	jmp  L407
L409:
FRAME.614::	;     }
;     for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = data_buffer[i];
	clra
	clrb
	stab 53,x
L428:
	ldab 53,x
	clra
	cpd #23
	bhi  L430
	ldab 53,x
	clra
	lsld
	std 0,x
	ldd #_data
	pshb
	psha
	ldd 0,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	xgdx
	addd #4
	pshb
	psha
	tsx
	inx
	inx
	inx
	inx
	ldd 0,x
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	puly
	std 0,y
L429:
	ldab 53,x
	incb
	stab 53,x
	bra  L428
L430:
FRAME.615::	; 	mode = 0;
	clra
	clrb
	stab  _mode
L401:
L400:
L398:
	xgdx
	addd #55
	xgdx
	txs
	rts
L394:
	.area bss
L435:
	.blkb 4
L436:
	.blkb 4
L437:
	.blkb 4
L438:
	.blkb 1
L439:
	.blkb 1
L440:
	.blkb 1
L441:
	.blkb 1
	.area text
	.globl _day_time
;        i -> 15,x
;     flag -> 16,x
_day_time:
	pshb
	psha
	tsx
	xgdx
	subd #16
	xgdx
	txs
FRAME.622::	;   }
; 
; }
; 
; 
; void day_time(unsigned char flag)
; { static unsigned char time[4];
	ldab 17,x
	stab 16,x
FRAME.629::	;   static float counter;
;   static unsigned char buffer[4];
;   static unsigned char h,hh,m,mm;
; 
;   unsigned char i;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L442
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L442:
FRAME.631::	; 
;   if(flag == _INITIALIZATION_)
	ldab 16,x
	clra
	cpd #2
	bne  L444
FRAME.632::	;   { if(power_on_restarted)
	ldab  _power_on_restarted
	clra
	cpd #0
	beq  L446
FRAME.633::	;     { time[0] = 0;
	clra
	clrb
	stab  L435
FRAME.634::	;       time[1] = 1;
	ldab #1
	stab  L435+1
FRAME.635::	; 	  time[2] = 0;
	clra
	clrb
	stab  L435+2
FRAME.636::	; 	  time[3] = 0;
	clra
	clrb
	stab  L435+3
FRAME.637::	; 	  counter = 0.0;
	ldy #L451
	ldd #L436
	xgdx
	jsr  __copy_float
FRAME.638::	; 	  power_on_restarted = 0;
	clra
	clrb
	stab  _power_on_restarted
L446:
FRAME.640::	; 	}
;     day_time_data[0] = &hh;
	ldd #L439
	std  _day_time_data
FRAME.641::	; 	day_time_data[1] = &h;
	ldd #L438
	std  _day_time_data+2
FRAME.642::	; 	day_time_data[2] = &mm;
	ldd #L441
	std  _day_time_data+4
FRAME.643::	; 	day_time_data[3] = &m;
	ldd #L440
	std  _day_time_data+6
	tsx
	jmp  L445
L444:
FRAME.646::	;   }
; 
;   else if(flag == _NEXT_TIMER_TICK_)
	ldab 16,x
	clra
	cpd #1
	beq X31
	jmp  L455
X31:
FRAME.647::	;   { if((counter+=0.032768) >= 60.0)
	ldd #L459
	pshb
	psha
	ldd #L436
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpadd
	tsx
	xgdx
	addd #7
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #7
	xgdy
	tsx
	xgdx
	addd #11
	xgdx
	jsr  __copy_float
	tsx
	xgdx
	addd #11
	xgdy
	ldd #L436
	xgdx
	jsr  __copy_float
	ldd #L460
	pshb
	psha
	tsx
	inx
	inx
	xgdx
	addd #11
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpcmp
	tsx
	bge X32
	jmp  L457
X32:
FRAME.648::	;     { counter -= 60.0;
	ldd #L460
	pshb
	psha
	ldd #L436
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpsub
	tsx
	xgdx
	addd #3
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #3
	xgdy
	ldd #L436
	xgdx
	jsr  __copy_float
FRAME.649::	; 	  if((++time[3])>=10)
	ldab  L435+3
	incb
	tsx
	stab 2,x
	ldab 2,x
	stab  L435+3
	ldab 2,x
	clra
	cpd #10
	bhs X33
	jmp  L461
X33:
FRAME.650::	; 	  { time[3] = 0;
	clra
	clrb
	stab  L435+3
FRAME.651::	; 	    if((++time[2])>=6)
	ldab  L435+2
	incb
	stab 1,x
	ldab 1,x
	stab  L435+2
	ldab 1,x
	clra
	cpd #6
	blo  L465
FRAME.652::	; 		{ time[2] = 0;
	clra
	clrb
	stab  L435+2
FRAME.653::	; 		  time[1]++;
	ldab  L435+1
	incb
	stab  L435+1
FRAME.654::	; 		  if((time[0] && time[1]>=3) || (!time[0] && time[1]>=10))
	ldab  L435
	clra
	cpd #0
	beq  L475
	ldab  L435+1
	clra
	cpd #3
	bhs  L474
L475:
	ldab  L435
	clra
	cpd #0
	bne  L470
	ldab  L435+1
	clra
	cpd #10
	blo  L470
L474:
FRAME.655::	; 		  { time[1] = 0;
	clra
	clrb
	stab  L435+1
FRAME.656::	; 		    if((++time[0])>=2)
	ldab  L435
	incb
	stab 0,x
	ldab 0,x
	stab  L435
	ldab 0,x
	clra
	cpd #2
	blo  L477
FRAME.657::	; 			{ time[0] = 0;
	clra
	clrb
	stab  L435
FRAME.658::	; 			  time[1] = 1;
	ldab #1
	stab  L435+1
L477:
L470:
L465:
L461:
L457:
FRAME.665::	; 			}
; 		  }
; 		}
; 	  }
;     }
; 
; 	if(mode == _day)
	ldab  _mode
	clra
	cpd #27
	beq X34
	jmp  L456
X34:
FRAME.666::	; 	{ hh = time[0] ? font[1] : 0;
	ldab  L435
	clra
	std 3,x
	std 5,x
	ldd 3,x
	beq  L484
	ldab  _font+1
	clra
	std 5,x
L484:
	ldab 6,x
	stab  L439
FRAME.667::	; 	  h  = font[time[1]];
	ldd #_font
	pshb
	psha
	ldab  L435+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L438
FRAME.668::	; 	  mm = font[time[2]];
	ldd #_font
	pshb
	psha
	ldab  L435+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L441
FRAME.669::	; 	  m  = font[time[3]];
	ldd #_font
	pshb
	psha
	ldab  L435+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L440
	jmp  L456
L455:
FRAME.673::	;     }
;   }
; 
;   else if(flag == _NEXT_CHARACTER_)
	ldab 16,x
	clra
	cpd #0
	beq X35
	jmp  L489
X35:
FRAME.674::	;   { if(!mode && sci_input_buffer == _day) mode = _day;
	ldab  _mode
	clra
	cpd #0
	bne  L491
	ldab  _sci_input_buffer
	clra
	cpd #27
	bne  L491
	ldab #27
	stab  _mode
	jmp  L492
L491:
FRAME.675::	;     else if((!mode || mode==_day) && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	std 13,x
	beq  L495
	ldd 13,x
	cpd #27
	bne  L493
L495:
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L493
	ldab #19
	stab  _mode
	jmp  L494
L493:
FRAME.676::	;     else if(mode == _set && sci_input_buffer == _day)
	ldab  _mode
	clra
	cpd #19
	bne  L496
	ldab  _sci_input_buffer
	clra
	cpd #27
	bne  L496
FRAME.677::	; 	{ mode = 100;
	ldab #100
	stab  _mode
FRAME.678::	; 	  hh = h = mm = m = font[0];
	ldab  _font
	stab 12,x
	ldab 12,x
	stab  L440
	ldab 12,x
	stab  L441
	ldab 12,x
	stab  L438
	ldab 12,x
	stab  L439
FRAME.679::	; 	  for(i=0;i<4;i++) buffer[i] = 0;
	clra
	clrb
	stab 15,x
L498:
	ldab 15,x
	clra
	cpd #4
	bhs  L500
	ldd #L437
	pshb
	psha
	ldab 15,x
	clra
	tsy
	addd 0,y
	puly
	xgdy
	clra
	clrb
	stab 0,y
L499:
	ldab 15,x
	incb
	stab 15,x
	bra  L498
L500:
FRAME.680::	; 	  blink_character = 3;
	ldab #3
	stab  _blink_character
FRAME.681::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
	jmp  L497
L496:
FRAME.683::	; 	}
; 	else if(mode == 100)
	ldab  _mode
	clra
	cpd #100
	beq X36
	jmp  L502
X36:
FRAME.684::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	ldab  _sci_input_buffer
	clra
	std 11,x
	cpd #1
	bge X37
	jmp  L504
X37:
	ldd 11,x
	cpd #10
	ble X38
	jmp  L504
X38:
FRAME.685::	; 	  { for(i=0;i<3;i++) buffer[i]=buffer[i+1];
	clra
	clrb
	stab 15,x
L506:
	ldab 15,x
	clra
	cpd #3
	bhs  L508
	ldab 15,x
	clra
	std 9,x
	ldd #L437
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	ldd #L437+1
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	puly
	stab 0,y
L507:
	ldab 15,x
	incb
	stab 15,x
	bra  L506
L508:
FRAME.686::	; 	    buffer[3] = sci_input_buffer%10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L437+3
FRAME.687::	; 	    hh = font[buffer[0]];
	ldd #_font
	pshb
	psha
	ldab  L437
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L439
FRAME.688::	; 	    h  = font[buffer[1]];
	ldd #_font
	pshb
	psha
	ldab  L437+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L438
FRAME.689::	; 	    mm = font[buffer[2]];
	ldd #_font
	pshb
	psha
	ldab  L437+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L441
FRAME.690::	; 	    m =  font[buffer[3]];
	ldd #_font
	pshb
	psha
	ldab  L437+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L440
	tsx
	jmp  L503
L504:
FRAME.692::	; 	  }
; 	  else if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L515
FRAME.693::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.694::	; 	    mode = _day;
	ldab #27
	stab  _mode
	jmp  L503
L515:
FRAME.696::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L503
FRAME.697::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.698::	;         for(i=0;i<4;i++) time[i] = buffer[i];
	clra
	clrb
	stab 15,x
L519:
	ldab 15,x
	clra
	cpd #4
	bhs  L521
	ldab 15,x
	clra
	std 9,x
	ldd #L435
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	ldd #L437
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	puly
	stab 0,y
L520:
	ldab 15,x
	incb
	stab 15,x
	bra  L519
L521:
FRAME.699::	; 		mode = _day;
	ldab #27
	stab  _mode
	bra  L503
L502:
FRAME.702::	; 	  }
; 	}
;     else if(mode == _day && sci_input_buffer == _game)  mode = 0;
	ldab  _mode
	clra
	cpd #27
	bne  L523
	ldab  _sci_input_buffer
	clra
	cpd #18
	bne  L523
	clra
	clrb
	stab  _mode
L523:
L503:
L497:
L494:
L492:
L489:
L456:
L445:
	xgdx
	addd #18
	xgdx
	txs
	rts
L434:
	.area bss
L538:
	.blkb 4
L539:
	.blkb 4
L540:
	.blkb 2
L541:
	.blkb 4
L542:
	.blkb 1
L543:
	.blkb 1
L544:
	.blkb 1
L545:
	.blkb 1
L546:
	.blkb 1
L547:
	.blkb 1
L548:
	.blkb 1
L549:
	.blkb 2
L550:
	.blkb 2
L551:
	.blkb 2
L552:
	.blkb 2
	.area text
	.globl _game_time
;        i -> 16,x
;     flag -> 17,x
_game_time:
	pshb
	psha
	tsx
	xgdx
	subd #17
	xgdx
	txs
FRAME.708::	;   }
; }
; 
; 
; void game_time(unsigned char flag)
; { static unsigned char time[4];
	ldab 18,x
	stab 17,x
FRAME.716::	;   static float counter;
;   static unsigned long game_time_maximum;
;   static unsigned char buffer[4], game_time_direction, game_started, timer_restarted;
;   static unsigned char h,hh,m,mm;
;   static unsigned long horn_time, horn_buffer, horn_time_maximum, horn_condition;
;   unsigned char i;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L553
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L553:
FRAME.718::	; 
;   if(flag == _INITIALIZATION_)
	ldab 17,x
	clra
	cpd #2
	beq X39
	jmp  L555
X39:
FRAME.719::	;   { horn_off
	ldab  4096
	andb #127
	stab  4096
FRAME.720::	;     horn_condition = 0;
	clra
	clrb
	std  L552
FRAME.721::	;     time[0] = 0;
	stab  L538
FRAME.722::	;     time[1] = 0;
	clra
	clrb
	stab  L538+1
FRAME.723::	; 	time[2] = 0;
	clra
	clrb
	stab  L538+2
FRAME.724::	; 	time[3] = 0;
	clra
	clrb
	stab  L538+3
FRAME.725::	; 	game_time_maximum = 1800;  //30 minutes.
	ldd #1800
	std  L540
FRAME.726::	; 	horn_time = horn_buffer = 0;
	clra
	clrb
	std  L550
	std  L549
FRAME.727::	; 	horn_time_maximum = 5*32;
	ldd #160
	std  L551
FRAME.728::	; 	game_started = timer_restarted = 0;
	clra
	clrb
	stab  L544
	clra
	clrb
	stab  L543
FRAME.729::	; 	counter = 0.0;
	ldy #L451
	ldd #L539
	xgdx
	jsr  __copy_float
FRAME.730::	;     data[0] = &hh;
	ldd #L546
	std  _data
FRAME.731::	; 	data[1] = &h;
	ldd #L545
	std  _data+2
FRAME.732::	; 	data[2] = &mm;
	ldd #L548
	std  _data+4
FRAME.733::	; 	data[3] = &m;
	ldd #L547
	std  _data+6
	tsx
	jmp  L556
L555:
FRAME.736::	;   }
; 
;   else if(flag == _NEXT_TIMER_TICK_)
	ldab 17,x
	clra
	cpd #1
	beq X40
	jmp  L563
X40:
FRAME.737::	;   { if(!(system_flag & _TIMER_ON_)) timer_restarted = 1;
	ldab  _system_flag
	clra
	bitb #128
	bne  L565
	ldab #1
	stab  L544
	jmp  L566
L565:
FRAME.738::	;     else if(game_started && timer_restarted)
	ldab  L543
	clra
	cpd #0
	bne X41
	jmp  L567
X41:
	ldab  L544
	clra
	cpd #0
	bne X42
	jmp  L567
X42:
FRAME.739::	;      if(game_time_direction && (((time[0]*10+time[1])*6+time[2])*10+time[3])<game_time_maximum )
	ldab  L542
	clra
	cpd #0
	bne X43
	jmp  L569
X43:
	ldab  L538+3
	clra
	pshb
	psha
	ldab  L538+2
	clra
	pshb
	psha
	ldab  L538+1
	clra
	pshb
	psha
	ldab  L538
	clra
	xgdy
	ldd #10
	jsr  __mulu
	tsy
	addd 0,y
	puly
	xgdy
	ldd #6
	jsr  __muli
	tsy
	addd 0,y
	puly
	xgdy
	ldd #10
	jsr  __muli
	tsy
	addd 0,y
	puly
	cpd  L540
	tsx
	blo X44
	jmp  L569
X44:
FRAME.740::	; 	 { if((counter += 0.032768) >= 1.0)
	ldd #L459
	pshb
	psha
	ldd #L539
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpadd
	tsx
	xgdx
	addd #8
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #8
	xgdy
	tsx
	xgdx
	addd #12
	xgdx
	jsr  __copy_float
	tsx
	xgdx
	addd #12
	xgdy
	ldd #L539
	xgdx
	jsr  __copy_float
	ldd #L576
	pshb
	psha
	tsx
	inx
	inx
	xgdx
	addd #12
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpcmp
	tsx
	bge X45
	jmp  L570
X45:
FRAME.741::	;        { counter -= 1.0;
	ldd #L576
	pshb
	psha
	ldd #L539
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpsub
	tsx
	xgdx
	addd #4
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #4
	xgdy
	ldd #L539
	xgdx
	jsr  __copy_float
FRAME.742::	; 	     if((++time[3])>=10)
	ldab  L538+3
	incb
	tsx
	stab 3,x
	ldab 3,x
	stab  L538+3
	ldab 3,x
	clra
	cpd #10
	bhs X46
	jmp  L570
X46:
FRAME.743::	; 	     { time[3] = 0;
	clra
	clrb
	stab  L538+3
FRAME.744::	; 	       if((++time[2])>=6)
	ldab  L538+2
	incb
	stab 2,x
	ldab 2,x
	stab  L538+2
	ldab 2,x
	clra
	cpd #6
	bhs X47
	jmp  L570
X47:
FRAME.745::	; 		   { time[2] = 0;
	clra
	clrb
	stab  L538+2
FRAME.746::	; 		     if((++time[1])>=10)
	ldab  L538+1
	incb
	stab 1,x
	ldab 1,x
	stab  L538+1
	ldab 1,x
	clra
	cpd #10
	bhs X48
	jmp  L570
X48:
FRAME.747::	; 		     { time[1] = 0;
	clra
	clrb
	stab  L538+1
FRAME.748::	; 		       if((++time[0])>=10)
	ldab  L538
	incb
	stab 0,x
	ldab 0,x
	stab  L538
	ldab 0,x
	clra
	cpd #10
	bhs X49
	jmp  L570
X49:
FRAME.749::	; 			   { time[0] = 0;
	clra
	clrb
	stab  L538
	jmp  L570
L569:
FRAME.756::	; 		       }
; 		     }
; 		   }
; 	     }
;        }
; 	 }
; 	 else if( !game_time_direction && (time[0] | time[1] | time[2] | time[3]) )
	ldab  L542
	clra
	cpd #0
	beq X50
	jmp  L591
X50:
	ldab  L538+3
	clra
	pshb
	psha
	ldab  L538+2
	clra
	pshb
	psha
	ldab  L538+1
	clra
	pshb
	psha
	ldab  L538
	clra
	tsy
	orab 1,y
	oraa 0,y
	puly
	tsy
	orab 1,y
	oraa 0,y
	puly
	tsy
	orab 1,y
	oraa 0,y
	puly
	cpd #0
	bne X51
	jmp  L591
X51:
FRAME.757::	; 	 { if((counter -= 0.032768) <= -1.0)
	ldd #L459
	pshb
	psha
	ldd #L539
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpsub
	tsx
	xgdx
	addd #8
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #8
	xgdy
	tsx
	xgdx
	addd #12
	xgdx
	jsr  __copy_float
	tsx
	xgdx
	addd #12
	xgdy
	ldd #L539
	xgdx
	jsr  __copy_float
	ldd #L598
	pshb
	psha
	tsx
	inx
	inx
	xgdx
	addd #12
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpcmp
	tsx
	ble X52
	jmp  L596
X52:
FRAME.758::	;        { counter += 1.0;
	ldd #L576
	pshb
	psha
	ldd #L539
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpadd
	tsx
	xgdx
	addd #4
	xgdx
	jsr  __from_fpacc1
	tsx
	xgdx
	addd #4
	xgdy
	ldd #L539
	xgdx
	jsr  __copy_float
FRAME.759::	; 	     if(time[3]>0) time[3]--;
	ldab  L538+3
	clra
	cpd #0
	tsx
	bls  L599
	ldab  L538+3
	subb #1
	stab  L538+3
	bra  L600
L599:
FRAME.761::	; 	     else
; 		 { time[3] = 9;
	ldab #9
	stab  L538+3
FRAME.762::	; 	       if(time[2]>0) time[2]--;
	ldab  L538+2
	clra
	cpd #0
	bls  L604
	ldab  L538+2
	subb #1
	stab  L538+2
	bra  L605
L604:
FRAME.764::	; 		   else
; 		   { time[2] = 5;
	ldab #5
	stab  L538+2
FRAME.765::	; 		     if(time[1]>0) time[1]--;
	ldab  L538+1
	clra
	cpd #0
	bls  L609
	ldab  L538+1
	subb #1
	stab  L538+1
	bra  L610
L609:
FRAME.767::	; 		     else
; 			 { if(time[0]>0)
	ldab  L538
	clra
	cpd #0
	bls  L613
FRAME.768::	; 			   { time[1] = 9;
	ldab #9
	stab  L538+1
FRAME.769::	; 		         time[0]--;
	ldab  L538
	subb #1
	stab  L538
L613:
L610:
L605:
L600:
L596:
L591:
L570:
L567:
L566:
FRAME.777::	; 			   }
; 		     }
; 		   }
; 	     }
;        }
; 	 }
; 
; 	if(mode != _game)
	ldab  _mode
	clra
	cpd #18
	bne X53
	jmp  L616
X53:
FRAME.778::	;       if(!time[0] && !time[1] && !game_time_direction && game_started)
	ldab  L538
	clra
	cpd #0
	beq X54
	jmp  L618
X54:
	ldab  L538+1
	clra
	cpd #0
	beq X55
	jmp  L618
X55:
	ldab  L542
	clra
	cpd #0
	beq X56
	jmp  L618
X56:
	ldab  L543
	clra
	cpd #0
	bne X57
	jmp  L618
X57:
FRAME.779::	; 	  { hh = time[2] ? font[time[2]] : 0;
	ldab  L538+2
	clra
	std 12,x
	std 14,x
	ldd 12,x
	beq  L624
	ldd #_font
	pshb
	psha
	ldab  L538+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 14,x
L624:
	ldab 15,x
	stab  L546
FRAME.780::	; 	    h  = time[2] | time[3] ? font[time[3]] : 0;
	ldab  L538+3
	clra
	pshb
	psha
	ldab  L538+2
	clra
	tsy
	orab 1,y
	oraa 0,y
	puly
	std 8,x
	std 10,x
	ldd 8,x
	beq  L630
	ldd #_font
	pshb
	psha
	ldab  L538+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 10,x
L630:
	ldab 11,x
	stab  L545
FRAME.781::	; 		mm = font[(int)(-counter*10)];
	ldd #_font
	pshb
	psha
	ldd #L539
	xgdx
	jsr  __to_fpacc1
	jsr  __fpneg
	tsx
	inx
	inx
	xgdx
	addd #4
	xgdx
	jsr  __from_fpacc1
	tsx
	inx
	inx
	xgdx
	addd #4
	pshb
	psha
	ldd #L632
	xgdx
	jsr  __to_fpacc1
	tsy
	ldx 0,y
	puly
	jsr  __to_fpacc2
	jsr  __fpmul
	tsx
	inx
	inx
	xgdx
	addd #4
	xgdx
	jsr  __from_fpacc1
	tsx
	inx
	inx
	xgdx
	addd #4
	xgdx
	jsr  __to_fpacc1
	jsr  __fp_to_int
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L548
FRAME.782::	; 		m  = 0;
	clra
	clrb
	stab  L547
	tsx
	bra  L619
L618:
FRAME.785::	; 	  }
; 	  else
; 	  { hh = time[0] ? font[time[0]] : 0;
	ldab  L538
	clra
	std 12,x
	std 14,x
	ldd 12,x
	beq  L634
	ldd #_font
	pshb
	psha
	ldab  L538
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 14,x
L634:
	ldab 15,x
	stab  L546
FRAME.786::	; 	    h  = font[time[1]];
	ldd #_font
	pshb
	psha
	ldab  L538+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L545
FRAME.787::	; 	    mm = font[time[2]];
	ldd #_font
	pshb
	psha
	ldab  L538+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L548
FRAME.788::	; 	    m  = font[time[3]];
	ldd #_font
	pshb
	psha
	ldab  L538+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L547
L619:
L616:
FRAME.791::	;       }
; 
; 	if(game_started)
	ldab  L543
	clra
	cpd #0
	bne X58
	jmp  L564
X58:
FRAME.792::	; 	 if(!horn_time)
	ldd  L549
	beq X59
	jmp  L641
X59:
FRAME.793::	; 	 { if((!time[0] && !time[1] && !time[2] && !time[3] && !game_time_direction) ||
	ldab  L538
	clra
	cpd #0
	bne  L655
	ldab  L538+1
	clra
	cpd #0
	bne  L655
	ldab  L538+2
	clra
	cpd #0
	bne  L655
	ldab  L538+3
	clra
	cpd #0
	bne  L655
	ldab  L542
	clra
	cpd #0
	beq  L651
L655:
	ldab  L538+3
	clra
	pshb
	psha
	ldab  L538+2
	clra
	pshb
	psha
	ldab  L538+1
	clra
	pshb
	psha
	ldab  L538
	clra
	xgdy
	ldd #10
	jsr  __mulu
	tsy
	addd 0,y
	puly
	xgdy
	ldd #6
	jsr  __muli
	tsy
	addd 0,y
	puly
	xgdy
	ldd #10
	jsr  __muli
	tsy
	addd 0,y
	puly
	cpd  L540
	tsx
	bhs X60
	jmp  L564
X60:
	ldab  L542
	clra
	cpd #0
	bne X61
	jmp  L564
X61:
L651:
FRAME.795::	; 	   (((((time[0]*10+time[1])*6+time[2])*10+time[3])>=game_time_maximum) && game_time_direction))
; 	   { if(horn_time_maximum)
	ldd  L551
	beq  L656
FRAME.796::	; 	     { horn_on
	ldab  _mode
	clra
	cpd #0
	bne  L658
	ldab  4096
	orab #128
	stab  4096
L658:
FRAME.797::	; 	       horn_time = horn_time_maximum;
	ldd  L551
	std  L549
FRAME.798::	; 		   horn_condition = 1;
	ldd #1
	std  L552
	jmp  L564
L656:
FRAME.800::	; 		 }
; 		 else game_started = 0;
	clra
	clrb
	stab  L543
	jmp  L564
L641:
FRAME.804::	;        }
;      }
; 	 else
; 	 { if(!(--horn_time))
	ldd  L549
	subd #1
	std 14,x
	std  L549
	ldd 14,x
	beq X62
	jmp  L564
X62:
FRAME.805::	; 	   { game_started = 0;
	clra
	clrb
	stab  L543
FRAME.806::	; 	     horn_off
	ldab  4096
	andb #127
	stab  4096
FRAME.807::	;  		 horn_condition = 0;
	clra
	clrb
	std  L552
	jmp  L564
L563:
FRAME.812::	; 	   }
; 	 }
;   }
; 
;   else if(flag == _NEXT_CHARACTER_)
	ldab 17,x
	clra
	cpd #0
	beq X63
	jmp  L662
X63:
FRAME.813::	;   { if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L664
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L664
	ldab #19
	stab  _mode
	jmp  L665
L664:
FRAME.814::	;     else if(mode == _set && sci_input_buffer == _game)
	ldab  _mode
	clra
	cpd #19
	bne  L666
	ldab  _sci_input_buffer
	clra
	cpd #18
	bne  L666
FRAME.815::	; 	{ mode = _game;
	ldab #18
	stab  _mode
FRAME.816::	;       hh = h = mm = m = font[0];
	ldab  _font
	stab 15,x
	ldab 15,x
	stab  L547
	ldab 15,x
	stab  L548
	ldab 15,x
	stab  L545
	ldab 15,x
	stab  L546
FRAME.817::	; 	  for(i=0;i<4;i++) buffer[i] = 0;
	clra
	clrb
	stab 16,x
L668:
	ldab 16,x
	clra
	cpd #4
	bhs  L670
	ldd #L541
	pshb
	psha
	ldab 16,x
	clra
	tsy
	addd 0,y
	puly
	xgdy
	clra
	clrb
	stab 0,y
L669:
	ldab 16,x
	incb
	stab 16,x
	bra  L668
L670:
FRAME.818::	; 	  blink_character = 3;
	ldab #3
	stab  _blink_character
FRAME.819::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
	jmp  L667
L666:
FRAME.821::	; 	}
; 	else if(mode == _set && sci_input_buffer == _1) mode = 201;
	ldab  _mode
	clra
	cpd #19
	bne  L672
	ldab  _sci_input_buffer
	clra
	cpd #1
	bne  L672
	ldab #201
	stab  _mode
	jmp  L673
L672:
FRAME.822::	; 	else if(mode == _set && sci_input_buffer == _horn)
	ldab  _mode
	clra
	cpd #19
	bne  L674
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L674
FRAME.823::	; 	{ mode = _horn;
	ldab #15
	stab  _mode
FRAME.824::	; 	  horn_buffer = horn_time_maximum;
	ldd  L551
	std  L550
FRAME.825::	; 	  horn_off
	ldab  4096
	andb #127
	stab  4096
FRAME.826::	; 	  horn_condition = 0;
	clra
	clrb
	std  L552
	jmp  L675
L674:
FRAME.828::	; 	}
; 	else if(mode == _horn && sci_input_buffer != 111)
	ldab  _mode
	clra
	cpd #15
	bne  L676
	ldab  _sci_input_buffer
	clra
	cpd #111
	beq  L676
FRAME.829::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 14,x
	cpd #1
	blt  L678
	ldd 14,x
	cpd #10
	bgt  L678
FRAME.830::	; 	            horn_time_maximum = (sci_input_buffer % 10) * 32;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	lsld
	lsld
	lsld
	lsld
	lsld
	std  L551
	tsx
	jmp  L677
L678:
FRAME.831::	; 	  else if(sci_input_buffer == _enter) mode = 0;
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L680
	clra
	clrb
	stab  _mode
	jmp  L677
L680:
FRAME.833::	; 	  else
; 	  { mode = 0;
	clra
	clrb
	stab  _mode
FRAME.834::	; 	    horn_time_maximum = horn_buffer;
	ldd  L550
	std  L551
	jmp  L677
L676:
FRAME.837::	;       }
; 	}
; 	else if(!mode && sci_input_buffer == _horn)
	ldab  _mode
	clra
	cpd #0
	bne  L682
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L682
FRAME.838::	; 	{ horn_on
	ldab  _mode
	clra
	cpd #0
	bne  L684
	ldab  4096
	orab #128
	stab  4096
L684:
FRAME.839::	; 	  horn_condition = 1;
	ldd #1
	std  L552
	jmp  L683
L682:
FRAME.841::	; 	}
; 	else if(sci_input_buffer == 111)
	ldab  _sci_input_buffer
	clra
	cpd #111
	bne  L686
FRAME.842::	; 	{ horn_off
	ldab  4096
	andb #127
	stab  4096
FRAME.843::	; 	  horn_condition = 0;
	clra
	clrb
	std  L552
	jmp  L687
L686:
FRAME.845::	; 	}
; 	else if(mode == 201)
	ldab  _mode
	clra
	cpd #201
	bne  L688
FRAME.846::	; 	{if(sci_input_buffer == _1) mode = _1;
	ldab  _sci_input_buffer
	clra
	cpd #1
	bne  L690
	ldab #1
	stab  _mode
	jmp  L689
L690:
FRAME.847::	; 	 else if(sci_input_buffer == _2) mode = _2;
	ldab  _sci_input_buffer
	clra
	cpd #2
	bne  L692
	ldab #2
	stab  _mode
	jmp  L689
L692:
FRAME.848::	; 	 else mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L689
L688:
FRAME.850::	; 	}
; 	else if(mode == _1)
	ldab  _mode
	clra
	cpd #1
	bne  L694
FRAME.851::	; 	{if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L696
FRAME.852::	; 	 { timer_restarted = 0;
	clra
	clrb
	stab  L544
FRAME.853::	; 	   time[0] = game_time_maximum / 600;
	ldd  L540
	ldx #600
	idiv
	xgdx
	stab  L538
FRAME.854::	; 	   time[1] = (game_time_maximum /60)% 10;
	ldd  L540
	ldx #60
	idiv
	xgdx
	ldx #10
	idiv
	stab  L538+1
FRAME.855::	; 	   time[2] = (game_time_maximum /10)% 6;
	ldd  L540
	ldx #10
	idiv
	xgdx
	ldx #6
	idiv
	stab  L538+2
FRAME.856::	; 	   time[3] = game_time_maximum % 10;
	ldd  L540
	ldx #10
	idiv
	stab  L538+3
FRAME.857::	; 	   game_time_direction = 0;
	clra
	clrb
	stab  L542
L696:
FRAME.859::	; 	 }
; 	 mode = 0;
	clra
	clrb
	stab  _mode
	tsx
	jmp  L695
L694:
FRAME.861::	; 	}
; 	else if(mode == _2)
	ldab  _mode
	clra
	cpd #2
	bne  L701
FRAME.862::	; 	{if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L703
FRAME.863::	; 	 { timer_restarted = 0;
	clra
	clrb
	stab  L544
FRAME.864::	; 	   time[0] = time[1] = time[2] = time[3] = 0;
	clra
	clrb
	stab  L538+3
	clra
	clrb
	stab  L538+2
	clra
	clrb
	stab  L538+1
	clra
	clrb
	stab  L538
FRAME.865::	;        game_time_direction = 1;
	ldab #1
	stab  L542
L703:
FRAME.867::	; 	 }
; 	 mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L702
L701:
FRAME.869::	; 	}
; 	else if(mode == _game)
	ldab  _mode
	clra
	cpd #18
	beq X64
	jmp  L708
X64:
FRAME.870::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	ldab  _sci_input_buffer
	clra
	std 14,x
	cpd #1
	bge X65
	jmp  L710
X65:
	ldd 14,x
	cpd #10
	ble X66
	jmp  L710
X66:
FRAME.871::	; 	  { buffer[0]=buffer[1];
	ldab  L541+1
	stab  L541
FRAME.872::	; 	    buffer[1]=buffer[2];
	ldab  L541+2
	stab  L541+1
FRAME.873::	; 		buffer[2]=buffer[3];
	ldab  L541+3
	stab  L541+2
FRAME.874::	; 	    buffer[3] = sci_input_buffer%10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L541+3
FRAME.875::	; 	    hh = font[buffer[0]];
	ldd #_font
	pshb
	psha
	ldab  L541
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L546
FRAME.876::	; 	    h  = font[buffer[1]];
	ldd #_font
	pshb
	psha
	ldab  L541+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L545
FRAME.877::	; 	    mm = font[buffer[2]];
	ldd #_font
	pshb
	psha
	ldab  L541+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L548
FRAME.878::	; 	    m  = font[buffer[3]];
	ldd #_font
	pshb
	psha
	ldab  L541+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L547
	tsx
	jmp  L711
L710:
FRAME.880::	; 	  }
; 	  else if(sci_input_buffer == _clear ||
	ldab  _sci_input_buffer
	clra
	std 12,x
	cpd #11
	beq  L726
	ldd 12,x
	cpd #12
	bne  L721
	ldab  L541
	clra
	cpd #0
	bne  L721
	ldab  L541+1
	clra
	cpd #0
	bne  L721
	ldab  L541+2
	clra
	cpd #0
	bne  L721
	ldab  L541+3
	clra
	cpd #0
	bne  L721
L726:
FRAME.882::	; 	         (sci_input_buffer == _enter && !buffer[0] && !buffer[1] && !buffer[2] && !buffer[3]))
; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.883::	; 	    mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L722
L721:
FRAME.885::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	beq X67
	jmp  L727
X67:
FRAME.886::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
FRAME.887::	; 	    game_time_maximum = ((buffer[0]*10 + buffer[1])*6+buffer[2])*10+buffer[3];
	ldab  L541+3
	clra
	pshb
	psha
	ldab  L541+2
	clra
	pshb
	psha
	ldab  L541+1
	clra
	pshb
	psha
	ldab  L541
	clra
	xgdy
	ldd #10
	jsr  __mulu
	tsy
	addd 0,y
	puly
	xgdy
	ldd #6
	jsr  __muli
	tsy
	addd 0,y
	puly
	xgdy
	ldd #10
	jsr  __muli
	tsy
	addd 0,y
	puly
	std  L540
FRAME.888::	; 		for(i=0;i<4;i++) time[i] = game_time_direction ? 0 : buffer[i];
	clra
	clrb
	tsx
	stab 16,x
L732:
	ldab 16,x
	clra
	cpd #4
	bhs  L734
	ldab  L542
	clra
	cpd #0
	beq  L737
	clra
	clrb
	std 10,x
	bra  L738
L737:
	ldd #L541
	pshb
	psha
	ldab 16,x
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 10,x
L738:
	ldd #L538
	pshb
	psha
	ldab 16,x
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 11,x
	stab 0,y
L733:
	ldab 16,x
	incb
	stab 16,x
	bra  L732
L734:
FRAME.889::	; 		mode = 0;
	clra
	clrb
	stab  _mode
FRAME.890::	; 		game_started = 1;
	ldab #1
	stab  L543
FRAME.891::	; 		timer_restarted = 0;
	clra
	clrb
	stab  L544
L727:
L722:
L711:
L708:
L702:
L695:
L689:
L687:
L683:
L677:
L675:
L673:
L667:
L665:
FRAME.895::	; 	  }
; 	}
; 
; 	if(sci_input_buffer != _horn  ||  mode)
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L741
	ldab  _mode
	clra
	cpd #0
	beq  L739
L741:
FRAME.896::	; 	{ horn_off
	ldab  4096
	andb #127
	stab  4096
FRAME.897::	; 	  horn_condition = 0;
	clra
	clrb
	std  L552
L739:
L662:
L564:
L556:
	xgdx
	addd #19
	xgdx
	txs
	rts
L537:
	.globl _process_data
;     flag -> 2,x
_process_data:
	pshb
	psha
	pshx
	tsx
FRAME.907::	; 	}
;   }
; }
; 
; 
; 
; 
; /////////root////////////
; void process_data(unsigned char flag)
; {  copreset
	ldab 3,x
	stab 2,x
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L762
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L762:
FRAME.915::	; 
;   //process sci_input_buffer and mode.
;   ///////////////////////////////////////////////////////////////////////////////////
;   ///cals////////////////////////////////////////////////////////////////////////////
;   // TO DO -> Enter procedures calls here.
; 
; 
;   home_score(flag);
	ldab 2,x
	clra
	jsr  _home_score
FRAME.916::	;   guest_score(flag);
	tsx
	ldab 2,x
	clra
	jsr  _guest_score
FRAME.917::	;   period(flag);
	tsx
	ldab 2,x
	clra
	jsr  _period
FRAME.918::	;   bonus_possession(flag);
	tsx
	ldab 2,x
	clra
	jsr  _bonus_possession
FRAME.920::	; 
;   home_fouls(flag);
	tsx
	ldab 2,x
	clra
	jsr  _home_fouls
FRAME.921::	;   guest_fouls(flag);
	tsx
	ldab 2,x
	clra
	jsr  _guest_fouls
FRAME.922::	;   player_foul(flag);
	tsx
	ldab 2,x
	clra
	jsr  _player_foul
FRAME.924::	; 
;   yards_to_go(flag);
	tsx
	ldab 2,x
	clra
	jsr  _yards_to_go
FRAME.925::	;   ball_on(flag);
	tsx
	ldab 2,x
	clra
	jsr  _ball_on
FRAME.931::	; 
; 
;   ///end/cals////////////////////////////////////////////////////////////////////////
;   ///////////////////////////////////////////////////////////////////////////////////
;   //timers.
;   if(flag == _NEXT_CHARACTER_) test_segments();
	tsx
	ldab 2,x
	clra
	cpd #0
	bne  L764
	jsr  _test_segments
L764:
FRAME.932::	;   day_time(flag);
	tsx
	ldab 2,x
	clra
	jsr  _day_time
FRAME.933::	;   game_time(flag);
	tsx
	ldab 2,x
	clra
	jsr  _game_time
FRAME.935::	; 
;   if(flag == _NEXT_CHARACTER_ && mode == _set &&
	tsx
	ldab 2,x
	clra
	cpd #0
	bne  L766
	ldab  _mode
	clra
	cpd #19
	bne  L766
	ldab  _sci_input_buffer
	clra
	std 0,x
	cpd #11
	beq  L768
	ldd 0,x
	cpd #12
	bne  L766
L768:
FRAME.937::	;   (sci_input_buffer == _clear || sci_input_buffer == _enter))
;   { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L769
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L769:
FRAME.938::	;     mode = 0;
	clra
	clrb
	stab  _mode
FRAME.939::	;     horn_off
	ldab  4096
	andb #127
	stab  4096
L766:
	pulx
	pulx
	rts
L761:
	.globl _main
;        i -> 0,x
_main:
	pshx
	tsx
	sei
FRAME.949::	;   }
; }
; 
; 
; ////////////////////////////////////////////////////////////
; 
; void main()
; { unsigned char i;                          // program data declarations.
;   asm("	sei");
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L773
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L773:
FRAME.950::	;   mode = 0;
	clra
	clrb
	stab  _mode
FRAME.951::	;   initialization();         // programm initialization.
	jsr  _initialization
FRAME.952::	;   power_on_restarted = 0xff;
	ldab #255
	stab  _power_on_restarted
 cli
FRAME.954::	; 
;   asm(" cli");
L775:
L776:
FRAME.957::	; 
;   while(1)
;   { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	clra
	clrb
	tsx
	stab 0,x
L778:
	ldab 0,x
	clra
	cpd #23
	bhi  L780
	ldd #_data
	pshb
	psha
	ldab 0,x
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_extender
	std 0,y
L779:
	ldab 0,x
	incb
	stab 0,x
	bra  L778
L780:
L782:
L783:
FRAME.958::	; 	while(no_rx_time >= 1831)
	ldd  _no_rx_time
	cpd #1831
	blo  L784
FRAME.959::	; 	{ copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L782
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
	bra  L782
L784:
FRAME.961::	; 	}
; 	process_data(_INITIALIZATION_);
	ldd #2
	jsr  _process_data
L787:
L788:
FRAME.962::	;     while(no_rx_time < 3663)
	ldd  _no_rx_time
	cpd #3663
	tsx
	blo X68
	jmp  L775
X68:
FRAME.963::	;     { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L787
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
	bra  L787
L772:
	.globl _datachange
;        i -> 0,x
_datachange:
	pshx
	tsx
FRAME.972::	;     }
;   }
; }
; 
; 
; 
; void datachange()
; { int i;
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L793
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L793:
FRAME.973::	;   proceed_dim();
	jsr  _proceed_dim
FRAME.974::	;   if(sci_input_buffer != _dim) process_data(_NEXT_CHARACTER_);
	ldab  _sci_input_buffer
	clra
	cpd #22
	tsx
	beq  L795
	clra
	clrb
	jsr  _process_data
L795:
	tsx
	pulx
	rts
L792:
	.globl _integrate
_integrate:
	pshx
	pshx
	pshx
	tsx
FRAME.979::	; }
; 
; 
; void integrate()
; { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L798
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L798:
FRAME.981::	; 
;   if( !received && sci_input_buffer != 255 && sci_input_buffer != 233 )
	ldab  _received
	clra
	cpd #0
	bne  L800
	ldab  _sci_input_buffer
	clra
	std 4,x
	cpd #255
	beq  L800
	ldd 4,x
	cpd #233
	beq  L800
FRAME.982::	;   { received = 1;
	ldab #1
	stab  _received
FRAME.983::	;     no_rx_time = 0;
	clra
	clrb
	std  _no_rx_time
FRAME.984::	;     datachange();
	jsr  _datachange
L800:
FRAME.987::	;   }
; 
;   if( received && (sci_input_buffer == 255 || sci_input_buffer == 233))
	ldab  _received
	clra
	cpd #0
	tsx
	beq  L802
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #255
	beq  L804
	ldd 2,x
	cpd #233
	bne  L802
L804:
FRAME.988::	;   { received = 0;
	clra
	clrb
	stab  _received
FRAME.989::	;     system_flag = sci_input_buffer == 255 ? system_flag | _TIMER_ON_ : system_flag & ~_TIMER_ON_;
	ldab  _sci_input_buffer
	clra
	cpd #255
	bne  L806
	ldab  _system_flag
	clra
	orab #128
	oraa #0
	std 0,x
	bra  L807
L806:
	ldab  _system_flag
	clra
	andb #127
	anda #255
	std 0,x
L807:
	ldab 1,x
	stab  _system_flag
L802:
	pulx
	pulx
	pulx
	rts
L797:
	.globl __sci
;        i -> 4,x
;     base -> 6,x
__sci:
	pshx
	pshx
	pshx
	pshx
	tsx
FRAME.1001::	; 	// for game timer condition.
;   }
; }
; 
; 
; 
; 
; 
; /////////////// communication interrupt /////////////////////
; #pragma interrupt_handler _sci
; void _sci()
; { unsigned char base = PORTA & 6;
	ldab  4096
	andb #6
	stab 6,x
FRAME.1004::	;   int i;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L811
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L811:
FRAME.1006::	; 
;   sci_input_buffer = SCSR;
	ldab  4142
	stab  _sci_input_buffer
FRAME.1007::	;   sci_input_buffer = SCDR;
	ldab  4143
	stab  _sci_input_buffer
FRAME.1008::	;   if((sci_input_counter[0] >= 7) || (sci_input_counter[1] >= 7 + base))
	ldd  _sci_input_counter
	cpd #7
	bge  L816
	ldab 6,x
	clra
	addd #7
	pshb
	psha
	ldd  _sci_input_counter+2
	tsy
	cpd 0,y
	puly
	blt  L813
L816:
FRAME.1009::	;   { integrate();
	jsr  _integrate
FRAME.1010::	;     for(i=0;i<2;i++) sci_input_counter[i] = i ? base : 0;
	clra
	clrb
	tsx
	std 4,x
L817:
	ldd 4,x
	cpd #2
	blt X69
	jmp  L814
X69:
	ldd 4,x
	std 2,x
	ldd 4,x
	beq  L822
	ldab 6,x
	clra
	std 2,x
L822:
	ldd #_sci_input_counter
	pshb
	psha
	ldd 4,x
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 2,x
	std 0,y
L818:
	ldd 4,x
	addd #1
	std 4,x
	bra  L817
L813:
FRAME.1013::	;   }
;   else
;    for(i=0;i<2;i++)
	clra
	clrb
	std 4,x
L824:
	ldd 4,x
	cpd #2
	bge  L826
FRAME.1014::	;     if(sci_input_counter[i] == sci_input_buffer) sci_input_counter[i]++;
	ldab  _sci_input_buffer
	clra
	pshb
	psha
	ldd #_sci_input_counter
	pshb
	psha
	ldd 4,x
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	tsy
	cpd 0,y
	puly
	bne  L828
	ldd #_sci_input_counter
	pshb
	psha
	ldd 4,x
	lsld
	tsy
	addd 0,y
	puly
	std 2,x
	ldy 2,x
	ldd 0,y
	addd #1
	ldy 2,x
	std 0,y
	bra  L829
L828:
FRAME.1015::	;     else sci_input_counter[i] = i ? base : 0;
	ldd 4,x
	std 0,x
	ldd 4,x
	beq  L831
	ldab 6,x
	clra
	std 0,x
L831:
	ldd #_sci_input_counter
	pshb
	psha
	ldd 4,x
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,x
	std 0,y
L829:
L825:
	ldd 4,x
	addd #1
	std 4,x
	jmp  L824
L826:
L814:
	pulx
	pulx
	pulx
	pulx
	rti
L810:
	.globl __rti
; blink_data -> 0,x
; blink_buffer -> 1,x
;        i -> 3,x
__rti:
	des
	pshx
	pshx
	tsx
FRAME.1024::	; }
; 
; ////////// timer interrupt ////////////////////
; #pragma interrupt_handler _rti
; void _rti()
; { unsigned char *blink_buffer;
;   unsigned char blink_data,i;
; 
;   TFLG2  = 0x40;               // reset RTI interrupt flag RTIF.
	ldab #64
	stab  4133
FRAME.1026::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L835
	ldd #_dynamic_dim
	pshb
	psha
	ldd  _dim
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  4143
L835:
FRAME.1028::	; 
;   if(no_rx_time <= 3663) no_rx_time++;   //120 seconds.
	ldd  _no_rx_time
	cpd #3663
	bhi  L837
	ldd  _no_rx_time
	addd #1
	std  _no_rx_time
L837:
FRAME.1030::	; 
;   process_data(_NEXT_TIMER_TICK_);
	ldd #1
	jsr  _process_data
FRAME.1033::	; 
; 
;   if(mode == 100 && !(no_rx_time & 0x10) && (blink_character < 4))
	ldab  _mode
	clra
	cpd #100
	tsx
	bne  L839
	ldd  _no_rx_time
	bitb #16
	bne  L839
	ldab  _blink_character
	clra
	cpd #4
	bhs  L839
FRAME.1034::	;   { blink_buffer = day_time_data[blink_character];
	ldd #_day_time_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	std 1,x
FRAME.1035::	;     day_time_data[blink_character] = (unsigned char *)extender;
	ldd #_day_time_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_extender
	std 0,y
FRAME.1036::	; 	putcharacters();
	jsr  _putcharacters
FRAME.1037::	; 	day_time_data[blink_character] = blink_buffer;
	ldd #_day_time_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	tsx
	ldd 1,x
	std 0,y
	jmp  L840
L839:
FRAME.1039::	;   }
;   else if(blink_character && !blink_segments && !(no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	beq  L841
	ldab  _blink_segments
	clra
	cpd #0
	bne  L841
	ldd  _no_rx_time
	bitb #16
	bne  L841
FRAME.1040::	;   { blink_buffer = data[blink_character];
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	std 1,x
FRAME.1041::	;     data[blink_character] = (unsigned char *)extender;
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_extender
	std 0,y
FRAME.1042::	; 	putcharacters();
	jsr  _putcharacters
FRAME.1043::	; 	data[blink_character] = blink_buffer;
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	tsx
	ldd 1,x
	std 0,y
	jmp  L842
L841:
FRAME.1045::	;   }
;   else if(blink_character && !blink_segments && (no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	bne X70
	jmp  L843
X70:
	ldab  _blink_segments
	clra
	cpd #0
	beq X71
	jmp  L843
X71:
	ldd  _no_rx_time
	bitb #16
	bne X72
	jmp  L843
X72:
FRAME.1046::	;   { blink_buffer = data[blink_character];
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	std 1,x
FRAME.1047::	;     if((*data[blink_character]) == 0) data[blink_character] = (unsigned char *)(&font[0]);
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldy 0,y
	ldab 0,y
	clra
	cpd #0
	bne  L845
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_font
	std 0,y
	bra  L846
L845:
FRAME.1049::	; 	else
; 	 if((*data[blink_character]) == 10) data[blink_character] = (unsigned char *)(&font[10]);
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldy 0,y
	ldab 0,y
	clra
	cpd #10
	bne  L847
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd #_font+10
	std 0,y
L847:
L846:
FRAME.1050::	; 	putcharacters();
	jsr  _putcharacters
FRAME.1051::	; 	data[blink_character] = blink_buffer;
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	tsx
	ldd 1,x
	std 0,y
	jmp  L844
L843:
FRAME.1053::	;   }
;   else if(blink_character && blink_segments && !(no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	bne X73
	jmp  L850
X73:
	ldab  _blink_segments
	clra
	cpd #0
	bne X74
	jmp  L850
X74:
	ldd  _no_rx_time
	bitb #16
	beq X75
	jmp  L850
X75:
FRAME.1054::	;   { blink_buffer = data[blink_character];       //keep address.
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	ldd 0,y
	std 1,x
FRAME.1055::	;     blink_data = *blink_buffer;                 //init value.
	ldy 1,x
	ldab 0,y
	stab 0,x
FRAME.1056::	; 	data[blink_character] = &blink_data;        //point to buffer.
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	xgdx
	std 0,y
FRAME.1057::	;     for( i=1 ; i<=8; i<<=1 )                    //correct data.
	ldab #1
	tsx
	stab 3,x
L852:
	ldab 3,x
	clra
	cpd #8
	bhi  L854
FRAME.1058::	;      if(blink_segments & i) blink_data &= ~i;   //make dark segments.
	ldab 3,x
	clra
	pshb
	psha
	ldab  _blink_segments
	clra
	tsy
	andb 1,y
	anda 0,y
	puly
	cpd #0
	beq  L856
	ldab 3,x
	comb
	pshb
	ldab 0,x
	tsy
	andb 0,y
	ins
	stab 0,x
L856:
L853:
	ldab 3,x
	lslb
	stab 3,x
	bra  L852
L854:
FRAME.1059::	; 	putcharacters();
	jsr  _putcharacters
FRAME.1060::	; 	data[blink_character] = blink_buffer;
	ldd #_data
	pshb
	psha
	ldab  _blink_character
	clra
	lsld
	tsy
	addd 0,y
	puly
	xgdy
	tsx
	ldd 1,x
	std 0,y
	bra  L851
L850:
FRAME.1062::	;   }
;   else putcharacters();
	jsr  _putcharacters
L851:
L844:
L842:
L840:
	tsx
	ins
	pulx
	pulx
	rti
L834:
	.area interrupt_vectors
	.area interrupt_vectors
_interrupt_vectors:
	.word __sci
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __rti
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.word __start
	.area bss
	.globl _buffer
_buffer:
	.blkb 4
	.globl _no_rx_time
_no_rx_time:
	.blkb 2
	.globl _blink_segments
_blink_segments:
	.blkb 1
	.globl _blink_character
_blink_character:
	.blkb 1
	.globl _day_time_data
_day_time_data:
	.blkb 8
	.globl _data
_data:
	.blkb 48
	.globl _dim
_dim:
	.blkb 2
	.globl _power_on_restarted
_power_on_restarted:
	.blkb 1
	.globl _received
_received:
	.blkb 1
	.globl _sci_input_counter
_sci_input_counter:
	.blkb 4
	.globl _sci_input_buffer
_sci_input_buffer:
	.blkb 1
	.globl _mode
_mode:
	.blkb 1
	.globl _system_flag
_system_flag:
	.blkb 1
	.area text
L632:
	.word 0x4120,0x0
L598:
	.word 0xbf80,0x0
L576:
	.word 0x3f80,0x0
L460:
	.word 0x4270,0x0
L459:
	.word 0x3d06,0x37bd
L451:
	.word 0x0,0x0

	.area text
	.globl _dynamic_dim
_dynamic_dim:
	.byte 'b,'D
	.byte -86,-1
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
N.79::	; //==10=23=1996======================
; //  baseball - old board - no timer.
; //==================================
; 
; 
; /////////////////////////////////////////////////////////////////////
; ////board/distribution///////////////////////////////////////////////
; // TO DO -> correct difinitions.
; 
; #define _FIRST_DIGIT_NUMBER_    1  // top board start digit number.
; #define _MIDDLE_DIGIT_NUMBER_   1  // bottom board start digit number.
; #define _LAST_DIGIT_NUMBER_    23
; 
; ////end/board/distribution///////////////////////////////////////////
; /////////////////////////////////////////////////////////////////////
; const unsigned char dynamic_dim[]=
; { 'b' , //===============================
;   0x44, //adjustable - low brightness.
;   0xaa, //adjustable - middle brightness.
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
N.80::	;   sci_input_counter[0] = 0;
	clra
	clrb
	std  _sci_input_counter
N.81::	;   sci_input_counter[1] = PORTA & 6;
	ldab  4096
	clra
	andb #6
	clra
	std  _sci_input_counter+2
N.83::	; 
;   received = 0;
	clra
	clrb
	stab  _received
N.85::	; 
;   no_rx_time = 0;
	clra
	clrb
	std  _no_rx_time
N.86::	;   dim = initialdim;
	ldd #1
	std  _dim
N.88::	; 
;   system_flag = 0;
	clra
	clrb
	stab  _system_flag
N.90::	; 
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
N.92::	; 
;   PACTL |= 0x88; // DDRA7 = 1   ==>  PA7, PA3 are output.
	ldab  4134
	orab #136
	stab  4134
N.93::	;   PORTA |= 0x07; // horn off;  PA6,5,4,3 = 0.
	ldab  4096
	orab #7
	stab  4096
N.98::	; 
; 
;   // SPI initialization.
; 
;   PORTD = 0x02;  // ss* - lo,  sck - lo,  mosi - lo.
	ldab #2
	stab  4104
N.99::	;   DDRD  = 0x3e;  // PD5,4,3 - outs.
	ldab #62
	stab  4105
N.100::	;   SPCR  = 0x54;  // spi - master.
	ldab #84
	stab  4136
N.103::	; 
;   // init sci for receive.
;   DDRD &= ~0x01;  // enable receive line.
	ldab  4105
	andb #254
	stab  4105
N.104::	;   BAUD  =  0x33;  // baud rate is equal to 1200 bits per second.
	ldab #51
	stab  4139
N.105::	;   SCCR1 =  0x00;
	clra
	clrb
	stab  4140
N.106::	;   SCCR2 =  0x24;  // RIE,RE bits on.
	ldab #36
	stab  4141
N.111::	; 
; 
;   // timer interrupt initialization.
; 
;   PACTL |= 0x03;               // RTR1=RTR0=1 --> RTI each E/2**16 =   0.032768 sec.
	ldab  4134
	orab #3
	stab  4134
N.112::	;   TMSK2 |= 0x43;               // RTII=1 --> RTI enable. ; clc = e/16
	ldab  4132
	orab #67
	stab  4132
N.115::	; 
;   // for display dynamic dimming mechanizm.
;   SCCR2 |= 0x08;     // sci transmit enable
	ldab  4141
	orab #8
	stab  4141
N.118::	; 
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
N.127::	; }
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
N.128::	;   begining_digit = PORTE & 8 ? _FIRST_DIGIT_NUMBER_ : _MIDDLE_DIGIT_NUMBER_;
	ldab  4106
	clra
	bitb #8
	beq  L12
	ldd #1
	std 6,x
	bra  L13
L12:
	ldd #1
	std 6,x
L13:
	ldd 6,x
	std 11,x
N.129::	;   priznak = 0;
	clra
	clrb
	stab 10,x
N.131::	; 
;   for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
	ldd #23
	std 8,x
L14:
	ldd 8,x
	cpd 11,x
	bge X0
	jmp  L16
X0:
N.132::	;   { if(mode == _day || mode == 100)
	ldab  _mode
	clra
	std 4,x
	cpd #27
	beq  L20
	ldd 4,x
	cpd #100
	bne  L18
L20:
N.133::	;     { if(i<4) buffer = dim ? *(day_time_data[i]) : 0;
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
N.134::	; 	  else    buffer = 0;
	clra
	clrb
	stab 13,x
	bra  L19
L18:
N.136::	; 	}
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
N.137::	;     if(intermediate[i] != buffer)
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
N.138::	; 	{ intermediate[i] = buffer;
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
N.139::	; 	  priznak = 1;
	ldab #1
	stab 10,x
L29:
L15:
	ldd 8,x
	subd #1
	std 8,x
	jmp  L14
L16:
N.143::	; 	}
;   }
; 
;   if(priznak)
	ldab 10,x
	clra
	cpd #0
	bne X1
	jmp  L31
X1:
N.144::	;   { for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
	ldd #23
	std 8,x
L33:
	ldd 8,x
	cpd 11,x
	blt  L35
N.145::	;     { SPDR = intermediate[i];
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
N.146::	;       while( !(SPSR & 0x80) )
	ldab  4137
	clra
	bitb #128
	bne  L39
N.147::	; 	  { copreset
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
N.150::	; 	  }
;     }
; 	PORTD &= ~0x20;      // SS* - low.
	ldab  4104
	andb #223
	stab  4104
N.151::	;     PORTD |=  0x20;      // SS* - high.
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
N.158::	;   }
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
N.159::	;   TOC1 = TCNT + 125*milliseconds ;
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
N.160::	;   TFLG1 = 0x80;
	ldab #128
	stab  4131
L48:
L49:
N.161::	;   while( !( TFLG1 & 0x80 ) )
	ldab  4131
	clra
	bitb #128
	tsx
	bne  L50
N.162::	;   { copreset
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
N.164::	;   }
;   TFLG1 = 0x80;
	ldab #128
	stab  4131
	pulx
	rts
L45:
	.globl _proceed_dim
_proceed_dim:
N.168::	; }
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
N.169::	;   if( sci_input_buffer == _dim)
	ldab  _sci_input_buffer
	clra
	cpd #22
	bne  L56
N.170::	;   { dim++;
	ldd  _dim
	addd #1
	std  _dim
N.171::	;     dim %= 4;
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
N.187::	;   }
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
N.189::	; 
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
N.191::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L65
N.192::	;   { score = 0;
	clra
	clrb
	stab  L59
N.193::	;     score_10 = 0;
	clra
	clrb
	stab  L60
N.194::	;     score_1 = font[0];
	ldab  _font
	stab  L61
N.195::	;     data[5] = &score_10;
	ldd #L60
	std  _data+10
N.196::	; 	data[6] = &score_1;
	ldd #L61
	std  _data+12
	jmp  L66
L65:
N.198::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X2
	jmp  L69
X2:
N.199::	;   { if(!mode && sci_input_buffer == _home)
	ldab  _mode
	clra
	cpd #0
	bne  L71
	ldab  _sci_input_buffer
	clra
	cpd #13
	bne  L71
N.200::	;     { score = (score + 1 ) % 200;
	ldy #200
	ldab  L59
	clra
	addd #1
	jsr  __modi
	stab  L59
N.201::	;       score_10 = score/10 ? font[score / 10] : 0;
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
N.202::	; 	  score_1 = font[score % 20];
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
N.204::	; 	}
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
N.205::	; 	else if(mode == _set && sci_input_buffer == _home)
	ldab  _mode
	clra
	cpd #19
	bne  L78
	ldab  _sci_input_buffer
	clra
	cpd #13
	bne  L78
N.206::	; 	{ mode = _home;
	ldab #13
	stab  _mode
N.207::	; 	  blink_character = 6;
	ldab #6
	stab  _blink_character
N.208::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
N.209::	; 	  buffer = 0;
	clra
	clrb
	stab  L62
N.210::	;       score_10 = 0;
	clra
	clrb
	stab  L60
N.211::	; 	  score_1 = font[0];
	ldab  _font
	stab  L61
	jmp  L79
L78:
N.213::	; 	}
; 	else if(mode == _home)
	ldab  _mode
	clra
	cpd #13
	beq X3
	jmp  L80
X3:
N.214::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L82
N.215::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.216::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.217::	;         score_10 = score/10 ? font[score / 10] : 0;
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
N.218::	;         score_1 = font[score % 20];
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
N.220::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L87
N.221::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.222::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.223::	; 		score = buffer;
	ldab  L62
	stab  L59
N.224::	;         score_10 = score/10 ? font[score / 10] : 0;
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
N.225::	;         score_1 = font[score % 20];
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
N.227::	; 	  }
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
N.228::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
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
N.229::	; 	    buffer += sci_input_buffer % 10;
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
N.230::	; 	    score_10 = font[buffer / 10];
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
N.231::	; 		score_1 = font[buffer % 10];
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
N.239::	; 	  }
; 	}
;   }
; }
; 
; 
; void guest_score(unsigned char flag)
; { static unsigned char score, score_10, score_1, buffer;
	ldab 5,x
	stab 4,x
N.241::	; 
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
N.243::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L108
N.244::	;   { score = 0;
	clra
	clrb
	stab  L102
N.245::	;     score_10 = 0;
	clra
	clrb
	stab  L103
N.246::	;     score_1 = font[0];
	ldab  _font
	stab  L104
N.247::	;     data[7] = &score_10;
	ldd #L103
	std  _data+14
N.248::	; 	data[8] = &score_1;
	ldd #L104
	std  _data+16
	jmp  L109
L108:
N.250::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X6
	jmp  L112
X6:
N.251::	;   { if(!mode && sci_input_buffer == _guest)
	ldab  _mode
	clra
	cpd #0
	bne  L114
	ldab  _sci_input_buffer
	clra
	cpd #16
	bne  L114
N.252::	;     { score = (score + 1) % 200;
	ldy #200
	ldab  L102
	clra
	addd #1
	jsr  __modi
	stab  L102
N.253::	;       score_10 = score/10 ? font[score / 10] : 0;
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
N.254::	; 	  score_1 = font[score % 20];
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
N.256::	; 	}
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
N.257::	; 	else if(mode == _set && sci_input_buffer == _guest)
	ldab  _mode
	clra
	cpd #19
	bne  L121
	ldab  _sci_input_buffer
	clra
	cpd #16
	bne  L121
N.258::	; 	{ mode = _guest;
	ldab #16
	stab  _mode
N.259::	; 	  blink_character = 8;
	ldab #8
	stab  _blink_character
N.260::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
N.261::	; 	  buffer = 0;
	clra
	clrb
	stab  L105
N.262::	;       score_10 = 0;
	clra
	clrb
	stab  L103
N.263::	; 	  score_1 = font[0];
	ldab  _font
	stab  L104
	jmp  L122
L121:
N.265::	; 	}
; 	else if(mode == _guest)
	ldab  _mode
	clra
	cpd #16
	beq X7
	jmp  L123
X7:
N.266::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L125
N.267::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.268::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.269::	;         score_10 = score/10 ? font[score / 10] : 0;
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
N.270::	;         score_1 = font[score % 20];
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
N.272::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L130
N.273::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.274::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.275::	; 		score = buffer;
	ldab  L105
	stab  L102
N.276::	;         score_10 = score/10 ? font[score / 10] : 0;
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
N.277::	;         score_1 = font[score % 20];
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
N.279::	; 	  }
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
N.280::	; 	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
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
N.281::	; 	    buffer += sci_input_buffer % 10;
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
N.282::	; 	    score_10 = font[buffer / 10];
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
N.283::	; 		score_1 = font[buffer % 10];
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
N.290::	; 	  }
; 	}
;   }
; }
; 
; void period(unsigned char flag)
; { static unsigned char score, score_1, buffer;
	ldab 5,x
	stab 4,x
N.292::	; 
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
N.294::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L150
N.295::	;   { score = 0;
	clra
	clrb
	stab  L145
N.296::	;     score_1 = 0;
	clra
	clrb
	stab  L146
N.297::	;     data[1] = &score_1;
	ldd #L146
	std  _data+2
	jmp  L151
L150:
N.299::	;   }
;   else if(flag == _NEXT_CHARACTER_)
	ldab 4,x
	clra
	cpd #0
	beq X10
	jmp  L153
X10:
N.300::	;   { if(!mode && sci_input_buffer == _period)
	ldab  _mode
	clra
	cpd #0
	bne  L155
	ldab  _sci_input_buffer
	clra
	cpd #23
	bne  L155
N.301::	;     { score = (score + 1) % 20;
	ldy #20
	ldab  L145
	clra
	addd #1
	jsr  __modi
	stab  L145
N.302::	;       score_1 = score ? font[score] : 0;
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
N.304::	; 	}
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
N.305::	; 	else if(mode == _set && sci_input_buffer == _period)
	ldab  _mode
	clra
	cpd #19
	bne  L162
	ldab  _sci_input_buffer
	clra
	cpd #23
	bne  L162
N.306::	; 	{ mode = _period;
	ldab #23
	stab  _mode
N.307::	; 	  blink_character = 1;
	ldab #1
	stab  _blink_character
N.308::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
N.309::	; 	  buffer = 0;
	clra
	clrb
	stab  L147
N.310::	;       score_1 = font[0];
	ldab  _font
	stab  L146
	jmp  L163
L162:
N.312::	; 	}
; 	else if(mode == _period)
	ldab  _mode
	clra
	cpd #23
	beq X11
	jmp  L164
X11:
N.313::	; 	{ if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L166
N.314::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.315::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.316::	;         score_1 = score ? font[score] : 0;
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
N.318::	;       }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L171
N.319::	; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.320::	; 	    blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.321::	; 		score = buffer;
	ldab  L147
	stab  L145
N.322::	;         score_1 = score ? font[score] : 0;
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
N.324::	; 	  }
; 	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #1
	blt  L176
	ldd 2,x
	cpd #10
	bgt  L176
N.325::	; 	  { buffer = buffer%10 ? 10+sci_input_buffer%10 : sci_input_buffer%10;
	ldab  L147
	clra
	ldx #10
	idiv
	cpd #0
	tsx
	beq  L179
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	addd #10
	tsx
	std 0,x
	bra  L180
L179:
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	tsx
	std 0,x
L180:
	ldab 1,x
	stab  L147
N.326::	; 	    score_1 = font[buffer];
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
L186:
	.blkb 1
L187:
	.blkb 1
L188:
	.blkb 1
L189:
	.blkb 1
L190:
	.blkb 1
L191:
	.blkb 1
L192:
	.blkb 1
L193:
	.blkb 1
L194:
	.blkb 1
L195:
	.blkb 1
	.area text
	.globl _bonus_possession
;     flag -> 4,x
_bonus_possession:
	pshb
	psha
	pshx
	pshx
	tsx
N.333::	; 	  }
; 	}
;   }
; }
; 
; void bonus_possession(unsigned char flag) // ball_strike_out in baseball.
; { static unsigned char score, ball, strike, out, hit,
	ldab 5,x
	stab 4,x
N.336::	;                        ball_1, strike_1, out_1, s_o_b, hit_1;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L196
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
L196:
N.338::	; 
;   if(flag == _INITIALIZATION_)
	ldab 4,x
	clra
	cpd #2
	bne  L198
N.339::	;   { ball = strike = out = score = hit = 0;
	clra
	clrb
	stab  L190
	clra
	clrb
	stab  L186
	clra
	clrb
	stab  L189
	clra
	clrb
	stab  L188
	clra
	clrb
	stab  L187
N.340::	;     ball_1 = strike_1 = out_1 = s_o_b = hit_1 = 0;
	clra
	clrb
	stab  L195
	clra
	clrb
	stab  L194
	clra
	clrb
	stab  L193
	clra
	clrb
	stab  L192
	clra
	clrb
	stab  L191
N.342::	; 
; 	data[3] = &ball_1;
	ldd #L191
	std  _data+6
N.343::	; 	data[4] = &strike_1;
	ldd #L192
	std  _data+8
N.344::	; 	data[2] = &out_1;
	ldd #L193
	std  _data+4
N.345::	; 	data[9] = &hit_1;
	ldd #L195
	std  _data+18
N.346::	; 	data[10] = &s_o_b;
	ldd #L194
	std  _data+20
	jmp  L199
L198:
N.348::	;   }
;   else if(flag == _NEXT_CHARACTER_ && !mode)
	ldab 4,x
	clra
	cpd #0
	beq X12
	jmp  L205
X12:
	ldab  _mode
	clra
	cpd #0
	beq X13
	jmp  L205
X13:
N.349::	;   { if(sci_input_buffer == _player)
	ldab  _sci_input_buffer
	clra
	cpd #25
	beq X14
	jmp  L207
X14:
N.350::	;     { ball = (ball + 1) % 4;
	ldy #4
	ldab  L187
	clra
	addd #1
	jsr  __modi
	stab  L187
N.351::	; 	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	ldd #_extender
	pshb
	psha
	ldab  L187
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L189
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L188
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	stab  L194
N.352::	; 	  ball_1 = ball ? font[ball] : 0;
	ldab  L187
	clra
	tsx
	std 0,x
	std 2,x
	ldd 0,x
	beq  L210
	ldd #_font
	pshb
	psha
	ldab  L187
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 2,x
L210:
	ldab 3,x
	stab  L191
	jmp  L208
L207:
N.354::	; 	}
;     else if(sci_input_buffer == _shot)
	ldab  _sci_input_buffer
	clra
	cpd #26
	beq X15
	jmp  L212
X15:
N.355::	; 	{ strike = (strike + 1) % 3;
	ldy #3
	ldab  L188
	clra
	addd #1
	jsr  __modi
	stab  L188
N.356::	; 	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	ldd #_extender
	pshb
	psha
	ldab  L187
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L189
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L188
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	stab  L194
N.357::	; 	  strike_1 = strike ? (strike_1 & 0x80) | font[strike] : strike_1 & 0x80;
	ldab  L188
	clra
	cpd #0
	tsx
	beq  L215
	ldd #_font
	pshb
	psha
	ldab  L188
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	pshb
	psha
	ldab  L192
	clra
	andb #128
	clra
	tsy
	orab 1,y
	oraa 0,y
	puly
	std 2,x
	bra  L216
L215:
	ldab  L192
	clra
	andb #128
	clra
	std 2,x
L216:
	ldab 3,x
	stab  L192
	jmp  L213
L212:
N.359::	; 	}
; 	else if(sci_input_buffer == _day)
	ldab  _sci_input_buffer
	clra
	cpd #27
	beq X16
	jmp  L217
X16:
N.360::	; 	{ out = (out + 1) % 3;
	ldy #3
	ldab  L189
	clra
	addd #1
	jsr  __modi
	stab  L189
N.361::	; 	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	ldd #_extender
	pshb
	psha
	ldab  L187
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L189
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	lslb
	lslb
	pshb
	ldd #_extender
	pshb
	psha
	ldab  L188
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	tsy
	orab 0,y
	ins
	stab  L194
N.362::	; 	  out_1 = out ? (out_1 & 0x80) | font[out] : out_1 & 0x80;
	ldab  L189
	clra
	cpd #0
	tsx
	beq  L220
	ldd #_font
	pshb
	psha
	ldab  L189
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	pshb
	psha
	ldab  L193
	clra
	andb #128
	clra
	tsy
	orab 1,y
	oraa 0,y
	puly
	std 2,x
	bra  L221
L220:
	ldab  L193
	clra
	andb #128
	clra
	std 2,x
L221:
	ldab 3,x
	stab  L193
	bra  L218
L217:
N.364::	; 	}
; 	else if(sci_input_buffer == _empty)
	ldab  _sci_input_buffer
	clra
	cpd #28
	bne  L222
N.365::	; 	{ hit = (hit + 1) % 3;
	ldy #3
	ldab  L190
	clra
	addd #1
	jsr  __modi
	stab  L190
N.366::	; 	  hit_1 = extender[hit];
	ldd #_extender
	pshb
	psha
	ldab  L190
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L195
L222:
L218:
L213:
L208:
L205:
L199:
	tsx
	pulx
	pulx
	pulx
	rts
L185:
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
N.379::	; 	}
;   }
; }
; 
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
	beq  L226
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
L226:
N.381::	; 
;   if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L228
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L228
	ldab #19
	stab  _mode
	jmp  L229
L228:
N.382::	;   else if(mode == _set && sci_input_buffer == _8) mode = _8;
	ldab  _mode
	clra
	cpd #19
	bne  L230
	ldab  _sci_input_buffer
	clra
	cpd #8
	bne  L230
	ldab #8
	stab  _mode
	jmp  L231
L230:
N.383::	;   else if(mode == _8 && sci_input_buffer == _enter)
	ldab  _mode
	clra
	cpd #8
	beq X17
	jmp  L232
X17:
	ldab  _sci_input_buffer
	clra
	cpd #12
	beq X18
	jmp  L232
X18:
N.384::	;   { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data_buffer[i] = data[i];
	clra
	clrb
	stab 53,x
L234:
	ldab 53,x
	clra
	cpd #23
	bhi  L236
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
L235:
	ldab 53,x
	incb
	stab 53,x
	bra  L234
L236:
N.385::	;     for(j = 0; j < 7; j++)
	clra
	clrb
	stab 52,x
L238:
	ldab 52,x
	clra
	cpd #7
	blo X19
	jmp  L240
X19:
N.386::	;     { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)(extender+8);
	clra
	clrb
	stab 53,x
L242:
	ldab 53,x
	clra
	cpd #23
	bhi  L244
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
L243:
	ldab 53,x
	incb
	stab 53,x
	bra  L242
L244:
N.387::	;       putcharacters();
	jsr  _putcharacters
N.388::	; 	  for(i=0;i<3;i++) delay(500);
	clra
	clrb
	tsx
	stab 53,x
L247:
	ldab 53,x
	clra
	cpd #3
	bhs  L249
	ldd #500
	jsr  _delay
L248:
	tsx
	ldab 53,x
	incb
	stab 53,x
	bra  L247
L249:
N.389::	;       for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	clra
	clrb
	stab 53,x
L251:
	ldab 53,x
	clra
	cpd #23
	bhi  L253
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
L252:
	ldab 53,x
	incb
	stab 53,x
	bra  L251
L253:
N.390::	; 	  putcharacters();
	jsr  _putcharacters
N.391::	; 	  for(i=0;i<3;i++) delay(500);
	clra
	clrb
	tsx
	stab 53,x
L255:
	ldab 53,x
	clra
	cpd #3
	bhs  L257
	ldd #500
	jsr  _delay
L256:
	tsx
	ldab 53,x
	incb
	stab 53,x
	bra  L255
L257:
L239:
	ldab 52,x
	incb
	stab 52,x
	jmp  L238
L240:
N.393::	;     }
;     for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = data_buffer[i];
	clra
	clrb
	stab 53,x
L259:
	ldab 53,x
	clra
	cpd #23
	bhi  L261
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
L260:
	ldab 53,x
	incb
	stab 53,x
	bra  L259
L261:
N.394::	; 	mode = 0;
	clra
	clrb
	stab  _mode
L232:
L231:
L229:
	xgdx
	addd #55
	xgdx
	txs
	rts
L225:
	.area bss
L266:
	.blkb 4
L267:
	.blkb 4
L268:
	.blkb 4
L269:
	.blkb 1
L270:
	.blkb 1
L271:
	.blkb 1
L272:
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
N.401::	;   }
; 
; }
; 
; 
; void day_time(unsigned char flag)
; { static unsigned char time[4];
	ldab 17,x
	stab 16,x
N.408::	;   static float counter;
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
	beq  L273
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
L273:
N.410::	; 
;   if(flag == _INITIALIZATION_)
	ldab 16,x
	clra
	cpd #2
	bne  L275
N.411::	;   { if(power_on_restarted)
	ldab  _power_on_restarted
	clra
	cpd #0
	beq  L277
N.412::	;     { time[0] = 0;
	clra
	clrb
	stab  L266
N.413::	;       time[1] = 1;
	ldab #1
	stab  L266+1
N.414::	; 	  time[2] = 0;
	clra
	clrb
	stab  L266+2
N.415::	; 	  time[3] = 0;
	clra
	clrb
	stab  L266+3
N.416::	; 	  counter = 0.0;
	ldy #L282
	ldd #L267
	xgdx
	jsr  __copy_float
N.417::	; 	  power_on_restarted = 0;
	clra
	clrb
	stab  _power_on_restarted
L277:
N.419::	; 	}
;     day_time_data[0] = &hh;
	ldd #L270
	std  _day_time_data
N.420::	; 	day_time_data[1] = &h;
	ldd #L269
	std  _day_time_data+2
N.421::	; 	day_time_data[2] = &mm;
	ldd #L272
	std  _day_time_data+4
N.422::	; 	day_time_data[3] = &m;
	ldd #L271
	std  _day_time_data+6
	tsx
	jmp  L276
L275:
N.425::	;   }
; 
;   else if(flag == _NEXT_TIMER_TICK_)
	ldab 16,x
	clra
	cpd #1
	beq X20
	jmp  L286
X20:
N.426::	;   { if((counter+=0.032768) >= 60.0)
	ldd #L290
	pshb
	psha
	ldd #L267
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
	ldd #L267
	xgdx
	jsr  __copy_float
	ldd #L291
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
	bge X21
	jmp  L288
X21:
N.427::	;     { counter -= 60.0;
	ldd #L291
	pshb
	psha
	ldd #L267
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
	ldd #L267
	xgdx
	jsr  __copy_float
N.428::	; 	  if((++time[3])>=10)
	ldab  L266+3
	incb
	tsx
	stab 2,x
	ldab 2,x
	stab  L266+3
	ldab 2,x
	clra
	cpd #10
	bhs X22
	jmp  L292
X22:
N.429::	; 	  { time[3] = 0;
	clra
	clrb
	stab  L266+3
N.430::	; 	    if((++time[2])>=6)
	ldab  L266+2
	incb
	stab 1,x
	ldab 1,x
	stab  L266+2
	ldab 1,x
	clra
	cpd #6
	blo  L296
N.431::	; 		{ time[2] = 0;
	clra
	clrb
	stab  L266+2
N.432::	; 		  time[1]++;
	ldab  L266+1
	incb
	stab  L266+1
N.433::	; 		  if((time[0] && time[1]>=3) || (!time[0] && time[1]>=10))
	ldab  L266
	clra
	cpd #0
	beq  L306
	ldab  L266+1
	clra
	cpd #3
	bhs  L305
L306:
	ldab  L266
	clra
	cpd #0
	bne  L301
	ldab  L266+1
	clra
	cpd #10
	blo  L301
L305:
N.434::	; 		  { time[1] = 0;
	clra
	clrb
	stab  L266+1
N.435::	; 		    if((++time[0])>=2)
	ldab  L266
	incb
	stab 0,x
	ldab 0,x
	stab  L266
	ldab 0,x
	clra
	cpd #2
	blo  L308
N.436::	; 			{ time[0] = 0;
	clra
	clrb
	stab  L266
N.437::	; 			  time[1] = 1;
	ldab #1
	stab  L266+1
L308:
L301:
L296:
L292:
L288:
N.444::	; 			}
; 		  }
; 		}
; 	  }
;     }
; 
; 	if(mode == _day)
	ldab  _mode
	clra
	cpd #27
	beq X23
	jmp  L287
X23:
N.445::	; 	{ hh = time[0] ? font[1] : 0;
	ldab  L266
	clra
	std 3,x
	std 5,x
	ldd 3,x
	beq  L315
	ldab  _font+1
	clra
	std 5,x
L315:
	ldab 6,x
	stab  L270
N.446::	; 	  h  = font[time[1]];
	ldd #_font
	pshb
	psha
	ldab  L266+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L269
N.447::	; 	  mm = font[time[2]];
	ldd #_font
	pshb
	psha
	ldab  L266+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L272
N.448::	; 	  m  = font[time[3]];
	ldd #_font
	pshb
	psha
	ldab  L266+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L271
	jmp  L287
L286:
N.452::	;     }
;   }
; 
;   else if(flag == _NEXT_CHARACTER_)
	ldab 16,x
	clra
	cpd #0
	beq X24
	jmp  L320
X24:
N.453::	;   { if(!mode && sci_input_buffer == _day) mode = _day;
	ldab  _mode
	clra
	cpd #0
	bne  L322
	ldab  _sci_input_buffer
	clra
	cpd #27
	bne  L322
	ldab #27
	stab  _mode
	jmp  L323
L322:
N.454::	;     else if((!mode || mode==_day) && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	std 13,x
	beq  L326
	ldd 13,x
	cpd #27
	bne  L324
L326:
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L324
	ldab #19
	stab  _mode
	jmp  L325
L324:
N.455::	;     else if(mode == _set && sci_input_buffer == _day)
	ldab  _mode
	clra
	cpd #19
	bne  L327
	ldab  _sci_input_buffer
	clra
	cpd #27
	bne  L327
N.456::	; 	{ mode = 100;
	ldab #100
	stab  _mode
N.457::	; 	  hh = h = mm = m = font[0];
	ldab  _font
	stab 12,x
	ldab 12,x
	stab  L271
	ldab 12,x
	stab  L272
	ldab 12,x
	stab  L269
	ldab 12,x
	stab  L270
N.458::	; 	  for(i=0;i<4;i++) buffer[i] = 0;
	clra
	clrb
	stab 15,x
L329:
	ldab 15,x
	clra
	cpd #4
	bhs  L331
	ldd #L268
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
L330:
	ldab 15,x
	incb
	stab 15,x
	bra  L329
L331:
N.459::	; 	  blink_character = 3;
	ldab #3
	stab  _blink_character
N.460::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
	jmp  L328
L327:
N.462::	; 	}
; 	else if(mode == 100)
	ldab  _mode
	clra
	cpd #100
	beq X25
	jmp  L333
X25:
N.463::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	ldab  _sci_input_buffer
	clra
	std 11,x
	cpd #1
	bge X26
	jmp  L335
X26:
	ldd 11,x
	cpd #10
	ble X27
	jmp  L335
X27:
N.464::	; 	  { for(i=0;i<3;i++) buffer[i]=buffer[i+1];
	clra
	clrb
	stab 15,x
L337:
	ldab 15,x
	clra
	cpd #3
	bhs  L339
	ldab 15,x
	clra
	std 9,x
	ldd #L268
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	ldd #L268+1
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
L338:
	ldab 15,x
	incb
	stab 15,x
	bra  L337
L339:
N.465::	; 	    buffer[3] = sci_input_buffer%10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L268+3
N.466::	; 	    hh = font[buffer[0]];
	ldd #_font
	pshb
	psha
	ldab  L268
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L270
N.467::	; 	    h  = font[buffer[1]];
	ldd #_font
	pshb
	psha
	ldab  L268+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L269
N.468::	; 	    mm = font[buffer[2]];
	ldd #_font
	pshb
	psha
	ldab  L268+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L272
N.469::	; 	    m =  font[buffer[3]];
	ldd #_font
	pshb
	psha
	ldab  L268+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L271
	tsx
	jmp  L334
L335:
N.471::	; 	  }
; 	  else if(sci_input_buffer == _clear)
	ldab  _sci_input_buffer
	clra
	cpd #11
	bne  L346
N.472::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.473::	; 	    mode = _day;
	ldab #27
	stab  _mode
	jmp  L334
L346:
N.475::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L334
N.476::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.477::	;         for(i=0;i<4;i++) time[i] = buffer[i];
	clra
	clrb
	stab 15,x
L350:
	ldab 15,x
	clra
	cpd #4
	bhs  L352
	ldab 15,x
	clra
	std 9,x
	ldd #L266
	pshb
	psha
	ldd 9,x
	tsy
	addd 0,y
	puly
	pshb
	psha
	ldd #L268
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
L351:
	ldab 15,x
	incb
	stab 15,x
	bra  L350
L352:
N.478::	; 		mode = _day;
	ldab #27
	stab  _mode
	bra  L334
L333:
N.481::	; 	  }
; 	}
;     else if(mode == _day && sci_input_buffer == _game)  mode = 0;
	ldab  _mode
	clra
	cpd #27
	bne  L354
	ldab  _sci_input_buffer
	clra
	cpd #18
	bne  L354
	clra
	clrb
	stab  _mode
L354:
L334:
L328:
L325:
L323:
L320:
L287:
L276:
	xgdx
	addd #18
	xgdx
	txs
	rts
L265:
	.area bss
L369:
	.blkb 4
L370:
	.blkb 4
L371:
	.blkb 2
L372:
	.blkb 4
L373:
	.blkb 1
L374:
	.blkb 1
L375:
	.blkb 1
L376:
	.blkb 1
L377:
	.blkb 1
L378:
	.blkb 1
L379:
	.blkb 1
L380:
	.blkb 2
L381:
	.blkb 2
L382:
	.blkb 2
L383:
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
N.487::	;   }
; }
; 
; 
; void game_time(unsigned char flag)
; { static unsigned char time[4];
	ldab 18,x
	stab 17,x
N.495::	;   static float counter;
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
	beq  L384
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
L384:
N.497::	; 
;   if(flag == _INITIALIZATION_)
	ldab 17,x
	clra
	cpd #2
	beq X28
	jmp  L386
X28:
N.498::	;   { horn_off
	ldab  4096
	andb #127
	stab  4096
N.499::	;     horn_condition = 0;
	clra
	clrb
	std  L383
N.500::	;     time[0] = 0;
	stab  L369
N.501::	;     time[1] = 0;
	clra
	clrb
	stab  L369+1
N.502::	; 	time[2] = 0;
	clra
	clrb
	stab  L369+2
N.503::	; 	time[3] = 0;
	clra
	clrb
	stab  L369+3
N.504::	; 	game_time_maximum = 1800;  //30 minutes.
	ldd #1800
	std  L371
N.505::	; 	horn_time = horn_buffer = 0;
	clra
	clrb
	std  L381
	std  L380
N.506::	; 	horn_time_maximum = 5*32;
	ldd #160
	std  L382
N.507::	; 	game_started = timer_restarted = 0;
	clra
	clrb
	stab  L375
	clra
	clrb
	stab  L374
N.508::	; 	counter = 0.0;
	ldy #L282
	ldd #L370
	xgdx
	jsr  __copy_float
N.509::	;     data[0] = &hh;
	ldd #L377
	std  _data
N.510::	; 	data[1] = &h;
	ldd #L376
	std  _data+2
N.511::	; 	data[2] = &mm;
	ldd #L379
	std  _data+4
N.512::	; 	data[3] = &m;
	ldd #L378
	std  _data+6
	tsx
	jmp  L387
L386:
N.515::	;   }
; 
;   else if(flag == _NEXT_TIMER_TICK_)
	ldab 17,x
	clra
	cpd #1
	beq X29
	jmp  L394
X29:
N.516::	;   { if(!(system_flag & _TIMER_ON_)) timer_restarted = 1;
	ldab  _system_flag
	clra
	bitb #128
	bne  L396
	ldab #1
	stab  L375
	jmp  L397
L396:
N.517::	;     else if(game_started && timer_restarted)
	ldab  L374
	clra
	cpd #0
	bne X30
	jmp  L398
X30:
	ldab  L375
	clra
	cpd #0
	bne X31
	jmp  L398
X31:
N.518::	;      if(game_time_direction && (((time[0]*10+time[1])*6+time[2])*10+time[3])<game_time_maximum )
	ldab  L373
	clra
	cpd #0
	bne X32
	jmp  L400
X32:
	ldab  L369+3
	clra
	pshb
	psha
	ldab  L369+2
	clra
	pshb
	psha
	ldab  L369+1
	clra
	pshb
	psha
	ldab  L369
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
	cpd  L371
	tsx
	blo X33
	jmp  L400
X33:
N.519::	; 	 { if((counter += 0.032768) >= 1.0)
	ldd #L290
	pshb
	psha
	ldd #L370
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
	ldd #L370
	xgdx
	jsr  __copy_float
	ldd #L407
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
	bge X34
	jmp  L401
X34:
N.520::	;        { counter -= 1.0;
	ldd #L407
	pshb
	psha
	ldd #L370
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
	ldd #L370
	xgdx
	jsr  __copy_float
N.521::	; 	     if((++time[3])>=10)
	ldab  L369+3
	incb
	tsx
	stab 3,x
	ldab 3,x
	stab  L369+3
	ldab 3,x
	clra
	cpd #10
	bhs X35
	jmp  L401
X35:
N.522::	; 	     { time[3] = 0;
	clra
	clrb
	stab  L369+3
N.523::	; 	       if((++time[2])>=6)
	ldab  L369+2
	incb
	stab 2,x
	ldab 2,x
	stab  L369+2
	ldab 2,x
	clra
	cpd #6
	bhs X36
	jmp  L401
X36:
N.524::	; 		   { time[2] = 0;
	clra
	clrb
	stab  L369+2
N.525::	; 		     if((++time[1])>=10)
	ldab  L369+1
	incb
	stab 1,x
	ldab 1,x
	stab  L369+1
	ldab 1,x
	clra
	cpd #10
	bhs X37
	jmp  L401
X37:
N.526::	; 		     { time[1] = 0;
	clra
	clrb
	stab  L369+1
N.527::	; 		       if((++time[0])>=10)
	ldab  L369
	incb
	stab 0,x
	ldab 0,x
	stab  L369
	ldab 0,x
	clra
	cpd #10
	bhs X38
	jmp  L401
X38:
N.528::	; 			   { time[0] = 0;
	clra
	clrb
	stab  L369
	jmp  L401
L400:
N.535::	; 		       }
; 		     }
; 		   }
; 	     }
;        }
; 	 }
; 	 else if( !game_time_direction && (time[0] | time[1] | time[2] | time[3]) )
	ldab  L373
	clra
	cpd #0
	beq X39
	jmp  L422
X39:
	ldab  L369+3
	clra
	pshb
	psha
	ldab  L369+2
	clra
	pshb
	psha
	ldab  L369+1
	clra
	pshb
	psha
	ldab  L369
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
	bne X40
	jmp  L422
X40:
N.536::	; 	 { if((counter -= 0.032768) <= -1.0)
	ldd #L290
	pshb
	psha
	ldd #L370
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
	ldd #L370
	xgdx
	jsr  __copy_float
	ldd #L429
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
	ble X41
	jmp  L427
X41:
N.537::	;        { counter += 1.0;
	ldd #L407
	pshb
	psha
	ldd #L370
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
	ldd #L370
	xgdx
	jsr  __copy_float
N.538::	; 	     if(time[3]>0) time[3]--;
	ldab  L369+3
	clra
	cpd #0
	tsx
	bls  L430
	ldab  L369+3
	subb #1
	stab  L369+3
	bra  L431
L430:
N.540::	; 	     else
; 		 { time[3] = 9;
	ldab #9
	stab  L369+3
N.541::	; 	       if(time[2]>0) time[2]--;
	ldab  L369+2
	clra
	cpd #0
	bls  L435
	ldab  L369+2
	subb #1
	stab  L369+2
	bra  L436
L435:
N.543::	; 		   else
; 		   { time[2] = 5;
	ldab #5
	stab  L369+2
N.544::	; 		     if(time[1]>0) time[1]--;
	ldab  L369+1
	clra
	cpd #0
	bls  L440
	ldab  L369+1
	subb #1
	stab  L369+1
	bra  L441
L440:
N.546::	; 		     else
; 			 { if(time[0]>0)
	ldab  L369
	clra
	cpd #0
	bls  L444
N.547::	; 			   { time[1] = 9;
	ldab #9
	stab  L369+1
N.548::	; 		         time[0]--;
	ldab  L369
	subb #1
	stab  L369
L444:
L441:
L436:
L431:
L427:
L422:
L401:
L398:
L397:
N.556::	; 			   }
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
	bne X42
	jmp  L447
X42:
N.557::	;       if(!time[0] && !time[1] && !game_time_direction && game_started)
	ldab  L369
	clra
	cpd #0
	beq X43
	jmp  L449
X43:
	ldab  L369+1
	clra
	cpd #0
	beq X44
	jmp  L449
X44:
	ldab  L373
	clra
	cpd #0
	beq X45
	jmp  L449
X45:
	ldab  L374
	clra
	cpd #0
	bne X46
	jmp  L449
X46:
N.558::	; 	  { hh = time[2] ? font[time[2]] : 0;
	ldab  L369+2
	clra
	std 12,x
	std 14,x
	ldd 12,x
	beq  L455
	ldd #_font
	pshb
	psha
	ldab  L369+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 14,x
L455:
	ldab 15,x
	stab  L377
N.559::	; 	    h  = time[2] | time[3] ? font[time[3]] : 0;
	ldab  L369+3
	clra
	pshb
	psha
	ldab  L369+2
	clra
	tsy
	orab 1,y
	oraa 0,y
	puly
	std 8,x
	std 10,x
	ldd 8,x
	beq  L461
	ldd #_font
	pshb
	psha
	ldab  L369+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 10,x
L461:
	ldab 11,x
	stab  L376
N.560::	; 		mm = font[(int)(-counter*10)];
	ldd #_font
	pshb
	psha
	ldd #L370
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
	ldd #L463
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
	stab  L379
N.561::	; 		m  = 0;
	clra
	clrb
	stab  L378
	tsx
	bra  L450
L449:
N.564::	; 	  }
; 	  else
; 	  { hh = time[0] ? font[time[0]] : 0;
	ldab  L369
	clra
	std 12,x
	std 14,x
	ldd 12,x
	beq  L465
	ldd #_font
	pshb
	psha
	ldab  L369
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	clra
	std 14,x
L465:
	ldab 15,x
	stab  L377
N.565::	; 	    h  = font[time[1]];
	ldd #_font
	pshb
	psha
	ldab  L369+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L376
N.566::	; 	    mm = font[time[2]];
	ldd #_font
	pshb
	psha
	ldab  L369+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L379
N.567::	; 	    m  = font[time[3]];
	ldd #_font
	pshb
	psha
	ldab  L369+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L378
L450:
L447:
N.570::	;       }
; 
; 	if(game_started)
	ldab  L374
	clra
	cpd #0
	bne X47
	jmp  L395
X47:
N.571::	; 	 if(!horn_time)
	ldd  L380
	beq X48
	jmp  L472
X48:
N.572::	; 	 { if((!time[0] && !time[1] && !time[2] && !time[3] && !game_time_direction) ||
	ldab  L369
	clra
	cpd #0
	bne  L486
	ldab  L369+1
	clra
	cpd #0
	bne  L486
	ldab  L369+2
	clra
	cpd #0
	bne  L486
	ldab  L369+3
	clra
	cpd #0
	bne  L486
	ldab  L373
	clra
	cpd #0
	beq  L482
L486:
	ldab  L369+3
	clra
	pshb
	psha
	ldab  L369+2
	clra
	pshb
	psha
	ldab  L369+1
	clra
	pshb
	psha
	ldab  L369
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
	cpd  L371
	tsx
	bhs X49
	jmp  L395
X49:
	ldab  L373
	clra
	cpd #0
	bne X50
	jmp  L395
X50:
L482:
N.574::	; 	   (((((time[0]*10+time[1])*6+time[2])*10+time[3])>=game_time_maximum) && game_time_direction))
; 	   { if(horn_time_maximum)
	ldd  L382
	beq  L487
N.575::	; 	     { horn_on
	ldab  _mode
	clra
	cpd #0
	bne  L489
	ldab  4096
	orab #128
	stab  4096
L489:
N.576::	; 	       horn_time = horn_time_maximum;
	ldd  L382
	std  L380
N.577::	; 		   horn_condition = 1;
	ldd #1
	std  L383
	jmp  L395
L487:
N.579::	; 		 }
; 		 else game_started = 0;
	clra
	clrb
	stab  L374
	jmp  L395
L472:
N.583::	;        }
;      }
; 	 else
; 	 { if(!(--horn_time))
	ldd  L380
	subd #1
	std 14,x
	std  L380
	ldd 14,x
	beq X51
	jmp  L395
X51:
N.584::	; 	   { game_started = 0;
	clra
	clrb
	stab  L374
N.585::	; 	     horn_off
	ldab  4096
	andb #127
	stab  4096
N.586::	;  		 horn_condition = 0;
	clra
	clrb
	std  L383
	jmp  L395
L394:
N.591::	; 	   }
; 	 }
;   }
; 
;   else if(flag == _NEXT_CHARACTER_)
	ldab 17,x
	clra
	cpd #0
	beq X52
	jmp  L493
X52:
N.592::	;   { if(!mode && sci_input_buffer == _set) mode = _set;
	ldab  _mode
	clra
	cpd #0
	bne  L495
	ldab  _sci_input_buffer
	clra
	cpd #19
	bne  L495
	ldab #19
	stab  _mode
	jmp  L496
L495:
N.593::	;     else if(mode == _set && sci_input_buffer == _game)
	ldab  _mode
	clra
	cpd #19
	bne  L497
	ldab  _sci_input_buffer
	clra
	cpd #18
	bne  L497
N.594::	; 	{ mode = _game;
	ldab #18
	stab  _mode
N.595::	;       hh = h = mm = m = font[0];
	ldab  _font
	stab 15,x
	ldab 15,x
	stab  L378
	ldab 15,x
	stab  L379
	ldab 15,x
	stab  L376
	ldab 15,x
	stab  L377
N.596::	; 	  for(i=0;i<4;i++) buffer[i] = 0;
	clra
	clrb
	stab 16,x
L499:
	ldab 16,x
	clra
	cpd #4
	bhs  L501
	ldd #L372
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
L500:
	ldab 16,x
	incb
	stab 16,x
	bra  L499
L501:
N.597::	; 	  blink_character = 3;
	ldab #3
	stab  _blink_character
N.598::	; 	  blink_segments = 0;
	clra
	clrb
	stab  _blink_segments
	jmp  L498
L497:
N.600::	; 	}
; 	else if(mode == _set && sci_input_buffer == _1) mode = 201;
	ldab  _mode
	clra
	cpd #19
	bne  L503
	ldab  _sci_input_buffer
	clra
	cpd #1
	bne  L503
	ldab #201
	stab  _mode
	jmp  L504
L503:
N.601::	; 	else if(mode == _set && sci_input_buffer == _horn)
	ldab  _mode
	clra
	cpd #19
	bne  L505
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L505
N.602::	; 	{ mode = _horn;
	ldab #15
	stab  _mode
N.603::	; 	  horn_buffer = horn_time_maximum;
	ldd  L382
	std  L381
N.604::	; 	  horn_off
	ldab  4096
	andb #127
	stab  4096
N.605::	; 	  horn_condition = 0;
	clra
	clrb
	std  L383
	jmp  L506
L505:
N.607::	; 	}
; 	else if(mode == _horn && sci_input_buffer != 111)
	ldab  _mode
	clra
	cpd #15
	bne  L507
	ldab  _sci_input_buffer
	clra
	cpd #111
	beq  L507
N.608::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	ldab  _sci_input_buffer
	clra
	std 14,x
	cpd #1
	blt  L509
	ldd 14,x
	cpd #10
	bgt  L509
N.609::	; 	            horn_time_maximum = (sci_input_buffer % 10) * 32;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	lsld
	lsld
	lsld
	lsld
	lsld
	std  L382
	tsx
	jmp  L508
L509:
N.610::	; 	  else if(sci_input_buffer == _enter) mode = 0;
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L511
	clra
	clrb
	stab  _mode
	jmp  L508
L511:
N.612::	; 	  else
; 	  { mode = 0;
	clra
	clrb
	stab  _mode
N.613::	; 	    horn_time_maximum = horn_buffer;
	ldd  L381
	std  L382
	jmp  L508
L507:
N.616::	;       }
; 	}
; 	else if(!mode && sci_input_buffer == _horn)
	ldab  _mode
	clra
	cpd #0
	bne  L513
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L513
N.617::	; 	{ horn_on
	ldab  _mode
	clra
	cpd #0
	bne  L515
	ldab  4096
	orab #128
	stab  4096
L515:
N.618::	; 	  horn_condition = 1;
	ldd #1
	std  L383
	jmp  L514
L513:
N.620::	; 	}
; 	else if(sci_input_buffer == 111)
	ldab  _sci_input_buffer
	clra
	cpd #111
	bne  L517
N.621::	; 	{ horn_off
	ldab  4096
	andb #127
	stab  4096
N.622::	; 	  horn_condition = 0;
	clra
	clrb
	std  L383
	jmp  L518
L517:
N.624::	; 	}
; 	else if(mode == 201)
	ldab  _mode
	clra
	cpd #201
	bne  L519
N.625::	; 	{if(sci_input_buffer == _1) mode = _1;
	ldab  _sci_input_buffer
	clra
	cpd #1
	bne  L521
	ldab #1
	stab  _mode
	jmp  L520
L521:
N.626::	; 	 else if(sci_input_buffer == _2) mode = _2;
	ldab  _sci_input_buffer
	clra
	cpd #2
	bne  L523
	ldab #2
	stab  _mode
	jmp  L520
L523:
N.627::	; 	 else mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L520
L519:
N.629::	; 	}
; 	else if(mode == _1)
	ldab  _mode
	clra
	cpd #1
	bne  L525
N.630::	; 	{if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L527
N.631::	; 	 { timer_restarted = 0;
	clra
	clrb
	stab  L375
N.632::	; 	   time[0] = game_time_maximum / 600;
	ldd  L371
	ldx #600
	idiv
	xgdx
	stab  L369
N.633::	; 	   time[1] = (game_time_maximum /60)% 10;
	ldd  L371
	ldx #60
	idiv
	xgdx
	ldx #10
	idiv
	stab  L369+1
N.634::	; 	   time[2] = (game_time_maximum /10)% 6;
	ldd  L371
	ldx #10
	idiv
	xgdx
	ldx #6
	idiv
	stab  L369+2
N.635::	; 	   time[3] = game_time_maximum % 10;
	ldd  L371
	ldx #10
	idiv
	stab  L369+3
N.636::	; 	   game_time_direction = 0;
	clra
	clrb
	stab  L373
L527:
N.638::	; 	 }
; 	 mode = 0;
	clra
	clrb
	stab  _mode
	tsx
	jmp  L526
L525:
N.640::	; 	}
; 	else if(mode == _2)
	ldab  _mode
	clra
	cpd #2
	bne  L532
N.641::	; 	{if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	bne  L534
N.642::	; 	 { timer_restarted = 0;
	clra
	clrb
	stab  L375
N.643::	; 	   time[0] = time[1] = time[2] = time[3] = 0;
	clra
	clrb
	stab  L369+3
	clra
	clrb
	stab  L369+2
	clra
	clrb
	stab  L369+1
	clra
	clrb
	stab  L369
N.644::	;        game_time_direction = 1;
	ldab #1
	stab  L373
L534:
N.646::	; 	 }
; 	 mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L533
L532:
N.648::	; 	}
; 	else if(mode == _game)
	ldab  _mode
	clra
	cpd #18
	beq X53
	jmp  L539
X53:
N.649::	; 	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	ldab  _sci_input_buffer
	clra
	std 14,x
	cpd #1
	bge X54
	jmp  L541
X54:
	ldd 14,x
	cpd #10
	ble X55
	jmp  L541
X55:
N.650::	; 	  { buffer[0]=buffer[1];
	ldab  L372+1
	stab  L372
N.651::	; 	    buffer[1]=buffer[2];
	ldab  L372+2
	stab  L372+1
N.652::	; 		buffer[2]=buffer[3];
	ldab  L372+3
	stab  L372+2
N.653::	; 	    buffer[3] = sci_input_buffer%10;
	ldab  _sci_input_buffer
	clra
	ldx #10
	idiv
	stab  L372+3
N.654::	; 	    hh = font[buffer[0]];
	ldd #_font
	pshb
	psha
	ldab  L372
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L377
N.655::	; 	    h  = font[buffer[1]];
	ldd #_font
	pshb
	psha
	ldab  L372+1
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L376
N.656::	; 	    mm = font[buffer[2]];
	ldd #_font
	pshb
	psha
	ldab  L372+2
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L379
N.657::	; 	    m  = font[buffer[3]];
	ldd #_font
	pshb
	psha
	ldab  L372+3
	clra
	tsy
	addd 0,y
	puly
	xgdy
	ldab 0,y
	stab  L378
	tsx
	jmp  L542
L541:
N.659::	; 	  }
; 	  else if(sci_input_buffer == _clear ||
	ldab  _sci_input_buffer
	clra
	std 12,x
	cpd #11
	beq  L557
	ldd 12,x
	cpd #12
	bne  L552
	ldab  L372
	clra
	cpd #0
	bne  L552
	ldab  L372+1
	clra
	cpd #0
	bne  L552
	ldab  L372+2
	clra
	cpd #0
	bne  L552
	ldab  L372+3
	clra
	cpd #0
	bne  L552
L557:
N.661::	; 	         (sci_input_buffer == _enter && !buffer[0] && !buffer[1] && !buffer[2] && !buffer[3]))
; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.662::	; 	    mode = 0;
	clra
	clrb
	stab  _mode
	jmp  L553
L552:
N.664::	; 	  }
; 	  else if(sci_input_buffer == _enter)
	ldab  _sci_input_buffer
	clra
	cpd #12
	beq X56
	jmp  L558
X56:
N.665::	; 	  { blink_character = 0;
	clra
	clrb
	stab  _blink_character
N.666::	; 	    game_time_maximum = ((buffer[0]*10 + buffer[1])*6+buffer[2])*10+buffer[3];
	ldab  L372+3
	clra
	pshb
	psha
	ldab  L372+2
	clra
	pshb
	psha
	ldab  L372+1
	clra
	pshb
	psha
	ldab  L372
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
	std  L371
N.667::	; 		for(i=0;i<4;i++) time[i] = game_time_direction ? 0 : buffer[i];
	clra
	clrb
	tsx
	stab 16,x
L563:
	ldab 16,x
	clra
	cpd #4
	bhs  L565
	ldab  L373
	clra
	cpd #0
	beq  L568
	clra
	clrb
	std 10,x
	bra  L569
L568:
	ldd #L372
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
L569:
	ldd #L369
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
L564:
	ldab 16,x
	incb
	stab 16,x
	bra  L563
L565:
N.668::	; 		mode = 0;
	clra
	clrb
	stab  _mode
N.669::	; 		game_started = 1;
	ldab #1
	stab  L374
N.670::	; 		timer_restarted = 0;
	clra
	clrb
	stab  L375
L558:
L553:
L542:
L539:
L533:
L526:
L520:
L518:
L514:
L508:
L506:
L504:
L498:
L496:
N.674::	; 	  }
; 	}
; 
; 	if(sci_input_buffer != _horn  ||  mode)
	ldab  _sci_input_buffer
	clra
	cpd #15
	bne  L572
	ldab  _mode
	clra
	cpd #0
	beq  L570
L572:
N.675::	; 	{ horn_off
	ldab  4096
	andb #127
	stab  4096
N.676::	; 	  horn_condition = 0;
	clra
	clrb
	std  L383
L570:
L493:
L395:
L387:
	xgdx
	addd #19
	xgdx
	txs
	rts
L368:
	.globl _process_data
;     flag -> 2,x
_process_data:
	pshb
	psha
	pshx
	tsx
N.686::	; 	}
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
	beq  L593
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
L593:
N.694::	; 
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
N.695::	;   guest_score(flag);
	tsx
	ldab 2,x
	clra
	jsr  _guest_score
N.696::	;   period(flag);
	tsx
	ldab 2,x
	clra
	jsr  _period
N.697::	;   bonus_possession(flag);
	tsx
	ldab 2,x
	clra
	jsr  _bonus_possession
N.703::	; 
; 
;   ///end/cals////////////////////////////////////////////////////////////////////////
;   ///////////////////////////////////////////////////////////////////////////////////
;   //timers.
;   if(flag == _NEXT_CHARACTER_) test_segments();
	tsx
	ldab 2,x
	clra
	cpd #0
	bne  L595
	jsr  _test_segments
L595:
N.707::	;   //day_time(flag);     // no timers for this baseball old type board.
;   //game_time(flag);
; 
;   if(flag == _NEXT_CHARACTER_ && mode == _set &&
	tsx
	ldab 2,x
	clra
	cpd #0
	bne  L597
	ldab  _mode
	clra
	cpd #19
	bne  L597
	ldab  _sci_input_buffer
	clra
	std 0,x
	cpd #11
	beq  L599
	ldd 0,x
	cpd #12
	bne  L597
L599:
N.709::	;   (sci_input_buffer == _clear || sci_input_buffer == _enter))
;   { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L600
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
L600:
N.710::	;     mode = 0;
	clra
	clrb
	stab  _mode
N.711::	;     horn_off
	ldab  4096
	andb #127
	stab  4096
L597:
	pulx
	pulx
	rts
L592:
	.globl _main
;        i -> 0,x
_main:
	pshx
	tsx
	sei
N.721::	;   }
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
	beq  L604
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
L604:
N.722::	;   mode = 0;
	clra
	clrb
	stab  _mode
N.723::	;   initialization();         // programm initialization.
	jsr  _initialization
N.724::	;   power_on_restarted = 0xff;
	ldab #255
	stab  _power_on_restarted
 cli
N.726::	; 
;   asm(" cli");
L606:
L607:
N.729::	; 
;   while(1)
;   { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	clra
	clrb
	tsx
	stab 0,x
L609:
	ldab 0,x
	clra
	cpd #23
	bhi  L611
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
L610:
	ldab 0,x
	incb
	stab 0,x
	bra  L609
L611:
L613:
L614:
N.730::	; 	while(no_rx_time >= 1831)
	ldd  _no_rx_time
	cpd #1831
	blo  L615
N.731::	; 	{ copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L613
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
	bra  L613
L615:
N.733::	; 	}
; 	process_data(_INITIALIZATION_);
	ldd #2
	jsr  _process_data
L618:
L619:
N.734::	;     while(no_rx_time < 3663)
	ldd  _no_rx_time
	cpd #3663
	tsx
	blo X57
	jmp  L606
X57:
N.735::	;     { copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L618
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
	bra  L618
L603:
	.globl _datachange
;        i -> 0,x
_datachange:
	pshx
	tsx
N.744::	;     }
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
	beq  L624
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
L624:
N.745::	;   proceed_dim();
	jsr  _proceed_dim
N.746::	;   if(sci_input_buffer != _dim) process_data(_NEXT_CHARACTER_);
	ldab  _sci_input_buffer
	clra
	cpd #22
	tsx
	beq  L626
	clra
	clrb
	jsr  _process_data
L626:
	tsx
	pulx
	rts
L623:
	.globl _integrate
_integrate:
	pshx
	pshx
	pshx
	tsx
N.751::	; }
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
	beq  L629
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
L629:
N.753::	; 
;   if( !received && sci_input_buffer != 255 && sci_input_buffer != 233 )
	ldab  _received
	clra
	cpd #0
	bne  L631
	ldab  _sci_input_buffer
	clra
	std 4,x
	cpd #255
	beq  L631
	ldd 4,x
	cpd #233
	beq  L631
N.754::	;   { received = 1;
	ldab #1
	stab  _received
N.755::	;     no_rx_time = 0;
	clra
	clrb
	std  _no_rx_time
N.756::	;     datachange();
	jsr  _datachange
L631:
N.759::	;   }
; 
;   if( received && (sci_input_buffer == 255 || sci_input_buffer == 233))
	ldab  _received
	clra
	cpd #0
	tsx
	beq  L633
	ldab  _sci_input_buffer
	clra
	std 2,x
	cpd #255
	beq  L635
	ldd 2,x
	cpd #233
	bne  L633
L635:
N.760::	;   { received = 0;
	clra
	clrb
	stab  _received
N.761::	;     system_flag = sci_input_buffer == 255 ? system_flag | _TIMER_ON_ : system_flag & ~_TIMER_ON_;
	ldab  _sci_input_buffer
	clra
	cpd #255
	bne  L637
	ldab  _system_flag
	clra
	orab #128
	oraa #0
	std 0,x
	bra  L638
L637:
	ldab  _system_flag
	clra
	andb #127
	anda #255
	std 0,x
L638:
	ldab 1,x
	stab  _system_flag
L633:
	pulx
	pulx
	pulx
	rts
L628:
	.globl __sci
;        i -> 4,x
;     base -> 6,x
__sci:
	pshx
	pshx
	pshx
	pshx
	tsx
N.773::	; 	// for game timer condition.
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
N.776::	;   int i;
; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L642
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
L642:
N.778::	; 
;   sci_input_buffer = SCSR;
	ldab  4142
	stab  _sci_input_buffer
N.779::	;   sci_input_buffer = SCDR;
	ldab  4143
	stab  _sci_input_buffer
N.780::	;   if((sci_input_counter[0] >= 7) || (sci_input_counter[1] >= 7 + base))
	ldd  _sci_input_counter
	cpd #7
	bge  L647
	ldab 6,x
	clra
	addd #7
	pshb
	psha
	ldd  _sci_input_counter+2
	tsy
	cpd 0,y
	puly
	blt  L644
L647:
N.781::	;   { integrate();
	jsr  _integrate
N.782::	;     for(i=0;i<2;i++) sci_input_counter[i] = i ? base : 0;
	clra
	clrb
	tsx
	std 4,x
L648:
	ldd 4,x
	cpd #2
	blt X58
	jmp  L645
X58:
	ldd 4,x
	std 2,x
	ldd 4,x
	beq  L653
	ldab 6,x
	clra
	std 2,x
L653:
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
L649:
	ldd 4,x
	addd #1
	std 4,x
	bra  L648
L644:
N.785::	;   }
;   else
;    for(i=0;i<2;i++)
	clra
	clrb
	std 4,x
L655:
	ldd 4,x
	cpd #2
	bge  L657
N.786::	;     if(sci_input_counter[i] == sci_input_buffer) sci_input_counter[i]++;
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
	bne  L659
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
	bra  L660
L659:
N.787::	;     else sci_input_counter[i] = i ? base : 0;
	ldd 4,x
	std 0,x
	ldd 4,x
	beq  L662
	ldab 6,x
	clra
	std 0,x
L662:
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
L660:
L656:
	ldd 4,x
	addd #1
	std 4,x
	jmp  L655
L657:
L645:
	pulx
	pulx
	pulx
	pulx
	rti
L641:
	.globl __rti
; blink_data -> 0,x
; blink_buffer -> 1,x
;        i -> 3,x
__rti:
	des
	pshx
	pshx
	tsx
N.796::	; }
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
N.798::	; 
;   copreset
	ldab #85
	stab  4154
	ldab #170
	stab  4154
	ldab  4142
	clra
	bitb #128
	beq  L666
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
L666:
N.800::	; 
;   if(no_rx_time <= 3663) no_rx_time++;   //120 seconds.
	ldd  _no_rx_time
	cpd #3663
	bhi  L668
	ldd  _no_rx_time
	addd #1
	std  _no_rx_time
L668:
N.802::	; 
;   process_data(_NEXT_TIMER_TICK_);
	ldd #1
	jsr  _process_data
N.805::	; 
; 
;   if(mode == 100 && !(no_rx_time & 0x10) && (blink_character < 4))
	ldab  _mode
	clra
	cpd #100
	tsx
	bne  L670
	ldd  _no_rx_time
	bitb #16
	bne  L670
	ldab  _blink_character
	clra
	cpd #4
	bhs  L670
N.806::	;   { blink_buffer = day_time_data[blink_character];
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
N.807::	;     day_time_data[blink_character] = (unsigned char *)extender;
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
N.808::	; 	putcharacters();
	jsr  _putcharacters
N.809::	; 	day_time_data[blink_character] = blink_buffer;
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
	jmp  L671
L670:
N.811::	;   }
;   else if(blink_character && !blink_segments && !(no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	beq  L672
	ldab  _blink_segments
	clra
	cpd #0
	bne  L672
	ldd  _no_rx_time
	bitb #16
	bne  L672
N.812::	;   { blink_buffer = data[blink_character];
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
N.813::	;     data[blink_character] = (unsigned char *)extender;
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
N.814::	; 	putcharacters();
	jsr  _putcharacters
N.815::	; 	data[blink_character] = blink_buffer;
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
	jmp  L673
L672:
N.817::	;   }
;   else if(blink_character && !blink_segments && (no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	bne X59
	jmp  L674
X59:
	ldab  _blink_segments
	clra
	cpd #0
	beq X60
	jmp  L674
X60:
	ldd  _no_rx_time
	bitb #16
	bne X61
	jmp  L674
X61:
N.818::	;   { blink_buffer = data[blink_character];
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
N.819::	;     if((*data[blink_character]) == 0) data[blink_character] = (unsigned char *)(&font[0]);
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
	bne  L676
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
	bra  L677
L676:
N.821::	; 	else
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
	bne  L678
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
L678:
L677:
N.822::	; 	putcharacters();
	jsr  _putcharacters
N.823::	; 	data[blink_character] = blink_buffer;
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
	jmp  L675
L674:
N.825::	;   }
;   else if(blink_character && blink_segments && !(no_rx_time & 0x10))
	ldab  _blink_character
	clra
	cpd #0
	bne X62
	jmp  L681
X62:
	ldab  _blink_segments
	clra
	cpd #0
	bne X63
	jmp  L681
X63:
	ldd  _no_rx_time
	bitb #16
	beq X64
	jmp  L681
X64:
N.826::	;   { blink_buffer = data[blink_character];       //keep address.
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
N.827::	;     blink_data = *blink_buffer;                 //init value.
	ldy 1,x
	ldab 0,y
	stab 0,x
N.828::	; 	data[blink_character] = &blink_data;        //point to buffer.
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
N.829::	;     for( i=1 ; i<=8; i<<=1 )                    //correct data.
	ldab #1
	tsx
	stab 3,x
L683:
	ldab 3,x
	clra
	cpd #8
	bhi  L685
N.830::	;      if(blink_segments & i) blink_data &= ~i;   //make dark segments.
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
	beq  L687
	ldab 3,x
	comb
	pshb
	ldab 0,x
	tsy
	andb 0,y
	ins
	stab 0,x
L687:
L684:
	ldab 3,x
	lslb
	stab 3,x
	bra  L683
L685:
N.831::	; 	putcharacters();
	jsr  _putcharacters
N.832::	; 	data[blink_character] = blink_buffer;
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
	bra  L682
L681:
N.834::	;   }
;   else putcharacters();
	jsr  _putcharacters
L682:
L675:
L673:
L671:
	tsx
	ins
	pulx
	pulx
	rti
L665:
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
L463:
	.word 0x4120,0x0
L429:
	.word 0xbf80,0x0
L407:
	.word 0x3f80,0x0
L291:
	.word 0x4270,0x0
L290:
	.word 0x3d06,0x37bd
L282:
	.word 0x0,0x0

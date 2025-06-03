
//==============10=12=96=================\\
// keyboard for all types of game boards \\
//=======================================\\



//***********General*Information*********************
// eprom loading conditions:
//  - buf start : d000
//  - buf end   : ffff
//  - prom start: 5000
//  - prom end  : 7fff
//  - file start address:00000000
//
// lcd screen segments access:
//
//       01
//     .----.
//   40|    |02
//     |-20-|
//   10|    |04
//     '----' .
//       08   80
//
// Keyboard kodes:
// Condition        Response
// =========================
// Key Pressed      flag keypressed in myflags or not 0 or not 2c
// Key Depressed    $00 if switch "timer" is OFF, $1f and flag timer -
//                      if it is ON.
// key  0           $0a
// keys 1...9       $01...$09
//      clear       $0b
//      enter       $0c
//      player      $19
//      shot        $1a
//      day         $1b
//  <empty button>  $1c
//      dim         $16
//      period      $17
//      game        $12
//      set         $13
//      poss        $0e
//      horn        $0f
// HOME  fouls      $15
//       bonus      $11
//       score      $0d
// GUEST fouls      $18
//       bonus      $14
//       score      $10
///////////////////////////////////////////////////////////


#include <hc11.h>

typedef struct _KBD
{  unsigned timer   : 1,
            pressed : 1,
            data    : 6;
} KBD;

KBD kbd, prev_kbd;

double timer;
char signature[7];


void copreset()
{ COPRST = 0x55;
  COPRST = 0xAA;
}

void dly15ms()
{ TOC1  = TCNT + 0x01d5;
  TFLG1 = 0x80;
  while(!(TFLG1 & 0x80)) copreset();
  TFLG1 = 0x80;
}

void init_program(void)
{ PACTL |= 0x88;  // ddra7,3=1 ->pa7,3 is output.
  PORTA |= 0x08;  // set Rx/Tx to Rx.
  DDRD   = 0x2e;  // ss*,sck,mosi,miso,txd,rxd
                  // pd5,pd3,2,1 are out; pd4,0-ins
  kbd.data    = 0;
  kbd.timer   = 0;
  kbd.pressed = 0;

  timer = -3999.9;

  signature[0] = 0;
  signature[1] = 0;
  signature[2] = 0;
  signature[3] = 0;
  signature[4] = 0;
  signature[5] = 0;
  signature[6] = 0;
}


unsigned char test_kbd(void)
{ unsigned char prevporta = PORTA & 0x0f;
  unsigned char mask = 0x10,i;

  for(i=0; i<4; i++)
  { copreset();
    PORTA = prevporta | mask;
    mask <<= 1;
    if(PORTE)
    { for(mask = 0x40; mask >= 0x01; mask >>= 1)
      if( PORTE & mask ) return i+1;
      else i+=4;
	  return i;
    }
  }
  return 0;
}

void update_kbd(void)
{ unsigned char i;
  copreset();

  prev_kbd.timer = kbd.timer;
  prev_kbd.pressed = kbd.pressed;
  prev_kbd.data = kbd.data;

  if((i=test_kbd()) == 0)     { kbd.timer = 0; kbd.pressed = 0;}
  else if (i == 0x1f)         { kbd.timer = 1; kbd.pressed = 0;}
       else if( !kbd.pressed) { kbd.data = (unsigned)i; kbd.pressed = 1;}
            else                kbd.data = 0;
}

void sendbit(unsigned data)
{
  PORTD = data ? PORTD | 0x04 : PORTD & ~0x04 ;
  while( PORTD & 0x10 ) copreset();
  while( !(PORTD & 0x10)) copreset();
}

void sendbyte(unsigned data)
{ unsigned i;
  copreset();
  sendbit(0);                                         // send start bit -> "0"
  for(i = 0x01; i <= 0x80; i<<=1) sendbit(data & i);  // send byte lsb first
  sendbit(1);                                         // send stop bit -> "1"
}

void send(unsigned data)
{  unsigned char i,j,k;

   copreset();

   PORTA &= ~0x08;                                     // turn on the transmitter.

   k = 0x03 & *(unsigned char *)0xb600;
   if(k==1) k=2;
   else if(k==2) k=1;
   k <<= 1;

   for(j = 0; j < 2; j++)
   { for(i = 0; i < 12; i++) sendbit(1);                 // send the idle line signal
     for(i = k; i< 7 + k ; i++) sendbyte(i);  //send preambula
     sendbyte(data);
   }

   for(j = 0; j < 2; j++)
   { for(i = 0; i < 12; i++) sendbit(1);                 // send the idle line signal
     for(i = k ; i< 7 + k ; i++) sendbyte(i);  //send preambula
     if( !kbd.timer ) sendbyte(233);
	 else             sendbyte(255);
   }

   PORTA |= 0x08;                                      // turn off the transmitter.
}


void correctaddress(void)
{ unsigned short t;
  if(kbd.data == 10) kbd.data = 0;
  else if(kbd.data > 7) return;
  // erase.
  PPROG   = 0x16;
  *(unsigned char *)0xb600 = (unsigned char)kbd.data & 7;
  PPROG   = 0x17;
  dly15ms();
  PPROG   = 0;
  // write.
  PPROG   = 0x02;
  *(unsigned char *)0xb600 = kbd.data & 7;
  PPROG   = 0x03;
  dly15ms();
  PPROG   = 0;
}


void sendkbddata(void)
{ int i;
  update_kbd();

  if(kbd.data || (kbd.timer != prev_kbd.timer))
  { for(i=0;i<6;i++) signature[i] = signature[i+1];
    signature[6] = (char) kbd.data;

	copreset();
    if( signature[5] != 0x13 &&
	    signature[5] != 2 &&
		signature[5] != 3 &&
		signature[5] != 7 ) signature[5] = 0;

	if(signature[0] != 0x13 ||
	   signature[1] != 2 ||
	   signature[2] != 3 ||
	   signature[3] != 3 ||
	   signature[4] != 7 ||
	   signature[5] != 7)
	{ send(kbd.data);
	  if(kbd.data == 15)
	  { while( test_kbd() && test_kbd() != 0x1f) copreset();
        send(111);
	  }
    }
	else
	{ correctaddress();
	  for(i=0;i<6;i++) signature[i] = 0;
      PORTD = 0x04 & *(unsigned char *)0xb600 ? PORTD | 0x02 : PORTD & ~0x02;
	}

	timer = -3999.9;
  }
  kbd.data=0;
}

void main(void)
{ copreset();
  init_program();
  PORTD = 0x04 & *(unsigned char *)0xb600 ? PORTD | 0x02 : PORTD & ~0x02;
  send(77);
  while(1)
  {  copreset();
     sendkbddata();
	 if((timer += 1.0) > 3999.9)
	 { timer = -3999.9;
	   send(77);
	 }
  }
}


extern void _start();	/* entry point in crt11.s */

/////// the end of text area ////////////////

#pragma data:interrupt_vectors

static void (*interrupt_vectors[])() =
{	_start,	/* SCI   */
	_start,	/* SPI   */
	_start,	/* PAIE  */
	_start,	/* PAO   */
	_start,	/* TOF   */
	_start,	/* TOC5  */
	_start,	/* TOC4  */
	_start,	/* TOC3  */
	_start,	/* TOC2  */
	_start,	/* TOC1  */
	_start,	/* TIC3  */
	_start,	/* TIC2  */
	_start,	/* TIC1  */
	_start,	/* RTI   */
	_start,	/* IRQ   */
	_start,	/* XIRQ  */
	_start,	/* SWI   */
	_start,	/* ILLOP */
	_start,	/* COP   */
	_start,	/* CLM   */
	_start  /* RESET */
};

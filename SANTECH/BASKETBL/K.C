
//==============10=12=96=================\\
// keyboard for all types of game boards \\
//=======================================\\



void game_time(unsigned char flag)
{ static unsigned char time[4];
  static float counter;
  static unsigned long game_time_maximum;
  static unsigned char buffer[4], game_time_direction, game_started, timer_restarted;
  static unsigned char h,hh,m,mm;
  static unsigned long horn_time, horn_buffer, horn_time_maximum, horn_condition;
  unsigned char i;

  copreset

  if(flag == _INITIALIZATION_)
  { horn_off
    horn_condition = 0;
    time[0] = 0;
    time[1] = 0;
	time[2] = 0;
	time[3] = 0;
	game_time_maximum = 1800;  //30 minutes.
	horn_time = horn_buffer = 0;
	horn_time_maximum = 5*32;
	game_started = timer_restarted = 0;
	counter = 0.0;
    data[0] = &hh;
	data[1] = &h;
	data[2] = &mm;
	data[3] = &m;
  }

  else if(flag == _NEXT_TIMER_TICK_)
  { if(!(system_flag & _TIMER_ON_)) timer_restarted = 1;
    else if(game_started && timer_restarted)
     if(game_time_direction && (((time[0]*10+time[1])*6+time[2])*10+time[3])<game_time_maximum )
	 { if((counter += 0.032768) >= 1.0)
       { counter -= 1.0;
	     if((++time[3])>=10)
	     { time[3] = 0;
	       if((++time[2])>=6)
		   { time[2] = 0;
		     if((++time[1])>=10)
		     { time[1] = 0;
		       if((++time[0])>=10)
			   { time[0] = 0;
		       }
		     }
		   }
	     }
       }
	 }
	 else if( !game_time_direction && (time[0] | time[1] | time[2] | time[3]) )
	 { if((counter -= 0.032768) <= -1.0)
       { counter += 1.0;
	     if(time[3]>0) time[3]--;
	     else
		 { time[3] = 9;
	       if(time[2]>0) time[2]--;
		   else
		   { time[2] = 5;
		     if(time[1]>0) time[1]--;
		     else
			 { if(time[0]>0)
			   { time[1] = 9;
		         time[0]--;
			   }
		     }
		   }
	     }
       }
	 }

	if(mode != _game)
      if(!time[0] && !time[1] && !game_time_direction && game_started)
	  { hh = time[2] ? font[time[2]] : 0;
	    h  = time[2] | time[3] ? font[time[3]] : 0;
		mm = font[(int)(-counter*10)];
		m  = 0;
	  }
	  else
	  { hh = time[0] ? font[time[0]] : 0;
	    h  = font[time[1]];
	    mm = font[time[2]];
	    m  = font[time[3]];
      }

	if(game_started)
	 if(!horn_time)
	 { if((!time[0] && !time[1] && !time[2] && !time[3] && !game_time_direction) ||
	   (((((time[0]*10+time[1])*6+time[2])*10+time[3])>=game_time_maximum) && game_time_direction))
	   { if(horn_time_maximum)
	     { horn_on
	       horn_time = horn_time_maximum;
		   horn_condition = 1;
		 }
		 else game_started = 0;
       }
     }
	 else
	 { if(!(--horn_time))
	   { game_started = 0;
	     horn_off
 		 horn_condition = 0;
	   }
	 }
  }

  else if(flag == _NEXT_CHARACTER_)
  { if(!mode && sci_input_buffer == _set) mode = _set;
    else if(mode == _set && sci_input_buffer == _game)
	{ mode = _game;
      hh = h = mm = m = font[0];
	  for(i=0;i<4;i++) buffer[i] = 0;
	  blink_character = 3;
	  blink_segments = 0;
	}
	else if(mode == _set && sci_input_buffer == _1) mode = 201;
	else if(mode == _set && sci_input_buffer == _horn)
	{ mode = _horn;
	  horn_buffer = horn_time_maximum;
	  horn_off
	  horn_condition = 0;
	}
	else if(mode == _horn && sci_input_buffer != 111)
	{ if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	            horn_time_maximum = (sci_input_buffer % 10) * 32;
	  else if(sci_input_buffer == _enter) mode = 0;
	  else
	  { mode = 0;
	    horn_time_maximum = horn_buffer;
      }
	}
	else if(!mode && sci_input_buffer == _horn)
	{ horn_on
	  horn_condition = 1;
	}
	else if(sci_input_buffer == 111)
	{ horn_off
	  horn_condition = 0;
	}
	else if(mode == 201)
	{if(sci_input_buffer == _1) mode = _1;
	 else if(sci_input_buffer == _2) mode = _2;
	 else mode = 0;
	}
	else if(mode == _1)
	{if(sci_input_buffer == _enter)
	 { timer_restarted = 0;
	   time[0] = game_time_maximum / 600;
	   time[1] = (game_time_maximum /60)% 10;
	   time[2] = (game_time_maximum /10)% 6;
	   time[3] = game_time_maximum % 10;
	   game_time_direction = 0;
	 }
	 mode = 0;
	}
	else if(mode == _2)
	{if(sci_input_buffer == _enter)
	 { timer_restarted = 0;
	   time[0] = time[1] = time[2] = time[3] = 0;
       game_time_direction = 1;
	 }
	 mode = 0;
	}
	else if(mode == _game)
	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	  { buffer[0]=buffer[1];
	    buffer[1]=buffer[2];
		buffer[2]=buffer[3];
	    buffer[3] = sci_input_buffer%10;
	    hh = font[buffer[0]];
	    h  = font[buffer[1]];
	    mm = font[buffer[2]];
	    m  = font[buffer[3]];
	  }
	  else if(sci_input_buffer == _clear ||
	         (sci_input_buffer == _enter && !buffer[0] && !buffer[1] && !buffer[2] && !buffer[3]))
	  { blink_character = 0;
	    mode = 0;
	  }
	  else if(sci_input_buffer == _enter)
	  { blink_character = 0;
	    game_time_maximum = ((buffer[0]*10 + buffer[1])*6+buffer[2])*10+buffer[3];
		for(i=0;i<4;i++) time[i] = game_time_direction ? 0 : buffer[i];
		mode = 0;
		game_started = 1;
		timer_restarted = 0;
	  }
	}

	if(sci_input_buffer != _horn  ||  mode)
	{ horn_off
	  horn_condition = 0;
	}
  }
}




/////////root////////////
void process_data(unsigned char flag)
{  copreset

  //process sci_input_buffer and mode.
  ///////////////////////////////////////////////////////////////////////////////////
  ///cals////////////////////////////////////////////////////////////////////////////
  // TO DO -> Enter procedures calls here.

  //top.
  home_score(flag);
  guest_score(flag);
  period(flag);
  bonus_possession(flag);

  //bottom.
  home_fouls(flag);
  guest_fouls(flag);
  player_foul(flag);


  ///end/cals////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////
  //timers.
  if(flag == _NEXT_CHARACTER_) test_segments();
  day_time(flag);
  game_time(flag);

  if(flag == _NEXT_CHARACTER_ && mode == _set &&
  (sci_input_buffer == _clear || sci_input_buffer == _enter))
  { copreset
    mode = 0;
    horn_off
  }
}

////////// timer interrupt ////////////////////
#pragma interrupt_handler _rti
void _rti()
{ unsigned char *blink_buffer;
  unsigned char blink_data,i;

  TFLG2  = 0x40;               // reset RTI interrupt flag RTIF.

  copreset

  if(no_rx_time <= 3663) no_rx_time++;   //120 seconds.

  process_data(_NEXT_TIMER_TICK_);


  if(mode == 100 && !(no_rx_time & 0x10) && (blink_character < 4))
  { blink_buffer = day_time_data[blink_character];
    day_time_data[blink_character] = (unsigned char *)extender;
	putcharacters();
	day_time_data[blink_character] = blink_buffer;
  }
  else if(blink_character && !blink_segments && !(no_rx_time & 0x10))
  { blink_buffer = data[blink_character];
    data[blink_character] = (unsigned char *)extender;
	putcharacters();
	data[blink_character] = blink_buffer;
  }
  else if(blink_character && !blink_segments && (no_rx_time & 0x10))
  { blink_buffer = data[blink_character];
    if((*data[blink_character]) == 0) data[blink_character] = (unsigned char *)(&font[0]);
	else
	 if((*data[blink_character]) == 10) data[blink_character] = (unsigned char *)(&font[10]);
	putcharacters();
	data[blink_character] = blink_buffer;
  }
  else if(blink_character && blink_segments && !(no_rx_time & 0x10))
  { blink_buffer = data[blink_character];       //keep address.
    blink_data = *blink_buffer;                 //init value.
	data[blink_character] = &blink_data;        //point to buffer.
    for( i=1 ; i<=8; i<<=1 )                    //correct data.
     if(blink_segments & i) blink_data &= ~i;   //make dark segments.
	putcharacters();
	data[blink_character] = blink_buffer;
  }
  else putcharacters();
}


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
	_rti,	/* RTI   */
	_start,	/* IRQ   */
	_start,	/* XIRQ  */
	_start,	/* SWI   */
	_start,	/* ILLOP */
	_start,	/* COP   */
	_start,	/* CLM   */
	_start  /* RESET */
};

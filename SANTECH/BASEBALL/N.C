//==10=23=1996======================
//  baseball - old board - no timer.
//==================================


/////////////////////////////////////////////////////////////////////
////board/distribution///////////////////////////////////////////////
// TO DO -> correct difinitions.

#define _FIRST_DIGIT_NUMBER_    1  // top board start digit number.
#define _MIDDLE_DIGIT_NUMBER_   1  // bottom board start digit number.
#define _LAST_DIGIT_NUMBER_    23

////end/board/distribution///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
const unsigned char dynamic_dim[]=
{ 'b' , //===============================
  0x44, //adjustable - low brightness.
  0xaa, //adjustable - middle brightness.
  0xff  //===============================
};
#define initialdim 1
#define copreset COPRST=0x55;COPRST=0xAA;if(SCSR&0x80)SCDR=dynamic_dim[dim];
#define horn_on  if(!mode){PORTA|=0x80;}
#define horn_off PORTA&=~0x80;

#include <hc11.h>

// common data.

#define _TIMER_ON_  0x80
unsigned char system_flag;

unsigned char mode;

const unsigned char font[]=
{ 0x5f,0x06,0x3b,0x2f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,
  0xdf,0x86,0xbb,0xaf,0xe6,0xed,0xfd,0x87,0xff,0xef
};
const unsigned char extender[]=
{ 0,1,3,7,0xf,0x1f,0x3f,0x7f,0xff
};

// global communication data area declarations.
unsigned char sci_input_buffer;         // buffer for insert of the entered data from sci.
int           sci_input_counter[2];     // counter of the same appearences.
unsigned char received;
unsigned char power_on_restarted;

// global display data.
const int nextdim[]=
{ 1,3,1,8,1,1,1,1,0
};
int           dim;
unsigned char *data[_LAST_DIGIT_NUMBER_+1];
unsigned char *day_time_data[4];
// data for blinking displays - correspondes to the state machine mode.
unsigned char blink_character, blink_segments;


//received symbol set.
enum
{ _timer_on,_1,_2,_3,_4,_5,_6,_7,_8,_9,_0,
  _clear,_enter,_home,_possession,_horn,_guest,
  _home_bonus,_game,_set,_guest_bonus,
  _home_fouls,_dim,_period,_guest_fouls,
  _player,_shot,_day,_empty,
  _1c, _1d, _1e, _timer_off
};

//time_out counter
unsigned no_rx_time;

//program data.
unsigned char buffer[4];


void initialization()
{ sci_input_buffer = 0;
  sci_input_counter[0] = 0;
  sci_input_counter[1] = PORTA & 6;

  received = 0;

  no_rx_time = 0;
  dim = initialdim;

  system_flag = 0;

  mode = mode == _day ? _day : 0;

  PACTL |= 0x88; // DDRA7 = 1   ==>  PA7, PA3 are output.
  PORTA |= 0x07; // horn off;  PA6,5,4,3 = 0.


  // SPI initialization.

  PORTD = 0x02;  // ss* - lo,  sck - lo,  mosi - lo.
  DDRD  = 0x3e;  // PD5,4,3 - outs.
  SPCR  = 0x54;  // spi - master.

  // init sci for receive.
  DDRD &= ~0x01;  // enable receive line.
  BAUD  =  0x33;  // baud rate is equal to 1200 bits per second.
  SCCR1 =  0x00;
  SCCR2 =  0x24;  // RIE,RE bits on.


  // timer interrupt initialization.

  PACTL |= 0x03;               // RTR1=RTR0=1 --> RTI each E/2**16 =   0.032768 sec.
  TMSK2 |= 0x43;               // RTII=1 --> RTI enable. ; clc = e/16

  // for display dynamic dimming mechanizm.
  SCCR2 |= 0x08;     // sci transmit enable

  // display_blinking mechanism;
  blink_character = blink_segments = 0;
}


void putcharacters()
{ int i, begining_digit;
  static unsigned char intermediate[_LAST_DIGIT_NUMBER_+1];
  unsigned char priznak, buffer;

  copreset
  begining_digit = PORTE & 8 ? _FIRST_DIGIT_NUMBER_ : _MIDDLE_DIGIT_NUMBER_;
  priznak = 0;

  for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
  { if(mode == _day || mode == 100)
    { if(i<4) buffer = dim ? *(day_time_data[i]) : 0;
	  else    buffer = 0;
	}
    else buffer = dim ? *(data[i]) : 0;
    if(intermediate[i] != buffer)
	{ intermediate[i] = buffer;
	  priznak = 1;
	}
  }

  if(priznak)
  { for(i = _LAST_DIGIT_NUMBER_; i >= begining_digit; i--)
    { SPDR = intermediate[i];
      while( !(SPSR & 0x80) )
	  { copreset
	  }
    }
	PORTD &= ~0x20;      // SS* - low.
    PORTD |=  0x20;      // SS* - high.
  }
}



void delay(unsigned int milliseconds)
{ copreset
  TOC1 = TCNT + 125*milliseconds ;
  TFLG1 = 0x80;
  while( !( TFLG1 & 0x80 ) )
  { copreset
  }
  TFLG1 = 0x80;
}

void proceed_dim()
{ copreset
  if( sci_input_buffer == _dim)
  { dim++;
    dim %= 4;
  }
}
// programma

//////////////////data*processing//////////////////////////

#define _NEXT_CHARACTER_   0
#define _NEXT_TIMER_TICK_  1
#define _INITIALIZATION_   2

/////////////////////////////////////////////////////////////////////////////////
///////procedures////////////////////////////////////////////////////////////////
// TO DO -> Enter procedure descriptions here.

void home_score(unsigned char flag)
{ static unsigned char score, score_10, score_1, buffer;

  copreset

  if(flag == _INITIALIZATION_)
  { score = 0;
    score_10 = 0;
    score_1 = font[0];
    data[5] = &score_10;
	data[6] = &score_1;
  }
  else if(flag == _NEXT_CHARACTER_)
  { if(!mode && sci_input_buffer == _home)
    { score = (score + 1 ) % 200;
      score_10 = score/10 ? font[score / 10] : 0;
	  score_1 = font[score % 20];
	}
	else if(!mode && sci_input_buffer == _set) mode = _set;
	else if(mode == _set && sci_input_buffer == _home)
	{ mode = _home;
	  blink_character = 6;
	  blink_segments = 0;
	  buffer = 0;
      score_10 = 0;
	  score_1 = font[0];
	}
	else if(mode == _home)
	{ if(sci_input_buffer == _clear)
	  { mode = 0;
	    blink_character = 0;
        score_10 = score/10 ? font[score / 10] : 0;
        score_1 = font[score % 20];
	  }
	  else if(sci_input_buffer == _enter)
	  { mode = 0;
	    blink_character = 0;
		score = buffer;
        score_10 = score/10 ? font[score / 10] : 0;
        score_1 = font[score % 20];
	  }
	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	    buffer += sci_input_buffer % 10;
	    score_10 = font[buffer / 10];
		score_1 = font[buffer % 10];
	  }
	}
  }
}


void guest_score(unsigned char flag)
{ static unsigned char score, score_10, score_1, buffer;

  copreset

  if(flag == _INITIALIZATION_)
  { score = 0;
    score_10 = 0;
    score_1 = font[0];
    data[7] = &score_10;
	data[8] = &score_1;
  }
  else if(flag == _NEXT_CHARACTER_)
  { if(!mode && sci_input_buffer == _guest)
    { score = (score + 1) % 200;
      score_10 = score/10 ? font[score / 10] : 0;
	  score_1 = font[score % 20];
	}
	else if(!mode && sci_input_buffer == _set) mode = _set;
	else if(mode == _set && sci_input_buffer == _guest)
	{ mode = _guest;
	  blink_character = 8;
	  blink_segments = 0;
	  buffer = 0;
      score_10 = 0;
	  score_1 = font[0];
	}
	else if(mode == _guest)
	{ if(sci_input_buffer == _clear)
	  { mode = 0;
	    blink_character = 0;
        score_10 = score/10 ? font[score / 10] : 0;
        score_1 = font[score % 20];
	  }
	  else if(sci_input_buffer == _enter)
	  { mode = 0;
	    blink_character = 0;
		score = buffer;
        score_10 = score/10 ? font[score / 10] : 0;
        score_1 = font[score % 20];
	  }
	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	  { buffer = (buffer%100)/10 ? 100+(buffer%10)*10 : (buffer%10)*10;
	    buffer += sci_input_buffer % 10;
	    score_10 = font[buffer / 10];
		score_1 = font[buffer % 10];
	  }
	}
  }
}

void period(unsigned char flag)
{ static unsigned char score, score_1, buffer;

  copreset

  if(flag == _INITIALIZATION_)
  { score = 0;
    score_1 = 0;
    data[1] = &score_1;
  }
  else if(flag == _NEXT_CHARACTER_)
  { if(!mode && sci_input_buffer == _period)
    { score = (score + 1) % 20;
      score_1 = score ? font[score] : 0;
	}
	else if(!mode && sci_input_buffer == _set) mode = _set;
	else if(mode == _set && sci_input_buffer == _period)
	{ mode = _period;
	  blink_character = 1;
	  blink_segments = 0;
	  buffer = 0;
      score_1 = font[0];
	}
	else if(mode == _period)
	{ if(sci_input_buffer == _clear)
	  { mode = 0;
	    blink_character = 0;
        score_1 = score ? font[score] : 0;
      }
	  else if(sci_input_buffer == _enter)
	  { mode = 0;
	    blink_character = 0;
		score = buffer;
        score_1 = score ? font[score] : 0;
	  }
	  else if(sci_input_buffer >= _1 && sci_input_buffer <= _0)
	  { buffer = buffer%10 ? 10+sci_input_buffer%10 : sci_input_buffer%10;
	    score_1 = font[buffer];
	  }
	}
  }
}

void bonus_possession(unsigned char flag) // ball_strike_out in baseball.
{ static unsigned char score, ball, strike, out, hit,
                       ball_1, strike_1, out_1, s_o_b, hit_1;

  copreset

  if(flag == _INITIALIZATION_)
  { ball = strike = out = score = hit = 0;
    ball_1 = strike_1 = out_1 = s_o_b = hit_1 = 0;

	data[3] = &ball_1;
	data[4] = &strike_1;
	data[2] = &out_1;
	data[9] = &hit_1;
	data[10] = &s_o_b;
  }
  else if(flag == _NEXT_CHARACTER_ && !mode)
  { if(sci_input_buffer == _player)
    { ball = (ball + 1) % 4;
	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	  ball_1 = ball ? font[ball] : 0;
	}
    else if(sci_input_buffer == _shot)
	{ strike = (strike + 1) % 3;
	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	  strike_1 = strike ? (strike_1 & 0x80) | font[strike] : strike_1 & 0x80;
	}
	else if(sci_input_buffer == _day)
	{ out = (out + 1) % 3;
	  s_o_b = extender[strike] | (extender[out] | (extender[ball] << 2)) << 2;
	  out_1 = out ? (out_1 & 0x80) | font[out] : out_1 & 0x80;
	}
	else if(sci_input_buffer == _empty)
	{ hit = (hit + 1) % 3;
	  hit_1 = extender[hit];
	}
  }
}



///////end/procedures////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

void test_segments()
{ unsigned char *data_buffer[_LAST_DIGIT_NUMBER_ + 1];
  unsigned char i,j;
  copreset

  if(!mode && sci_input_buffer == _set) mode = _set;
  else if(mode == _set && sci_input_buffer == _8) mode = _8;
  else if(mode == _8 && sci_input_buffer == _enter)
  { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data_buffer[i] = data[i];
    for(j = 0; j < 7; j++)
    { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)(extender+8);
      putcharacters();
	  for(i=0;i<3;i++) delay(500);
      for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	  putcharacters();
	  for(i=0;i<3;i++) delay(500);
    }
    for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = data_buffer[i];
	mode = 0;
  }

}


void day_time(unsigned char flag)
{ static unsigned char time[4];
  static float counter;
  static unsigned char buffer[4];
  static unsigned char h,hh,m,mm;

  unsigned char i;

  copreset

  if(flag == _INITIALIZATION_)
  { if(power_on_restarted)
    { time[0] = 0;
      time[1] = 1;
	  time[2] = 0;
	  time[3] = 0;
	  counter = 0.0;
	  power_on_restarted = 0;
	}
    day_time_data[0] = &hh;
	day_time_data[1] = &h;
	day_time_data[2] = &mm;
	day_time_data[3] = &m;
  }

  else if(flag == _NEXT_TIMER_TICK_)
  { if((counter+=0.032768) >= 60.0)
    { counter -= 60.0;
	  if((++time[3])>=10)
	  { time[3] = 0;
	    if((++time[2])>=6)
		{ time[2] = 0;
		  time[1]++;
		  if((time[0] && time[1]>=3) || (!time[0] && time[1]>=10))
		  { time[1] = 0;
		    if((++time[0])>=2)
			{ time[0] = 0;
			  time[1] = 1;
			}
		  }
		}
	  }
    }

	if(mode == _day)
	{ hh = time[0] ? font[1] : 0;
	  h  = font[time[1]];
	  mm = font[time[2]];
	  m  = font[time[3]];
    }
  }

  else if(flag == _NEXT_CHARACTER_)
  { if(!mode && sci_input_buffer == _day) mode = _day;
    else if((!mode || mode==_day) && sci_input_buffer == _set) mode = _set;
    else if(mode == _set && sci_input_buffer == _day)
	{ mode = 100;
	  hh = h = mm = m = font[0];
	  for(i=0;i<4;i++) buffer[i] = 0;
	  blink_character = 3;
	  blink_segments = 0;
	}
	else if(mode == 100)
	{ if(sci_input_buffer >= _1 && sci_input_buffer <=_0)
	  { for(i=0;i<3;i++) buffer[i]=buffer[i+1];
	    buffer[3] = sci_input_buffer%10;
	    hh = font[buffer[0]];
	    h  = font[buffer[1]];
	    mm = font[buffer[2]];
	    m =  font[buffer[3]];
	  }
	  else if(sci_input_buffer == _clear)
	  { blink_character = 0;
	    mode = _day;
	  }
	  else if(sci_input_buffer == _enter)
	  { blink_character = 0;
        for(i=0;i<4;i++) time[i] = buffer[i];
		mode = _day;
	  }
	}
    else if(mode == _day && sci_input_buffer == _game)  mode = 0;
  }
}


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


  home_score(flag);
  guest_score(flag);
  period(flag);
  bonus_possession(flag);


  ///end/cals////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////
  //timers.
  if(flag == _NEXT_CHARACTER_) test_segments();
  //day_time(flag);     // no timers for this baseball old type board.
  //game_time(flag);

  if(flag == _NEXT_CHARACTER_ && mode == _set &&
  (sci_input_buffer == _clear || sci_input_buffer == _enter))
  { copreset
    mode = 0;
    horn_off
  }
}


////////////////////////////////////////////////////////////

void main()
{ unsigned char i;                          // program data declarations.
  asm("	sei");
  copreset
  mode = 0;
  initialization();         // programm initialization.
  power_on_restarted = 0xff;

  asm(" cli");

  while(1)
  { for(i=0;i<=_LAST_DIGIT_NUMBER_;i++) data[i] = (unsigned char *)extender;
	while(no_rx_time >= 1831)
	{ copreset
	}
	process_data(_INITIALIZATION_);
    while(no_rx_time < 3663)
    { copreset
    }
  }
}



void datachange()
{ int i;
  copreset
  proceed_dim();
  if(sci_input_buffer != _dim) process_data(_NEXT_CHARACTER_);
}


void integrate()
{ copreset

  if( !received && sci_input_buffer != 255 && sci_input_buffer != 233 )
  { received = 1;
    no_rx_time = 0;
    datachange();
  }

  if( received && (sci_input_buffer == 255 || sci_input_buffer == 233))
  { received = 0;
    system_flag = sci_input_buffer == 255 ? system_flag | _TIMER_ON_ : system_flag & ~_TIMER_ON_;
	// for game timer condition.
  }
}





/////////////// communication interrupt /////////////////////
#pragma interrupt_handler _sci
void _sci()
{ unsigned char base = PORTA & 6;
  int i;

  copreset

  sci_input_buffer = SCSR;
  sci_input_buffer = SCDR;
  if((sci_input_counter[0] >= 7) || (sci_input_counter[1] >= 7 + base))
  { integrate();
    for(i=0;i<2;i++) sci_input_counter[i] = i ? base : 0;
  }
  else
   for(i=0;i<2;i++)
    if(sci_input_counter[i] == sci_input_buffer) sci_input_counter[i]++;
    else sci_input_counter[i] = i ? base : 0;
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


//////////////// interrupt table ///////////////////
extern void _start();   /* entry point in crt11.s */
#pragma data:interrupt_vectors
static void (*interrupt_vectors[])() =
{ _sci,           /* SCI */
  _start,         /* SPI */
  _start,         /* PAIE */
  _start,         /* PAO */
  _start,         /* TOF */
  _start,         /* TOC5 */
  _start,         /* TOC4 */
  _start,         /* TOC3 */
  _start,         /* TOC2 */
  _start,         /* TOC1 */
  _start,         /* TIC3 */
  _start,         /* TIC2 */
  _start,         /* TIC1 */
  _rti,           /* RTI */
  _start,         /* IRQ */
  _start,         /* XIRQ */
  _start,         /* SWI */
  _start,         /* ILLOP */
  _start,         /* COP */
  _start,         /* CLM */
  _start          /* RESET */
};


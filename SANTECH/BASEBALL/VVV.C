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

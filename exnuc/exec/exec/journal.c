#if defined(ENV5)

#define TRUE 1

#include <tools.h>
#include <stdio.h>
#include <fcntl.h>
#include <journal.h>

static int JNL_echo_read_event;
static int JNL_echo_last_event;
static FILE *JNL_record = 0;
static FILE *JNL_echo = 0;
static int JNL_rec_windows[MAX_WINDOW];
static int JNL_valid_window[MAX_WINDOW];
static int timer_flag = 0;
static int playback_time = 0;
static char *key_buffer;
static int key_buffer_count;

static struct jnl_timers jnl_timer_no[TIMER_MAX_COUNT];
static int JNL_message_strip[2];
static int JNL_message_strip_count = 0;

int JNL_init_journal(filename,excl_flag)
char *filename;
int excl_flag;
{
int flag;
int i;
int jnlopen;



flag = O_WRONLY | O_CREAT | O_TRUNC;
if ( excl_flag )
  {
   flag = flag | O_EXCL;
  }

JNL_echo_read_event = 0;
JNL_echo_last_event = 0;
JNL_record = 0;
jnlopen = open(filename, flag, 0660);
if ( jnlopen != -1 )
  {
  JNL_record = (FILE *)fdopen(jnlopen, "w+");
  JNL_record_input(4, (char *) &flag);/*newly created not modified file*/
  for ( i = 0 ; i < TIMER_MAX_COUNT ; i++ )
    {
    jnl_timer_no[i].used = 0;
    jnl_timer_no[i].previous = 0;
    }
  for ( i = 0 ; i < MAX_WINDOW ; i++ )
   {
    JNL_valid_window[i] = 0;
   }
  return(1);
  }
else 
  {
  return(0);
  }
}

int JNL_init_playback(filename,runname)
char *filename;
char *runname;
{
int flag;
int type,nbytes;

JNL_echo = fopen(filename, ("r"));
/*strip off header info*/
flag = 0;
if ( JNL_echo )
 {
 JNL_echo_input ( 4, (char *) &flag );
 JNL_echo_input(4, (char *) &type);/*type info event*/
 JNL_echo_input(4, (char *) &type);/*type JNL_CHAR*/
 JNL_echo_input(4, (char *) &nbytes);
 JNL_echo_input(nbytes,runname);
 runname[nbytes] = 0;
 }
return((int) JNL_echo);
}


int JNL_echo_read_event_func()
{	
int status;

status = 0;
if ( JNL_echo_read_event )
 {
  status = 1;
 }
return ( status );
}

int JNL_record_new_window( window )
int window;
{
int type;
int old_window;
int done;

if (JNL_echo)
 {
 done = 0;
 while ( !done )
  {
   JNL_echo_input(4, (char *) &type);/*user event*/
   if ( type < 0 )
    {
    JNL_process_del_info_event();
    }
   else
    {
    done = JNL_process_info_event(window);
    JNL_echo_read_event = 0;/*ready to read next event*/
    }
   }
 }/*end if echo*/

if ( JNL_record )
 {
  if (( window >= 0 ) && ( window < MAX_WINDOW ))
   {
   JNL_valid_window[window] = 1;
   }
  old_window = window;  
  JNL_record_info_event(JNL_WINDOW_CHANGE, 0, 
                                  &old_window);
 }
else
 {
 /*if you get here you have a message strip window save it*/
 if (JNL_message_strip_count == 1)
  {
   JNL_message_strip[JNL_message_strip_count -1] = window;
   JNL_message_strip_count++;
  }
 else if (JNL_message_strip_count == 2)
  {
   JNL_message_strip[JNL_message_strip_count -1] = window;
   JNL_message_strip_count++;
  }
 else
  JNL_message_strip_count++;
 }
return(1);
}



int JNL_echo_event(mask,  event )
int mask;
int *event;
{
int type;	
int done;
int status;
char dummy[JNL_MAX_CHAR];

JNL_process_slow_echo();	
/*JNL_echo_read_event = 0 says the event was used get next
  on next call to echo_event,  =1 use last event*/
status = 0;
if ( JNL_echo )
{
done = 0;
while ( !done )
  {
  if ( !JNL_echo_read_event )
   {
    status = JNL_echo_input(4, (char *) event);
    if ( !status ) 
     {
      /*you have data is this a deleted event*/
      if ( *event < 0 )
       {
	done = 1;
	if ( !mask )
	 {
          Inq_events( event);
         }
        else
         {
         Wait_for_next(mask, event);
         }	
        fclose(JNL_echo);
        JNL_echo = 0;            
    }/*end if deleted event*/
   else if ( *event == JNL_INFO_EVENT )
    {
	 JNL_echo_input ( 4, (char *) &type );
	 if ( type == JNL_WINDOW_CHANGE )
	  {
	   /*this info must be read when record_new_window called*/
           JNL_adjust_echo();/*back up 4 bytes*/
           JNL_adjust_echo();/*back up 4 bytes*/
           *event = 0;
           done = 1;
      }
	 else if ( type == JNL_TIMER_NO )
	  {
	   /*this info must be read when record_new_window called*/
           JNL_adjust_echo();/*back up 4 bytes*/
           JNL_adjust_echo();/*back up 4 bytes*/
           *event = 0;
           done = 1;
          }
         else
          {
     	  /*just character data*/
          JNL_adjust_echo();/*back up 4 bytes to type*/	
          JNL_process_info_event(dummy);
          }
         }
      else
         {
	    done = 1;
	    JNL_echo_last_event = *event;/*save for next call possibly*/
	    JNL_echo_read_event = 1;/*won't read again until event read*/
         }     
       }
   else
       {/*eof*/
	done = 1;
	if ( !mask )
	 {
          Inq_events( event);
         }
        else
         {
         Wait_for_next(mask, event);
         }
       }
    }/*not time for new read event yet*/
   else
    {
    *event = JNL_echo_last_event;
    done = 1;
    }
 }/*end while*/
}/*end if JNL_echo*/
else
{
 if ( !mask )
   {
   Inq_events( event);
   }
   else
   {
   Wait_for_next(mask, event);
   }
}
return( status );
}


int JNL_process_info_event(new_window)
int new_window;
{
int type;
int window;
int nbytes;
char string[JNL_MAX_CHAR];
int status;

status = 1;
if (JNL_echo)
 {
  JNL_echo_input(4, (char *) &type);
  if ( type == JNL_WINDOW_CHANGE )
   {
    JNL_echo_input(4, (char *) &window);
    JNL_rec_windows[window] = new_window;
    status = 1;/*looking for window event, found it*/
   }
  else if ( type == JNL_CHAR )
   {
    JNL_echo_input(4, (char *) &nbytes);
    if ( nbytes)
       {
        JNL_echo_input(nbytes, string);
       }
    status = 0;/*if looking for window not it*/
   }
 }
return(status);
}

int JNL_process_del_info_event()
{
int type;
int window;
int nbytes;
char string[JNL_MAX_CHAR];

if (JNL_echo)
 {
  JNL_echo_input(4, (char *) &type);
  if ( type == JNL_WINDOW_CHANGE )
   {
    JNL_echo_input(4, (char *) &window);
   }
  else if ( type == JNL_CHAR )
   {
    JNL_echo_input(4, (char *) &nbytes);
    if ( nbytes)
       {
        JNL_echo_input(nbytes, string);
       }
   }
 }
return(1);
}


/*format of user event
int event = 0x7fffffff
type = 0 initial record of file
int type CHAR then #bytes and string
if type = JNL_CHANGE_WINDOW else window number 
*/

int JNL_record_info_event(type, event_nbytes, string)
int type;
int event_nbytes;
char *string;
{
int atype;
int abytes;
int event;

event = JNL_INFO_EVENT;
atype = type;
abytes = event_nbytes;

if ( JNL_record )
{
  JNL_record_input(4, (char *) &event); 
  JNL_record_input(4, (char *) &atype);

  if (( type == JNL_WINDOW_CHANGE) || (type == JNL_STOPSIGN))
   {
   /*if it is JNL_STOPSIGN we need to record number of buffer put out */
   JNL_record_input( 4, string );/*for menu type just store window#*/
   }
  else if ( type == JNL_CHAR ) 
   {
    JNL_record_input(4, (char *) &abytes);/*for all other user events store string*/
    if ( event_nbytes )
     {
     JNL_record_input(event_nbytes, string);
     }
   }
}
return(1);
}

int JNL_record_event( event)
int event;
{
   int aevent;

    if ( JNL_record )
    {
        aevent = event;	
        JNL_record_input(4, (char *) &aevent); 
    }
    return(1);
}

int JNL_close_jnl()
{
 if(JNL_record)
 {
    fclose(JNL_record);/*close journal file*/
    JNL_record = 0;
 }
 return(1);
}

int JNL_close_jnl_pbk()
{
int i;
 if(JNL_record)
 {
   for ( i = 0 ; i < MAX_WINDOW ; i++ )
   {
    JNL_valid_window[i] = 0;
   }

    fclose(JNL_record);/*close journal file*/
    JNL_record = 0;	
 } 
 if (JNL_echo)
 {
   fclose(JNL_echo);
   JNL_echo = 0;
 }
return(1);
}


int JNL_close_echo()
{
 if (JNL_echo)
 {
     fclose(JNL_echo);
     JNL_echo = 0;
 }
return(1);
}

int JNL_record_input(  nbytes, buffer )
int nbytes;
char *buffer;
{
    int status;
    if (JNL_record)
    {
      status = 0;
      status = fwrite(buffer, nbytes, 1, JNL_record);
      status = fflush(JNL_record);
    }
    return(1);
}


int JNL_echo_input(nbytes, buffer )
int nbytes;
char *buffer;
{
    int status;
    
    status = 0;
    if (JNL_echo)
    {
       status = fread(buffer, nbytes, 1, JNL_echo);   
       if ( !status )
        {
	status = 1;/*eof retruns 1 because tools returns 0 for good*/
	                        /*hardware input*/
        JNL_echo = 0;
        fclose(JNL_echo);
        }
       else
        {
        status = 0;/*status = 0 have an event*/
        }
    }
    return(status);
}

int JNL_adjust_echo()
{
    int status;
    status = 1;
    if (JNL_echo)
    {
       status = fseek(JNL_echo, -4, 1);
    }
    return(status);
}

int JNL_adjust_echo_button()
{
int status;
int nbytes;

nbytes = - ( sizeof (struct echo_button));
status = 1;
/*number bytes in button*/
    if (JNL_echo)
    {
       status = fseek(JNL_echo,nbytes, 1);
    }
    return(status);
}

int JNL_adjust_echo_refresh_button()
{
int status;
int nbytes;

nbytes = - ( sizeof (struct echo_refresh_button));
status = 1;
/*number bytes in button*/
    if (JNL_echo)
    {
       status = fseek(JNL_echo,nbytes, 1);
    }
    return(status);
}

int JNL_adjust_echo_collapse_button()
{
int status;
int nbytes;

nbytes = - ( sizeof (struct echo_collapse_button));
status = 1;
/*number bytes in button*/
    if (JNL_echo)
    {
       status = fseek(JNL_echo,nbytes, 1);
    }
    return(status);
}

int JNL_adjust_delete_button()
{
int status;
int nbytes;

nbytes = - ( sizeof (struct echo_delete_button));
status = 1;
/*number bytes in button*/
    if (JNL_echo)
    {
       status = fseek(JNL_echo,nbytes, 1);
    }
    return(status);
}

int JNL_wait_for_next(mask, event)
int mask;
int *event;
{

    int done;
    int status;

    status = 0;
    done = 0;
    if (JNL_echo)
    {
      status = JNL_echo_event(mask,  event);
    }/*end if echo*/
    else
    {
        Wait_for_next(mask, event);
    }

return(status);
}


int JNL_inq_events(event)
int *event;
{
int mask;
int status;

status = 0;
mask = 0;
    if (JNL_echo)
    {
    status = JNL_echo_event(mask,  event );
    }/*end if echo*/
    else
    {
     status = Inq_events( event);
    }    
    return( status );
}

int JNL_inq_button_data(window, x, y, btype, state, timetag)
int *window;
int *x;
int *y;
int *btype;
int *state;
int *timetag;
{
 int status;
 struct echo_button button;
 
 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof(struct echo_button), (char *) &button);
     JNL_adjust_echo_button();
     JNL_oldwindow_to_window(button.window, window);
     *x = button.x;
     *y = button.y;
     *state = button.state;
     *btype = button.btype;
     *timetag = button.timetag;
    }
  else
    {
     status = Inq_button_data(window,x,y,btype,state,timetag); 
    }
return(status);
}

int JNL_get_button_data(window, x, y, btype, state, timetag)
int *window;
int *x;
int *y;
int *btype;
int *state;
int *timetag;
{
 struct echo_button button;
 int status;
 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_button), (char *) &button);
     JNL_echo_read_event = 0;/*ready to read next event*/
     JNL_oldwindow_to_window( button.window, window);
     *x = button.x;
     *y = button.y;
     *state = button.state;
     *btype = button.btype;
     *timetag = button.timetag;

    }
  else
    {/*not echoing*/
     status = Get_button_data(window,x,y,btype,state,timetag);
    }
 if (JNL_record && (!status) && ( *window != JNL_message_strip[0] )
                      && (*window != JNL_message_strip[1] ) )
 { 
  JNL_record_event(BUTTON_EVENT);

     button.window = *window;
     button.x = *x;
     button.y = *y;
     button.state = *state;
     button.btype = *btype;
     button.timetag = *timetag;

     JNL_record_input( sizeof (struct echo_button), (char *) &button); 
 }
 return(status);
}



int JNL_process_slow_echo()
{

int event;
int window;
int x;
int y;
int btype;
int state;
int timetag;
int status;
int done;
int key_char;
int count;

static int slowpbk = 0;

if ( slowpbk )
   {
   Wait_for_next( BUTTON_EVENT, &event);	
   if ( event & BUTTON_EVENT )
    {
    status = Get_button_data(&window,&x,&y,&btype,&state,&timetag);
    if ( btype == RIGHT_BUTTON )
      {
       if ( slowpbk )
        {
        /*reset true stop slow playback*/
        slowpbk = 0;
        }
      }
    else if ( btype == LEFT_BUTTON )
      {
        /*turn off playback*/
        JNL_echo = 0;
      }
    }
  }/*end if slowpbk true*/


 Inq_events( &event);
  if ( event & BUTTON_EVENT )
   {
   status = Get_button_data(&window,&x,&y,&btype,&state,&timetag);
   if ( btype == RIGHT_BUTTON )
      {
        slowpbk = 1;
      }
   else if ( btype == LEFT_BUTTON )
      {
        /*turn off playback*/
        JNL_echo = 0;
      }
    }
  else if ( event & KEYBOARD_EVENT )
    {

    done = 0;
    while ( !done )
     {
       Inq_events( &event);
       if ( event & KEYBOARD_EVENT )
         {
         Set_keyboard_buffer(&key_char, 1);		
         Get_keyboard_data(&count);
         if ( ( unsigned char )key_char == 0x85 )
           {
           /*up arrow speed it up*/
           playback_time = playback_time - 3;
           if ( playback_time < 0 )
              {
               playback_time = 0;
               done = 0;
              }
            }/*end if up arrow*/
         else if ( ( unsigned char )key_char == 0x83 )
            {
             /*down arrow slow it down*/
             playback_time = playback_time + 3;
             if ( playback_time > 100 )
               {
               playback_time = 100;
               done = 1;
               }
            }/*end down arrow*/

          }/*end if keyboard event inside inq*/
        else
          {
           done = 1;
          }/*no more key events*/
       Set_keyboard_buffer( key_buffer, 1);
      }/*end if key event*/
    }/*end if event*/

 if (( playback_time ) && ( !slowpbk ))
     {
     Wait_timer(playback_time);
     }

return(1);
}

JNL_oldwindow_to_window(oldwindow, window)
int oldwindow;
int *window;
{

    if ( oldwindow <= 0 )
      {
      *window = oldwindow;
      }
    else
      {
      *window = JNL_rec_windows[oldwindow];
      }
return(1);
}


int JNL_get_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, 
                                       ay2, opmask)
int *window;
int *vs_no;
int *x;
int *y;
int *x2;
int *y2;
int *ax1;
int *ay1;
int *ax2;
int *ay2;
int *opmask;
{

 struct echo_refresh_button button;
 int status,index;
 
 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_refresh_button), (char *) &button);
     JNL_echo_read_event = 0;/*ready to read next event*/
     JNL_oldwindow_to_window( button.window, window);
     *x = button.x;
     *y = button.y;
     *vs_no = button.vs_no;
     *x2 = button.x2;
     *y2 = button.y2;
     *ax1 = button.ax1;
     *ay1 = button.ay1;
     *ax2 = button.ax2;
     *ay2 = button.ay2;
     *opmask = button.opmask;
     /*modify*/
     Modify_win(*window, *x, *y, *x2, *y2);
     }
  else
    {/*not echoing*/
     status = Get_refresh_area_data(window,vs_no, x,y,x2, y2, 
                               ax1, ay1, ax2, ay2, opmask);
    }
 index = *window;
 if (JNL_record && (!status) && ( *window != JNL_message_strip[0] )
                      && (*window != JNL_message_strip[1] ) )
 { 
  
  if ( index >= 0  &&  index < MAX_WINDOW  && 
                           JNL_valid_window[index] != 0 )
  {

  JNL_record_event(REFRESH_EVENT);

     button.window = *window;
     button.vs_no = *vs_no;
     button.x = *x;
     button.y = *y;
     button.x2 = *x2;
     button.y2 = *y2;
     button.ax1 = *ax1;
     button.ay1 = *ay1;
     button.ax2 = *ax2;
     button.ay2 = *ay2;
     button.opmask = *opmask;

     JNL_record_input( sizeof (struct echo_refresh_button), (char *) &button); 
 }
}
 return(status);
}


int JNL_inq_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, 
                                       ay2, opmask)
int *window;
int *vs_no;
int *x;
int *y;
int *x2;
int *y2;
int *ax1;
int *ay1;
int *ax2;
int *ay2;
int *opmask;
{

 struct echo_refresh_button button;
 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_refresh_button), (char *) &button);
     JNL_adjust_echo_refresh_button();
     JNL_oldwindow_to_window( button.window, window);
     *x = button.x;
     *y = button.y;
     *vs_no = button.vs_no;
     *x2 = button.x2;
     *y2 = button.y2;
     *ax1 = button.ax1;
     *ay1 = button.ay1;
     *ax2 = button.ax2;
     *ay2 = button.ay2;
     *opmask = button.opmask;

     }
  else
    {/*not echoing*/
     status = Inq_refresh_area_data(window,vs_no, x,y,x2, y2, 
                               ax1, ay1, ax2, ay2, opmask);
    }

 return(status);
}

int JNL_get_collapse_data(window, opmask)
int *window;
int *opmask;
{

 struct echo_collapse_button button;
 int status;
 int x, y;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_collapse_button), (char *) &button);
     JNL_echo_read_event = 0;/*ready to read next event*/
     JNL_oldwindow_to_window( button.window, window);
     *opmask = button.opmask;
     if ( *opmask )
       {
       Inq_win_collapse_org(*window, &x, &y);
       Collapse_win(*window, x, y );
       }
      else
       {
       Uncollapse_win(*window);
       }
   }
 else
    {/*not echoing*/
     status = Get_collapse_data(window, opmask);
    }
 if (JNL_record && (!status) && ( *window != JNL_message_strip[0] )
                      && (*window != JNL_message_strip[1] ) )
  { 
  JNL_record_event(COLLAPSE_EVENT);
  button.window = *window;
  button.opmask = *opmask;

  JNL_record_input( sizeof (struct echo_collapse_button), 
                                  (char *) &button); 
  }
 return(status);
}

int JNL_inq_collapse_data(window, opmask)
int *window;
int *opmask;
{

 struct echo_collapse_button button;
 int status;
 
 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_collapse_button), (char *) &button);
     JNL_adjust_echo_collapse_button();
     JNL_oldwindow_to_window( button.window, window);
     *opmask = button.opmask;
   }
 else
    {/*not echoing*/
     Inq_collapse_data(window, opmask);
    }

 return(status);
}

int JNL_get_delete_data(window)
int *window;
{

 struct echo_delete_button button;
 int status;
 int index;
 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_delete_button), (char *) &button);
     JNL_echo_read_event = 0;/*ready to read next event*/
     JNL_oldwindow_to_window( button.window, window);
     Delete_win(*window);
   }
 else
    {/*not echoing*/
     status = Get_delete_data(window);
    }
 if (JNL_record && (!status) && ( *window != JNL_message_strip[0] )
                      && (*window != JNL_message_strip[1] ) )
  { 
   index = *window;
   if ( index >= 0  &&  index < MAX_WINDOW  )
    {
    JNL_valid_window[index] = 0;
    }
  JNL_record_event(DELETE_EVENT);
  button.window = *window;
  JNL_record_input( sizeof (struct echo_delete_button), 
                                  (char *) &button); 
  }
 return(status);
}

int JNL_inq_delete_data(window)
int *window;
{

 struct echo_delete_button button;
 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (struct echo_delete_button), (char *) &button);
     JNL_adjust_delete_button();
     JNL_oldwindow_to_window( button.window, window);
   }
 else
    {/*not echoing*/
     status = Inq_delete_data(window);
    }

 return(status);
}

int JNL_inq_user_data(user_data)
int *user_data;
{


 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (int), (char *) user_data);
     fseek(JNL_echo,-4, 1);
   }
 else
    {/*not echoing*/
     status = Inq_user_data(user_data);
    }

 return(status);
}

int JNL_get_user_data(user_data)
int *user_data;
{


 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (int), (char *) user_data);
     JNL_echo_read_event = 0;/*ready to read next event*/
   }
 else
    {/*not echoing*/
     status = Get_user_data(user_data);
    }
  if (JNL_record && (!status))
  { 
  JNL_record_event(USER_EVENT);
  JNL_record_input( sizeof (int), (char *) user_data); 
  }
 return(status);
}

int JNL_inq_win_user_icon_data(window, icon_id)
int *window;
int *icon_id;
{

 int oldwindow;
 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (int), (char *) &oldwindow);
     JNL_echo_input(sizeof (int), (char *) icon_id);
     status = fseek(JNL_echo,-8, 1);
     JNL_oldwindow_to_window( oldwindow, window);
   }
 else
    {/*not echoing*/
     status = Inq_win_user_icon_data(window, icon_id);
    }

 return(status);
}

int JNL_get_win_user_icon_data(window, icon_id)
int *window;
int *icon_id;
{

 int oldwindow;
 int status;

 status = 0;
 if (JNL_echo)
   {
     JNL_echo_input(sizeof (int), (char *) &oldwindow);
     JNL_echo_input(sizeof (int), (char *) icon_id);
     JNL_oldwindow_to_window( oldwindow, window);
     JNL_echo_read_event = 0;/*ready to read next event*/
   }
 else
    {/*not echoing*/
     status = Get_win_user_icon_data(window, icon_id);
    }
if (JNL_record && (!status))
  { 
  JNL_record_event(WINDOW_USER_ICON_EVENT);
  JNL_record_input( sizeof (int), (char *) window); 
  JNL_record_input( sizeof (int), (char *) icon_id); 
  }
 return(status);
}

int JNL_start_timer ( delta_time, repeatflag, timer_no )
int delta_time;
int repeatflag;
int *timer_no;
{
int status,status1;
int event;
int type;
int i;
int done;
int have_timer_slot;
int dummy = 0;

status = Start_timer(delta_time, repeatflag, timer_no);

if ( !status)
{
have_timer_slot = 0;
if ( JNL_echo )
 {
 for ( i = 0 ; i < TIMER_MAX_COUNT ; i++ )
   {
   if (( !jnl_timer_no[i].used ) && !(have_timer_slot))
    {
    jnl_timer_no[i].used = 1;	
    jnl_timer_no[i].current = *timer_no;	
    /*may have info events throw them away*/
    done = 0;
    while ( !done )
     {
     status1 = JNL_echo_input(4, (char *) &event);/*user data*/
     if ( !status1 ) 
      {
      /*you have data is this a deleted event*/
      if ( event < 0 )
       {
 	   done = 1;
       fclose(JNL_echo);
       JNL_echo = 0;            
       }/*end if deleted event*/
      else if ( event == JNL_INFO_EVENT )
        {
	    JNL_echo_input ( 4, (char *) &type );
	    if ( type == JNL_TIMER_NO )
	      {
          JNL_echo_input(4,  (char *) &jnl_timer_no[i].previous );
          done = 1;
          }
         else
          {
   	      /*just character data*/
          JNL_adjust_echo();/*back up 4 bytes*/	
          JNL_process_info_event(dummy);
          }
         }
       }
     else
       {/*eof*/
  	   done = 1;
       }
   }/*end while*/
  have_timer_slot = TRUE;
  }/*end if slot available*/
 }/*end for*/
}/*end if echo*/
}
if (JNL_record && (!status))
 {
 type = JNL_TIMER_NO;
 JNL_record_event ( JNL_INFO_EVENT );
 JNL_record_input ( 4, (char *) &type );
 JNL_record_input ( 4, (char *) timer_no);
 }
return(status);
}

int JNL_stop_timer(timer_no)
int timer_no;
{
int status;
int i;

status = Stop_timer(timer_no);
for ( i = 0 ; i < TIMER_MAX_COUNT ; i++ )
 {
 if ( jnl_timer_no[i].used )
  {
  if ( timer_no == jnl_timer_no[i].current )
   {
    jnl_timer_no[i].current = 0;
    jnl_timer_no[i].previous = 0;
    jnl_timer_no[i].used = 0;
   }
  }/*end if used*/
 }
return ( status );
}

int JNL_get_timer_data(timer_no)
int *timer_no;
{
int status;

status = JNL_echo_timer_data(timer_no);
JNL_record_timer_data(timer_no);
return(status);

}


int JNL_echo_timer_data(timer_no)
int *timer_no;
{
int status;
int i;

status = 0;
if (JNL_echo)
 {
  JNL_echo_input(4, (char *) timer_no);
  JNL_echo_read_event = 0;/*ready to read next event*/
  for ( i = 0 ; i < TIMER_MAX_COUNT ; i++ )
   {
   if ( jnl_timer_no[i].used )
    {
     if ( *timer_no == jnl_timer_no[i].previous)
      {
       *timer_no = jnl_timer_no[i].current;
      }
     }/*end if used*/
   }/*end for*/
 }
else 
 {
  status = Get_timer_data(timer_no);
 }
return(status);

}

int JNL_record_timer_data(timer_no)
int *timer_no;
{
int event;	
if (JNL_record)
 {
 event = (TIMER_EVENT);
 JNL_record_input(4, (char *) &event);
 JNL_record_input(4, (char *) timer_no);
 }
return(1);
}

int JNL_set_keyboard_buffer ( buffer, count )
char *buffer;
int count;
{
int status;

key_buffer_count = count;
key_buffer = buffer;
status = Set_keyboard_buffer ( buffer, count );
return(status);
}

int JNL_get_keyboard_data( count)
int *count;
{
int status;

status = 0;
if (JNL_echo)
    {
      *count = 0;	
      JNL_echo_input ( 1, (char *) count );
      JNL_echo_input( *count, (char *) key_buffer);/*input from file*/
      JNL_echo_read_event = 0;/*ready to read next event*/
    }
else
    {
     status = Get_keyboard_data(count);
    }

if ( JNL_record  && (!status))
    {
    JNL_record_event ( KEYBOARD_EVENT );
    JNL_record_input ( 1, (char *) count );
    JNL_record_input ( *count, (char *) key_buffer );        
    }
return(status);
}

int JNL_inq_keyboard_data( count)
int *count;
{
int status;

status = 0;
if (JNL_echo)
    {
      *count = 0;	
      JNL_echo_input ( 1, (char *) count );	
      JNL_echo_input(*count, (char *) key_buffer);/*input from file*/
      fseek(JNL_echo, -( *count + 1 ) , 1);/*+1 for #bytes*/
    }
else
    {
     status = Inq_keyboard_data(count);
    }


return(status);
}

int JNL_inq_keyboard_buffer( buf_addr,  count)
char *buf_addr[];
int *count;
{
int status;

status = 0;
if (JNL_echo)
    {
      *count = 0;		
      JNL_echo_input ( 1, (char *) count );		
      JNL_echo_input(*count, (char *) key_buffer);/*input from file*/
      buf_addr = &key_buffer;
      fseek(JNL_echo, -(*count), 1);
    }
else
    {
     status = Inq_keyboard_buffer(buf_addr, count);
    }

return(status);
}

int JNL_set_timer_playback(mytime)
int mytime;
{
timer_flag = 1;
playback_time = mytime;
return(1);
}


int JNL_playback()
{	
int status;

status = 0;
if ( JNL_echo )
 {
  status = 1;
 }
return ( status );
}


int JNL_journal()
{	
int status;
status = 0;
if ( JNL_record )
 {
 status = 1;
 }
return ( status );
}


/* this function can operate in both X and ENV5 environments */
int JNL_adjust_journal_button()
{
  int status;
  int nbytes;

  /* number bytes in journal event */

  nbytes = - (sizeof (struct echo_button));

  status = 1;
  if (JNL_record)
  {
    status = fseek(JNL_record,nbytes, 1);
  }
  return(status);
}


#elif defined(X11)
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Intrinsic.h>
#include <X11/Xproto.h>
#include <FI.h>
#include <stdio.h>
#include <fcntl.h>
#include <journal.h>
#include <wl.h>

#define MAX_WINDOW 40
#define JNL_MAX_WINDOW 200
#define TRUE 1
FILE *JNL_record;
FILE *JNL_echo;
Window JNL_rec_new_windows[JNL_MAX_WINDOW];
int window_do_configure_flag[JNL_MAX_WINDOW];
Window JNL_rec_old_windows[JNL_MAX_WINDOW];
Window hw_wn_no;
Window runtime_forms[3];
int window_counter = 0;
int time_to_save_panel = 0;
int time_to_save_bar = 0;
Window copyright_window = 0;
Window message_strip = 0;
int jnl_warning;


extern Display *EXdisplay;

extern char *getenv();

/*
 * Defining this variable to hold failed requests.
 * The error handler will set them. This can be looked into in
 * the program and corresplnding actions can be taken.
 * TR 119528628 . A sort of kludge.
 */

int ErrorHandler();

unsigned long error_code = 0;


#if defined( CLIX ) && defined( X11 )
extern  int INGR_DigButtonPress;
extern  int INGR_DigButtonRelease;
extern  int INGR_DevButtonPress;
extern  int INGR_DevButtonRelease;
extern  int INGR_DevButtonPress_class;
extern  int INGR_DevButtonRelease_class;

#endif
int JNL_init_journal(filename,excl_flag)
char *filename;
int excl_flag;
{
int flag;
int jnlopen;
char *jnlwarning;

JNL_clear_windows();

flag = O_RDWR | O_CREAT | O_TRUNC;
if ( excl_flag )
  {
   flag = flag | O_EXCL;
  }

JNL_record = 0;
jnlopen = open(filename, flag, 0660);
if ( jnlopen != -1 )
  {
  jnl_warning = 0;
  if ((jnlwarning=getenv("JNL_WARNING")) && atoi(jnlwarning))
               jnl_warning = 1;
  JNL_record = (FILE *)fdopen(jnlopen, "w+");
  JNL_record_input(4, (char *) &flag);/*newly created not modified file*/
  return(1);
  }
else 
  {
  return(0);
  }
}

int JNL_init_playback(filename,runname)
char *filename;
char *runname;
{
int flag;
XEvent xevent;

JNL_echo = fopen(filename, ("r"));
/*strip off header info*/
flag = 0;
if ( JNL_echo )
 {
 JNL_echo_input ( 4, (char *) &flag );
 JNL_echo_input(sizeof (XEvent), &xevent);/*user event*/
 JNL_echo_input(xevent.xbutton.x,runname);
 runname[xevent.xbutton.x] = 0;
 }
return((int) JNL_echo);
}

int JNL_XPending( display )
Display *display;
{
int status;
status = 1;

if ( !JNL_echo )
 {
 status = XPending(display);
 }

return(status);
}

JNL_save_panel()
{
time_to_save_panel = 1;
return (1);
}

JNL_save_bar()
{
time_to_save_bar = 1;
return (1);
}

int JNL_playback()
{	
int status;

status = 0;
if ( JNL_echo )
 {
  status = 1;
 }
return ( status );
}

int JNL_journal()
{	
int status;

status = 0;
if ( JNL_record )
 {
  status = 1;
 }
return ( status );
}

JNL_XCreateWindow ( display,parent,x,y,width,height,border_width,
                            depth,class,visual,valuemask,attributes)
Display *display;
Window parent;
int x,y;
unsigned int width,height;
unsigned int border_width;
int depth;
unsigned int class;
Visual *visual;
unsigned long valuemask;
XSetWindowAttributes *attributes;
{

hw_wn_no = XCreateWindow ( display,parent,x,y,width,height,border_width,
                            depth,class,visual,valuemask,attributes);
if (!copyright_window)
   copyright_window = hw_wn_no;

window_counter++;
/*if this is the initial time through we must hold onto these window
  in case we have a save they will have to be written to the file first*/
if ( window_counter == 2 )message_strip = hw_wn_no;/*message strip*/
if ( window_counter == 3 )runtime_forms[0] = hw_wn_no;/*bar menu*/
if ( window_counter == 4 )runtime_forms[1] = hw_wn_no;/*panel menu*/
if ( window_counter == 5 )runtime_forms[2] = hw_wn_no;/*pocket menu*/
if ( time_to_save_panel )
   {
   runtime_forms[1] = hw_wn_no;/*a save was just picked*/
   time_to_save_panel = 0;
   }

if ( time_to_save_bar )
   {
   runtime_forms[0] = hw_wn_no;/*a save was just picked*/
   time_to_save_bar = 0;
   }

if (JNL_record)
 {
  JNL_record_new_window (hw_wn_no);
 }
return(hw_wn_no);
}

JNL_record_runtime_forms()
{
int i;
if ( JNL_record )
 {
  for ( i = 0 ; i < 3 ; i++ )
   {
   JNL_record_info_event(JNL_WINDOW_CHANGE, 0, 
                                  runtime_forms[i]);
   JNL_rec_new_windows[i] = runtime_forms[i];
   }
 }
}

int JNL_record_new_window( window )
Window window;
{
XEvent xevent;
int done,i,status;
Window *win;
int flag;
char char_string[JNL_MAX_CHAR];

/*do not move this code for it set up the pointers from old to new*/
 flag = TRUE;
 win = JNL_rec_new_windows;
 for( i=0; i<JNL_MAX_WINDOW && flag == TRUE; i++,win++)
   {
    if (*win == 0 )
	   {
	    *win = window;
        flag = 0;    
       }
    }

if (JNL_echo)
 {
 /*if replay wait on the mapping event for this window*/
 done = 0;
 while ( !done )
  {
   status = JNL_echo_input(sizeof (XEvent), &xevent);/*user event*/
   if (status)
     {
     JNL_close_echo();
     done = 1;
     }
   else
     {
      window_do_configure_flag[i] = 0;/*this will be set to true
                                       when we get a expose
                                       on this window*/
      if (( xevent.type == JNL_INFO_EVENT )
                     && (xevent.xany.serial == JNL_WINDOW_CHANGE))
       {
       /*found match*/
       JNL_rec_old_windows[i - 1] = xevent.xany.window;
       done = 1;
       }
      else if (( xevent.type == JNL_INFO_EVENT )
                     && (xevent.xany.serial == JNL_CHAR))

       {
       JNL_echo_input(xevent.xbutton.x,char_string);
       }
     }/*end have event*/
   }/*end while not done*/
 }/*end if echo*/
JNL_record_info_event(JNL_WINDOW_CHANGE, 0, 
                                  window);
return(1);
}

JNL_XWithdrawWindow(display,w,screen_no)
Display *display;
Window w;
int screen_no;
{
XEvent my_event;
XWithdrawWindow(display,w,screen_no);
if (JNL_echo)
 {
  while (1)
  {
  XWindowEvent(display,w,SubstructureNotifyMask,&my_event);
  if ( my_event.type == UnmapNotify ) break;
  }
 }
}

JNL_XUnmapWindow(display,w)
Display *display;
Window w;
{
XEvent my_event;
XUnmapWindow(display,w);
if (JNL_echo)
 {
  while (1)
  {
  XWindowEvent(display,w,SubstructureNotifyMask,&my_event);
  if ( my_event.type == UnmapNotify ) break;
  }
 }
}

JNL_XMapWindow(display,w)
Display *display;
Window w;
{
XEvent my_event;
XMapWindow(display,w);
if (JNL_echo)
 {
  XWindowEvent(display,w,ExposureMask,&my_event);
  while (XCheckWindowEvent(display,w,ExposureMask,&my_event));
 }
}

JNL_XMapRaised(display,w)
Display *display;
Window w;
{
XEvent my_event;
XMapRaised(display,w);
XFlush(display);
if (JNL_echo)
 {
  XWindowEvent(display,w,ExposureMask,&my_event);
  while (XCheckWindowEvent(display,w,ExposureMask,&my_event));
 }
}
 
void JNL_XNextEvent( display,xevent )
Display *display;
XEvent *xevent;
{
if ( JNL_echo )
 {
 JNL_process_slow_echo();
 JNL_read_next_event(xevent);

 /*JNL_echo reset to false in read_next_event if finished*/

 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 XNextEvent(display,xevent);
/* XtAppNextEvent(appContext,xevent);*/
 }

if (JNL_record)
 {
 JNL_record_next_event(xevent,0);/*flag of 0,record only events you want*/
 }
}

void JNL_XtAppNextEvent( appContext,xevent )
XtAppContext appContext;
XEvent *xevent;
{
if ( JNL_echo )
 {
 JNL_process_slow_echo();
 JNL_read_next_event(xevent);

 /*JNL_echo reset to false in read_next_event if finished*/

 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 XtAppNextEvent(appContext,xevent);
 }

if (JNL_record)
 {
 JNL_record_next_event(xevent,0);/*flag of 0,record only events you want*/
 }
}

int JNL_XGrabPointer(display,grab_window,owner_events,event_mask,
      pointer_mode,keyboard_mode,confine_to,cursor,time)
Display *display;
Window grab_window;
Bool owner_events;
unsigned int event_mask;
int pointer_mode, keyboard_mode;
Window confine_to;
Cursor cursor;
Time time;
{
int status;
if (JNL_echo)
  return(GrabSuccess);
else
 {
 status =XGrabPointer(display,grab_window,owner_events,event_mask,
                 pointer_mode,keyboard_mode,confine_to,cursor,time);
 return(status);
 }
}

void JNL_XUngrabPointer(display,time)
Display *display;
Time time;
{
if (JNL_echo)
   return;
else
  XUngrabPointer(display,time);
}

int JNL_XCheckTypedEvent( display,event_type,xevent )
Display *display;
int event_type;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo )
 {
 status = JNL_peek_next_event(xevent);
 if ( !status )
  {
  /*do have data is it like the type*/
   if ( xevent->type == event_type )
    {
    JNL_read_next_event(xevent);
    status = 1;
    }
   else
    {
    status = 0;
    }
  }
 /*JNL_echo reset to false in read_next_event if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XCheckTypedEvent(display,event_type,xevent);
 }

if (JNL_record && status)
 {
 JNL_record_next_event(xevent,0);
 }
return(status);
}

int JNL_XCheckTypedWindowEvent( display,w,event_type,xevent )
Display *display;
Window w;
int event_type;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo )
 {
 status = JNL_peek_next_event(xevent);
 if ( !status )
  {
  /*do have data is it like the type*/
   if ( ( xevent->type == event_type ) &&
        ( xevent->xany.window == w )  )
    {
    JNL_read_next_event(xevent);
    status = 1;
    }
   else
    {
    status = 0;
    }
  }
 /*JNL_echo reset to false in read_next_event if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XCheckTypedWindowEvent(display,w,event_type,xevent);
 }

if (JNL_record && status)
 {
 JNL_record_next_event(xevent,0);
 }
return(status);
}





int JNL_XCheckMaskEvent( display,event_mask,xevent )
Display *display;
long event_mask;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo )
 {
 status = JNL_peek_next_event(xevent);
 if ( !status )
  {
  /*do have data is it like the type*/
   status = 0;
   switch ( xevent->type )
          {
          case KeyPress :
            if ( event_mask & KeyPressMask )
                status = 1;
                break;

          case KeyRelease:
            if ( event_mask & KeyReleaseMask )
                status = 1;
                break;

  	      case ButtonRelease :
            if ( event_mask & ButtonReleaseMask )
                status = 1;
                break;

          case ButtonPress:
            if ( event_mask & ButtonPressMask )
                status = 1;
                break;

    	  case ConfigureNotify:
	      case DestroyNotify:
          case UnmapNotify:
          case MapNotify:
          case CirculateNotify:
          case CreateNotify:
          case GravityNotify:
          case ReparentNotify:
            if ( event_mask & SubstructureNotifyMask )
                status = 1;
                break;

          case MotionNotify:
            if (( event_mask & PointerMotionHintMask ) ||
               ( event_mask & PointerMotionMask ) ||
               ( event_mask & ButtonMotionMask ))
                status = 1;
                break;

          case Expose:
            if ( event_mask & ExposureMask )
                status = 1;
                break;

          default:
           break;
     }/*end switch*/

  }
 if ( status )
      status = JNL_read_next_event(xevent);
 /*JNL_echo reset to false in read_next_event if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XCheckMaskEvent(display,event_mask,xevent);
 }

if (JNL_record && status)
 {
 JNL_record_next_event(xevent,0);
 }
return(status);
}

int JNL_XCheckWindowEvent( display,w,event_mask,xevent )
Display *display;
Window w;
long event_mask;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo )
 {
 status = JNL_peek_next_event(xevent);
 if ( !status )
  {
  /*do have data is it like the type*/
   status = 0;
   switch ( xevent->type )
          {
          case KeyPress :
            if (( event_mask & KeyPressMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

          case KeyRelease:
            if (( event_mask & KeyReleaseMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

  	  case ButtonRelease :
            if (( event_mask & ButtonReleaseMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

          case ButtonPress:
            if (( event_mask & ButtonPressMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

    	  case ConfigureNotify:
	      case DestroyNotify:
          case UnmapNotify:
          case MapNotify:
          case CirculateNotify:
          case CreateNotify:
          case GravityNotify:
          case ReparentNotify:
            if (( event_mask & SubstructureNotifyMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

          case MotionNotify:
            if ((( event_mask & PointerMotionHintMask ) ||
               ( event_mask & PointerMotionMask ) ||
               ( event_mask & ButtonMotionMask )) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

          case Expose:
            if (( event_mask & ExposureMask ) &&
                        (xevent->xany.window == w))
                status = 1;
                break;

          default:

           break;
     }/*end switch*/

  }
 if ( status )
      status = JNL_read_next_event(xevent);
 /*JNL_echo reset to false in read_next_event if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XCheckWindowEvent(display,w,event_mask,xevent);
 }

if (JNL_record && status)
 {
 JNL_record_next_event(xevent,0);
 }
return(status);
}

int JNL_XWindowEvent( display,w,event_mask,xevent )
Display *display;
Window w;
long event_mask;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo )
 {
 JNL_read_next_event(xevent);
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XWindowEvent(display,w,event_mask,xevent);
 }

if (JNL_record )
 {
 JNL_record_next_event(xevent,1);
 }
return(status);
}

int JNL_XMaskEvent( display,event_mask,xevent )
Display *display;
long event_mask;
XEvent *xevent;
{
if ( JNL_echo )
 {
  JNL_read_next_event(xevent);
  /*do have data is it like the type,if you get here you wait on 
                            correct event*/
  }
 /*JNL_echo reset to false in read_next_event if finished*/

if ( !JNL_echo )
 {
  XMaskEvent(display,event_mask,xevent);
 }

if (JNL_record )
 {
 JNL_record_next_event(xevent,1);
 }
return(1);
}

int JNL_XCheckIfEvent( display,xevent,predicate,arg )
Display *display;
XEvent *xevent;
Bool (*predicate)();
char *arg;
{
int status;
status = 0;
if ( JNL_echo )
 {
 status = JNL_peek_next_event(xevent);
 if ( !status )
  {
  /*do have data is it like the type*/
   status = (*predicate)(display,xevent,arg);
   if ( status )
      status = JNL_read_next_event(xevent);
  }
  /*JNL_echo reset to false in read_next_event or peek if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 status = XCheckIfEvent(display,xevent,predicate,arg);
 }

if (JNL_record && status)
 {
 JNL_record_next_event(xevent,0);
 }
return(status);
}

JNL_XPeekIfEvent( display,xevent,predicate,arg )
Display *display;
XEvent *xevent;
Bool (*predicate)();
char *arg;
{
int i,status,nevents,peek_true;
long off_set;
XEvent myevent;

status = 0;
peek_true = 0;
off_set = 0;
nevents = 0;
if ( JNL_echo )
 {
 JNL_read_next_event(&myevent);/*had better be the number of events*/
 if (( myevent.xany.type == JNL_INFO_EVENT ) && 
        ( myevent.xany.serial == JNL_PENDING_EVENTS ))
  {
  off_set =  ftell ( JNL_echo );
  for ( i = 0 , !peek_true ; i < myevent.xbutton.x ; i++ )
   {
   status = JNL_read_next_event(xevent);
   if ( !status )
    {
    /*do have data is it like the type*/
    status = (*predicate)(display,xevent,arg);
    if ( status )
        peek_true = 1;
    }
   }/*end for*/
  }
  if ( !peek_true )
     printf ("JNLPeekIfEvent failed\n");
  else
   fseek (JNL_echo ,0, off_set); 
  /*JNL_echo reset to false in read_next_event or peek if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 nevents = XPending(display);
 XPeekIfEvent(display,xevent,predicate,arg);
 }

if (JNL_record)
 {
 JNL_record_info_event(JNL_PENDING_EVENTS,4,nevents);
 }
}

void JNL_XIfEvent( display,xevent,predicate,arg )
Display *display;
XEvent *xevent;
Bool (*predicate)();
char *arg;
{
if ( JNL_echo )
 {
 JNL_read_next_event(xevent);
  /*do have data is it like the type*/
  (*predicate)(display,xevent,arg);
  /*JNL_echo reset to false in read_next_event or peek if finished*/
 }/*end if JNL_echo*/

if ( !JNL_echo )
 {
 XIfEvent(display,xevent,predicate,arg);
 }

if (JNL_record )
 {
 JNL_record_next_event(xevent,1);
 }
}


JNL_clear_windows()
{
int i;
Window *win;

  win = JNL_rec_new_windows;
  for( i=0; i<JNL_MAX_WINDOW ; i++,win++)
       {
       *win = 0;
       window_do_configure_flag[i] = 0;
       }
return (1);
}

int JNL_read_next_event( xevent )
XEvent *xevent;
{
int done;
int status;
XWindowChanges values;
int i,flag;
Window *win;
int real_event;
int nbytes;
char string[JNL_MAX_CHAR];

XEvent send_event;
real_event = 0;
while ( !real_event )
{
 status = JNL_echo_input((sizeof ( XEvent)),  xevent);
 if (( status )  || (xevent->xany.type < 0 ))
   {
    done = 0;
    JNL_close_echo();
    send_event.xclient.type = ClientMessage;
    send_event.xclient.display = xevent->xany.display;      
    send_event.xclient.send_event = 1;     
    send_event.xclient.message_type = 0;
    send_event.xclient.format = 8;
    send_event.xclient.data.l[0] = 5;
    win = JNL_rec_new_windows;
    flag = 1;
    for( i=0; i<JNL_MAX_WINDOW && flag == TRUE; i++,win++)
             {
              if ( *win  )
                {
                    send_event.xclient.window = *win;                     
                    flag = FALSE;
                }
             }
     XSendEvent(EXdisplay,send_event.xclient.window,FALSE,ClientMessage,&send_event);
     while (!done)
      {      
      XNextEvent(EXdisplay,xevent);
      if ( xevent->type == ClientMessage )
           done = 1;
      }
     /*have processed all playback events retrun to interactive*/
     return (0);
     }
 else
     {
     /*have data is it just info*/
     if ( xevent->type != JNL_INFO_EVENT )
        {
         XSync(EXdisplay,1);
         real_event = 1;/*exit read loop*/
         status = JNL_oldwindow_to_window(xevent);

         if (status)
          {
               flag = TRUE;
               win = JNL_rec_new_windows;
               for( i=0; i<JNL_MAX_WINDOW && flag == TRUE; i++,win++)
                {
                 if ( *win == xevent->xany.window )
                  {
                  flag = 0;
                  break;                  
                  }
                }
               if (flag)
                  printf("error on playback conversion\n");

          xevent->xany.display = EXdisplay;/*use current display*/
          switch (xevent -> type)
           {
            case ConfigureNotify:
               if ( !window_do_configure_flag[i] )
                  {
                        real_event = 0;/*exit read loop*/
                        JNL_record_input((sizeof ( XEvent)),  xevent);
                        /*record this because we never get to 
                          record event*/
                        break;
                  }

              values.x = xevent->xconfigure.x;
              values.y = xevent->xconfigure.y;
              values.width = xevent->xconfigure.width;
              values.height = xevent->xconfigure.height;
              values.border_width = xevent->xconfigure.border_width;
              values.sibling = 0;
              values.stack_mode = 0;
              xevent->xconfigure.window = xevent->xany.window;

              XConfigureWindow(EXdisplay,xevent->xconfigurerequest.window,
                           (CWX | CWY | CWWidth | CWHeight | CWBorderWidth),
                            &values);

              break;

    	    case DestroyNotify:  
               window_do_configure_flag[i] = 0;
              break;

            case UnmapNotify:
              window_do_configure_flag[i] = 0;
              break;
/*              status = JNL_XPeekEvent(EXdisplay ,&send_event );
              if ( status )
               { 
                if ( send_event.type == DestroyNotify )
                  {
                   break;
                  }
                }*/
/*               XIconifyWindow(EXdisplay,xevent->xunmap.window,EXscreen);*/
/*               sleep(1);
               break;*/
   
            case MapNotify:
              break;

            case Expose:
               window_do_configure_flag[i] = 1;
              break;

            default:
              break;
            }/*end switch*/
                    done = 1;
         }/*this was one of our windows*/
        }/*end if not info event */
       else if (( xevent->type == JNL_INFO_EVENT )
                     && (xevent->xany.serial == JNL_CHAR))
        {
        /*it is info event if it is JNL_CHAR there is character
          must remove it*/
         nbytes = xevent->xbutton.x;
         if (nbytes > JNL_MAX_CHAR)nbytes = JNL_MAX_CHAR;
         JNL_echo_input(nbytes,string);
        }
       else if ((xevent->type == JNL_INFO_EVENT) &&
                           (xevent->xany.serial == JNL_STOPSIGN))
       {
       return(1);
       }
       else
        {
         /*journal mismatch*/
         printf("journaling mismatch, replay and journaling disabled\n");
         JNL_close_jnl();
         JNL_close_echo();
         return(0);
        }
     }
   }
return(status);
}

JNL_record_next_event( xevent,record_flag )
XEvent *xevent;
int record_flag;/*=1 record regardless*/
{
int         i, flag;
Window     *win;
XEvent      send_event,myevent;
int         status;
Window      child;
static      warned_em_yet = FALSE;
WLuint16    lscreen;
int         hw_screen;
int type;
static int installed = 0;

if (!installed)
{
   /* Set the error handler */
   XSetErrorHandler(ErrorHandler);
   installed = 1;
}

 if ( xevent->xany.window != message_strip )
 {
   flag = TRUE;
   win = JNL_rec_new_windows;
   for( i=0; i<JNL_MAX_WINDOW && flag == TRUE; i++,win++)
        {
        if ( *win == xevent->xany.window )
                {
                flag = FALSE;
                break;
                }
        }
  if ( !flag )
   {
    switch( xevent->type)
          {
          case KeyPress :
          case KeyRelease:
          case ClientMessage:
              status = JNL_record_input((sizeof ( XEvent)),  xevent);
              break;

    	  case ConfigureNotify:
                if ( !xevent->xany.send_event )
                {
                    send_event.type  = ConfigureNotify;
                    send_event.xconfigure.type = 
                                  xevent->xconfigure.type;
                    send_event.xconfigure.serial = 
                                  xevent->xconfigure.serial;
                    send_event.xconfigure.display =
                                  xevent->xconfigure.display;
                    send_event.xconfigure.event = 
                                  xevent->xconfigure.event;
                    send_event.xconfigure.window = 
                                  xevent->xconfigure.window;
                    send_event.xconfigure.width =
                                  xevent->xconfigure.width;
                    send_event.xconfigure.height =
                                  xevent->xconfigure.height;
                    send_event.xconfigure.above =
                                  xevent->xconfigure.above;
                    send_event.xconfigure.override_redirect =
                                  xevent->xconfigure.override_redirect;

                    /*not root relative musr translate to root window*/
                    WLget_active_screen(&lscreen,&type);
                    WLget_hardware_screen_from_logical(lscreen,&hw_screen);

		    {
                     
		      Window  rtw, pw, *chws;
		      int	i,  sts;
		      unsigned int   nchws;

		      sts = XQueryTree(EXdisplay,RootWindow(EXdisplay, hw_screen),
					&rtw, &pw, &chws, &nchws);

		      for(i=0; i<nchws; i++)
			  if((chws[i] == xevent->xany.window))
			  break;

		      if( i != nchws )
		      { 
                        XTranslateCoordinates(EXdisplay,xevent->xany.window,
                                          RootWindow(EXdisplay,hw_screen),
                                           0,0,
                                           &send_event.xconfigure.x,
                                           &send_event.xconfigure.y,
                                           &child);
                        send_event.xconfigure.send_event = 1;
                        status = JNL_record_input((sizeof ( XEvent)), 
                                                    &send_event);
		      }
		      XFree((caddr_t)chws);
		    }
                 }
                 else
                  {
                    int  x, y, screen_num;
                    unsigned int  width, height;
                    unsigned int  border_width, depth ;
                    Window    root; 
                   
                    screen_num = DefaultScreen( EXdisplay );

                    XGetGeometry( EXdisplay, 
                                  xevent->xconfigure.window,
                                  &root, &x, &y,
                                  &width, &height, &border_width,
                                  &depth);
                     
                    XTranslateCoordinates(EXdisplay,xevent->xany.window,
                                          RootWindow(EXdisplay, screen_num),
                                           0, 0, &x, &y, &child );

                    xevent->xconfigure.x = x;
                    xevent->xconfigure.y = y;
                    xevent->xconfigure.width = width;
                    xevent->xconfigure.height = height;

                    status = JNL_record_input((sizeof ( XEvent)),  xevent);  
                  }
                    break;
          case UnmapNotify:
          case Expose:
          case MapNotify:
  	      case ButtonRelease :
          case ButtonPress:
    	  case CreateNotify:
    	  case ReparentNotify:
	      case DestroyNotify:


          if ( xevent->type == ButtonPress )
              JNL_record_last_button_press_offset();
          if ( xevent->type == DestroyNotify ) 
          /*remove this window from our window array*/
              {
               *win = 0;
              }

         status = JNL_record_input((sizeof ( XEvent)),  xevent);

          break;

          default:


            if (record_flag)
               {
                if ( xevent->type != MotionNotify )
                 {
                    status = JNL_record_input((sizeof ( XEvent)),  xevent);
                 }
               }

           break;
          }/*end switch*/
   }
    else if ((xevent->type == KeyPress || xevent->type == ButtonPress) &&
             (xevent->xany.window != copyright_window) &&
             (warned_em_yet == FALSE))
    {
        char *c;
        warned_em_yet = TRUE;
        c = "The current journal file will not be valid from this point on.\nExit and restart the product to reinstigate journaling.";
        JNL_record_info_event(JNL_CHAR, strlen(c), c);
        if (jnl_warning)
        {
        fprintf(stderr, "Warning:\n%s\n", c);
        FI_message_box2 (FI_CURRENT_SCREEN, -1, -1, "Warning", FI_BLACK,
                         "swiss742", 24.0, c, FI_BLACK, "swiss742", 24.0,
                         FI_CENTER_JUSTIFIED, 80);
        }
    }
 }/*end if not message_strip*/
}
static long button_press_offset;
static long current_offset;

JNL_record_last_button_press_offset()
{
button_press_offset = ftell(JNL_record);
}

JNL_record_current_offset()
{
current_offset = ftell(JNL_record);
}
JNL_set_offset_to_last_button()
{
long pos;
JNL_record_current_offset();
pos = current_offset - button_press_offset;
fseek( JNL_record, -pos, 1 );
}
JNL_set_offset_to_current_position()
{
fseek(JNL_record,current_offset,0);
}

JNL_XPeekEvent( display,xevent )
Display *display;
XEvent *xevent;
{
int status;
status = 0;
if ( JNL_echo ) 
 {
 status = JNL_peek_next_event(xevent);
 if ( status ) 
     {
       XPeekEvent(display,xevent);
      }
 }/*end if JNL_echo*/
else
 {
 XPeekEvent(display,xevent);
 }
}


int JNL_peek_next_event( xevent )
XEvent *xevent;
{
/*if there is no input JNL_echo will be set to 0*/
int status;
int real_event,nbytes;
char string[JNL_MAX_CHAR];
long offset;

if (JNL_echo)offset = ftell(JNL_echo);
real_event = 0;
while (!real_event)
{
status = JNL_echo_input((sizeof ( XEvent)),  xevent);
 {
  if(!status)
  {
  /*have data is it just info*/
   if ( xevent->type != JNL_INFO_EVENT )
   {
   real_event = 1;
   JNL_oldwindow_to_window(xevent);
   }
  else
  {
    if (( xevent->type == JNL_INFO_EVENT )
                     && (xevent->xany.serial == JNL_CHAR))
        {
        /*it is info event if it is JNL_CHAR there is character
          must remove it*/
         nbytes = xevent->xbutton.x;
         if (nbytes > JNL_MAX_CHAR)nbytes = JNL_MAX_CHAR;
         JNL_echo_input(nbytes,string);
        }


    else if (( xevent->type == JNL_INFO_EVENT )
                     && (xevent->xany.serial == JNL_WINDOW_CHANGE))
        {
         fseek(JNL_echo,offset,0);/*go back to start of record*/
         return(0);/*nothing to process*/

        }
    }/*end if is INFO event*/
   }/*end if status 0 means you have data*/
  else real_event = 1; /*must exit routine*/
  }/*end test status*/
 }/*end real_event = 0*/
if (JNL_echo)fseek(JNL_echo,offset,0);
return( status );
}

JNL_XPutBackEvent( display,xevent)
Display *display;
XEvent *xevent;
{
if (JNL_echo)
   fseek(JNL_echo,-(sizeof(XEvent)),1); 
else
   XPutBackEvent( display,xevent);

if (JNL_record)
   fseek(JNL_record,-(sizeof(XEvent)),1); 

}

/*format of user event
int event = 0x7fffffff
type = 0 initial record of file
int type CHAR then #bytes and string
if type = JNL_CHANGE_WINDOW else window number 
*/
int JNL_read_button_count(count)
int *count;
{
int status;
XEvent xevent;

status = JNL_echo_input((sizeof ( XEvent)),  &xevent);
*count =  xevent.xbutton.x;
return(status);
}

int JNL_record_info_event(type, event_nbytes, string)
int type;
int event_nbytes;
char string[];
{
XEvent xevent;

xevent.type = JNL_INFO_EVENT;

if ( JNL_record )
{
  if (type == JNL_WINDOW_CHANGE)
   {
   /*for stopsign record number of buffer put out in antimation*/
   xevent.xany.window = (Window)string;
   xevent.xany.serial = JNL_WINDOW_CHANGE;
   xevent.xbutton.x = 0;/*grnuc uses JNL_WINDOW_CHANGE and has nbytes>0*/
   JNL_record_input( sizeof(XEvent), &xevent );   
                              /*for menu type just store window#*/
   }
  else if (type == JNL_STOPSIGN)
   {
   /*for stopsign record number of buffer put out in antimation*/
   xevent.xany.window = (Window)string;
   xevent.xany.serial = JNL_STOPSIGN;
   JNL_record_input( sizeof(XEvent), &xevent );   
                              /*for menu type just store window#*/
   }
  else if ( type == JNL_CHAR )
   {
   xevent.xany.serial = JNL_CHAR;
   xevent.xbutton.x = event_nbytes;
   JNL_record_input( sizeof(XEvent), &xevent );   
   JNL_record_input(event_nbytes,string);
   }
  else if ( type == JNL_BUTTON_COUNT )
   {
   xevent.xany.serial = JNL_BUTTON_COUNT;
   xevent.xbutton.x = (int)string;
   JNL_record_input( sizeof(XEvent), &xevent );   
   }
  else if ( type == JNL_PENDING_EVENTS )
   {
   xevent.xbutton.x = (int)string;
   xevent.xany.serial = JNL_PENDING_EVENTS;
   JNL_record_input( sizeof(XEvent), &xevent );   
                              /*for menu type just store window#*/
   }

}
return(1);
}
int JNL_if_read_button_count(count,xevent)
int *count;
XEvent *xevent;
{
  JNL_echo_input((sizeof ( XEvent)),  xevent);

  if ( xevent->type == JNL_INFO_EVENT )
   {
   *count = xevent->xbutton.x;
   return(1);
   }
  else 
   {
   if (JNL_record)
    {
    if (xevent->type == ButtonRelease )
     {
     JNL_oldwindow_to_window(xevent);    
     JNL_record_input((sizeof ( XEvent)),  xevent);/*write out release*/
     }
    else
     {
     printf(" JNL error in if_button_count\n");
     }
    }
   return(0);/*was the release button*/
   }
}
   
int JNL_close_jnl()
{
 if(JNL_record)
 {
    fclose(JNL_record);/*close journal file*/
    JNL_record = 0;
 }
 return(1);
}

int JNL_close_jnl_pbk()
{
 if(JNL_record)
 {
    fclose(JNL_record);/*close journal file*/
    JNL_record = 0;	
 } 
 if (JNL_echo)
 {
 JNL_close_echo();
 }
return(1);
}


int JNL_close_echo()
{
 if (JNL_echo)
 {
        JNL_echo = 0;
        fclose(JNL_echo);
 }
return(1);
}

int JNL_record_input(  nbytes, buffer )
int nbytes;
char *buffer;
{
    int status;
    if (JNL_record)
    {
      status = 0;
      status = fwrite(buffer, nbytes, 1, JNL_record);
      status = fflush(JNL_record);
    }
    return(1);
}


int JNL_echo_input(nbytes, buffer )
int nbytes;
char *buffer;
{
    int status;
    status = 0;
    if (JNL_echo)
    {
       status = fread(buffer, nbytes, 1, JNL_echo);   
       if ( !status )
        {
	    status = 1;/*eof retruns 1 because tools returns 0 for good*/
	                        /*hardware input*/
        JNL_close_echo();
        }
       else
        {
        status = 0;/*status = 0 have an event*/
        }
    }
    return(status);
}


int JNL_read_record_event(nbytes, buffer )
int nbytes;
char *buffer;
{
    int status;
    status = 0;
    if (JNL_record)
    {
       status = fread(buffer, nbytes, 1, JNL_record);   
    }
    return(status);
}


int JNL_oldwindow_to_window(xevent)
XEvent *xevent;
{
Window *win;
int flag,i;

flag = TRUE;
win = JNL_rec_old_windows;
for( i=0; i<JNL_MAX_WINDOW && flag == TRUE; i++,win++)
   {
    if (*win == xevent->xany.window )
	   {
           flag = 0;    
           }
    }
if ( !flag)
   {
     xevent->xany.window  = JNL_rec_new_windows[i - 1];
     switch( xevent->type)
          {
    	  case ConfigureNotify:
	      case DestroyNotify:
          case UnmapNotify:
          case MapNotify:
            xevent->xconfigure.window  = JNL_rec_new_windows[i - 1];
            /*all the above cases have the above field*/
            break;
          default:
            break;
          }
  return(1);
  }
else
  return(0);
}

int JNL_process_slow_echo()
{
XEvent event;
int status;
static int slowpbk = 0;

if ( slowpbk )
   {
   XMaskEvent( EXdisplay,ButtonPressMask | KeyPressMask, &event );
   if ( event.xbutton.button == Button3 )
      {
        /*reset true stop slow playback*/
        slowpbk = 0;
        return(1);
      }
    else if  ( event.xbutton.button == Button1 )
      {
        /*turn off playback*/
        JNL_close_echo();
        return(1);
      }
  }/*end if slowpbk true*/

 status = XCheckMaskEvent( EXdisplay,ButtonPressMask, &event );
 if (status)
  {
  if ( event.xbutton.button == Button3 )
        slowpbk = 1;
   else if ( event.xbutton.button == Button1 )
        JNL_close_echo();        /*turn off playback*/
  }

return(1);
}


/* this function can operate in both X and ENV5 environments */
int JNL_adjust_journal_button()
{
  int status;
  int nbytes;

  /* number bytes in journal event */

  nbytes = - (2 * sizeof (XEvent)); /* one for button down, one for release */

  status = 1;
  if (JNL_record)
  {
    status = fseek(JNL_record,nbytes, 1);
  }
  return(status);
}

#else
#error Windowing system switches must be set!
#endif

/*
 *  The error handler. Specifically for TR 119528648, for which a
 *  Xconfigure Event is got for a Window off ems command.  The
 *  XGetGeometry call fails due to a a BadDrawable. Hence, ignore
 *  trap and ignore this and allow the flow to continue.
 *  Need to dig more into the problem and find a clean solution
 *  - Srikanth.
 */

#ifdef X11
int ErrorHandler(display, event)
Display       *display;
XErrorEvent   *event;
{
   error_code = 0;

   if  ( ((event->error_code == BadDrawable) ||
       (event->error_code == BadWindow)) && (event->request_code ==
       X_TranslateCoords) )
          error_code = X_TranslateCoords;

}
#endif


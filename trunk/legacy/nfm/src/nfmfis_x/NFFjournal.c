
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <tools.h>
#include <stdio.h>
#include <fcntl.h>
#include "NFFjournal.h"

#include "NFMporttypes.h"

static int    JNL_echo_read_event;
static int    JNL_echo_last_event;
static int    JNL_rec_windows[MAX_WINDOW];
static int    timer_flag = 0;
static int    playback_time = 0;
static int    key_buffer_count;
static char   *key_buffer;
static FILE   *JNL_record;
static FILE   *JNL_echo;
static struct jnl_timers jnl_timer_no[TIMER_MAX_COUNT];

int JNL_init_journal (filename, excl_flag)
  char   *filename;
  int    excl_flag;
  {
    int   i;
    int   flag;
    int   jnlopen;

    flag = O_WRONLY | O_CREAT | O_TRUNC;
    if (excl_flag)
       flag |= O_EXCL;

    JNL_record = NULL;
    JNL_echo_read_event = 0;
    JNL_echo_last_event = 0;

    jnlopen = open (filename, flag, 0660);
    if (jnlopen == -1) return (0);

    JNL_record = (FILE *) fdopen (jnlopen, "w+");

    /*  Newly created not modified file  */

    JNL_record_input (4, (char *) &flag);

    for (i = 0 ; i < TIMER_MAX_COUNT; ++i)
      {
        jnl_timer_no[i].used = 0;
        jnl_timer_no[i].previous = 0;
      }

    return (1);
  }

int JNL_init_playback (filename)
  char    *filename;
  {
    int    flag = 0;

    if ((JNL_echo = fopen (filename, ("r"))) == NULL)
        return (0);

    /*  Strip off header info  */

    JNL_echo_input (4, (char *) &flag);

    if (JNL_record != NULL)
      {
        /*  May not have access to journal file  */

        fseek (JNL_record, -4, 1);

        /*  If created from another file, copy header  */

        JNL_record_input (4, (char *) &flag);
      }

    return (1);
  }


int JNL_record_new_window (window)
  int    window;
  {
    int    type;
    int    done = 0;
    int    old_window;

    if (JNL_echo != NULL)
      {
        while (!done)
          {
            /*  User event  */

            JNL_echo_input (4, (char *) &type);
            if (type < 0)
              {
                JNL_process_del_info_event ();
              }
            else
              {
                done = JNL_process_info_event (window);

                /*  Ready to read next event  */

                JNL_echo_read_event = 0;
              }
          }
      }

    if (JNL_record != NULL)
      {
        old_window = window;  
        JNL_record_info_event (JNL_WINDOW_CHANGE, 0, &old_window);
      }

    return (1);
  }



int JNL_echo_event (mask, event)
  int    mask;
  int    *event;
  {
    int        type;    
    int        done = 0;
    int        status = 0;
    char    dummy[JNL_MAX_CHAR];

    JNL_process_slow_echo ();

    if (JNL_echo == NULL)
      {
        if (!mask)
            Inq_events (event);
        else
            Wait_for_next (mask, event);

        return (0);
      }

    while (!done)
      {
        /*  JNL_echo_read_event = 0 says the event was used;
            get next on next call to echo_event; = 1 use last event  */

        if (!JNL_echo_read_event)
          {
            if ((status = JNL_echo_input (4, (char *) event)) == 0)
              {
                /*  You have data if this is a deleted event  */

                if (*event < 0)
                  {
                    done = 1;

                    if (!mask)
                        Inq_events (event);
                    else
                        Wait_for_next (mask, event);

                    fclose (JNL_echo);
                    JNL_echo = 0;            
                  }
                else if (*event == JNL_INFO_EVENT)
                  {
                    JNL_echo_input (4, (char *) &type);

                    if (type == JNL_WINDOW_CHANGE)
                      {
                        /*  This info must be read
                            when record_new_window called  */

                        /*  Back up 4 bytes  */

                        JNL_adjust_echo ();

                        /*  Back up 4 bytes  */

                        JNL_adjust_echo ();

                        *event = 0;
                        done = 1;
                      }

                    if (type == JNL_TIMER_NO)
                      {
                        /*  This info must be read
                            when record_new_window called  */

                        /*  Back up 4 bytes  */

                        JNL_adjust_echo ();

                        /*  Back up 4 bytes  */

                        JNL_adjust_echo ();

                        *event = 0;
                        done = 1;
                      }
                    else
                      {
                        /*  Just character data  */

                        /*  Back up 4 bytes  */

                        JNL_adjust_echo ();

                        JNL_process_info_event (dummy);
                      }
                  }
                else
                  {
                    done = 1;

                    /*  Save for next call possibly  */

                    JNL_echo_last_event = *event;

                    /*  Won't read again until event read  */

                    JNL_echo_read_event = 1;
                  }     
              }
            else
              {
                /*  End of file  */

                done = 1;
                if (!mask)
                    Inq_events (event);
                else
                    Wait_for_next (mask, event);
              }
          }
        else
          {
            /*  Not time for new read event yet  */

            *event = JNL_echo_last_event;
            done = 1;
          }
      }

    return (status);
  }


int JNL_process_info_event (new_window)
  int    new_window;
  {
    int        type;
    int        window;
    int        nbytes;
    int        status = 1;
    char    string[JNL_MAX_CHAR];

    if (JNL_echo == NULL) return (status);

    JNL_echo_input (4, (char *) &type);

    if (type == JNL_WINDOW_CHANGE)
      {
        JNL_echo_input (4, (char *) &window);
        JNL_rec_windows[window] = new_window;

        /*  Looking for window event, found it  */

        status = 1;
      }
    else if (type == JNL_CHAR)
      {
        JNL_echo_input (4, (char *) &nbytes);

        if (nbytes)
            JNL_echo_input (nbytes, string);

        /*  If looking for window not it  */

        status = 0;
      }

    return (status);
  }

int JNL_process_del_info_event ()
  {
    int     type;
    int     window;
    int     nbytes;
    char    string[JNL_MAX_CHAR];

    if (JNL_echo == NULL) return (1);

    JNL_echo_input (4, (char *) &type);
    if (type == JNL_WINDOW_CHANGE)
      {
        JNL_echo_input (4, (char *) &window);
      }
    else if (type == JNL_CHAR)
      {
        JNL_echo_input (4, (char *) &nbytes);
        if (nbytes)
            JNL_echo_input (nbytes, string);
      }

    return (1);
  }


/*  Format of user event
    int        event = 0x7fffffff
            type = 0 initial record of file
    int        type CHAR then #bytes and string
    if        type = JNL_CHANGE_WINDOW else window number 
*/


int JNL_record_info_event (type, event_nbytes, string)
  int    type;
  int    event_nbytes;
  char   *string;
  {
    int   atype;
    int   abytes;
    int   event;

    event = JNL_INFO_EVENT;
    atype = type;
    abytes = event_nbytes;

    if (JNL_record == NULL) return (1);

    JNL_record_input (4, (char *) &event);
    JNL_record_input (4, (char *) &atype);

    if (type == JNL_WINDOW_CHANGE)
      {
        /*  For menu type just store window #  */

        JNL_record_input (4, string);
      }
    else if (type == JNL_CHAR) 
      {
        /*  For all other user events store string  */

        JNL_record_input (4, (char *) &abytes);

        if (event_nbytes)
            JNL_record_input (event_nbytes, string);
      }

    return (1);
  }


int JNL_record_event (event)
  int    event;
  {
    int        aevent;
    
    if (JNL_record != NULL)
      {
        aevent = event;    
        JNL_record_input (4, (char *) &aevent); 
      }

    return(1);
  }


int JNL_close_jnl ()
  {
    if (JNL_record != NULL)
      {
        /*  Close journal file  */

        fclose (JNL_record);
        JNL_record = NULL;
      }

    return (1);
  }


int JNL_close_jnl_pbk ()
  {
    if (JNL_record != NULL)
      {
        /*  Close journal file  */

        fclose (JNL_record);
        JNL_record = NULL;
      }

    if (JNL_echo != NULL)
      {
        fclose (JNL_echo);
        JNL_echo = NULL;
      }

    return (1);
  }


int JNL_close_echo ()
  {
    if (JNL_echo != NULL)
      {
        fclose (JNL_echo);
        JNL_echo = NULL;
      }

    return (1);
  }


int JNL_record_input (nbytes, buffer)
  int  nbytes;
  char *buffer;
  {
    int    status;

    if (JNL_record)
      {
        status = 0;
        status = fwrite (buffer, nbytes, 1, JNL_record);
        status = fflush (JNL_record);
      }

    return (1);
  }


int JNL_echo_input (nbytes, buffer)
  int  nbytes;
  char *buffer;
  {
    int    status;
    
    status = 0;

    if (JNL_echo)
      {
         status = fread (buffer, nbytes, 1, JNL_echo);   

         if ( !status )
           {
             status = 1; /*  eof retruns 1 because tools returns 0 for good  */
                         /*hardware input*/
             JNL_echo = 0;
             fclose (JNL_echo);
           }
         else
           {
            status = 0;/*status = 0 have an event*/
           }
      }

    return (status);
  }

int JNL_adjust_echo ()
  {
    int    status;

    status = 1;

    if (JNL_echo)
      {
        status = fseek (JNL_echo, -4, 1);
      }

    return (status);
  }

int JNL_adjust_echo_button ()
  {
    int    status;
    int    nbytes;

    nbytes = -(sizeof (struct echo_button));
    status = 1;

    /*  Number bytes in button  */

    if (JNL_echo)
      {
        status = fseek (JNL_echo, nbytes, 1);
      }

    return (status);
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

int JNL_wait_for_next (mask, event)
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


int JNL_inq_events (event)
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

int JNL_inq_button_data (window, x, y, btype, state, timetag)
  int *window;
  int *x;
  int *y;
  int *btype;
  int *state;
  int *timetag;
  {
    int    status;
    struct echo_button button;
 
    status = 0;
    if (JNL_echo)
   {
     JNL_echo_input (sizeof (struct echo_button), (char *) &button);
     JNL_adjust_echo_button ();
     JNL_oldwindow_to_window (button.window, window);
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
     JNL_echo_input (sizeof (struct echo_button), (char *) &button);
     JNL_echo_read_event = 0;  /*  ready to read next event  */
     JNL_oldwindow_to_window (button.window, window);
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

  if (JNL_record)
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
 int status;
 
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

  if (JNL_record)
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

  if (JNL_record)
  { 
  JNL_record_event(COLLAPSE_EVENT);
  button.window = *window;
  button.opmask = *opmask;

  JNL_record_input( sizeof (struct echo_collapse_button), (char *) &button);
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

  if (JNL_record)
  { 
  JNL_record_event(DELETE_EVENT);
  button.window = *window;
  JNL_record_input( sizeof (struct echo_delete_button), (char *) &button); 
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

if (JNL_record)
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

if (JNL_record)
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
int status;
int type;
int i;
int done;

status = Start_timer(delta_time, repeatflag, timer_no);

status = 0;
done = 0;
if ( JNL_echo )
 {
 for ( i = 0 ; i < TIMER_MAX_COUNT ; i++ )
   {
   if (( !jnl_timer_no[i].used ) && !(done))
    {
    jnl_timer_no[i].used = 1;    
    jnl_timer_no[i].current = *timer_no;    
    JNL_echo_input(4, (char *) &type );/*user event*/
    JNL_echo_input(4, (char *) &type );/*type = timer_event*/
    JNL_echo_input(4, (char *) &jnl_timer_no[i].previous );
    done = 1;
    }
  }/*end for*/
 }/*end if echo*/

if ( JNL_record )
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
return(0);
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
      JNL_echo_input( *count, key_buffer);/*input from file*/
      JNL_echo_read_event = 0;/*ready to read next event*/
    }
else
    {
     status = Get_keyboard_data(count);
    }

if ( JNL_record )
    {
    JNL_record_event ( KEYBOARD_EVENT );
    JNL_record_input ( 1, (char *) count );
    JNL_record_input ( *count, key_buffer );
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
      JNL_echo_input(*count, key_buffer);/*input from file*/
      fseek(JNL_echo, -( *count + 1 ) , 1);/*+1 for #bytes*/
    }
else
    {
     status = Inq_keyboard_data(count);
    }


return(status);
}

int JNL_inq_keyboard_buffer( buf_addr,  count)
char **buf_addr;
int *count;
{
int status;

status = 0;
if (JNL_echo)
    {
      *count = 0;        
      JNL_echo_input ( 1, (char *) count );
      JNL_echo_input(*count, key_buffer);/*input from file*/
      buf_addr = (char **) key_buffer;
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

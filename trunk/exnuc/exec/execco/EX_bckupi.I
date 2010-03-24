class implementation EX_bckup;
#include "exsysdep.h"
#include <execmsg.h>
#include <stdio.h>
#include <stdlib.h>
#include <exproto.h>

#define debug 0

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
%safe
#include <X11/Intrinsic.h>
%endsafe
#endif

extern int timer_no;
extern int EX_time_for_backup;
%safe
static int backup_time = 0;
%endsafe


#ifdef X11
static unsigned long xtime;
%safe
static XtIntervalId xtimer;
extern Widget   EXtoplevel;
%endsafe
#endif


#ifdef X11
%safe
void EX_Xtimeout(w,xtimer_local)
XtPointer w;
XtIntervalId *xtimer_local;
{
    EX_time_for_backup = TRUE;
    *xtimer_local = XtAppAddTimeOut((XtWidgetToApplicationContext(EXtoplevel)),
                                            xtime,EX_Xtimeout,
                                            w);
    xtimer = *xtimer_local;
}
%endsafe
#endif

/*************************************************************************/
/************************* EX_bckup wakeup method ***********************/
/*************************************************************************/

method wakeup(int pos)
{

/*    UI_message("SET BACKUP TIME"); */
      ex$message(msgnumb = EX_M_SetBckTime);
    
    return(OM_S_SUCCESS);
}

/*************************************************************************/
/***************************** EX_bckup execute method ******************/
/*************************************************************************/

method execute(int *response; char *response_data; int pos)
{
#ifdef ENV5
  int status;
#endif
  char mess[128];
  int hr,min,sec;
  int not_exit;

  not_exit = TRUE;
  hr = min = sec = 0;

  while( not_exit )
  {
     switch(ME.super_cmd->state)
     {
       case 0:

/*         UI_prompt("Enter timed backup interval   hh[:mm[:ss]] :"); */
         ex$message(msgnumb = EX_P_EntBckTime,justification = RIGHT_JUS);
         
         hr=backup_time/3600;
	 min = (backup_time - hr * 3600 )/60;
	 sec = backup_time - hr*3600 - min*60;

         sprintf(mess,"Original Backup Time Interval : %02.2d:%02.2d:%02.2d",
                        hr,min,sec);

         ex$message(msgnumb = EX_S_Var1, type="%s", var=mess);



         EX_get_keyin(response,response_data,0);

         if( *response == STRING )
	 {
             ex$message( msgnumb = EX_S_Clear);
             if ( sscanf( response_data,"%ld:%ld:%ld", &hr, &min, &sec) < 1)
	     {
                  ex$message(msgnumb = EX_S_TryAgain);
	     }
	     else
	     {
                sprintf(mess,"Backup Time Interval : %02.2d:%02.2d:%02.2d",
                        hr,min,sec);
                ex$message(msgnumb = EX_S_Var1, type="%s", var=mess);
#ifndef NT
                sleep(2);
#else
                _sleep(2);
#endif
                backup_time = sec;
                backup_time += (min * 60);
		backup_time += (hr * 3600);
                if (backup_time > 0)
                {
#ifdef ENV5
                  int junk;
                  junk = backup_time * 60;
                  if( timer_no != -1 ) JNL_stop_timer( timer_no);
                  status = JNL_start_timer (junk, 1, &timer_no);
                  if( status != 0 ) printf("Backup Timer not started\n");
#endif
#ifdef X11
    xtime = backup_time*1000; /*x timer in milliseconds*/
%safe
    xtimer = XtAppAddTimeOut((XtWidgetToApplicationContext(EXtoplevel)),
                                            xtime,EX_Xtimeout,
                                            (XtPointer)EXtoplevel);
%endsafe
#endif

                }
		else
		{
#ifdef ENV5
                    if( timer_no != -1 ) Stop_timer( timer_no);
#endif
		}
                not_exit = FALSE;
		*response = TERMINATE;
             }
	 }
         else if(*response == RESET)
	 {
             EX_init_keyboard();
	     UI_echo(" ");    
	 }
         else if ( *response == D_RESET )
	 {
             not_exit = FALSE;
	     *response = TERMINATE;
	 }
         else
	 {
             not_exit = FALSE;
	 }
	 break;

       default:
         break;
     }
  }
  return(OM_S_SUCCESS);
}

end implementation EX_bckup;

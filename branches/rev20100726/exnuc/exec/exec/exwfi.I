/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* change history: 

      11/24 86  HT : change to make kbdprocessor return multiple char
      11/25 86  HT : add hooks for input listener and generator
      6/8   87  HT : add check msgque for ipc message and put on soft queue
                     for fortran or other process
      7/23  87  HT : add EX_ALL_CHAR_MODE return raw key
      11/18 87  HT : add start end function call for CI	
                                                                         */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
class implementation exec;

#include "exsysdep.h"
#include <stdio.h>
#include <OMerrordef.h>
#include <string.h>
#include <exproto.h>


#ifdef ENV5
#include <tools.h>
%safe
#include <FIproto_pub.h>
%endsafe
#endif

#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <msmacros.h>
#include <igewinmacros.h>
#include <igewindef.h>
#include <igewindow.h>
#include "wl.h"

#ifdef X11
#include <journal.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <sys/time.h>
%safe
#include <XFIproto_pub.h>
%endsafe

#if defined( CLIX )
#include <X11/extensions/XDigitizer.h>
#endif

%safe
#include <X11/Intrinsic.h>
%endsafe

#include <limits.h>
#include <signal.h>

extern int select();
#endif

from IGEingen   import generate;
from IGEinlisnr import listen;

extern int EX_logkbd;
extern int EX_time_for_backup;

#define ESCAPE_key 033

#ifdef X11
extern Display *EXdisplay;
extern unsigned int EX_button_state;
extern Window   EX_prim_win_no;
extern long EX_stopproc_id;
extern int FIdecode();


struct clp_icon
{
   IGRlong      *msg;
   IGRint       *opmask;
};

extern  struct timeval EXtimeout;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* Button types */

#define		UP		0		/* up		*/
#define		DOWN		1		/* down		*/
#define		SINGLE_CLICK	2		/* click	*/
#define		DOUBLE_DOWN	3		/* double down	*/
#define		DOUBLE_CLICK	4		/* double click	*/
#define		TRIPLE_DOWN	5		/* triple down	*/
#define		UP_DOWN_UP	6		/* up down up	*/
#define		UP_DOWN		7		/* up down	*/

#define		TIMEOUT		999		/* timeout	*/


#define EX_WIN_MASK (ButtonPressMask | ButtonReleaseMask | \
                     KeyPressMask    |  EnterWindowMask  | \
                     LeaveWindowMask | \
                     ExposureMask     |  StructureNotifyMask )

/* IF you changed EX_WIN_MASK be sure to change it in
                 DPwnactivate.I  exwfi.I dp(tx)dynamics.I */

%safe
extern Widget   EXtoplevel;
static int EX_wfi_debug = 0;
char *EX_event_name[] = { "0","1",
"KeyPress",             /* 2 */
"KeyRelease",           /* 3 */
"ButtonPress",          /* 4 */
"ButtonRelease",        /* 5 */
"MotionNotify",         /* 6 */ 
"EnterNotify",          /* 7 */
"LeaveNotify",          /* 8 */
"FocusIn",              /* 9 */
"FocusOut",             /* 10 */
"KeymapNotify",         /* 11 */
"Expose",               /* 12 */
"GraphicsExpose",       /* 13 */ 
"NoExpose",             /* 14 */
"VisibilityNotify",     /* 15 */
"CreateNotify",         /* 16 */
"DestroyNotify",        /* 17 */
"UnmapNotify",          /* 18 */
"MapNotify",            /* 19 */
"MapRequest",           /* 20 */
"ReparentNotify",       /* 21 */
"ConfigureNotify",      /* 22 */
"ConfigureRequest",     /* 23 */
"GravityNotify",        /* 24 */
"ResizeRequest",        /* 25 */
"CirculateNotify",      /* 26 */
"CirculateRequest",     /* 27 */
"PropertyNotify",       /* 28 */
"SelectionClear",       /* 29 */
"SelectionRequest",     /* 30 */
"SelectionNotify",      /* 31 */
"ColormapNotify",       /* 32 */
"ClientMessage",        /* 33 */
"MappingNotify",        /* 34 */
"LASTEvent"             /* 35 */
"36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53", /* 53 */
"54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71", /* 71 */
"72","73","74","75","76","77","78","79","80","81","82", /* 82 */
"DigPointerMotion",   /* 83 */
"DigEnterRegion",   /* 84 */
"DigLeaveRegion",   /* 85 */
"DigButtonPress",   /* 86 */
"DigButtonRelease", /* 87 */
"DigButtonTimedout",/* 88 */
"DigNumberOfEvents",/* 89 */
"90",
"91",
"92",
"93",
"94",


};

#if defined( X11 )
#if defined( IRIX )
static int  X_WAIT_TIME = 700;            /* time to wait for button */
                                          /* event time on IRIX      */
#else
static int  X_WAIT_TIME = 500;            /* time to wait for button */
                                          /* event time on SUN       */
#endif
#endif
%endsafe

#endif
extern int timer_no;
extern OM_S_OBJID EX_exec_id;
extern OMuword    EX_exec_osnum;
extern struct EXevent_queue *event_queue_front;
extern int EX_index;
extern short EX_linebuffer_flag;
extern long  backup_event;
extern  char EX_keybuff[];
extern int EX_batch_mode;
extern unsigned int OM_Gf_mailbox;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method wait_for_input (  int *response;  char *response_data;
                           int mode;  int *num_bytes )
{

  int delta;
  int deltaq;
#ifdef X11
  XEvent current_event,myevent;
  Time prev_time;
  char *env, *getenv();
#endif
#ifdef ENV5
  int window;
  int icon_id;
  int current_events;
  static  int msgq_timer_started = 0;
  static  int msgq_timer = -1; 
#endif
  long msg;
  IGRlong ret_val;
  int no_bytes;
  int status;
  int num_char, old_num_char;
#ifndef NT
  int usage;
#endif
  int ended;
  int generator_exist, listener_exist;
  static OM_S_CHANSELECT to_generator, to_listener;
  static int init_done = 0;
  OMuint count;

#ifdef X11
  int transition;
#if defined( CLIX )

extern  int INGR_DigButtonPress;
extern  int INGR_DigButtonRelease;
extern  int INGR_DevButtonPress;
extern  int INGR_DevButtonRelease;
extern  int INGR_DevButtonPress_class;
extern  int INGR_DevButtonRelease_class;

  XDeviceButtonEvent *devent;  
  XDeviceButtonEvent my_devent;  

/*  commented out
  int INGR_DigEnterRegion;
  int INGR_DigLeaveRegion;
  int INGR_DigPointerMotion;
  int INGR_DigButtonTimeout;
  int INGR_DigNumberOfEvents;
*/

#endif

%safe
  XtAppContext appContext;
%endsafe  
#endif
  
  EX_linebuffer_flag = 0; 
  response_data[0] = '\0';
  old_num_char = 0;
  delta = 180; /* 3 seconds for check timer event */
  deltaq = 1;/*timer for mailbox*/
  status = OM_S_SUCCESS;
  generator_exist = 0;   /* no generators */
  listener_exist  = 0;   /* no listener   */

  /* get mouse button speed environment variable, if available */
#ifdef X11
  env = getenv("MOUSE_SPEED");
  if( env)
  {
    sscanf(env, "%d", &X_WAIT_TIME);
  }
/*
printf( "mouse speed = %d\n", X_WAIT_TIME);
*/
#endif

  if (!init_done)
  {
    int ret_stat;
    
    init_done = 1;
    to_generator.type = OM_e_num;
    to_listener.type = OM_e_num;
    ret_stat = om$get_channel_number ( channame = "exec.to_generator",
                                       p_channum = &to_generator.u_sel.number );
    if (ret_stat != OM_S_SUCCESS)
      om$report_error ( sts = ret_stat );
    ret_stat = om$get_channel_number ( channame = "exec.to_listener",
                                       p_channum = &to_listener.u_sel.number );
    if (ret_stat != OM_S_SUCCESS)
      om$report_error ( sts = ret_stat );
  }

  status = om$get_channel_count(osnum = EX_exec_osnum,
                            objid = EX_exec_id,
                           p_chanselect = &to_generator,
                           count = &count   );
  if( !(1 & status))
  {
      om$report_error(sts = status);
      printf("wfi get generator chan count error\n");
  }
  else if( count)
  {
     generator_exist = 1;
  }

  status = om$get_channel_count(osnum = EX_exec_osnum,
                            objid = EX_exec_id,
                           p_chanselect = &to_listener,
                           count = &count   );
  if( !(1 & status))
  {
      om$report_error(sts = status);
      printf("wfi get generator chan count error\n");
  }
  else if( count)
  {
     listener_exist = 1;
  }

  num_char = 0;
#ifdef X11
%safe  
  appContext = XtWidgetToApplicationContext(EXtoplevel);

%endsafe
#endif
  EX_call_start_func();/*this is called just once before we get input*/
  while(1)
  {
     if( generator_exist )
     { 
        ended = 0;
        response_data[0] = '\0';
         /* there is a generator, get from generator */
        status = om$send( mode = OM_e_wrt_object,
            msg = message IGEingen.generate(response,response_data,num_bytes,&ended),
                 senderid = my_id,
                 p_chanselect = &to_generator,
                 targetos = OM_Gw_current_OS,
                     from = 0,
                       to = 0  );
        if(! (1&status) )
        {
            om$report_error(sts = status);
            printf("wfi get generator generate error\n");
        }  
        else
        {
            if( ended )
            {
               generator_exist = 0;
                status = om$send( mode = OM_e_wrt_object,
                    msg = message Root.delete(0),
                         senderid = my_id,
                         p_chanselect = &to_generator,
                         targetos = OM_Gw_current_OS,
                             from = 0,
                               to = 0  );
               if( ! (1&status))
               {
                  printf("\n IN exwfi delete generator error \n");
                  om$report_error(sts = status);
               }
            }
            if (listener_exist )
            {
                status = om$send( mode = OM_e_wrt_object,
                msg = message IGEinlisnr.listen(response,response_data,num_bytes),
                         senderid = my_id,
                     p_chanselect = &to_listener,
                         targetos = OM_Gw_current_OS,
                             from = 0,
                               to = 0  );
                if(! (1&status) )
                {
                    om$report_error(sts = status);
                    printf("wfi in generator exist send to listener error\n");
                }  
            }
            EX_call_end_func();
            return(1);
        }              
    }
    else
    if (event_queue_front) /* something in the queue */
    {
        int send_to_rap;

	send_to_rap = 0; 
        no_bytes = 1024;
        ret_val = EXgetq(&msg,response,&no_bytes,response_data);
        *num_bytes = no_bytes;

        if(*response == EX_FORM_DATA)
	{
	    FI_manipulate_form( response_data );
	}
        if( (*response & EX_HARDWARE_GENERATED) ==  EX_HARDWARE_GENERATED )
	{
	   send_to_rap = 1;
	   *response = *response & (~EX_HARDWARE_GENERATED);
	}

        if ( listener_exist  && send_to_rap )
        {
           send_to_rap = 0;
           status = om$send( mode = OM_e_wrt_object,
            msg = message IGEinlisnr.listen(response,response_data,num_bytes),
                     senderid = my_id,
                 p_chanselect = &to_listener,
                     targetos = OM_Gw_current_OS,
                         from = 0,
                           to = 0  );
            if(! (1&status) )
            {
                om$report_error(sts = status);
                printf("wfi que not empty send to listener error\n");
            }  
        }
        EX_call_end_func();

       return(1);
    } 


    if (  !EX_batch_mode && ((mode & EX_ALL_ASCII_MODE)
                                  && (EX_logkbd) && (num_char) ))
    {
        /*this was a cludge put in for 16bit edit text*/
        /* all character mode */
        EX_call_end_func();
        *response = STRING;
        *num_bytes = strlen(response_data) +1;
        if (listener_exist )
        {
           status = om$send( mode = OM_e_wrt_object,
           msg = message IGEinlisnr.listen(response,response_data,num_bytes),
                                 senderid = my_id,
                             p_chanselect = &to_listener,
                                 targetos = OM_Gw_current_OS,
                                     from = NULL,
                                       to = NULL  );
           if(! (1&status) )
           {
               om$report_error(sts = status);
               printf("wfi EX_all_char_mode send to listener  error\n");
           }  
        }

        return(1);
    }  

    if ( !EX_batch_mode && !(mode & EX_ALL_CHAR_MODE)
                      && (EX_linebuffer_flag) )
    {
      EX_call_end_func();

      /* EX_linebuffer_flag is set when <CR> is hit */
      /* function to extract string up to <CR> */

      /* stuff from logical keyboard  are not in EX_keybuff */
      if (  EX_is_logkbd_inactive() ) 
      {
         if(EX_keybuff[0] != ESCAPE_key)
         {
            *response = STRING;
	    strcpy(response_data,EX_keybuff);
         }
         else
         {
            *response = CMD_STRING;
	    strcpy(response_data,&EX_keybuff[1]);
         }
      }
      else *response = STRING;  /* from logkbd */

      *num_bytes = strlen(response_data)+1;
      EX_init_keyboard();

      if (listener_exist )
      {
         status = om$send( mode = OM_e_wrt_object,
         msg = message IGEinlisnr.listen(response,response_data,num_bytes),
                               senderid = my_id,
                           p_chanselect = &to_listener,
                               targetos = OM_Gw_current_OS,
                                   from = 0,
                                     to = 0  );
         if(! (1&status) )
         {
             om$report_error(sts = status);
             printf("wfi EX_char_mode line_buffer_flag send to listener  error\n");
         }  
      }

      return(1);

    }/* linebuffer flag */

    else
    if (  !EX_batch_mode && ( (mode & EX_ALL_CHAR_MODE) ||
                              (mode & EX_ALL_ASCII_MODE) )   && (num_char) )
    {
        /* all character mode */
        EX_call_end_func();
        *response = EX_CHAR;
        *num_bytes = strlen(response_data) ;
        if (listener_exist )
        {
           status = om$send( mode = OM_e_wrt_object,
           msg = message IGEinlisnr.listen(response,response_data,num_bytes),
                                 senderid = my_id,
                             p_chanselect = &to_listener,
                                 targetos = OM_Gw_current_OS,
                                     from = 0,
                                       to = 0  );
           if(! (1&status) )
           {
               om$report_error(sts = status);
               printf("wfi EX_all_char_mode send to listener  error\n");
           }  
        }

        return(1);
    }  
  else
    {
      if( OM_Gf_mailbox )
      {
           EX_process_msgque();
      }
#ifdef ENV5
        if( ! msgq_timer_started  && OM_Gf_mailbox )
        {
           status = Start_timer(deltaq,1,&msgq_timer);
           msgq_timer_started = TRUE;
        }
#endif 



#ifdef X11
        JNL_XtAppNextEvent( appContext, &current_event );

/*
printf("current_event.type=<%d> window=<%x> p=<%x> %s\n",current_event.type ,current_event.xany.window,EX_prim_win_no, EX_event_name[current_event.type]);
*/
        if (current_event.type == KeyPress   )
        {
               status =  FI_process_event( &current_event, 1 );
               if ( status )
                 continue;
               usage  = 0;
               EX_linebuffer_flag = 0; /* flag will be set either in process
                                          return or in logical kbd return  */
               num_char = 0;
               status = EX_get_kbd_input(&current_event,response_data,&num_char, mode);
               if(( status == 1 ) || ( status == 3 )) /* ordinary key */
               {
                   if (usage != 0) /* form used the input */
                   {
                       EX_linebuffer_flag = 0;              
                       num_char = 0;
                   }
                   else if ((mode != EX_ALL_CHAR_MODE ) &&
                            (mode != EX_ALL_ASCII_MODE ) )
                   {
                       EX_keybd_process_return(response_data,num_char);
                       num_char = strlen(response_data) ;/*may have changed*/
                   } 
    
               } /*keyboard event*/
        }
        else if  ( current_event.type == ButtonPress   ) 
        {
/*
printf("Got ButtonPress\n");
*/
            transition=DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=current_event.xbutton.time;
            EX_button_state = current_event.xbutton.state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= JNL_XCheckWindowEvent(EXdisplay,
                                          current_event.xbutton.window,
                                          ButtonReleaseMask,
                                          &myevent);

	    if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< X_WAIT_TIME))
	    {
		transition=SINGLE_CLICK;
    		prev_time=myevent.xbutton.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=JNL_XCheckWindowEvent(EXdisplay,
                                             current_event.xbutton.window,
                                   	     ButtonPressMask,
                                             &myevent);

  		if(status && (((unsigned int)myevent.xbutton.time -
                                       (unsigned int) prev_time)< X_WAIT_TIME))
                {
	           transition=DOUBLE_DOWN;
		   prev_time=myevent.xbutton.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=JNL_XCheckWindowEvent(EXdisplay,
                                                current_event.xbutton.window,
                                                ButtonReleaseMask,
                                                &myevent);
  		   if(status && (((unsigned int)myevent.xbutton.time -
                                       (unsigned int) prev_time)< X_WAIT_TIME))
               	   {
		       transition=DOUBLE_CLICK;
    		       prev_time=myevent.xbutton.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckWindowEvent(EXdisplay,
                                                   current_event.xbutton.window,
                                                   ButtonPressMask,
                                                   &myevent);
     		       if(status && (((unsigned int)myevent.xbutton.time -
                                       (unsigned int) prev_time)< X_WAIT_TIME))
                       {
		          transition=TRIPLE_DOWN;
		       }
		   }
	       }
           }

  	   if(status &&
              (((int)myevent.xbutton.time - (int) prev_time)> X_WAIT_TIME))
           {
             /*if time difference > 150 need to out it back*/
              JNL_XPutBackEvent(EXdisplay,&myevent);
           }
           if( transition != -1 )
	   {
              status =  FI_process_event( &current_event, transition );
/*
printf("after calling FI_process_event status = <%d> \n",status);       
*/

              if ( ! status )
              {
/*
printf("Call EX_button_AST transition=%d\n", transition);
*/
                 EX_button_AST(response,
                               response_data,
                               &current_event,
                               transition);
              }
	   }
        }
#if defined( CLIX )

        else if ( current_event.type == INGR_DigButtonPress   ) 
        {
/*
printf("Got INGR_DigButtonPress %d at %d %d window=%x\n", current_event.xbutton.button,
            current_event.xbutton.x, current_event.xbutton.y,
            current_event.xbutton.window);
*/
                                                                        
            transition=DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=current_event.xbutton.time;
            EX_button_state = current_event.xbutton.state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= JNL_XCheckTypedWindowEvent(EXdisplay,current_event.xbutton.window,
                                 INGR_DigButtonRelease,&myevent);
	    if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< 150))
	    {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		transition=SINGLE_CLICK;
    		prev_time=myevent.xbutton.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=JNL_XCheckTypedWindowEvent(EXdisplay, current_event.xbutton.window,
                                 INGR_DigButtonPress,&myevent);
  		if(status && (((unsigned int)myevent.xbutton.time -
                                               (unsigned int) prev_time)< 150))
                {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
	           transition=DOUBLE_DOWN;
		   prev_time=myevent.xbutton.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                       current_event.xbutton.window,
                                       INGR_DigButtonRelease,&myevent);
  		   if(status && (((unsigned int)myevent.xbutton.time -
                                             (unsigned int) prev_time)< 150))
               	   {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		       transition=DOUBLE_CLICK;
    		       prev_time=myevent.xbutton.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                        current_event.xbutton.window,
                                        INGR_DigButtonPress,&myevent);
     		       if(status && (((unsigned int)myevent.xbutton.time -
                                            (unsigned int) prev_time)< 150))
                       {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		          transition=TRIPLE_DOWN;
		       }
		   }
	       }
           }

  	   if(status && (((int)myevent.xbutton.time - (int) prev_time)> 150))
           {
             /*if time difference > 150 need to out it back*/
              JNL_XPutBackEvent(EXdisplay,&myevent);
           }
           if( transition != -1 )
	   {
              status =  FI_process_event( &current_event, transition );
/*
printf("after calling FI_process_event status = <%d> \n",status);       
*/
              if ( ! status )
              {
/*printf("DIG BUTTON Call EX_button_AST transition=%d\n", transition);*/
                 EX_button_AST(response,response_data ,&current_event, transition);
              }
	   }
        }
        else if ( current_event.type == INGR_DevButtonPress   ) 
        {
/*printf("Got INGR_DevButtonPress\n");*/

	    devent = ( XDeviceButtonEvent *) &current_event;
	    
            transition=DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=devent->time;
            EX_button_state = devent->state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= JNL_XCheckTypedWindowEvent(EXdisplay,devent->window,
                                 INGR_DevButtonRelease,(XEvent *)&my_devent);
	    if(status && (((unsigned int)my_devent.time - 
                            (unsigned int) prev_time)< 150))
	    {
		transition=SINGLE_CLICK;
    		prev_time=my_devent.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=JNL_XCheckTypedWindowEvent(EXdisplay, devent->window,
                                 INGR_DevButtonPress,(XEvent *)&my_devent);
  		if(status && (((unsigned int)my_devent.time -
                                               (unsigned int) prev_time)< 150))
                {
	           transition=DOUBLE_DOWN;
		   prev_time=my_devent.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                       devent->window,
                                       INGR_DevButtonRelease,
                                       (XEvent *)&my_devent);
  		   if(status && (((unsigned int)my_devent.time -
                                             (unsigned int) prev_time)< 150))
               	   {
		       transition=DOUBLE_CLICK;
    		       prev_time=my_devent.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                        devent->window,
                                        INGR_DevButtonPress,
                                        (XEvent *)&my_devent);
     		       if(status && (((unsigned int)my_devent.time -
                                            (unsigned int) prev_time)< 150))
                       {
		          transition=TRIPLE_DOWN;
		       }
		   }
	       }
           }

  	   if(status && (((int)my_devent.time - (int) prev_time)> 150))
           {
             /*if time difference > 150 need to out it back*/
              JNL_XPutBackEvent(EXdisplay,(XEvent *)&my_devent);
           }
           if( transition != -1 )
	   {
              status =  FI_process_event( &current_event, transition );
/*
printf("after calling FI_process_event status = <%d> \n",status);       
*/
              if ( ! status )
              {
/*printf("DIG BUTTON Call EX_button_AST transition=%d\n", transition);*/
                 EX_button_AST(response,response_data ,&current_event, transition);
              }
	   }
        }
#endif
        else if (current_event.type == Expose   )
        {
               transition = -1;
               if( ! FI_process_event(&current_event, transition ) )
               {
                      DPhandle_event( &current_event);
                      EX_call_end_func();
               }
        }
        else if ( (current_event.type == ConfigureNotify ) ||
                  (current_event.type == DestroyNotify   ) ||
                  (current_event.type == MapNotify       ) ||
                  (current_event.type == UnmapNotify     ) ||
                  (current_event.type == VisibilityNotify ))
        {
/*printf("VVVVcurrent_event.type=<%d> window=<%x>\n",current_event.type ,current_event.xany.window);*/
               transition = -1;
               if( ! FI_process_event(&current_event, transition ) )
               {
                      DPhandle_event( &current_event);
                      EX_call_end_func();
               }
        }
        else if (current_event.type == ClientMessage )
        {
/*	    prologue (&current_event, "ClientMessage");*/
            DPhandle_event( &current_event);
        }
        else if (current_event.type == EnterNotify )
        {
/*	    prologue (&current_event, "EnterNotify");*/
        }
        else if (current_event.type == MotionNotify )
        {
            while( JNL_XCheckMaskEvent(EXdisplay,ButtonMotionMask, &current_event));
        }
        else if ( (current_event.type == LeaveNotify )       ||
                  (current_event.type == KeyRelease )        ||
                  (current_event.type == ButtonRelease )     ||
                  (current_event.type == ColormapNotify )    ||
                  (current_event.type == FocusIn)            ||
                  (current_event.type == FocusIn)            ||
                  (current_event.type ==  FocusOut )         ||
                  (current_event.type ==  KeymapNotify )     ||
                  (current_event.type ==  GraphicsExpose )   ||
                  (current_event.type ==  NoExpose )         ||
                  (current_event.type ==  CreateNotify )     ||
                  (current_event.type ==  MapRequest )       ||
                  (current_event.type ==  ReparentNotify )   ||
                  (current_event.type ==  ConfigureRequest ) ||
                  (current_event.type ==  GravityNotify )    ||
                  (current_event.type ==  ResizeRequest )    ||
                  (current_event.type ==  CirculateNotify )  ||
                  (current_event.type ==  CirculateRequest ) ||
                  (current_event.type ==  PropertyNotify )   ||
                  (current_event.type ==  SelectionClear )   ||
                  (current_event.type ==  SelectionRequest ) ||
                  (current_event.type ==  SelectionNotify )  ||
#if defined( CLIX )
                  (current_event.type == INGR_DigButtonRelease   ) ||
                  (current_event.type == INGR_DevButtonRelease   ) ||
/*
                  (current_event.type ==  INGR_DigPointerMotion  ) ||
                  (current_event.type ==  INGR_DigEnterRegion    ) ||
                  (current_event.type ==  INGR_DigLeaveRegion    ) ||
*/
#endif
                  (current_event.type ==  MappingNotify )    )
	{
	}
        else
	{
/*	    printf ("Unknown event type %d\n", current_event.type);*/
            if (JNL_playback())
            {
               printf("mismatch in journaling events, playback exited\n");
               JNL_close_echo();
            }
            else
            {
               XtDispatchEvent(&current_event);
            }
	} /* end of switch */

#endif
#ifdef ENV5
        if( EX_batch_mode )
	{
	   EX_wait_for_next( TIMER_EVENT, &current_events);
	}
	else
	{
	    EX_wait_for_next(( BUTTON_EVENT  |  KEYBOARD_EVENT |
			    REFRESH_EVENT |  DELETE_EVENT   |
			    COVER_EVENT   |  COLLAPSE_EVENT |
			    EXTRA_EVENT   |  TIMER_EVENT |
			    WINDOW_USER_ICON_EVENT | USER_EVENT | SWAPVS_EVENT ), 
			    &current_events);
        }
     

        if (current_events & KEYBOARD_EVENT)
        {

           usage  = 0;
           EX_linebuffer_flag = 0; /* flag will be set either in process
	                              return or in logical kbd return  */
	   num_char = 0;
           status = EX_get_kbd_input(response_data,&num_char, mode);
           if(( status == 1 ) || ( status == 3 )) /* ordinary key */
           {
	       if (usage != 0) /* form used the input */
	       {
                   EX_linebuffer_flag = 0;		
	           num_char = 0;
	       }
               else if ((mode != EX_ALL_CHAR_MODE ) &&
	                (mode != EX_ALL_ASCII_MODE ) )
               {
                   EX_keybd_process_return(response_data,num_char);
                   num_char = strlen(response_data) ;/*may have changed*/
               } 

           } /*keyboard event*/
        }


        if (current_events & BUTTON_EVENT)
        {
            status =  FI_process_event( current_events );

            if ( ! status )
            {
                EX_button_AST(response,response_data);
            }
        }

        if((current_events & REFRESH_EVENT) |
           (current_events & DELETE_EVENT)  |
           (current_events & COVER_EVENT)   |
           (current_events & COLLAPSE_EVENT))
        {
           if( ! FI_process_event( current_events ) )
           {
              DPhandle_event();
    	      EX_call_end_func();
	   }
        }  
        if(current_events & USER_EVENT )  
        {
           if( ! FI_process_event( current_events ) )
           {
            /*if in playback mode and forms does not eat user event
              we will*/
            JNL_get_user_data(&window);
    	    EX_call_end_func();
	   }
        }  


        if (current_events & WINDOW_USER_ICON_EVENT )
        {
           if( ! FI_process_event( current_events ) )
           {
            JNL_get_win_user_icon_data(&window, &icon_id);
    	    EX_call_end_func();
	   }
        }  



        if (current_events & TIMER_EVENT)
        {
           int temp_timer_no;
           int event;
           int finished;
           finished = 0;
            JNL_echo_timer_data(&temp_timer_no);
            if(temp_timer_no == msgq_timer)
            {    
/*                Stop_timer(msgq_timer);   */
/*                msgq_timer_started = FALSE;*/
            }
            else if (temp_timer_no == timer_no)
            {
             /*backup will now be handled when the stack is
                           clear in cmdserver*/
                EX_time_for_backup = TRUE;

   	            JNL_record_timer_data(&timer_no);
            }
            while( !finished)
            {
                Inq_events(&event);
                if( event & TIMER_EVENT)
                {
                    JNL_echo_timer_data(&temp_timer_no);
        
             
                    if(temp_timer_no == msgq_timer)
                    {  
/*                      Stop_timer(msgq_timer);   */
/*                        msgq_timer_started = FALSE;*/
                    }
                    else if (temp_timer_no == timer_no)
                    {
   	                    JNL_record_timer_data(&timer_no);
                        EX_time_for_backup = TRUE;
                        }
                }
                else
                {
                    finished = 1;
                }
            }                    
/*            printf("getting out of timer event\n");   */

        }

      if ( current_events & SWAPVS_EVENT )
         {
         Clear_swapvs_data();
         MS_paint_area();/*may have garbage on back screen*/
         }

#endif
     } /* end if hardware data */
  } /*end while*/
}/*EX_wait_for_input*/

#define FUNCTION_KEY 0xfffffffe

extern int FI_keyin_needed();
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
int EX_record_new_window( window )
#ifdef ENV5
int window;
#endif
#ifdef X11
Window  window;
#endif
{
   JNL_record_new_window( window );
   return(1);
}

#ifdef ENV5
int EX_dyn_process_input_event (mask) 
/* return 0 if something dyn cannot handle */
/* return 1 stay in dyn */
int mask;  /* mask of events to check, 0 means every event */
{
  int response; 
  double dummy[32];
  char *response_data;
  int mode;

  int current_events;
  int status;
  int num_char;

  response_data = (char *)dummy;
  mode = 1;
  response_data[0] = '\0';
  EX_linebuffer_flag = 0; 
  status = OM_S_SUCCESS;
  
  num_char = 0;

    if (event_queue_front) /* something in the queue */
    {
       return(0);
    }
    else /* event queue empty */
    {
        EX_inq_events(&current_events);
        if (mask == 0 ) mask = 0xffffffff; 
        if (current_events & KEYBOARD_EVENT & mask )
        {
           return(0); /* This better work Herman. */
        } /*keyboard event*/
        else if (current_events & BUTTON_EVENT & mask )
        {
            /* originally calling MS_process_event to handle both
	       OM form and C form  ( FI_process_event was called inside MS_process_event)
               since MS_process_event call is missing, EX_get_win_class is used
	       to find out if the data point is for OM based form  */
	       
            status =  FI_process_event( current_events );
            if ( ! status )
            {
                char class_name[24];
		int window,x,y,btype,state,timetag;
                window = -200;
                EX_inq_button_data(&window,&x,&y,&btype,&state,&timetag);
		if (window != -200 )
		{
                   EX_get_win_class( window,class_name);

		   if(  !strcmp(class_name, "IGEwindow" ) )
		   {
                      EX_button_AST(&response,response_data);
                      return(1);
		   }
		}
                return(0);
            }
        }
        else if (current_events & TIMER_EVENT & mask)
        {
           int temp_timer_no;

           JNL_echo_timer_data(&temp_timer_no);
           if (temp_timer_no == timer_no)
           {
                JNL_record_timer_data(&timer_no);
                EX_time_for_backup = TRUE;
                return(0);
           }
        } 

        /* dpdynamics will handle window events */
	/* user may collapse/delete window, dynamics need to react */


        return(1);

     }  /* else event queue empty */

}/* EX_dyn_process_input */

int EX_wait_for_next(mask, event)
int mask;
int *event;
{
int status;
   status = JNL_wait_for_next(mask, event);
   if ( status )
   {
      UI_echo(" Playback has completed");
   }
   return(1);
}


int EX_inq_events(event)
int *event;
{
  int status;

  status = JNL_inq_events(event);
  return(status);
}

int EX_inq_button_data(window, x, y, btype, state, timetag)
int *window;
int *x;
int *y;
int *btype;
int *state;
int *timetag;
{
int status;

   status =  JNL_inq_button_data(window, x, y, btype, state, timetag);
   return(status);
}

int EX_get_button_data(window, x, y, btype, state, timetag)
int *window;
int *x;
int *y;
int *btype;
int *state;
int *timetag;
{
int status;

   status = JNL_get_button_data(window, x, y, btype, state, timetag);
   return(status);
}








int EX_get_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, ay2, opmask)
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
int status;

  status = JNL_get_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, ay2, opmask);
  return(status);
}


int EX_inq_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, ay2, opmask)
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

   int status;

   status = JNL_inq_refresh_area_data(window, vs_no, x, y, x2, y2, ax1, ay1, ax2, ay2, opmask);
   return(status);
}

int EX_get_collapse_data(window, opmask)
int *window;
int *opmask;
{
   int status;

   status = JNL_get_collapse_data(window, opmask);
   return(status);
}

int EX_inq_collapse_data(window, opmask)
int *window;
int *opmask;
{
   int status;

   status = JNL_inq_collapse_data(window, opmask);
   return(status);
}

int EX_get_delete_data(window)
int *window;
{
   int status;
   status =  JNL_get_delete_data(window);
   return(status);
}

int EX_inq_delete_data(window)
int *window;
{
   int status;

   status =  JNL_inq_delete_data(window);
   return(status);
}



int EX_set_keyboard_buffer ( buffer, count )
char *buffer;
int count;
{
   int status;

   status = JNL_set_keyboard_buffer ( buffer, count );
   return ( status );
}

int EX_get_keyboard_data ( count )
int *count;
{
   JNL_get_keyboard_data ( count );
   return(1);
}


int EX_inq_keyboard_data ( count )
int *count;
{
   int status;

   status =  JNL_inq_keyboard_data ( count );
   return(status);
}
#endif
#ifdef X11
int EX_dyn_process_input_event (mask) 
/* return 0 if something dyn cannot handle */
/* return 1 stay in dyn */
int mask; 
{
  int mode, response;
  double dummy[32];
  char *response_data;

  XEvent current_event,myevent;
  Time prev_time;

  int status;
  int num_char;
  int transition;
  Window window;
  WLuint32    lwin;
  OMuword     lwin_os;
  OM_S_OBJID  lwin_oid;

#if defined( CLIX )

extern  int INGR_DigButtonPress;
extern  int INGR_DigButtonRelease;
extern  int INGR_DevButtonPress;
extern  int INGR_DevButtonRelease;
extern  int INGR_DevButtonPress_class;
extern  int INGR_DevButtonRelease_class;

  XDeviceButtonEvent *devent;  
  XDeviceButtonEvent my_devent;  

/*  commented out
  int INGR_DigEnterRegion;
  int INGR_DigLeaveRegion;
  int INGR_DigPointerMotion;
  int INGR_DigButtonTimeout;
  int INGR_DigNumberOfEvents;
*/

#endif

%safe
  XtAppContext appContext;
  appContext = XtWidgetToApplicationContext(EXtoplevel);
%endsafe

  response_data = (char*)dummy;
  response_data[0] = '\0';

  mode = 1;
  EX_linebuffer_flag = 0; 
  status = OM_S_SUCCESS;
  
  num_char = 0;

  if (event_queue_front ) /* something in the queue */
  {
     return(0);
  }
  else /* event queue empty */
  {
      JNL_XtAppNextEvent( appContext, &current_event );
/*
if( EX_wfi_debug )
  printf("dyn current_event.type=<%d> window=<%x> p=<%x> %s\n",current_event.type ,current_event.xany.window,EX_prim_win_no, EX_event_name[current_event.type]);	  
*/
      switch( current_event.type)
      {
        case KeyPress :

           JNL_XPutBackEvent( EXdisplay,&current_event);
           if (mask == 0x08880000 ) /* stay in dyn for text */
    	    {
            /*this cludge is for dynamic text ant change in this should
              be  coordinated with bill cecil*/
            return(1);  
   	        }
           else
            {
            return(0);
            }

	  case ButtonRelease :
               return(1);
          case ButtonPress:
               EX_button_state = current_event.xbutton.state;
/*printf("EX_button_state=<%x> <%x>\n",EX_button_state,current_event.xbutton.state);*/

/*     printf("Dyn Got button  transition=<%d>\n",transition);*/
              window = current_event.xany.window;
              if (WL_SUCCESS != EX_trans_win(window, &lwin, &lwin_os, &lwin_oid))
	      {
		transition = DOWN;
		EXtimeout.tv_usec=150000;
		prev_time=current_event.xbutton.time;
		EX_button_state = current_event.xbutton.state;
		select(1,0,0,0,&EXtimeout);
	    	EXtimeout.tv_usec=150000;
	    	status= JNL_XCheckWindowEvent(EXdisplay,current_event.xbutton.window,
                                  		ButtonReleaseMask,&myevent);
	    	if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< X_WAIT_TIME))
	    	{
		  transition=SINGLE_CLICK;
    		  prev_time=myevent.xbutton.time;
		  select(1,0,0,0,&EXtimeout);
	          EXtimeout.tv_usec=150000;
   	          status=JNL_XCheckWindowEvent(EXdisplay, current_event.xbutton.window,
                                   		ButtonPressMask,&myevent);
  		  if(status && (((unsigned int)myevent.xbutton.time -
                                               (unsigned int) prev_time)< X_WAIT_TIME))
                  {
	            transition=DOUBLE_DOWN;
		    prev_time=myevent.xbutton.time;
	            select(1,0,0,0,&EXtimeout);
		    EXtimeout.tv_usec=150000;
                    status=JNL_XCheckWindowEvent(EXdisplay,
                                        current_event.xbutton.window,
                                              ButtonReleaseMask,&myevent);
  		    if(status && (((unsigned int)myevent.xbutton.time -
                                             (unsigned int) prev_time)< X_WAIT_TIME))
               	    {
		       transition=DOUBLE_CLICK;
    		       prev_time=myevent.xbutton.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckWindowEvent(EXdisplay,
                                        current_event.xbutton.window,
                                              ButtonPressMask,&myevent);
     		       if(status && (((unsigned int)myevent.xbutton.time -
                                            (unsigned int) prev_time)< X_WAIT_TIME))
                       {
		          transition=TRIPLE_DOWN;
		       }
		    }
	          }
                }

		if(status && (((int)myevent.xbutton.time - (int) prev_time)> X_WAIT_TIME))
		{
             		/*if time difference > 150 need to out it back*/
              		JNL_XPutBackEvent(EXdisplay,&current_event);
           	}

                if( transition != -1 )
		{
		    status = FI_process_event(&current_event, transition);
		    if( ! status )
		    {
                       EX_button_AST(&response,response_data ,&current_event, transition);
                    	/*     printf("Dyn button return 1\n"); */
		       return(1);
		    }
                }
	      }
	      else
	      {
                   JNL_XPutBackEvent(EXdisplay,&current_event);
		   return(0);
	      }
 
               break;

	  case EnterNotify:

	    /*prologue (&current_event, "DYN EnterNotify");*/

            status = WLget_logical_window ( current_event.xany.window, &lwin );
            if (status == WL_SUCCESS)
            {
/*printf("Dyn Enter graphic window <%d> hide cursor\n",lwin); */
               WLhide_cursor ( lwin, 1 );
	    }

	    break;

	  case LeaveNotify:
/*            XtAppNextEvent( appContext, &current_event );*/
	    /*prologue (&current_event, "DYN LeaveNotify");*/

            status = WLget_logical_window ( current_event.xany.window, &lwin );
            if (status == WL_SUCCESS)
            {
/*printf("Dyn Leave graphic window <%d> show cursor\n",lwin);   */
               WLshow_cursor ( lwin );
	    }
	    break;
	  case MotionNotify:

            while( JNL_XCheckMaskEvent(EXdisplay,ButtonMotionMask, &current_event));

	    break;

	  case Expose:
               transition = -1;

               FI_process_event(&current_event, transition);

               break;
          case KeyRelease:
	  case FocusIn:
	  case FocusOut:
	  case ColormapNotify:
	  case ReparentNotify:

	    break;
	  case ConfigureNotify:
	  case DestroyNotify:
          case MapNotify:
	  case UnmapNotify:
	  case VisibilityNotify:
/*printf("dyn current_event.type=<%d> window=<%x>\n",current_event.type ,current_event.xany.window);*/
               transition = -1;
               FI_process_event(&current_event, transition );

               break;
	  case ClientMessage:
	    /*prologue (&current_event, "ClientMessage");*/
            DPhandle_event( &current_event);
	    break;


          default:

#if defined( CLIX )

        if ( current_event.type == INGR_DigButtonPress   ) 
        {
/*
printf("Got INGR_DigButtonPress %d at %d %d window=%x\n", current_event.xbutton.button,
            current_event.xbutton.x, current_event.xbutton.y,
            current_event.xbutton.window);
*/
                                                                        
            transition=DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=current_event.xbutton.time;
            EX_button_state = current_event.xbutton.state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= JNL_XCheckTypedWindowEvent(EXdisplay,current_event.xbutton.window,
                                 INGR_DigButtonRelease,&myevent);
	    if(status && (((unsigned int)myevent.xbutton.time - 
                            (unsigned int) prev_time)< 150))
	    {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		transition=SINGLE_CLICK;
    		prev_time=myevent.xbutton.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=JNL_XCheckTypedWindowEvent(EXdisplay, current_event.xbutton.window,
                                 INGR_DigButtonPress,&myevent);
  		if(status && (((unsigned int)myevent.xbutton.time -
                                               (unsigned int) prev_time)< 150))
                {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
	           transition=DOUBLE_DOWN;
		   prev_time=myevent.xbutton.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                       current_event.xbutton.window,
                                       INGR_DigButtonRelease,&myevent);
  		   if(status && (((unsigned int)myevent.xbutton.time -
                                             (unsigned int) prev_time)< 150))
               	   {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		       transition=DOUBLE_CLICK;
    		       prev_time=myevent.xbutton.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                        current_event.xbutton.window,
                                        INGR_DigButtonPress,&myevent);
     		       if(status && (((unsigned int)myevent.xbutton.time -
                                            (unsigned int) prev_time)< 150))
                       {
/*printf("myevent.xbutton.window=%x\n",myevent.xbutton.window);*/
		          transition=TRIPLE_DOWN;
		       }
		   }
	       }
           }

  	   if(status && (((int)myevent.xbutton.time - (int) prev_time)> 150))
           {
             /*if time difference > 150 need to out it back*/
              JNL_XPutBackEvent(EXdisplay,&myevent);
           }
           if( transition != -1 )
	   {
              status =  FI_process_event( &current_event, transition );
/*
printf("after calling FI_process_event status = <%d> \n",status);       
*/
              if ( ! status )
              {
/*printf("DIG BUTTON Call EX_button_AST transition=%d\n", transition);*/
                 EX_button_AST(&response,response_data ,&current_event, transition);
              }
	   }
        }
        else if ( current_event.type == INGR_DevButtonPress   ) 
        {
/*printf("Got INGR_DevButtonPress\n");*/

	    devent = ( XDeviceButtonEvent *) &current_event;
	    
            transition=DOWN;
  	    EXtimeout.tv_usec=150000;
	    prev_time=devent->time;
            EX_button_state = devent->state;
            select(1,0,0,0,&EXtimeout);
	    EXtimeout.tv_usec=150000;
	    status= JNL_XCheckTypedWindowEvent(EXdisplay,devent->window,
                                 INGR_DevButtonRelease,(XEvent *)&my_devent);
	    if(status && (((unsigned int)my_devent.time - 
                            (unsigned int) prev_time)< 150))
	    {
		transition=SINGLE_CLICK;
    		prev_time=my_devent.time;
		select(1,0,0,0,&EXtimeout);
	        EXtimeout.tv_usec=150000;
   	        status=JNL_XCheckTypedWindowEvent(EXdisplay, devent->window,
                                 INGR_DevButtonPress,(XEvent *)&my_devent);
  		if(status && (((unsigned int)my_devent.time -
                                               (unsigned int) prev_time)< 150))
                {
	           transition=DOUBLE_DOWN;
		   prev_time=my_devent.time;
	           select(1,0,0,0,&EXtimeout);
		   EXtimeout.tv_usec=150000;
                   status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                       devent->window,
                                       INGR_DevButtonRelease,
                                       (XEvent *)&my_devent);
  		   if(status && (((unsigned int)my_devent.time -
                                             (unsigned int) prev_time)< 150))
               	   {
		       transition=DOUBLE_CLICK;
    		       prev_time=my_devent.time;
	               select(1,0,0,0,&EXtimeout);
		       EXtimeout.tv_usec=150000;
                       status=JNL_XCheckTypedWindowEvent(EXdisplay,
                                        devent->window,
                                        INGR_DevButtonPress,
                                        (XEvent *)&my_devent);
     		       if(status && (((unsigned int)my_devent.time -
                                            (unsigned int) prev_time)< 150))
                       {
		          transition=TRIPLE_DOWN;
		       }
		   }
	       }
           }

  	   if(status && (((int)my_devent.time - (int) prev_time)> 150))
           {
             /*if time difference > 150 need to out it back*/
              JNL_XPutBackEvent(EXdisplay,(XEvent *)&my_devent);
           }
           if( transition != -1 )
	   {
              status =  FI_process_event( &current_event, transition );
/*
printf("after calling FI_process_event status = <%d> \n",status);       
*/
              if ( ! status )
              {
/*printf("DIG BUTTON Call EX_button_AST transition=%d\n", transition);*/
                 EX_button_AST(&response,response_data ,&current_event, transition);
              }
	   }
        }
        else
        {
#endif

/*printf("dyn default current_event.type=<%d>\n",current_event.type );*/
        if (JNL_playback())
          {
          printf("mismatch in journaling events, playback exited\n");
          JNL_close_echo();
         }
        else
         {

            XtDispatchEvent( &current_event );
         }
	    return(1);
#if defined (CLIX)
        }
#endif

     }
        /* dpdynamics will handle window events */
	/* user may collapse/delete window, dynamics need to react */


        return(1);


  }  /* else event queue empty */
}/* EX_dyn_process_input */

#endif

/*
 %safe
static int starts_down[] = { DOWN,SINGLE_CLICK, DOUBLE_DOWN, DOUBLE_CLICK, TRIPLE_DOWN};
static int starts_up[] = { UP, UP_DOWN, UP_DOWN_UP };
 %endsafe
*/

end implementation exec;

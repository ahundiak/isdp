/*-----
%GP% CODE CLASSIFICATION
----
%HD%

    MODULE NAME : DPhandle_event

    Abstract    : This module contains the routine to handle icon 
                  actioon.       
----
%SC%

    VALUE = DPhandle_event()
----
%EN%

    ON ENTRY:

        NAME         DATA TYPE          DESCRIPTION
      ----------   ----------------    ------------------------------

----
%EX%

    ON EXIT:

        NAME         DATA TYPE          DESCRIPTION
      ----------   ----------------    ------------------------------
----
%MD%

   MODULES INVOKED: 

----
%NB%

   NOTES:
----
%CH%

   CHANGE HISTORY:

        ht may-14-86 : Creation date
----
%PD%

   -------------------------------------------------------------------------
                   P R O G R A M    D E S C R I P T I O N
   -------------------------------------------------------------------------

       This routine handles icon operations.
----*/
class implementation IGEgadget;


#ifdef ENV5
#include <tools.h>
#include <sdl.h>
%safe
#include <FIproto_pub.h>
%endsafe
#endif

#include "igewindef.h"
#include "igewindow.h"
#include "wl.h"
#include "cm.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>

%safe
#include <X11/Intrinsic.h>
%endsafe

extern Display *EXdisplay;
%safe
extern Widget EXtoplevel;
%endsafe
#endif

extern OM_S_OBJID       EX_exec_id;
extern uword            EX_exec_osnum;

/* structures needed for the make message calls  */

struct mov_icon
{
   IGRlong      *msg;
   IGRint       *w_no;
   IGRint       *flag;
   IGRint       *x1;
   IGRint       *y1;
   IGRint       *x2;
   IGRint       *y2;
};

struct other_icon
{
   IGRlong      *msg;
};

struct cov_icon
{
   IGRlong		*msg;
   struct IGEdit_range	*range;
};

struct clp_icon
{
   IGRlong      *msg;
   IGRint       *opmask;
};


from exec import passon;

#ifdef X11
IGRboolean DPhandle_event(xevent)
XEvent  *xevent;
{
#ifdef IRIX
    XEvent  xevent1;
#endif
   IGRint               mask, x1, y1, x2, y2;
   int                  xx, yy;
   IGRint               opmask; /* operation mask */
   IGRlong              status = TRUE;
   IGRlong              msg;
   Window               xwin_no, child;
   IGRint               flag;  /* flag for move icon */
   IGRint               loop;
   struct mov_icon      mvicon;
   struct clp_icon      clpicon;
   struct other_icon    othicon;
   struct cov_icon      covicon;
   struct IGEdit_range  range;
   OM_S_MESSAGE         msg_struct;
   XEvent               en;
   XWMHints             wmhints;
   char                *mname;
   XWindowAttributes    win_attr;
   int                  transition;
   WLuint32             lwin;
   WLuint16             lscreen;
   WLuint32             ctx_num;
   OMuword              win_os;
   OM_S_OBJID           win_oid;
   struct WLnative_info native_info;
   struct WLbounds      bounds;


   loop = TRUE;
   mask = 0;
   transition = -1;

   if( !FI_process_event ( xevent,transition ) )
   {
      /*=======================================================*/
      /* check for graphic window, we do NOT want forms window */
      /*=======================================================*/

      status = EX_trans_win (xevent->xany.window, &lwin, &win_os, &win_oid);
      if ( status != WL_SUCCESS )
      {
         return(OM_E_ERROR);   /* forms window */
      }

      switch( xevent->type )
      {
         case ClientMessage:

            mname = XGetAtomName (EXdisplay, xevent->xclient.message_type);
            if( !strcmp(mname, "WM_PROTOCOLS") )
            {
               XFree(mname);
               mname = XGetAtomName (EXdisplay, xevent->xclient.data.l[0]);
	       if( ! strcmp(mname,"WM_DELETE_WINDOW") )
	       {
                   /* 
                   **  delete wn objects and hardware window
                   */
                    
                   XFree(mname);

                   othicon.msg = &msg;
	    
 		   status = om$make_message (  classname = "IGEgadget", 
					       methodname = "delicon", 
					    size = sizeof(struct other_icon), 
					    p_arglist = &othicon, 
					    p_msg = &msg_struct);
		   if (! (1 & status))
		   {
		      printf("Error in wnd_delete make of delicon\n");
		      om$report_error(sts = status);
 		   }
                   else
		   {
        		  status = om$send(mode = OM_e_wrt_object,
           			           msg = &msg_struct, 
        			     senderid = NULL_OBJID,
        			     targetid = win_oid, 
        			     targetos = win_os);
        		  if (! (1 & status))
        		  {
        		     printf("Error in wnd_delete send to delicon\n");
        		     om$report_error(sts = status);
        		  }
                   }
                }
                else
                {
                  if( mname ) XFree(mname);
                }
             }
             else
             {
                if( mname ) XFree(mname);
             }
             break;


          case DestroyNotify:

                 status = OM_S_SUCCESS;

            /* 
            **  delete wn objects and hardware window
            */

		  othicon.msg = &msg;
	    
		  status = om$make_message (  classname = "IGEgadget", 
					    methodname = "delicon", 
					    size = sizeof(struct other_icon), 
					    p_arglist = &othicon, 
					    p_msg = &msg_struct);
		  if (! (1 & status))
		  {
#ifdef DEBUG
		      printf("Error in DPhandle_event make of delicon\n");
		      om$report_error(sts = status);
#endif
		      goto wrapup;
		  }

                  xwin_no = xevent->xdestroywindow.window;
                  status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }

		  status = om$send(mode = OM_e_wrt_object,
			     msg = &msg_struct,
			     senderid = NULL_OBJID,
			     targetid = win_oid, 
			     targetos = win_os);
		  if (! (1 & status))
		  {
#ifdef DEBUG
		     printf("Error in DPhandle_event send to delicon\n");
		     om$report_error(sts = status);
#endif
		     goto wrapup;
		  }
          if (JNL_playback())
           {
              XDestroyWindow(EXdisplay,xwin_no);
              XFlush(EXdisplay);
              sleep(1);
           }
                  break;
		  
          case UnmapNotify:
  
          case MapNotify : /* opmask = 0; */


    /*   Map always followed by Expose, have to set uncollapse bit in expose */

              opmask = (xevent->type == UnmapNotify) ? 1 : 0;

              /*
              **  collapsed   opmask != 0
              **  uncollapsed opmask  = 0
              */

               clpicon.msg = &msg;
               clpicon.opmask = &opmask;
       
               status = om$make_message (classname = "IGEgadget", 
                                        methodname = "clpicon", 
                                        size = sizeof(struct clp_icon), 
                                        p_arglist = &clpicon, 
                                        p_msg = &msg_struct);
               if (! (1 & status))
               {
#ifdef DEBUG
                  printf("Error in DPhandle_event make of clpicon\n");
                  om$report_error(sts = status);
#endif
                  goto wrapup;
               }

               xwin_no = xevent->xunmap.window;                   
               status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
               if (status != WL_SUCCESS) 
               {
                  status = OM_E_ERROR;
                  goto wrapup;
               }

               status = om$send(mode = OM_e_wrt_object,
                             msg = &msg_struct, 
                             senderid = NULL_OBJID,
                             targetid = win_oid, 
                             targetos = win_os);
              if (! (1 & status))
              {
#ifdef DEBUG
                  printf("Error in DPhandle_event send to clpicon clp\n");
                  om$report_error(sts = status);
#endif
                  goto wrapup;
              }
              break;

             
         case Expose:

               range.xlo = xevent->xexpose.x;
               range.ylo = xevent->xexpose.y;
               range.xhi = range.xlo + xevent->xexpose.width - 1;
               range.yhi = range.ylo + xevent->xexpose.height - 1;
#ifndef IRIX
/*this was done because sgi is not sending the correct count 
  and we were geting multiple updates here we will leave all 
  other X alone*/        
               if ( xevent->xexpose.count == 0 )
               {
#endif
                  xwin_no = xevent->xexpose.window;
                  status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }

                  status = WLget_logical_screen_from_window ( xwin_no, 
                                                              &lscreen );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }
  
                  status = CMget_active_context ( lscreen, &ctx_num );
                  if (status != CM_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }

                  status = WLget_native_info ( lwin, ctx_num, &native_info );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }
                  status = OM_S_SUCCESS;

                  XTranslateCoordinates (EXdisplay, xwin_no,
                                      RootWindow(EXdisplay,native_info.screen),
                                      0, 0, &x1, &y1, &child );

                  /* window manager hints */

                  wmhints.flags = 0;
            
                  wmhints.icon_x =  x1;
                  wmhints.icon_y =  y1;
                  wmhints.flags |= IconPositionHint;
                  XSetWMHints (EXdisplay,xwin_no,&wmhints);
#ifndef IRIX
               }
               else
               {          
                  status = 1;
                  while (status)           
                  {
                      status = JNL_XCheckWindowEvent(EXdisplay,
                                                xevent->xexpose.window,
                                                Expose,xevent);

	              if (range.xlo > xevent->xexpose.x)
                         range.xlo = xevent->xexpose.x;
	              if (range.ylo > xevent->xexpose.y)
                         range.ylo = xevent->xexpose.y;

                      if ((xevent->xexpose.x + xevent->xexpose.width -1)
                                           > range.xhi)
                                 range.xhi = xevent->xexpose.x + 
                                                xevent->xexpose.width - 1;

                      if ((xevent->xexpose.y + xevent->xexpose.height - 1)
                                           > range.yhi)
                                 range.yhi = xevent->xexpose.y +
                                                xevent->xexpose.height - 1;
                   }
                }
#else
                     status = 1; 

                     while ( (JNL_XPending(EXdisplay)) && status)
                      {
                      JNL_XPeekEvent(EXdisplay,&xevent1);
                      if ( (xevent1.xexpose.window == xwin_no) &&
                           (xevent1.xexpose.type == Expose))
                       {
                       JNL_XNextEvent(EXdisplay,&xevent1);

   		       if (range.xlo > xevent1.xexpose.x)
              		           range.xlo = xevent1.xexpose.x;
		       if (range.ylo > xevent1.xexpose.y)
		                         range.ylo = xevent1.xexpose.y;

                       if ((xevent1.xexpose.x + xevent1.xexpose.width - 1)
                                           > range.xhi)
                                 range.xhi = xevent1.xexpose.x + 
                                                xevent1.xexpose.width - 1;

                       if ((xevent1.xexpose.y + xevent1.xexpose.height - 1)
                                           > range.yhi)
                                 range.yhi = xevent1.xexpose.y +
                                                xevent1.xexpose.height - 1;
                       }
                      else
                       {
                       status = 0;
                       }
                      }
#endif


                covicon.msg = &msg;
	    
                /* Is partial update available  */

                covicon.range = &range;
		    
                status = om$make_message (classname = "IGEgadget", 
					  methodname = "covicon", 
					  size = sizeof(struct cov_icon), 
					  p_arglist = &covicon, 
					  p_msg = &msg_struct);
		if (! (1 & status))
                {
#ifdef DEBUG
                   printf("Error in DPhandle_event make of covicon\n");
                   om$report_error(sts = status);
#endif
                   goto wrapup;
                }

                xwin_no = xevent->xexpose.window;			    
                status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
                if (status != WL_SUCCESS)
                {
                   status = OM_E_ERROR;
                   goto wrapup;
                }

                status = om$send(mode = OM_e_wrt_object,
				 msg = &msg_struct,
				 senderid = NULL_OBJID,
				 targetid = win_oid, 
				 targetos = win_os);
                if (! (1 & status))
                {
#ifdef DEBUG
                   printf ("Error in DPhandle_event send to covicon\n");
                   om$report_error(sts = status);
#endif
                   goto wrapup;
                }
                break;


             case ConfigureNotify:

                flag = 2;
                xwin_no = xevent->xconfigure.window;
                status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
                if (status != WL_SUCCESS) 
                {
                   status = OM_E_ERROR;
                   goto wrapup;
                }
                status = OM_S_SUCCESS;

                /* clear  expose events */

                while (XCheckTypedWindowEvent( EXdisplay, xwin_no, MapNotify, &en) );

                mvicon.msg  = &msg;
                mvicon.w_no = (IGRint *)&lwin;
                mvicon.flag = &flag;

/*
		Resize :  send_event = 0 & x,y relative to the parent.
		Move   :  send_event = 1 & x,y already relative to RootWindow.
*/
                x1 = xevent->xconfigure.x;
                y1 = xevent->xconfigure.y;
/*
printf("DPhdlevent <0x%x> xconfigure x1=<%d> \ny1=<%d> width=<%d> height=<%d> send_event=<%d>\n",
    xevent->xconfigure.window,
    xevent->xconfigure.x,xevent->xconfigure.y,
    xevent->xconfigure.width,xevent->xconfigure.height,
    xevent->xconfigure.send_event);
*/

               status = XTranslateCoordinates (EXdisplay, xwin_no,
                             RootWindow(EXdisplay,0), 0,0,
                             &xx, &yy, &child );
/*
printf("DPhdlevent after translateCoor status=<%d> xx=<%d> yy=<%d> Child=<%x>\n",status,xx,yy,child);
*/
               if (status != False)
               {
                  if (child != RootWindow(EXdisplay,0)  && (child != None))
                  {
                     status = XGetWindowAttributes(EXdisplay,child,&win_attr);
                     if ( status )
                     {
                        x1 = win_attr.x;
                        y1 = win_attr.y;
                     }
                  }
               }
               else
               {
                  if ( ScreenCount (EXdisplay) == 2 )
                  {
                     status = XTranslateCoordinates(EXdisplay, xwin_no,
                                   RootWindow(EXdisplay,1), 0,0,
                                   &xx, &yy, &child );
/*
printf("DPhdlevent after translateCoor status=<%d> xx=<%d> yy=<%d> Child=<%x>\n",status,xx,yy,child);
*/
                      if(status != False)
                      {
                         if (child != RootWindow(EXdisplay,1) && child != None)
			 {
			    status = XGetWindowAttributes(EXdisplay,
                                                           child, &win_attr);
                            if ( status )
                            {
                               x1 = win_attr.x;
                               y1 = win_attr.y;
                            }
                         }
                      }
                   }
                }

                x2 = x1 + xevent->xconfigure.width -1;
                y2 = y1 + xevent->xconfigure.height -1;

                /* window manager hints */

                xwin_no = xevent->xconfigure.window;

                wmhints.flags = 0;
                wmhints.icon_x =  x1;
                wmhints.icon_y =  y1;
                wmhints.flags |= IconPositionHint;
                XSetWMHints(EXdisplay,xwin_no,&wmhints);

                mvicon.x1 = &x1;
                mvicon.x2 = &x2;
                mvicon.y1 = &y1;
                mvicon.y2 = &y2;

                bounds.x = 0;
                bounds.y = 0;
                bounds.width = xevent->xconfigure.width;
                bounds.height = xevent->xconfigure.height;
               

                WLwindow_bounds_changed( lwin, &bounds );

                status = om$make_message (classname = "IGEgadget", 
					    methodname = "movicon", 
					    size = sizeof(struct mov_icon), 
					    p_arglist = &mvicon, 
					    p_msg = &msg_struct);
                if (! (1 & status))
		{
#ifdef DEBUG
		   printf("Error in DPhandle_event make of movicon\n");
		   om$report_error(sts = status);
#endif
		   goto wrapup;
		}

                status = EX_trans_win ( xwin_no, &lwin, &win_os, &win_oid );
                if (status != WL_SUCCESS) 
                {
                   status = OM_E_ERROR;
                   goto wrapup;
                }

                status = om$send(mode = OM_e_wrt_object,
                                 msg = &msg_struct,
                             senderid = NULL_OBJID,
                             targetid = win_oid, 
                             targetos = win_os);
                if (! (1 & status))
                {
#ifdef DEBUG
                   printf("Error in DPhandle_event send to movicon 2\n");
                   om$report_error(sts = status);
#endif
                   goto wrapup;
                }
                break;

	 default:
 	     break;
      }
   }
wrapup:

   return(status);
}
#endif

#ifdef ENV5
IGRboolean DPhandle_event()
{
   IGRint               mask, vs_no, x1, y1, x2, y2, ax1, ay1, ax2, ay2;
   IGRint               opmask; /* operation mask */
   IGRlong              status = TRUE;
   IGRlong              msg;
   IGRint               win_no;
   IGRint               flag;  /* flag for move icon */
   IGRint               loop;
   struct mov_icon      mvicon;
   struct clp_icon      clpicon;
   struct other_icon    othicon;
   struct cov_icon      covicon;
   struct IGEdit_range  range;
   OM_S_MESSAGE         msg_struct;
   int		        events;
   WLuint32             lwin;
   OMuword              win_os;
   OM_S_OBJID           win_oid;

   
   events = DELETE_EVENT | REFRESH_EVENT | COVER_EVENT | COLLAPSE_EVENT;

   loop = TRUE;
   mask = 0;

   while (loop)
   {
      loop = FALSE;

      EX_inq_events (&mask);

      mask &= events;
	
      if (mask)
      {
         loop = TRUE;

         if (!FI_process_event(mask))
         {  
            /*==================================================*/
            /* 0 here means there may be more events to process */
            /* 1 means they processed the event exit            */
            /*==================================================*/

            if (JNL_playback())
            {
               /*===========================================================*/
               /*  in playback forms may have processed some of the events  */
               /*  and you need to read next event (4 bytes)                */
               /*===========================================================*/

               if (!JNL_echo_read_event_func() )
               {
                  status = OM_S_SUCCESS;
                  return (status);
               }
            }

            /*=======================================================*/
            /*  not in playback mode continue as usual               */
            /*  forms processed some of the events see what is left  */
            /*=======================================================*/

            loop = FALSE;
            EX_inq_events(&mask);
            mask &= events;
            if (mask)
            {       
               loop = TRUE;

               if (mask & DELETE_EVENT)
               {
                  EX_get_delete_data (&win_no);

                  status = OM_S_SUCCESS;

                  if (win_no > NWINDOW)
                  {
#ifdef DEBUG
                     printf("\n\n-- delete event after Get_delete_data;\n");
                     printf("-- window number greater than maximun allowed\n");
                     printf("-- win_no = %d\n",win_no);
#endif
                     goto wrapup;
                  }
  
                  /*=========================================*/
                  /*  delete wn objects and hardware window  */
                  /*=========================================*/

		  othicon.msg = &msg;
	    
		  status = om$make_message (  classname = "IGEgadget", 
 					    methodname = "delicon", 
					    size = sizeof(struct other_icon), 
					    p_arglist = &othicon, 
					    p_msg = &msg_struct);
		  if (! (1 & status))
		  {
#ifdef DEBUG
		      printf("Error in DPhandle_event make of delicon\n");
		      om$report_error(sts = status);
#endif
		      goto wrapup;
		  }

                  status = EX_trans_win ( win_no, &lwin, &win_os, &win_oid );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }

                  status = om$send (mode = OM_e_wrt_object,
                                    msg = &msg_struct,
			     senderid = NULL_OBJID,
			     targetid = win_oid,
			     targetos = win_os);

                  /* the above message send to delicon will end up calling  */
                  /* DPhandle_event again and handling the refresh event/   */
                  /* cover event etc;  May then try to refresh itself after */
                  /* deletion.  Query to get current mask.                  */
                  EX_inq_events (&mask);  
                  mask &= events; 

                  if (! (1 & status))
		  {
#ifdef DEBUG
		     printf("Error in DPhandle_event send to delicon\n");
		     om$report_error(sts = status);
#endif
                     goto wrapup;
		  }
               }

               if (mask & COLLAPSE_EVENT) 
               {
                  EX_get_collapse_data(&win_no, &opmask);

                  /*============================*/
                  /*  collapsed   opomask != 0  */
                  /*  uncollapsed opomask  = 0  */
                  /*============================*/

                  clpicon.msg = &msg;
                  clpicon.opmask = &opmask;
       
                  status = om$make_message (classname = "IGEgadget", 
                                            methodname = "clpicon", 
                                            size = sizeof(struct clp_icon), 
                                            p_arglist = &clpicon, 
                                            p_msg = &msg_struct);
                  if (! (1 & status))
                  {
#ifdef DEBUG
                     printf("Error in DPhandle_event make of clpicon\n");
                     om$report_error(sts = status);
#endif
                     goto wrapup;
                  }
                   
                  status = EX_trans_win ( win_no, &lwin, &win_os, &win_oid );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }

                  status = om$send (mode = OM_e_wrt_object,
                             msg = &msg_struct,
                             senderid = NULL_OBJID,
                             targetid = win_oid,
                             targetos = win_os);
                  if (! (1 & status))
                  {
#ifdef DEBUG
                     printf("Error in DPhandle_event send to clpicon clp\n");
                     om$report_error(sts = status);
#endif
                     goto wrapup;
                  }
               }      /*end if mask....collapse event */

               if (mask & REFRESH_EVENT)
               {
                  EX_get_refresh_area_data(&win_no, &vs_no, &x1, &y1, &x2, &y2,
                                           &ax1, &ay1, &ax2, &ay2, &opmask);

                  status = EX_trans_win ( win_no, &lwin, &win_os, &win_oid );
                  if (status != WL_SUCCESS) 
                  {
                     status = OM_E_ERROR;
                     goto wrapup;
                  }
                  status = OM_S_SUCCESS;

                  if ((wn_was_covered(opmask)  || wn_icon_refresh(opmask)) &&
                      (! wn_changed_position(opmask)) &&
                      (! wn_changed_size(opmask)    ) &&
                      (! wn_changed_vs(opmask)      ) && 
                      (! wn_uncollapsed(opmask)     ))
                  {
                     covicon.msg = &msg;
	    
                     /*==============================*/
	             /* Is partial update available  */
                     /*==============================*/	    

                     range.xlo = ax1;
                     range.ylo = ay1;
                     range.xhi = ax2;
                     range.yhi = ay2;
                     covicon.range = &range;
	    
                     status = om$make_message (classname = "IGEgadget", 
					       methodname = "covicon", 
					       size = sizeof(struct cov_icon), 
					       p_arglist = &covicon, 
					       p_msg = &msg_struct);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event make of covicon\n");
			om$report_error(sts = status);
#endif
			goto wrapup;
		     }
					    
                     status = om$send (mode = OM_e_wrt_object,
				       msg = &msg_struct,
                                       senderid = NULL_OBJID,
                                       targetid = win_oid, 
                                       targetos = win_os);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event send to covicon\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }
                  }

                  if ((wn_changed_position(opmask) || wn_changed_vs(opmask)) &&
                          !wn_changed_size(opmask))
                  {

                     /*=======================*/
                     /*  move only  flag = 0  */
                     /*=======================*/

                     flag = 0;

                     if ( wn_was_covered(opmask) || wn_was_off_screen(opmask)
                          || wn_is_covered(opmask) || wn_changed_vs(opmask) 
		          || wn_is_off_screen(opmask))
                     {
                        flag = 3;
                     }

                     if (wn_changed_vs(opmask))
                     {
                        flag |= WN_CHANGED_VS;
                     }

		     mvicon.msg  = &msg;
		     mvicon.w_no = (IGRint *)&lwin;
		     mvicon.flag = &flag;
		     mvicon.x1   = &x1;
		     mvicon.x2   = &x2;
		     mvicon.y1   = &y1;
		     mvicon.y2   = &y2;
	    
                     status = om$make_message (classname = "IGEgadget", 
                                               methodname = "movicon", 
                                               size = sizeof(struct mov_icon), 
                                               p_arglist = &mvicon, 
                                               p_msg = &msg_struct);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event make of movicon\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }

                     status = om$send (mode = OM_e_wrt_object,
                                       msg = &msg_struct,
                             senderid = NULL_OBJID,
                             targetid = win_oid,
                             targetos = win_os);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event send to movicon 0\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }
                  }

                  if (wn_changed_size(opmask) && !wn_changed_position(opmask))
                  {
 
                     /*==========================*/
                     /*  stretch only  flag = 1  */
                     /*==========================*/

                     flag = 1;

                     mvicon.msg  = &msg;
                     mvicon.w_no = (IGRint *)&lwin;
                     mvicon.flag = &flag;
                     mvicon.x1   = &x1;
                     mvicon.x2   = &x2;
                     mvicon.y1   = &y1;
                     mvicon.y2   = &y2;
	    
                     status = om$make_message (classname = "IGEgadget", 
                                               methodname = "movicon", 
                                               size = sizeof(struct mov_icon), 
                                               p_arglist = &mvicon, 
                                               p_msg = &msg_struct);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event make of movicon\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }
				    
                     status = om$send (mode = OM_e_wrt_object,
                                       msg = &msg_struct,
                                       senderid = NULL_OBJID,
                                       targetid = win_oid,
                                       targetos = win_os);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event send to movicon 1\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }
                  }

                  if (wn_changed_size(opmask) && wn_changed_position(opmask))
                  {
  
                     /*==============================*/
                     /*  stretch and move  flag = 2  */
                     /*==============================*/

                     flag = 2;

                     if (wn_changed_vs(opmask))
                     {
                        flag |= WN_CHANGED_VS;
                     }

                     mvicon.msg  = &msg;
                     mvicon.w_no = (IGRint *)&lwin;
                     mvicon.flag = &flag;
                     mvicon.x1   = &x1;
                     mvicon.x2   = &x2;
                     mvicon.y1   = &y1;
                     mvicon.y2   = &y2;
	    
                     status = om$make_message (classname = "IGEgadget", 
                                               methodname = "movicon", 
                                               size = sizeof(struct mov_icon), 
                                               p_arglist = &mvicon, 
                                               p_msg = &msg_struct);
                     if (! (1 & status))
		     {
#ifdef DEBUG
                        printf("Error in DPhandle_event make of movicon\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }

                     status = om$send (mode = OM_e_wrt_object,
                                       msg = &msg_struct,
                                       senderid = NULL_OBJID,
                                       targetid = win_oid,
                                       targetos = win_os);
                     if (! (1 & status))
                     {
#ifdef DEBUG
                        printf("Error in DPhandle_event send to movicon 2\n");
                        om$report_error(sts = status);
#endif
                        goto wrapup;
                     }
                  }
               }     /* end refresh event */

               if (mask & COVER_EVENT) 
               {
                  Get_cover_data(&win_no);
               }    
            }  /*if mask after forms*/
         } /* end of if (!FI_process_event)  */
      }
   }

wrapup:

   return(status);
}
#endif

end implementation IGEgadget;

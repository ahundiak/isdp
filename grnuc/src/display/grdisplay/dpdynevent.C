#include "grimport.h"
#include "igrtypedef.h"
#include "dpdef.h"

#include "wl.h"
#include "cm.h"

/* prototype files */
#include "dpdynevent.h"

/* This is the EnvironV implementation of DPdynevent */

IGRint	DPdynevent( lwin_no, state, pan_state, pan_point )

  WLuint32	lwin_no;
  IGRint	*state;
  IGRint	*pan_state;
  IGRint	*pan_point;


{
   IGRint 	events;
   IGRint	button_hwin_no;
   IGRint	x;
   IGRint	y;
   IGRint	button;
   IGRint	transition;
   IGRint	timetag;
   IGRint	hwin_no;
   int num_contexts;
   WLuint32 base_context_no;
   struct WLnative_info native_info;

   if ( WLget_window_base_context( lwin_no, &base_context_no ) != WL_SUCCESS )
   {
      *state = DP_EXIT;
      return( 0 );
   }

   if ( WLget_native_info( lwin_no, base_context_no, &native_info ) != WL_SUCCESS )
   {
      *state = DP_EXIT;
      return( 0 );
   }

   hwin_no = native_info.base_win;

   Inq_events( &events );
   events &= ~TIMER_EVENT;

   if (events)
   {
      if (events & BUTTON_EVENT)
      {
         Inq_button_data(&button_hwin_no,&x,&y,&button,&transition,&timetag);

         if (button_hwin_no == hwin_no)
         {		
            switch (button)
            {
               case LEFT_BUTTON:

                  switch (transition)
                  {
                     case DOWN:
                        *state = ZOOM_IN;
                        break;

                     case UP:
                        *state = WAIT;
                        break;

                     default:
                        *state = DP_EXIT;
                        break;
                  }
                  break;

               case RIGHT_BUTTON:

                  switch (transition)
                  {

                     case DOWN:
                        *state = ZOOM_OUT;
                        break;
		    
                     case UP:
                        *state = WAIT;
                        break;

                     default:
                        *state = DP_EXIT;
                        break;
                  }
                  break;

               case MIDDLE_BUTTON:

                  switch (transition)
                  {
                     case DOUBLE_CLICK:

                        if (*pan_state)
                        {
                           *pan_state = FALSE;
                        }
                        else
                        {
                           *pan_state = TRUE;
                        }

                        *state = CHANGE_STATE;
                        break;

                     case DOWN:

                        if (*pan_state)
                        {
                           pan_point[0] = x;
                           pan_point[1] = y;
                           *state = PAN;
                        }
                        else
                        {
                           *state = ROTATE;
                        }
                        break;

                     case UP:
                        *state = WAIT;
                        break;

                     default:
                        *state = DP_EXIT;
                        break;
                  }
                  break;

               default:
                  break;

            } /* end of switch (button)  */
         }
         else
         {
            *state = DP_EXIT;
         }

         if (*state != DP_EXIT)
         {
            Get_button_data(&button_hwin_no,&x,&y,&button,&transition,&timetag);
         }

      } /* end of if (events & BUTTON_EVENT) */
      else
      {
         *state = DP_EXIT;
      }

   } /* end of if (event)  */

   return( 1 );

}  /* DPdynevent */



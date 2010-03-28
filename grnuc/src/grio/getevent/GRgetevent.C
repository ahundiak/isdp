/* #######################    APOGEE COMPILED   ######################## */

/*
     GRgetevent() - I/O filter for retrieving an event given an event mask
 
     Abstract:          This is a filter that takes a mask and returns
                        events that are specified in the mask.  All input
			that does not match the mask results in an event
			returned with an event.response of GR_UNKNOWN_TYPE.
			response and response_data are set by the 
			ex$wait_for_input filter.

  Arguments: (-) means output, (+) means input

    *msg            IGRlong        (-) Code indicating status on return

    *mask           IGRlong        (+) Mask used to describe wanted event types

    *size           IGRlong        (+) Size of buffer allocated for event

    *event          struct GRevent (-) Event buffer 

    *response       IGRlong        (-) Response from ex$wait_for_input

    *response_data  IGRchar        (-) Response_data from ex$wait_for_input
 

     History:

        czn 06/25/86 : change to return value events.        
        czn 07/25/86 : make vsd global.
        srh 11/20/86 : installed UOM interface, accessed by gr$expr_eval and 
                       provided support for response type SPECIFIED_OBJ.
        srh 03/09/87 : fixes bug;  a data button was causing event->response
		       to be set to DATA even when GRm_DATA was not in the
		       event mask.
        srh 03/12/87 : converted code to call co$getevent macro in order to 
		       standardize the user interface for commands;  the new
		       expression evaluator is thus supported by all commands
		       that use this filter.
        scw 07/14/92 : Ansi conversion
 */

/* EH */



#include   "grimport.h"
#include   "igrtypedef.h"
#include   "OMminimum.h"
#include   "OMDB.h"
#include   "igetypedef.h"
#include   "OMlimits.h"
#include   "igr.h"
#include   "gr.h"
#include   "msdef.h"
#include   "exdef.h"
#include   "ex.h"
#include   "igrdp.h"
#include   "godef.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "grdpbmacros.h"

#include "codebug.h"
#include   "igrmacros.h"

IGRlong GRgetevent ( msg,
                     mask,
                     size, 
                     event,
                     response,
                     response_data )

IGRlong         *msg;
IGRlong         *mask;
IGRlong         *size;
struct GRevent  *event;
IGRlong         *response;
IGRchar         *response_data;

{
   IGRlong         return_status; /* GRgetevent will return the same status   */
				  /* co$getevent!                             */

   IGRlong         local_mask;    /* this is the mask sent to co$getevent     */

   GRIOalias_name  value_type;    /* this string is defined by the mask:      */
				  /* (*mask & GRm_SCALAR) --> GRIO_SCALAR     */
				  /* (*mask & GRm_DISTANCE) --> GRIO_DISTANCE */
				  /* (*mask & GRm_ANGLE) --> GRIO_ANGLE       */

   IGRchar        *p_value_type;  /* ptr to value type sent to co$getevent    */

   /*  EV - End Variables */

   _m_debug_str( "> GRgetevent" );

   p_value_type = value_type;

   if ( *mask & GRm_SCALAR )
   {
      _m_debug_str( "GRgetevent: input mask says GRm_SCALAR" );
      _m_debug( printf( "GRgetevent: mask from user = 0x%x\n", *mask ) );

      local_mask = ( *mask | GRm_VALUE );
      strcpy( value_type, GRIO_SCALAR );
   }
   else if ( *mask &  GRm_DIST )
   {
      _m_debug_str( "GRgetevent: input mask says GRm_DIST" );
      _m_debug( printf( "GRgetevent: mask from user = 0x%x\n", *mask ) );

      local_mask = ( *mask | GRm_VALUE );
      strcpy( value_type, GRIO_DISTANCE );
   }
   else if ( *mask &  GRm_ANGLE )
   {
      _m_debug_str( "GRgetevent: input mask says GRm_ANGLE" );
      _m_debug( printf( "GRgetevent: mask from user = 0x%x\n", *mask ) );

      local_mask = ( *mask | GRm_VALUE );
      strcpy( value_type, GRIO_ANGLE );
   }
   else /* do not alter mask!!! */
   {
      _m_debug_str( "GRgetevent: input mask is not a value" );
      _m_debug( printf( "GRgetevent: mask from user = 0x%x\n", *mask ) );

      local_mask = *mask; 
      p_value_type = NULL;
   }

   _m_debug_str( "GRgetevent: calling co$getevent" );
   _m_debug(
      printf("GRgetevent: input mask to co$getevent = 0x%x\n", local_mask) );
   return_status = co$getevent( msg = msg,
                                event_mask = local_mask,
                                event_size = *size,
                                prompt = NULL, 
                                value_type = p_value_type,
                                response = response, 
                                response_data = response_data,
                                event = event );

   _m_check2p( return_status, *msg, "GRgetevent:  co$getevent FAILED!" );
   _m_debug_str( "GRgetevent: return from co$getevent" );
   _m_debug( printf( "   status = 0x%x\n", return_status ) );
   _m_debug( printf( "      msg = 0x%x\n", *msg ) );

   /* make return_msg compatable with old GRgetevent */
   if ( *msg == CO_e_syntax ) 
   {
      *msg = GRe_conv; 
   }

   _m_debug_str( "< GRgetevent" );

   return( return_status );

}  /* end GRgetevent() */


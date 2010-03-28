/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
   CObuild_event()
       
   Abstract:  function to fill in the fields of a GRevent struct

   Arguments:

      *msg                 IGRlong         
       event_response      IGRlong        
       event_nbytes        IGRint         
      *button              struct EX_button
      *value               IGRdouble      
      *keyin               IGRchar        
       subtype             IGRint        
       num_id              IGRshort       
       num_val             IGRshort       
       values_1            IGRdouble      
       values_2            IGRdouble      
      *located_object_1    struct GRlc_info  
      *located_object_2    struct GRlc_info 
      *event               struct GRevent    



 Returns:  MSSUCC 
	   MSFAIL - if args invalid ( e.g. nbytes is out of range )

 */

#define MATRIX_SIZE      16


#include "coimport.h"
#include "codebug.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMDB.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "msdef.h"
#include "griodef.h"
#include "grio.h"
#include "igrmacros.h"


#define MAX_EVENT_SIZE  ( sizeof( struct GRevent ) - ( 2 * sizeof( IGRint ) ) )

IGRlong  CObuild_event( msg,
                        event_response,
                        event_nbytes,
                        button,
                        keyin,
                        value,
                        subtype,
                        num_id,
                        num_val,
                        values_1,
                        values_2,
                        located_object_1,
                        located_object_2,
                        event )



    IGRlong            *msg;
    IGRlong            event_response;
    IGRint             event_nbytes;
    struct EX_button  *button;
    IGRdouble         *value;          
    IGRchar           *keyin;    
    IGRint             subtype;
    IGRshort           num_id;
    IGRshort           num_val;
    IGRdouble          values_1;
    IGRdouble          values_2;
    struct GRlc_info  *located_object_1;
    struct GRlc_info  *located_object_2;
    struct GRevent    *event;

{
   IGRlong 
      ReturnStatus = MSSUCC; 

   _m_debug_str( ">  CObuild_event" );
   *msg = MSSUCC;  /* always return success */
   
   /* 
    * Stuff event with passed parms 
    */
   if ( ( event_nbytes < 0 ) && ( event_nbytes > MAX_EVENT_SIZE ) )
   {
      _m_debug_str( "CObuildevent:  event_nbytes is out of range" );
      ReturnStatus = MSFAIL;
      *msg = MSFAIL;
      goto quit;
   }

   event->response  = event_response;
   event->nbytes    = event_nbytes;
   event->subtype   = subtype;
   event->num_id    = num_id;
   event->num_val   = num_val;
   event->values[0] = values_1;
   event->values[1] = values_2;

   if( located_object_1 != NULL )
   {
      event->located_object[0] = *located_object_1;
   }
   /* else we leave the sturcture uninitialized */


   /*
    *  clear out the located object info #2
    */
   if( located_object_2 != NULL )
   {
      event->located_object[1] = *located_object_2;
   }
   /* else we leave the sturcture uninitialized */

   /*
    * depending on the buffer type, stuff the union portion of the 
    * event with the buffered data 
    */
   if ( button )
   {
      _m_debug_str( "CObuildevent:  copying button buffer to event.button" );
      event->event.button = *button;
   }
   else if ( value )
   {
      _m_debug_str( "CObuildevent:  copying value buffer to event.value" );
      event->event.value = *value;
   }
   else if ( keyin )
   {
      _m_debug_str( "CObuildevent:  copying keyin buffer to event.keyin" );
      memcpy( event->event.keyin, keyin, event_nbytes );
   }
   else
   {
      _m_debug_str( "CObuild_event: no buffer specified" );
      ReturnStatus = MSFAIL;
      *msg = MSFAIL;
   }

quit:
   _m_debug_str( "<  CObuild_event" );
   return( ReturnStatus ); /* always return success */
}

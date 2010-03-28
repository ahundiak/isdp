/* #######################    APOGEE COMPILED   ######################## */

/*
 ------------------------------------------------------------------------------

  Module:  CO_ni_set_active_CS_type()

  Abstract:
  
     This function sets the active Coordiante System Type.

  Example:  status = CO_ni_set_active_CS_type( ReturnMsg,
                                               Events );
                                 

  Arguments:

     *ReturnMsg     IGRlong         

         Return message:
            MSSUCC - success
            MSFAIL - Invalid CS name

     *Events[]      struct GRevent
     
        Array of points to GRevent structures
	   Events[0] is a pointer to an event containing the string
                     describing the active CS type ( i.e.  "rectangular",
		     "spherical", etc. )

  Notes:

    If the CS type found in Events is an invalid name, this function will 
    return a status of MSSUCC and a return message code of MSFAIL.
 
 
  History:   srh   08/10/87   - created
             dhm   08/15/91   - added cs$change_type

 -----------------------------------------------------------------------------
 */

/* EH */

#include "coimport.h"
#include   "codebug.h"
#include   "OMminimum.h"
#include   "OMprimitives.h"
#include   "igrtypedef.h"
#include   "igetypedef.h"
#include   "msdef.h"
#include   "exdef.h"
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "igrdp.h"
#include   "ex.h"
#include   "go.h"
#include   "ex.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "igrmacros.h"
#include   "csdef.h"
#include   "grcoordsys.h"
#include   "csmacros.h"

#define    CStype      Events[0]->event.keyin

IGRlong CO_ni_set_active_CS_type( ReturnMsg,
                                  Events )

    IGRlong            *ReturnMsg;     /*  return information code           */
    struct GRevent     *Events[];      /*  CS type ( STRING )                */

{

    IGRlong   ReturnStatus = MSSUCC; /* msg code returned to calling routine  */

    IGRint    BufferSize;

    IGRchar      FullCStype[MAX_CS_TYPE];   /* full name of CS type    */
 
    /* EV -- end local varaibles */


    _m_debug_str( ">  CO_ni_set_active_CS_type()" );

    /*
     *  --------------------------------------------------------------------
     *  Step 0:  Setup variable initial values
     *  --------------------------------------------------------------------
     */
    *ReturnMsg = MSSUCC;


       /*
        *  check to see in the CStype is a prefix of the valid CS types 
        *  and if so, update the DPB C.S. type parameter with the full 
        *  name of the type
        */
       if ( strncmp( CStype, "rectangular", strlen( CStype ) ) == 0 ) 
       {
          _m_debug_str( "Type is \"rectangular\"");
          strncpy( FullCStype, "rectangular", MAX_CS_TYPE );
       }
       else if  ( strncmp( CStype, "cylindrical", strlen( CStype ) ) == 0 )
       {
          _m_debug_str( "Type is \"cylindrical\"");
          strncpy( FullCStype, "cylindrical", MAX_CS_TYPE );
       }
       else if  ( strncmp( CStype, "spherical",   strlen( CStype ) ) == 0 )
       {
          _m_debug_str( "Type is \"spherical\"");
          strncpy( FullCStype, "spherical", MAX_CS_TYPE );
       }
       else
       {
         _m_debug_str("CO_ni_set_active_CS_type: illegal CS Type" );
         _m_debug( printf( "Type is \"%s\"\n", CStype ) );
         *ReturnMsg = MSFAIL;
         goto quit;
       }

       BufferSize = MAX_CS_TYPE;
       _m_debug_str( "CO_ni_set_active_CS_type: calling gr$put_cs_type" );
       gr$put_cs_type( msg    =  ReturnMsg,
                       sizbuf = &BufferSize,
                       buffer =  FullCStype );

       _m_checkp( *ReturnMsg,
                  "CO_ni_set_active_CS_type: gr$put_cs_type failed" );
       _m_check( *ReturnMsg, ReturnStatus = MSFAIL );
       _m_checkq( *ReturnMsg );

       cs$change_type(msg = ReturnMsg,
                      cs_os = NULL,
                      type_string = FullCStype);

       _m_checkp( *ReturnMsg,
                  "CO_ni_set_active_CS_type: cs$change_type failed" );
       _m_check( *ReturnMsg, ReturnStatus = MSFAIL );
       _m_checkq( *ReturnMsg );

       /*
        *  Since the CS type has probably changed, update the "Current point"
        *  form to reflect this
        */
       co$update_current_point_form( msg = ReturnMsg );
       

quit:
   _m_debug_str( "< CO_ni_set_active_CS_type" );
   return( ReturnStatus  );

}

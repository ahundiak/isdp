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

/*----
%GR%
----
%HD%
    ROUTINE NAME: GRget_token

    Abstract:  This function parses user input into tokens recognizable
        by a command object.  These tokens are useful in programming 
        state machines via state and action tables.

    Valid tokens:
    -------------

  	GR_UNKNOWN_TYPE
        STRING	
 	RESET	
        VALUE	
  	DATA
        - GRst_REGULAR		
        - GRst_ANGLE_TO		
        - GRst_ANGLE_FROM		
 	- GRst_TANGENT_TO		
 	- GRst_TANGENT_FROM	
 	- GRst_PERPEND_TO	
 	- GRst_PERPEND_FROM	
 	GR_UNWANTED_PT

    note: both GR_DATA and - GRst_REGULAR are equivalent. This function is 
    more optimized at this point if DATA is used
----
%SC%

        token = GRget_token(
                      msg,
                      TokenArray,
                      mask,
                      size,
                      event,
                      response,
                      response_data );

----
%EN%

 ON ENTRY:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 TokenArray       IGRint          a list of tokens that the command object
                                 will accept back from GRget_token

 mask            IGRint          a mask of desired events, used in the call
                                 to GRgetevent

 size            IGRint          size of the event buffer provided, used in
                                 the call to GRgetevent
----
%EX%

 ON EXIT:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 msg             IGRlong         the status, returned from GRgetevent

 event           struct GRevent  the buffer for the event which is returned
                                 from GRgetevent

 response        enum eds_buttons the type of user input, the type being
                                  defined according to the executive standards,
                                  needing translation to command object tokens

 response_data   char            the buffer to store a the response


 value(IGRint)=the index of into the token array of the event that takes place
                                 

----
%MD%

 MODULES INVOKED:
        GRgetevent -  a filter on top of CS_WaitForInput

----
%NB%



----
%CH%

 CHANGE HISTORY:
    mjm   4/1/86   :   creation date.
    mjm   4/21/86  :   used ching's  event typess instead of enum tokens
    mjm   5/12//86 :   new executive ... no more GRt_~~~~'s

----
%PD%
----------------------------------------------------------------------
                 P R O G R A M   D E S C R I P T I O N
----------------------------------------------------------------------

    This function calls GRgetevent to find out what the user
    has input.  Once that input has been found, then the type
    of user input is tranlated into a token that is recognized
    by the calling command object.  What is returned is not the
    token, but the token's index into a list of desired tokens
    that is supplied by the command object.

static IGRint TokenList[] = { 
        RESET,
       -GRst_REGULAR,
       -GRst_TANGENT_TO,
        GR_UNWANTED_PT,
        GR_UNKNOWN_TYPE
    };


    if the user hits a reset, token will be 0, since RESET
    is in the zeroth position in the TokenList array.
        token = GRget_token(
                      &msg,
                      TokenList,
                      &EventMask,
                      &Event,
                      &EventSize,
                      response,
                      response_data );


         *  Load states and actions.  
         *  The new state must
         *  come from the old state and the new input.  

        ME.COconst->action = (IGRint) Action[ ME.super_cmd->state ][ token ];
        ME.super_cmd->state = (IGRint) 
                                NewState[ ME.super_cmd->state ][ token ];

---- */
/*EH*/

#include "coimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "exdef.h"


IGRlong GRget_token(msg,TokenArray,mask,event,size,response,response_data)


    IGRlong            *msg;
    IGRint              TokenArray[];
    IGRint             *mask;
    IGRint             *size;
    struct GRevent     *event;
    IGRint             *response;
    IGRchar            *response_data;

{
    IGRint MyToken;
    IGRint i;
    IGRint j;
    IGRint UnwantedPointMarker;

    GRgetevent(
        msg, 
        mask, 
        size, 
        event, 
        response, 
        response_data );

/* KLUDGE - ARE NOT CHECKING FOR SUCCES */

    /*
     * clear status field
     */
/*
    UI_status("");
*/




    /* 
     * check the message type for success
     * send back the GRunknown index
     */
    if ( event->response == DATA )
    {
        MyToken = -event->subtype;
        
        /*
         *  this is to set the token to data for simple points and sub 
         *  types such as center, midpoint, and keypoint event generators.
         */
        if ( (MyToken < -GRst_PERPEND_FROM) || (MyToken == -GRst_REGULAR) )
        {
            MyToken = DATA;
        }
    }
    else
    {
        MyToken = event->response;
    }

    /*
     *  The GRt_UNKNOWN enumerated type always terminates the TokenArray array
     */
    for( i=0; TokenArray[i] != GR_UNKNOWN_TYPE; i++ )
    {
        if ( MyToken == TokenArray[i] )
        {
            return( i );
        }
    }

    /*
     * if DATA is not in the token array then check to see
     * if -GRst_REGULAR is because the two are equivalent 
     * also, check to see if GR_UNWANTED_PT is in the TokenArray
     * and remember its place if a GR_UNKNOWN_TYPE would be sent
     * back
     */
    UnwantedPointMarker = -1;
    if ( event->response == DATA )
    {
        for( j=0; TokenArray[j] != GR_UNKNOWN_TYPE; j++)
        {
            if ( (TokenArray[j] == -GRst_REGULAR) && (MyToken == DATA)  )
            {
                return(j);
            }
            else if ( TokenArray[j] == GR_UNWANTED_PT )
            {
                UnwantedPointMarker = j;
            }
        }
        if ( UnwantedPointMarker >= 0 )
        {
            return( UnwantedPointMarker );
        }
    }

    /*
     * am returning GR_UNKNOWN_TYPE
     */
    return( i );
}

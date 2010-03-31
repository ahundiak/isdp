/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"





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
    ROUTINE NAME: GRloc_token

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

        token = GRloc_token(
                      msg,
                      tok_array,
                      event);

----
%EN%

 ON ENTRY:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 tok_array       IGRint          a list of tokens that the command object
                                 will accept back from GRloc_token
----
%EX%

 ON EXIT:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 msg             IGRlong         the status, returned from co$getevent

 event           struct GRevent  the buffer for the event which is returned
                                 from co$getevent
----
%MD%

 MODULES INVOKED:

----
%NB%



----
%CH%

 CHANGE HISTORY:

22 May 1989 jBk Cleaned up comments a little, in order to make
                them more understandable and more consistent with
                the workings of the function, GRloc_token.

    mjm   5/12//86 :   new executive ... no more GRt_~~~~'s
    mjm   4/21/86  :   used ching's  event typess instead of enum tokens
    mjm   4/1/86   :   creation date.

----
%PD%
----------------------------------------------------------------------
                 P R O G R A M   D E S C R I P T I O N
----------------------------------------------------------------------

This function processes the event (as filled by co$getevent) to
find out what the user has input.  The type of user input is
tranlated into a token that is recognized by the calling command
object.  What is returned is not the token, but the token's index
into a list of desired tokens that is supplied by the command
object.

---- */
/*EH*/

#include "OMminimum.h"
#include "OMprimitives.h"
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
#include "igrmacros.h"
#include "msdef.h"
#include "dp.h"
#include "exdef.h"
#include "codef.h"
#include <stdio.h>

IGRint GRloc_token(msg,tok_array,event)


IGRlong *msg;
IGRint tok_array[];
struct GRevent *event;

{
IGRint my_tok;
IGRint i, j;
IGRint unwanted_pt_marker;

/* KLUDGE - ARE NOT CHECKING FOR SUCCES */
/* 
 * check the message type for success
 * send back the GRunknown index
 */
  if (event->response == DATA)
  {
    my_tok = -event->subtype;

    /*
     *  this is to set the token to data for simple points and sub 
     *  types such as center, midpoint, and keypoint event generators.
     */
    if ( my_tok < -GRst_PERPEND_FROM || my_tok == -GRst_REGULAR)
      my_tok = DATA;
  }
  else
    my_tok = event->response;

/*
 * The GRt_UNKNOWN enumerated type always terminates the tok_array array
 */
  for( i=0; tok_array[i] != GR_UNKNOWN_TYPE; i++ )
  {
    
    if ( my_tok == tok_array[i] )
      return(i);
  }
  /*
   * if DATA is not in the token array then check to see
   * if -GRst_REGULAR is because the two are equivalent 
   * also, check to see if GR_UNWANTED_PT is in the tok_array
   * and remember its place if a GR_UNKNOWN_TYPE would be sent
   * back
   */
  unwanted_pt_marker = -1;
  if ( event->response == DATA )
  {
    for( j=0; tok_array[j] != GR_UNKNOWN_TYPE; j++)
    {
      if ((tok_array[j] == -GRst_REGULAR) && (my_tok == DATA))
        return(j);
      else if (tok_array[j] == GR_UNWANTED_PT)
        unwanted_pt_marker = j; 
    }
    if (unwanted_pt_marker >= 0)
      return(unwanted_pt_marker);
  }
/*
 * am returning GR_UNKNOWN_TYPE
 */
  return(i);
}

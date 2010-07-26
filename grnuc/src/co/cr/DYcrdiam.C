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
IGRlong DYrbcirdiam(
                Events,
                ActiveDisplay )
                                                                            
Abstract
    This routine sets up data for rubberbanding for "place circle by 
    diameter points".
                                                                            
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first diameter point.

    struct IGRdisplay  *display
        color, style, weight, etc. of display

Example call

    DYrbcirdiam( 
                events,
                &ME.COconst->ActiveDisplay );

Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    trc 6/20/86 : creation date
    trc 9/22/86 : convert to OM 4.0
    trc 1/19/87 : convert to new argument list, removed getting of 
                        Rotation Matrix, changed header style.
    trc 3/06/87 : adapted to the new include file design
    trc 3/10/87 : changed to call the one circle dynamics function
*/


#include "coimport.h"
#include "codebug.h"


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
#include "OMerrordef.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "madef.h"
#include "codef.h"



/*
 *  the router to construct the circle returns boolean
 */
extern    IGRboolean    GRcrdiam();





IGRlong DYrbcirdiam( Events, display )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  /* Active symbologies     */

{
    IGRlong    status;

    status = DYrbcircle( 
                Events,
                display,
                GRcrdiam,
                2,               /* 2 events */
                1 );             /* cursor goes in *events[1] */

    return( OM_S_SUCCESS );
}

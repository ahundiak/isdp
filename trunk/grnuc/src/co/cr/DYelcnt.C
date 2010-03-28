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
IGRlong DYrbellcnt(
                Events,
                ActiveDisplay )
                                                                            
Abstract
    This routine sets up data for rubberbanding for "place circle by 
    three points".
                                                                            
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

    struct IGRdisplay  *display
        color, style, weight, etc. of display

Example call

    DYrbellcnt( 
                events,
                &ME.COconst->ActiveDisplay );

Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    trc 05/18/87 : creation date
*/

#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "godef.h"
#include "griodef.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "codef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dpstruct.h"

#include "igrmacros.h"
#include "dpmacros.h"


/*
 *  the router to construct the ellipse returns boolean
 */
extern    IGRboolean    GRelcnaxpt();



IGRlong DYrbellcnt( Events, display )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  /* Active symbologies     */

{
    IGRlong    status;

    status = DYrbcircle( 
                Events,
                display,
                GRelcnaxpt,
                3,               /* 3 events */
                2 );             /* cursor goes in *events[2] */

    return( OM_S_SUCCESS );
}


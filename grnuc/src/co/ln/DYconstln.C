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

#include "coimport.h"
#include "codebug.h"

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


IGRlong DYrbconstruct_line( Events, display )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  /* Active symbologies     */

{
    /* Used by curving line routines: circles, arcs, ellipses, etc  */

    IGRlong  
	       status,
	       SaveSubtype;

    struct IGRdisplay
	       LocalDisplay;

/*
    LocalDisplay.rgb_value = ?;
    LocalDisplay.color = ?;
*/

    /* Basic setup to make sure the first point passed to the dynamics
       routine is a regular point (not a tangency, perpendicular,special
       etc.
     */

    /*
     * So that we don't trash the original subtype value we save it and
     * restore it after the call to DYrblinear()
     */
    SaveSubtype = Events[0]->subtype;

    LocalDisplay.style             = 0;
    LocalDisplay.weight            = 0;
    Events[0]->subtype             = GRst_REGULAR;

    /* Call to dynamics routine  */

    status = DYrblinear( 
                Events,
                &LocalDisplay );

    Events[0]->subtype = SaveSubtype;

    return( OM_S_SUCCESS );
}

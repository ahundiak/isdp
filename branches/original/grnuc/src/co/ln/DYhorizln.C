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

/* ---------------------------------------------------------------------------

 DYrb_horizontal_line()

 Abstract
    This routine sets up dynamics information for "place horizontal line"

 Arguments

    struct GRevent   *Events[]
        an array of events.  these are usually collected by
        a command object.  

        Events[0] is the first point of the line.

    struct IGRdisplay  *ActiveDisplay
        color, style, weight, etc. of ActiveDisplay

 Example call

    DYrb_horizontal_line(  Events,
                          &ActiveDisplay );

 Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

 History
    srh 06/07/87 : creation date

 --------------------------------------------------------------------------- */

/* EH - end of header for DYrb_horizontal_line()  */



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
#include "OMerrordef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "igrmacros.h"

#define HORIZONTAL   ( 1 )


IGRlong DYrb_horizontal_line( Events, 
			      ActiveDisplay )

    struct GRevent           *Events[];
    struct IGRdisplay        *ActiveDisplay;  /* Active symbologies     */

{
    IGRboolean
       HV_Flag= HORIZONTAL;

    /*  EV - end of variable declarations */

    DYrb_hor_vert_line( Events,
		        ActiveDisplay,
		       &HV_Flag );

    return( OM_S_SUCCESS );

}


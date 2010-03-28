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
IGRlong DYrbfixlinear(
                Events,
                ActiveDisplay )
                                                                            
Abstract
    This routine sets up dynamics data for "measure angle between
    2 points and arbitrary axis".  The dynamics function displays
    a static, (unmoving) line between the two points (in Events[2]
    and Events[3]), and displays rubberbanding dynamics, between 
    the point in Events[0] and the cursor.

                                                                            
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first point of the line.

        event[2] is the first point of the static line.
        event[3] is the second point of the static line.

    struct IGRdisplay  *display
        color, style, weight, etc. of display

Example call

    DYrblinear( 
                events,
                &ME.COconst->ActiveDisplay );

Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    dlw 23/08/88 : adapted from DYrblinear
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
 *  set up extern definitions for functions used
 */
extern    IGRint    DYrbfixlinedyn();
extern    IGRboolean    GRls2pt();




struct DYline_params 
{
    IGRlong                 msg;
    struct GRevent         *events[2];
    IGRshort                NumberOfEvents;
    struct DPele_header     headers[2];
};






IGRlong DYrbfixlinear( Events, display )

    struct GRevent             *Events[];
    struct IGRdisplay          *display;  /* Active symbologies     */

{
/* BV - BEGINNING OF VARIABLE LIST */

    IGRlong                   msg;
    IGRlong                   status;
    IGRlong                   two = 2;
    struct DYline_params      DYinfo;
    struct IGResbc            LineSpecific;
    struct GRevent            point2;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line using 
     *  eddie jennings macro
     */
    GRls_declare( rb_line_bspline, RbLinePolesetc );
    GRls_declare( static_line_bspline, StaticLinePolesetc );

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */



    /*
     *  initialize the poles, weights, knots pointers in the bspline 
     *  using the macro defined by eddie jennings
     */
    GRls_init( rb_line_bspline, RbLinePolesetc );
    GRls_init( static_line_bspline, StaticLinePolesetc );


    status = GRls2pt(&msg,
                     &Events[2],
                     &two,
                     &static_line_bspline);

     /*  extract the events from the array  */

    LineSpecific.is_polydis = FALSE;
    LineSpecific.is_curvedis = TRUE;

    dp$build_dis_buffer(
                    buffer = &DYinfo.headers[0],
                    display_att = display,
                    geometry = &rb_line_bspline,
                    type         =  IGRBC,      /* type is bspline  */
                    ele_spec_att = &LineSpecific );

    dp$build_dis_buffer( buffer       = &DYinfo.headers[1],
                         type         =  IGRBC,      /* type is bspline  */
                         display_att  =  display,
                         geometry     = &static_line_bspline,
                         ele_spec_att = &LineSpecific );

    point2 = *Events[0];
    point2.subtype = GRst_REGULAR;
    DYinfo.events[0] = Events[0];
    DYinfo.events[1] = &point2;
    DYinfo.NumberOfEvents = 2;

    dp$dynamics( 
                dyn_fun = DYrbfixlinedyn,
                information = &DYinfo );

    return( OM_S_SUCCESS );
}


IGRint DYrbfixlinedyn( 
                DYinfo,
                point,
                matrix,
                objects,
                num_objects,
                buffers,
                 num_buffers,
                dummy_in1,
                dummy_in2,
                dummy_in3,
                dummy_out1,
                dummy_out2,
                dummy_out3 )

        struct DYline_params         *DYinfo;
        struct EX_button             *point;
        IGRdouble                    *matrix;
        struct GRid                  **objects;
        IGRint                       *num_objects;
        struct DPele_header          **buffers;
        IGRint                       *num_buffers;

        IGRchar                      *dummy_in1;
        IGRchar                      *dummy_in2;
        IGRchar                      *dummy_in3;

        IGRchar                      **dummy_out1;
        IGRchar                      **dummy_out2;
        IGRchar                      **dummy_out3;

{
    IGRboolean    status;



    DYinfo->events[1]->event.button = *point;
    
    /*
     *  call the router for line by two point construction
     */
    status = GRls2pt( 
                &DYinfo->msg,
                 DYinfo->events,
                &DYinfo->NumberOfEvents,
                 DYinfo->headers[0].geometry.bspcurve );

    *buffers = DYinfo->headers;
    *num_buffers = 2;

    return(   (status && !COERROR( DYinfo->msg )) ? MSSUCC : MSFAIL );
}

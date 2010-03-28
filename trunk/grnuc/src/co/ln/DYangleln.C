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

 IGRlong DYline_angle_view()

 Abstract
     This routine is a stndard dynamics function as called by dp$dynamics.
     It displays a line at a specified angle ( e.g. vertical, horizontal,
     active angle ) in a specified view.


 Arguments

    struct DYline_angle_params   * Information;

       Information->header        - display buffer info
       Information->angle         - angle of the line in the view
       Information->events        - array of event points
       Information->nbr_events    - number of events in events array


    ... the rest of the arguments are standard and defined by the dp$dynamics
        interface


 Example call


 Status returns

        MSSUCC
        MSFAIL
        

 History
    srh 05/07/87 : creation date

 --------------------------------------------------------------------------- */

/* EH - end of header for DYline_angle_view()  */



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
#include "msdef.h"
#include "OMerrordef.h"
#include "igrdef.h"
#include "grdpbdef.h"
#include "dpdef.h"
#include "grdpb.h"
#include "dp.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "codef.h"
#include "madef.h"
#include "igrmacros.h"


struct DYline_angle_params               /* dynamics information structure  */
{
    struct DPele_header    *header;      /* dynamics header information     */
    struct GRevent         *events[2];   /* buffer of data pt events        */
    IGRdouble              *angle;       /* Angle of line in view           */
    IGRshort               *nbr_events;  /* number of data points in events */
};


IGRlong DYline_angle_view( Information,
                           Cursor,
                           Matrix,
                           Objects,
                           NumberOfObjects,
                           Buffers,
                           NumberOfBuffers,
                           dummy_in1,
                           dummy_in2,
                           dummy_in3,
                           dummy_out1,
                           dummy_out2,
                           dummy_out3 )

   struct DYline_angle_params   * Information;
   struct EX_button             * Cursor;
   IGRdouble                    * Matrix;
   struct GRid                 ** Objects;
   IGRint                       * NumberOfObjects;
   struct DPele_header         ** Buffers;
   IGRint                       * NumberOfBuffers;
   IGRchar                      * dummy_in1;
   IGRchar                      * dummy_in2;
   IGRchar                      * dummy_in3;
   IGRchar                     ** dummy_out1;
   IGRchar                     ** dummy_out2;
   IGRchar                     ** dummy_out3;

{
    /* BV - begin variable declarations  */

    IGRlong
       Status    = MSSUCC,
       ReturnMsg = MSSUCC;

    /* EV - end variable declarations  */



    /*
     *  Override the subtype of the second data point event and put the
     *  button information from the cursor in the second events button
     *  buffer.
     */
    Information->events[1]->subtype       =  GRst_REGULAR;
    Information->events[1]->event.button  = *Cursor;

    /*
     *  Get the B-spline geometry of the line at active angle 
     */
    Status = GRaals2pt( &ReturnMsg,
                         Information->events,
                         Information->nbr_events,
                         Information->angle, 
                         Information->header->geometry.polyline );

    *NumberOfObjects = 0;
    *NumberOfBuffers = 1;
    *Buffers = Information->header;

    return( ( !COERROR(Status) && !COERROR(ReturnMsg) ) ? MSSUCC : MSFAIL );
}


/* ---------------------------------------------------------------------------


 IGRlong DYrb_angle_line( Events, 
                          ActiveDisplay,
                          Angle )

 Abstract
    This routine sets up dynamics information for "place line at active angle"


 Arguments

    struct GRevent     *Events[]
        an array of events.  these are usually collected by
        a command object.  

        Events[0] is the first point of the line.

    struct IGRdisplay  *ActiveDisplay
        color, style, weight, etc. of display

    IGRlong            *Angle
        angle at which line is drawn w.r.t view specified in first point


 Example call

    DYrb_angle_line(  Events, 
                     &ActiveDisplay,
                     &Angle );

 Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

 History
    srh 06/07/87 : creation date
    srh 02/16/88 : added special point router

 --------------------------------------------------------------------------- */

/* EH - end of header for DYrb_line_active_angle()  */

IGRlong DYrb_angle_line( Events,
                         ActiveDisplay,
                         Angle )

    struct GRevent           *Events[];
    struct IGRdisplay        *ActiveDisplay;
    IGRlong                  *Angle;

{

    IGRshort
	     NbrOfEvents = 2;

    struct GRevent
	     DynEvent1,
	     DynEvent2;

    struct DYline_angle_params
             Information;

    struct DPele_header 
             Header;

    struct IGResbc
             LineSpecific;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line 
     */
    struct IGRbsp_curve
       Bspline;            /* Bspline curve returned    */

    IGRdouble
       Poles[6],           /* poles for Bspline         */
       Weights[2],         /* weights for Bspline       */
       Knots[4];           /* knots for Bspline         */


    /*  EV - end of variable declarations */


    /*
     *  initialize the poles, weights, knots pointers in the bspline 
     *  using the macro defined by eddie jennings
     */
    Bspline.poles = Poles;
    Bspline.weights = Weights;
    Bspline.knots = Knots;

    /*
     *  I don't trust the dynamics functions to not alter my events
     *  so I use clones in the dynamics routine so that my original
     *  data will not be trashed.
     */
    DynEvent1 = *Events[0];
    DynEvent2 = *Events[0];   /* initial value of second point */

    /* set line specific attributes */
    LineSpecific.is_polydis = FALSE;
    LineSpecific.is_curvedis = TRUE;

    dp$build_dis_buffer( buffer       = &Header,
                         display_att  =  ActiveDisplay,
                         ele_spec_att = &LineSpecific,
                         geometry     = ( struct IGRbsp_curve * ) &Bspline );
        
    Information.angle      =  (double *) Angle;
    Information.header     = &Header;
    Information.nbr_events = &NbrOfEvents;
    Information.events[0]  = &DynEvent1;
    Information.events[1]  = &DynEvent2;

    dp$dynamics( dyn_fun     =  DYline_angle_view,
                 information = &Information );

    return( OM_S_SUCCESS );
}

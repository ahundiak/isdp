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

 DYrb_hor_vert_line()

 Abstract
    This routine sets up dynamics information for "place vertical line"
    and "place horizontal line";

 Arguments

    struct GRevent   *Events[]
        an array of events.  these are usually collected by
        a command object.  

        Events[0] is the first point of the line.

    struct IGRdisplay  *ActiveDisplay
        color, style, weight, etc. of ActiveDisplay

    IGRboolean         * HV_Flag
        flag which indicates whether the line is horizontal or veritical
           if *HV_Flag == 0 - vertical
           if *HV_Flag == 1 - horizontal

 Example call

    DYrb_hor_vert_line( Events,
                        ActiveDisplay,
                       &HV_Flag );

 Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

 History
    srh 06/07/87 : creation date
    srh 02/11/88 : added ability to handle special points ( perpedicular,
                   horizontal, at angle )

 --------------------------------------------------------------------------- */

/* EH - end of header for DYrb_hor_vert_line()  */



#include "coimport.h"
#include "codebug.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
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
#include "dpmacros.h"
#include "igrmacros.h"


struct DYhor_vert_line_params   
{
   IGRboolean            * hv_flag;
   struct DPele_header   * header;
   struct GRevent        * events[2];
};


IGRlong DYhor_vert_line(   Information,
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

   struct DYhor_vert_line_params * Information;
   struct EX_button              * Cursor;
   IGRdouble                     * Matrix;
   struct GRid                  ** Objects;
   IGRint                        * NumberOfObjects;
   struct DPele_header          ** Buffers;
   IGRint                        * NumberOfBuffers;
   IGRchar                       * dummy_in1;
   IGRchar                       * dummy_in2;
   IGRchar                       * dummy_in3;
   IGRchar                      ** dummy_out1;
   IGRchar                      ** dummy_out2;
   IGRchar                      ** dummy_out3;

{
    /* BV - begin variable declarations  */

    IGRshort
                   NumberOfEvents = 2;
    IGRlong
                   ReturnStatus = MSSUCC,
                   ReturnMsg    = MSSUCC;

    /* EV - end variable declarations  */




    /*
     *  Copy contents of first event point into second event.
     *  Then override the subtype and button information with
     *  those of the the cursor.
     */
    Information->events[1]->subtype =  GRst_REGULAR;
    Information->events[1]->event.button  = *Cursor;

    /*
     *  Get the B-spline geometry of the line at active angle 
     */
    ReturnStatus = GRhvls2pt( &ReturnMsg,
                               Information->events,
                              &NumberOfEvents,
                               Information->hv_flag,
                               Information->header->geometry.polyline );

    _m_check2p( ReturnStatus, ReturnMsg,
       "CO_ni_place_horizontal_line:  GRhvls2pt failed" );
    _m_check2q( ReturnStatus, ReturnMsg );


    *NumberOfObjects = 0;
    *NumberOfBuffers = 1;
    *Buffers = Information->header;

quit:
    return( ( ReturnStatus & ReturnMsg & 1 ) ? MSSUCC : MSFAIL );
}


/* ---------------------------------------------------------------------------


 IGRlong DYrb_hor_vert_line( Events, 
                             ActiveDisplay,
                             HV_Flag )

 Abstract
    This routine sets up dynamics information for "place line at active angle"


 Arguments

    struct GRevent     *Events[]

        an array of events.  these are usually collected by a
        command object.  Events[0] is the first point of the line.


    struct IGRdisplay  *ActiveDisplay

        color, style, weight, etc. of display


    IGRboolean         *HV_Flag

        flag: if 0;  line is vertical
              if 1;  line is horizontal


 Example call

    DYrb_hor_vert_line(  Events, 
                        &ActiveDisplay,
                        &HV_Flag );

 Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

 History
    srh 06/07/87 : creation date

 --------------------------------------------------------------------------- */

/* EH - end of header for DYrb_hor_vert_line()  */

IGRlong DYrb_hor_vert_line( Events,
                            ActiveDisplay,
                            HV_Flag )

    struct GRevent          * Events[];
    struct IGRdisplay       * ActiveDisplay;
    IGRboolean              * HV_Flag;

{

    struct DYhor_vert_line_params
             Information;

    struct DPele_header 
             Header;

    struct GRevent
	     DynEvent1,
	     DynEvent2;

    struct IGResbc
             LineSpecific;

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
     *  so I use clones in the dynamics soutine so that my instatnce 
     *  data cannot be trashed.
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
        
    Information.hv_flag   =  HV_Flag;
    Information.header    = &Header;
    Information.events[0] = &DynEvent1;
    Information.events[1] = &DynEvent2;

    dp$dynamics( dyn_fun     =  DYhor_vert_line,
                 information = &Information );

    return( OM_S_SUCCESS );
}

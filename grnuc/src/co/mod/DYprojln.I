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
IGRlong DYrbproject_linear(
                FunctionIndex,
                events,
                ModuleInfo,
                my_id,
                my_os,
                MyChannelStruct,
                ObjectsGrid )

    IGRlong                     FunctionIndex;
    struct GRevent             *events[];
    struct GRmd_env            *ModuleInfo;   
    GRobjid                     my_id;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectsGrid;

Abstract
    This routine sets up data for rubberbanding for commands
    that need to show a division on a closed element.  Two
    events are fed to this routine.  A constant, fixed line will
    be displayed.
                                                                            
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first point of the line.
        event[1] is the second point of the line.

    struct IGRdisplay  *display
        color, style, weight, etc. of display

Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    trc 01/26/87 : creation date
    trc 03/06/87 : adapted to the new include file design
*/
class implementation Root;

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
#include "codef.h"


/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import   GRlnproject;


/*
 *  set up extern definitions for functions used
 */
%safe
extern    IGRint    DYproject_linedyn();
%endsafe
extern    IGRboolean    GRls2pt();




struct DYline_params 
{
    IGRlong                 msg;
    struct GRevent         *events[2];
    IGRshort                NumberOfEvents;
    struct DPele_header    *line;
};









IGRlong DYrbproject_linear(
                FunctionIndex,
                Events,
                ModuleInfo,
                my_id,
                my_os,
                MyChannelStruct,
                ObjectsGrid )

    IGRlong                     FunctionIndex;
    struct GRevent             *Events[];
    struct GRmd_env            *ModuleInfo;   
    GRobjid                     my_id;
    GRspacenum                  my_os;
    OM_S_CHANSELECT            *MyChannelStruct;
    struct GRid                *ObjectsGrid;

{
    IGRlong                   msg;
    IGRlong                   status;
    IGRboolean                b_status;
    struct DPele_header       element;
    struct DYline_params      DYinfo;
    struct IGResbc            LineSpecific;
    struct IGRdisplay         display;
    IGRshort                   NumberOfEvents = 2;
    IGRdouble           BorePoints[6];  /* points to store boreline         */
    struct IGRline      BoreLine;       /* boreline for apparent project    */
    IGRpoint            DummyPoint1;
    IGRpoint            ProjectPoint;
    IGRdouble           DummyDouble;
    struct GRparms      AcceptParms;
    struct GRevent      FirstEvent;
    struct GRevent           *Point1;
    struct GRevent            Point2;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line using 
     *  eddie jennings macro
     */
    GRls_declare( line, LinePolesetc );




    /*
     *  initialize the poles, weights, knots pointers in the bspline 
     *  using the macro defined by eddie jennings
     */
    GRls_init( line, LinePolesetc );


    
    /*
     *  pull the events out of the array
     */
    FirstEvent = *Events[0];


    /*
     *  set boreline for apparent project
     */
    BoreLine.point1 = &( BorePoints[0] );
    BoreLine.point2 = &( BorePoints[3] );


    /*
     *  use brad's CObrln to find the boreline
     *  so as to do a boreline project
     *  to set up the FROM point boreline
     */
    b_status = CObrln( 
                    &msg,
                    &my_id,
                    &FirstEvent,
                    &BoreLine );
                                                                 

    /*
     *  send to the graphic object to project
     *  the accept point onto the graphic object
     *  
     *  GOAL : find the ProjectedParms for the input point
     */
    if ( MyChannelStruct != NULL )
    {
        /*
         *  send by channel
         */
        status = om$send(
                    msg = message GRgraphics.GRlnproject(
                        &msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &BoreLine,
                        DummyPoint1,
                        ProjectPoint,
                        &DummyDouble,
                        &AcceptParms ),
                     p_chanselect = MyChannelStruct );
    }
    else
    {
        /*
         *  send by object
         */
        status = om$send(
                    msg = message GRgraphics.GRlnproject(
                        &msg,
                        &ModuleInfo->md_env.matrix_type,
                        ModuleInfo->md_env.matrix,
                        &BoreLine,
                        DummyPoint1,
                        ProjectPoint,
                        &DummyDouble,
                        &AcceptParms ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }


    Events[0]->event.button.x = ProjectPoint[0];
    Events[0]->event.button.y = ProjectPoint[1];
    Events[0]->event.button.z = ProjectPoint[2];


    LineSpecific.is_polydis = FALSE;
    LineSpecific.is_curvedis = TRUE;

    display.style = 0;
    display.weight = 0;
    display.color = 1;

    dp$build_dis_buffer(
                    buffer = &element,
                    display_att = &display,
                    geometry = &line,
                    ele_spec_att = &LineSpecific );

    Point1 = Events[0];
    Point2 = *Point1;
    Point2.subtype = GRst_REGULAR;
    DYinfo.events[0] = Point1;
    DYinfo.events[1] = &Point2;
    DYinfo.NumberOfEvents = 2;
    DYinfo.line = &element;

    /*
     *  call the router for line by two point construction
     */
    status = GRls2pt( 
                 &msg,
                 Events,
                 &NumberOfEvents,
                 DYinfo.line->geometry.bspcurve );

    dp$dynamics( 
                dyn_fun = DYproject_linedyn,
                information = &DYinfo );

    return( OM_S_SUCCESS );
}


IGRint DYproject_linedyn( 
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
                 DYinfo->line->geometry.bspcurve );

    *buffers = DYinfo->line;
    *num_buffers = 1;

    return(   (status && !COERROR( DYinfo->msg )) ? MSSUCC : MSFAIL );
}


end implementation Root;

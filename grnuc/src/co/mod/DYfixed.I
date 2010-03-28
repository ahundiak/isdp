/*
Name
        DYrbfixed_linear(

Synopsis
        IGRlong DYrbfixed_linear(
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

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first point of the line.
        event[1] is the second point of the line.

    struct IGRdisplay  *display
        color, style, weight, etc. of display

Description
    This routine sets up data for rubberbanding for commands
    that need to show a division on a closed element.  Two
    events are fed to this routine.  A constant, fixed line will
    be displayed.  The two events will be projected onto the
    element, and a line drawn between them.  No matter where
    the cursor is, the line will between the two points.

    example commands are:
        partial delete
        place symbology override
        measure length along an element
                                                                            
Status returns

        OM_S_SUCCESS            
        OM_E_ABORT

History
    trc 01/26/87 : creation date
    trc 03/06/87 : adapted to the new include file design
    mrm 02/02/93 : fixed to use active module id for display, rather than that 
                   of the located object; this was causing problems with
                   objects located in reference files (TR119300850).
*/
class implementation Root;

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
#include "exmacros.h"
#include "grio.h"
#include "dpstruct.h"
#include "dp.h"
#include "igrmacros.h"
#include "dpdef.h"
#include "dpmacros.h"


/*----------------------------------------
 *    imports
 *----------------------------------------
 */
from GRgraphics import   GRlnproject;


/*
 *  set up extern definitions for functions used
 */
%safe
extern    IGRint    DYfixed_linedyn();
%endsafe
extern    IGRboolean    GRls2pt();




struct DYline_params 
{
    struct DPele_header    *line;
};


IGRlong DYrbfixed_linear(
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
    OM_S_OBJID                  active_module_objid;
    OMuword                     active_module_osnum;
    IGRshort                   NumberOfEvents = 2;
    IGRdouble           BorePoints[6];  /* points to store boreline         */
    struct IGRline      BoreLine;       /* boreline for apparent project    */
    IGRpoint            DummyPoint1;
    IGRpoint            Point1;
    IGRpoint            Point2;
    IGRdouble           DummyDouble;
    struct GRparms      AcceptParms;
    struct GRevent      FirstEvent;
    struct GRevent      SecondEvent;

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
    SecondEvent   = *Events[1];


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
                        Point1,
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
                        Point1,
                        &DummyDouble,
                        &AcceptParms ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, msg, "DYrbfixed - failed first GRlnproject" );
    _m_check2q( status, msg );


    Events[0]->event.button.x = Point1[0];
    Events[0]->event.button.y = Point1[1];
    Events[0]->event.button.z = Point1[2];



    /*
     *  use brad's CObrln to find the boreline
     *  so as to do a boreline project
     *  to set up the FROM point boreline
     */
    b_status = CObrln( 
                    &msg,
                    &my_id,
                    &SecondEvent,
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
                        Point2,
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
                        Point2,
                        &DummyDouble,
                        &AcceptParms ),
                    targetid = ObjectsGrid->objid,
                    targetos = ObjectsGrid->osnum );
    }
    _m_check2p( status, msg, "DYrbfixed - failed second GRlnproject" );
    _m_check2q( status, msg );


    Events[1]->event.button.x = Point2[0];
    Events[1]->event.button.y = Point2[1];
    Events[1]->event.button.z = Point2[2];

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

    DYinfo.line = &element;

    /*
     *  call the router for line by two point construction
     */
    status = GRls2pt( 
                 &msg,
                 Events,
                 &NumberOfEvents,
                 DYinfo.line->geometry.bspcurve );

    /* get the active module id for display */
    ex$get_cur_mod(id = &active_module_objid, osnum = &active_module_osnum);

    /*
     *  display the line so that it will not flicker
     */
    status = dp$display(
                msg = &msg,
                mode = GRhd,
                objid = active_module_objid,
		osnum = active_module_osnum,
                buffer = &element );



quit:
    return( OM_S_SUCCESS );
}


IGRint DYfixed_linedyn( 
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
    *buffers = DYinfo->line;
    *num_buffers = 0;

    return( MSFAIL );
}


end implementation Root;

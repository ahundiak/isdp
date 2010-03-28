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

     CO_ni_place_line_at_active_angle()

     Abstract:
        Non-interactive function for construction of a Line Segment at 
        Active Angle.  The data point in Events[0] is one end point of the 
        line segment.  The data point in Events[1] is first projected onto
        the view plane of the window defined in Events[0]; the result is
        then project onto the vector defined by the first point, the view
        plane and the active angle.  This projected point is the second 
        end point of the line constructed.  Active angle is stored in 
	Events[2].

  History:

      srh ??/??/?? : ( memory fault ) created 
      srh 05/23/89 : removed GRIS_ properties from construct list 

 */
#include "coimport.h"
#include "codebug.h"

#include "OMminimum.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "msdef.h"
#include "codef.h"
#include "griodef.h"
#include "dpdef.h"
#include "grdpbdef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "grdpb.h"

#include "griomacros.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "igrmacros.h"


/*
 *----------------------------------------
 *   CO_ni_place_line_at_active_angle
 *----------------------------------------
 */
IGRlong CO_ni_place_line_at_active_angle( ReturnMsg,
				          Events,
                                          DisplayMode,
                                          newflag,
                                          ModuleInfo,
                                          ActiveDisplay,
                                          ActiveLevel,
                                          attr,
                                          name,
                                          LineSegmentGrid,
                                          DisplayGrid,
                                          classname,
                                          classid,
                                          neighbor,
                                          cob_id,
                                          cob_os,
                                          p_co_chanselect,
                                          co_index )

    IGRlong              *ReturnMsg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *LineSegmentGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

{

    /* BV - BEGINNING OF VARIABLE LIST */

    IGRshort 
		NumberOfEvents = 2;


    IGRlong    
		ReturnStatus  = MSSUCC,                 /* return code  */
                NumberOfBytes = sizeof( IGRdouble ),
                BytesReceived;


    IGRdouble  
		ActiveAngle,    /* from dpb             */
                Poles[6],       /* poles for Bspline    */
                Weights[2],     /* weights for Bspline  */
                Knots[4];       /* knots for Bspline    */


    struct IGRbsp_curve 
		AbstractGeometry;  /* Bspline curve returned    */



    /* EV - END OF VARIABLE LIST */

    _m_debug_str( "> CO_ni_place_line_at_active_angle" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Assign b-spine buffers
     * ----------------------------------------------------------------------
     */
    AbstractGeometry.poles   = Poles;
    AbstractGeometry.weights = Weights;
    AbstractGeometry.knots   = Knots;

    /*
     * ---------------------------------------------------------------------
     *  Step 1:  Get the default active angle from the DPB
     * ---------------------------------------------------------------------
     */
    _m_debug_str( "CO_ni_place_line_at_active_angle: gr$get_active_angle" );

    gr$get_active_angle(
            msg    =  ReturnMsg,
            sizbuf = &NumberOfBytes,
            buffer = &ActiveAngle,
            nret   = &BytesReceived );

    _m_checkp( *ReturnMsg,
	"CO_ni_place_line_at_active_angle - failed gr$get_active_angle" );
    _m_checkq( *ReturnMsg );

    /*
     * ------------------------------------------------------------------------
     *   Step 2:  Get b-sline geometry of horizontal line
     * ------------------------------------------------------------------------
     */
    ReturnStatus = GRaals2pt(  ReturnMsg,
		               Events,
                              &NumberOfEvents,
			      &ActiveAngle,
			      &AbstractGeometry );

    _m_check2p( ReturnStatus, *ReturnMsg,
       "CO_ni_place_line_at_active_angle: GRaals2pt failed");
    _m_check2q( ReturnStatus, *ReturnMsg );

    /*
     * verify a valid curve was generated
     */
    ReturnStatus = COcheck_curve( ReturnMsg, &AbstractGeometry );
    _m_checkq(ReturnStatus);

    /*
     * -----------------------------------------------------------------------
     *   Step 3:    Construct the line segment
     * -----------------------------------------------------------------------
     */
    _m_debug_str( "CO_ni_place_line_at_active_angle:  calling co$construct" );
    if ( classname != NULL )
    {
       /*
        *  classname is specified
        */
        ReturnStatus = co$construct_object(
                        msg = ReturnMsg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &AbstractGeometry,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = LineSegmentGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classname = classname );
                                                                            
    }
    else
    {
        /*
         * classid is specified
         */
        ReturnStatus = co$construct_object(
                        msg = ReturnMsg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &AbstractGeometry,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = LineSegmentGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classid = classid );
    }

    _m_check2p( ReturnStatus, *ReturnMsg,
               "CO_ni_place_line_at_active_angle - co$construct_object failed");

quit:
    _m_debug_str( "< CO_ni_place_line_at_active_angle" );
    return ( ReturnStatus );

} /* end CO_ni_place_line_at_active_angle() */


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

     CO_ni_place_horizontal_line()

     Abstract:
        Non-interactive function for construction of a Line Segment which
        is HORIZONTAL in the view specified by the first data point event.

	The data point in Events[0] is one end point of the line segment. 
	The data point in Events[1] is first projected onto the view plane 
	of the window defined in Events[0]; the result is then project onto
	the vector defined by the first point, the view plane and an angle 
	of 0 radians.  This projected point is the second end point of the
	line constructed.  

  History:

      srh ??/??/?? : created ( memory fault )
      srh 02/11/88 : added ability to handle special event types such as
		      perpendicular, tangent, and at angle.
      srh 05/23/89 : removed GRIS_ properties from construct list 

*/
#include    "coimport.h"
#include    "codebug.h"

#include    "OMminimum.h"
#include    "OMprimitives.h"

#include    "igetypedef.h"
#include    "igrtypedef.h"
#include    "godef.h"
#include    "msdef.h"
#include    "codef.h"
#include    "griodef.h"
#include    "dpdef.h"
#include    "grdpbdef.h"
#include    "madef.h"

#include    "gr.h"
#include    "igr.h"
#include    "igrdp.h"
#include    "go.h"
#include    "ex.h"
#include    "grio.h"
#include    "dp.h"
#include    "grdpb.h"

#include    "griomacros.h"
#include    "grdpbmacros.h"
#include    "comiscmac.h"
#include    "exmacros.h"
#include    "dpmacros.h"
#include    "igrmacros.h"

#define  HORIZONTAL ( 1 )  /* in GRhvls2pt(): HV_Flag == 1 means horizontal */

extern  IGRboolean   MAdegrad();
extern  IGRboolean   MAtrnmx();
extern  IGRboolean   MAlalnfpt();

/*
 *----------------------------------------
 *   CO_ni_place_horizontal_line
 *----------------------------------------
 */
IGRlong CO_ni_place_horizontal_line( ReturnMsg,
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
		 NumberOfEvents = 2;     /* nbr of event ptrs in Events[]    */

    IGRboolean
	         HV_Flag = HORIZONTAL;   /* indicates horizontal or vertical */

    IGRlong
                 ReturnStatus = MSSUCC;  /* return code                      */

    IGRdouble    Poles[6],               /* poles for Bspline    */
                 Weights[2],             /* weights for Bspline  */
                 Knots[4];               /* knots for Bspline    */

    struct IGRbsp_curve  
		 AbstractGeometry;       /* Bspline curve returned   */


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "CO_ni_place_horizontal_line >" );

    /* 
     * ----------------------------------------------------------------------
     *  Step 0:  Initialize data 
     * ----------------------------------------------------------------------
     */
    AbstractGeometry.poles = Poles;
    AbstractGeometry.weights = Weights;
    AbstractGeometry.knots = Knots;

    /*
     * ------------------------------------------------------------------------
     *   Step 1:  Get b-sline geometry of horizontal line
     * ------------------------------------------------------------------------
     */
     ReturnStatus = GRhvls2pt( ReturnMsg,
			       Events,
			      &NumberOfEvents,
			      &HV_Flag,
			      &AbstractGeometry );

    _m_check2p( ReturnStatus, *ReturnMsg,
       "CO_ni_place_horizontal_line:  GRhvls2pt failed" );
    _m_check2q( ReturnStatus, *ReturnMsg );

    /*
     * verify a valid curve was generated
     */
    ReturnStatus = COcheck_curve( ReturnMsg, &AbstractGeometry );
    _m_checkq(ReturnStatus);

    /*
     * -----------------------------------------------------------------------
     *   Step 2:    Construct the line segment
     * -----------------------------------------------------------------------
     */
    _m_debug_str( "CO_ni_place_horizontal_line:  calling co$construct" );
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

    _m_check2p( ReturnStatus,
                *ReturnMsg,
                "CO_ni_place_horizontal_line - failed in co$construct object" );

quit:
    _m_debug_str( "< CO_ni_place_horizontal_line" );
    return ( ReturnStatus );

} /* end CO_ni_place_horizontal_line() */


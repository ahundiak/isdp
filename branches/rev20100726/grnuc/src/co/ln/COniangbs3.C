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

 IGRlong CO_ni_place_angle_bisector_3pt()

  Abstract:
     Non-interactive function for construction of an angular bisector
     by 3 points.  The data points are stored in Events[0], Events[1], 
     and Events[2].  Events[1] is the vertex of the angle bisected.
     The resulting Line Segment bisects the angle from the vertex and
     ends at the bisectors intersection with the imaginary line from
     the other two definition points ( Events[0] and Events[2] ).
        
 Arguments:

   struct GRevent   *Events[]   
      An array of two data point events used to calculate the bisector's
      geometry

         Event[0] is the first definition point of the angle
         Event[1] is the vertex of the angle and one endpoint of the bisector
         Event[2] is the third definition point of the angle

   The rest of the arguments are exactly as specified in co$construct_object
   except that object, objid, and geometry are not allowed.

 History:
    srh   ??/??/?? :  ( memory fault ) created 
    srh   05/23/89 :  removed GRIS_ properties from construct list 

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
#include "madef.h"

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



extern  IGRboolean   GRls2pt();
extern  IGRboolean   MAangbis();
extern  IGRboolean   MA2lnisect();
extern  IGRboolean   MA2pttobc();

/*
 *----------------------------------------
 *   CO_ni_place_angle_bisector_3pt
 *----------------------------------------
 */

IGRlong CO_ni_place_angle_bisector_3pt( ReturnMsg,
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

    IGRboolean          BooleanStatus;  /* return status by MAxxx() routines */

    IGRlong             LocalMsg;          /* return msg of functions called  */
    IGRlong             ReturnStatus = MSSUCC;   /* return code               */

    IGRdouble           Tolerance;         /*                      */
    IGRdouble           Tparm1;            /*                      */
    IGRdouble           Tparm2;            /*                      */

    IGRpoint            FirstPoint;        /*                      */
    IGRpoint            Vertex;            /*                      */
    IGRpoint            ThirdPoint;        /*                      */
    IGRpoint            BisectorPoint1;    /*                      */
    IGRpoint            BisectorPoint2;    /*                      */
    IGRpoint            IntersectionPoint; /*                      */

    struct IGRline      Line1;             /*                      */
    struct IGRline      Line2;             /*                      */
    struct IGRline      Line3;             /*                      */
    struct IGRline      UnitVector;        /*                      */

    GRls_declare(AbstractGeometry,PolesAndWeights);


/* EV - END OF VARIABLE LIST */

    _m_debug_str( "> CO_ni_place_angle_bisector_3pt()" );


    GRls_init(AbstractGeometry,PolesAndWeights);

    FirstPoint[0] = Events[0]->event.button.x;
    FirstPoint[1] = Events[0]->event.button.y;
    FirstPoint[2] = Events[0]->event.button.z;
    
    Vertex[0] = Events[1]->event.button.x;
    Vertex[1] = Events[1]->event.button.y;
    Vertex[2] = Events[1]->event.button.z;

    ThirdPoint[0] = Events[2]->event.button.x;
    ThirdPoint[1] = Events[2]->event.button.y;
    ThirdPoint[2] = Events[2]->event.button.z;


    Line1.point1 = Vertex;
    Line1.point2 = FirstPoint;

    Line2.point1 = Vertex;
    Line2.point2 = ThirdPoint;

    Tolerance = 0.1;  /* This tolerance value is not significant */

    /*
     * Get angular bisector in end point format  
     */
    UnitVector.point1 = BisectorPoint1;
    UnitVector.point2 = BisectorPoint2;

    _m_debug_str( "CO_ni_place_angle_bisector_3pt:  calling MAangbis" );
    BooleanStatus = MAangbis( &LocalMsg,
                              &Line1,
                              &Line2,
                              &Tolerance,
                              &UnitVector );

    if ( COERROR( LocalMsg ) || !( BooleanStatus ) )
    {
       _m_debug_str( "CO_ni_place_angle_bisector_3pt:  MAangbis failed" );
       _m_debug( printf( " b_status = %s\n", BooleanStatus ? "TRUE":"FALSE" ) );
       _m_debug( printf( " msg = 0x%x\n", LocalMsg ) );
       ReturnStatus = MSFAIL;
       goto quit;
    }
 
    /*
     *  Extend calculated bisector to intersect with the
     *   opposite side of the triangle (Line3) defined by 
     *   the three points.
     */
    Line3.point1 = FirstPoint;
    Line3.point2 = ThirdPoint;

    _m_debug_str( "CO_ni_place_angle_bisector_3pt:  calling MA2lnisect" );
    BooleanStatus = MA2lnisect( &LocalMsg,
                                &UnitVector, 
                                &Line3,
                                &Tolerance,
                                 IntersectionPoint,
                                &Tparm1,   /* tparms not used */
                                &Tparm2 );

    if ( COERROR( LocalMsg ) || !( BooleanStatus ) )
    {
       _m_debug_str( "CO_ni_place_angle_bisector_3pt:  MA2lnisect failed" );
       _m_debug( printf( " b_status = %s\n", BooleanStatus ? "TRUE":"FALSE" ) );
       _m_debug( printf( " msg = 0x%x\n", LocalMsg ) );
       ReturnStatus = MSFAIL;
       goto quit;
    }
 

    /*
     *  Get abstract geometry of bisector
     */

    _m_debug_str( "CO_ni_place_angle_bisector_3pt:  calling MA2pttobc" );
    BooleanStatus = MA2pttobc( &LocalMsg,
                                Vertex,
                                IntersectionPoint,
                               &AbstractGeometry );


    if ( COERROR( LocalMsg ) || !( BooleanStatus ) )
    {
       _m_debug_str( "CO_ni_place_angle_bisector_3pt:  MA2pttobc failed" );
       _m_debug( printf( " b_status = %s\n", BooleanStatus ? "TRUE":"FALSE" ) );
       _m_debug( printf( " msg = 0x%x\n", LocalMsg ) );
       ReturnStatus = MSFAIL;
       goto quit;
    }
 
    /*
     * -----------------------------------------------------------------------
     *   Step 2:    Construct the line segment
     * -----------------------------------------------------------------------
     */

    ReturnStatus = COcheck_curve(&LocalMsg,&AbstractGeometry);
    _m_checkq(ReturnStatus);

    _m_debug_str( "CO_ni_place_angle_bisector_3pt:  calling co$construct" );
    if ( classname != NULL )
    {
       /*
        *  classname is specified
        */
        ReturnStatus = co$construct_object(
                        msg = &LocalMsg,
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
                        msg = &LocalMsg,
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

    _m_check2p( ReturnStatus, LocalMsg,
        "CO_ni_place_angle_bisector_3pt - failed in co$construct object" );

quit:
    *ReturnMsg = LocalMsg;
    _m_debug_str( "<  CO_ni_place_angle_bisector_3pt" );
    return ( ReturnStatus );

}

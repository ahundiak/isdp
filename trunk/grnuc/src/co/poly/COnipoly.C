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
   IGRlong CO_ni_place_polygon(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                PolygonGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )
                                                                            
      IGRlong              *msg;
      struct GRevent       *Events[];
      enum GRdpmode        *DisplayMode;
      IGRboolean            newflag;
      struct GRmd_env      *ModuleInfo;
      struct IGRdisplay    *ActiveDisplay;
      IGRshort             *ActiveLevel;
      IGRchar              *attr;
      IGRchar              *name;
      struct GRid          *PolygonGrid;
      struct GRid          *DisplayGrid;
      IGRchar              *classname;
      GRclassid             classid;
      OM_S_NEIGHBOR         neighbor;
      OM_S_OBJID            cob_id;
      GRspacenum            cob_os;
      OM_S_CHANSELECT      *p_co_chanselect;
      IGRint                co_index;

   Abstract:

      This function constructs a bspline representation of a Polygon, then
      constructs and optionally displays a Polygon object.  If the display_obj
      is specified, then the object is displayed.

   Arguments:

      struct GRevent   *Events[]   
	 An array of data point events used to create tha polygon geometry

            Event[0] is the first and last vertex point
            Event[1] is the second vertex point
            Event[2] is the third vertex point

      The rest of the arguments are exactly as specified in co$construct_object
      except that object, objid, and geometry are not allowed.


   Status returns:

      OM_S_SUCCESS            
      OM_E_ABORT
      OM_E_INVARG             
      OM_E_BADCLASSNAMES
      OM_E_INVCLUSTERID
      OM_E_NODYNMEM
      OM_E_NOEXTEND_CLUSTER
      OM_E_NOSUCHCLASS
      OM_E_NOSUCHOS
      OM_I_ADDEDATEND

   Caveats:

      May not specify an object space.  The object space will be the
      same object space as the module's object space.

      Only able to construct a triangle; additional vertices must be added
      after constuction has occured.

  History:

      srh ??/??/?? : ( memory fault ) created 
      srh 05/23/89 : removed GRIS_ properties from construct list 
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
#include "madef.h"
#include "msdef.h"

#include "gr.h"
#include "grerr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "comiscmac.h"
#include "igrmacros.h"

/*
 * eddie type macros for setting up abstract geometry structures for 
 * triangle used in polygon construct
 */
#define GRtriangle_declare(a,b)	\
        struct IGRbsp_curve a;	\
        IGRdouble b[18]

#define GRtriangle_init(a,b)	\
        (a).poles = b;		\
        (a).knots = &b[12]

/*
 *  GRls2pt() converts 2 points into the abstract geometry of a line segment.
 *  MAbccendpts() gets the end points of a linear abstract geometry.  These
 *  two functions are used together to generate the vertices of a polyline.
 *
 *  MApytobc() converts a polyline (series of points) into the abstract 
 *  geometry of the polygon that is to be constructed.
 */
extern  IGRboolean   GRls2pt();
extern  IGRboolean   MAbcendpts();
extern  IGRboolean   MApytobc();

/*
 *----------------------------------------
 *    CO_ni_place_polygon
 *----------------------------------------
 */
IGRlong CO_ni_place_polygon(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                PolygonGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *PolygonGrid;
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

           IGRboolean   b_status;       /* return status                     */
           IGRlong      local_msg;      /* return code                       */
           IGRlong      status;         /* return code                       */
           IGRshort      NumberOfEvents = 2; /* for GRls2pt router            */
           IGRpoint     dummy_point;    /* dummy pt used in MAbcendpts call  */
           IGRpoint     points[4];      /* 4 pts needed to define a          */
                                        /* triangle (last pt = first pt)     */

    struct GRevent     *MyEvents[2];    /* array of event addr for GRls2pt   */
    struct IGRpolyline  polyline;       /* polyline used to create polygon   */

    /*
     *  make the neccessary geometry declarations and allocations for knots
     *  and poles.
     */
    GRls_declare( Lineseg, LinesegPolesEtc );
    GRtriangle_declare( Polygon, PolygonPolesEtc );

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */

    _m_debug_str( "> CO_ni_place_polygon" );

    /*
     *  initialize the pole and knot pointers 
     *
     *     GRls2pt() only needs 2 poles and 4 knots
     *     MApytobc() needs 4 poles and 6 knots
     */
    GRls_init( Lineseg, LinesegPolesEtc );
    GRtriangle_init( Polygon, PolygonPolesEtc );

    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
     local_msg = MSSUCC;
    status = MSSUCC;

    /*
     * <step 1>  Get abstract geometry of line segment defined by the first and
     *           second events.
     */
    MyEvents[0] = Events[0];
    MyEvents[1] = Events[1];

    _m_debug_str( "CO_ni_place_polygon - Calling GRls2pt Router(1)" );
    b_status = GRls2pt( &local_msg,
                         MyEvents,
                        &NumberOfEvents,
                        &Lineseg );
    _m_check_boolp( b_status,"CO_ni_place_polygon - failed in GRls2pt");
    _m_check_bool( b_status, status = OM_E_ABORT );
    _m_check( local_msg, printf( "   msg = 0x%x\n",local_msg ) );
    _m_check_boolq( b_status );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(&local_msg,&Lineseg);
    _m_checkq(status);


    /*
     * <step 2>  Get both end points from the this abstract geometry; these are
     *           the first and second vertices of the polygon. 
     */
    _m_debug_str( "CO_ni_place_polygon - Calling MAbcendpts(1)" );
    b_status = MAbcendpts( &local_msg,
                           &Lineseg,
                            points[0],
                            points[1] );

    _m_check_boolp( b_status,"CO_ni_place_polygon - failed in MAbcendpts");
    _m_check_bool( b_status, status = OM_E_ABORT );
    _m_check( local_msg, printf( "   msg = 0x%x\n",local_msg ) );
    _m_check_boolq( b_status );

    /*
     * <step 3>  Get abstract geometry of line segment defined by the second 
     *           vertex of the polygon and the third events.
     */
    MyEvents[0] = Events[1];
    MyEvents[0]->subtype = GRst_REGULAR;       /* clear any special atributes */
    MyEvents[0]->event.button.x = points[1][0];
    MyEvents[0]->event.button.y = points[1][1];
    MyEvents[0]->event.button.z = points[1][2];

    MyEvents[1] = Events[2];

    _m_debug_str( "CO_ni_place_polygon - Calling GRls2pt Router(2)" );
    b_status = GRls2pt( &local_msg,
                         MyEvents,
                        &NumberOfEvents,
                        &Lineseg );
    _m_check_boolp( b_status,"CO_ni_place_polygon - failed in GRls2pt");
    _m_check_bool( b_status, status = OM_E_ABORT );
    _m_check( local_msg, printf( "   msg = 0x%x\n",local_msg ) );
    _m_check_boolq( b_status );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(&local_msg,&Lineseg);
    _m_checkq(status);


    /*
     * <step 4>  Get the second end point from the this abstract geometry; this 
     *           is the third vertex of the polygon.  
     */
    _m_debug_str( "CO_ni_place_polygon - Calling MAbcendpts (2)" );
    b_status = MAbcendpts( &local_msg,
                           &Lineseg,
                            dummy_point,     /* ignored */
                            points[2] );

    _m_check_boolp( b_status,"CO_ni_place_polygon - failed in MAbcendpts");
    _m_check_bool( b_status, status = OM_E_ABORT );
    _m_check( local_msg, printf( "   msg = 0x%x\n",local_msg ) );
    _m_check_boolq( b_status );

    /*
     * <step 5>  Create a polyline buffer having 4 points.  The first three
     *           of these are the three vertices calculated above.  The 
     *           first vertex is placed in the fourth point to achieve closure.
     *           This buffer is then converted to the abstract geometry of a 
     *           polygon (triangle).
     */
    polyline.num_points = 4;     /* 4 vertices; first vertex = last vertex    */
    polyline.points = points[0]; /* array of polyline vertices */

    /* close polyline */
    points[3][0] = points[0][0];
    points[3][1] = points[0][1];
    points[3][2] = points[0][2];

    _m_debug_str( "CO_ni_place_polygon - Calling MApytobc" );
    b_status = MApytobc( &local_msg,
                         &polyline,
                         &Polygon );
    _m_check_boolp( b_status,"CO_ni_place_polygon - failed in MApytobc");
    _m_check_bool( b_status, status = OM_E_ABORT );
    _m_check( local_msg, printf( "   msg = 0x%x\n",local_msg ) );
    _m_check_boolq( b_status );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(&local_msg,&Polygon);
    _m_checkq(status);

    /*
     * <step 6>  Construct the polygon (triangle) via om$construct.
     */

    /* set up the object space of the new object */
    PolygonGrid->osnum = ModuleInfo->md_id.osnum;

    /*
     *  classname is specified
     */
    _m_debug_str( "CO_ni_place_polygon - Calling co$construct" );
    if ( classname != NULL )
    {
        status = co$construct_object(
                        msg = &local_msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &Polygon,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = PolygonGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classname = classname );
                                                                            
    }
    else /* classid is specified */
    {
        status = co$construct_object(
                        msg = &local_msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &Polygon,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = PolygonGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classid = classid );
    }

    _m_check2p( 
                status,
                local_msg,
                "CO_ni_place_polygon - failed in co$construct object" );

quit:
    *msg = local_msg;
    _m_debug_str( "< CO_ni_place_polygon" );
    return ( status );
}

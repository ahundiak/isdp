/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                     < 1986, 1987, 1988, 1989, 1990 >
  
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
IGRlong CO_ni_place_npoly_by_vertex(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                LineGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index,
                p_go_chanselect,
                go_index,
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *LineGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;
    OM_S_CHANSELECT      *p_go_chanselect;
    IGRint                go_index;

Abstract
    This function constructs a bspline representation of an n-sided
    polygon, then constructs and optionally displays a polygon object.
    If the display_obj is specified, then the object is displayed.
    Note: The function has been modified to be used for placing polygons
    by midpoint of side as well.
         
                                                                        
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the number of sides
        event[1] is the center point of the polygon.
        event[2] is a vertex point of the polygon.


    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, objid, and geometry are not allowed.


Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_BADCLASSNAMES
        OM_E_INVCLUSTERID
        OM_E_NODYNMEM
        OM_E_NOEXTEND_CLUSTER
        OM_E_NOSUCHCLASS
        OM_E_NOSUCHOS
        OM_I_ADDEDATEND
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.

History
    trc 06/15/87 : Created
    srh 05/23/89 : removed GRIS_ properties from construct list 
    jjc 10/25/89 : added funtionality for N-sided Polygon by Midpoint of Side
    jjc 01/24/90 : Conditionally compiled out the code for Polygon by
                   Midpoint of Side for IDRAW.

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
#include "dpdef.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "igrmacros.h"
#include "comiscmac.h"
#include "dpmacros.h"

extern IGRlong COnpolygonConstruct();

#ifndef IDRAW
extern IGRlong COnmppolygonConstruct();
#endif /* IDRAW */

/*----------------------------------------
 *  CO_ni_place_npoly
 *----------------------------------------
 */
IGRlong CO_ni_place_npoly_by_vertex(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                LineGrid,
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
    struct GRid          *LineGrid;
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

    IGRlong             status;         /* return code                  */
    IGRboolean          b_status;       /* return status                */
    struct GRid         WindowGrid;   /* window object id */
    IGRlong             WhichError; 
    IGRmatrix           RotationMatrix;
    IGRlong             BytesReturned;
    struct var_list     VariableList[2];
    IGRlong             NumberOfSides;
    IGRdouble          *PointArray;
    IGRdouble          *Knots;
    struct IGRbsp_curve bspline;        /* used in the construct            */
    struct IGRpolyline  polyline;       /* polyline used to when making bsp */
    IGRpoint            CenterPoint;    /* point part of center event       */
    IGRpoint            EdgePoint;      /* point part of vertex event       */

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "CO_ni_place_npoly_by_vertex." );


    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = MSSUCC;
    b_status = TRUE;


    NumberOfSides = (IGRlong) Events[0]->event.value;
    PointArray = (IGRdouble *)om$malloc( 
                    size = ((NumberOfSides + 1) * 3) * sizeof( IGRdouble ) );
    Knots = (IGRdouble *)om$malloc(
                    size = (NumberOfSides + 1 + 2 ) * sizeof( IGRdouble ) );
    if ( PointArray == NULL || Knots == NULL )
    {
        *msg = MSFAIL;
        return( OM_E_ABORT );
    }

    WindowGrid.objid = Events[1]->event.button.objid;
    WindowGrid.osnum = Events[1]->event.button.osnum;
                                                                              

    /*
     *  set up the variable list
     */
    VariableList[0].var       = VIEW_ROTATION;
    VariableList[0].var_ptr   = (char *) RotationMatrix;
    VariableList[0].num_bytes = sizeof( IGRdouble ) * 16;
    VariableList[0].bytes_returned = &BytesReturned;
    VariableList[1].var = END_PARAM;
                                                                              

    /*
     *  get the view matrix for the display
     */
    _m_debug_str( "COnipoly - calling inq_set." );
    status = dp$inq_set_gragad(
                            msg = msg,
                            gragad_objid = WindowGrid.objid,
                            which_error = &WhichError,
                            var_list = VariableList );
    _m_check2p( status, *msg, "COnipoly - failed inq_set_gragad." );
    _m_check2q( status, *msg );
                                                                              

                                                                              
    /*
     *  init the polyline
     */
    polyline.num_points = NumberOfSides + 1;
    polyline.points     = PointArray;
                                                                              

    /*
     *  init the bspline's pointers
     */
    bspline.poles = PointArray;
    bspline.knots = Knots;
                                                                              

    /*
     *  construct the point array of the polygon
     */
    CenterPoint[0] = Events[1]->event.button.x;
    CenterPoint[1] = Events[1]->event.button.y;
    CenterPoint[2] = Events[1]->event.button.z;
    EdgePoint[0] = Events[2]->event.button.x;
    EdgePoint[1] = Events[2]->event.button.y;
    EdgePoint[2] = Events[2]->event.button.z;


/*  the following check is done to distinguish which command called this
 *  function.  Place N-sided Polygon by Vertex will have a subtype of
 *  GRst_REGULAR and Place N-sided Polygon by Midpoint of Side will 
 *  have a subtype of GRst_DEFAULT.  this was done since the two commands
 *  were so similar. 
 */

 if(Events[3]->subtype == GRst_REGULAR) {

    _m_debug_str( "COnipoly - calling COnpolygonConstruct." );
    status = COnpolygonConstruct( 
                                msg,
                                RotationMatrix,
                                CenterPoint,
                                EdgePoint,
                                &NumberOfSides,
                                PointArray );
    _m_check2p( status, *msg, "COninpoly - failed in COnpolyConstr." );
    _m_check2q( status, *msg );

  }
 else if(Events[3]->subtype == GRst_DEFAULT) {
#ifndef IDRAW
    _m_debug_str( "COnipoly - calling COnmppolygonConstruct." );
    status = COnmppolygonConstruct( 
                                msg,
                                RotationMatrix,
                                CenterPoint,
                                EdgePoint,
                                &NumberOfSides,
                                PointArray );
    _m_check2p( status, *msg, "COninpoly - failed in COnmppolyConstr." );
    _m_check2q( status, *msg );
#endif /* IDRAW */
  }

    /*
     *  turn the polyline into a bspline
     */
    _m_debug_str( "COnipoly - calling MApytobc." );
    b_status = MApytobc( 
                        msg,
                        &polyline,
                        &bspline );
    _m_check_boolp( b_status, "COnipoly - failed MApytobc." );
    _m_check_boolq( b_status );
    _m_checkp( *msg, "COnipoly - failed MApytobc." );
    _m_checkq( *msg );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&bspline);
    _m_checkq(status);

    /*
     *  classname is specified
     */
    _m_debug_str( "CO_ni_place_npoly - calling construct." );
    LineGrid->osnum = ModuleInfo->md_id.osnum;
    if ( classname != NULL )
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &bspline,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = LineGrid,
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
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &bspline,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = LineGrid,
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
                *msg,
                "CO_ni_place_npoly - failed in co$construct object." );

quit:
    om$dealloc( ptr = PointArray );
    om$dealloc( ptr = Knots );
    return ( status );
}

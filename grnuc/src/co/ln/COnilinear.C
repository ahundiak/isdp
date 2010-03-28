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
IGRlong CO_ni_place_linear(
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
    This function constructs a bspline representation of a line, then
     constructs and optionally displays a line object.
    If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the first point of the line.
        event[1] is the second point of the line.


    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, objid, and geometry are not allowed.


Status returns

    om return codes dealing with construct/connect/send
                                                                            
Caveats
    May not specify an object space.  The object space will be the
    same object space as the module's object space.

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
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"

#include "igrmacros.h"
#include "comiscmac.h"


/*
 *  the router to construct the line returns boolean
 */
extern    IGRboolean    GRls2pt();



/*----------------------------------------
 *  CO_ni_place_linear
 *----------------------------------------
 */
IGRlong CO_ni_place_linear(
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

    IGRlong		status;
    IGRshort            NumberOfEvents = 2;

    IGRboolean          b_status;

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a line using 
     *  eddie jennings macro
     */
    GRls_declare( line, LinePolesetc );

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "CO_ni_place_linear." );


    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = OM_S_SUCCESS;


    /*
     *  initialize the poles, weights, knots pointers in the line 
     *  using the macro defined by eddie jennings
     */
    GRls_init( line, LinePolesetc );


    /*  
     *  ROUTER:
     *  Construct the nurb form of a line given
     *  the two data point events.  Special construction
     *  points are handled by this router.
     */
    _m_debug_str( "CO_ni_place_linear - Calling GRls2pt Router." );
    b_status = GRls2pt( 
                    msg,
                    Events,
                    &NumberOfEvents,
                    &line );
    _m_check_boolp( b_status,"CO_ni_place_linear - failed in GRls2pt.");
    _m_check_boolq( b_status );
    _m_checkp( *msg, "CO_ni_place_linear - failed in GRls2pt." );
    _m_checkq( *msg );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&line);
    _m_checkq(status);

    /*
     *  set up the object space of the new object
     */
    _m_debug_str( "CO_ni_place_linear - calling construct." );
    LineGrid->osnum = ModuleInfo->md_id.osnum;


    /*
     *  classname is specified
     */
    if ( classname != NULL )
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &line,
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
                        geometry = &line,
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
                "CO_ni_place_linear - failed in co$construct object." );

quit:
    return ( status );
}

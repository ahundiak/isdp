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
IGRlong CO_ni_place_circle(
                router_pointer,
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                CircleGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )

    IGRboolean    (*router_pointer)();
    IGRshort               NumberOfEvents;
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *CircleGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

Abstract
    This function constructs a bspline representation of a circle, then
     constructs and optionally displays a circle object.
    If the display_obj is specified, then the object is displayed.
    The router_pointer is the router used to construct the bspline.
                                                                            
Arguments

    IGRboolean    *router_pointer();
        pointer to one of R.D.'s math routers

    IGRshort           NumberOfEvents
        number of events to supply to router_pointer

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

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
    trc 03/09/87 : created
    srh 05/22/89 : removed hard coded properties from co$construct_object
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
#include "grerr.h"


/*----------------------------------------
 *  CO_ni_place_circle
 *----------------------------------------
 */
IGRlong CO_ni_place_circle(
                router_pointer,
                NumberOfEvents,
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                CircleGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index )
                                                                            
    IGRboolean    (*router_pointer)();
    IGRshort               NumberOfEvents;
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *CircleGrid;
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

    IGRlong     status;

    IGRboolean          b_status;       /* return status                */

    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a circle using 
     *  eddie jennings macro
     */
    GRconic_declare( circle, CirclePolesetc );

/* EV - END OF VARIABLE LIST, USED FOR SEARCHING */


    _m_debug_str( "CO_ni_place_circle." );


    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = OM_S_SUCCESS;


    /*
     *  initialize the poles, weights, knots pointers in the circle 
     *  using the macro defined by eddie jennings
     */
    GRconic_init( circle, CirclePolesetc );


    /*  
     *  ROUTER:
     *  Construct the nurb form of a circle given
     *  the data point events.  Special construction
     *  points are handled by this router.
     */
    _m_debug_str( "CO_ni_place_circle - Calling router_pointer Router." );
    b_status = router_pointer( 
                    msg,
                    Events,
                    &NumberOfEvents,
                    &circle );
    _m_checkp( *msg, "CO_ni_place_circle - failed in router_pointer." );
    _m_checkq( *msg );
    _m_check_boolp( b_status,"CO_ni_place_circle - failed in router_pointer.");
    _m_check_boolq( b_status );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&circle);
    _m_checkq(status);

    /*
     *  set up the object space of the new object
     */
    _m_debug_str( "CO_ni_place_circle - calling construct." );
    CircleGrid->osnum = ModuleInfo->md_id.osnum;        
    
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
				     geometry = &circle,
				     symbology = ActiveDisplay,
				     level = ActiveLevel,
				     attr = attr,
				     name = name,
				     grid = CircleGrid,
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
				     geometry = &circle,
				     symbology = ActiveDisplay,
				     level = ActiveLevel,
				     attr = attr,
				     name = name,
				     grid = CircleGrid,
				     display_obj = DisplayGrid,
				     neighbor = neighbor,
				     cob_id = cob_id,
				     cob_os = cob_os,
				     p_co_chansel = p_co_chanselect,
				     co_index = co_index,
				     classid = classid );
      }
    
    _m_check2p(status,*msg,
	       "CO_ni_place_circle - failed in co$construct object." );
  quit:
    return ( status );
}





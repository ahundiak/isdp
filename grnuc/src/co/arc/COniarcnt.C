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
IGRlong CO_ni_place_arc_cent(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                CirarcGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index,
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *CirarcGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

Abstract
    This function constructs a bspline representation of a circular arc, then
    constructs and optionally displays a circular arc object.
    If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] center point.
        event[1] axis point 1.
        event[2] axis point 2.


    The rest of the arguments are exactly as specified in co$construct_object.
    Except that object, and objid are not allowed.


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
    bmr 03/06/87 : adapted to the new include file design
    srh 05/22/89 : removed hard coded properties from co$construct_object
*/

#include "coimport.h"
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
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

/*
 *  the router to construct the arc returns boolean
 */

extern    IGRboolean    GRarcnptang();


/*----------------------------------------
 *  CO_ni_place_arc_cent
 *----------------------------------------
 */
IGRlong CO_ni_place_arc_cent(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                CirarcGrid,
                DisplayGrid,
                classname,
                classid,
                neighbor,
                cob_id,
                cob_os,
                p_co_chanselect,
                co_index)
                                                                            
    IGRlong              *msg;
    struct GRevent       *Events[];
    enum GRdpmode        *DisplayMode;
    IGRboolean            newflag;
    struct GRmd_env      *ModuleInfo;
    struct IGRdisplay    *ActiveDisplay;
    IGRshort             *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *CirarcGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;
{


    IGRlong             status;         /* return code                  */
    IGRshort            NumberOfEvents;
    IGRboolean          b_status;       /* return status                */
    IGRboolean          clock_flag;
    IGRlong             NumberOfBytes;
    IGRlong             BytesReceived;
    IGRlong             EventSize=sizeof( struct GRevent);
                                        /* size of event                */


    /*
     *  make the neccessary declarations for the bspline curve
     *  and the knots, weights, poles for a ellipse using 
     *  eddie jennings macro
     */
    GRconic_declare( circle_arc, circle_arc_poles );



    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
     status = MSSUCC;


    /*
     *  initialize the poles, weights, knots pointers in the circle_arc 
     *  using the macro defined by eddie jennings
     */
    GRconic_init(circle_arc, circle_arc_poles);


    /*  
     *  ROUTER:
     *  Construct the nurb form of a circle arc given
     *  the two data point events.  Special construction
     *  points are handled by this router.
     */


    NumberOfEvents = 3;
    NumberOfBytes = sizeof( clock_flag );
    status = gr$get_arc_direction(msg = msg,
                                  sizbuf = &NumberOfBytes,
                                  buffer = &clock_flag,
                                  nret = &BytesReceived );

    b_status = GRarcnptang(msg,
                           Events,
                          &NumberOfEvents,
                          &clock_flag,
                          &circle_arc);
    _m_check_boolp( b_status,"CO_ni_place_arc_cent - failed in ");
    _m_check_boolq( b_status );
    _m_checkq( *msg );


    /*
     *  set up the object space of the new object
     */
    CirarcGrid->osnum = ModuleInfo->md_id.osnum;


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
                        geometry = &circle_arc,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = CirarcGrid,
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
                        geometry = &circle_arc,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = CirarcGrid,
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
                "CO_ni_place_arc_cent - failed in co$construct object." );

quit:
    return ( status );
}

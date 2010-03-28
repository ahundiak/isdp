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
IGRlong CO_ni_place_point(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                PointGrid,
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
    IGRshort              *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *PointGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

Abstract
    This function constructs a bspline representation of a point, then
     constructs and optionally displays a point object.
    If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        Event[0] - point


    IGRlong      number_events
        the number of events in the array.
        should be 2


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
    srh 05/23/89 : removed GRIS_ properties from construct list 
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
 *  the math function to construct the point returns boolean
 */
extern    IGRboolean    MA2pttobc();

/*----------------------------------------
 *  CO_ni_place_point
 *----------------------------------------
 */
IGRlong CO_ni_place_point(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                PointGrid,
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
    IGRshort              *ActiveLevel;
    IGRchar              *attr;
    IGRchar              *name;
    struct GRid          *PointGrid;
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
    IGRboolean          b_status;       /* return status                */
    IGRdouble           point1[3];      /* first point */
    IGRdouble           point2[3];      /* second point */
extern    IGRboolean    MA2pttobc();
    struct IGRbsp_curve point;
    IGRdouble           pole_buff[15];  /* stub poles for bspline  */
    IGRdouble           knot_buff[15];  /* stub knots for bspline  */
    struct IGRdisplay   local_display;
    IGRboolean          aflag = 0;

    aflag = pwIsActivationOn();
    if(aflag)
      pwGetActiveModuleEnv(ModuleInfo);

    if ( ActiveDisplay == NULL )
    {
        IGRlong NumberOfBytes;
        IGRlong BytesReceived;

        NumberOfBytes = sizeof( local_display );
        status = gr$get_active_display(msg = msg,
                                       sizbuf = &NumberOfBytes,
                                       buffer = &local_display,
                                       nret = &BytesReceived );
        local_display.weight = local_display.weight +3;
        if(local_display.weight > 31 ) local_display.weight = 31;
        ActiveDisplay = &local_display;
    }
    else	{
	ActiveDisplay->weight += 3;
        if(ActiveDisplay->weight > 31 ) ActiveDisplay->weight = 31;
    }

    point.poles = pole_buff;         
    point.knots = knot_buff;


    /*
     *  SET up msg and status so that a nil event will not end up with a
     *  bad status
     */
    *msg = MSSUCC;
    status = MSSUCC;

    point1[0] = Events[0]->event.button.x;
    point1[1] = Events[0]->event.button.y;
    point1[2] = Events[0]->event.button.z;

    point2[0] = Events[0]->event.button.x;
    point2[1] = Events[0]->event.button.y;
    point2[2] = Events[0]->event.button.z;

    b_status = MA2pttobc(msg,
                         point1,
                         point2,
                        &point); 
    _m_check_boolp( b_status,"CO_ni_place_point - failed in MA2ptrcconstr.");
    _m_check_boolq( b_status );
    _m_checkp( *msg, "CO_ni_place_point - failed in MA2ptrcconstr." );
    _m_checkq( *msg );


    /*
     *  set up the object space of the new object
     */
    PointGrid->osnum = ModuleInfo->md_id.osnum;


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
                        geometry = &point,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = PointGrid,
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
        status = co$construct_object(msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &point,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = PointGrid,
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
                "CO_ni_place_point - failed in co$construct object." );

    ActiveDisplay->weight -= 3;

quit:
    return ( status );
}

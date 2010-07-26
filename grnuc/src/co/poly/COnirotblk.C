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
IGRlong CO_ni_place_rotblk(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                RotblkGrid,
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
    struct GRid          *RotblkGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;

Abstract
    This function constructs a bspline representation of a rotated block, then
     constructs and optionally displays a rotated block object.
    If the display_obj is specified, then the object is displayed.
                                                                            
Arguments

    IGRlong      *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        Event[0] - 1st point
        Event[1] - 2st point
        Event[2] - point defining hieght

    IGRlong      number_events
        the number of events in the array.
        should be 3


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
#include "grerr.h"
#include "OMerrordef.h"
/*
 *  the router to construct the rotated block returns boolean
 */
extern    IGRboolean    MA3ptrcconstr();



/*----------------------------------------
 *  CO_ni_place_rotblk
 *----------------------------------------
 */
IGRlong CO_ni_place_rotblk(
                msg,
                Events,
                DisplayMode,
                newflag,
                ModuleInfo,
                ActiveDisplay,
                ActiveLevel,
                attr,
                name,
                RotblkGrid,
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
    struct GRid          *RotblkGrid;
    struct GRid          *DisplayGrid;
    IGRchar              *classname;
    GRclassid             classid;
    OM_S_NEIGHBOR         neighbor;
    OM_S_OBJID            cob_id;
    GRspacenum            cob_os;
    OM_S_CHANSELECT      *p_co_chanselect;
    IGRint                co_index;
{
    IGRboolean          b_status;       /* return status                */
    IGRlong             status;         /* return code                  */
    struct IGRbsp_curve rotblk;
    IGRdouble           pt1[3],pt2[3],pt3[3];
    IGRdouble           pole_buff[15];  /* stub poles for bspline  */
    IGRdouble           knot_buff[7];  /* stub knots for bspline  */
    IGRchar             classstub[15];

    rotblk.poles = pole_buff;         
    rotblk.knots = knot_buff;

    /*
     *  set up msg and status so that a nil event will not end up with a
     *  bad status
     */

    *msg = MSSUCC;
    status = MSSUCC;


    /*
     *  initialize the poles, weights, knots pointers in the rotated block 
     *  using the macro defined by eddie jennings
     */
    if((Events[0]->event.button.x == Events[1]->event.button.x) &&
       (Events[0]->event.button.y == Events[1]->event.button.y) &&
       (Events[0]->event.button.z == Events[1]->event.button.z))
      {
	status = MSFAIL;
       *msg = GRILLDEFINITION;
        goto quit;
      }
    pt1[0] = Events[0]->event.button.x;
    pt1[1] = Events[0]->event.button.y;
    pt1[2] = Events[0]->event.button.z;

    pt2[0] = Events[1]->event.button.x;
    pt2[1] = Events[1]->event.button.y;
    pt2[2] = Events[1]->event.button.z;

    pt3[0] = Events[2]->event.button.x;
    pt3[1] = Events[2]->event.button.y;
    pt3[2] = Events[2]->event.button.z;
    b_status = MA3ptrcconstr(msg,
                             pt1,
                             pt3,
                             pt2,
                            &rotblk); 
    _m_check_boolp( b_status,"CO_ni_place_rotblk - failed in MA3ptrcconstr.");
    _m_check_boolq( b_status );
    _m_checkp( *msg, "CO_ni_place_rotblk - failed in MA3ptrcconstr." );
    _m_checkq( *msg );

    /*
     * verify a valid curve was generated
     */
    status = COcheck_curve(msg,&rotblk);
    _m_checkq(status);

    /*
     *  set up the object space of the new object
     */
    RotblkGrid->osnum = ModuleInfo->md_id.osnum;


    /*
     *  classname is specified
     */
    if ( classname != NULL )
    {
        strcpy(classstub,"GR3dorthpoly");
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = (IGRchar *) &rotblk,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = RotblkGrid,
                        display_obj = DisplayGrid,
                        neighbor = neighbor,
                        cob_id = cob_id,
                        cob_os = cob_os,
                        p_co_chansel = p_co_chanselect,
                        co_index = co_index,
                        classname = classstub);
                                                                            
    }
    else /* classid is specified */
    {
        status = co$construct_object(
                        msg = msg,
                        mode = DisplayMode,
                        module = ModuleInfo,
                        newflag = newflag,
                        properties = 0,
                        geometry = &rotblk,
                        symbology = ActiveDisplay,
                        level = ActiveLevel,
                        attr = attr,
                        name = name,
                        grid = RotblkGrid,
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
                "CO_ni_place_rotblk - failed in co$construct object." );

quit:
    return ( status );
}

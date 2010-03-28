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
IGRlong CO_ni_place_tentat_point(
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
 */


/*----------------------------------------
 *  CO_ni_place_tentat_point
 *----------------------------------------
 */
IGRlong CO_ni_place_tentat_point(
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

    *msg = MSSUCC;
    status = MSSUCC;

    COdiscoords(msg,&Events[0]->event.button,ModuleInfo,KEYIN_FIELD,LEFT_JUS);

    DPdrawcross( msg,&Events[0]->event.button);

    return ( status );
}

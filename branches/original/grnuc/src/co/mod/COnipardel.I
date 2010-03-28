/* #######################    APOGEE COMPILED   ######################## */
/* 
IGRlong CO_ni_partial_delete(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct;    
                ObjectsGrids )
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;    
    struct GRid          *ObjectsGrids;

                                                                               

Abstract
                                                                            
Arguments

    IGRlong           *msg
        return codes

    struct GRevent   *events[]
        an array of events.  these are usually collected by
        a command object.  

        event[0] is the from point
        event[1] is the to point
        event[2] is the directional point if element is PHYSICALLY closed.

    struct GRmd_env   *module
        context of located object

    GRobjid           cob_id
        object id of calling object, or at least some object

    GRspacenum        cob_os
        object space number of calling object, or at least some object

    struct GRid       *display_obj
        id of object to display located object

Status returns

        OM_S_SUCCESS            
        OM_E_INVARG             
        OM_E_NODYNMEM
        OM_E_NOSUCHOS

History
    bmr 03/06/87 : adapted to the new include file design
*/
class implementation Root;

#include "coimport.h"
#include "OMerrordef.h"
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
#include "msdef.h"
#include "dp.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

from GRcurve      import GR2ptpartdel; 
from GRcurve      import GR3ptpartdel;
from GRvg         import GRgeomprops;
from GRgraphics   import GRdisplay;


/*----------------------------------------
 *  CO_ni_partial_delete
 *----------------------------------------
 */
IGRlong CO_ni_partial_delete(
                msg,
                Events,
                ModuleInfo,
                DisplayMode,
                DisplayGrid,
                my_id,
                MyChannelStruct,
                ObjectsGrid)
                                                                               
    IGRlong              *msg;
    struct GRevent       *Events[];
    struct GRmd_env      *ModuleInfo;
    enum GRdpmode         DisplayMode;
    struct GRid          *DisplayGrid;
    GRobjid               my_id;
    OM_S_CHANSELECT      *MyChannelStruct;    
    struct GRid          *ObjectsGrid;
                                                                               
{

    IGRlong                      status;         /* return code             */
    struct GRevent               FromEvent;
    struct GRevent               ToEvent;
    struct GRevent               DirEvent;
    IGRpoint                     ToPoint;
    struct GRparms               ToParms;
    IGRpoint                     DirPoint;
    struct GRparms               DirParms;
    IGRpoint                     FromPoint;
    struct GRparms               FromParms;
    struct GRid                  obj1;
    struct GRid                  obj2;
    IGRshort                     num;
    struct GRprops               properties;
    struct GRid                  element;
    IGRuint                      NumberObjectsFound;
    OM_S_OBJECT_LINKAGE          ChannelLinkage[1];
    enum GRdpmode                dp_mode;

    if ( MyChannelStruct != NULL )  /* extract object from channel */
     {
       /*
        *  find out who is on my channel
        */
       status = om$get_channel_objects(
                        objid = my_id,
                        p_chanselect = MyChannelStruct,
                        list = ChannelLinkage,
                        size = 1,
                        count = &NumberObjectsFound );
       element.objid = ChannelLinkage[0].S_objid;
       element.osnum = ChannelLinkage[0].osnum;
     }

    else                            /* grid passed */

     {
        element = *ObjectsGrid;
     }

    /*
     *  pull the events out of the array
     */
    FromEvent = *Events[0];
    ToEvent   = *Events[1];

    status = om$send(msg = message GRvg.GRgeomprops(msg,
                              &ModuleInfo->md_env.matrix_type,
                               ModuleInfo->md_env.matrix,
                              &properties),
                        targetid = element.objid,
                        targetos = element.osnum );
      _m_check2q( status, *msg );


     /*
      * Project from point onto object in ObjectsGrid 
      */
     status = co$project_event( msg     =  msg,
                                event   = &FromEvent,
                                module  =  ModuleInfo,
                                cob_id  =  my_id,
                                grid    = &element,
	 	                parms   = &FromParms,
	  		        point   =  FromPoint );
      _m_check2q(status, *msg);

      /*
       * Project to point onto object in ObjectsGrid 
       */

      status = co$project_event( msg     =  msg,
                                 event   = &ToEvent,
                                 module  =  ModuleInfo,
                                 cob_id  =  my_id,
                                 grid    = &element,
	  	                 parms   = &ToParms,
   			         point   =  ToPoint );
      _m_check2q(status, *msg);

      if(properties.phy_closed)
       {
         DirEvent   = *Events[2];
         status = co$project_event( msg     =  msg,
                                    event   = &DirEvent,
                                    module  =  ModuleInfo,
                                    cob_id  =  my_id,
                                    grid    = &element,
	     	                    parms   = &DirParms,
        	                    point   =  DirPoint );
        _m_check2q(status, *msg);

       /*
        *  send to pardel to object
        */
       status = om$send(msg = message GRcurve.GR3ptpartdel(msg,
                                    (struct GRmd_env *)&ModuleInfo->md_id,
                                     FromPoint,
                                     DirPoint,
                                     ToPoint,
                                    &FromParms,
                                    &DirParms,
                                    &ToParms,
                                    &obj1.objid,
                                    &obj2.objid,
                                    &num),
                      targetid = element.objid,
                      targetos = element.osnum );
/*
    _m_check2(status, *msg, ex$message( msgnumb = GR_E_ErrEnc,
                                        field   = ERROR_FIELD,
                                        justification = LEFT_JUS ); );

*/
    _m_check2q( status, *msg );
    }
   else
    {

       status = om$send(msg = message GRcurve.GR2ptpartdel(msg,
                                    (struct GRmd_env *)&ModuleInfo->md_id,
                                     FromPoint,
                                     ToPoint,
                                    &FromParms,
                                    &ToParms,
                                    &obj1.objid,
                                    &obj2.objid,
                                    &num),
                      targetid = element.objid,
                      targetos = element.osnum );
/*
      _m_check2(status, *msg, ex$message( msgnumb = GR_E_ErrEnc,
                                          field   = ERROR_FIELD,
                                          justification = LEFT_JUS ); );

*/

    }

    dp_mode = DisplayMode;
    status = om$send(msg = message GRgraphics.GRdisplay (msg,
                             &ModuleInfo->md_env.matrix_type,
                              ModuleInfo->md_env.matrix,
                             &dp_mode, 
                              DisplayGrid),
                     targetid = obj1.objid,
                     targetos = element.osnum);
    if(num > 1)
      {
        status = om$send(msg = message GRgraphics.GRdisplay (msg,
                             &ModuleInfo->md_env.matrix_type,
                              ModuleInfo->md_env.matrix,
                             &dp_mode, 
                              DisplayGrid),
                     targetid = obj2.objid,
                     targetos = element.osnum);

      }

quit:
    return(OM_S_SUCCESS);
}

end implementation Root;

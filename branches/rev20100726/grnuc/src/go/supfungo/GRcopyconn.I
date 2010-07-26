/* #######################    APOGEE COMPILED   ######################## */
class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "grownerdef.h"

from GRgraphics   import   GRcopy;
from GRconnector  import   GRflexconn, GRrigidconn;

/*\
Name
   GRcopy_and_connect_object

Description
   This is a helper function that performs a construct and connect.

   *msg              IGRlong              Completiton code
   osnum             GRspacenum           Osnum of object to be copied
   objid             GRobjid              Object id of object to be copied
   *mod_env          struct GRmd_env      Module environment
   *target_env       struct GRmd_env      Target module environment
   *target_id        struct GRid          Target id for connect
   channel_type      IGRint               Has the following values
                                             -  GR_RIGID
                                             -  GR_FLEXIBILE
   connection_type   IGRlong              Has the following values
                                             -  GR_OVERRIDE
                                             -  GR_NO_OVERRIDE
   *new_id           struct GRid          Object id of copied object

Notes
   The new_id may be NULL.

Return Values
   MSSUCC   -  If successful
   MSFAIL   -  If failure

History
   Gray Winn   12/30/87    Creation Date
\*/

IGRint GRcopy_and_connect_object (msg, osnum, objid, mod_env, target_env,
                                  target_id, channel_type, 
                                  connection_type, new_id)
IGRlong           *msg;
GRspacenum        osnum;
GRobjid           objid;
struct GRmd_env   *mod_env;
struct GRmd_env   *target_env;
struct GRid       *target_id;
IGRint            channel_type;
IGRlong           connection_type;
struct GRid       *new_id;
{
IGRlong           om_msg;
GRobjid           new_objid;

   *msg = MSSUCC;

   /*
    *  Construct a copy of the object.
    */

   om_msg = om$send (msg = message GRgraphics.GRcopy (msg, mod_env, 
            target_env, &new_objid),
            senderid = objid, targetos = osnum,  targetid = objid);

   om_msg = GRconnect_object (msg, target_env->md_id.osnum, new_objid, 
            target_id, channel_type, connection_type, OM_K_MAXINT,
            OM_K_MAXINT);

   if (new_id)
   {
      new_id->osnum = target_env->md_id.osnum;
      new_id->objid = new_objid;
   }
   return(om_msg);
}

/*\
Name
   GRconnect_object

Description
   This is a helper function that performs a connect operation.

   *msg              IGRlong              Completiton code
   osnum             GRspacenum           osnum of connected object
   objid             GRobjid              object id connected object
   *target_id        struct GRid          Target id for connect
   channel_type      IGRint               Has the following values
                                             -  GR_RIGID
                                             -  GR_FLEXIBILE
   connection_tye    IGRint               Has the following values
                                             -  GR_OVERRIDE
                                             -  GR_NO_OVERRIDE
   target_index      IGRlong              Index for the target channel 
                                          when connecting.
   obj_index         IGRlong              Index for the object's channel
                                          when connecting. 

Return Values
   MSSUCC   -  If successful
   MSFAIL   -  If failure

History
   Gray Winn   12/30/87    Creation Date
\*/

IGRint GRconnect_object (msg, osnum, objid, target_id, channel_type,
                         connection_type, target_index, obj_index)
IGRlong           *msg;
GRspacenum        osnum;
GRobjid           objid;
struct GRid       *target_id;
IGRint            channel_type;
IGRlong           connection_type;
IGRlong           target_index;
IGRlong           obj_index;
{
IGRlong           om_msg;

   *msg = MSSUCC;

   if (channel_type == GR_RIGID)
   {
      om_msg = om$send (
               msg = message GRconnector.GRrigidconn (msg, target_id,
               &target_index), 
               senderid = NULL_OBJID, targetos = osnum, targetid = objid);
   }else
   {
      om_msg = om$send(
               msg = message GRconnector.GRflexconn (msg, &connection_type,
               target_id, &target_index, &obj_index), 
               senderid = NULL_OBJID, targetos = osnum, targetid = objid);
   }
   return(om_msg);
}
end implementation Root;

class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

from GRreffile import GRgetosnum;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRcomponent_disconnecting                                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRcomponent_disconnecting ( IGRlong         * msg; 
                                   struct GRmd_env * mod_env;
                                   struct GRid     * comp_id )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    
    *msg = MSSUCC;

    return(om_msg);
}        

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRflexconn                                                      |
 |                                                                           |
 | This method keeps instance objects from being flexibly nested.            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRflexconn ( IGRlong     *msg;
                    IGRlong     *flag;
                    struct GRid *owners_id;
                    IGRlong     *owners_index;
                    IGRlong     *graphics_index )
{
    IGRlong     om_msg = OM_S_SUCCESS;
    OMuword     classid;

    *msg = MSSUCC;
    
    /*
     * Get the classid.
     */
    om_msg = om$get_classid (objid = owners_id->objid,
                             osnum = owners_id->osnum,
                             p_classid = &classid);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }
    
    /*
     * If the owner isn't another instance object ...
     */
    if (om$is_ancestry_valid (superclassid = OPP_EMinstance_class_id,
                              subclassid = classid) != OM_S_SUCCESS)
    {
        om_msg = om$send ( msg = message GRconnector.GRflexconn
                                                        ( msg,
                                                          flag,
                                                          owners_id,
                                                          owners_index,
                                                          graphics_index ),
                           mode = OM_e_wrt_message,
                           targetid = my_id);
    }
    else
    {
        *msg = MSFAIL;
    }

 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRrigidconn                                                     |
 |                                                                           |
 | This method allows for the nesting of owners.                             |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRrigidconn (IGRlong     *msg;
                    struct GRid *owners_id;
                    IGRlong     *owners_index)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    OMuword     classid;

    *msg = MSSUCC;
    
    /*
     * Get the classid.
     */
    om_msg = om$get_classid (objid = owners_id->objid,
                             osnum = owners_id->osnum,
                             p_classid = &classid);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }
    
    /*
     * If the owner isn't another instance object ...
     */
    if (om$is_ancestry_valid (superclassid = OPP_EMinstance_class_id,
                              subclassid = classid) != OM_S_SUCCESS)
    {
        om_msg = om$send ( msg = message GRconnector.GRrigidconn
                                                        ( msg,
                                                          owners_id,
                                                          owners_index),
                           mode = OM_e_wrt_message,
                           targetid = my_id);
    }
    else
    {
        *msg = MSFAIL;
    }

 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRget_channel_type                                              |
 |                                                                           |
 | This method determines the type of owner the object is.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRget_channel_type (IGRlong *msg; IGRint *type; IGRint *conn_type)
{
    *msg = MSSUCC;
    *conn_type = GR_NO_OVERRIDE;
    *type = GR_RIGID;
    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRget_locate_properties                                         |
 |                                                                           |
 | This method determines the locate props of the owner.                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
    IGRboolean aflag=0;
    IGRlong loc_msg;

    aflag = pwIsActivationOn();
    
    *msg = MSSUCC;
    if (aflag)
    {
      EMmemb memb;
      struct GRid rfhead;
      GRspacenum osnum, osn;

      om$send (msg = message EMdescribe.EMget_memb(&loc_msg,
                                                   "reffile",
                                                   EM_GRAPHIC,
                                                   0,
                                                   &memb),
               senderid = NULL_OBJID,
               targetid = my_id,
               targetos = OM_Gw_current_OS);

       rfhead.objid = memb.id.objid;
       rfhead.osnum = memb.id.osnum;

       om$send(msg = message GRreffile.GRgetosnum(&loc_msg, &osnum),
               senderid = NULL_OBJID,
               targetid = rfhead.objid,
               targetos = rfhead.osnum);

       osn = pwGetActiveOs();
       if (osn == osnum)
       {
         *properties = LC_REF_OBJECTS;
       }
       else
       {
         *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
                       GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
                       GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
                       GR_LC_NO_PRM_COMP  | GR_LC_RIGID;
       }
    }
    else
    {
    *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
                  GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
                  GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
                  GR_LC_NO_PRM_COMP  | GR_LC_RIGID;
    }
    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRrigid_connecting                                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/27/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRrigid_connecting (IGRlong     * msg;
                           struct GRid * go_id)
{
    *msg = MSSUCC;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRcomponent_idchanged                                           |
 |                                                                           |
 | For now this message doesn't do anything. A component's id can change     |
 | during a clip operation where the original object becomes several new     |
 | objects. We may want to look at reattaching these objects but we need to  |
 | figure out what member info to use.                                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/27/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRcomponent_idchanged (IGRlong     * msg;
                              IGRshort    * num_comp_ids;
                              struct GRid * comp_ids)
{
    *msg = MSSUCC;
    return OM_S_SUCCESS;
}

end implementation EMinstance;





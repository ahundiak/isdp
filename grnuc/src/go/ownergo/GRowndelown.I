/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRdelete_owner

Description
    The method is used to delete the header object and not the components.

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The module environment

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation Date
    jay wallingford 04/27/89    Optimized the making of the to_components chanselect
    SM              10/5/92     Notify my children (send NDparent_deleted 
                                message). Similar notification exists in
                                GRgraphics.GRdelete, but the owner does
                                not use GRdelete for deleting itself.
\*/

class implementation GRowner;

#include "grimport.h"
#include "OMminimum.h"
#include "msdef.h"
#include "gocmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

extern IGRint   GRget_to_comp_chansel();
from NDnode import NDparent_deleted;

method GRdelete_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong           om_msg;
    struct GRid       my_GRid;
    OM_S_CHANSELECT   chansel;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    GRget_to_owner_chansel ( &chansel );

    /*
     *  Inform my owners that I am deleting myself.
     */
    om_msg = om$send (msg = message GRcmpowner.GRcomponent_disconnecting 
                                                       (msg,
                                                        mod_env, 
                                                        &my_GRid),
                      p_chanselect = &chansel);

     /*
      * notify my children if I am getting deleted.
      * sm 10/03/92
      */

      if (me->properties & GRIS_ASSOCIATIVE)
      {
       long  l_msg;
       OM_S_CHANSELECT  children;
       struct GRid src_grid;

       om$make_chanselect(channame = "NDchildren.children",
                          p_chanselect = &children);

       om$send (msg = message NDnode.NDparent_deleted(&l_msg, 1, &my_GRid,
                                                      &src_grid, mod_env),
                p_chanselect = &children);
      }


    /*
     *  Remove the objid from the name directory.
     */
    di$rm_objid (objid = my_id);

    /*
     * The suggested route is to call your parents delete method wrt to
     * messsage after doing your own processing.  GRvg has a delete method
     * that deletes with respect to range and name.  However, this function
     * will remove the owner from the name index object (btree), then 
     * delete the object by sending the delete message wrt to message to 
     * itself at the Root level.
     */
    om_msg = om$send ( mode = OM_e_wrt_message, 
                       msg = message Root.delete (NULL),
                       targetid = my_id);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);

    return (om_msg);
}
end implementation GRowner;

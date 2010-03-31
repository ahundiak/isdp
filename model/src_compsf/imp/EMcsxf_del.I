class implementation EMScompsurf;

#include "msdef.h" /* MS message codes */
#include "msmacros.h"
#include "emsdef.h"
#include "nddef.h" /* For ND_BROAD_DEL */
#include "ndmacros.h"
#include "godef.h"

from EMSparameter import EMparam_delete, EMparam_xform;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
/*
Description 
    Also delete the parameter parents.

Return values
    *msg  MSSUCC if all goes well

Notes
    This is a slightly dirty implementation since this class does not have
    the father channel.  But, by adding the override here, we save lots of
    overrides which, i believe, makes it worthwhile.

History
    PP  07/22/92    Added the section for a preprocess before deleting.
    PP  06/08/91    Notify the batch that a delete is taking place.
    DLB 04/23/91    Creation.
*/
{
  IGRlong msg_loc;
  struct GRid my_GRid;
  IGRlong EFnotify_delete();
  extern IGRboolean ASbroadcast_in_progress;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  {
    OM_S_CHANSELECT to_father;
    EMmake_chanselect(NDfather_father, &to_father);
    om$send(msg = message EMSparameter.EMparam_delete(&msg_loc, md_env),
            p_chanselect = &to_father);

    om$send(msg = message EMAsurface.EMpreprocess_delete(&msg_loc,
                  md_env),
            targetid = my_id);
  }

  EFnotify_delete(&msg_loc,my_GRid,md_env);

  return(om$send(mode = OM_e_wrt_parent,
                 msg = message EMScompsurf.GRdelete(msg, md_env),
                 targetid = my_id));
}

method GRxform(IGRlong *EMmsg; struct GRmd_env *md_env; 
               IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
  IGRlong msg_loc;
  IGRint i,comp_type;
  struct GRid child_GRid;
  extern IGRboolean ASbroadcast_in_progress;

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
  {
    OM_S_CHANSELECT to_father;
    EMmake_chanselect(NDfather_father, &to_father);
    om$send(msg = message EMSparameter.EMparam_xform(&msg_loc, md_env,
                  matrix_type, matrix, newobjid),
            p_chanselect = &to_father);
  }

/* Begin pp 06/06/91 */
  if (!ASbroadcast_in_progress)
  {
    OMuint children_count = 0;
    struct GRid my_GRid;
    OM_S_CHANSELECT to_children;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    EMmake_chanselect(NDchildren_children, &to_children);
/*
 * I am determining the children count to avoid the problem of notifying
 * the batch when I am being copied and xformed. This will not be necessary
 * once GRNUC sets the bit to enable us to differentiate between the two.
 * When I am copied, there should not be any objects on the children channel.
 * pp 06/15/91
 */

    om$get_channel_count(p_chanselect = &to_children,
                         objid = my_id,
                         count = &children_count);

    for (i=0;i<children_count;i++)
    {
     om$get_objid_at_index(objid = my_id,
                           p_chanselect = &to_children,
                           index = i,
                           objidaddr = &child_GRid.objid,
                           osnumaddr = &child_GRid.osnum);

     comp_type = ND_COMP;
     nd$wait_batch(
                   type = GR_GEOM_POSTED,
                   l_object = &child_GRid,
                   l_obj_info = &comp_type,
                   nb_obj = 1);
    }
  }

/* end pp */

  return(om$send(mode = OM_e_wrt_parent,
                 msg = message EMScompsurf.GRxform(EMmsg, md_env,
                       matrix_type, matrix, newobjid),
                 targetid = my_id));
  
}

IGRlong EFnotify_delete(msg,my_GRid,md_env)
IGRlong *msg;
struct GRid my_GRid;
struct GRmd_env *md_env;
  {
   IGRlong msg_loc;
   OM_S_CHANSELECT to_children,to_father;
   struct GRid src_grid;
 
   *msg = EMS_S_Success;

   EMmake_chanselect(NDchildren_children, &to_children);
   EMmake_chanselect(NDfather_father, &to_father);

   om$send (msg = message NDnode.NDparent_deleted(&msg_loc, 
                                                   1,
                                                   &my_GRid,
                                                   &src_grid,
                  md_env),
                  senderid = my_GRid.objid,
             p_chanselect = &to_children);

   om$send (msg = message NDnode.NDchildren_deleted(&msg_loc,
                   1, &my_GRid, &src_grid, md_env),
                  senderid = my_GRid.objid,
             p_chanselect = &to_father);
    return (OM_S_SUCCESS);
 }
end implementation EMScompsurf;


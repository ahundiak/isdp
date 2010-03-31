/* #################   APOGEE  COMPILED   ######################### */
class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "exmacros.h"
#include "EMSlcdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMpostdelete (IGRlong *msg; IGRushort options; 
                     struct GRmd_env *model_env)
{
  IGRboolean mscexists;
  extern IGRboolean ASbroadcast_in_progress;
  IGRlong stat_OM,
          msg_loc;
  GRobjid mcpobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;
  OM_S_CHANSELECT proc_chan;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSloop->lp_props & EMLP_MSCEXISTS;
  if (mscexists) 
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mcpobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;
      mscexists = FALSE;
      stat_OM = OM_S_SUCCESS;
      }
    }

  if (mscexists)
    {
    /* Clear the bit indicating the model-space counterpart exists */

    ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;

    if (model_env)
      mdenv_ptr = model_env;
    else
      {
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &model_env_mem.md_id.objid);
      model_env_mem.md_id.osnum = OM_Gw_current_OS;
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

    if (!ASbroadcast_in_progress)
     om$send (msg = message GRgraphics.GRdelete (&msg_loc, mdenv_ptr),
      targetid = mcpobj);
    }

/*
 The edges have not gone away yet so we should not broadcast the postdelete
 message to the edges.
                 pp 12/23/91

  else
    {

    EMmake_chanselect (EMSbd_owner_to_comps, &proc_chan);
    om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    }
*/

  /*
   * Send the message to the inner loops, if any
   * exist.
   */

  EMmake_chanselect (EMSloop_to_inner, &proc_chan);
  om$send (msg = OPPmargs, p_chanselect = &proc_chan);

  return (stat_OM);
}


method EMpostxform_xyz (IGRlong *msg; IGRushort options; 
                        struct GRmd_env *model_env; 
                        IGRshort *xmattyp; IGRmatrix *xmat)
{
  IGRboolean mscexists;
  IGRlong stat_OM,
          msg_loc;
  GRobjid mcpobj, xobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;
  OM_S_CHANSELECT proc_chan;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSloop->lp_props & EMLP_MSCEXISTS;
  if (mscexists) 
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mcpobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;
      mscexists = FALSE;
      }
    }

  if (mscexists)
    {
    /*
     * Transform the model-space counterpart.
     */

    if (model_env)
      mdenv_ptr = model_env;
    else
      {
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &model_env_mem.md_id.objid);
      model_env_mem.md_id.osnum = OM_Gw_current_OS;
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

    om$send (msg = message GRgraphics.GRxform (&msg_loc, mdenv_ptr,
     xmattyp, *xmat, &xobj), targetid = mcpobj);
    }
  /*
   * Send this message to the edges to accomplish their post-xform function.
   */

  EMmake_chanselect (EMSbd_owner_to_comps, &proc_chan);
  om$send (msg = OPPmargs, p_chanselect = &proc_chan);

  /*
   * Send the message to the inner loops, if any
   * exist.
   */

  EMmake_chanselect (EMSloop_to_inner, &proc_chan);
  om$send (msg = OPPmargs, p_chanselect = &proc_chan);

  return (stat_OM);
}


method EMpostrtree (IGRlong *msg; IGRboolean add; IGRushort options; 
                    struct GRmd_env *model_env)
{
  IGRboolean mscexists;
  IGRlong stat_OM,
          msg_loc;
  GRobjid mcpobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;
  OM_S_CHANSELECT proc_chan;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSloop->lp_props & EMLP_MSCEXISTS;
  if (mscexists) 
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mcpobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;
      mscexists = FALSE;
      }
    }

  if (mscexists)
    {
    /*
     * Add or delete from the R-tree, the model-space counterpart.
     */

    if (model_env)
      mdenv_ptr = model_env;
    else
      {
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &model_env_mem.md_id.objid);
      model_env_mem.md_id.osnum = OM_Gw_current_OS;
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

    if (add)
      om$send (msg = message GRgraphics.GRaddwrng (&msg_loc, mdenv_ptr),
       targetid = mcpobj);
    else
      om$send (msg = message GRgraphics.GRremwrng (&msg_loc, mdenv_ptr),
       targetid = mcpobj);
    }
  else
    {
    /*
     * MSC does not exist at the loop. Send this message to the edges to
     * accomplish their post-rtree function.
     */

    EMmake_chanselect (EMSbd_owner_to_comps, &proc_chan);
    om$send (msg = OPPmargs, p_chanselect = &proc_chan);
    }

  /*
   * Send the message to the inner loops, if any
   * exist.
   */

  EMmake_chanselect (EMSloop_to_inner, &proc_chan);
  om$send (msg = OPPmargs, p_chanselect = &proc_chan);

  return (stat_OM);
}


end implementation EMSloop;

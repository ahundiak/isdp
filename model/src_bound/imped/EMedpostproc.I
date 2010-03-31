/* #################   APOGEE  COMPILED   ######################### */
class implementation EMSedge;

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
  IGRlong stat_OM,
          msg_loc;
  GRobjid mscobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;
  extern IGRboolean ASbroadcast_in_progress;

  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSedge->ed_props & EMED_MSCEXISTS;
  if (mscexists)
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;
      mscexists = FALSE;
      }
    }  

  if (mscexists)
    {
    /* Clear the bit indicating the model-space counterpart exists
     * and delete the GRcurve that stands for the MSC.
     */

    ME.EMSedge->ed_props &= ~EMLP_MSCEXISTS;

    if (model_env)
      mdenv_ptr = model_env;
    else
      {
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &model_env_mem.md_id.objid);
      model_env_mem.md_id.osnum = OM_Gw_current_OS;
      EMidmatrix(&msg_loc, &model_env_mem.md_env.matrix_type, 
                 model_env_mem.md_env.matrix);
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

   
    if (!ASbroadcast_in_progress)
    {
     om$send (msg = message GRgraphics.GRdelete (&msg_loc, mdenv_ptr),
     targetid = mscobj);
    }
   }

  return (OM_S_SUCCESS);
}


method EMpostxform_xyz (IGRlong *msg; IGRushort options; 
                        struct GRmd_env *model_env; 
                        IGRshort *xmattyp; IGRmatrix *xmat)
{
  IGRboolean mscexists;
  IGRlong stat_OM,
          msg_loc;
  GRobjid mscobj, xobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;

  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSedge->ed_props & EMED_MSCEXISTS;
  if (mscexists) 
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;
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
      EMidmatrix(&msg_loc, &model_env_mem.md_env.matrix_type, 
                 model_env_mem.md_env.matrix);
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

    om$send (msg = message GRgraphics.GRxform (&msg_loc, mdenv_ptr,
     xmattyp, *xmat, &xobj), targetid = mscobj);
    }

  return (OM_S_SUCCESS);
}


method EMpostrtree (IGRlong *msg; IGRboolean add; IGRushort options; 
                    struct GRmd_env *model_env)
{
  IGRboolean mscexists;
  IGRlong stat_OM,
          msg_loc;
  GRobjid mscobj;
  struct GRmd_env model_env_mem, *mdenv_ptr;

  *msg = EMS_S_Success;

  /*
   * Obtain the model-space counterpart, if one
   * is present.
   */

  mscexists = ME.EMSedge->ed_props & EMED_MSCEXISTS;
  if (mscexists) 
    {
    msg_loc = EMS_S_Success;

    stat_OM = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = my_id);

    if (msg_loc == EMS_I_NotFound || ! (1 & stat_OM & msg_loc))
      {
      ME.EMSedge->ed_props &= ~EMED_MSCEXISTS;
      mscexists = FALSE;
      }
    }

  if (mscexists)
    {
    /*
     * Add or remove from the R-tree, this model-space counterpart.
     */

    if (model_env)
      mdenv_ptr = model_env;
    else
      {
      ex$get_modid (mod_osnum = OM_Gw_current_OS,
       mod_id = &model_env_mem.md_id.objid);
      model_env_mem.md_id.osnum = OM_Gw_current_OS;
      EMidmatrix(&msg_loc, &model_env_mem.md_env.matrix_type, 
                 model_env_mem.md_env.matrix);
      model_env_mem.md_env.matrix_type = MAIDMX;

      mdenv_ptr = &model_env_mem;
      }

    if (add)
      om$send (msg = message GRgraphics.GRaddwrng (&msg_loc, mdenv_ptr),
       targetid = mscobj);
    else
      om$send (msg = message GRgraphics.GRremwrng (&msg_loc, mdenv_ptr),
       targetid = mscobj);
    }

  return (OM_S_SUCCESS);
}


end implementation EMSedge;

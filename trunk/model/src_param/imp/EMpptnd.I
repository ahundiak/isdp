/*
  DESCRIPTION

    This file consists of the overrides necessary at this class for
    the relevant ND-messages.
  
  HISTORY

    SS  :  03/15/91  :  Creation
    Sudha  06/30/93  :  Modified for BSprototypes ansification

*/

class implementation EMSparampt;

#include "dimsrc.h"
#include "ma.h"
#include "maoptsxfo.h"
#include "maidmx.h"

method NDgive_structure (IGRlong *msg; struct ret_struct *NDstruct;
                         struct GRmd_env *mdenv)
{
  IGRlong msg_loc, stat_OM;
  struct EMSgeomdata pt;
  IGRshort        temp_mat_type;
  IGRlong          one = 1;
  IGRmatrix       temp_mat;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  temp_mat_type = MAIDMX;
  MAidmx(msg,temp_mat);

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             &temp_mat_type, temp_mat, &pt),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  NDstruct->type = point_generic;
  OM_BLOCK_MOVE (pt.point, NDstruct->var.point_st.pt, sizeof (IGRpoint));

  if (mdenv->md_env.matrix_type != MAIDMX)
  {
   MAoptsxform(msg,&one,&mdenv->md_env.matrix_type,
                       mdenv->md_env.matrix,
                       NDstruct->var.point_st.pt,
                       NDstruct->var.point_st.pt);
  }


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpptndgivestr");
  return (stat_OM);
}


method DMgive_structure (IGRint *msg; IGRint type; IGRboolean inq0_set1;
                         struct dim_ret_struct *str; struct GRmd_env *md_env)
{
  IGRshort        temp_mat_type;
  IGRlong         one = 1;
  IGRmatrix       temp_mat;
  IGRlong msg_loc, stat_OM;
  struct EMSgeomdata pt;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  temp_mat_type = MAIDMX;
  MAidmx((IGRlong *)msg,temp_mat);

  stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
             &temp_mat_type, temp_mat, &pt),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  str->type = DMkeypt;
  OM_BLOCK_MOVE (pt.point, str->var.dm_keypt.point, sizeof (IGRpoint));
  str->var.dm_keypt.u_par = 0.0;

  if (md_env->md_env.matrix_type != MAIDMX)
  {
   MAoptsxform ((IGRlong *)msg,&one,&md_env->md_env.matrix_type,
                       md_env->md_env.matrix,
                       str->var.dm_keypt.point,
                       str->var.dm_keypt.point);
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpptdmgivestr");
  return (stat_OM);
}


method DMgive_src_info (IGRint *msg; struct GRmd_env *md_env;
                        struct dim_src_info *src_info)
{
  IGRlong stat_OM, msg_loc;
  struct dim_ret_struct dim_ret_struct;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = om$send (msg = message dim_src.DMgive_structure ((IGRint *) &msg_loc, 
             DMkeypt, FALSE, &dim_ret_struct, md_env),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  src_info->type = DMkeypt;
  src_info->var.dm_keypt = dim_ret_struct.var.dm_keypt;
  src_info->degraded = FALSE;
  src_info->num_parents = 0;

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSparampt.DMgive_src_info");
  return (stat_OM);
}

end implementation EMSparampt;

/*
  DESCRIPTION

    This file consists of the overrides necessary at this class for
    the relevant ND-messages.
  
  HISTORY

    SS  :  03/15/91  :  Creation
    Sudha  06/30/93  :  Modified for BSprototypes ansification

*/

class implementation EMSparamvc;

#include "ma.h"
#include "maoptsxfo.h"
#include "maidmx.h"

method NDgive_structure (IGRlong *msg; struct ret_struct *NDstruct;
                         struct GRmd_env *mdenv)
{
  IGRshort        temp_mat_type;
  IGRlong         one = 1;
  IGRmatrix       temp_mat;
  IGRlong msg_loc, stat_OM;
  struct EMSgeomdata vc;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  temp_mat_type = MAIDMX;
  MAidmx(msg,temp_mat);

  stat_OM = om$send (msg = message EMSparamgm.EMgetdimgeom (&msg_loc, NULL,
             &temp_mat_type, temp_mat,
             NULL, NULL, &vc, NULL),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (vc.geomtype != GEOMDATA_LINE, *msg, EMS_E_InvalidCase, ret_end);

  NDstruct->type = line_generic;
  OM_BLOCK_MOVE (vc.line.line_pt1, NDstruct->var.line_st.p0,
   sizeof (IGRpoint));
  OM_BLOCK_MOVE (vc.line.line_pt2, NDstruct->var.line_st.p1,
   sizeof (IGRpoint));

  if (mdenv->md_env.matrix_type != MAIDMX)
  {
   MAoptsxform(msg,&one,&mdenv->md_env.matrix_type,
                       mdenv->md_env.matrix,
                       NDstruct->var.line_st.p0,
                       NDstruct->var.line_st.p0);

   MAoptsxform(msg,&one,&mdenv->md_env.matrix_type,
                       mdenv->md_env.matrix,
                       NDstruct->var.line_st.p1,
                       NDstruct->var.line_st.p1);
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpvcndgivestr");
  return (stat_OM);
}


method DMgive_structure (IGRint *msg; IGRint type; IGRboolean inq0_set1;
                         struct dim_ret_struct *str; struct GRmd_env *md_env)
{
  IGRshort        temp_mat_type;
  IGRlong         two = 2;
  IGRmatrix       temp_mat;
  IGRlong msg_loc, stat_OM;
  struct EMSgeomdata vc;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  temp_mat_type = MAIDMX;
  MAidmx((IGRlong *)msg,temp_mat);

  stat_OM = om$send (msg = message EMSparamgm.EMgetdimgeom (&msg_loc, NULL,
             &temp_mat_type, temp_mat,
             NULL, NULL, &vc, NULL),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (vc.geomtype != GEOMDATA_LINE, *msg, EMS_E_InvalidCase, ret_end);

  str->type = DMkeyseg;
  OM_BLOCK_MOVE (vc.line.line_pt1, str->var.dm_keyseg.line,
   2 * sizeof (IGRpoint));
  str->var.dm_keyseg.u_par = 0.0;

  if (md_env->md_env.matrix_type != MAIDMX)
  {
   MAoptsxform((IGRlong *)msg,&two,&md_env->md_env.matrix_type,
                       md_env->md_env.matrix,
                       str->var.dm_keyseg.line,
                       str->var.dm_keyseg.line);
  }


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpvcdmgivestr");
  return (stat_OM);
}

end implementation EMSparamvc;

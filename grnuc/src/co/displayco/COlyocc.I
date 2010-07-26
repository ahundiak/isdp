class implementation COlayer;

#include <stdio.h>
#include "OMindex.h"
#include "dpfile.h"
#include "grmessage.h"

from module import GRmod_passon;


method occupied(int *sts)
{
  IGRint      status, msg1, i, j, yes, no;
  IGRlong     beg, fin, msg, msg2;
  GRobjid     mod_id;
  GRspacenum  mod_os;

  IGRlong        bytes_on_layer[MAX_LVLDEF];
  OM_S_MESSAGE   pass_msg;
  OM_S_MESSAGE   level_msg;
  DB_3D_DBL_BOX  range_box;
  OM_S_KEY_DESC  range_key;

  struct pass_struct  /* arguments for GRlevelcount method */
  {
    IGRlong *p_msg;
    IGRlong *p_bytes;
    IGRlong *p_ele;
  }os_pass_count;

  struct GRpass_args_struct  /* arguments for pass method */ 
  {
    OM_p_MESSAGE msg_to_pass;
    OM_p_KEY_DESC p_select_key;
    char *p_criteria;
    OM_p_KEY_DESC p_target_key;
    int (*user_compare)();
    int *ret;
  }pass_args;


  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Create the message to pass to all graphic objects to tell what layer
   * they are on.  This tells me if a layer is occupied or not.
   */

  os_pass_count.p_msg = &msg;
  os_pass_count.p_bytes = &bytes_on_layer[0];
  os_pass_count.p_ele = &me->elements_on_layer[0];

  for (i = 0; i < MAX_LVLDEF; i++ )
  {
    bytes_on_layer[i] = 0;
    me->elements_on_layer[i] = 0;
  }

  status = om$make_message(classname = "GRgraphics",
                           methodname = "GRlevelcount",
                           size = sizeof(struct pass_struct),
                           p_arglist = &os_pass_count,
                           p_msg = &level_msg);
  if ( !(status & 1 ) )
  {
    om$report_error(sts = status);
    goto quit;
  }

  status = om$make_message(classname = "OMrtree",
                           methodname = "pass",
                           size = sizeof( struct GRpass_args_struct),
                           p_arglist = &pass_args,
                           p_msg = &pass_msg);
  if (!(1&status))
  {
    om$report_error(sts = status);
    goto quit;
  }

  pass_args.msg_to_pass = &level_msg;
  pass_args.ret = &msg1;
  pass_args.p_criteria = NULL;
  pass_args.p_target_key = 0;
  pass_args.user_compare = 0;
  pass_args.p_select_key = &range_key;
  pass_args.p_select_key->key.p_3ddbl = &range_box;
  pass_args.p_select_key->type = KEY_3D_DBL;

  range_key.key.p_3ddbl->xmin = GRDGNLIMITS_MIN_D;
  range_key.key.p_3ddbl->ymin = GRDGNLIMITS_MIN_D;
  range_key.key.p_3ddbl->zmin = GRDGNLIMITS_MIN_D;
  range_key.key.p_3ddbl->xmax = GRDGNLIMITS_MAX_D;
  range_key.key.p_3ddbl->ymax = GRDGNLIMITS_MAX_D;
  range_key.key.p_3ddbl->zmax = GRDGNLIMITS_MAX_D;

  beg = 0;
  fin = GRDGNLIMITS_MAX_I;

  status = ex$get_cur_mod(id = &mod_id,
                          osnum = &mod_os);
  if (!( 1 & status))
  {
    om$report_error(sts = status);
    goto quit;
  }

  status = om$send(msg = message module.GRmod_passon(&msg2,
                                                     &pass_msg,
                                                     "module.primary",
                                                     (IGRint *)&beg,
                                                     (IGRint *)&fin),
                   targetid = mod_id,
                   targetos = mod_os);
  msg1 = msg2;

  if ( !(status & 1 ))
  {
    om$report_error(sts = status);
    goto quit;
  }

  /*
   * Check the individual layers to see if they are occupied or not.
   */

  for (i = 0; i < MAX_LVLDEF; i++)
  {
    if (me->elements_on_layer[i])
    {
      ex$message(msgnumb = GR_I_LayYes,  buff = me->ind_ly[i].occupied );
    }
    else
    {
      ex$message(msgnumb = GR_I_LayNo,  buff = me->ind_ly[i].occupied );
    }
  }

  /*
   * Check all the group's number mask to see if a layer in that
   * group is occupied or not or mixed.
   */

  for (i = 0; i < me->num_in_group; i++)
  {
    yes = FALSE;
    no = FALSE;

    for (j = 0; j < MAX_LVLDEF; j++)
    {
      if ( DPlevel_check(j, me->group[i].ly_num_mask) )
      {
        if (me->elements_on_layer[j])
          yes = TRUE;
        else
          no = TRUE;
      }

    }  /* end for j loop */

    if (yes && no)
    {
      ex$message(msgnumb = GR_I_LayMixed,  buff = me->group[i].occupied );
    }
    else if (yes)
    {
      ex$message(msgnumb = GR_I_LayYes,  buff = me->group[i].occupied );
    }
    else
    {
      ex$message(msgnumb = GR_I_LayNo,  buff = me->group[i].occupied );
    }

  }  /* end for i loop */


quit:

  return(status);

}

end implementation COlayer;

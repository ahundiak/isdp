class implementation SKmgr;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include <alloca.h>
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "mainvmx.h"

#define MIN 0
#define MAX 1

#define X 0
#define Y 1

#define FIRST  0
#define SECOND 1

from SKptvar import SKupdaterange;
from SKconstraint import SKpass_by_class_type;

method SKinit (long *msg; unsigned short opts;
               unsigned short props;
               IGRpoint origin; IGRvector xaxis, normal)
{
  long msg_loc, stat_OM;
  struct SKvarinfo *varinfo; 

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (!(opts & SK_OPT_NO_STORE_PROPS))
   ME.SKmgr->props = props;

  if (!(opts & SK_OPT_NO_STORE_ORIENTATION))
  {
   stat_OM = om$send (msg = message SKmgr.SKputornt (&msg_loc, origin,
             xaxis, normal), targetid = my_id);
   EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if (!(opts & SK_OPT_NO_INIT_SAVE_STATE))
  {
   om$vla_set_dimension (varray = ME.SKmgr->oldvars, size = 3);
   varinfo = ME.SKmgr->oldvars;
   varinfo[0].varobj = NULL_OBJID;
   varinfo[1].varobj = NULL_OBJID;
   varinfo[2].varobj = NULL_OBJID;
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKinit");
  return (stat_OM);
}

method SKputornt (long *msg;
                  double *origin, *xaxis, *normal)
{
  *msg = EMS_S_Success;

  if (origin)
    OM_BLOCK_MOVE (origin, ME.SKmgr->origin, sizeof(IGRpoint));

  if (normal)
    OM_BLOCK_MOVE (normal, ME.SKmgr->normal, sizeof(IGRvector));

  if (xaxis)
    OM_BLOCK_MOVE (xaxis, ME.SKmgr->x_axis, sizeof(IGRvector));

  return OM_S_SUCCESS;
}

method SKgetxyrange (long *msg; double xyrange[2][2])
{
  long msg_loc;
  OM_S_CHANSELECT chan_to_vars;

  *msg = EMS_S_Success;

  om$make_chanselect (channame = "SKmgr.to_vars",
   p_chanselect = &chan_to_vars);

  xyrange[MIN][X] = MAXDOUBLE;
  xyrange[MIN][Y] = MAXDOUBLE;
  xyrange[MAX][X] = -MAXDOUBLE;
  xyrange[MAX][Y] = -MAXDOUBLE;
  om$send (msg = message SKptvar.SKupdaterange (&msg_loc, xyrange),
   p_chanselect = &chan_to_vars);
 
  return OM_S_SUCCESS;
}

method SKreturn_yourself(long *EMmsg; OM_S_OBJID *sk_mgr_objid)
{
 *EMmsg = EMS_S_Success;
 *sk_mgr_objid = my_id;
 return (OM_I_STOP_SENDING);
}

method SKtransform_pt(long *EMmsg; unsigned int options;
                      short *mattyp; IGRmatrix matrix;
                      int num_pts;double *pts; double *xypts)
{
 long status;
 short out_mattyp;
 IGRmatrix out_mat;
 int i;
 long    one = 1;
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 OM_BLOCK_MOVE (pts, xypts, sizeof(double)*3*num_pts);

 status = om$send (msg = message SKmgr.SKget_xymat(EMmsg,options,
                         mattyp,matrix,&out_mattyp,out_mat), 
                   targetid = my_id);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 for (i=0;i<num_pts;i++)
 {
   if (out_mattyp != MAIDMX)
   {
    MAoptsxform(EMmsg, &one, &out_mattyp,
                out_mat, &pts[3*i], &xypts[3*i]);
   }
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In SKmgr:SKtransform_pt error");
 return (status);
}

method SKchkcycle (long *msg; unsigned short opts;
                   struct GRid *conflict_parent)
{
  int         i, count;
  long        stat_OM;
  struct GRid my_grid, one_id, *parents;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain my parents
   */

  stat_OM = om$send (msg = message NDnode.NDget_objects (ND_ROOT, &one_id,
             1, NULL, 0, MAXINT, &count), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  if (count > 1)
    {
    parents = (struct GRid *) alloca (count * sizeof (struct GRid));
    EMerr_hndlr (!parents, *msg, EMS_E_NoStackMemory, ret_end);

    stat_OM = om$send (msg = message NDnode.NDget_objects (ND_ROOT, parents,
               count, NULL, 0, MAXINT, &count), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
    }
  else
    parents = &one_id;

  /*
   * Test if any of my parents are in fact my children
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  for (i=0; i<count; i++)
    if (nd$dep_exist (l_root = &my_grid, nb_root = 1,
         l_tip = &parents[i], nb_tip = 1))
      {
      *msg = EMS_I_Cycle;
      if (conflict_parent)
        *conflict_parent = parents[i];
      break;
      }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.SKchkcycle");
  return (stat_OM);
}


method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = MSSUCC;
 ex$message ( buff = info->type, msgnumb = EMS_S_Profile );

 return OM_S_SUCCESS;
}

method GRcopy (long *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
  int 			i;
  OMuint 		count, newcount;
  long 			msg_loc, stat_OM;
  GRobjid 		*loc_newobjids;
  struct IGRdisplay 	disp;
  struct GRvg_construct const_args;
  OM_S_CHANSELECT 	chan_to_comps;
  extern long 		EFbuild_graphic_group();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *newobjid = NULL_OBJID;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
                        count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

  if (count == 1)
  {
    stat_OM = om$send (msg = message GRgraphics.GRcopy (&msg_loc, obj_dsenv,
               new_dsenv, newobjid), p_chanselect = &chan_to_comps);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    loc_newobjids = (GRobjid *) alloca (count * sizeof (GRobjid));
    EMerr_hndlr (!loc_newobjids, *msg, EMS_E_NoStackMemory, ret_end);
    newcount = 0;
    for (i=0; i<count; i++)
    {
      stat_OM = om$send (msg = message GRgraphics.GRcopy (&msg_loc, obj_dsenv,
                               new_dsenv, &loc_newobjids[i]), from = i, to = i,
                         p_chanselect = &chan_to_comps);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      if (loc_newobjids[i] != NULL_OBJID) 
        newcount++;
    }

    EMinitvgcnstr (&msg_loc, new_dsenv, &disp, NULL, &const_args);
    EMgetvgcnstr (NULL, NULL, new_dsenv, DEFAULT_GR_LEVEL, NULL, NULL, NULL,
                  &const_args);
    if (newcount > 1) 
    {
      stat_OM = EFbuild_graphic_group (count, loc_newobjids, NULL, &const_args,
                                       newobjid, &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
      for (i=0; i<count; i++)
        if (loc_newobjids[i] != NULL_OBJID)
          *newobjid = loc_newobjids[i];
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKmgr.GRcopy");
  return (stat_OM);
}

method GRchgcolor (long *msg; int unsigned *rgb_val; 
                   short unsigned *color)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  ME.GRvg->display_attr.color = *color;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  return OM_S_SUCCESS;
}

method GRchgweight (long *msg; IGRuchar *weight)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  ME.GRvg->display_attr.weight = *weight;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  return OM_S_SUCCESS;
}

method GRchgstyle (long *msg; IGRuchar *style)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  ME.GRvg->display_attr.style = *style;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  return OM_S_SUCCESS;
}

method GRchgdp (long *msg; struct IGRdisplay *dp_attr)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  ME.GRvg->display_attr = *dp_attr;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  return OM_S_SUCCESS;
}

method GRputsymb (long *msg; struct GRsymbology *symb)
{
  OM_S_CHANSELECT chan_to_comps;

  *msg = EMS_S_Success;

  ME.GRgraphics->level = symb->level;
  ME.GRvg->display_attr = symb->display_attr;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  return OM_S_SUCCESS;
}

method GRgetsymb (long *msg; struct GRsymbology *symb)
{
  *msg = EMS_S_Success;

  symb->level = ME.GRgraphics->level;
  symb->display_attr = ME.GRvg->display_attr;

  return OM_S_SUCCESS;
}

method GRchglevel (long *msg; short *level)
{
  long msg_loc;
  OM_S_CHANSELECT chan_to_comps, chan_to_cnstrs;

  *msg = EMS_S_Success;

  ME.GRgraphics->level = *level;

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  om$send (msg = OPPmargs, p_chanselect = &chan_to_comps);

  EMmake_chanselect (SKmgr_to_constrs, &chan_to_cnstrs);
  om$send (msg = message SKconstraint.SKpass_by_class_type (&msg_loc,
   OPPmargs, SK_PASS_IMPLICIT_CLASS | SK_PASS_EXPLICIT_CLASS),
   p_chanselect = &chan_to_cnstrs);

  return OM_S_SUCCESS;
}


method GRchgprops ( long *msg; short *action; short *props )
{
  OM_S_CHANSELECT chan_to_cnstrs;

  om$send ( msg = message GRowner.GRchgprops ( msg, action, props ), 
     mode = OM_e_wrt_message, 
     targetid = my_id );

  EMmake_chanselect ( SKmgr_to_constrs, &chan_to_cnstrs );
  om$send ( msg = OPPmargs, p_chanselect = &chan_to_cnstrs );

  return OM_S_SUCCESS;
}

end implementation SKmgr;


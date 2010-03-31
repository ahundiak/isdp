/*

Name
  EMSasptcnstr.EMinit

Abstract
  Constraint initiliazation method to place a coincident constraint between
  a parametric point and another 3D point.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  associative, 3D-constraint

History
  ???????  : Sikandar Saifullah : created
  05/12/93 : Rajiv Agrawal      : Added GRst_REGULAR to the list of valid subtypes.
  02/01/94 : Rajiv Agrawal      : Changed call to dm$get_dim_plane to 
                                  ems$get_active_datum_plane so that we can never have any
                                  ambiguity.  (TR119416392)

 */
class implementation EMSasptcnstr;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSasopts.h"
#include "EMdtmacros.h"

#define FIRST  0

#define STATIC_MAX_PARENTS 5

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_IGEgadget_class_id, OPP_GRbspline_class_id;
extern GRclassid OPP_SKgmhndlpt_class_id;
extern GRclassid OPP_SKgeometry_class_id;
extern GRclassid OPP_SKptvar_class_id;

from EMSparameter import EMgetdimgeom, EMpasschild;
from EMSassoc import EMexternal_constraint_changed;

method EMinit (IGRlong *msg; IGRushort opts;
               struct GRmd_env *md_env;
               IGRint num_parents; 
               struct GRid *parents; 
               IGRushort cnstr_props; IGRchar *moreinfo;
               IGRint num_children;
               struct GRid *children)
{
  IGRboolean 		plane_parent;
  int 			i, dim_src_type , stat_OM;
  long 			msg_loc;
  GRclassid 		classid;
  struct EMSasptinfo 	*asptinfo;
  struct GRid 		my_grid, dimpln_grid, dparents[STATIC_MAX_PARENTS];
  struct GRid 		dumid, dcontexts[STATIC_MAX_PARENTS];
  struct GRas 		assoc_info;
  struct src_attr 	src_attr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  asptinfo = (struct EMSasptinfo *) moreinfo;
  plane_parent = FALSE;
  switch (asptinfo->type)
  {
    case GRst_CENTER:
      dim_src_type = DMcenpt;
      plane_parent = TRUE;
      break;
    case GRst_REGULAR:
    case GRst_KEYPOINT:
      dim_src_type = DMkeypt;
      break;
    case GRst_MIDPOINT:
      dim_src_type = DMmidpt;
      break;
    case GRst_INTER:
      dim_src_type = DMintpt;
      plane_parent = TRUE;
      break;
    default:
      *msg = EMS_E_NotSupported;
      goto ret_end;
  }

  for (i=0; i<num_parents; i++)
  {
    om$get_classid (objid = parents[i].objid, osnum = parents[i].osnum,
                    p_classid = &classid);
    if (om$is_ancestry_valid (subclassid = classid,
         superclassid = OPP_GRbspline_class_id) != OM_S_SUCCESS)
      {EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);}

    dumid.objid = NULL_OBJID;
    stat_OM = as$make_source(go_grid = parents[i], context_grid = dumid,
               as_os = md_env->md_id.osnum, as_grid = &dparents[i]);
    EMomerr_exit (stat_OM, ret_end);
    dcontexts[i].objid = NULL_OBJID;
  }

  if (plane_parent)
  {
    om$get_classid (objid = asptinfo->win_pln.objid, 
     osnum = asptinfo->win_pln.osnum, p_classid = &classid);
    if (om$is_ancestry_valid (subclassid = classid,
         superclassid = OPP_IGEgadget_class_id) == OM_S_SUCCESS) 
    {
      /*
       * get the active datum plane
       */
      dimpln_grid.objid = NULL_OBJID;
      ems$get_active_datum_plane (msg = &msg_loc, datpln = &dimpln_grid);
      EMerr_hndlr (EMSerror (msg_loc) || IF_NULL_OBJID (dimpln_grid.objid),
                   stat_OM, OM_E_ABORT, ret_end);
    }
    else 
    {
       dimpln_grid = asptinfo->win_pln;
    }

    dparents[num_parents] = dimpln_grid;
    dcontexts[num_parents].objid = NULL_OBJID;
    num_parents++;
  }

  assoc_info.num_parents = num_parents;
  assoc_info.parents = dparents;
  assoc_info.context = dcontexts;
  src_attr.type = dim_src_type;
  src_attr.attr = (IGRdouble *) asptinfo->pts;
  assoc_info.as_attr = (IGRchar *) &src_attr;

  stat_OM = om$send (msg = message NDnode.NDplace (&assoc_info, md_env, NULL),
             targetid = my_id); 
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message NDnode.NDs_compute_node (&msg_loc, NULL,
             md_env), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  stat_OM = om$send (msg = message NDnode.NDchg_state (ND_DEL_NO_CH,
             ND_DEL_NO_CH), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);

  /*
   * Connect up the children
   */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  for (i=0; i<num_children; i++)
    {
    stat_OM = om$send (msg = message NDnode.NDconnect (1, &my_grid, NULL_GRID,
               ND_ADD), targetid = children[i].objid, 
               targetos = children[i].osnum);
    EMomerr_exit (stat_OM, ret_end);
    }

  /*
   * If the option to check for cycles is in place, do so.
   */

  if (opts & EMScnstr_check_cycle &&
      nd$dep_exist (l_root = &my_grid, nb_root = 1, 
       l_tip = dparents, nb_tip = num_parents))
    {
    *msg = EMS_I_Cycle;
    goto ret_end;
    }

  /*
   * If requested, create a graphics handle for myself and connect
   * it as rigid component.
   */

  if (opts & EMScnstr_connect_geomhandle)
    {
    stat_OM = om$send (msg = message EMSimpcnstr.EMgeomhandle (&msg_loc,
               NULL, md_env, NULL), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * The addition of this constraint causes the child object to be
   * externally constrained. Record this fact.
   */

  for (i=0; i<num_children; i++)
    om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
     message EMSassoc.EMexternal_constraint_changed (&msg_loc,
     EMext_const_chg_CONSTRAINT_ADDED)), targetid = children[i].objid,
     targetos = children[i].osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSasptcnstr.EMinit");
  return (stat_OM);
}


IGRboolean EMptsubtype_supported (event)
struct GRevent *event;
{
  IGRboolean supported;
  IGRint i, num_curves, subtype;
  GRclassid class;
  struct GRid *grid, geom_id;
  OM_S_CHANSELECT to_geom;

  supported = FALSE;

  subtype = event->subtype;
  if (subtype == GRst_CENTER ||
      subtype == GRst_KEYPOINT ||
      subtype == GRst_MIDPOINT ||
     /* subtype == GRst_ENDPOINT || */
      subtype == GRst_INTER)
  {
    num_curves = 0;
    for (i=0; i<event->num_id; i++)
    {
      grid = &event->located_object[i].located_obj;
      om$get_classid (objid = grid->objid, osnum = grid->osnum,
                      p_classid = &class);
      if ((om$is_ancestry_valid (subclassid = class,
             superclassid = OPP_GRbspline_class_id) == OM_S_SUCCESS &&
           om$is_ancestry_valid (subclassid = class,
             superclassid = OPP_SKgmhndlpt_class_id) != OM_S_SUCCESS) ||
           (subtype == GRst_KEYPOINT && 
            om$is_ancestry_valid (subclassid = class,
              superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS))
        num_curves++;
      else if (subtype == GRst_KEYPOINT && 
            om$is_ancestry_valid (subclassid = class,
              superclassid = OPP_SKptvar_class_id) == OM_S_SUCCESS)
      {
        /*
         * Special case handling if the user tentative snaps to a profile vertex.
         * Return the corresponding Geometric entity.
         */
        
        EMmake_chanselect (SKvariable_to_geometries, &to_geom);
        om$get_objid_at_index ( objid = grid->objid, osnum = grid->osnum,
                                p_chanselect = &to_geom, index = 0,
                                objidaddr = &geom_id.objid, osnumaddr = &geom_id.osnum);
        event->located_object[i].located_obj.objid = geom_id.objid;
        event->located_object[i].located_obj.osnum = geom_id.osnum;
        num_curves++;
      }
    }
    if (num_curves && num_curves == event->num_id)
      supported = TRUE;
  }

  return (supported);
}


void EMasptcnstr (msg, opts, md_env, event, num_childs, childs, cnstr)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *md_env;
struct GRevent *event;
IGRint num_childs;
struct GRid *childs;
GRobjid *cnstr;
{
  IGRint i, num_parents;
  IGRlong msg_loc, stat_OM;
  struct GRid aspt_parents[2];
  struct EMSasptinfo asptinfo;
  extern IGRboolean EMptsubtype_supported();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  
  if (EMptsubtype_supported (event))
    {
    num_parents = event->num_id;
    for (i=0; i<event->num_id; i++)
      aspt_parents[i] = event->located_object[i].located_obj;

    asptinfo.type = event->subtype;
    OM_BLOCK_MOVE (&event->event.button.x, asptinfo.pts[0], sizeof (IGRpoint));
    asptinfo.win_pln.objid = event->event.button.objid;
    asptinfo.win_pln.osnum = event->event.button.osnum;

    stat_OM = om$construct (classid =  OPP_EMSasptcnstr_class_id,
               msg = message EMScnstr.EMinit (&msg_loc, opts, md_env,
               num_parents, aspt_parents, NULL, (IGRchar *) &asptinfo,
               num_childs, childs),
               osnum = md_env->md_id.osnum, p_objid = cnstr);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  else
    *msg = EMS_E_NotSupported;


ret_end:
  EMWRAPUP (*msg, stat_OM, "EMasptcnstr");
  return;
}

method NDupdate(IGRint *EMmsg;
                IGRint cnt_type;
                IGRint count;
                struct GRid *list;
                IGRint *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 IGRlong status;
/*
 * Compute the same outside the rtree as we know we are not in the rtree.
 * pp
 */

 cnt_type |= ND_COMP_NO_REM_RT | ND_COMP_NO_ADD_RT;

 status = om$send (msg = message EMSasptcnstr.NDupdate(EMmsg,cnt_type,
                         count,list,parent_state,context,new_objid,
                         md_env),
                   mode = OM_e_wrt_parent,
                   targetid = my_id);
 return (status);
}
end implementation EMSasptcnstr;

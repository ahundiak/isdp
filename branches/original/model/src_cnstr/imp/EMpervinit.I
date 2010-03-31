/*

Name
  EMSpervcnstr.EMinit

Abstract
  Constraint initiliazation method to place a 3D perpendicular constraint.

Synopsis

Description

Return Value

Notes

Index

Keywords
  associative, 3D-constraint

History
  ???????  : Sikandar Saifullah : created
  06/07/93 : Sudha : modified for BSprototype includes
  02/01/94 : Rajiv Agrawal      : Changed call to dm$get_dim_plane to 
                                  ems$get_active_datum_plane so that we can 
                                  never have any ambiguity.  (TR119416392)
  02/07/94 : Scott Walters      : BUILD FIX - Added OMmacros.h to include list

 */
class implementation EMSpervcnstr;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dimplan.h"
#include "dimmacros.h"
#include "EMSasopts.h"
#include "EMdtmacros.h"

#include "bserr.h"
#include "bsdotp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1

extern GRclassid OPP_IGEgadget_class_id, OPP_EMSparamvc_class_id;

from EMSparameter import EMpasschild;
from EMSassoc import EMexternal_constraint_changed;

method EMinit (IGRlong *msg; IGRushort opts;
               struct GRmd_env *md_env;
               IGRint num_parents; 
               struct GRid *parents; 
               IGRushort cnstr_props; IGRchar *moreinfo;
               IGRint num_children;
               struct GRid *children)
{
  IGRboolean plane_parent;
  IGRshort mattyp;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mat;
  IGRvector normal;
  GRclassid objclass;
  struct GRid plpr_id, my_grid, dumid, dparents[2], dcontexts[2];
  struct EMSgeomdata child_vcgeom;
  struct EMSnrminfo *nrminfo;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * This constraint needs only one parent since the normal can be determined
   * unambiguously through this object alone. Except with line-segments,
   * when a plane-parent is necessary to determine the necessary geometry.
   * The information for the latter part is there in the moreinfo (diminfo)
   * coming.
   */

  EMerr_hndlr (num_parents != 1, *msg, EMS_E_InvalidCase, ret_end);

  /*
   * Check if the parent yields a plane with an unambiguous normal
   * vector definition, without the use of a plane. If it does not, then
   * use the plane that is input in the moreinfo.
   */

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  EMget_obj_normal (&msg_loc, NULL, &mattyp, mat, parents, NULL, NULL, NULL,
                    normal);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  if (msg_loc == EMS_I_NotFound)
  {
    nrminfo = (struct EMSnrminfo *) moreinfo;
    om$get_classid (objid = nrminfo->win_pln.objid, 
     osnum = nrminfo->win_pln.osnum, p_classid = &objclass);
    if (om$is_ancestry_valid (subclassid = objclass,
         superclassid = OPP_IGEgadget_class_id) == OM_S_SUCCESS) 
    {
      /*
       * get the active datum plane
       */
      plpr_id.objid = NULL_OBJID;
      ems$get_active_datum_plane (msg = &msg_loc, datpln = &plpr_id);
      EMerr_hndlr (EMSerror (msg_loc) || IF_NULL_OBJID (plpr_id.objid),
                   stat_OM, OM_E_ABORT, ret_end);
    }
    else 
    {
      plpr_id = nrminfo->win_pln;
    }

    EMget_obj_normal (&msg_loc, NULL, &mattyp, mat, parents, 
                      &mattyp, mat, &plpr_id, normal);
    EMerr_hndlr (EMSerror (msg_loc) || msg_loc == EMS_I_NotFound, *msg,
                 EMS_E_InvalidArg, ret_end);
    plane_parent = TRUE;
  }
  else
    plane_parent = FALSE;

  /*
   * Create AS-source objects if necessary.
   */

  dumid.objid = NULL_OBJID;
  stat_OM = as$make_source(go_grid = *parents, context_grid = dumid,
             as_os = md_env->md_id.osnum, as_grid = &dparents[FIRST]);
  EMomerr_exit (stat_OM, ret_end);
  dcontexts[FIRST].objid = NULL_OBJID;

  if (plane_parent)
  {
    stat_OM = as$make_source(go_grid = plpr_id, context_grid = dumid,
               as_os = md_env->md_id.osnum, as_grid = &dparents[SECOND]);
    EMomerr_exit (stat_OM, ret_end);
    dcontexts[SECOND].objid = NULL_OBJID;
    num_parents++;
  }

  /*
   * Connect up the parent(s)
   */

  stat_OM = om$send (msg = message NDnode.NDconnect (num_parents, dparents,
             NULL_GRID, ND_ADD), targetid = my_id);
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
   * Initialize properties.
   */

  ME.EMScnstr->cnstr_props = cnstr_props;

  /*
   * Check if the normal so obtained is opposed to the normal stored in
   * the child. If so, record this in the props field.
   */

  stat_OM = EMgetdrivgeom (&msg_loc, EMSsolve_minimum, &mattyp, mat, &my_grid,
             FALSE, GEOMDATA_VECTOR, &child_vcgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

  if (BSdotp (&msg_loc, normal, child_vcgeom.vector) < 0.0)
  {
    if (cnstr_props & EMScnstr_negative_axis)
      cnstr_props &= ~EMScnstr_negative_axis;
    else
      cnstr_props |= EMScnstr_negative_axis;
    ME.EMScnstr->cnstr_props = cnstr_props;
  }
  ME.EMScnstr->cnstr_props |= EMScnstr_direction_validated;

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
   * Update the property indicating that the children objects have 
   * been externally constrained.
   */

  for (i=0; i<num_children; i++)
    om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
     message EMSassoc.EMexternal_constraint_changed (&msg_loc,
     EMext_const_chg_CONSTRAINT_ADDED)), targetid = children[i].objid,
     targetos = children[i].osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSpervcnstr.EMinit");
  return (stat_OM);
}


method EMvalidate_direction(IGRlong *EMmsg; struct GRmd_env *md_env)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRushort		cnstr_props = NULL;
 BSrc			rc;
 struct GRid		my_grid, child;
 IGRshort 		mattyp, junkmattyp;
 IGRmatrix		junkmat;
 IGRdouble		*mat, *my_normal;
 struct EMSgeomdata 	child_vcgeom, my_vcgeom;
 IGRint			i;
 OM_S_CHANSELECT	to_child;
 OMuint			count = 0;

 *EMmsg = EMS_S_Success;

 if(ME.EMScnstr->cnstr_props & EMScnstr_direction_validated)
  goto wrapup;

 EMmake_chanselect (NDchildren_children, &to_child);

 sts = om$get_channel_count(objid = my_id, p_chanselect = &to_child, 
       count= &count);
 if(!(1&sts)) goto wrapup;
 if(count > 1) goto wrapup;

 child.objid = NULL_OBJID;
 sts = om$send(msg = message NDnode.ASreturn_go(&child, &junkmattyp, junkmat),
       p_chanselect = &to_child, from = 0, to = 0);
 if(!(1&sts)) goto wrapup;
 if(child.objid == NULL_OBJID) goto wrapup;

 if(!EFisAncestryValid(EMmsg, child.objid, child.osnum, 
                       OPP_EMSparamvc_class_id, TRUE))
  goto wrapup;

 cnstr_props = ME.EMScnstr->cnstr_props;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 mattyp = md_env->md_env.matrix_type;
 mat = md_env->md_env.matrix;

 /* Get the current locus.
 */
 sts = om$send(msg = message EMSpervcnstr.EMgetgeomlocus(EMmsg, NULL, 
       &mattyp, mat, &my_vcgeom), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Apply the reversal flag to get the actual normal from the parent.
 */
 my_normal = my_vcgeom.vector;
 if (cnstr_props & EMScnstr_negative_axis)
  for (i=0; i<3; i++)
   my_normal[i] = -my_normal[i];

 /*
  * Check if the normal so obtained is opposed to the normal stored in
  * the child. If so, record this in the props field.
  */
  sts = EMgetdrivgeom (EMmsg, EMSsolve_minimum, &mattyp, mat, &my_grid,
             FALSE, GEOMDATA_VECTOR, &child_vcgeom);
  if(!(1&*EMmsg&sts)) goto wrapup;

  if (BSdotp (&rc, my_normal, child_vcgeom.vector) < 0.0)
   cnstr_props |= EMScnstr_negative_axis;
  else 
   cnstr_props &= ~EMScnstr_negative_axis;

  cnstr_props |= EMScnstr_direction_validated;
  ME.EMScnstr->cnstr_props = cnstr_props;

wrapup:
EMWRAPUP(*EMmsg, sts, "EMSpervcnstr.EMvalidate_direction");
return(sts);
}



/*
 Funtion interface for validating the perpendicular constraint.
*/
from OMObjSpace import pass;

IGRint EMvalidate_direction(EMmsg, mod_env)
IGRlong *EMmsg;
struct GRmd_env *mod_env;
{
 IGRlong	sts = OM_S_SUCCESS;
 OM_S_CLASSLIST classlist;
 OMuword 	search_class;
 GRobjid	osobj = NULL_OBJID;
 GRspacenum     osnum;

 sts = om$osnum_to_oso_objid (osnum = mod_env->md_id.osnum, 
           p_objid = &osobj);
 osnum = mod_env->md_id.osnum;

 search_class = OPP_EMSpervcnstr_class_id;    
 classlist.w_count = 1;
 classlist.w_flags = OM_CLST_subclass;
 classlist.p_classes = &search_class;

 sts = om$send (msg = message OMObjSpace.pass (&classlist,
       OM_e_wrt_message, message EMSpervcnstr.EMvalidate_direction(
       EMmsg, mod_env)), targetid = osobj, targetos = osnum, 
       senderid = osobj);

 return(sts);
}

end implementation EMSpervcnstr;

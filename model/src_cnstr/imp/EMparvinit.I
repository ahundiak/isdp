class implementation EMSparvcnstr;

/*
  History
        Sudha   06/07/93        modified for BSprototype includes
*/

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "EMSasopts.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bscollinmn2.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

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
  IGRboolean collinear;
  IGRshort mattyp;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  IGRdouble *mat;
  struct IGRbsp_curve *absgcv;
  struct GRid my_grid, dumid, dparent, dcontext;
  struct ret_struct info_struct;
  struct EMSgeomdata child_vcgeom, parent_vcgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Only one parent makes sense for this constraint
   */

  EMerr_hndlr (num_parents != 1, *msg, EMS_E_InvalidArg, ret_end);

  mattyp = md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;

  /*
   * Check if the parent yields a B-spline curve with an unambiguous
   * vector definition. If not, flag an error.
   */

  stat_OM = EMgetabsg (&msg_loc,
             &md_env->md_env.matrix_type, md_env->md_env.matrix,
             parents->osnum, parents->objid, &absgcv);
  if (stat_OM == OM_W_UNKNOWN_MSG)
  {
   stat_OM = om$send (msg = message NDnode.NDgive_structure(
                            &msg_loc, &info_struct, md_env),
                      targetid = parents->objid,
                      targetos = parents->osnum);
   if (1&stat_OM&msg_loc)
   {
    EMerr_hndlr (!(info_struct.type & line_generic), *msg, 
                    EMS_E_InvalidArg, ret_end);
   }
  }
  else if (stat_OM == OM_S_SUCCESS)
  {
   if (absgcv->num_poles > 2)
    {
    BScollinmn2 (absgcv->num_poles, (IGRpoint *)absgcv->poles, absgcv->weights, &collinear,
     &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    EMerr_hndlr (!collinear, *msg, EMS_E_InvalidArg, ret_end);
    }
  }
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);



  /*
   * Create AS-source objects if necessary.
   */

  dumid.objid = NULL_OBJID;
  stat_OM = as$make_source(go_grid = *parents, context_grid = dumid,
             as_os = md_env->md_id.osnum, as_grid = &dparent);
  EMomerr_exit (stat_OM, ret_end);
  dcontext.objid = NULL_OBJID;

  /*
   * Connect up the parent
   */

  stat_OM = om$send (msg = message NDnode.NDconnect (1, &dparent,
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
   * Check if the direction so obtained is opposed to the direction stored in
   * the child. If so, record this in the props field.
   */

  stat_OM = EMgetdrivgeom (&msg_loc, EMSsolve_minimum, &mattyp, mat, &my_grid,
             FALSE, GEOMDATA_VECTOR, &child_vcgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

  stat_OM = EMgetdrivgeom (&msg_loc, NULL, &mattyp, mat, &my_grid,
             TRUE, GEOMDATA_VECTOR, &parent_vcgeom);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMerr_hndlr (msg_loc == EMS_I_NotFound, *msg, EMS_E_InvalidCase, ret_end);

  if (BSdotp (&msg_loc, parent_vcgeom.vector, child_vcgeom.vector) < 0.0)
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
   * The addition of this constraint causes the child object to be
   * externally constrained. Record this fact.
   */

  for (i=0; i<num_children; i++)
    om$send (msg = message EMSparameter.EMpasschild (&msg_loc, NULL,
     message EMSassoc.EMexternal_constraint_changed (&msg_loc,
    EMext_const_chg_CONSTRAINT_ADDED)), targetid = children[i].objid,
     targetos = children[i].osnum);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSparvinit");
  return (stat_OM);
}

extern OMuword OPP_EMSparamvc_class_id;

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
 sts = om$send(msg = message EMSparvcnstr.EMgetgeomlocus(EMmsg, NULL, 
       &mattyp, mat, &my_vcgeom), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Apply the reversal flag to get the actual normal from the parent.
 */
 my_normal = my_vcgeom.vector;
 if (cnstr_props & EMScnstr_negative_axis)
  for (i=0; i<3; i++)
   my_normal[i] = -my_normal[i];

 /*
  * Check if the direction so obtained is opposed to the direction stored in
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
EMWRAPUP(*EMmsg, sts, "EMSparvcnstr.EMvalidate_direction");
return(sts);
}



/*
 Funtion interface for validating the perpendicular constraint.
*/
from OMObjSpace import pass;

IGRint EMvalidate_direction1(EMmsg, mod_env)
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

 search_class = OPP_EMSparvcnstr_class_id;    
 classlist.w_count = 1;
 classlist.w_flags = OM_CLST_subclass;
 classlist.p_classes = &search_class;

 sts = om$send (msg = message OMObjSpace.pass (&classlist,
       OM_e_wrt_message, message EMSparvcnstr.EMvalidate_direction(
       EMmsg, mod_env)), targetid = osobj, targetos = osnum, 
       senderid = osobj);

 return(sts);
}

end implementation EMSparvcnstr;

class implementation GAbcsubbc;

#include "dimmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "GAbcsubbc.h"
#include "bsparameters.h"
#include "bslsqplvpts.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bschangepar.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1
extern GRclassid OPP_EMSparamvc_class_id, OPP_EMSparampt_class_id,
OPP_ASsourcein_class_id;

from EMSparamgm import EMgetgeom;

method EMconstruct_associative(IGRlong *EMmsg;
IGRushort const_options;
OM_S_OBJID old_objid;
IGRint nb_root;
IGRchar *parent_info;
IGRint type;
IGRchar *recomp_info;
struct GRvg_construct *construct_list)
{
  IGRlong status;
  union EMSparent_info *roots = NULL;
  IGRuint root_count;
  IGRuint *root_type = NULL;
  IGRint curve_type;
  struct GRid my_GRid;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  switch(type)
  {
  case  GAbcsubbc_AScurve_by_data_reduction:
    break;

  default:
    return (om$send (msg = message GAbspline.EMconstruct_associative(EMmsg,
        const_options, old_objid,nb_root,parent_info,
        type,recomp_info,construct_list),
        mode = OM_e_wrt_message,
        targetid = my_id));
  }

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;
  curve_type = type;

  root_count = nb_root;
  root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
  EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$send (msg = message EMSassoc.EMget_parent_type(EMmsg, 
      curve_type,
      root_count,
      root_type),
      targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  roots = (union EMSparent_info *)stackalloc(root_count*
      sizeof(union EMSparent_info));
  EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
      root_count,
      parent_info,root_type, roots),
      targetid = my_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

  switch (type)
  {
  case  GAbcsubbc_AScurve_by_data_reduction:
    {
      BSrc rc;
      IGRdouble avg_error_buff;
      IGRdouble max_error_buff;
      IGRlong max_ind_buff;
      IGRpoint error_line_buff[2];
      IGRdouble *beg_tan=NULL, *end_tan=NULL,save_cht, bas_tol;
      struct GAbcsubbc_AScurve_by_data_reduction_info *info;

      info = (struct GAbcsubbc_AScurve_by_data_reduction_info *)recomp_info;

      if (info->props & GR_beginning_tangent)
        beg_tan = roots[1].vector;

      if (info->props & GR_end_tangent)
      {
        IGRint i; 
      
        end_tan = roots[root_count-1].vector;
        for (i=0;i<3;i++) end_tan[i] = -end_tan[i];
      }

      BSEXTRACTPAR(&rc, BSTOLBASIS, bas_tol);
      BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);
      /*
       * need the following check to take care of the problem on
       * some 2.1 Sun versions where there was not a transos
       * function and thus the cht stored in the VLA might be bogus. The
       * only way we know of dealing with the problem is by setting
       * an arbitrary range (function of base tolerance). Note that
       * this imposes a limit on how big cht tolerance can be with
       * respect to base tolerance (cht < 10e6 * basetol) for this
       * particular class.
       */
      if ((info->cht <= bas_tol) || (info->cht >= (10e6*bas_tol)))
      	info->cht = save_cht;
      BSchangepar(&rc, BSTOLCHRDHT, info->cht);

      status = om$send(
          msg = message GRsubbc.EMleast_squares_fit_curvee(
          info->order,
          0,
          NULL,
          NULL,
          &roots[0].lc_info,
          (IGRvector *)beg_tan,
          (IGRvector *)end_tan,
          NULL,
          NULL, /* No reference curve */
          &avg_error_buff,
          &max_error_buff,
          &max_ind_buff,
          error_line_buff,
          construct_list),
          targetid = my_id);
      BSchangepar(&rc, BSTOLCHRDHT, save_cht);
      EMerr_hndlr(!(1&status&*(construct_list->msg)), *EMmsg, EMS_E_Fail, wrapup);
      /*
 * Use the geometry field in the construct list to return information
 * to the command object. The right way to do this is to add an argument
 * in EMconstruct_associative. Again return this only if it is an initial
 * construction.
 */
      if (!(const_options & EMSasconst_recompute))
      {
        struct EMfit_error_info *ret_info;
        construct_list->geometry = (IGRchar *)
            malloc(sizeof(struct EMfit_error_info));
        EMerr_hndlr(!construct_list->geometry, *EMmsg,
            EMS_E_DynamicMemoryAllocated,wrapup);
        ret_info = (struct EMfit_error_info *)
            construct_list->geometry;
        ret_info->average_error = avg_error_buff;
        ret_info->max_error = max_error_buff;
        ret_info->max_indicator = max_ind_buff;
        OM_BLOCK_MOVE(error_line_buff, ret_info->error_line, 2*sizeof (IGRpoint));
      }
    }
    break;
  }

wrapup:
  EMWRAPUP (*EMmsg, status, "In GAbcsubbc:EMconstruct_associative error");
  return (status);
}

method EMget_parent_type(IGRlong *EMmsg;
IGRint primitive_type;
IGRuint root_count;
IGRuint *root_type)

/* ************************************************************************
Description
 This function gets the root types which is used for getting information
 about the parents. Adequate memory needs to be allocated for root_type 
 enough to suffice the number of parents.

Arguments
 Input
  root_count : number of roots expected. Necessary.
  
 Output
  root_type : Memory allocated to suffice the number of parents.

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there was an error in getting the root_structures.
 EMS_E_InvalidArg : If the number of roots expected does not match what
                    is returned.
                    Or if the construction code is invalid.
                    Or if root list is not supplied.

History
   11/01/91 : PP  : Creation
 ************************************************************************* */
{
  IGRlong status;
  IGRint i;

  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  switch (primitive_type)
  {
  case  GAbcsubbc_AScurve_by_data_reduction:

    root_type[0]=EMSlcinfo;
    for (i=1;i<root_count;i++)
      root_type[i] = EMSvector;
    break;

  default:
    {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
    }
  }

wrapup:
  EMWRAPUP (status, *EMmsg, "In GAbcsubbc:EMget_parent_type error");
  return (status);
}

method EMassoc_autodimparam (IGRlong *msg; IGRushort opts;
IGRshort *mattyp; IGRmatrix mat;
GRobjid paramobj; 
struct IGRplane *dim_plane;
IGRdouble *dim_plane_xaxis;
struct EMSgeomdata *dim_geom;
IGRint *dim_type)
/***********************************************************************
Description
 This method overrides the one inherited from EMassoc class. It calls 
 EMassoc_dimparam.
 Upon exit the completion code will be one of the following:
 EMS_S_Success : everything OK.
 EMS_E_Fail: otherwise.
History
   06/03/92: Carlos  : Creation
 **************************************************************************/
{
  IGRlong               om_msg = OM_S_SUCCESS;
  OM_S_CHANSELECT       chansel;
  IGRint                num_parents = 0, i, index = -1;
  OM_S_OBJECT_LINKAGE * objects = NULL;
  struct GRid         * parents;

  *msg = EMS_S_Success;

  EMmake_chanselect (NDfather_father, &chansel);
  om$get_channel_count (object = me, p_chanselect = &chansel, 
                        count = (OMuint *) &num_parents);
  if (num_parents)
  {
    objects = (OM_p_OBJECT_LINKAGE)alloca(num_parents * sizeof(OM_S_OBJECT_LINKAGE));
    parents = (struct GRid *)alloca(num_parents * sizeof(struct GRid));
    om$get_channel_objects ( object = me, 
        p_chanselect = &chansel,
        count = (OMuint *) &num_parents,
        size = num_parents,
        list = objects );

    for (i=0; i<num_parents; i++)
    {
      parents[i].osnum = objects[i].osnum;
      if ((parents[i].objid = objects[i].S_objid) == paramobj)
        index = i;
    }
    if (index != -1)
    {
      struct GRmd_env mod_env;

      mod_env.md_env.matrix_type = *mattyp;
      memcpy (mod_env.md_env.matrix, mat, 16 * sizeof(IGRdouble));
      om_msg = om$send ( msg = message GAbcsubbc.EMassoc_dimparam 
          ( msg,
          &mod_env,
          opts,
          me->type,
          me->info,
          num_parents,
          parents,
          index,
          dim_plane,
          dim_plane_xaxis,
          dim_geom,
          dim_type ),
          targetid = my_id );
      EMerr_hndlr (!(1&om_msg), *msg, EMS_E_Fail, ret_end);
    }
    else *msg = EMS_E_Fail;
  }
  else *msg = EMS_E_Fail;

ret_end:

  EMWRAPUP (*msg, om_msg, "GAbcsubbc.EMassoc_autodimparam");
  return (om_msg);
}


method EMassoc_dimparam ( IGRlong *msg; 
	struct GRmd_env *mod_env;
	IGRushort options;
	IGRint type; 
	IGRchar *info;
	IGRint num_parents; 
	struct GRid *parents;
	IGRint index; 
	struct IGRplane *dim_plane; 
	IGRdouble *dim_plane_xaxis;
	struct EMSgeomdata *dim_geom; 
	IGRint *dim_type)
{
  IGRboolean is_world=TRUE;
  IGRlong i, msg_loc, stat_OM;
  IGRdouble *dptr, *vec;
  IGRpoint vecpt;
  GRrange range;
  GRclassid parclass;
  struct IGRline vecline;
  struct EMSgeomdata vcgeom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  om$get_classid (objid = parents[index].objid, osnum = parents[index].osnum,
        p_classid = &parclass);
  if (om$is_ancestry_valid (subclassid = parclass, 
        superclassid = OPP_EMSparamvc_class_id) == OM_S_SUCCESS)
    {
    IGRchar *p_geom;
    struct IGRbsp_curve  curve;
    struct IGRbsp_curve *pcurve;
    IGRpoint *pole1, *poleN;
    IGRpoint f_pt;
    BSrc     b_status;
    IGRdouble arrow_size;
      
    /* get the vector geometry (unitary) */
    stat_OM = om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
          &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
          &vcgeom), targetid = parents[index].objid,
          targetos = parents[index].osnum);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    vec = vcgeom.vector;
      
    /* get my abstract geometry */
    pcurve = &curve;
    stat_OM = om$send (msg = message GRvg.GRgenabsg (&msg_loc,
            &mod_env->md_env.matrix_type, 
            mod_env->md_env.matrix,
            &p_geom), 
            targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    pcurve = (struct IGRbsp_curve *)p_geom;
    pole1 = (IGRpoint *) &pcurve->poles;
    poleN = (IGRpoint *) &pcurve->poles[3*(pcurve->num_poles - 1)];
    vecline.point2 = vecpt;
    vecline.point1 = f_pt;
      
   /* determine the size of the vector to be displayed 
    * (20% of the range box diagonal) 
    */
    stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc, 
      &mod_env->md_env.matrix_type, mod_env->md_env.matrix,
      &is_world, range), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    arrow_size = 0.20 * BSdistptpt(&b_status, &range[0], &range[3]);
      
    /*
     * need to know which vector is sending this message. I assume
     * the first vector has index 1 in the parents list, and that 
     * the second has index != 1. If the vector is the second one, 
     * compute the vector using as starting point the last pole in 
     * the curve, otherwise take the first pole.
     */
    if (index != 1) 
      for (i=0; i<3; i++) {
        f_pt[i] = pcurve->poles[(3*(pcurve->num_poles - 1)) + i];
        vecpt[i] = f_pt[i] + vec[i] * arrow_size;
        }
      else
        for (i=0; i<3; i++) {
          f_pt[i] = pcurve->poles[i];
          vecpt[i] = f_pt[i] + vec[i] * arrow_size;
          }

    if (dim_geom) {
      dim_geom->geomtype = GEOMDATA_LINE;
      dptr = dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
      OM_BLOCK_MOVE (&vecline.point1[0], dptr, sizeof (IGRpoint)); 

      dptr = dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
      OM_BLOCK_MOVE (&vecline.point2[0], dptr, sizeof (IGRpoint));
      }

    if (dim_plane) {
      IGRint code = 0;
      IGRvector normal_vec;
      BSrc	rc;
      IGRvector Xprod;
      dptr = dim_plane->point;
      OM_BLOCK_MOVE (&f_pt[0], dptr, sizeof (IGRpoint));
      /* find a plane which contains the line formed by the displayed 
      vector and is a least squares fit through the poles of the
      curve */
      BSlsqplvpts (f_pt,vecpt,pcurve->num_poles,(IGRpoint *)pcurve->poles,
	             NULL, &code, normal_vec, &rc);
      dptr = dim_plane->normal;
      switch (code) {
	  case 1: /* poles are coincident */
	  case 2: /* poles are collinear  */ 
	    for (i=0; i<3; i++)
	      normal_vec[i] = poleN[i] - pole1[i];
	    /* use cross product of dimension vector and a vector
	    from first pole to last pole */ 
	    BScrossp (&rc, normal_vec,vec,Xprod);
	    OM_BLOCK_MOVE ((IGRpoint *)&Xprod[0], dptr, sizeof (IGRpoint));
	    break; 
	  case 3: /* poles non-collinear and distinct */
	    OM_BLOCK_MOVE ((IGRpoint *)&normal_vec[0], dptr, sizeof (IGRpoint));
	    break;
	  default:
	    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_BSerror, ret_end);
	  break;
          }
      } 

    if (dim_plane_xaxis)
      {
      dptr = dim_plane_xaxis;
      OM_BLOCK_MOVE (vec, dptr, sizeof (IGRpoint));
      }
  else /* parent not a vector */
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }  
ret_end:
  EMWRAPUP (*msg, stat_OM, "GAbcsubbc.EMassoc_dimparam");
  return (stat_OM);
}

end implementation GAbcsubbc;

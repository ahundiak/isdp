/*
  DESCRIPTION
    Implements the methods needed to incorporate a point element into a
    profile.

  HISTORY
    ????          : ???????? : Creation.
    Rajiv Agrawal : 12/22/92 : Some code standardization and cleanup.
    Rajiv Agrawal : 1/25/93  : Removed SKcreate_constraints method.
    Sudha         : 7/02/93  : Modified for BSprototypes ansification

*/

class implementation SKpoint;

#include "OMmacros.h"
#include "parametric.h"
#include "gocmacros.h"

#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grsymdef.h"
#include "vardef.h"
#include "var.h"
#include "mapriv.h"
#include "matypemx.h"
#include "mamulmx.h"

extern OMuword OPP_SKptvar_class_id;

from SKvariable import SKgetvar, SKputvar;

method SKcreate_constraint_points(IGRlong *msg; 
                                  IGRushort options;
                                  IGRshort *matrix_type;
                                  IGRdouble *matrix;
                                  OM_S_OBJID skmgr, *first, *last;
                                  IGRint *element_no;
                                  IGRint total_count)
                               
{
 OM_S_CHANSELECT       mgr_pts_chan, pts_mgr_chan, pts_geom_chan, 
                       geom_pts_chan;
 IGRlong               OM_stat, mthd_stat;
 GRobjid               sk_pt;

 extern IGRboolean     EFplace_line_string();

 /* *************************************************************** */

 *msg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 EMerr_hndlr (skmgr == NULL_OBJID, *msg, EMS_E_InvalidArg, wrapup);

 OM_stat = om$construct (classid = OPP_SKptvar_class_id,
                         p_objid = &sk_pt);
 EMerr_hndlr (!(1&OM_stat),*msg, EMS_E_Fail,wrapup);

 OM_stat = EMmake_chanselect (SKmgr_to_vars, &mgr_pts_chan);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (SKvariable_to_mgr, &pts_mgr_chan);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 OM_stat = om$send (msg = message Root.connect (mgr_pts_chan, NULL,
                     sk_pt, OM_Gw_current_OS, pts_mgr_chan, OM_K_MAXINT),
                    targetid = skmgr);
 EMerr_hndlr (!(1&OM_stat),*msg,EMS_E_OMerror,wrapup);

 OM_stat = EMmake_chanselect (SKvariable_to_geometries, &pts_geom_chan);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 OM_stat = EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

 OM_stat = om$send (msg = message Root.connect (pts_geom_chan,
                     OM_K_MAXINT, my_id, OM_Gw_current_OS, geom_pts_chan,
                     OM_K_MAXINT),
                    targetid = sk_pt);
 EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);
 
 OM_stat = om$send (msg = message SKvariable.SKputvar(&mthd_stat,NULL,
                          matrix_type ,matrix,ME.GR3dpoint->point),
                    targetid = sk_pt);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg, EMS_E_Fail,wrapup);

wrapup:
 EMWRAPUP(*msg, OM_stat, " SKpoint:SKcreate_constraint_points");
 return (OM_stat);
}

method SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                             IGRshort *mattyp_to_lxyz; IGRdouble *mat_to_lxyz)
{
 OM_S_CHANSELECT      geom_pts_chan;
 struct IGRpolyline   polyline;
 struct GRpost_info   post_info;
 IGRpoint             point;
 IGRlong              OM_stat, mthd_stat;
 GRobjid              newid;
 IGRushort     xform_opts; 
 IGRshort four=4, mattyp;
 IGRdouble *mat;
 IGRmatrix mat_store;

 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 if (mattyp_to_lxyz && mat_to_lxyz)
   {
   xform_opts = SK_OPT_FULL_TRANSFORM;
   mattyp = md_env->md_env.matrix_type;
   if (mattyp != MAIDMX)
     {
     mat = mat_store;
     MAmulmx (&mthd_stat, &four, &four, &four, 
      md_env->md_env.matrix, mat_to_lxyz, mat);
     EMerr_hndlr (EMSerror (mthd_stat), *msg, EMS_E_Fail, wrapup);
     MAtypemx(&mthd_stat, mat, &mattyp);
/*
     mattyp = NULL;
*/
     }
   else
     {
     mattyp = *mattyp_to_lxyz;
     mat = mat_to_lxyz;
     }
   }
 else
   {
   xform_opts = NULL;
   mattyp = md_env->md_env.matrix_type;
   mat = md_env->md_env.matrix;
   }

 EMmake_chanselect (SKgeometry_to_defpts, &geom_pts_chan);
 OM_stat = om$send (msg = message SKvariable.SKgetvar (&mthd_stat,
                     xform_opts, &mattyp, mat,
                     point),
                    p_chanselect = &geom_pts_chan);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,wrapup);

 polyline.num_points = 1;
 polyline.points = point;
 post_info.construct_flag = FALSE;

 OM_stat = om$send (msg = message GRlinear.GRputpolyline (&mthd_stat,
                     md_env, &post_info, &polyline, &newid),
                    targetid = my_id);
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail, wrapup);

 GRabsg_del_by_objid(&my_id, &OM_Gw_current_OS);

wrapup:
 
 GR_NOTIFY_LISTENERS(msg, &OM_stat, GR_GEOM_MODIFIED);
 EMWRAPUP(*msg, OM_stat, " SKpoint:SKcreate_constraint_points");
 return (OM_stat);

}

/*
 *  Overriding GRplotyourself and GRformatele so that geometric contraints
 *  will not plot or convert to IGDS as GR3dpoints.
 *
 */

method GRplotyourself(IGRlong *msg;
                      struct GRmd_env *md_env;
                      IGRchar *dgn_buf;
                      IGRchar *bs_buf;
                      IGRchar *ele_buf;
                      IGRint *ele_size;
                      IGRint *file_des;
                      IGRdouble *max_overflow;
                      struct GRid *id_info;
                      IGRdouble *scale_factor)
{
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


extern    IGRboolean    GUcpxhandler();
extern    IGRint	GUget_symb_level();

static struct GRmd_env new_env;
static IGRmatrix scale_matrix;

%safe
static int old_scale=0;
static IGRshort	old_type=-1;
%endsafe

method GRformatele ( IGRlong *msg; struct GRmd_env *md_env; 
		     IGRchar *dgn_buf; IGRchar *bs_buf;
		     IGRchar *ele_buf; IGRint *ele_size; IGRint *file_des;
		     IGRdouble *max_overflow; IGRdouble *scale_factor )
{
  IGRchar  *bs_ptr;
  IGRchar  class_name[OM_K_MAXCLASS_LEN];
  IGRboolean  world = TRUE;
  IGRint  ele_type;
  IGRlong  status;
  IGRlong  num_values = 6;
  GRrange  range;
  struct GRsymbology  symbology;
  IGRboolean          overflow_stat;
  IGRshort    num_rc = 4;
  struct IGRlbsys     *lbsys_ptr;
  IGRlong    i;
  IGRlong    OMmsg;
  IGRchar    IGDSclass = 0;
  struct    GRid id;
  IGRboolean    format;
  IGRboolean    mark_as_cpx;
  IGRboolean    cpx_calling = FALSE;

  OMmsg = OM_S_SUCCESS;
  bs_ptr = bs_buf;
  lbsys_ptr = (struct IGRlbsys *)bs_buf;

  status = om$get_classname ( classname = class_name, object = me );
  if ( !(1 & status) )
    goto wrap_up;

  status = GUmapclass_to_igds ( class_name, &ele_type );
  if (  status != OM_S_SUCCESS )
    goto wrap_up;

  if (*scale_factor ==  1)
  {
    new_env = *md_env;
    old_scale = *scale_factor;
    old_type = md_env->md_env.matrix_type;
  }
  else
  {
    new_env.md_id = md_env->md_id;

    if (! ((*scale_factor == old_scale) &&
        (old_type == MAIDMX)  && 
        (new_env.md_env.matrix_type == MAIDMX)))
    {
      if (*scale_factor != old_scale)
      {
        scale_matrix[0] = scale_matrix[5] = scale_matrix[10] = 
            *scale_factor;
        scale_matrix[1] = scale_matrix[2] = scale_matrix[3] = 0.0;
        scale_matrix[4] = scale_matrix[6] = scale_matrix[7] = 0.0;
        scale_matrix[8] = scale_matrix[9] = scale_matrix[11] = 0.0;
        scale_matrix[12]= scale_matrix[13] = scale_matrix[14] = 0.0;
        scale_matrix[15] = 1.0;

        old_scale = *scale_factor;
      }

      if (new_env.md_env.matrix_type == MAIDMX)
        for (i=0; i<16; ++i)
          new_env.md_env.matrix[i] = scale_matrix[i];
      else
        MAmulmx ( msg, &num_rc, &num_rc, &num_rc, scale_matrix,
            md_env->md_env.matrix, new_env.md_env.matrix );

      MAtypemx(msg,new_env.md_env.matrix,
          &new_env.md_env.matrix_type);

      old_type = md_env->md_env.matrix_type;/* use input value  */
    }
  }

  status = om$send (   mode = OM_e_wrt_object, 
      msg = message GRvg.GRgetrang ( msg, 
      &new_env.md_env.matrix_type, 
      new_env.md_env.matrix, &world, range ), 
      senderid = my_id, 
      targetid = my_id );

  overflow_stat = GUcheck_overflow ( msg, &num_values, range,
      max_overflow );
  if ( !overflow_stat )
    goto wrap_up;

  status = om$send(mode = OM_e_wrt_object,
      msg = message GRvg.GRgetsymb ( msg, &symbology ),
      senderid = my_id,
      targetid = my_id );

  GUget_symb_level ( msg, &symbology );

  id.osnum = OM_Gw_current_OS;
  id.objid = my_id;

  if ( (ele_type == GU_CELL ) || (ele_type == GU_CPX_STRING))
    cpx_calling = TRUE;

  if (! GUcpxhandler( msg, &cpx_calling, md_env, dgn_buf, bs_buf, 
      ele_buf, ele_size, file_des, max_overflow, 
      scale_factor, &IGDSclass, &me->properties, 
      &symbology.level, &id, &format, &mark_as_cpx ) )
  {
    *msg = MSSUCC;
    goto wrap_up;
  }

  status = TRUE;

wrap_up:
  return OM_S_SUCCESS;
}


end implementation SKpoint;


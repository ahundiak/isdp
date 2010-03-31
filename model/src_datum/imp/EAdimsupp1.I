class implementation EMSdimdtm;

/*
  HISTORY

	Sudha	23-june-93	modified for BSprototype ansification

*/

#include <alloca.h>
#include "OMmacros.h"
#include "REdatpln.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "emsdef.h"
#include <math.h>
#include "maptlnpro.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bscrossp.h"
#include "bserr.h"
#include "bsmkvec.h"
#include "bsnorvec.h"


from EMSdatpln import EMget_pln_info;
from expression import NDgive_value;
from EMSsurface import EMget_point_on_surface, EMalgnnrml;
from GRlinear import GRgetpolyline;
from EMSassoc import EMget_info;

extern OMuword OPP_EMSsubbs_class_id, OPP_EMSdatpln_class_id;

method give_plane ( IGRint          *EMmsg;
                    IGRmatrix       matrix;
                    struct GRmd_env *md_env )
{
 IGRlong status, rc, msg_loc;
 IGRint          i;
 unsigned int    info_size, type;
 IGRpoint        origin;
 IGRvector       zaxis, xaxis, yaxis;
 struct GRid     my_GRid,refpln_GRid, dim_GRid;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 dim_GRid.objid   = sender_id;
 dim_GRid.osnum   = sender_os;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 for (i=0;i<16;i++)
  matrix[i] = 0.0;

 matrix[15] = 1.0;

 pp_get_ref_plane(&msg_loc, &my_GRid, &refpln_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

/*
 status = EFget_active_parameter (&refpln_GRid, &dim_GRid, &param_GRid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
*/

 status = om$send (msg = message EMSassoc.EMget_info (&msg_loc,
                         NULL, &type, &info_size, NULL),
                   targetid = refpln_GRid.objid,
                   targetos = refpln_GRid.osnum);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                         NULL,md_env, xaxis, yaxis, zaxis, origin, NULL),
                   targetid = refpln_GRid.objid,
                   targetos = refpln_GRid.osnum);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 switch (type)
 {
  case EMS_ASparallel_to_planar_element:
  case EMS_ASparallel_to_planar_element_new:

   OM_BLOCK_MOVE (zaxis,matrix, sizeof (IGRvector));
   OM_BLOCK_MOVE (xaxis,&matrix[8], sizeof (IGRvector));
   OM_BLOCK_MOVE (yaxis,&matrix[4], sizeof (IGRvector));
/*
   BScrossp (&rc, &matrix[8], matrix, &matrix[4]);
*/
  break;
 
  case EMS_ASangle_to_planar_element:
  {
   char *ptr;
   struct EMSdatpln_planar_element_info datpln_info;
   ptr = (char *)&datpln_info;

   status = om$send (msg = message EMSassoc.EMget_info (&msg_loc,
                         NULL, &type, &info_size, &ptr),
                   targetid = refpln_GRid.objid,
                   targetos = refpln_GRid.osnum);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   if ((datpln_info.props & EMS_BOTTOM_ELEMENT) ||
       (datpln_info.props & EMS_TOP_ELEMENT))
   {
     OM_BLOCK_MOVE (yaxis,matrix, sizeof (IGRvector));
     OM_BLOCK_MOVE (zaxis,&matrix[4], sizeof (IGRvector));
   }
   else
   {
     OM_BLOCK_MOVE (xaxis,matrix, sizeof (IGRvector));
     OM_BLOCK_MOVE (zaxis,&matrix[4], sizeof (IGRvector));
   }
   BScrossp (&rc, matrix, &matrix[4], &matrix[8]);
  }
  break;
 }
wrapup:
 EMWRAPUP (*EMmsg, status, "EMSdtmdim.give_plane");
 return (status);
}

method give_axis  ( IGRint          * msg;
                    IGRvector         axis;
                    struct GRmd_env * md_env )
{
    *msg = NO_AXIS;
    return (OM_S_SUCCESS);
}

method DMgive_structure ( IGRint                *EMmsg;
                          IGRint                dim_type;
                          IGRboolean            inq0_set1;
                          struct dim_ret_struct *str;
                          struct GRmd_env       *md_env )
{
 IGRlong         status, msg_loc;
 IGRint action,i,num_parents, type, info_size;
 struct IGRpolyline py;
 IGRpoint pts_buff[5];
 char *info = NULL;
 IGRdouble sign, length;
 IGRvector zaxis;
 struct GRid *parents = NULL;
 struct GRid     my_GRid, refpln_GRid, dim_GRid;
 struct EMSdatpln_planar_element_info *datpln_info;
 OM_S_CHANSELECT to_components;
 IGRmatrix mat;
 short tmp_mat_type;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 py.num_points = 5;
 py.points = (IGRdouble *)pts_buff;

 tmp_mat_type = MAIDMX;
 MAidmx(&msg_loc,mat);

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 pp_get_ref_plane(&msg_loc, &my_GRid, &refpln_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 dim_GRid.objid   = sender_id;
 dim_GRid.osnum   = sender_os;

 EFget_parents_and_info (&msg_loc, &refpln_GRid, &type, &info_size, NULL,
                         &num_parents, NULL);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (num_parents)
 {
  parents = (struct GRid *) alloca (sizeof (struct GRid) * num_parents);
  EMerr_hndlr(!parents, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if (info_size)
 {
  info = (char *) alloca (info_size);
  EMerr_hndlr(!info, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 EFget_parents_and_info (&msg_loc, &refpln_GRid, &type, &info_size, info,
                         &num_parents, parents);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EMmake_chanselect(GRcmpowner_to_components, &to_components);

 action = 1;
 status = om$send (msg = message GRlinear.GRgetpolyline(&msg_loc,
                         &tmp_mat_type,
                         mat,
                         &action,
                         &py),
                   p_chanselect = &to_components,
                   from = 0,
                   to = 0,
                   senderid = refpln_GRid.objid);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 datpln_info = (struct EMSdatpln_planar_element_info *)info;

 switch (type)
 {
  case EMS_ASparallel_to_planar_element:
  {
    str->type = DMkeyseg;
    str->var.dm_keyseg.u_par = 0.0;

    status = om$send (msg = message EMSdatpln.EMget_pln_info(&msg_loc,
                         NULL,md_env, NULL, NULL, zaxis, 
                         NULL, 
                         NULL),
                   targetid = refpln_GRid.objid,
                   targetos = refpln_GRid.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    status = om$send (msg = message expression.NDgive_value(&length),
                      targetid = parents[num_parents-1].objid,
                      targetos = parents[num_parents-1].osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    OM_BLOCK_MOVE(&py.points[0],str->var.dm_keyseg.line,sizeof
          (IGRpoint));
    

    if (datpln_info->props & EMS_REVERSE_DIR)
     sign = -1;
    else
     sign = 1;

    for (i=0;i<3;i++)
     str->var.dm_keyseg.line[3+i] = str->var.dm_keyseg.line[i] - 
                       zaxis[i]*sign*length;
  }
  break;

  case EMS_ASparallel_to_planar_element_new:
  {
    struct GRmd_env parentpln_env;
    struct GRid parentpln_GRid;
    struct IGRplane plane;
    IGRpoint plane_point;
    IGRvector plane_normal;

    plane.point = plane_point;
    plane.normal = plane_normal;

    str->type = DMkeyseg;
    str->var.dm_keyseg.u_par = 0.0;

    status = om$send (msg = message NDnode.ASreturn_go(&parentpln_GRid,
                            &parentpln_env.md_env.matrix_type, 
                             parentpln_env.md_env.matrix),
                     targetid = parents[0].objid,
                     targetos = parents[0].osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    EFget_oriented_normal(&msg_loc,NULL,&parentpln_GRid,&parentpln_env,&plane);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if (datpln_info->props & EMS_OFFSET_VALUE)
    {
     status = om$send (msg = message expression.NDgive_value(&length),
                      targetid = parents[num_parents-1].objid,
                      targetos = parents[num_parents-1].osnum);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     length = fabs (length);
    }

    OM_BLOCK_MOVE(&py.points[0],str->var.dm_keyseg.line,sizeof
          (IGRpoint));
    
    if (datpln_info->props & EMS_PLANE_REV)
      sign = -1;
    else
      sign = 1;

    for (i=0;i<3;i++)
     str->var.dm_keyseg.line[3+i] = str->var.dm_keyseg.line[i] - 
                       plane_normal[i]*sign*length;
  }
  break;

  case EMS_ASangle_to_planar_element:
  {
   str->type = DMkeyseg;
   str->var.dm_keyseg.u_par = 0.0;

   if (dim_type & ORIG_INFO)
   {
    ppget_orig_line (&msg_loc, datpln_info->props, &py,
                     str->var.dm_keyseg.line,
                     &str->var.dm_keyseg.line[3]);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   }
   else
   {
    ppget_measure_line(&msg_loc, &parents[0], &parents[1],
                      str->var.dm_keyseg.line,
                      &str->var.dm_keyseg.line[3]); 
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
   }
  }
 }
 {
   IGRlong two;

   two = 2;
   MAoptsxform(&msg_loc,&two,&md_env->md_env.matrix_type,
	       md_env->md_env.matrix,
	       str->var.dm_keyseg.line,
	       str->var.dm_keyseg.line);
   if (!(1&msg_loc)) goto wrapup;
 }


wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSdtmdim: DMgive_structure");
 return (status);
}

IGRint ppget_measure_line(EMmsg, as_pln_GRid, as_pvt_GRid, lnpt1, lnpt2)
IGRlong *EMmsg;
struct GRid *as_pln_GRid;
struct GRid *as_pvt_GRid;
IGRpoint lnpt1;
IGRpoint lnpt2;
{
  IGRboolean pos_orient,is_surface = FALSE, is_datpln = FALSE;
  IGRushort pos_option;
  IGRlong status, msg_loc;
  IGRdouble t;
  IGRpoint parent_plnpt, pivot_point1, pivot_point2;
  IGRvector parent_plnnrml;
  struct IGRline pivot_line;
  struct IGRplane plane;
  struct GRid parentpln_GRid, *pivot_GRid;
  struct EMparms parms;
  struct GRmd_env pln_env, *pivot_env;
  struct GRlc_info pivot_lcinfo;

  IGRvector tmp_vec;

  status = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  plane.point = parent_plnpt;
  plane.normal = parent_plnnrml;
  pivot_line.point1 = pivot_point1;
  pivot_line.point2 = pivot_point2;

  status = om$send (msg = message NDnode.ASreturn_go(&parentpln_GRid,
                            &pln_env.md_env.matrix_type, 
                             pln_env.md_env.matrix),
                     senderid = NULL_OBJID,
                     targetid = as_pln_GRid->objid,
                     targetos = as_pln_GRid->osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   pivot_GRid = &pivot_lcinfo.located_obj;
   pivot_env = &pivot_lcinfo.module_info;
   status = om$send (msg = message NDnode.ASreturn_go(pivot_GRid,
                            &pivot_env->md_env.matrix_type, 
                             pivot_env->md_env.matrix),
                     senderid = NULL_OBJID,
                     targetid = as_pvt_GRid->objid,
                     targetos = as_pvt_GRid->osnum);
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   if (EFisAncestryValid(&msg_loc,parentpln_GRid.objid, parentpln_GRid.osnum,
                       OPP_EMSsubbs_class_id,FALSE))
    is_surface = TRUE;
   else
    is_surface = FALSE;

   if (is_surface)
   {
    status = om$send(msg = message EMSsurface.EMget_point_on_surface(&msg_loc,
                          &pln_env,0,1, parent_plnpt, &parms),
                     senderid = NULL_OBJID,
                     targetid = parentpln_GRid.objid,
                     targetos = parentpln_GRid.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    pos_option = EMS_GET_POS_ORIENT;
    status = om$send (msg = message EMSsurface.EMalgnnrml(
                           &msg_loc,
                           pos_option,
                           &pos_orient,
                           NULL,
                           NULL),
                     senderid = NULL_OBJID,
                     targetid = parentpln_GRid.objid,
                     targetos = parentpln_GRid.osnum);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    OM_BLOCK_MOVE(parms.normal,parent_plnnrml,sizeof (IGRvector));
   }
   else
   {
     status = EFget_orientation_from_parent(&msg_loc,&parentpln_GRid,&pln_env,
                           NULL,NULL,parent_plnnrml,parent_plnpt);
     EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   }

   pp_project_onto_plane(&msg_loc,&pivot_lcinfo, &plane,&pivot_line);
   EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   status = MAptlnproj (&msg_loc, plane.point, &pivot_line, 
                        lnpt1, 
                        &t);
   EMerr_hndlr (!status, *EMmsg, EMS_E_MAerror, wrapup);
   OM_BLOCK_MOVE(plane.point,lnpt2,sizeof
                 (IGRpoint));

  /* TR#119221096
   * Pivot line passing thru plane origin creates a zero measure vector
   * In such cases the normal to the pivot line in the parent ref plane 
   * gives the required measure vector -- satish
   */
 
   status =  BSmkvec(&msg_loc, tmp_vec, lnpt1, lnpt2);
   BSnorvec( &msg_loc, tmp_vec);
   if (msg_loc == BSDGENRAT )
   {
	IGRvector pv_vec;
	IGRpoint pv_point;
	IGRpoint intr_pt;
	IGRvector intr_vec;
	BSrc rc;
	IGRint i;

	status = BSmkvec(&rc, pv_vec, pivot_line.point1, pivot_line.point2);
	BSnorvec(&rc, pv_vec);

	BSnorvec(&rc, plane.normal);

	status = BScrossp(&rc, plane.normal, pv_vec, intr_vec);
	EMerr_hndlr((rc!=0), *EMmsg, EMS_E_BSerror, wrapup);


	for (i=0;i<3;i++)
	{
		intr_pt[i] = 0.0;
		intr_pt[i] = pivot_line.point1[i] + 2.0*intr_vec[i];
	}
	OM_BLOCK_MOVE(pivot_line.point1,lnpt1,sizeof(IGRpoint));
	OM_BLOCK_MOVE(intr_pt,lnpt2,sizeof(IGRpoint));
	
   }

	
wrapup:
 EMWRAPUP (*EMmsg, status, "In ppgetmeasline error");
 return (status);
}

IGRint ppget_orig_line (EMmsg,props,py,lnpt1, lnpt2)
IGRlong *EMmsg;
char props;
struct IGRpolyline *py;
IGRpoint lnpt1;
IGRpoint lnpt2;
{
 *EMmsg = EMS_S_Success;

 if (props & EMS_BOTTOM_ELEMENT)
 {
      OM_BLOCK_MOVE(&py->points[0],lnpt1,sizeof
          (IGRpoint));
      OM_BLOCK_MOVE(&py->points[9],lnpt2,sizeof
          (IGRpoint));
 }
 else if (props & EMS_TOP_ELEMENT)
 {
      OM_BLOCK_MOVE(&py->points[9],lnpt1,sizeof
          (IGRpoint));
      OM_BLOCK_MOVE(&py->points[0],lnpt2,sizeof
          (IGRpoint));
 }
 else if (props & EMS_LEFT_ELEMENT)
 {
      OM_BLOCK_MOVE(&py->points[0],lnpt1,sizeof
          (IGRpoint));
      OM_BLOCK_MOVE(&py->points[3],lnpt2,sizeof
          (IGRpoint));
 }
 else
 {
      OM_BLOCK_MOVE(&py->points[3],lnpt1,sizeof
          (IGRpoint));
      OM_BLOCK_MOVE(&py->points[0],lnpt2,sizeof
          (IGRpoint));
 }
 return (OM_S_SUCCESS);
}

method NDmake_source ( long *msg;
                       struct GRid *located_obj,*context;char *path;
                       GRspacenum as_osnum; struct GRid *as)
{
 IGRlong sts, loc_msg;
 OMuword myclassid;
 IGRuint tag_con_stat;
 OMuword old_tag_os;
 OMuint obj_tag;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 as->objid = NULL_OBJID;
 tag_con_stat = om$enable_tag_connects(flag = TRUE);
 om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = OM_Gw_current_OS);

 sts = om$get_classid (objid = my_id,
                       p_classid = &myclassid);
 if (!(1&sts)) goto wrapup;

 if (myclassid == OPP_EMSdimdtm_class_id)
 {
   sts = om$objid_to_tag(
      objid = my_id,
      p_tag = &obj_tag);

   if (sts != OM_S_SUCCESS)
   {
   sts = om$change_class (objid = my_id,
                          sd_override = OM_K_change_class_sd_override,
                          classname = "EMSdimdtm1");
   if (!(1&sts)) goto wrapup;

   sts = om$add_tag(p_tag = &obj_tag);
   }
 }

 if (context->objid != NULL_OBJID)
 {
  sts = ASmake_source_from_go(&loc_msg, located_obj,context,
                                 as_osnum, as);
  if (!(1&sts&loc_msg)) *msg = MSFAIL;
 }
 else
  *as = *located_obj;

wrapup:
 om$enable_tag_connects(flag = tag_con_stat);
 om$set_tag_os(p_prev_osnum = &old_tag_os, osnum = old_tag_os);
 return (sts);
}

end implementation EMSdimdtm;

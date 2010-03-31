class implementation EMSdimdtm;

/*
  HISTORY

        Sudha   23-june-93      modified for BSprototype ansification
*/

#include <alloca.h>
#include "nddef.h"
#include "REdatpln.h"
#include "dimangular.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"


from EMSassoc import EMget_info;

from GRlinear import GRgetpolyline;

method EMautodim ( IGRlong             *EMmsg;
                   struct GRmd_env     *md_env)
{
 IGRlong status,msg_loc,long_rc;
 OMuint num_parents;
 IGRint action,type, info_size, trak_dir;
 IGRpoint dumpt;
 IGRchar *info = NULL;
 struct GRid *parents = NULL, datum_GRid, dim_GRid, my_GRid;
 struct IGRpolyline py;
 IGRpoint pts_buff[5];
 IGRboolean   aflag = 0;
 OM_S_CHANSELECT to_components;
 

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
 py.num_points = 5;
 py.points = (IGRdouble *)pts_buff;
 
 pp_get_ref_plane(&msg_loc, &my_GRid, &datum_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EFget_parents_and_info (&msg_loc, &datum_GRid, &type, &info_size, NULL,
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

 EFget_parents_and_info (&msg_loc, &datum_GRid, &type, &info_size, info,
                         &num_parents, parents);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 EMmake_chanselect(GRcmpowner_to_components, &to_components);


 if(aflag = pwIsActivationOn())
 {
   MAidmx(&long_rc, md_env->md_env.matrix);
   md_env->md_env.matrix_type = MAIDMX;
 }
 action = 1;
 status = om$send (msg = message GRlinear.GRgetpolyline(&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix,
                         &action,
                         &py),
                   p_chanselect = &to_components,
                   from = 0,
                   to = 0,
                   senderid = datum_GRid.objid);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


 switch (type)
 {
  case EMS_ASparallel_to_planar_element:
  case EMS_ASparallel_to_planar_element_new:
  {
    dim_GRid.objid = NULL_OBJID;
    trak_dir = 0;

    dm$place_sglpara ( orig_grid    = &my_GRid,
                       orig_pt      = dumpt,
                       plane_grid   = &my_GRid,
                       trak_dir     = trak_dir,
                       owner        = &parents[num_parents-1],
                       dim_grid     = &dim_GRid );
    EMerr_hndlr (dim_GRid.objid == NULL_OBJID, *EMmsg, EMS_E_Fail, wrapup);
    break;
  }

  case EMS_ASangle_to_planar_element:
  { IGRint  msg_loc,sector = 1;
   IGRdouble trak_dist, *dimpln_z, dotp;
   IGRvector orig_vec, meas_vec, pseudo_z;
   IGRpoint orig_lnpt1, orig_lnpt2, meas_lnpt1, meas_lnpt2;
   IGRmatrix dim_pln_mx;
   struct EMSdatpln_planar_element_info *datpln_info;
   BSrc		rc;

   status = om$send (msg = message EMSdimdtm.give_plane(&msg_loc, 
                           dim_pln_mx, md_env),
                     targetid = my_id);
   EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


   if(aflag = pwIsActivationOn())
   {
     pwGetActiveModuleEnv(md_env);
   }

   dimpln_z = &dim_pln_mx[8];
   dim_GRid.objid = NULL_OBJID;
   datpln_info = (struct EMSdatpln_planar_element_info *) info;
   if ((datpln_info->props & EMS_BOTTOM_ELEMENT) ||
      (datpln_info->props & EMS_TOP_ELEMENT))
    trak_dist = BSdistptpt(&rc, py.points, &py.points[9]); 
   else
    trak_dist = BSdistptpt(&rc, py.points, &py.points[3]); 

   trak_dist = trak_dist/2.0;

   ppget_orig_line (&msg_loc,datpln_info->props,&py,orig_lnpt1, orig_lnpt2);
   EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   ppget_measure_line(&msg_loc, &parents[0], &parents[1], meas_lnpt1,
                      meas_lnpt2);
   EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   status = BSmkvec(&rc, orig_vec,orig_lnpt1, orig_lnpt2);
   BSnorvec (&rc, orig_vec);
   EMerr_hndlr((rc!=0), *EMmsg, EMS_E_BSerror, wrapup);

   status = BSmkvec(&rc, meas_vec,meas_lnpt1, meas_lnpt2);
   BSnorvec (&rc, meas_vec);
   EMerr_hndlr((rc!=0), *EMmsg, EMS_E_BSerror, wrapup);

   status = BScrossp(&rc,orig_vec,meas_vec, pseudo_z);
   EMerr_hndlr((rc!=0), *EMmsg, EMS_E_BSerror, wrapup);

   dotp = pseudo_z[0]*dimpln_z[0] + pseudo_z[1]*dimpln_z[1] +
          pseudo_z[2]*dimpln_z[2];

   if (dotp < 0.0)
    sector = CLOCK_WISE;
   else
    sector = 0;
   dm$place_angular (orig_grid  = &my_GRid,
                     orig_pt    = dumpt,
                     meas_grid  = &my_GRid,
                     meas_pt    = dumpt,
                     plane_grid = &my_GRid,
                     sector     = sector,
                     trak_dist  = trak_dist,
                     owner      = &parents[num_parents-1],
                     dim_grid   = &dim_GRid );
   EMerr_hndlr (dim_GRid.objid == NULL_OBJID, *EMmsg, EMS_E_Fail, wrapup);
  break;
  }

 }
 
wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSdimdtm : EMautodim error");
 return (status);
}

EFget_parents_and_info (EMmsg, obj_GRid, type, info_size, info,
                        num_parents, parents)
IGRlong *EMmsg;
struct GRid *obj_GRid;
IGRuint *type;
IGRuint *info_size;
IGRchar *info;
IGRint *num_parents;
struct GRid *parents;
{
 IGRlong status,msg_loc;
 IGRint i;
 OM_S_OBJECT_LINKAGE *objects = NULL;
 OM_S_CHANSELECT father;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 msg_loc = EMS_S_Success;
 EMmake_chanselect (NDfather_father, &father);

 status = om$get_channel_count (objid = obj_GRid->objid,
                                osnum = obj_GRid->osnum,
                                p_chanselect = &father, 
                                count = (OMuint *) num_parents);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 if (parents && num_parents)
 {
  objects = (OM_S_OBJECT_LINKAGE *) alloca(*num_parents * 
                sizeof(OM_S_OBJECT_LINKAGE));
  EMerr_hndlr(!objects, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  om$get_channel_objects (objid = obj_GRid->objid, 
                          osnum = obj_GRid->osnum,
                          p_chanselect = &father,
                          count = (OMuint *) num_parents,
                          size = *num_parents,
                          list = objects);

  for (i=0; i<*num_parents; i++) 
  {
   parents[i].objid = objects[i].S_objid;
   parents[i].osnum = objects[i].osnum;
  }
 }

 status = om$send (msg = message EMSassoc.EMget_info (&msg_loc, NULL,
                         type, info_size, (info ? &info : NULL)),
                   senderid = NULL_OBJID,
                   targetid = obj_GRid->objid,
                   targetos = obj_GRid->osnum);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


wrapup:
 return (status);
} 

pp_get_ref_plane(EMmsg, dim_ref_GRid, ref_pln_GRid)
IGRlong *EMmsg;
struct GRid *dim_ref_GRid;
struct GRid *ref_pln_GRid;
{
 OMuint num_parents;
 IGRlong status;
 OM_S_CHANSELECT father;
 OM_S_OBJECT_LINKAGE parent_list;

 *EMmsg = EMS_S_Success;

 EMmake_chanselect (NDfather_father, &father);

 status = om$get_channel_objects (objid = dim_ref_GRid->objid,
                                  osnum = dim_ref_GRid->osnum,
                                  p_chanselect = &father,
                                  list = &parent_list,
                                  size = 1,
                                  count = &num_parents);
 if (status == OM_I_LISTOVFLOW)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 ref_pln_GRid->objid = parent_list.S_objid;
 ref_pln_GRid->osnum = parent_list.osnum;

wrapup:
 return (status);
}

method EMdelete_dim_support (IGRlong *msg; struct GRmd_env *env)
{
 *msg = MSSUCC;
 return (om$send (msg = message Root.delete(1),
                  targetid = my_id));
}
end implementation EMSdimdtm;


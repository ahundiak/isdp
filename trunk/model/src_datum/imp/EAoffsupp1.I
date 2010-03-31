class implementation EMSdimoff;



#define dflT1 0

/*
  HISTORY

	dfl	11/93	

*/


#include <alloca.h>
#include "OMmacros.h"
#include "REdatpln.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "emsdef.h"
#include "nddef.h"
#include <math.h>
#include "maptlnpro.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bscrossp.h"
#include "bserr.h"



/* offset control bits */
#define ORIENTATION             1
#define PROJECTION              2
#define UNIFORM                 4
#define COMPOSITE               8
#define FILLET                  16
#define LOOPS                   32
#define RIGHTSIDE               64
#define PLANAR			128
#define CLOSED                  256

from EMSdatpln import EMget_pln_info;
from expression import NDgive_value;
from EMSsurface import EMget_point_on_surface, EMalgnnrml;
from GRlinear import GRgetpolyline;
from EMSassoc import EMget_info, EMgetparam;
from ASsource import ASreturn_go;
from GRcurve import GRendpts, GRgenabsg;
from GRvg import GRdetplane;

extern OMuword OPP_EMSsubbs_class_id,
       OPP_EMSparamvl_class_id,
       OPP_EMSplane_class_id, 
       OPP_EMSproject_class_id, 
       OPP_EMSsurface_class_id,
       OPP_ASsource_class_id, 
       OPP_EMSdatpln_class_id;

extern double BSdistptpt();

method give_plane ( IGRint          *EMmsg;
                    IGRmatrix       dmatrix;
                    struct GRmd_env *md_env )
{

 int             EAsupp;
 IGRlong status, rc, msg_loc, stat_OM;

 IGRboolean      value_found, plane_found;
 IGRint          i, j;
 OMuint          num_parents;
 OMuword         class_id;
 unsigned int    info_size, type;
 IGRint          parvl_idx;
 IGRchar         *info = NULL;
 IGRchar 	 *generic_pointer = NULL;
 GRobjid 	 closest_crv_id;
 struct IGRbsp_curve 	        *closest_crv_geom = NULL;
 IGRpoint        cveval[2];
 IGRdouble       sign;
 IGRvector       crossp, crossp2;
 IGRshort        mat_type,
                 org_mat_type, 
                 plane_mat_type, 
                 cv_mat_type;
 IGRdouble       size;
 IGRdouble       donofcv, donorgcv;
 IGRdouble       *matrix,
                 org_matrix[16], 
                 dimmatrix[16], 
                 cv_matrix[16], 
                 plane_matrix[16];         
 IGRpoint        plane_point, stpt1, stpt2, ept;
 IGRvector       plane_normal;
 OM_S_CHANSELECT to_comps;
 OM_S_OBJECT_LINKAGE *object = NULL;
 struct GRid     my_GRid,
                 org_GRid,
                 target,
                 curve_GRid,
                 plane_GRid,
                 *parents = NULL,
                 dim_GRid;
 struct IGRplane plane;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 dim_GRid.objid   = sender_id;
 dim_GRid.osnum   = sender_os;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 EAsupp = 0;
 pp_get_gacurve(&msg_loc, &my_GRid, &curve_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, NULL,
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
 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, info,
                         &num_parents, parents);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EAsupp = 111;
 /* determine offset control */

#if dflT1
 /* test what came in */
 printf("offset control flags = %d\n", me->offset_control);
 
#endif



 /* determine parent index of offset distance */
 /* determine ASsource parent index  */
 /* ASsource object could be the listener of a curve and/or plane 
    or reference plane */

 plane_found = FALSE;
 value_found = FALSE;
 EAsupp = 124;

 for(i=0, j=0; i<num_parents;i++) {
   status = om$get_classid(
                     objid = (parents + i)->objid,
                     osnum = (parents + i)->osnum,
                     p_classid = &class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    
   if(!plane_found) {
        status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSdatpln_class_id);
        EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
        if(status == OM_S_SUCCESS) {
           om$send (msg = message EMSassoc.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
           EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
           plane_found = TRUE;
        } else { 
           status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSsurface_class_id);
           EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
           if(status == OM_S_SUCCESS) {
              om$send (msg = message EMSassoc.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
              EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
              plane_found = TRUE;
           } else {
             status = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_ASsource_class_id);
             EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
             if(status == OM_S_SUCCESS) {
               om$send (msg = message ASsource.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
               EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
       
               status = om$get_classid(
                     objid = plane_GRid.objid,
                     osnum = plane_GRid.osnum,
                     p_classid = &class_id);
               EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
               status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSsurface_class_id);
               EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
               if(status == OM_S_SUCCESS)
                 plane_found = TRUE;
	     }  
          } 
      }     
   }
   if(!value_found) {
     status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSparamvl_class_id); 
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     if(status == OM_S_SUCCESS) {
          parvl_idx = i;
          value_found = TRUE;
     }
   }
 }

 if(!(value_found && plane_found)) {
   status = 0;  
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }
 /* point to the 2 curves */
   status = om$send (msg = message EMSassoc.ASreturn_go(&curve_GRid,
                                                     &cv_mat_type,
                                                     cv_matrix),
                mode = OM_e_wrt_message,
                targetid = curve_GRid.objid,
                targetos = curve_GRid.osnum);   
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);



   status = om$get_classid(
                     objid = parents->objid,
                     osnum = parents->osnum,
                     p_classid = &class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
   status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_ASsource_class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   if(status != 1) {

      status = om$send (msg = message EMSassoc.ASreturn_go(&org_GRid,
                                               &org_mat_type,
                                               org_matrix),
                mode = OM_e_wrt_message,
                targetid = parents->objid,
                targetos = parents->osnum);   
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    } else {
      status = om$send (msg = message ASsource.ASreturn_go(&org_GRid,
                                               &org_mat_type,
                                               org_matrix),
                mode = OM_e_wrt_message,
                targetid = parents->objid,
                targetos = parents->osnum);   
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    }



   donofcv = donorgcv = 0.0;

   if((me->offset_control & COMPOSITE) &&
      (me->offset_control & CLOSED)) {
    stat_OM = EMmake_chanselect(GRcmpowner_to_components,
                                &to_comps);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    object = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                                        sizeof(OM_S_OBJECT_LINKAGE));
    stat_OM = om$get_channel_objects(objid = curve_GRid.objid,
                                     osnum = curve_GRid.osnum,
                                     p_chanselect = &to_comps,
                                     list = object,
                                     size = (OMuint) 1,
                                     count = (OMuint *) &size);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &cv_mat_type,
                             cv_matrix,
                             stpt2, ept),
                       targetid = object->S_objid,
                       targetos = curve_GRid.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    donofcv = BSdistptpt(&rc, stpt1, ept);

    stat_OM = om$get_channel_objects(objid = org_GRid.objid,
                                     osnum = org_GRid.osnum,
                                     p_chanselect = &to_comps,
                                     list = object,
                                     size = (OMuint) 1,
                                     count = (OMuint *) &size);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &org_mat_type,
                             org_matrix,
                             stpt1, ept),
                       targetid = object->S_objid,
                       targetos = org_GRid.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    donorgcv = BSdistptpt(&rc, stpt1, ept);

  }
/*--------------------------------------------------------------------*/

   if(donofcv < donorgcv) {
       target.objid = curve_GRid.objid;
       target.osnum = curve_GRid.osnum;
       mat_type = cv_mat_type;
       matrix = cv_matrix;
   } else {
       target.objid = org_GRid.objid;
       target.osnum = org_GRid.osnum;
       mat_type = org_mat_type;
       matrix   = org_matrix;
   }
 
    /* get start point of one of the curves  */

    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &mat_type,
                             matrix,
                             stpt1, ept),
                       targetid = target.objid,
                       targetos = target.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

 /* derive plane normal and plane point from orientation plane */

    plane.point = (IGRdouble *) &plane_point[0];
    plane.normal = (IGRdouble *) &plane_normal[0];
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRdetplane(&msg_loc,
                             &plane_mat_type,
                             plane_matrix,
                             &plane),
                      targetid = plane_GRid.objid,
                      targetos = plane_GRid.osnum);
   EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);


   closest_crv_id = target.objid;
   stat_OM = om$send(msg = message GRcurve.GRgenabsg(
                            &msg_loc,
                            &mat_type,
                            matrix,
                            &generic_pointer),
                     targetid = closest_crv_id,
                     targetos = target.osnum);
   EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
             
   closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;

   BScveval(closest_crv_geom, 0.0, 1, cveval, &rc);
   if(rc != BSSUCC) {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

   BSnorvec(&rc, cveval[1]);

   BScrossp(&rc, cveval[1], plane.normal, crossp);
   if(rc != BSSUCC) {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }
   BSnorvec(&rc, crossp);

   if(me->offset_control & RIGHTSIDE)
    sign = 1.0;
   else
    sign = -1.0;

   if  (donofcv < donorgcv) 
     sign = sign * -1.0;

  
   BScrossp(&rc, crossp, plane.normal, crossp2);
   if(rc != BSSUCC) {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }
   BSnorvec(&rc, crossp2);

 /* build a matrix */
  dmatrix[3] = dimmatrix[7] = dimmatrix[11] = 0.0;
  dmatrix[0] = crossp[0];
  dmatrix[1] = crossp[1];
  dmatrix[2] = crossp[2];
  dmatrix[4] = crossp2[0];
  dmatrix[5] = crossp2[1];
  dmatrix[6] = crossp2[2];
  dmatrix[8] = plane.normal[0];
  dmatrix[9] = plane.normal[1];
  dmatrix[10] = plane.normal[2];
  dmatrix[12] = stpt1[0];
  dmatrix[13] = stpt1[1];
  dmatrix[14] = stpt1[2];
  dmatrix[15] = 1;


  return(status);


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
 IGRlong         status, stat_OM, rc, msg_loc;
 int EAsupp;
 IGRboolean      plane_found, value_found;
 IGRint action,i,j,num_parents, type, info_size;
 struct IGRpolyline py;
 IGRpoint pts_buff[5];
 OMuword         class_id;
 IGRdouble sign;
 IGRchar         *info = NULL;
 IGRchar 	 *generic_pointer = NULL;
 GRobjid 	 closest_crv_id;
 struct IGRbsp_curve 	        *closest_crv_geom = NULL;
 IGRpoint        cveval[2];
 IGRvector       crossp;
 IGRshort        mat_type,
                 org_mat_type, 
                 plane_mat_type, 
                 cv_mat_type;
 IGRdouble       offset_distance;
 IGRdouble       donofcv, donorgcv;
 IGRdouble       *matrix,
                 org_matrix[16], 
                 cv_matrix[16], 
                 plane_matrix[16];         
 IGRint          parvl_idx;
 IGRint          size;
 IGRpoint        plane_point, stpt1, stpt2, ept;
 IGRvector       plane_normal;
 struct GRid    *parents = NULL;
 OM_S_CHANSELECT to_comps;
 OM_S_OBJECT_LINKAGE *object = NULL;
 struct GRid     my_GRid,
                 org_GRid,
                 target, 
                 curve_GRid, 
                 dim_GRid,
                 plane_GRid;
 struct IGRplane plane;
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
 EAsupp = 222;
 pp_get_gacurve(&msg_loc, &my_GRid, &curve_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 dim_GRid.objid   = sender_id;
 dim_GRid.osnum   = sender_os;

 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, NULL,
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

 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, info,
                         &num_parents, parents);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 EMmake_chanselect(GRcmpowner_to_components, &to_components);

 action = 1;

 datpln_info = (struct EMSdatpln_planar_element_info *)info;

 /* determine offset control */

#if dflT1
 /* test what came in */
 printf("offset control flags = %d\n", me->offset_control);
 
#endif



 /* determine parent index of offset distance */
 /* determine ASsource parent index  */
 /* ASsource object could be the listener of a curve and/or plane 
    or reference plane */

 plane_found = FALSE;
 value_found = FALSE;
 EAsupp = 124;

 for(i=0, j=0; i<num_parents;i++) {
   status = om$get_classid(
                     objid = (parents + i)->objid,
                     osnum = (parents + i)->osnum,
                     p_classid = &class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 
   if(!plane_found) {
        status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSdatpln_class_id);
        EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
        if(status == OM_S_SUCCESS) {
           om$send (msg = message EMSassoc.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
           EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
           plane_found = TRUE; 
        } else { 
           status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSsurface_class_id);
           EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
           if(status == OM_S_SUCCESS) {
              om$send (msg = message EMSassoc.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
              EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
              plane_found = TRUE;
           } else {
              status = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_ASsource_class_id);
              EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
              if(status == OM_S_SUCCESS) {
                om$send (msg = message ASsource.ASreturn_go(&plane_GRid,
                                                     &plane_mat_type,
                                                     plane_matrix),
                  mode     = OM_e_wrt_message,
                  targetid = (parents + i)->objid,
                  targetos = (parents + i)->osnum);   
                EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
       
                status = om$get_classid(
                     objid = plane_GRid.objid,
                     osnum = plane_GRid.osnum,
                     p_classid = &class_id);
                EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
                status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSsurface_class_id);
                EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
                if(status == OM_S_SUCCESS)
                 plane_found = TRUE;
              }
          } 
      }      
   }
   if(!value_found) {
     status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSparamvl_class_id); 
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     if(status == OM_S_SUCCESS) {
          parvl_idx = i;
          value_found = TRUE;
     }
   }
 }
 EAsupp = 345;
 if(!(value_found && plane_found)) {
   status = 0;  
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }
 /* point to the 2 curves */
   status = om$send (msg = message EMSassoc.ASreturn_go(&curve_GRid,
                                                     &cv_mat_type,
                                                     cv_matrix),
                mode = OM_e_wrt_message,
                targetid = curve_GRid.objid,
                targetos = curve_GRid.osnum);   
   EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);


   status = om$get_classid(
                     objid = parents->objid,
                     osnum = parents->osnum,
                     p_classid = &class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
   status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_ASsource_class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);

   if(status != 1) {

      status = om$send (msg = message EMSassoc.ASreturn_go(&org_GRid,
                                               &org_mat_type,
                                               org_matrix),
                mode = OM_e_wrt_message,
                targetid = parents->objid,
                targetos = parents->osnum);   
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    } else {
      status = om$send (msg = message ASsource.ASreturn_go(&org_GRid,
                                               &org_mat_type,
                                               org_matrix),
                mode = OM_e_wrt_message,
                targetid = parents->objid,
                targetos = parents->osnum);   
      EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
    }

   EAsupp = 555;
   donofcv = donorgcv = 0.0;

   if((me->offset_control & CLOSED) &&
      (me->offset_control & COMPOSITE)) {
    stat_OM = EMmake_chanselect(GRcmpowner_to_components,
                                &to_comps);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    object = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                                        sizeof(OM_S_OBJECT_LINKAGE));
    stat_OM = om$get_channel_objects(objid = curve_GRid.objid,
                                     osnum = curve_GRid.osnum,
                                     p_chanselect = &to_comps,
                                     list = object,
                                     size = (OMuint) 1,
                                     count = (OMuint *) &size);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &cv_mat_type,
                             cv_matrix,
                             stpt1, ept),
                       targetid = object->S_objid,
                       targetos = curve_GRid.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);
    donofcv = BSdistptpt(&rc, stpt1, ept);
    
   
    stat_OM = om$get_channel_objects(objid = org_GRid.objid,
                                     osnum = org_GRid.osnum,
                                     p_chanselect = &to_comps,
                                     list = object,
                                     size = (OMuint) 1,
                                     count = (OMuint *) &size);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &org_mat_type,
                             org_matrix,
                             stpt1, ept),
                       targetid = object->S_objid,
                       targetos = org_GRid.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

    donorgcv = BSdistptpt(&rc,stpt1, ept);
   }

   if (donofcv < donorgcv) { 
       target.objid = curve_GRid.objid;
       target.osnum = curve_GRid.osnum;
       mat_type = cv_mat_type;
       matrix = cv_matrix;
   } else {
       target.objid = org_GRid.objid;
       target.osnum = org_GRid.osnum;
       mat_type = org_mat_type;
       matrix   = org_matrix;
   }
 
    /* get start point of one of the curves  */

    stat_OM = om$send( msg = message GRcurve.GRendpts(
                             &msg_loc,
                             &mat_type,
                             matrix,
                             stpt1, ept),
                       targetid = target.objid,
                       targetos = target.osnum);
    EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);

 /* derive plane normal and plane point from orientation plane */

    plane.point = (IGRdouble *) &plane_point[0];
    plane.normal = (IGRdouble *) &plane_normal[0];
    stat_OM = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRdetplane(&msg_loc,
                             &plane_mat_type,
                             plane_matrix,
                             &plane),
                      targetid = plane_GRid.objid,
                      targetos = plane_GRid.osnum);
   EMerr_hndlr(!(1&stat_OM), msg_loc, EMS_E_Fail, wrapup);


   closest_crv_id = target.objid;
   stat_OM = om$send(msg = message GRcurve.GRgenabsg(
                            &msg_loc,
                            &mat_type,
                            matrix,
                            &generic_pointer),
                     targetid = closest_crv_id,
                     targetos = target.osnum);
   EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);
             
   closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;
   EAsupp = 666;
   BScveval(closest_crv_geom, (IGRdouble) 0.0, 1, cveval, &rc);
   if(rc != BSSUCC) {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

   BSnorvec(&rc, cveval[1]);

   BScrossp(&rc, cveval[1], plane.normal, crossp);
   if(rc != BSSUCC) {
    *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

   BSnorvec(&rc, crossp);

   if(me->offset_control & RIGHTSIDE)
    sign = 1.0;
   else
    sign = -1.0;

   if (donofcv < donorgcv)
        sign = sign * -1.0;
   EAsupp =333;
   stat_OM = om$send (msg = message expression.NDgive_value(&offset_distance),
                      targetid = (parents + parvl_idx)->objid,
                      targetos = (parents + parvl_idx)->osnum);
   EMerr_hndlr(!(1&stat_OM), *EMmsg, EMS_E_Fail, wrapup);


   stpt2[0] = stpt1[0] + sign * offset_distance * crossp[0];
   stpt2[1] = stpt1[1] + sign * offset_distance * crossp[1];
   stpt2[2] = stpt1[2] + sign * offset_distance * crossp[2];
#if dflT1
   
   donofcv = BSdistptpt(&rc, stpt1, stpt2);
   printf("distance = %f\n", donofcv);
#endif
 /*switch (type)
 {
  case EMS_ASparallel_to_planar_element_new:
  case EMS_ASparallel_to_planar_element:
  {*/
    str->type = DMkeyseg;
    str->var.dm_keyseg.u_par = 0.0;


    OM_BLOCK_MOVE(stpt1,str->var.dm_keyseg.line,sizeof
          (IGRpoint));
    

    for (i=0;i<3;i++)
     str->var.dm_keyseg.line[3+i] = stpt2[i];
 /* }
  break;

 }*/

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

method NDupdate(int *msg, cn_type, count;
		   struct GRid *parents;
		   int * parent_state;
		   struct GRid *context,*new_objid;
		   struct GRmd_env *md_env)
{

 *msg = ND_COMP_SUCC;
 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;
 return (OM_S_SUCCESS);
}

end implementation EMSdimoff;

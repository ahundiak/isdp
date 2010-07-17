/*

  File           VLallMethod.I 
  Creation Date  November 92
  Auteur         Ghassan Jahmi

*/

class implementation VLallLinCmd;

#include <stdio.h>
#include <math.h>
#include "AS_status.h"
#include "coparamac.h"
#include "expmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "csmacros.h"
#include "lcdef.h"
#include "ex.h"
#include "expression.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vlmsg.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "nddef.h"
#include "madef.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"


from GRgraphics import GRdisplay;
from GRgraphics import GRdelete;
from GRvg import GRchgname;
from GRvg import GRgetname;
from GRvg import GRcenter;
from NDnode import NDget_objects;
from NDnode import NDchange_connect;
from NDnode import ASreturn_go;
from NDnode import NDchg_state;
from ACncpx import ACmplace;
from ACrg_collect import ACadd_list_attribute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import AClist_attribute;
from GRgraphics import GRaltconstruct;
from GRgencs import GRgetmatrix;
from GRvg import GRputsymb;

extern GRclassid OPP_VLbutLine_class_id;
extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_VLseaLine_class_id;
extern GRclassid OPP_VLwatLine_class_id;
extern GRclassid OPP_VLtrace_class_id;
extern GRclassid OPP_EMSsurface_class_id;
extern GRclassid OPP_GRgencs_class_id;
extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_ASsource_class_id;
extern struct GRid NULL_GRID;
extern double atof();
extern struct GRid MANwk_hull;
#define EPS 0.000001

void VLdispObj( obj,module,mode,code)
struct GRid 	*obj;
struct GRmd_env *module;
enum GRdpmode   *mode;
int		code;
{
int	loc_msg;
int	dim;
IGRlong	msg;
IGRshort	mat_type,mm_type;
IGRdouble	mat[16], *mm;
struct GRid buff;
IGRlong		status;

  if (code) {
    status = dp$erase_hilite(msg=&loc_msg,
                             objid = module->md_id.objid,
                             osnum = module->md_id.osnum);
  }
  buff = *obj;
  status = om$send(  msg = message NDnode.ASreturn_go
				(&buff,&mat_type,mat),
                        targetid = obj->objid,
		        targetos = obj->osnum,
			senderid = NULL_OBJID);
  if (mat_type != MAIDMX ) {
    if (module->md_env.matrix_type != MAIDMX ) {
      dim = 4;
      MAmulmx(&loc_msg,&dim,&dim,&dim,module->md_env.matrix, mat,mat);
      MAtypemx( &loc_msg, mat, &mat_type);
      mm = mat;
      mm_type = mat_type;
    }
    else {
      mm = mat;
      mm_type = mat_type;
    }
  }
  else {
    mm = module->md_env.matrix;
    mm_type = module->md_env.matrix_type;
  }
   status =
        om$send(msg = message GRgraphics.GRdisplay(
                             &msg,
                             &mm_type,
                             mm,
                             mode,
                             &module->md_id ),
               targetid = buff.objid,
               targetos = buff.osnum,
               senderid = NULL_OBJID);
          if (!(status & msg & 1))
            ex$message( msgnumb = VL_E_ERGrDisp );
}

/* convert between active and base coordinate */
VLconvertCoord(module,vect,wld,type)
struct GRmd_env *module;
IGRdouble	*vect,*wld;
int 		type;
{
struct GRid	act_cs;
IGRdouble	mat[16],inv_mat[16];
int 		loc_msg,four,one;
IGRlong		status, msg;

    /* get active cs */
    act_cs.osnum = module->md_id.osnum;
    status = cs$get_active_info(
	                        msg = &loc_msg,
	                        osnum = act_cs.osnum,
	                        module= module->md_id.objid,
	                        objid = &act_cs.objid);
      if (!(status&loc_msg&1)) {
        ex$message(msgnumb = VL_E_ConsTstFail);
        return 0;
      }
      /* get cs matrix */
      status = om$send(  msg = message GRgencs.GRgetmatrix( &msg, mat ),
                              targetid = act_cs.objid,
                              targetos = act_cs.osnum,
                              senderid = NULL_OBJID);
      if (!(status&msg&1)) {
        ex$message(msgnumb = VL_E_ConsTstFail);
        return 0;
      }
      four = 4; one = 1;
      if (type == 1) { /* base to active conversion */
        MAinvmx( &loc_msg, &four, mat, inv_mat );
        if (!(loc_msg&1)) {
          ex$message(msgnumb = VL_E_ConsTstFail);
          return 0;
        }
        MAmulmx( &loc_msg, &four, &four, &one, inv_mat, vect, wld );
      }
      else 
        MAmulmx( &loc_msg, &four, &four, &one, mat, vect, wld );

      if (!(loc_msg&1)) {
        ex$message(msgnumb = VL_E_ConsTstFail);
        return 0;
      }
      if (wld[3] > EPS || wld[3] < -EPS) {
        wld[0] = wld[0]/wld[3];
        wld[1] = wld[1]/wld[3];
        wld[2] = wld[2]/wld[3];
        wld[3] = 1;
      }
  return 1;
}

/* get the object name */
VLgetName(obj,pt_name)
struct GRid *obj;
char *pt_name;
{
char name[100];
IGRlong  loc_msg,status;
int j;
IGRshort	mat_type;
IGRdouble	mat[16];
struct GRid buff;
GRclassid	cid;

  buff = *obj;
  om$get_classid(osnum = obj->osnum,
                 objid = obj->objid,
                 p_classid = &cid);
  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_ASsource_class_id )
             == OM_S_SUCCESS ) {
    status = om$send(  msg = message NDnode.ASreturn_go
				  (&buff,&mat_type,mat),
                          targetid = obj->objid,
		          targetos = obj->osnum,
			  senderid = NULL_OBJID);
  }
  status = om$send(msg = message GRvg.GRgetname(&loc_msg,name),
                   targetid = buff.objid,
                   targetos = buff.osnum,
		   senderid = NULL_OBJID);
  if(!(status & loc_msg & 1)) return 0;
  else {
    /* just the name, without path */
    for(j = strlen(name)-1;name[j] != ':'; j--);
    strcpy(pt_name,name+j+1);
    return 1;
  }
}

  /* test the object class */
VLnameTest(obj,cs)
struct GRid	*obj;
struct GRid	*cs;
{
GRclassid	cid;

  om$get_classid(osnum = obj->osnum,
                 objid = obj->objid,
                 p_classid = &cid);

  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GRgencs_class_id )
             == OM_S_SUCCESS ) {
    *cs = *obj; 
    return 2;
  }
  else { 
    if (om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_GR3dpoint_class_id )
               == OM_S_SUCCESS ) {
      *cs = *obj;
      return 1;
    }
    else {
      if (om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_GR3dlineseg_class_id )
                 == OM_S_SUCCESS ) {
        *cs = *obj;
        return 2;
      }
     }
   }
  return 0;
}

 /* test the object class and construct a vector */ 
VLname2Test (obj,cs,module)
struct GRid     *obj,*cs;
struct GRmd_env *module;
{
GRclassid	cid;

  om$get_classid(osnum = obj->osnum,
                 objid = obj->objid,
                 p_classid = &cid);

  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GR3dpoint_class_id )
             != OM_S_SUCCESS ) {
    ex$message(msgnumb = VL_E_BadObj);
    return 0;
  }
  if (!VLgetVector( cs,obj,NULL,NULL,module,cs)) {
    ex$message(msgnumb = VL_E_ConsCsFail);
    return 0;
  }
  return 1;
}

VLtestExp(obj,array,module)
struct GRid	*obj;
char		*array;
struct GRmd_env	*module;
{

  obj->objid = NULL_OBJID;
  vds$translate (objname = array,
                 p_objid = &obj->objid,
                 p_osnum = &obj->osnum );
  if (obj->objid == NULL_OBJID) {
    ex$message(msgnumb = VL_E_BadObj);
    return 0;
  }
  if (obj->osnum != module->md_id.osnum ) {
    ex$message(msgnumb = VL_E_ObjOutCurr);
    return 0;
  }
  return 1;
}

 /* from two points or IDs, it make a vector  */
VLgetVector (point,point1,pt,pt1,mod_info,obj_res)
struct GRid	*point,*point1;
IGRdouble       *pt,*pt1;
struct GRmd_env *mod_info;
struct GRid	*obj_res;
{
IGRpoint	pnt1,pnt2;
IGRlong 	loc_msg,status;
IGRdouble	       vect[3],tmp;
struct GRvg_construct  cst;
struct IGRpolyline    geom;

  if (pt == NULL) {
    status = om$send(msg = message GRvg.GRcenter(&loc_msg, 
                                           &mod_info->md_env.matrix_type,
                                           mod_info->md_env.matrix,
					   pnt1),
		          targetid = point->objid,
		          targetos = point->osnum,
		          senderid = NULL_OBJID);
    if (!(status&loc_msg&1)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      return 0;
    }
  }
  else {
    pnt1[0] = pt[0]; pnt1[1] = pt[1]; pnt1[2] = pt[2];
  }
  if (pt1 == NULL) {
    status = om$send(msg = message GRvg.GRcenter(&loc_msg, 
                                           &mod_info->md_env.matrix_type,
                                           mod_info->md_env.matrix,
					   pnt2),
		          targetid = point1->objid,
		          targetos = point1->osnum,
		          senderid = NULL_OBJID);
    if (!(status&loc_msg&1)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      return 0;
    }
  }
  else {
    pnt2[0] = pt1[0]; pnt2[1] = pt1[1]; pnt2[2] = pt1[2];
  }
  vect[0] = pnt2[0] - pnt1[0];
  vect[1] = pnt2[1] - pnt1[1];
  vect[2] = pnt2[2] - pnt1[2];
  tmp = sqrt(vect[0]*vect[0] + vect[1]*vect[1] + vect[2]*vect[2]);
  if (tmp > EPS) {
    vect[0] = vect[0]/tmp;
    vect[1] = vect[1]/tmp;
    vect[2] = vect[2]/tmp;
  }
  /* construct an object to contain this vector */
  VLinitCnst(&cst);
  cst.env_info	= mod_info;
  cst.properties	&=  ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
  geom.num_points = 1;
  geom.points     = vect;
  cst.geometry = (char *)&geom;

  obj_res->osnum = mod_info->md_id.osnum;
  status = om$construct( classid = OPP_GR3dpoint_class_id,
                         osnum   = obj_res->osnum,
                         p_objid = &obj_res->objid );
  if (!(status&1)) {
    ex$message(msgnumb = VL_E_ConsCsFail);
    return 0;
  }
  status = om$send( msg = message GRgraphics.GRaltconstruct(&cst),
                    targetid = obj_res->objid,
                    targetos = obj_res->osnum,
		    senderid = NULL_OBJID);
   if(!(status & 1))
    {
     ex$message(msgnumb = VL_E_ConsCsFail);
     return 0;
    }
  return 1;
}

method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
int		 loc_msg,rep;
IGRlong 	 status, msg;
int   		 i;
char   		 array[200];
struct GRid 	 tmp;
GRclassid	 cid;
IGRdouble	 val = 100;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message VLallLinCmd.VLsave_all(&msg),
 		       targetid = my_id);
     
      if(!(status & msg & 1))
      { 
	FIg_set_state_off(me->form_ptr,FI_ACCEPT);
        ex$message( msgnumb = VL_E_BadPlc);
	goto quit;
      }
      _put_response(resp = TERMINATE);
      break;
    
    case FI_EXECUTE : 
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_DATA);
        me->locate_prev = 0;
      }
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      
      status = om$send(msg = message VLallLinCmd.VLsave_all(&msg),
		       targetid = my_id);
     
      if(!(status & msg & 1))
      { 
        FIg_set_state_off(me->form_ptr,FI_EXECUTE);
        ex$message( msgnumb = VL_E_BadPlc);
	goto quit;
      }
      FIg_set_state_off(me->form_ptr,FI_EXECUTE);
      _put_response(resp = RET_INFO);
      break;

    case FI_CANCEL: 
      _put_response(resp = TERMINATE);
      break;
     
    case FI_RESET: 
     if (me->mytype == 1 || me->mytype == 8 || 
         me->mytype == 5 || me->mytype == 11) {
       FIg_erase(me->form_ptr,G_ALLOWENCE);
       FIg_erase(me->form_ptr,G_ALLOW_DIR);
       FIg_erase(me->form_ptr,G_EXTRA_ALLOW);
       FIg_erase(me->form_ptr,G_EXTRA_TXT);
       FIg_erase(me->form_ptr,G_ALLOW_TXT);
       FIg_erase(me->form_ptr,G_VALUE_TXT);
       FIg_erase(me->form_ptr,G_ALLOW_DIR_TXT);
     }
      me->cs = me->old_cs;
      me->hull = me->old_hull;
      me->pt_select = me->old_pt_select;
      me->allow_dir = me->old_allow_dir;
      me->point2 = me->old_point2;
      if (me->old_nb_info > om$dimension_of(varray = me->info))
      om$vla_set_dimension(varray = me->info,size = me->old_nb_info);
      me->nb_info = me->old_nb_info;
      for (i=0; i<me->old_nb_info; i++)
        me->info[i] = me->old_info[i];
        me->to_modify = me->old_to_modify;
      FIg_set_state_off(me->form_ptr,FI_RESET);

      FIfld_set_text( me->form_ptr, G_DATA_NAME,   0, 0, "", FALSE );
      FIfld_set_text( me->form_ptr, G_BUTT_NAME,   0, 0, "", FALSE );
      FIfld_set_text( me->form_ptr, G_SEL_PT_NAME, 0, 0, "", FALSE );
      FIfld_set_text( me->form_ptr, G_HULL_NAME,   0, 0, "", FALSE );
      FIfld_set_text( me->form_ptr, G_ALLOWENCE,   0, 0, "", FALSE );
      FIfld_set_text( me->form_ptr, G_EXTRA_ALLOW, 0, 0, "", FALSE );

      _put_response(resp = RESET_ALL);

      break;
    
     case G_SELECT_PT:
      if (me->locate_pt_select) {
        FIg_set_state_on(me->form_ptr,G_SELECT_PT);
      }
      else me->locate_pt_select = 1;
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_DATA);
        me->locate_prev = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      
      om$get_classid(osnum = me->pt_select.osnum,
                     objid = me->pt_select.objid,
                     p_classid = &cid);
      if ((om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_expression_class_id )
                 != OM_S_SUCCESS)) {
        me->DisplayMode = GRhd;
	VLdispObj(&me->pt_select,&me->ModuleInfo,&me->DisplayMode,1);
      }
      _put_response(resp = SEL_PT);
      break;

     case G_SEL_PT_NAME :
       FIg_get_text(me->form_ptr,G_SEL_PT_NAME,array); 
       if (!strcmp(array,"No")) {

              // we recreate plugs because of problems in ASSOC : the
              // original plug is dead after two disconnect and connect.
           exp$create(exp_name = NULL,
                      exp_syntax = "PLUG",
                      p_exp_id = &me->pt_plug.objid,
                      osnum = me->pt_plug.osnum,
                      type_rq = EXP_TEXT);
           om$send( msg  = message NDnode.NDchg_state
                                                 (ND_DEL_NO_CH, ND_DEL_NO_CH),
           			targetid = me->pt_plug.objid,
           			targetos = me->pt_plug.osnum );
	 me->pt_select = me->pt_plug;
         break;
       }
       vds$translate (objname = array,
                      p_objid = &tmp.objid,
                      p_osnum = &tmp.osnum );
       if( tmp.objid == NULL_OBJID ) {
         FIg_set_text(me->form_ptr,G_SEL_PT_NAME,""); 
         ex$message( msgnumb = VL_E_InvName , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         goto quit;
       }
       if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
         ex$message( msgnumb = VL_E_ObjOutCurr , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_SEL_PT_NAME,"");
         goto quit;
       }
       me->DisplayMode = GRhd;
       VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);

       om$get_classid(osnum = tmp.osnum,
                      objid = tmp.objid,
                      p_classid = &cid);
     
       as$make_source( go_grid = tmp,
                       as_os   =me->ModuleInfo.md_id.osnum ,
                       as_grid = &tmp);

       if (
           (om$is_ancestry_valid(subclassid     = cid,
                                superclassid = OPP_GR3dpoint_class_id )
                  == OM_S_SUCCESS ) 
          ){
          me->pt_select.objid = tmp.objid;
          me->pt_select.osnum = tmp.osnum;
       }
       else {
         ex$message( msgnumb = VL_E_BadObj , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_SEL_PT_NAME,"");
         goto quit;
       }
       break;

     case G_DATA:
      if (me->locate_prev) {
        FIg_set_state_on(me->form_ptr,G_DATA);
      }
      else me->locate_prev = 1;
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      
      for (i=0;i<me->nb_info;i++) {
      om$get_classid(osnum = me->info[i].osnum,
                     objid = me->info[i].objid,
                     p_classid = &cid);
      if ((om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_expression_class_id )
                 != OM_S_SUCCESS) && me->info[i].objid != NULL_OBJID) {
       me->DisplayMode = GRhd;
       if (me->nb_info > 1)
         VLdispObj(&me->info[i],&me->ModuleInfo,&me->DisplayMode,0);
       else
         VLdispObj(&me->info[i],&me->ModuleInfo,&me->DisplayMode,1);
      }
      }
      _put_response(resp = INFO_D);
      break;

     case G_DATA_NAME :
       FIg_get_text(me->form_ptr,G_DATA_NAME,array); 
       vds$translate (objname = array,
                      p_objid = &tmp.objid,
                      p_osnum = &tmp.osnum );
       val = atof(array);
       if( tmp.objid == NULL_OBJID && !val) {
         FIg_set_text(me->form_ptr,G_DATA_NAME,""); 
         ex$message( msgnumb = VL_E_InvName , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         goto quit;
       }
       if (tmp.osnum != me->ModuleInfo.md_id.osnum && !val) {
         ex$message( msgnumb = VL_E_ObjOutCurr , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_DATA_NAME,"");
         goto quit;
       }
       if (1 > om$dimension_of(varray = me->info))
         om$vla_set_dimension(varray = me->info,size = 1);
       if (val) {
         status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                                    unit_type = GRIO_DISTANCE,
                                    osnum     = me->ModuleInfo.md_id.osnum,
                                    primary = val,
                                    result  = &val);
         me->info[0].osnum = me->ModuleInfo.md_id.osnum;
         exp$create(exp_name = NULL,
                        exp_value = val,
                        p_exp_id = &me->info[0].objid,
                        osnum = me->info[0].osnum);
	 om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
		  targetid = me->info[0].objid,
		  targetos = me->info[0].osnum );
         me->nb_info = 1;
         goto quit;
       }
         
         om$get_classid(osnum = tmp.osnum,
                        objid = tmp.objid,
                        p_classid = &cid);
       if (om$is_ancestry_valid(subclassid     = cid,
                              superclassid = OPP_expression_class_id )
                == OM_S_SUCCESS ) {
         me->info[0] = tmp;
         me->nb_info = 1;
       }
       else {
         me->DisplayMode = GRhd;
         VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);

         if (
           (om$is_ancestry_valid(subclassid     = cid,
                                superclassid = OPP_EMSplane_class_id )
                  == OM_S_SUCCESS ) ||
           (om$is_ancestry_valid(subclassid     = cid,
                                superclassid = OPP_EMSsurface_class_id )
                  == OM_S_SUCCESS ) ||
           (om$is_ancestry_valid(subclassid     = cid,
                                superclassid = OPP_GRbspline_class_id )
                  == OM_S_SUCCESS )
          ){
            as$make_source( go_grid = tmp,
                            as_os   =me->ModuleInfo.md_id.osnum ,
                            as_grid = &tmp);
            me->info[0].objid = tmp.objid;
            me->info[0].osnum = tmp.osnum;
            me->nb_info = 1;
         }
       else {
         ex$message( msgnumb = VL_E_BadObj , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_DATA_NAME,"");
         goto quit;
       }
     }
       break;

     case G_CS :
     case G_ALLOW_DIR :
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_DATA);
        me->locate_prev = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      me->DisplayMode = GRhd;
      if (gadget_label == G_CS) {
        me->vect = &me->cs;
        if (!(rep=VLreadDirect (&me->cs,gadget_label,form_ptr,&me->ModuleInfo,
			  &me->DisplayMode,&me->point2,&my_id)))
          goto quit;
        switch (rep) {
          case 2 : _put_response(resp = CS);
                   break;
          case 3 : _put_response(resp = POINT); /* locate second point */
                   break;
          case 4 : _put_response(resp = MOD); /*return to modify_form state */
        }
      }
      else {
        me->vect = &me->allow_dir;
        if (!(rep=VLreadDirect (&me->allow_dir,gadget_label,form_ptr,
                               &me->ModuleInfo, &me->DisplayMode,
			       &me->point2,&my_id)))
          goto quit;
        switch (rep) {
          case 2 : _put_response(resp = ALLOWDIR);
                   break;
          case 3 : _put_response(resp = POINT); /* locate second point */
                   break;
          case 4 : _put_response(resp = MOD); /*return to modify_form state */
        }
      }
      break;

     case G_HULL:
      if (me->locate_hull) {
        FIg_set_state_on(me->form_ptr,G_HULL);
      }
      else me->locate_hull = 1;
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_DATA);
        me->locate_prev = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->hull.objid != NULL_OBJID) {
        me->DisplayMode = GRhd;
        VLdispObj(&me->hull,&me->ModuleInfo,&me->DisplayMode,1);
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      _put_response(resp = HULL);
      break;

     case G_HULL_NAME :
       FIg_get_text(me->form_ptr,G_HULL_NAME,array); 
       vds$translate (objname = array,
                      p_objid = &tmp.objid,
                      p_osnum = &tmp.osnum );
       if( tmp.objid == NULL_OBJID ) {
         ex$message( msgnumb = VL_E_InvName , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_HULL_NAME,"");
         goto quit;
       }
       if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
         ex$message( msgnumb = VL_E_ObjOutCurr , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_HULL_NAME,"");
         goto quit;
       }
       me->hull = tmp;
       me->DisplayMode = GRhd;
       VLdispObj(&me->hull,&me->ModuleInfo,&me->DisplayMode,1);
       as$make_source( go_grid = me->hull,
                       as_os   =me->ModuleInfo.md_id.osnum ,
                       as_grid = &me->hull);
       break;

     case G_MODIF :
      if (me->locate_modif) {
        FIg_set_state_on(me->form_ptr,G_MODIF);
      }
      else me->locate_modif = 1;
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_DATA);
        me->locate_prev = 0;
      }
      me->DisplayMode = GRhd;
        if (me->to_modify.objid != NULL_OBJID)
          VLdispObj(&me->to_modify,&me->ModuleInfo,&me->DisplayMode,1);

        if (me->mytype == 6 || me->mytype == 9) {_put_response(resp = MOD1_D);}
        else {
          if (me->mytype == 7 || me->mytype == 10){_put_response(resp = MOD2_D);}
          else {
            if (me->mytype == 8) {_put_response(resp = MOD3_D);}
            else {
               if (me->mytype == 11) {_put_response(resp = MOD4_D);}
            }
          }
        }
        break;
   }

 quit:
  return OM_S_SUCCESS;
}

method VLsave_all ( int *msg )
{
IGRlong		status=0,loc_msg=0;
IGRint		suc;
IGRdouble	allo=0,ext_allo=0;
struct GRid	butt,roots[40],buff;
int		r_pos,counter;
char		tmp[200],all[100],ext_all[100],cur_name[100];
char		pt_name[100];
IGRboolean 	put_batch = FALSE;
GRclassid	cid;
struct ACrg_coll ACrg[4];
IGRshort	mat_type;
IGRdouble	mat[16];
IGRchar		arr1[100],arr2[100];
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRint			b_mod;
enum	GRdpmode	dpmode=GRbd;

  /* Retrieve parameters in the form and control they are OK */

  *msg = MSFAIL;

  FIg_get_text(me->form_ptr,G_ALLOWENCE,all);
  if (strcmp(all,"No"))
    sscanf(all,"%lf",&allo);
  FIg_get_text(me->form_ptr,G_EXTRA_ALLOW,ext_all);
  if (strcmp(ext_all,"No"))
  sscanf(ext_all,"%lf",&ext_allo);

  if (allo) {
    status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                               unit_type = GRIO_DISTANCE,
                               osnum     = me->ModuleInfo.md_id.osnum,
                               primary = allo,
                               result  = &allo);
    if(!(status & loc_msg & 1)) {
      ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
      FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
      goto quit;
    }
  }
  if (ext_allo) {
    status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                               unit_type = GRIO_DISTANCE,
                               osnum     = me->ModuleInfo.md_id.osnum,
                               primary = ext_allo,
                               result  = &ext_allo);
    if(!(status & loc_msg & 1)) {
      ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
      FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
      goto quit;
    }
  }

  if (
      allo< 0 || ext_allo < 0 || me->hull.objid == NULL_OBJID||me->nb_info == 0 
      || (me->mytype >=6 && me->to_modify.objid == NULL_OBJID) 
     ) {
    ex$message( msgnumb = VL_E_InvParam, buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }

  switch (me->mytype) {
    case 0:
      strcpy(arr1,"butt");
      strcpy(arr2,"BButt");
      break;
    case 1 :
      strcpy(arr1,"watline");
      strcpy(arr2,"WaterL");
      break;
    case 2 :
      strcpy(arr1,"seam");
      strcpy(arr2,"BSeam");
      break;
    case 3 :
      strcpy(arr1,"butt");
      strcpy(arr2,"CButt");
    break;
    case 4 :
      strcpy(arr1,"seam");
      strcpy(arr2,"CSeam");
      break;
    case 5 :
      strcpy(arr1,"trace");
      strcpy(arr2,"Trace");
      break;
   }

  FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
  if ( cur_name[0] == '\0' ) strcpy( cur_name, arr2 );

  om$get_classid(osnum = me->allow_dir.osnum,
                 objid = me->allow_dir.objid,
                 p_classid = &cid);
  if (
      (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_expression_class_id )
             == OM_S_SUCCESS && allo > 0)
     ) {
    ex$message( msgnumb = VL_E_AllDirNeed, buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }

  if (me->mytype >= 6) {
        if (me->allow_dir.objid != me->old_allow_dir.objid  ||
            me->allow_dir.osnum != me->old_allow_dir.osnum ){
        status = om$send(msg = message NDnode.NDchange_connect
                        (1,&me->old_allow_dir,&me->allow_dir),
                        targetid = me->to_modify.objid,
		        targetos = me->to_modify.osnum);
        if(!(status & 1)) {
          ex$message(msgnumb = VL_E_PbsModPar);
          goto quit;
        } 
        put_batch = TRUE;
      me->old_allow_dir = me->allow_dir;
    }
        if (me->cs.objid != me->old_cs.objid ||
                 me->cs.osnum != me->old_cs.osnum ){
        status = om$send(msg = message NDnode.NDchange_connect
                        (1,&me->old_cs,&me->cs),
                        targetid = me->to_modify.objid,
		        targetos = me->to_modify.osnum);
        if(!(status & 1)) {
          ex$message(msgnumb = VL_E_PbsModPar);
          goto quit;
        } 
        put_batch = TRUE;
      me->old_cs = me->cs;
    }

      if (me->old_info[0].objid != me->info[0].objid ||
              me->old_info[0].osnum != me->info[0].osnum) {
      status = om$send(msg = message NDnode.NDchange_connect
                      (1,&me->old_info[0],&me->info[0]),
                      targetid = me->to_modify.objid,
		      targetos = me->to_modify.osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_PbsModPar);
        goto quit;
      } 
      put_batch = TRUE;
      me->old_info[0] = me->info[0];
    }
        if (me->pt_select.objid != me->old_pt_select.objid ||
             me->pt_select.osnum != me->old_pt_select.osnum ){
        status = om$send(msg = message NDnode.NDchange_connect
                        (1,&me->old_pt_select,&me->pt_select),
                        targetid = me->to_modify.objid,
		        targetos = me->to_modify.osnum);
        if(!(status & 1)) {
          ex$message(msgnumb = VL_E_PbsModPar);
          goto quit;
        } 
        put_batch = TRUE;
      me->old_pt_select = me->pt_select;
    }

    if (me->hull.objid != me->old_hull.objid
        || me->hull.osnum != me->old_hull.osnum ){
      status = om$send(msg = message NDnode.NDchange_connect
                      (1,&me->old_hull,&me->hull),
                      targetid = me->to_modify.objid,
		      targetos = me->to_modify.osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_PbsModPar);
        goto quit;
      } 
      put_batch = TRUE;
      me->old_hull = me->hull;
    }
    if (
        me->allowence != allo || me->ext_allow != ext_allo
       ) {
      counter = 0;
        strcpy(ACrg[counter].name,N_ATT_SELECTOR);
        ACrg[counter].desc.type = AC_ATTRIB_DOUBLE;
        if (me->mytype==6 || me->mytype == 7 || 
            me->mytype == 8 || me->mytype == 11)
          ACrg[counter].desc.value.att_exp = V_ATT_BASE;
        else
          ACrg[counter].desc.value.att_exp = V_ATT_CURVED;
        counter++;
      if (allo) {
        strcpy(ACrg[counter].name,N_ATT_AL_VAL);
        ACrg[counter].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[counter].desc.value.att_exp = allo;
        counter++;
      } 
      if (ext_allo) {
        strcpy(ACrg[counter].name,N_ATT_EXTRA_AL);
        ACrg[counter].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[counter].desc.value.att_exp = ext_allo;
        counter++;
      } 

      status = om$send(msg = message ACrg_collect.ACset_list_attribute
                                      (&loc_msg,counter,ACrg ),
			targetid = me->box.objid,
			targetos = me->box.osnum);
      if (!(status&loc_msg&1)) {
        ex$message( msgnumb = VL_E_InvColl , buff = tmp);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
      }
      put_batch = TRUE; 
      me->allowence = allo;
      me->ext_allow = ext_allo;
    }
    FIg_get_text(me->form_ptr,G_BUTT_NAME,tmp);
    if(!VLgetName(&me->to_modify, pt_name)) {
      if (strcmp(tmp,"Defined")) {
	status = om$send(msg	= message VLgenLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						tmp,
						arr1,
						&me->hull, 
						me->to_modify,
						&dpmode),
			targetid = my_id );
       if(!(status & loc_msg & 1))
         ex$message(msgnumb = VL_E_BadChgName);
      }
    }
    else {
      if (strcmp(pt_name,tmp)) {
	status = om$send(msg	= message VLgenLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						tmp,
						arr1,
						&me->hull, 
						me->to_modify,
						&dpmode),
			targetid = my_id );
       if(!(status & loc_msg & 1))
         ex$message(msgnumb = VL_E_BadChgName);
      }
    }
    if(put_batch) {
      IGRint  cn_type;
      struct GRid my_grid;
   
      my_grid.objid = me->to_modify.objid;
      my_grid.osnum = me->to_modify.osnum;

      cn_type    = ND_COMP; /* recompute the object */
      status = nd$wait_batch(type        = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &my_grid,
                             l_obj_info  = &cn_type );

       nd$mod_batch(request     = ND_INQ,
                    p_ret_mode  = &b_mod );

	if( b_mod != ND_DEFER ){
 	     ex$message(msgnumb = VL_E_ModLine);
	      nd$exec_batch();
	}
   
      ex$message(msgnumb = VL_E_LineMod);
    }
  }
  else {
    if (me->nb_info == 1) {
    om$get_classid(osnum = me->info[0].osnum,
                   objid = me->info[0].objid,
                   p_classid = &cid);
    if ((om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_expression_class_id )
               == OM_S_SUCCESS )) {
      status = om$send(  msg = message NDnode.ASreturn_go
					(&buff,&mat_type,mat),
                         targetid = me->cs.objid,
		         targetos = me->cs.osnum);
      if (!(status&1)) {
        ex$message(msgnumb = VL_E_ConsCsFail);
        goto quit;
      }
      om$get_classid(osnum = buff.osnum,
                     objid = buff.objid,
                     p_classid = &cid);
      if ((om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_GRgencs_class_id )
                 != OM_S_SUCCESS )) {
        ex$message( msgnumb = VL_E_NeedCS, buff = tmp);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
        goto quit;
      }
    }
    }

  /* Construct ACrg_collection */
  r_pos = 0;
  strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
  ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
  if (me->mytype == 3 || me->mytype == 4)
    ACrg[r_pos].desc.value.att_exp = V_ATT_CURVED;
  else
    ACrg[r_pos].desc.value.att_exp = V_ATT_BASE;
  r_pos++;
  if (allo) {
    strcpy(ACrg[r_pos].name,N_ATT_AL_VAL);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = allo;
    r_pos++;
  }
  if (ext_allo) {
    strcpy(ACrg[r_pos].name,N_ATT_EXTRA_AL);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = ext_allo;
    r_pos++;
  }

  roots[INDEX_ATT_BOX].osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
                        osnum   = roots[INDEX_ATT_BOX].osnum,
                        p_objid = &roots[INDEX_ATT_BOX].objid);
  om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
	   targetid = roots[INDEX_ATT_BOX].objid,
	   targetos = roots[INDEX_ATT_BOX].osnum );
  if(!(status & 1)) {
    ex$message( msgnumb = VL_E_InvColl , buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }
  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&loc_msg, r_pos, ACrg),
                   targetid = roots[INDEX_ATT_BOX].objid,
                   targetos = roots[INDEX_ATT_BOX].osnum);
  if(!(status & loc_msg & 1)) {
    ex$message( msgnumb = VL_E_InvColl , buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }

  roots[INDEX_HULL]           = me->hull;
  roots[INDEX_CS]             = me->cs;
  roots[INDEX_PT_SELECT]      = me->pt_select;
  roots[INDEX_AL_CS]          = me->allow_dir;

    butt.osnum = me->ModuleInfo.md_id.osnum;
    switch (me->mytype) {
    case 0 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    status = om$construct( classid = OPP_VLbutLine_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    ex$message(msgnumb = VL_E_ButtCreat);
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc,
					  AChdr_noprotect | AChdr_nodisplay, 0,
                                          BUTT_DEF_1,
                                          INDEX_START_CL,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }

    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_ButtCreated);

    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
   }
    break;
    case 1 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    status = om$construct( classid = OPP_VLwatLine_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    ex$message(msgnumb = VL_E_WaterLCreat);
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc, 
					 AChdr_noprotect | AChdr_nodisplay, 0,
                                          WatLine_DEF_1,
                                          INDEX_START_CL,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }
    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_WaterLCreated);
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
    }
    break;
    case 2 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    ex$message(msgnumb = VL_E_SeamCreat);
    status = om$construct( classid = OPP_VLseaLine_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc,
					  AChdr_noprotect | AChdr_nodisplay, 0,
                                          SEAM_DEF_1,
                                          INDEX_START_CL,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }
    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_SeamCreated);
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
    }
    break;
    case 3 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    ex$message(msgnumb = VL_E_CurvButtCreat);
    status = om$construct( classid = OPP_VLbutLine_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc,
					  AChdr_noprotect | AChdr_nodisplay, 0,
                                          BUTT_DEF_4,
                                          INDEX_START_CL,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }
    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_CurvButtCreated);
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
    }
    break;
    case 4 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    ex$message(msgnumb = VL_E_CurvSeamCreat);
    status = om$construct( classid = OPP_VLseaLine_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc,
					  AChdr_noprotect | AChdr_nodisplay, 0,
                                          SEAM_DEF_4,
                                          INDEX_START_CL,
                                          roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }
    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_CurvSeamCreated);
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
    }
    break;

    case 5 :
    for (r_pos=0;r_pos < me->nb_info; r_pos++)
    {
    roots[INDEX_GR_INFO]        = me->info[r_pos];
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    status = om$construct( classid = OPP_VLtrace_class_id,
                           osnum   = butt.osnum,
                           p_objid = &butt.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
    ex$message(msgnumb = VL_E_TraceElem);
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc, 
					 AChdr_noprotect | AChdr_nodisplay, 0,
                                          TRACE_DEF_4,
                                          INDEX_START_CL,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = butt.objid,
                          targetos = butt.osnum );
    if (!(status & suc & 1)) {
        ex$message( msgnumb = VL_E_BadPlc );
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = butt.objid,
                targetos = butt.osnum );
        goto quit;
    }
    status = om$send(msg	= message VLallLinCmd.VLsetSymbNameDisp(
						&loc_msg,
						pt_name,
						arr1,
						&me->hull, 
						butt,
						&dpmode),
			targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message(msgnumb = VL_E_BadChgName);
    ex$message(msgnumb = VL_E_TracedElem);
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                         targetid = my_id);
       if (!(status&loc_msg&1))
         ex$message(msgnumb = VL_E_BadChgSymb);
       FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                      0, pt_name,FALSE);
    }
    break;
  }
  /* prepare a default name for the next butt */
    status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           arr1,
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                      targetid = my_id);
    if (!(status&loc_msg&1))
      ex$message(msgnumb = VL_E_BadChgSymb);
      FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,0, pt_name,FALSE);
  }
  /* set defaults used by RESET */
  if (me->nb_info == 1) {
    FIg_get_text(me->form_ptr,G_BUTT_NAME,tmp); 
    FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,
                           0,0,tmp,0,0);
    }
  FIg_get_text(me->form_ptr,G_DATA_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_DATA_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_HULL_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_HULL_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_SEL_PT_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_ALLOW_DIR,tmp); 
  FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_CS,tmp); 
  FIfld_set_default_text(me->form_ptr,G_CS,
                         0,0,tmp,0,0);
  FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,
                         0,0,all,0,0);
  FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,
                         0,0,ext_all,0,0);
  if (me->nb_info > om$dimension_of(varray = me->old_info))
    om$vla_set_dimension(varray = me->old_info,size = me->nb_info);
  me->old_nb_info = me->nb_info;
  for (r_pos=0; r_pos<me->nb_info; r_pos++)
    me->old_info[r_pos] = me->info[r_pos];
    me->old_to_modify = me->to_modify;
  me->old_cs = me->cs;
  MANwk_hull = me->old_hull = me->hull;
  me->old_pt_select = me->pt_select;
  me->old_allow_dir = me->allow_dir;
  me->old_point2 = me->point2;

    *msg = MSSUCC;
  quit :
  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
    return OM_S_SUCCESS;
}

method VLcontrol_info (int *sts)
{
struct GRobj_env	*LocatedObjects;
int 			nb_obj,loc_msg,j;
GRclassid		cid;
char			pt_name[50],array[100];
IGRlong			status;


  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc);
    goto quit;
  }

  /* Verify the located object classes are good to avoid
    errors caused by locating objects by name */

  if(nb_obj > om$dimension_of( varray = me->info))
    om$vla_set_dimension(varray = me->info,size = nb_obj);
    for (j=0;j<nb_obj;j++) 
    {
      om$get_classid(osnum = LocatedObjects[j].obj_id.osnum,
                   objid = LocatedObjects[j].obj_id.objid,
                   p_classid = &cid);
      if (
        (om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_EMSplane_class_id )
               == OM_S_SUCCESS ) ||
        (om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_EMSsurface_class_id )
               == OM_S_SUCCESS ) ||
        (om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_GRcompcurve_class_id )
               == OM_S_SUCCESS ) ||
        (om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_GRbspline_class_id )
               == OM_S_SUCCESS )
       ){
          as$make_source( go_grid = LocatedObjects[j].obj_id,
                          mod_env = &LocatedObjects[j].mod_env,
                          as_os   =me->ModuleInfo.md_id.osnum ,
                          as_grid = &me->info[j]);
       }
       else {
         ex$message( msgnumb = VL_E_BadObj , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         me->ret = *sts = MY_ERROR;
         goto quit; 
       }
     }
     me->nb_info = nb_obj;
     if (nb_obj > 1) {
       sprintf(pt_name,"%d Defined",nb_obj);
     }
     else {
       if (!VLgetName(&LocatedObjects[0].obj_id,pt_name))
         strcpy(pt_name,"Defined");
     }
     FIg_set_text(me->form_ptr,G_DATA_NAME,pt_name);
  quit :
  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
    ASend_fence();
    FIg_set_state_off(me->form_ptr,G_DATA);
    me->locate_prev = 0;
    return OM_S_SUCCESS;
}

method VLcontrol_line(int *sts)
{
struct GRobj_env	*LocatedObjects;
int 			nb_obj;
char			pt_name[150],array[256];
struct GRid		list[100];
int 			count,loc_msg,j,i;
IGRlong			msg;
GRclassid		cid;
IGRlong			status;
struct ACrg_coll        list_att[20];

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc);
    goto quit;
  }
    if (nb_obj == 1) {
      if (VLgetName(&LocatedObjects[0].obj_id,pt_name)) {
        FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                       0, pt_name,FALSE);
        FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,
                               0,0,pt_name,0,0);
      }
      else {
        FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                       0, "",FALSE);
        FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,
                               0,0,"",0,0);
       }
    }
    for (i=0;i<nb_obj;i++) 
    {
      om$get_classid(osnum = LocatedObjects[i].obj_id.osnum,
                   objid = LocatedObjects[i].obj_id.objid,
                   p_classid = &cid);
     if (
        ((om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_VLbutLine_class_id )
               != OM_S_SUCCESS ) && ((me->mytype == 6) || (me->mytype == 9))) ||
         ((om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_VLseaLine_class_id )
               != OM_S_SUCCESS ) && (me->mytype == 7 || me->mytype == 10)) ||
         ((om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_VLwatLine_class_id )
               != OM_S_SUCCESS )&& (me->mytype == 8)) ||
        ((om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_VLtrace_class_id )
               != OM_S_SUCCESS ) && ((me->mytype == 5)))
        ){
       ex$message( msgnumb = VL_E_BadObj , buff = array);
       FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
       me->ret = *sts = MY_ERROR;
       goto quit; 
     }
     me->to_modify = LocatedObjects[i].obj_id;
     status = om$send(msg = message NDnode.NDget_objects
						(ND_ROOT,list,100,
                                                 NULL, NULL,
                                                 OM_K_MAXINT, &count),
                                 targetid = LocatedObjects[i].obj_id.objid,
                                 targetos = LocatedObjects[i].obj_id.osnum);
     if (!(status&1)) {
       ex$message(msgnumb = VL_E_BadParent);
       goto quit;
     }
      me->hull = list[INDEX_HULL];
      me->old_hull = me->hull;
      if(!VLgetName(&list[INDEX_HULL], pt_name))
        strcpy(pt_name,"Defined");
      FIfld_set_text(me->form_ptr,G_HULL_NAME,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_HULL_NAME,
                             0,0,pt_name,0,0);

      me->allow_dir = list[INDEX_AL_CS];
      me->old_allow_dir = me->allow_dir;
      if(!VLgetName(&list[INDEX_AL_CS], pt_name)) {
        if (!VLfindDirectName(&me->allow_dir,pt_name,&me->ModuleInfo,1)) {
          ex$message(msgnumb = VL_E_ConsCsFail);
          goto quit;
        }
      }
      else {
        if (!strcmp(pt_name,"BASEcoordsys"))
          strcpy(pt_name,"Base CS");
      }
      FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,
                             0,0,pt_name,0,0);


      if (1 > om$dimension_of(varray = me->info))
        om$vla_set_dimension(varray = me->info,size = 1);
      if (1 > om$dimension_of(varray = me->old_info))
        om$vla_set_dimension(varray = me->old_info,size = 1);
      me->info[0] = list[INDEX_GR_INFO];
      me->old_info[0] = me->info[0];
      me->nb_info = 1;
      if(!VLgetName(&list[INDEX_GR_INFO], pt_name))
        strcpy(pt_name,"Defined");
      FIfld_set_text(me->form_ptr,G_DATA_NAME,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_DATA_NAME,
                             0,0,pt_name,0,0);

      me->pt_select = list[INDEX_PT_SELECT];
      me->old_pt_select = me->pt_select;
      om$get_classid(osnum = me->pt_select.osnum,
                     objid = me->pt_select.objid,
                     p_classid = &cid);
  
      if (om$is_ancestry_valid(subclassid     = cid,
                               superclassid = OPP_expression_class_id )
                 == OM_S_SUCCESS ) {
        strcpy(pt_name,"No");
      }
      else {
        if(!VLgetName(&list[INDEX_PT_SELECT], pt_name))
          strcpy(pt_name,"Defined");
      }
      FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,
                             0,0,pt_name,0,0);

      status = om$send(msg = message ACrg_collect.AClist_attribute
                                                 (&msg,20,list_att,&count),
                       targetid = list[INDEX_ATT_BOX].objid,
                       targetos = list[INDEX_ATT_BOX].osnum);
      if (!(status&msg&1)) {
        ex$message( msgnumb = VL_E_InvColl , buff = pt_name);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,pt_name);
      }
      me->box = list[INDEX_ATT_BOX];
      if ((j=VLseekFields(list_att,count,N_ATT_SELECTOR)) != -1) {
        if (list_att[j].desc.value.att_exp != V_ATT_BASE &&
            list_att[j].desc.value.att_exp != V_ATT_CURVED) {
        ex$message( msgnumb = VL_E_InvType1 , buff = pt_name);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,pt_name);
        me->ret = *sts = MY_ERROR;
        goto quit;
        }
      }
      else {
        ex$message( msgnumb = VL_E_InvSelector , buff = pt_name);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,pt_name);
        me->ret = *sts = MY_ERROR;
        goto quit;
      }
      
      if ((j=VLseekFields(list_att,count,N_ATT_AL_VAL)) != -1) {
        me->allowence = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->allowence,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = array);

        if(!(status & loc_msg & 1)) {
          ex$message( msgnumb = VL_E_BadPlc, buff = array);
          FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
          goto quit;
        }
        j=0;
        while (array[j] != ' ') j++;
        array[j] = '\0';
        strcpy(pt_name,array);
      }
      else
        strcpy(pt_name,"No");
      FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,
                             0,0,pt_name,0,0);

      if ((j=VLseekFields(list_att,count,N_ATT_EXTRA_AL)) != -1) {
        me->ext_allow = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->ext_allow,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = array);

        if(!(status & loc_msg & 1)) {
          ex$message( msgnumb = VL_E_BadPlc, buff = array);
          FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,array);
          goto quit;
        }
        j=0;
        while (array[j] != ' ') j++;
        array[j] = '\0';
        strcpy(pt_name,array);
      }
      else
        strcpy(pt_name,"No");
      FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,
                             0,0,pt_name,0,0);

      
      me->cs = list[INDEX_CS];
      me->old_cs = me->cs;
      if(!VLgetName(&list[INDEX_CS], pt_name)) {
        if (!VLfindDirectName(&me->cs,pt_name,&me->ModuleInfo,1)) {
          ex$message(msgnumb = VL_E_ConsCsFail);
          goto quit;
        }
      }
      else {
        if (!strcmp(pt_name,"BASEcoordsys"))
          strcpy(pt_name,"Base CS");
      }
      FIfld_set_text(me->form_ptr,G_CS,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_CS,
                             0,0,pt_name,0,0);
   }
    me->old_to_modify = me->to_modify;
  quit :
  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
    ASend_fence();
    FIg_set_state_off(me->form_ptr,G_MODIF);
    me->locate_modif = 0;
    return OM_S_SUCCESS;
}

method VLcontrol_exp_info (int *sts)
{
struct GRid	obj;
GRclassid	cid;

  if (!VLtestExp(&obj,me->event1.event.keyin,&me->ModuleInfo))
    goto quit;

    /* test the object class */
  om$get_classid(osnum = obj.osnum,
                 objid = obj.objid,
                 p_classid = &cid);
  if (
      (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_EMSplane_class_id )
             == OM_S_SUCCESS ) ||
      (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_EMSsurface_class_id )
             == OM_S_SUCCESS ) ||
      (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GRbspline_class_id )
             == OM_S_SUCCESS )
     ) {
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    if (1 > om$dimension_of(varray = me->info))
      om$vla_set_dimension(varray = me->info,size = 1);
    as$make_source(
                   go_grid = obj,
                   as_os   =me->ModuleInfo.md_id.osnum ,
                   as_grid = &me->info[0]);
    me->nb_info = 1;
    FIg_set_text(me->form_ptr,G_DATA_NAME,me->event1.event.keyin);
  }
  else {
    if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_expression_class_id )
             == OM_S_SUCCESS ) {
    if (1 > om$dimension_of(varray = me->info))
      om$vla_set_dimension(varray = me->info,size = 1);
      me->info[0] = obj;
      me->nb_info = 1;
      FIg_set_text(me->form_ptr,G_DATA_NAME,"Defined");
    }
    else {
      ex$message( msgnumb = VL_E_BadObj);
      me->ret = *sts = MY_ERROR;
      goto quit;
    }
  }
quit :
  FIg_set_state_off(me->form_ptr,G_DATA);
  return OM_S_SUCCESS;
}

method VLcontrol_value (int *sts)
{
int loc_msg;
double dd;
IGRlong status;

  if (1 > om$dimension_of(varray = me->info))
    om$vla_set_dimension(varray = me->info,size = 1);
  me->info[0].osnum = me->ModuleInfo.md_id.osnum;
  me->nb_info = 1;
  dd = me->event1.event.value;
  status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                             unit_type = GRIO_DISTANCE,
                             osnum     = me->ModuleInfo.md_id.osnum,
                             primary = dd,
                             result  = &dd);
  exp$create(exp_name = NULL,
                 exp_value = dd,
                 p_exp_id = &me->info[0].objid,
                 osnum = me->info[0].osnum);
  om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
	  targetid = me->info[0].objid,
	  targetos = me->info[0].osnum );
  FIg_set_text(me->form_ptr,G_DATA_NAME,"Defined");

  goto quit;
quit :
  dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,G_DATA);
  return OM_S_SUCCESS;
}

end implementation VLallLinCmd;

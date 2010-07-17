/* 
  File           VLbutMethod.I 
  Creation Date  November 92
  Auteur         Ghassan Jahmi

*/

class implementation VLbutLinCmd;

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
#include "DItypedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vlmsg.h"
#include <math.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DIdef.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#define EPS 0.000001

extern GRclassid OPP_VLbutLine_class_id;
extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_VLwatLine_class_id;
extern GRclassid OPP_GRgencs_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern struct GRid NULL_GRID;
extern VLinitCnst();
extern MAmulmx();
extern struct GRid MANwk_hull;
from GRgraphics import GRdelete;
from ACncpx import ACmplace;
from GRvg import GRgetname;
from GRvg import GRchgname;
from GR3dpoint import GRcenter;
from NDnode import NDget_objects;
from NDnode import NDchange_connect;
from NDnode import NDconnect;
from NDnode import NDdisconnect;
from NDnode import ASreturn_go;
from NDnode import NDchg_state;
from expression import NDgive_value;
from GRgraphics import GRaltconstruct;
from GRgencs import GRgetmatrix;
from ACrg_collect import ACadd_list_attribute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import AClist_attribute;
from NDmacro import ACreturn_foot;
from GRvg import GRputsymb;

VLseekFields (list,nb,array)
struct ACrg_coll	*list;
int	nb;
char 	*array;
{
int  i;

  for (i=0;i<nb;i++)
  {
    if (!strcmp(list[i].name,array))  return i;
  }
  return -1;
}

VLreadDirect (direct,gadget,form_ptr,module,mode,point2,objid)
struct GRid		*direct;
int			gadget;
char			*form_ptr;
struct GRmd_env		*module;
enum GRdpmode		*mode;
int			*point2;
GRobjid			*objid;
{
char			*pt,array[200];
IGRlong			status;
int			loc_msg,rep;
struct GRid		tmp;

  FIg_get_text(form_ptr,gadget,array);
  if (
      !strcmp(array,"x")|| !strcmp(array,"X") ||
      !strcmp(array,"-X")|| !strcmp(array,"-x")||
      !strcmp(array,"y")|| !strcmp(array,"Y") ||
      !strcmp(array,"-Y")|| !strcmp(array,"-y")||
      !strcmp(array,"z")|| !strcmp(array,"Z") ||
      !strcmp(array,"-Z")|| !strcmp(array,"-z")||
      !strcmp(array,"No")|| !strcmp(array,"no")
     ) {
    status = om$send(msg = message VLgenLinCmd.VLparse_str(&loc_msg,array,direct),
       targetid = *objid,
       targetos = OM_Gw_current_OS,
       senderid = NULL_OBJID);
   
    if(!(status & loc_msg & 1))
    { 
      ex$message(msgnumb = VL_E_BadDir);
      return 0;
    }
  }
  else {
    if (!strcmp(array,"Base CS")) {
      tmp.objid = NULL_OBJID;
      vds$translate (objname = "BASEcoordsys",
                     p_objid = &tmp.objid,
                     p_osnum = &tmp.osnum );
      if (tmp.objid != NULL_OBJID)
        as$make_source( go_grid = tmp,
                        as_os   =module->md_id.osnum ,
                        as_grid = &tmp);
      *direct = tmp;
    }
    else {
      if (!strcmp(array,"active CS")) {
        tmp.osnum = module->md_id.osnum;
        status = cs$get_active_info(msg = &loc_msg,
				    namebuf_size = 200,
				    name = array,
                                    namebytes_ret = &rep,
				    osnum = tmp.osnum,
				    module= module->md_id.objid ,
				    objid = &tmp.objid);
        if (!(status&loc_msg&1)) {
          ex$message(msgnumb = VL_E_ConsCsFail);
          return 0;
        } 
        if (tmp.objid != NULL_OBJID)   {
          as$make_source( go_grid = tmp,
                          as_os   = module->md_id.osnum ,
                          as_grid = &tmp);
          if (array[0] != '\0') {
            /* just the name, without path */
	    for(rep = strlen(array)-1;array[rep] != ':'; rep--);
            pt = array+rep+1;
            FIg_set_text(form_ptr,gadget,pt);
          }
          VLdispObj(&tmp,module,mode,1);
          *direct = tmp;
        }
      }
      else {
        if (!strcmp(array,"others")) {
          return 2;
        }
          else {
            if (!strcmp(array,"previous")) {
              return 1;
            }
          vds$translate (objname = array,
                         p_objid = &tmp.objid,
                         p_osnum = &tmp.osnum );
          if( tmp.objid == NULL_OBJID) {
            ex$message( msgnumb = VL_E_BadObj);
            FIg_set_text(form_ptr,gadget,"");
            return 0;
          }
          if (tmp.osnum != module->md_id.osnum ) {
	    ex$message(msgnumb = VL_E_ObjOutCurr);
            FIg_set_text(form_ptr,gadget,"");
            return 0;
          }
          if (!(*point2)) { /* if it is the first point */
              if((rep=VLnameTest(&tmp,direct))){
                FIg_set_text(form_ptr,gadget, array);
                VLdispObj(&tmp,module,mode,1);
                as$make_source( go_grid = *direct,
                                as_os   =module->md_id.osnum ,
                                as_grid = direct);
                if (rep == 1) { /* a point is located */
                  *point2 = 1;
                  return 3;
                }
              }
              else {
                ex$message( msgnumb = VL_E_BadObj);
                FIg_set_text(form_ptr,gadget,"");
		return 0;
              }
            }
            else { /* it is the second point */
              if ((rep = VLname2Test(&tmp,direct,module))) {
                FIg_set_text(form_ptr,gadget, array);
                VLdispObj(&tmp,module,mode,1);
                as$make_source(
                     go_grid = *direct,
                     as_os   = module->md_id.osnum ,
                     as_grid = direct);
  		*point2 = 0;
		return 4;
              }
              else {
                ex$message( msgnumb = VL_E_BadObj);
                FIg_set_text(form_ptr,gadget,"");
		return 0;
              }
            }
        }
      }
    }
  }
  return 1;
}

VLmodifyList (old_nb,old_list,nb,list)
int old_nb;
struct GRid *old_list;
int nb;
struct GRid *list;
{
int i;

  if (old_nb != nb) return 1;
  for (i=0; i<old_nb; i++)
  {
    if (
        old_list[i].objid != list[i].objid || 
        old_list[i].osnum != list[i].osnum
       )
      return 1;
  }
  return 0;
}

VLfindDirectName(cs,name,module)
struct GRid 	*cs;
char        	*name;
struct GRmd_env *module;
{
struct GRid  tmp;
int	     i,loc_msg;
IGRlong	     msg;
IGRlong      status;
GRclassid    cid;
IGRdouble    pnt[4],wld[4];
struct GRid  graph_obj;
IGRshort     mat_type;
IGRdouble    mat[16];

  om$get_classid(osnum = cs->osnum,
                 objid = cs->objid,
                 p_classid = &cid);
  
  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_expression_class_id )
             == OM_S_SUCCESS ) {
    strcpy(name,"No");
    return 1;
  }

  tmp.objid = NULL_OBJID;
  vds$translate (objname = "BASEcoordsys",
                 p_objid = &tmp.objid,
                 p_osnum = &tmp.osnum );
  if (tmp.objid != NULL_OBJID)
    as$make_source( go_grid = tmp,
                    as_os   =module->md_id.osnum ,
                    as_grid = &tmp);
  if (cs->objid == tmp.objid && cs->osnum == tmp.osnum) {
    strcpy(name,"Base CS");
    return 1;
  }
  /* get active cs */
  tmp.osnum = module->md_id.osnum;
  status = cs$get_active_info(msg = &loc_msg,
			      osnum = tmp.osnum,
			      module= module->md_id.objid ,
			      objid = &tmp.objid);
  if (!(status&loc_msg&1)) {
     ex$message(msgnumb = VL_E_ConsCsFail);
     return 0;
  } 
  if (tmp.objid != NULL_OBJID)   {
    as$make_source( go_grid = tmp,
                    as_os   =module->md_id.osnum ,
                    as_grid = &tmp);
    
    if (cs->objid == tmp.objid && cs->osnum == tmp.osnum) {
      strcpy(name,"active CS");
      return 1;
    }
  }
  else  return 0;

  graph_obj = *cs;
  mat_type = module->md_env.matrix_type;
  for (i=0; i<16; i++) mat[i] = module->md_env.matrix[i];
  status = om$send(  msg = message NDnode.ASreturn_go(&graph_obj,&mat_type,mat),
                     targetid = cs->objid,
		     targetos = cs->osnum,
		     senderid = NULL_OBJID);
  status = om$send(msg = message GRvg.GRcenter( &msg, &mat_type, mat, pnt),
		          targetid = graph_obj.objid,
		          targetos = graph_obj.osnum,
			  senderid = NULL_OBJID);
    if (!(status&msg&1)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      return 0;
    }
  pnt[3] = 0;
  if (!VLconvertCoord(module,pnt,wld,1)) {
    ex$message(msgnumb = VL_E_BadDir);
    return 0;
  }
  if (
      (wld[0] > 1- EPS) && (wld[0] < 1+ EPS) &&
      (wld[1] >  -EPS) && (wld[1] < EPS) &&
      (wld[2] >  -EPS) && (wld[2] < EPS)
     ) {
    strcpy(name,"x");
    return 1;
  }
  if (
      (wld[0] > -1 - EPS) && (wld[0] < - 1+ EPS) &&
      (wld[1] >  -EPS) && (wld[1] < EPS) &&
      (wld[2] >  -EPS) && (wld[2] < EPS)
     ) {
    strcpy(name,"-x");
    return 1;
  }
  if (
      (wld[1] > 1- EPS && wld[1] < 1+ EPS) &&
      (wld[0] >  -EPS && wld[0] < EPS) &&
      (wld[2] >  -EPS && wld[2] < EPS)
     ) {
    strcpy(name,"y");
    return 1;
  }
  if (
      (wld[1] > -1- EPS && wld[1] < -1+ EPS) &&
      (wld[0] >  -EPS && wld[0] < EPS) &&
      (wld[2] >  -EPS && wld[2] < EPS)
     ) {
    strcpy(name,"-y");
    return 1;
  }
  if (
      (wld[2] > 1- EPS && wld[2] < 1+ EPS) &&
      (wld[0] >  -EPS && wld[0] < EPS) &&
      (wld[1] >  -EPS && wld[1] < EPS)
     ) {
    strcpy(name,"z");
    return 1;
  }
  if (
      (wld[2] > -1 - EPS && wld[2] < -1+ EPS) &&
      (wld[0] >  -EPS && wld[0] < EPS) &&
      (wld[1] >  -EPS && wld[1] < EPS)
     ) {
    strcpy(name,"-z");
    return 1;
  }
  strcpy(name,"others");
  return 1;
}

method form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{
int		 loc_msg,rep;
IGRlong		 msg;
IGRlong 	 status;
int   		 j,i,row, pos;
char   		 array[200];
struct GRid 	 tmp;
int       	 r_pos,sel_flag;
GRclassid	 cid;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message VLbutLinCmd.VLsave_all(&msg),
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
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      
      status = om$send(msg = message VLbutLinCmd.VLsave_all(&msg),
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
      me->cs = me->old_cs;
      me->previous = me->old_previous;
      me->hull = me->old_hull;
      me->to_modify = me->old_to_modify;
      me->pt_select = me->old_pt_select;
      me->allow_dir = me->old_allow_dir;
      me->point2 = me->old_point2;
      me->dev = me->old_dev;
      if (!me->dev) {
         FIg_erase(me->form_ptr,G_WIDTH);
         FIg_erase(me->form_ptr,G_WIDTH_TXT);
      }
      if (me->old_nb_cl_line > om$dimension_of(varray = me->cl_line))
      om$vla_set_dimension(varray = me->cl_line,size = me->old_nb_cl_line);
      me->nb_cl_line = me->old_nb_cl_line;
      for (i=0; i<me->old_nb_cl_line; i++)
        me->cl_line[i] = me->old_cl_line[i];
      FIg_set_state_off(me->form_ptr,FI_RESET);
      FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_LENGTH,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_HULL_NAME,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                   0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_BUTT_NAME,0,
                   0, "",FALSE);
      FIfld_get_num_rows(me->form_ptr,G_LIST_WATER,&rep);
      for(i=0; i<rep; ++i)
      FIfld_set_text(me->form_ptr,G_LIST_WATER,i,
                   0, "",FALSE);
      _put_response(resp = RESET_BUTT);
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
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
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

     case G_PREV:
      if (me->locate_prev) {
        FIg_set_state_on(me->form_ptr,G_PREV);
      }
      else me->locate_prev = 1;
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      
      if (me->previous.objid != NULL_OBJID) {
        me->DisplayMode = GRhd;
        VLdispObj(&me->previous,&me->ModuleInfo,&me->DisplayMode,1);
      }
      _put_response(resp = PREV);
      break;

     case G_PREV_NAME :
       FIg_get_text(me->form_ptr,G_PREV_NAME,array); 
       vds$translate (objname = array,
                      p_objid = &tmp.objid,
                      p_osnum = &tmp.osnum );
       if( tmp.objid == NULL_OBJID ) {
         FIg_set_text(me->form_ptr,G_PREV_NAME,""); 
         ex$message( msgnumb = VL_E_InvName , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         goto quit;
       }
       if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
         ex$message( msgnumb = VL_E_ObjOutCurr , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_PREV_NAME,"");
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

       if ((om$is_ancestry_valid(subclassid     = cid,
                                superclassid = OPP_VLbutLine_class_id )
                  == OM_S_SUCCESS ) && me->hull.objid != NULL_OBJID){
          me->previous.objid = tmp.objid;
          me->previous.osnum = tmp.osnum;
       }
       else {
         ex$message( msgnumb = VL_E_BadObj , buff = array);
         FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
         FIg_set_text(me->form_ptr,G_PREV_NAME,"");
         goto quit;
       }
       break;

     case G_ADD:
      if (me->locate_add) {
        FIg_set_state_on(me->form_ptr,G_ADD);
      }
      else me->locate_add = 1;
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      FIfld_get_active_row(me->form_ptr,G_LIST_WATER,&row,&pos);
      FIfld_get_text(me->form_ptr,G_LIST_WATER,row,0,
                     200,array, &sel_flag,&r_pos);
      if (array[0] != '\0') {
        vds$translate (objname = array,
                       p_objid = &tmp.objid,
                       p_osnum = &tmp.osnum );
        if( tmp.objid == NULL_OBJID) {
          ex$message( msgnumb = VL_E_BadObj);
         goto LAB;
        }
	if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
	  ex$message(msgnumb = VL_E_ObjOutCurr);
         goto LAB;
        }
        me->DisplayMode = GRhd;
        VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);
        status = om$send(msg = message VLbutLinCmd.VLadd_1_cl_line(
						&loc_msg,
						&tmp,
						OPP_VLwatLine_class_id),
		        	targetid = my_id);
        if (!(status & loc_msg&1)) {
	  goto LAB;
        }
       FIg_set_state_off(me->form_ptr,G_ADD);
       goto quit;
      }
LAB:  for (i=0; i<me->nb_cl_line;i++)
      {
        me->DisplayMode = GRhd;
        VLdispObj(&me->cl_line[i],&me->ModuleInfo,&me->DisplayMode,0);
      }
      _put_response(resp = ADD);
      break;

     case G_ALLOW_DIR :
     case G_DIRECTION :
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      me->DisplayMode = GRhd;
      if (gadget_label == G_DIRECTION) {
        me->vect = &me->cs;
        if (!(rep=VLreadDirect (&me->cs,gadget_label,form_ptr,&me->ModuleInfo,
                          &me->DisplayMode,&me->point2,&my_id)))
          goto quit;
        switch (rep) {
          case 2 : _put_response(resp = DIRECT);
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
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
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

     case G_DELETE :
      if (me->locate_del) {
        FIg_set_state_on(me->form_ptr,G_DELETE);
      }
      else me->locate_del = 1;
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
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
       FIfld_get_active_row(me->form_ptr,G_LIST_WATER,&row,&pos);
       i=0; pos = -1;
       while (i<me->nb_cl_line && row >= me->num_cl_line[i]) {
         if (row == me->num_cl_line[i]) pos = i;
         i++;
       }
       for (j=i; j<me->nb_cl_line;j++)
       {
         (me->num_cl_line[j])--;
       }
                 /* erase object from the list */
        if (pos >= 0) {
          if (pos + 1 < me->nb_cl_line) {
            memcpy(&me->cl_line[pos],&me->cl_line[pos+1],
                              (me->nb_cl_line - pos -1)*sizeof(struct GRid));
            memcpy(&me->num_cl_line[pos],&me->num_cl_line[pos+1],
                              (me->nb_cl_line - pos -1)*sizeof(int));
          }
          me->nb_cl_line--;
        }
      FIfld_get_num_rows(me->form_ptr,G_LIST_WATER,&rep);
      FIfld_delete_rows(me->form_ptr,G_LIST_WATER,row,1);
      if (row >= rep-1 && row)
        FIfld_pos_cursor(me->form_ptr,G_LIST_WATER,row-1,0,0,0,0,0);
      else
        FIfld_pos_cursor(me->form_ptr,G_LIST_WATER,row,0,0,0,0,0);
      FIg_set_state_off(me->form_ptr,G_DELETE);
       break;

     case G_LIST_WATER :
       FIfld_get_active_row(me->form_ptr,G_LIST_WATER,&row,&pos);
       for (i=0;i<me->nb_cl_line;i++)
       {
         if (row == me->num_cl_line[i]) break;
       }
       if (i< me->nb_cl_line) {
         me->DisplayMode = GRhd;
         VLdispObj(&me->cl_line[i],&me->ModuleInfo,&me->DisplayMode,1);
       }
       break;
     case G_DEV :
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
       FIg_get_state(me->form_ptr,G_DEV,&rep); 
       if (rep) {
         FIg_display(me->form_ptr,G_WIDTH);
         FIg_display(me->form_ptr,G_WIDTH_TXT);
       }
       else {
         FIg_erase(me->form_ptr,G_WIDTH);
         FIg_erase(me->form_ptr,G_WIDTH_TXT);
       }
       me->dev = rep;
       break;
     case G_MODIF :
      if (me->locate_modif) {
        FIg_set_state_on(me->form_ptr,G_MODIF);
      }
      else me->locate_modif = 1;
      if (me->locate_prev) {
        FIg_set_state_off(me->form_ptr,G_PREV);
        me->locate_prev = 0;
      }
      if (me->locate_hull) {
        FIg_set_state_off(me->form_ptr,G_HULL);
        me->locate_hull = 0;
      }
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_pt_select) {
        FIg_set_state_off(me->form_ptr,G_SELECT_PT);
        me->locate_pt_select = 0;
      }
      me->DisplayMode = GRhd;
      VLdispObj(&me->to_modify,&me->ModuleInfo,&me->DisplayMode,1);
      _put_response(resp = MOD_D);
      break;
  }

 quit:
  return OM_S_SUCCESS;
}
 
method VLsave_all ( int *msg )
{
IGRlong		status=0,loc_msg=0;
IGRint		suc;
IGRdouble	width=0,length=0,allo=0,ext_allo=0;
struct GRid	butt,roots[40];
int  		i,j;
int		r_pos,sel_flag,dev;
char		tmp[200],wid[50],len[50],all[50],ext_all[50],cur_name[50];
char		pt_name[100];
IGRboolean 	put_batch = FALSE;
struct ACrg_coll ACrg[10];
GRclassid		cid;
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRint			b_mod;
enum	GRdpmode	dpmode=GRbd;

  /* Retrieve parameters in the form and control they are OK */

  *msg = MSFAIL;

  FIg_get_text(me->form_ptr,G_LENGTH,len);
  sscanf(len,"%lf",&length);
  FIg_get_text(me->form_ptr,G_ALLOWENCE,all);
  if (strcmp(all,"No"))
    sscanf(all,"%lf",&allo);
  FIg_get_text(me->form_ptr,G_EXTRA_ALLOW,ext_all);
  if (strcmp(ext_all,"No"))
  sscanf(ext_all,"%lf",&ext_allo);

  status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                             unit_type = GRIO_DISTANCE,
                             osnum     = me->ModuleInfo.md_id.osnum,
                             primary = length,
                             result  = &length);
  if(!(status & loc_msg & 1)) {
    ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
  }

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

  if (length<0 || allo < 0 || ext_allo < 0 || me->hull.objid == NULL_OBJID ||
      me->cs.objid == NULL_OBJID || me->previous.objid == NULL_OBJID
      || me->nb_cl_line == 0) {
    ex$message( msgnumb = VL_E_InvParam, buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }
  FIg_get_state(me->form_ptr,G_DEV,&dev); 
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

  if (me->mytype == 1) {
    if (me->cs.objid != me->old_cs.objid || me->cs.osnum != me->old_cs.osnum){
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
    if (me->allow_dir.objid != me->old_allow_dir.objid || me->allow_dir.osnum != me->old_allow_dir.osnum){
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

    if (me->previous.objid != me->old_previous.objid
        || me->previous.osnum != me->old_previous.osnum){
      status = om$send(msg = message NDnode.NDchange_connect
                      (1,&me->old_previous,&me->previous),
                      targetid = me->to_modify.objid,
		      targetos = me->to_modify.osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_PbsModPar);
        goto quit;
      } 
      put_batch = TRUE;
      me->old_previous = me->previous;
    }
    if (me->pt_select.objid != me->old_pt_select.objid
        || me->pt_select.osnum != me->old_pt_select.osnum){
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
        || me->hull.osnum != me->old_hull.osnum){
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
    if (me->old_dev != dev || me->width != width || me->length != length 
        || me->allowence != allo || me->ext_allow != ext_allo) {
      r_pos = 0;
      if (!dev) {
        strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = V_ATT_NEXT;
      }
      else {
        strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = V_ATT_DEV;
        FIg_get_text(me->form_ptr,G_WIDTH,wid);
        sscanf(wid,"%lf",&width);
        status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                                   unit_type = GRIO_DISTANCE,
                                   osnum     = me->ModuleInfo.md_id.osnum,
                                   primary = width,
                                   result  = &width);
        if(!(status & loc_msg & 1)) {
          ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
          FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
        }
      }
      r_pos++;
      if (length) {
        strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = length;
        r_pos++;
      }
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
      if (dev && width) {
        strcpy(ACrg[r_pos].name,N_ATT_TST_W);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
        ACrg[r_pos].desc.value.att_exp = width;
        r_pos++;
      }
      status = om$send(msg = message ACrg_collect.ACset_list_attribute
                                      (&loc_msg,r_pos,ACrg ),
			targetid = me->box.objid,
			targetos = me->box.osnum);
      if (!(status&loc_msg&1)) {
        ex$message( msgnumb = VL_E_InvColl , buff = tmp);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
      }
      put_batch = TRUE; 
      me->length = length;
      me->allowence = allo;
      me->ext_allow = ext_allo;
      me->dev = dev;
      me->old_dev = dev;
      me->width = width;
    }
    if (VLmodifyList(me->old_nb_cl_line,me->old_cl_line,
                   me->nb_cl_line,me->cl_line)
       ) {
      status = om$send(msg = message NDnode.NDdisconnect
                      (me->old_nb_cl_line,me->old_cl_line),
                      targetid = me->to_modify.objid,
        	      targetos = me->to_modify.osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_PbsModPar);
        goto quit;
      } 
      status = om$send(msg = message NDnode.NDconnect
                      (me->nb_cl_line,me->cl_line,NULL_GRID,ND_ADD),
                      targetid = me->to_modify.objid,
        	      targetos = me->to_modify.osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_PbsModPar);
        goto quit;
      } 
      
      put_batch = TRUE;
      if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
        om$vla_set_dimension(varray = me->old_cl_line,
                                                  size = me->nb_cl_line);
      me->old_nb_cl_line = me->nb_cl_line;
      for (i=0; i<me->nb_cl_line; i++)
        me->old_cl_line[i] = me->cl_line[i];
    }
    FIg_get_text(me->form_ptr,G_BUTT_NAME,tmp);
    if(!VLgetName(&me->to_modify, pt_name)) {
      if (strcmp(tmp,"Defined")) {
        status = om$send(msg    = message VLbutLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
						"butt",
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
        status = om$send(msg    = message VLbutLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
						"butt",
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

 	     ex$message(msgnumb = VL_E_ModButt);
	      nd$exec_batch();
	}

      ex$message(msgnumb = VL_E_ButtMod);
    }
  }
  else {
  /* Construct ACrg_collection */
  r_pos = 0;
  strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
  ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
  if (dev) {
    ACrg[r_pos].desc.value.att_exp = V_ATT_DEV;
    FIg_get_text(me->form_ptr,G_WIDTH,wid);
    sscanf(wid,"%lf",&width);
    status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                               unit_type = GRIO_DISTANCE,
                               osnum     = me->ModuleInfo.md_id.osnum,
                               primary = width,
                               result  = &width);
    if(!(status & loc_msg & 1)) {
      ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
      FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    }
  }
  else ACrg[r_pos].desc.value.att_exp = V_ATT_NEXT;
  r_pos++;
  if (length) {
    strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = length;
    r_pos++;
  }
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
  if (width) {
    strcpy(ACrg[r_pos].name,N_ATT_TST_W);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = width;
    r_pos++;
  }
  roots[INDEX_ATT_BOX].osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
                        osnum   = roots[INDEX_ATT_BOX].osnum,
                        p_objid = &roots[INDEX_ATT_BOX].objid);
  if(!(status & 1)) {
    ex$message( msgnumb = VL_E_InvColl , buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }
  om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
           targetid = roots[INDEX_ATT_BOX].objid,
           targetos = roots[INDEX_ATT_BOX].osnum );
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
  roots[INDEX_GR_INFO]        = me->previous;
  roots[INDEX_PT_SELECT]      = me->pt_select;
  roots[INDEX_AL_CS]          = me->allow_dir;
  roots[INDEX_CS]             = me->cs;

  for (i=0; i<me->nb_cl_line;i++)
    roots[i+INDEX_START_CL] = me->cl_line[i],

    butt.osnum = me->ModuleInfo.md_id.osnum;
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
                                          BUTT_DEF_3,
                                          INDEX_START_CL+ me->nb_cl_line,
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
    ex$message(msgnumb = VL_E_ButtCreated);
    FIg_get_text(me->form_ptr,G_BUTT_NAME,pt_name);
    if (pt_name[0]) {
    FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                   0, pt_name,FALSE);
   }
   else
    FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                   0, "Defined",FALSE);
        status = om$send(msg    = message VLbutLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                pt_name,
						"butt",
                                                &me->hull,
                                                butt,
						&dpmode),
                        targetid = my_id );
       if(!(status & loc_msg & 1))
         ex$message(msgnumb = VL_E_BadChgName);
    /* prepare a default name for the next butt */
    FIg_get_text(me->form_ptr,G_BUTT_NAME,cur_name);
    if ( cur_name[0] == '\0' ) strcpy( cur_name, "Butt" );
    status = om$send(msg = message VLbutLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           "butt",
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
    me->previous = butt;
  }
  /* set defaults used by RESET */
  FIg_get_text(me->form_ptr,G_PREV_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_PREV_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_BUTT_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_BUTT_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_DIRECTION,tmp);
  FIfld_set_default_text(me->form_ptr,G_DIRECTION,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_ALLOW_DIR,tmp);
  FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_SEL_PT_NAME,tmp);
  FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_HULL_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_HULL_NAME,
                         0,0,tmp,0,0);
  FIfld_set_default_text(me->form_ptr,G_LENGTH,
                         0,0,len,0,0);
  FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,
                         0,0,all,0,0);
  FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,
                         0,0,ext_all,0,0);
  if (dev) FIfld_set_default_text(me->form_ptr,G_WIDTH,
                           0,0,wid,0,0);
  FIg_set_default_value(me->form_ptr,G_DEV,(double)dev);
  me->old_previous = me->previous;
  me->old_cs = me->cs;
  MANwk_hull = me->old_hull = me->hull;
  me->old_to_modify = me->to_modify;
  me->old_pt_select = me->pt_select;
  me->old_allow_dir = me->allow_dir;
  me->old_point2 = me->point2;
  me->old_dev = me->dev;
  if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
    om$vla_set_dimension(varray = me->old_cl_line,size = me->nb_cl_line);
  me->old_nb_cl_line = me->nb_cl_line;
  for (i=0; i<me->nb_cl_line; i++)
    me->old_cl_line[i] = me->cl_line[i];

  FIfld_get_num_rows(me->form_ptr,G_LIST_WATER,&j);
  for (i=0; i<j; i++)
  {
    FIfld_get_text(me->form_ptr,G_LIST_WATER,i,0,
                   200,tmp, &sel_flag,&r_pos);
    FIfld_set_default_text(me->form_ptr,G_LIST_WATER,i,
                           0, tmp,FALSE);
  }
    
    *msg = MSSUCC;
  quit :
    return OM_S_SUCCESS;
}

method VLcontrol_butt (int *sts)
{
struct GRid             butt,list[100];
int                     nb,i,j,count,loc_msg;
IGRlong			msg;
GRclassid               cid;
char                    pt_name[256];
IGRlong                 status;
struct ACrg_coll        list_att[20];

  butt = me->event1.located_object[0].located_obj;
  me->to_modify = butt;
  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,list,100,
                                                      NULL, NULL,
	                                              OM_K_MAXINT, &count),
                                targetid = butt.objid,
                                targetos = butt.osnum);
     if (!(status&1)) {
        ex$message(msgnumb = VL_E_BadParent);
        goto quit;
      }
      if(VLgetName(&butt, pt_name)) {
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

      me->hull = list[INDEX_HULL];
      me->old_hull = me->hull;
      if(!VLgetName(&list[INDEX_HULL], pt_name))
        strcpy(pt_name,"Defined");
      FIfld_set_text(me->form_ptr,G_HULL_NAME,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_HULL_NAME,
                             0,0,pt_name,0,0);

      me->cs = list[INDEX_CS];
      me->old_cs = me->cs;
      if(!VLgetName(&list[INDEX_CS], pt_name)) {
        if (!VLfindDirectName(&me->cs,pt_name,&me->ModuleInfo)) {
          ex$message(msgnumb = VL_E_ConsCsFail);
          goto quit;
        }
      }
      else {
        if (!strcmp(pt_name,"BASEcoordsys"))
          strcpy(pt_name,"Base CS");
      }
      FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_DIRECTION,
                             0,0,pt_name,0,0);

      me->allow_dir = list[INDEX_AL_CS];
      me->old_allow_dir = me->allow_dir;
      if(!VLgetName(&list[INDEX_AL_CS], pt_name)) {
        if (!VLfindDirectName(&me->allow_dir,pt_name,&me->ModuleInfo)) {
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


      me->previous = list[INDEX_GR_INFO];
      me->old_previous = me->previous;
      if(!VLgetName(&list[INDEX_GR_INFO], pt_name))
        strcpy(pt_name,"Defined");
      FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_PREV_NAME,
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
                                                 (&msg,20,list_att,&nb),
                       targetid = list[INDEX_ATT_BOX].objid,
                       targetos = list[INDEX_ATT_BOX].osnum);
      if (!(status&msg&1)) {
        ex$message( msgnumb = VL_E_InvColl , buff = pt_name);
        FIg_set_text(me->form_ptr,FI_MSG_FIELD,pt_name);
      }
      me->box = list[INDEX_ATT_BOX];
      if ((j=VLseekFields(list_att,nb,N_ATT_SELECTOR)) != -1) {
        if (list_att[j].desc.value.att_exp != V_ATT_NEXT &&
            list_att[j].desc.value.att_exp != V_ATT_DEV) {
        ex$message( msgnumb = VL_E_InvType , buff = pt_name);
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
        if (list_att[j].desc.value.att_exp == V_ATT_DEV) {
         me->dev = 1;
         me->old_dev = 1;
         FIg_set_state(me->form_ptr,G_DEV,1); 
         FIg_set_default_value(me->form_ptr,G_DEV,(double)1);
         FIg_display(me->form_ptr,G_WIDTH_TXT); 
         FIg_display(me->form_ptr,G_WIDTH); 
         if ((j=VLseekFields(list_att,nb,N_ATT_TST_W)) != -1) {
           me->width = list_att[j].desc.value.att_exp;
           j = 1;
           status = co$cvt_imp_to_alias(msg = &loc_msg,
                                        unit_type = GRIO_DISTANCE,
                                        working_units = &me->width,
                                        osnum =  me->ModuleInfo.md_id.osnum,
                                        num_alias = &j,
                                        cvt_list = pt_name);

           j=0;
           while (pt_name[j] != ' ') j++;
           pt_name[j] = '\0';
           FIfld_set_text(me->form_ptr,G_WIDTH,0,
                          0, pt_name,FALSE);
           FIfld_set_default_text(me->form_ptr,G_WIDTH,
                                  0,0,pt_name,0,0);
        }
      }
      else {
        me->old_dev=me->dev = 0;
         FIg_set_state(me->form_ptr,G_DEV,0); 
      }
    
      if ((j=VLseekFields(list_att,nb,N_ATT_LEN_ALONG)) != -1) {
        me->length = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->length,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = pt_name);

        j=0;
        while (pt_name[j] != ' ') j++;
        pt_name[j] = '\0';
      }
      FIfld_set_text(me->form_ptr,G_LENGTH,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_LENGTH,
                             0,0,pt_name,0,0);
      if ((j=VLseekFields(list_att,nb,N_ATT_AL_VAL)) != -1) {
        me->allowence = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->allowence,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = pt_name);

        j=0;
        while (pt_name[j] != ' ') j++;
        pt_name[j] = '\0';
      }
      else
        strcpy(pt_name,"No");
      FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,
                             0,0,pt_name,0,0);
      if ((j=VLseekFields(list_att,nb,N_ATT_EXTRA_AL)) != -1) {
        me->ext_allow = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->ext_allow,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = pt_name);

        j=0;
        while (pt_name[j] != ' ') j++;
        pt_name[j] = '\0';
      }
      else
        strcpy(pt_name,"No");
      FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,
                             0,0,pt_name,0,0);

      if (count - INDEX_START_CL > om$dimension_of(varray = me->cl_line))
        om$vla_set_dimension(varray = me->cl_line,
				size = count-INDEX_START_CL);
      if (count - INDEX_START_CL > om$dimension_of(varray = me->old_cl_line))
        om$vla_set_dimension(varray = me->old_cl_line,
				size = count-INDEX_START_CL);
      if (count - INDEX_START_CL > om$dimension_of(varray = me->num_cl_line))
        om$vla_set_dimension(varray = me->num_cl_line,
				size = count-INDEX_START_CL);
      for (i=INDEX_START_CL,j=0; i<count; i++,j++)
      { 
        me->cl_line[j] = list[i];
        me->num_cl_line[j] = j;
        me->old_cl_line[j] = list[i];
        if(!VLgetName(&list[i], pt_name)) {
          strcpy(pt_name,"Defined");
        }
        FIfld_set_text(me->form_ptr,G_LIST_WATER,j,
                       0, pt_name,FALSE);
        FIfld_set_default_text(me->form_ptr,G_LIST_WATER,
                               j,0,pt_name,0,0);
      }
      me->nb_cl_line = j;
      me->old_nb_cl_line = j;
      me->old_to_modify = me->to_modify;
  quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    ASend_fence();
    FIg_set_state_off(me->form_ptr,G_MODIF);
    me->locate_modif = 0;
    return OM_S_SUCCESS;
}

end implementation VLbutLinCmd;

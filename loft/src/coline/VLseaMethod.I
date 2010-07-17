/* 
  File           VLseaMethod.I 
  Creation Date  November 92
  Auteur         Ghassan Jahmi

*/

class implementation VLseaLinCmd;

#include <math.h>
#include "AS_status.h"
#include "coparamac.h"
#include "expmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "csmacros.h"
#include "grdpbmacros.h"
#include "lcdef.h"
#include "ex.h"
#include "expression.h"
#include "DItypedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vlmsg.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DIdef.h"
#include "parametric.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#define EPS 0.000001

extern GRclassid OPP_VLbutLine_class_id;
extern GRclassid OPP_VLseaLine_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GRgencs_class_id;
extern GRclassid OPP_expression_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern struct GRid NULL_GRID;
extern VLinitCnst();
extern VLcreatePtInter();
extern MAinvmx();
extern MAmulmx();
extern struct GRid MANwk_hull;
from GRgraphics import GRdelete;
from ACncpx import ACmplace;
from GRvg import GRgetname;
from GRvg import GRchgname;
from NDnode import NDget_objects;
from NDnode import ASreturn_go;
from NDnode import NDchange_connect;
from NDnode import NDconnect;
from NDnode import NDdisconnect;
from NDnode import NDchg_state;
from GR3dpoint import GRcenter;
from GRgraphics import GRaltconstruct;
from NDmacro import ACreturn_foot;
from ACcpx import find_macro;
from ACcpx_defn import ACgive_name;
from NDmacro import ACgive_structure;
from ACrg_collect import ACadd_list_attribute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import AClist_attribute;
from GRvg import GRputsymb;

method form_notification ( int form_label ; int gadget_label ; double value ;
			   char * form_ptr )
{
int		loc_msg,rep;
IGRlong		status, msg;
int	        i,j,row, pos;
char	        array[200];
struct GRid	tmp;
int	        r_pos,sel_flag;
GRclassid 	cid;
IGRpoint	pnt;

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message VLseaLinCmd.VLsave_all(&msg),
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
      status = om$send(msg = message VLseaLinCmd.VLsave_all(&msg),
		       targetid = my_id);
     
      if(!(status & msg & 1))
      { 
	FIg_set_state_off(me->form_ptr,FI_EXECUTE);
	ex$message( msgnumb = VL_E_BadPlc);
	goto quit;
      }
      FIg_set_state_off(me->form_ptr,FI_EXECUTE);
      /*_put_response(resp = RET_INFO);*/
      break;

   case FI_CANCEL: 
      _put_response(resp = TERMINATE);
      break;
     
    case FI_RESET: 
      me->previous = me->old_previous;
      me->cs = me->old_cs;
      me->hull = me->old_hull;
      me->to_modify = me->old_to_modify;
      me->dev = me->old_dev;
      me->pt_select = me->old_pt_select;
      me->allow_dir = me->old_allow_dir;
      me->point2 = me->old_point2;
      me->point2_tst = me->old_point2_tst;
      me->test_vec[0] = me->old_test_vec[0];
      me->test_vec[1] = me->old_test_vec[1];
      me->test_vec[2] = me->old_test_vec[2];
      if (me->old_nb_cl_line > om$dimension_of(varray = me->cl_line))
      om$vla_set_dimension(varray = me->cl_line,size = me->old_nb_cl_line);
      me->nb_cl_line = me->old_nb_cl_line;
      for (i=0; i<me->old_nb_cl_line; i++)
	me->cl_line[i] = me->old_cl_line[i];
      if (me->mytype == 1) {
        FIg_erase(me->form_ptr,G_TESTVEC);
        FIg_erase(me->form_ptr,G_TEST);
      }
      FIg_set_state_off(me->form_ptr,FI_RESET);
      FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_WIDTH,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_WIDTH2,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_LAW,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_DIVISOR,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_ALLOWENCE,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_ALLOW_DIR,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_EXTRA_ALLOW,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_HULL_NAME,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_SEAM_NAME,0,
                        0, "",FALSE);
      FIfld_set_text(me->form_ptr,G_SEL_PT_NAME,0,
                        0, "",FALSE);
      FIfld_get_num_rows(me->form_ptr,G_LIST_BUTT,&rep);
      for(i=0; i<rep; ++i)
      FIfld_set_text(me->form_ptr,G_LIST_BUTT,i,
                   0, "",FALSE);
      FIg_erase(me->form_ptr,G_ITER_TXT);
      FIg_erase(me->form_ptr,G_ITER);
      _put_response(resp = RESET_SEAM);
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
	 ex$message( msgnumb = VL_E_InvName , buff = array);
	 FIg_set_text(me->form_ptr,FI_MSG_FIELD,array);
	 FIg_set_text(me->form_ptr,G_PREV_NAME,"");
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
				superclassid = OPP_VLseaLine_class_id )
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
      FIfld_get_active_row(me->form_ptr,G_LIST_BUTT,&row,&pos);
      FIfld_get_text(me->form_ptr,G_LIST_BUTT,row,0,
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
	status = om$send(msg = message VLseaLinCmd.VLadd_1_cl_line(
						&loc_msg,
						&tmp,
						OPP_VLbutLine_class_id),
			 targetid = my_id);
	if (!(status & loc_msg&1)) {
	  goto LAB;
	}
       FIg_set_state_off(me->form_ptr,G_ADD);
       goto quit;
      }
LAB : for (i=0; i<me->nb_cl_line;i++)
      {
	me->DisplayMode = GRhd;
        VLdispObj(&me->cl_line[i],&me->ModuleInfo,&me->DisplayMode,0);
      }
      _put_response(resp = ADD);
      break;

     case G_TESTVEC :
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

      FIg_get_text(me->form_ptr,G_TESTVEC,array);
      if (
	  !strcmp(array,"y") || !strcmp(array,"-y") || !strcmp(array,"z")
	  || !strcmp(array,"-z")||
	  !strcmp(array,"Y") || !strcmp(array,"-Y") || !strcmp(array,"Z")
	  || !strcmp(array,"-Z") ||
	  !strcmp(array,"+Y") || !strcmp(array,"+y") || !strcmp(array,"+Z")
	  || !strcmp(array,"+z") || !strcmp(array,"No")
                 || !strcmp(array,"no")
	 ) {
	status = om$send(msg = message VLseaLinCmd.VLparse_str_tst(&loc_msg,array),
			 targetid = my_id);

	if(!(status & loc_msg & 1))
	{
	  ex$message(msgnumb = VL_E_BadDir);
	  goto quit;
	}
      }
      else {
	if (!strcmp(array,"others")) {
	  _put_response(resp = TEST);
	  goto quit;
	} 
	else {
	      vds$translate (objname = array,
			     p_objid = &tmp.objid,
			     p_osnum = &tmp.osnum );
	      if( tmp.objid == NULL_OBJID) {
		ex$message( msgnumb = VL_E_BadObj);
		FIg_set_text(me->form_ptr,G_TESTVEC,"");
		goto quit;
	      }
	      if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
		ex$message(msgnumb = VL_E_ObjOutCurr);
		FIg_set_text(me->form_ptr,G_TESTVEC,"");
		goto quit;
	      }
	       om$get_classid(osnum = tmp.osnum,
				objid = tmp.objid,
				p_classid = &cid);

        	if (!me->point2_tst) {/* if it is the first test vector point */
		  if (om$is_ancestry_valid(subclassid     = cid,
			       superclassid = OPP_GR3dpoint_class_id )
			== OM_S_SUCCESS ) {
		    me->DisplayMode = GRhd;
	                   VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);
		    status = om$send(msg = message GRvg.GRcenter(
					   &msg, 
					   &me->ModuleInfo.md_env.matrix_type,
					   me->ModuleInfo.md_env.matrix,
					   me->test_vec),
			  targetid = tmp.objid,
			  targetos = tmp.osnum);
		     if (!(status&msg&1)) {
		       ex$message(msgnumb = VL_E_ConsTstFail);
		     }
		      me->point2_tst = 1;/* next point will be the second one */
		      _put_response(resp = POINT_TST);
		  }
		  else {
		    ex$message( msgnumb = VL_E_BadObj);
		    FIg_set_text(me->form_ptr,G_TESTVEC,"");
		    goto quit;
		  }
		}
		else {
		  if (om$is_ancestry_valid(subclassid     = cid,
			       superclassid = OPP_GR3dpoint_class_id )
			== OM_S_SUCCESS ) {
		    me->DisplayMode = GRhd;
	                   VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);
		    status = om$send(msg = message GRvg.GRcenter(
					   &msg, 
					   &me->ModuleInfo.md_env.matrix_type,
					   me->ModuleInfo.md_env.matrix,
					   pnt),
			  targetid = tmp.objid,
			  targetos = tmp.osnum);
		     if (!(status&msg&1)) {
		       ex$message(msgnumb = VL_E_ConsTstFail);
		     }
		     me->test_vec[0] = pnt[0] - me->test_vec[0];
		     me->test_vec[1] = pnt[1] - me->test_vec[1];
		     me->test_vec[2] = pnt[2] - me->test_vec[2];
		    _put_response(resp = MOD);
		    me->point2_tst = 0;
		  }
		  else {
		    ex$message( msgnumb = VL_E_BadObj);
		    FIg_set_text(me->form_ptr,G_TESTVEC,"");
		    goto quit;
		  }
		}
	      }
	    }
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
                  break;
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
                   break;
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
      if (me->locate_modif) {
	FIg_set_state_off(me->form_ptr,G_MODIF);
	me->locate_modif = 0;
      }
      if (me->hull.objid != NULL_OBJID) {
        me->DisplayMode = GRhd;
        VLdispObj(&me->hull,&me->ModuleInfo,&me->DisplayMode,1);
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
       _put_response(resp = MOD);
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
       FIfld_get_active_row(me->form_ptr,G_LIST_BUTT,&row,&pos);
       i=0; pos = -1;
       while (i<me->nb_cl_line && row >= me->num_cl_line[i]) {
         if (row == me->num_cl_line[i]) pos = i;
         i++;
       }
       for (j=i; j<me->nb_cl_line;j++)
       {
         (me->num_cl_line[j])--;
       }
       if (pos >= 0) {
          if (pos + 1 < me->nb_cl_line) {
            memcpy(&me->cl_line[pos],&me->cl_line[pos+1],
                              (me->nb_cl_line - pos -1)*sizeof(struct GRid));
            memcpy(&me->num_cl_line[pos],&me->num_cl_line[pos+1],
                              (me->nb_cl_line - pos -1)*sizeof(int));
          }
          me->nb_cl_line--;
       }
      FIfld_get_num_rows(me->form_ptr,G_LIST_BUTT,&rep);
      FIfld_delete_rows(me->form_ptr,G_LIST_BUTT,row,1);
      if (row >= rep-1 && row)
        FIfld_pos_cursor(me->form_ptr,G_LIST_BUTT,row-1,0,0,0,0,0);
      else
        FIfld_pos_cursor(me->form_ptr,G_LIST_BUTT,row,0,0,0,0,0);
      FIg_set_state_off(me->form_ptr,G_DELETE);
      break;

     case G_LIST_BUTT :
       FIfld_get_active_row(me->form_ptr,G_LIST_BUTT,&row,&pos);
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
      if (me->locate_modif) {
        FIg_set_state_on(me->form_ptr,G_MODIF);
      }
      else me->locate_modif = 1;
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
       FIg_get_state(me->form_ptr,G_DEV,&me->dev);
       if (me->dev) {
         FIg_display(me->form_ptr,G_ITER_TXT);
         FIg_display(me->form_ptr,G_ITER);
       }
       else {
         FIg_erase(me->form_ptr,G_ITER_TXT);
         FIg_erase(me->form_ptr,G_ITER);
       }
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
      _put_response(resp = MOD_D);
      break;
  }
 quit:
  return OM_S_SUCCESS;
}
 
method VLsave_all ( int *msg )
{
GRclassid	cid;
IGRlong		status=0,loc_msg=0;
IGRint		suc;
IGRdouble	width=0,width2=-1,allo=0,ext_allo=0,divisor = 0;
IGRdouble	test_value,prod,prod1,val;
struct GRid	buff,buff1,seam,inter;
struct GRid	roots[40],vect_id;
int		bool;
int  		aut,nb_seam,i,stop=0,dev,smooth,/*proj,*/nb_iter = 0;
int		r_pos,sel_flag;
short           prop=0;
char		tmp[200],wid[50],wid2[50],all[50],iter[50], cur_name[50],
                ext_all[50],en[50],law[50];
char		pt_name[100],*mac_name,div[50];
struct GRmd_env vect_env;
IGRdouble	mat[16],vect[4],wld[4],wld1[4];
IGRpoint	pnt;
IGRshort	mat_type;
struct GRmd_env env1,env2;
IGRboolean      put_batch = FALSE;
struct ACrg_coll ACrg[10];
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRint			b_mod;
struct	ret_struct	ptr_rst;
enum	GRdpmode	dpmode=GRbd;

  /* Retrieve parameters in the form and control they are OK */

  *msg = MSFAIL;

  FIg_get_state(me->form_ptr, G_AUTO,&aut);
  FIg_get_text(me->form_ptr,G_WIDTH,wid); 
  sscanf(wid,"%lf",&width);
  FIg_get_text(me->form_ptr,G_ALLOWENCE,all);
  if (strcmp(all,"No"))
    sscanf(all,"%lf",&allo);
  FIg_get_text(me->form_ptr,G_WIDTH2,wid2); 
  if (wid2[0] != '\0')
  {
    sscanf(wid2,"%lf",&width2);
    if(width2 <= allo)
    {
       FIg_set_text(me->form_ptr,FI_MSG_FIELD,
                       "Width2 must be greater than Allowance");
       return OM_S_SUCCESS;
    }
  }
  FIg_get_text(me->form_ptr,G_LAW,law); 
  FIg_get_text(me->form_ptr,G_EXTRA_ALLOW,ext_all);
  if (strcmp(ext_all,"No"))
  sscanf(ext_all,"%lf",&ext_allo);
  FIg_get_text(me->form_ptr,G_DIVISOR,div); 
  if (strcmp(div,"No"))
    sscanf(div,"%lf",&divisor);
  FIg_get_text(me->form_ptr,G_TEST,en); 
  FIg_get_text(me->form_ptr,G_TESTVEC,tmp);
  if (!strcmp(en,"No") || !strcmp(en,"no") ||
      !strcmp(tmp,"No") || !strcmp(tmp,"no"))
    bool = 0;
  else {
    sscanf(en,"%lf",&test_value);
    status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                               unit_type = GRIO_DISTANCE,
                               osnum     = me->ModuleInfo.md_id.osnum,
                               primary = test_value,
                               result  = &test_value);
    if(!(status & loc_msg & 1)) {
      ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
      FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
      goto quit;
    }
    bool = 1;
  }

  status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                             unit_type = GRIO_DISTANCE,
                             osnum     = me->ModuleInfo.md_id.osnum,
                             primary = width,
                             result  = &width);
  if(!(status & loc_msg & 1)) {
    ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
  }
  if (width2 >= 0) {
    status = co$cvt_imp_to_wrk(msg =  &loc_msg,
                               unit_type = GRIO_DISTANCE,
                               osnum     = me->ModuleInfo.md_id.osnum,
                               primary = width2,
                               result  = &width2);
    if(!(status & loc_msg & 1)) {
      ex$message( msgnumb = VL_E_BadPlc, buff = tmp);
      FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    }
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
  if (
      aut<0 || width<0 || allo<0 || ext_allo<0 || divisor < 0 || 
      me->hull.objid == NULL_OBJID|| me->cs.objid == NULL_OBJID || 
      me->previous.objid == NULL_OBJID || me->nb_cl_line == 0
     ) {
    ex$message( msgnumb = VL_E_InvParam , buff = tmp);
    FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
    goto quit;
  }
  FIg_get_state(me->form_ptr,G_DEV,&dev);
  if (dev) {
    FIg_get_text(me->form_ptr,G_ITER,iter); 
    if (iter[0] != '\0')
      sscanf(iter,"%d",&nb_iter);
  }
  FIg_get_state(me->form_ptr,G_SMOOTH,&smooth);
  //FIg_get_state(me->form_ptr,G_PROJ,&proj);
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
    if (me->allow_dir.objid != me->old_allow_dir.objid || me->allow_dir.osnum !=
 me->old_allow_dir.osnum){
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
    if (
        me->old_dev != dev     || me->length != width   ||
        me->length2 != width2  || strcmp(me->law,law)   ||
        me->divisor != divisor || me->allowence != allo ||
        me->ext_allow!=ext_allo|| me->smooth != smooth  ||
       // me->proj != proj       || 
        me->nb_iter != nb_iter
       ) {
      r_pos = 0;
      strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
      ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
      if (!dev) 
        ACrg[r_pos].desc.value.att_exp = V_ATT_NEXT;
      else 
        ACrg[r_pos].desc.value.att_exp = V_ATT_DEV;
      r_pos++;
      if (dev) {
        strcpy(ACrg[r_pos].name,N_ATT_ITERATION);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = nb_iter;
        r_pos++;
      }
      if (width) {
        strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = width;
        r_pos++;
      }
      if (width2 >= 0 && width2 != width) {
        strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG2);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = width2;
        r_pos++;
      }
      strcpy(ACrg[r_pos].name,N_ATT_LAW);
      ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
      if (!strcmp(law,"linear") || !strcmp(law,"LINEAR"))
        prop = prop | V_ATT_LINEAR;
      else {
        if (!strcmp(law,"cubic") || !strcmp(law,"CUBIC"))
          prop = prop | V_ATT_CUBIC;
        else {
          if (!strcmp(law,"cubic2") || !strcmp(law,"CUBIC2"))
            prop = prop | V_ATT_CUBIC2;
          else
            if(!strcmp(law,"quintic")||!strcmp(law,"QUINTIC"))
              prop = prop | V_ATT_QUINTIC;
        }
      }
      if (smooth) prop = prop | V_ATT_S_LISS;
      //if (proj) prop = prop | V_ATT_S_PROJ;
      ACrg[r_pos].desc.value.att_exp = prop;
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
      if (divisor) {
        strcpy(ACrg[r_pos].name,N_ATT_DIVISOR);
        ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[r_pos].desc.value.att_exp = divisor;
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
      me->allowence = allo;
      me->divisor = divisor;
      me->ext_allow = ext_allo;
      me->old_dev = dev;
      me->dev = dev;
      me->length = width;
      me->length2 = width2;
      strcpy(me->law,law);
      me->smooth = smooth;
      //me->proj = proj;
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
        om$vla_set_dimension(varray = me->old_cl_line,size = me->nb_cl_line);
      me->old_nb_cl_line = me->nb_cl_line;
      for (i=0; i<me->nb_cl_line; i++)
        me->old_cl_line[i] = me->cl_line[i];
    }
    FIg_get_text(me->form_ptr,G_SEAM_NAME,tmp);
    if(!VLgetName(&me->to_modify, pt_name)) {
      if (strcmp(tmp,"Defined")) {
        status = om$send(msg    = message VLseaLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "seam",
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
         status = om$send(msg    = message VLseaLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "seam",
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
      status = nd$wait_batch(type       = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &my_grid,
                             l_obj_info  = &cn_type );
   
       nd$mod_batch(request     = ND_INQ,
                    p_ret_mode  = &b_mod );

	if( b_mod != ND_DEFER ){

 	     ex$message(msgnumb = VL_E_ModSeam);
	      nd$exec_batch();
          status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_CONTENTS,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid = me->to_modify.objid,
                                targetos = me->to_modify.osnum );
          if ((status&loc_msg&1)) {
            status = om$send(  msg     = message NDmacro.ACgive_structure(
                                            &suc,
					    NULL,
                                            N_ATT_MR_LEN,
                                            &ptr_rst,
                                            &me->ModuleInfo),
                                targetid = vect_id.objid,
                                targetos = vect_id.osnum );
	    if ((status&suc&1)) {
               val = ptr_rst.var.root_pm_st.value;
               status = om$send(  msg     = message NDmacro.ACgive_structure(
                                            &suc,
					    NULL,
                                            N_ATT_MR_WID,
                                            &ptr_rst,
                                            &me->ModuleInfo),
                                targetid = vect_id.objid,
                                targetos = vect_id.osnum );
	       if ((status&suc&1)) {
                  ex$message(msgnumb = VL_E_SeamWL,type = "%s%.2lf%.2lf",
                       var = `pt_name,val,ptr_rst.var.root_pm_st.value`); }
	    }
          }
	}
      ex$message(msgnumb = VL_E_SeamMod);
    }
  }
  else {
  /* Construct ACrg_collection */
  r_pos = 0;
  strcpy(ACrg[r_pos].name,N_ATT_SELECTOR);
  ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
  if (dev)
    ACrg[r_pos].desc.value.att_exp = V_ATT_DEV;
  else 
    ACrg[r_pos].desc.value.att_exp = V_ATT_NEXT;
  r_pos++;
  if (dev && nb_iter >= 0) {
    strcpy(ACrg[r_pos].name,N_ATT_ITERATION);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = nb_iter;
    r_pos++;
  }
  if (width) {
    strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = width;
    r_pos++;
  }
  if (width2 >= 0 && width2 != width) {
    strcpy(ACrg[r_pos].name,N_ATT_LEN_ALONG2);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = width2;
    r_pos++;
  }
  if (!strcmp(law,"linear") || !strcmp(law,"LINEAR"))
    prop = prop |V_ATT_LINEAR;
  else {
    if (!strcmp(law,"cubic") || !strcmp(law,"CUBIC"))
      prop = prop | V_ATT_CUBIC;
    else {
      if (!strcmp(law,"cubic2") || !strcmp(law,"CUBIC2"))
        prop = prop | V_ATT_CUBIC2;
      else
        if(!strcmp(law,"quintic")||!strcmp(law,"QUINTIC"))
          prop = prop | V_ATT_QUINTIC;
    }
  }
  if (smooth) prop = prop | V_ATT_S_LISS;
  //if (proj) prop = prop | V_ATT_S_PROJ;
  strcpy(ACrg[r_pos].name,N_ATT_LAW);
  ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[r_pos].desc.value.att_exp = prop;
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
  if (divisor) {
    strcpy(ACrg[r_pos].name,N_ATT_DIVISOR);
    ACrg[r_pos].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[r_pos].desc.value.att_exp = divisor;
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
  FIg_get_text(me->form_ptr,G_DIRECTION,tmp);
  if (!strcmp(tmp,"previous")) {
  status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_TG,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid = me->previous.objid,
                                targetos = me->previous.osnum);
  if (!(status&loc_msg&1)) {
     ex$message( msgnumb = VL_E_ConsCsFail , buff = tmp);
     FIg_set_text(me->form_ptr,FI_MSG_FIELD,tmp);
     goto quit;
  }
 vect_env = me->ModuleInfo;
 vect_env.md_id.osnum    = vect_id.osnum;
 as$make_source( go_grid = vect_id,
                 mod_env = &vect_env,
                as_os   = me->ModuleInfo.md_id.osnum,
               as_grid = &me->cs );
 }
  roots[INDEX_CS]             = me->cs;

  for (i=0; i<me->nb_cl_line;i++)
    roots[i+INDEX_START_CL] = me->cl_line[i];
  nb_seam = 1;
  while (!stop) {
    seam.osnum = me->ModuleInfo.md_id.osnum;
    status = om$construct( classid = OPP_VLseaLine_class_id,
                           osnum   = seam.osnum,
                           p_objid = &seam.objid );
    if (!(status&1)) {
      ex$message( msgnumb = VL_E_BadPlc );
      goto quit;
    }
  
    if (!aut){
       ex$message(msgnumb = VL_E_SeamCreat);
    }
    else
      ex$message(msgnumb = VL_E_NextSeam,type = "%d",var = `nb_seam`);
    nb_seam++;
    status = om$send(  msg  = message ACncpx.ACmplace(
                                          &suc, 
                                          AChdr_noprotect|AChdr_nodisplay, 0,
                                          SEAM_DEF_2,
                                          INDEX_START_CL+ me->nb_cl_line,
					  roots,
                                          &me->ModuleInfo ),
                          targetid = seam.objid,
                          targetos = seam.osnum );
    if (!(status & suc & 1)) {
      if (aut) {
        ex$message( msgnumb = VL_E_EndAutPlac );
      }
      else {
        ex$message( msgnumb = VL_E_BadPlc );
      }
      om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
              targetid = seam.objid,
              targetos = seam.osnum );
      stop = 1;
    }

    if (!stop && bool && aut) {
        /* find the limit point */
      status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_PT_LIM,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid = seam.objid,
                                targetos = seam.osnum );
      if (!(status&loc_msg&1)) {
        ex$message(msgnumb = VL_E_ConsTstFail);
        goto quit;
      }
      status = om$send(msg = message GRvg.GRcenter(&loc_msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                           me->ModuleInfo.md_env.matrix,
                                           pnt),
                          targetid = vect_id.objid,
                          targetos = vect_id.osnum);
      vect[0] = pnt[0]; vect[1] = pnt[1]; vect[2] = pnt[2]; vect[3] = 1;
      if (!VLconvertCoord(&me->ModuleInfo,vect,wld,1))
        goto quit;

    /* find if previous is a Base seam or a Next one */
      status = om$send(msg = message ACcpx.find_macro(&buff),
                       targetid = me->previous.objid,
                       targetos = me->previous.osnum);
      if (!(status&loc_msg&1)) {
        ex$message( msgnumb = VL_E_BadPlc);
	goto quit;
      }
      status = om$send(msg = message ACcpx_defn.ACgive_name(&mac_name),
                          targetid = buff.objid,
                          targetos = buff.osnum);

      if (!strcmp(mac_name,SEAM_DEF_1)) {
         /* if it is a Base seam find its intersection point with the first
            butt ; this point will be used to the stop test */

        status = om$send(  msg = message NDnode.ASreturn_go(
						&buff,&mat_type,mat),
                          targetid = me->previous.objid,
                          targetos = me->previous.osnum);
        if (!(status&1)) {
          ex$message(msgnumb = VL_E_ConsTstFail);
          goto quit;
        }
        env1.md_env.matrix_type = mat_type;
        for (i=0;i<16;i++)
          env1.md_env.matrix[i] = mat[i];
        env1.md_id.objid = me->ModuleInfo.md_id.objid;
        env1.md_id.osnum = buff.osnum;
        status = om$send(  msg = message NDnode.ASreturn_go(
						&buff1,&mat_type,mat),
                          targetid = me->cl_line[0].objid,
                          targetos = me->cl_line[0].osnum);
        if (!(status&1)) {
          ex$message(msgnumb = VL_E_ConsTstFail);
          goto quit;
        }
        env2.md_env.matrix_type = mat_type;
        for (i=0;i<16;i++)
          env2.md_env.matrix[i] = mat[i];
        env2.md_id.objid = me->ModuleInfo.md_id.objid;
        env2.md_id.osnum = buff1.osnum;

        status = VLcreatePtInter(&loc_msg,&buff,&env1,&buff1,&env2,
				    &inter,&me->ModuleInfo);
        if (!(status&loc_msg&1)) {
          ex$message(msgnumb = VL_E_ConsTstFail);
          goto quit;
        }
        status = om$send(msg = message GRvg.GRcenter(&loc_msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                           me->ModuleInfo.md_env.matrix,
                                           pnt),
                          targetid = inter.objid,
                          targetos = inter.osnum);
        vect[0] = pnt[0]; vect[1] = pnt[1]; vect[2] = pnt[2]; vect[3] = 1;
        if(!VLconvertCoord(&me->ModuleInfo,vect,wld1,1))
          goto quit;
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = inter.objid,
                targetos = inter.osnum );
      }
      else {
        /* find the limit point */
      status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_PT_LIM,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid =  me->previous.objid,
                                targetos =  me->previous.osnum );
      if (!(status&loc_msg&1)) {
        ex$message(msgnumb = VL_E_ConsTstFail);
        goto quit;
      }
      status = om$send(msg = message GRvg.GRcenter(&loc_msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                           me->ModuleInfo.md_env.matrix,
                                           pnt),
                          targetid = vect_id.objid,
                          targetos = vect_id.osnum);
      vect[0] = pnt[0]; vect[1] = pnt[1]; vect[2] = pnt[2]; vect[3] = 1;
      if (!VLconvertCoord(&me->ModuleInfo,vect,wld1,1))
        goto quit;

      }

      FIg_get_text(me->form_ptr,G_TESTVEC,tmp);
      if (strcmp(tmp,"y") && strcmp(tmp,"z")) {
        vect[0] = me->test_vec[0]; vect[1] = me->test_vec[1]; 
	vect[2] = me->test_vec[2]; vect[3] = 0;
        if (!VLconvertCoord(&me->ModuleInfo,vect,me->test_vec,1))
          goto quit;
      }
      prod=sqrt(me->test_vec[0]*me->test_vec[0]+me->test_vec[1]*me->test_vec[1]+
	        me->test_vec[2]*me->test_vec[2]);
      if (prod > EPS) {
        me->test_vec[0] = me->test_vec[0]/prod;
        me->test_vec[1] = me->test_vec[1]/prod;
        me->test_vec[2] = me->test_vec[2]/prod;
      }
      prod=me->test_vec[0]*wld[0]+me->test_vec[1]*wld[1]+me->test_vec[2]*wld[2];
      prod1=me->test_vec[0]*wld1[0]+me->test_vec[1]*wld1[1]+
            me->test_vec[2]*wld1[2];
      if ((prod < test_value && test_value < prod1)
          || (prod1 < test_value && test_value < prod)
         ) {
        stop = 1;
        om$send(msg = message GRgraphics.GRdelete(&loc_msg,&me->ModuleInfo),
                targetid = seam.objid,
                targetos = seam.osnum );
      }
    }
    if (!stop) {
       if (!aut) ex$message(msgnumb = VL_E_SeamCreated);
       FIg_get_text(me->form_ptr,G_SEAM_NAME,pt_name);
       if (pt_name[0])
         FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                        0, pt_name,FALSE);
       else
         FIfld_set_text(me->form_ptr,G_PREV_NAME,0,
                        0, "Defined",FALSE);
         status = om$send(msg    = message VLseaLinCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                pt_name,
                                                "seam",
                                                &me->hull,
                                                seam ,
						&dpmode),
                        targetid = my_id );
       if(!(status & loc_msg & 1))
         ex$message(msgnumb = VL_E_BadChgName);
    
      status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_CONTENTS,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid = seam.objid,
                                targetos = seam.osnum );
      if ((status&loc_msg&1)) {
        status = om$send(  msg     = message NDmacro.ACgive_structure(
                                            &suc,
					    NULL,
                                            N_ATT_MR_LEN,
                                            &ptr_rst,
                                            &me->ModuleInfo),
                                targetid = vect_id.objid,
                                targetos = vect_id.osnum );
        if ((status&suc&1)) {
          val = ptr_rst.var.root_pm_st.value;
          status = om$send(  msg     = message NDmacro.ACgive_structure(
                                            &suc,
					    NULL,
                                            N_ATT_MR_WID,
                                            &ptr_rst,
                                            &me->ModuleInfo),
                                targetid = vect_id.objid,
                                targetos = vect_id.osnum );
          if ((status&suc&1)) {
            ex$message(msgnumb = VL_E_SeamWL,type = "%s%.2lf%.2lf",
                         var = `pt_name,val,ptr_rst.var.root_pm_st.value`);
          }
        }
      }
  /* prepare a default name for the next seam */
    FIg_get_text(me->form_ptr,G_SEAM_NAME,cur_name);
    if ( cur_name[0] == '\0' ) strcpy( cur_name, "Seam" );
    status = om$send(msg = message VLseaLinCmd.VLgetSymbDirName(
                                                           &loc_msg,
                                                           "seam",
                                                           &me->hull,
                                                           cur_name,
                                                           &symb,
                                                           tar_dir,
                                                           pt_name),
                      targetid = my_id);
    if (!(status&loc_msg&1))
      ex$message(msgnumb = VL_E_BadChgSymb);
      FIfld_set_text(me->form_ptr,G_SEAM_NAME,0, 0, pt_name,FALSE);
      me->previous = seam;
    }
    if (aut && !stop) {
      roots[INDEX_GR_INFO]      = seam;
           /* find the next direction */
      status = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            N_MF_TG,
                                            &vect_id,
                                            &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix ),
                                targetid = seam.objid,
                                targetos = seam.osnum );
      if (!(status&loc_msg&1)) {
        /* old CS is kept */
      }
      else {
         vect_env = me->ModuleInfo;
         vect_env.md_id.osnum    = vect_id.osnum;
                        as$make_source( go_grid = vect_id,
                                        mod_env = &vect_env,
                                        as_os   = me->ModuleInfo.md_id.osnum, 
                                        as_grid = &roots[INDEX_CS] );
      }
    }
    else stop = 1;
  }
  if (aut) {
     nb_seam = nb_seam - 2;
     ex$message(msgnumb = VL_E_SeamsCreated,type = "%d", var = `nb_seam`);
  }
  }

  /* set defaults used by RESET */
  FIg_get_text(me->form_ptr,G_PREV_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_PREV_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_SEAM_NAME,tmp);
  FIfld_set_default_text(me->form_ptr,G_SEAM_NAME,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_DIRECTION,tmp);
  FIfld_set_default_text(me->form_ptr,G_DIRECTION,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_HULL_NAME,tmp); 
  FIfld_set_default_text(me->form_ptr,G_HULL_NAME,
                         0,0,tmp,0,0);
  FIfld_set_default_text(me->form_ptr,G_WIDTH,
                         0,0,wid,0,0);
  FIfld_set_default_text(me->form_ptr,G_WIDTH2,
                         0,0,wid2,0,0);
  FIfld_set_default_text(me->form_ptr,G_LAW,
                         0,0,law,0,0);
  FIg_set_default_value(me->form_ptr,G_AUTO,(double)aut);
  FIfld_set_default_text(me->form_ptr,G_TEST,
                         0,0,en,0,0);
  FIg_get_text(me->form_ptr,G_TESTVEC,tmp);
  FIfld_set_default_text(me->form_ptr,G_TESTVEC,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_ALLOW_DIR,tmp);
  FIfld_set_default_text(me->form_ptr,G_ALLOW_DIR,
                         0,0,tmp,0,0);
  FIg_get_text(me->form_ptr,G_SEL_PT_NAME,tmp);
  FIfld_set_default_text(me->form_ptr,G_SEL_PT_NAME,
                         0,0,tmp,0,0);
  FIfld_set_default_text(me->form_ptr,G_ALLOWENCE,
                         0,0,all,0,0);
  FIfld_set_default_text(me->form_ptr,G_DIVISOR,
                         0,0,div,0,0);
  FIfld_set_default_text(me->form_ptr,G_EXTRA_ALLOW,
                         0,0,ext_all,0,0);
  FIfld_set_default_text(me->form_ptr,G_ITER,
                         0,0,iter,0,0);
  FIg_set_default_value(me->form_ptr,G_DEV,(double)dev);
  FIg_set_default_value(me->form_ptr,G_SMOOTH,(double)smooth);
  //FIg_set_default_value(me->form_ptr,G_PROJ,(double)proj);
  me->old_dev = me->dev;
  me->old_previous = me->previous;
  me->old_cs = me->cs;
  MANwk_hull = me->old_hull = me->hull;
  me->old_to_modify = me->to_modify;
  me->old_pt_select = me->pt_select;
  me->old_allow_dir = me->allow_dir;
  me->old_point2 = me->point2;
  me->old_point2_tst = me->point2_tst;
  me->old_test_vec[0] = me->test_vec[0];
  me->old_test_vec[1] = me->test_vec[1];
  me->old_test_vec[2] = me->test_vec[2];
  if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
    om$vla_set_dimension(varray = me->old_cl_line,size = me->nb_cl_line);
  me->old_nb_cl_line = me->nb_cl_line;
  for (i=0; i<me->nb_cl_line; i++)
    me->old_cl_line[i] = me->cl_line[i];

  FIfld_get_num_rows(me->form_ptr,G_LIST_BUTT,&nb_seam);
  for (i=0; i<nb_seam; i++)
  {
    FIfld_get_text(me->form_ptr,G_LIST_BUTT,i,0,
                   200,tmp, &sel_flag,&r_pos);
    FIfld_set_default_text(me->form_ptr,G_LIST_BUTT,i,
                           0, tmp,FALSE);
  }
    *msg = MSSUCC;
  quit :
    return OM_S_SUCCESS;
}

method VLcontrol_seam (int *sts)
{
struct GRid             seam,list[100];
int                     i,j,nb;
int                     loc_msg,count;
IGRlong			msg;
GRclassid               cid;
char                    pt_name[250];
IGRlong                 status;
struct ACrg_coll        list_att[20];
short			prop=0;

      seam = me->event1.located_object[0].located_obj;
       me->to_modify = seam;
       status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,list,100,
                                                           NULL, NULL,
							   OM_K_MAXINT, &count),
                                targetid = seam.objid,
                                targetos = seam.osnum);
      if (!(status&1)) {
        ex$message(msgnumb = VL_E_BadParent);
        goto quit;
      }
      if(VLgetName(&seam, pt_name)) {
        FIfld_set_text(me->form_ptr,G_SEAM_NAME,0,
                       0, pt_name,FALSE);
        FIfld_set_default_text(me->form_ptr,G_SEAM_NAME,
                               0,0,pt_name,0,0);
      }
      else {
        FIfld_set_text(me->form_ptr,G_SEAM_NAME,0,
                       0, "",FALSE);
        FIfld_set_default_text(me->form_ptr,G_SEAM_NAME,
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
        if (!VLfindDirectName(&me->cs,pt_name,&me->ModuleInfo,2)) {
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
         me->old_dev =1;
         FIg_set_state(me->form_ptr,G_DEV,1); 
         if ((j=VLseekFields(list_att,nb,N_ATT_ITERATION)) != -1) {
           me->nb_iter = list_att[j].desc.value.att_exp;
           FIg_display(me->form_ptr,G_ITER_TXT);
           FIg_display(me->form_ptr,G_ITER);
           sprintf(pt_name,"%d",me->nb_iter);
           FIfld_set_text(me->form_ptr,G_ITER,0,
                          0, pt_name,FALSE);
           FIfld_set_default_text(me->form_ptr,G_ITER,
                                  0,0,pt_name,0,0);
         }
         else {
           FIfld_set_text(me->form_ptr,G_ITER,0,
                          0, "",FALSE);
           FIfld_set_default_text(me->form_ptr,G_ITER,
                                  0,0,"",0,0);
         }
       }
       else {
         me->old_dev = me->dev = 0;
         FIg_set_state(me->form_ptr,G_DEV,0); 
         FIg_erase(me->form_ptr,G_ITER_TXT);
         FIg_erase(me->form_ptr,G_ITER);
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
      FIfld_set_text(me->form_ptr,G_WIDTH,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_WIDTH,
                             0,0,pt_name,0,0);
      if ((j=VLseekFields(list_att,nb,N_ATT_LEN_ALONG2)) != -1) {
        me->length2 = list_att[j].desc.value.att_exp;
        j = 1;
        status = co$cvt_imp_to_alias(msg = &loc_msg,
                                     unit_type = GRIO_DISTANCE,
                                     working_units = &me->length2,
                                     osnum =  me->ModuleInfo.md_id.osnum,
                                     num_alias = &j,
                                     cvt_list = pt_name);
        j=0;
        while (pt_name[j] != ' ') j++;
        pt_name[j] = '\0';
        FIfld_set_text(me->form_ptr,G_WIDTH2,0,
                       0, pt_name,FALSE);
        FIfld_set_default_text(me->form_ptr,G_WIDTH2,
                               0,0,pt_name,0,0);
      }
      else {
        FIfld_set_text(me->form_ptr,G_WIDTH2,0, 0, "",FALSE);
        FIfld_set_default_text(me->form_ptr,G_WIDTH2, 0,0,"",0,0);
      }
      if ((j=VLseekFields(list_att,nb,N_ATT_LAW)) != -1)  {
        prop = list_att[j].desc.value.att_exp;
        if ((prop & V_ATT_LAW_MASK) ==  V_ATT_LINEAR) strcpy(me->law,"linear");
        else {
          if ((prop & V_ATT_LAW_MASK) ==  V_ATT_CUBIC) strcpy(me->law,"cubic");
          else {
            if ((prop & V_ATT_LAW_MASK) ==  V_ATT_CUBIC2) 
              strcpy(me->law,"cubic2");
            else
              if ((prop & V_ATT_LAW_MASK) ==  V_ATT_QUINTIC) 
                strcpy(me->law,"quintic");
          }
        }
        if ((prop & V_ATT_S_PROP_MASK) & V_ATT_S_LISS) me->smooth = 1;
          else me->smooth = 0;
        //if ((prop & V_ATT_S_PROP_MASK) & V_ATT_S_PROJ) me->proj = 1; 
          //else me->proj = 0;
      }
      FIfld_set_text(me->form_ptr,G_LAW,0,
                     0, me->law,FALSE);
      FIfld_set_default_text(me->form_ptr,G_LAW,
                             0,0,me->law,0,0);
      FIg_set_state(me->form_ptr,G_SMOOTH,me->smooth); 
      //FIg_set_state(me->form_ptr,G_PROJ,me->proj); 
      FIg_set_default_value(me->form_ptr,G_SMOOTH,(double)me->smooth);
      //FIg_set_default_value(me->form_ptr,G_PROJ,(double)me->proj);
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
      if ((j=VLseekFields(list_att,nb,N_ATT_DIVISOR)) != -1) {
        me->divisor = list_att[j].desc.value.att_exp;
        sprintf(pt_name,"%.3lf",me->divisor);
      }
      else
        strcpy(pt_name,"No");
      FIfld_set_text(me->form_ptr,G_DIVISOR,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,G_DIVISOR,
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
        FIfld_set_text(me->form_ptr,G_LIST_BUTT,j,
                       0, pt_name,FALSE);
        FIfld_set_default_text(me->form_ptr,G_LIST_BUTT,
                               j,0,pt_name,0,0);
      }
      me->nb_cl_line = j;
      me->old_nb_cl_line = j;
      me->old_to_modify = me->to_modify;
  quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    FIg_set_state_off(me->form_ptr,G_MODIF);
    me->locate_modif = 0;
    ASend_fence();
    return OM_S_SUCCESS;
}

/* locate points for test vector */
method VLcontrol_data_tst (int *sts)
{
struct GRobj_env	*LocatedObjects;
int 			nb_obj;
IGRlong			status, msg;
int			loc_msg;
char                    pt_name[100];
IGRpoint		pnt;

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
	  if (VLgetName(&LocatedObjects[0].obj_id,pt_name))
	    FIg_set_text(me->form_ptr,G_TESTVEC, pt_name);
	  status = om$send(msg = message GRvg.GRcenter(&msg,
					   &me->ModuleInfo.md_env.matrix_type,
					   me->ModuleInfo.md_env.matrix,
					   me->test_vec),
			  targetid = LocatedObjects[0].obj_id.objid,
			  targetos = LocatedObjects[0].obj_id.osnum);
	  if (!(status&msg&1)) {
	    ex$message(msgnumb = VL_E_ConsTstFail);
	    goto quit;
	  }
	  me->point2_tst = 1;
          me->ret = *sts = POINT;
	  goto quit;
       }
    else {
	  status = om$send(msg = message GRvg.GRcenter(&msg,
					   &me->ModuleInfo.md_env.matrix_type,
					   me->ModuleInfo.md_env.matrix,
					   pnt),
			  targetid = LocatedObjects[1].obj_id.objid,
			  targetos = LocatedObjects[1].obj_id.osnum);
	 if (!(status&msg&1)) {
	  ex$message(msgnumb = VL_E_ConsTstFail);
	  me->ret = *sts = MY_ERROR;
	  goto quit;
	}
	me->test_vec[0] = pnt[0] - me->test_vec[0];
	me->test_vec[1] = pnt[1] - me->test_vec[1];
	me->test_vec[2] = pnt[2] - me->test_vec[2];
    }
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  ASend_fence();
  return OM_S_SUCCESS;
}

 /* when a point is located with a GRst_DELTA_WLD 
    or GRst_PREC_WLD subtype for test vector */
method VLcontrol_data1_tst (int *msg)
{
IGRdouble       wld[4],center[4],vect[3];
int             loc_msg;

  *msg = MSFAIL;
  if (me->event1.subtype == GRst_DELTA_WLD) {
    if (!me->point2_tst) { /* if it is the first point */
      me->test_vec[0] = me->event1.event.button.x;
      me->test_vec[1] = me->event1.event.button.y;
      me->test_vec[2] = me->event1.event.button.z;
      me->point2_tst = 1;
    }
    else {
      me->test_vec[0] = me->event1.event.button.x - me->test_vec[0];
      me->test_vec[1] = me->event1.event.button.y - me->test_vec[1];
      me->test_vec[2] = me->event1.event.button.z - me->test_vec[2];
      me->point2_tst = 0;
    }
  }
  else {
    vect[0] = me->event1.event.button.x;
    vect[1] = me->event1.event.button.y;
    vect[2] = me->event1.event.button.z;
    center[0] = 0; center[1] = 0; center[2] = 0; center[3] = 1;
    if (!VLconvertCoord(&me->ModuleInfo,center,wld,0)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      goto quit;
    }
    me->test_vec[0] = vect[0] - wld[0];
    me->test_vec[1] = vect[1] - wld[1];
    me->test_vec[2] = vect[2] - wld[2];
  }
  *msg = MSSUCC;
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLcontrol_pt2_tst (int *sts)
{
struct GRid	point;
IGRlong		status, msg;
int		loc_msg;
char		pt_name[200];
IGRpoint        pnt;

  point = me->event1.located_object[0].located_obj;
  if(VLgetName(&point,pt_name))
    FIg_set_text(me->form_ptr,G_TESTVEC, pt_name);
  status = om$send(msg = message GRvg.GRcenter(&msg,
					     &me->ModuleInfo.md_env.matrix_type,
					     me->ModuleInfo.md_env.matrix,
					     pnt),
			  targetid = point.objid,
			  targetos = point.osnum);
  if (!(status&msg&1)) {
    ex$message(msgnumb = VL_E_ConsTstFail);
    goto quit;
  }
  me->test_vec[0] = pnt[0] - me->test_vec[0];
  me->test_vec[1] = pnt[1] - me->test_vec[1];
  me->test_vec[2] = pnt[2] - me->test_vec[2];

  me->point2_tst = 0;
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLcontrol_exp2_tst (int *sts)
{
IGRpoint	pnt;
char		*str;
struct GRid	obj;
GRclassid	cid;
IGRlong		status, msg;
int		loc_msg;

  str = me->event1.event.keyin;
  if (!VLtestExp(&obj,str,&me->ModuleInfo))
    goto quit;
  om$get_classid(osnum = obj.osnum,
                 objid = obj.objid,
                 p_classid = &cid);

  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GR3dpoint_class_id )
             == OM_S_SUCCESS ) {
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    status = om$send(msg = message GRvg.GRcenter(&msg,
					     &me->ModuleInfo.md_env.matrix_type,
					     me->ModuleInfo.md_env.matrix,
					     pnt),
			  targetid = obj.objid,
			  targetos = obj.osnum);
    if (!(status&msg&1)) {
      ex$message(msgnumb = VL_E_ConsTstFail);
      goto quit;
    }
    FIg_set_text(me->form_ptr,G_TESTVEC,str);
    me->test_vec[0] = pnt[0] - me->test_vec[0];
    me->test_vec[1] = pnt[1] - me->test_vec[1];
    me->test_vec[2] = pnt[2] - me->test_vec[2];
    me->point2_tst = 0;
  }
  else {
    ex$message( msgnumb = VL_E_BadObj);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLcontrol_exp_tst (int *sts)
{
char		*str;
struct GRid	obj;
GRclassid       cid;
IGRlong 	status, msg;
int		loc_msg;

  str = me->event1.event.keyin;
  if (!VLtestExp(&obj,str,&me->ModuleInfo))
    goto quit;
  om$get_classid(osnum = obj.osnum,
                 objid = obj.objid,
                 p_classid = &cid);
  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GR3dpoint_class_id )
             == OM_S_SUCCESS ) {
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    
  status = om$send(msg = message GRvg.GRcenter(&msg,
					     &me->ModuleInfo.md_env.matrix_type,
					     me->ModuleInfo.md_env.matrix,
					     me->test_vec),
			  targetid = obj.objid,
			  targetos = obj.osnum);
  if (!(status&msg&1)) {
    ex$message(msgnumb = VL_E_ConsTstFail);
    goto quit;
  }
    FIg_set_text(me->form_ptr,G_TESTVEC,str);
    me->ret = *sts = POINT;
    me->point2_tst = 1;
  }
  else {
    ex$message( msgnumb = VL_E_BadObj);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLparse_str_tst (int *msg ; char *direction)
{
  *msg = MSFAIL;
  me->test_vec[0] = 0; me->test_vec[1] = 0;
  me->test_vec[2] = 0; me->test_vec[3] = 0;
  if (!strcmp(direction,"No") || !strcmp(direction,"no")) {
    *msg = MSSUCC;
    goto quit;
  }

    if (direction[0] == '-') {
      if (direction[1] == 'z' || direction[1] == 'Z')
	me->test_vec[2] = -1;
      else
	if (direction[1] == 'y' || direction[1] == 'Y') 
	  me->test_vec[1] = -1;
    }
    else {
	if ((direction[0] == 'y' || direction[0] == 'Y') ||
	    (direction[0] == '+' &&(direction[1] == 'y' || direction[1] == 'Y'))
	   )
	    me->test_vec[1] = 1;
	else {
	if ((direction[0] == 'z' || direction[0] == 'Z') ||
	    (direction[0] == '+' &&(direction[1] == 'z' || direction[1] == 'Z'))
	   )
	    me->test_vec[2] = 1;
	  else {
	    ex$message(msgnumb = VL_E_BadDir);
	    goto quit;
	  }
	}
      }

  *msg = MSSUCC;
quit :
  return OM_S_SUCCESS;
}

end implementation VLseaLinCmd;

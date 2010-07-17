class implementation VLplCntrCmd;

#include "msdef.h"
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
#include "DIdef.h"
#include "msmacros.h"
#include "grmacros.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "vsplatedef.h"
#include "vlctrl.h"
#include "vlcntrline.h"

extern struct GRid NULL_GRID;
extern GRclassid OPP_VLctrLine_class_id;
from VLctrLine import  VLcreate;
from VLctrLine import VLget_surf;
from VLctrLine import VLget_attributes;
from VLctrLine import VLset_attributes;
from VLctrLine import VLset_surf;
from NDnode import NDget_objects;
from NDnode import NDconnect;
from NDnode import NDdisconnect;
from NDmacro import ACreturn_foot;
from NDnode import NDdelete;

/* *********************** form_notification *********************** */
/*
/*      Manage gadgets in the form
/*       
/*
/* */
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

  if( form_ptr == NULL ) return( OM_E_INVARG ); 
   
  FIg_set_text(me->form_ptr,FI_MSG_FIELD,"");

  switch( gadget_label )
  {
    case FI_ACCEPT:
      status = om$send(msg = message VLplCntrCmd.VLsave_all(&msg),
 		       targetid = my_id);
     
      if(!(status & msg & 1))
      { 
	FIg_set_state_off(me->form_ptr,FI_ACCEPT);
        ex$message( msgnumb = VL_E_BadPlc,time=0,seconds=0);
	goto quit;
      }
      _put_response(resp = TERMINATE);
      break;
    
    case FI_EXECUTE : 
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
      
      status = om$send(msg = message VLplCntrCmd.VLsave_all(&msg),
		       targetid = my_id);
     
      if(!(status & msg & 1))
      { 
        FIg_set_state_off(me->form_ptr,FI_EXECUTE);
        ex$message( msgnumb = VL_E_BadPlc,time=0,seconds=0);
	goto quit;
      }
      FIg_set_state_off(me->form_ptr,FI_EXECUTE);
      /*_put_response(resp = RET_INFO);*/
      break;

    case FI_CANCEL: 
      _put_response(resp = TERMINATE);
      break;
     
    case FI_RESET: 
      me->to_modify = me->old_to_modify;
      if (me->old_nb_cl_line > om$dimension_of(varray = me->cl_line))
      om$vla_set_dimension(varray = me->cl_line,size = me->old_nb_cl_line);
      me->nb_cl_line = me->old_nb_cl_line;
      for (i=0; i<me->old_nb_cl_line; i++)
        me->cl_line[i] = me->old_cl_line[i];
      FIg_set_state_off(me->form_ptr,FI_RESET);
      break;

    case G_ADD :
      if (me->locate_add) {
        FIg_set_state_on(me->form_ptr,G_ADD);
      }
      else me->locate_add = 1;
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
      FIfld_get_active_row(me->form_ptr,G_LIST_SURF,&row,&pos);
      FIfld_get_text(me->form_ptr,G_LIST_SURF,row,0,
                     200,array, &sel_flag,&r_pos);
      if (array[0] != '\0') {
        vds$translate (objname = array,
                       p_objid = &tmp.objid,
                       p_osnum = &tmp.osnum );
        if( tmp.objid == NULL_OBJID) {
          ex$message( msgnumb = VL_E_BadObj,time=0,seconds=0);
         goto LAB;
        }
	if (tmp.osnum != me->ModuleInfo.md_id.osnum ) {
          ex$message( msgnumb = VL_E_ObjOutCurr,time=0,seconds=0);
          goto LAB;
        }
        me->DisplayMode = GRhd;
        VLdispObj(&tmp,&me->ModuleInfo,&me->DisplayMode,1);
        status = om$send(msg = message VLplCntrCmd.VLadd_1_surf(
						&loc_msg,
						&tmp),
		        	targetid = my_id);
        if (!(status & loc_msg&1)) {
	  goto LAB;
        }
       FIg_set_state_off(me->form_ptr,G_ADD);
       goto quit;
      }
LAB : 
      for (i=0; i<me->nb_cl_line;i++)
      {
        me->DisplayMode = GRhd;
        VLdispObj(&me->cl_line[i].obj_id,&me->ModuleInfo,&me->DisplayMode,0);
      }
      _put_response(resp = ADD);
      break;
    case G_DELETE :
      if (me->locate_del) {
        FIg_set_state_on(me->form_ptr,G_DELETE);
      }
      else me->locate_del = 1;
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_modif) {
        FIg_set_state_off(me->form_ptr,G_MODIF);
        me->locate_modif = 0;
      }
       FIfld_get_active_row(me->form_ptr,G_LIST_SURF,&row,&pos);
       i=0; pos = -1;
       while (i<me->nb_cl_line && row >= me->num_cl_line[i]) {
         if (row == me->num_cl_line[i]) pos = i;
         i++;
       }
                    /* modify position in the gadget */
       for (j=i; j<me->nb_cl_line;j++)
       {
         (me->num_cl_line[j])--;
       }
                 /* erase object from the list */
        if (pos >= 0) {
          if (pos + 1 < me->nb_cl_line) {
            memcpy(&me->cl_line[pos],&me->cl_line[pos+1],
                            (me->nb_cl_line - pos -1)*sizeof(struct GRobj_env));
            memcpy(&me->num_cl_line[pos],&me->num_cl_line[pos+1],
                            (me->nb_cl_line - pos -1)*sizeof(int));
          }
          me->nb_cl_line--;
        }
      FIfld_get_num_rows(me->form_ptr,G_LIST_SURF,&rep);
      FIfld_delete_rows(me->form_ptr,G_LIST_SURF,row,1);
      if (row >= rep-1 && row)
        FIfld_pos_cursor(me->form_ptr,G_LIST_SURF,row-1,0,0,0,0,0);
      else
        FIfld_pos_cursor(me->form_ptr,G_LIST_SURF,row,0,0,0,0,0);
      FIg_set_state_off(me->form_ptr,G_DELETE);
      break;

     case G_LIST_SURF :
       FIfld_get_active_row(me->form_ptr,G_LIST_SURF,&row,&pos);
       for (i=0;i<me->nb_cl_line;i++)
       {
         if (row == me->num_cl_line[i]) break;
       }
       if (i< me->nb_cl_line) {
         me->DisplayMode = GRhd;
         VLdispObj(&me->cl_line[i].obj_id,&me->ModuleInfo,&me->DisplayMode,1);
       }
       break;
     case G_MODIF :
      if (me->locate_modif) {
        FIg_set_state_on(me->form_ptr,G_MODIF);
      }
      else me->locate_modif = 1;
      if (me->locate_add) {
        FIg_set_state_off(me->form_ptr,G_ADD);
        me->locate_add = 0;
      }
      if (me->locate_del) {
        FIg_set_state_off(me->form_ptr,G_DELETE);
        me->locate_del = 0;
      }
      me->DisplayMode = GRhd;
      VLdispObj(&me->to_modify,&me->ModuleInfo,&me->DisplayMode,1);
      _put_response(resp = MOD_D);
      break; 
   }
quit:
  return OM_S_SUCCESS;
}

/* *********************** VLsave_all *********************** */
/*
/*      place and modify control lines.
/*       
/*
/* */
method VLsave_all (int *msg)
{
IGRlong        		 status=0,loc_msg;
IGRint		   	 plate_side,flag;
IGRint			 i,j;
IGRchar		 	 name[100],array[100],tmp[200];
struct GRid		 clline,*old_list,*list;
IGRchar         	 tar_dir[DI_PATH_MAX];
struct  GRsymbology      symb;
IGRint			 b_mod;
IGRboolean      	 put_batch = FALSE;
int             	 r_pos,sel_flag;
enum	GRdpmode	 dpmode=GRbd;

  *msg = MSFAIL;
  FIg_get_state(me->form_ptr,G_PLATE_SIDE,&plate_side);
  if (plate_side == V_ATT_TOP) strcpy(name,VS_K_plTopSfPath);
  if (plate_side == V_ATT_BOTTOM) strcpy(name,VS_K_plBotSfPath);
  FIg_get_state(me->form_ptr,G_ONE_OR_ALL,&flag);
  if (!flag) flag = V_ATT_SINGLE;
  else flag = V_ATT_MULTIPLE;
  FIg_get_text(me->form_ptr,G_DIRECTION,array);

  if (me->mytype == 1) { /* modify */
    if (me->one_or_all != flag || strcmp(me->plate_side,name)
        || me->axis != array[0]) {
                                 /* modify attributes */
      status = om$send(msg = message VLctrLine.VLset_attributes (&loc_msg, name,
							      flag,array[0],
							      &me->box),
			targetid = me->to_modify.objid,
			targetos = me->to_modify.osnum);
      if (!(status&loc_msg&1)) {
        printf("problems in setting attributes\n");
      }
      put_batch = TRUE;
      me->one_or_all = flag; 
      me->axis = array[0]; 
      strcpy(me->plate_side,name);
    }

    old_list = (struct GRid *) malloc(me->old_nb_cl_line*sizeof(struct GRid));
    list = (struct GRid *) malloc(me->nb_cl_line*sizeof(struct GRid));
    for (i=0;i<me->old_nb_cl_line;i++)
    {
      old_list[i] = me->old_cl_line[i].obj_id;
    }
    for (i=0;i<me->nb_cl_line;i++)
    {
      list[i]     = me->cl_line[i].obj_id;
    }
    if (VLmodifyList(me->old_nb_cl_line,old_list,
                   me->nb_cl_line,list)
       ) {
      status = om$send(msg = message VLctrLine.VLset_surf (
						&loc_msg, 
						me->old_nb_cl_line,old_list,
						me->nb_cl_line,list),
			targetid = me->to_modify.objid,
			targetos = me->to_modify.osnum);
      if (!(status&loc_msg&1)) {
        printf("problems in setting surfaces\n");
      }
      put_batch = TRUE;
      if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
        om$vla_set_dimension(varray = me->old_cl_line,
                                                  size = me->nb_cl_line);
      me->old_nb_cl_line = me->nb_cl_line;
      for (i=0; i<me->nb_cl_line; i++)
        me->old_cl_line[i] = me->cl_line[i];
    }
    free(old_list);
    FIg_get_text(me->form_ptr,G_CTRL_NAME,tmp);
    if(!VLgetName(&me->to_modify, name)) {
      if (strcmp(tmp,"Defined")) {
        status = om$send(msg    = message VLplCntrCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                me->to_modify,
                                                &dpmode),
                        targetid = my_id );
      }
    }
    else {
      if (strcmp(name,tmp)) {
        status = om$send(msg    = message VLplCntrCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                me->to_modify,
                                                &dpmode),
                        targetid = my_id );
      }
    }
    if (put_batch) {
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
              nd$exec_batch();
        }
    }
  }
  else {
  FIg_get_text(me->form_ptr,G_CTRL_NAME,tmp);
  if (flag) { /* one control line for all plates */
    clline.osnum = me->ModuleInfo.md_id.osnum;
    status = om$construct(classid = OPP_VLctrLine_class_id,
                          osnum = clline.osnum,
                          p_objid = &clline.objid);
    status = om$send(msg = message VLctrLine.VLcreate(
                                  &loc_msg,array[0],name,
                                  flag, me->nb_cl_line, me->cl_line, NULL,
                                  &me->ModuleInfo),
                      targetid = clline.objid,
                      targetos = clline.osnum);
    if (!(loc_msg&status&1)) {
      ex$message( msgnumb = VL_E_BadPlc,time=0, seconds=0);
      om$send(msg=message NDnode.NDdelete(&(me->ModuleInfo)),
                  targetid = clline.objid,
                  targetos = clline.osnum);
      goto quit;
    }
    status = om$send(msg    = message VLplCntrCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                clline,
                                                &dpmode),
                        targetid = my_id );
    if(!(status & loc_msg & 1))
      ex$message( msgnumb = VL_E_BadChgName,time=0,seconds=0);
    status = om$send(msg = message VLplCntrCmd.VLgetSymbDirName(
                                                &loc_msg,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                "CRTL",
                                                &symb,
                                                tar_dir,
                                                tmp),
                      targetid = my_id);
    if (!(status&loc_msg&1))
      ex$message( msgnumb = VL_E_BadChgSymb,time=0,seconds=0);
  }
  else {  /* one control line per plate */
     for (i=0;i < me->nb_cl_line;i++)
    {
      clline.osnum = me->ModuleInfo.md_id.osnum;
      status = om$construct(classid = OPP_VLctrLine_class_id,
                            osnum = clline.osnum,
                            p_objid = &clline.objid);
      status = om$send(msg = message VLctrLine.VLcreate(
                                  &loc_msg,array[0],name,
                                  flag, 1, &me->cl_line[i], NULL,
                                  &me->ModuleInfo),
                        targetid = clline.objid,
                        targetos = clline.osnum);
      if (!(loc_msg&status&1)) {
        ex$message( msgnumb = VL_E_BadPlc,time=0,seconds=0);
        om$send(msg=message NDnode.NDdelete(&(me->ModuleInfo)),
                    targetid = clline.objid,
                    targetos = clline.osnum);
        goto quit;
      }
      status = om$send(msg    = message VLplCntrCmd.VLsetSymbNameDisp(
                                                &loc_msg,
                                                tmp,
                                                "ctline",
                                                &me->cl_line[i].obj_id,
                                                clline,
                                                &dpmode),
                        targetid = my_id );
      if(!(status & loc_msg & 1))
        ex$message( msgnumb = VL_E_BadChgName,time=0,seconds=0);
      status = om$send(msg = message VLplCntrCmd.VLgetSymbDirName(
                                                &loc_msg,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                "CRTL",
                                                &symb,
                                                tar_dir,
                                                tmp),
                      targetid = my_id);
      if (!(status&loc_msg&1))
        ex$message( msgnumb = VL_E_BadChgSymb,time=0,seconds=0);
    }
  }
    FIfld_set_text(me->form_ptr,G_CTRL_NAME,0,
                   0, tmp,FALSE);
  }
  /* set default used by RESET*/
  FIg_get_text(me->form_ptr,G_CTRL_NAME,tmp);
  FIfld_set_default_text(me->form_ptr,G_CTRL_NAME,
                         0,0,tmp,0,0);
  FIg_set_default_value(me->form_ptr,G_ONE_OR_ALL,(double)flag);
  FIg_set_default_value(me->form_ptr,G_PLATE_SIDE,(double)plate_side);
  FIg_set_default_value(me->form_ptr,G_PLATE_SIDE,(double)plate_side);
  FIg_get_text(me->form_ptr,G_DIRECTION,tmp);
  FIfld_set_default_text(me->form_ptr,G_DIRECTION,
                         0,0,tmp,0,0);

  if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
    om$vla_set_dimension(varray = me->old_cl_line,size = me->nb_cl_line);
  me->old_nb_cl_line = me->nb_cl_line;
  for (i=0; i<me->nb_cl_line; i++)
    me->old_cl_line[i] = me->cl_line[i];

  FIfld_get_num_rows(me->form_ptr,G_LIST_SURF,&j);
  for (i=0; i<j; i++)
  {
    FIfld_get_text(me->form_ptr,G_LIST_SURF,i,0,
                   200,tmp, &sel_flag,&r_pos);
    FIfld_set_default_text(me->form_ptr,G_LIST_SURF,i,
                           0, tmp,FALSE);
  }
  *msg = MSSUCC;
quit :
  return OM_S_SUCCESS;
}

/* *********************** control_surf *********************** */
/*
/*       Receives  located plates or surfaces.
/*       
/*
/* */

method VLcontrol_surf (int *sts)
{
struct GRobj_env	*LocatedObjects;
int 			nb_obj,i,j,sel_flag,r_pos;
int			nb_supprim,count;
char			pt_name[100],array[100];
struct GRid		tmp;
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRlong 		status, loc_msg;

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
    ex$message( msgnumb = VL_E_NoObjLoc,time=0,seconds=0);
    goto quit;
  }
  /* Verify the located objects aren't already in the list */ 
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &tmp);
    for (j=0; j<me->nb_cl_line;j++)
    {
      if (me->cl_line[j].obj_id.objid == tmp.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }
  if (nb_supprim)
      ex$message( msgnumb = VL_E_ObjSuppr, time=0,seconds=0);

  if(nb_obj - nb_supprim + me->nb_cl_line > 
				om$dimension_of( varray = me->cl_line)) {
    om$vla_set_dimension(varray = me->cl_line,size =
                                      nb_obj-nb_supprim+me->nb_cl_line);
  }
  if(nb_obj - nb_supprim + me->nb_cl_line > 
				om$dimension_of( varray = me->num_cl_line)) {
    om$vla_set_dimension(varray = me->num_cl_line,size =
                                      nb_obj-nb_supprim+me->nb_cl_line);
  }

  for (i=0; i<nb_obj; i++) 
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &LocatedObjects[i].obj_id);
    me->cl_line[i+me->nb_cl_line] = LocatedObjects[i];
    /* find the object name */
    if(!VLgetName(&LocatedObjects[i].obj_id,pt_name)) {
      strcpy(pt_name,"Defined");
    }
    /* put name in the gadget */
    FIfld_get_num_rows(me->form_ptr,G_LIST_SURF,&count);
    if (count == 1) {
      FIfld_get_text(me->form_ptr,G_LIST_SURF,0,0,
                     100,array, &sel_flag,&r_pos);
      if (array[0] == '\0') {
        me->num_cl_line[i+me->nb_cl_line] = count-1; /* the line number zero 
							of the gadget*/
        FIfld_set_text(me->form_ptr,G_LIST_SURF,count-1,
                       0, pt_name,FALSE);
        FIfld_pos_cursor(me->form_ptr,G_LIST_SURF,count-1,0,0,0,0,0);
      }
      else {
        me->num_cl_line[i+me->nb_cl_line] = count;
        FIfld_set_text(me->form_ptr,G_LIST_SURF,count,
                       0, pt_name,FALSE);
        FIfld_pos_cursor(me->form_ptr,G_LIST_SURF,count,0,0,0,0,0);
      }
    }
    else {
      me->num_cl_line[i+me->nb_cl_line] = count;
      FIfld_set_text(me->form_ptr,G_LIST_SURF,count,
                     0, pt_name,FALSE);
      FIfld_pos_cursor(me->form_ptr,G_LIST_SURF,count,0,0,0,0,0);
    }
  }
  if (!me->nb_cl_line) { /* the first one */
      /* prepare a default name for the next control line */
    status = om$send(msg = message VLplCntrCmd.VLgetSymbDirName(
                                                &loc_msg,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                "CRTL",
                                                &symb,
                                                tar_dir,
                                                pt_name),
                      targetid = my_id);
    if (!(status&loc_msg&1))
      ex$message( msgnumb = VL_E_BadChgSymb,time=0,seconds=0);
    FIfld_set_text(me->form_ptr,G_CTRL_NAME,0,
                   0, pt_name,FALSE);
  }
  me->nb_cl_line += nb_obj - nb_supprim;
   
  quit :
    ASend_fence();
    return 1;
}

/* *********************** add_1_surf *********************** */
/*
/*  Add one surface in the surfaces list.
/*  
/*
/* */
method VLadd_1_surf (int *msg ; struct GRid *obj)
{
IGRlong			status, loc_msg;
int 			j;
struct GRid		tmp;
IGRchar         	pt_name[100],tar_dir[DI_PATH_MAX];
struct  GRsymbology      symb;

  *msg = MSFAIL; 
  /* Verify the object is'nt already in the list */ 
  as$make_source( go_grid = *obj,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = &tmp);
  for (j=0; j<me->nb_cl_line;j++)
  {
    if (me->cl_line[j].obj_id.objid == tmp.objid)
    {
      ex$message( msgnumb = VL_E_ObjInList,time=0,seconds=0);
      goto quit;
    }
  }

  if(me->nb_cl_line + 1 > om$dimension_of( varray = me->cl_line))
    om$vla_set_dimension(varray = me->cl_line,size =
                                      me->nb_cl_line + 1);

  as$make_source( go_grid = *obj,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = obj);
  me->cl_line[me->nb_cl_line].obj_id = *obj;
  me->cl_line[me->nb_cl_line].mod_env = me->Current;
  if (!me->nb_cl_line) {
    status = om$send(msg = message VLplCntrCmd.VLgetSymbDirName(
                                                &loc_msg,
                                                "ctline",
                                                &me->cl_line[0].obj_id,
                                                "CRTL",
                                                &symb,
                                                tar_dir,
                                                pt_name),
                      targetid = my_id);
    if (!(status&loc_msg&1))
      ex$message( msgnumb = VL_E_BadChgSymb,time=0,seconds=0);
    FIfld_set_text(me->form_ptr,G_CTRL_NAME,0,
                   0, pt_name,FALSE);
  }
  me->nb_cl_line += 1;
   
  *msg = MSSUCC;
  quit :
    return OM_S_SUCCESS;
}

/* *********************** control_line *********************** */
/*
/*       Receives a located control line, searches its attributes and 
/*       fills fields in the form. 
/*
/* */
method VLcontrol_line (int *sts)
{
struct GRid	line;
IGRlong 	status,loc_msg;
IGRchar		pt_name[100];
IGRint		j;

  line = me->event1.located_object[0].located_obj;
  me->to_modify = line;
                                /* Get her name */
  if(VLgetName(&line, pt_name)) {
    FIfld_set_text(me->form_ptr,G_CTRL_NAME,0,
                   0, pt_name,FALSE);
    FIfld_set_default_text(me->form_ptr,G_CTRL_NAME,
                           0,0,pt_name,0,0);
  }

                                     /* get her parents number or plates */
  status = om$send(msg = message VLctrLine.VLget_surf(
						&loc_msg,
						NULL,
						&me->nb_cl_line),
                                targetid = line.objid,
                                targetos = line.osnum);
  if (!(status&loc_msg&1)) {
    printf("problems in getting surfaces\n");
  }
  if (me->nb_cl_line > om$dimension_of(varray = me->cl_line))
    om$vla_set_dimension(varray = me->cl_line, size = me->nb_cl_line);
  if (me->nb_cl_line > om$dimension_of(varray = me->old_cl_line))
  om$vla_set_dimension(varray = me->old_cl_line, size = me->nb_cl_line);

                                     /* get her parent surfaces or plates */
  status = om$send(msg = message VLctrLine.VLget_surf(
						&loc_msg,
						me->cl_line,
						&me->nb_cl_line),
                                targetid = line.objid,
                                targetos = line.osnum);
  if (!(status&loc_msg&1)) {
    printf("problems in getting surfaces\n");
  }
  for (j=0; j<me->nb_cl_line; j++)
  {
    me->num_cl_line[j] = j;
    me->old_cl_line[j].obj_id = me->cl_line[j].obj_id;
    if(!VLgetName(&me->cl_line[j], pt_name)) {
    strcpy(pt_name,"Defined");
    }
    FIfld_set_text(me->form_ptr,G_LIST_SURF,j,
                   0, pt_name,FALSE);
    FIfld_set_default_text(me->form_ptr,G_LIST_SURF,
                           j,0,pt_name,0,0);
  }
                                      /* get her attributes */
  status = om$send(msg = message VLctrLine.VLget_attributes(
						&loc_msg,
						me->plate_side,
						&me->one_or_all,
						&me->axis,
						&me->box),
                                targetid = line.objid,
                                targetos = line.osnum);

  if (!(status&loc_msg&1)) {
    printf("problems in getting attributes\n");
  }

  if (!strcmp(VS_K_plTopSfPath,me->plate_side)) {
    FIg_set_state(me->form_ptr,G_PLATE_SIDE,V_ATT_TOP);
    FIg_set_default_value(me->form_ptr,G_PLATE_SIDE,(double)V_ATT_TOP);
  }
  else {
    FIg_set_state(me->form_ptr,G_PLATE_SIDE,V_ATT_BOTTOM);
    FIg_set_default_value(me->form_ptr,G_PLATE_SIDE,(double)V_ATT_BOTTOM);
  }

  FIg_set_state(me->form_ptr,G_ONE_OR_ALL,me->one_or_all);
  FIg_set_default_value(me->form_ptr,G_ONE_OR_ALL,(double)me->one_or_all);

  pt_name[0] = me->axis; pt_name[1] = '\0';
  FIfld_set_text(me->form_ptr,G_DIRECTION,0,
                   0, pt_name,FALSE);
  FIfld_set_default_text(me->form_ptr,G_DIRECTION,
                           0,0,pt_name,0,0);
  me->old_nb_cl_line = me->nb_cl_line;
  me->old_to_modify = me->to_modify;

  dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,G_MODIF);
  return OM_S_SUCCESS;
}

end implementation VLplCntrCmd;

/* $Id: SMSplVNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMSplVNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSplVNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/29  09:09:38  pinnacle
# Replaced: smspace/cmd/SMSplVNotif.I for:  by ksundar for vds.240
#
# Revision 1.4  1996/03/22  14:19:34  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.3  1996/01/02  10:27:12  pinnacle
# Replaced: smspace/cmd/SMSplVNotif.I for:  by rgade for vds.240
#
# Revision 1.2  1995/09/26  20:29:36  pinnacle
# Replaced: smspace/cmd/SMSplVNotif.I for:  by sundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

 /*               SMBndNotif.I                             */
 /*   Methods  and functions for SMVolBySplt               */ 
 /*   Methods for the CO                                   */
 /*   Pascale Lacroix  (ISDC)			           */
 /*   Creation date July-92                                */
  
 class implementation SMCmdSpltVl;
  
#define AS_DEBUG	1
 
#include <string.h> 
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"
#include "macro.h"
#include "AS_status.h"
#include "parametric.h"
#include "FI.h"

#include "msdef.h"
#include "msmacros.h"
#include "SMmsg.h"
#include "SMspacecom.h"
#include "vdsmacros.h"
#include "VDmem.h"

#define MAX_SURF 	14
#define MAX_TEMP	15 	/* number of templates */
 
extern GRclassid 	OPP_SMVolBySplt_class_id, OPP_EMSsurface_class_id, 
 			OPP_ci_macro_class_id, OPP_ACpretend_class_id;
extern			SMspace_getTempDefString();
 
from ci_macro		import init;
from GRgraphics	import  GRdelete, GRdisplay;
from ACmacro_defn 	import ACgive_upscan;
from NDnode		import NDgive_structure, NDconnect, NDdisconnect, 
			       NDchg_state,NDget_objects;
from NDmacro		import ACreturn_foot;
from ASnode		import ASreturn_go;
from GRvg		import GRputsymb, GRputname, GRchgname, GRgetname;
from SMmgr		import SMGetAttDbl,SMGetAttTxt;
from EMSsurface	import  EMshow_normals ;
from ACncpx		import ACmplace,ACget_STATE,ACchg_STATE;
 

/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance (management of fence)
/*
/**/
 
method store_obj(long *sts; int max_obj)
{
 enum GRdpmode		mode;
 int			i,nb_obj, stat;
 long			test;
 char			name[MY_MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;

 
 *sts = OM_S_SUCCESS;

 	
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 if(me->select_row == -2){
	/* store floor */

	om$send(msg = message SMCmdSpltVl.store_floor(&test),
                                targetid = my_id);
	goto wrapup;
 }
 else if ( me->select_row == -1){
	/* store ceiling */
	om$send(msg = message SMCmdSpltVl.store_ceiling(&test),
                                targetid = my_id);
	goto wrapup;
 }

 LocatedObjects = NULL;
 as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);

 if(nb_obj == 0)
   {
     	/*No obj selected*/
     	*sts = NO_OBJ;
     	goto wrapup;
   }
 if(nb_obj > 1 && me->Fence == TRUE && me->IndexFcObj != me->select_row){
   	/* only one fence locate is allowed */
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Invalid Locate");
     	*sts = TOO_FENCE;
        stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
        if(!(stat & test & 1))
          { 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
          } 
     	goto wrapup;
  }
  if(nb_obj <= 1 && me->Fence == TRUE && me->IndexFcObj == me->select_row){
   	/* desactivate fence */
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						me->select_row, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
   		
   	me->Fence = FALSE;
   	me->IndexFcObj = 0;
   	me->nb_FenceObjects = 0;
   	_FREE(me->FenceObjects ) ;
   		
  }
  if(nb_obj > 1 && me->mytype == MODIFY ){
   	/* no fence locate is allowed for modify*/
     	*sts = MD_FENCE;
     	goto wrapup;
  }
  if(nb_obj > 1) {
   	me->Fence = TRUE;
   	me->IndexFcObj = me->select_row;
   	me->nb_FenceObjects = nb_obj;
   	_FREE(me->FenceObjects ) ;
   	me->FenceObjects = _MALLOC(nb_obj, struct GRobj_env);
   	if(me->FenceObjects == NULL){
   		printf("ERROR, Bad Allocation\n");
   		*sts = OM_E_ABORT;
   		goto wrapup;
   	}
	for(i = 0; i< nb_obj; i++) {
     			stat = as$make_source(
     					go_grid = LocatedObjects[i].obj_id,
			     		mod_env = &LocatedObjects[i].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &me->FenceObjects[i].obj_id);
     			as$status(sts = stat);
        		if(!(stat & 1))
          		{ 
 				printf("ERROR as$make_source\n");
 				*sts = OM_E_ABORT;
 				goto wrapup;
          		} 
          		me->FenceObjects[i].mod_env = LocatedObjects[i].mod_env;
          			
	}		
   		
   		
  }
  if(me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID)	
			me->nb_limits ++;
  else {
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						me->select_row, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
  }
  if(me->nb_limits == max_obj){
 	ex$message(msgnumb = SM_S_TooObj);
 	*sts = OM_E_ABORT;
 	goto wrapup;
  }
	 
  if(nb_obj <= 1){
  	stat = as$make_source(
     			     go_grid = me->event1.located_object[0].located_obj,
			     mod_env = &me->event1.located_object[0].module_info,
			     as_os   = me->act_env.md_id.osnum,
			     as_grid = &me->limits[me->select_row].surf.located_obj);
  	as$status(sts = stat);
  	if(!(stat & 1))
    	{ 
 		printf("ERROR as$make_source\n");
 		*sts = OM_E_ABORT;
 		goto wrapup;
    	}
	me->limits[me->select_row].surf.module_info = me->event1.located_object[0].module_info;

  } 
  else
	me->limits[me->select_row].surf = me->event1.located_object[0];
  name[0] = '\0';
  if(me->Fence == FALSE || me->select_row != me->IndexFcObj){
		vd$get_name(name = name, obj = &(me->limits[me->select_row].surf.located_obj));
		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		vd$get_name(name = name, obj = &(me->event1.located_object[0].located_obj )) ;
        		if(name[0] == '\0') strcpy(name, "defined");
		}
  }
  if(name[0] == '\0') strcpy(name, "defined");
  FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row,
  			1, name, TRUE);
 
 	  
wrapup:

ASend_fence();  
return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* verify about the deleted object
/*
/**/


method verify_obj(long *sts)
{
 int	i;

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.verify_obj(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);
 
 if( (me->Fence == FALSE || me->IndexFcObj == -2) && 
	(me->floor.surf.located_obj.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->floor.surf.located_obj.osnum,
			       objid = me->floor.surf.located_obj.objid)&1) )){
   	ex$message(msgnumb = SM_S_ElDel);
   	me->state = _terminate;
   	return OM_S_SUCCESS;
 }
 if( (me->Fence == FALSE || me->IndexFcObj == -1) && 
	(me->ceiling.surf.located_obj.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->ceiling.surf.located_obj.osnum,
			       objid = me->ceiling.surf.located_obj.objid)&1) )){
   	ex$message(msgnumb = SM_S_ElDel);
   	me->state = _terminate;
   	return OM_S_SUCCESS;
 }
 for(i=0;i<me->nb_FenceObjects;i++){
 	if(me->FenceObjects[i].obj_id.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->FenceObjects[i].obj_id.osnum,
			       objid = me->FenceObjects[i].obj_id.objid)&1) ){
   	 	ex$message(msgnumb = SM_S_ElDel);
   	 	me->state = _terminate;
   	 	return OM_S_SUCCESS;
	}
 }

 return OM_S_SUCCESS;

}



/* ----------------------------------------------------------------- */ 
/*
/* store the element that must be the floor element
/*
/**/


method store_floor(long *sts)
{
 enum GRdpmode		mode;
 int			i,nb_obj, stat;
 long			test;
 char			name[MY_MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;


 *sts = OM_S_SUCCESS;

 	
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 me->floor_ceil = 1;

 LocatedObjects = NULL;
 as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);

 if(nb_obj == 0)
   {
     	/*No obj selected*/
     	*sts = NO_OBJ;
	goto wrapup;
   }
 if(nb_obj > 1 && me->Fence == TRUE && me->IndexFcObj != me->select_row){
   	/* only one fence locate is allowed */
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Invalid Locate");
     	*sts = TOO_FENCE;
        stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
        if(!(stat & test & 1))
          { 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
          } 
     	goto wrapup;
  }
  if(nb_obj <= 1 && me->Fence == TRUE && me->IndexFcObj == -2){
   	/* replace fence by the object */
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-2, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
   		
   	me->Fence = FALSE;
   	me->IndexFcObj = 0;
   	me->nb_FenceObjects = 0;
   	_FREE(me->FenceObjects) ;
   		
  }
  if(nb_obj > 1 && me->mytype == MODIFY ){
   	/* no fence locate is allowed for modify*/
     	*sts = MD_FENCE;
     	goto wrapup;
  }
  if(nb_obj > 1) {
   	me->Fence = TRUE;
   	me->IndexFcObj = -2;
   	me->nb_FenceObjects = nb_obj;
   	_FREE(me->FenceObjects) ;
   	me->FenceObjects = _MALLOC(nb_obj, struct GRobj_env);
   	if(me->FenceObjects == NULL){
   		printf("ERROR, Bad Allocation\n");
   		*sts = OM_E_ABORT;
   		goto wrapup;
   	}
	for(i = 0; i< nb_obj; i++) {
     			stat = as$make_source(
     					go_grid = LocatedObjects[i].obj_id,
			     		mod_env = &LocatedObjects[i].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &me->FenceObjects[i].obj_id);
     			as$status(sts = stat);
        		if(!(stat & 1))
          		{ 
 				printf("ERROR as$make_source\n");
 				*sts = OM_E_ABORT;
 				goto wrapup;
          		} 
          		me->FenceObjects[i].mod_env = LocatedObjects[i].mod_env;
          			
	}		
   		
   		
  }
 if(me->floor.surf.located_obj.objid != NULL_OBJID){
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-2, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
  }
  if(nb_obj <= 1){ 	
  	stat = as$make_source(
     			     go_grid = me->event1.located_object[0].located_obj,
			     mod_env = &me->event1.located_object[0].module_info,
			     as_os   = me->act_env.md_id.osnum,
			     as_grid = &me->floor.surf.located_obj);
  	as$status(sts = stat);
  	if(!(stat & 1))
    	{ 
 		printf("ERROR as$make_source\n");
 		*sts = OM_E_ABORT;
 		goto wrapup;
    	} 
	me->floor.surf.module_info = me->event1.located_object[0].module_info;
  }
  else me->floor.surf = me->event1.located_object[0];

 vd$get_name(name = name, obj = &(me->floor.surf.located_obj));
 if(name[0] == '\0') {
        /* try get name on the graphic object */
        vd$get_name(name = name,
		    obj = &( me->event1.located_object[0].located_obj ));
        if(name[0] == '\0') strcpy(name, "defined");
 }

 FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 0, 1, 
					name, TRUE);
				
 stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1))
  { 
 	ex$message(msgnumb = SM_S_ErrDsp);
 	*sts = OM_E_ABORT;
	goto wrapup;
  } 
 me->select_row = -2;
 
wrapup:

ASend_fence();  
return OM_S_SUCCESS;
}
 
 

/* ----------------------------------------------------------------- */ 
/*
/* store the element that must be the ceiling element
/*
/**/


method store_ceiling(long *sts)
{
 enum GRdpmode		mode;
 int			i, nb_obj, stat;
 long			test;
 char			name[MY_MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;


 *sts = OM_S_SUCCESS;

 	
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");


 LocatedObjects = NULL;
 as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);

 if(nb_obj == 0)
   {
     	/*No obj selected*/
     	*sts = NO_OBJ;
	goto wrapup;
   }
 if(nb_obj > 1 && me->Fence == TRUE && me->IndexFcObj != me->select_row){
   	/* only one fence locate is allowed */
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Invalid Locate");
     	*sts = TOO_FENCE;
        stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
        if(!(stat & test & 1))
          { 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
          } 
     	goto wrapup;
  }
  if(nb_obj <= 1 && me->Fence == TRUE && me->IndexFcObj == -1){
   	/* replace fence by the object */
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-1, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
   		
   	me->Fence = FALSE;
   	me->IndexFcObj = 0;
   	me->nb_FenceObjects = 0;
   	_FREE(me->FenceObjects ) ;
   		
  }
  if(nb_obj > 1 && me->mytype == MODIFY ){
   	/* no fence locate is allowed for modify*/
     	*sts = MD_FENCE;
     	goto wrapup;
  }
  if(nb_obj > 1) {
   	me->Fence = TRUE;
   	me->IndexFcObj = -1;
   	me->nb_FenceObjects = nb_obj;
   	_FREE(me->FenceObjects) ;
   	me->FenceObjects = _MALLOC(nb_obj, struct GRobj_env);
   	if(me->FenceObjects == NULL){
   		printf("ERROR, Bad Allocation\n");
   		*sts = OM_E_ABORT;
   		goto wrapup;
   	}
	for(i = 0; i< nb_obj; i++) {
     			stat = as$make_source(
     					go_grid = LocatedObjects[i].obj_id,
			     		mod_env = &LocatedObjects[i].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &me->FenceObjects[i].obj_id);
     			as$status(sts = stat);
        		if(!(stat & 1))
          		{ 
 				printf("ERROR as$make_source\n");
 				*sts = OM_E_ABORT;
 				goto wrapup;
          		} 
          		me->FenceObjects[i].mod_env = LocatedObjects[i].mod_env;
          			
	}		
   		
   		
  }
 if(me->ceiling.surf.located_obj.objid != NULL_OBJID){
	mode = GRhe;
     	stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						-1, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
		goto wrapup;
        }
  }
  if(nb_obj <= 1){ 	
  	stat = as$make_source(
     			     go_grid = me->event1.located_object[0].located_obj,
			     mod_env = &me->event1.located_object[0].module_info,
			     as_os   = me->act_env.md_id.osnum,
			     as_grid = &me->ceiling.surf.located_obj);
  	as$status(sts = stat);
  	if(!(stat & 1))
    	{ 
 		printf("ERROR as$make_source\n");
 		*sts = OM_E_ABORT;
 		goto wrapup;
    	} 
	me->ceiling.surf.module_info = me->event1.located_object[0].module_info;
  }
  else me->ceiling.surf = me->event1.located_object[0];

 vd$get_name(name = name, obj = &(me->ceiling.surf.located_obj));
 if(name[0] == '\0') {
        /* try get name on the graphic object */
        vd$get_name(name = name,
		    obj  = &(me->event1.located_object[0].located_obj ));
        if(name[0] == '\0') strcpy(name, "defined");
 }

 FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 1, 1, 
					name, TRUE);
				
 stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1))
  { 
 	ex$message(msgnumb = SM_S_ErrDsp);
 	*sts = OM_E_ABORT;
	goto wrapup;
  } 
 me->select_row = -1;

wrapup:

ASend_fence();  
return OM_S_SUCCESS;
}
 
 

/* ----------------------------------------------------------------- */ 
 


method display_normal(long *sts)
{
long			msg,sizebuf, nret;
int			stat;
struct GRlc_info	obj;
struct IGRdisplay	dis;
struct GRmd_env		md_env;

 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg=&msg);

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg    = &msg, sizbuf  = &sizebuf,
                        buffer = &dis, nret    = &nret);

		
 if( me->Fence == TRUE && me->select_row == me->IndexFcObj){

	if(me->FenceObjects[0].obj_id.objid == NULL_OBJID) return OM_S_SUCCESS;

 	/* take the normal of the first elt */
 	
	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->FenceObjects[0].obj_id.objid,
                        targetos = me->FenceObjects[0].obj_id.osnum );
                        	
 }
 else if(me->select_row == -2){
	if(me->floor.surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
 	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                       senderid = NULL_OBJID,
                       targetid = me->floor.surf.located_obj.objid,
                       targetos = me->floor.surf.located_obj.osnum);

 }
 else if(me->select_row == -1){
	if(me->ceiling.surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
 	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                       senderid = NULL_OBJID,
                       targetid = me->ceiling.surf.located_obj.objid,
                       targetos = me->ceiling.surf.located_obj.osnum);

 }
 else{
	if(me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
 	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                       senderid = NULL_OBJID,
                       targetid = me->limits[me->select_row].surf.located_obj.objid,
                       targetos = me->limits[me->select_row].surf.located_obj.osnum);
 }
 md_env = obj.module_info;
 md_env.md_id = me->act_env.md_id;

 stat = om$send( msg = message EMSsurface.EMshow_normals( &msg,
 							  &md_env,
 							  &dis,
 							  GRhd),
         	targetid= obj.located_obj.objid,
         	targetos= obj.located_obj.osnum ) ;
return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */ 
 


method store_orient(long *sts)
{
 
 *sts = OM_S_SUCCESS;

 if(me->event1.event.keyin[0] == 'n' || me->event1.event.keyin[0] == 'N'){
 	if( me->select_row == -2)  {
 		me->floor.rev = 1;
   		FIfld_set_text(me->forms[0].form_ptr,FLOOR_F,0, 2, 
   			"R", FALSE);
   	}
 	else if( me->select_row == -1)  {
 		me->ceiling.rev = 1;
   		FIfld_set_text(me->forms[0].form_ptr,FLOOR_F,1, 2, 
   			"R", FALSE);
   	}
 	else {
 		me->limits[me->select_row].rev = 1;
   		FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2, 
   			"R", TRUE);
   	}
 }
 else 	{
 	if( me->select_row == -2)  {
 		me->floor.rev = 0;
   		FIfld_set_text(me->forms[0].form_ptr,FLOOR_F,0, 2, 
   			"", FALSE);
   	}
 	else if( me->select_row == -1)  {
 		me->ceiling.rev = 0;
   		FIfld_set_text(me->forms[0].form_ptr,FLOOR_F,1, 2, 
   			"", FALSE);
   	}
 	else {
 		me->limits[me->select_row].rev = 0;
   		FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2, 
   			"", TRUE);
   	}
 }


 return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */ 

method reverse_orient(long *sts)
{

 *sts = OM_S_SUCCESS;

 if( me->select_row == -2)  {
 	me->floor.rev = 1;
 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F,0, 2, 
   			"R", FALSE);
 }
 else if( me->select_row == -1)  {
 	me->ceiling.rev = 1;
 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F,1, 2, 
   			"R", FALSE);
 }
 else{	
 	me->limits[me->select_row].rev = 1;
 	FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2, 
   			"R", FALSE);
 }

 return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */ 

method accept_orient(long *sts)
{

 *sts = OM_S_SUCCESS;

 if( me->select_row == -2)  {
 	me->floor.rev = 0;
 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F,0, 2, 
   			"", FALSE);
 }
 else if( me->select_row == -1)  {
 	me->ceiling.rev = 0;
 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F,1, 2, 
   			"", FALSE);
 }
 else{	
 	me->limits[me->select_row].rev = 0;
 	FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row, 2, 
   			"", FALSE);
 }

 return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */ 
 


method GadgOn(long *sts)
{
 *sts = OM_S_SUCCESS;

 FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
 FIg_enable(me->forms[0].form_ptr,FI_RESET);
 FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
 
 return OM_S_SUCCESS;
 
}
/* ----------------------------------------------------------------- */ 
 


method GadgOf(long *sts)
{
 *sts = OM_S_SUCCESS;

 FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
 FIg_disable(me->forms[0].form_ptr,FI_RESET);
 FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);

 return OM_S_SUCCESS;
 
}

/* ----------------------------------------------------------------- */ 
/*
/* hilite all the located objects (semi_hilite and hilite the selected object)
/*
/**/

 
method DispAll(long *sts)
{
int			stat;
enum   GRdpmode		mode;

*sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.DispAll(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);


/* display floor */

mode = GRhhd;
if (me->select_row == -2) mode = GRhd;
stat = om$send(msg = message SMCmdSpltVl.DispLoc(-2, mode),
                        		targetid= my_id ) ;

if (!(stat & 1)){
	ex$message(msgnumb = SM_S_ErrDsp);
	*sts = OM_E_ABORT;
	return  OM_S_SUCCESS;
}

/* display ceiling */

mode = GRhhd;
if (me->select_row == -1) mode = GRhd;
stat = om$send(msg = message SMCmdSpltVl.DispLoc(-1, mode),
                        		targetid= my_id ) ;

if (!(stat & 1)){
	ex$message(msgnumb = SM_S_ErrDsp);
	*sts = OM_E_ABORT;
	return  OM_S_SUCCESS;
}


return OM_S_SUCCESS ;

} 

/* ----------------------------------------------------------------- */ 
/*
/* display the object at the given index (all objects if it is
/* the index of a fence).
/*
/**/
 
method DispLoc(int index; enum GRdpmode mode)
{
 long                    status;
 struct  GRid            currentModule ;
 long                    sts ;
 struct GRlc_info	 obj;
 
 ex$get_cur_mod( id      = &currentModule.objid,
                 osnum   = &currentModule.osnum ) ;


 om$send(msg = message SMCmdVol.DispLoc(index, mode),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 if (me->Fence == FALSE && index == -2){
		if(me->floor.surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
		
		status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->floor.surf.located_obj.objid,
                        targetos = me->floor.surf.located_obj.osnum );

		if(status & 1)  /* Jean :Not found : one sourcein not connected */
 		  {
			status = om$send(msg     = message GRgraphics.GRdisplay(
                  				&sts,
                                		&obj.module_info.md_env.matrix_type,
                                		obj.module_info.md_env.matrix,
                                		&mode,
                                		&currentModule ),
         	  		targetid= obj.located_obj.objid,
         			targetos= obj.located_obj.osnum ) ;
 			as$status();
		  }
 }
 else if (me->Fence == FALSE && index == -1){
		if(me->ceiling.surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
		
		status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->ceiling.surf.located_obj.objid,
                        targetos = me->ceiling.surf.located_obj.osnum );

		if(status & 1)  /* Jean :Not found : one sourcein not connected */
 		  {
 			status = om$send(msg     = message GRgraphics.GRdisplay(
                  				&sts,
                                		&obj.module_info.md_env.matrix_type,
                                		obj.module_info.md_env.matrix,
                                		&mode,
                                		&currentModule ),
         			targetid= obj.located_obj.objid,
         			targetos= obj.located_obj.osnum ) ;
 			as$status();
      		  }

 }
return OM_S_SUCCESS ;
 
}


/* ----------------------------------------------------------------- */ 
/*
/* store the located occurence of the macro (for modify or locate from
/* occurence) and fill the info in the form
/*
/**/

 
method store_occ(long *sts)
{
 int			i, k,  MyProps, stat, count,first,
 			num_rows ;
 long 			attr;
 char			name[MY_MAX_CHAR];
 long			test,msg;
 struct GRid		go, *roots;
 struct ret_struct      str;


 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 dp$erase_hilite(msg = &msg);
 me->select_row = 0;
 me->last_row = 0;
 me->pos = 0;
 roots = NULL;
 	
 me->macro_id = me->event1.located_object[0].located_obj;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&roots,0,OM_K_MAXINT,&count),
                   senderid = NULL_OBJID,
                   targetid = me->macro_id.objid,
                   targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || count > MAX_TEMP){
 		printf("ERROR retrieve roots of the macro \n");         
		goto wrapup;
 }

 /* Get the expression mask */
 if(count != 0)
  {
    stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
		   targetid= roots[0].objid,
		   targetos= roots[0].osnum);
    as$status(sts = stat);
    if(!(stat & msg & 1)){
      printf("ERROR NDgive_structure\n");         
      goto wrapup;
    }
   }
  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
  /* Put default properties if count == 0                            */
 else 
  {
    ex$message(msgnumb = SM_I_NoParMac);
    MyProps = 0x18000;
    /* To be consistent with following assignation : made as if */
    /* one expression was found                                 */
    count = 1;  
  }

 MyProps = (IGRint) str.var.root_pm_st.value;
 
 if(MyProps & 0x8000) me->infinite = 1;
 else                 me->infinite = 0;

 if(MyProps & 0x10000) me->extend = 1;
 else                  me->extend = 0;

 if(MyProps & 0x4000) me->floor_ceil = 1;
 else                 me->floor_ceil = 0;

 if(me->floor_ceil) {
	me->old_nb_limits = me->nb_limits = count - 3;
	first = 3;
 }
 else {
	me->old_nb_limits = me->nb_limits = count - 1;
	first = 1;
 }
 
 if(me->floor_ceil){
 	me->floor.surf.located_obj = roots[1];
 	stat = GetEnvFrObj(&roots[1],
			   &me->floor.surf.module_info,
			   NULL);
 	if(!(stat & 1)){
			/* Jean: if error macro has probably lost one parent */
                     ex$message(msgnumb = SM_I_LostPar);
	}
 
 	if((1<< 0) & MyProps) me->floor.rev = 1;
	else me->floor.rev = 0;

 	me->ceiling.surf.located_obj = roots[2];
 	stat = GetEnvFrObj(&roots[2],
			   &me->ceiling.surf.module_info,
			   NULL);
 	if(!(stat & 1))
		  {  /* Jean: if error macro has probably lost one parent */
                     ex$message(msgnumb = SM_I_LostPar);
		  }
 
 	if((1<< 1) & MyProps) me->ceiling.rev = 1;
	else me->ceiling.rev = 0;
 }
 k=first -1;
 for(i=0;i< me->nb_limits;i++)  {
 		stat = GetEnvFrObj(	&roots[i+first], 
 		 			&me->limits[i].surf.module_info,
 		 			NULL);
 		if(!(stat & 1))
		  {  /* Jean: if error macro has probably lost one parent */
                     ex$message(msgnumb = SM_I_LostPar);
		  }
 		me->limits[i].surf.located_obj =  roots[i+first];
 			
   if((1<<k) & MyProps) 	me->limits[i].rev = 1;
   else	                	me->limits[i].rev = 0;
   k++;
 }
 if(me->mytype == MODIFY) {
 	me->old_macro_id = me->macro_id ;
 	me->old_floor_ceil = me->floor_ceil;
 	for(i=0;i< me->old_nb_limits;i++) { 
 		me->old_limits[i] = me->limits[i];
   		me->old_limits[i].rev = me->limits[i].rev;
 	}
 	me->old_floor   = me->floor;
 	me->old_ceiling = me->ceiling;
 }
 FImcf_get_attr(me->forms[0].form_ptr,LIMITS, &attr);
 attr = attr | FI_ROW_SELECT;

 FImcf_set_attr(me->forms[0].form_ptr,LIMITS, attr);
 
 FImcf_get_attr(me->forms[0].form_ptr,FLOOR_F, &attr);
 attr = attr | FI_ROW_SELECT;
 FImcf_set_attr(me->forms[0].form_ptr,FLOOR_F, attr);

 vd$get_name(name = me->def_name, obj = &me->macro_id);

 if(me->mytype == MODIFY) {
 	strcpy(me->old_def_name,me->def_name);
 	me->old_infinite = me->infinite;
 	me->old_extend   = me->extend;
 }
 else GetDefName("SMVolBySplt_0",me->def_name);

 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);


 if(me->infinite == 1)
	FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
 else	FIg_set_state_on(me->forms[0].form_ptr, INFINITE);

 if(me->extend == 1)
	FIg_set_state_off(me->forms[0].form_ptr, EXTEND);
 else	FIg_set_state_on(me->forms[0].form_ptr, EXTEND);
	

 /* mettre les prompts et default values dans la forme */

 for(i=0;i< MAX_SURF;i++){
 		
 	if(me->floor_ceil && i == 0)
		FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 0, 
				"floor", FALSE);
	if(me->floor_ceil && i == 1)
		FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 0, 
				"ceiling", FALSE);
	
 	sprintf(name,"%s%d","surf",i+1);
	FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 0, 
				name, FALSE);
				
	/* set the name of the objects */
	
	if(me->floor_ceil && i == 0){
		if (me->Fence == FALSE || me->IndexFcObj != -2){
		    if(me->floor.surf.located_obj.objid != NULL_OBJID){
			vd$get_name(name = name, obj = &(me->floor.surf.located_obj));
 			if(name[0] == '\0') {
        			/* try get name on the graphic object */
        			stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        		senderid = NULL_OBJID,
                        		targetid = me->floor.surf.located_obj.objid,
                        		targetos = me->floor.surf.located_obj.osnum );
        			if(!(stat&1)) strcpy(name,"missing");/* Jean : pretend not connected*/	
        			else vd$get_name(name = name, obj = &go);
				if(name[0] == '\0') strcpy(name, "defined");
 			}
		   }

		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 1,
  				 name, FALSE);
  				 
		if(me->floor.rev == 0)
			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "", FALSE);
		else 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "R", FALSE);
  	}
	if(me->floor_ceil && i == 1){
		if (me->Fence == FALSE || me->IndexFcObj != -1){
		    if(me->ceiling.surf.located_obj.objid != NULL_OBJID){
			vd$get_name(name = name, obj = &(me->ceiling.surf.located_obj));
 			if(name[0] == '\0') {
        			/* try get name on the graphic object */
        			stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        		senderid = NULL_OBJID,
                        		targetid = me->ceiling.surf.located_obj.objid,
                        		targetos = me->ceiling.surf.located_obj.osnum );
        			if(!(stat&1)) strcpy(name,"missing");/* Jean : pretend not connected*/	
        			else vd$get_name(name = name, obj = &go);
				if(name[0] == '\0') strcpy(name, "defined");
 			}
		   }
		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 1,
  				 name, FALSE);
		if(me->ceiling.rev == 0)
			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "", FALSE);
		else 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "R", FALSE);
  	}
  	if(i < me->nb_limits){
		if (me->Fence == FALSE || i != me->IndexFcObj){
		  if(me->limits[i].surf.located_obj.objid != NULL_OBJID){
			vd$get_name(name = name, obj = &(me->limits[i].surf.located_obj));
			if(name[0] == '\0') {
        			/* try get name on the graphic object */
        			stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
                        		senderid = NULL_OBJID,
                        		targetid = me->limits[i].surf.located_obj.objid,
                        		targetos = me->limits[i].surf.located_obj.osnum );
        			if(!(stat&1)) strcpy(name,"missing");/* Jean : pretend not connected*/	
        			else vd$get_name(name = name, obj = &go);
  				if(name[0] == '\0') strcpy(name, "defined");
			}
		  }
		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1,
  				 name, FALSE);
  			
		if(me->limits[i].rev == 0)
			FIfld_set_text(me->forms[0].form_ptr, LIMITS, 
					i, 2, "", FALSE);
		else 	FIfld_set_text(me->forms[0].form_ptr, LIMITS, 
					i, 2, "R", FALSE);
  	}
  	else {
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1, 
					"not defined", FALSE);
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 2, 
					"", FALSE);
	}
			
 }

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	goto wrapup;
 }

 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);
 stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){ 
 		ex$message(msgnumb = SM_S_ErrDsp);
		goto wrapup;
 } 

return OM_S_SUCCESS;

wrapup:
 *sts = OM_E_ABORT;
 return OM_S_SUCCESS;

} 

/* ----------------------------------------------------------------- */ 
/*
/* reinit all instances, reinit form, set all default prompts and 
/* template types of the macro 
/*
/**/
 
method reset_form(long *sts)
{
 int		i;
 long		attr;
 char		name[MY_MAX_CHAR];

  
 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.reset_form(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 FImcf_get_attr(me->forms[0].form_ptr,FLOOR_F, &attr);
 attr = attr | FI_ROW_SELECT;
 FImcf_set_attr(me->forms[0].form_ptr,FLOOR_F, attr);
 
 if(me->mytype != MODIFY) {
		me->floor_ceil = 0;
		me->floor.surf.located_obj.objid = NULL_OBJID;
		me->ceiling.surf.located_obj.objid = NULL_OBJID;
		me->floor.rev = 0;
		me->ceiling.rev = 0;
 		FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
 		FIg_set_state_off(me->forms[0].form_ptr, EXTEND);
 }
 else {

		me->floor_ceil = me->old_floor_ceil;
		me->floor = me->old_floor;
		me->ceiling = me->old_ceiling;

 		if(me->old_infinite == 1)
 			FIg_set_state_off(me->forms[0].form_ptr, INFINITE);
 		else 
 			FIg_set_state_on(me->forms[0].form_ptr, INFINITE);

 		if(me->old_extend == 1)
 			FIg_set_state_off(me->forms[0].form_ptr, EXTEND);
 		else 
 			FIg_set_state_on(me->forms[0].form_ptr, EXTEND);
		
 }
	
 /* mettre les prompts et default values dans la forme */

 for(i=0;i< MAX_SURF;i++){
 		
 		if(me->floor_ceil && i == 0)
			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 0, 
				"floor", FALSE);
		if(me->floor_ceil && i == 1)
			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 0, 
				"ceiling", FALSE);

 		sprintf(name,"%s%d","surf",i+1);
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 0, 
				name, FALSE);
				
		/* set the name of the objects */

	
		if(me->floor_ceil && i == 0){
			if (me->Fence == FALSE || me->IndexFcObj != -2)
				vd$get_name(name = name, obj = &(me->floor.surf.located_obj));
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 1,
  				 name, FALSE);
  				 
			if(me->floor.rev == 0)
				FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "", FALSE);
			else 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "R", FALSE);
  		}
		if(me->floor_ceil && i == 1){
			if (me->Fence == FALSE || me->IndexFcObj != -1) 
				vd$get_name(name = name, obj = &(me->ceiling.surf.located_obj));
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, i, 1,
  				 name, FALSE);
			if(me->ceiling.rev == 0)
				FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "", FALSE);
			else 	FIfld_set_text(me->forms[0].form_ptr, FLOOR_F, 
					i, 2, "R", FALSE);
  		}
  		if(i < me->nb_limits){
			if (me->Fence == FALSE || i != me->IndexFcObj) 
			    vd$get_name(name = name, obj = &(me->limits[i].surf.located_obj));
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1,
  				 name, FALSE);
  			
			if(me->limits[i].rev == 0)
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, 
					i, 2, "", FALSE);
			else 	FIfld_set_text(me->forms[0].form_ptr, LIMITS, 
					i, 2, "R", FALSE);
  		}
  		else {
			FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1, 
					"not defined", FALSE);
			FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 2, 
					"", FALSE);
		}
			
 }

 for(i=0;i< me->nb_col_limits;i++)
 	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, i, TRUE);

 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);


  	
return OM_S_SUCCESS;

}



/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

method clear_form( long *sts )
{
 int 	num_rows, stat;

  
 *sts = OM_S_SUCCESS;
  
 om$send(msg = message SMCmdVol.clear_form(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 me->floor.surf.located_obj.objid = NULL_OBJID;
 me->floor.rev = 0;
 me->ceiling.surf.located_obj.objid = NULL_OBJID;
 me->ceiling.rev = 0;
 me->floor_ceil 		= 0;

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,FLOOR_F, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
 }
 if(num_rows){
 	stat = FIfld_delete_rows(me->forms[0].form_ptr,FLOOR_F, 
 					0,num_rows);
	if(stat != FI_SUCCESS){
		printf("error FIfld_delete_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
	}
 }

 if(me->mytype == MODIFY) FIg_set_text(me->forms[0].form_ptr, LOAD, 
		"Disconnect");

return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* Get the info from the form to place or modify the macro
/* 
/**/
 
method save_all(long *sts )
{
  int 			i, k, fc, nb_obj, nb_roots, num_char = MY_MAX_CHAR, sel_flag, 
  			r_pos, stat, first, nb_fail, state;
  long			test;
  char 			text[MY_MAX_CHAR];
  long			sizebuf, nret, msg;
  struct GRid 		mac, *roots, *old_roots;
  unsigned int		VMask;
  struct GRsymbology	symb;
  
  	*sts = OM_S_SUCCESS;
  	
  	roots = NULL;
  	old_roots = NULL;
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->act_env.md_id.osnum;
        dp$erase_hilite(msg = &msg);
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

	sizebuf = sizeof(struct IGRdisplay);
   	gr$get_active_display(	msg    = &msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

   	sizebuf = sizeof(IGRshort);
   	gr$get_active_level(	msg     = &msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);

	if( (me->floor_ceil && me->nb_limits < 1) || 
	    (!me->floor_ceil && me->nb_limits < 2) ){
		ex$message(msgnumb = SM_S_NotObjLoc);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, Not enough objects located");
		*sts =  OM_E_ABORT; 
		goto quit;
	} 
 
 	/* delete duplicated objects */

	for(i=0;i<me->nb_limits;i++){
		if( (me->Fence == FALSE || me->IndexFcObj != -2 ) && 
		me->limits[i].surf.located_obj.objid == me->floor.surf.located_obj.objid &&
		me->limits[i].surf.located_obj.osnum ==  me->floor.surf.located_obj.osnum )
			me->limits[i].surf.located_obj.objid = NULL_OBJID;

		if( (me->Fence == FALSE || me->IndexFcObj != -1) && 
		me->limits[i].surf.located_obj.objid == me->ceiling.surf.located_obj.objid &&
		me->limits[i].surf.located_obj.osnum ==  me->ceiling.surf.located_obj.osnum)
			me->limits[i].surf.located_obj.objid = NULL_OBJID;

		if(me->Fence == TRUE && me->IndexFcObj >= 0){
			for(k=0;k<me->nb_FenceObjects;k++){
				if(me->limits[i].surf.located_obj.objid == me->FenceObjects[k].obj_id.objid &&
				me->limits[i].surf.located_obj.osnum == me->FenceObjects[k].obj_id.osnum)
					me->limits[i].surf.located_obj.objid = NULL_OBJID;
			}
		}
		for(k=0;k<i;k++){
			if(me->limits[i].surf.located_obj.objid == me->limits[k].surf.located_obj.objid &&
			me->limits[i].surf.located_obj.osnum == me->limits[k].surf.located_obj.osnum)
				me->limits[i].surf.located_obj.objid = NULL_OBJID;
		}
	}

	/* verif macro name */
			
   	FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
	if(text[0] == '\0'){
		if(me->mytype == MODIFY) {
			me->def_name[0] = '\0';
			mac = me->macro_id;
		}
		else{
			ex$message(msgnumb = SM_S_ErNoMacNm);
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"ERROR, No macro name");
			*sts =  OM_E_ABORT; 
			goto quit;
		}
	} 
	else {
		if(me->mytype == MODIFY) mac = me->macro_id;
		strcpy(me->def_name, text);
		if(!SMCanChgElemName(&mac, text)){
			ex$message(msgnumb = SM_S_ErInvMacNm);
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"ERROR, Invalid macro name");
			*sts =  OM_E_ABORT; 
			goto quit;
		}			
	}

  	/* store value in instances */
  	
  	FIg_get_state(me->forms[0].form_ptr,INFINITE,&state);
  	if(state ) me->infinite = 0;
  	else       me->infinite = 1;

  	FIg_get_state(me->forms[0].form_ptr,EXTEND,&state);
  	if(state ) me->extend = 0;
  	else       me->extend = 1;
  	
	VMask = 0x0000;
	if(me->infinite) VMask = VMask | 0x8000;
	if(me->extend) VMask = VMask | 0x10000;
	

	if(me->Fence == TRUE) nb_obj = me->nb_FenceObjects ;
	else nb_obj = 1;
	if(me->floor_ceil) nb_roots = me->nb_limits + 3;
	else nb_roots = me->nb_limits+1;

	if(me->floor_ceil) {
		VMask = VMask | 0x4000;
		if(me->floor.rev)   VMask = VMask | (1<<0);
		if(me->ceiling.rev) VMask = VMask | (1<<1);
		k=0;
		for(i=0;i< me->nb_limits;i++){
			if(me->limits[i].surf.located_obj.objid == NULL_OBJID) {
				nb_roots --;
				continue;
			}
			if(me->limits[i].rev) VMask = VMask | (1<<k+2);
			k++;
		}
	}
	else{
		k = 0;
		for(i=0;i< me->nb_limits;i++){
			if(me->limits[i].surf.located_obj.objid == NULL_OBJID) {
				nb_roots --;
				continue;
			}
			if(me->limits[i].rev) VMask = VMask | (1<<k);
			k++;
		}
	
	}

	nb_fail = 0;
	for(fc = 0; fc < nb_obj; fc++){
		 
  		/* place the macro */

  		if(me->mytype == PLACE){ 
  			mac.objid = NULL_OBJID;
  			mac.osnum = me->act_env.md_id.osnum;
 
  			stat = om$construct(classid = OPP_SMVolBySplt_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
  			if(!(stat & 1)){
     				printf("erreur creating macro\n"); 
				*sts =  OM_E_ABORT; 
				goto quit;
  			}
  			
		}
	
  		roots = _MALLOC(nb_roots, struct GRid);
  		if(roots == NULL){
			printf("ERROR Bad allocation\n");
			*sts =  OM_E_ABORT; 
			goto quit;
  		}

		if(me->floor_ceil ){
  			if(me->Fence == TRUE && me->IndexFcObj == -2) {
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[1]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
     				stat = as$make_source(
     					go_grid = me->ceiling.surf.located_obj,
			     		mod_env = &me->ceiling.surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[2]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
  			else if(me->Fence == TRUE && me->IndexFcObj == -1) {
     				stat = as$make_source(
     					go_grid = me->floor.surf.located_obj,
			     		mod_env = &me->floor.surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[1]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[2]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
  			else {
     				stat = as$make_source(
     					go_grid = me->floor.surf.located_obj,
			     		mod_env = &me->floor.surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[1]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
     				stat = as$make_source(
     					go_grid = me->ceiling.surf.located_obj,
			     		mod_env = &me->ceiling.surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[2]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
		}
		if(me->floor_ceil ) 	first = 3;
		else			first = 1;
		k=0;		
  		for(i=0;i<me->nb_limits;i++) {
			if(me->limits[i].surf.located_obj.objid == NULL_OBJID) continue;

  			if(me->Fence == TRUE &&  i == me->IndexFcObj) {
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[first+k]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
  			else {
     				stat = as$make_source(
     					go_grid = me->limits[i].surf.located_obj,
			     		mod_env = &me->limits[i].surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[first+k]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
			k++;
  		}

  		if(me->mytype == PLACE){
  			 
  			/* mask is roots[0] */
  		
  			roots[0].osnum = me->act_env.md_id.osnum;
  			stat = exp$create( 	exp_name  = NULL,
  					exp_value = (IGRdouble) VMask,
  					p_exp_id  = &roots[0].objid,
  					osnum     = roots[0].osnum);
  			if(stat != EXP_S_SUCCESS){
  				printf("ERROR creating expression for VMask\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  			}

        		stat = om$send(msg = message NDnode.NDchg_state(
                                                ND_DEL_NO_CH | ND_WAIT_DEL,
                                                ND_DEL_NO_CH | ND_WAIT_DEL),

                   	targetid = roots[0].objid,
                   	targetos = roots[0].osnum);

        		as$status(sts = stat);
        		if(!(stat & 1)){
                		printf("ERROR NDnode.NDchg_state\n");
                		*sts =  OM_E_ABORT;
                		goto quit;
        		}

			/* place macro */
			
			stat = om$send(msg = message ACncpx.ACmplace
                   			((IGRint *)&msg,ACcant_place_sym,0,
                    			"SMVolBySplt",nb_roots, roots,&me->act_env),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);


 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
			        ex$message(msgnumb = SM_E_FailPlVol);
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}
			
			GetDefName(text, me->def_name);
			stat = om$send(msg = message GRvg.GRputname
                   			(&msg, me->def_name),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);


 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
        			printf("erreur GRvg.GRputname\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}
			/* put active symbology */
		
			stat = om$send(msg = message GRvg.GRputsymb
                   			(&msg, &symb),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

 			as$status(sts = stat);
  			if(!(stat & msg & 1)){
        			printf("erreur GRvg.GRputsymb\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}
			
  		}
  		else{
  			 
			/* modify macro */

			stat = om$send(msg = message SMCmdSpltVl.SMmodif_mac
						(VMask, nb_roots, roots),
			 		targetid = my_id);
 			if(!(stat & 1)){
 				ex$message(msgnumb = SM_E_FailMdVol); 
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
 			}
  		}
  		_FREE(roots ) ;
  	}


 if(nb_fail == nb_obj) {*sts = OM_E_ABORT; goto quit;}
 
 if(me->mytype == MODIFY){    
/* 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Modify Successfull");
	ex$message(msgnumb = SM_S_ModSucc); if fails SMModify success*/
 }
 else 	{
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
	ex$message(msgnumb = SM_S_PlSucc);
 }

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY)  
		{ex$message(msgnumb = SM_S_ModFail);}
	 		
 	else if (mac.objid != NULL_OBJID && 
 		 om$is_objid_valid(osnum = mac.osnum, objid = mac.objid)){
                stat = om$send(msg = message GRgraphics.GRdelete(&msg, &me->act_env),
                             targetid = mac.objid,targetos = mac.osnum);
                as$status(sts = stat);
                if(!(stat&msg&1))printf("ERROR delete macro\n");
                mac.objid = NULL_OBJID;
		ex$message(msgnumb = SM_S_PlFail);
 	}
  }
  else{
  	me->select_row = 0;
  	me->last_row = 0;
  	me->pos = 0;
  	if(me->mytype == MODIFY){ 
 		me->old_macro_id 	= me->macro_id ;
 		me->old_floor   	= me->floor;
		me->old_floor_ceil 	= me->floor_ceil;
 		strcpy(me->old_def_name,me->def_name);
 		me->old_infinite 	= me->infinite;
 		me->old_extend 		= me->extend;
 		me->old_ceiling 	= me->ceiling;
 		me->old_nb_limits 	= me->nb_limits;
 		for(i=0;i< me->old_nb_limits;i++) 
 			me->old_limits[i] = me->limits[i];
		for(i=me->old_nb_limits;i<MAX_SURF;i++) {
			me->old_limits[i].surf.located_obj.objid = NULL_OBJID;
			me->old_limits[i].rev = 0;	
		}
  	}
  	else {
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
  		FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  		stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      			targetid = my_id);
  		if(!(stat & test & 1)){ 
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  		} 
   		FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
  		GetDefName(text,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  	}
  }
  
  
  _FREE(roots ) ;
  return OM_S_SUCCESS;
}


/* ----------------------------------------------------------------- */ 
/*
/* delete an element (Modify)
/* 
/**/
 
method delete_elt(long *sts )
{
 int		i, k, l, stat, Nb_Max_Temp ,num_rows;
 int		def_properties;
 long		test,msg;
 struct GRid	mac;
 char		*c, name[MY_MAX_CHAR],text[MY_MAX_CHAR];

 *sts = OM_S_SUCCESS;
 
 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
 }
 if(me->delete_elt){

	if(me->delete_row != -1){
  		/* delete the element and redisplay the form */

     		stat = om$send(msg = message SMCmdSpltVl.DispLoc(
     						me->delete_row, GRhe),
                        		targetid= my_id ) ;

     		if (!(stat & 1)){
                	ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
                	return  OM_S_SUCCESS;
        	}

		for(i=0;i<me->nb_limits -1;i++){
			if(i < me->delete_row) k = i;
			else k = i+1;

			me->limits[i] = me->limits[k];
		}
		me->limits[me->nb_limits -1].surf.located_obj.objid = NULL_OBJID;
		me->limits[me->nb_limits -1].rev = 0;
		me->nb_limits --;
	
 		if(num_rows){
 			stat = FIfld_delete_rows(me->forms[0].form_ptr,LIMITS, 
 						0,num_rows);
			if(stat != FI_SUCCESS){
				printf("error FIfld_delete_rows: %d\n",stat);
				*sts = OM_E_ABORT;
				return OM_S_SUCCESS;
			}
 		}
 		stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMVolBySplt",
                            p_macro_defn_id     = &mac );

 		if (!(stat & 1) || IF_NULL_OBJID(mac.objid)){
			printf("error macro not found\n");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
 		}
 		Nb_Max_Temp = 0;
 		stat = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&def_properties,&me->dup),
                           targetid = mac.objid,
                           targetos = mac.osnum );

 		as$status(sts = stat);
 		if(!(stat & 1)){
			printf("error  ACmacro_defn.ACgive_upscan\n");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
 		}
 		/* mettre les prompts et default values dans la forme */

 		l = 0;
 		for(i=1;i<Nb_Max_Temp;i=i+1){
		        SMspace_getTempDefString( &msg, me->dup[i].type, text);	

			FIfld_set_text(me->forms[0].form_ptr, LIMITS, l, 0, 
					me->dup[i].prompt, FALSE);

			if(l < me->nb_limits){
				if (me->Fence == FALSE || l != me->IndexFcObj) 
				    vd$get_name(name = name, obj = &(me->limits[l].surf.located_obj));
  				if(name[0] == '\0') strcpy(name, "defined");
 				FIfld_set_text(me->forms[0].form_ptr, LIMITS, l, 1,
  				 name, FALSE);
			}
 			else
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, l, 1, 
					text, FALSE);
			if(me->limits[l].rev == 0)
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, l, 2, 
					"", FALSE);
			else FIfld_set_text(me->forms[0].form_ptr, LIMITS, l, 2, 
					"R", FALSE);
			l++;
 		}
 
	}
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);

  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 2, TRUE);
  	me->select_row = 0;
  	me->pos = 0;
  	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  	stat = om$send(msg = message SMCmdSpltVl.DispAll(&test),
 		      			targetid = my_id);
  	if(!(stat & test & 1)){ 
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  	} 
  	
  	me->delete_elt = 0;
  }
  else{
  	/* set the rows unselected */
  	me->delete_row = -1;
 	for(i=0;i<num_rows;i++){
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 0, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 1, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,i, 2, FALSE);
	} 	
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 			"Select the Elt to be disconnected");
  	me->delete_elt = 1;
  }
  return OM_S_SUCCESS;
}



/* ----------------------------------------------------------------- */ 
/*
/* modify the macro
/* 
/**/

method SMmodif_mac(unsigned int	VMask; int nb_new; struct GRid  *new)
{
 long			msg;
 int			i, oldnb_roots, nb_temp, stat;
 struct GRid 		original, *old_roots;
 char			tmp[10];
 IGRboolean		discon, put_batch;
 unsigned int		old_Mask;
 struct ret_struct	str;  
  
 old_roots = NULL;
 oldnb_roots = 0;
 put_batch = FALSE;

 
 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
					&oldnb_roots),
		targetid = me->macro_id.objid,
		targetos = me->macro_id.osnum );

 if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP){
 	printf("ERROR retrieve roots of the macro \n");         
	return OM_E_ABORT;
 }

  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
 /* If macro has been move to root due to delete of one of the roots */
 /* Creation of a dummy expression to allow to recreate a depandancy */
 if(oldnb_roots == 0)
  {
    struct GRid exp;
    struct GRid original;
    int         state;
    int         MyProps = 0x18000;
    
    put_batch = TRUE;

    /* Recreate an expression with default parameter */
    exp.osnum = me->ModuleInfo.md_id.osnum;
    stat = exp$create(exp_name  = NULL,
		      exp_value = (IGRdouble)MyProps,
		      p_exp_id  = &exp.objid,
		      osnum     = exp.osnum);
    as$status(sts = stat, action = GOTO_VALUE, value = wrapup);

    stat = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL), 
		   targetid = exp.objid,
		   targetos = exp.osnum);
    as$status(sts = stat);
  
    original.objid = NULL_OBJID;
    stat = om$send(msg = message NDnode.NDconnect
		   (1, &exp, original, ND_ADD),
		   targetid = me->macro_id.objid,
		   targetos = me->macro_id.osnum); 
    as$status(sts = stat,action = GOTO_VALUE, value = wrapup);

    /* Refound all parents so we can execute normal instruction */
    stat = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
		    &oldnb_roots),
		   targetid = me->macro_id.objid,
		   targetos = me->macro_id.osnum );
    if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP){
      printf("ERROR retrieve roots of the macro \n");         
      return OM_E_ABORT; 
    }

    /* Macro have probably been move to root .Change it state and
       so it will be recompute when in batch                     */
    stat =  om$send(msg = message ACncpx.ACget_STATE(&state),
		    targetid = me->macro_id.objid ,
		    targetos = me->macro_id.osnum);
    as$status(sts = stat,action = GOTO_VALUE, value = wrapup);
    
    if(state & ncpx_root) /* Your are move to root ? */
     {
       /* You will be no longer in move to root state ! */
       stat = om$send(msg = message ACncpx.ACchg_STATE(ncpx_root,~ncpx_root),
		      targetid = me->macro_id.objid ,
		      targetos = me->macro_id.osnum);
       as$status (sts = stat,action = GOTO_VALUE, value = wrapup);
     }
 }

 stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
		targetid= old_roots[0].objid,
		targetos= old_roots[0].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)) {
      printf("ERROR retrieve VMask \n");         
      return OM_E_ABORT;
    }
 
 old_Mask = (unsigned int) str.var.root_pm_st.value;

 if(strcmp(me->def_name,me->old_def_name)){

	if(!SMChgElemName(&me->macro_id, me->def_name, &me->act_env)){
		printf("Warning: can't change macro name\n");
	}
 }

 if(VMask != old_Mask){
 	sprintf(tmp,"%lf", (IGRdouble)VMask);
  	stat = exp$modify( 	exp_id  	= old_roots[0].objid,
  				exp_syntax 	= tmp,
  				osnum     	= old_roots[0].osnum);
  	if(stat != EXP_S_SUCCESS){
  		printf("ERROR modify expression\n");
		return OM_E_ABORT;
  	}
 }

 discon = FALSE;
  
 if( oldnb_roots != nb_new) discon = TRUE;
 i = 1;
 while(discon == FALSE && i<oldnb_roots && i< nb_new ){
  		if(old_roots[i].objid != new[i].objid ||
  		   old_roots[i].osnum != new[i].osnum)
  		   	discon = TRUE;
  		i++;	   
 }

  if(discon){ 
	put_batch = TRUE;
        nb_temp = oldnb_roots - 1;
	if(nb_temp) /* Template could be 0 if macro has lose parents */
	 {
	   stat = om$send(msg = message NDnode.NDdisconnect
			  (nb_temp, &old_roots[1]),
			  targetid = me->macro_id.objid,
			  targetos = me->macro_id.osnum );
	   as$status(sts = stat);
	   if(!(stat & 1)){
	     printf("Erreur NDnode.NDdisconnect\n");
	     return OM_E_ABORT;
	   }
	 }

        nb_temp = nb_new - 1;
  	NDduplicate_root(nb_temp, &new[1]);
  	original.objid = NULL_OBJID;
  	stat = om$send(msg = message NDnode.NDconnect
		      (nb_temp, &new[1], original, ND_ADD),
		       targetid = me->macro_id.objid,
		       targetos = me->macro_id.osnum );

  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDconnect\n");
		return OM_E_ABORT;
  	}
 }
 if(put_batch){
     		IGRint  cn_type,wait_batch;

     		cn_type    = 1; /* recompute the object */
     		stat = nd$wait_batch(
     						type  = GR_GEOM_POSTED,
                            			l_object   = & me->macro_id,
                            			l_obj_info = &cn_type,
                            			nb_obj     = 1);

     		nd$mod_batch(request = ND_INQ,
     			     p_ret_mode = &wait_batch);

     		if(wait_batch == ND_DEFER) {
     				/* Nothing to do */
				return OM_S_SUCCESS;
		}
     		nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);

 }

 return OM_S_SUCCESS ;

 wrapup:
 return OM_E_ABORT;
}

end implementation SMCmdSpltVl;




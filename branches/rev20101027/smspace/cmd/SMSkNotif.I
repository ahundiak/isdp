/* $Id: SMSkNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMSkNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSkNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/01/02  16:13:52  pinnacle
# Replaced: smspace/cmd/SMSkNotif.I for:  by mdong for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/29  09:07:46  pinnacle
# Replaced: smspace/cmd/SMSkNotif.I for:  by ksundar for vds.240
#
# Revision 1.3  1996/03/22  14:18:36  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/01/24  20:06:44  pinnacle
# Replaced: ./smspace/cmd/SMSkNotif.I for:  by azuurhou for vds.240
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

 /*               SMSkNotif.I                    */
 /*   Methods  and functions for SMCmdSkVol        */ 
 /*   Methods for the CO                          */
 /*   Pascale Lacroix  (ISDC)			  */
 /*   Creation date July-92                       */
  
 class implementation SMCmdSkVol;
  
#define AS_DEBUG	1
 
#include <string.h> 
#include "expression.h"
#include "expmacros.h"
#include "macro.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"

#include "FI.h"
#include "expmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "SMmsg.h"
#include "SMspacecom.h"
#include "vdsmacros.h"
#include "VDmem.h"


#include "bserr.h"
#include "bstypes.h"

/* include prototypes ‚*/

#include "bsmdstptcv.h"
#include "bscvarrevt.h"
#include "bsmkvec.h"
 
#define MAX_OBJ 	99
#define MAX_TEMP	100 	/* number of templates */
 
 
 extern GRclassid 	OPP_SMSketchVol_class_id, OPP_EMSsurface_class_id, 
 			OPP_ci_macro_class_id, OPP_ACpretend_class_id;
 
 from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute,
 				ACmod_list_attribute;
 from GRgraphics	import GRdelete, GRdisplay;
 from ACmacro_defn 	import ACgive_upscan;
 from NDnode		import NDgive_structure, NDconnect, NDdisconnect, 
			       NDchange_connect,NDchg_state,NDget_objects;
 from NDmacro		import ACreturn_foot;
 from ASnode		import ASreturn_go;
 from GRvg		import GRputsymb, GRputname, GRchgname, GRgetname;
 from SMmgr		import SMGetAttDbl,SMGetAttTxt;
 from ACncpx		import ACmplace,ACchg_STATE,ACget_STATE;
 

/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance (management of fence)
/*
/**/
 
method store_obj(long *sts; int	max_obj)
{
 enum GRdpmode		mode;
 int			i, nb_obj, stat;
 BSrc			bsretcode;
 long			test;
 char			name[MY_MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;
 IGRdouble 		dis_fact=1.0, length;
 IGRpoint 		tgt_pts[1][2];
 struct GRparms 	ref_par;
 struct IGRbsp_curve	*bc;


 
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
        stat = om$send(msg = message SMCmdSkVol.DispAll(&test),
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
     	stat = om$send(msg = message SMCmdSkVol.DispLoc(
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
  if( me->select_row > 0){
  	me->CurveId = LocatedObjects[0].obj_id;
  	stat = ASgenabsg(&me->CurveId,&bc);
  	as$status(sts = stat);

  	if( bc->phy_closed ) *sts = CLOSED_CURVE;
  	else{
  		BSmdstptcv( bc, &me->event2.event.button.x, &ref_par.u, me->accept_pt, 
  			&length, &bsretcode );
  		if( bsretcode != BSSUCC ) { 
  			printf("ERROR   BSmdstptcv\n");
     			*sts = OM_E_ABORT;
     			goto wrapup;
  		}

  		BScvarrevt( bc, &ref_par.u, 1, dis_fact, tgt_pts, &bsretcode );
  		if( bsretcode != BSSUCC ) { 
  			printf("ERROR   BScvarrevt \n");
     			*sts = OM_E_ABORT;
     			goto wrapup;
  		}

  		BSmkvec( &bsretcode, me->tg_vect, tgt_pts[0][0],tgt_pts[0][1] );
  	}
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
     	stat = om$send(msg = message SMCmdSkVol.DispLoc(
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
	vd$get_name(name = name,
		    obj = &(me->limits[me->select_row].surf.located_obj));
	if(name[0] == '\0') {
        	/* try get name on the graphic object */
        	vd$get_name(name = name,
			obj = &(me->event1.located_object[0].located_obj ));
        	if(name[0] == '\0') strcpy(name, "defined");
	}
  }
  if(name[0] == '\0') strcpy(name, "defined");
  FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row,
  			1, name, TRUE);
  
  if(me->select_row == 1 && *sts != CLOSED_CURVE) *sts = NEED_NORMAL;
 	  
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
/* set the active row, and display of the objects
/*
/**/
 
method next_row(long *sts)
{

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdVol.next_row(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 if( (*sts) == END_TEMP ){

	if(me->select_row == 0 && 
	    me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID){
   			FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
   			FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
			*sts = NEED_SOLID;
			return OM_S_SUCCESS;
	}		

	if(me->select_row == 1 && me->reverse == -1){
   			FIfld_set_select(me->forms[0].form_ptr, LIMITS,1, 0, TRUE);
   			FIfld_set_select(me->forms[0].form_ptr, LIMITS,1, 1, TRUE);
			*sts = NEED_CURVE;
			return OM_S_SUCCESS;
	}		
 } 
 
return OM_S_SUCCESS;
 
}



/* ----------------------------------------------------------------- */ 
/*
/* store the located occurence of the macro (for modify or locate from
/* occurence) and fill the info in the form
/*
/**/

 
method store_occ(long *sts)
{
 int			i,  stat, num_rows, count;
 long			attr;
 char			name[MY_MAX_CHAR];
 long			msg, test;
 struct GRid		go,*roots;
 struct ret_struct      str;


 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 dp$erase_hilite(msg = &msg);

 me->select_row = 0;
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
 		*sts = OM_E_ABORT;
		goto wrapup;
 }

 if(count > 0 )/* Common case : macro is OK */
 {
 /* Get the reverse expression  */
 
 stat = om$send(msg = message NDnode.NDgive_structure(&msg, &str, NULL),
                   	senderid = NULL_OBJID,
                        targetid= roots[0].objid,
                        targetos= roots[0].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR NDgive_structure\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }

 me->reverse = (IGRint) str.var.root_pm_st.value;

 if(me->reverse) me->normal_flag = -1;
 else me->normal_flag = 1;

 me->old_nb_limits = me->nb_limits = count - 1;
 		
 for(i=0;i< me->nb_limits;i++)  {
 		stat = GetEnvFrObj(	&roots[i+1], 
 		 			&me->limits[i].surf.module_info,
 		 			NULL);
    		/* Jean: if error macro has probably lost one parent */
    		if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}
 		me->limits[i].surf.located_obj =  roots[i+1];
 			
 }
}
else     /* Jean : 5/4/93  Macro is broken : user  will relocate parents*/
  {
    ex$message(msgnumb =  SM_I_NoParMac);

    me->old_nb_limits = me->nb_limits = 0;

     /* Recreate an expression with default parameter */
    me->reverse = 0;
    me->normal_flag = 1;
}



 if(me->mytype == MODIFY) {
 	for(i=0;i< me->old_nb_limits;i++) 
 		me->old_limits[i] = me->limits[i];

 }

 FImcf_get_attr(me->forms[0].form_ptr,LIMITS, &attr);
 attr = attr | FI_ROW_SELECT;
 FImcf_set_attr(me->forms[0].form_ptr,LIMITS, attr);
 
 vd$get_name(name = me->def_name, obj = &me->macro_id );


 if(me->mytype == MODIFY) {
 		me->old_macro_id = me->macro_id ;
 		strcpy(me->old_def_name,me->def_name);
 		me->old_reverse = me->reverse;
 }
 else (void)GetDefName("SMSketchVol_0",me->def_name);


 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 if(me->reverse == 1) 	me->normal_flag = -1;
 else			me->normal_flag = 1;
	


 FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 0, 
				"Volume", FALSE);

 if(me->limits[0].surf.located_obj.objid != NULL_OBJID){
 	vd$get_name(name = name, obj = &(me->limits[0].surf.located_obj));
 	if(name[0] == '\0') {
        	/* try get name on the graphic object */
        	stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        senderid = NULL_OBJID,
                        targetid = me->limits[0].surf.located_obj.objid,
                        targetos = me->limits[0].surf.located_obj.osnum );
        	if(!(stat&1)) {
			strcpy(name,"missing");/* Jean : pretend not connected*/	
			go =  me->limits[0].surf.located_obj;
		}
        	else vd$get_name(name = name, obj = &go);
		if(name[0] == '\0') strcpy(name, "defined");
 	}
 }
 else strcpy(name,"other_generic");
 FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 1, 
				name, FALSE);
 
 for(i=1;i<MAX_OBJ;i=i+1){
	sprintf(name,"%s%d","curve",i-1);
	FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 0, 
				name, FALSE);
	if(i < me->nb_limits ){
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
        			if(!(stat&1)) {
					strcpy(name, "missing"); /* Jean */
					go =  me->limits[i].surf.located_obj;
				}
        			else vd$get_name(name = name, obj = &go);
  				if(name[0] == '\0') strcpy(name, "defined");
			   }
			}
		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1,
  				 name, FALSE);
	}
 	else
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1, 
					"curve_generic", FALSE);

 }

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	goto wrapup;
 }

 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
 FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);
 stat = om$send(msg = message SMCmdSkVol.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){ 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		goto wrapup;
 } 

wrapup:
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
 int		i,  stat, num_rows;
 long		attr;
 char		name[MY_MAX_CHAR];
 long		test, msg;
 struct GRid	go;

 	*sts = OM_S_SUCCESS;
  	dp$erase_hilite(msg = &msg);

  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

	me->Fence = FALSE;
	me->FenceObjects = NULL;
	me->nb_FenceObjects = 0;
	me->IndexFcObj = 0;
 	me->select_row = 0;
 	me->pos = 0;



	if(me->mytype != MODIFY) {
		me->nb_limits = 0;
 		me->reverse = -1;
		(void)GetDefName("SMSketchVol_0",me->def_name);
 		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
		for(i=0;i<MAX_OBJ;i++) me->limits[i].surf.located_obj.objid = NULL_OBJID;

	}
	else {
		me->nb_limits = me->old_nb_limits;
 		me->macro_id = me->old_macro_id;
 		me->reverse = me->old_reverse;
		for(i=0;i<MAX_OBJ;i++) me->limits[i] = me->old_limits[i];

 		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 		if(me->old_reverse == 1)	me->normal_flag = -1;
 		else 				me->normal_flag = 1;
	}
	
 	FImcf_get_attr(me->forms[0].form_ptr,LIMITS, &attr);
 	attr = attr | FI_ROW_SELECT;
 	FImcf_set_attr(me->forms[0].form_ptr,LIMITS, attr);


 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
 	}
 	if(num_rows){
 		stat = FIfld_delete_rows(me->forms[0].form_ptr,LIMITS, 
 						0,num_rows);
		if(stat != FI_SUCCESS){
			printf("error FIfld_delete_rows: %d\n",stat);
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
 	}

 	/* mettre les prompts et default values dans la forme */

 	FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 0, 
				"Volume", FALSE);

 	if(me->mytype == MODIFY ){
 		vd$get_name(name = name, obj = &(me->limits[0].surf.located_obj));
 		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        senderid = NULL_OBJID,
                        targetid = me->limits[0].surf.located_obj.objid,
                        targetos = me->limits[0].surf.located_obj.osnum );
        		if(!(stat&1)) go =  me->limits[0].surf.located_obj;
        		vd$get_name(name = name, obj = &go);
			if(name[0] == '\0') strcpy(name, "defined");
 		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 1, 
				name, FALSE);
	}
	else  FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 1, 
					"other_generic", FALSE);

 	for(i=1;i<MAX_OBJ;i=i+1){

		sprintf(name,"%s%d","curve",i-1);
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 0, 
					name, FALSE);
		
		if(me->mytype == MODIFY && i < me->nb_limits){
			if (me->Fence == FALSE || i != me->IndexFcObj) {
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
        				if(!(stat&1)) go =  me->limits[i].surf.located_obj;
        				vd$get_name(name = name, obj = &go);
  					if(name[0] == '\0') strcpy(name, "defined");
				}
			}
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1,
  				 name, FALSE);
		}
		else FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1, 
					"curve_generic", FALSE);

 	}
 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
 	}

  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);
  				
  	/* hilite objects */
  	
	if(me->mytype == MODIFY){
        	stat = om$send(msg = message SMCmdSkVol.DispAll(&test),
 		      targetid = my_id);
        	if(!(stat & test & 1)){ 
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
 			return OM_S_SUCCESS;
        	} 
	}
return OM_S_SUCCESS;

}


/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

method clear_form( long *sts )
{

 *sts = OM_S_SUCCESS;
  
 om$send(msg = message SMCmdVol.clear_form(sts),
			mode = OM_e_wrt_message,
		      	targetid = my_id);

 if(me->mytype == MODIFY) 
	FIg_set_text(me->forms[0].form_ptr, LOAD,"Disconnect");
 me->normal_flag = 1;
 me->reverse = -1;	

return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* Get the info from the form to place or modify the macro
/* 
/**/
 
method save_all(long *sts )
{
  int 			i, k,fc, nb_obj, nb_roots, num_char = MY_MAX_CHAR, sel_flag, 
  			r_pos, stat, nb_fail;
  char 			text[MY_MAX_CHAR];
  long			test,sizebuf, nret, msg;
  struct GRid 		mac, *roots, *old_roots;
  struct GRsymbology	symb;
  
  	*sts = OM_S_SUCCESS;
  	roots = NULL;
  	old_roots = NULL;

  	mac.objid = NULL_OBJID;
  	mac.osnum = me->act_env.md_id.osnum;

  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
	if(me->nb_limits < 2){
		ex$message(msgnumb = SM_S_NotObjLoc);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, No enough objects located");
		*sts =  OM_E_ABORT; 
		goto quit;
	} 
 
  
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
		strcpy(me->def_name,text);
		if(!SMCanChgElemName(&mac, text)){
			ex$message(msgnumb = SM_S_ErInvMacNm);
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"ERROR, Invalid macro name");
			*sts =  OM_E_ABORT; 
			goto quit;
		}			
	}
  	/* store value in instances */
  	
  	if(me->normal_flag == -1 ) me->reverse = 1;
  	else me->reverse = 0;
  	

	if(me->Fence == TRUE && me->IndexFcObj == 0) {
		nb_obj = me->nb_FenceObjects ;
		nb_roots = me->nb_limits+1;
	}
	else {
		nb_obj = 1;
		nb_roots = me->nb_limits + 1;
		/*
		 * changement jean (4/12/93)
		 * Avoiding memory fault.
		 * nb_roots = me->nb_limits + me->nb_FenceObjects;
		 */
	}
	nb_fail = 0;
	for(fc = 0; fc < nb_obj; fc++){
		 
  		/* place the macro */

  		if(me->mytype == PLACE){ 
  			mac.objid = NULL_OBJID;
  			mac.osnum = me->act_env.md_id.osnum;
 
  			stat = om$construct(classid = OPP_SMSketchVol_class_id,
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
		k=0;
                for(i=0;i<me->nb_limits;i++) {
  			if(me->Fence == TRUE && i == me->IndexFcObj && i == 0) {
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[i+k+1]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
			else if(me->Fence == TRUE && i == me->IndexFcObj){
				for(k=0;k<me->nb_FenceObjects;k++){
     					stat = as$make_source(
     						go_grid = me->FenceObjects[k].obj_id,
			     			mod_env = &me->FenceObjects[k].mod_env,
			     			as_os   = me->act_env.md_id.osnum,
			     			as_grid = &roots[i+k+1]);
     					as$status(sts = stat);
        				if(!(stat & 1))
          				{ 
 						printf("ERROR as$make_source\n");
 						*sts = OM_E_ABORT;
 						goto quit;
          				} 
				}
			} 
  			else {
     				stat = as$make_source(
     					go_grid = me->limits[i].surf.located_obj,
			     		mod_env = &me->limits[i].surf.module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &roots[i+k+1]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
          		}
  		}

  		if(me->mytype == PLACE){
  			 
                	/*reverse is roots[0] */

                	roots[0].osnum = me->act_env.md_id.osnum;
                	stat = exp$create(exp_name  = NULL,
                                          exp_value = (IGRdouble) me->reverse,
                                          p_exp_id  = &roots[0].objid,
                                          osnum     = roots[0].osnum);
                	if(stat != EXP_S_SUCCESS){
                        	printf("ERROR creating expression for reverse\n");
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
                    			"SMSketchVol",nb_roots, roots,
                    			&me->act_env),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);


  			as$status(sts = stat);
 			if(!(stat & msg & 1)){
        			printf("erreur place macro\n");
        			nb_fail ++;
        			_FREE(roots) ;
        			continue;
  			}
			
			(void)GetDefName(text, me->def_name);
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

			stat = om$send(msg = message SMCmdSkVol.SMmodif_mac
						(nb_roots, roots),
			 		targetid = my_id);
 			if(!(stat & 1)){
 				printf("ERROR  SMCmdSkVol.SMmodif_mac\n");
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
	ex$message(msgnumb = SM_S_ModSucc);if fails SMModify success*/
 }
 else 	{
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successful");
	ex$message(msgnumb = SM_S_PlSucc);
 }

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY)   
		{ex$message(msgnumb = SM_S_ModFail);}
 		
 	else if (mac.objid != NULL_OBJID && 
 		 om$is_objid_valid(osnum = mac.osnum, objid = mac.objid)){

                stat = om$send(msg = message GRgraphics.GRdelete(&msg, 
				&me->act_env),
                             targetid = mac.objid,targetos = mac.osnum);
                as$status(sts = stat);
                if(!(stat&msg&1))printf("ERROR delete macro\n");
                mac.objid = NULL_OBJID;
                FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Fails");
		ex$message(msgnumb = SM_S_PlFail);
 	}
  }
  else{
  	me->select_row = 0;
  	me->pos = 0;
  	if(me->mytype == MODIFY){ 
 		me->old_macro_id = me->macro_id ;
 		strcpy(me->old_def_name,me->def_name);
 		me->old_reverse = me->reverse;
		 me->old_nb_limits =  me->nb_limits;
 		for(i=0;i< me->old_nb_limits;i++)  
 			me->old_limits[i] = me->limits[i];
		for(i=me->old_nb_limits;i<MAX_OBJ;i++) 
			me->old_limits[i].surf.located_obj.objid = NULL_OBJID;
  	}
  	else {
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  		FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  		stat = om$send(msg = message SMCmdSkVol.DispAll(&test),
 		      			targetid = my_id);
  		if(!(stat & test & 1)){ 
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  		} 
   		FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
  		(void)GetDefName(text,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  	}
  }
  /*UI_status("");*/
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
 int		i, k, stat, num_rows;
 long		test;
 char		name[MY_MAX_CHAR];
 struct GRid 	go;

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

     		stat = om$send(msg = message SMCmdSkVol.DispLoc(
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
 		/* mettre les prompts et default values dans la forme */
 
 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 0, 
				"Volume", FALSE);

 		vd$get_name(name = name, obj = &( me->limits[0].surf.located_obj));
 		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        senderid = NULL_OBJID,
                        targetid = me->limits[0].surf.located_obj.objid,
                        targetos = me->limits[0].surf.located_obj.osnum );
        		if(!(stat&1)) go =  me->limits[0].surf.located_obj;
        		vd$get_name(name = name, obj = &go);
			if(name[0] == '\0') strcpy(name, "defined");
 		}
  		if(name[0] == '\0') strcpy(name, "defined");
 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, 0, 1, 
				name, FALSE);

 		for(i=1;i<MAX_OBJ;i=i+1){
			sprintf(name,"%s%d","curve",i-1);
			FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 0, 
				name, FALSE);

			if(me->mytype == MODIFY && i < me->nb_limits){
				if (me->Fence == FALSE || i != me->IndexFcObj){ 
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
        				if(!(stat&1)) go =  me->limits[i].surf.located_obj;
        				vd$get_name(name = name, obj = &go);
  					if(name[0] == '\0') strcpy(name, "defined");
				  }
				}
  				if(name[0] == '\0') strcpy(name, "defined");
 				FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1,
  				 	name, FALSE);
			}
 			else
				FIfld_set_text(me->forms[0].form_ptr, LIMITS, i, 1, 
					"curve_generic", FALSE);

 		}
	}
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  	me->select_row = 0;
  	me->pos = 0;
  	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  	stat = om$send(msg = message SMCmdSkVol.DispAll(&test),
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

method SMmodif_mac(int nb_new; struct GRid  *new)
{
 int			i, oldnb_roots, nb_temp, stat;
 struct GRid 		original, *old_roots;
 char			tmp[10];
 IGRboolean		put_batch, discon;
  
 old_roots = NULL;
 oldnb_roots = 0;
 put_batch = FALSE;
 
 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
					&oldnb_roots),
	senderid = NULL_OBJID,
	targetid = me->macro_id.objid,
	targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP){
 	printf("ERROR retrieve roots of the macro \n");         
	return OM_E_ABORT;
 }
  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
 /* If macro has been move to root due to delete of one of the roots */
 /* Creation of two dummy expression to allow to recreate a depandancy */
 if(oldnb_roots == 0)
  {
    struct GRid exp;
    struct GRid original;
    int         state;
    int         reverse = 0;

    put_batch = TRUE;
    /* Recreate an expression with default parameter */
    exp.osnum = me->ModuleInfo.md_id.osnum;
    stat = exp$create(exp_name  = NULL,
		      exp_value = (IGRdouble)reverse,
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

    as$status(sts = stat);
    if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP)
     {printf("ERROR retrieve roots of the macro \n"); return OM_E_ABORT;}

    /* Macro have probably been move to root .Change it state and
       so it will be recompute when in batch                     */
    stat =  om$send(msg = message ACncpx.ACget_STATE(&state),
		    targetid = me->macro_id.objid ,
		    targetos = me->macro_id.osnum);
    as$status(sts = stat,action = GOTO_VALUE, value = wrapup);
    
    if(state & ncpx_root) /* Move to root */
     {
       stat = om$send(msg = message ACncpx.ACchg_STATE(ncpx_root,~ncpx_root),
		      targetid = me->macro_id.objid ,
		      targetos = me->macro_id.osnum);
       as$status (sts = stat,action = GOTO_VALUE, value = wrapup);
     }
  }

 if(strcmp(me->def_name,me->old_def_name)){
	if(!SMChgElemName(&me->macro_id, me->def_name, &me->act_env)){
		printf("Warning: can't change macro name\n");
	}

 }

 if(me->old_reverse != me->reverse){
 	sprintf(tmp,"%lf", (IGRdouble)me->reverse);
  	stat = exp$modify( 	exp_id  	= old_roots[0].objid,
  				exp_syntax 	= tmp,
  				osnum     	= old_roots[0].osnum);
  	if(stat != EXP_S_SUCCESS){
  		printf("ERROR modify expression for reverse\n");
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
        nb_temp = oldnb_roots - 1;
	if(nb_temp){
  		stat = om$send(msg = message NDnode.NDdisconnect
		      (nb_temp, &old_roots[1]),
                   		senderid = NULL_OBJID,
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
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );

  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDconnect\n");
		return OM_E_ABORT;
  	}
  }

 if(discon) put_batch = TRUE;

 if(put_batch){
     	IGRint  cn_type,wait_batch;

     	cn_type    = 1; /* recompute the object */
     	stat = nd$wait_batch(
     				type  = GR_GEOM_POSTED,
                            	l_object   = & me->macro_id,
                            	l_obj_info = &cn_type,
                            	nb_obj     = 1);

  	as$status(sts = stat);
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

end implementation SMCmdSkVol;




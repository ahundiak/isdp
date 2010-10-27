/* $Id: SMCmdVol.sl,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMCmdVol.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdVol.sl,v $
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
# Revision 1.4  1996/03/22  14:21:00  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.3  1996/01/02  10:22:26  pinnacle
# Replaced: smspace/cmd/SMCmdVol.sl for:  by rgade for vds.240
#
# Revision 1.2  1995/12/28  11:46:04  pinnacle
# Replaced: smspace/cmd/SMCmdVol.sl for:  by rgade for vds.240
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

/*    File          SMCmdVol.sl
      Description   Command object to place limited volumes and surfaces
      Auteur        Pascale Lacroix (ISDC) 
      Date          June 94
*/

command_table        	"vds.cmd"
class                	SMCmdVol
super_class          	VDS_LOCATE
product_name         	"$VDS"
options		     	"SItc"

start_state		terminate

specification

#include <stdio.h>
#include <string.h> 
#include "stdlib.h" 
#include "math.h"
#include "macro.h"

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "acdef.h"
#include "acmacros.h"

#include "AS_status.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "msdef.h"
#include "msmacros.h"
#include "vdsmacros.h"

#include "SMmsg.h"

#include "FI.h"
#include "SMspacecom.h"

#define MAX_SURF	99
#define MAX_TEMP	100



instance 
{
char			macro_name[MY_MAX_CHAR]; /* must be init by subclasses */
char			auto_name[MY_MAX_CHAR]; /* must be init by subclasses */
int			nb_limits;	/* input located objects*/
struct sfinfo	 	limits[MAX_SURF];
int			nb_col_limits; /* nb of column in the field LIMITS */
char			def_name[MY_MAX_CHAR];
int			infinite;
int			extend;

int			old_nb_limits;	/* input located objects*/
struct sfinfo	 	old_limits[MAX_SURF];
char			old_def_name[MY_MAX_CHAR];
int			old_infinite;
int			old_extend;


struct GRmd_env		act_env;
int			select_row; /* if negative, means not in LIMITS field */
int			last_row;   /* last select_row in LIMITS */
int			num_vis_row;/* in LIMITS */
int			pos;

int			start_index; /* first index of template to put     */
				     /* in the field LIMITS                */
struct	sup		*dup;  /* template def (init at reset_form) */
struct GRid		macro_id;
struct GRid		old_macro_id;
IGRboolean		Fence;
struct GRobj_env  	*FenceObjects;

int			nb_FenceObjects;
int			IndexFcObj;
int			delete_elt;
int			delete_row;


}

implementation


#define AS_DEBUG	1

from ASnode		import 	ASreturn_go;
from GRgraphics		import 	GRdisplay;
from EMSsurface		import 	EMshow_normals;
from ACmacro_defn	import 	ACgive_upscan;
extern			SMspace_getTempDefString();

%safe

        static int      x_memo = -1,
                        y_memo = -1;
%endsafe


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 int			i;
 IGRlong		msg, sizebuf, nret;
	
 *sts = OM_S_SUCCESS;

 dp$erase_hilite(msg = &msg);
 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &me->act_env,
                      nret    = &nret);

 me->start_index = 0;
 me->macro_name[0] = '\0';
 me->auto_name[0] = '\0';
 me->macro_id.objid = NULL_OBJID;
 me->old_macro_id.objid = NULL_OBJID;
 
 me->nb_limits = 0;
 me->old_nb_limits = 0;
 for(i=0;i<MAX_SURF;i++) {
	me->limits[i].rev =  0;
	me->old_limits[i].rev = 0;
	me->limits[i].surf.located_obj.objid = NULL_OBJID;
	me->old_limits[i].surf.located_obj.objid = NULL_OBJID;
 } 
 me->nb_col_limits 	= 2;
 me->delete_elt 	= 0;
 me->delete_row 	= 0;
 me->infinite 		= 1;	
 me->old_infinite 	= 1;	   	
 me->extend 		= 1;	
 me->old_extend 	= 1;	   	
 me->def_name[0] 	= '\0';
 me->old_def_name[0] 	= '\0';
 me->select_row 	= 0;
 me->last_row 		= 0;
 me->pos 		= 0;
 me->dup 		= NULL;

 me->Fence       	= FALSE;
 me->FenceObjects 	= NULL;
 me->nb_FenceObjects 	= 0;
 me->IndexFcObj 	= 0;
	
 if(x_memo != -1 || y_memo != -1)
                FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);
 FIfld_get_num_vis_rows(me->forms[0].form_ptr,LIMITS, 
        	&me->num_vis_row);


status = OM_S_SUCCESS;
goto quit;


}
/* ====================== delete_all =============================

    This action delete memory

============================================================= */
action delete_all
{
 IGRlong                msg;

 *sts = OM_S_SUCCESS;

 dp$erase_hilite(msg = &msg);

 if(me->FenceObjects ){free(me->FenceObjects);me->FenceObjects = NULL;}
 if ( me->forms[0].form_ptr != NULL )
     FIf_get_location(me->forms[0].form_ptr,&x_memo,&y_memo);

status = OM_S_SUCCESS;
goto quit;

}

/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			i,state, stat = OM_S_SUCCESS;
 int  			sel_flag, r_pos, num_rows;
 int  			pos, col, row, num_char = MY_MAX_CHAR;
 long			test;
 char 			text[MY_MAX_CHAR];


 if ( form_ptr == NULL ){
 	/*| no form_ptr set */
     	return( OM_E_INVARG ); 
 }
  
 FIg_set_text(form_ptr,FI_MSG_FIELD,"");
 UI_message("");
  
 switch( gadget_label ){
   
  	case FI_ACCEPT:
   	case FI_EXECUTE:
		UI_prompt("");
     		stat = om$send(msg = message SMCmdVol.save_all(&test),
		      targetid = my_id);
     		if(!(stat & test & 1)){
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		if(gadget_label == FI_ACCEPT) _put_response(resp = TERMINATE);
		_put_response(resp = RESTART)	 
     		break;
      
   	case FI_CANCEL: 
     		_put_response(resp = TERMINATE);
     		break;
     
   	case FI_RESET:
     		stat = om$send(msg = message SMCmdVol.reset_form(&test),
			 targetid = my_id);
  		_put_response(resp = MODIF_FORM);
     		break;
   
   	case LOAD:
     		_put_response(resp = LOAD_OCC);
    		break;
    
   	case OCC_NAME:

   		FIfld_get_text(form_ptr,OCC_NAME,0, 0,
                       		num_char, text,&sel_flag,&r_pos);
 		(void)GetDefName(text,me->def_name);
 		FIg_set_text(form_ptr,OCC_NAME,me->def_name);
   		
    		break;

    		
   	case INFINITE:
			FIg_get_state(form_ptr,INFINITE, &state);
			if(state == 1)  me->infinite = 0;
			else me->infinite = 1;
   		
    		break;

   	case LIMITS:

     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos); 
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     		FIfld_get_select(form_ptr,LIMITS,row, 0,&sel_flag);

		if(me->limits[row].surf.located_obj.objid == NULL_OBJID){
 			FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->last_row, 
  				me->pos);
			
 		for(i=0;i< me->nb_col_limits;i++)
 			FIfld_set_select(me->forms[0].form_ptr, LIMITS,me->last_row, i, TRUE);
			break;
		}

      		if(me->delete_elt ){

			/* get the row to be deleted */

			me->delete_row = (sel_flag == TRUE) ? row : -1;
     			if(sel_flag == TRUE){
				me->select_row = row;
        			stat = om$send(msg = message SMCmdVol.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			} 
				me->select_row = 0;
 				FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
					"Valid with disconnect button");
				break;
				
     			}
 			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
				"Select the Elt to be disconnected");
			break;
		}
     		stat = FIfld_get_num_rows(form_ptr,LIMITS, &num_rows);
     		if(stat != FI_SUCCESS) {
			printf("error FIfld_get_num_rows\n");
			goto quit;
     		}
     		FImcf_get_active_col(  form_ptr,LIMITS, &col, &pos); 
     		FIfld_get_active_row(form_ptr,LIMITS, &row, &pos);
     
        	me->select_row = row;
        	me->last_row = row;
		me->pos = pos;
     		FIfld_get_select(form_ptr,LIMITS,me->select_row, 
     						0,&sel_flag);
     		if(sel_flag == TRUE){
        		stat = om$send(msg = message SMCmdVol.DispAll
        						(&test),
 		      			targetid = my_id);
        		if(!(stat & test & 1)){ 
 					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        		} 
        		break;
     		}
  		_put_response(resp = MODIF_FORM);
     		break;
     

} /* END switch ( gadget_label ) */
  
  
  return OM_S_SUCCESS;
}


/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

action clear_form
{
  int 	i,num_rows, stat;
  long	msg;
  
 	
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");

 me->macro_id.objid = NULL_OBJID;

 if(me->mytype == PLACE) me->nb_limits = 0;

 for(i=0;i<MAX_SURF;i++) {
	me->limits[i].surf.located_obj.objid = NULL_OBJID;
	me->limits[i].rev = 0;
 }

 me->nb_limits = 0;

 me->nb_col_limits 	= 2;
 me->delete_elt 	= 0;
 me->delete_row 	= 0;
 me->infinite 		= 1;	
 me->old_infinite 	= 1;	   	
 me->extend 		= 1;	
 me->old_extend 	= 1;	   	
 me->def_name[0] 	= '\0';
 me->old_def_name[0] 	= '\0';
 me->select_row 	= 0;
 me->last_row 		= 0;
 me->pos 		= 0;
 me->dup 		= NULL;

 me->Fence       	= FALSE;
 me->FenceObjects 	= NULL;
 me->nb_FenceObjects 	= 0;
 me->IndexFcObj 	= 0;
	

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


status = OM_S_SUCCESS;
goto quit;

}

/* ----------------------------------------------------------------- */ 
/*
/* reinit all instances, reinit form, set all default prompts and 
/* template types of the macro 
/*
/**/
 
action reset_form
{
 int		i, stat, num_rows;
 long		attr;
 long		test;
 struct GRid	mac;
 long		msg;
  
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);

 if(me->forms[0].form_ptr == NULL){
       	*sts = OM_E_ABORT;
       	return OM_S_SUCCESS;
 }
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 me->select_row = 0;
 me->pos = 0;
 me->last_row = 0;
 me->Fence = FALSE;
 me->FenceObjects = NULL;
 me->nb_FenceObjects = 0;
 me->IndexFcObj = 0;
 me->infinite = 1;
 me->extend = 1;


 mac.objid = NULL_OBJID;

 if(me->mytype != MODIFY) {
	me->nb_limits = 0;
	(void)GetDefName(me->auto_name,me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
	for(i=0;i<MAX_SURF;i++) {
		me->limits[i].surf.located_obj.objid = NULL_OBJID;
		me->limits[i].rev = 0;
	}
 }
 else {
	me->nb_limits = me->old_nb_limits;
	me->infinite = me->old_infinite;
	me->extend = me->old_extend;
 	me->macro_id = me->old_macro_id;
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
	for(i=0;i<MAX_SURF;i++)me->limits[i] = me->old_limits[i];
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
	
 stat = om$send(msg = message SMCmdVol.load_macro(&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){ 
 	printf("ERROR load macro\n");
 	*sts = OM_E_ABORT;
 	return OM_S_SUCCESS;
 }


 for(i=0;i< me->nb_col_limits;i++)
 	FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, i, TRUE);

 FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,me->select_row, 
  				me->pos);
  				
 /* hilite objects */
 	
 if(me->mytype == MODIFY){
       	stat = om$send(msg = message SMCmdVol.DispAll(&test),
 		      targetid = my_id);
       	if(!(stat & test & 1)){ 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
       	} 
 }

status = OM_S_SUCCESS;
goto quit;

}

/* ----------------------------------------------------------------- */ 
/*
/* display the object at the given index 
/*
/**/
 
action DispLoc(int index; enum GRdpmode mode)
{
 struct  GRid            currentModule ;
 long                    sts ;
 struct GRlc_info	 obj;
 int			 i;

 /*|get cur mod*/
 
 ex$get_cur_mod( id      = &currentModule.objid,
                 osnum   = &currentModule.osnum ) ;


 if( me->Fence == TRUE && index == me->IndexFcObj){
	/* display the elts in the fence */
		
	for(i=0; i<me->nb_FenceObjects;i++){
		status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        	senderid = NULL_OBJID,
                        	targetid = me->FenceObjects[i].obj_id.objid,
                        	targetos = me->FenceObjects[i].obj_id.osnum );
                        	
		 /* Jean 5/7/93 Not found : one sourcein not connected */
		if(status & 1) { 
 			status = om$send(msg     = message GRgraphics.GRdisplay(
                  			&sts,
                                	&obj.module_info.md_env.matrix_type,
                                	obj.module_info.md_env.matrix,
                                	&mode,
                                	&currentModule ),
         			targetid= obj.located_obj.objid,
         			targetos= obj.located_obj.osnum ) ;
			as$status();
 			if (!(status & 1)){
            				printf("error in sending GRgraphics.GRdisplay\n");
            				return OM_E_ABORT;
      			}
		}
	}
 }
 else{
	if(index < 0) return OM_S_SUCCESS;
 	if(me->limits[index].surf.located_obj.objid == NULL_OBJID) 
	     		return OM_S_SUCCESS;

 	status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->limits[index].surf.located_obj.objid,
                        targetos = me->limits[index].surf.located_obj.osnum );

 	/* Jean 5/7/93 Not found : one sourcein not connected */
 	if(status & 1){
 		status = om$send(msg     = message GRgraphics.GRdisplay(
                  		&sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
         		targetid= obj.located_obj.objid,
         		targetos= obj.located_obj.osnum ) ;
 		as$status();
 		if (!(status & 1)){
            		printf("error in sending GRgraphics.GRdisplay\n");
            		return OM_E_ABORT;
 		}
 	}
 }

goto quit;
 
}

/* ----------------------------------------------------------------- */ 
/*
/* hilite all the located objects (semi_hilite and hilite the selected object)
/*
/**/

 
action DispAll
{
int			i, stat;
enum   GRdpmode		mode;


*sts = OM_S_SUCCESS;


for(i=0;i< me->nb_limits;i++){
	if(me->limits[i].surf.located_obj.objid == NULL_OBJID) continue;
	mode = GRhhd;
	if (me->select_row == i) mode = GRhd;
     	stat = om$send(msg = message SMCmdVol.DispLoc(
     						i, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
                ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
                return  OM_S_SUCCESS;
        }
}
status = OM_S_SUCCESS;
goto quit;


} 


/* ----------------------------------------------------------------- */ 
/*
/* set the active row, and display of the objects
/*
/**/
 
action next_row
{
 int	i, num_rows, stat;
 long	test;
 
 *sts = OM_S_SUCCESS;

 
 if (me->select_row < 0 ) return OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 stat = FIfld_get_num_rows(me->forms[0].form_ptr,LIMITS, &num_rows);
 if(stat != FI_SUCCESS) {
 	printf("error FIfld_get_num_rows: %d\n",stat);
 	*sts = OM_E_ABORT;
 	return OM_S_SUCCESS;
 }
 if(me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID){
	/* MOVE_ON on TEMPLATE */
	for(i=0;i< me->nb_col_limits; i++)	
 		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, i, TRUE);

 	me->select_row = 0;
 	me->last_row = 0;
 	me->pos = 0;
 	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
       	stat = om$send(msg = message SMCmdVol.DispAll(&test),
 		      targetid = my_id);
       	if(!(stat & test & 1))
       	{ 
 		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
       	} 
 	*sts = END_TEMP;
 	return OM_S_SUCCESS;
 }
 me->last_row ++;
 me->select_row ++;
 me->pos ++;

 stat = om$send(msg = message SMCmdVol.display_normal(&test),
 		      	targetid = my_id);
 stat = om$send(msg = message SMCmdVol.DispAll(	&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){ 
 	ex$message(msgnumb = SM_S_ErrDsp);
 	*sts = OM_E_ABORT;
 	return OM_S_SUCCESS;
 } 

 if(me->select_row < num_rows){
	for(i=0;i< me->nb_col_limits; i++)
 		FIfld_set_select(me->forms[0].form_ptr, LIMITS,
  					me->select_row, i, TRUE);
 }
 else {
	for(i=0;i< me->nb_col_limits; i++)
 		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, i, TRUE);

 	me->select_row = 0;
 	me->last_row = 0;
 	me->pos = 0;
 	*sts = END_TEMP;
 }
 if(me->pos < me->num_vis_row)
 	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
 else {
 	me->pos --;
 	FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   				me->select_row, me->pos);
 }
 
status = OM_S_SUCCESS;
 goto quit;

 
}

/* ----------------------------------------------------------------- */ 
/*
/* verify about the deleted object
/*
/**/


action verify_obj
{
 int	i;

 *sts = OM_S_SUCCESS;
 
 for(i=0;i<me->nb_limits;i++){
	if(me->Fence == TRUE && me->IndexFcObj == i) continue;
	if(me->limits[i].surf.located_obj.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->limits[i].surf.located_obj.osnum,
			       objid = me->limits[i].surf.located_obj.objid)&1) ){
   	 	ex$message(msgnumb = SM_S_ElDel);
   	 	me->state = _terminate;
   	 	return OM_S_SUCCESS;
	}
 }

 status = OM_S_SUCCESS;
 goto quit;

}

/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance 
/*
/**/
 
action store_obj(long	*sts; int	max_obj)
{
 enum GRdpmode		mode;
 int			stat;
 char			name[MY_MAX_CHAR];
 
 *sts = OM_S_SUCCESS;

 	
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 if(me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID)	
			me->nb_limits ++;
  else {
	mode = GRhe;
     	stat = om$send(msg = message SMCmdVol.DispLoc(
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
    	
  name[0] = '\0';
  vd$get_name(name = name, obj = &(me->limits[me->select_row].surf.located_obj));
  if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		vd$get_name(name = name, obj = &(me->event1.located_object[0].located_obj ));
        		if(name[0] == '\0') strcpy(name, "defined");
		}
  FIfld_set_text(me->forms[0].form_ptr, LIMITS,me->select_row,
  			1, name, TRUE);
 
 	  
wrapup:

 status = OM_S_SUCCESS;
 goto quit;

}
/* ----------------------------------------------------------------- */ 
 


action display_normal
{
long			msg,sizebuf, nret;
int			stat;
struct GRlc_info	obj;
struct GRmd_env		md_env;
struct IGRdisplay	dis;

 dp$erase_hilite(msg=&msg);
 *sts = OM_S_SUCCESS;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg    = &msg, sizbuf  = &sizebuf,
                        buffer = &dis, nret    = &nret);

 if(me->limits[me->select_row].surf.located_obj.objid == NULL_OBJID) return OM_S_SUCCESS;
		
 stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                       senderid = NULL_OBJID,
                       targetid = me->limits[me->select_row].surf.located_obj.objid,
                       targetos = me->limits[me->select_row].surf.located_obj.osnum);
 md_env =  obj.module_info;
 md_env.md_id = me->act_env.md_id;

 stat = om$send( msg = message EMSsurface.EMshow_normals( &msg,
 							  &md_env,
 							  &dis,
 							  GRhd),
         	targetid= obj.located_obj.objid,
         	targetos= obj.located_obj.osnum ) ;

 status = OM_S_SUCCESS;
 goto quit;

}

/* --------------------------------------------- */

action load_macro
{
 int			i, k, stat, Nb_Max_Temp ;
 char			*c, name[MY_MAX_CHAR], text[MY_MAX_CHAR];
 struct GRid		go, mac;
 int			def_properties;
 long			msg;

 *sts = OM_S_SUCCESS;


 Nb_Max_Temp = 0;
 strcpy(name, "defined");  
 stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = me->macro_name,
                            p_macro_defn_id     = &mac );

 if (!(stat & 1) || IF_NULL_OBJID(mac.objid)){
		printf("error macro not found\n");
		*sts = OM_E_ABORT;
		goto quit;
 }
 stat = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&def_properties,&me->dup),
                           targetid = mac.objid,
                           targetos = mac.osnum );

 as$status(sts = stat);
 if(!(stat & 1)){
	printf("error  ACmacro_defn.ACgive_upscan\n");
	*sts = OM_E_ABORT;
	goto quit;
 }
 k=0;
 for(i=me->start_index;i<Nb_Max_Temp;i=i+1){
	SMspace_getTempDefString( &msg, me->dup[i].type, text );

	FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 0, 
				me->dup[i].prompt, FALSE);
	if(k < me->nb_limits){
		if(me->limits[k].surf.located_obj.objid != NULL_OBJID){
			vd$get_name(name = name, obj = &(me->limits[k].surf.located_obj));
			if(name[0] == '\0') {
        			/* try get name on the graphic object */
        			stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
                        		senderid = NULL_OBJID,
                        		targetid = me->limits[k].surf.located_obj.objid,
                        		targetos = me->limits[k].surf.located_obj.osnum );
        			if(!(stat&1)) {
					strcpy(name,"missing");/* Jean : pretend not connected*/	
					go =  me->limits[k].surf.located_obj;
				}
        			else vd$get_name(name = name, obj = &go);
  				if(name[0] == '\0') strcpy(name, "defined");
			}
		}

 		FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1,
  				 name, FALSE);
	}
 	else
		FIfld_set_text(me->forms[0].form_ptr, LIMITS, k, 1, 
					text, FALSE);

	k++;
 }



status = OM_S_SUCCESS;
goto quit;
}

/* $Id: SMBndNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMBndNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMBndNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/03/19  20:17:46  pinnacle
# TR_179900401
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/29  09:06:48  pinnacle
# Replaced: smspace/cmd/SMBndNotif.I for:  by ksundar for vds.240
#
# Revision 1.4  1996/03/22  14:17:40  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.3  1996/01/24  20:07:30  pinnacle
# Replaced: ./smspace/cmd/SMBndNotif.I for:  by azuurhou for vds.240
#
# Revision 1.2  1996/01/02  10:21:20  pinnacle
# Replaced: smspace/cmd/SMBndNotif.I for:  by rgade for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	03/19/99	ejm	TR_179900401: Command doesn't work if ALL
 *				bounding surfaces parents are missing.
 *				Added NDconnect call if me->nb_objects = 0.
 * -------------------------------------------------------------------*/

 /*               SMBndNotif.I                    */
 /*   Methods  and functions for SMSfBnd          */ 
 /*   Methods for the CO                          */
 /*   Pascale Lacroix  (ISDC)			  */
 /*   Creation date July-92                       */
  
class implementation SMCmdSfBnd;
  
#define AS_DEBUG	1
 
#include <string.h> 
#include "expression.h"
#include "acmacros.h"
#include "macro.h"
#include "parametric.h"
#include "FI.h"
#include "SMmsg.h"
#include "vdsmacros.h"
#include "nddef.h"	/* ND_ADD    */
#include "asbox.h"	/* NULL_GRID */

#include "AS_status.h"
#include "VDmem.h"
// #define vdsDEBUG     1
#include "v_dbgmacros.h"


#define SEVERE_ERROR    4

#define PLACE    	0
#define MODIFY		1
 
#define AS_DEBUG	1
 
#define SEVERE_ERROR    4
#define BAD_LOCATED	507
#define END_TEMP 	509
#define LOAD_OCC 	511
#define NO_OBJ 	513
#define TOO_FENCE 	515
#define MD_FENCE 	517
#define LOAD_TRACK 	519
#define RESTART 	521
#define LOAD_FORM 	523
#define DEL_ELT 	525

 
extern GRclassid 	OPP_EMSsurface_class_id;
extern SMspace_getTempDefString();
 
from GRgraphics		import GRdelete, GRdisplay;
from SMSfBnd		import SMcreate, SMModify;
from ACmacro_defn 	import ACgive_upscan;
from NDnode		import NDget_objects, NDconnect;
from ASnode		import ASreturn_go;
from SMmgr		import SMGetAttDbl,SMGetAttTxt;
from ACncpx		import ACmplace,ACchg_STATE,ACget_STATE;

%safe
static int Reconnect=FALSE;
%endsafe


/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance (management of fence)
/*
/**/
 
method store_obj(long *sts)
{
 enum GRdpmode		mode;
 int			i, nb_obj, stat;
 long			test;
 GRclassid		obj_classid;
 char			name[MAX_CHAR];
 struct GRobj_env  	*LocatedObjects;
 extern int 		(*AStranslate)()  ;


 SetProc( store_obj ); Begin  

 	*sts = OM_S_SUCCESS;
 	
  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
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
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Invalid Locate");
     		*sts = TOO_FENCE;
        	stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
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
     		stat = om$send(msg = message SMCmdSfBnd.DispLoc(
     						me->select_row, mode),
                        		targetid= my_id ) ;

     		if (!(stat & 1)){
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
			goto wrapup;
        	}
   		
   		me->Fence = FALSE;
   		me->IndexFcObj = -1;
   		me->nb_FenceObjects = 0;
   		_FREE(me->FenceObjects); 
   		
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
	if(me->objects[me->select_row].located_obj.objid == NULL_OBJID)	
			me->nb_objects ++;
	else {
		mode = GRhe;
     		stat = om$send(msg = message SMCmdSfBnd.DispLoc(
     						me->select_row, mode),
                        		targetid= my_id ) ;

     		if (!(stat & 1)){
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
			goto wrapup;
        	}
	}
	if(me->nb_objects > MAX_SURF) /* Jean : 21 april 93 - Replace == by > */
	{			  
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  			"ERROR, Too much objects");
 		ex$message(msgnumb = SM_S_TooObj);
 		*sts = OM_E_ABORT;
 		goto wrapup;
 	}
	 
 	if(me->select_row == 0){
 		for(i=0;i<nb_obj;i++){
 			/* verify the support is a surface */
  			om$get_classid(	osnum     = LocatedObjects[i].obj_id.osnum, 
 			 		objid     =  LocatedObjects[i].obj_id.objid, 
 			 		p_classid = &obj_classid);
  			if( om$is_ancestry_valid(subclassid   = obj_classid,
 			  		superclassid = OPP_EMSsurface_class_id )
 			   			!= OM_S_SUCCESS ){ 
 				*sts = BAD_LOCATED;
 				goto wrapup;
 			}  
 		}      	
 		
 	}
 	if(nb_obj <= 1){
	    __DBGpr_obj ("as$make_source: go_grid:", me->event1.located_object[0].located_obj);
     		stat = as$make_source(
     			     go_grid = me->event1.located_object[0].located_obj,
			     mod_env = &me->event1.located_object[0].module_info,
			     as_os   = me->act_env.md_id.osnum,
			     as_grid = &me->objects[me->select_row].located_obj);
     		as$status(sts = stat);
        	if(!(stat & 1))
         	{ 
 			printf("ERROR as$make_source\n");
 			*sts = OM_E_ABORT;
 			goto wrapup;
          	}
	    __DBGpr_obj ("as$make_source: as_grid:", me->event1.located_object[0].located_obj);
          	me->objects[me->select_row].module_info = me->event1.located_object[0].module_info;
        } 
        else
        	me->objects[me->select_row] = me->event1.located_object[0];
        
	name[0] = '\0';
	if(me->select_row != me->IndexFcObj){
		vd$get_name(name = name,
			    obj = &(me->objects[me->select_row].located_obj));
		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		vd$get_name(name = name, 
			   obj = &(me->event1.located_object[0].located_obj ));
        		if(name[0] == '\0') strcpy(name, "defined");
		}
	}
 	if(name[0] == '\0') strcpy(name, "defined");
 	FIfld_set_text(me->forms[0].form_ptr, INFINITE,me->select_row,
  			1, name, FALSE);
 
 	  
wrapup:

ASend_fence();  
 End
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

 SetProc( verify_obj ); Begin  

 *sts = OM_S_SUCCESS;
 
 if(me->track_elt.located_obj.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->track_elt.located_obj.osnum,
			       objid = me->track_elt.located_obj.objid)&1) ){
 	ex$message(msgnumb = SM_S_TrkDel);
   	me->state = _terminate;
   	return OM_S_SUCCESS;
 }
 for(i=0;i<me->nb_objects;i++){
 	if(me->objects[i].located_obj.objid != NULL_OBJID && 
	! ( om$is_objid_valid( osnum = me->objects[i].located_obj.osnum,
			       objid = me->objects[i].located_obj.objid)&1) ){
 		ex$message(msgnumb = SM_S_ElDel);
   	 	me->state = _terminate;
   	 	return OM_S_SUCCESS;
	}
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

 End
 return OM_S_SUCCESS;

}


/* ----------------------------------------------------------------- */ 
/*
/* store the element that must be the track element
/*
/**/


method store_track(long *sts)
{
 int			stat;
 char			name[MAX_CHAR];
 long			test;

 SetProc( store_track ); Begin  

 *sts = OM_S_SUCCESS;

 	
 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 me->track_elt = me->event1.located_object[0];
     	
 stat = as$make_source(
     			go_grid = me->event1.located_object[0].located_obj,
			mod_env = &me->event1.located_object[0].module_info,
			as_os   = me->act_env.md_id.osnum,
			as_grid = &me->track_elt.located_obj);
 as$status(sts = stat);
 if(!(stat & 1))
  { 
 	printf("ERROR as$make_source\n");
 	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
  } 

 me->Track = 1;
 vd$get_name(name = name, obj = &(me->track_elt.located_obj));
 if(name[0] == '\0') {
        /* try get name on the graphic object */
        vd$get_name(name = name, obj = &(me->event1.located_object[0].located_obj ));
        if(name[0] == '\0') strcpy(name, "defined");
 }

 FIg_set_text(me->forms[0].form_ptr, TRACK_F,name);
				
 stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
 		      targetid = my_id);
 if(!(stat & test & 1)){ 
			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
 			return OM_S_SUCCESS;
 } 
 End
 return OM_S_SUCCESS;
 
}


/* ----------------------------------------------------------------- */ 
/*
/* set the active row, and display of the objects
/*
/**/
 
method next_row(long *sts)
{
 int	i, num_rows, stat;
 long	test;

 
 SetProc( next_row ); Begin  

	*sts = OM_S_SUCCESS;
  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
	stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
	if(stat != FI_SUCCESS) {
 		printf("error FIfld_get_num_rows: %d\n",stat);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
	}
	for(i=0;i<num_rows;i++){
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 0, FALSE);
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 1, FALSE);
	}
	if(me->objects[me->select_row].located_obj.objid == NULL_OBJID){
		/* MOVE_ON on TEMPLATE */
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
 		me->select_row = 0;
 		me->pos = 0;
   		FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,
   					me->select_row, me->pos);
        	stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
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
	me->select_row ++;
	me->pos ++;

        stat = om$send(msg = message SMCmdSfBnd.DispAll(	&test),
 		      targetid = my_id);
        if(!(stat & test & 1)){ 
		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		return OM_S_SUCCESS;
        } 

	if(me->select_row < num_rows){
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,
   					me->select_row, 0, TRUE);
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,
   				me->select_row, 1, TRUE);
	}
	else {
#ifdef OLD_CODE
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
 		me->select_row = 0;
 		me->pos = 0;
 		*sts = END_TEMP;
#endif
	  /* Jean : 21 april 93 . Why force saving ? I prefer foolowing code */
	  	me->select_row--; /* Else >= num_rows ==> not existing */
		FIfld_set_select(me->forms[0].form_ptr, INFINITE,
   					me->select_row, 0, TRUE);
   		FIfld_set_select(me->forms[0].form_ptr, INFINITE,
   				me->select_row, 1, TRUE);
	}
	if(me->pos < me->num_vis_row)
   		FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,
   					me->select_row, me->pos);
	else {
 		me->pos --;
   		FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,
   				me->select_row, me->pos);
	}
End 
return OM_S_SUCCESS;
 
}

/* ----------------------------------------------------------------- */ 
/*
/* hilite all the located objects (semi_hilite and hilite the selected object)
/*
/**/

 
method DispAll(long *sts)
{
int			i, stat;
enum   GRdpmode		mode;
struct GRid     	currentModule ;
struct GRlc_info	obj;

 SetProc( DispAll ); Begin  

*sts = OM_S_SUCCESS;

mode = GRhhd;
if(me->track_elt.located_obj.objid != NULL_OBJID){
 	ex$get_cur_mod( id      = &currentModule.objid,
                 	osnum   = &currentModule.osnum ) ;
		
	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->track_elt.located_obj.objid,
                        targetos = me->track_elt.located_obj.osnum );

	/* Jean 5/7/93 Not found : one sourcein not connected */
	if(stat & 1){
 		stat = om$send(msg     = message GRgraphics.GRdisplay(
                  		sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
         	targetid= obj.located_obj.objid,
         	targetos= obj.located_obj.osnum ) ;
        	as$status(sts = stat);
 		if (!(stat & 1)){
            		printf("error in sending GRgraphics.GRdisplay\n");
            		return OM_E_ABORT;
      		}
	}

}
for(i=0;i< me->nb_objects;i++){
	if(me->objects[i].located_obj.objid == NULL_OBJID) continue;
	mode = GRhhd;
	if (me->select_row == i) mode = GRhd;
     	stat = om$send(msg = message SMCmdSfBnd.DispLoc(
     						i, mode),
                        		targetid= my_id ) ;

     	if (!(stat & 1)){
		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
                return  OM_S_SUCCESS;
        }
}
End
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
 int			 i;
 long                    status;
 struct  GRid            currentModule ;
 long                    sts ;
 struct GRlc_info	obj;
 

 SetProc( DispLoc ); Begin  

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
	}
	else{
	     	if(me->objects[index].located_obj.objid == NULL_OBJID) 
	     		return OM_S_SUCCESS;

		status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->objects[index].located_obj.objid,
                        targetos = me->objects[index].located_obj.osnum );

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
End
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
 int			i, k, stat, count, 
 			num_rows, Nb_Max_Temp ;
 long			attr ;
 char			*c, text[MAX_CHAR],name[MAX_CHAR];
 IGRdouble 		dbl_val;
 long			test, msg;
 struct GRid		go, *roots, mac;
 int			def_properties;
 unsigned int		mask;
 IGRshort 		type;

 SetProc( store_occ ); Begin  

 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 dp$erase_hilite(msg = &msg);
 me->select_row = 0;
 me->pos = 0;
 roots = NULL;
 	
 me->macro_id = me->event1.located_object[0].located_obj;

 __DBGpr_obj ("me->macro_id:", me->macro_id);

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

 __DBGpr_int ("count of roots", count);
 	for(i=0;i< count;i++)  {
 __DBGpr_ith_obj(" roots", i, roots);
	}

 if(count > 0)  /* Common case : macro is OK */
  {
 	/* Get the offset */

 	stat = om$send(msg = message SMmgr.SMGetAttDbl
		   (&msg,"offset",&me->offset,&type),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
 	as$status(sts = stat);
 	if(!(stat & msg & 1))
   		{printf("Error get offset objid = %d\n",my_id); goto wrapup;}

 	SMConvDistIntExt(me->offset, &me->offset, me->act_env.md_id.osnum);

 	/* Get the ordered flag */

 	stat = om$send(msg = message SMmgr.SMGetAttDbl
		   (&msg,"ordered",&dbl_val,&type),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
 	as$status(sts = stat);
 	if(!(stat & msg & 1))
   		{printf("Error get ordered flag objid = %d\n",my_id); goto wrapup;}
	
	me->ordered = (int) dbl_val;

 	/* Get the track  */

 	stat = om$send(msg = message SMmgr.SMGetAttDbl
		   (&msg,"track",&dbl_val,&type),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
 	as$status(sts = stat);
 	if(!(stat & msg & 1))
   		{printf("Error get track flag objid = %d\n",my_id); goto wrapup;}
	
	me->Track = (int) dbl_val;

 	/* Get the rev_sup */

 	stat = om$send(msg = message SMmgr.SMGetAttDbl
		   (&msg,"rev_sup",&dbl_val,&type),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
 	as$status(sts = stat);
 	if(!(stat & msg & 1))
   		{printf("Error get rev_sup flag objid = %d\n",my_id); goto wrapup;}
	
	me->rev = (int) dbl_val;

 	

	if(me->Track) me->old_nb_objects = me->nb_objects = count - 2;
 	else me->old_nb_objects = me->nb_objects = count -1;

	if( me->nb_objects == 0 ){
	  __DBGpr_com("Reconnect=TRUE");
	  Reconnect=TRUE;
	}
 	
 	for(i=0;i< me->nb_objects;i++)  {
 		stat = GetEnvFrObj(	&roots[i+1], 
 		 			&me->objects[i].module_info,
 		 			NULL);
    		/* Jean: if error macro has probably lost one parent */
    		if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}
 		me->objects[i].located_obj =  roots[i+1];
#ifdef vdsDEBUG
		printf("\tme->objects[%d]: %d,%d", i, me->objects[i].located_obj.objid, me->objects[i].located_obj.osnum);
#endif
 	}
	if(me->Track){
 		stat = GetEnvFrObj(	&roots[count-1], 
 		 			&me->track_elt.module_info,
 		 			NULL);
    		/* Jean: if error macro has probably lost one parent */
    		if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}
 		me->track_elt.located_obj = roots[count-1];
	}
 	/* Get the infinite */

  	stat = om$send(msg = message SMmgr.SMGetAttDbl
		   (&msg,"infinite",&dbl_val,&type),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
  	as$status(sts = stat);
  	if(!(stat & msg & 1))
   		{printf("Error get infinite objid = %d\n",my_id); goto wrapup;}

  	mask = (unsigned int) dbl_val;
  
  	SMGetInfFrmMask(me->nb_objects, mask,me->infinite);
 }

 else     /* Jean : 5/4/93  Macro is broken : user  will relocate parents*/
  {
    __DBGpr_com("Warning : macro has no parent");
    ex$message(msgnumb =  SM_I_NoParMac);

    me->old_nb_objects = me->nb_objects  = 0;

     /* Recreate an expression with default parameter */
    me->offset = 0.0;
    me->rev = 0;
    me->ordered =0;
    me->Track = 0;
    me->track_elt.located_obj.objid = NULL_OBJID;
    for(i=0;i<MAX_SURF;i++) {
		me->infinite[i] = 'Y';	
		me->objects[i].located_obj.objid = NULL_OBJID;
    }

  }
	
 	if(me->mytype == MODIFY) {
 		for(i=0;i< me->old_nb_objects;i++)
 			me->old_objects[i] = me->objects[i];
 		me->oldtrack_elt = me->track_elt;
	}
 	FImcf_get_attr(me->forms[0].form_ptr,INFINITE, &attr);
 	attr = attr | FI_ROW_SELECT;
 	FImcf_set_attr(me->forms[0].form_ptr,INFINITE, attr);
 
	vd$get_name( name = me->def_name, obj = &me->macro_id);
	
 	if(me->mytype == MODIFY) {
		me->old_nb_objects = me->nb_objects;
 		strcpy(me->old_def_name,me->def_name);
		me->old_macro_id = me->macro_id;
 		me->old_offset = me->offset;
 		me->old_ordered = me->ordered;
 		me->old_track = me->Track;
 		me->old_rev = me->rev;
 	}
	else (void)GetDefName("SMSfBnd_0",me->def_name);

 	FIg_set_text(me->forms[0].form_ptr,NAME,me->def_name);
	FIfld_set_value(me->forms[0].form_ptr, OFFSET, 0, 0, 
				me->offset, FALSE);
	
 	if(me->ordered == 0)
 		FIg_set_state_off(me->forms[0].form_ptr, ORDERED);
 	else 
 		FIg_set_state_on(me->forms[0].form_ptr, ORDERED);
 	if(me->Track == 0)
		FIg_set_text(me->forms[0].form_ptr,TRACK_F,"No Track Element");
 	else {
	   if(me->track_elt.located_obj.objid!= NULL_OBJID){
 		vd$get_name(name = name, obj = &(me->track_elt.located_obj));
 		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        	senderid = NULL_OBJID,
                        	targetid = me->track_elt.located_obj.objid,
                        	targetos = me->track_elt.located_obj.osnum );
        		if(!(stat&1)) {
				strcpy(name,"missing");/* Jean : pretend not connected */
				go =  me->track_elt.located_obj;
			}
        		else vd$get_name(name = name, obj = &go);
			if(name[0] == '\0') strcpy(name, "defined");
		}
	    }
 	    FIg_set_text(me->forms[0].form_ptr, TRACK_F,name);
	}
 	if(me->rev == 0)
 		FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 	else 
 		FIg_set_state_on(me->forms[0].form_ptr, ORIENT);

 	if(me->mytype == MODIFY) 
 		SMGetInfFrmMask(me->nb_objects, mask,me->old_infinite);


 	stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMSfBnd",
                            p_macro_defn_id     = &mac );

	as$status(sts = stat);
 	if (!(stat & 1) || IF_NULL_OBJID(mac.objid)){
		printf("error macro not found\n");
		*sts = OM_E_ABORT;
		goto wrapup;
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
		goto wrapup;
 	}
 	
	__DBGpr_int ("me->nb_objects", me->nb_objects);

 	k=0; 
 	for(i=1;i<Nb_Max_Temp;i=i+1){
		SMspace_getTempDefString( &msg, me->dup[i].type, text );

		FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 0, 
					me->dup[i].prompt, FALSE);
		if(k< me->nb_objects){
			if (k != me->IndexFcObj){ 
			   if(me->objects[k].located_obj.objid != NULL_OBJID){
 				vd$get_name(name = name, obj = &(me->objects[k].located_obj));
				if(name[0] == '\0') {
        				/* try get name on the graphic object */
        				stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
                        			senderid = NULL_OBJID,
                        			targetid = me->objects[k].located_obj.objid,
                        			targetos = me->objects[k].located_obj.osnum );
        				if(!(stat&1)) {
						__DBGpr_com("missing");
						strcpy(name,"missing");/* Jean : pretend not connected */
						go =  me->objects[k].located_obj;
					}
        				else vd$get_name(name = name, obj = &go);
  					if(name[0] == '\0') strcpy(name, "defined");
				}
			    }
			}
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1,
  				 name, FALSE);
		}
		else FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1, 
					text, FALSE);
		if(me->infinite[k] == 'n' ||  me->infinite[k] == 'N')
			FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"N", FALSE);
		else FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"Y", FALSE);
		k++;
 	}
 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		goto wrapup;
 	}
  	for(i=0;i<num_rows;i++){
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 0, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 1, FALSE);
  	}

  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
  	FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,me->select_row, 
  				me->pos);
        stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
 		      targetid = my_id);
        if(!(stat & test & 1)){ 
		ex$message(msgnumb = SM_S_ErrDsp);
 		*sts = OM_E_ABORT;
 		goto wrapup;
        } 
 	if(me->mytype != MODIFY) FIg_set_state_off(me->forms[0].form_ptr, LOAD);


wrapup:
  End
  return OM_S_SUCCESS;

} 

/* ----------------------------------------------------------------- */ 
/*
/* reinit all instances, reinit form, set all default prompts and 
/* template types of the macro 
/*
/**/
 
method reinit_form(long *sts)
{
 int		i, k, stat, num_rows, Nb_Max_Temp ;
 long		attr ;
 char		*c, name[MAX_CHAR], text[MAX_CHAR];
 int		def_properties;
 struct GRid	go, mac;
 long		msg, test;
  
 	*sts = OM_S_SUCCESS;
  	dp$erase_hilite(msg = &msg);

  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");

	me->Fence = FALSE;
	me->FenceObjects = NULL;
	me->nb_FenceObjects = 0;
	me->IndexFcObj = -1;
 	me->select_row = 0;
 	me->pos = 0;

	mac.objid = NULL_OBJID;

	if(me->mytype != MODIFY) {
		me->nb_objects = 0;
		me->offset = 0.;
		(void)GetDefName("SMSfBnd_0",me->def_name);
		me->rev = 0;
		me->ordered = 0;
		me->track_elt.located_obj.objid = NULL_OBJID;
		me->Track = 0;
		
	}
	else {
		me->nb_objects = me->old_nb_objects;
		me->macro_id = me->old_macro_id;
		me->offset = me->old_offset;
		me->ordered = me->old_ordered ;
		me->Track = me->old_track;
		me->track_elt = me->oldtrack_elt;
		me->rev = me->old_rev;
		strcpy(me->def_name, me->old_def_name);
	}
	
 	FIg_set_text(me->forms[0].form_ptr,NAME,me->def_name);
	if(me->ordered == 0)
		FIg_set_state_off(me->forms[0].form_ptr,ORDERED);
	else
		FIg_set_state_on(me->forms[0].form_ptr,ORDERED);
	if(me->Track == 0) 
		FIg_set_text(me->forms[0].form_ptr,TRACK_F,"No Track Element");
 	else {
 		vd$get_name(name = name, obj = &(me->track_elt.located_obj));
 		if(name[0] == '\0') {
        		/* try get name on the graphic object */
        		stat = om$send( msg = message ASnode.ASreturn_go(
                                    &go,
                                    NULL,
                                    NULL),
                        	senderid = NULL_OBJID,
                        	targetid = me->track_elt.located_obj.objid,
                        	targetos = me->track_elt.located_obj.osnum );
        		if(!(stat&1)) go =  me->track_elt.located_obj;
        		vd$get_name(name = name, obj = &go);
			if(name[0] == '\0') strcpy(name, "defined");
		}
 		FIg_set_text(me->forms[0].form_ptr, TRACK_F,name);
	}
 	if(me->rev == 0)
 		FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 	else 
 		FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
 	FIfld_set_value(me->forms[0].form_ptr, OFFSET, 0, 0, 
 				me->offset, FALSE);
	for(i=0;i<MAX_SURF;i++) {
		if(me->mytype == MODIFY) me->infinite[i] = me->old_infinite[i];
		else me->infinite[i] = 'Y';	
		if(me->mytype == MODIFY) me->objects[i] = me->old_objects[i];
		else me->objects[i].located_obj.objid = NULL_OBJID;
	} 
 	if(me->forms[0].form_ptr == NULL){
        	*sts = OM_E_ABORT;
        	return OM_S_SUCCESS;
 	}
 	FImcf_get_attr(me->forms[0].form_ptr,INFINITE, &attr);
 	attr = attr | FI_ROW_SELECT;
 	FImcf_set_attr(me->forms[0].form_ptr,INFINITE, attr);

 	

 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
 	}
 	if(num_rows){
 		stat = FIfld_delete_rows(me->forms[0].form_ptr,INFINITE, 
 						0,num_rows);
		if(stat != FI_SUCCESS){
			printf("error FIfld_delete_rows: %d\n",stat);
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
 	}
 	stat = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMSfBnd",
                            p_macro_defn_id     = &mac );

	as$status(sts = stat);
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
 
 	k=0; 
 	for(i=1;i<Nb_Max_Temp;i=i+1){
		SMspace_getTempDefString( &msg, me->dup[i].type, text );

		FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 0, 
					me->dup[i].prompt, FALSE);
		
		if(me->mytype == MODIFY && k< me->nb_objects){
			if (k != me->IndexFcObj){
 				vd$get_name(name = name, obj = &(me->objects[k].located_obj));
				if(name[0] == '\0') {
        				/* try get name on the graphic object */
        				stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
                                          NULL,
                                          NULL),
                        			senderid = NULL_OBJID,
                        			targetid = me->objects[k].located_obj.objid,
                        			targetos = me->objects[k].located_obj.osnum );
        				if(!(stat&1)) go =  me->objects[k].located_obj;
        				vd$get_name(name = name, obj = &go);
  					if(name[0] == '\0') strcpy(name, "defined");
				}
			}
  			if(name[0] == '\0') strcpy(name, "defined");
 			FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1,
  				 name, FALSE);
		}
		else FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1, 
					text, FALSE);
		if(me->infinite[k] == 'n' ||  me->infinite[k] == 'N')
			FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"N", FALSE);
		else FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"Y", FALSE);
		k++;
 	}
 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
 	}
  	for(i=0;i<num_rows;i++){
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 0, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 1, FALSE);
  	}

  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
  	FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,me->select_row, 
  				me->pos);
  				
  	/* hilite objects */
  	
	if(me->mytype == MODIFY){
        	stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
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

method form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			def_properties, Nb_Max_Temp, state,
 			status = OM_S_SUCCESS;
 int  			sel_flag, r_pos, num_rows, stat;
 int  			pos, col, row, num_char = MAX_CHAR;
 long			test, msg;
 char 			text[MAX_CHAR];
 struct GRid		mac;
 enum GRdpmode		mode;
 struct GRid     	currentModule ;
 struct GRlc_info	obj;

        
	if ( form_ptr == NULL ){
     		/*| no form_ptr set */
     		return( OM_E_INVARG ); 
	}
  
  	FIg_set_text(form_ptr,MESSAGE_FIELD,"");
  
  	switch( gadget_label ){
   
  		case SAVE:
   		case STORE:
     		status = om$send(msg = message SMCmdSfBnd.save_all(&test),
		      targetid = my_id);
     		if(!(status & test & 1)){
			FIg_set_state_off(form_ptr,gadget_label);
			goto quit;
      		}   
     		if(gadget_label == SAVE) _put_response(resp = TERMINATE);
		_put_response(resp = RESTART);	 
			 
     		break;
      
   		case EXIT: 
     		_put_response(resp = TERMINATE);
     		break;
     
   		case ABORT:
     		status = om$send(msg = message SMCmdSfBnd.reinit_form(&test),
			 targetid = my_id);
		_put_response(resp = LOAD_FORM);
     		break;
   
   		case LOAD:
		if(me->mytype == MODIFY){
			UI_prompt("");
                	stat = om$send(msg = message SMCmdSfBnd.delete_elt(&test),
                                targetid = my_id);

        		if(!(stat & test & 1)){ 
				ex$message(msgnumb = SM_S_ErrDel);
 				goto quit;
        		} 
                	_put_response(resp = DEL_ELT);
			break;
		}
     		else _put_response(resp = LOAD_OCC);

    		break;
    
   		case NAME:
   		FIfld_get_text(form_ptr,NAME,0, 0,
                       		num_char, text,&sel_flag,&r_pos);
 		(void)GetDefName(text,me->def_name);
 		FIg_set_text(form_ptr,NAME,me->def_name);
   		
    		break;
        
   		case TRACK_B:
			mode = GRhe;
			if(me->track_elt.located_obj.objid != NULL_OBJID){
 				ex$get_cur_mod( id      = &currentModule.objid,
                 		osnum   = &currentModule.osnum ) ;
		
				stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        			senderid = NULL_OBJID,
                        			targetid = me->track_elt.located_obj.objid,
                        			targetos = me->track_elt.located_obj.osnum );

 				stat = om$send(msg     = message GRgraphics.GRdisplay(
                  				&msg,
                                		&obj.module_info.md_env.matrix_type,
                                		obj.module_info.md_env.matrix,
                                		&mode,
                                		&currentModule ),
                        			senderid = NULL_OBJID,
         					targetid= obj.located_obj.objid,
         					targetos= obj.located_obj.osnum ) ;

     				if (!(stat & 1))
					ex$message(msgnumb = SM_S_ErrDsp);
                	}
			if(me->Track == 0)   {
				_put_response(resp = LOAD_TRACK);
				break;
			}
			else {
				me->Track = 0;
 				me->track_elt.located_obj.objid = NULL_OBJID;

				FIfld_set_text(form_ptr,TRACK_F,0,0,
                       			"No track Element",FALSE);
				_put_response(resp = LOAD_FORM);
                       	}
   		
    		break;

    		
		case ORDERED:
 		status = ac$find_macro_defn( action      = ACfind_load,
                            macro_name  = "SMSfBnd",
                            p_macro_defn_id     = &mac );

 		as$status();
 		if (!(status & 1) || IF_NULL_OBJID(mac.objid)){
			printf("error macro not found\n");
			goto quit;
 		}
 		Nb_Max_Temp = 0;
 		status = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&def_properties,&me->dup),
                           targetid = mac.objid,
                           targetos = mac.osnum );

 		as$status();
 		if(!(status & 1)){
			printf("error  ACmacro_defn.ACgive_upscan\n");
			goto quit;
 		}
 		
		FIg_get_state(form_ptr,ORDERED, &state);
		if(state == 1) me->ordered = 1;
		else me->ordered = 0;

		break;	        

   		case INFINITE:
      
      		if(me->delete_elt ){

			/* get the row to be deleted */

     			FImcf_get_active_col(  form_ptr,INFINITE, &col, &pos); 
     			FIfld_get_active_row(form_ptr,INFINITE, &row, &pos);
     			FIfld_get_select(form_ptr,INFINITE,row, 0,&sel_flag);
			me->delete_row = (sel_flag == TRUE) ? row : -1;
     			if(sel_flag == TRUE){
				me->select_row = row;
        			stat = om$send(msg = message SMCmdSfBnd.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(stat & test & 1)){ 
					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			} 
				me->select_row = 0;
			}
     			if(row == 0 && sel_flag == TRUE){
     				/* support cannot be disconnected */
     				
     				FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
                                        "The Support cannot be disconnected");
                                FIfld_set_select(me->forms[0].form_ptr, INFINITE,
                                                row, 0, FALSE);
                                FIfld_set_select(me->forms[0].form_ptr, INFINITE,
                                                row, 1, FALSE);
                                FIfld_set_select(me->forms[0].form_ptr, INFINITE,
                                                row, 2, FALSE);
				me->delete_row = -1;
                                break;
                        }

     			if(sel_flag == TRUE){
 				FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
					"Valid with disconnect button");
				break;
				
     			}
 			FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
				"Select the Elt to be disconnected");
			break;
		}
     		status = FIfld_get_num_rows(form_ptr,INFINITE, &num_rows);
     		if(status != FI_SUCCESS) {
			printf("error FIfld_get_num_rows\n");
			goto quit;
     		}
     		FImcf_get_active_col(  form_ptr,INFINITE, &col, &pos); 
     		FIfld_get_active_row(form_ptr,INFINITE, &row, &pos);
     
     		if(col == 0 || col == 1){
        		me->select_row = row;
			me->pos = pos;
     			FIfld_get_select(form_ptr,INFINITE,me->select_row, 
     						0,&sel_flag);
#ifdef vdsDEBUG
	printf("\t col: %d, row: %d, sel_flag: %d\n", col,row,sel_flag);
#endif
     			if(sel_flag == TRUE){
        			status = om$send(msg = message SMCmdSfBnd.DispAll
        						(&test),
 		      			targetid = my_id);
        			if(!(status & test & 1)){ 
					ex$message(msgnumb = SM_S_ErrDsp);
 					goto quit;
        			} 
        			break;
     			}
     		}
     		else{
     	  	
     			FIfld_get_text(form_ptr,INFINITE,row, 2,
                       		num_char, text,&sel_flag,&r_pos);

     			if(text[0] == 'n' || text[0] == 'N')     
     				FIfld_set_text(form_ptr,INFINITE,row, 2,
                       			"N",FALSE);
     			else                     
     				FIfld_set_text(form_ptr,INFINITE,row, 2,
                      				 "Y",FALSE);
			FIfld_erase_cursor(form_ptr,INFINITE);
                       
     		}
     		break;
     

} /* END switch ( gadget_label ) */
  
  
 quit:
  return OM_S_SUCCESS;
}



/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

method reset_all( long *sts )
{
  int 	i, num_rows, stat;
  long	msg;
  
 	
  	*sts = OM_S_SUCCESS;
  	dp$erase_hilite(msg = &msg);


  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 	FIg_set_text(me->forms[0].form_ptr,NAME,"");
 	FIg_set_text(me->forms[0].form_ptr,OFFSET,"");
        FIg_set_text(me->forms[0].form_ptr,TRACK_F,"");

	me->select_row = 0;
	me->pos = 0;
	me->dup = NULL;
	me->nb_objects = 0;
	me->offset = 0.;
	me->ordered =0;
        me->def_name[0] = '\0';
  	me->delete_elt = 0;
  	me->delete_row = 0;

	me->Fence = FALSE;
	me->FenceObjects = NULL;
	me->nb_FenceObjects = 0;
	me->IndexFcObj = -1;
	me->macro_id.objid = NULL_OBJID;
	me->Track = 0;
	me->track_elt.located_obj.objid = NULL_OBJID;
	me->rev = 0;

	for(i=0;i<MAX_SURF;i++) {
		me->infinite[i] = 'Y';	
		me->objects[i].located_obj.objid = NULL_OBJID;
	}

 	stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
 	if(stat != FI_SUCCESS) {
		printf("error FIfld_get_num_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
 	}
 	if(num_rows){
 		stat = FIfld_delete_rows(me->forms[0].form_ptr,INFINITE, 
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
  int 			i, fc, nb_obj, num_char = MAX_CHAR, sel_flag, 
  			r_pos, stat, nb_fail, state;
  char 			text[MAX_CHAR];
  long			msg, test;
  struct GRid 		mac, *obj;
  unsigned int		inf_mask;
  IGRdouble		offset;


  SetProc( save_all ); Begin  

  	*sts = OM_S_SUCCESS;
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->act_env.md_id.osnum;
  	
  	obj = NULL;
	__DBGpr_int("me->nb_objects", me->nb_objects);

	if(me->nb_objects < 2){
		ex$message(msgnumb = SM_S_NotObjLoc);
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"ERROR, No objects located");
		*sts =  OM_E_ABORT; 
		goto quit;
	} 
  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 
	/* verif macro name */
			
   	FIfld_get_text(me->forms[0].form_ptr,NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
	if(text[0] == '\0'){
		if(me->mytype == MODIFY) {
			me->def_name[0] = '\0';
			mac = me->macro_id;
		}
		else{
			ex$message(msgnumb = SM_S_ErNoMacNm);
  			FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
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
  			FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
				"ERROR, Invalid macro name");
			*sts =  OM_E_ABORT; 
			goto quit;
		}			
	}
  

 
  	/* store value in instances */
  	
  	for(i=0;i<me->nb_objects;i++){
     		FIfld_get_text(me->forms[0].form_ptr,INFINITE,i, 2,
                       num_char, text,&sel_flag,&r_pos);
     		if(text[0] == 'N' || text[0] == 'n') me->infinite[i] = 'N';
     		else  me->infinite[i] = 'Y';
  	}
  	FIfld_get_value(me->forms[0].form_ptr, OFFSET, 0, 0, &me->offset, 
  			&sel_flag, &r_pos);

	SMConvDistExtInt(me->offset, &offset, me->act_env.md_id.osnum);

  	FIg_get_state(me->forms[0].form_ptr,ORDERED,&state);
  	if(state ) me->ordered = 1;
  	else me->ordered = 0;


	if(me->Track &&  me->track_elt.located_obj.objid == NULL_OBJID){
		ex$message(msgnumb = SM_S_TrkNoDef);
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  				"Track elt not defined");
		*sts =  OM_E_ABORT; 
		goto quit;
  	}
		

  	FIg_get_state(me->forms[0].form_ptr,ORIENT,&state);
  	if(state ) me->rev = 1;
  	else me->rev = 0;
  	
	if(me->Fence == TRUE) nb_obj = me->nb_FenceObjects ;
	else nb_obj = 1;
	nb_fail = 0;
	__DBGpr_int("nb_obj", nb_obj);
	for(fc = 0; fc < nb_obj; fc++){
		 
  		/* place the macro */

  		if(me->mytype == PLACE){ 
  			mac.objid = NULL_OBJID;
  			mac.osnum = me->act_env.md_id.osnum;
 
  			stat = om$construct(classid = OPP_SMSfBnd_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
                        as$status(sts = stat);
  			if(!(stat & 1)){
     				printf("erreur creating macro\n"); 
				*sts =  OM_E_ABORT; 
				goto quit;
  			}
		}
	
  		obj = _MALLOC(me->nb_objects, struct GRid);
  		if(obj == NULL){
			printf("ERROR Bad allocation\n");
			*sts =  OM_E_ABORT; 
			goto quit;
  		}
		__DBGpr_int("me->IndexFcObj", me->IndexFcObj);
  		for(i=0;i<me->nb_objects;i++) {
  			if(i == me->IndexFcObj) {
     				stat = as$make_source(
     					go_grid = me->FenceObjects[fc].obj_id,
			     		mod_env = &me->FenceObjects[fc].mod_env,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &obj[i]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
		__DBGpr_obj ("as$make_source, go_grid", me->FenceObjects[fc].obj_id);
		__DBGpr_obj ("as$make_source, as_grid", obj[i]);
          		}
  			else {
     				stat = as$make_source(
     					go_grid = me->objects[i].located_obj,
			     		mod_env = &me->objects[i].module_info,
			     		as_os   = me->act_env.md_id.osnum,
			     		as_grid = &obj[i]);
     				as$status(sts = stat);
        			if(!(stat & 1))
          			{ 
 					printf("ERROR as$make_source\n");
 					*sts = OM_E_ABORT;
 					goto quit;
          			} 
		__DBGpr_obj ("as$make_source, go_grid", me->objects[i].located_obj);
		__DBGpr_obj ("as$make_source, as_grid", obj[i]);
          		}
  		} /* for me->nb_objects */

		if( Reconnect ){
		__DBGpr_com("Reconnect all");
		stat = om$send( msg = message NDnode.NDconnect(
				me->nb_objects,obj,NULL_GRID,ND_ADD ),
                   	targetid = me->macro_id.objid,
                   	targetos = me->macro_id.osnum );
		Reconnect=FALSE;
		__DBGpr_int("NDnode.NDconnect stat", stat);
		if (!(stat & 1)) goto quit;
		}

  		SMGetMaskFrmInf(me->nb_objects, me->infinite, &inf_mask);  
  		if(me->mytype == PLACE){ 
  			stat = om$send(msg = message  SMSfBnd.SMcreate(&msg, 
                      		me->def_name, offset,me->ordered, 
                      		me->rev, &me->track_elt.located_obj,
                      		me->nb_objects, obj,inf_mask),
                      	senderid = NULL_OBJID,
                      	targetid = mac.objid,
                      	targetos = mac.osnum);
  			if(!(stat & msg & 1)){
				ex$message(msgnumb = SM_E_ErCrMac);
  				nb_fail ++;
  				_FREE(obj);
				continue;
  			}
   			FIfld_get_text(me->forms[0].form_ptr,NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
 			(void)GetDefName(text,me->def_name);
 			FIg_set_text(me->forms[0].form_ptr,NAME,me->def_name);
  		}
  		else{
		__DBGpr_int("Calling SMModify, me->nb_objects", me->nb_objects);
  			stat = om$send(msg = message  SMSfBnd.SMModify(&msg, 
                      			me->def_name, offset, me->ordered,
                      			me->rev, &me->track_elt.located_obj,
                      			me->nb_objects, obj,
                      			inf_mask),
                      		senderid = NULL_OBJID,
                      		targetid = me->macro_id.objid,
                      		targetos = me->macro_id.osnum);
  			if(!(stat & msg & 1)){
				ex$message(msgnumb = SM_E_ErMdMac);
  				nb_fail ++;
  				_FREE(obj);
				continue;
  			}
		__DBGpr_com("Returning from SMModify");
  		}
  		_FREE(obj);
  	}


 if(nb_fail == nb_obj) {*sts = OM_E_ABORT; goto quit;}
 
 if(me->mytype == MODIFY){    
	/* Nothing to inform */
 }
 else 	{
 	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Place Successfull");
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
  	if(me->mytype == MODIFY){ 
		me->old_macro_id = me->macro_id;
		me->old_ordered = me->ordered;
		me->old_rev = me->rev;
		me->old_track = me->Track;
		me->oldtrack_elt = me->track_elt;
		me->old_offset = me->offset;
		me->old_nb_objects = me->nb_objects;
 		strcpy(me->old_def_name,me->def_name);
		for(i=0;i< me->old_nb_objects; i++){
 			me->old_objects[i] = me->objects[i];
 			me->old_infinite[i] = me->infinite[i];
		}
		for(i=me->old_nb_objects;i<MAX_SURF;i++) {
			me->old_infinite[i] = 'Y';	
			me->old_objects[i].located_obj.objid = NULL_OBJID;
		}
		
  	}
  	else {
  		me->select_row = 0;
  		me->pos = 0;
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
  		FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,
   					me->select_row, me->pos);
  		stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
 		      			targetid = my_id);
  		if(!(stat & test & 1)){ 
 			ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
  		} 
   		FIfld_get_text(me->forms[0].form_ptr,NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
  		(void)GetDefName(text,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,NAME,me->def_name);
  	}
  }

  _FREE(obj);
  End
  return OM_S_SUCCESS;
}



/* ----------------------------------------------------------------- */ 
/*
/* delete an element (Modify)
/* 
/**/
 
method delete_elt(long *sts )
{
 int		i, k, stat, Nb_Max_Temp ,num_rows;
 int		def_properties;
 struct GRid	go, mac;
 long		test,msg;
 char		*c, name[MAX_CHAR],text[MAX_CHAR];

 SetProc( delete_elt ); Begin  

 *sts = OM_S_SUCCESS;
 
 stat = FIfld_get_num_rows(me->forms[0].form_ptr,INFINITE, &num_rows);
 if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
 }
 if(me->delete_elt ){

	if(me->delete_row != -1){
  	
  		/* delete the element and redisplay the form */

     		stat = om$send(msg = message SMCmdSfBnd.DispLoc(
     						me->delete_row, GRhe),
                        		targetid= my_id ) ;

     		if (!(stat & 1)){
                	ex$message(msgnumb = SM_S_ErrDsp);
 			*sts = OM_E_ABORT;
                	return  OM_S_SUCCESS;
        	}

		for(i=0;i<me->nb_objects -1;i++){
			if(i < me->delete_row) k = i;
			else k = i+1;

			me->infinite[i] = me->infinite[k];
			me->objects[i] = me->objects[k];
		}	
		me->objects[me->nb_objects -1].located_obj.objid = NULL_OBJID;
		me->nb_objects --;
	
 		if(num_rows){
 			stat = FIfld_delete_rows(me->forms[0].form_ptr,INFINITE, 
 						0,num_rows);
			if(stat != FI_SUCCESS){
				printf("error FIfld_delete_rows: %d\n",stat);
				*sts = OM_E_ABORT;
				return OM_S_SUCCESS;
			}
 		}
 		stat = ac$find_macro_defn( action      = ACfind_load,
                            		macro_name  = "SMSfBnd",
                            		p_macro_defn_id     = &mac );
		as$status(sts = stat);
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
 
 		k=0; 
 		for(i=1;i<Nb_Max_Temp;i=i+1){
		        SMspace_getTempDefString( &msg, me->dup[i].type, text );

			FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 0, 
					me->dup[i].prompt, FALSE);
			if(me->mytype == MODIFY && k < me->nb_objects){
				if (k != me->IndexFcObj){ 
 					vd$get_name(name = name, obj = &(me->objects[k].located_obj));
					if(name[0] == '\0') {
        					/* try get name on the graphic object */
        					stat = om$send( msg = message ASnode.ASreturn_go(
                                          		&go,
                                          		NULL,
                                          		NULL),
                        				senderid = NULL_OBJID,
                        				targetid = me->objects[k].located_obj.objid,
                        				targetos = me->objects[k].located_obj.osnum );
        					if(!(stat&1)) go =  me->objects[k].located_obj;
        					vd$get_name(name = name, obj = &go);
  						if(name[0] == '\0') strcpy(name, "defined");
					}
				}
  				if(name[0] == '\0') strcpy(name, "defined");
 				FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1,
  				 name, FALSE);
			}
			else
				FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 1, 
					text, FALSE);
			if(me->infinite[k] == 'n' ||  me->infinite[k] == 'N')
				FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"N", FALSE);
			else FIfld_set_text(me->forms[0].form_ptr, INFINITE, k, 2, 
					"Y", FALSE);
			k++;
 		}
 	}
  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 0, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 1, TRUE);
  	FIfld_set_select(me->forms[0].form_ptr, INFINITE,0, 2, TRUE);
  	me->select_row = 0;
  	me->pos = 0;
  	FIfld_set_active_row(me->forms[0].form_ptr, INFINITE,
   					me->select_row, me->pos);
  	stat = om$send(msg = message SMCmdSfBnd.DispAll(&test),
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
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 0, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 1, FALSE);
  		FIfld_set_select(me->forms[0].form_ptr, INFINITE,i, 2, FALSE);
	} 	
 	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
 			"Select the Elt to be disconnected");
  	me->delete_elt = 1;
  }
  End
  return OM_S_SUCCESS;
}

end implementation SMCmdSfBnd;


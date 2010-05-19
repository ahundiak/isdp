/* $Id: SMPerpNtf.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/cmd / SMPerpNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMPerpNtf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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

 /*               SMCmdPerpNtf.I                    */
 /*   Methods  and functions for SMCsPp        */ 
 /*   Methods for the CO                           */
 /*   Pascale Lacroix  (ISDC)			   */
 /*   Creation date July-92                        */
  
 class implementation SMCmdPerp;
  
 
#include <string.h> 
#include <math.h> 
#include "expression.h"
#include "expmacros.h"
#include "acmacros.h"
#include "AS_status.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "madef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "FI.h"
#include "expmacros.h"

#include "ACrg_collect.h"
#include "ACattrib.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "vdsmacros.h"

#include "SMCsPp.h"
 
 
#define PLACE    	0
#define MODIFY		1
 
#define AS_DEBUG	1

#define LOAD_OCC 	511
#define LOAD_CS	513
#define RESTART 	515

 
 
 extern GRclassid 	OPP_SMCsPp_class_id,OPP_SMcoll_class_id,
 			OPP_SMSurf_class_id;
 
 from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute,
 				ACset_list_attribute;
 from GRgraphics	import GRdelete, GRdisplay;
 from NDnode		import NDconnect, NDdisconnect, NDchange_connect,
			       NDchg_state, NDget_objects;
 from NDmacro		import ACreturn_foot;
 from ASnode		import ASreturn_go;
 from GRvg		import GRputsymb, GRputname, GRchgname, GRgetname;
 from ACncpx		import ACmplace;
 from SMCsPp		import SMGetParameters, SMcreate, SMModify;
 from SMmgr		import SMGetAttDbl;


/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance (management of fence)
/*
/**/
 
method store_cs(long *sts)
{
 char		name[MAX_CHAR];
 int		status;
 
 *sts = OM_S_SUCCESS;

 if(me->coord.objid != NULL_OBJID){
 	om$send(msg = message  SMCmdPerp.DispAll(GRhe),
                      targetid = my_id);
 }
 me->coord = me->event1.located_object[0].located_obj;

/* Retrieve the name of the coordinate system */

 status = as$make_source(go_grid = me->coord,
                          mod_env = &me->event1.located_object[0].module_info,
                          as_os   = me->act_env.md_id.osnum,
                          as_grid = &me->coord);
 as$status(action = RET_STATUS);
 me->cs_env = me->event1.located_object[0].module_info;
 name[0] = '\0';
 vd$get_name(name = name, obj = &(me->coord) );
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name,
		    obj = &(me->event1.located_object[0].located_obj ) );
  	if(name[0] == '\0') strcpy(name, "defined");
 }

  
 FIg_set_text(me->forms[0].form_ptr,CS_NAME,name);

 return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */
/*
/*  get the LPP from the global data
/**/

method GetLPP(long *sts)
{
IGRshort 	matrix_type;
IGRint		status;
IGRlong		msg;
IGRmatrix	matrix;
struct GRid	rg, exp;
struct GRmd_env	exp_env;

 *sts = OM_S_SUCCESS;

 /* Getting active global data */

 if(!SMGetActShipAtt(&me->global.obj_id,NULL,&me->global.mod_env)){
 	FIg_set_text(me->forms[0].form_ptr, MESSAGE_FIELD,
 		"ERROR, global data not defined");
	return OM_E_ABORT;
 }
 status =
   om$send(msg = message SMmgr.SMGetAttDbl(&msg,"LPP",&me->Lpp,0),
           targetid = me->global.obj_id.objid,
           targetos = me->global.obj_id.osnum);

 if (!(status & msg & 1)) {
 	FIg_set_text(me->forms[0].form_ptr, MESSAGE_FIELD,
 		"ERROR retrieving LPP");
	return OM_E_ABORT;
  }

 /* retrieve first the rg_coll */
 
 status = om$send( msg = message NDmacro.ACreturn_foot
		   (&msg , "parameter",&rg, 
		    &matrix_type, 
		     matrix ),
		   targetid = me->global.obj_id.objid,
		   targetos = me->global.obj_id.osnum);
 if(!(status & msg & 1)){
  	printf("Erreur retrieving foot of the global data\n"); 
	return OM_E_ABORT;
 }

 /* retrieve then the expression of LPP */

 status = om$send( msg = message NDmacro.ACreturn_foot
		   (&msg , "LPP",&exp, 
		    &matrix_type, 
		     matrix ),
		   targetid = rg.objid,
		   targetos = rg.osnum);
 if(!(status & msg & 1)){
  	printf("Erreur retrieving foot of the global data\n"); 
	return OM_E_ABORT;
 }
 status = GetEnvFrObj( &exp, &exp_env, NULL);
 if(!(status & 1)){
  		printf("ERROR GetEnvFrObj \n");         
		return OM_E_ABORT;
 }

 me->global.obj_id = exp;
 me->global.mod_env = exp_env;

   
return OM_S_SUCCESS;  
}

/* ----------------------------------------------------------------- */
/*
/* hilite the located objects 
/*
/**/


method DispAll(enum GRdpmode mode)
{
int                     stat;
long			msg;
struct GRid             currentModule ;
struct GRlc_info        obj;


ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

if(me->coord.objid != NULL_OBJID){
        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->coord.objid,
                        targetos = me->coord.osnum );

	/* Jean 5/7/93 Not found : one sourcein not connected */
	if(stat & 1) { 
        	stat = om$send(msg     = message GRgraphics.GRdisplay(
                                &msg,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
                targetid= obj.located_obj.objid,
                targetos= obj.located_obj.osnum ) ;
		as$status(sts = stat);
	}
}

return OM_S_SUCCESS;

}
/* ----------------------------------------------------------------- */
/*
/* verify about the deleted object
/*
/**/


method verify_obj(long *sts)
{

 *sts = OM_S_SUCCESS;

 if(me->coord.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->coord.osnum,
                               objid = me->coord.objid)&1) ){
        ex$message(msgnumb = SM_S_ErCsDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
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
 int			nb_att, count, stat;
 char			name[MAX_CHAR];
 long			msg;
 struct GRid		*roots, go;
 struct ACrg_coll	ACrg[SM_PERP_MAX_ATTR];


 *sts = OM_S_SUCCESS;
 roots = NULL;

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 dp$erase_hilite(msg = &msg);
 	
 me->macro_id = me->event1.located_object[0].located_obj;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&roots,0,OM_K_MAXINT,&count),
                   senderid = NULL_OBJID,
                   targetid = me->macro_id.objid,
                   targetos = me->macro_id.osnum );
        
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || count > 4){
 		printf("ERROR retrieve roots of the macro \n");         
 		*sts = OM_E_ABORT;
		goto wrapup;
 }

 if(count > 0)  /* Common case : macro is OK */
  {
 	stat = om$send(msg = message SMCsPp.SMGetParameters(
                   &msg, &me->coord, &me->aft_id.obj_id, &me->fore_id.obj_id, 
                   &nb_att, ACrg, me->def_name),
                   senderid = NULL_OBJID,
                   targetid = me->macro_id.objid,
                   targetos = me->macro_id.osnum );
 	as$status(sts = stat);
 	if(stat != OM_S_SUCCESS ){
 		printf("ERROR retrieving parameters of the perpendicular \n");
 		*sts = OM_E_ABORT;
		goto wrapup;
 	}

 	stat = GetEnvFrObj( &me->aft_id.obj_id, &me->aft_id.mod_env, NULL);
    	/* Jean: if error macro has probably lost one parent */
    	if(!(stat & 1)){ me->aft_id.obj_id.objid = NULL_OBJID; ex$message(msgnumb = SM_I_LostPar);}

 	stat = GetEnvFrObj( &me->fore_id.obj_id, &me->fore_id.mod_env, NULL);
    	/* Jean: if error macro has probably lost one parent */
    	if(!(stat & 1)){me->fore_id.obj_id.objid = NULL_OBJID; ex$message(msgnumb = SM_I_LostPar);}

 	stat = SMGetExpDist(&me->aft_id.obj_id, &me->fore_id.obj_id, &me->aftdist, 
			&me->foredist, me->aftexp, me->forexp);
    	/* Jean: if error macro has probably lost one parent */
    	if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}

 	stat = SMGetRgAtt(ACrg, nb_att, &me->is_analysis, &me->is_middle, &me->is_drawing,
		   me->aftname, me->midname, me->forename, me->drwname, 
		   me->axis);
 	if(!(stat & 1)){        
 		printf("ERROR SMGetRgAtt\n");         
  		*sts = OM_E_ABORT;
 		goto wrapup;
 	}
 
 	/* Get the coord syst env*/
 
 	stat = GetEnvFrObj( &me->coord, &me->cs_env, NULL);
    	/* Jean: if error macro has probably lost one parent */
    	if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}

 	SMConvDistIntExt(me->foredist, &me->foredist, me->act_env.md_id.osnum);
 	SMConvDistIntExt(me->aftdist, &me->aftdist, me->act_env.md_id.osnum);
}
 else     /* Jean : 5/4/93  Macro is broken : user  will relocate parents*/
  {
    ex$message(msgnumb =  SM_I_NoParMac);

     /* Recreate an expression with default parameter */
    me->foredist = 0.0;
    me->aftdist = 0.0;
    
  }

 vd$get_name( name = me->def_name, obj= &(me->macro_id) );

 if(me->mytype == MODIFY) {
 		me->old_macro_id = me->macro_id;
 		me->oldaft_id = me->aft_id;
 		me->oldfore_id = me->fore_id;
 		strcpy(me->old_def_name,me->def_name);
 		me->old_coord = me->coord;
 		me->old_global = me->global;
 		strcpy(me->old_axis, me->axis);
 		me->old_aftdist = me->aftdist;
 		me->old_foredist = me->foredist;
 		me->old_analysis = me->is_analysis;
 		me->old_middle = me->is_middle;
 		me->old_drawing = me->is_drawing;
		strcpy(me->old_aftexp, me->aftexp);
		strcpy(me->old_forexp, me->forexp);
 		strcpy(me->old_aftname,me->aftname);
 		strcpy(me->old_forename,me->forename);
 		strcpy(me->old_midname,me->midname);
 		strcpy(me->old_drwname,me->drwname);

 		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 }
 else {
 	(void)GetDefName("Perp_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }

 vd$get_name( name = name, obj = &(me->coord ) );
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
					  NULL,
                                          NULL),
                        senderid = NULL_OBJID,
                        targetid = me->coord.objid,
                        targetos = me->coord.osnum );
        if(!(stat&1)) {
		strcpy(name,"missing");/* Jean : pretend not connected */
		go =  me->coord;
	}
  	else vd$get_name(name = name, obj = &go );
 	if(name[0] == '\0') strcpy(name, "defined");  
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 
 di$split(pathname = me->aftexp, name = name);
 FIg_set_text(me->forms[0].form_ptr, AFTEXP, name);

 di$split(pathname = me->forexp, name = name);
 FIg_set_text(me->forms[0].form_ptr, FOREXP, name);

 FIfld_set_value(me->forms[0].form_ptr,AFTDIST,0,0,me->aftdist,FALSE);
 FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,me->foredist,FALSE);

 if(me->is_analysis) FIg_set_state_on(me->forms[0].form_ptr,ANALYSIS);
 else FIg_set_state_off(me->forms[0].form_ptr,ANALYSIS);
 
 if(me->is_middle) {
 	FIg_set_state_on(me->forms[0].form_ptr, MIDDLE);
 	FIg_display(me->forms[0].form_ptr,MIDNAME);
 	FIg_display(me->forms[0].form_ptr,MIDPP);
 	FIg_set_text(me->forms[0].form_ptr, MIDNAME,me->midname);
 }
 else {
 	FIg_set_state_off(me->forms[0].form_ptr, MIDDLE);
 	FIg_erase(me->forms[0].form_ptr,MIDNAME);
 	FIg_erase(me->forms[0].form_ptr,MIDPP);
 }

 if(me->is_drawing) {
 	FIg_set_state_on(me->forms[0].form_ptr, DRAWING);
 	FIg_display(me->forms[0].form_ptr,DRWNAME);
 	FIg_display(me->forms[0].form_ptr,DRWMAC);
 	FIg_set_text(me->forms[0].form_ptr, DRWNAME,me->drwname);
 }
 else {
 	FIg_set_state_off(me->forms[0].form_ptr, DRAWING);
 	FIg_erase(me->forms[0].form_ptr,DRWNAME);
 	FIg_erase(me->forms[0].form_ptr,DRWMAC);
 }

 FIg_set_text(me->forms[0].form_ptr, AFTNAME,me->aftname);
 FIg_set_text(me->forms[0].form_ptr, FORENAME,me->forename);
 if(me->is_middle) FIg_set_text(me->forms[0].form_ptr, MIDNAME,me->midname);
 if(me->is_drawing) FIg_set_text(me->forms[0].form_ptr, DRWNAME,me->drwname);

 om$send(msg = message  SMCmdPerp.DispAll(GRhhd),
                      targetid = my_id);

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
 int		stat;
 char		name[MAX_CHAR];
 long		msg;
 struct GRid	go;
  
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");

 if(me->mytype != MODIFY) {
	/* get active ship cs */

 	if(SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,&go,
	       &me->coord,&me->cs_env,(IGRboolean *)NULL)
    		&& me->coord.objid != NULL_OBJID){
 		vd$get_name(name = name, obj = &(me->coord ));
 		if(name[0] == '\0') {
  			/* try get name on the graphic object */
  			vd$get_name(name = name, obj = &go );
 			if(name[0] == '\0') strcpy(name, "defined"); 
 			FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
		}	
	}
	me->global.obj_id.objid = NULL_OBJID;
 	strcpy(me->axis,"x");
 	me->Lpp = 0.;
 	me->aftdist = 0.;
 	me->foredist = 0.;
 	me->aftexp[0] ='\0';
 	me->forexp[0] ='\0';
 	me->is_analysis = 0;
 	me->is_middle = 0;
 	me->is_drawing = 0;
 	strcpy(me->aftname ,"Aft");
 	strcpy(me->forename,"Fore");
 	strcpy(me->midname,"Mid");
 	strcpy(me->drwname,"SMDrwPrp");
 	me->def_name[0] = '\0';
 	me->macro_id.objid = NULL_OBJID;
 	stat = om$send(msg = message SMCmdPerp.GetLPP(&msg),
		      			targetid = my_id);
	if(stat & 1){
		stat = EXP_rec_untranslate(me->global.obj_id.objid, 
			me->global.obj_id.osnum, me->forexp);

 		if( (stat != DIR_S_SUCCESS)&&(stat != DIR_W_NAME_NOT_FOUND))
		 { di$report_error(sts = stat) ; me->forexp[0] = '\0';}

 		me->foredist = me->Lpp;
 		SMConvDistIntExt(me->foredist, &me->foredist, 
					me->act_env.md_id.osnum);
 		FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,me->foredist,FALSE);
	}
	(void)GetDefName("Perp_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }
 else {

 	me->macro_id = me->old_macro_id ;
 	me->aft_id = me->oldaft_id ;
 	me->fore_id = me->oldfore_id ;
 	me->global = me->old_global ;
 	me->coord = me->old_coord ;
 	strcpy(me->axis,me->old_axis) ;
	strcpy(me->aftexp, me->old_aftexp);
	strcpy(me->forexp, me->old_forexp);
 	me->aftdist = me->old_aftdist;
 	me->foredist = me->old_foredist;
 	me->is_analysis = me->old_analysis;
 	me->is_middle = me->old_middle;
 	me->is_drawing = me->old_drawing;
	strcpy(me->aftname, me->old_aftname);
	strcpy(me->midname, me->old_midname);
	strcpy(me->forename, me->old_forename);
	strcpy(me->drwname, me->old_drwname);
	strcpy(me->def_name, me->old_def_name);
 	vd$get_name(name = name, obj = &(me->coord ) );
 	if(name[0] == '\0') {
  		/* try get name on the graphic object */
        	stat = om$send( msg = message ASnode.ASreturn_go(
                                          &go,
					  NULL,
                                          NULL),
                        senderid = NULL_OBJID,
                        targetid = me->coord.objid,
                        targetos = me->coord.osnum );
        	if(!(stat&1)) go =  me->coord;
  		vd$get_name(name = name, obj = &go );
 		if(name[0] == '\0') strcpy(name, "defined"); 
 	} 
	/* take the names of expression and the values because if units has
	   changed we must convert in external units, and if the expression
	   is created, we must take its name */

 	stat = SMGetExpDist(&me->aft_id.obj_id, &me->fore_id.obj_id, &me->aftdist, 
			&me->foredist, me->aftexp, me->forexp);
    	/* Jean: if error macro has probably lost one parent */
    	if(!(stat & 1)){ex$message(msgnumb = SM_I_LostPar);}

 	SMConvDistIntExt(me->foredist, &me->foredist, me->act_env.md_id.osnum);
 	SMConvDistIntExt(me->aftdist, &me->aftdist, me->act_env.md_id.osnum);

 	FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,me->foredist,FALSE);
 	FIfld_set_value(me->forms[0].form_ptr,AFTDIST,0,0,me->aftdist,FALSE);
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);

 di$split(pathname = me->aftexp, name = name);
 FIg_set_text(me->forms[0].form_ptr,AFTEXP,name);

 di$split(pathname = me->forexp, name = name);
 FIg_set_text(me->forms[0].form_ptr,FOREXP,name);


 if(me->is_analysis) FIg_set_state_on(me->forms[0].form_ptr,ANALYSIS);
 else FIg_set_state_off(me->forms[0].form_ptr,ANALYSIS);
 
 if(me->is_middle) {
 	FIg_set_state_on(me->forms[0].form_ptr, MIDDLE);
 	FIg_display(me->forms[0].form_ptr,MIDNAME);
 	FIg_display(me->forms[0].form_ptr,MIDPP);
 	FIg_set_text(me->forms[0].form_ptr, MIDNAME,me->midname);
 }
 else {
 	FIg_set_state_off(me->forms[0].form_ptr, MIDDLE);
 	FIg_erase(me->forms[0].form_ptr,MIDNAME);
 	FIg_erase(me->forms[0].form_ptr,MIDPP);
 }

 if(me->is_drawing) {
 	FIg_set_state_on(me->forms[0].form_ptr, DRAWING);
 	FIg_display(me->forms[0].form_ptr,DRWNAME);
 	FIg_display(me->forms[0].form_ptr,DRWMAC);
 	FIg_set_text(me->forms[0].form_ptr, DRWNAME,me->drwname);
 }
 else {
 	FIg_set_state_off(me->forms[0].form_ptr, DRAWING);
 	FIg_erase(me->forms[0].form_ptr,DRWNAME);
 	FIg_erase(me->forms[0].form_ptr,DRWMAC);
 }

 FIg_set_text(me->forms[0].form_ptr, AFTNAME,me->aftname);
 FIg_set_text(me->forms[0].form_ptr, FORENAME,me->forename);
 if(me->is_middle) FIg_set_text(me->forms[0].form_ptr, MIDNAME,me->midname);
 if(me->is_drawing) FIg_set_text(me->forms[0].form_ptr, DRWNAME,me->drwname);
		
 if(me->mytype == MODIFY) om$send(msg = message  SMCmdPerp.DispAll(GRhhd),
                      			targetid = my_id);
  				
return OM_S_SUCCESS;

}



/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

method clear_form( long *sts )
{
int 	stat;
long	msg;
char	name[MAX_CHAR];  
 	
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);


 strcpy(me->axis,"x");
 me->aftdist = 0.;
 me->foredist = 0.;
 me->is_analysis = 0;
 me->is_middle = 0;
 me->is_drawing = 0;
 me->aftexp[0] ='\0';
 me->forexp[0] ='\0';
 me->aft_id.obj_id.objid = NULL_OBJID;
 me->fore_id.obj_id.objid = NULL_OBJID;
 strcpy(me->aftname ,"Aft");
 strcpy(me->forename,"Fore");
 strcpy(me->midname,"Mid");
 strcpy(me->drwname,"SMDrwPrp");
 me->def_name[0] = '\0';
 	
 stat = om$send(msg = message SMCmdPerp.GetLPP(&msg),
		      			targetid = my_id);
 if(stat & 1){
 	stat = EXP_rec_untranslate(me->global.obj_id.objid, 
			me->global.obj_id.osnum, me->forexp);
 	if( (stat != DIR_S_SUCCESS)&&(stat != DIR_W_NAME_NOT_FOUND))
		 { di$report_error(sts = stat) ; me->forexp[0] = '\0';}

 	me->foredist = me->Lpp;
 	SMConvDistIntExt(me->foredist, &me->foredist, 
					me->act_env.md_id.osnum);
 	FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,me->foredist,FALSE);
 }
 else  FIg_set_text(me->forms[0].form_ptr,FOREDIST,"");

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");

 FIg_set_text(me->forms[0].form_ptr,AFTDIST,"");

 di$split(pathname = me->forexp, name = name);
 FIg_set_text(me->forms[0].form_ptr,FOREXP,name);

 di$split(pathname = me->aftexp, name = name);
 FIg_set_text(me->forms[0].form_ptr,AFTEXP,name);
 
 FIg_set_text(me->forms[0].form_ptr,FORENAME,me->forename);
 FIg_set_text(me->forms[0].form_ptr,AFTNAME,me->aftname);

 
 if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);

 FIg_set_state_off(me->forms[0].form_ptr, MIDDLE);
 FIg_set_state_off(me->forms[0].form_ptr, ANALYSIS);
 FIg_set_state_off(me->forms[0].form_ptr, DRAWING);

 FIg_erase(me->forms[0].form_ptr,DRWNAME);
 FIg_erase(me->forms[0].form_ptr,DRWMAC);
 FIg_erase(me->forms[0].form_ptr,MIDNAME);
 FIg_erase(me->forms[0].form_ptr,MIDPP);

return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* Get the info from the form to place or modify the macro
/* 
/**/
 
method save_all(long *sts )
{
 int 			nb_att, num_char = MAX_CHAR, sel_flag, 
  			r_pos, stat, state;
 char 			text[MAX_CHAR];
 long			msg;
 struct GRid 		fore_grid, aft_grid, coord, mac;
 IGRdouble		foredist, aftdist;
 struct ACrg_coll	crit, ACrg[SM_PERP_MAX_ATTR];
 struct SMObjList  	list;
 
 *sts = OM_S_SUCCESS;
 msg = MSSUCC;
 list.list = NULL;
  	
 
 mac.objid = NULL_OBJID;
 mac.osnum = me->act_env.md_id.osnum;
  

 if(me->coord.objid == NULL_OBJID){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"ERROR, coord syst not defined");
     		ex$message(msgnumb = SM_S_ErCsNtDf);
		*sts =  OM_E_ABORT; 
		goto quit;
 }

 coord = me->coord;
 /* verif macro name */
			
 FIfld_get_text(me->forms[0].form_ptr,OCC_NAME,0, 0,
                       			num_char, text,&sel_flag,&r_pos);
 if(text[0] == '\0'){
		if(me->mytype == MODIFY) {
			mac = me->macro_id; 
			me->def_name[0] = '\0';
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
  	
 FIg_get_text(me->forms[0].form_ptr,AFTDIST, text);
 if(text[0] == '\0'){
  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  					"No aftdist defined");
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 sscanf(text,"%lf",&me->aftdist);	
 SMConvDistExtInt(me->aftdist, &aftdist, me->act_env.md_id.osnum);

 FIg_get_text(me->forms[0].form_ptr,FOREDIST, text);
 if(text[0] == '\0'){
  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  					"No foredist defined");
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 sscanf(text,"%lf",&me->foredist);	
 SMConvDistExtInt(me->foredist, &foredist, me->act_env.md_id.osnum);

 if( me->aft_id.obj_id.objid == NULL_OBJID){

	/* create the expression */

   	FIg_get_text(me->forms[0].form_ptr,AFTEXP, text);
	EXP_strip(text);
	strcpy(me->aftexp, text);
	me->aft_id.obj_id.osnum = me->act_env.md_id.osnum;
	stat = exp$create(	exp_name  = text,
				exp_value = aftdist,
				p_exp_id  = &me->aft_id.obj_id.objid,
				osnum     = me->aft_id.obj_id.osnum);
	if(stat != EXP_S_SUCCESS){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  					"Cannot create exp for AftDist");
		me->aft_id.obj_id.objid = NULL_OBJID;
   		FIg_set_text(me->forms[0].form_ptr,AFTEXP, "");
   		FIg_set_text(me->forms[0].form_ptr,AFTDIST, "");
		*sts =  OM_E_ABORT; 
		goto quit;
	}

 	stat = as$make_source(go_grid = me->aft_id.obj_id,
                          	mod_env = &me->aft_id.mod_env,
                          	as_os   = me->act_env.md_id.osnum,
                          	as_grid = &aft_grid);
 	as$status(sts = stat);
  	if(!(stat & 1)){
     			printf("erreur as$make_source\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  	}

 	stat = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   targetid = aft_grid.objid,
		   targetos = aft_grid.osnum);

 	as$status(sts = stat);
 	if(!(stat & 1)){
		printf("ERROR NDnode.NDchg_state\n"); 
		*sts = OM_E_ABORT;
		goto quit;
 	}
 }	
 else{	
 	stat = as$make_source( go_grid = me->aft_id.obj_id,
                          mod_env = &me->aft_id.mod_env,
                          as_os   = me->act_env.md_id.osnum,
                          as_grid = &aft_grid);
 	as$status(sts = stat);
  	if(!(stat & 1)){
     			printf("erreur as$make_source\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  	}

 }
 if( me->fore_id.obj_id.objid == NULL_OBJID){

	/* create the expression */

   	FIg_get_text(me->forms[0].form_ptr,FOREXP, text);
	EXP_strip(text);
	strcpy(me->forexp, text);
	me->fore_id.obj_id.osnum = me->act_env.md_id.osnum;
	stat = exp$create(	exp_name  = text,
				exp_value = foredist,
				p_exp_id  = &me->fore_id.obj_id.objid,
				osnum     = me->fore_id.obj_id.osnum);
	if(stat != EXP_S_SUCCESS){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
  					"Cannot create exp for ForeDist");
		me->fore_id.obj_id.objid = NULL_OBJID;
   		FIg_set_text(me->forms[0].form_ptr,FOREXP, "");
   		FIg_set_text(me->forms[0].form_ptr,FOREDIST, "");
		*sts =  OM_E_ABORT; 
		goto quit;
	}
 	stat = as$make_source(go_grid = me->fore_id.obj_id,
                          	mod_env = &me->fore_id.mod_env,
                          	as_os   = me->act_env.md_id.osnum,
                          	as_grid = &fore_grid);
 	as$status(sts = stat);
  	if(!(stat & 1)){
     			printf("erreur as$make_source\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  	}
 	stat = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   targetid = fore_grid.objid,
		   targetos = fore_grid.osnum);

 	as$status(sts = stat);
 	if(!(stat & 1)){
		printf("ERROR NDnode.NDchg_state\n"); 
		*sts = OM_E_ABORT;
		goto quit;
 	}
 }	
 else{

 	stat = as$make_source(go_grid = me->fore_id.obj_id,
                          	mod_env = &me->fore_id.mod_env,
                          	as_os   = me->act_env.md_id.osnum,
                          	as_grid = &fore_grid);
 	as$status(sts = stat);
  	if(!(stat & 1)){
     			printf("erreur as$make_source\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  	}
 }

 FIg_get_state(me->forms[0].form_ptr, MIDDLE, &state);
 if(state) me->is_middle = 1;
 else me->is_middle = 0;

 FIg_get_state(me->forms[0].form_ptr, ANALYSIS, &state);
 if(state) me->is_analysis = 1;
 else me->is_analysis = 0;
 if(me->is_analysis) {
	crit.desc.type = AC_ATTRIB_DOUBLE;
	strcpy(crit.desc.value.att_txt,"1");
	strcpy(crit.name,"is_analysis");

	stat = SM$CritSel(	options = SM_REF_FILE,
				msg = &msg,
				type = SM_PP,
				nb_crit = 1,
				crit = &crit,
				list = &list);
	if(!(stat&msg&1)){
 		FIg_set_text(me->forms[0].form_ptr, 
 				MESSAGE_FIELD,"ERROR SM$CritSel");
		*sts = OM_E_ABORT;
 		goto quit;
	}
	if(list.nb_objects && (!(me->mytype == MODIFY && 
	    me->macro_id.objid == list.list[0].obj_id.objid &&
	    me->macro_id.osnum == list.list[0].obj_id.osnum) )) {
		   	
		ex$message(msgnumb = SM_S_OneDgCsPp);
 		FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"There is already one Design Perpendicular");
		me->is_analysis = 0;
		FIg_set_state_off(me->forms[0].form_ptr,
						ANALYSIS);
		*sts = OM_E_ABORT;
 		goto quit;

	}
 }

 FIg_get_state(me->forms[0].form_ptr, DRAWING, &state);
 if(state) me->is_drawing = 1;
 else me->is_drawing = 0;

 FIg_get_text(me->forms[0].form_ptr,AFTNAME, me->aftname);
 FIg_get_text(me->forms[0].form_ptr,FORENAME, me->forename);
 if(me->is_middle) FIg_get_text(me->forms[0].form_ptr,MIDNAME, me->midname);
 if(me->is_drawing) FIg_get_text(me->forms[0].form_ptr,DRWNAME, me->drwname);
 

 /* fill the ACrg_coll with the attributes */

 nb_att = 8;
 stat = SMSetRgAtt(me->is_analysis, me->is_middle, me->is_drawing, 
		   me->aftname, me->midname, me->forename, me->drwname, 
		   me->axis, ACrg);

 if(!(stat & 1)){
        printf("ERROR SMSetRgAtt\n");
  	*sts =  OM_E_ABORT;
  	goto quit;
 }
 /* place the macro */

 if(me->mytype == PLACE) { 
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->act_env.md_id.osnum;
 
  	stat = om$construct(classid = OPP_SMCsPp_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
	as$status(sts = stat);
  	if(!(stat & 1)){
     			printf("erreur creating macro\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  	}

  			
	stat = om$send(msg = message SMCsPp.SMcreate
                   			(&msg, &coord,&aft_grid, 
					 &fore_grid,
                   			 nb_att, ACrg, me->def_name),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);



	as$status(sts = stat);
  	if(!(stat & msg & 1)){
        			printf("erreur place macro\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  	}
 }		
 else{
  			 
	/* modify macro */

	stat = om$send(msg = message SMCsPp.SMModify
                   			(&msg, &coord, &aft_grid, 
					 &fore_grid, 
                   			 nb_att, ACrg, me->def_name),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);


	as$status(sts = stat);
  	if(!(stat & msg & 1)){
        			printf("erreur modify macro\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  	}
 }



 

quit:
 if(list.list != NULL){free(list.list); list.list = NULL;}
 if(!(*sts&1)){
 	if(me->mytype == MODIFY) {
		ex$message(msgnumb = SM_S_ModFail); 		
	}
 	else 	{
 		if(mac.objid != NULL_OBJID && 
 		   !( om$is_objid_valid(osnum = mac.osnum,
 		   			objid = mac.objid) & 1) ){
 			stat = om$send(msg = message GRgraphics.GRdelete(&msg, &me->act_env),
 		             targetid = mac.objid,targetos = mac.osnum);
 			as$status(sts = stat);
 			if(!(stat&msg&1))printf("ERROR delete macro\n");
 			mac.objid = NULL_OBJID;
 		}
		ex$message(msgnumb = SM_S_PlFail);
		
 	}
  }
  else{
 	if(me->mytype == MODIFY){ 
 		me->old_macro_id = me->macro_id;
 		strcpy(me->old_def_name,me->def_name);
 		me->old_coord = me->coord;
 		me->oldaft_id = me->aft_id;
 		me->oldfore_id = me->fore_id;
 		strcpy(me->old_axis, me->axis);
 		strcpy(me->old_aftexp, me->aftexp);
 		strcpy(me->old_forexp, me->forexp);
 		me->old_aftdist = me->aftdist;
 		me->old_foredist = me->foredist;
 		me->old_analysis = me->is_analysis;
 		me->old_middle = me->is_middle;
 		me->old_drawing = me->is_drawing;
 		strcpy(me->old_aftname,me->aftname);
 		strcpy(me->old_forename,me->forename);
 		strcpy(me->old_midname,me->midname);
 		strcpy(me->old_drwname,me->drwname);
 	   
 		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Modify Successfull");
		ex$message(msgnumb = SM_S_ModSucc);
 	}
 	else 	{
 		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Place Successfull");
		ex$message(msgnumb = SM_S_PlSucc);
 	}
  }
  if(me->mytype == PLACE){ 
  	(void)GetDefName("Perp_0",me->def_name);
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  }
  

  return OM_S_SUCCESS;
}



end implementation SMCmdPerp;




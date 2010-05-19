/* $Id: SMLtdNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/cmd / SMLtdNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLtdNotif.I,v $
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
# Revision 1.4  1996/04/02  06:57:16  pinnacle
# Replaced: smspace/cmd/SMLtdNotif.I for:  by ksundar for vds.240
#
# Revision 1.3  1996/03/22  14:18:16  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/01/24  20:07:18  pinnacle
# Replaced: ./smspace/cmd/SMLtdNotif.I for:  by azuurhou for vds.240
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
 *	06/01/92	plx		Creation Date
 *	01/24/96	adz		Correction in invalid processing.
 *
 * -------------------------------------------------------------------*/

class implementation SMCmdLtdVol;
  
#include <string.h> 
#include "expression.h"
#include "expmacros.h"
#include "macro.h"
#include "acmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "FI.h"
#include "msdef.h"
#include "msmacros.h"
#include "vdsmacros.h"
#include "VDmem.h"		/* Memory Checking	*/
#include "v_dbgmacros.h"	/* Debug Statements.	*/
#include "SMmsg.h"

#include "SMspacecom.h"

#define MAX_SURF 	49
#define MAX_TEMP	50 	/* number of templates */
 
extern GRclassid 	OPP_SMLtdVol_class_id, OPP_EMSsurface_class_id, 
 			OPP_ci_macro_class_id, OPP_ACpretend_class_id;
 
from GRgraphics	import GRdelete, GRdisplay;
from ACmacro_defn 	import ACgive_upscan;
from NDnode		import NDgive_structure, NDconnect, NDdisconnect, 
			       NDchg_state, NDget_objects;
from NDmacro		import ACreturn_foot;
from ASnode		import ASreturn_go;
from GRvg		import GRputsymb, GRputname, GRchgname, GRgetname;
from SMmgr		import SMGetAttDbl,SMGetAttTxt;
from ACncpx		import ACmplace,ACchg_STATE,ACget_STATE;

/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance 
/*
/**/
 
method store_obj(long	*sts; int max_obj)
{
	*sts = OM_S_SUCCESS;

	om$send(msg = message SMCmdVol.store_obj(sts, MAX_SURF),
                mode = OM_e_wrt_message,
                targetid = my_id);

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
 int			i, stat, count, num_rows ;
 long			attr;
 long			msg;
 struct GRid		*roots;
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
 
if(count > 0)  /* Common case : macro is OK */
  {
 	me->nb_limits = count - 1;

 	/* Get the expression  */
 
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

 	me->consume = (IGRint) str.var.root_pm_st.value;
 		
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

    me->nb_limits = 0;
    me->consume = 0;

  }

 if(me->mytype == MODIFY) {
 	me->old_macro_id = me->macro_id ;
 	for(i=0;i< me->nb_limits;i++) 
 		me->old_limits[i] = me->limits[i] ;
 }
 FImcf_get_attr(me->forms[0].form_ptr,LIMITS, &attr);
 attr = attr | FI_ROW_SELECT;
 FImcf_set_attr(me->forms[0].form_ptr,LIMITS, attr);
 
 vd$get_name(  name= me->def_name, obj = &me->macro_id);

 if(me->mytype == MODIFY) {
 		me->old_consume = me->consume;
 		strcpy(me->old_def_name,me->def_name);
 }
 else (void)GetDefName("SMLtdVol_0",me->def_name);

 FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);


 if(me->consume == 1) FIg_set_state_on(me->forms[0].form_ptr, CONSUME);
 else	FIg_set_state_off(me->forms[0].form_ptr, CONSUME);
	

 stat = om$send(msg = message SMCmdLtdVol.load_macro(&msg),
 		      targetid = my_id);
 if(!(stat & msg & 1)){ 
 			printf("ERROR load macro\n");
 			*sts = OM_E_ABORT;
 			return OM_S_SUCCESS;
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
 stat = om$send(msg = message SMCmdLtdVol.DispAll(&msg),
 		      targetid = my_id);
 if(!(stat & msg & 1)){ 
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
	int		status;
	long		test;
  
	*sts = OM_S_SUCCESS;

	status =
	om$send(msg = message SMCmdVol.reset_form(&test),
                mode = OM_e_wrt_message,
                targetid = my_id);
	if(!(status & test & 1)){
		printf("ERROR reset_form \n");
		*sts = OM_E_ABORT;
		return status;
	}

	if(me->mytype != MODIFY) {
 		me->consume = 0;
 		FIg_set_state_off(me->forms[0].form_ptr, CONSUME);
	}
	else{
 		me->consume = me->old_consume;
	
		if(me->consume == 1)
		  FIg_set_state_on(me->forms[0].form_ptr, CONSUME);
		else 
		  FIg_set_state_off(me->forms[0].form_ptr, CONSUME);
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

	int		status;
  
	status =
	om$send(msg = message SMCmdVol.clear_form(sts),
		mode = OM_e_wrt_message,
		targetid = my_id);
	if(!(status & *sts & 1)){
		printf("ERROR clear_form \n");
 		*sts = OM_E_ABORT;
 		return status;
	}

	me->consume = 0;	
	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);

	return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* Get the info from the form to place or modify the macro
/* 
/**/
 
method save_all(long *sts )
{
	int 		i, sel_flag, r_pos, nb_roots,
			num_char = MY_MAX_CHAR, 
			stat, state;
	char 		text[MY_MAX_CHAR];
	long		sizebuf, test, nret, msg;
	struct GRid	mac, *roots;
	struct GRsymbology	symb;

	SetProc( SMCmdLtdVol_save_all ); Begin
  
	*sts = OM_S_SUCCESS;
	roots = NULL;

	mac.objid = NULL_OBJID;
	mac.osnum = me->act_env.md_id.osnum;

	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
	if( me->nb_limits == 0 ){
  	  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
  			"No objects located");
	  ex$message(msgnumb = SM_E_NoObjLoc);
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
			
	text[0] = '\0';
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
				"ERROR, No macro name defined ");
		*sts =  OM_E_ABORT; 
		goto quit;
	  }
	}
	else{
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
  	
	FIg_get_state(me->forms[0].form_ptr,CONSUME,&state);
	if(state ) me->consume = 1;
	else me->consume = 0;

	__DBGpr_int(" Consume ", me->consume );
  	
	nb_roots = me->nb_limits+1;
		 
	if(me->mytype == PLACE){ 
	 	 __DBGpr_com(" Place The Limited Volume " );
  		mac.objid = NULL_OBJID;
  		mac.osnum = me->act_env.md_id.osnum;
 
  		stat = om$construct(classid = OPP_SMLtdVol_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
  		if(!(stat & 1)){
     			printf("ERROR: creating macro failed\n"); 
			*sts =  OM_E_ABORT; 
			goto quit;
  		}
	}
	
	roots = _MALLOC( nb_roots, struct GRid );
	if(roots == NULL){
		printf("ERROR Bad allocation\n");
		*sts =  OM_E_ABORT; 
		goto quit;
	}

	for(i=0;i<me->nb_limits;i++) {
     		stat = as$make_source(
     				go_grid = me->limits[i].surf.located_obj,
		     		mod_env = &me->limits[i].surf.module_info,
		     		as_os   = me->act_env.md_id.osnum,
		     		as_grid = &roots[i+1]);
     		as$status(sts = stat);
        	if(!(stat & 1)){
 			printf("ERROR make_source failed \n");
 			*sts = OM_E_ABORT;
 			goto quit;
          	} 
	}

	if( me->mytype == PLACE ){
  			 
  	  __DBGpr_com(" onsume is roots[0] ");
  		
	  roots[0].osnum = me->act_env.md_id.osnum;
	  stat =
  	  exp$create( 	exp_name  = NULL,
  			exp_value = (IGRdouble) me->consume,
  			p_exp_id  = &roots[0].objid,
  			osnum     = roots[0].osnum);
	  if(stat != EXP_S_SUCCESS){
  		printf("ERROR creating expression for consume\n");
  		*sts =  OM_E_ABORT;
  		goto quit;
	  }
  		
          stat =
	  om$send(msg = message NDnode.NDchg_state(
                                            ND_DEL_NO_CH | ND_WAIT_DEL,
                                            ND_DEL_NO_CH | ND_WAIT_DEL),
                 targetid = roots[0].objid,
                 targetos = roots[0].osnum);

	  if(!(stat & 1)){
		as$status( sts = stat );
               	printf("ERROR NDnode.NDchg_state\n");
               	*sts =  OM_E_ABORT;
               	goto quit;
	  }
        		
	  /* place macro */
			
          (void)GetDefName(text, me->def_name);
	  stat =
	  om$send(msg = message GRvg.GRputname(&msg, me->def_name),
		senderid = NULL_OBJID,
                targetid = mac.objid,
		targetos = mac.osnum);
	  if(!(stat & msg & 1)){
  		as$status(sts = stat);
        	printf("ERROR msg GRvg.GRputname failed\n");
               	*sts =  OM_E_ABORT;
		goto quit;
	  }

	  stat =
	  om$send(msg = message ACncpx.ACmplace
                   		((IGRint *)&msg,ACcant_place_sym,0,
                    		"SMLtdVol",nb_roots, roots,
                    		&me->act_env),
		senderid = NULL_OBJID,
               	targetid = mac.objid,
		targetos = mac.osnum);

	  if(!(stat & msg & 1)){
		as$status(sts = stat);
        	printf("erreur place macro\n");
               	*sts =  OM_E_ABORT;
        	goto quit;
	  }
			
	  /* put active symbology */
	  stat =
	  om$send(msg = message GRvg.GRputsymb (&msg, &symb),
			senderid = NULL_OBJID,
                   	targetid = mac.objid,
		      	targetos = mac.osnum);

	  if(!(stat & msg & 1)){
		as$status(sts = stat);
        	printf("erreur GRvg.GRputsymb\n");
               	*sts =  OM_E_ABORT;
        	goto quit;
	  }
		/* Added for TR: 179600457 by Sundar */
	  	{
        	enum GRdpmode dpmode;
                dpmode = GRbd ;
 
                stat = om$send(  msg      = message GRgraphics.GRdisplay(
                                        &msg,
                                        &me->act_env.md_env.matrix_type,
                                        me->act_env.md_env.matrix,
                                        &dpmode,
                                        &me->act_env.md_id ),
                                targetid = mac.objid,
                                targetos = mac.osnum);
	  	}
	}
	else{
  			 
	  __DBGpr_com(" Modify Macro " );
	  stat =
	  om$send(msg = message SMCmdLtdVol.SMmodif_mac (nb_roots, roots),
		targetid = my_id);
	  if(!(stat & 1)){
 		printf("ERROR  SMCmdLtdVol.SMmodif_mac\n");
               	*sts =  OM_E_ABORT;
        	goto quit;
	  }
	}
 
	if( me->mytype == MODIFY ){	ex$message(msgnumb = SM_S_ModSucc);}
	else{
	  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
	  ex$message(msgnumb = SM_S_PlSucc);
	}

quit:
	if(!(*sts&1)){
 	  if( me->mytype == MODIFY ){	ex$message(msgnumb = SM_S_ModFail);}
 	  else if (mac.objid != NULL_OBJID && 
 		 om$is_objid_valid(osnum = mac.osnum, objid = mac.objid)){

		stat =
		om$send(msg = message GRgraphics.GRdelete(&msg, &me->act_env),
			targetid = mac.objid,
			targetos = mac.osnum);
                if(!(stat&msg&1)){
                	as$status(sts = stat);
			printf("ERROR delete macro\n");
		}
                mac.objid = NULL_OBJID;
		ex$message(msgnumb = SM_S_PlFail);
	  }
	}
	else{

	  __DBGpr_com(" Reset the form and instance ");

  	  me->select_row = 0;
  	  me->pos = 0;
  	  if(me->mytype == MODIFY){ 
 		me->old_macro_id = me->macro_id ;
 		me->old_consume = me->consume;
 		strcpy(me->old_def_name,me->def_name);
 		for(i=0;i< me->nb_limits;i++)
 			me->old_limits[i] = me->limits[i];
		for(i= me->nb_limits;i<MAX_SURF;i++) 
			me->old_limits[i].surf.located_obj.objid = NULL_OBJID;
	  }
  	  else{
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 0, TRUE);
  		FIfld_set_select(me->forms[0].form_ptr, LIMITS,0, 1, TRUE);
  		FIfld_set_active_row(me->forms[0].form_ptr, LIMITS,
   					me->select_row, me->pos);
  		stat = om$send(msg = message SMCmdLtdVol.DispAll(&test),
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
  
	_FREE( roots );

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
 IGRboolean		discon, put_batch;
  
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
    int         state, consume = 0;

    put_batch = TRUE;
    /* Recreate an expression with default parameter */
    exp.osnum = me->ModuleInfo.md_id.osnum;
    stat = exp$create(exp_name  = NULL,
		      exp_value = (IGRdouble) consume,
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

 if(me->old_consume != me->consume){
 	sprintf(tmp,"%lf", (IGRdouble)me->consume);
  	stat = exp$modify( 	exp_id  	= old_roots[0].objid,
  				exp_syntax 	= tmp,
  				osnum     	= old_roots[0].osnum);
  	if(stat != EXP_S_SUCCESS){
  		printf("ERROR modify expression for consume\n");
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


end implementation SMCmdLtdVol;




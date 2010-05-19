/* $Id: SMCmdPerp.sl,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/cmd / SMCmdPerp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdPerp.sl,v $
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
# Revision 1.2  1995/12/15  16:18:46  pinnacle
# Replaced: smperp/cmd/SMCmdPerp.sl for:  by v240_int for vds.240
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

/*    File          SMCmdPerp.sl
      Description   Command object to place perpendicular
      		    
      Auteur        Pascale Lacroix (ISDC) 
      Date          Oct-92     
*/

command_string       SMC_M_PlCsPp,0,SMPlCsPp
synonym		     SMC_M_MdCsPp,1,SMMdCsPp
command_table        "sman.cmd"
class                SMCmdPerp
super_class          VDS_LOCATE
product_name         "$VDS"

form "SMCsPp",0,0,"-1","-1"

specification

#include <stdio.h>

#include "OMmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "coparamac.h"
#include "growner.h"
#include "SMmsg.h"


#include "FI.h"

#include "SMCsPp.h"





instance 
{
struct GRobj_env	global; 
IGRdouble		Lpp;
struct GRid 		coord;
struct GRmd_env		cs_env;
char			axis[MAX_CHAR];
IGRdouble		aftdist;
IGRdouble		foredist;
char			aftexp[MAX_CHAR];
char			forexp[MAX_CHAR];
IGRint			is_analysis;
IGRint			is_middle;
IGRint			is_drawing;
char			aftname[MAX_CHAR];
char			forename[MAX_CHAR];
char			midname[MAX_CHAR];
char			drwname[MAX_CHAR];
char			def_name[MAX_CHAR];
struct GRobj_env	aft_id;
struct GRobj_env	fore_id;

struct GRobj_env	old_global; 
struct GRid 		old_coord;
char			old_axis[MAX_CHAR];
IGRdouble		old_aftdist;
IGRdouble		old_foredist;
char			old_aftexp[MAX_CHAR];
char			old_forexp[MAX_CHAR];
IGRint			old_analysis;
IGRint			old_middle;
IGRint			old_drawing;
char			old_aftname[MAX_CHAR];
char			old_forename[MAX_CHAR];
char			old_midname[MAX_CHAR];
char			old_drwname[MAX_CHAR];
char			old_def_name[MAX_CHAR];
struct GRobj_env	oldaft_id;
struct GRobj_env	oldfore_id;


struct GRmd_env		act_env;
struct GRid		macro_id;
struct GRid		old_macro_id;


}

implementation

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"
#include "gr.h"
#include "SMdef.h"
#include "SMmacros.h"


#define PLACE    	0
#define MODIFY		1

#define AS_DEBUG	1

#define LOAD_OCC 	511
#define LOAD_CS		513
#define RESTART 	515
#define MODIF_FORM 	517


%safe

	static int 	x_memo = -1,
			y_memo = -1;
%endsafe			

from NDmacro		import 	ACreturn_foot;
from NDnode		import	NDgive_structure;

extern	GRclassid	OPP_expression_class_id,OPP_text_exp_class_id;


/*************************************************************************/

state_table

#include "VDSFilter.h"
#include "SMmsg.h"

#define PLACE    	0
#define MODIFY		1

#define AS_DEBUG	1


#define LOAD_OCC 	511
#define LOAD_CS		513
#define RESTART 	515
#define MODIF_FORM 	517


state start

  on CMD_TYPE = PLACE	do message_key SM_M_PlCsPp
			do reset_form
                       		on ERROR do status_key SM_E_ErInit
				state terminate
                        do display_form  0
  			state modif_form 
  				
  on CMD_TYPE = MODIFY	do message_key	SM_M_MdCsPp	state loc_macro

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS		state load_cs
  on GR_UNKNOWN_TYPE.RESTART 		state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state restart

  on CMD_TYPE = PLACE	state modif_form
  				
  on CMD_TYPE = MODIFY	do clear_form state reloc_macro

  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state loc_macro
  prompt_key         SM_P_IdCsPp
  accept_key         SM_P_PlAccRej
  locate_class	     "SMCsPp"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID  do clear_form
				       do store_occ
                       on ERROR do status_key  SM_E_ErStMc state terminate
		       do display_form  0
				state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART 	state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC 	do clear_form 
                       			on ERROR state terminate
  				state load_from_occ

state reloc_macro
  prompt_key         SM_P_IdCsPp
  accept_key         SM_P_PlAccRej
  locate_class	     "SMCsPp"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID do store_occ
                       on ERROR do status_key  SM_E_ErStMc state terminate
				state modif_form
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

state  modif_form 
  prompt_key          SM_P_EntPrmFr
  filter              get_event

  on EX_FORM_FINISHED     	state terminate
  
  
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.RESTART state restart


		    
state load_cs
  prompt_key         SM_P_IdCrdStm
  locate_class	     "GRlbsys"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_cs  
                       		on ERROR state terminate
                       		state modif_form
  on EX_BACK_UP		state modif_form

  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC   do clear_form 
                       			on ERROR state terminate
  					state load_from_occ
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs


state load_from_occ
  prompt_key         SM_P_IdCsPp
  locate_class	     "SMCsPp"
  locate_owner       "LC_RIGID_COMP | LC_RIGID_OWNER | LC_FLEX_COMP |
                        LC_FLEX_OWNER | LC_REF_OBJECTS"

  filter              vds_locate

  on EX_DATA or EX_STRING or EX_OBJID 
			do store_occ 
                       		on ERROR state terminate
			state modif_form
				
  on GR_UNKNOWN_TYPE.MODIF_FORM		state modif_form
  on GR_UNKNOWN_TYPE.LOAD_OCC do clear_form 
                       			on ERROR state terminate
  					state load_from_occ

  on GR_UNKNOWN_TYPE.RESTART state restart
  on GR_UNKNOWN_TYPE.LOAD_CS	state load_cs


at init   do init_all
at delete do delete_all
at wakeup do verify_obj
	  do DispAll(GRhhd)

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMPerpNtf.I                                           */




action reset_form extern
action store_occ extern

action save_all extern
action clear_form extern
action store_cs extern
action DispAll(enum GRdpmode mode) extern
action verify_obj extern
action GetLPP extern


/* ====================== init_all =============================
  
	This action init instances
  
============================================================= */
action init_all
/*.init_all*/
{
 IGRint			stat;
 IGRlong		msg, test, sizebuf, nret;
 char			name[DI_PATH_MAX];
 
 /*| get current module env */

 *sts = OM_S_SUCCESS;
	
 dp$erase_hilite(msg = &msg);
 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(msg     = &msg,
                   sizbuf  = &sizebuf,
                   buffer  = &me->act_env,
                   nret    = &nret);

 /* get active ship cs */

 if(SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,(struct GRid *)NULL,
	       &me->coord,&me->cs_env,(IGRboolean *)NULL)
    && me->coord.objid != NULL_OBJID)
   {	
      strcpy(name, "defined");  
      SMGetSplitName(&me->coord, name);
      FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
   } 

 strcpy(me->axis,"x");
 me->global.obj_id.objid = NULL_OBJID;
 me->Lpp = 0.;
 me->aftdist = 0.;
 me->foredist = 0.;
 me->is_analysis = 0;
 me->is_middle = 0;
 me->is_drawing = 0;
 me->aftexp[0] ='\0';
 me->forexp[0] ='\0';
 strcpy(me->aftname ,"Aft");
 strcpy(me->forename,"Fore");
 strcpy(me->midname,"Mid");
 strcpy(me->drwname,"SMDrwPrp");
 me->def_name[0] = '\0';
 me->macro_id.objid = NULL_OBJID;
 me->aft_id.obj_id.objid = NULL_OBJID;
 me->fore_id.obj_id.objid = NULL_OBJID;

 me->old_global.obj_id.objid = NULL_OBJID;
 strcpy(me->old_axis,"x");
 me->old_aftdist = 0.;
 me->old_foredist = 0.;
 me->old_aftexp[0] ='\0';
 me->old_forexp[0] ='\0';
 me->old_analysis = 0;
 me->old_middle = 0;
 me->old_drawing = 0;
 strcpy(me->old_aftname ,"Aft");
 strcpy(me->old_forename,"Fore");
 strcpy(me->old_midname,"Mid");
 strcpy(me->old_drwname,"SMDrwPrp");
 me->old_def_name[0] = '\0';
 me->old_macro_id.objid = NULL_OBJID;
 me->oldaft_id.obj_id.objid = NULL_OBJID;
 me->oldfore_id.obj_id.objid = NULL_OBJID;

 stat = om$send(msg = message SMCmdPerp.GetLPP(&test),
		      			targetid = my_id);
 if(!(stat & test & 1))
 	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,
 					"Warning, LPP not defined");

 stat = EXP_rec_untranslate(me->global.obj_id.objid, 
			me->global.obj_id.osnum, me->forexp);
 if( (stat != DIR_S_SUCCESS)&&(stat != DIR_W_NAME_NOT_FOUND))
		 { di$report_error(sts = stat) ; me->forexp[0] = '\0';}
 
 strcpy(me->old_forexp, me->forexp);
 me->foredist = me->old_foredist = me->Lpp;

 SMConvDistIntExt(me->foredist, &me->foredist, 
					me->act_env.md_id.osnum);
 FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,
 					me->foredist,FALSE);
 
 di$split(pathname = me->forexp, name = name);
 FIg_set_text(me->forms[0].form_ptr,FOREXP,name);

 
 FIg_erase(me->forms[0].form_ptr,MIDNAME);
 FIg_erase(me->forms[0].form_ptr,MIDPP);
 FIg_erase(me->forms[0].form_ptr,DRWNAME);
 FIg_erase(me->forms[0].form_ptr,DRWMAC);
	
 if(x_memo != -1 || y_memo != -1)
                FIf_set_location(me->forms[0].form_ptr,x_memo,y_memo);

 if(me->mytype == MODIFY) 
		     FIg_set_text(me->forms[0].form_ptr,F_TITLE,
					"Modify Perpendicular");
 return status;
}

/* ====================== delete_all =============================

    This action delete memory

============================================================= */
action delete_all
{
 IGRlong                msg;

 *sts = OM_S_SUCCESS;

 dp$erase_hilite(msg = &msg);

 if ( me->forms[0].form_ptr != NULL )
      	             FIf_get_location(me->forms[0].form_ptr,&x_memo,&y_memo);

 return status;
}
        
/* ----------------------------------------------------------------- */ 

action form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
 int 			stat = OM_S_SUCCESS, state;
 long  			test, msg;
 char 			name[MAX_CHAR], text[MAX_CHAR];
 struct ACrg_coll  	crit;
 struct SMObjList  	list;
 struct ret_struct	ret_st;


 list.list = NULL;
        
 if ( form_ptr == NULL ){
     		/*| no form_ptr set */
     		return( OM_E_INVARG ); 
 }
  
 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
  
 switch( gadget_label ){
   
  	case SAVE:
   	case STORE:

     		stat = om$send(msg = message SMCmdPerp.save_all(&test),
		      targetid = my_id);
     		if(!(stat & test & 1)){
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
     		stat = om$send(msg = message SMCmdPerp.reset_form(&test),
			 targetid = my_id);
     		_put_response(resp = MODIF_FORM);

     		break;
   
   	case LOAD:
     		_put_response(resp = LOAD_OCC);
    		break;
    
   	case OCC_NAME:
   		FIg_get_text(form_ptr,OCC_NAME, text);
 		(void)GetDefName(text,me->def_name);
 		FIg_set_text(form_ptr,OCC_NAME,me->def_name);
   		
    		break;
        
   	case MIDDLE:
		FIg_get_state(me->forms[0].form_ptr, MIDDLE, &state);
		if(state){
			me->is_middle = 1;
 			FIg_display(me->forms[0].form_ptr,MIDNAME);
 			FIg_display(me->forms[0].form_ptr,MIDPP);
 			FIg_set_text(me->forms[0].form_ptr,MIDNAME,me->midname);
   		}
		else {
			me->is_middle = 0;
 			FIg_erase(me->forms[0].form_ptr,MIDNAME);
 			FIg_erase(me->forms[0].form_ptr,MIDPP);
		}
    		break;

   	case DRAWING:
		FIg_get_state(me->forms[0].form_ptr, DRAWING, &state);
		if(state){
			me->is_drawing = 1;
 			FIg_display(me->forms[0].form_ptr,DRWNAME);
 			FIg_display(me->forms[0].form_ptr,DRWMAC);
 			FIg_set_text(me->forms[0].form_ptr,DRWNAME,me->drwname);
   		}
		else {
			me->is_drawing = 0;
 			FIg_erase(me->forms[0].form_ptr,DRWNAME);
 			FIg_erase(me->forms[0].form_ptr,DRWMAC);
		}
    		break;

    		
	case ANALYSIS:
		FIg_get_state(me->forms[0].form_ptr, ANALYSIS, &state);
		if(state){
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
 					MESSAGE_FIELD,
 					"ERROR SM$CritSel");
				if(list.list != NULL){free(list.list); list.list = NULL;}
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
				if(list.list != NULL){free(list.list); list.list = NULL;}
				break;
			}
			me->is_analysis = 1;
 			stat = om$send(msg = message SMCmdPerp.GetLPP
 							(&test),
		      			targetid = my_id);
 			if(!(stat & test & 1)){
 				FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"ERROR, LPP not defined");
 				me->is_analysis = 0;
 				FIg_set_state_off(me->forms[0].form_ptr, 
 					ANALYSIS);
				goto quit;
 			}
 			stat = EXP_rec_untranslate(me->global.obj_id.objid, 
				me->global.obj_id.osnum, me->forexp);

 			if( (stat != DIR_S_SUCCESS) && 
				(stat != DIR_W_NAME_NOT_FOUND)){
		 		di$report_error(sts = stat) ; 
				me->forexp[0] = '\0';
			}
			me->fore_id = me->global; 
			me->foredist = me->Lpp;
			SMConvDistIntExt(me->foredist, &me->foredist, 
					me->act_env.md_id.osnum);
 			FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,
 					me->foredist,FALSE);
 			di$split(pathname = me->forexp, name = name);
 			FIg_set_text(me->forms[0].form_ptr,FOREXP,name); 

 			FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"Foredist is LPP (global data)");
   		}
		else {
			me->is_analysis = 0;
			me->fore_id.obj_id.objid = NULL_OBJID;
		}
    		break;
		
	case FOREDIST:
		if(me->is_analysis){

 			stat = EXP_rec_untranslate(me->global.obj_id.objid, 
				me->global.obj_id.osnum, me->forexp);

 			if( (stat != DIR_S_SUCCESS) && 
				(stat != DIR_W_NAME_NOT_FOUND)){
		 		di$report_error(sts = stat) ; 
				me->forexp[0] = '\0';
			}
			me->fore_id = me->global; 
			me->foredist = me->Lpp;
			SMConvDistIntExt(me->foredist, &me->foredist, 
					me->act_env.md_id.osnum);

 			di$split(pathname = me->forexp, name = name);
 			FIg_set_text(me->forms[0].form_ptr,FOREXP,
 					name);
 			FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,
 					me->foredist,FALSE);
 			FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"Foredist is LPP (global data)");
		}
		if( me->fore_id.obj_id.objid != NULL_OBJID &&
					me->forexp[0] != '\0'){
 			FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"expression cannot be modified");
 			FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,
 					me->foredist,FALSE);
		}
		break;



	case AFTDIST:
		if(me->aft_id.obj_id.objid != NULL_OBJID && 
					me->aftexp[0] != '\0'){
 			FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"expression cannot be modified");
 			FIfld_set_value(me->forms[0].form_ptr,AFTDIST,0,0,
 					me->aftdist,FALSE);
		}
		break;

	case FOREXP:
		if(me->is_analysis){

 			di$split(pathname = me->forexp, name = name);
 			FIg_set_text(me->forms[0].form_ptr,FOREXP,
 					name);
 			FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"Cannot change expression if design");
			break;
		}
   		FIg_get_text(form_ptr,FOREXP, text);
		EXP_strip(text);
		if(text[0] == '\0'){
			me->fore_id.obj_id.objid = NULL_OBJID;
			break;
		}
		stat = EXP_translate_exp(text, &me->fore_id.obj_id.objid, 
			&me->fore_id.obj_id.osnum);
		if(stat == EXP_SUCCESS){

			/* verify that it is an expression (BUG JLA) */ 

			if( !SMIsKindOf(&me->fore_id.obj_id, 
					OPP_expression_class_id) ||
			     SMIsKindOf(&me->fore_id.obj_id, 
					OPP_text_exp_class_id)){
				me->fore_id.obj_id.objid = NULL_OBJID;
 				FIg_set_text(me->forms[0].form_ptr,FOREXP,
 					"");
 				FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"Invalid Name");
				ex$message(msgnumb = SM_S_NotDblExp);
				break;
			}
 			stat = GetEnvFrObj( &me->fore_id.obj_id, 
					    &me->fore_id.mod_env, NULL);
 			if(!(stat & 1)){
  				printf("ERROR GetEnvFrObj \n");         
  				goto quit;
 			}
			stat = om$send(msg = message NDnode.NDgive_structure
				(&msg, &ret_st, &me->fore_id.mod_env),
				senderid = NULL_OBJID,
				targetid = me->fore_id.obj_id.objid,
				targetos = me->fore_id.obj_id.osnum);
			
			SMConvDistIntExt(ret_st.var.root_pm_st.value, 
					&me->foredist, 
					me->fore_id.mod_env.md_id.osnum);
 			FIfld_set_value(me->forms[0].form_ptr,FOREDIST,0,0,
 					me->foredist,FALSE);
		}
		else me->fore_id.obj_id.objid = NULL_OBJID;
		break;

	case 	AFTEXP:
   		FIg_get_text(form_ptr,AFTEXP, text);
		EXP_strip(text);
		if(text[0] == '\0'){
			me->aft_id.obj_id.objid = NULL_OBJID;
			break;
		}
		stat = EXP_translate_exp(text, &me->aft_id.obj_id.objid, 
			&me->aft_id.obj_id.osnum);
		if(stat == EXP_SUCCESS){

			/* verify that it is an double expression (BUG JLA) */ 

			if( !SMIsKindOf(&me->aft_id.obj_id, 
					OPP_expression_class_id) ||
			     SMIsKindOf(&me->aft_id.obj_id, 
					OPP_text_exp_class_id) ){
				me->aft_id.obj_id.objid = NULL_OBJID;
 				FIg_set_text(me->forms[0].form_ptr,AFTEXP,
 					"");
 				FIg_set_text(me->forms[0].form_ptr, 
 					MESSAGE_FIELD,
 					"Invalid Name");
				ex$message(msgnumb = SM_S_NotDblExp);
				break;
			}
 			stat = GetEnvFrObj( &me->aft_id.obj_id, 
					    &me->aft_id.mod_env, NULL);
 			if(!(stat & 1)){
  				printf("ERROR GetEnvFrObj \n");         
  				goto quit;
 			}
			stat = om$send(msg = message NDnode.NDgive_structure
				(&msg, &ret_st, &me->aft_id.mod_env),
				senderid = NULL_OBJID,
				targetid = me->aft_id.obj_id.objid,
				targetos = me->aft_id.obj_id.osnum);
			
			SMConvDistIntExt(ret_st.var.root_pm_st.value, 
					&me->aftdist, 
					me->aft_id.mod_env.md_id.osnum);
 			FIfld_set_value(me->forms[0].form_ptr,AFTDIST,0,0,
 					me->aftdist,FALSE);
		}
		else me->aft_id.obj_id.objid = NULL_OBJID;
		break;
		

   	case COORDINATE:
     		_put_response(resp = LOAD_CS);
   		
     		break;
     

} /* END switch ( gadget_label ) */


if(list.list != NULL){free(list.list); list.list = NULL;}
  
  return OM_S_SUCCESS;
}


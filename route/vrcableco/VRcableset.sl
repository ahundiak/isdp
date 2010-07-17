/* $Id: VRcableset.sl,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco/VRcableset.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcableset.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/03/04  22:57:00  pinnacle
# Replaced: vrcableco/VRcableset.sl for:  by hverstee for route240
#
# Revision 1.5  1996/02/04  06:39:14  pinnacle
# Replaced: vrcableco/VRcableset.sl for:  by ashankar for route240
#
# Revision 1.4  1996/01/16  20:16:46  pinnacle
# Replaced: vrcableco/VRcableset.sl for:  by r240_int for route240
#
# Revision 1.3  1995/12/08  21:19:16  pinnacle
# Replaced: vrcableco/VRcableset.sl for:  by r240_int for route240
#
 *
 * History:
 *	4/25/91		AdZ	creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb		Add VX_FIproto.h
 *
 *************************************************************************/


/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

class			VRcableset
super_class		"VDB_LOCATE"
command_string		VRC_M_StRvCbDP,0,VRStRvCbDP

form			"VRCbSetup",0,1,"-1","-1"
product_name		"$ROUTE"
command_table		"route.cmd"

start_state		start


/* --------------------------------------------------------------------- */
/* SPECIFICATION AREA */

specification

#include <stdio.h>
#include <string.h>

#include "dpstruct.h"
#include "VRcabledef.h"

instance
{
	IGRchar		work_dir[CABLE_MAX_TXT];
	IGRchar		equip_table[CABLE_MAX_TXT];
	IGRchar		cable_file[CABLE_MAX_TXT];

	IGRchar		exp_dir[CABLE_MAX_TXT];
	IGRchar		home_dir[CABLE_MAX_TXT];
}

/* --------------------------------------------------------------------- */
/* IMPLEMENTATION AREA */

implementation
/* 
 * include files
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "FI.h"
#include "CIforms.h"
#include "ODE.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "expmacros.h"
#include "expression.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#include "VRcabledef.h"
#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1
/*
 * defined form 	./config/english/forms
 */
#define FORM_NAME 	"VRCableSetup"
#define FORM_ID 	100
/* 
 * Available Gadgets 
 *
 * predefined are :
 *	FI_CANCEL	( 4 )
 *	FI_RESET	( 3 )
 *	FI_ACCEPT	( 1 )
 *	FI_MSG_FIELD	( 10 )
 */
#define	L_EQUIP_TAB		15
#define	L_CABLE_FILE		16
#define	L_WORKING_DIR		17	/* colomn table */

from	text_exp	import	 NDgive_structure;

/* --------------------------------------------------------------------- */
/* STATES AREA */
state_table

#include "VRmsg.h"

state start
   message_key     VR_M_StRvCbDP 
   prompt_key      VR_P_EntNames 
   filter          get_event
   on EX_STRING    state terminate


at init do cable_init( &me->ret )

/* ---------------------------------------------------------------------- */
/* CABLE_INIT */
action	cable_init
{
/*
 * local variables
 */
IGRchar			path_dir[CABLE_MAX_TXT];
IGRchar			expression_dir[CABLE_MAX_TXT];
IGRlong			msg;
OM_S_OBJID		cur_id;
OMuword			cur_os;
struct	GRid		tmp_obj, VRcable_co;
struct	ret_struct	ret_str;

	*sts = MSSUCC;
/* 
 * Used here to create the form and tell the forms system too
 * who the form belongs to.
 */
	me->work_dir[0]	   = '\0';
	me->equip_table[0] = '\0';
	me->cable_file[0]  = '\0';
	me->exp_dir[0]     = '\0';
	me->home_dir[0]    = '\0';
/*
 * get current working directory
 */
	/*| get_cur_mod */
	status = ex$get_cur_mod(   id = &cur_id,
				osnum = &cur_os );

	/*| find current path*/
	status = di$pwd( dirname = path_dir );
	if( status != DIR_S_SUCCESS ){
		di$report_error( sts	= status ,
				comment = " Error in pwd " );
		return( OM_I_STOP_SENDING );
	}
	/*" Form pathname : <%s> \n", path_dir */

	status = di$translate(	objname	= path_dir,
				osnum	= cur_os,
				p_objid	= &(VRcable_co.objid),
				p_osnum	= &(VRcable_co.osnum) );

	if( status != DIR_S_SUCCESS ){
	/*
	 * not available in system!! error message
	 */
		di$report_error(sts = status, 
				comment = " Error in di_translate " );
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}
/*
 * fill in the known fields, look in a expression table if the variables are
 * defined. If defined, give the names as default in the form.
 */

/* 
 * check if directory exist; if not create the directory
 */
	/*| give pathname */
	status = di$give_pathname(osnum  = cur_os,
				pathname = expression_dir );
	if( status != DIR_S_SUCCESS ){
		/*| give_pathname failed */
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}
	/*" active file <%s> \n", expression_dir */

	strcat( expression_dir, ":usr:" );
	strncpy( me->home_dir, expression_dir, strlen( expression_dir ) - 1 );
	strcat( expression_dir, CABLE_EXP_DIR );
		
	/*" expression_dir : <%s> \n", expression_dir */
	status = di$translate(	objname = expression_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

	if( status != DIR_S_SUCCESS ){
		/*| have to create the object */
		tmp_obj.objid = NULL_OBJID;
		status = di$mkdir( dirname = expression_dir,
			/*	osnum	= cur_os,	*/
				p_dirid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

		if( status != DIR_S_SUCCESS ){
				/*| mkdir failed */
				me->state = _terminate;
				return( OM_I_STOP_SENDING );
		}
	}
	strcpy( me->exp_dir, expression_dir );	
	/*" exp_dir <%s> \n", me->exp_dir */
/*
 * check expressions
 */
	/*| get Equip_Table expression */
	tmp_obj.objid = NULL_OBJID;
	status = di$translate( 	objname = CABLE_EQUIP_TABLE,
				path	= me->exp_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

	if( status == DIR_S_SUCCESS ){
	/* 
	 * get the exp_syntax for the CABLE_EQUIP_TABLE 
	 */
	  /*| get string expression */
	  status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo ),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );

	  strcpy( me->equip_table, ret_str.var.text_st.text_string );
	}
	else	me->equip_table[0] = '\0';

	/*" equip_table: <%s> \n", me->equip_table */

	/*| get Output_File expression */
	tmp_obj.objid = NULL_OBJID;
	status = di$translate( 	objname = CABLE_OUTPUT_FILE,
				path	= me->exp_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

	if( status == DIR_S_SUCCESS ){
	/* 
	 * get the exp_syntax for the CABLE_OUTPUT_FILE
	 */
	  /*| get string expression */
	  status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );

 	  strcpy( me->cable_file, ret_str.var.text_st.text_string );
	}
	else {	strcpy( me->cable_file, getenv("PWD"));
		strcat( me->cable_file, "/");
	}

	/*" cable_fil: <%s> \n", me->cable_file */

	/*| get working_directory expression */
	tmp_obj.objid = NULL_OBJID;
	status = di$translate( 	objname = CABLE_WORKING_DIR,
				path	= me->exp_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );
	if( status == DIR_S_SUCCESS ){
	/* 
	 * get the exp_syntax for the CABLE_WORKING_DIR 
	 */
	  /*| get string expression */
	  status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );
	  strcpy( me->work_dir,  ret_str.var.text_st.text_string );
	}
	else 	me->work_dir[0] = '\0';

	/*" working_dir : <%s> \n", me->work_dir */

	if( me->work_dir[0] != ':' ){
	  strcpy( path_dir, me->home_dir );
	  strcat( path_dir, me->work_dir );
	  strcpy( me->work_dir, path_dir );
	}

	/*" me->work_dir : <%s> \n", me->work_dir */
/*
 * write in the three form fields.
 */
	/*| setup form */
	status = FIg_set_text( me->forms[0].form_ptr, L_EQUIP_TAB, me->equip_table );
	if( status != FI_SUCCESS ){
		printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", status );
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}
	status = FIg_set_text( me->forms[0].form_ptr, L_CABLE_FILE, me->cable_file );
	if( status != FI_SUCCESS ){
		printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", status );
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}

	/*| Fct INIT 14 */
	status = FIg_set_text( me->forms[0].form_ptr, L_WORKING_DIR, me->work_dir );
	if( status != FI_SUCCESS ){
		printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", status );
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}
}

/* ---------------------------------------------------------------------- */
/* FORM_NOTIFICATION */
action	form_notification

/*
 *	int	form_label	: the label of the form
 *	int	gadget_label	: the label of the gadget
 *	double	fld_value	: the value of the gadget
 *	Form	form_ptr	: pointer to the form
 */	
{
/*
 * This routine is called each time input is supplied to or selected in
 * the form. The data has to be found back in the instance data of the
 * class
 */

/*
 * local variables
 */
IGRchar		err_msg[CABLE_MAX_TXT];
IGRchar		work_dir[CABLE_MAX_TXT];
IGRchar		act_path[CABLE_MAX_TXT];
IGRchar		cur_dir[CABLE_MAX_TXT];
IGRchar		expression_dir[CABLE_MAX_TXT];
IGRint		sts,len;
OM_S_OBJID	cur_id;
OMuword		cur_os;
IGRlong		msg;
struct	GRid	tmp_obj;
struct	ret_struct	ret_str;

	/*" form_label   : %d\n", form_label */
	/*" gadget_label : %d\n", gadget_label */

	if( form_ptr == NULL ){
		/*| no form active */
		return( OM_E_INVARG );
	}
	
	sts = ex$get_cur_mod(	id = &cur_id, osnum = &cur_os );
/*
 * clean up the message area ( if used )
 */
	strcpy( err_msg, " " );
	sts = FIg_set_text(	form_ptr,		/* form pointer */
				FI_MSG_FIELD,		/* gadget label */
				err_msg );	/* message	*/
	if( sts != FI_SUCCESS ){
		printf("\nCable Set Up Table: fct FIg_set_text() sts = %d\n", sts);
		me->state = _terminate;
		return( OM_I_STOP_SENDING );
	}
/*
 * select option of the form
 */
	switch ( gadget_label ){

	case FI_CANCEL:
	/* 
	 * Erase the displayed form
	 */
		FIg_set_state_on( form_ptr, FI_CANCEL );
		ex$message( msgnumb = EMS_P_ClearPromptField );
		/*ex$message( msgnumb = EMS_M_ClearMessageField );*/
		ex$message( msgnumb = EMS_S_ClearStatusField );

		sts = FIf_erase( form_ptr );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIf_erase() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}

		_put_response( resp = TERMINATE );	/* exit from command object */

		break;

	case FI_RESET:  
	/*
	 * retrieve the expression from the working space
	 */
		/*" expression_dir : <%s> \n", me->exp_dir */
		sts = di$translate(	objname = me->exp_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

		/*" exp_dirid : objid %d \n", tmp_obj.objid */
		if( sts != DIR_S_SUCCESS ){

		  strcpy( expression_dir, me->home_dir );
		  strcat( expression_dir, CABLE_EXP_DIR );
		  /*| have to create the object */
		  /*" total path <%s> \n", expression_dir */	
		  tmp_obj.objid = NULL_OBJID;

		  /*| have to create the object */
		  tmp_obj.objid = NULL_OBJID;
		  sts = di$mkdir( dirname = expression_dir,
				osnum	= cur_os,
				p_dirid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

		  /*" sts : %d \n", sts */
		  /*" dirobj : objid %d \n", tmp_obj.objid */
		  if( sts != DIR_S_SUCCESS ){
			printf("\nCable Set Up: fct mkdir() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		  strcpy( me->exp_dir, expression_dir );	
		  /*" exp_dir <%s> \n", me->exp_dir */
		}
		
		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_EQUIP_TABLE,
					path	= me->exp_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

		if( sts == DIR_S_SUCCESS ){
		/* 
		 * get the exp_syntax for the CABLE_EQUIP_TABLE 
		 */
		  sts = om$send( msg = message text_exp.NDgive_structure( 
						&msg,
						&ret_str,
						&me->ModuleInfo ),
					targetid = tmp_obj.objid,
					targetos = tmp_obj.osnum,
					senderid = NULL_OBJID );

		  strcpy( me->equip_table, ret_str.var.text_st.text_string );
		  /*" RESET expression : <%s> \n", me->equip_table */
		}
		else	me->equip_table[0] = '\0';

		/* ---------------------------------------------------------- */
		/*" form equip_table ; <%s> \n", me->equip_table */
		/* ---------------------------------------------------------- */

		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_OUTPUT_FILE,
					path	= me->exp_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

		if( sts == DIR_S_SUCCESS ){
		/* 
		 * get the exp_syntax for the CABLE_OUTPUT_FILE
		 */
		  sts = om$send( msg = message text_exp.NDgive_structure( 
						&msg,
						&ret_str,
						&me->ModuleInfo ),
					targetid = tmp_obj.objid,
					targetos = tmp_obj.osnum,
					senderid = NULL_OBJID );

		  strcpy( me->cable_file, ret_str.var.text_st.text_string );
		  /*" RESET expression : <%s> \n", me->cable_file */
		}
		else{	strcpy( me->cable_file, getenv("PWD"));
			strcat( me->cable_file, "/" );
		}
		/* ---------------------------------------------------------- */
		/*" form cable_file ; <%s> \n", me->cable_file */
		/* ---------------------------------------------------------- */

		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_WORKING_DIR,
					path	= me->exp_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

		if( sts == DIR_S_SUCCESS ){
		/*
		 * get the exp_syntax for the CABLE_WORKING_DIR
		 */
		  sts = om$send( msg = message text_exp.NDgive_structure( 
						&msg,
						&ret_str,
						&me->ModuleInfo ),
					targetid = tmp_obj.objid,
					targetos = tmp_obj.osnum,
					senderid = NULL_OBJID );

		  strcpy( me->work_dir, ret_str.var.text_st.text_string );
		  /*" RESET me->work_dir : <%s> \n", me->work_dir */
		}
		else	me->work_dir[0] = '\0';

		/* ---------------------------------------------------------- */
		/*" form me->work_dir ; <%s> \n", me->work_dir */
		/* ---------------------------------------------------------- */

		if( me->work_dir[0] != ':' ){
		/*
        	 * get current working directory
 		 */
		  /*" Form pathname : <%s> \n", work_dir */
		  strcpy( work_dir, me->home_dir );
		  strcat( work_dir, me->work_dir );
		  strcpy( me->work_dir, work_dir );
		  /*" form me->work_dir ; <%s> \n", me->work_dir */
		}
	/*
	 * display the strings into the gadgets
	 */ 
		sts = FIg_set_text( form_ptr, L_EQUIP_TAB, me->equip_table );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts );
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		sts = FIg_set_text( form_ptr, L_CABLE_FILE, me->cable_file );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts );
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}	
	
		sts = FIg_set_text( form_ptr, L_WORKING_DIR, me->work_dir );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts );
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}

		sts = FIf_display( form_ptr );	/* display the form */
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIf_display() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		} 
		break;

	case FI_ACCEPT: 
	/*
	 * find the existing expressions and modify the exp_syntax
	 * when the object isn't found create the expression
	 */
		/*" equip_table : <%s> \n", me->equip_table */
		/*" cable_file  : <%s> \n", me->cable_file */
		/*" work_dir    : <%s> \n", me->work_dir */
		/*" exp_dir     : <%s> \n", me->exp_dir */
		/*" home_dir    : <%s> \n", me->home_dir */
	/*
	 * test if file is in system
	 */
		if( access( me->equip_table, 04 ) != 0 ){
		/* 
		 * give an error message
		 */
		  strcpy(err_msg, "Cable Setup isn't accepted!!" );
   		  sts = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		  if( sts != FI_SUCCESS ){
		  	printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		  FIg_set_state_off( form_ptr, FI_ACCEPT );
		  break;
		}
	/*
	 * check if the directory exist
	 */
		/*" expression_dir : <%s> \n", me->exp_dir */
		sts = di$translate(	objname = me->exp_dir,
					p_objid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

		/*" exp_dirid : objid %d \n", tmp_obj.objid */
		if( sts != DIR_S_SUCCESS ){

			strcpy( expression_dir, me->home_dir );
			strcat( expression_dir, CABLE_EXP_DIR );
			/*| have to create the object */
			tmp_obj.objid = NULL_OBJID;
			sts = di$mkdir( dirname = expression_dir,
					osnum	= cur_os,
					p_dirid = &tmp_obj.objid,
					p_osnum = &tmp_obj.osnum );

			/*" sts : %d \n", sts */
			if( sts != DIR_S_SUCCESS ){
				printf("\nCable Set Up: fct mkdir() sts = %d\n", sts);
				me->state = _terminate;
				return( OM_I_STOP_SENDING );
			}
			strcpy( me->exp_dir, expression_dir );	
			/*" exp_dir <%s> \n", me->exp_dir */
		}

		/* ----------------------------------------------------------- */
		/* get current working directory */
		/* ----------------------------------------------------------- */
		status = di$pwd( dirname = act_path );
		if( status != DIR_S_SUCCESS){
		  printf(" ERROR: cannot get active working directory\n");
		  me->state = _terminate;
		  return( OM_I_STOP_SENDING );
		}

		/* ----------------------------------------------------------- */
		/*| go to directory */
		/* ----------------------------------------------------------- */
		sts = di$cd( dirname = me->exp_dir );
		if( sts != DIR_S_SUCCESS ){
			printf("\nCable Set Up: fct cd() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}

		/* ----------------------------------------------------------- */
		/*| set expressions */
		/* ----------------------------------------------------------- */
		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_EQUIP_TABLE,
					path	= me->exp_dir,
					p_objid = &(tmp_obj.objid),
					p_osnum = &(tmp_obj.osnum) );

		if( sts != DIR_S_SUCCESS ){
			/*| create CABLE_EQUIP_TABLE */
			sts = exp$create(exp_name = CABLE_EQUIP_TABLE,
					type_rq	 = EXP_TEXT,
					exp_syntax = me->equip_table,
					p_exp_id = &(tmp_obj.objid) );
		}
		else{	sts = exp$modify(exp_name = CABLE_EQUIP_TABLE,
					exp_syntax = me->equip_table );
		}

		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_OUTPUT_FILE,
					path	= me->exp_dir,
					p_objid = &(tmp_obj.objid),
					p_osnum = &(tmp_obj.osnum) );

		if( sts != DIR_S_SUCCESS ){
			/*|  create CABLE_OUTPUT_FILE */
			sts = exp$create(exp_name = CABLE_OUTPUT_FILE,
					type_rq	 = EXP_TEXT,
					exp_syntax = me->cable_file,
					p_exp_id = &(tmp_obj.objid) );
		}
		else{	sts = exp$modify(exp_name = CABLE_OUTPUT_FILE,
					exp_syntax = me->cable_file );
		}

		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = CABLE_WORKING_DIR,
					path	= me->exp_dir,
					p_objid = &(tmp_obj.objid),
					p_osnum = &(tmp_obj.osnum) );

		if( sts != DIR_S_SUCCESS ){
			/*|  FI_ACCEPT create CABLE_WORKING_DIR */
			sts = exp$create(exp_name = CABLE_WORKING_DIR,
					type_rq	 = EXP_TEXT,
					exp_syntax = me->work_dir,
					p_exp_id = &(tmp_obj.objid) );
		}
		else{	sts = exp$modify(exp_name = CABLE_WORKING_DIR,
					exp_syntax = me->work_dir );
		}
		/* ----------------------------------------------------------- */
		/*| reset working directory */
		/* ----------------------------------------------------------- */
		status = di$cd( dirname = act_path );
		if( status !=  DIR_S_SUCCESS ){
		  printf(" ERROR: cannot change dir to [%s]\n", act_path);
		  me->state = _terminate;
		  return( OM_I_STOP_SENDING );
		}

		ex$message( msgnumb = EMS_P_ClearPromptField );
		/*ex$message( msgnumb = EMS_M_ClearMessageField );*/
		ex$message( msgnumb = EMS_S_ClearStatusField );

		sts = FIf_erase( form_ptr );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIf_erase() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		_put_response( resp = TERMINATE );	/* exit from command object */

		break;
	
	case L_EQUIP_TAB :
	/*
	 * get the new equipment table name
	 */
		sts = FIg_get_text( form_ptr, gadget_label, me->equip_table );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_get_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		/*" equip_table <%s>\n", me->equip_table */
	/*
	 * test if file is in system
	 */
		if( me->equip_table[0] == '\0' ){
		  /*| name is required */
		  sprintf( err_msg, "%s", "Equipment Table has to be defined ");
   		  sts = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		  if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate; 
			return( OM_I_STOP_SENDING );
		  }
		  break;
		}

		if( me->equip_table[0] != '/' ){
		  /*| find full pathname */
		  strcpy( cur_dir, getenv("PWD"));
		  strcat( cur_dir, "/");
		  strcat( cur_dir, me->equip_table );
		  strcpy( me->equip_table, cur_dir );

		  /* show new string */
		  sts = FIg_set_text( form_ptr, L_EQUIP_TAB, me->equip_table );
		  if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts );
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		}

		if( access( me->equip_table, 04 ) != 0 ){
		  /* give error message */
		  sprintf( err_msg, "File <%s> does not exist", me->equip_table );
   		  sts = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		  if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		}
		break;

	case L_WORKING_DIR :
	/*
	 * get the new working directory
	 */
		sts = FIg_get_text( form_ptr, gadget_label, me->work_dir );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_get_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		/*" me->work_dir : <%s> \n", me->work_dir */
	/*
         * test current working directory
 	 */
		if( me->work_dir[0] != ':' ){
		/*
        	 * get current working directory
 		 */
		  strcpy( work_dir, me->home_dir );
		  strcat( work_dir, me->work_dir );
		  strcpy( me->work_dir, work_dir );
		}
		else{ 
		  /*" strlen : %d\n", strlen( me->home_dir ) */
		  /*" home_  : <%s>\n", me->home_dir */
		  /*" work_  : <%s>\n", me->work_dir */

		  len = strlen( me->home_dir );
		  /*" test:%d\n",strncmp(me->home_dir,me->work_dir,len) <= 0 */
		  if( ! strncmp( me->home_dir, me->work_dir, len ) <= 0 ){
		    /*| NOT accepted */
		    sprintf( err_msg," Working directory %s not allowed.", me->work_dir );
		    sts = FIg_set_text(	form_ptr, FI_MSG_FIELD,	err_msg );
		    if( sts != FI_SUCCESS ){	
			printf("\nCable Set Up Table: fct FIg_set_text() sts = %d\n", sts);
		  	me->state = _terminate;
			return( OM_I_STOP_SENDING );
		    }
		    strcpy( me->work_dir, me->home_dir );

   		    sts = FIg_set_text( form_ptr, gadget_label, me->work_dir );
		    if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		    }
		    break; 
		  }
		}

		/*
		 * test is new working directory exist
	 	 */
		/*" form me->work_dir ; <%s> \n", me->work_dir */
		tmp_obj.objid = NULL_OBJID;
		sts = di$translate( 	objname = me->work_dir,
					p_objid = &(tmp_obj.objid),
					p_osnum = &(tmp_obj.osnum) );

		if( sts != DIR_S_SUCCESS ){
		/*
		 * Directory probably not available in system; Ask to create
		 */
		  strcpy( err_msg, " Warning: Create New Subdirectory !! " );
		  sts = FIg_set_text(	form_ptr, FI_MSG_FIELD,	err_msg );
		  if( sts != FI_SUCCESS ){	
			printf("\nCable Set Up Table: fct FIg_set_text() sts = %d\n", sts);
		  	me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		}

   		sts = FIg_set_text( form_ptr, gadget_label, me->work_dir );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		break;

	case L_CABLE_FILE :
	/*
	 * get the new cable output file
	 */		
		sts = FIg_get_text( form_ptr, gadget_label, me->cable_file );
		if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_get_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		}
		/*" cable_file : <%s> \n", me->cable_file */
	/*
	 * test if file is in system
	 */
		if( access( me->cable_file, 04 ) == 0 ){
		/* 
		 * cable output file exist already; give message
		 */
		  strcpy( err_msg, "Warning!! Cable Output File already exists");
   		  sts = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		  if( sts != FI_SUCCESS ){
			printf("\nCable Set Up: fct FIg_set_text() sts = %d\n", sts);
			me->state = _terminate;
			return( OM_I_STOP_SENDING );
		  }
		}
		break;
	default:
		/*" not active gadget label : %d \n", gadget_label */
		break;

	} /* END switch ( gadget_label ) */

} /* END form_notification() */


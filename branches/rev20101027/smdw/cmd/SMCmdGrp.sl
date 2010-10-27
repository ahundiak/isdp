/* $Id: SMCmdGrp.sl,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdw/cmd / SMCmdGrp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdGrp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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

/****************************************************************************

	Filename:	SMCmdGrp.sl
	Author:		AD Zuurhout 
	Type:		Slic File
	Process by:	$EXNUC/bin/slic SMCmdGrp.sl
	Output:		SMCmdGrp.S  and SMCmdGrpi.I
	makemake file	SMcoppl.m -> makefile -> ../lib/SMDwght.o

	Description:

	  Slic file to produce methods, necessary for the user interface
	  for Loading groups for the Space Management Product.

	History:
	ADZ 	02-09-1992	Creation date
	ADZ	25-09-1992	Message_key was incorrect.
				Error message incorrect in SM_GRP_FILENAME
 
 ****************************************************************************/
		  
/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	SMC_M_LdGrp, 0, SMLdGr
class		SMCmdGrp
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"sman.cmd"
options		"SITC"

/* used forms */
form		"SMgrp",0,0,"-1","-1"

start_state	start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification
/*
  The Command Object will use the following instance for 
  creation of the "Create (Modify) Groups Command"

*/
#include "igrtypedef.h"
#include "SMdef.h"

instance
{
  IGRchar  Filename[MAX_CHAR_LINE];	/* Name fo file which contains the
					   Group values                   */
  IGRchar  Workdir[MAX_CHAR_LINE];	/* Name of location where the 
					   Group information will be
					   placed (saved) in the model.    */
  IGRint   Override;			/* Indicator for overriding of the	
					   existing values (yes/no)        */
}

/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "AS_status.h"		/* as$status 	*/
#include "vdsmacros.h"		/* vd$openfile	*/
#include "VDmsg.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "FI.h"			/* FI_...	*/

#include "DItypedef.h"		/* di$give_pathname */
#include "DIdef.h"
#include "DIprims.h"
#include "SMmsg.h"

#define	SMAN_GRP_FILENAME	13
#define SMAN_GRP_WORKDIR	15
#define SMAN_GRP_OVERRIDE	17

extern	int SMCrtGrp();


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "SMmsg.h"

state *
        on  EX_DATA.GRst_PERPEND_FROM                           state HaveError
        on  EX_DATA.GRst_ANGLE_FROM                             state HaveError
        on  EX_DATA.GRst_TANGENT_FROM                           state HaveError
        on  EX_DATA.GRst_PERPEND_TO                             state HaveError
        on  EX_DATA.GRst_ANGLE_TO                               state HaveError


state start

  message_key	SM_M_LdGrp
  prompt_key	SM_P_SfChForm
  filter	get_event

  on EX_FORM_FINISHED						state terminate 

state HaveError

  status_key	SM_E_InvData
  on ELSE							state -

at init do set_def

/************************************************************************/
/*	METHOD:	wakeup							*/
/************************************************************************/

action wakeup
{
  me->ret = MSSUCC;

  status =
  om$send(msg = message CEO_LOCATE.wakeup (pos),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status( action = RET_STATUS );

  /* set values in the form */
  FIg_set_text( me->forms[0].form_ptr, SMAN_GRP_FILENAME, me->Filename );
  FIg_set_text( me->forms[0].form_ptr, SMAN_GRP_WORKDIR, me->Workdir );
  FIg_set_state(me->forms[0].form_ptr, SMAN_GRP_OVERRIDE, me->Override );

  /* display the form */
  if ( me->forms[0].form_ptr )
    FIf_display( me->forms[0].form_ptr );
  else{
    ex$message( msgnumb = SM_E_FrmNtFnd, type = "%s", var = `"SMgrp"` );
    return( OM_E_ABORT );
  }
}

/************************************************************************/
/*	METHOD:	set_def							*/
/************************************************************************/

action set_def
{
FILE		*f_ptr;
IGRchar		dir_name[256];
GRspacenum	cur_os;
struct	GRid	dir;

  /*| check if default file exist */
  me->Filename[0] = '\0';
  me->Workdir[0]  = '\0';
  strcpy( me->Workdir , "group" );
  me->Override    = 0;
  f_ptr = NULL;
  vd$openfile(	file_name	= "Group",
		product_name	= "Vds",
		sub_path	= "config",
		cur_dir		= TRUE,
		p_file		= &f_ptr );
  if( f_ptr != NULL ){
    /* set default filename in form */
    strcpy( me->Filename, "Group" );
    strcpy( me->Workdir , "group" );
    /* test for override option */
    ex$get_cur_mod( osnum = &cur_os );
    dir_name[0] = '\0';
    di$give_pathname( osnum = cur_os, pathname = dir_name );
    strcat( dir_name,":usr:");
    strcat( dir_name, me->Workdir );

    dir.objid = NULL_OBJID;
    dir.osnum = cur_os;
    status = di$translate(	objname	= dir_name,
				p_objid = &dir.objid,
				p_osnum = &dir.osnum );
    if( status == DIR_S_SUCCESS && dir.objid != NULL_OBJID ){
      /* directory exist -> default Override = YES */
      me->Override = 1;
    }

    ex$message( msgnumb = VD_S_DefFile, type="%s", var = `me->Filename` );
  }
  else{
    ex$message( msgnumb = VD_S_NoDefFile, type="%s", var = `"Group"` );
  }

  if( f_ptr ) fclose ( f_ptr );

}

/************************************************************************/
/*	METHOD:	sleep							*/
/************************************************************************/

action sleep
{
IGRlong	msg;

  status =
  om$send(msg = message CEO_LOCATE.sleep(pos),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status( action = RET_STATUS );

  dp$erase_hilite( msg = &msg );
  UI_prompt("");
  UI_message("");
  UI_status("");
}


/************************************************************************/
/*	METHOD:	form_notification					*/
/************************************************************************/

action form_notification
{
FILE		*f_ptr;
IGRchar		my_text[256];
IGRchar		dir_name[256];
IGRchar		error[256];
GRspacenum	cur_os;
struct	GRid	dir;

  /* clear message field */
  FIg_set_text( form_ptr, FI_MSG_FIELD, "" );

  switch ( gadget_label )
  {
    case FI_ACCEPT :
	/* test the values before activation
	 */
	if( strlen(me->Filename ) == 0 ){
	  ex$message( msgnumb = SM_E_NoFileDef, buff = error );
	  FIg_set_text( form_ptr, FI_MSG_FIELD, error );
	  break;
	}

	ex$get_cur_mod( osnum = &cur_os );
	status = SMCrtGrp(	me->Filename,
				me->Workdir,
				me->Override,
				cur_os );
	if( ! status ){
	  UI_status(" Error encountered, restart command" );
	  break;
	}

	FIf_erase( form_ptr );
        _put_response( resp = EX_FORM_FINISHED );
	break;

    case FI_CANCEL :

	FIf_erase( form_ptr );
        _put_response( resp = EX_FORM_FINISHED );
	break;

    case SMAN_GRP_FILENAME :
	/* get the file with the dead weights values
	 */
	FIg_get_text( form_ptr, gadget_label, my_text );
	if( strlen( my_text ) == 0 ){
	  break;
	}

	if( strlen( my_text ) > MAX_CHAR_LINE - 1 ){
	  /* truncated the Filename */
	  my_text[MAX_CHAR_LINE-1] = '\0';
	  ex$message( msgnumb = SM_E_NameTrunc, buff = error );
	  FIg_set_text( form_ptr, FI_MSG_FIELD, error );
	}
	strcpy( me->Filename, my_text );

	f_ptr = NULL;
	vd$openfile(	file_name	= me->Filename,
			product_name	= "Vds",
			sub_path	= "config",
			cur_dir		= TRUE,
			p_file		= &f_ptr );
	if( f_ptr ) fclose( f_ptr );
	else{
	  ex$message( msgnumb = SM_E_FlNotFnd, type = "%s",
			var = `me->Filename`, buff = error );
	  FIg_set_text( form_ptr, FI_MSG_FIELD, error );
	}
	
	break;

    case SMAN_GRP_WORKDIR :
	/* get the name of the working directory and 
	   test of existance
	 */
	FIg_get_text( form_ptr, gadget_label, my_text );

	me->Override = 0;
	if( my_text[0] != '\0' ){
	  
	  if( strlen( my_text ) > MAX_CHAR_LINE - 1 ){
	    /* truncated the filename */
	    my_text[MAX_CHAR_LINE-1] = '\0';
	    ex$message( msgnumb = SM_E_NameTrunc, buff = error );
	    FIg_set_text( form_ptr, FI_MSG_FIELD, error );
	  }
	  strcpy( me->Workdir, my_text );

	  /* test for Override option */
	  ex$get_cur_mod( osnum = &cur_os );
	  dir_name[0] = '\0';
	  di$give_pathname( osnum = cur_os, pathname = dir_name );
	  strcat( dir_name,":usr:");
	  strcat( dir_name, me->Workdir );

	  dir.objid = NULL_OBJID;
	  dir.osnum = cur_os;
	  status = di$translate(	objname	= dir_name,
					p_objid = &dir.objid,
					p_osnum = &dir.osnum );
	  if( status == DIR_S_SUCCESS && dir.objid != NULL_OBJID ){
	    /* directory exist -> default Override = YES */
	    me->Override = 1;
	  }
	}
	FIg_set_state( form_ptr, SMAN_GRP_OVERRIDE, me->Override );

	if( me->Override ){
	  ex$message( msgnumb = SM_E_DirExist, buff = error );
	}
	else{
	  ex$message( msgnumb = SM_E_DirNew, buff = error );
	}
	FIg_set_text( form_ptr, FI_MSG_FIELD, error );

	break;

    case SMAN_GRP_OVERRIDE :
	/* in case the working directory exist,
	   the dead weights tables can be modified
         */ 
	FIg_get_state( form_ptr, gadget_label, &me->Override );
	
	/* test if Override option is permitted 
	 */
	ex$get_cur_mod( osnum = &cur_os );
	dir_name[0] = '\0';
	di$give_pathname( osnum = cur_os, pathname = dir_name );
	strcat( dir_name,":usr:");
	strcat( dir_name, me->Workdir );

	dir.objid = NULL_OBJID;
	dir.osnum = cur_os;
	status = di$translate(	objname	= dir_name,
				p_objid = &dir.objid,
				p_osnum = &dir.osnum );
	if( status != DIR_S_SUCCESS ){
	  if( me->Override ){
	    me->Override = 0;
	    FIg_set_state( form_ptr, gadget_label, me->Override );
	    ex$message( msgnumb = SM_E_OverNtPos, buff = error );
	    FIg_set_text( form_ptr, FI_MSG_FIELD, error );
	  }
	}
	break;

    default:

	/* Invalid gadget label selected */
        printf("Invalid gadget : %d\n", gadget_label );
  }
}


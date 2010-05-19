/* $Id: SMCmdFit.sl,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smfit/cmd / SMCmdFit.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdFit.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/11/20  14:40:04  pinnacle
# ah
#
# Revision 1.3  1997/11/06  12:46:22  pinnacle
# Replaced: smfit/cmd/SMCmdFit.sl for:  by vgnair for vds
#
# Revision 1.2  1997/09/12  04:50:48  pinnacle
# Replaced: smfit/cmd/SMCmdFit.sl for:  by vgnair for vds
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
 *	09/12/97	vini		Added the method to fit objects by 
 *					inputing the id and the osnum of the
 *					object.
 *	11/20/97	ah		Needed to add grmacros.h
 *					to get it to compile
 * -------------------------------------------------------------------*/
/*
 *
 *	Filename:	SMCmdFit.sl
 *	Author:		Ad Zuurhout
 *
 *	Date:		Jan 1993
 *	Type:		Slic File ; Comamnd Object
 *	Process by:	$EXNUC/bin/slic -ISCT SMCmdFit.sl
 *
 *	Description:
 *
 *	  Slic file to produce a command object to fit a compartment
 *	  object in a view.
 *	  Also the class .S and class -i.I are created.
 *	
 *	  This command locates a object of the class compartment and fits
 *	  the compartment volume in the specified view of all the views.
 *
 *	History:
 *	Jan	1993	Creation date.
 *
 */

/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string          SMC_M_CmpFit, SMFIT_COMP_TYPE, SMFitCmp
synonym			SMC_M_ObjFit, SMFIT_OBJECT_TYPE, SMFitObj
synonym			SMC_M_FitObjId, 2, SMFitObjId
command_table		"sman.cmd"
product_name		"$VDS"
class			"SMCmdFit"
super_class		"VDS_LOCATE"
options			"SITC"

start_state       	fit_locate

/************************************************************************/
/*	SPECIFICTION SECTION						*/
/************************************************************************/

specification

#include "dpfile.h"
#define		InValObjSel		3015 


instance 
{
	struct	GRevent	obj_event;	/* selected object		*/

	IGRint	num_ggid ;	/* number of view gragads selected	*/

	struct	GRid	ggid[MAX_WINDOW];
				/* maximum available window gragags	*/
	struct  GRid	object; /* the objid and osnum input */

}

/************************************************************************/
/*	IMPLEMENTATION SECTION						*/
/************************************************************************/

implementation

#include <string.h>
#include <stdio.h>
#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "msdef.h"
#include "msmacros.h"

#include "grmacros.h"

#include "vdsmacros.h"
#include "SMmsg.h"
#include "AS_status.h"

/*
 * view name length
 */
#define 	NAME_LENG		20
#define		SMFIT_COMP_TYPE		0
#define		SMFIT_OBJECT_TYPE	1
#define		SMFIT_OBJID_TYPE	2

from	NDmacro		import 	ACreturn_foot;


/************************************************************************/
/*	STATE TABLE							*/
/************************************************************************/

state_table

#include 	"grmessage.h"
#include 	"codpdef.h"
#include 	"dpdef.h"
#include	"SMmsg.h"
#include	"VDSFilter.h"

#define		SMFIT_COMP_TYPE		0
#define		SMFIT_OBJECT_TYPE	1
#define		SMFIT_OBJID_TYPE	2
#define		InValObjSel		3015 



state *
	on EX_RESTART						state fit_locate
	on EX_BACKUP						state -

at  wakeup  do  wakeup_act
at  sleep   do  sleep_act

/*****************/
state	fit_locate
/*****************/

  on CMD_TYPE = 0						state fit_SMcomp
  on CMD_TYPE = 1						state fit_object
  on CMD_TYPE = 2						state fit_objid


/*****************/
state	fit_SMcomp
/*****************/

   message_key		SM_M_CmpFit
   prompt_key           SM_P_ScLocComp
   locate_class         "SMcomp"

   locate_display       " ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          ALL_WINDOWS  | LC_ERASE_ALL "
   locate_owner         " LC_FLEX_COMP | LC_REF_OBJECTS | LC_RIGID_COMP"
   locate_properties    " LC_DP_ONLY | LC_LC_ONLY "
   accept_key           SM_P_AcRes
   mask                 " GRm_DATA | GRm_RJT_MOVEON | GRm_STRING "
   filter               vds_locate

   on EX_DATA or EX_STRING
	do get_object
		on SUCCESS					state fit
    								state fit_locate

   on EX_RJT_MOVEON						state terminate


/*****************/
state	fit_object
/*****************/

   message_key		SM_M_ObjFit
   prompt_key           SM_P_LocObj
   locate_class         "GRvg" 

   locate_display       " ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          ALL_WINDOWS  | LC_ERASE_ALL "
   locate_owner         " LC_FLEX_COMP | LC_REF_OBJECTS | LC_RIGID_COMP "
   locate_properties    " LC_DP_ONLY | LC_LC_ONLY "
   accept_key           SM_P_AcRes
   mask                 " GRm_DATA | GRm_RJT_MOVEON | GRm_STRING "
   filter               vds_locate

   on EX_DATA or EX_STRING
	do get_object
		on SUCCESS					state fit
    								state fit_locate

   on EX_RJT_MOVEON						state terminate


/**********/
state	fit
/**********/

   prompt_key		GR_P_IdWinMoveOn
   filter		get_event

   on EX_DATA or TEXT_VALUE 
	do getGragad( ALL_GG_CLASSES | GG_WIN_ON )
		on SUCCESS do objectfit
				on SUCCESS 		 	state fit 
				on InValObjSel 			state fit_objid
								state fit_locate
		on InvInp 					state fit
								state fit_locate

   on EX_RJT_MOVEON
	do getAllGragad( ALL_GG_CLASSES | GG_WIN_ON )
	     on SUCCESS do objectfit
				on SUCCESS			state terminate
				on InValObjSel 			state fit_objid
								state fit_locate
		on InvInp 					state fit 
								state fit_locate

   on EX_BACKUP	do status "EX_BACKUP"				state fit_locate

/**************/
state  fit_objid
/**************/

   prompt 		"Give objid"
   mask 		"GRm_STRING"
   filter		get_event

   on EX_STRING
	do get_objid
		on SUCCESS					state fit_osnum
		on InvInp 					state .
								state fit_locate

   on EX_BACKUP							state fit_locate

/*************/
state  fit_osnum
/*************/

   prompt 		"Give osnum"
   mask			"GRm_STRING"
   filter 		get_event

   on EX_STRING 
	do get_osnum
		on SUCCESS   do status " "			state accept
		on InvInp 					state fit_objid
								state fit_locate

   on EX_BACKUP							state fit_locate


/************/
state  accept
/************/

        prompt          "Accept/Reject"
        filter          get_event

        on EX_DATA                                              state fit

        on EX_RJT_MOVEON do sleep_act                           state fit_locate


/************************************************************************/
/*	IMPLEMENTATION METHODS						*/
/************************************************************************/

action wakeup_act
{
  /*
   * print the message name,
   */
  switch( me->mytype ){
    case 0:	ex$message( msgnumb = SM_M_CmpFit ); 		break;
    case 1:	ex$message( msgnumb = SM_M_ObjFit ); 		break;
    case 2:	ex$message( msgnumb = SM_M_FitObjId );		break;

    default:	ex$message( msgnumb = SM_M_ObjFit ); 		break;
  }

  status = OM_S_SUCCESS;
goto quit;
}

/************************************************************************/
action sleep_act
{
IGRlong	msg;
  /*
   * erase the object hilited
   */
  dp$erase_hilite( msg = &msg );

  status = OM_S_SUCCESS;
goto quit;
}


/************************************************************************/
action get_object
{
GRclassid	classid;

  /*
   * get the event.
   */
  me->obj_event = me->event1;

  /*
   * check if the event is not of type GRpoint.
   * only in the command "Fit Object"
   */
  if( me->mytype == SMFIT_OBJECT_TYPE ) {
    status = om$get_classid(
	osnum     = me->obj_event.located_object[0].located_obj.osnum,
	objid     = me->obj_event.located_object[0].located_obj.objid,
	p_classid = &classid );

    if( ! (1&status) ) {
      printf(" get_object: om$get_classid for SMCmdFit failed\n");
      me->ret = SrchFlt ;
      goto quit ;
    }

    if( om$is_ancestry_valid(
			subclassid     = classid,
			superclassname = "GRpoint" ) == OM_S_SUCCESS ){

      ex$message( field = ERROR_FIELD, 
		  in_buff = " Invalid object selected " );
      me->ret = InvInp ;
      goto quit ;
    }
  }

  status = OM_S_SUCCESS ;
}


/************************************************************************/

action getGragad( IGRint type_gragad )
{
IGRlong		msg;
GRclassid	classid;

  me->ret = OM_S_SUCCESS;

  if( strlen( me->event1.event.keyin ) > NAME_LENG )
  {
	me->event1.event.keyin[NAME_LENG-1] = '\0';
  }

  switch( me->event1.response ) {

    case EX_DATA :

	me->num_ggid = 1;
	me->ggid[0].osnum = me->event1.event.button.osnum;
	me->ggid[0].objid = me->event1.event.button.objid;

      break;

    case EX_STRING :

	/*
	 * check for string length and quit if neccessary
	 */
	if ( ! strlen( me->event1.event.keyin ) ) {
	  ex$message ( msgnumb = GR_E_AmbNme);
	  me->ret = SrchFlt;
          goto quit;
	}

	/*
	 * check if name exists
	 */
	me->num_ggid = 0;
	status =
	dp$get_gragad_id(msg = &msg,
			name = me->event1.event.keyin,
			array_size = MAX_WINDOW,
			numberofids = &me->num_ggid, 
			found_GRids = me->ggid,
			type_gragad= type_gragad);

	/*
	 * Display appr. error messages  & set the "action return code"
	 * ( checking for existing windows succeeds if num_ggid = 1 or > 1 )
	 */
	if ( me->num_ggid == 0) {
		ex$message ( msgnumb = GR_E_WinNotFnd);
		me->ret = SrchFlt;
		goto quit;
	}
	else if(me->num_ggid > 1) {
		/*
		 * Error only if searching for one window.
		 * Command can't proceed if more then one window 
                 * is returned
		 */
		if( MAX_WINDOW == 1 ) {
	            ex$message ( msgnumb = GR_E_AmbNme);
		    me->ret = SrchFlt;
		    goto quit;
		}
	} 
     break ;
  } /* end of switch  */


  status = om$get_classid( 	osnum     = me->ggid[0].osnum,
				objid     = me->ggid[0].objid,
				p_classid = &classid );

  if( ! (1&status) ) {
    printf(" get_object: om$get_classid for VDCmdFit failed\n");
    me->ret = FunFail ;
    goto quit ;
  }

  if( om$is_ancestry_valid(
			subclassid     = classid,
			superclassname = "VDggxyGrid" ) == OM_S_SUCCESS ){

    ex$message( field = ERROR_FIELD, 
		in_buff = " Not a principal view " );
    me->ret = InvInp ;
    goto quit ;
  }


  status = OM_S_SUCCESS ;

}

/************************************************************************/
action getAllGragad( IGRint type_gragad )
{
IGRlong	msg;
IGRchar	str_name[20];

  me->ret = OM_S_SUCCESS;

  /* check if name exists */

  me->num_ggid = 0;
  strcpy(str_name, "*");

  status = 
  dp$get_gragad_id(	msg         = &msg,
			name        = str_name,
			array_size  = MAX_WINDOW,
			numberofids = &me->num_ggid, 
			found_GRids = me->ggid,
			type_gragad = type_gragad);

  /*
   * Display appr. error messages  & set the "action return code"
   */
  if ( me->num_ggid == 0) {
    ex$message ( msgnumb = GR_E_WinNotFnd);
    me->ret = SrchFlt;
    goto quit;
  }

  status = OM_S_SUCCESS ;
}

/***********************************************************************/

action get_objid
{
   int Obj_id;

   Obj_id = NULL_OBJID;

   Obj_id = atoi( me->event1.event.keyin );
   me->object.objid = Obj_id;
}

/***********************************************************************/

action  get_osnum
{
   int Os;
   GRclassid       classid;

   Os = atoi(me->event1.event.keyin);
   me->object.osnum = Os;

	/*
	 * Check If the object is valid
	 */
 
   if(!(om$is_objid_valid(osnum=Os, objid=me->object.objid )== OM_S_SUCCESS )){ 
	ex$message( field = ERROR_FIELD,
        	    in_buff = " Invalid object selected " );
	me->ret = InvInp ;
	goto quit ;
   }
   status = om$get_classid( osnum     = me->object.osnum,
        		    objid     = me->object.objid,
  			    p_classid = &classid );

    if( om$is_ancestry_valid( subclassid     = classid,
              		      superclassname = "GRpoint" ) == OM_S_SUCCESS ){
         ex$message( field = ERROR_FIELD,
                     in_buff = " Invalid object selected " );
         me->ret = InvInp ;
         goto quit ;
    }

    if(!( om$is_ancestry_valid( subclassid     = classid,
               			superclassname = "GRvg" ) == OM_S_SUCCESS )){
         ex$message( field = ERROR_FIELD,
                     in_buff = " Invalid object selected " );
         me->ret = InvInp ;
         goto quit;
    }
    else   gr$display_object ( object_id = &me->object , mode = GRhd );
}

/************************************************************************/
action objectfit
{
struct	GRmd_env obj_env;

char s[80];
	 /*
	 * Check the command type
	 */

      if ( me->mytype !=2 ) {
	obj_env.md_id  = me->ModuleInfo.md_id ;
	obj_env.md_env = me->obj_event.located_object[0].module_info.md_env ;

	status = 
	vd$vw_fit_object(object	= &me->obj_event.located_object[0].located_obj,
			md_env	= &obj_env,
			ggid	= me->ggid,
			num_ggid= me->num_ggid );

	as$status( action = RET_STATUS );
	status = OM_S_SUCCESS;
	goto quit;
      } 

     else {
	status = vd$vw_fit_object(   object  = &me->object,
                                    ggid    = me->ggid,
                                     num_ggid= me->num_ggid );

	if (!(status&1 )) {
	    sprintf(s,"Invalid Object Selected ");
	    UI_status(s);
	    me->ret = InValObjSel; 
	    goto quit;
        }

	as$status( action = RET_STATUS ) 
	status = OM_S_SUCCESS;
	goto quit;
     }
}

/************************************************************************/
/************************************************************************/

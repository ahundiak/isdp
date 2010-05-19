/* $Id: SMCmdPlMdFr.sl,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/cmd / SMCmdPlMdFr.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdPlMdFr.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/02  09:10:36  pinnacle
# Replaced: smframe/cmd/SMCmdPlMdFr.sl for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/07  22:35:34  pinnacle
# Replaced: ./smframe/cmd/SMCmdPlMdFr.sl for:  by azuurhou for vds.240
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
 *	11/07/95	adz		TR #179423889 ; Locate of F.S. when 
 *					relocating c.s.
 *      12/02/97        Sundar          Changed instance & method reinit_all
 *					for the CR:179309743.
 *	
 * -------------------------------------------------------------------*/

/*    File          SMCmdPlMdFr.sl
      Description   Command object for place or modify frame system
      Auteur        Jean Jasinczuk (ISDC) 
      Date          26-12-91     
*/

command_string       SMC_M_FrPl,0,SMPlPlSs
synonym              SMC_M_FrMod,1,SMMdPlSsPr  
command_table        "sman.cmd"
class                SMCmdPlMdFr
super_class          VDS_LOCATE
product_name         "$VDS"

form "SMFrm",0,0,0,0
form "SMFrmSect",1,0,0,0
form "SMFrmNms",2,0,0,0

specification

#include <stdio.h>

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "csmacros.h"
/* #include "tools.h" * Not Required  --  AA */
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "FI.h"
#include "ACrg_collect.h"
#include "v_dbgmacros.h"
#include "SMframe.h"

#include "SMmsg.h"

instance 
{
  struct main_param_buffer param_buf;
  struct main_param_buffer old_param_buf;
  int new_nb_sect;	      	/* the number of sections, current */
  int old_nb_sect;       	/* When enter in the section form */
  int new_nb_nm_sect;           /* the number of name sections, current */
  int old_nb_nm_sect;           /* When enter in the name form */
  int first_nb_sect;         	/* When first enter               */
  
  int xsec,ysec;  		/* Position for form section */

  int first_nb_frame;           /* nb_frame when enter MODIFY */ 
  struct GRid list[4];          /* Information for old frame if MODIFY */
  struct frame_def first_frame; /* old buffer when MODIFY */
	
	
  short  is_def_num[NB_MAX_SECTION]; /* sections defined by number */
  short  is_def_name[NB_MAX_SECTION]; /* name sections defined */
  short  is_def_dist[NB_MAX_SECTION]; /* sections defined by distance */ 
	
  struct sect_info     first_sect_info[NB_MAX_SECTION]; /* When enter modify */
  struct sect_info     old_sect_info[NB_MAX_SECTION];   /* When enter form sect*/
  struct sect_info     new_sect_info[NB_MAX_SECTION];   /* Current */

  struct nm_sect_info     first_nm_sect_info[NB_MAX_SECTION]; /* When enter modify */
  struct nm_sect_info     new_nm_sect_info[NB_MAX_SECTION];   /* Current */
  struct nm_sect_info     old_nm_sect_info[NB_MAX_SECTION];   /* When enter form name */
	
  struct sect_dist     sect_dist[NB_MAX_SECTION];   /* The section defined by distances */
  /* Buffer for the rev and reinf string */
  struct frame_str     first_frame_str; /* When enter modify */ 
  struct frame_str     old_frame_str;  /*  When enter form sect */ 

  char sect_unit[ATTR_TXT]; /* Unit we are working when section form displayed */
  struct GRid   owner; /* The ACdiowner which represent frame system */

  IGRint	owner_loc_off ;
}

implementation

#define AS_DEBUG	1

#include "AS_status.h"
#include "SMmsg.h"

from	GRvg		import 	GRchgprops;

/*************************************************************************/

state_table

#define PLACE			0
#define MODIFY			1
#define TRUE			1
#define FALSE			0

#define	NEXT			505  
#define COORDINATE		506
#define MY_ERROR		507
#define LOADC			508
#define ERASE_SECTION		509
#define DISPLAY_SECTION		510
#define OLD_FRAME_SYSTEM	511
#define RELOCATE_FRAME		512

#include "SMmsg.h"
#include "VDSFilter.h"

state start

  erase_form    0
  erase_form    1

  on CMD_TYPE = PLACE					state form_modify
  on CMD_TYPE = MODIFY					state frame_locate  
  
state frame_locate

    erase_form    0
    erase_form    1 

    message_key            SM_M_FrModify
    prompt_key             SM_P_FrLocate
    accept_key             SM_P_FrAccRej
    locate_class           "SMfrm_syst" 
    locate_owner           "LC_RIGID_COMP | LC_RIGID_OWNER |
                            LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"    
    filter                 vds_locate	
    
    on EX_DATA or EX_STRING
	do control_frame
		on RETURN_CODE = MY_ERROR 
                   do status_key  SM_I_FrLocate		state .
                on RETURN_CODE = OLD_FRAME_SYSTEM
         	   do status_key SM_I_UpdFrSyst		state terminate    
                on ERROR				state terminate
							state form_modify
                                          
state form_modify

    display_form  0
    erase_form    1

    on CMD_TYPE = PLACE
   	do message_key SM_M_FrPlace			state bis_form_modify
    on CMD_TYPE = MODIFY
	do message_key SM_M_FrModify			state bis_form_modify

state bis_form_modify

    display_form	0
    erase_form		1
    prompt_key		SM_P_FrPlMd
    dynamics		off
    filter		get_event

   on GR_UNKNOWN_TYPE.COORDINATE			state query_coord
   on GR_UNKNOWN_TYPE.LOADC				state load_comp 
   on GR_UNKNOWN_TYPE.DISPLAY_SECTION			state form_section
   on GR_UNKNOWN_TYPE.RELOCATE_FRAME			state frame_locate

state form_section

    display_form	1
    prompt_key		SM_P_FrPlMd
    dynamics		off
    filter		get_event

    on GR_UNKNOWN_TYPE.ERASE_SECTION			state form_modify

state load_comp

    display_form	0                                            
    message_key		SM_M_FrPlace
    prompt_key		SM_P_FrLocate
    accept_key		SM_P_FrAccRej
    locate_class	"SMfrm_syst"
    filter		vds_locate	
    
    on EX_DATA or EX_STRING
	do control_frame
           on RETURN_CODE = MY_ERROR 
              do status_key  SM_I_FrLocate		state .
           on ERROR					state terminate
							state form_modify

    on EX_BACK_UP
	do make_selectable 				state form_modify
    
state query_coord

    execute		frame_loc_off
    display_form	0
    prompt_key		SM_P_FrCoord
    dynamics		off
    accept_key          SM_P_FrAccRej    
    locate_eligible     "+EMSplane,GRgencs"
    locate_owner        "LC_RIGID_COMP | LC_RIGID_OWNER |
                        LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
    filter		vds_locate_noauto

    on EX_DATA or EX_STRING
	do coord_syst
	do frame_loc_on					state form_modify            
    on EX_BACK_UP
	do make_selectable
	do frame_loc_on					state form_modify

at	wakeup	do wakeup_frame_loc
at	sleep	do form_sleep
		do sleep_frame_loc
at	delete	do form_delete

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern

action SMSetNmFrm (IGRchar *NmFrm) extern

action SMReSetNmFrm (IGRchar *NmFrm; IGRint button) extern

action SMProcFrmNmFld( IGRchar *NmFrm ) extern

action init_names(  long *sts; int type_init) extern

action control_frame extern 

action init_sections(  long *sts; int type_init) extern

action refresh_main_form extern

action init_param_buf( long *sts; int type_init) extern

action coord_syst extern

action make_selectable extern

action save_all extern
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action init
{
  long   msg;

  status     = om$send(msg = message CEO_LOCATE.init( type, str_ptr ), 
		       targetid = my_id,
		       mode     = OM_e_wrt_message);
		      
  as$status( action = RET_STATUS );
  me->xsec = me->ysec = -1;
  
  if(me->mytype == PLACE)
   {
     om$send(msg = message SMCmdPlMdFr.reinit_all(&msg,PLACE),targetid = my_id);
     if(!(msg & 1)) goto wrapup;
   }

  /*
   * IN the mode MODIFY, we turn the locate of the selected frame system.
   * this is done to avoid internal dependencies.
   */
  me->owner_loc_off = FALSE ;

 goto quit;

 wrapup:
  me->state = _terminate;
  return ( OM_I_STOP_SENDING ); 
}

/* Jean : 24 June 93 . New method to reinit the form                         */
/* This method reinit all : param_buf, section and main_form                 */ 
/* type_init is PLACE or MODIFY (not read with me->mytype because can be     */
/* used in a place command as if it's a modify (i.e in load_from_componant)  */

action reinit_all(long *sts;int type_init)
{
  IGRlong msg;
  
  /* Init the parameter for main form  */ 
  status = om$send(msg = message SMCmdPlMdFr.init_param_buf(&msg,type_init),
		   targetid = my_id);
  if(!(status & msg & 1))
   {
     printf("error init_parameter %d\n",status); 
     goto wrapup;
   } 
     
  /* Init the array for the names */
  status = om$send(msg = message SMCmdPlMdFr.init_names(&msg,type_init),
                   targetid = my_id);
  if(!(status & msg & 1))
   {
     printf("error init_parameter");
     goto wrapup;
   }

  /* Init the array for the sections */   
  status = om$send(msg = message SMCmdPlMdFr.init_sections(&msg,type_init),
		   targetid = my_id);
  if(!(status & msg & 1))
   {
     printf("error init_parameter");
     goto wrapup;      
   }

  status = om$send(msg = message SMCmdPlMdFr.refresh_main_form(&msg),
		   targetid = my_id);
  if(!(status & msg & 1))
   {
     printf("Problem displaying main form\n"); 
     goto wrapup;
   } 

  *sts = OM_S_SUCCESS;
  goto quit;

 wrapup:
  *sts = OM_E_ABORT;
}

action form_sleep
{
        dp$erase_hilite(msg = sts);
}

action form_delete 
{
       dp$erase_hilite(msg = sts);
}

action	frame_loc_off
{
	IGRshort	set = 0;
	IGRshort	properties = GRIS_LOCATABLE ;

	SetProc( CMD_frame_loc_off ); Begin

  	if( me->mytype == MODIFY ){
	  status =
	  om$send(msg = message GRvg.GRchgprops(sts,&set,&properties),
		  targetid = me->owner.objid ,
		  targetos = me->owner.osnum );
	  me->owner_loc_off = TRUE ;
	}

	End
}
		
action	frame_loc_on
{
	IGRshort	set = 1;
	IGRshort	properties = GRIS_LOCATABLE ;

	SetProc( CMD_frame_loc_on ); Begin

  	if( me->mytype == MODIFY ){
	  status =
	  om$send(msg = message GRvg.GRchgprops(sts,&set,&properties),
		targetid = me->owner.objid ,
		targetos = me->owner.osnum );
	  me->owner_loc_off = FALSE ;
	}
	End
}

action	wakeup_frame_loc
{
	IGRshort	set = 0;
	IGRshort	properties = GRIS_LOCATABLE ;

	SetProc( CMD_wakeup_frame_loc ); Begin

  	if( me->mytype == MODIFY ){
	  if( me->owner_loc_off == TRUE ){
	    status =
	    om$send(msg = message GRvg.GRchgprops(sts,&set,&properties),
		    targetid = me->owner.objid ,
		    targetos = me->owner.osnum );
	  }
	}

	End
}

action	sleep_frame_loc
{
	IGRshort	set = 1;
	IGRshort	properties = GRIS_LOCATABLE ;

	SetProc( CMD_sleep_frame_loc ); Begin

  	if( me->mytype == MODIFY ){
	  if( me->owner_loc_off == TRUE ){
	    status =
	    om$send(msg = message GRvg.GRchgprops(sts,&set,&properties),
		    targetid = me->owner.objid ,
		    targetos = me->owner.osnum );
	  }
	}

	End
}


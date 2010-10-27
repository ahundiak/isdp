/* $Id: VDCmdHllDbg.sl,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdhulldbg/cmd / VDCmdHllDbg.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdHllDbg.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
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

/*    
   File :		VDCmdHllDbg.sl
   Author :		Alain CLAUDE
   Revision date :	93/02/23

   Description :	Command object to Debug In a Hull

   The operations are the following :
		- Read the file (Debug In format)
		- Make the composite surface
		- Ask for a mirror-copy operation on the composite surface
		  along the x-axis of the Ship coordinate system (or of
		  the active coordinate system if no CS is defined), and
		  make another make composite surface
		- Give a name		

   Note : there are 3 types of c.s.
	- Ship coordinate system   (checked during init method)
	- Active coordinate system (if no s.c.s. has been defined,
                                   also checked during init method)
	- Located c.s. (see get_coord_sys method triggered by button c.s.)

   History :
	93/02/03	Initial release
	93/02/05	Update get_coord_sys action
	93/02/23	Add call to VDis_ascii_file()
	93/03/04        Jean: Change way to retrieve active CS.
*/


command_string      VDC_M_DgInHl, 0, VDDgInHl
class               VDCmdHllDbg
command_table       "vds.cmd"
super_class         VDS_LOCATE
product_name        "$VDS"
options             "SITC"

form "VDDbgHull", 0, 0, "-1", "-1"

specification

#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "FI.h"

#include "VDmsg.h"
#include "VDCmdHull.h"  /* Our form constants */

#define NUM_OBJ	100	/* Allocate memory by blocks of 100 objids */

instance
{
   char		FileName[GR_MAX_CHAR] ;  /* Debug In format file */
   FILE		*file_ptr ;

   char		hull_name[DI_PATH_MAX] ; /* Name of the hull  */
   GRobjid	hull_id ;	         /* Ship Hull         */

   struct GRid	cs_id ;
   char		cs_name[GR_MAX_CHAR] ;
   IGRboolean	mirror_copy_flag ; 	 /* Optional */

   long		cst_msg ;
   struct GRvg_construct cst ;
}

/*
	Implementation
 */

implementation

from GRgraphics  import	GRconstruct, GRcopy, GRxform, GRdisplay, GRdelete ;
from GRgraphics  import	GRgetname, GRputname ;
from EMSsfstitch import	EMmake_comp ;
from GRgencs	 import GRgetmatrix ;
extern 			GRcsget_active_info() ;
extern long		SMGetActCs()    ; /* see $VDS/SMutil/SMActObj.I */
extern 			EFfreadGeom() ;
extern IGRboolean 	MAinvmx(), MAmulmx(), MAtypemx() ;
extern			DPerase_hilite()  ;
extern int		VDis_ascii_file() ;

%safe
  static int x_pos = -1, y_pos = -1 ;
%endsafe

/* ------------------------------------------------------------------
                        Utilities functions
   ------------------------------------------------------------------ */


static int VDstrip_blanks(output, input)
	char input[], output[] ;
/*
   Description : this function strips the leading and trailing blanks of 
	a string
 */
{
int		i, len ;
char		buffer[BUFSIZ] ;

for (i = 0 ; isspace(input[i]) ; i++) ;
strcpy(buffer, &input[i]) ;

if ((strrchr(buffer, ' ') != NULL) || (strrchr(buffer, '\t') != NULL)){
	len = strlen(buffer)  ;
	for (i = len - 1 ; (isspace(buffer[i])) && (i >= 0) ; i--) ;
	if (i != (len - 1)) { buffer[i+1] = '\0' ; }
	}

strcpy(output, buffer) ;
return OM_S_SUCCESS ;

} /* VDstrip_blanks() */


/*  ------------------------------------------------------------------ */


static int VDget_cs_name(msg, cs_id, cs_name)
   long                         *msg ;                  /* O */
   struct GRid			*cs_id ;		/* I */
   char				cs_name[] ;		/* O */
/*
	Description : get coordinate system name
 */
{
long	status ;
char	name[GR_MAX_CHAR], *aux ;

status = om$send(	msg = message GRgraphics.GRgetname(msg, name),
                	senderid = NULL_OBJID,
          		targetid = cs_id->objid,
			targetos = cs_id->osnum) ; 
if (! (status & *msg & 1)) { 
	status = OM_E_ABORT ; as$status() ; goto wrapup ;
	}

aux = strrchr(name, ':') ;
if (aux) {
	aux ++ ; strcpy(cs_name, aux) ;
	}
else {
	strcpy(cs_name, name) ;
	}

wrapup:
return status ;
} /* VDget_cs_name() */


/*  ------------------------------------------------------------------ */


static int VDmake_comp(msg, surf_list, num_surf, construct_list, composite)
   long                         *msg ;                  /* O */
   GRobjid                      *surf_list ;            /* I */
   IGRint                       num_surf ;              /* I */
   struct GRvg_construct        *construct_list ;       /* I */
   GRobjid                      *composite ;            /* O */
/*
   Description : this function constructs a composite surface (EMSsfstitch)
 */
{
long			status ;
extern GRclassid	OPP_EMSsfstitch_class_id ;

status = om$construct(  classid = OPP_EMSsfstitch_class_id,
                p_objid = composite,
                osnum   = construct_list->env_info->md_id.osnum,
                msg     = message GRgraphics.GRconstruct(construct_list)) ;
as$status() ; 
if (! (status & 1)) { *msg = MSFAIL ; *composite = NULL_OBJID ; goto wrapup ; }

status = om$send(msg = message EMSsfstitch.EMmake_comp(
                        msg,
                        num_surf,
                        surf_list,
                        construct_list->env_info,
                        NULL, NULL, NULL, NULL, NULL),
                senderid = NULL_OBJID,
                targetid = *composite,
                targetos = construct_list->env_info->md_id.osnum) ;
as$status() ; if (! (status & 1)) *msg = EMS_I_Fail ;

if (*msg != EMS_S_Success) {

	/* Composite surface can not be made */
	if (*msg == EMS_I_Fail) { ex$message(msgnumb = EMS_I_00090) ; }
	else { status = OM_E_ABORT ; as$status() ; }

	/* Delete composite object */
	status = om$send(msg = message GRgraphics.GRdelete
				(msg, construct_list->env_info),
			senderid = NULL_OBJID,
			targetid = *composite,
			targetos = construct_list->env_info->md_id.osnum) ; 
	as$status() ;
	*composite = NULL_OBJID ;
	status = OM_E_ABORT ; *msg = MSFAIL ; /* because EMS_I_Fail is odd */
	goto wrapup ;
	} /* error case */

wrapup :
return status ;

} /* VDmake_comp() */


/* ------------------------------------------------------------------
                        State table
   ------------------------------------------------------------------ */


state_table

#include "VDmsg.h"
#include "VDCmdHull.h"

state start		/* Ask for file name         */
			/* Debug In + Make Composite */
	display_form 0
        message_key	VD_M_DgInHl
        prompt_key	VD_P_DgEntPmFm
        dynamics        0
        mask            "GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP"
        filter          get_event

        on EX_RJT_MOVEON or GR_UNKNOWN_TYPE.CANCEL_DBG
		state terminate

        on EX_BACK_UP or GR_UNKNOWN_TYPE.RESET_DBG
		do reset_form					state .

        on NULL_STRING						state .

	on GR_UNKNOWN_TYPE.ASK_CS
		do disable_gadgets				state st_cs

	on GR_UNKNOWN_TYPE.EXEC_DBG
		do read_form		/* Get form parameters */
		   on ERROR					state .
		do read_file		/* Debug In + Make Composite */
		   on ERROR					state .
		do mirror_copy
		   on ERROR					state .
		do give_name
		   on ERROR					state .
		do restart_form					state .

	on GR_UNKNOWN_TYPE.ACCEPT_DBG
		do read_form		/* Get form parameters */
		   on ERROR					state .
		do read_file		/* Debug In + Make Composite */
		   on ERROR					state .
		do mirror_copy
		   on ERROR					state .
		do give_name
		   on ERROR					state .
		state terminate

state st_cs		/* Locate ship coordinate system */

        message_key		VD_M_DgInHl
        prompt_key		VD_P_DgIdCSMv
        locate_eligible		"+GRgencs"
        locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
        locate_owner            "LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP"
        locate_display          "ELEM_HILIGHT"
        dynamics                0
        mask                    "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
        filter                  locate

        on GR_UNKNOWN_TYPE.CANCEL_DBG
		do enable_gadgets				state terminate

        on EX_BACK_UP or EX_RJT_MOVEON
		do enable_gadgets				state start

        on EX_DATA
		do get_coord_sys
		   on ERROR					state .
		do enable_gadgets				state start


/*
        ------------------------------------------------------------------
                        Actions definition
        ------------------------------------------------------------------
 */


action init
{
long	SMmsg ;

status = om$send(msg      = message CEO_LOCATE.init(type, str_ptr),
             targetid = my_id,
             mode     = OM_e_wrt_message) ; as$status(action = RET_STATUS) ;

/* Initial values */
me->hull_id      = NULL_OBJID ;
me->hull_name[0] = '\0' ;
me->FileName[0]  = '\0' ;
me->file_ptr     = NULL ;
me->cs_name[0]   = '\0' ;
me->cs_id.objid  = NULL_OBJID ;
me->mirror_copy_flag = FALSE  ;

/* Fill in form */
if (! me->forms[0].form_ptr) {
	ex$message( msgnumb = VD_S_DgNoFrmFnd ) ;
	status = OM_E_ABORT ; as$status(action = RET_STATUS) ;
	}

if (x_pos != -1 && y_pos != -1)
	FIf_set_location(me->forms[0].form_ptr,x_pos,y_pos) ;
else {
	x_pos = 1 ; y_pos = 100 ;
	FIf_set_location(me->forms[0].form_ptr,x_pos,y_pos) ;
	}

/* Default values */
strcpy(me->hull_name, "hull") ;
FIg_set_text(me->forms[0].form_ptr, FIELD1, me->hull_name) ; 

strcpy(me->FileName, "hull.dbgin") ;
FIg_set_text(me->forms[0].form_ptr, FIELD2, me->FileName) ; 

/* Get the active CS : if not found take EMS one */
status = SMGetDefCs(TRUE,                    /* Take EMS cs by default */
		   (struct GRid *)NULL,      /* Connected with glob not need */
		   (IGRshort *)NULL,         /* State not used */ 
	           &me->cs_id,               /* Graphic object needed*/
		   (struct GRid *)NULL,      /* No make source on cs */
		   (struct GRmd_env *)NULL,  /* No mod env */
		   (IGRboolean *)NULL);      /* No flag needed */

if (!(status & 1) || me->cs_id.objid == NULL_OBJID) { 
  status = OM_E_ABORT ; as$status(action = RET_STATUS) ; 
}


status = VDget_cs_name(&SMmsg, &me->cs_id, me->cs_name) ;
if (! (status & SMmsg & 1)) { 
	status = OM_E_ABORT ; as$status(action = RET_STATUS) ; 
	}

FIg_set_text(me->forms[0].form_ptr, FIELD3, me->cs_name) ;

/* Mirror option */
FIg_get_state(me->forms[0].form_ptr, TOGGLE1, &me->mirror_copy_flag) ;
} /* action init */


/* ------------------------------------------------------------------ */


action wakeup
{
status = om$send(	msg = message CEO_LOCATE.wakeup(pos),
          		mode = OM_e_wrt_message,
          		targetid = my_id) ; as$status(action = RET_STATUS) ;

/* Set construction list */
me->cst.msg           = &me->cst_msg ;
me->cst.properties    = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE ;
me->cst.display       = &me->ActiveDisplay ;
me->cst.env_info      = &me->ModuleInfo ;
me->cst.newflag       = FALSE ;
me->cst.level         = me->ActiveLevel ;
me->cst.geometry      = NULL ;
me->cst.class_attr    = NULL ;
me->cst.name          = NULL ;

} /* action wakeup */


/* ------------------------------------------------------------------ */


action delete
{
/* Close Debug In file */
if (me->file_ptr  != NULL) fclose(me->file_ptr) ;

/* Get form positions */
FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

status = om$send(msg     = message CEO_LOCATE.delete(f_defer_flag),
         targetid = my_id,
         mode     = OM_e_wrt_message) ; as$status(action = RET_STATUS) ;

} /* action delete */


/* ------------------------------------------------------------------ */


action form_notification
/*
   Description :
   form_notification (int form_label; int gadget_label ; double value ;
                          char * form_ptr)
 */
{
char	buffer[BUFSIZ], aux[BUFSIZ] ;
int	select_flag, pos ;

if ( form_ptr == NULL ) {
	printf("Form for command Debug In Hull not found \n") ;
	return OM_E_INVARG ;
	}

FIg_set_text(form_ptr, FI_MSG_FIELD, "") ;

switch( gadget_label ) {

   case FIELD1 : /* hull name */
	status = FIfld_get_text(form_ptr, 
		gadget_label, 0, 0, 80, buffer, &select_flag, &pos ) ;
	if (status != FI_SUCCESS) {
		printf("Cannot get hull name \n") ;
		goto quit ;
		}
	/* Strip leading and trailing blanks */
	VDstrip_blanks(aux, buffer) ;
	strcpy(me->hull_name, aux) ;

	/* Next input */
	if (me->FileName[0] == '\0') {
	   FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "Enter file name") ;
	   FIfld_pos_cursor(me->forms[0].form_ptr, FIELD2, 0, 0, 0, 0, 0, 0) ;
	   }
	break ;	

   case FIELD2 : /* file name */
	status = FIfld_get_text(form_ptr, 
		gadget_label, 0, 0, 80, buffer, &select_flag, &pos ) ;
	if (status != FI_SUCCESS) {
		printf("Cannot get file name \n") ;
		goto quit ;
		}
	/* Strip leading and trailing blanks */
	VDstrip_blanks(aux, buffer) ;
	strcpy(me->FileName, aux) ;
	break ;	

   case BUTTON1 : /* coordinate system */
	_put_response(resp = ASK_CS) ;
	break ;

   case TOGGLE1 : /* copy and mirror option */
	FIg_get_state(form_ptr, gadget_label, &me->mirror_copy_flag) ;
	break ;

   case FI_EXECUTE :
	_put_response(resp = EXEC_DBG) ;
	break ;

   case FI_ACCEPT :
	_put_response(resp = ACCEPT_DBG) ;
	break ;

   case FI_CANCEL :
	_put_response(resp = CANCEL_DBG) ;
	break ;

   case FI_RESET :
	_put_response(resp = RESET_DBG) ;
	break ;

   default :
	#ifdef DEBUG
	printf("Unactive gadget label \n") ;
	#endif
	break ;
   }

} /* form_notification */


/* ------------------------------------------------------------------ */


action reset_form
/*
	Description : after a RESET or BACKUP
 */
{
/* strcpy(me->hull_name, "hull") ; */
me->hull_name[0] = '\0' ;
me->hull_id = NULL_OBJID ;

/* strcpy(me->FileName, "hull.dbgin") ; */
me->FileName[0] = '\0' ;
if (me->file_ptr  != NULL) { fclose(me->file_ptr) ; }
me->file_ptr = NULL ;

FIg_set_text(me->forms[0].form_ptr, FIELD1, me->hull_name) ; 
FIg_set_text(me->forms[0].form_ptr, FIELD2, me->FileName)  ;

FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "") ;

FIg_set_state_off(me->forms[0].form_ptr, FI_RESET)   ;
FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;

/* Do not touch c.s. info */
FIg_set_text(me->forms[0].form_ptr, FIELD3, me->cs_name) ;

*sts = SUCC ;
} /* reset_form */


/* ------------------------------------------------------------------ */

action restart_form
/*
	Description : after EXECUTE
 */
{
FIg_set_text(me->forms[0].form_ptr, FIELD1, me->hull_name) ; 
FIg_set_text(me->forms[0].form_ptr, FIELD2, me->FileName)  ;

FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "") ;

FIg_set_state_off(me->forms[0].form_ptr, FI_RESET)   ;
FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;

FIg_set_text(me->forms[0].form_ptr, FIELD3, me->cs_name) ;

*sts = SUCC ;
} /* restart_form */


/* ------------------------------------------------------------------ */


action enable_gadgets
/*
	Description : re-enable gadgets after a c.s. locate
 */
{
long	SMmsg ;

dp$erase_hilite(msg = &SMmsg) ; /* de-hilite c.s. */

FIg_enable(me->forms[0].form_ptr, FIELD1)  ;
FIg_enable(me->forms[0].form_ptr, FIELD2)  ;
FIg_enable(me->forms[0].form_ptr, TOGGLE1) ; /* mirror */
FIg_enable(me->forms[0].form_ptr, BUTTON1) ; /* c.s.   */

FIg_enable(me->forms[0].form_ptr, FI_RESET)   ;
FIg_enable(me->forms[0].form_ptr, FI_EXECUTE)   ;
FIg_enable(me->forms[0].form_ptr, FI_ACCEPT)   ;

*sts = SUCC ;
}


/* ------------------------------------------------------------------ */


action disable_gadgets
/*
	Description : whenever we are locating a c.s.
 */
{
long	SMmsg ;

dp$erase_hilite(msg = &SMmsg) ; /* de-hilite c.s. */

FIg_disable(me->forms[0].form_ptr, FIELD1)  ;
FIg_disable(me->forms[0].form_ptr, FIELD2)  ;
FIg_disable(me->forms[0].form_ptr, TOGGLE1) ; /* mirror */
FIg_disable(me->forms[0].form_ptr, BUTTON1) ; /* c.s.   */

FIg_disable(me->forms[0].form_ptr, FI_RESET)   ;
FIg_disable(me->forms[0].form_ptr, FI_EXECUTE)   ;
FIg_disable(me->forms[0].form_ptr, FI_ACCEPT)   ;

*sts = SUCC ;
}


/* ------------------------------------------------------------------ */


action get_coord_sys
/*
	Description : get a coordinate system to make the copy and mirror
 */
{
long	SMmsg ;

#ifdef DEBUG
printf("old cs_id is %d/%d \n", me->cs_id.objid, me->cs_id.osnum) ;
printf("old cs name is <%s> \n", me->cs_name) ;
#endif

me->cs_id = me->event1.located_object[0].located_obj ;

status = VDget_cs_name(&SMmsg, &me->cs_id, me->cs_name) ;
if (! (status & SMmsg & 1)) { 
	status = OM_E_ABORT ; as$status() ; *sts = ERRO ; goto quit ;
	}

#ifdef DEBUG
printf("new cs_id is %d/%d \n", me->cs_id.objid, me->cs_id.osnum) ;
printf("new cs name is <%s> \n", me->cs_name) ;
#endif

status = FIg_set_text(me->forms[0].form_ptr, FIELD3, me->cs_name) ;
if (status != FI_SUCCESS) { status = OM_W_ABORT; as$status() ; }
*sts = SUCC ;
}


/* ------------------------------------------------------------------ */


action read_form
/*
	Description : check if hull and file names are given
	Note : if name for hull already exists, then ask for a new name
 */
{
struct GRid	duplicate ;
extern          DIfast_trans(), DIreport_error() ;

if (me->hull_name[0] == '\0') {
   FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "Enter hull name") ;
   FIfld_pos_cursor(me->forms[0].form_ptr, FIELD1, 0, 0, 0, 0, 0, 0) ;
   FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
   FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;
   *sts = ERRO ; goto quit ;
   }

if (me->FileName[0] == '\0') {
   FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, "Enter file name") ;
   FIfld_pos_cursor(me->forms[0].form_ptr, FIELD2, 0, 0, 0, 0, 0, 0) ;
   FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
   FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;
   *sts = ERRO ; goto quit ;
   }

/* Check if name has not been used before */
status = di$translate(objname = me->hull_name,	/* I */
		p_objid = &duplicate.objid,	/* O */
		p_osnum = &duplicate.osnum	/* O */
		) ;
if (status == DIR_W_NAME_NOT_FOUND) {
	*sts = SUCC ; goto quit ;
	}
else {
	if (status == DIR_S_SUCCESS) {
	   ex$message(	msgnumb = VD_S_DgDirExist, type="%s",
			var = `me->hull_name` );

	   FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
		"Enter new name for hull") ;
	   FIfld_pos_cursor(me->forms[0].form_ptr, FIELD1, 0,0,0,0,0,0) ;
	   }
	else {
	   di$report_error(sts = status, comment = "traduction") ;
	   }
	me->hull_name[0] = '\0' ; *sts = ERRO ; goto quit ;
	}

} /* read_form */


/* ------------------------------------------------------------------ */


action read_file
/*
	Description :

  This method reads an EMS "Debug In" file, and make a composite of the 
  located surfaces.
 */  
{
GRclassid	object_class ;
int		index, num_allocated;
long		SMmsg ;

IGRboolean	tryhex, use_classname ;

GRobjid		cur_objid ;

GRobjid 	*surf_list, *storage ;

extern GRclassid OPP_EMSsubbs_class_id ;

/*
	Open file in read-only mode
 */

if (me->FileName[0] == '\0') { *sts = ERRO ; goto quit ; }

me->file_ptr = (FILE *) fopen(me->FileName, "r") ;
if (me->file_ptr == NULL) {
	ex$message( msgnumb = VD_S_DgNoRead, type="%s",var = `me->FileName` ) ;
        FIfld_pos_cursor(me->forms[0].form_ptr, FIELD2, 0, 0, 0, 0, 0, 0) ;
	FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
	FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;
	*sts = ERRO ; goto quit ;
	}

/*
	Check if file is an ASCII one by searching for '\n' among the BUFSIZ
	first characters - keep this test here
 */

if (! VDis_ascii_file(me->FileName)) {
	ex$message(msgnumb = VD_S_DgNoASCII, type="%s", var = `me->FileName` ) ;
        FIfld_pos_cursor(me->forms[0].form_ptr, FIELD2, 0, 0, 0, 0, 0, 0) ;
	FIg_set_state_off(me->forms[0].form_ptr, FI_ACCEPT)  ;
	FIg_set_state_off(me->forms[0].form_ptr, FI_EXECUTE) ;
	*sts = ERRO ; goto quit ;
	}

/*
	Initialization
 */

num_allocated = NUM_OBJ ;

surf_list = (GRobjid *) om$malloc(size = num_allocated * sizeof(GRobjid)) ;
if (surf_list == NULL) {
	*sts = ERRO ;
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = quit) ;
	}

index = 0 ; /* to store each located surface */


/*
	Debug In file, and locate surfaces
 */

tryhex = TRUE ;
use_classname = TRUE ;
while (! feof(me->file_ptr)) {	/* for each object */

	status = EFfreadGeom(
		me->file_ptr,			/* I/O */
		me->ModuleInfo.md_id.osnum,	/* I */
		&cur_objid,			/* O */
		&me->cst,			/* I */
		&me->DisplayMode,		/* I */
		use_classname,
		tryhex) ;

	if (feof(me->file_ptr)) {

		#ifdef DEBUG
		printf("End of file reached => close file \n") ;
		#endif

		fclose(me->file_ptr) ; me->file_ptr = NULL ;
		break ; /* go to make the composite */
		}

	if (! (status & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	status = om$get_classid(osnum = me->ModuleInfo.md_id.osnum,
                		objid = cur_objid,
                		p_classid = &object_class) ;
	if (! (status & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	if (om$is_ancestry_valid(
		superclassid	= OPP_EMSsubbs_class_id,
		subclassid	= object_class) == OM_S_SUCCESS) {

		/* Realloc storage for surf_list if necessary */
		if (index >= num_allocated) {

		   #ifdef DEBUG
		   printf("Reallocate storage \n") ;
		   #endif

	    	   num_allocated += NUM_OBJ ;
	    	   storage = (GRobjid *) om$realloc(ptr = (char *)surf_list,
				size = num_allocated * sizeof(GRobjid)) ;
	    	   if (storage == NULL) {
		      *sts = ERRO ; status = OM_E_ABORT ; 
		      as$status(action = GOTO_VALUE, value = quit) ;
		      }

	           surf_list = storage ;
		   } /* realloc */

		/* Store surface id */
		surf_list[index] = cur_objid ; index ++ ;
        	} /* if surface */

	} /* while EOF not reached */

/*
	Make composite surface
 */

if (index > 1) {
   status = VDmake_comp(&SMmsg, surf_list, index, &me->cst, &me->hull_id) ;
   if (! (status & SMmsg & 1)) {
	ex$message(msgnumb = VD_S_DgNoCmpSf, type="%s", var=`me->FileName` ) ;
	*sts = ERRO ; goto quit ;
	}
   }
else {
   if (index == 1) {
	me->hull_id = surf_list[0] ;
	}
   else {
	ex$message(msgnumb = VD_S_DgNoCmpFl, type="%s", var=`me->FileName` ) ;
	*sts = ERRO ; goto quit ;
	}
   }

me->DisplayMode = GRbd ;
status = om$send(msg = message GRgraphics.GRdisplay(
		&SMmsg,		
		&me->cst.env_info->md_env.matrix_type,
		me->cst.env_info->md_env.matrix,
		&me->DisplayMode,
		&me->cst.env_info->md_id),
		senderid = NULL_OBJID,
		targetid = me->hull_id,
		targetos = me->ModuleInfo.md_id.osnum) ; as$status() ;
*sts = SUCC ;

#ifdef DEBUG
printf("Action read_file successfully completed \n") ;
#endif

} /* read_file */


/* ------------------------------------------------------------------ */


action mirror_copy
/*
   Description : 
	Make a copy and then a mirror transformation with respect to the 
	X-Z plane of the defined coordinate system

   Error handling : if the final composite cannot be made the mirror
	object is destroyed, and the name is given to the first part of
	the hull - convention
 */
{
short	four = 4   ;
short	trans_type ;
double  xz_sym[] = { 	1,  0, 0, 0,
			0, -1, 0, 0,
			0,  0, 1, 0,
			0,  0, 0, 1	} ;
double	pass[16], inv_pass[16], trans[16] ;

GRobjid surf_list[2] ;
long	SMmsg ;

FIg_get_state(me->forms[0].form_ptr, TOGGLE1, &me->mirror_copy_flag) ;
if (me->mirror_copy_flag) {

	#ifdef DEBUG
	printf("Copy and mirror will be done \n") ;
	#endif

	/* Get local to world matrix */
	status = om$send(msg = message GRgencs.GRgetmatrix(&SMmsg, pass),
			senderid = NULL_OBJID,
			targetid = me->cs_id.objid,
			targetos = me->cs_id.osnum) ; 
	if (! (status & SMmsg & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	/* Inverse matrix */
	MAinvmx(&SMmsg, &four, pass, inv_pass) ;
	if (SMmsg != MSSUCC) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	/* Compute transformation matrix */
	MAmulmx(&SMmsg, &four, &four, &four, xz_sym, inv_pass, trans) ;
	if (SMmsg != MSSUCC) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}
	MAmulmx(&SMmsg, &four, &four, &four, pass, trans, trans) ;
	if (SMmsg != MSSUCC) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	/* Make a copy and mirror */
	surf_list[0] = me->hull_id ; me->hull_id = NULL_OBJID ;
	status = om$send(msg = message GRgraphics.GRcopy(
				&SMmsg,		
				&me->ModuleInfo,
				&me->ModuleInfo,
				&surf_list[1]),
			senderid = NULL_OBJID,
			targetid = surf_list[0],
			targetos = me->ModuleInfo.md_id.osnum) ; 
	if (! (status & SMmsg & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	MAtypemx(&SMmsg, trans, &trans_type) ;
	if (! (SMmsg & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	status = om$send(msg = message GRgraphics.GRxform(&SMmsg,	
				&me->ModuleInfo, &trans_type, trans,
				&surf_list[1]),
			senderid = NULL_OBJID,
			targetid = surf_list[1],
			targetos = me->ModuleInfo.md_id.osnum) ; 
	if (! (status & SMmsg & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		}

	status = om$send(msg = message GRgraphics.GRdisplay(
				&SMmsg,		
				&me->cst.env_info->md_env.matrix_type,
				me->cst.env_info->md_env.matrix,
				&me->DisplayMode,
				&me->cst.env_info->md_id),
				senderid = NULL_OBJID,
				targetid = surf_list[1],
				targetos = me->ModuleInfo.md_id.osnum) ; 
	if (! (status & SMmsg & 1)) {
		*sts = ERRO ; as$status(action = GOTO_VALUE, value = quit) ;
		} /* keep this display here */

	status = VDmake_comp(&SMmsg, surf_list, 2, &me->cst, &me->hull_id) ;
	if (! (status & SMmsg & 1)) {

	   #ifdef DEBUG
	   printf("Cannot make composite with mirror object \n") ;
	   #endif
#if 0
- test -
	   status = om$send(msg = message GRgraphics.GRdelete
				(&SMmsg, me->cst.env_info),
			senderid = NULL_OBJID,
			targetid = surf_list[1],
			targetos = me->ModuleInfo.md_id.osnum) ; 
	   as$status() ;
#endif
	   me->hull_id = surf_list[0] ; /* OK */
	   }
#ifdef DEBUG
	else {
	   ex$message( msgnumb = VD_S_DgCmpMirOb ) ;
	   }
#endif
	} /* if mirror option */

*sts = SUCC;

#ifdef DEBUG
printf("End of action mirror_copy \n") ;
#endif
} /* mirror_copy */


/* ------------------------------------------------------------------ */


action give_name
/*
	Description : Give a name to the hull in the current directory
	Note : a check on the name has been done previously
 */  
{
long SMmsg ;

#ifdef DEBUG
printf("Hull name is <%s> \n", me->hull_name) ;
#endif

/* Hull name is required */
if (me->hull_name[0] == '\0') { *sts = ERRO ; goto quit ; }

status = om$send(msg = message GRgraphics.GRputname(&SMmsg, me->hull_name),
			senderid = NULL_OBJID,
			targetid = me->hull_id,
			targetos = me->ModuleInfo.md_id.osnum) ; 
if (! (status & SMmsg & 1)) { 
	status = OM_E_ABORT ; as$status() ; 
	me->hull_name[0] = '\0' ; *sts = ERRO ; goto quit ;
	}
#if 0
FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
	"Hull successfully named in current directory") ;
#endif

*sts = SUCC;
} /* give_name */


/* ------------------------------------------------------------------ */


/* $Id: VRcablerep.sl,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco/VRcablerep.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcablerep.sl,v $
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
# Revision 1.4  1996/03/04  22:57:00  pinnacle
# Replaced: vrcableco/VRcablerep.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  20:16:38  pinnacle
# Replaced: vrcableco/VRcablerep.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:19:08  pinnacle
# Replaced: vrcableco/VRcablerep.sl for:  by r240_int for route240
#
 *
 * History:
 *	4/25/90	 	AdZ	creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb		Add VX_FIproto.h
 *
 *************************************************************************/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

class			VRcablerep
super_class		"VDB_LOCATE"
command_string		VRC_M_CrCbOtFl,0,VRCrCbOtFl
product_name		"$ROUTE"
command_table		"route.cmd"

start_state		start

specification

#include <stdio.h>
#include <string.h>

/* --------------------------------------------------------------------- */
/* CLASS IMPLEMENTATION */

implementation
/*
 * include files
 */
#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dpstruct.h"
#include "VRcabledef.h"
#include "AS_status.h"
#include "vrcablec_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

from	text_exp	import	 NDgive_structure;
from	VRcable		import	 VRCbGetProps;

/* --------------------------------------------------------------------- */
/* STATUS AREA */
state_table

#include "VRmsg.h"
#include "AS_status.h"


state start
	message_key	VR_M_CrCbOtFl	
	on ELSE	 	do cable_report( &me->ret )
			on ERROR				state err_msg
								state terminate


state err_msg
	status_key 	VR_S_CbErrOutFile
	error_box	" Error in Set Up Report File "

	on ELSE							state terminate


/* ---------------------------------------------------------------------- */
/* CABLE_REPORT */

action cable_report
/*.cable_report*/
{
/*
 * local variables
 */
IGRchar			file_name[CABLE_MAX_TXT];
IGRchar			report_name[CABLE_MAX_TXT];
IGRchar			buff[CABLE_MAX_BUF];
IGRdouble		length;
IGRlong			msg;
FILE			*file_ptr=NULL, *rep_ptr=NULL;
struct	GRid		tmp_obj;
struct	ret_struct	ret_str;
struct	VRcable_data	Cable_Data;
/*
 * open the equipment file to look for the cable objects
 */
	*sts = MSSUCC;

	tmp_obj.objid = NULL_OBJID;
	status = VRCb_Object_Active( CABLE_EQUIP_TABLE, &tmp_obj );	
	if( status ){
	 	/*| get exp_syntax for CABLE_EQUIP_TABLE */
		status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );

		strcpy( file_name, ret_str.var.text_st.text_string );
		/*" file_name : <%s> \n", file_name */
	}
	else{
		/*| Equip_Table not defined */
		*sts = MSFAIL;
		goto wrapup;
	}

	if( (file_ptr = (FILE *) fopen( file_name , "r")) == NULL ){
		printf("\nCable Report: Can't open file <%s> \n", file_name);
		*sts = MSFAIL;
		goto wrapup;
	}
/*
 * get output file of cable reports
 */
	tmp_obj.objid = NULL_OBJID;
	status = VRCb_Object_Active( CABLE_OUTPUT_FILE, &tmp_obj );	
	if( status ){
	 	/*| get exp_syntax for CABLE_OUTPUT_FILE */
		status = om$send( msg = message text_exp.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo ),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );

 		strcpy( report_name, ret_str.var.text_st.text_string );
	}
	else {
		/*| Cable Output File not defined */
		*sts = MSFAIL;
		goto wrapup;
	}

	/*" INIT file_name : <%s> \n", report_name */
	if( (rep_ptr = (FILE *) fopen( report_name , "w")) == NULL ){
		printf("\nCable Report: Can't open file <%s> \n", report_name);
		*sts = MSFAIL;
		goto wrapup;
	}
/*
 * get information of each cable and write in the report file
 */
	/*| get line in buffer */
	while( fgets( buff, sizeof(buff), file_ptr ) != NULL ){

	  /*" buf[%d] = <%s> \n", buff */ 
	  if( sscanf( buff,"%s %s %s %s %s %s %s", 
				Cable_Data.CableNameStr,
				Cable_Data.Equipment1Str,
				Cable_Data.ConnectPnt1Str,
				Cable_Data.Equipment2Str,
				Cable_Data.ConnectPnt2Str,
				Cable_Data.BendRadiusStr,
				Cable_Data.SectRadiusStr ) == 7 ){
			
		/*" Cable_Name = <%s> \n", Cable_Data.CableNameStr */
	  /*
	   * test if cable exist in system
	   */
	    tmp_obj.objid = NULL_OBJID;
	    tmp_obj.osnum = OM_Gw_current_OS;
	    status = VRCb_Object_Active( Cable_Data.CableNameStr, &tmp_obj );	
	    if( status ){
		/*| object in system */
		status = om$send( msg = message VRcable.VRCbGetProps(
						&msg,
						&me->ModuleInfo,
						NULL,
						NULL,
						&length ),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum );
		if( length > 0 )
		  VRCb_Pr_Defined( rep_ptr, Cable_Data.CableNameStr, length );
	    }
	  }
        }

wrapup:

/*
 * close the input and output file
 */
	if ( file_ptr ) fclose( file_ptr );
	if ( rep_ptr  ) fclose( rep_ptr );

return OM_S_SUCCESS;
}



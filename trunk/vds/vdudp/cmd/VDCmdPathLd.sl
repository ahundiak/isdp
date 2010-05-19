/* $Id: VDCmdPathLd.sl,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdudp/cmd / VDCmdPathLd.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdPathLd.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
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

command_string       VDC_M_LdPtFC, 0, VDLdPtFC
command_table        "vds.cmd"
class                VDCmdPathLd
super_class          VDCmdPath
product_name         "$VDS"


specification

/* instance variables for form control */

instance
{
struct GRid	VDSpath_co;
}


implementation

#include <stdio.h>
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"

#include "VDmsg.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSudp_priv.h"

#include "VDSudpco.h"

#include "AS_status.h"
#define AS_DEBUG 1
 

/**********************************************************/

state_table

#include "VDmsg.h"
#include "VDSudpco.h"

#define	getObject	1
#define haveError	2
#define	PATH_FORM	0
#define PATH_SYMB	1


state start
	message_key		VD_M_LdPtFC
	prompt_key		VD_P_IdComp
	accept_key		VD_P_AccRej
	relocate_key		VD_P_IdNamComp
	locate_class		"GRgraphics"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	filter			locate



   on EX_RJT_MOVEON
	do status_key	VD_E_IgnMvOn				state .

   on EX_DATA or EX_OBJID
	do store
	   	  on RETURN_CODE = "SEVERE_ERROR"		state haveError
								state terminate


state haveError
   status_key VD_E_ErStPath
   on ELSE							state -

/* -------------------------------------------------------- */

action store
{
 struct GRid 		loc_obj;

 me->ret = SUCCESS;

 loc_obj = me->event1.located_object[0].located_obj;
 status     = om$send(  targetid = me->VDSpath_co.objid,
 			targetos = me->VDSpath_co.osnum,
			mode   = OM_e_wrt_message,
			msg    = message VDCmdPath.store_path( loc_obj));
 if(!(status & 1))
  {
   printf("error sending store_path\n");
   me->ret = SEVERE_ERROR;
  }
return OM_S_SUCCESS;

}

/* -------------------------------------------------------- */

action init
{
 char 	path_name[DI_PATH_MAX + 20];

 status     = om$send(  targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.init( type, str_ptr ) );
 as$status( action = RET_STATUS );
 status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			    pathname = path_name );

 if ( status != DIR_S_SUCCESS )
   {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
   }

 strcat( path_name, COMMAND_NAME );


 status = di$translate (  objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &me->VDSpath_co.objid,
			  p_osnum = &me->VDSpath_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
   printf("ERROR: this command must only be used with the form VDDirPath\n");
   me->state = _terminate;
   return ( OM_I_STOP_SENDING );
  }

}

/* -------------------------------------------------------- */

action delete
{

   status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO_LOCATE.delete ( 0 ));
   return ( OM_S_SUCCESS );
}
















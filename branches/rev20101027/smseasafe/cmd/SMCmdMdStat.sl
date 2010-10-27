/* $Id: SMCmdMdStat.sl,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smseasafe/cmd / SMCmdMdStat.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdMdStat.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
  File           SMCmdMdStat.sl 
  Creation Date  August 92
  Auteur         Ghassan Jahmi - Jean Jasinczuk (ISDC)

 This file implement the command object to review and/or modify object state 

  Modifiaction: April 93 Compile for 2.2 
*/


command_string       SMC_M_SMDef,0,SMStDf
command_table        "sman.cmd"
class                SMCmdMdStat
super_class          CEO_LOCATE
product_name         "$VDS"

form "SMChgObjSt",0,0,0,0

specification

#include <stdio.h>
#include "OMmacros.h"

#include "exdef.h"
#include "dpmacros.h"
#include "FI.h"
#include "SMdef.h"
#include "ACrg_collect.h"
#include "SMmacros.h"
#include "SMCmdSeasafe.h"
#include "SMmsg.h"

instance 
{
variable struct GRid listobj[1];
int nbobj;
}

implementation
from GRgraphics import GRdisplay;
#define AS_DEBUG	1

#include "AS_status.h"

/*************************************************************************/

state_table

#include "SMmsg.h"
#define MY_ERROR 500
#define SAVE 509

state start

   message_key  SM_M_ModLoc
   prompt_key	SM_P_ObjLoc
   accept_key   SM_P_ObjConf
   locate_class "SMmgr"         /* object classes to locate */
    filter         locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID   
				do control_obj
				   on RETURN_CODE = MY_ERROR
					state .
				   on ERROR state terminate
				state second

state second
   message_key  SM_M_ModLoc
   prompt_key	SM_P_ObjLoMo
   locate_class "SMmgr"         /* object classes to locate */
    filter         locate_noauto

  on EX_DATA or EX_STRING or EX_OBJID   
		do control_obj
		   on RETURN_CODE = MY_ERROR		state .
		   on ERROR				state terminate
							state .

  on EX_RJT_MOVEON					 state disp_form

state disp_form
   display_form  0
   message_key   SM_M_ModLoc
   prompt_key    SM_P_SfChForm
   filter        get_event

   on GR_UNKNOWN_TYPE.SAVE do erase_form 0
				state start


at wakeup do display_half_hilite
at sleep do erase_hilite
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMRDNotif.I                                           */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern
action control_obj extern

action save_all extern

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action display_half_hilite
{
long msg;
int i;

  me->DisplayMode = GRhhd;
 for (i=0; i<me->nbobj; i++)
 {
   status = om$send(msg = message GRgraphics.GRdisplay
                                         (
					  &msg,
		                          &me->ModuleInfo.md_env.matrix_type,
		                          me->ModuleInfo.md_env.matrix,
		                          &me->DisplayMode,
		                          &me->ModuleInfo.md_id
					 ),
		      targetid = me->listobj[i].objid,
		      targetos = me->listobj[i].osnum);
		    
		    
     if (!(status & msg & 1))
       ex$message( msgnumb = SM_E_ERGrDisp );
  }
}

action erase_hilite
{
  status = dp$erase_hilite(msg=&me->ret,
			   objid = me->ModuleInfo.md_id.objid,
			   osnum = me->ModuleInfo.md_id.osnum);
}

action init
{
  
 status = om$send(targetid = my_id,
		  mode   = OM_e_wrt_message,
		  msg    = message CEO_LOCATE.init( type, str_ptr ) );
 if (!(status & 1))
    {
      printf("error at CEO_LOCATE.init\n");
      me->state = _terminate;
      return ( OM_I_STOP_SENDING );
    }

me->nbobj = 0;
}

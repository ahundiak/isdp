/* $Id: SMCmdSglPl.sl,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smplane/cmd / SMCmdSglPl.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmdSglPl.sl,v $
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

/*    File          SMCmdSglPl.sl
      Description   Command object for place or modify a single plane
      Auteur        Jean Jasinczuk (ISDC) 
      Date          June-92     
*/

command_string       SMC_M_PlInfPl,0,SMPlSnPl
synonym              SMC_M_MdInfPl,1,SMMdSnPl
command_table        "sman.cmd"
class                SMCmdSglPl
super_class          VDS_LOCATE
product_name         "$VDS"

form "SMInfPlane",0,0,0,0

specification

#include <stdio.h>
#include "igrtypedef.h"

#include "OMmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"

#include "csmacros.h"
/* #include "tools.h"  * Not Required  -- AA */
#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "coparamac.h"
#include "growner.h"
#include "FI.h"

#include "SMCmdSglPl.h"

#include "SMmsg.h"

instance 
{
  struct param_buffer param_buf;
  struct param_buffer old_param_buf;

  struct GRid  mac;             /* When modify, GRid of the plane occurrence */
  
  variable struct GRid    cs[1];   /* Array of all the selected cs (or plane)*/
  variable struct GRmd_env cs_env[1]; /* Mod env of the selected cs (or plane)*/
  IGRint nb_cs;
  variable struct GRid    old_cs[1]; /* Buffer for cs */
  IGRint old_nb_cs;
  variable struct GRmd_env old_cs_env[1]; /* Buffer for mod_env of cs */

}

implementation

#define AS_DEBUG	1

#include "AS_status.h"

/*************************************************************************/

state_table

#define COORDINATE  506
#define BAD_LOCATED 507
#define LOADC       508
#define PL_RELOCATE 509 
#define PLACE 0
#define MODIFY 1
#define TRUE 1
#define FALSE 0

#include "SMmsg.h"
#include "VDSFilter.h"

state start

  on CMD_TYPE = PLACE   state form_modify
                        
  on CMD_TYPE = MODIFY  state plane_locate 
  
state plane_locate
  erase_form    0
  message_key            SM_M_PlModify
  prompt_key             SM_P_PlLocate
  accept_key             SM_P_PlAccRej
  locate_class           "SMInfPlane" 
  filter                 vds_locate	
    
  on EX_DATA or EX_STRING   do control_plane
                        on RETURN_CODE = BAD_LOCATED 
                           do status_key  SM_I_FrLocate
                           state .
                       on ERROR state terminate

                       state form_modify
                                          

state form_modify
display_form  0
on CMD_TYPE = PLACE
   do message_key SM_M_PlPlace state bis_form_modify
on CMD_TYPE = MODIFY
   do message_key  SM_M_PlModify state bis_form_modify


state bis_form_modify
   display_form  0
   prompt_key	SM_P_FrPlMd
   dynamics	off
   filter	get_event

   on GR_UNKNOWN_TYPE.COORDINATE state query_coord
   on GR_UNKNOWN_TYPE.LOADC state load_comp 
   on GR_UNKNOWN_TYPE.PL_RELOCATE state plane_locate 

state load_comp
    display_form   0                                            
    message_key    SM_M_PlPlace
    prompt_key	   SM_P_PlLocate
    accept_key     SM_P_PlAccRej
    locate_class   "SMInfPlane"
    mask           "GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP"
    filter         vds_locate	
    
  on EX_DATA or EX_STRING do control_plane
                          on RETURN_CODE = BAD_LOCATED 
                             do status_key  SM_I_PlLocate
                             state .
                         on ERROR state terminate
                      state form_modify

    on EX_BACK_UP     do make_selectable 
                      state form_modify

    
state query_coord
   display_form  0
   prompt_key		SM_P_FrCoord
   dynamics		off
   accept_key           SM_P_FrAccRej    
   locate_eligible      "+EMSplane,GRgencs"
   mask                "GRm_DATA | GRm_OBJID |
                         GRm_STRING | GRm_RESET | GRm_BACK_UP"
   locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                         LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
   filter		vds_locate_noauto


   on EX_DATA or EX_STRING or EX_OBJID do coord_syst
                                       on RETURN_CODE = BAD_LOCATED 
                                           state .
                                       state form_modify            

   on EX_BACK_UP do make_selectable
                   state form_modify


at wakeup do form_wakeup                                            
at sleep do form_sleep
at delete do form_delete

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in SMPlNotif.I                                           */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr ) extern

action control_plane	extern 

action init		extern

action form_delete	extern

action coord_syst	extern

action make_selectable	extern

action save_all		extern

action reset_all	extern

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action form_wakeup
{
 
  if(me->mytype == MODIFY && me->mac.objid != NULL_OBJID)
   {
     status = om$is_objid_valid (osnum =  me->mac.osnum,
				 objid = me->mac.objid );   
     
     if(status != OM_S_SUCCESS )  /* The macro doesn't exists anymore */
      {
	UI_status("The macro doesn't exist\n");
	me->state = _terminate;
	return OM_I_STOP_SENDING;
      }
   }  
}

action form_sleep
{
        dp$erase_hilite(msg = sts);
}

action DisplayCs(long * sts ; enum GRdpmode Mode)
{
  int i;
  IGRlong msg;
  struct GRid go_cs;

  for(i=0;i<me->nb_cs;i++)
   {
     if(!GetEnvFrObj(&me->cs[i],NULL,&go_cs)) 
       go_cs = me->cs[i];

     status = dp$display(msg = &msg, oids = &go_cs , mode = Mode);
     if(!(status & 1))
      {
	printf("Warning: Problem displaying cs %d,%d\n",
	              go_cs.objid,go_cs.osnum);
      }
   }
}



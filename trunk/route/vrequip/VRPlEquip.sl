/* $Id: VRPlEquip.sl,v 1.3 2001/02/20 01:13:45 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip/VRPlEquip.sl
 *
 * Description:
 *	Place Equipement Command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlEquip.sl,v $
 *	Revision 1.3  2001/02/20 01:13:45  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:54:38  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:51  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  2000/08/09  15:30:54  pinnacle
# Created: route/vrequip/VRPlEquip.sl by apazhani for Service Pack
#
# Revision 1.6  1999/12/29  11:58:28  pinnacle
# Replaced by Anand for CR 179900908
#
# Revision 1.5  1999/10/13  16:23:20  pinnacle
# Replaced: vrequip/VRPlEquip.sl for: CR 179800598 by aharihar for route
#
# Revision 1.4  1999/03/04  06:44:16  pinnacle
# Replaced: vrequip/VRPlEquip.sl for: TR 179800237 by aharihar for route
#
# Revision 1.3  1999/01/28  06:39:28  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by apazhani for route
#
# Revision 1.2  1998/12/17  15:46:32  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.8  1998/04/12  08:22:02  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by apazhani for route
#
# Revision 1.7  1998/03/04  04:36:14  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by apazhani for route
#
# Revision 1.6  1998/03/02  06:12:24  pinnacle
# Replaced: vrequip/VRPlEquip.sl for: TR179701668 by aharihar for route
#
# Revision 1.5  1997/12/29  22:23:02  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.4  1997/10/20  15:33:24  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.3  1997/09/08  03:45:14  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.2  1997/09/08  00:17:44  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.8  1997/06/05  17:26:06  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.7  1997/05/29  13:08:52  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
#  Version 1.6 has vd$RisSelect query for 4 DB attributes, the forth one being
#  eqp_family, which is to be used when macro_name is not specified. 
#  Instead in version 1.7 we use VRdbGetEqOccur(); 
#
# Revision 1.5  1997/05/21  13:41:40  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.4  1997/05/16  23:30:02  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by kddinov for route
#
# Revision 1.3  1997/02/14  22:05:34  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by hverstee for route
#
# Revision 1.2  1997/02/14  15:48:54  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.12  1996/06/06  16:16:04  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by r240_int for route240
#
# Revision 1.11  1996/06/06  13:50:18  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by ashankar for route240
#
# Revision 1.10  1996/05/14  15:41:56  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by ashankar for route240
#
# Revision 1.9  1996/03/05  22:45:38  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by hverstee for route240
#
# Revision 1.8  1996/03/04  21:13:58  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by hverstee for route240
#
# Revision 1.7  1996/02/19  04:51:56  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by ashankar for route240
#
# Revision 1.6  1996/01/16  23:47:14  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by r240_int for route240
#
# Revision 1.5  1995/12/08  21:21:46  pinnacle
# Replaced: vrequip/VRPlEquip.sl for:  by r240_int for route240
#
 *
 * History:
 * 	01/20/93	K.B.	Creation (isdc Paris)
 *	03/09/93		3D implementation 	
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	May/97		kdd	VRPidEquip. The form UI is changed. 
 *				the new form VRPidEquip has 4 fields. 
 *				see vdb$RisSelect, me->num_cols. 
 *	     vdb$RisSelect(FI_EQUIP_TABLE) is called in "init"
 *	     vdb$RisSelect(FI_EQUIP_LIST)  is called in "VRPID_LoadFromField"
 *
 *	Mar 02 98	Anand	Removed message_key in state PLACE_DYN
 *      Mar 04 98       Alwin   The method dynamics is modified to erase the
 *                              unwanted phanton figure which leads to
 *                              confusion. TR179525895
 *      Apr 12 98       Alwin   Above modification in dynamics has been removed
 *				and added "sleep" and "wakeup" to take care of 
 *				the phantom graphics.
 *      Dec 17 98       Alwin   Modified VRPlaceEquip(), to dynamically allocate
 *				the memory for feets of the PID euipment.
 *      Jan 27 99       Alwin   Added FeetDesc to prevent crash.
 *      Mar 04 99       Anand   Forced update of PID equipment when its dynamic
 *      			attributes are changed thru the Modify PID
 *      			equipment command/form.
 *      Oct 13 99       Anand   CR 179800598 - Let users change equipment scale
 *      Dec 1999   	Anand   CR 179900908 - Implemented option to maintain
 *                 		existing nozzle parameters on PID eqp when the
 *                 		replace PID equipment button is utilized.
 *      Aug 2000   	Alwin   Found while fixing CR179901716. Malloc failed 
 *				while allocating 0 bytes and fixed.
 *
 *************************************************************************/

command_string		"Place PID Equipment", 0, VRPlEqCm
synonym			"Select PID Equipment", 1, VRSelEq
synonym			"Modify PID Equipment", 2, VRModEq
class			VRPlEquip
super_class		VRCmpMgr
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"route.cmd"
start_state		main 

form "VREquipment", 0, 0,"-1", "-1"
form "VREquipSelect", 1, 0,"-1", "-1"
form "VRSearchParams", 2, 0,"-1", "-1"
form "VRPidEquip", 3, 0,"-1", "-1"
form "VRModPidEqp", 4, 0, "-1", "-1"


specification
#include "FI.h"
#include "VRdimdef.h"
#include "VRhvacstr.h"
#include "VRpipestr.h"

#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "VRdef.h"
#include "VRattr_def.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "go.h"
#include "VREquipForm.h"

instance
{
  Form				form_ptr;
  IGRchar			EquipNumber[41];
  int 				list_present;

/*******************************************************************************
* KDD  May/97
* 
* EquipTable	= pointer to PID_EQUIP_MASTER_TBL 
*		  Populates gadgets FI_EQUIP_TABLE & FI_TBL_LIST_1_2_3
* 
* EquipList     = pointer to data selected from table FI_EQUIP_TABLE( active )
*		     with classification == FI_TBL_LIST_1_2_3 or ""
*		     Not all columns are used. See "lst_cols". 
*		  Populates gadget FI_EQUIP_LIST
*
* num_cols	= number of cols (4) in PID_EQUIP_MASTER_TBL
* num_rows	= number of rows     in PID_EQUIP_MASTER_TBL
*
* lst_cols	= number of cols (3) in FI_EQUIP_TABLE(active) 
*             NOTE: the full sub_table has 8 columns!
*	      NOTE: We ask for EQP_NUMBER, EQP_DESCR, MACRO_NAME
*		        see vdb$RisSelect in VRPID_LoadFromField.
*			EQP_NUMBER goes in FI_EQUIP_LIST (0) 
*			EQP_DESCR  goes in FI_EQUIP_LIST (1) 
*			MACRO_NAME goes in FI_EQUIP_MACRO
*			   if macro_name == ' ' use Part.Familly (TR#179701127)
*
* lst_rows	= number of rows     in FI_EQUIP_TABLE(active)
*
* EquipToModify	= Equipment located for modification. 
*
* CmpId (VRCmpMgr) = Equipment being placed (later removed in case of Replace).
*-------------------------------------------------------------------------------
* 	PID_EQUIP	(master) table format
*
*  discpl_table | 	Ex: PIPING_EQUIP
*  class1 | 
*  class2 | 
*  class3
*
*-------------------------------------------------------------------------------
*	PIPING_EQUIP, HVAC_EQUIP, ELEC_EQUIP tables format 
*
*  last_class | 	Ex: the last classification listed in PID_EQUIP 
*  EQP_NUMBER | 
*  EQP_DESCR | 
*  MACRO_NAME | 
*  EQP_FAMILY | 
*  EQP_PARTNO | 
*  EQP_PARTREV | 
*  EQP_LOCATION 
*
*  Those tables are listed in "discpl_table" column of PID_EQUIP (master) table.
*  Their "last_class" column corresponds to an entry in FI_TBL_LIST_1_2_3
*
*-------------------------------------------------------------------------------
*	"equip_list" 	table format same as PIPING_EQUIP, no last_class column.
*
*-------------------------------------------------------------------------------
*  NOTE: To deal with the legacy data, the old "equip_list" table 
*	 (now PID_EQUIP_LIST_TBL) is treated as another discpl_table. 
*	 While "normal" discpl_tables have "last_class" column, 
*	 "equip_list" doesn't! 
*
*	 The difference is in the vdb$RisSelect query in VRPID_LoadFromField.
* 
* 	 We use PID_EQUIP_LIST_TBL if PID_EQUIP_MASTER_TBL can not be found.
*
*  Note: Expandable feature: VRStorage (VRStorage.I) stores the ID of:
*		- placed equipment (deleted if Modify Pid Eq) VRPidPlaceEquip.
*		- equipment selected for replacement VRPidSelectEquip.
*		- equipment located for modification VRPidModifyEquip.
*	 Those can be use by outside API to place/manipulate list of PID Eqpts.
*******************************************************************************/
  char                          **EquipList, 
                                **EquipTable;

  char				MasterTable[21];
  char				EquipDescr[80];

  int				num_cols,	
				num_rows,
				lst_rows,
				lst_cols;

  struct GRid			EquipToModify;

}

implementation

#include <stdio.h>
#include <string.h>
#include "FI.h"
#include "gr.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRDbParamDef.h"
#include "vrparameters.h"
#include "VRattr_def.h"
#include "VRact_params.h"
#include "VRchgattrdef.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRmsg.h"
#include "VRMcForm.h"
#include "asmacros.h"
#include "asbox.h"
#include "VREquipForm.h"
#include "VREquipment.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "VRdef.h"
#include "VRmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepmacros.h"
#include "acrepdef.h"
#include "nddef.h"
#include "VRPid.h"
#include "VDScheckdef.h"
#include "VDSutil.h"

#include "vrpdu_pto.h"
#include "vrco_pto.h"

#include "vdbmacros.h"
#include "vrdbgmacros.h"
#include "VDmem.h" 
#include "VREquipForm.h"

%safe
#include "VX_FIproto.h"
%endsafe


#define AS_DEBUG
#define	DYNCOMP			10
#define DYN_ON			11

/* Command type definitions  */
#define         VR_PLACE_EQUIPMENT      0
#define         VR_SELECT_EQUIPMENT     1
#define         VR_MODIFY_EQUIPMENT     2

extern int	VRStorage(); 
extern int 	VRPidEquipReplace(); 
extern int 	VRGadgetDefState();
extern int	VRCleanStringFromSpaces(); 
extern int	VRTestPidEquip25(); 

from	NDnode		import	NDchg_state,
				ASreturn_go; //added by alwin
from	GRgraphics	import	GRdelete,
				GRdisplay, GRchgprops;
from	ACrg_collect	import	ACset_list_attribute,
				AClist_attribute;

from	VREquipment	import	VRPlaceNozzleFeet,
				VRReplace,
				VRUpdateDynAttr;

from	ACdb_info	import	ACset_db_info;

from	VRGeneric	import	VRChgParams,
				VRGetParams,
				VRGetOrigCoor,
				VRGetMatrix,
				VRConnect;

from	GRgencs		import	GRgetmatrix;
from	ACncpx		import	ACgive_structure;
from    ACcpx           import  find_macro; //added by alwin
from    ACcpx_defn      import  ACgive_feet_desc; //added by alwin

extern	GRclassid	OPP_ACrg_collect_class_id; 
extern	GRclassid	OPP_ACdyn_col_class_id; 


state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "ECmsg.h"
#include "VRco.h"
#include "VRsketchdef.h"
#include "VRDbStruct.h"
#include "lc.h"
#include "VREquipForm.h"

#define	DYNCOMP			10
#define DYN_ON			11

/* ======================================================================== */

state main

   on CMD_TYPE = 0 do   message     "Place PID Equipment" 	state start
   on CMD_TYPE = 1 do   message     "Select PID Equipment" 	state start
   on CMD_TYPE = 2 do	message     "Modify PID Equipment" 	state start

   on ELSE	   do	message	    "Unknown command" 		state terminate

/* ======================================================================== */
 
state start
   execute VREraseForms( &me->ret)  

   on ELSE 	
		do VRInitInstance(&me->ret)
            	do VRTestRep(&me->ret)
                on RETURN_CODE = VRNOT_OK   do VRcleanup        state terminate

                on CMD_TYPE = 2                                 state LOCATE_OLD
								state select 


/* ======================================================================== */

state LOCATE_OLD
 
        prompt                  "Locate PID Equipment to modify"
        dynamics                off
        locate_eligible         "VREquipment"
        locate_owner            "LC_RIGID_OWNER | LC_RIGID_COMP |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER"
        filter                  locate
 
 
   on EX_DATA   do VRGetEquip(&me->ret, 2) 			
	   	   on RETURN_CODE = VRNOT_OK
			do status_key VR_E_NotPidEquip		state terminate
								state MODIFY

   on ELSE							state terminate 

/* ======================================================================== */
state MODIFY
        execute VRInitForm ( &me->ret, VRPidModifyForm)
 
        dynamics                off
        filter                  get_event
 
   on EX_FORM_FINISHED                                          state start
 
   on VR_REPLACE                                                state select
 

   on ELSE							state .

/* ======================================================================== */

state select
	execute VRInitForm (&me->ret, VRPidSelectForm) 

	prompt	"Select PID Equipment/Key in (Table, EqpNum)/MoveOn to locate"
        dynamics                off
        filter                  get_event


   on EX_STRING or EX_CHAR     
	do VRGetEquipByName( &me->ret)
	   on RETURN_CODE = VRNOT_OK  
			do status "Invalid Input" 		state .

	   do VRPutResponse( EX_FORM_FINISHED )			state . 


   on EX_FORM_FINISHED

	on CMD_TYPE = 1						state terminate

	do VREvaluateEquip(&me->ret)
	   on RETURN_CODE = VRNOT_OK  				state .

	   on RETURN_CODE = VRUSERPARAM
                        do VRUpdateForm(&me->ret)
			do VRPutResponse( EX_FORM_FINISHED)	state .

	   on CMD_TYPE = 2	do VRPutResponse( EX_DATA)	state PLACE_DYN

	   on RETURN_CODE = DYN_ON                 		state PLACE_DYN
								state GET_REF

    on EX_BACK_UP                                   		state -

    on EX_RJT_MOVEON 	do VREraseForms (&me->ret)      	state LOC_CMP

    on CLEAR_STACK						state terminate 

    on ELSE							state terminate

/* ======================================================================== */
state GET_REF

	prompt_key		VR_P_IdentifyReferencial
	dynamics		off
	locate_eligible		"+GRgencs"
	locate_owner         	"LC_RIGID_OWNER|LC_FLEX_COMP|LC_REF_OBJECTS"
 	filter			locate


   on EX_DATA		do VRGetRef(&me->ret)
			do VRPlaceEquip(&me->ret)
			do VRResetForm(	&me->ret)	state start

   on EX_FORM_FINISHED					state .

   on EX_RJT_MOVEON					state .

   on EX_BACK_UP					state -

   on ELSE						state .

/* ======================================================================== */

state PLACE_DYN

	prompt_key		VR_P_IdentPointOrRef
	dynamics		DYNCOMP
   	filter                  get_event


   on EX_DATA		do VRGetPoint(&me->ret)	
			do VRRotateComponent(&me->ret)
			do VRPlaceEquip(&me->ret)
			do VRResetForm(	&me->ret)		

			on CMD_TYPE = 2		
				do VRPidEqpReplace            	state terminate
								state start	
			
   on EX_RJT_MOVEON						state GET_REF

   on EX_BACK_UP						state -

   on EX_STRING or EX_CHAR					state . 

   on EX_FORM_FINISHED						state .

   on EX_RESTART						state . 

   on ELSE							state terminate

/* ======================================================================== */
/* This state locates source component for Modification of Existing equipment.*/

state LOC_CMP

	prompt_key		VR_P_IdComp
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VREquipment"
        locate_owner            "LC_RIGID_OWNER | LC_RIGID_COMP |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER |LC_REF_OBJECTS"
 	filter			locate


   on CMD_TYPE = 1						state - 


   on EX_DATA	
	do VRGetEquip(&me->ret,1)
       	do VREvaluateEquip(&me->ret)
       	   on RETURN_CODE = VRNOT_OK                            state .

           on RETURN_CODE = VRUSERPARAM
                    	do VRUpdateForm(&me->ret)		state .
 
	   on CMD_TYPE = 2      do VRPutResponse( EX_DATA)	state PLACE_DYN

           on RETURN_CODE = DYN_ON                              state PLACE_DYN
								state GET_REF

   on EX_FORM_FINISHED						state .

   on EX_RJT_MOVEON						state .

   on EX_BACK_UP						state -

   on ELSE							state terminate

/* ======================================================================== */
/* 
state EVALUATE
 
        dynamics                off
        filter                  get_event
 
        on EX_FORM_FINISHED    
                on CMD_TYPE    = 1                              state terminate
 
                do VREvaluateEquip(&me->ret)
 
                        on RETURN_CODE = VRNOT_OK               state -
                        on RETURN_CODE = VRUSERPARAM   
                                do VRUpdateForm(&me->ret)       state .
                        on RETURN_CODE = DYN_ON                 state PLACE_DYN
                                                                state GET_REF
 
        on EX_STRING or EX_CHAR
                do VRGetEquipByName( &me->ret )
                        on CMD_TYPE     = 1             	state terminate
		        on RETURN_CODE = VRNOT_OK               state .
           		do VRPutResponse( EX_FORM_FINISHED )    state .

                                                        state .
 
        on EX_RJT_MOVEON
                on CMD_TYPE     = 1
                        do VREraseForms (&me->ret)      state LOC_CMP
                                                        state .
 
        on EX_BACK_UP                                   state -
 
        on ELSE                                         state terminate
 
*/

/* ======================================================================== */

state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE						state -

/* ======================================================================== */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method init

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action init
{
  IGRint		i;
  struct GRid		TempId;

SetProc(init); Begin

  /*| call VDB_LOCATE.init with respect to message */
  status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VDB_LOCATE.init( type, str_ptr ),
			targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  TempId.objid = NULL_OBJID; 
  status = VRStorage((char *) &TempId, VRPidPlaceEquip,  NULL, 1);
  status = VRStorage((char *) &TempId, VRPidSelectEquip, NULL, 1);
  status = VRStorage((char *) &TempId, VRPidModifyEquip, NULL, 1);

/* KDD Initialize. */
  me->form_ptr 		= me->forms[3].form_ptr;  
  me->num_cols 		= 4;
  me->num_rows 		= 0;   

  me->lst_cols 		= 3;
  me->lst_rows 		= 0; 

  me->EquipList		= NULL; 
  me->EquipTable	= NULL;

  if ( me->EquipTable ) {
     vdb$RisFreeBuffer ( buffer    = me->EquipTable,
                         size      = me->num_cols * me->num_rows );
     me->EquipTable = NULL;
  }

  status = vdb$RisSelect( select      = "discpl_table, class1, class2, class3",
			  table_name  = PID_EQUIP_MASTER_TBL,
			  where	      = "discpl_table IS NOT NULL",
			  order	      = "1, 2, 3, 4", 
			  numselect   = me->num_cols,
			  p_numrows   = &me->num_rows,
			  p_buffer    = &me->EquipTable );
  if ( !(status&1) || !me->EquipTable ) {	
     UI_error("Table " PID_EQUIP_MASTER_TBL " not found in DB. Switch to "
				PID_EQUIP_LIST_TBL); 

     /* Create an entry in me->EquipTable for PID_EQUIP_LIST_TBL */

     if ( me->EquipTable ) {
        vdb$RisFreeBuffer ( buffer    = me->EquipTable,
                            size      = me->num_cols * me->num_rows );
        me->EquipTable = NULL;
     }

     me->num_rows = 1;
     i = sizeof( char *) * (me->num_rows * me->num_cols);
     me->EquipTable     = (char **) om$malloc( size = i);
     me->EquipTable[0]  = om$malloc( size = strlen(PID_EQUIP_LIST_TBL) + 1);
     strcpy(me->EquipTable[0], PID_EQUIP_LIST_TBL);

     for (i = 1; i < me->num_cols; i++) {
        me->EquipTable[i]  = om$malloc( size = 1);
        strcpy(me->EquipTable[i], "");
     }
     strcpy(me->MasterTable, PID_EQUIP_LIST_TBL); 
  }
  else {
     strcpy(me->MasterTable, PID_EQUIP_MASTER_TBL); 
  }

  me->list_present = TRUE;

wrapup:

End;
}


/**************************************************************************/
action VRPutResponse( int 	response)
{
 
_put_response( resp = response);

}

/**************************************************************************/
action VRPidEqpReplace
{
struct GRid		EquipId;
IGRlong			retcode;

SetProc(VRPidEqpReplace); Begin

  status = 1; 

  if ( me->EquipToModify.objid == NULL_OBJID) { 
	UI_status("PID Equipment to modify not located.");
	printf("PID Equipment to modify not located.\n");
	goto wrapup;
  }

  if ( me->CmpId.objid == NULL_OBJID) { 
	UI_status("New PID Equipment not created.");
	printf("New PID Equipment not created.\n");
	goto wrapup;
  }

  status = FIg_get_state( me->forms[4].form_ptr, FI_RETAIN_PARAMS,
							  ((int *) &retcode) );
    /* This is admittedly bad coding. The retcode was intended for return code
     * purposes only. Here, I have used it as a "Trojan horse" to send the
     * value of check box of the Modify Equipment form to a method of the
     * VRequipment class. This was done for service pack purposes. Other
     * developers to kindly refrain from this kind of coding.
     *						Anand for CR 179900908 */
  status = om$send ( msg     = message VREquipment.VRReplace
                                        ( &retcode, me->CmpId, &me->ModuleInfo),
                    targetid = me->EquipToModify.objid,
                    targetos = me->EquipToModify.osnum);
  as$status();

  /* Prevent NewEquip from deletion if VRReplace failed */
  if ( !( status &1) ) {me->CmpId.objid = NULL_OBJID; }

__DBGpr_obj("Temporary Equipment to be deleted", me->CmpId);
__DBGpr_obj("Replaced Equipment               ", me->EquipToModify); 

  if ( me->CmpId.objid != NULL_OBJID) { 
  	status = om$send ( msg     = message GRgraphics.GRdelete
					( &retcode, &me->ModuleInfo),
                          targetid = me->CmpId.objid,
                          targetos = me->CmpId.osnum);
  	as$status();

	me->CmpId.objid = NULL_OBJID;
  }
 
wrapup:
End;
}


/**************************************************************************/
action VRInitForm( IGRlong	*msg;
		   int		FormIndex)
{
struct GRid		OldEquip, SysParId, UsrParId, MisParId;
struct ACrg_coll	*SysAttr = NULL, *UsrAttr = NULL, *XAttr = NULL, 
			*DynAttr = NULL, *AddAttr = NULL;

struct ACrg_coll        Collection[8];
struct VRdbEquipPart    Part;


	char		**buffer = NULL; 

        char            EquipNumber[64]={""},        
                        TableName[64]={""},        
                        MacroName[64]={""},
			EquipDescr[64]={""},
                        EqpFamilly[64]={""},
                        EqpPartRev[64]={""},
                        macro_lib[128]={""};


	int		i, j, num_rows,
			NumSysAttr = 0, NumUsrAttr = 0, NumXAttr = 0, 
			NumDynAttr = 0, NumAddAttr = 0;

	IGRlong		retcode, sts; 
	Form		form;

	double		PidScale = 1.0; 


SetProc(VRInitForm); Begin

  status = 1;
  me->ret = OM_S_SUCCESS;


  switch ( FormIndex ) {
  case VRPidModifyForm:

/*-----------------
1.  Initialize VRModPidEqp form
-------------------*/

	form = me->forms[4].form_ptr;
	FIf_reset( form); 
 
	me->ret = VRNOT_OK;

/*-----------------  Get the located Equipment to modify.  -------------------*/
	OldEquip = me->EquipToModify;
	if (OldEquip.objid == NULL_OBJID) {
	   UI_status("PID Equipment not selected"); 
	   goto wrapup; 
	}

/*----------------- Get the system and user collections.  -------------------*/
  	sts = om$send( msg   = message VRGeneric.VRGetParams
                                    (&retcode, &SysParId, &UsrParId, &MisParId),
	            targetid = OldEquip.objid,
	            targetos = OldEquip.osnum);
	as$status(sts = sts, action = GOTO_VALUE, value = wrapup);

	/*------- Test if PID Equipment is prior Route 2.5 -----------*/
	sts = VRTestPidEquip25( OldEquip); 

        if ( MisParId.objid == NULL_OBJID) {
           MisParId.osnum = UsrParId.osnum;
 
           sts = om$construct( classid = OPP_ACrg_collect_class_id,
                               p_objid = &MisParId.objid,
                               osnum   = MisParId.osnum);
           as$status( sts = sts, action = GOTO_VALUE, value = wrapup );
 
           sts = om$send( msg   = message NDnode.NDchg_state ( ~0,ND_DEL_NO_CH),
                       targetid = MisParId.objid,
                       targetos = MisParId.osnum);
           as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
 
           sts = om$send( msg   = message VRGeneric.VRChgParams
                                    (&retcode, &SysParId, &UsrParId, &MisParId),
                       targetid = OldEquip.objid,
                       targetos = OldEquip.osnum);
           as$status(sts = sts, action = GOTO_VALUE, value = wrapup);
        }


        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_MERGE_COLL,
                                p_InputCollectionId   = &SysParId,
                                OutNumPar             = &NumSysAttr,
                                OutParList            = &SysAttr );
 
 
        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_MERGE_COLL,
                                p_InputCollectionId   = &UsrParId,
                                OutNumPar             = &NumUsrAttr,
                                OutParList            = &UsrAttr );
 
 
        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_MERGE_COLL,
                                p_InputCollectionId   = &MisParId,
                                OutNumPar             = &NumXAttr,
                                OutParList            = &XAttr );

/*---------- Get vital display & DB info from the System Collection. ---------*/

	for ( i = 0; i < NumSysAttr; i=i+1 ) {
	      if (!strcmp( SysAttr[ i ].name , VR_N_PID_EQP_NUMBER ))
                        strcpy( EquipNumber, SysAttr[ i ].desc.value.att_txt);
 
	      if (!strcmp( SysAttr[ i ].name , "eqp_family" ))
                        strcpy( EqpFamilly,  SysAttr[ i ].desc.value.att_txt);
 
	      if (!strcmp( SysAttr[ i ].name , "eqp_partrev" ))
                        strcpy( EqpPartRev,  SysAttr[ i ].desc.value.att_txt);
 
	      if (!strcmp( SysAttr[ i ].name , VR_N_MACRO_NAME_AN ))
                        strcpy( MacroName,  SysAttr[ i ].desc.value.att_txt);
 
	      if (!strcmp( SysAttr[ i ].name , VR_N_TABLE_NAME_DB ))
                        strcpy( TableName,  SysAttr[ i ].desc.value.att_txt);

              if (!strcmp( SysAttr[ i ].name , VR_N_PID_SCALE_DB )) {
                 PidScale =  SysAttr[i].desc.value.att_exp;
	         status = VRGadgetDefState( (char *) &PidScale, -EQUIP_SCALE,1);
	      }

	}

/*----------------- Load DynAttr and AddAttr Collections.  -------------------*/

	NumDynAttr = 0; 
	for ( i = 0; i < NumXAttr; i=i+1 ) {
	    if (       ( XAttr[ i ].desc.type == AC_ATTRIB_TEXT ) &&
	       (!strcmp( XAttr[ i ].desc.value.att_txt , "DB_default" )) )  {
 
                if (NumDynAttr == 0) DynAttr = _MALLOC( 1, struct ACrg_coll);
                DynAttr = _REALLOC ( DynAttr, NumDynAttr + 1, struct ACrg_coll);
                DynAttr [ NumDynAttr ] = XAttr[ i ];
                NumDynAttr = NumDynAttr + 1;
      	    }
  	}
  	if ( XAttr) { _FREE ( XAttr ); XAttr = NULL;} NumXAttr = 0; 

  	if ( NumDynAttr == 0 ) {
	   sts = VRdbGetEqOccur(&retcode,TableName,EquipNumber,NULL,&Part,NULL);
 
           VDSget_eqp_library ( Part.Familly, macro_lib );
           VREQ_set_att_list( Part.Familly, Part.PartNb, Part.PartRev, NULL,
                                                &DynAttr, NULL, &NumDynAttr);
 
      	   if ( NumDynAttr > 0 ) { 
		NumXAttr = NumDynAttr;
          	XAttr = _MALLOC( NumXAttr, struct ACrg_coll);
	   }
 
           for ( i = 0; i < NumXAttr; i=i+1 ) {
              strcpy( XAttr[ i ].name, DynAttr[ i ].name);
              XAttr[ i ].desc.type = AC_ATTRIB_TEXT ;
              strcpy( XAttr[ i ].desc.value.att_txt , "DB_default" ) ;
           }
 
          VR$ModifyCollection(p_msg                = &retcode,
                             Operation             = VR_MERGE_COLL,
                             p_ParamsListToModify  = XAttr,
                             NbParamsToModify      = NumXAttr,
                             p_OutputCollectionId  = &MisParId );
      	  if ( XAttr) { _FREE ( XAttr ); XAttr = NULL;} NumXAttr = 0; 
  	}


        if ( AddAttr) { _FREE ( AddAttr ); AddAttr = NULL;} NumAddAttr = 0; 
 
        for (    i = 0; i < NumUsrAttr; i = i+ 1 ) {
           for ( j = 0; j < NumDynAttr; j = j+ 1 ) {
              if ( !strcmp( DynAttr[ j ] .name , UsrAttr [ i ] .name ) ) {
                      DynAttr[ j ] = UsrAttr [ i ];
                      break;
              }
           }
 
           if ( j == NumDynAttr ) {
              if (NumAddAttr == 0) AddAttr = _MALLOC( 1, struct ACrg_coll);
              AddAttr = _REALLOC ( AddAttr, NumAddAttr + 1, struct ACrg_coll);
              AddAttr [ NumAddAttr ] =  UsrAttr [ i ] ;
              NumAddAttr = NumAddAttr + 1 ;
           }
        }
 
        if ( UsrAttr) { _FREE ( UsrAttr ); UsrAttr = NULL;} NumUsrAttr = 0; 


/*------------ Retrieve from DB Equipment description. -----------*/
{
	char		where[128];

	sprintf(where, "eqp_number = '%s'", EquipNumber);

     	status = vdb$RisSelect( select      = "eqp_descr",
                    		table_name  = (char *) TableName,
                    		where       = where,
                    		numselect   = 1,
                    		p_numrows   = &num_rows,
                    		p_buffer    = &buffer );
 
	if ( (status & 1) && (buffer) ) strcpy(EquipDescr, buffer[0]); 

	vdb$RisFreeBuffer ( buffer    = buffer,
                            size      = 1 * num_rows );
       	buffer = NULL;
}


/*---------------------- Populate the form. *----------------------*/

        sts = VR$DispCollAttr2( pForm   = form,
                                Gadget  = FI_DYN_ATTRIB,
                                pNbAttr = &NumDynAttr,
                                ListAttr= DynAttr );
       
        sts = VR$DispCollAttr2( pForm   = form,
                                Gadget  = FI_ADD_ATTRIB,
                                pNbAttr = &NumAddAttr,
                                ListAttr= AddAttr );
      
        FIfld_set_text(form, FI_EQUIP_DESCR, 0, 0, (char *) EquipDescr, 0);
        FIfld_set_text(form,FI_EQUIP_NUMBER,0,0,(char *)EquipNumber,0);
        FIfld_set_text(form, FI_EQUIP_MACRO, 0, 0,(char *)MacroName,0);
       
        FIfld_set_default_text( form, FI_EQUIP_NUMBER, 0, 0,
                                         (char *) EquipNumber, FALSE);
        FIfld_set_default_text( form, FI_EQUIP_MACRO, 0, 0,
                                         (char *) MacroName, FALSE);
        FIfld_set_default_text( form, FI_EQUIP_DESCR, 0, 0,
                                         (char *) EquipDescr, FALSE);
       

/*---------------------- Display the form.  *----------------------*/

        FIf_display( form );

	me->ret = OM_S_SUCCESS;

	break;


/*-----------------
2.   Load VRPidEquip form.
-------------------*/
  case VRPidSelectForm:

	me->form_ptr          = me->forms[3].form_ptr;

	/* call the customized form reset function */
  	status = om$send( msg      = message VRPlEquip.VRResetForm( ),
	                  targetid = my_id );
	as$status();
 
	/* Set up the data links */
  	FIg_set_pass_data( me->form_ptr, FI_EQUIP_TABLE, FI_STORE_TABLE);
  	FIg_set_pass_data( me->form_ptr, FI_TBL_LIST_1, FI_STORE_LIST_1);
  	FIg_set_pass_data( me->form_ptr, FI_TBL_LIST_2, FI_STORE_LIST_2);
  	FIg_set_pass_data( me->form_ptr, FI_TBL_LIST_3, FI_STORE_LIST_3);
 
	/* Hide the store gadgets */
  	FIg_erase( me->form_ptr, FI_STORE_TABLE);
  	FIg_erase( me->form_ptr, FI_STORE_LIST_1);
  	FIg_erase( me->form_ptr, FI_STORE_LIST_2);
  	FIg_erase( me->form_ptr, FI_STORE_LIST_3);
 
 
	/* Change the message on one of the sub forms to "Dynamic Attributes" */
  	FIg_erase  (me->forms[2].form_ptr, 16);
  	FIg_display(me->forms[2].form_ptr, 11);
 
	/* Set the proper title on the form and P&ID scale gadget */
	if  (me->mytype == VR_SELECT_EQUIPMENT) {
	     FIg_set_text  (me->form_ptr, FI_FORM_TITLE,"Select PID Equipment");
	     FIfld_set_default_text(me->form_ptr, FI_FORM_TITLE, 0, 0,
                                        "Select PID Equipment" ,FALSE);

		    /* Below two lines moved into the body of this else
		     * condition by Anand for CR 179800598 */
	     FIg_disable( me->form_ptr, FI_ACCEPT);
	     FIg_disable( me->form_ptr, FI_EXECUTE);
	}
	else if (me->mytype == VR_MODIFY_EQUIPMENT)
	{
	     struct ACrg_coll	Collector;

	     FIg_set_text  (me->form_ptr, FI_FORM_TITLE,"Modify PID Equipment");
	     FIfld_set_default_text(me->form_ptr, FI_FORM_TITLE, 0, 0,
                                        "Modify PID Equipment" ,FALSE);

    /* Below lines added by Anand for CR 179800598 */
	     FIg_display( me->form_ptr, EQUIP_SCALE );
	     FIg_display( me->form_ptr, 17 );

	     status = om$send( msg   = message VRGeneric.VRGetParams
					     (&retcode, &SysParId, NULL, NULL),
		     targetid = me->EquipToModify.objid,
		     targetos = me->EquipToModify.osnum);
	     as$status(sts = status, action = GOTO_VALUE, value = wrapup);

	     strcpy( Collector.name, VR_N_PID_SCALE_DB);
	     Collector.desc.type = AC_ATTRIB_DOUBLE;
	     status = VRGetAttribute( &Collector, 1, &SysParId, NULL, 0);
	     __DBGpr_dbl(" Pid scale", Collector.desc.value.att_exp );
	     FIg_set_value( me->form_ptr, EQUIP_SCALE,
						Collector.desc.value.att_exp);
    /* Above lines added by Anand for CR 179800598 */
	}
	else {
	     FIg_display( me->form_ptr, EQUIP_SCALE );
	     FIg_display( me->form_ptr, 17 );
 
		    /* Below two lines moved into the body of this else
		     * condition by Anand for CR 179800598 */
	     FIg_disable( me->form_ptr, FI_ACCEPT);
	     FIg_disable( me->form_ptr, FI_EXECUTE);
	}

  	FIf_display( me->form_ptr );

  default:	break;

  }

wrapup:
        if ( SysAttr) { _FREE ( SysAttr ); SysAttr = NULL;}
        if ( UsrAttr) { _FREE ( UsrAttr ); UsrAttr = NULL;}
        if ( DynAttr) { _FREE ( DynAttr ); DynAttr = NULL;}
        if ( AddAttr) { _FREE ( AddAttr ); AddAttr = NULL;}
        if ( XAttr  ) { _FREE ( XAttr   ); XAttr   = NULL;}

End;
}


/**************************************************************************/
action VRTestRep
{
  int                   flag;
  struct GRid           TempId;


SetProc(VRTestRep); Begin

  me->ret = VRNOT_OK;

/** KDD + stop if the active representation is not P&ID ***/
  if ( ! bVR_IS_PID_ACTIVE ) {
     UI_status("Active representation must be P&ID.");
     goto wrapup;
  }

  if( ! bVR_IS_PID( me->cRep ) ) {
     UI_status("Abort: Object representation is not P&ID.");
     __DBGpr_int("Object", (int) my_id);
     goto wrapup;
  }

  /*| ----- Initialize Sys Collection  empty ----- */
  me->SysParamId.osnum = me->ModuleInfo.md_id.osnum;

  status =
  om$construct( classid = OPP_ACrg_collect_class_id,
                p_objid = &me->SysParamId.objid,
                osnum   = me->SysParamId.osnum,
                msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
  as$status( action = GOTO_VALUE, value = wrapup );
 
 
  /*| ----- Initialize Usr Collection  empty ----- */
  me->UsrParamId.osnum = me->SysParamId.osnum;

  status =
  om$construct( classid = OPP_ACrg_collect_class_id,
                p_objid = &me->UsrParamId.objid,
                osnum   = me->UsrParamId.osnum,
                msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
  as$status( action = GOTO_VALUE, value = wrapup );
 
 
  /*| ----- Initialize Missing Collection  empty ----- */
  me->MissParamId.osnum = me->UsrParamId.osnum;

  status =
  om$construct( classid = OPP_ACrg_collect_class_id,
                p_objid = &me->MissParamId.objid,
                osnum   = me->MissParamId.osnum,
                msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
  as$status( action = GOTO_VALUE, value = wrapup );


  me->CmpId.objid               = NULL_OBJID;
  me->EquipToModify.objid       = NULL_OBJID;
 
  me->EquipDescr[0]     = 0;
  me->EquipNumber[0]    = 0;



  me->ret = OM_S_SUCCESS;

wrapup:
End;
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*----------------------------
*	This method evaluates Equipment (after VRGetEquip). at the time of
*	calling me->SysParamId, me->UsrParamId, me->MissParamId must be ready.
------------------------------*/
action VREvaluateEquip 
{
  IGRlong 			retcode, msg;
  IGRint			NbMissingParams;
  IGRint			NbAttr;
  struct	ACrg_coll	Collection[VR_MAX_ATTR];
  struct	ACrg_coll	*p_MissingParamsList=NULL;
  IGRchar			MacroName[41]={""},
				TableName[41]={""};

  double			value=1.0;

  extern IGRint VREvaluateEquip();
  
SetProc( VRPlEquip.VREvaluateEquip); Begin

  me->ret = VRNOT_OK;

  if( ! bVR_IS_PID( me->cRep ) ) {
     UI_status("Active representation must be P&ID.");
     __DBGpr_int("Object", (int) my_id);
     goto wrapup;
  }

  /*| -- Initialize the component Symbology -- */
  me->Symb.display_attr = me->ActiveDisplay;
  me->Symb.level        = me->ActiveLevel;

  NbMissingParams = 0;

__DBGpr_obj("me->CmpId      ", me->CmpId); 
__DBGpr_str("me->EquipNumber",  me->EquipNumber);

/*** KDD MissParamId are used to store DB default parameters only. ****/

  status = VREvaluateEquip( 	&retcode,
				me->EquipNumber,
			 	&me->Symb,
				me->cRep, 
				&me->SysParamId,
				&me->UsrParamId,
				&me->MissParamId,
				&me->CmpId, 
				&NbMissingParams,
				&p_MissingParamsList,
				&me->ModuleInfo );

  __DBGpr_int("NbMissingParams", (int) NbMissingParams);
  __DBGpr_obj("me->CmpId      ", me->CmpId); 


  if (!(status & 0x01) || !(retcode & 0x01))
  {
    	ex$message( field   = ERROR_FIELD,
	    	    msgnumb = VR_E_ErrorEvaluation );
      	status = FIg_set_text(me->form_ptr, FI_MSG_FIELD,
						"Error during evaluation");
	
	if( me->CmpId.objid != NULL_OBJID )
	{
        	status = 
		om$send ( msg      = message GRgraphics.GRdelete( &retcode, 
							   &me->ModuleInfo),
		       	  senderid = my_id,
		       	  targetid = me->CmpId.objid,
		       	  targetos = me->CmpId.osnum);
		as$status();

		me->CmpId.objid = NULL_OBJID;
	}

    	me->ret = VRNOT_OK;
    	status =  OM_S_SUCCESS;
        goto wrapup;
  }
  else
  {
	struct ACdb_info	DbInfo;

	if ( bVR_IS_PID(me->cRep)) {
		DbInfo.quantity = PID_EQUIP_OBJ;
	}
	else {
		DbInfo.quantity = EQUIPMENT_OBJ;
	}

	status =
	om$send(msg = message ACdb_info.ACset_db_info
				( &retcode, &DbInfo),
			senderid = NULL_OBJID,
			targetid = me->CmpId.objid,
			targetos = me->CmpId.osnum);
	as$status();

        status = VRStorage((char *) &me->CmpId, VRPidPlaceEquip, NULL, 1);
  }

/*** Create or modify user collection after the evaluated return values 
*    Out since we work with P&ID only. 
*
*  if ( ! bVR_IS_PID(me->cRep)) {
*	status = 
*	om$send ( msg 	 = message VREquipment.VRUpdateDynAttr( &retcode, 
*						   	   &me->ModuleInfo),
*	    	senderid = NULL_OBJID,
*	    	targetid = me->CmpId.objid,
*		targetos = me->CmpId.osnum);
*	as$status();
*   }
***/

  me->ret = DYN_ON;
 
  if( NbMissingParams )
  {
	UI_status("Missing parameters");

	status =
  	VR$ModifyCollection( 	p_msg			= &retcode,
				Operation		= VR_UNION_COLL,
				p_ParamsListToModify	= p_MissingParamsList,
				NbParamsToModify	= NbMissingParams,
				p_OutputCollectionId	= &me->UsrParamId );

        me->ret = VRUSERPARAM;
	goto wrapup; 
  }

/*** KDD Allow Modification of the User Collection attributes ***/

  if  (me->mytype == VR_PLACE_EQUIPMENT) {

        status = VR$DispCollAttr2( pForm   = me->forms[2].form_ptr,
				   Gadget  = USER_ATTR_FLD,
				   pCollId = &me->UsrParamId );

  	FIg_set_text(me->forms[2].form_ptr,FI_MSG_FIELD,
					"User Parameters Collection");
  	FIf_display( me->forms[2].form_ptr );
  }

wrapup:

  if ( p_MissingParamsList) { _FREE( p_MissingParamsList ); }

End;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*-----------------------------
*	This method updates Sys, Usr, Mis collections, and me instances.
-------------------------------*/
action VRGetEquip( int *sts; IGRint Locate )
{
  IGRlong       	msg, retcode;
  IGRint		retmsg, FootIndex=-1;
  IGRint		NbOcc=0;
  IGRchar		Error[300];
  IGRchar		macro_lib[100];

  struct  GRid		EquipId, SysParId, UsrParId, MisParId;
  struct  ret_struct	AttrRst;
  struct  VRdbEquipDesc	OccLst;
struct ACrg_coll        Collection[8];


  char			where[64], **EquipDesc = NULL; 

  IGRchar		table[41]={""}, MacroName[41]={""};

  int			flag; 
  double		PidScale;

  IGRint  		VREQ_set_att();


SetProc(VRGetEquip); Begin

  macro_lib[0] = 0;
  me->ret = OM_S_SUCCESS;
  *sts    = OM_S_SUCCESS;

  if( Locate == 1 ) {
/*--------------
#  Equipment is located to be used as a template for placement/replacement.
*
*  Load the info needed in VREvaluateEquip method.
*  EquipNumber, Table, MacroName, PisScale gadgets of VRPidEquip form 
*  Very much like in form_notification case FI_ACCEPT (VRPidEquip)
----------------*/
  	status = dp$erase_hilite( msg   = &msg,
                             	  osnum = me->ModuleEnv.md_id.osnum);

	if( !bVR_IS_PID(me->cRep)) 
		{ me->ret = VRNOT_OK; *sts = VRNOT_OK; return OM_S_SUCCESS; }

	EquipId = me->event1.located_object[0].located_obj;
        status = VRStorage( (char *) &EquipId, VRPidSelectEquip, NULL, 1); 

        status = om$send( msg   = message VRGeneric.VRGetParams (&retcode,
                                      &SysParId, &UsrParId, &MisParId),
                       senderid = NULL_OBJID,
                       targetid = EquipId.objid,
                       targetos = EquipId.osnum);
        as$status();

/*--------- me->SysParamId	is	merged
	    me->UsrParamId	is 	union
	    me->MissParamId	is 	recreated 
---------*/

        VR$ModifyCollection( p_msg                 = &retcode,
                             Operation             = VR_CLEAR_COLL,
                             p_ParamsListToModify  = Collection,
                             NbParamsToModify      = 0,
                             p_OutputCollectionId  = &me->MissParamId );

	if ( me->mytype == VR_PLACE_EQUIPMENT  || 
	     me->mytype == VR_SELECT_EQUIPMENT ) { 

             VR$ModifyCollection( p_msg                 = &retcode,
                                  Operation             = VR_CLEAR_COLL,
                                  p_ParamsListToModify  = Collection,
                                  NbParamsToModify      = 0,
                                  p_OutputCollectionId  = &me->UsrParamId );

             VR$ModifyCollection( p_msg                 = &retcode,
                                  Operation             = VR_CLEAR_COLL,
                                  p_ParamsListToModify  = Collection,
                                  NbParamsToModify      = 0,
                                  p_OutputCollectionId  = &me->SysParamId );
        }

        VR$ModifyCollection( p_msg                 = &retcode,
                             Operation             = VR_MERGE_COLL,
                             p_InputCollectionId   = &SysParId,
                             p_OutputCollectionId  = &me->SysParamId );
 
        VR$ModifyCollection( p_msg                 = &retcode,
                             Operation             = VR_UNION_COLL,
                             p_InputCollectionId   = &UsrParId,
                             p_OutputCollectionId  = &me->UsrParamId );
 
        VR$ModifyCollection( p_msg                 = &retcode,
                             Operation             = VR_MERGE_COLL,
                             p_InputCollectionId   = &MisParId,
                             p_OutputCollectionId  = &me->MissParamId );
 
	me->EquipNumber[0] = 0;
        strcpy( Collection[0].name, VR_N_PID_EQP_NUMBER);
        Collection[0].desc.type = AC_ATTRIB_TEXT;
        status   = VRGetAttribute( Collection, 1, &me->SysParamId, NULL, 0);
        strcpy( me->EquipNumber, Collection[0].desc.value.att_txt);

 
	me->EquipDescr[0] = 0;
        strcpy( Collection[0].name, "eqp_descr");
        Collection[0].desc.type = AC_ATTRIB_TEXT;
        status	= VRGetAttribute( Collection, 1, &me->UsrParamId, NULL, 0);
        strcpy(me->EquipDescr, Collection[0].desc.value.att_txt);


/* KDD Jule 97. Henk's correction.
*	status = 
*	om$send ( msg = message ACncpx.ACgive_structure
*				( &retmsg, &FootIndex, "eqp_number",
*				&AttrRst, &me->ModuleEnv ),
*		  senderid = NULL_OBJID,
*		  targetid = EquipId.objid,
*		  targetos = EquipId.osnum );
*  	as$status ( action = RET_STATUS );
*
*	if( status&1 )
*		strcpy( me->EquipNumber, AttrRst.var.text_st.text_string );
*/ 

	goto wrapup; 
  }
  else if ( Locate == 2) {
/*-------------
*   Pid Equipment has been located for modification. store ID 
---------------*/
        status = dp$erase_hilite( msg   = &msg,
                                  osnum = me->ModuleEnv.md_id.osnum);
 
        if( !bVR_IS_PID(me->cRep)) 
		{ me->ret = VRNOT_OK; *sts = VRNOT_OK; return OM_S_SUCCESS; }

        me->EquipToModify = me->event1.located_object[0].located_obj;
        status = VRStorage((char *) &me->EquipToModify,VRPidModifyEquip,NULL,1);

__DBGpr_obj("Located Equipment for Modification", me->EquipToModify); 

	goto wrapup;
  }


/*--------------------- 
#  Retrieve Sys, and Usr Attributes from Form Interface. Load Missing Coll.
----------------------*/

  if( me->EquipNumber[0] )
  {
	OccLst.Desc[0] = 0;
	OccLst.Location[0] = 0;

	/* Set up (Clear) Collections */

        VR$ModifyCollection( p_msg                 = &retcode,
                             Operation             = VR_CLEAR_COLL,
                             p_ParamsListToModify  = Collection,
                             NbParamsToModify      = 0,
                             p_OutputCollectionId  = &me->MissParamId );
 
        if ( me->mytype == VR_PLACE_EQUIPMENT  ||
             me->mytype == VR_SELECT_EQUIPMENT ) {
 
             VR$ModifyCollection( p_msg                 = &retcode,
                                  Operation             = VR_CLEAR_COLL,
                                  p_ParamsListToModify  = Collection,
                                  NbParamsToModify      = 0,
                                  p_OutputCollectionId  = &me->UsrParamId );
 
             VR$ModifyCollection( p_msg                 = &retcode,
                                  Operation             = VR_CLEAR_COLL,
                                  p_ParamsListToModify  = Collection,
                                  NbParamsToModify      = 0,
                                  p_OutputCollectionId  = &me->SysParamId );
        }



        FIg_get_text( me->forms[3].form_ptr, FI_STORE_TABLE, table);
        FIg_get_text( me->forms[3].form_ptr, FI_EQUIP_MACRO, MacroName);
        FIg_get_value(me->forms[3].form_ptr, EQUIP_SCALE,    &PidScale);

__DBGpr_str("table                  ", table);
__DBGpr_str("MacroName              ", MacroName);
__DBGpr_dbl("PidScale               ", PidScale);

	status = VRdbGetEqOccList( &msg, table , me->EquipNumber,
					NULL, &NbOcc, &OccLst, Error );

	strcpy( me->EquipDescr, OccLst.Desc);

__DBGpr_int("NbOcc                  ", NbOcc);
__DBGpr_str("OccLst.Desc            ", OccLst.Desc); 

/*	if( !bVR_IS_PID(me->cRep))   */
	{
		struct	VRdbEquipPart	Part;
		struct  ACrg_coll	Collection[8], *p_Collection;
		IGRint			NumDynAttr=0, i;

		Part.Familly[0] = 0;
		Part.PartNb[0]	= 0;
		Part.PartRev[0]	= 0;

		status = VRdbGetEqOccur( &msg, table, 
					 me->EquipNumber, NULL, &Part, NULL );

		if( !(status&1) ) {
		    char text[128];

		    sprintf(text, "Table %s is empty", table);
                    status = FIg_set_text( me->forms[3].form_ptr, FI_MSG_FIELD,
                                        text);
		    UI_status( text);
		    me->ret = VRNOT_OK; *sts = VRNOT_OK; goto wrapup;
		}

		if( ! ( Part.Familly[0] ) ) {
                    status = FIg_set_text( me->forms[3].form_ptr, FI_MSG_FIELD,
                                        "family not specified" );
		    UI_status( "family not specified" );
		    me->ret = VRNOT_OK; *sts = VRNOT_OK; goto wrapup;
		}


__DBGpr_str("Part.Familly                ", Part.Familly);

		VDSget_eqp_library ( Part.Familly, macro_lib );
__DBGpr_str("macro_lib                   ", macro_lib   );

		status = ac$construct_path( mode    = AC_ADD_PATH | AC_INQ,
					    name    = macro_lib);

		if ( strlen(macro_lib) == 0 ) status = 0; 
	
		if( ! ( status&1 ) ) {
		    char		text[128];

		    sprintf(text, "Macro Library %s not found", macro_lib); 
                    status = FIg_set_text( me->forms[3].form_ptr, FI_MSG_FIELD,
                                        text);
		    UI_status(text); 
		    printf("ERROR: Macro <%s>, EquipNumber <%s>, table <%s>\n",
			 MacroName, me->EquipNumber, table ); 
		    me->ret = VRNOT_OK; *sts = VRNOT_OK; goto wrapup;
		}

__DBGpr_str("Part.PartNb                 ", Part.PartNb);
__DBGpr_str("Part.PartRev                ", Part.PartRev);

        	status = VREQ_set_att ( Part.Familly, Part.PartNb, Part.PartRev,
                                &me->SysParamId, &me->UsrParamId);

/*----------------
# KDD Sept 97. "eqp_partno" gets Part.PartNb value.
*              VR_N_PID_EQP_NUMBER attribute gets me->EquipNumber.
----------------*/

		strcpy( Collection[0].name, VR_N_MACRO_NAME_AN);
		Collection[0].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[0].desc.value.att_txt, MacroName);

		strcpy( Collection[1].name,"eqp_family" );
		Collection[1].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[1].desc.value.att_txt, Part.Familly);

		strcpy( Collection[2].name, "eqp_partrev");
		Collection[2].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[2].desc.value.att_txt, Part.PartRev);

		strcpy( Collection[3].name, "eqp_partno");
		Collection[3].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[3].desc.value.att_txt, Part.PartNb);

		strcpy( Collection[4].name, VR_N_PID_EQP_NUMBER);
		Collection[4].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[4].desc.value.att_txt, me->EquipNumber);

		strcpy( Collection[5].name, VR_N_TABLE_NAME_DB); 
		Collection[5].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[5].desc.value.att_txt, table);

		strcpy( Collection[6].name, VR_N_PID_SCALE_DB ); 
		Collection[6].desc.type = AC_ATTRIB_DOUBLE;
		Collection[6].desc.value.att_exp = PidScale;

                if ( MacroName[0] =='\0'  || me->EquipNumber[0] == '\0' ||
		     table[0]     =='\0' ) {
                   UI_status("MacroName or EquipNumber or Table are missing");
                   printf("MacroName or EquipNumber or Table are missing\n");
		   me->ret = VRNOT_OK; *sts = VRNOT_OK; 
                   status =  0;
                   goto wrapup;
                }

		status =
  		VR$ModifyCollection(p_msg 		 = &msg,
				    Operation 		 = VR_MERGE_COLL,
				    p_ParamsListToModify = Collection,
				    NbParamsToModify 	 = 7,
				    p_OutputCollectionId = &me->SysParamId );


/*------------------------------- KDD July 97
*  We separate the User Collection in two: Dynamic and Additional.
*  PID Equipment needs to know names of Dynamic (DataBase Default) Parameters.
*  Attributes in the Missing Collection with value "DB_default" are Dynamic.
*  "Modify PID Equipment" command may change ONLY the value of Dynamic 
*  attributes, and value+name of Additional attributes. 
-------------------------------*/
                status = om$send( msg    = message ACrg_collect.AClist_attribute
                                                  (&msg, 0, NULL, &NumDynAttr ),
                                targetid = (me->UsrParamId).objid,
                                targetos = (me->UsrParamId).osnum );
 
		if( NumDynAttr > 0 )
		{
		  p_Collection = _MALLOC( NumDynAttr, struct ACrg_coll);
                  __CheckPtr( p_Collection, "Memory Allocation failed ",wrapup);

		  status = 
		  om$send( msg    = message ACrg_collect.AClist_attribute
				  (&msg, NumDynAttr, p_Collection, &NumDynAttr),
                                targetid = (me->UsrParamId).objid,
                                targetos = (me->UsrParamId).osnum );
 
		  for ( i = 0; i < NumDynAttr; i++ ) {
		      p_Collection[i].desc.type = AC_ATTRIB_TEXT;
		      strcpy( p_Collection[i].desc.value.att_txt ,"DB_default");
		  }
                   
		  status =
		  VR$ModifyCollection(p_msg                = &msg,
                                    Operation            = VR_MERGE_COLL,
                                    p_ParamsListToModify = p_Collection,
                                    NbParamsToModify     = NumDynAttr,
                                    p_OutputCollectionId = &me->MissParamId );
 
		  _FREE ( p_Collection );
		}


/*----- Aug 97 Clark B. requested "n_itemdesc" in the user collection. 
* 9-97 Out as per Jeff's recommendation. 
* Can be included in the default DB parameters.
*
*                sprintf( where, "n_itemname = '%s'", Part.PartNb);
* 
*                status = vdb$RisSelect(   select      = "n_itemdesc",
*                                          table_name  = Part.Familly,
*                                          where       = where,
*                                          numselect   = 1,
*                                          p_numrows   = &NbOcc,
*                                          p_buffer    = &EquipDesc );
* 
*                if ( (status&1) && EquipDesc ) {
*                     strcpy( Collection[ 0 ].name, "n_itemdesc");
*                     Collection[ 0 ].desc.type = AC_ATTRIB_TEXT;
*                     strcpy( Collection[ 0 ].desc.value.att_txt, EquipDesc[0]);
* 
*                     status =
*                     VR$ModifyCollection(p_msg           = &msg,
*                                    Operation            = VR_MERGE_COLL,
*                                    p_ParamsListToModify = Collection,
*                                    NbParamsToModify     = 1,
*                                    p_OutputCollectionId = &me->UsrParamId );
*                }
*
*                if ( EquipDesc ) {
*                        vdb$RisFreeBuffer ( buffer    = EquipDesc,
*                                            size      = 1 * NbOcc );
*                        EquipDesc = NULL;
*                }
*-------*/

#ifdef MY_DEBUG
  printf("UsrParamId fill = %d %d \n",
         me->UsrParamId.objid, me->UsrParamId.osnum);
  printf("SysParamId fill = %d %d \n",
        me->SysParamId.objid, me->SysParamId.osnum);
#endif
	}
        SMVA_enable( me->forms[3].form_ptr, 1, FI_ACCEPT );

  }

wrapup:

End;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRGetRef
{
  IGRlong       msg;
  struct  GRid  RefId, SRefId;

SetProc(VRGetRef); Begin

  /* ----- Get located referencial  ----- */
  RefId = me->event1.located_object[0].located_obj;

  status = dp$erase_hilite ( msg   = &msg,
                             osnum = me->ModuleEnv.md_id.osnum);

  /*| -- Take matrix from the located component that will be replaced -- */
  if( RefId.objid != NULL_OBJID )
  {  
	IGRshort	nIndex=1;
	IGRshort	nCptNum=1;

	status = as$make_source( go_grid = RefId,
				 mod_env = &me->event1.located_object[0].module_info,
				 as_os   = me->ModuleInfo.md_id.osnum,
				 as_grid = &SRefId);
  	as$status ();

	status = 
	om$send( msg = message VRGeneric.VRConnect(	&msg, &SRefId,
							nIndex, nCptNum, 
							&me->ModuleEnv ),
		senderid = NULL_OBJID,
		targetid = me->CmpId.objid,
		targetos = me->CmpId.osnum );
	as$status ();

        status =
        om$send( msg      = message GRgencs.GRgetmatrix( &msg, me->CmpMatrix ),
                 targetid = RefId.objid,
                 targetos = RefId.osnum );
	as$status ();
 
	status = VR$OrientComp( p_retmsg = &msg,
		       	  	p_CmpId  = &me->CmpId,
		       	  	Matrix   = me->CmpMatrix,
		       	  	p_MdEnv  = &me->ModuleInfo
	              		);
	

  	if( ! ( status & 1 & msg ) )
  	{
		me->ret = VRNOT_OK;
		return OM_S_SUCCESS;
  	}
  }

End;
}
/*************************************************************************/
action VRPlaceEquip
{
  IGRlong		msg;

SetProc(VRPlaceEquip); Begin

  if( me->CmpId.objid != NULL_OBJID )
  {
	IGRint			i,NbNozzle=0;
	enum 	GRdpmode	Mode;
	struct	GRid		*NozzleIds=NULL; //changed to pointer

	__DBGpr_obj("me->CmpId           =", me->CmpId);

        /* added by alwin for TR179802498 */
        {
          IGRint        NumFeet=0;
          struct GRid   GraphicId, DefId;
	  struct myfeet	*FeetDesc=NULL; //added to prevent crash. Alwin

          status =
          om$send( msg      = message NDnode.ASreturn_go
                                        ( &GraphicId, NULL, NULL),
                   targetid = me->CmpId.objid,
                   targetos = me->CmpId.osnum );
          as$status( action = RET_STATUS );

          if( GraphicId.objid == NULL_OBJID )
          {
             End
             return OM_E_INVARG;
          }

          /*| ----- Get definition of the graphic macro ----- */
          status = om$send (    msg      = message ACcpx.find_macro ( &DefId ),
                                targetid = GraphicId.objid,
                                targetos = GraphicId.osnum );

          /*| ----- Get feet names from definition ----- */
          status =
          om$send( msg      = message ACcpx_defn. ACgive_feet_desc
                                                ( &NumFeet, &FeetDesc ),
                 targetid = DefId.objid,
                 targetos = DefId.osnum );

          /* May be all the feets are not "nozzle", but still to be on the safe
          side it's better to allocate the memory for all. Previously we had a 
	  hard coded limit of 20, which will restrict the Equipment macro to 
	  only 20 Nozzle feets. Alwin */

          if( NumFeet )
          {
            NozzleIds = _MALLOC( NumFeet, struct GRid );
            __CheckPtr( NozzleIds, "Memory Allocation failed - feets", quit );

            for( i=0; i<NumFeet; i++ )
            {
                    NozzleIds[i].objid = NULL_OBJID;
                    NozzleIds[i].osnum = me->ModuleInfo.md_id.osnum;
            }
          }
        }
        /* added by alwin for TR179802498 */

	status =
	om$send ( msg 	   = message VREquipment.VRPlaceNozzleFeet
						( &msg, &NbNozzle, NozzleIds,
						  &me->ModuleInfo ),
		 senderid = NULL_OBJID,
		 targetid = me->CmpId.objid,
		 targetos = me->CmpId.osnum );
	as$status( );

	__DBGpr_int("VRPlaceNozzleFeet: NbNozzle =", NbNozzle);

	for ( i=0; i<NbNozzle; i++ )
	{
		__DBGpr_obj("Nozzle Id           =", NozzleIds[i]);

		if( NozzleIds[i].objid != NULL_OBJID )
		{
			status =
			om$send( msg      = message GRgraphics.GRdisplay(
					     &msg, 
					     &me->ModuleInfo.md_env.matrix_type,
				 	     me->ModuleInfo.md_env.matrix, 
					     &Mode, 
					     &me->ModuleInfo.md_id ),
		 		targetid = NozzleIds[i].objid, 
		  		targetos = NozzleIds[i].osnum );
  			as$status();
		}
	}

	__DBGpr_obj("me->CmpId         ", me->CmpId); 

	_FREE( NozzleIds ); // added by alwin for freeing the memory allocated
			    // for nozzle feets.
  }

End;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method form_notification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action form_notification
{
  IGRlong		msg, retcode, sts;
  IGRint		retmsg;
  IGRdouble		dValue;
  IGRint		i, NbAttr=0;
  unsigned char		szText[15];
  struct  ACrg_coll	Collection[VR_MAX_ATTR];
  IGRint		r_pos;
  IGRint		type;
  int			col, row, active_row, len, len2;
  int			sel_flag=0;

  char			pattern[41]={""},
			TableName[41], EquipDesc[41],
      			*p_MacroName;

  struct VRdbEquipPart  Part;

  struct GRid		OldEquip, UsrParId, SysParId, MisParId;
  int			num_rows = 0,
			NumDynAttr = 0, NumAddAttr = 0; 
  struct ACrg_coll	*DynAttr = NULL, *AddAttr = NULL;


SetProc(form_notification); Begin

  UI_status ("");
  status = 1;

  if( !form_ptr )    return OM_S_SUCCESS;

  if ( ! me->list_present ) {
	_put_response( resp = TERMINATE );
	return OM_S_SUCCESS;
  }

/* KDD  form VRPidEquip is the main one */
  if ( form_ptr == me->forms[4].form_ptr ) { goto l_VRModPidEqp; }         
  if ( form_ptr != me->forms[3].form_ptr ) { goto other_forms; }         

  FIg_set_text( form_ptr, FI_MSG_FIELD, "");

  switch( gadget_label ) {
    case FI_EQUIP_TABLE:
	FIg_set_text( form_ptr, FI_STORE_LIST_1, ""); 

    case FI_TBL_LIST_1:
	FIg_set_text( form_ptr, FI_STORE_LIST_2, ""); 

    case FI_TBL_LIST_2:
	FIg_set_text( form_ptr, FI_STORE_LIST_3, ""); 

    case FI_TBL_LIST_3:
	FIg_reset( form_ptr, FI_EQUIP_LIST); 
	FIg_set_text( form_ptr, FI_EQUIP_NUMBER, ""); 
	FIg_set_text( form_ptr, FI_EQUIP_MACRO, ""); 

  	FIg_disable( form_ptr, FI_ACCEPT);
  	FIg_disable( form_ptr, FI_EXECUTE);

        status = om$send( msg      = message VRPlEquip.VRPID_LoadFromField( 
						form_ptr, gadget_label ),
                          targetid = my_id );
	if ( ! status&1) goto wrapup; 
	break;

    case FI_EQUIP_LIST:
/* soft data link from active FI_EQUIP_LIST (column 1) to FI_EQUIP_NUMBER */

  	FIfld_get_active_row( form_ptr, FI_EQUIP_LIST, &active_row, &r_pos);

		/* Keep the user happy with his selection */
        FIfld_set_select( form_ptr, FI_EQUIP_LIST, active_row, 0, TRUE);
        FIfld_set_select( form_ptr, FI_EQUIP_LIST, active_row, 1, TRUE);

  	FIfld_get_text( form_ptr, FI_EQUIP_LIST, active_row, 0, 40,
                               	(unsigned char *) pattern, &sel_flag, &r_pos);

        FIg_set_text( form_ptr, FI_EQUIP_NUMBER, pattern); 

  	FIfld_get_text( form_ptr, FI_EQUIP_LIST, active_row, 1, 40,
                               	(unsigned char *) EquipDesc, &sel_flag, &r_pos);

	strcpy(me->EquipDescr, EquipDesc); 

        if ( strlen(pattern) == 0 ) break;

/*** We assume: FI_EQUIP_LIST(row) == me->EquipList[ row*me->lst_cols]
* If column "macro_name" is empty, use "eqp_family" TR#179701127. 
* To avoid requery each time reallocate space for me->EquipList pointer.
***/

	len2 = active_row * me->lst_cols + 2 ; 
        p_MacroName = me->EquipList[ len2 ];

        if ( ( strlen( p_MacroName ) == 0) || ( *p_MacroName == ' ')) {
           FIg_get_text( form_ptr, FI_STORE_TABLE, TableName);

           status = VRdbGetEqOccur( &msg, TableName, pattern, NULL, &Part,NULL);

	   me->EquipList[ len2] = om$realloc( ptr  = me->EquipList[ len2 ], 
					      size = strlen(Part.Familly) + 1); 

	   strcpy(me->EquipList[ len2 ], Part.Familly);
           p_MacroName = me->EquipList[ len2 ];

           FIg_set_text(form_ptr, FI_MSG_FIELD,"eqp_family used as macro_name");
        }
        FIg_set_text( form_ptr, FI_EQUIP_MACRO, p_MacroName);

  	FIg_enable( form_ptr, FI_ACCEPT);
  	FIg_enable( form_ptr, FI_EXECUTE);
	break;


    case FI_EQUIP_NUMBER:
	FIg_set_text( form_ptr, FI_EQUIP_MACRO, ""); 

        FIg_get_text( form_ptr, FI_EQUIP_NUMBER, pattern );
	len = strlen (pattern);

        for ( i = 0; i < me->lst_rows; i++) {
           if ( !strncmp(me->EquipList[i*me->lst_cols], pattern, len) ) {

              FIfld_pos_cursor(form_ptr, FI_EQUIP_LIST, i, 0, 0, 0, 0, 0);
              FIfld_set_active_row(form_ptr, FI_EQUIP_LIST, i, 0);
  	      FIfld_set_select( form_ptr, FI_EQUIP_LIST, i, 0, TRUE);

			/* TR#179701127 */

              len2 = i * me->lst_cols + 2 ;
              p_MacroName = me->EquipList[ len2 ];

              if ( ( strlen( p_MacroName ) == 0) || ( *p_MacroName == ' ')) {
                 FIg_get_text( form_ptr, FI_STORE_TABLE, TableName);

                 status = VRdbGetEqOccur( &msg, TableName, 
			  me->EquipList[ i * me->lst_cols ], NULL, &Part, NULL);

           	 me->EquipList[len2] = om$realloc( ptr= me->EquipList[ len2],
					          size= strlen(Part.Familly)+1);

           	 strcpy(me->EquipList[ len2 ], Part.Familly);
           	 p_MacroName = me->EquipList[ len2 ];

                 FIg_set_text(form_ptr, FI_MSG_FIELD,
					"eqp_family used as macro_name");
              }
              FIg_set_text( form_ptr, FI_EQUIP_MACRO, p_MacroName);

              break;
           }
        }

  	FIg_enable( form_ptr, FI_ACCEPT);
  	FIg_enable( form_ptr, FI_EXECUTE);
	break;

    case FI_ACCEPT:
    case FI_EXECUTE:
        status = VRGadgetDefState(form_ptr, FI_STORE_TABLE, 1);
        status = VRGadgetDefState(form_ptr, FI_STORE_LIST_1, 1);
        status = VRGadgetDefState(form_ptr, FI_STORE_LIST_2, 1);
        status = VRGadgetDefState(form_ptr, FI_STORE_LIST_3, 1);
        status = VRGadgetDefState(form_ptr, FI_EQUIP_NUMBER, 1);
        status = VRGadgetDefState(form_ptr, EQUIP_SCALE, 1);

        FIg_get_text( form_ptr, FI_EQUIP_NUMBER, me->EquipNumber); 

        FIfld_get_active_row( form_ptr, FI_EQUIP_LIST, &active_row, &r_pos);
        FIfld_get_text(       form_ptr, FI_EQUIP_LIST, active_row, 1, 40,
                          (unsigned char *) me->EquipDescr, &sel_flag, &r_pos);

        status = om$send( msg  = message VRPlEquip.VRGetEquip( &sel_flag,0),
                      targetid = my_id );

        if ( !(status & 1) || !(sel_flag & 1) ) {
		FIg_set_text(form_ptr, FI_MSG_FIELD, 
				"Error in getting the equipment"); 
	}
	else {
		FIf_erase(form_ptr);
        	_put_response(resp = EX_FORM_FINISHED);
	}

	break;

    case FI_RESET:
  	status = om$send( msg = message VRPlEquip.VRResetForm( ),
	             targetid = my_id );
	break;

    case EQUIP_SCALE:
        NbAttr = 1;
        Collection[0].desc.type = AC_ATTRIB_DOUBLE;
        strcpy ( Collection[0].name , VR_N_PID_SCALE_DB );
	break;

    case FI_CANCEL:
        FIf_erase(form_ptr);
        _put_response(resp = TERMINATE);
        break;

    default:
	break;
  }

  goto wrapup;

/*------------------------------- VRModPidEqp form --------------------*/
l_VRModPidEqp:

  switch( gadget_label ) {
 
    case FI_RESET:
          status = om$send( msg  = message VRPlEquip.VRInitForm
                                                ( &retcode, VRPidModifyForm),
                        targetid = my_id);
          as$status(sts = sts);

	  break;

    case FI_CANCEL:
	  FIf_erase( form_ptr ); 
	  _put_response(resp = EX_FORM_FINISHED);
          break;
 

     case FI_REPLACE:
     case FI_EXECUTE:
     case FI_ACCEPT:
 
/*-----------------
#  Get the Dynamic and Additional collections from the form. 
*------------------*/
	NumDynAttr = 0; 
        FIfld_get_num_rows( form_ptr, FI_DYN_ATTRIB, &num_rows);
        VR$CreCollFromForm(     form                    = form_ptr,
                                gadget                  = FI_DYN_ATTRIB,
                                end_row                 = num_rows,
                                NumParLst               = &NumDynAttr,
                                ParLst                  = &DynAttr);

	NumAddAttr = 0;
        FIfld_get_num_rows( form_ptr, FI_ADD_ATTRIB, &num_rows);
        VR$CreCollFromForm(     form                    = form_ptr,
                                gadget                  = FI_ADD_ATTRIB,
                                end_row                 = num_rows,
                                NumParLst               = &NumAddAttr,
                                ParLst                  = &AddAttr);

/*-----------------
#  Get the attributes of the located, for modification, equipment.
*------------------*/
	OldEquip = me->EquipToModify;

    	sts    = om$send( msg   = message VRGeneric.VRGetParams (&retcode,
                                      &SysParId, &UsrParId, &MisParId),
                       senderid = NULL_OBJID,
                       targetid = OldEquip.objid,
                       targetos = OldEquip.osnum);
    	as$status(sts = sts );


/*-----------------
#  Build the new User Collection.
*------------------*/

        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_CLEAR_COLL,
                                p_ParamsListToModify  = DynAttr,
                                NbParamsToModify      = 0,
                                p_OutputCollectionId  = &UsrParId );

        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_MERGE_COLL,
                                p_ParamsListToModify  = DynAttr,
                                NbParamsToModify      = NumDynAttr,
                                p_OutputCollectionId  = &UsrParId );

        VR$ModifyCollection(    p_msg                 = &retcode,
                                Operation             = VR_UNION_COLL,
                                p_ParamsListToModify  = AddAttr,
                                NbParamsToModify      = NumAddAttr,
                                p_OutputCollectionId  = &UsrParId) ;

        if ( AddAttr) { _FREE ( AddAttr ); AddAttr = NULL;} NumAddAttr = 0; 
        if ( DynAttr) { _FREE ( DynAttr ); DynAttr = NULL;} NumDynAttr = 0; 

/*-----------------
#  Send VR_REPLACE signal if gadget == FI_REPLACE.
*  Send EX_FORM_FINISHED signal if gadget == FI_ACCEPT.
*  Update the form if gadget == FI_EXECUTE.
*------------------*/
	if ( gadget_label == FI_REPLACE) { 
	       	_put_response(resp = VR_REPLACE);
		FIf_erase( form_ptr);
	}
        else if ( gadget_label == FI_ACCEPT) {
	       	_put_response(resp = EX_FORM_FINISHED);
		FIf_erase( form_ptr);
	}
	else {
  		status = om$send( msg  = message VRPlEquip.VRInitForm
                                	        ( &retcode, VRPidModifyForm),
                	      targetid = my_id);
		as$status(sts = sts);
	}

	break;
  }

  /* Looks like one needs to explicitly request recompute since updating
   *  the collections themselves don't take care about that.
   * 						 - Anand for TR 179800237 */

  nd$wait_batch(  type       = GR_GEOM_POSTED,
		  l_object   = &OldEquip,
		  nb_obj     = 1 );

  nd$exec_batch();

  /* Above lines added for TR 179800237 */

  goto wrapup;


/*------------------------------ other forms ------------------------*/
other_forms:

  dValue = 0.0;
  szText[0] = '\0';

  FIg_get_type( form_ptr, gadget_label, &type );
  if ( type == FI_FIELD && form_ptr == me->forms[0].form_ptr)
  {
	FIfld_get_type( form_ptr, gadget_label, col, &type );
	if ( type == FI_DOUBLE || type == FI_INT )
	{
		FIfld_get_value( form_ptr, gadget_label, row, col,
				 &dValue, &sel_flag, &r_pos );
	}
	else if ( type == FI_ALPHA )	
	{
         	FIfld_get_text( form_ptr, gadget_label,  row, col,
				MAX_FIELD, szText, &sel_flag, &r_pos );
	}
  }

  /*"form label  : %d\n", form_label*/
  /*"gadget label: %d\n", gadget_label*/
  /*"gadget type : %d\n", type*/
  /*"Value       : %f\n", value*/

  if ( form_ptr == me->forms[2].form_ptr )
  {	
	switch( gadget_label )
	{
    		case FI_ACCEPT:
		case FI_EXECUTE: 
			FIg_set_state_off( form_ptr, gadget_label );
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, 
					&me->UsrParamId, NULL );
			as$status();
			_put_response(resp = EX_FORM_FINISHED);

		break;

		case FI_CANCEL:
			FIf_erase( form_ptr );
		break;

		case USER_ATTR_FLD:
		break;
	}
  }
  else if ( form_ptr == me->forms[1].form_ptr )
  {
	if( gadget_label == CATALOG_FIELD )
	{
		FIg_reset( me->forms[2].form_ptr, USER_ATTR_FLD);
		FIg_reset( me->form_ptr, EQUIP_NUMBER);
		FIg_reset( me->form_ptr, EQUIP_DESC);
		FIg_reset( me->form_ptr, EQUIP_SYMB);

		FIg_get_text( form_ptr, gadget_label, me->EquipNumber );

		status = 
		om$send ( msg = message VRPlEquip.VRGetEquip( &retmsg,0 ),
	    		  targetid = my_id );
  		as$status();
	}
  }
  else if (form_ptr == me->forms[0].form_ptr )
  {
 	switch( gadget_label )
    	{
    		case EQUIP_NUMBER :
/***  MADE A REVIEW FIELD ONLY
*			szText[0] = '\0';
*			** -- See if the code has already been defined -- **
*			FIg_get_text( form_ptr, gadget_label, me->EquipNumber);
*
*			status = 
*			om$send(msg = message VRPlEquip.VRGetEquip( &retmsg,0 ),
*	    			  targetid = my_id );
*  			as$status();
***/
		break;

    		case EQUIP_SCALE :	
			NbAttr = 1;
			Collection[0].desc.type = AC_ATTRIB_DOUBLE;
			strcpy ( Collection[0].name , VR_N_PID_SCALE_DB ); 
		break;

		case CATALOG_BUTTOM :
			FIg_set_state_off (form_ptr, gadget_label);
			FIf_display( me->forms[1].form_ptr );
		break;

    		case FI_RESET :
			FIg_set_state_off (form_ptr, gadget_label);
		break;

    		case FI_CANCEL :
			FIg_set_state_off (form_ptr, FI_CANCEL);
			FIf_erase( form_ptr );
			_put_response( resp = TERMINATE );
		break;

    		case FI_ACCEPT :
	    	case FI_EXECUTE :
			FIg_set_state_off (form_ptr, gadget_label );
			FIf_erase(  me->forms[1].form_ptr );
			_put_response(resp = EX_FORM_FINISHED);
		break;
	}
  }
 
  /* ------------------------------------------------------ */
  /* -- Update Static Collection with modified attribute -- */
  /* ------------------------------------------------------ */

  for (i=0; i<NbAttr; i++)
  {
	/*" Add/Mod <%s> in list\n", Collection[i].name */
	if (Collection[i].desc.type == AC_ATTRIB_TEXT)
	{
		/*| AC_ATTRIB_TEXT type */
		strcpy(Collection[i].desc.value.att_txt, (char *) szText );
	}
	else if (Collection[i].desc.type == AC_ATTRIB_DOUBLE)
	{
		/*| AC_ATTRIB_DOUBLE type */
		Collection[i].desc.value.att_exp = dValue;
	}
  }

  /*"NbAttr = %d\n",NbAttr*/

  if( NbAttr )
  {
  	status =
  	VR$ModifyCollection ( 	p_msg 			= &msg,
				Operation 		= VR_MERGE_COLL,
				p_ParamsListToModify 	= Collection,
				NbParamsToModify 	= NbAttr,
				p_OutputCollectionId 	= &me->SysParamId );
  }

wrapup:
End;
}/* end form_notification */

/****************************************************************************/
action delete
{
  IGRlong msg;

SetProc(VRPlEquip.delete); Begin

  if (!(me->VDB_terminated))
  {
__DBGpr_int("Delete form     ", me->form_ptr); 

    FIf_erase ( me->form_ptr );

    if( me->CmpId.objid != NULL_OBJID )
    {
  	if(1&(om$is_objid_valid(objid = me->CmpId.objid,
		          	osnum = me->CmpId.osnum)))
  	{
  		status = 
		om$send ( msg      = message GRgraphics.GRdelete(
							&msg, 
							&me->ModuleInfo),
		  	senderid = my_id,
		  	targetid = me->CmpId.objid,
		  	targetos = me->CmpId.osnum);
		as$status ();

		me->CmpId.objid = NULL_OBJID; 
	}
    }
  }

__DBGpr_com("Ready for VDB_LOCATE.delete"); 

  status =
  om$send ( mode     = OM_e_wrt_message,
	    msg      = message VDB_LOCATE.delete( f_defer_flag),
	    targetid = my_id);
  as$status(action = RET_STATUS);

/* Free up the memory used for DB tables */
__DBGpr_com("Ready for VRPlEquip.VRcleanup"); 

  status = om$send( msg      = message VRPlEquip.VRcleanup(&msg ),
                    targetid = my_id );

End;
}
/*******************************************************************************
*
*  Method to get the default state of VRPidEquip form
*
*------------------------------------------------------------------------------
*  How it works 
*
* 1. "init" action
* 2. set FI_EQUIP_TABLE( active row ) == FI_STORE_TABLE
* 3. Load the form from field FI_EQUIP_TABLE. 
*
* For more classifications repeat steps 1,2,3 for FI_EQUIP_LIST_1_2_3
*
* To save memory, we are using the following technique:
*
*------------------------------------------------------------------------------
* NOTE: Undisplayable gadgets are used to store last selected rows of
* 	"discpl_table" and sub classifications. 
*
*******************************************************************************/
action VRResetForm ( )
{
  int			i, active_row;
  char			table[41], class1[41], class2[41], class3[41],
			equip[41];

  int 			count, flag, pos;

  char			text[41]={""}, 
			*p_text, *q_text;

  double                pid_scale;

  Form			form_ptr;

SetProc(VRResetForm); Begin

  form_ptr = me->form_ptr;

			/* Full initialize */

  UI_status("");

  FIf_erase(  me->forms[2].form_ptr );

  if ( me->mytype == VR_PLACE_EQUIPMENT )
  { 
	  /* Restore last default state of gadgets. - Do so only for place
	   * equipment command (Anand for CR 179800598) */

      status = VRGadgetDefState(form_ptr, FI_STORE_TABLE, 0);
      status = VRGadgetDefState(form_ptr, FI_STORE_LIST_1, 0);
      status = VRGadgetDefState(form_ptr, FI_STORE_LIST_2, 0);
      status = VRGadgetDefState(form_ptr, FI_STORE_LIST_3, 0);
      status = VRGadgetDefState(form_ptr, FI_EQUIP_NUMBER, 0);

      FIf_reset( form_ptr );

      status = VRGadgetDefState(form_ptr, EQUIP_SCALE, 0);

      FIg_get_text(form_ptr, FI_STORE_TABLE,  table);
      FIg_get_text(form_ptr, FI_STORE_LIST_1, class1);
      FIg_get_text(form_ptr, FI_STORE_LIST_2, class2);
      FIg_get_text(form_ptr, FI_STORE_LIST_3, class3);
      FIg_get_text(form_ptr, FI_EQUIP_NUMBER, equip);
      FIg_get_value(form_ptr, EQUIP_SCALE,    &pid_scale);
  }
	     /* Below lines added by Anand for CR 179800598 */
  else if ( me->mytype == VR_MODIFY_EQUIPMENT)
  { 
      struct ACrg_coll	Collection;
      IGRchar		SelectStr[60],TableName[30],WhereStr[250];
      IGRchar		**Class;
      IGRint		NumRow;
      struct GRid	SysParId;
      IGRlong		retcode;

	  /* Set form so that it reflects selected equipment that is about to
	   * be replaced, rather than previously placed equipment */

      status = om$send( msg   = message VRGeneric.VRGetParams
				   (&retcode, &SysParId, NULL, NULL),
		  targetid = me->EquipToModify.objid,
		  targetos = me->EquipToModify.osnum);
      as$status(sts = status, action = GOTO_VALUE, value = wrapup);

      strcpy( Collection.name, VR_N_TABLE_NAME_DB);
      Collection.desc.type = AC_ATTRIB_TEXT;
      status = VRGetAttribute( &Collection, 1, &SysParId, NULL, 0);
      strcpy(table, Collection.desc.value.att_txt);
      __DBGpr_str(" DBtablename", table);

      strcpy( Collection.name, VR_N_PID_EQP_NUMBER);
      Collection.desc.type = AC_ATTRIB_TEXT;
      status = VRGetAttribute( &Collection, 1, &SysParId, NULL, 0);
      strcpy( equip, Collection.desc.value.att_txt);
      __DBGpr_str(" Equipment number",equip);

      sprintf( SelectStr, "%s.class1, %s.class2, %s.class3",
							PID_EQUIP_MASTER_TBL,
							PID_EQUIP_MASTER_TBL,
							PID_EQUIP_MASTER_TBL );
      __DBGpr_str(" Select ", SelectStr);

      strcpy( TableName, PID_EQUIP_MASTER_TBL );
      strcat( TableName, " , " );
      strcat( TableName, table );
      __DBGpr_str(" From ", TableName);

      sprintf( WhereStr,"%s.eqp_number='%s' and (%s.last_class=%s.class1 or %s.last_class=%s.class2 or %s.last_class=%s.class3)", table, equip,
						  table, PID_EQUIP_MASTER_TBL,
						  table, PID_EQUIP_MASTER_TBL,
						  table, PID_EQUIP_MASTER_TBL);
      __DBGpr_str(" Where ", WhereStr );

      status = vdb$RisSelect( select      = SelectStr,
			      table_name  = TableName,
			      where	  = WhereStr,
			      numselect   = 3,
			      p_numrows   = &NumRow,
			      p_buffer    = &Class );

      if( (status & 1) && (Class) )
      {
	  strcpy(class1, Class[0]); 
	  strcpy(class2, Class[1]); 
	  strcpy(class3, Class[2]); 
      }

      vdb$RisFreeBuffer ( buffer    = Class,
			  size      = 3 * NumRow );


      strcpy( Collection.name, VR_N_MACRO_NAME_AN);
      Collection.desc.type = AC_ATTRIB_TEXT;
      status = VRGetAttribute( &Collection, 1, &SysParId, NULL, 0);
      FIg_set_text( form_ptr, FI_EQUIP_MACRO, Collection.desc.value.att_txt);
      __DBGpr_str(" Macro name", Collection.desc.value.att_txt);

  }
	     /* Above lines added by Anand for CR 179800598 */

  FIg_set_text(form_ptr, FI_STORE_TABLE, "");
  FIg_set_text(form_ptr, FI_STORE_LIST_1, "");
  FIg_set_text(form_ptr, FI_STORE_LIST_2, "");
  FIg_set_text(form_ptr, FI_STORE_LIST_3, "");
  FIg_set_text(form_ptr, FI_EQUIP_NUMBER, "");

  __DBGpr_str("TABLE ",  table);
  __DBGpr_str("LIST_1", class1);
  __DBGpr_str("LIST_2", class2);
  __DBGpr_str("LIST_3", class3);
  __DBGpr_str("EQUIP_NUMBER", equip);

/***    Load the "discpl_table" (sub tables) column of the master table  ***/

  active_row = -1;
  count = 0;
  q_text = text;

  for (i =0; i < me->num_rows; i++) {
        p_text = me->EquipTable [i * me->num_cols];
        if ( strcmp(p_text, q_text) ) {
           FIfld_set_text( form_ptr, FI_EQUIP_TABLE, count++, 0, p_text, FALSE);
           q_text = p_text;
        }
  }

/* Now repeat the mouse clicks from the last time the user used this form */ 

   
			/***  FI_EQUIP_TABLE ***/

  count = -1;
  active_row = -1;
  FIfld_get_num_rows( form_ptr, FI_EQUIP_TABLE, &count);

  for (i = 0; i < count; i++) {
      FIfld_get_text(form_ptr, FI_EQUIP_TABLE, i, 0, 40, 
				(unsigned char *) text, &flag, &pos);
      if ( !strcmp(table, text) ) { 
         FIg_set_text(form_ptr, FI_STORE_TABLE,  table);
         active_row = i;
         break;
      } 
  }

  if ( active_row == -1 ) {
     UI_status("Master Table has been updated");
     goto wrapup; 
  }

  FIfld_pos_cursor(form_ptr, FI_EQUIP_TABLE, active_row, 0, 0, 0, 0, 0);
  FIfld_set_active_row( form_ptr, FI_EQUIP_TABLE, active_row, 0);
  FIfld_set_select( form_ptr, FI_EQUIP_TABLE, active_row, 0, TRUE);

  status = om$send( msg      = message VRPlEquip.VRPID_LoadFromField(
                                       form_ptr, FI_EQUIP_TABLE ),
                    targetid = my_id );

  if ( status != -1 ) goto equip_list;


                        /***  FI_TBL_LIST_1 ***/
  count = -1;
  active_row = -1; 
  FIfld_get_num_rows( form_ptr, FI_TBL_LIST_1, &count);


  for (i = 0; i < count; i++) {
      FIfld_get_text(form_ptr, FI_TBL_LIST_1, i, 0, 40, 
				(unsigned char *) text, &flag, &pos);
      if ( !strcmp(class1, text) ) { 
  	 FIg_set_text(form_ptr, FI_STORE_LIST_1, class1);
	 active_row = i;
	 break;
      }
  }
  if ( active_row == -1) { 
	__DBGpr_str("FI_TBL_LIST_1 no matches for", class1); 
	goto wrapup; 
  }

  FIfld_pos_cursor(form_ptr, FI_TBL_LIST_1, active_row, 0, 0, 0, 0, 0);
  FIfld_set_active_row( form_ptr, FI_TBL_LIST_1, active_row, 0);
  FIfld_set_select( form_ptr, FI_TBL_LIST_1, active_row, 0, TRUE);

  status = om$send( msg      = message VRPlEquip.VRPID_LoadFromField(
                                       form_ptr, FI_TBL_LIST_1 ),
                    targetid = my_id );
  if ( status != -1 ) goto equip_list; 


                        /***  FI_TBL_LIST_2 ***/

  count = -1;
  active_row = -1;
  FIfld_get_num_rows( form_ptr, FI_TBL_LIST_2, &count);

  for (i = 0; i < count; i++) {
      FIfld_get_text(form_ptr, FI_TBL_LIST_2, i, 0, 40, 
				(unsigned char *) text, &flag, &pos);
      if ( !strcmp(class2, text) ) {
  	 FIg_set_text(form_ptr, FI_STORE_LIST_2, class2);
         active_row = i;
         break;
      }
  }
  if ( active_row == -1) { 
	__DBGpr_str("FI_TBL_LIST_2 no matches for", class2); 
	goto wrapup; 
  }

  FIfld_pos_cursor(form_ptr, FI_TBL_LIST_2, active_row, 0, 0, 0, 0, 0);
  FIfld_set_active_row( form_ptr, FI_TBL_LIST_2, active_row, 0);
  FIfld_set_select( form_ptr, FI_TBL_LIST_2, active_row, 0, TRUE);

  status = om$send( msg      = message VRPlEquip.VRPID_LoadFromField(
                                       form_ptr, FI_TBL_LIST_2 ),
                    targetid = my_id );
  if ( status != -1 ) goto equip_list; 


                        /***  FI_TBL_LIST_3 ***/

  count = -1;
  active_row = -1;
  FIfld_get_num_rows( form_ptr, FI_TBL_LIST_3, &count);

  for (i = 0; i < count; i++) {
      FIfld_get_text(form_ptr, FI_TBL_LIST_3, i, 0, 40, 
				(unsigned char *) text, &flag, &pos);
      if ( !strcmp(class3, text) ) {
  	 FIg_set_text(form_ptr, FI_STORE_LIST_3, class3);
         active_row = i;
         break;
      }
  }
  if ( active_row == -1) { 
	__DBGpr_str("FI_TBL_LIST_3 no matches for", class3); 
	goto wrapup; 
  }

  FIfld_pos_cursor(form_ptr, FI_TBL_LIST_3, active_row, 0, 0, 0, 0, 0);
  FIfld_set_active_row( form_ptr, FI_TBL_LIST_3, active_row, 0);
  FIfld_set_select( form_ptr, FI_TBL_LIST_3, active_row, 0, TRUE);

  status = om$send( msg      = message VRPlEquip.VRPID_LoadFromField(
                                       form_ptr, FI_TBL_LIST_3 ),
                    targetid = my_id );


                        /***  FI_EQUIP_LIST ***/
equip_list:

  count = -1;
  active_row = -1;
  FIfld_get_num_rows( form_ptr, FI_EQUIP_LIST, &count);

  for (i = 0; i < count; i++) {
      FIfld_get_text(form_ptr, FI_EQUIP_LIST, i, 0, 40,
                                (unsigned char *) text, &flag, &pos);
      if ( !strcmp(equip, text) ) {
  	 FIg_set_text(form_ptr, FI_EQUIP_NUMBER, equip);
         active_row = i;
         break;
      }
  }
  if ( active_row == -1) { 
	__DBGpr_str("FI_EQUIP_LIST no matches for", equip); 
	goto wrapup; 
  }

  FIfld_pos_cursor(form_ptr, FI_EQUIP_LIST, active_row, 0, 0, 0, 0, 0);
  FIfld_set_active_row( form_ptr, FI_EQUIP_LIST, active_row, 0);
  FIfld_set_select( form_ptr, FI_EQUIP_LIST, active_row, 0, TRUE);
  FIfld_set_select( form_ptr, FI_EQUIP_LIST, active_row, 1, TRUE);

wrapup:
End;
}
/**************************************************************************/
action VRUpdateForm
{
SetProc(VRUpdateForm); Begin

  if( me->UsrParamId.objid == NULL_OBJID ) goto wrapup;

  FIg_enable(me->forms[2].form_ptr, FI_EXECUTE);
  FIg_enable(me->forms[2].form_ptr, FI_CANCEL);
  FIg_enable(me->forms[2].form_ptr, FI_ACCEPT);

  status = VR$DispCollAttr2(	pForm	= me->forms[2].form_ptr,
				Gadget	= USER_ATTR_FLD,
				pCollId	= &me->UsrParamId );
  as$status();
 
  FIf_display( me->forms[2].form_ptr );

wrapup:

End;
}/* ==================================================================== */

action dynamics
{
  extern IGRlong VRFollowCursor();

SetProc(dynamics); Begin

  if ( dynamics == DYNCOMP )
  {
      status = 
      VRFollowCursor( &me->CmpId, &me->ActiveDisplay, &me->ModuleInfo);
  }

End;
} /* end method dynamics */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRGetPoint
{
  IGRchar	CsType[MAX_CS_TYPE];
  struct GRid	CsId;
  IGRlong	sts, retcode;

  extern int 	VRskget_active_cs();

SetProc(VRGetPoint); Begin

  status = OM_S_SUCCESS;

  if ( me->mytype == VR_PLACE_EQUIPMENT ) { 
      	/* ----- Get located point ----- */
  	VRskget_active_cs( NULL, &CsId, me->CmpMatrix, CsType );

  	me->CmpMatrix[3]  = me->event1.event.button.x;
  	me->CmpMatrix[7]  = me->event1.event.button.y;
  	me->CmpMatrix[11] = me->event1.event.button.z;
  }
  else if ( me->mytype == VR_MODIFY_EQUIPMENT) { 
	struct GRid	OldEquip;
	IGRdouble	Origin[3];

	OldEquip = me->EquipToModify;

        status = om$send( msg   = message VRGeneric.VRGetMatrix(&retcode,0,NULL,
				  (IGRdouble *) me->CmpMatrix, &me->ModuleInfo),
                       targetid = OldEquip.objid,
                       targetos = OldEquip.osnum );
        as$status ();
  }

End;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRcleanup 
{
SetProc(VRcleanup); Begin

__DBGpr_int("me->EquipList ", me->EquipList);
  /* Free up the memory I have reserved */

  if ( me->EquipList ) {
     vdb$RisFreeBuffer ( buffer    = me->EquipList,
                         size      = me->lst_cols * me->lst_rows );

     me->EquipList = NULL;
  }

__DBGpr_int("me->EquipTable", me->EquipTable);
  if ( me->EquipTable ) {
     status = vdb$RisFreeBuffer ( buffer    = me->EquipTable,
                                  size      = me->num_cols * me->num_rows );

     me->EquipTable = NULL;
  }

End;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action VRPID_LoadFromField( Form 	form_ptr;
			    int 	gadget)
{
/*******************************************************************************
* KDD May/97 
* 
* This routine gets the active row of "gadget" and populates "next_gadget"
* with the sub classification of gadget's classification.
*
* Designed to work with form VRPidEquip.
*
* This routine is intended for use when the user clicks in 
* FI_EQUIP_TABLE, FI_TBL_LIST_1, FI_TBL_LIST_2 or FI_TBL_LIST_3  fields. 
*
* When the selected classification is the last one (ex: FI_TBL_LIST_3) 
*   then populate FI_EQUIP_LIST gadget, from table = FI_EQUIP_TABLE(active)
*   with classification = gadget(select).
*
*------------------------------------------------------------------------------
* NOTE: We assume the contents of field
*    FI_EQUIP_TABLE(row) == me->EquipTable[row*me->num_cols] 
*    See how we call vds$RisSelect macro in "init".
*
* NOTE: DO NOT call this routine with gadgets other than the above listed!
*
* NOTE: FI_STORE_TABLE is data linked ("init") from FI_EQUIP_TABLE
*       FI_STORE_LIST_x is data linked ("init") from FI_TBL_LIST_x
*
*-------------------------------------------------------------------------------
* 	PARAMETERS
*
* form_ptr   I	= form pointer
* gadget     I  = field gadget to select from (one of 3 allowed). 
*
*------------------------------------------------------------------------------
*	RETURN STATUS
*
* -1            = more classifications are available. FI_EQUIP_LIST not loaded.
*
* 1             = the selected row in gadget is the last classification.
*                 FI_EQUIP_LIST was loaded. 
*
* 0             = error
*******************************************************************************/

	int		i,
			count,
			tbl_col,
			next_gadget;

	char		table[41]={""}, 
			class1[41]={""}, 
			class2[41]={""},
			pattern[41]={""};

	char 		where[128],
			text[256]={""},
      			*q_text,
      			*p_text;

SetProc(VRPID_LoadFromField); Begin

/*** Initialize ***/

  status = 1;

/* vdb$RisSelect orders only, with "where" clause present */
  sprintf(where,"eqp_number IS NOT NULL"); 

  FIg_get_text(form_ptr, FI_STORE_TABLE, table);

__DBGpr_str("VRPID_LoadFromField FI_STORE_TABLE = ", table);

/* PID_EQUIP_LIST_TBL doesn't have sub classifications (discpl_tables do have)*/
  if ( !strcmp(table, PID_EQUIP_LIST_TBL) ) { goto  load_eqp_list; }


		/*** Main dispatch switch ***/


  tbl_col = 100;

  switch (gadget) {
    case FI_EQUIP_TABLE:
     	FIg_reset( form_ptr, FI_TBL_LIST_1);
	FIg_reset( form_ptr, FI_TBL_LIST_2);
        FIg_reset( form_ptr, FI_TBL_LIST_3);

	next_gadget = FI_TBL_LIST_1;
	tbl_col = 0;
	break;

    case FI_TBL_LIST_1:
	FIg_reset( form_ptr, FI_TBL_LIST_2);
        FIg_reset( form_ptr, FI_TBL_LIST_3);

        FIg_get_text(form_ptr, FI_STORE_LIST_1, pattern); 
	strcpy(class1 , pattern);

	next_gadget = FI_TBL_LIST_2;
	tbl_col = 1;
	break;

    case FI_TBL_LIST_2:
        FIg_reset( form_ptr, FI_TBL_LIST_3);

        FIg_get_text(form_ptr, FI_STORE_LIST_1, class1); 
        FIg_get_text(form_ptr, FI_STORE_LIST_2, pattern); 
	strcpy(class2 , pattern);

	next_gadget = FI_TBL_LIST_3;
	tbl_col = 2;
	break;

    case FI_TBL_LIST_3:
        FIg_get_text(form_ptr, FI_STORE_LIST_1, class1); 
        FIg_get_text(form_ptr, FI_STORE_LIST_2, class2); 
        FIg_get_text(form_ptr, FI_STORE_LIST_3, pattern); 
	goto last_classification;

    default:
	status = 0; 
	goto wrapup;
  }

		/*** load the subclassification field in next_gadget ***/
  count = 0;

  text[0] = '\0';
  q_text = text;

  for ( i = 0; i < me->num_rows; i++ ) {
/********* kdd + to do 
* if ( strcmp( table,me->EquipTable[i*me->num_cols]) ) continue;
* if ( tbl_col > 0 ) {
*    if ( strcmp(class1,me->EquipTable[i*me->num_cols + 1]) ) continue;
*    if ( tbl_col > 1) 
*       if ( strcmp(class2,me->EquipTable[i*me->num_cols + 2]) ) continue;
* }
**********/
     if (                 !strcmp( table,me->EquipTable[i*me->num_cols]) && 
        ((tbl_col < 1) || !strcmp(class1,me->EquipTable[i*me->num_cols + 1])) &&
        ((tbl_col < 2) || !strcmp(class2,me->EquipTable[i*me->num_cols + 2])) )
     {
	p_text = me->EquipTable [i * me->num_cols + tbl_col + 1];
	if ( strcmp(p_text, q_text) ) {
      	   FIfld_set_text( form_ptr, next_gadget, count++, 0, p_text, FALSE);
	   q_text = p_text;
        }
     }
  }

/* Return if additional classifications are displayed */
  if ( count > 0 ) { status = -1; goto wrapup; }


last_classification:
	
/*** "pattern" is the last available classification. Must not be "" (Tyler) ***/

     if ( strlen(pattern) == 0 ) {
        sprintf(text, "Invalid sub classification for table %s", table);
        UI_status(text);
        status = 0;
        goto wrapup;
     }
     sprintf(where, "last_class = '%s'", pattern);

load_eqp_list:

     if ( me->EquipList ) {
        vdb$RisFreeBuffer ( buffer    = me->EquipList,
                            size      = me->lst_cols * me->lst_rows );

       me->EquipList = NULL;
     }

     status = 
     vdb$RisSelect( select      = "eqp_number, eqp_descr, macro_name",
                    table_name  = (char *) table,
                    where       = where,
                    order       = "1",
                    numselect   = me->lst_cols,
                    p_numrows   = &me->lst_rows,
                    p_buffer    = &me->EquipList );

     if ( !(status&1) || !me->EquipList ) { 
        if ( me->EquipList ) {
           vdb$RisFreeBuffer ( buffer    = me->EquipList,
                               size      = me->lst_cols * me->lst_rows );
          me->EquipList = NULL;
        }
	sprintf(text,"DB query failure: table <%s>, select <%s>, where <%s>",			 table, "eqp_number, eqp_descr, macro_name", where);
	printf("\n%s\n", text); 
	status = 0;
	goto wrapup;
     }

     for ( i = 0; i < me->lst_rows; i++) {
        FIfld_set_text( form_ptr, FI_EQUIP_LIST, i, 0,
                 me->EquipList [i * me->lst_cols], FALSE);
	
        FIfld_set_text( form_ptr, FI_EQUIP_LIST, i, 1,
                 me->EquipList [i * me->lst_cols + 1], FALSE);
     }

wrapup:
End;
return status;
}



/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*-------------------------
# The user has selected PID Equipment by keying "table_name, eqp_number" 
* Load the form "VRPidEquip" withTableName, MacroName, PidScale, me->EquipNumber
* Then call VRGetEquip( , 0).
*	Currently we are using PidScale from the last Placement.
---------------------------*/

action VRGetEquipByName 
{
#include <string.h> 
extern char	*strchr();


  char			*comma, *p_text, where[64],
			TableName [ 64], **MacroName = NULL;

  int			rows = 0, cols = 1, sel_flag;

  int    		retcode=1;

SetProc(VRGetEquipByName); Begin

  me->ret = VRNOT_OK; 
  status = 1;

__DBGpr_str("me->response_data        ", me->response_data);

/*----------------------
#  Get the TableName and EquipNumber. Format: "Table, Equipment"
------------------------*/
  if ( (comma = strchr(me->response_data, ',')) == NULL ) 
						{status = 0; goto wrapup; }
  *comma = '\0'; 
  p_text = me->response_data; 
  status = VRCleanStringFromSpaces ( p_text, &p_text ); 
  strcpy( TableName, p_text); 

  p_text = (comma + 1); 
  status = VRCleanStringFromSpaces ( p_text, &p_text ); 
  strcpy( me->EquipNumber, p_text); 

__DBGpr_str(" TableName                   ", TableName);
__DBGpr_str(" me->EquipNumber             ", me->EquipNumber  ); 

  if ( (strlen(me->EquipNumber) == 0) || (strlen(TableName) == 0 ) ) 
						{status = 0; goto wrapup; }

  FIf_erase( me->form_ptr);

  FIg_set_text( me->form_ptr, FI_EQUIP_NUMBER, me->EquipNumber);
  FIg_set_text( me->form_ptr, FI_STORE_TABLE,  TableName);
  
  status = VRGadgetDefState( me->form_ptr, FI_STORE_TABLE, 1);
  status = VRGadgetDefState( me->form_ptr, FI_EQUIP_NUMBER, 1);

  sprintf(where, "eqp_number = '%s'", me->EquipNumber);

  status = vdb$RisSelect(   select      = "macro_name",
	                    table_name  = (char *) TableName,
	                    where       = where,
	                    numselect   = cols,
	                    p_numrows   = &rows,
	                    p_buffer    = &MacroName );

  if ( !(status&1) || !MacroName || (rows == 0) ) {
     printf("Can not find MacroName for %s,%s", TableName, me->EquipNumber);
     FIg_set_text(  me->form_ptr, FI_EQUIP_MACRO, "" ) ; 
  }
  else { 
     FIg_set_text(  me->form_ptr, FI_EQUIP_MACRO, MacroName[0] ) ; 
  }

  if ( MacroName ) {
     vdb$RisFreeBuffer ( buffer    = MacroName,
                         size      = cols * rows );
     MacroName = NULL;
  }


  status = om$send( msg      = message VRPlEquip.VRGetEquip( &retcode,0),
                    targetid = my_id );

  if ( !(status & 1) || !(retcode & 1) ) me->ret = VRNOT_OK;
  else                                   me->ret = OM_S_SUCCESS;

wrapup:

End;

return  status;
}



/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VREraseForms
{
SetProc (VREraseForms); Begin

  status = 1;

  if ( me->forms[0].form_ptr) FIf_erase(me->forms[0].form_ptr);
  if ( me->forms[1].form_ptr) FIf_erase(me->forms[1].form_ptr);
  if ( me->forms[2].form_ptr) FIf_erase(me->forms[2].form_ptr);
  if ( me->forms[3].form_ptr) FIf_erase(me->forms[3].form_ptr);

End;
return status; 
}

/* This method has been written to take care of the Phantom Equipment graphics
appearing off the screen. When we try to change the command, this sleep will
get executed. In this change the display properties to Non-displayable and
Non-locatable mode which erase the display. This will prevent the phantom 
graphics appearing on screen, while fitting. Alwin */

action sleep
{
  if( me->CmpId.objid != NULL_OBJID )
  {
      IGRshort  action, props;
      IGRlong   retcode;
 
        props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        action = 0;
        status = om$send ( msg = message GRgraphics.GRchgprops(
                                                &retcode,
                                                &action,
                                                &props ),
                           targetid = me->CmpId.objid,
                           targetos = me->CmpId.osnum );
        as$status();
 
  }
 
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.sleep( pos ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
 
}
 
/* When the wakeup is called we have to display the Evaluated Equipment 
graphics otherwise, the graphics won't at the cursor end; during the dynamics.
Alwin for TR179525895 */

action wakeup
{
  if( me->CmpId.objid != NULL_OBJID )
  {
      IGRshort  action, props;
      IGRlong   retcode;
 
        props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 
        action = 1; // Action is set to 1 to redisplay again.
 
        status = om$send ( msg = message GRgraphics.GRchgprops(
                                                &retcode,
                                                &action,
                                                &props ),
                           targetid = me->CmpId.objid,
                           targetos = me->CmpId.osnum );
        as$status();
 
  }
 
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.wakeup( pos ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
 
}


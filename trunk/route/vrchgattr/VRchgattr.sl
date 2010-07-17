/* $Id: VRchgattr.sl,v 1.2 2001/02/20 01:12:00 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrchgattr/VRchgattr.sl
 *
 * Description:
     This file contains the command object needed to change PIPING
               HVAC or RACEWAY components' attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRchgattr.sl,v $
 *	Revision 1.2  2001/02/20 01:12:00  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.5  2000/04/04  16:40:14  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by lawaddel for route
#
# Revision 1.4  2000/03/20  17:15:30  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by lawaddel for route
#
# Revision 1.3  1999/05/03  13:37:30  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by sbilla for route
#
# Revision 1.2  1999/04/27  14:19:10  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for: CR 179900491 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/25  18:37:16  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by kddinov for route
#
# Revision 1.2  1997/09/09  20:29:48  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.16  1996/06/13  15:39:22  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.15  1996/04/25  13:38:06  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.14  1996/04/25  00:13:32  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.13  1996/04/19  14:21:50  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by ashankar for route240
#
# Revision 1.12  1996/04/10  22:41:20  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by ashankar for route240
#
# Revision 1.11  1996/04/09  19:29:32  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.10  1996/04/04  16:56:36  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by r240_int for route240
#
# Revision 1.9  1996/03/22  23:57:16  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.8  1996/03/13  22:16:30  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.7  1996/03/05  23:21:48  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.6  1996/03/04  21:29:38  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by hverstee for route240
#
# Revision 1.5  1996/02/29  11:51:30  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by ashankar for route240
#
# Revision 1.4  1996/02/01  12:29:48  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by ashankar for route240
#
# Revision 1.3  1996/01/16  20:46:54  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:19:26  pinnacle
# Replaced: vrchgattr/VRchgattr.sl for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
	momo : 04-10-1991   review date

	bruno : 07-12-1992	subclass VRActParam to inheritate of the 
				form managment.

	Lori : 10-24-1994	CR#179422038  Update call to VRGetAttrFromDB 
				to include product information.

 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb		Add VX_FIproto.h, prototypes
 *      02/29/96        Shankar         Changed prompts; updated state table.
 *	04/04/06	adz		Malloc & Free checking.
 *      09/05/97        law             Changed prompts for copy parameters
 *      03/20/00        law             tr179901167-deleted fields for
 *                                      transitions.
 *
 *************************************************************************/

command_string       VRC_M_ChgPpCompDgnPar,0,VRChPCmDgP
synonym              VRC_M_ChgHvCompDgnPar,1,VRChHCmDgP
synonym		     VRC_M_ChgRwCompDgnPar,2,VRChRCmDgP
class                VRchgattr
super_class	     VDB_LOCATE
product_name         "$ROUTE"
command_table	     "route.cmd"

specification

#include "igrtypedef.h"
#include "VRchgattrdef.h"
#include "VRattr_def.h"
#include "FI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

/* Added by Anand for CR 179900491 */
#include "VRRwDimen.h"


instance
{
  IGRint			my_ret;		  /* return code                             */
  IGRint			product; 	  /* product flag                            */
  IGRboolean			bPid;		  /* representation */

  variable IGRint		BranchType[0];    /* */

  IGRchar			*form_name[2];    /* main and sub forms name 		*/
  Form				form_ptr[2];      /* main and sub forms pointers	*/

  IGRint			NumOfLocatedObjects; /* number of located objects	*/
  struct	  GRid		*LocatedObjects;  /* list of located objects		*/

  IGRint			NumOfSysCollect;  /* number of system collection to update   */
  IGRint			NumOfUserCollect; /* number of user collection to update     */

  variable struct GRid		SysParamId[0];    /* list of system collection to update     */
  variable struct GRid		UserParamId[0];   /* list of user collection to update       */


  /* Collection containing the modification */

  struct	  GRid		SMoId;	/* all system attributes to modify	*/
  struct	  GRid		UAdId;  /* all user attributes to add		*/
  struct	  GRid		UMoId;  /* all user attributes to modify	*/
  struct	  GRid		UDeId;  /* all user attributes to delete	*/

  struct	  GRid		SysId;	/* system attributes for display */
  struct	  GRid		UsrId;  /* union of all user attributes for display */

 /*C instance variables for line seq num id management */
  IGRint			PrevLineNum;
  IGRboolean			bLineNumUsed; 

 /*C super kludge for airflow isolation     */

  IGRdouble                     dAirFlowSav;

  /* Structure that stores information pertaining to variably spaced
   * multi-tiers. Instance data added by Anand for CR 179900491 */
  struct VRRwCptDetails	RcwyCptInfo;
}


implementation

#include "OMprimitives.h"
#include "OMmacros.h"
#include "VRPid.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRattr_def.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "VRuserdef.h"
#include "VRact_params.h"
#include "VRpriv_attr.h"
#include "VRprivmacros.h"
#include "VRmacros.h"
#include "VRformdef.h"
#include "VRMcForm.h"
#include "VRDbStruct.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "acrepdef.h"
#include "vrtools_pto.h"
#include "vrchgatt_pto.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG
/*
#define	MY_DEBUG
*/
#define MAIN     0
#define SUB      1


#define PIPING_FORM_NAME  "VRPpDgPar"
#define HVAC_FORM_NAME    "VRHvDgPar"
#define RACEWAY_FORM_NAME "VRRwDgPar"

#define SUB_FORM_NAME 	"VRModAddPara"

  extern GRclassid OPP_VRPComp_class_id;
  extern GRclassid OPP_VRPCComp_class_id;
  extern GRclassid OPP_VRHanger_class_id;
  extern GRclassid OPP_VRHComp_class_id;
  extern GRclassid OPP_VRHCComp_class_id;
  extern GRclassid OPP_VRRComp_class_id;
  extern GRclassid OPP_VRRCComp_class_id;
  extern GRclassid OPP_VRPNozz_class_id;
  extern GRclassid OPP_VRHNozz_class_id;
  extern GRclassid OPP_VRRNozz_class_id;
  extern GRclassid OPP_VRCorrection_class_id;

from	NDnode		import	NDcopy, NDget_objects;
from	ACrg_collect	import	AClist_attribute,ACset_list_attribute,
				ACget_named_attribute;
from	VRGeneric	import	VRGetNeighbors;
from	VRGeneric	import	VRGetParams, VRChgParams, VRGetStatus, 
				VRGetCompDesc, VRIsGeometricAttr, VRGetSysType;
from	ACncpx		import	ACget_rep;
from    VRCorrection    import  VRSetFlow;
from    VRProduct       import  VRGetProduct;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

state_table

#include "VRuserdef.h"
#include "VRattr_def.h"
#include "VRchgattrdef.h"
#include "VRmsg.h"
#include "FI.h"

#define MAIN     0
#define SUB      1

state main

   on CMD_TYPE = 0 do	message_key	VR_M_ChgPpCompDgnPar	state start
   on CMD_TYPE = 1 do	message_key	VR_M_ChgHvCompDgnPar	state start
   on CMD_TYPE = 2 do	message_key	VR_M_ChgRwCompDgnPar	state start

state start

   execute	VRInitAttr ( VR_SYSTEM_ATTR | VR_USER_ATTR )

   on ELSE			 				state GET_OBJ

state GET_OBJ

   prompt_key		VR_P_IdComp
   dynamics		off
   locate_owner         "LC_RIGID_COMP"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate_noauto

   on  EX_FORM_FINISHED
		do VRset_ret( &me->ret )
			on RETURN_CODE = FI_CANCEL
			do VREraseForms( &me->ret )
			state terminate
		state .

   on EX_BACK_UP or EX_RJT_MOVEON
		state .

   on EX_DATA or EX_OBJID
		do VRGetObjects( &me->ret )
			on ERROR
			state .

		do VRResetAttr ( VR_SYSTEM_ATTR | VR_USER_ATTR )
		do VRUpdSysForm( &me->ret )
		do Main_Form_start( &me->ret )
		do VRUpdSysForm( &me->ret ) /* added for tr179901167 */
		state CHG_PAR


state CHG_PAR

   prompt_key		VR_P_ChgPar
   dynamics		off
   filter		get_event

   on EX_BACK_UP or EX_RJT_MOVEON
	do VRreset_gadget_form( &me->ret )
	do VREraseForms( &me->ret )
	state GET_OBJ

   on  EX_FORM_FINISHED
	do VRset_ret( &me->ret )
		on RETURN_CODE = SUB_COPY_PARAM
		state LOC_COPY

		on RETURN_CODE = SUB_ADD_TO_LIST
		state LOC_ADD

		on RETURN_CODE = MOD_LOAD_COMPONENT
		state LOC_CMP

		on RETURN_CODE = FI_EXECUTE
		do VRCompute( &me->ret )
		state start

		on RETURN_CODE = FI_ACCEPT
		do VREraseForms( &me->ret )
		do VRCompute( &me->ret )
		state terminate

		on RETURN_CODE = FI_CANCEL
		do VREraseForms( &me->ret )
		state terminate

	state GET_OBJ
					
state LOC_COPY

   prompt               "Identify Component to Use for Replacement"
   dynamics		off
   locate_owner         "LC_RIGID_COMP | LC_REF_OBJECTS"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate

   on EX_DATA
	do VRPopupGadget( SUB, SUB_COPY_PARAM )
	do VRCopyCmpParam( &me->ret )
	do VRupd_subform( &me->ret )
	do VRUpdUsrForm( &me->ret )
	state CHG_PAR

   on EX_FORM_FINISHED
	do VRset_ret( &me->ret )
		on RETURN_CODE = SUB_COPY_PARAM
		state .

		on RETURN_CODE = SUB_ADD_TO_LIST
		do VRPopupGadget( SUB, SUB_COPY_PARAM )
		state LOC_ADD

		on RETURN_CODE = MOD_LOAD_COMPONENT
		do VRPopupGadget( SUB, SUB_COPY_PARAM )
		state LOC_CMP

		on RETURN_CODE = FI_ACCEPT
		do VREraseForms( &me->ret )
		do VRCompute( &me->ret )
		state start

		on RETURN_CODE = FI_EXECUTE
		do VRCompute( &me->ret )
		state .

		on RETURN_CODE = FI_CANCEL
		do VREraseForms( &me->ret )
		state terminate

	state .

   on ELSE
	state CHG_PAR


state LOC_ADD

   prompt_key		VR_P_IdComp
   dynamics		off
   locate_owner         "LC_RIGID_COMP"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate

   on EX_DATA
	do VRPopupGadget( SUB, SUB_ADD_TO_LIST )
	do VRAddCollFromCmp( &me->ret )
	do VRUpdUsrForm( &me->ret )
	state CHG_PAR
                                
   on EX_FORM_FINISHED
	do VRset_ret( &me->ret )
		on RETURN_CODE = SUB_COPY_PARAM
		do VRPopupGadget( SUB, SUB_ADD_TO_LIST )
		state LOC_COPY

		on RETURN_CODE = SUB_ADD_TO_LIST
		state .

		on RETURN_CODE = MOD_LOAD_COMPONENT
		do VRPopupGadget( SUB, SUB_ADD_TO_LIST )
		state LOC_CMP

		on RETURN_CODE = FI_ACCEPT
		do VREraseForms( &me->ret )
		do VRCompute( &me->ret )
		state GET_OBJ

		on RETURN_CODE = FI_CANCEL
		do VREraseForms( &me->ret )
		state terminate

	state .

   on ELSE
	state CHG_PAR


state LOC_CMP

   prompt               "Identify Component to Use for Replacement"
   dynamics		off
   locate_owner         "LC_RIGID_COMP | LC_REF_OBJECTS"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate

   on EX_DATA
	do VRPopupGadget( MAIN, MOD_LOAD_COMPONENT )
	do VRGetSysColl( &me->ret )
	do VRupd_all_gadget_form( &me->ret )
	do VRUpdSysForm
	state CHG_PAR
                                
   on EX_FORM_FINISHED
	do VRset_ret( &me->ret )
		on RETURN_CODE = SUB_COPY_PARAM
		do VRPopupGadget( MAIN, MOD_LOAD_COMPONENT )
		state LOC_COPY

		on RETURN_CODE = SUB_ADD_TO_LIST
		do VRPopupGadget( MAIN, MOD_LOAD_COMPONENT )
		state LOC_ADD

		on RETURN_CODE = MOD_LOAD_COMPONENT
		state CHG_PAR 

		on RETURN_CODE = FI_ACCEPT
		do VREraseForms( &me->ret )
		do VRCompute( &me->ret )
		state start

		on RETURN_CODE = FI_CANCEL
		do VREraseForms( &me->ret )
		state terminate

	state .

   on ELSE
	state CHG_PAR


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  IGRint	fi_status;
  
  extern int	COB_FI_form_notification();
  extern int	COB_FI_initial_form_notification();

  /* Nozzles should be non-locatable */

  /*| call VDB_LOCATE.init method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.init( type, str_ptr ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  fi_status = FI_SUCCESS;
  
  me->form_ptr[MAIN]=NULL;
  me->form_ptr[SUB]=NULL;

  me->SysId.objid = NULL_OBJID;
  me->UsrId.objid = NULL_OBJID;

  me->bPid = FALSE;

  me->PrevLineNum  = -1;
  me->bLineNumUsed = FALSE;

  switch( type )
  {
    case 0 : 	me->product = VR_PIPING;
             
		/*| before name assign */
  		me->locate_eligible_thing.w_count = 3;
  		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  		om$vla_set_dimension( varray = me->eligible_classids,
                        	size   = me->locate_eligible_thing.w_count );

  		me->form_name[MAIN] = PIPING_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRPComp_class_id;
             	me->eligible_classids[1] = OPP_VRPCComp_class_id;
             	me->eligible_classids[2] = OPP_VRHanger_class_id;
             	/* me->eligible_classids[2] = OPP_VRPNozz_class_id; */
             	break;

    case 1 : 	me->product = VR_HVAC;

		/*| before name assign */
  		me->locate_eligible_thing.w_count = 2;
  		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  		om$vla_set_dimension( varray = me->eligible_classids,
                        	size   = me->locate_eligible_thing.w_count );

  		me->form_name[MAIN] = HVAC_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRHComp_class_id;
             	me->eligible_classids[1] = OPP_VRHCComp_class_id;
             	/* me->eligible_classids[2] = OPP_VRHNozz_class_id */;
             	break;

    case 2 : 	me->product = VR_CABLING;

		/*| before name assign */
  		me->locate_eligible_thing.w_count = 2;
  		me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  		om$vla_set_dimension( varray = me->eligible_classids,
                        	size   = me->locate_eligible_thing.w_count );

  		me->form_name[MAIN] = RACEWAY_FORM_NAME ;
             	me->eligible_classids[0] = OPP_VRRComp_class_id;
             	me->eligible_classids[1] = OPP_VRRCComp_class_id;
             	/* me->eligible_classids[2] = OPP_VRRNozz_class_id; */
             	break;

    default: return OM_E_ABORT;
  }

  me->locate_eligible_thing.p_classes = me->eligible_classids;
  me->locate_eligible = &me->locate_eligible_thing;

  me->form_name[SUB] = SUB_FORM_NAME ;

  /*"MAIN form_name = %s\n", me->form_name[MAIN] */
  /*"SUB  form_name = %s\n", me->form_name[SUB] */

  /*| before call to FIf_new*/
  fi_status = FIf_new( MAIN, me->form_name[MAIN], COB_FI_form_notification,
                       					&me->form_ptr[MAIN]);
  if( fi_status )
  {
    /*"fi_status = %d\n", fi_status */

    ex$message( field   = ERROR_FIELD,
                in_buff = "Not able to create form !" );
    goto warapup;
  }

  /*| before call to FIf_set_cmd */
  fi_status = FIf_set_cmd_oid_os( me->form_ptr[MAIN], my_id, OM_Gw_current_OS );
  if( fi_status ) goto warapup;
  status = FIf_set_initial_notification_routine ( me->form_ptr[MAIN], 
					COB_FI_initial_form_notification );
  if ( status ) goto warapup;

  /*| -- Initialisation of gadget's list with data base -- */
  /*    Karine 02-04-92   */
  VRGetAttrFromDB( me->form_ptr[MAIN], me->product );
  
  goto quit;

warapup :
  me->form_ptr[MAIN] = NULL;
  me->state = _terminate;
  return OM_I_STOP_SENDING ;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action delete
{

  if (!(me->VDB_terminated))
  {
	status =
	om$send( msg      = message VRchgattr.VRDeleteAttr
				( VR_SYSTEM_ATTR | VR_USER_ATTR ),
		targetid = my_id );
	as$status( );

	if( me->form_ptr[MAIN] != NULL ) FIf_delete( me->form_ptr[MAIN] );
	if( me->form_ptr[SUB]  != NULL ) FIf_delete( me->form_ptr[SUB]  );
  }

	status =
	om$send(	targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message VDB_LOCATE.delete ( 0 ));
	as$status( action = RET_STATUS );

  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRset_ret
{
  status = OM_S_SUCCESS;

   me->ret = me->my_ret;
  goto quit;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRGetObjects
{
  IGRshort			CmpStatus;
  IGRshort                      kk;
  IGRint 			i,j;
  IGRint                        FirstOne;
  IGRint                        tCount;
  IGRlong			retcode;
  struct	ACrg_coll	BranchParam;
  IGRint			ACrep;
  IGRboolean			CollectExist;
  struct	GRid		SysParamId;
  struct	GRid		UserParamId;
  GRclassid			p_classid;
  extern	GRclassid	OPP_VRNozzle_class_id;
  extern	GRclassid	OPP_VRCptIn_class_id;


  SetProc( VRGetObjects ); Begin

  *sts = MSSUCC;

  me->NumOfSysCollect  = 0;
  me->NumOfUserCollect = 0;
  me->LocatedObjects   = NULL ;

  tCount = 0;
  FirstOne = 0;

  /*"Located object = %d\n", me->event1.located_object[0].located_obj */

  ASstart_fence
  ( me->event1.located_object[0].located_obj, me->ModuleInfo.md_id.osnum,
    &me->NumOfLocatedObjects, &me->LocatedObjects, me->response,
    me->response_data
  );

  if( ! me->NumOfLocatedObjects )
  {
    *sts = MSFAIL;
    return OM_S_SUCCESS;
  }

  om$vla_set_dimension( varray = me->BranchType,
                        size   = me->NumOfLocatedObjects );

  strcpy( BranchParam.name, VR_N_COMP_TOPO_IN );

  for( i=0; i<me->NumOfLocatedObjects; i++ )
  {
	/*"LocatedObjects[%d] = %d\n", i, me->LocatedObjects[i].objid */
	/* get class id to see if this is a nozzle. If so, skip it */

	status =
	om$get_classid( osnum = me->LocatedObjects[i].osnum,
			objid = me->LocatedObjects[i].objid,
			p_classid = &p_classid );

	if (((om$is_ancestry_valid( subclassid = p_classid,
				superclassid = OPP_VRNozzle_class_id))
				== OM_S_SUCCESS ) ||
		((om$is_ancestry_valid( subclassid = p_classid,
					superclassid = OPP_VRCptIn_class_id))
					== OM_S_SUCCESS ))
	continue;

        /*    TR 179601741
        in case the pocketmenu network select has been chosen we still
        have to check for the product....... you can't win             */

        status =
        om$send (msg = message VRProduct.VRGetProduct (&kk, NULL),
            targetid = me->LocatedObjects[i].objid,
            targetos = me->LocatedObjects[i].osnum );

        if (kk != me->product) continue;

        if (tCount == 0) FirstOne = i;
        tCount++;

	/*| See if the component is a correction component */
	status =
	om$send( msg      = message VRGeneric.VRGetStatus
				( &retcode, &CmpStatus ),
		targetid = me->LocatedObjects[i].objid,
		targetos = me->LocatedObjects[i].osnum );
	as$status();

	/*"CmpStatus = %d\n", CmpStatus */

	if( CmpStatus&VR_CORRECTION )
	{
		/*| It's a correction component */
		me->BranchType[i] = -1;
	}
	else
	{
		/* ------------------------------------ */
		/*| See if the component is in Pid mode */
		/* ------------------------------------ */

		status =
		om$send( msg      = message VRGeneric.ACget_rep (&ACrep),
			targetid = me->LocatedObjects[i].objid,
			targetos = me->LocatedObjects[i].osnum );
		as$status();

		if ( bVR_IS_PID ( ACrep ) )
		{
			me->bPid = TRUE;
			me->BranchType[i] = -1;
		}
		else
		{
			status =
			om$send( msg      = message VRGeneric.VRGetCompDesc
					( &retcode, &BranchParam, &me->ModuleInfo ),
				targetid = me->LocatedObjects[i].objid,
				targetos = me->LocatedObjects[i].osnum );
			as$status();
			me->BranchType[i] = (IGRint) BranchParam.desc.value.att_exp;
#ifdef MY_DEBUG
			printf ("Initial Topo = %d\n",me->BranchType[i]);
#endif
		}


	}/* end not correction treatment */

	status =
	om$send( msg      = message VRGeneric.VRGetParams
				( &retcode, &SysParamId, &UserParamId, NULL ),
		targetid = me->LocatedObjects[i].objid,
		targetos = me->LocatedObjects[i].osnum );
             
	/*"Get object %d System parameters\n", me->LocatedObjects[i].objid */

	CollectExist = FALSE;

	if (om$dimension_of(varray = me->SysParamId)) 
	{
		for( j=0; j<me->NumOfSysCollect; j++ )
		{
			if (me->SysParamId[j].objid == SysParamId.objid)
			{
				CollectExist = TRUE;
				break;
			}
		}
	}

	if( ! CollectExist )
	{
		om$vla_set_dimension( 	varray = me->SysParamId,
					size   = me->NumOfSysCollect+1 );

		me->SysParamId[me->NumOfSysCollect] = SysParamId;

		/*"New ParamId = %d\n", me->SysParamId[me->NumOfSysCollect].objid */ 

		me->NumOfSysCollect++;
	}

	/* ------------------------------- */
	/*| Get User Collection parameters */
	/* ------------------------------- */
             
	CollectExist = FALSE;

	if(om$dimension_of( varray = me->UserParamId ) )
	{
		for( j=0; j<me->NumOfUserCollect; j++ )
		{
			if( me->UserParamId[j].objid == UserParamId.objid )
			{
				CollectExist = TRUE;
				break;
			}
		}
	}

	if( !CollectExist )
	{
		om$vla_set_dimension( 	varray = me->UserParamId,
					size   = me->NumOfUserCollect+1 );

		me->UserParamId[me->NumOfUserCollect] = UserParamId;

		/*"New ParamId = %d\n", me->UserParamId[me->NumOfUserCollect].objid */ 

		me->NumOfUserCollect++;

		status = VR$ModifyCollection ( 	p_msg 			= &retcode,
					Operation		= VR_UNION_COLL,
					p_InputCollectionId	= &UserParamId,
					p_OutputCollectionId	= &me->UsrId );
		as$status( action = RET_STATUS );
	}

  }/* end loop on components */

  if (tCount == 0)
  {  /*   got it, whole set is wrong product, exit gracefully    */
    *sts = MSFAIL;

    /* de-highlight this set ???*/

    ASend_fence();
    me->LocatedObjects   = NULL ;

    UI_status ("Network select of wrong type");
    goto quit;
  }

  /* Display attributes of the first located component */
  me->SysId = me->SysParamId[FirstOne];

  End
  goto quit;

}/* end VRGetObjects */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRResetAttr ( int flag )
{
  IGRlong	retmsg;

  status = OM_S_SUCCESS;

  if( flag & VR_SYSTEM_ATTR )
  {
	/*| ------ Reset System attr -------- */

	status = om$send( msg      = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL ),
		targetid = me->SMoId.objid,
		targetos = me->SMoId.osnum );
	as$status( action = RET_STATUS );

  }/* end reset system attributes */

  if( flag & VR_USER_ATTR )
  {
	/*| ------ Reset User attr -------- */

	/* Additional user attr */
	status = om$send( msg      = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL ),
		targetid = me->UAdId.objid,
		targetos = me->UAdId.osnum );
	as$status( action = RET_STATUS );

	/* Modified user attr */
	status = om$send( msg      = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL ),
		targetid = me->UMoId.objid,
		targetos = me->UMoId.osnum );
	as$status( action = RET_STATUS );

	/* Deleted user attr */
	status = om$send( msg      = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL ),
		targetid = me->UDeId.objid,
		targetos = me->UDeId.osnum );
	as$status( action = RET_STATUS );

  }/* end reset system attributes */

  goto quit;

}/* end VRResetAttr */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRInitAttr ( int flag )
{

  status = OM_S_SUCCESS;
  me->dAirFlowSav = 0.0;

  if( flag & VR_SYSTEM_ATTR )
  {
	/* ------ VR_SYSTEM_ATTR -------- */

	me->SMoId.osnum  = me->ModuleInfo.md_id.osnum;
	status = om$construct( 	classid = OPP_ACrg_collect_class_id,
				p_objid = &me->SMoId.objid,
				osnum   =  me->SMoId.osnum);
	as$status( action = RET_STATUS ); 

	/*"created System modified %d\n", me->SMoId.objid */

  }/*end system flag */

  if( flag & VR_USER_ATTR )
  {
	/* ------ VR_USER_ATTR -------- */

	/* user additional attributes */
	me->UAdId.osnum = me->ModuleInfo.md_id.osnum;
	status = om$construct( 	classid = OPP_ACrg_collect_class_id,
				p_objid = &me->UAdId.objid,
				osnum   = me->UAdId.osnum );
	as$status( action = RET_STATUS ); 
	/*"User Add Collect %d\n", me->UAdId.objid */

	/* user modified attributes */
	me->UMoId.osnum = me->ModuleInfo.md_id.osnum;
	status = om$construct( 	classid = OPP_ACrg_collect_class_id,
				p_objid = &me->UMoId.objid,
				osnum   = me->UMoId.osnum );
	as$status( action = RET_STATUS ); 
	/*"User Modify Collect %d\n", me->UMoId.objid */

	/* user deleted attributes */
	me->UDeId.osnum = me->ModuleInfo.md_id.osnum;
	status = om$construct( 	classid = OPP_ACrg_collect_class_id,
				p_objid = &me->UDeId.objid,
				osnum   = me->UDeId.osnum );
	as$status( action = RET_STATUS ); 
	/*"User Delete Collect %d\n", me->UDeId.objid */

	/* user union attributes (for display purpose) */
	me->UsrId.osnum = me->ModuleInfo.md_id.osnum;
	status = om$construct( 	classid = OPP_ACrg_collect_class_id,
				p_objid = &me->UsrId.objid,
				osnum   = me->UsrId.osnum );
	as$status( action = RET_STATUS ); 
	/*"User Union Collect %d\n", me->UsrId.objid */

  }/* end User flag */

  goto quit;
}/* end VRInitAttr */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRDeleteAttr ( int flag )
{

  status = OM_S_SUCCESS;

  if(	(flag & VR_SYSTEM_ATTR) &&
	1&(om$is_objid_valid(	objid = me->SMoId.objid,
				osnum = me->SMoId.osnum)))
  {
	/*| put the system modification collection in the delete batch */

	nd$wait_batch( 	type       = GR_DELETED,
			l_object   = &me->SMoId,
			nb_obj     = 1 );

	me->SMoId.objid = NULL_OBJID;
  }

  if( flag & VR_USER_ATTR )
  {
	/* put the three modification collections in the delete batch */

	if (1&(om$is_objid_valid(objid = me->UAdId.objid,
				 osnum = me->UAdId.osnum)))
	{
		/*| Delete User Add collection */
		nd$wait_batch( 	type       = GR_DELETED,
				l_object   = &me->UAdId,
				nb_obj     = 1 );

		me->UAdId.objid = NULL_OBJID;
	}

	if (1&(om$is_objid_valid(objid = me->UMoId.objid,
				 osnum = me->UMoId.osnum)))
	{
		/*| Delete User Modify collection */
		nd$wait_batch( 	type       = GR_DELETED,
				l_object   = &me->UMoId,
				nb_obj     = 1 );

		me->UMoId.objid = NULL_OBJID;
	}

	if (1&(om$is_objid_valid(objid = me->UDeId.objid,
				 osnum = me->UDeId.osnum)))
	{
		/*| Delete User Delete collection */
		nd$wait_batch( 	type       = GR_DELETED,
				l_object   = &me->UDeId,
				nb_obj     = 1 );

		me->UDeId.objid = NULL_OBJID;
	}

	if (1&(om$is_objid_valid(objid = me->UsrId.objid,
				 osnum = me->UsrId.osnum)))
	{
		/*| Delete User Delete collection */
		nd$wait_batch( 	type       = GR_DELETED,
				l_object   = &me->UsrId,
				nb_obj     = 1 );

		me->UsrId.objid = NULL_OBJID;
	}

  }/* end delete user attr */

  goto quit;
}/* end VRDeleteAttr */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRUpdSysForm
{
    status = VRUpdALLSysForm( me->product, me->form_ptr[MAIN],&me->SysId );
    as$status( action = RET_STATUS );

    /* Below lines added by Anand for CR 179900491 */
    if(me->product == VR_RWAY || me->product == VR_HVAC) /** TR179901333 **/
    {
	IGRint			proc_mode, shape_code, *active_cpt;
	IGRlong			retmsg;
	struct ACrg_coll	AttrList;
        __DBGpr_com("product either hvac or rway");
	/* First get shape from collection */
	strcpy(AttrList.name, VR_N_SHAPE_IN);
	status = om$send( msg = message ACrg_collect.ACget_named_attribute
		( &retmsg, &AttrList ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
	as$status( action = RET_STATUS );
	shape_code	=	AttrList.desc.value.att_exp;

        if(me->product == VR_RWAY) /* tr179901333 */
        {
	/* Now call VRRw_dimen_fields with proc_mode=0 to populate the
	 * RcwyCptInfo structure. */
        __DBGpr_com("product is rway");
	proc_mode	=	0;
	active_cpt	=	NULL;
	status = VRRw_dimen_fields( me->form_ptr[MAIN], 0, NULL,
				    &me->ModuleInfo, 1, active_cpt, proc_mode,
				    shape_code, &me->RcwyCptInfo, &me->SysId );

	/* Finally, call VRRw_dimen_fields with proc_mode=1 to display the
	 * RcwyCptInfo structure on the form. */
	proc_mode	=	1;
	active_cpt	=	&proc_mode; /* The function was not implemented
					       keeping this command in mind.
					       Hence, in order to get matters
					       working, pass a pointer whose
					       contents is unity - Anand */
	status = VRRw_dimen_fields( me->form_ptr[MAIN], 0, NULL, 
				    &me->ModuleInfo, 1, active_cpt, proc_mode,
				    shape_code, &me->RcwyCptInfo, NULL );

            /******* added by Reddy for CR179900491  ******/
                if(shape_code == VR_RECT)
                    FIg_display(me->form_ptr[MAIN], SP_TIER_DG );
                else
                {
                   FIg_erase( me->form_ptr[MAIN], SYMB_N_TIER_DG);
                   FIg_erase( me->form_ptr[MAIN], SYMB_SP_TIER_DG);
                }
        }

        /*** block added for tr179901167 ***/
        if(shape_code > 9) /* We have a transition object, delete some fields */
        {
           if(me->product == VR_RWAY)
           {
               FIg_erase( me->form_ptr[MAIN], SYMB_SHAPE);
               FIg_erase( me->form_ptr[MAIN], SYMB_W_SIZE);
               FIg_erase( me->form_ptr[MAIN], SYMB_D_SIZE);
               FIg_erase( me->form_ptr[MAIN], RW_SP_TIER_TEXT);
               FIg_erase( me->form_ptr[MAIN], RW_SP_TIER_TX_IN);
               FIg_erase( me->form_ptr[MAIN], RW_SP_TIER_TX_MM);
               FIg_erase( me->form_ptr[MAIN], RW_N_TIER_TEXT);
               FIg_erase( me->form_ptr[MAIN], N_TIER_DG);
               FIg_erase( me->form_ptr[MAIN], SP_TIER_DG);
               FIg_erase( me->form_ptr[MAIN], SYMB_N_TIER_DG);
               FIg_erase( me->form_ptr[MAIN], SYMB_SP_TIER_DG);
               FIg_erase( me->form_ptr[MAIN],RW_D_SIZE_DGTEXT);
               FIg_erase( me->form_ptr[MAIN],RW_D_SIZE_DGTX_IN);
               FIg_erase( me->form_ptr[MAIN],RW_D_SIZE_DGTX_MM);
               FIg_erase( me->form_ptr[MAIN],RW_W_SIZE_DGTEXT);
               FIg_erase( me->form_ptr[MAIN],RW_W_SIZE_DGTX_IN);
               FIg_erase( me->form_ptr[MAIN],RW_W_SIZE_DGTX_MM);
               FIg_erase( me->form_ptr[MAIN],FRM_DEPTH_1);
               FIg_erase( me->form_ptr[MAIN],FRM_WIDTH_1);
            }
            else if (me->product == VR_HVAC)
            {
               FIg_erase( me->form_ptr[MAIN],HV_D_SIZE_DGTEXT);
               FIg_erase( me->form_ptr[MAIN],HV_D_SIZE_DGTX_IN);
               FIg_erase( me->form_ptr[MAIN],HV_D_SIZE_DGTX_MM);
               FIg_erase( me->form_ptr[MAIN],HV_W_SIZE_DGTEXT);
               FIg_erase( me->form_ptr[MAIN],HV_W_SIZE_DGTX_IN);
               FIg_erase( me->form_ptr[MAIN],HV_W_SIZE_DGTX_MM);
               FIg_erase( me->form_ptr[MAIN],W_SIZE);
               FIg_erase( me->form_ptr[MAIN],D_SIZE);
            }
            FIg_erase( me->form_ptr[MAIN],SYMB_SHAPE);
            FIg_erase( me->form_ptr[MAIN],SYMB_W_SIZE);
            FIg_erase( me->form_ptr[MAIN],SYMB_D_SIZE);
        }

    }

    goto quit;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action Main_Form_start
{
  status = OM_S_SUCCESS;

	if( me->form_ptr[MAIN] == NULL ) return OM_E_ABORT;

	/* -- Update form format -- */
	VRFormatSysForm ( me->product, me->form_ptr[MAIN], 1, me->bPid );

	/* -- Display System form -- */
	FIf_display( me->form_ptr[MAIN] );

  goto quit;

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRGetSysColl
{
  IGRlong		retcode;
  struct	GRid	LocatedObjectId;


  *sts = MSSUCC;

  /*| object is located */

  LocatedObjectId = me->event1.located_object[0].located_obj;

  /*"loc_obj = %d %d\n", LocatedObjectId.objid, LocatedObjectId.osnum */

  status =
  VR$GetCmpAttributes(	p_retmsg	= &retcode,
			Product		= me->product,
	 		p_ComponentId	= &LocatedObjectId,
	 		p_SysParamId	= &me->SysId,
	 		p_MdEnv		= &me->ModuleInfo );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status =
  VR$GetCmpAttributes(	p_retmsg	= &retcode,
			Product		= me->product,
	 		p_ComponentId	= &LocatedObjectId,
	 		p_SysParamId	= &me->SMoId,
	 		p_MdEnv		= &me->ModuleInfo );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRPopupGadget( IGRint form_index, gadget_label )
{
  status = OM_S_SUCCESS;
  FIg_set_state_off( me->form_ptr[form_index], gadget_label );
  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VREraseForms
{
  status = OM_S_SUCCESS;

	/*| erase MAIN form */
	if( me->form_ptr[MAIN] != NULL ) FIf_erase( me->form_ptr[MAIN] );

	/*| erase SUB form */
	if ( me->form_ptr[SUB] != NULL ) FIf_erase( me->form_ptr[SUB] );
  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRAddCollFromCmp
{
  IGRlong			retcode;
  struct		GRid	UserParamId;
  struct		GRid	LocatedObjectId;

  *sts    = MSSUCC;
  retcode = MSSUCC;

  /* this method reset the user form and copy a component's user param in it */

  /*| OBJECT IS LOCATED */

  LocatedObjectId = me->event1.located_object[0].located_obj;

  /*"located obj = %d\n", LocatedObjectId.objid */

  status = om$send( msg      = message VRGeneric.VRGetParams
                                       ( &retcode, NULL, &UserParamId, NULL ),
                    targetid = LocatedObjectId.objid,
                    targetos = LocatedObjectId.osnum );
             
  /*"Get object %d user parameters\n", UserParamId */

  /*"Add params to %d\n", me->UsrId.objid */

  status = VR$ModifyCollection( 	p_msg 			= &retcode,
					Operation		= VR_UNION_COLL,
					p_InputCollectionId	= &UserParamId,
					p_OutputCollectionId	= &me->UsrId );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRCopyCmpParam
{
	IGRlong	retmsg;

	*sts = MSSUCC;

	/* -- Reset user collection -- */
	status =
	om$send( msg      = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL ),
		targetid = me->UsrId.objid,
		targetos = me->UsrId.osnum );
	as$status( action = RET_STATUS );

	/* -- update with located component's user attributes -- */
	status =
	om$send( msg      = message VRchgattr.VRAddCollFromCmp( sts ),
			targetid = my_id );
	as$status( action = RET_STATUS );

  goto quit;
}/* end VRCopyCmpParam */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRUpdateConnect( IGRint mode, NumOfCollect; struct GRid *ListCollId, *ActId;
                        struct GRmd_env *MdEnv )
{
  struct GRid		ChildrenId[30], *p_ChildrenId, NewId;
  IGRlong		retcode ;
  IGRint		i, j, k, NbChildren;
  IGRboolean 		CollectCopy, CmpExist;  
  struct GRid		*TmpPointer1;

  SetProc( VRUpdateConnect ); Begin

  retcode = MSSUCC;
  p_ChildrenId = NULL ;
  TmpPointer1 = NULL;

  for( i=0; i<NumOfCollect; i++ )
  {
    status =
    om$send( msg      = message NDnode.NDget_objects
                                 ( ND_CHILDREN, NULL, 0, NULL, 0, OM_K_MAXINT,
                                   &NbChildren ),
             targetid = ListCollId[i].objid,
             targetos = ListCollId[i].osnum );
    as$status( action = RET_STATUS );

    if( NbChildren > 30 )
    {
      _FREE( TmpPointer1 ); TmpPointer1 = NULL ;

      TmpPointer1 =  _MALLOC( NbChildren , struct GRid );
      if( TmpPointer1 ) p_ChildrenId = ( struct GRid * ) TmpPointer1;
      else  return OM_E_NODYNMEM;
    }
    else p_ChildrenId = ChildrenId;

    status =
    om$send( msg      = message NDnode.NDget_objects
                                 ( ND_CHILDREN, p_ChildrenId, NbChildren,
                                   NULL, 0, OM_K_MAXINT, &NbChildren ),
             targetid = ListCollId[i].objid,
             targetos = ListCollId[i].osnum );
    as$status( action = GOTO_VALUE, value = warup );

    /*"NbChild = %d\n", NbChildren */

/* -- Copy collection if one of the components depending -- */
/* -- on this parameters is not to be modified 		 -- */

    for( j=0,CollectCopy=FALSE; j<NbChildren && !CollectCopy; j++ )
    {
      for( k=0,CmpExist=FALSE; k<me->NumOfLocatedObjects && !CmpExist; k++ )
      {
        if( p_ChildrenId[j].objid == me->LocatedObjects[k].objid )
		CmpExist = TRUE;
      }

      if( ! CmpExist )
	CollectCopy = TRUE;

    }/* end loop on depending components */

    if( CollectCopy )
    {
	status =
	om$send( msg      = message NDnode.NDcopy
					( &retcode, 0, MdEnv, MdEnv, &NewId ),
                 targetid = ListCollId[i].objid, 
                 targetos = ListCollId[i].osnum  );
	as$status( action = GOTO_VALUE, value = warup );

	/*| collection is copied */

      for( j=0; j<NbChildren; j++ )
      {
        for( k=0; k<me->NumOfLocatedObjects; k++ )
        {
          if( p_ChildrenId[j].objid == me->LocatedObjects[k].objid )
          {
            /*| call change parameters */
            status =
	    om$send( msg      = message VRGeneric.VRChgParams
                                  (&retcode,
                                   mode & ~VR_USER_ATTR   ? &NewId : NULL,
                                   mode & ~VR_SYSTEM_ATTR ? &NewId : NULL,
			           NULL ),
                     targetid = p_ChildrenId[j].objid, 
                     targetos = p_ChildrenId[j].osnum  );
            as$status( action = GOTO_VALUE, value = warup );
          }
        }
      }
    }/* end copy collection */
    else NewId = ListCollId[i];

    /*| component  attributes before change */
    /*^ VRprint_user_attr( &NewId ); */

    switch( mode )
    {
	case VR_SYSTEM_ATTR :
		/*A report the change in line seq number to DB */

		/*NR	Not required : remove afterwards : Manyam */

		if ( me->bPid )
			VRReportLineId( &NewId, &me->SMoId );

		status =
		VR$ModifyCollection( 	p_msg 			= &retcode,
					Operation 		= VR_MERGE_COLL,
					p_InputCollectionId 	= &me->SMoId,
					p_OutputCollectionId 	= &NewId );
		as$status ();
		break;

	case VR_USER_ATTR:
		/* -- Remove attributes -- */
		status =
		VR$ModifyCollection ( 	p_msg 			= &retcode,
					Operation 		= VR_SUBSTR_COLL,
					p_InputCollectionId 	= &me->UDeId,
					p_OutputCollectionId 	= &NewId );
		as$status ();


		/* -- Modify attributes -- */
		status =
		VR$ModifyCollection ( 	p_msg 			= &retcode,
					Operation 		= VR_UPDATE_COLL,
					p_InputCollectionId 	= &me->UMoId,
					p_OutputCollectionId 	= &NewId );
		as$status ();

		/* -- Add attributes -- */
		status =
		VR$ModifyCollection ( 	p_msg 			= &retcode,
					Operation 		= VR_MERGE_COLL,
					p_InputCollectionId 	= &me->UAdId,
					p_OutputCollectionId 	= &NewId );
		as$status ();
		break;

	default :
			/*| unknown mode */
			goto warup;
    }


    _FREE( TmpPointer1 );
    TmpPointer1 = NULL ;
    __DBGpr_com(" component  attributes after change ");

    /*^ VRprint_user_attr( &NewId ); */

    End

warup :
    _FREE( TmpPointer1 );
    TmpPointer1 = NULL ;
  }

  End
  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRreset_gadget_form
{
  status = OM_S_SUCCESS;

  VRreset_gadget( me->product, me->form_ptr[MAIN] );
  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRupd_all_gadget_form
{
  status = OM_S_SUCCESS;

  VRupd_all_checkgadgets( me->product, me->form_ptr[MAIN] );
  goto quit;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRupd_subform
{
  status = OM_S_SUCCESS;

  VRupd_all_gadget_subform( me->form_ptr[SUB] );
  goto quit;
}

action VRCompute                        extern
action form_notification		extern
action initial_form_notification	extern
action VRUpdUsrForm			extern


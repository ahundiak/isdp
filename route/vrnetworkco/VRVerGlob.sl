/* $Id: VRVerGlob.sl,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco/VRVerGlob.sl
 *
 * Description:
 *	Global Verify
 *
 *	This command is used to verify route objects.  The objects to
            be verified can be selected individually or through an event
            generator.  No limitations are given as far as to what product
            (piping, HVAC, RWAY) can be selected.  An error report is 
            produced and the user is given the option to produce a verbose
            report summarizing all of the verifications done on all of the 
            objects.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRVerGlob.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
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
# Revision 1.6  1996/04/04  21:21:08  pinnacle
# Replaced: vrnetworkco/VRVerGlob.sl for:  by hverstee for route240
#
# Revision 1.5  1996/01/17  00:30:38  pinnacle
# Replaced: vrnetworkco/VRVerGlob.sl for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  21:22:18  pinnacle
# Replaced: vrnetworkco/VRVerGlob.sl for:  by r240_int for route240
#
 *
 * History:
 *	11-94	   	Lori		creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/


command_string          VRC_M_GbVerify,0,VRGlbVfy
class                   VRVerGlob
super_class             VRVerify
product_name            "$ROUTE"
command_table           "route.cmd"

specification
instance
{
}

implementation

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "EXgrid.h"
#include "AS_status.h"
#include "grdpbmacros.h" 
#include "VRverify.h"
#include "ACrg_collect.h"
#include "vrmacros.h"
#include "vrdef.h"
#include "VDmem.h"
#include "VRmsg.h"
#include "coparamac.h"
#include "VRverifymac.h"
 
%safe
#include "VX_FIproto.h"
%endsafe


extern GRclassid OPP_VRPComp_class_id;
extern GRclassid OPP_VRPCComp_class_id;
extern GRclassid OPP_VRHComp_class_id;
extern GRclassid OPP_VRHCComp_class_id;
extern GRclassid OPP_VRRComp_class_id;
extern GRclassid OPP_VRRCComp_class_id;
extern GRclassid OPP_VRLink_class_id;
extern GRclassid OPP_VRElCable_class_id;
extern GRclassid OPP_VRFoCable_class_id;
extern GRclassid OPP_VRCorrection_class_id;
extern GRclassid OPP_VRCnrlSeg_class_id;
extern GRclassid OPP_VRComponent_class_id;
extern GRclassid OPP_VRConcComp_class_id;
extern GRclassid OPP_VRPCorentity_class_id;
extern GRclassid OPP_VRHCorentity_class_id;
extern GRclassid OPP_VRRCorentity_class_id;
extern GRclassid OPP_VRplane_class_id;
extern GRclassid OPP_VRDepPlane_class_id;


state_table
#include  "VRmsg.h"
#include   "VRverify.h"

#define TRUE   1
#define FALSE  0

state start

      on ELSE
               state GET_OBJ

state GET_OBJ
      prompt_key           VR_P_VerSelObj              
      accept_key           VR_P_AccReject
      locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS"
      filter               locate

      on EX_DATA or EX_OBJID
              do VRGetLocObjects( &me->ret )
                     on ERROR
                              state .
	      do dehighlight
		 state GET_FILE_NAME_ERR

      on ELSE
              state terminate


state GET_FILE_NAME_ERR
	prompt_key        VR_P_GetERepFile
 	filter            get_event
	
	on EX_BACK_UP	state start
	
	on EX_STRING 	  do set_error
			  do store_file_name( &me->ret )
			  on RETURN_CODE = VR_K_FileIsDirectory
	                       do status_key VR_E_CantCreateEFile	                                                  state .
	                  on RETURN_CODE = VR_K_FileExist
			                    state OVER_FILE_ERR
	                  state ASK_VERBOSE
	                  

	                  
state OVER_FILE_ERR
	prompt_key        VR_P_Overwrite
	filter            get_event
	
	on EX_BACKUP   state -

	on EX_STRING do check_response_y( &me->ret )
	                 on RETURN_CODE = FALSE state -
	                 state ASK_VERBOSE


state ASK_VERBOSE
	prompt_key       VR_P_AskVerbose 
	filter           get_event

	on EX_BACKUP   state GET_FILE_NAME_ERR
	 
	on EX_STRING do check_response_n( &me->ret )
		on RETURN_CODE = TRUE
			do set_verbose
			state GET_FILE_NAME_VER
		on RETURN_CODE = FALSE
			state VERIFY
		state .


state GET_FILE_NAME_VER
	prompt_key        VR_P_GetVRepFile
	filter            get_event
	
	on EX_BACK_UP	state GET_FILE_NAME_ERR
	
	on EX_STRING do store_file_name( &me->ret )
			  on RETURN_CODE = VR_K_FileIsDirectory
	                       do status_key VR_E_CantCreateVFile	                                                  state .
	                  on RETURN_CODE = VR_K_FileExist
			                    state OVER_FILE_VER
	                  state VERIFY

state OVER_FILE_VER
	prompt_key        VR_P_Overwrite
	filter            get_event
	
	on EX_BACK_UP  state ASK_VERBOSE

	on EX_STRING do check_response_y( &me->ret )
	                 on RETURN_CODE = FALSE state -
	                 state VERIFY

state VERIFY
        status_key       VR_M_Processing
        on ELSE
		do open_files ( &me->ret )
		on RETURN_CODE =  VR_K_CantCreateErrFile
			do status_key VR_E_CantCreateEFile
                           state GET_FILE_NAME_ERR
		on RETURN_CODE = VR_K_CantCreateVerbFile
			do status_key VR_E_CantCreateVFile
                           state ASK_VERBOSE
		do title_reports
                do VRVerifyObjects
		do end_reports
		do close_files
                	state terminate

action init
{

  me->bNetCommand = FALSE;
  
  /*A Do not get corrections and control segments - set array size to zero */
  /*A to know these structures are not being used in this command */
  me->NewObj[CORR_OBJ_NUM].ObjCount = 0;
  me->NewObj[CORR_OBJ_NUM].ArraySize = 0;
  me->NewObj[CORR_OBJ_NUM].object = NULL;

  me->NewObj[CS_OBJ_NUM].ObjCount = 0;
  me->NewObj[CS_OBJ_NUM].ArraySize = 0;
  me->NewObj[CS_OBJ_NUM].object = NULL;

  me->NewObj[PLANE_OBJ_NUM].ObjCount = 0;
  me->NewObj[PLANE_OBJ_NUM].ArraySize = 0;
  me->NewObj[PLANE_OBJ_NUM].object = NULL;

  /*A Call parent init message */
  status =
    om$send( msg    = message VRVerify.init ( type, str_ptr ),
            mode   = OM_e_wrt_message,
            targetid = my_id);
  as$status( action = RET_STATUS );
  
  /*A Set up eligible classes for locate */
  me->locate_eligible_thing.w_count = 6;
  me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  om$vla_set_dimension( varray = me->eligible_classids,
                       size   = me->locate_eligible_thing.w_count );
  

  me->eligible_classids[0] = OPP_VRComponent_class_id;
  me->eligible_classids[1] = OPP_VRConcComp_class_id;
  me->eligible_classids[2] = OPP_VRCorrection_class_id;
  me->eligible_classids[3] = OPP_VRCnrlSeg_class_id;
  me->eligible_classids[4] = OPP_VRplane_class_id;
  me->eligible_classids[5] = OPP_VRDepPlane_class_id;

  me->locate_eligible_thing.p_classes = me->eligible_classids;
  me->locate_eligible = &me->locate_eligible_thing;
  return status;
} /* end init */



action VRGetLocObjects
{
  IGRint              i, NumOfFenceObjs;
  struct  GRobj_env   *FenceObjs;
  IGRlong             retmsg;
  
  *sts = MSSUCC;

  me->NumOfObjects = 0;
  /*A Get rid of old selected objects */
  if ( me->LocatedObjects || me->Fencemd_env )
    {
      status = om$send( msg = message VRVerify.dehighlight(&retmsg),
		       targetid = my_id);
      status = om$send( msg = message VRVerify.free_memory(&retmsg),
		       targetid = my_id);

      if ( !(retmsg&1) || !(status & 1))
	{
	  *sts = MSFAIL;
	  return OM_S_SUCCESS;
	}
    }


  NumOfFenceObjs = 0;
  FenceObjs = NULL;
	  
  /*A get objects from fence */
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &NumOfFenceObjs,
                 p_obj_env = &FenceObjs, 
                 response = me->response, 
                 response_data = me->response_data);
	

  /*A Check to see that some objects were selected */
  if ( !NumOfFenceObjs )
    {
      *sts = MSFAIL;
      goto wrapup;
    } 

  /*A transfer objects to instance data */
  me->NumOfObjects = NumOfFenceObjs;
  me->LocatedObjects = _MALLOC (NumOfFenceObjs, struct GRid );

  if ( !me->LocatedObjects ) 
    {
      *sts = MSFAIL;
      printf("Could not allocate memory\n");
      ASend_fence();
      return OM_E_NODYNMEM;
    }

  me->Fencemd_env = _MALLOC (NumOfFenceObjs, struct GRmd_env);

  if ( !me->Fencemd_env ) 
    {
      *sts = MSFAIL;
      printf("Could not allocate memory\n");
      ASend_fence();
      return OM_E_NODYNMEM;
    }
  
   
  for ( i=0; i<me->NumOfObjects; i++ )
    {
      me->LocatedObjects[i] = FenceObjs[i].obj_id;
      me->Fencemd_env[i] = FenceObjs[i].mod_env;
    }

  me->md_env = FenceObjs[0].mod_env;
  me->ObjToProcess = me->LocatedObjects;
  me->NumToProcess = me->NumOfObjects;

 wrapup:
  ASend_fence();
  goto quit;

} /* end VRGetLocObjects */










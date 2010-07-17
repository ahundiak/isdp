/* $Id: VRNReplace.sl,v 1.2 2001/01/11 23:13:32 anand Exp $  */

/* I/ROUTE
 *
 * File:	route/vrco/VRNReplace.sl 
 *
 * Description: Replace Nozzle Component 
 * 
 * Dependencies: None
 *
 * $Revision: 1.2 $
 *
 * History: 
 *
 *	04/06/94	jim p.	TR # 179418215b
 *	10/14/94	Lori	TR # 179309027, add PID scale
 *	11/29/95	yzhu	TR # 179528304
 *
 *	12/20/95	HF	TR # 179528590
 *				Remove  _put_response( resp = TERMINATE );
 *	     			in method init().
 *	     			Otherwise I/ROUTE will crash if the command:
 *	     			"Modify Piping Nozzle" is started by keyin
 *	     			while the user has not yet logged in into PDU.
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	07/10/00	Alwin	Modified VRGetNozzle and added state init_rway
 *				to handle Raceway Nozzle. CR179901003
 *************************************************************************/

command_string		VRC_M_ModifyPipingNozzle, 0 , VRMdPpNz
synonym			VRC_M_ModifyHvacNozzle, 1 , VRMdHvNz
synonym			VRC_M_ModifyRwayNozzle, 2 , VRMdRwNz
class			VRNReplace
super_class		VRPlNozzle
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"route.cmd"

start_state	start

form "VRUserParam", 0,0,"-1","-1"

/*+cmd
  Command Object Class VRNReplace

  Superclass	VRPlNozzle

  Abstract	
		VRNReplace modifies piping and HVAC nozzles.


  Methods
      <Name>		<Public/Private>	<Description>

  Overridden Methods
     init		

  Forms
    VRUserParam		VRUserParam		
-cmd*/
specification

/*+v
  Abstract
	
  Notes/Remarks
	No Instance Variables
*/
instance

{
}

/*
-v*/
implementation

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "AS_status.h"
#include "FI.h"
#include "FEI.h"
#include "FIdyn.h"
#include "AS_status.h"
#include "ACattrib.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "dpmacros.h"
#include "ndmacros.h"
#include "VRchgattrdef.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "VRact_params.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "VRattr_def.h"
#include "VRdef.h"
#include "VRformdef.h"
/*#include "VRFormUtil.h" */

#include "VRMcForm.h"
#include "VRNozzleForm.h"
#include "VRmacros.h"
#include "VRnozzmacros.h"
#include "VRmsg.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "VRPid.h"
#include "acrepdef.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG
#define	MAIN			1

from	NDnode		import	NDdisplay, NDget_objects;
from	ACrg_collect	import	AClist_attribute;
from 	VRGeneric	import	VRGetInstance, VRGetParams, VRGetStatus;
from	VRNozzle	import  VRGetRefId;
from    ACncpx          import  ACget_NV_rep;
from	GRgraphics	import	GRdelete;

/* ======================================================================== */

state_table

#include "VRcompdef.h"
#include "VRmsg.h"
#include "VRco.h"


state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError


/* ======================================================================== */

state start


   on CMD_TYPE = 0 do	message_key	VR_M_ModifyPipingNozzle state init_pipe
   on CMD_TYPE = 1 do	message_key	VR_M_ModifyHvacNozzle   state init_hvac
   on CMD_TYPE = 2 do	message_key	VR_M_ModifyRwayNozzle   state init_rway


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state init_pipe

	message_key		VR_M_ModifyPipingNozzle
	prompt_key		VR_P_IdentifyNozzle
	accept_key    		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRPNozz"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state .

	on EX_DATA		do VRGetNozzle( &me->ret )	state Modify

	on EX_FORM_FINISHED					state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state init_hvac

	message_key		VR_M_ModifyHvacNozzle
	prompt_key		VR_P_IdentifyNozzle
	accept_key    		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRHNozz"
   	locate_owner         	"LC_RIGID_COMP | LC_REF_OBJECTS"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON				state .

	on EX_DATA		do VRGetNozzle( &me->ret )	state Modify

	on EX_FORM_FINISHED					state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state init_rway

        message_key             VR_M_ModifyRwayNozzle
        prompt_key              VR_P_IdentifyNozzle
        accept_key              VR_P_AccRejectComponent
        dynamics                off
        locate_eligible         "VRRNozz"
        locate_owner            "LC_RIGID_COMP | LC_REF_OBJECTS"
        filter                  locate

        on EX_BACK_UP or EX_RJT_MOVEON                          state .

        on EX_DATA              do VRGetNozzle( &me->ret )      state Modify

        on EX_FORM_FINISHED                                     state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state Modify


	prompt_key	VR_P_ChgPar
	dynamics	off
 	filter		get_event


	on EX_BACK_UP or EX_RJT_MOVEON				state -

	on EX_FORM_FINISHED	
                     do VRChangeAttr(&me->ret)
			on RETURN_CODE = VRUSERPARAM	
				do VRUpdateMissing (&me->ret)	state .
			on RETURN_CODE = VRNOT_OK		state .
		     do VRInsertNozzle (&me->ret)
		     state start
	
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE							state -


/* ======================================================================== */

/*+mo
  Overridden Message init

  Arguments
	None

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_xxx	...

-mo*/		/* overridden message */


action init
{
  me->NozzleId.objid = NULL_OBJID;
  me->ModifyCommand = TRUE;

  /*| call VRPlNozzle.init with respect to message */
  status = om$send ( mode     = OM_e_wrt_message,
		     msg      = message VRPlNozzle.init( type, str_ptr ),
		     targetid = my_id);

  me->Init	    = FALSE;

  if( !(status & 1 ))
  {
        return OM_E_ABORT ;
  }

  return (status);
}

/* ======================================================================== */

/*+me
  Public Message VRGetNozzle

  Abstract
      <Description>

  Algorithm
      <Optional Description>

  Arguments
      <Data Type>	<Name>  <I/O>	<Description>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_xxx	...

-me*/		/* public message */


action VRGetNozzle
{
  IGRlong	msg;
  IGRint	i, j;
  IGRint	VRNbNozAttr;
  IGRchar 	Names[VRPNbNozAttr][10];
  struct GRid	TempId[2];
  struct GRid	ExpId[VRPNbNozAttr];
  IGRint	cpt, NbExp;
  IGRchar	ExpName[VRPNbNozAttr][DI_PATH_MAX];
  unsigned char TempRep;

  me->NozzleId		    = me->event1.located_object[0].located_obj;
  me->SysParamId.objid	    = NULL_OBJID;
  me->UserParamId.objid	    = NULL_OBJID;
  me->MissingParamsId.objid = NULL_OBJID;

  status = 
  om$send( msg      = message NDnode.NDdisplay( 0, GRhe, &me->ModuleInfo ), 
		    targetid = me->NozzleId.objid,
		    targetos = me->NozzleId.osnum);
  as$status(  msg = "Error in undisplay component" );

  status = om$send(msg = message ACncpx.ACget_NV_rep(&TempRep),
		   senderid = NULL_OBJID,
		   targetid = me->NozzleId.objid,
		   targetos = me->NozzleId.osnum ) ;
  as$status();
  me->PidRep = FALSE;
  me->PidRep = bVR_IS_PID( TempRep );

  /*| -- Get parameters box from the located nozzle -- */
  status = 
  om$send( msg	      = message VRGeneric.VRGetParams( &msg, &me->SysParamId,
				   &me->UserParamId, &me->MissingParamsId ),
		    targetid  = me->NozzleId.objid,
		    targetos  = me->NozzleId.osnum );
  as$status( msg = "Error in VRGetParams" );

  /*"SysParamId = %d UserParamId = %d \n",me->SysParamId.objid,me->UserParamId.objid*/

  status = 
  om$send( msg	      = message VRGeneric.VRGetStatus( &msg, &me->CompInstance.nStatus ),
	   targetid  = me->NozzleId.objid,
	   targetos  = me->NozzleId.osnum );
  as$status( msg = "Error in VRGetStatus" );

  if( me->Product != VR_RWAY ) //added for CR179901003
  if( me->event1.located_object[0].located_obj.osnum == 2 ) 
  {
	FIg_display( me->form_ptr[0], 45 );
	FIg_erase( me->form_ptr[0], 47 );
	FIg_display( me->form_ptr[0], TYPE );
		
	FIfld_set_mode( me->form_ptr[0], EXP_TAG_NUMBER, 0, FI_INSERT);
	FIfld_set_mode( me->form_ptr[0], EXP_SERVICE   , 0, FI_INSERT);

	if( me->Product == VR_PIPING )
	{
	  	FIfld_set_mode( me->form_ptr[0], EXP_NOM_SIZE  , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_COND  , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_PRESSURE  , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_SCH_THK   , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_STAND , 0, FI_INSERT);
	}
	else
	{
	  	FIfld_set_mode( me->form_ptr[0], EXP_WIDTH , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_DEPTH , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_AIR_FLOW , 0, FI_INSERT);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_PREP , 0, FI_INSERT);
	}
  }
  else /* for cr179601978 display values in reference file*/
  {
        FIg_display( me->form_ptr[0], 45 );
        FIg_erase( me->form_ptr[0], 47 );
        FIg_erase( me->form_ptr[0], RESET_BTN );
        FIg_display( me->form_ptr[0], TYPE );
        FIg_disable( me->form_ptr[0], FI_ACCEPT );
        FIg_disable( me->form_ptr[1], FI_ACCEPT );
        FIg_disable( me->FormUser, FI_ACCEPT );
        FIg_disable( me->FormUser, 2 );

	FIfld_set_mode( me->form_ptr[0], EXP_TAG_NUMBER, 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], EXP_SERVICE   , 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], TAG_NUMBER    , 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], SERVICE       , 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], END_COND      , 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], 35            , 0, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], 35            , 1, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], 35            , 2, FI_REVIEW);
	FIfld_set_mode( me->FormUser,    12            , 0, FI_REVIEW);
	FIfld_set_mode( me->FormUser,    12            , 1, FI_REVIEW);
	FIfld_set_mode( me->form_ptr[0], TYPE          , 0, FI_REVIEW);
  	FIfld_set_mode( me->form_ptr[1], SPEC_NAME     , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], SYSTEM_NAME   , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], SEQ_NUMBER    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], FLUID         , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], ZONE_NB       , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], SCHDL_THK_OVRD, 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], INSUL_TYPE    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], INSUL_THIK    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], TRACING_TYPE  , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], PAINT_TYPE    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], OPER_TEMP     , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], OPER_PRESSURE , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], DGN_TEMP      , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], DGN_PRESS     , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], SPECIFIC_GRAV , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], APPRO_STS     , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], CONSTR_STS    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], WEIGHT_GRP    , 0, FI_REVIEW);
        FIfld_set_mode( me->form_ptr[1], CHANGE_NO     , 0, FI_REVIEW);

	FIfld_set_text( me->form_ptr[0], 10, 0, 0, 
                    "You only can review parameters in reference file", FALSE);
        if( me->Product == VR_PIPING )
	{
	  	FIfld_set_mode( me->form_ptr[0], EXP_NOM_SIZE  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_COND  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_PRESSURE  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_SCH_THK   , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_STAND , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], NOMINAL_SIZE  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], PRESSURE_CLASS, 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], SCHDL_THK     , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], END_STAND     , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], APPRV_STS     , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], CONST_STS     , 0, FI_REVIEW);
	}
	else
	{
	  	FIfld_set_mode( me->form_ptr[0], EXP_WIDTH  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_DEPTH  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_AIR_FLOW  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], EXP_END_PREP  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], WIDTH  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], DEPTH  , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], NOZZLE_AIRFLOW , 0, FI_REVIEW);
	  	FIfld_set_mode( me->form_ptr[0], END_PREP  , 0, FI_REVIEW);
	}
  }

  /* ----- Update System Parameters form ----- */
  TempId[0].objid = me->UserParamId.objid;
  TempId[1].objid = me->MissingParamsId.objid;
  status = om$send( msg      = message VRPlNozzle.VRinit( &msg ),
                    targetid = my_id );
  as$status();
  me->UserParamId.objid     = TempId[0].objid;  
  me->MissingParamsId.objid = TempId[1].objid;

  /* ----- Update User Parameters form ----- */
  status = VR$DispCollAttr(	pForm	= me->FormUser,
				Gadget	= USER_ATTR_FLD,
				pCollId	= &me->UserParamId );
  as$status( action = RET_STATUS );

  /* ----- Update Missing Parameters form ----- */
  status = om$send( msg      = message VRPlNozzle.VRUpdateMissing( &msg ),
                    targetid = my_id );
  as$status();

  /*| -- Get Referencial Id for the replace command -- */
  me->RefId.objid = NULL_OBJID; 
  status = om$send( msg	      = message VRNozzle.VRGetRefId( &msg, &me->RefId ),
		    targetid  = me->NozzleId.objid,
		    targetos  = me->NozzleId.osnum );
  as$status( msg = "Error in VRGetRefId" );
  /*" RefId = %d \n",me->RefId.objid*/

  if( me->Product == VR_PIPING )	VRNbNozAttr = VRPNbNozAttr;
  else					VRNbNozAttr = VRHNbNozAttr;

  /* if( me->CompInstance.nStatus & VR_OUT_MACRO ) yzhu  5/14/97*/
  {	
	  /* ------------------------------ */
	  /* --- Get Expressions names ---- */
	  /* ------------------------------ */

	  /* --- Get Sys collection parents --- */ 
	  NbExp      = 0;
	  status = 
	  om$send( msg = message NDnode.NDget_objects
			 ( ND_ROOT, ExpId, VRNbNozAttr, 
					       NULL, 0, OM_K_MAXINT, &NbExp ),
 	   	   targetid = me->SysParamId.objid,
	   	   targetos = me->SysParamId.osnum);
  	  as$status();
  	  /*"NbExp = %d \n",NbExp*/

  	  /* --- Get Name from each expression Id --- */
  	  for( i=0; i<NbExp; i++ )
  	  {
		cpt = 0;

		/*"ExpId = %d\n", ExpId[i].objid */

  		status = 
  		di$untranslate ( objname = ExpName[i],
                   	 	 objid   = ExpId[i].objid,
                   	 	 osnum   = ExpId[i].osnum );

		if( status & DIR_S_SUCCESS )
		{
			IGRchar		*RealName;
			char 	*strrchr();

			/*"ExpName[%d] = <%s> \n",i,ExpName[i]*/

			RealName = strrchr( ExpName[i], ':' );

			if( RealName != NULL )
		     		strcpy( Names[i], RealName+1 );
		}
		else Names[i][0] = '\0';

		/*"Name[%d] = <%s> \n",i,Names[i]*/
	  }

	if( NbExp != 0 )
	{
	/* ----- Put the expression names in the fields ----- */
	  FIfld_set_text( me->form_ptr[0], EXP_TAG_NUMBER, 0, 0, 
				Names[0], FALSE);
	  FIfld_set_text( me->form_ptr[0], EXP_SERVICE   , 0, 0, 
				Names[1], FALSE);
	
	  if( me->Product == VR_PIPING )
	    {
	      FIfld_set_text( me->form_ptr[0], EXP_NOM_SIZE  , 0, 0, 
				Names[2], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_END_COND  , 0, 0, 
				Names[3], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_PRESSURE  , 0, 0, 
				Names[4], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_SCH_THK   , 0, 0, 
				Names[5], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_END_STAND , 0, 0, 
				Names[6], FALSE);
	    }
	  else
	    {
	      FIfld_set_text( me->form_ptr[0], EXP_WIDTH  , 0, 0, 
				Names[2], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_DEPTH  , 0, 0, 
				Names[3], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_AIR_FLOW  , 0, 0, 
				Names[4], FALSE);
	      FIfld_set_text( me->form_ptr[0], EXP_END_PREP  , 0, 0, 
				Names[5], FALSE);
	    }
	}
	  /* --- Get Missing collection parents --- */ 
	  NbExp      = 0;
	  if ( me->MissingParamsId.objid != NULL_OBJID )
	    {
	      status = 
		om$send( msg = message NDnode.NDget_objects
			( ND_ROOT, ExpId, VRNbNozAttr, 
			 NULL, 0, OM_K_MAXINT, &NbExp ),
			targetid = me->MissingParamsId.objid,
			targetos = me->MissingParamsId.osnum);
	      as$status();
	    }
  	  /*"NbExp = %d \n",NbExp*/

  	  /* --- Get Name from each expression Id --- */
	  for( i=0; i<NbExp; i++ )
	  {
		cpt = 0;

		/*"expid = %d\n", ExpId[i].objid */
  		status = 
  		di$untranslate ( objname = ExpName[i],
                   	 	 objid   = ExpId[i].objid,
                   	 	 osnum   = ExpId[i].osnum );

		if( status & DIR_S_SUCCESS )
		{
			/*"ExpName[%d] = <%s> \n",i,ExpName[i]*/

	  		/* ---- Take only the names and remove the 
				directories paths ----- */
			for ( j=0; j<DI_PATH_MAX; j++ )
			{
				if ( ExpName[i][j] == ':' )
				{
					cpt += 1;
					j   += 1;
				}
				if (cpt == 3)
				{
					strcpy( Names[i], &ExpName[i][j] );
					j = DI_PATH_MAX;
				}
			}
		}
		else Names[i][0] = '\0';

		/*"Names[%d] = <%s> \n",i,Names[i]*/
	  }

	  for( i=0; i<NbExp; i++ )
	  {
  		FIfld_set_text( me->form_ptr[0], MISSING, i, 2, 
			Names[i], FALSE);
	  }
  }


  if( !me->PidRep )
    {
      FIg_erase( me->form_ptr[0], NOZ_PID_SCALE);
      FIg_erase( me->form_ptr[0], NOZ_PID_SCALE_TXT);
    }
  else
    {
      FIg_display( me->form_ptr[0], NOZ_PID_SCALE);
      FIg_display( me->form_ptr[0], NOZ_PID_SCALE_TXT);
    }
  FIf_display( me->form_ptr[0]);

  return OM_S_SUCCESS;
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/*+mi
  Private Message delete

  Abstract
      <Description>

  Algorithm
      <Optional Description>

  Arguments
      <Data Type>	<Name>  <I/O>	<Description>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_xxx	...

-mi*/		/* private message */

action delete
{
  IGRlong sts;

  if (!(me->VDB_terminated))
  {
    if( me->form_ptr[0] != NULL )
  	FIf_erase ( me->form_ptr[0] );

    if( me->form_ptr[1] != NULL )
  	FIf_erase ( me->form_ptr[1] );

    if( me->FormUser != NULL )
  	FIf_erase ( me->FormUser );

    me->ModifyCommand = FALSE;
  }

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message VDB_LOCATE.delete( f_defer_flag),
		  targetid = my_id);
  as$status( sts = sts, action = RET_STATUS );

  return OM_S_SUCCESS;
}


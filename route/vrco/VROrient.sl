/* $Id: VROrient.sl,v 1.3 2001/03/22 16:30:43 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco/VROrient.sl
 *
 * Description:
 *	Rotate Component round Primary or Secondary axis.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VROrient.sl,v $
 *	Revision 1.3  2001/03/22 16:30:43  anand
 *	JTS CR MP 3970
 *	
 *	Revision 1.2  2001/02/20 01:12:25  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/03/17  20:07:14  pinnacle
# Replaced: vrco/VROrient.sl for:  by apazhani for route
#
# Revision 1.2  2000/03/09  21:41:12  pinnacle
# For TR179900990
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/20  15:28:28  pinnacle
# Replaced: vrco/VROrient.sl for:  by kddinov for route
#
# Revision 1.3  1997/10/15  17:36:02  pinnacle
# Replaced: vrco/VROrient.sl for:  by kddinov for route
#
# Revision 1.2  1997/03/10  11:31:26  pinnacle
# Replaced: vrco/VROrient.sl for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/05/01  14:33:20  pinnacle
# Replaced: vrco/VROrient.sl for:  by hverstee for route240
#
# Revision 1.5  1996/04/30  23:31:06  pinnacle
# Replaced: vrco/VROrient.sl for:  by hverstee for route240
#
# Revision 1.4  1996/01/16  21:17:00  pinnacle
# Replaced: vrco/VROrient.sl for:  by r240_int for route240
#
# Revision 1.3  1995/12/08  21:19:56  pinnacle
# Replaced: vrco/VROrient.sl for:  by r240_int for route240
#
 *
 * History:
 *	Creation : 	Karine (isdc Paris)	07-1992
 *
 *	12/06/95	tlb	Remove VRcmd.h
 *				VR_S_InvalidDataType - not defined ,
 *				replace by VR_S_InvDataType	
 *				Missing VRsketchdef.h in state table
 *
 *	03/09/2000	Alwin	Corrected the orientation of evaluated
 *				component. Which otherwise would lead to
 *				confusion and wrong results. TR179900990
 *
 *	Mar 22 01	Anand	JTS CR MP 3970
 *************************************************************************/

command_string		VRC_M_RotatePComp, 0, VRRotPCmp
synonym			VRC_M_RotateHComp, 1, VRRotHCmp
synonym			VRC_M_RotateRComp, 2, VRRotRCmp
class			VROrient
super_class		VRCmpMgr
product_name		"$ROUTE"
start_state		start
command_table		"route.cmd"

specification

#define VRHanger 	0
#define VRComp	 	1
#define VRNOT_THIS_WAY	1110


instance
{
  struct 	GRid 	SaveCmpId;
}

/**********************************************************/

implementation

#include <stdio.h>
#include "igewindow.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "VRcsdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acrepdef.h"
#include "bsvalues.h"
#include "VRMath.h"
#include "VRmsg.h"
#include <math.h>
#include "VRcptmacros.h"
#include "vrco_pto.h"
#include "bsdotp.h"

#include "vrdbgmacros.h"
#include <stdlib.h>
#define M_PI            3.14159265358979323846

#define AS_DEBUG

from 	NDnode		import	NDdisplay;
from	VRGeneric	import	VRGetSysType,
				VRGetSupports,
				VRGetCptOnSup,
				VRGetInstance,
				VRGetCptGeom,
				VRGetParams,
				VRGetSupOnCpt,
				VRGetTopo,
				VRGetOrigCoor;
from	GRgraphics	import	GRdisplay, GRdelete, GRgetprops, GRchgprops;
from	GRvg		import	GRgetsymb;
from	ACncpx		import	ACget_NV_rep;
from	VRProduct	import	VRGetProduct;

state_table

#include "VRco.h"
#include "VRsketchdef.h"
#include "VRmsg.h"

state *
on  EX_DATA.GRst_PERPEND_FROM   state HaveError
on  EX_DATA.GRst_ANGLE_FROM     state HaveError
on  EX_DATA.GRst_TANGENT_FROM   state HaveError
on  EX_DATA.GRst_PERPEND_TO     state HaveError
on  EX_DATA.GRst_ANGLE_TO       state HaveError

/* ======================================================================== */

state start
	execute VRInitInstance ( &me->ret )

	on CMD_TYPE = 0
	do message_key		VR_M_RotatePComp
	state GET_POBJ

	on CMD_TYPE = 1
	do message_key          VR_M_RotateHComp
	state GET_HOBJ

	on CMD_TYPE = 2
	do message_key          VR_M_RotateRComp
	state GET_ROBJ

/* ======================================================================== */

state GET_POBJ

	message_key		VR_M_RotatePComp
	prompt_key		VR_P_IdCompToOrientate
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRPComp, VRPCComp"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON					state .

	on EX_DATA	do VRGetRotObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK
			do status_key VR_E_IdCompNotOrient		state -
			do VRGetCmpAttributes( &me->ret )
			do VRGetSymb( &me->ret )
			do VREvaluateComp( &me->ret )			
		on RETURN_CODE = VR_NOT_VALID				state -
		on RETURN_CODE = VR_ADDED_PARAM				state -
			do VRRotateComponent( &me->ret )
			state SwitchPrim

/* ======================================================================== */
state GET_HOBJ

	message_key		VR_M_RotateHComp
	prompt_key		VR_P_IdCompToOrientate
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRHComp, VRHCComp"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON					state .

	on EX_DATA	do VRGetRotObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK
			do status_key VR_E_IdCompNotOrient		state -
			do VRGetCmpAttributes( &me->ret )
			do VRGetSymb( &me->ret )
			do VREvaluateComp( &me->ret )			
		on RETURN_CODE = VR_NOT_VALID				state -
		on RETURN_CODE = VR_ADDED_PARAM				state -
			do VRRotateComponent( &me->ret )
			state OrientComp

/* ======================================================================== */
state GET_ROBJ

	message_key		VR_M_RotateRComp
	prompt_key		VR_P_IdCompToOrientate
	accept_key		VR_P_AccRejectComponent
	dynamics		off
	locate_eligible		"VRRComp, VRRCComp"
	filter			locate

	on EX_BACK_UP or EX_RJT_MOVEON					state .

	on EX_DATA	do VRGetRotObject ( &me->ret )
		on RETURN_CODE = VRNOT_OK
			do status_key VR_E_IdCompNotOrient		state -
			do VRGetCmpAttributes( &me->ret )
			do VRGetSymb( &me->ret )
			do VREvaluateComp( &me->ret )			
		on RETURN_CODE = VR_NOT_VALID				state -
		on RETURN_CODE = VR_ADDED_PARAM				state -
			do VRRotateComponent( &me->ret )
			state OrientComp

/* ======================================================================== */
state SwitchPrim

	message_key		VR_M_RotateComponent
	prompt_key		VR_P_DefineOrientationReverse
	dynamics		off
	filter			get_event

	on EX_BACK_UP 	  						state -

	on EX_RJT_MOVEON  
			do VRReverseComponent(&me->ret)
		on RETURN_CODE = VRNOT_OK
			    do status_key VR_S_CannotProcessThisObject	state -
		on RETURN_CODE = VRNOT_THIS_WAY				state .
									state .

	on EX_DATA/*	do VRIsOrientable( &me->ret )
		on RETURN_CODE = VRNOT_OK			
			do VRComputeComponent(&me->ret)			state start*/
									state OrientComp

	on ELSE		do VRDeleteComponent(&me->ret)			state start

/* ======================================================================== */
state OrientComp

	message_key	VR_M_RotateComponent
	prompt_key	VR_P_GiveDataOrKeyinToOrientCmp
	dynamics 	DYNCOMPONENT
	filter		get_event

	on EX_DATA	do VRComputeCmpAngle(&me->ret)
			do VRRotateComponent (&me->ret)		state .
			
	on EX_BACK_UP   					state -

	on EX_RJT_MOVEON  
			do VRRotateQuadrant (&me->ret)		state .

	on EX_STRING or DISTANCE	
		do VRGetAngle(&me->ret)
		on RETURN_CODE = VRNOT_OK		
			do VRComputeComponent(&me->ret)		state start
			do VRRotateComponent (&me->ret)		state .

	on ELSE		do VRDeleteComponent(&me->ret)		state start

/* ======================================================================== */

state HaveError
   
   status_key  VR_S_InvDataType

   on ELSE							state -

/* ======================================================================== */

action dynamics
{
  IGRint		i;
  IGRdouble		Origin[3],XAxis[3], YAxis[3];

  me->ret = MSSUCC;
  status  = OM_S_SUCCESS;

  for( i=0; i<3; i++ )
  {
	XAxis[i]  = me->CmpMatrix[i*4];
	YAxis[i]  = me->CmpMatrix[(i*4)+1];
	Origin[i] = me->CmpMatrix[(i*4)+3];
  }  

  if (dynamics == DYNCOMPONENT)
  	VRorient ( VR_PIPING, Origin, XAxis, YAxis, &me->ActiveDisplay,
                   &me->ModuleEnv);

  goto quit;

} /* end action dynamics */

/* ==================== VRGetRotObject ================================	*/

action	VRGetRotObject 
{
  IGRshort			action, props;
  IGRlong			msg;
  IGRshort			CptNum;
  IGRint			i, ret;
  IGRdouble			Origin[3];
  IGRdouble			dCpVector[3];
  struct 	GRid		SupIds[VR_MAX_CPTS], SupportId;
  enum 		GRdpmode 	Mode;

  SetProc(Md VRGetRotObject ); Begin

  /* ----- Initialize instances ----- */
  me->SaveCmpId		= me->event1.located_object[0].located_obj;
  me->ModuleEnv 	= me->event1.located_object[0].module_info;

  status = om$send( msg = message VRProduct.VRGetProduct( &me->Product,
								NULL ),
		senderid = NULL_OBJID,
		targetid = me->SaveCmpId.objid,
		targetos = me->SaveCmpId.osnum );
  as$status();

  me->bCmpReversed      = FALSE;
  me->bIsRotCmd         = TRUE;

  __DBGpr_obj("Locat Object",me->SaveCmpId);
  __DBGpr_obj("Locat MdEnv",me->ModuleEnv.md_id);

  status = dp$erase_hilite( msg   = &msg,
			    osnum = me->ModuleEnv.md_id.osnum );

  /* -- See if the located component can be reoriented -- */
  ret = FALSE;
  ret = VR$IsCmpOrientable( p_Msg 	= &msg,
			    p_CmpId	= &me->SaveCmpId,
			    p_MdEnv 	= &me->ModuleEnv );

  /* -- Supports are not colinear so we cannot rotate component -- */
  if ( !ret )
  {
    me->ret = VRNOT_OK;
    goto quit;
  }

  /* --  Retrieve nb of connect points of located component -- */
  status = om$send( msg     = message VRGeneric.VRGetTopo( &msg, VR_MAX_CPTS,
		    					   &me->CmpNbCpts,
		    					   Origin,
		    				           (IGRdouble *) NULL,
		    				           (struct GRid *) NULL,
		    				           (IGRshort *) NULL,
		    					   &me->ModuleEnv),
	    	   targetid = me->SaveCmpId.objid,
	    	   targetos = me->SaveCmpId.osnum);
  as$status ();
  __DBGpr_int("nb of connect points of located component",me->CmpNbCpts);

  /* -- Get component supports for further switch of cpts -- */
  status = 
  om$send ( msg      = message VRGeneric.VRGetSupports ( &msg, VR_MAX_CPTS, 
							 SupIds,
							 &me->NbSupports),
	    targetid = me->SaveCmpId.objid,
	    targetos = me->SaveCmpId.osnum );
  as$status ();

  /* -- Initialization of array of support to be able to see if rotation are
         possible -- */ 
  if( me->NbSupports > 1 )
  {
      /*| ----- Keep array of supports directions for further rotation ----- */

      for( i=0; i<me->NbSupports; i++ )
      {
	  status = 
	  om$send( msg     = message VRGeneric.VRGetCptOnSup( &msg, &SupIds[i],
							      &CptNum,
							      &me->ModuleEnv ),
		  targetid = me->SaveCmpId.objid,
		  targetos = me->SaveCmpId.osnum);
	  as$status ();

	  if( DBG_Gb_dbg & DBG_PROD )
	      fprintf( DBG_Gb_Fp, "Cpt %d on Support %d\n",
						     CptNum, SupIds[i].objid );

	  status = 
	  om$send( msg     = message VRGeneric.VRGetCptGeom( &msg, CptNum,
							     NULL, dCpVector,
							     NULL,
							     &me->ModuleEnv),
		  targetid = me->SaveCmpId.objid,
		  targetos = me->SaveCmpId.osnum );
	  as$status ();

	  me->SupOrientation[3*i]     = dCpVector[0];
	  me->SupOrientation[(3*i)+1] = dCpVector[1];
	  me->SupOrientation[(3*i)+2] = dCpVector[2];
	  __DBGpr_vec(" Support orientation",&me->SupOrientation[3*i]);
      }
  }

  /* Commented out the below block of code. Did not quite understand the
   * intention behind grabbing the first connected connect point. It works fine
   * without the below code, and uncommenting the below code causes me->CptNum
   * to be initialised (typically) to 0 as opposed to -1 that, down the line,
   * causes some confusing graphics.	Anand for CR 3970 */
#if 0
    /* -- Initialization of CptNum for oreintation -- */
  /* -- Take the first cpt wich is connected -- */
  SupportId.objid = NULL_OBJID;
  for( i=0; i<me->CmpNbCpts; i++ )
  {
  	status = 
  	om$send( msg     = message VRGeneric.VRGetSupOnCpt( &msg, i, &SupportId,
						            &me->ModuleEnv ),
		targetid = me->SaveCmpId.objid,
	        targetos = me->SaveCmpId.osnum );
	as$status ();

	if ( SupportId.objid != NULL_OBJID )	
	{
	    me->CptNum = i;
	    i = me->CmpNbCpts; // How about "break;" instead??
	}
  }	
  __DBGpr_int( " Cpt No ", me->CptNum );
#endif

  /* ---- Get Component ItemNum for next Evaluate ---- */
  status = 
  om$send( msg	    = message VRGeneric.VRGetSysType( &msg, &me->CmpItemNum ),
	   targetid = me->SaveCmpId.objid,
	   targetos = me->SaveCmpId.osnum);
  as$status();
  __DBGpr_int("Component type",me->CmpItemNum);

  me->CptNum = -1; //forcing it for now. Alwin for TR179900990

  /* ---- Get Located Component Matrix ----- */
  status = VR$GetMatrix ( p_msg	        = &msg,
                          p_ComponentId = &me->SaveCmpId,
			  CompCpt	= me->CptNum,
			  p_Matrix      = me->CmpMatrix,
                          p_MdEnv	= &me->ModuleEnv);
  as$status ();
  as$status ( sts = msg );
  
  __DBGpr_mat( " Old Matrix ", me->CmpMatrix );

  /*Erase the display of this object, permanently. Otherwise it will lead
    to confusion, if we refresh the screen between two stages of cmd. Alwin*/
  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  action = 0;
  status = om$send ( msg = message GRgraphics.GRchgprops( &msg,
							  &action,
							  &props ),
	  targetid = me->SaveCmpId.objid,
	  targetos = me->SaveCmpId.osnum );
  as$status();

  Mode = GRbe;
  status = 
  om$send( msg = message GRgraphics.GRdisplay ( &msg, 
					     &me->ModuleEnv.md_env.matrix_type,
				 		me->ModuleEnv.md_env.matrix, 
						&Mode, &me->ModuleEnv.md_id ),
      targetid = me->SaveCmpId.objid, 
      targetos = me->SaveCmpId.osnum );
  as$status();

if( DBG_Gb_dbg & DBG_PROD )
  fprintf(DBG_Gb_Fp,
		   "Initial CmpNbCpts %d, CptNum %d, NextCptNum %d, flip %d\n",
					me->CmpNbCpts, me->CptNum,
					me->NextCptNum, me->bFlipByCenterPoint);

  End
  goto quit;
} /* end action VRGetRotObject */

/* ======================================================================== */
/*----------------
# KDD 10-97 string input handling EX_STRING.
* me->event1.event.keyin (or value) are wrong, use me->response_data.
----------------*/
action VRGetAngle
{
SetProc(VRGetAngle); Begin

  me->ret = MSSUCC;
  status  = OM_S_SUCCESS;

  if ( (*(me->response) & EX_STRING) && (strlen(me->response_data) > 0) )
  {
      double		angle; 

      sscanf(me->response_data,"%lf", &angle);
      __DBGpr_dbl("keyin value", angle);

      me->Angle = me->Angle + M_PI * (angle/180.0); 
      modulo (&me->Angle, 2*M_PI);
      goto wrapup;
  }
  else
  { 
        *sts = VRNOT_OK;
	goto wrapup;
  }

wrapup:

End;
  goto quit;
} /* end action VRGetAngle */

/********************************************************************************/
action VRGetSymb
{
  IGRlong			msg;
  
  /*| -- Get the component Symbology -- */
  status = om$send( msg      = message GRvg.GRgetsymb (&msg, &me->Symb),
		  targetid = me->SaveCmpId.objid,
		  targetos = me->SaveCmpId.osnum );
  as$status( );

  /*"color  : %d\n", me->Symb.display_attr.color*/
  /*"weight : %d\n", me->Symb.display_attr.weight*/
  /*"style  : %d\n", me->Symb.display_attr.style*/

  /*| -- Get Navsea representation -- */
  status = 
  om$send( msg      = message ACncpx.ACget_NV_rep( &me->cRep ),
           targetid = me->SaveCmpId.objid,
           targetos = me->SaveCmpId.osnum );
  as$status();

  goto quit;
}

/*******************************************************************************/
action VRGetCmpAttributes
{
  IGRlong 	msg;
  
  SetProc(Md VRGetCmpAttributes); Begin

  /* ---- Get paraneters collections from the component ----- */
  status = 
  om$send( msg	      = message VRGeneric.VRGetParams( &msg, &me->SysParamId,
							     &me->UsrParamId, 
							     &me->MissParamId ),
	   targetid  = me->SaveCmpId.objid,
	   targetos  = me->SaveCmpId.osnum );
  as$status( action = RET_STATUS );	

  /*"SysParamId  = %d %d \n",me->SysParamId.objid,me->SysParamId.osnum*/
  /*"UsrParamId  = %d %d \n",me->UsrParamId.objid,me->UsrParamId.osnum*/
  /*"MissParamId = %d %d \n",me->MissParamId.objid,me->MissParamId.osnum*/

  /* ---- Get specific attributes from the component ---- */
  status = 
  VRGetCmpInfo( &msg, me->CmpAABBCCcode, me->CmpNumber, me->CmpNotes, 
		&me->CmpOption, &me->SaveCmpId, &me->ModuleEnv );

  /*"AABBCCcode  = %s \n",me->CmpAABBCCcode*/
  /*"Number      = %s \n",me->CmpNumber*/
  /*"Notes       = %s \n",me->CmpNotes*/
  /*"Option code = %d \n",me->CmpOption*/

  /* ---- Get Component type from the component ---- */
  status = VRGetCmpType ( &msg, (IGRshort *)&me->CmpType, &me->SaveCmpId,
			  &me->ModuleEnv );
  /*"Type = %d \n",me->CmpType*/

  End
  goto quit;
}

action VRIsOrientable
{
  IGRlong 	msg;
  IGRint	i;
  IGRdouble	dDotp;

  me->ret = VRALL_OK;
  status  = OM_S_SUCCESS;

  if ( me->NbSupports < 2 )	goto quit;

  /* -- If existing supports are non colinear we cannot rotate component -- */
  for( i=0; i<me->NbSupports; i++ )
  {
	dDotp = BSdotp(&msg, &me->SupOrientation[0], &me->SupOrientation[3*i]);
	if( fabs(dDotp) != 1 )
	{
		/*| -- Supports are not colinear so we cannot rotate component -- */
		me->ret = VRNOT_OK;
		goto quit;
	}
  }

  goto quit;
}
/*****************************************************************************/
action VRComputeComponent
{
  IGRshort 			action, props;
  IGRlong 			msg, lConstructionListMsg;
  struct	GRvg_construct	ConstructionList;
  struct	VRGenInfo	CompInstance;
  enum 		GRdpmode 	Mode;
  IGRmatrix	tempMatrix;

  SetProc(Md VRComputeComponent); Begin

  __DBGpr_int( " Cpt Num ", me->CptNum );
  status = 
  VR$GetMatrix( p_msg         = &msg,
                p_ComponentId = &me->CmpId,
		p_Matrix      = me->CmpMatrix,
		p_MdEnv       = &me->ModuleEnv );
  as$status();

  status = 
  VR$GetMatrix( p_msg         = &msg,
                p_ComponentId = &me->CmpId,
		CompCpt	      = me->CptNum,
                p_Matrix      = tempMatrix,
		p_MdEnv       = &me->ModuleEnv );
  as$status();

  me->CmpMatrix[3] = tempMatrix[3];
  me->CmpMatrix[7] = tempMatrix[7];
  me->CmpMatrix[11] = tempMatrix[11];
  __DBGpr_mat( " Component's matrix ", me->CmpMatrix );

  status = 
  om$send( msg      = message VRGeneric.VRGetInstance( &msg, &CompInstance),
	   targetid = me->SaveCmpId.objid,
	   targetos = me->SaveCmpId.osnum );
  as$status();

  __DBGpr_dbl("Calc Angle",me->Angle);
  __DBGpr_dbl("Secondary rotation angle",
				CompInstance.Attr.Comp.Orientation.dSecondary);

  me->Angle = me->Angle + CompInstance.Attr.Comp.Orientation.dSecondary;

/* The below line -
 * //  if (me->bCmpReversed)
 * replaced by the one below by Anand for CR 3970. The bFlipByCenterPoint
 * instance carries the true geometric relevance for the component being
 * flipped; the bCmpReversed does not.
 */

  if( me->bFlipByCenterPoint )
  {
      me->Angle = 2*M_PI - me->Angle;
      CompInstance.Attr.Comp.Orientation.dPrimary *= -1;
  }

  __DBGpr_dbl("New Angle", me->Angle);
  __DBGpr_dbl("Primary rotation angle",
				CompInstance.Attr.Comp.Orientation.dPrimary);

  /*| Fill in ConstructionList structure */
  ConstructionList.msg		= &lConstructionListMsg;
  ConstructionList.env_info	= (struct GRmd_env *) &me->ModuleEnv;
  ConstructionList.newflag	= FALSE;
  ConstructionList.level	= me->Symb.level;
  ConstructionList.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  ConstructionList.geometry	= 0;
  ConstructionList.display	= &me->Symb.display_attr;
  ConstructionList.class_attr	= NULL;
  ConstructionList.name		= 0;

  status = VR$Replace (	p_msg 		= &msg,
			p_OldCmpId	= &me->SaveCmpId,
			p_NewCmpId	= &me->CmpId,
			p_NewGrId	= NULL,
			NewCmpType	= me->CmpType,
			NbCpts		= me->CmpNbCpts,
			p_NewInstance	= &CompInstance,
			p_Matrix	= me->CmpMatrix,
			Angle 		= me->Angle,
			p_CnstList	= &ConstructionList,
			p_MdEnv		= &me->ModuleEnv);
  as$status ();
  as$status ( sts = msg );

  if (!(status & OM_S_SUCCESS))
  {
	/*A set the tag num to -1 */
	/*A don't want the comp to report to DB about the deletion */
	status = VRResetTagNum( &me->CmpId );
	as$status( action = RET_STATUS );

    	status = 
	om$send ( msg 	   = message GRgraphics.GRdelete( &msg, &me->ModuleEnv),
		  senderid = my_id,
		  targetid = me->CmpId.objid,
		  targetos = me->CmpId.osnum);
	as$status();

	End
    	return OM_E_ABORT;
  }

  props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  action = 0;
  status = om$send ( msg = message GRgraphics.GRchgprops( &msg,
							  &action,
							  &props ),
	  targetid = me->SaveCmpId.objid,
	  targetos = me->SaveCmpId.osnum );
  as$status();

  Mode = GRbe;
  status =
  om$send( msg      = message GRgraphics.GRdisplay( &msg, 
					     &me->ModuleEnv.md_env.matrix_type,
					     me->ModuleEnv.md_env.matrix, 
					     &Mode, &me->ModuleEnv.md_id ),
	   targetid = me->SaveCmpId.objid, 
	   targetos = me->SaveCmpId.osnum );
  as$status();

  /*A set the tag num to -1 */
  /*A don't want the comp to report to DB about the deletion */
  status = VRResetTagNum( &me->SaveCmpId );
  as$status( action = RET_STATUS );

  status = 
  om$send ( msg      = message GRgraphics.GRdelete( &msg, &me->ModuleEnv),
	    targetid = me->SaveCmpId.objid,
	    targetos = me->SaveCmpId.osnum);
  as$status();

  me->SaveCmpId.objid = NULL_OBJID;

  Mode = GRbd;
  status = 
  om$send( msg = message GRgraphics.GRdisplay( &msg, 
						&me->ModuleEnv.md_env.matrix_type,
				 		me->ModuleEnv.md_env.matrix, 
						&Mode, 
						&me->ModuleEnv.md_id ),
	   targetid = me->CmpId.objid, 
	   targetos = me->CmpId.osnum );
  as$status();

  me->Angle = 0;

  End
  goto quit;
} /* end action  VRComputeComponent*/

/*****************************************************************************/
action VRDeleteComponent
{
  IGRlong 	msg;
  enum 		GRdpmode 	Mode;

  if( me->CmpId.objid != NULL_OBJID )
  {
	Mode = GRbe;
  	status = 
  	om$send( msg      = message GRgraphics.GRdisplay( &msg, 
						    	  &me->ModuleEnv.md_env.matrix_type,
				 		    	  me->ModuleEnv.md_env.matrix, 
						    	  &Mode, 
						    	  &me->ModuleEnv.md_id ),
	    	 targetid = me->CmpId.objid, 
	    	 targetos = me->CmpId.osnum );
  	as$status();

	/*A set the tag num to -1 */
	/*A don't want the comp to report to DB about the deletion */
	status = VRResetTagNum( &me->CmpId );
	as$status( action = RET_STATUS );
  
	status = 
  	om$send ( msg      = message GRgraphics.GRdelete( &msg, &me->ModuleEnv),
	    	  targetid = me->CmpId.objid,
	    	  targetos = me->CmpId.osnum);
  	as$status();

	me->CmpId.objid = NULL_OBJID;

	Mode = GRbd;
  	status = 
  	om$send( msg      = message GRgraphics.GRdisplay( &msg, 
						    	  &me->ModuleEnv.md_env.matrix_type,
				 		    	  me->ModuleEnv.md_env.matrix, 
						    	  &Mode, 
						    	  &me->ModuleEnv.md_id ),
	    	  targetid = me->SaveCmpId.objid, 
	    	  targetos = me->SaveCmpId.osnum );
  	as$status();

    //added by alwin for TR179900990
    {
      IGRshort  action, props;
      IGRlong   retcode;

      /* Now that we've backed up completely we should ensure this component
      goes to its original state. So that one can locate and select for
      rotating the component. Alwin */
      /*****
        action  = 0     - Clearing the properties
        action  = 1     - Set the properties
        action  = -1    - Replace the properties
      *****/

      status = om$send( msg = message GRgraphics.GRgetprops( &retcode,
                                    &props ),
                         targetid = me->SaveCmpId.objid,
                         targetos = me->SaveCmpId.osnum );
      as$status();

      props =  GRIS_LOCATABLE | GRIS_DISPLAYABLE;
      action = -1; //replace the existing properties
      status = om$send ( msg = message GRgraphics.GRchgprops(
                                              &retcode,
                                              &action,
                                              &props ),
                         targetid = me->SaveCmpId.objid,
                         targetos = me->SaveCmpId.osnum );
      as$status();
   }

  }

  goto quit;
} /* end */

/*****************************************************************************/

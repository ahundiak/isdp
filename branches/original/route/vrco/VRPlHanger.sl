/* $Id: VRPlHanger.sl,v 1.1.1.1 2001/01/04 21:12:43 cvs Exp $  */

/*************************************************************************
 * I/RUOTE
 *
 * File:	vrco/VRPlHanger.sl
 *
 * Description:
 *   This file contains the command object to place support
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlHanger.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
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
# Revision 1.7  1996/03/08  20:52:58  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by hverstee for route240
#
# Revision 1.6  1996/03/05  22:07:42  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by hverstee for route240
#
# Revision 1.5  1996/03/04  18:13:02  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by hverstee for route240
#
# Revision 1.4  1996/02/06  08:27:20  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by ashankar for route240
#
# Revision 1.3  1996/01/16  21:17:18  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:20:18  pinnacle
# Replaced: vrco/VRPlHanger.sl for:  by r240_int for route240
#
 *
 * History:
 *	11/27/90			modified
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      03/05/96        hv      Implement VDB_LOCATE class
 *      03/08/96        hv      Allow support of constrained comps
 *
 *************************************************************************/

command_string       VRC_M_PlaceHanger,0,VRPlSp
class                VRPlHanger
super_class          VDB_LOCATE
product_name         "$ROUTE"
command_table	     "route.cmd"

form "VRSupDsParam",1,0,"-1","-1"

specification

#include "VRdimdef.h"
#include "VRhvacstr.h"
#include "VRpipestr.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRco.h"

instance
{
IGRshort		nProduct;
IGRdouble		dOrientationVector [3];
IGRdouble		dOriginPoint [3];
IGRdouble		dLastPoint [3];
IGRdouble		dUserDataPoint [3];
IGRdouble		dDirection [3];
IGRdouble		dCompMatrix [16];
IGRdouble		dCompOrg [3];
struct	GRmd_env	ObjEnv;
struct	GRid		CompId;
struct	tagVRSupAttr	SupportAttr;
struct	tagVRSupAttr	TmpAttr;
struct	VRGenInfo	VRGenInfo;
IGRshort		nSysType;
}

implementation

#include <stdio.h>
#include "FI.h"
#include "FEI.h"
#include "asmacros.h"
#include "parametric.h"
#include "VRdef.h"
#include "AS_status.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "bserr.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "VRMath.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"
#include "vrco_pto.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "mainvmx.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG

#define DETAIL_NUMBER			17
#define TYPE				18
#define TAG_NUMBER			16
#define WEIGHT				19
#define LOAD_ATTR			20
#define LINEDYN				1

from 	NDnode		import	NDdisplay;
from 	NDnode		import	NDplace;
from 	VRHanger	import	VRGetAttributes;
from	VRGeneric	import	VRGetSysType;
from	VRGeneric	import	VRGetMatrix;
from	VRGeneric	import	VRGetOrigCoor;
from	VRGeneric	import	VRGetStatus;
from	VRGeneric	import	VRGetCorrections;
from	VRCorrection	import	VRGetCorLength;
from	VRCorrection	import	VRGetPipeCpts;
from 	ACncpx 		import	ACget_NV_rep;

/**********************************************************/

state_table

#include	"VRmsg.h"
#include	"VRmacros.h"
#include 	"VRco.h"

#define LINEDYN				1

state start

   message_key		VR_M_PlaceHanger
   display_form		1

  on CMD_TYPE = 0	do InitAttributes( &me->ret )
			do UpdateForm( &me->ret )				state GET_OBJ

state GET_OBJ

   prompt_key		VR_P_IdSupportedComponent
   dynamics		off
   locate_class		"VRComponent,VRConcComp"
   locate_owner		"LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_RIGID_COMP"
   relocate_key		VR_P_IdComp
   accept_key		VR_P_AcceptLocationReject
   filter		locate

   on EX_DATA		do HaveObject( &me->ret )				
			on RETURN_CODE = BAD_ORIEN 
			  do status_key VR_E_PointOutOfSegmentRange
								state .
								state GET_ORIEN

   on EX_RJT_MOVEON	             				state .

   on EX_BACK_UP						state .

   on EX_FORM_FINISHED						state SUPP_ATTR

state GET_ORIEN

   prompt_key		VR_P_DefineOrientation
   dynamics		LINEDYN
   locate_stack_size	10
   relocate_key		VR_P_DefineOrientation
   filter		get_event

   
   on EX_DATA		do MakeHanger( &me->ret )				
			on RETURN_CODE = BAD_ORIEN
			  do status_key VR_S_BadOrientation	state .
								state GET_OBJ

   on EX_RJT_MOVEON						state -

   on EX_BACK_UP						state -

   on EX_FORM_FINISHED						state SUPP_ATTR


state SUPP_ATTR

   prompt_key		VR_P_IdHanger
   dynamics		off
   locate_class		"VRHanger"
   locate_owner		"LC_NO_REF_HEADER | LC_REF_OBJECTS | LC_RIGID_COMP"
   locate_stack_size	10
   accept_key		VR_P_AccReject
   filter		locate

   on EX_DATA		do HaveSupportAttributes( &me->ret )
			do TmpForm( &me->ret )
			do ResetButton( &me->ret )				state -

   on EX_RJT_MOVEON	do ResetButton( &me->ret )				state -

   on EX_BACK_UP	do ResetButton( &me->ret )				state -

   on EX_FORM_FINISHED	do ResetButton( &me->ret )			state .


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method HaveSupportAttributes

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action HaveSupportAttributes
{
IGRlong		retmsg;

  me->ret = MSSUCC;

  status = om$send( msg = message VRHanger.VRGetAttributes( 
						&retmsg, 
						&me->TmpAttr ),
		targetid = me->event1.located_object[0].located_obj.objid,
		targetos = me->event1.located_object[0].located_obj.osnum );
  as$status( );

  return ( status );

} /* end action HaveSupportAttributes */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method ResetButton

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


action ResetButton
{

  me->ret = MSSUCC;

  FIbtn_set_auto_pop_up_on( me->forms[0].form_ptr, LOAD_ATTR );

  return( OM_S_SUCCESS );

} /* end action ResetButton */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method UpdateForm

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


action UpdateForm
{

  me->ret = MSSUCC;

  FIg_set_text( me->forms[0].form_ptr, TAG_NUMBER,    me->SupportAttr.szTagNumber );
  FIg_set_text( me->forms[0].form_ptr, DETAIL_NUMBER, me->SupportAttr.szDetailNumber );
  FIg_set_value(me->forms[0].form_ptr, TYPE,          (IGRdouble)me->SupportAttr.Type );
  FIg_set_value(me->forms[0].form_ptr, WEIGHT,        me->SupportAttr.dWeight ); 

  return( OM_S_SUCCESS );

} /* end action UpdateForm */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method TmpForm

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action TmpForm
{

  me->ret = MSSUCC;

  FIg_set_text(  me->forms[0].form_ptr, TAG_NUMBER,    me->TmpAttr.szTagNumber );
  FIg_set_text(  me->forms[0].form_ptr, DETAIL_NUMBER, me->TmpAttr.szDetailNumber );
  FIg_set_value( me->forms[0].form_ptr, TYPE,          (IGRdouble)me->TmpAttr.Type );
  FIg_set_value( me->forms[0].form_ptr, WEIGHT,        me->TmpAttr.dWeight );

  FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Don't Forget To Save " );

  return( OM_S_SUCCESS );

} /* end action TmpForm */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method form_notification

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action form_notification
{
#define VRLOC_CMP       1104
#define VRALL_OK        1105

IGRchar		text[60];
IGRlong		msg;
IGRint		Type;
IGRint		my_resp;
IGRdouble	value;

  me->ret = MSSUCC;

  /*"form   label %d \n", form_label   */
  /*"gadget label %d \n", gadget_label */

  FIg_set_text(   me->forms[0].form_ptr, FI_MSG_FIELD, " " );
  FIfld_get_type( me->forms[0].form_ptr, gadget_label, 0, &Type );

  switch( gadget_label )
  {
  case DETAIL_NUMBER :

    /* IGRchar szDetailNumber [20];*/
    if ( Type == FI_ALPHA )	
    {
	IGRint	NumChar = 20;
	IGRint	r_pos;
	IGRint	selectFlag;

	FIfld_get_text( me->forms[0].form_ptr, gadget_label, 0, 0, NumChar, 
				(unsigned char*)text, &selectFlag, &r_pos );
	strcpy( me->TmpAttr.szDetailNumber, text );
    }
    else 
    {
	/*| BAD GADGET TYPE*/
	
    }

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Don't Forget To Save " );
    break;

  case TYPE: 

    /* IGRint Type;*/
    if ( Type == FI_INT )
    {
	    FIg_get_value( me->forms[0].form_ptr, gadget_label, &value );
	    me->TmpAttr.Type = (IGRint)value;
    }
    else 
    {
	/*| BAD GADGET TYPE*/
    }

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Don't Forget To Save " );
    break;

  case TAG_NUMBER :

    /* IGRchar szTagNumber [12];*/
    if ( Type == FI_ALPHA )	
    {
	IGRint	NumChar = 20;
	IGRint	r_pos;
	IGRint	selectFlag;

	FIfld_get_text( me->forms[0].form_ptr, gadget_label, 0, 0, NumChar, 
				(unsigned char *)text, &selectFlag, &r_pos );
	strcpy( me->TmpAttr.szTagNumber, text );
    }
    else
    {
	/*| BAD GADGET TYPE*/
    }

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Don't Forget To Save " );
    break;

  case WEIGHT: 

    /* IGRdouble dWeight; */
    if ( Type == FI_DOUBLE )
    {
  	    FIg_get_value( me->forms[0].form_ptr, gadget_label, &value );
	    me->TmpAttr.dWeight = value;
    }
    else
    {
	/*| BAD GADGET TYPE*/
    }

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Don't Forget To Save " );
    break;

  case FI_RESET:

    me->TmpAttr = me->SupportAttr;

    status = 
    om$send(targetid = my_id,
	    mode   = OM_e_wrt_message,
	    msg    = message VRPlHanger.UpdateForm ( &me->ret ) );
    as$status( msg = "Error in update form" );

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Changes Discarded " );
    FIg_set_state_off( me->forms[0].form_ptr, FI_RESET );
    break;

  case LOAD_ATTR:

    /* I put EX_FORM_FINISHED because it did not work with
     * EX_FORM_DATA ???????????????????????????????????????
     */
    my_resp = EX_FORM_FINISHED;
    status = ex$putque( msg = &msg,
			pos = FRONT,
			response = &my_resp );

    as$status( msg = "Error in ex$putque" );
    break;

  case FI_EXECUTE:
  case FI_ACCEPT:

    me->SupportAttr = me->TmpAttr;
    ex$message(	field	= ERROR_FIELD,
		justification = CENTER_JUS,
		in_buff	= " Values Stored " );

    me->ret = VRALL_OK;

    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " Values Stored " );
    FIg_set_state_off( me->forms[0].form_ptr, FI_EXECUTE );
    if( gadget_label == FI_ACCEPT ){
	FIf_erase( me->forms[0].form_ptr );
	_put_response( resp = TERMINATE );
    }
    break;

  case FI_CANCEL:

    me->ret = VRLOC_CMP;
    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, " " );
    FIg_set_state_off( me->forms[0].form_ptr, FI_CANCEL );
    FIf_erase( me->forms[0].form_ptr );
    _put_response( resp = TERMINATE );
    break;

  default:

    /*"gadget_label %d unknown\n", gadget_label */
    break;

  }/* end switch on gadget */

  return ( OM_S_SUCCESS );

} /* end action form_notification */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method init

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


action init
{

  me->ret = MSSUCC;

  /*| Calling VDB_LOCATE_init method with respect to message */
  status = om$send (mode = OM_e_wrt_message,
		    msg = message VDB_LOCATE.init (type , str_ptr),
		    targetid = my_id);

  if (me->VDB_terminated) return status;

  /*| Calling VRinit_products to load the macro object spaces */
  status = VRinit_products ();
  as$status (action = RET_STATUS);

  return( status);

} /* end action init */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method InitAttributes

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


action InitAttributes
{

  /* initialize support attributes */
  me->nProduct				= VR_PIPING;
  *me->SupportAttr.szTagNumber		= 0;
  me->SupportAttr.dSize			= 0.0;
  me->SupportAttr.Type			= 0;
  *me->SupportAttr.szDetailNumber	= 0;
  me->SupportAttr.dWeight		= 0.0;
  *me->SupportAttr.szRemarks		= 0;
  me->SupportAttr.ApprvStatus		= 0;
  me->SupportAttr.ConstrStatus		= 0;
  me->SupportAttr.cNoMtoFlag		= 0x20;

  /* copy in user's temporary working structure */
  me->TmpAttr = me->SupportAttr;

return( OM_S_SUCCESS );

} /* end action InitAttributes */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method HaveObject

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action HaveObject
{
IGRint			i;
IGRlong			msg;

  me->ret = MSSUCC;

  /*| object located */
  me->CompId = me->event1.located_object[0].located_obj;
  me->ObjEnv = me->event1.located_object[0].module_info;
  /*"located_obj = %d %d\n", me->CompId.objid, me->CompId.osnum */
  /*"located_obj.osnum = %d\n", me->ObjEnv.md_id.osnum */
  /*^
    printf ("Module Env Matrix of Located Object\n");
    for (i=0;i<4;i++)
      printf ("%lf,%lf,%lf,%lf\n",	me->ObjEnv.md_env.matrix [i*4],
					me->ObjEnv.md_env.matrix [i*4+1],
					me->ObjEnv.md_env.matrix [i*4+2],
					me->ObjEnv.md_env.matrix [i*4+3]);
  */

  status = om$send( msg      = message NDnode.NDdisplay( 
				0,
				GRhe, 
				&me->ObjEnv ), 
		senderid = my_id,
		targetid = me->CompId.objid, 
		targetos = me->CompId.osnum);
  as$status();


    /* +++++++++++++++++++++++++++++++++++++++++++++++ */
    /*             RETRIEVE COMPONENT TYPE		   */
    /* +++++++++++++++++++++++++++++++++++++++++++++++ */


  status = 
  om$send( msg = message VRGeneric.VRGetSysType( &msg, &me->nSysType ),
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );

  /* For MakeHanger Use - To be Component dependant */
  status = 
  om$send( msg = message VRGeneric.VRGetMatrix( &msg, 0, (struct GRid *) NULL,
					        me->dCompMatrix, &me->ObjEnv),
	   targetid = me->CompId.objid,
	   targetos = me->CompId.osnum);
  as$status ( action = RET_STATUS );
  as$status ( sts = msg , action = RET_STATUS );

  if( me->nSysType != VR_PIPE )
  {
    	/*|  Placement at component origin */
    	status = 
	om$send( msg = message VRGeneric.VRGetOrigCoor( &msg, me->dCompOrg,
							&me->ObjEnv),
		 targetid = me->CompId.objid,
		 targetos = me->CompId.osnum);
    	as$status ( action = RET_STATUS );
    	as$status ( sts = msg , action = RET_STATUS );

    	for (i=0;i<3;i++)	me->dOriginPoint [i] = me->dCompOrg [i];
  }
  else  
  {
    	/*| Pipe Component - Placement at Projection point */
    	me->dUserDataPoint [0] = me->event1.event.button.x;
    	me->dUserDataPoint [1] = me->event1.event.button.y;
    	me->dUserDataPoint [2] = me->event1.event.button.z;
    	status = (IGRlong ) VRSkLocatePipe (	&msg,
						&me->event1,
						me->dUserDataPoint,
						&me->CompId,
						&me->ObjEnv,
						me->dOriginPoint);
    	as$status (action = RET_STATUS);

    	if ( msg != MSSUCC )
    	{
		me->ret = BAD_ORIEN;
		return OM_S_SUCCESS;
    	}

    	/*^
      	printf ("AcceptPoint = (%lf,%lf,%lf)\n",
      	me->dUserDataPoint [0], me->dUserDataPoint [1], me->dUserDataPoint [2]);
    	*/
  } /* end if VR_PIPE */


  /*^ 
    printf ("dOriginPoint = (%lf,%lf,%lf)\n",
    me->dOriginPoint [0], me->dOriginPoint [1], me->dOriginPoint [2]);
  */

  /*| Forcing event to component origin or projection */
  status = VRUpdateEvent ( &msg, me->dOriginPoint, &me->event1 );
  as$status (action = RET_STATUS);

  return OM_S_SUCCESS;

} /* end action HaveObject */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method MakeHanger

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action MakeHanger
{
IGRshort		nStatus, Quatre = 4;
IGRint			i, NbCorEntity;
IGRuchar		cRep;
IGRdouble		dInvertedMatrix [16];
IGRdouble		dSupportOffset;
IGRdouble		dDirectionVector [3];
IGRdouble		dTmpVector [3], dEndPoints [6], dFactor;
IGRdouble		dCorLength;
IGRlong			msg, ConstructionListMsg, retmsg, Ret;
BSrc			rc;
enum 	GRdpmode	mode;
struct 	GRid		SupId, ContextId, SourceId, CorId;
struct	GRas		AssocList;
struct	GRvg_construct	ConstructionList;

  /* -- Put user data point in instances -- */
  me->dUserDataPoint [0] = me->event1.event.button.x;
  me->dUserDataPoint [1] = me->event1.event.button.y;
  me->dUserDataPoint [2] = me->event1.event.button.z;

  for (i=0;i<3;i++){
    me->dOrientationVector [i] = me->dUserDataPoint [i] - 
				 me->dOriginPoint[i];
  } /* end for */

  BSnorvec (&rc,me->dOrientationVector);

  /*^
    printf ("dOrientationVector = (%lf,%lf,%lf)\n",
		me->dOrientationVector [0],
		me->dOrientationVector [1],
		me->dOrientationVector [2]);
  */

  /*| Check Support Orientation */
  VRCheckSupportOrientation (&retmsg, &me->CompId, me->dOrientationVector,
					    &me->ObjEnv);
  if (retmsg != MSSUCC)
    {
    /*| Bad Direction of Hanger */
    me->ret = BAD_ORIEN;

    /*| Forcing event to component origin or projection */
    status = VRUpdateEvent (	&msg,
				me->dOriginPoint,
				&me->event1);
    as$status (action = RET_STATUS);
    return OM_S_SUCCESS;
  } 

  /*| Get Component Representation */
  cRep = 0x20;
  status = om$send( msg = message ACncpx.ACget_NV_rep
			    ( &cRep ),
		    targetid = me->CompId.objid,
		    targetos = me->CompId.osnum );
  as$status( action = RET_STATUS );
  /*"Representation got from Component = %d\n",cRep */

  /************* Compute Factor for Pipe Component ***********************/
  status = om$send(msg = message VRGeneric.VRGetStatus (
				    &msg,
				    &nStatus),
		    targetid = me->CompId.objid,
		    targetos = me->CompId.osnum );
  as$status( action = RET_STATUS );


  /* Initialize dFactor to null in case of support on component */
  dFactor = 0.0;

  if (nStatus & VR_CORRECTION){
    /*| Compute Factor for Correction Component */
    status = om$send(msg = message VRGeneric.VRGetCorrections (
				&msg,
				1,
				&CorId,
				&NbCorEntity),
		targetid = me->CompId.objid,
		targetos = me->CompId.osnum );
    as$status( action = RET_STATUS );
    /*"CorId is %d\n", CorId.objid */

    status = om$send(msg = message VRCorrection.VRGetPipeCpts (
				&retmsg,
				&me->ObjEnv,
				dEndPoints),
		targetid = CorId.objid,
		targetos = CorId.osnum );
    as$status( action = RET_STATUS );
    /*^
      printf( "By GetPipeCpts dEndPoints [0] = (%lf,%lf,%lf)\n",
      		dEndPoints [0],dEndPoints [1],dEndPoints [2]);
      printf( "dEndPoints [3] = (%lf,%lf,%lf)\n",
    		dEndPoints [3],dEndPoints [4],dEndPoints [5]);
    */
    BSmkvec (&rc, dDirectionVector, &dEndPoints [3], &dEndPoints [0]);
    BSnorvec (&rc,dDirectionVector);

    status = om$send(msg = message VRCorrection.VRGetCorLength (
				0,
				&me->ObjEnv,
				&dCorLength),
		targetid = CorId.objid,
		targetos = CorId.osnum );
    as$status( action = RET_STATUS );

    /*"Correction length = %lf\n",dCorLength */

    if( dCorLength < VR_EPSILON ){
	dFactor = 0.0;
    }
    else{
	BSmkvec (&rc, dTmpVector, me->dOriginPoint, &dEndPoints [0]);
	if( (dSupportOffset = BSlenvec (&rc,dTmpVector)) < VR_EPSILON ){
	    dFactor = 0.0;
	}
	else{
	    dFactor = dSupportOffset / dCorLength;
	}
    } /* end if CorLength Null */

    /*"dFactor = %lf\n", dFactor */
    /*| Process Support Origin relative to one EndPoint */
    for (i=0;i<3;i++){
	me->dCompMatrix [i*4+3] = dEndPoints [i] -
			    dDirectionVector [i] * dCorLength * dFactor;
    }
    /*^
      printf ("New dCompMatrix (3,7,11) = (%lf,%lf,%lf)\n",
    	me->dCompMatrix [3], me->dCompMatrix [7], me->dCompMatrix [11]);
      printf ("dFactor = %lf\n", dFactor);
    */
  } /* end if Pipe Support */

  /********************** Process Component Orientation ******************/

  for (i=0;i<3;i++){
    dTmpVector [i] = me->dOrientationVector [i];
  } /* end for */

  /*| Invert Transformation matrix of component for Hanger Orientation */

  MAinvmx (&Ret,&Quatre,me->dCompMatrix,dInvertedMatrix);
  if (!Ret){
    /*| Error Inverting Component Matrix */
    return Ret;
  }
  for (i=0;i<3;i++){
    me->dOrientationVector [i] = dTmpVector [0] * dInvertedMatrix [i*4] + 
				 dTmpVector [1] * dInvertedMatrix [i*4+1] +
				 dTmpVector [2] * dInvertedMatrix [i*4+2]; 
  } 

  /*************** FINAL TRANSFORMATION ***********************/
  /*^
    printf ("dOrientation vector in component referential\n");
    printf ("dOrientationVector = (%lf,%lf,%lf)\n",
		me->dOrientationVector [0],
		me->dOrientationVector [1],
		me->dOrientationVector [2]);
  */
  for (i=0;i<3;i++)
    me->VRGenInfo.Attr.Supp.dOrientation [i] = me->dOrientationVector [i];

  /******************************************************************/
  /*" GRfindcontext : osnum passed=%d\n", me->ObjEnv.md_id.osnum */

  status = GRfindcontext(	&msg,
				&me->ObjEnv.md_env.matrix_type,
				me->ObjEnv.md_env.matrix,
				&me->ObjEnv.md_id.osnum,
				&ContextId );
  if (status == OM_S_SUCCESS && msg == MSSUCC){
    /*"Context found\n" */
    if (ContextId.osnum == me->CompId.osnum){
	/*"ContextId.osnum == me->CompId.osnum\n" */
	ContextId.objid = NULL_OBJID;
    }
  }
  else{
    /*"Context not found\n" */
    ContextId.objid = NULL_OBJID;
  }


  /*| Construct new source element */
  as$make_source( go_grid	= me->CompId,
		  context_grid 	= ContextId,
		  as_os 	= me->ModuleInfo.md_id.osnum,
		  as_grid 	= &SourceId);
  /*"SourceId (os,id)=(%d,%d)\n",SourceId.osnum,SourceId.objid */

  /*| Set Assoc and Construction list and Specific attributes */
  AssocList.num_parents    	= 1;
  AssocList.parents        	= &SourceId;
  AssocList.context        	= NULL;
  AssocList.as_attr        	= ( IGRchar * ) &me->VRGenInfo;
  AssocList.go_attr        	= NULL;
  AssocList.go_objid.objid 	= NULL_OBJID;
  AssocList.my_context.objid	= NULL_OBJID;

  ConstructionList.msg		= &ConstructionListMsg;
  ConstructionList.env_info	= (struct GRmd_env *) &me->ModuleInfo;
  ConstructionList.newflag	= FALSE;
  ConstructionList.level	= me->ActiveLevel;
  ConstructionList.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  ConstructionList.geometry	= 0;
  ConstructionList.display	= &me->ActiveDisplay;
  ConstructionList.class_attr	= NULL;
  ConstructionList.name		= 0;

  me->VRGenInfo.nStatus 	= 0;
  strcpy ( me->VRGenInfo.szAABBCC , VR_SUPPORT_NAME );
  me->VRGenInfo.nNbAttr 	= 0;
  me->VRGenInfo.nNbTopo 	= 1;
  me->VRGenInfo.GraphicsId.objid= NULL_OBJID;
  me->VRGenInfo.cRep		= cRep;
  me->VRGenInfo.nJustif		= VR_CENTER_JUST;
  me->VRGenInfo.Attr.Supp.dFactor = dFactor;
  me->VRGenInfo.VRSupAttr	= me->SupportAttr;

  /*^
    printf ("Level : %d, Osnum of LocatedObject : %d, Current Osnum : %d\n",
			me->ActiveLevel,
			me->ObjEnv.md_id.osnum,
			me->ModuleInfo.md_id.osnum);
  */

    /* +++++++++++++++++++++++++++++++++++++++++++++++ */
    /*            PLACE SUPPORT                        */
    /* +++++++++++++++++++++++++++++++++++++++++++++++ */

  SupId.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct (classname = "VRHanger", 
		    p_objid   = &SupId.objid, 
		    osnum     = SupId.osnum );
  as$status( action = RET_STATUS );

  status = om$send( msg = message VRHanger.NDplace(
				(struct GRas *) &AssocList,
				(struct GRmd_env *) &me->ModuleInfo,
				(IGRchar *) &ConstructionList),
		targetid = SupId.objid,
		targetos = SupId.osnum );
  as$status( action = RET_STATUS );

  mode = GRbd;
  status = om$send( msg = message VRGeneric.NDdisplay(
				0,
				mode,
				(struct GRmd_env *) &me->ModuleInfo),
		targetid = SupId.objid, 
		targetos = SupId.osnum);
  as$status();

  return(OM_S_SUCCESS);

} /* end action MakeHanger */



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			method dynamics

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action dynamics
{

  switch (dynamics){
  case LINEDYN:
    status = VRBlinear (me->dOriginPoint,&me->ActiveDisplay);
    as$status (action = RET_STATUS);
    break;
  default:
    status = om$send (msg = message CEO.dynamics (dynamics,sts),
				mode = OM_e_wrt_message,
				targetid = my_id);
    as$status ();
  } /* end switch */

} /* end action dynamics */


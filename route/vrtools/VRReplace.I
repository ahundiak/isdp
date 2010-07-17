/* $Id: VRReplace.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRReplace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRReplace.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
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
# Revision 1.2  1996/01/18  00:32:22  pinnacle
# Replaced: vrtools/VRReplace.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *
 *************************************************************************/
/*************************************************************/
/*	File 	: VRReplace.I
/*	Author	: B Demars ( ISDC, Paris )
/*	Date	: 13-Jan-92 Route release 1.4.3.18
/*
/*	* --92	1.4.3.
/*
/*************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "igr.h"
#include "msdef.h"
#include <stdio.h>
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRstructs.h"
#include "VRmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#define AS_DEBUG

from NDnode	import	NDget_objects, NDchange_node, NDs_compute_node;
from NDnodein	import	NDchange_connect;
from VRGeneric	import	VRGetSupports, VRGetInstance;

from GRvg	import	GRgetname, GRputname, GRchgname;

/*-------------------------------------------------------------------*/
/*	function VRReplace component
/*
/* 
/* Given two component objects, it replaces the old component by the
/* new one.
/* The new component should have been evaluated before, using the
/* VR$Evaluate macro.
/* 
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/


IGRint VRReplace( msg, 	p_OldCmpId,
			p_NewCmpId, NewCmpType,p_NewGrId, NbCpts,
			p_NewCmpStr, NbNewSegs, NewSegIds,
			dMatrix, dAngle,
			p_CnstList, p_MdEnv )
			       
IGRlong 		*msg ;         	/* O : Return code, MSSUCC or MSFAIL.   */
struct GRid		*p_OldCmpId ; 	/* I : Component to get ridde of.       */
struct GRid		*p_NewCmpId ; 	/* I : Component to substitute.         */
IGRint			NewCmpType; 	/* I : Component's type (returned by VR$Evaluate) */
struct GRid		*p_NewGrId;	/* I : New component's graphic		*/
IGRint			NbCpts;		/* I : Number of connection points.	*/
struct VRGenInfo	*p_NewCmpStr;  	/* I : Temporary */
IGRint			NbNewSegs;	/* I : Number of segments to be added.	*/
struct GRid		*NewSegIds;	/* I : List of new segments.		*/
IGRdouble		*dMatrix;      	/* I : Default Orientation and position matrix. */
IGRdouble		dAngle;	       	/* I : Rotation angle around ??? */
struct GRvg_construct   *p_CnstList;   	/* I : construction list */
struct GRmd_env 	*p_MdEnv;

/*.VRReplace */
{
	IGRint		status,i;
	IGRint		NbSegs, NbAttr;
	IGRlong		retmsg;
	struct GRid	SegList[VR_MAX_CPTS];


	/*"OldCompId = <%d %d>\n", p_OldCmpId->objid, p_OldCmpId->osnum */
	/*"NewCompId = <%d %d>\n", p_NewCmpId->objid, p_NewCmpId->osnum */

		/* ---------------------- */
		/* -- Graph management -- */
		/* ---------------------- */

	/* -- Change all dependents from old to new componnet -- */

	{	/* Get all dependents of old component */

		IGRint		NbChildren;
		struct GRid	*buffer;

		status = om$send(
			msg      = message NDnode.NDget_objects (
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&buffer,
						0,
						OM_K_MAXINT,
						&NbChildren ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status( action = RET_STATUS );

		/* Loop on dependents to change their connection to new component */

		/*"NbChildren = %d \n",NbChildren*/

		for ( i=0; i<NbChildren; i++ )
		{

			/*" Moving dependent : <%d,%d>\n", buffer[i].objid, buffer[i].osnum */
			status = om$send(
				mode	 = OM_e_wrt_message,
				msg      = message NDnodein.NDchange_connect (
						1, p_OldCmpId, p_NewCmpId ),
				senderid = NULL_OBJID,
				targetid = buffer[i].objid,
				targetos = buffer[i].osnum );
			as$status();

		}/* end loop on dependents */

	}/* end move dependents */

	/* -- Get segment ids for the new component placement -- */

	status = om$send(
		msg      = message VRGeneric.VRGetSupports (
				&retmsg, VR_MAX_CPTS, SegList, &NbSegs ),
		senderid = NULL_OBJID,
		targetid = p_OldCmpId->objid,
		targetos = p_OldCmpId->osnum );
	as$status();

	/*"NbSegs = %d \n",NbSegs*/

	/*| -- Get number of attributes collections of old component -- */

	{
		struct VRGenInfo	TmpInstance;
		status = om$send(
			msg      = message VRGeneric.VRGetInstance (
					&retmsg, &TmpInstance ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		NbAttr = TmpInstance.nNbAttr;

	}/* end get number of attributes collections */

	/*| -- Disconnect topology from old component -- */

	if (NbSegs)
	{
		OM_S_CHANSELECT	Channel;

		Channel.type 		= OM_e_name;
		Channel.u_sel.name 	= "father";

		status = om$send(
			msg      = message Root.range_disconnect
					( Channel, NbAttr, OM_K_MAXINT ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status( action = RET_STATUS );

	}/* end disconnect topology */

	/*| -- Place new component with full topology -- */

		/* add new segments to the list */

	if ( NbNewSegs > 0 && (NbSegs + NbNewSegs) <= VR_MAX_CPTS )
	{

		/*" Add %d segments to the list\n", NbNewSegs */

		for ( i=0; i<NbNewSegs; i++ )
			SegList[NbSegs+i] = NewSegIds[i];

		NbSegs += NbNewSegs;

	}/* end add new segments */

	/*| perform the placement */
	if ( NbSegs )
	{
		status = 
		VR$Place (	p_msg		= msg,
				p_ComponentId	= p_NewCmpId,
				Type		= NewCmpType,
				NbCpts		= NbCpts,
				p_GraphicsId	= p_NewGrId,
				p_Instance	= p_NewCmpStr,
				NbSegments	= NbSegs,
				p_SegmentIds	= SegList,
				p_Matrix	= dMatrix,
				Angle		= dAngle,
				p_CnstList	= p_CnstList,
				p_MdEnv		= p_MdEnv );
		as$status ( action = GOTO_VALUE, value = wrapup );
	}
	/*| -- Change name -- */

	{
		IGRchar		CompName[100];

		CompName[0] = 0;

		status =
		om$send( msg = message GRvg.GRgetname ( &retmsg, CompName ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		/*" CompName = \"%s\"\n", CompName */

		status =
		om$send( msg = message GRvg.GRchgname ( &retmsg, p_MdEnv, "" ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		status =
		om$send( msg = message GRvg.GRputname ( &retmsg, CompName ),
			senderid = NULL_OBJID,
			targetid = p_NewCmpId->objid,
			targetos = p_NewCmpId->osnum );
		as$status();

	}/* end manage Naming */

	/*| -- Update graph -- */

	status =
	om$send( msg = message NDnode.NDchange_node ( p_MdEnv ),
		senderid = NULL_OBJID,
		targetid = p_NewCmpId->objid,
		targetos = p_NewCmpId->osnum );
	as$status(action = RET_STATUS);
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

wrapup :
	/*| -- On Error restore previous steps -- */

	printf (" ERROR treatment not yet implemented in VRReplace \n");
	return OM_E_ABORT;

}/* end VRReplace */

end implementation Root;

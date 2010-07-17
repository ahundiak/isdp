/* $Id: VRReConnect.I,v 1.2 2001/02/20 01:18:04 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRReConnect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRReConnect.I,v $
 *	Revision 1.2  2001/02/20 01:18:04  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1996/08/06  17:21:36  pinnacle
# Replaced: vrtools/VRReConnect.I for:  by r241_int for route
#
# Revision 1.2  1996/07/25  19:39:26  pinnacle
# (No comment)
#
# Revision 1.1  1996/04/24  23:57:48  pinnacle
# Created: vrtools/VRReConnect.I by msmanem for pmeroute
#
# Revision 1.2  1996/01/18  00:32:16  pinnacle
# Replaced: vrtools/VRReConnect.I for:  by r240_int for route240
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

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "msdef.h"
#include <stdio.h>
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRstructs.h"
#include "VRcsdef.h"
#include "VRcordef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#define AS_DEBUG

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

from NDnode	 import	NDget_objects, NDchange_node;
from NDnodein	 import	NDchange_connect;
from VRGeneric	 import	VRGetSupports, VRGetInstance, VRGetIndex;
from VRGeneric	 import	VRGetCptOnSup,VRGetStatus;
from GRvg	 import	GRgetname, GRputname, GRchgname;
from VRGeneric	 import	VRNotifyCorrections;
from VRComponent import	VRDisconnect;

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

IGRint VRReConnect( msg, p_OldCmpId, p_NewCmpId, nCptNum, NbCpts,
		    NbNewSegs, NewSegIds, p_MdEnv)
	
		       
IGRlong 		*msg ;         	/* O : Return code, MSSUCC or MSFAIL.   */
struct GRid		*p_OldCmpId ; 	/* I : Component to get ridde of.       */
struct GRid		*p_NewCmpId ; 	/* I : Component to substitute.         */
IGRshort		*nCptNum;	/* I : */ 
IGRint			NbCpts;		/* I : Number of connection points.	*/
IGRint			NbNewSegs;	/* I : Number of segments to be added.	*/
struct GRid		*NewSegIds;	/* I : List of new segments.		*/
struct GRmd_env 	*p_MdEnv;

/*.VRReConnect */
{
	IGRint		status,i;
	IGRint		NbSegs, NbAttr;
	IGRshort	CptNum[VR_MAX_CPTS];
	IGRshort	nIndex[VR_MAX_CPTS];
	struct GRid	SegList[VR_MAX_CPTS];
	IGRshort	StatusValue;

	SetProc ( VRReConnect ); Begin

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
		status = VDPPmeUpdate( msg, *p_NewCmpId, *p_OldCmpId );
		CheckRC ( status, *msg );

	}/* end move dependents */

	/* -- Get segment ids for the new component placement -- */
	status = om$send(
		msg      = message VRGeneric.VRGetSupports (
				msg, VR_MAX_CPTS, SegList, &NbSegs ),
		senderid = NULL_OBJID,
		targetid = p_OldCmpId->objid,
		targetos = p_OldCmpId->osnum );
	as$status();
	/*"NbSegs = %d \n",NbSegs*/

	for( i=0; i<VR_MAX_CPTS ; i++ )
	{
		nIndex[i] = -1;
		CptNum[i] = -1;
	}

	/*| ----- Retrieve Component Index and CptNum on its topos ----- */ 
  	for ( i=0; i<NbSegs ; i++ )
  	{
    		status = 
		om$send( msg	   = message VRGeneric.VRGetIndex( msg, 
					    			   &SegList[i],
					    			   &nIndex[i]),

			 senderid = NULL_OBJID,
		         targetid = p_OldCmpId->objid,
		         targetos = p_OldCmpId->osnum);


		if( nCptNum )
			CptNum[i] = nCptNum[i];
		else
		{
		/*C If The old Component is an Error Component then trying */
		/*C to GetCptOnSup returns an OM_E_ABORT. To avoid this    */
		/*C verify for the component status before sending the 	   */
		/*C message. 						   */

		/*C	Fix for TR # 179421187 - Mallik		 	   */

			status = om$send( msg	= message VRGeneric.VRGetStatus
					( msg, &StatusValue ),
				senderid = NULL_OBJID,
				targetid = p_OldCmpId->objid,
				targetos = p_OldCmpId->osnum );
			as$status ();
			if (!( StatusValue & VR_ERROR))
			{
			status = 
			om$send ( msg     = message VRGeneric.VRGetCptOnSup( 
								     msg, 
						       		     &SegList[i],
								     &CptNum[i],
						       		     p_MdEnv ),
 			  	  senderid = NULL_OBJID,
		     	  	  targetid = p_OldCmpId->objid,
	             	  	  targetos = p_OldCmpId->osnum );
			as$status ();
			}
		}
  	}

	/*| -- Get number of attributes collections of old component -- */
	{
		struct VRGenInfo	TmpInstance;
		status = om$send(
			msg      = message VRGeneric.VRGetInstance (
					msg, &TmpInstance ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		NbAttr = TmpInstance.nNbAttr;

	}/* end get number of attributes collections */


	/*| -- Disconnect topology from old component -- */

	for(i=0;i<NbSegs; i++)
	{
		status = om$send(msg      = message VRComponent.VRDisconnect
					( msg, &SegList[i], p_MdEnv ),
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
  		status = VRConnect( msg, p_NewCmpId, CptNum, NbCpts, 
				    SegList, NbSegs, nIndex, p_MdEnv );
	}

	/*| -- Change name -- */
	{
		IGRchar		CompName[100];

		CompName[0] = 0;

		status =
		om$send( msg = message GRvg.GRgetname ( msg, CompName ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		/*" CompName = \"%s\"\n", CompName */

		status =
		om$send( msg = message GRvg.GRchgname ( msg, p_MdEnv, "" ),
			senderid = NULL_OBJID,
			targetid = p_OldCmpId->objid,
			targetos = p_OldCmpId->osnum );
		as$status();

		status =
		om$send( msg = message GRvg.GRputname ( msg, CompName ),
			senderid = NULL_OBJID,
			targetid = p_NewCmpId->objid,
			targetos = p_NewCmpId->osnum );
		as$status();

	}/* end manage Naming */

	/*| -- Update graph -- */
	status = om$send( msg = message NDnode.NDchange_node ( p_MdEnv ),
			  senderid = NULL_OBJID,
			  targetid = p_NewCmpId->objid,
			  targetos = p_NewCmpId->osnum );
	as$status(action = RET_STATUS);

	status = 
	om$send( msg = message VRGeneric.VRNotifyCorrections( msg, 0 ),
		 senderid = NULL_OBJID,
		 targetid = p_NewCmpId->objid,
		 targetos = p_NewCmpId->osnum );
	as$status(action = RET_STATUS);

	End
	return OM_S_SUCCESS ;

}/* end VRReConnect */

end implementation Root;

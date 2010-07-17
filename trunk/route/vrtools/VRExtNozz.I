/* $Id: VRExtNozz.I,v 1.1.1.1 2001/01/04 21:13:11 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRExtNozz.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRExtNozz.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:11  cvs
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
# Revision 1.2  1996/01/18  00:30:38  pinnacle
# Replaced: vrtools/VRExtNozz.I for:  by r240_int for route240
#
 *
 * History:
 *    	20-OCT-93  BD   creation date for VDS equipments.
 *	01/17/96  tlb	Add prototypes, Change VRExtNozzles to ANSII style
 *
 *************************************************************************/

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRstructs.h"
#include "VRnozzmacros.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRPid.h"
#include "vrtools_pto.h"

from    VRNozHold	import	VRGetInstance,
				VRGiveAttributes;
from    ACncpx	import	ACgive_structure;
from    ASnode	import	ACconnect_pretend;

IGRint VRExtNozzles ( 
	struct GRid 	*pEquipId,	/* Equipment holding the nozzle */
	IGRchar		cRep,		/* Representation of the equipment */
	struct GRid 	*pNozHoldId,	/* Foot Nozzle Hold 
						(stored in the definition) */
	IGRchar		*pcPath,	/* Path to the Foot 
						(to create the pretend */
	struct GRvg_construct *pCnstList,/* Construction parameters fo nozzle */
	struct GRid 	*pNozzleId,	/* Returns the placed nozzle */
	struct GRmd_env	*pMdEnv		/* Module Environment */
	)
{

  IGRint			status,j,Index, Product;
  IGRint			NbCollections,NbAttributes[VR_NB_ATTR];
  IGRlong			retmsg;
  struct GRid			TempList[VR_NB_ATTR+1], PretId;
  struct VRGenInfo		NozzInstance;
  struct ACrg_coll		Attributes[200];


	/*C Initialize */
	for (j=0; j<VR_NB_ATTR+1; j=j+1)
	{
		TempList[j].objid = NULL_OBJID;
	}

	/*A Get all attributes from the Nozzle Hold */

	/* -- Generate attributes collections -- */

	/*A Get attributes from VRNozHold */

	/*C Get Instances */
	status = 
	om$send ( msg = message VRNozHold.VRGetInstance
					( &retmsg, &Product,
			   		NozzInstance.szNumber,
			   		NozzInstance.szNotes,
			   		&NozzInstance.Attr.Nozz.dSecAngle ),
		senderid = NULL_OBJID,
		targetid = pNozHoldId->objid,
		targetos = pNozHoldId->osnum );
	as$status ( action = RET_STATUS );

	/*C Get attributes to be stored in collections */
	status = 
	om$send ( msg = message VRNozHold.VRGiveAttributes
					( &retmsg, VR_NB_ATTR, 200,
					&NbCollections, NbAttributes, 
					Attributes ),
		senderid = NULL_OBJID,
		targetid = pNozHoldId->objid,
		targetos = pNozHoldId->osnum );
	as$status ( action = RET_STATUS );

	/*" %d collections\n",NbCollections*/

	/*C Create collections */
	Index = 0;
	for (j=0; j<NbCollections; j=j+1)
	{
		TempList[j].osnum = pEquipId->osnum;
		status = VR$ModifyCollection
				( p_msg 		= &retmsg,
		  		Operation		= VR_MERGE_COLL,
		  		p_ParamsListToModify	= &Attributes[Index],
		  		NbParamsToModify	= NbAttributes[j],
		  		p_OutputCollectionId	= &TempList[j] );

		Index = Index + NbAttributes[j];
		as$status (action = RET_STATUS );

		/*
		printf (" Collection[%d] = <%d, %d>\n", j,
			TempList[j].objid, TempList[j].osnum);
		*/

	}/* end loop on collections */

	/*A Evaluate Nozzle */

	pNozzleId->objid = NULL_OBJID;

	NozzInstance.cRep		= cRep;
	NozzInstance.nStatus		= VR_GR_DEPENDANT;
	NozzInstance.nJustif		= VR_CENTER_JUST;
	NozzInstance.szAABBCC[0]	= 0;

	status = VR$EvaluateNozz( p_msg			= &retmsg,
 		  		Product			= Product,
 		  		p_Instance		= &NozzInstance,
 		  		p_SysParamsId		= &TempList[0],
 		  		p_UsrParamsId		= &TempList[1],
 		  		p_MssParamsId		= &TempList[2],
		  		p_ComponentId		= pNozzleId,
 		  		p_NbMissingParams	= NULL,
 		  		p_NbCpts		= NULL,
 		  		p_MdEnv			= pMdEnv );

	if ( ! (status&1) || (retmsg != MSSUCC) )
	{
		printf ("Nozzle evaluation failed \n");
		goto VRBadNozzle;
	}

	/*A  Generate pretend as child of the equipment */

	/*C Generate pretend object */
	status =
	om$send ( msg = message ASnode.ACconnect_pretend( 
					(IGRint *) &retmsg,
					pcPath, &PretId  ),
		senderid = NULL_OBJID,
		targetid = pEquipId->objid,
		targetos = pEquipId->osnum );
	as$status();

	/*A Connect the nozzle to the pretend */

	status = 
	VR$PlaceNozz (	p_msg		= &retmsg,
			p_ComponentId	= pNozzleId,
			p_Instance 	= &NozzInstance,
			p_RefId		= &PretId,
			p_CnstList	= pCnstList,
			p_MdEnv 	= pMdEnv );
	if ( ! (status&1) || (retmsg != MSSUCC) )
	{
		printf ("Nozzle placement failed \n");
		goto VRBadNozzle;
	}

	return OM_S_SUCCESS;

VRBadNozzle :
	if ( pNozzleId->objid != NULL_OBJID )
	{
		printf ("SHOULD DELETE NOZZLE\n");
	}

	return OM_E_ABORT;

}/* end of VRExtNozzles */

end implementation Root;

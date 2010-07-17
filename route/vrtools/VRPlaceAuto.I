/* $Id: VRPlaceAuto.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRPlaceAuto.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlaceAuto.I,v $
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
# Revision 1.3  1996/01/18  00:32:08  pinnacle
# Replaced: vrtools/VRPlaceAuto.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *
 *************************************************************************/
/*************************************************************/
/*D	File 	: VRPlaceAuto.I
	Author	: B Demars ( ISDC, Paris )
	Date	: 22-JUL-93 Route release 2.2.0.14

	The function VRPlaceAutoComponent on topology
		- Dangle
		- Elbow
		- Tee

*************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "VRSttopo.h"

#include "AS_status.h"
#include "vrtools_pto.h"
#include "bscrossp.h"

from NDnode	import	NDdisplay;

IGRint VRPlaceAutoComponent( msg, Product, pCmpId, bDisplay,
			pSysId, pUsrId, NbTopo, pTopo, pSymb, cRep, pmd_env )

IGRlong 		*msg ;		/* O : Return code, MSSUCC or MSFAIL.   	*/
IGRint			Product;	/* I : Product number ( see vrdef.h )		*/
struct GRid		*pCmpId ;	/* O : Component placed.                	*/
IGRboolean		bDisplay;	/* I : Display place component.			*/
struct GRid		*pSysId ;	/* I : System parameter collection.             */
struct GRid		*pUsrId ;	/* I : User parameter collection.              	*/
IGRint			NbTopo;		/* I : Number of segment to  be attached to. 	*/
struct VRTopo		*pTopo ;	/* I : List of segments.                	*/
struct GRsymbology	*pSymb;		/* I : Symbology				*/
IGRchar			cRep;		/* I : representation				*/
struct GRmd_env 	*pmd_env;	/* I : Module environment			*/

{
register IGRint		i;
	IGRint		status;
	IGRlong		retmsg;
	IGRshort	nItemNum;
	IGRdouble	dTopoAngle=0.0;
	IGRdouble	dMatrix[16];


/*A 	I/	Based on the number of Topology specified select the type of 
		component that will be placed :

			1 - DANGLE
			2 - ELBOW
			3 - TEE
*/
	switch ( NbTopo )
	{
		case 1 : nItemNum = VR_DANGLING;break;
		case 2 : nItemNum = VR_ELBOW;	break;
		case 3 : nItemNum = VR_TEE;	break;
		default : return OM_E_INVARG;

	}/* end switch ( NbSegments ) */

	if ( NbTopo == 1 )
	{
		/*C Get matrix from end of segment 1 */
		status =
		VR$GetMatrix(
			p_msg		= &retmsg,
			p_SegmentId	= &pTopo[0].SegId,
			SegEnd		= (IGRint) pTopo[0].nEndPoint,
			p_Matrix	= dMatrix,
			p_MdEnv		= pmd_env );
		as$status( action = RET_STATUS);

		/*C KLUDGE FOR DANGLES UNTIL SKETCH GETS VALUES FROM PIPE CPT */
		/*C If the width of the only topo is specified => Y axis . */
		if ( NbTopo == 1 && pTopo[0].pd3Width )
		{
			IGRdouble 	dXaxis[3], dZaxis[3];
			BSrc		rc;

			dXaxis[0] = dMatrix[0];
			dXaxis[1] = dMatrix[4];
			dXaxis[2] = dMatrix[8];

			BScrossp( &rc, dXaxis,pTopo[0].pd3Width, dZaxis);

			if ( rc == BSSUCC ) 
			{
				/*C Modify matrix */
				for (i=0; i<3; i++)
				{
					/*C Set New Y */
					dMatrix[i*4 + 1] = pTopo[0].pd3Width[i];
					/*C Set New Z */
					dMatrix[i*4 + 2] = dZaxis[i];
				}
			}

		}/* end dangle orientation */

	}/* end one topo */
	else
	{
		status =
		VRGetTopology (&retmsg,&pTopo[0],&pTopo[1],
				&dTopoAngle, dMatrix, pmd_env );
		as$status ( action = RET_STATUS );

	}/* end compute matrix and angle */

/*A	II/	Evaluate auto-component
*/
	{
	IGRshort	nOption=1;
	IGRint		NbMissParams,CmpType,CmpNbCpts;

	pCmpId->objid = NULL_OBJID;

	status =
	VR$Evaluate(	p_msg		= msg,
			Product		= Product,
			ItemNum		= nItemNum,
			Angle		= dTopoAngle,
			SStatus		= (IGRshort) VR_SYSTEM,
			p_Option	= &nOption,
			Symbology	= pSymb,
			Representation	= cRep,
			p_Type		= &CmpType,
			p_NbCpts	= &CmpNbCpts,		
			p_SysParamId	= pSysId,
			p_UsrParamId	= pUsrId,
			p_ComponentId	= pCmpId,
			p_NbMissParams	= &NbMissParams,
			p_MdEnv		= pmd_env);
	as$status ( action = RET_STATUS );

	}/* end evaluate */

/*A	III/	Orientate component
*/

	{
	
	/*C	Apply matrix to component ( Component is center ) */

	status =
	VR$OrientComp(	p_retmsg 	= &retmsg,
			p_CmpId		= pCmpId,
			Matrix		= dMatrix,
			p_MdEnv		= pmd_env );
	as$status( action = RET_STATUS);

	}/* end orient component */

/*A	IV/	Connect component to topology
*/
	{
	IGRshort	nCptNum=-1;

	for (i=0; i<NbTopo; i++)
	{
		status =
		VRConnect( &retmsg, pCmpId, &nCptNum, 0, 
		 	   &pTopo[i].SegId, 1, &pTopo[i].nEndPoint, pmd_env);
		as$status( action = RET_STATUS);
	}
	}/* end connect */

/*A	V/	Display component if required
*/
	if ( bDisplay )
	{
	  	status =
		om$send( msg      = message NDnode.NDdisplay( 0, GRbd, pmd_env ),
			senderid = NULL_OBJID,
			targetid = pCmpId->objid, 
			targetos = pCmpId->osnum);
	 	as$status( action = RET_STATUS );

	}
	return OM_S_SUCCESS;

}/* end VRPlaceAutoComponent */

end implementation Root;

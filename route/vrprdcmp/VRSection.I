/* $Id: VRSection.I,v 1.4 2002/04/10 20:17:54 louis Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRSection.I
 *
 * Description:
 *	This file contains functions that are used for sections creation
 *	during predrop calculations.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRSection.I,v $
 *	Revision 1.4  2002/04/10 20:17:54  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:16:56  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:53:11  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  00:02:58  pinnacle
# Created: route/vrprdcmp/VRSection.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/04  21:27:38  pinnacle
# Replaced: vrprdcmp/VRSection.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/17  19:31:04  pinnacle
# Replaced: vrprdcmp/VRSection.I for:  by r240_int for route240
#
# Revision 1.2  1995/12/17  18:09:48  pinnacle
# Replaced: ./vrprdcmp/VRSection.I for:  by azuurhou for route240
#
 *
 * History:
 *	03/13/94	manyam		predrop calculations.
 *	01/17/96    tlb		Add prototypes
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *
 ***************************************************************************/

class implementation	Root;

#include	<stdio.h>
#include	<math.h>
#include	"OMminimum.h"
#include	"OMerrordef.h"
#include	"OMprimitives.h"
#include	"bstypes.h"
#include	"bsparameters.h"
#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"gr.h"
#include 	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"AS_status.h"
#include	"VRdimdef.h"
#include	"VRdef.h" 
#include	"VRMath.h"
#include	"VRcompdef.h"
#include	"VRstructs.h"
#include	"VRmacros.h"
#include	"vrmacros.h"
#include	"vrparameters.h"
#include	"VRDbParamDef.h"
#include	"VRStSect.h"
#include	"bsdotp.h"
#include	"VDmem.h"
#include        "vrdbgmacros.h"

from	VRGeneric	import	VRGetSysType,
				VRGetStatus,
				VRGetCptGeom;

/*
#define	DEBUG
*/

/* TBD
	section_mask needs to be set properly in VRGetSections and
	VRGetSectInfo

	Investigation about a unique identifier for an I/ROUTE comp
*/

/**********************************************************************

   Doc: VRGetSections

   Abstract: Given a tip object and Cpt of this tip object, this function
	traverses the network and divides it in to sections. The criteria
	for dividing in to sections are

		i) Change in flow rate
		
		ii) Change in shape or size

	It outputs "VRSection" structure and number of sections. This needs
	to be called first whenever the user wants to divide a network into
	sections.

	Memory for "pSection" should be allocated by the caller. This
	func is not designed to return the number of sections once and
	section info once( this has been done keeping in mind the processing
	needed ). Caller can declare some large array and pass it to func.
	Number of sections equal to "pIndex+1".

   History:
	23 Mar 94	Manyam	Creation

   Return Status:
	OM_S_SUCCESS	success
	OM_E_INVARG	Invalid arguments
	OM_E_ABORT	Error during processing

   Future Scope :
	This has to be extended so as to support "From Cmp" and "To Cmp".
	( given a start component and end component, this should be able
	to divide it into sections )

	The criteria ( one or more ) for dividing a network in to sections
	should be defined as one of the arguments.

	Need to review the alogorithm for speed improvement.

	OLET's need to be considered as one of the criteria for dividing
	in to sections.

	Support IN_LINE_EQUIPMENT( How do we decide a component is
	an INLINE_EQUIPMENT or a componet ? Is it by "comp_type"
	attribute )
	
	COMMENTS :	Manyam		: 	1 Jul 1994

		Reviewed this problem to implement INLINE-EQUIPMENT.
	ASHRAE treats more or less like other fittings. We also 
	consider it in the same way. No need for any special 
	processing.


***********************************************************************/

IGRint	VRGetSections( pStartCmp, nStartCpt, pSection, pIndex, pMdEnv )

	struct	GRid		*pStartCmp;	/* I : Start Cmp Id	*/
	IGRshort		nStartCpt; 	/* I : Start Cpt 	*/
	struct	VRSection	*pSection;	/* O : Section info str */
						
	IGRint			*pIndex;	/* O : Index for the array
						pSection. This needs to be
						set to -1 to start with. When
						the funnction returns, the Nb
						of elems in "pSection" equal
						to "pIndex+1"		*/
	struct	GRmd_env	*pMdEnv;	/* I : Mod Env of Start Id */

/* start VRGetSections */
{
	IGRshort		nNextCpt=-1, nStatus;
	IGRint			status, NbCpts, i, j;
	IGRlong			msg;
	IGRboolean		bStartRun=FALSE, bIsSameSect=TRUE;
	IGRboolean		bLoop = FALSE;
	struct	GRid		NextId;
	struct	ACrg_coll	AttrList[6];
	struct	VRcp_attr	StartCptAttr, NextCptAttr;
	IGRboolean		VRCheckCptAttr(), VRIsTwisted(), bTwist=FALSE;
	IGRint			StartCmpType;
	
        SetProc( VRRCComp_VRGetSections ); Begin
	/*C validate the arguments */
	if ( !pStartCmp || nStartCpt > VR_MAX_CPTS ||
		!pSection || !pIndex || !pMdEnv )
        {
           End
			return OM_E_INVARG;
        }

	/*C initialization */
	NextId.objid = NULL_OBJID;

#ifdef	DEBUG
	printf( "pStartCmp = %ld \n", pStartCmp->objid );
	printf( "StartCpt = %d \n", nStartCpt );
#endif	

	/*A processing for the dangle component or the tip object	*/

	/*C check the pIndex argument to test whether it is starting	*/
	if( *pIndex == -1 )
	{
		/*C set the index to zero	*/
		*pIndex = 0;

		/*C get tip obj's neighbour	*/
		status = 
		vr$review_topology (    pMsg = &msg,
			pComponent = pStartCmp,
			CptNum = nStartCpt,
			pNeighbor  = &NextId,
			pNeighCpt  = (IGRint *)&nNextCpt,
			pMdEnv = pMdEnv );
		as$status( action = RET_STATUS );

		/*C no component found */
		if( NextId.objid == NULL_OBJID )
			return OM_E_ABORT;

		/*C get tip obj's cpt attr	*/
		strcpy( AttrList[0].name, VR_N_COMP_TYPE_IN );
		strcpy( AttrList[1].name, VR_N_WIDTH1_DB );
		strcpy( AttrList[2].name, VR_N_DEPTH1_DB );
		strcpy( AttrList[3].name, VR_N_SHAPE_IN );

		status =
		vr$review_parameters(pMsg	= &msg,
                           pComponent   = pStartCmp,
                           NbParams     = 4,
                           pList        = AttrList,
                           pMdEnv       = pMdEnv );
		as$status();

		/*C Fill up the cpt attr structure ( only width, depth,
		and shape fields are filled up.we need to do diff type
		of processing GetCptInfo does not work for danglings*/

		if ( (int)AttrList[0].desc.value.att_exp ==
			VR_V_DANGLING_TYPE )
		{
			pSection[*pIndex].CptAttr.width	=
				( double )AttrList[1].desc.value.att_exp;
			pSection[*pIndex].CptAttr.depth	=
				( double )AttrList[2].desc.value.att_exp;
			pSection[*pIndex].CptAttr.section_mask =
				( IGRchar )AttrList[3].desc.value.att_exp;
		} else {
			status =
			VR$GetCptInfo(   p_retmsg       = &msg,
                                 p_CmpId	= pStartCmp,
				 CmpCptNum      = nStartCpt,	
				 p_CptProp	= &pSection[*pIndex].CptAttr,
                                 p_MdEnv        = pMdEnv );
			as$status();
		}

		/*C init the first entry of structure */
		pSection[*pIndex].StartId = *pStartCmp;
		pSection[*pIndex].nStartCpt = nStartCpt;
		pSection[*pIndex].EndId = NextId;
		pSection[*pIndex].nEndCpt = nNextCpt;

		/*C call recursively */
		status =
		VRGetSections( &NextId, nNextCpt, pSection, pIndex, pMdEnv );

                End
		return status;

  	}/* end processing for the dangle */

	/*A get the number of Cpts */
	strcpy( AttrList[0].name, VR_N_NB_CONNECT_IN );
	strcpy( AttrList[1].name, VR_N_COMP_TYPE_IN );
	status =
	vr$review_parameters(pMsg	= &msg,
                           pComponent   = pStartCmp,
                           NbParams     = 2,
                           pList        = AttrList,
                           pMdEnv       = pMdEnv );


	NbCpts = (IGRint) AttrList[0].desc.value.att_exp;
	StartCmpType = (IGRint) AttrList[1].desc.value.att_exp;

	status = 
  	om$send( msg      = message VRGeneric.VRGetStatus(
				&msg, &nStatus ),
		senderid	= NULL_OBJID,
   		targetid	= pStartCmp->objid,
   		targetos	= pStartCmp->osnum );
	as$status( action = RET_STATUS );

	/*C If greater than 2, it is a Tee.
		If less than 2( i.e. 1), it is a dangle */

	if( NbCpts != 2  )
    	{
		/* save RunEnd information */
        	pSection[*pIndex].EndId = *pStartCmp;
	        pSection[*pIndex].nEndCpt = nStartCpt;
        	bStartRun = TRUE;
	}

	/*C process the StartCmp with it's neighbors at each Cpt */
	for( i=0; i < NbCpts; ++i )
	{
		/*C Skip the from connection point */
		if ( i == nStartCpt ) continue;

		/*C find neighbor to propagate */
		status =
		vr$review_topology (    pMsg = &msg,
                                pComponent = pStartCmp,
                                CptNum = i,
                                pNeighbor  = &NextId,
                                pNeighCpt  = (IGRint *)&nNextCpt,
                                pMdEnv = pMdEnv );
		as$status( action = RET_STATUS );
#ifdef	DEBUG
	printf( " StartCmp = %d : nNextCpt = %d\n", pStartCmp->objid,
		nNextCpt );
#endif

		if( NextId.objid == NULL_OBJID ) continue;

		/*C get the comp's cpt attributes	*/
		strcpy( AttrList[0].name, VR_N_COMP_TYPE_IN );
		strcpy( AttrList[1].name, VR_N_WIDTH1_DB );
		strcpy( AttrList[2].name, VR_N_DEPTH1_DB );
		strcpy( AttrList[3].name, VR_N_SHAPE_IN );

		status =
		vr$review_parameters(pMsg	= &msg,
                           pComponent   = &NextId,
                           NbParams     = 4,
                           pList        = AttrList,
                           pMdEnv       = pMdEnv );
		as$status();
	
		/*C check whether the neighbor is dangle or not	*/
		if ( (int)AttrList[0].desc.value.att_exp ==
			VR_V_DANGLING_TYPE )
		{
			NextCptAttr.width =
				( double )AttrList[1].desc.value.att_exp;
			NextCptAttr.depth =
				( double )AttrList[2].desc.value.att_exp;
			NextCptAttr.section_mask =
				( IGRchar )AttrList[3].desc.value.att_exp;
		} else {
			status =
			VR$GetCptInfo(   p_retmsg       = &msg,
                                 p_CmpId	= &NextId,
				 CmpCptNum      = nNextCpt,
				 p_CptProp	= &NextCptAttr,
                                 p_MdEnv        = pMdEnv );
			as$status( action = RET_STATUS );
		}
	
 		/*C check whether the two components are twisted */
		bTwist	=
		VRIsTwisted( pStartCmp, (short)i, &NextId, nNextCpt, pMdEnv );

		/*C get the cpt attr of the start component */
		if (  ( ( StartCmpType == VRH_V_REDUCER_TYPE ) || 
			( StartCmpType == VRH_V_SIZE_TRANSITION_TYPE ) || 
			( StartCmpType == VRH_V_ORIENT_TRANSITION_TYPE ) ) )
/*	&& 	!( nStatus & VR_CORRECTION ) )	
*/
			StartCptAttr = pSection[*pIndex].CptAttr;
		else {
			status =
			VR$GetCptInfo(
				 p_retmsg       = &msg,
                               	 p_CmpId	= pStartCmp,
				 CmpCptNum      = (short)i,
				 p_CptProp	= &StartCptAttr,
                                 p_MdEnv        = pMdEnv );
			as$status( action = RET_STATUS );
		}

		/*C call a function to check the cpt attr */
		bIsSameSect =
		VRCheckCptAttr( &StartCptAttr,
			&NextCptAttr, bTwist );

		if( !bStartRun && !bIsSameSect )
		{
		        /* save RunEnd information */
	        	pSection[*pIndex].EndId = *pStartCmp;
		        pSection[*pIndex].nEndCpt = nStartCpt;
	        	bStartRun = TRUE;
		}

		/*C if CompId ends a run : it begins the next ones */
		if ( bStartRun )
		{
			(*pIndex)++;
			pSection[*pIndex].StartId = *pStartCmp;
			pSection[*pIndex].nStartCpt = i;
			pSection[*pIndex].EndId = NextId;
			pSection[*pIndex].nEndCpt = nNextCpt;
			pSection[*pIndex].CptAttr = NextCptAttr;
		}

		/*C make sure that neighbor is not already processed */
		for( j=0; j < *pIndex; ++j )
		  if( pSection[j].EndId.objid == NextId.objid &&
		    pSection[j].EndId.osnum == NextId.osnum )
			bLoop = TRUE;

		if( bLoop )
		{
			/* save RunEnd information */
			pSection[*pIndex].EndId = *pStartCmp;
			pSection[*pIndex].nEndCpt = nStartCpt;

			if( pSection[*pIndex].StartId.objid
				== pSection[*pIndex].EndId.objid )
			--(*pIndex);
			bLoop = FALSE;
		}
		else
			status =
			VRGetSections( &NextId, nNextCpt,
				pSection, pIndex, pMdEnv );
	}

        End
	return status;

}/* end VRGetSections */

/**********************************************************************

   Doc: VRGetSectCmps

   Abstract: Given a Start Cmp , it's Cpt and EndCmp , it's Cpt, this	
	function returns the Nb of cmps in between and their Ids
	including the start and end cmps.
	
	Memory has to be allocated by the caller. First this can be 
	called by passing NULL as an argument for "pCmpIds" in which case
	this one returns Nb Cmps in between. The caller can allocate
	memory and call the function again.

   History:
	24 Mar 94	Manyam	Creation

   Return Status:
	OM_S_SUCCESS	success
	OM_E_INVARG	Invalid arguments

   Future Scope :

***********************************************************************/

IGRint	VRGetSectCmps( pStartCmp, nStartCpt,
		pEndCmp, nEndCpt, pCmpIds, pNbCmps, pMdEnv )

	struct	GRid		*pStartCmp;	/* I : Start Cmp Id 	*/
	IGRshort		nStartCpt;	/* I : Start Cmp's Cpt	*/
	struct	GRid		*pEndCmp;	/* I : End Cmp Id 	*/
	IGRshort		nEndCpt;	/* I : End Cmp's Cpt	*/
	struct	GRid		*pCmpIds;	/* O : Array of Cmp Ids */
	IGRint			*pNbCmps;	/* O : Nb Cmps in bet	*/
	struct	GRmd_env	*pMdEnv;	/* I : Mod Env of StartCmp*/

/*start VRGetSectCmps */
{
	IGRshort	nNextCpt=-1;
	IGRint		status, i;
	IGRlong		msg;
	struct	GRid	NextId;

        SetProc( VRRCComp_VRGetSectCmps ); Begin
	if ( !pStartCmp || !pEndCmp )
        {
          End
		return	OM_E_INVARG;
        }

	NextId.objid = NULL_OBJID;

	/*C get the neighbour of the start comp */
	status = 
	vr$review_topology (    pMsg = &msg,
		pComponent = pStartCmp,
		CptNum = nStartCpt,
		pNeighbor  = &NextId,
		pNeighCpt  = (IGRint *)&nNextCpt,
		pMdEnv = pMdEnv );
	as$status( action = RET_STATUS );

	/*C no component found */
	if( NextId.objid == NULL_OBJID )
        {
            End
		return OM_E_ABORT;
        }


	if ( NextId.objid == pEndCmp->objid &&
		NextId.osnum == pEndCmp->osnum &&
			nNextCpt == nEndCpt )
        {
           End
				return OM_S_SUCCESS;
        }

	if ( pCmpIds )
		pCmpIds[*pNbCmps] = NextId;
	(*pNbCmps)++;

	/*C we are sure that the cmp has only two cpts */
	for ( i=0; i< 2; i++ )
	{

	  if( i == nNextCpt ) continue;
	
	  status =	
	  VRGetSectCmps( &NextId, i,
		pEndCmp, nEndCpt, pCmpIds, pNbCmps, pMdEnv );
	
	}

        End
	return OM_S_SUCCESS;

}/*end VRGetSectCmps */

/*********************************************************************

   Doc: VRProcessCmp

   Abstract: Given either a start cmp or end cmp of a section, this
	function decides whether that cmp needs to be considered in
	the current section or not and return TRUE or FALSE accordingly.

   History:
	24 Mar 94	Manyam	Creation

   Return Status:
	TRUE	the cmp can be considered in the current section
	FALSE	the cmp can not be considered

   Future Scope :

	OLETS are considered just like TEES. Modify if required depending
	on the feed back after testing.

	Y_TOPO and 4_WAYS_TOPO	are considered under some assumptions.
	Modify after testing.

***********************************************************************/

IGRboolean	VRProcessCmp( pCmpId, nCpt, bIsStart, pMdEnv )

	struct	GRid		*pCmpId;	/* I : Cmp Id		*/
	IGRshort		nCpt;		/* I : Cmp's Cpt	*/
	IGRboolean		bIsStart;	/* I : Flag to indicate
						1 : start cmp 0 : end cmp*/
	struct	GRmd_env	*pMdEnv;	/* I : Cmp's Mod Env	*/

/* start VRProcessCmp */
{
	IGRshort		nSysType, nStatus;
	IGRint			status, CmpTopo, NbCpts;
	IGRlong			msg;
	IGRboolean		bConsider=TRUE;
	struct	ACrg_coll	Attr[2];
	
        SetProc( VRRCComp_VRProcessCmp ); Begin
	/*A validate the args */
	if ( !pCmpId || !pMdEnv || 
		nCpt > VR_MAX_CPTS || nCpt < 0 )
        {
            End
			return FALSE;
        }

	/*A get the comp's attributes		*/
	strcpy( Attr[0].name , VR_N_COMP_TOPO_IN );
	strcpy( Attr[1].name , VR_N_NB_CONNECT_IN );
	status =
	vr$review_parameters(   pMsg            = &msg,
                                pComponent      = pCmpId,
                                NbParams        = 2,
                                pList           = Attr,
                                pMdEnv          = pMdEnv );

	CmpTopo = (int) Attr[0].desc.value.att_exp;
	NbCpts = (int) Attr[1].desc.value.att_exp;
	
	/*A get the status and item num of the component */
  	status = 
	om$send( msg      = message VRGeneric.VRGetSysType(
			&msg, &nSysType ),
		senderid	= NULL_OBJID,
	   	targetid	= pCmpId->objid,
	   	targetos	= pCmpId->osnum );
	as$status();

	switch( CmpTopo )
	{
		case VRH_V_2_WAYS_TOPO:
		case VRH_V_INLINE_TOPO :
		if ( bIsStart )
			bConsider = FALSE;
		else 
			bConsider = TRUE;
		break;

		case VRH_V_3_WAYS_TOPO:
		case VRH_V_OLET_TOPO:
		if ( nCpt == 1 ) /* consider for cpt 0 */
			bConsider = FALSE;
		else
			bConsider = TRUE;
		break;

		case VRH_V_Y_BRANCH_TOPO:
		/*C do not consider at the main section */
		if ( !nCpt )
			bConsider = FALSE;
		else
			bConsider = TRUE;
		break;

		case VRH_V_4_WAYS_TOPO:
		/*C consider at all 4 cpts */
		bConsider = TRUE;
		break;

		default :
		/*C do not consider the danglings */
		if ( NbCpts == 1 )
		{
		  switch( nSysType )
		  {
			case VR_DANGLING:
			bConsider = FALSE;
			break;

			default:
			bConsider = TRUE;
			break;
		  }/* end switch nSysType */

		} else bConsider = TRUE;
		break;
		
	}/* end switch */

        End
	return	bConsider;

}/* end VRProcessCmp */

/*********************************************************************

   Doc: VRGetSectionInfo

   Abstract: Given a VRSection and Nb of sections, this function
	returns the nb of comps those sections contain and their Ids.
	Memory for "pCmpIds" field in "VRSectInfo" struct will be
	allocated by this function and caller needs to free it.

   History:
	24 Mar 94	Manyam	Creation

   Return Status:
	OM_S_SUCCESS	success
	OM_E_INVARG	Invalid arguments

   Future Scope :

***********************************************************************/

IGRint	VRGetSectInfo( pSection, NbSections, pSectInfo, pMdEnv )

	struct	VRSection	*pSection;	/* I : Ptr to Array	*/
	IGRint			NbSections;	/* I : Nb of Sections	*/
	struct	VRSectInfo	*pSectInfo;	/* O : Section Info	*/
	struct	GRmd_env	*pMdEnv;	/* I : Mod Env of Cmp	*/

/* start VRGetSectInfo */
{
	IGRint			status,i,j;
	IGRint			NbViaCmps;
	struct	GRid		IntBuffer[300];
	IGRboolean		bIncludeStart = TRUE, bIncludeEnd = TRUE;

        SetProc( VRRCComp_VRGetSectInfo ); Begin
	/*C validate arguments */
	if ( !pSectInfo || !pSection || !pMdEnv )
        {
           End
		return	OM_E_INVARG;
        }

	for ( i=0; i < NbSections; i++ )
	{
	  /*A initialize the number of cmps */
	  pSectInfo[i].NbCmps = 0;
	  pSectInfo[i].pCmpIds = NULL;
	  NbViaCmps = 0;

	  /*A get the number of components inbetween the start and end */
	  status =
	  VRGetSectCmps( &pSection[i].StartId, pSection[i].nStartCpt,
		&pSection[i].EndId, pSection[i].nEndCpt, 
		IntBuffer, &pSectInfo[i].NbCmps, pMdEnv );

	  /*A store the num of cmps in between */
	  NbViaCmps = pSectInfo[i].NbCmps;

	  /*A decide whether to include the start and end comps */
	  bIncludeStart =
	  VRProcessCmp( &pSection[i].StartId, pSection[i].nStartCpt, 
			TRUE, pMdEnv );

	  bIncludeEnd =
	  VRProcessCmp( &pSection[i].EndId, pSection[i].nEndCpt,
			FALSE, pMdEnv );
	  
	  /*A increment the number of cmps accordingly */
	  if ( bIncludeStart )
		 pSectInfo[i].NbCmps++;


	  if ( bIncludeEnd )
		 pSectInfo[i].NbCmps++;

	  /*A allocate memory for the array */
	  pSectInfo[i].pCmpIds	= ( struct GRid *) 
		_CALLOC( pSectInfo[i].NbCmps, struct GRid );

	  if ( !pSectInfo[i].pCmpIds )
	  {
		printf( " Could not allocate the dynamic memory \n" );
		goto FREE_MEMORY;
	  }

	  /*A store the start cmp */
	  if ( bIncludeStart )
		pSectInfo[i].pCmpIds[0] = pSection[i].StartId;

	  /*A store the ids */
	  for ( j=0; j < NbViaCmps; j++ )
	  {
	      if ( bIncludeStart )
	      	pSectInfo[i].pCmpIds[j+1] = IntBuffer[j];
	      else
	      	pSectInfo[i].pCmpIds[j] = IntBuffer[j];

	  } /* end loop on section cmps */

	  /*A store the end cmp */
	  if ( bIncludeEnd )
		pSectInfo[i].pCmpIds[pSectInfo[i].NbCmps-1] = 
			pSection[i].EndId;

	} /* end loop on sections*/

        End
	return 	OM_S_SUCCESS;

FREE_MEMORY :
	for ( i=0; i<NbSections; i++ )
		if ( pSectInfo[i].pCmpIds )
			_FREE ( pSectInfo[i].pCmpIds );
        End
	return	OM_E_ABORT;

}/* end VRGetSectInfo */


/*********************************************************************

   Doc: VRCheckCptAttr

   Abstract: This function checks whether the two cpt attrs are same
	or not( only width, depth, shape are checked now). This is used
	for section's purpose.

   History:
	24 Mar 94	Manyam	Creation

   Return Status:
	FALSE	Not Same
	TRUE	Same

   Future Scope :
	Extend the function in such a way that a flag should be
	mentioned to check the given attribute
	
	Extend to support checking of other attributes also.

***********************************************************************/

IGRboolean	VRCheckCptAttr( pRefCptAttr, pCptAttr, bTwist )

		struct	VRcp_attr	*pRefCptAttr;	/*I : Ref cpt attr */
		struct	VRcp_attr	*pCptAttr;	/*I : cpt attr to be
								checked */
		IGRboolean		bTwist;		/*I : whether twisted*/
/* start VRCheckCptAttr */
{
	
	/*C validate arguments and return FALSE  */
	if ( !pRefCptAttr || !pCptAttr )
		return	FALSE;

	/*C do special processing for circular shape in HVAC */
	if ( (int ) pRefCptAttr->section_mask == (int) VR_CIRC &&
          (int)pCptAttr->section_mask == ( int ) VR_CIRC ) 
	{
	  if ( pRefCptAttr->width != pCptAttr->width )
		return	FALSE;
	  else return TRUE;
	} else {


	  /*C check the cpt attr against the reference attributes */
	  if( bTwist )
	  {
	     if ( pRefCptAttr->width != pCptAttr->depth ||
	    	pRefCptAttr->depth != pCptAttr->width )
			return FALSE;
	  } else {
	  if ( pRefCptAttr->width != pCptAttr->width ||
	    pRefCptAttr->depth != pCptAttr->depth )
		return FALSE;
	  }
	}

/*	  (int)pRefCptAttr->section_mask != (int)pCptAttr->section_mask )
	  pRefCptAttr->section_mask & VR_SHAPE != 
	    pCptAttr->section_mask & VR_SHAPE )
		return FALSE;
*/
	/*C both the attributes are same in aspects that are under conderation*/
	return	TRUE;

}/* end VRCheckCptAttr */

IGRboolean	VRIsTwisted( pRefId, nRefCpt, pCmpId, nCmpCpt, pMdEnv )

		struct	GRid		*pRefId;/*I : Ref Cmp Id	*/
		IGRshort		nRefCpt;/*I : Ref Cpt		*/
		struct	GRid		*pCmpId;/*I : Cmp to be checked	*/
		IGRshort		nCmpCpt;/*I : Cmp's Cpt		*/
		struct	GRmd_env	*pMdEnv;/*I : module environment*/
/* start VRIsTwisted */
{
	BSrc		bsretcode;
	IGRlong		retmsg;
	IGRboolean	bTwist;
	IGRdouble	dRefOrient[3], dCmpOrient[3], BSdotp();
	IGRint		status;

	if ( !pRefId || !pCmpId	|| !pMdEnv )
		return	FALSE;

	/*A get the section orientation from the cmps */
	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retmsg, nRefCpt,
				NULL, NULL, dRefOrient, pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pRefId->objid,
		targetos = pRefId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	/* dRefOrient = %f %f %f\n", dRefOrient[0],
		dRefOrient[1], dRefOrient[2]	*/

	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retmsg, nCmpCpt,
				NULL, NULL, dCmpOrient, pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	/* dCmpOrient = %f %f %f\n", dCmpOrient[0],
		dCmpOrient[1], dCmpOrient[2] */

	bTwist =
	(fabs (BSdotp( &bsretcode, dRefOrient, dCmpOrient)) < VRGetTol(VR_ORTHO_TOL) );

	return	bTwist;
	
}/*end	VRIsTwisted	*/

end implementation	Root;


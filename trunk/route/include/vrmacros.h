/* $Id: vrmacros.h,v 1.1.1.1 2001/01/04 21:12:10 cvs Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:        include/vrmacros.h
 *
 * Description:
 *	This include file provides any developer with functionalities
 *	to review/modify components belonging to any routing built with
 *	the I/ROUTE product.
 *
 * Dependencies:
 *	Prerequisite include files :
 *
 *		- msdef.h
 *		- ACattrib.h
 *		- ACrg_collect.h
 *
 * Revision History:
 *      $Log: vrmacros.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:10  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/11/30  18:36:40  pinnacle
 * Replaced: include/vrmacros.h for:  by apazhani for route
 *
 *
 * History:
 *       Date            Name     Description
 *      07/13/92        B Demars  Creation
 *      11/30/98        Alwin     Modified to add a 'comma' for vr$get_cpt_prop
 *				  macro to get rid of compilation errors. Found
 *				  while working on MariSTEP functions.
 *
 *************************************************************************/

#ifndef vr_macros_include
#define vr_macros_include

/*
 *      This file depends on the following files :
 *		- msdef.h
 *		- ACattrib.h
 *		- ACrg_collect.h
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRint	VRSelectComponent __((	long	*pMsg,
					int	Product,
					int	NbSelect,
					struct ACrg_coll  *pSelect,
					struct GRid	  **pAddrList,
					int	*pNumber ));

extern IGRint	VRReviewParameters __((	long		*pMsg,
					struct GRid	*pComponent,
					int		NbParams,
					struct ACrg_coll *pList,
					struct GRmd_env	 *pMdEnv ));

extern IGRint 	VRReviewTopology __((	IGRlong 	*pMsg,
					struct GRid 	*pComponent,
					IGRint 		CptNum,
					IGRdouble 	*pTee,
					IGRdouble 	*pMatrix,
					struct GRid 	*pNeighbor,
					IGRint 		*pNeighCpt,
					struct GRmd_env *pMdEnv ));

extern IGRint 	VRGetCptProp __((	IGRlong 	*pMsg,
				 	struct GRid 	*pCmpId,
				 	IGRshort 	nCptNum,
				 	IGRdouble 	*pDim1,
				 	IGRdouble 	*pDim2,
				 	IGRshort 	*pSection,
				 	IGRint 	*pEndPrep,
				 	IGRdouble 	*pPressure,
				 	IGRdouble 	*pCptOffSet,
				 	struct GRmd_env *pMdEnv ));

extern IGRint VRReviewFlowdir __(( 	IGRlong 	*pMsg,
					struct GRid 	*pComponent,
					IGRint 	CptNum,
					IGRshort 	*pFlowDir,
				 	IGRdouble 	*pFlowRate,
					struct GRmd_env *pMdEnv  ));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------

	vr$select_component

Based on a list of select criteria defined by the names and values in the
structure ACrg_coll and a list of component objects or of object spaces, 
this macro returns the number and list of components that match this criteria. 

Arguments description :

long			*pMsg		: (O) completion code : returns MSSUCC
					      or MSFAIL.
int			Product		: (I) VR_HVAC or VR_PIPING or VR_RWAY
					      ( values defined in vrdef.h ).
int			NbSelect	: (I) number of specified parameters.

struct ACrg_coll	*pSelect	: (I) parameters descriptions.

struct GRid		**pAddrList	: (O) returned pointer to the List.

int			*pNumber	: (O) number of returned components.

-----------------------------------------------------------------*/


#omdef vr$select_component ( 	pMsg			,
				Product			,
				NbSelect   = 0		,
				pSelect	   = NULL	,
				pAddrList		,
				pNumber			)
VRSelectComponent ( (pMsg), (Product), (NbSelect), (pSelect), (pAddrList), (pNumber) )
#endomdef

/****************************************************************

			Review information

*****************************************************************/


/*---------------------------------------------------------------
 *
 *	vr$review_parameters
 *
 *	This macro returns, from the object defined by pComponent, the types
 *	and values of the parameters specified in pList filled in before 
 *	calling.
 *
 * Arguments description :
 *
 * long			*pMsg		: (O) returns MSFAIL if any
 *					      parameter fails ( in
 *					      this case, its returned
 *					      type is AC_ATTRIB_TYPE_NOT_DEF );
 * struct GRid		*pComponent	: (I) component's object id.
 *
 * int			NbParams 	: (I) number of names initialized
 *					      in the List array.
 * struct ACrg_coll	*pList		: (I/O) pointer to the List
 *						array.
 * struct GRmd_env		*pMdEnv		: (I) module environment.
 *
 *---------------------------------------------------------------*/

#omdef vr$review_parameters ( 	pMsg			,
				pComponent		,
				NbParams 		,
				pList 			,
				pMdEnv			)

VRReviewParameters ( (pMsg), (pComponent), (NbParams), (pList), (pMdEnv))
#endomdef


/*---------------------------------------------------------------
 * 
 * 	vr$review_topology
 * 
 * This macro returns information of the connect point of the component's 
 * specified connect point.
 * 
 * Arguments description :
 * 
 * long			*pMsg		: (O) completion code
 * 					      returns MSFAIL if a
 * 					      bad connection point
 * 					      number has been specified,
 * 					      MSSUCC otherwise.
 * struct GRid		*pComponent	: (I) specified component.
 * 
 * int			CptNum		: (I) specified connection point
 * 
 * double		*pTee		: (O) matrix (4x4) of the component
 * 					      (optional).
 * double		*pMatrix	: (O) matrix (4x4) of the specified
 * 					      connection point (optional).
 * struct GRid		*pNeighbor	: (O) component connected to
 * 					      the specified connection point
 * 					      (optional).
 * int			*pNeighCpt	: (O) neighbor's connection point
 * 					      number (optional).
 * struct GRmd_env	*pMdEnv		: (I) module environment.
 * 
-----------------------------------------------------------------*/

#omdef vr$review_topology ( 	pMsg			,
				pComponent		,
				CptNum			,
				pTee       = NULL	,
				pMatrix    = NULL	,
				pNeighbor  = NULL	,
				pNeighCpt  = NULL	,
				pMdEnv			)

VRReviewTopology ( (pMsg),(pComponent),(CptNum),(pTee),
		   (pMatrix),(pNeighbor),(pNeighCpt), (pMdEnv) ) 

#endomdef

/*---------------------------------------------------------------
 * 
 * 	vr$get_cpt_prop
 * 
 * This macro returns the connect point properties at a component's specified 
 * connection point.
 * 
 * Arguments description :
 * 
 * IGRlong		*pMsg		: (O) completion code
 * 					      returns MSFAIL if a
 * 					      bad connection point
 * 					      number has been specified,
 * 					      MSSUCC otherwise.
 * struct GRid		*pComponent	: (I) specified component.
 * 
 * IGRshort		nCptNum		: (I) specified connection point
 * 
 * IGRdouble		*pDim1		: (O) returns 
 *					     Diameter in case of PIPING Comp
 *					     Width  in case of HVAC & CABLING
 * IGRdouble		*pDim2		: (O) returns 
 *					     -1     in case of PIPING Comp
 *					     Depth  in case of HVAC & CABLING
 * IGRshort		*pSection	: (O) Section Mask at the Cpt
 *					     -1     in case of PIPING Comp
 * IGRint		*pEndPrep	: (O) End Prep at the Specified 
 *					      CptNum
 * IGRdouble		*pPressure	: (O) Pressure at the Specified 
 *					      CptNum 
 * IGRdouble		*pCptOffSet	: (O) Cpt Offset at the Specified
 *					      CptNum
 * struct GRmd_env	*pMdEnv		: (I) module environment.
 * 
-----------------------------------------------------------------*/

#omdef vr$get_cpt_prop ( 	pMsg			,
				pComponent		,
				nCptNum			,
				pDim1		= NULL	,
				pDim2		= NULL	,
				pSection  	= NULL	,
				pEndPrep  	= NULL	,
				pPressure  	= NULL	,
				pCptOffSet 	= NULL	,
				pMdEnv			)

VRGetCptProp ( (pMsg),(pComponent),(nCptNum),(pDim1), (pDim2 ), /*added this com
ma. Alwin Nov 30 1998 */
		(pSection),(pEndPrep), (pPressure),(pCptOffSet), (pMdEnv) ) 

#endomdef

/*---------------------------------------------------------------
 * 
 * 	vr$review_flowdir
 * 
 * This macro returns flow direction at a component's specified 
 * connect point.
 * 
 * Arguments description :
 * 
 * long			*pMsg		: (O) completion code
 * 					      returns MSFAIL if a
 * 					      bad connection point
 * 					      number has been specified,
 * 					      MSSUCC otherwise.
 * struct GRid		*pComponent	: (I) specified component.
 * 
 * int			CptNum		: (I) specified connection point
 *
 * short		*pFlowdir	: (O) flow direction at connection point
 *					      VR_FLOW_IN, VR_FLOW_OUT or 
 *					      VR_FLOW_UNKNOWN
 *
 * double		*pFlowRate	: (O) flow rate.
 * 
 * struct GRmd_env	*pMdEnv		: (I) module environment.
 * 
-----------------------------------------------------------------*/


#omdef vr$review_flowdir ( 	pMsg			,
				pComponent		,
				CptNum			,
				pFlowdir	= NULL	,
				pFlowRate	= NULL	,
				pMdEnv			)

VRReviewFlowdir ( (pMsg),(pComponent),(CptNum),(pFlowdir),(pFlowRate),(pMdEnv) ) 

#endomdef

#endif

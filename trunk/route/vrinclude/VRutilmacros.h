/* $Id: VRutilmacros.h,v 1.2 2001/01/12 20:49:01 anand Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:        vrinclude\VRutilmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRutilmacros.h,v $
 *      Revision 1.2  2001/01/12 20:49:01  anand
 *      SP merge
 *
 * Revision 1.1  2000/05/11  21:57:28  pinnacle
 * Created: route/vrinclude/VRutilmacros.h by apazhani for Service Pack
 *
 * Revision 1.2  1998/11/03  19:03:48  pinnacle
 * Replaced: vrinclude/VRutilmacros.h for:  by apazhani for route
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      name            description
 *
 *      04-Mar-92       1.4.5.03
 *      July 97         kdd     modify collection with List output.
 *      23 Oct 98       Alwin   Added an argument to the function,
 *                              VRGetCompGenInfo. for TR179800720
 *      11 May 00       Alwin   Corrected mistake in above definition
 *
/****************************************************************************/

#ifndef VRutilmacros_include
#define VRutilmacros_include

#include "ACrg_collect.h"
#include "VRstructs.h"
#include "VRutildef.h"

/**************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern	IGRint VRModifyCollection __((	
				IGRlong			*p_msg,
				IGRint			Operation,
				IGRshort		Type,
				struct	GRid		*p_InputCollectionId,
				struct	ACrg_coll	*p_ParamsListToModify,
				IGRint			NbParamsToModify,
				struct	GRid		*p_OutputCollectionId
					));


/* added the last argument for TR179800720 */
extern long  VRGetCompGenInfo __((
				IGRlong			*p_retmsg,
				IGRshort		Product,
				IGRint			TopoParentsNum,
				struct	GRid		*p_TopoParentsList,
				IGRshort		CmpItemName,
				IGRshort		CmpJust,
				IGRshort		*p_CmpIndexOnTopo,
				IGRshort		*p_RelCmpOrient,
				IGRdouble		*p_CmpAngle,
				IGRdouble		*p_CmpOrientSection,
				struct	GRmd_env	*p_MdEnv,
				struct	GRid		*p_ActParamId,
				struct	GRid		*p_BufParamId,
				struct	VRGenInfo	*p_CmpGenInfo,
				struct	GRid		*p_CmpSysParamId,
				struct  GRid		*p_CmpMissParamId ));


extern IGRint VRModifyCollection2 __((  IGRlong                 *msg,
	                                int                     Operation,
	                                IGRint                  InNumAttr,
	                                struct GRid             *InParId,
	                                struct ACrg_coll        *InAttrList,
	                                IGRint                  *OutNumAttr,
	                                struct ACrg_coll        **OutAttrList));

#if defined(__cplusplus)
}
#endif

/****************************************************************************
* Abstract :                                                          	
*	given an input collection or a list of parameters and an output 
*	collection this macro :					
*										
* - UPDATE : if the output and the input have common parameters. this macro set	
*	   the output paramters by the input one. the output collection should  
*	   be created by the caller		 				
*										
* - UNION : add in the output all input parameters which don't exist in the 
*		  output the output collection should  be created by the caller	
*										
* - MERGE : UPDATE + UNION. output can be NULL_OBJID so this macro creates a new
*		  collection.							
*										
* - SUBSTR: remove from the output collection, all attributes contained in the  
*		  input collection. No update of output collection. 
*										
* - INTER : remove from the output collection, all attributes not contained in  
*		  the input collection. No update of output collection. 
*
* - CLEAR : remove all attributes from the output collection or parameter list.
*------------------------------------------------------------------------------
*
*  PARAMETERS:
*
* O:	IGRlong		*p_msg			return code           	
*
* I:	IGRshort     	Operation		operation type ( VRutildef.h )
*
* I: struct GRid	*p_InputCollectionId	input collection grid 	
*
* I: strcut ACrg_coll	*p_ParamsListToModify	list of input parameters 
*
* I:	IGRint		NbParamsToModify	number of input parameters	
*						Valid with InParListToMod
*
* O: struct GRid	*p_OutputCollectionId	output collection ID.  	
*										
* O: struct ACrg_coll	**OutParList        pointer to output list of parameters
*	
* O:	IGRint		*OutNumPar		output number of parameters
*					Valid only with OutParList
*					On input must have number of
*					parameters in OutParList (if != NULL)
******************************************************************************/

#omdef VR$ModifyCollection
       ( p_msg,                         	
         Operation		= VR_MERGE_COLL,
	 Type			= VR_RG_COLL,
	 p_InputCollectionId	= NULL 		^ p_ParamsListToModify = NULL,	
	 NbParamsToModify	= 0,		
	 p_OutputCollectionId	= NULL 		^ OutParList           = NULL,
	 OutNumPar		= NULL )  

#if (om$specified (p_ParamsListToModify) && !om$specified(NbParamsToModify) )
#omerror "Given p_ParamsListToModify, also specify NbParamsToModify (input)."

#elif (om$specified (OutParList) && !om$specified(OutNumPar) )
#omerror "Given OutParList, also specify OutNumPar (output)."

#elif om$specified (p_OutputCollectionId)
VRModifyCollection( ( p_msg                ), ( Operation            ), 
		    ( Type                 ), ( p_InputCollectionId  ),
                    ( p_ParamsListToModify ), ( NbParamsToModify     ), 
		    ( p_OutputCollectionId ) )

#else
VRModifyCollection2(( p_msg                ), ( Operation            ),
                    ( NbParamsToModify     ), 
		    ( p_InputCollectionId  ), ( p_ParamsListToModify ), 
		    ( OutNumPar            ),
                    ( OutParList           ) )

#endif
#endomdef

/*********************************************************************************************/
/*											     */
/* Abstract : This macro is a private macro used to build the GenInfo structure and system   */
/*            parameters collection needed to place or replace an automatic component. 	     */
/*	      Now this is only used in the sketch ans called in VR$PlaceCmpByItemNum macro   */
/*											     */
/*	Type		Name				Description			     */
/*											     */
/*	IGRlong		 	*p_retmsg		O   : return code		     */
/*	IGRshort	 	Product			I   : product name		     */
/*	IGRint		 	TopoParentsNum		I   : component templates number     */
/*	struct GRid	 	*p_TopoParentsList	I   : component's templates	     */
/*	IGRshort	 	CmpItemName		I   : component's Item Name	     */
/*	IGRshort	 	CmpJust			I   : component's placement justif.  */
/*	IGRshort	 	*p_CmpIndexOnTopo	I   : component's index on its templ.*/
/*	IGRdouble	 	*p_RelCmpOrient		I   : component's orientation        */
/*							      relatively to its templates    */
/*							      direction			     */
/*	IGRdouble		*p_CmpOrientSection	I   : not used in PIPING. component's*/
/*						              section orientation	     */
/*	struct GRmd_env		*p_MdEnv		I   : module environnement	     */
/*	struct GRid	 	*p_ActParamId		I   : system parameters grid 	     */
/*	struct GRid	 	*p_BufParamId		I   : system parameters grid needed  */
/*							      for no symetric component      */
/*	struct VRGenInfo 	p_CmpGenInfo		I   : component's generic info	     */
/*	struct GRid		*p_CmpSysParamId	O   : component system param id      */
/*	struct GRid		*p_CmpMissParamId	O   : component Missing param id      */
/*											     */
/*********************************************************************************************/

#omdef VR$GetCompGenInfo( 	p_retmsg,
         			Product	   		= VR_PIPING,
         			TopoParentsNum    	= 0,        
         			p_TopoParentsList 	= NULL,     
         			CmpItemName	   	= VR_DANGLING,
         			CmpJust	   		= VR_CENTER_JUST,
         			p_CmpIndexOnTopo  	= NULL,          
         			p_RelCmpOrient    	= NULL,          
         			p_CmpAngle        	= NULL,          
         			p_CmpOrientSection	= NULL,          
         			p_MdEnv,          
         			p_ActParamId,          
         			p_BufParamId      	= NULL,
				p_CmpGenInfo		= NULL,         
         			p_CmpSysParamId,
         			p_CmpMissParamId
         		)                  
VRGetCompGenInfo
           ( p_retmsg, Product, TopoParentsNum, (struct GRid *)p_TopoParentsList,
             CmpItemName, CmpJust, (IGRshort *)p_CmpIndexOnTopo, 
	     (IGRshort *)p_RelCmpOrient, (IGRdouble *)p_CmpAngle,
             (IGRdouble *)p_CmpOrientSection, p_MdEnv, p_ActParamId,
             (struct GRid *)p_BufParamId, p_CmpGenInfo, p_CmpSysParamId,
	     p_CmpMissParamId /* added for TR179800720 */
           )

#endomdef

#endif

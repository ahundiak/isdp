/* $Id: VRprivmacros.h,v 1.2 2001/01/12 20:48:56 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRprivmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRprivmacros.h,v $
 *	Revision 1.2  2001/01/12 20:48:56  anand
 *	SP merge
 *	
 * Revision 1.1  2000/05/11  21:57:22  pinnacle
 * Created: route/vrinclude/VRprivmacros.h by apazhani for Service Pack
 *
 * Revision 1.2  1998/10/28  23:21:34  pinnacle
 * Replaced: vrinclude/VRprivmacros.h for:  by apazhani for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/09/10  15:18:42  pinnacle
 * Replaced: vrinclude/VRprivmacros.h for:  by onayragu for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.2  1996/01/17  23:41:18  pinnacle
 * Replaced: vrinclude/VRprivmacros.h for:  by r240_int for route240
 *
 *
 * History:
 *	04/08/92   momo		created
 *	05/03/93   Karine	2.2 release
 *	01/15/96   tlb		Fix VRGetDimensionAttributes prototype
 *  10/23/98   Alwin        Modified the macro VR$GetCompGenInfo.
 *                              TR179800720/179800830
 *  05/11/00   Alwin        Removed  the macro definition VR$GetCompGenInfo.
 *
 *************************************************************************/

#ifndef VRprivmacros_include
#define VRprivmacros_include


#include "VRstructs.h"
#include "VRpriv_attr.h"
#include "ACrg_collect.h"

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRint VRGetCmpAttributes __((
				IGRlong			*p_retmsg,
				IGRshort		Product,
				struct	GRid		*p_ComponentId,
				IGRshort		CmpCptNum,
	  			struct	GRid		*p_SysParamId,
				struct	GRid		*p_UserParamId,
				struct	GRid		*p_MissParamId,
				struct	GRmd_env	*p_MdEnv	));

extern IGRint VRGetDimensionAttributes __((
				IGRlong			*p_retmsg,
				IGRshort		Product,
				struct	GRid		*p_ComponentId,
				IGRint			CmpCptNum,
				struct	GRid		*p_SysCollectionId,
				union VRparam_attr	*p_DimAttributes,
				struct	GRmd_env	*p_MdEnv	));

extern IGRlong VRModifyHvacSection __((
				IGRlong			*p_retmsg,
				IGRint			Operation,
				IGRdouble		*p_InPutSection,
				IGRdouble		*p_StartPt,
				IGRdouble		*p_EndPt,
				struct	GRid		*p_ComponentId,
				IGRint			CmpCptNum,
				IGRdouble		*p_OutPutSection,
				struct	GRmd_env	*p_MdEnv	));

extern IGRint VRDefineSegPlanes __((
				IGRlong			*p_retmsg,
				IGRshort		TopoFlag,
				struct	GRid		*p_InPutPlanes,
				IGRdouble		*p_SegmentPt0,
				IGRdouble		*p_SegmentPt1,
				IGRboolean		SharePlanes,
				IGRboolean		InPutPlanesType,
				struct	GRmd_env	*p_MdEnv,
				struct	GRid		*p_OutPutPlanes	));

extern IGRint VRPlaceCmpByItemName __((
           			IGRlong			*p_retmsg,
				IGRshort		PlacementTime,
				IGRshort		Product,
				IGRint			TopoParentsNum, 
	     			struct	GRid		*p_TopoParentsList,
				IGRshort		CmpItemName,
				IGRshort		CmpJust,
	     			IGRshort		*p_CmpIndexOnTopo,
				IGRshort		*p_RelCmpOrient,
				IGRdouble		*p_CmpAngle,
				IGRdouble		*p_CmpOrientSection,
				IGRboolean		DisplayFlag,
				struct	GRid		*p_OldCmpId,
				struct	GRmd_env	*p_MdEnv,
				struct	GRid		*p_ActParamId,
				struct	GRid		*p_BufParamId,
				struct	GRid		*p_UserParamId,
				struct	GRid		*p_MissParamId,
				struct	GRvg_construct	*p_CmpCstList	));

#if defined(__cplusplus)
}
#endif

/*********************************************************************************************/
/* Abstract :                                                                                */
/*	this macro is a private macro used in the sketch to get attributes from a located    */
/*      component									     */
/*											     */
/*      Type			Name		Description				     */
/*								 			     */
/*	IGRlong			p_retmsg	return code                                  */
/*	IGRshort		Product		product name 			             */
/*	IGRboolean		CloneFlag	if we copy component params		     */
/*	struct GRid		p_ComponentId	component from witch the system is going     */
/*						to get system and/or user parameters	     */
/*	IGRint			CmpCptNum	the system gets from a p_ComponentId         */
/*						the system and user parameters and override  */
/*						the system dimension ones by those of the    */
/*						given CmpCptNum			             */
/*	struct GRid		p_SysParamId	result : system parameters GRid              */
/*	struct GRid	 	p_UserParamId	result : user parameters GRid                */
/*	struct GRid		p_MissParamId   result : missing parameters GRid 	     */
/*	struct GRmd_env		p_MdEnv		Current moduleInfo		             */
/*											     */
/*********************************************************************************************/

#omdef VR$GetCmpAttributes( 	p_retmsg,                   
 				Product		= VR_PIPING,
  				p_ComponentId	= NULL,	
  				CmpCptNum	= -1,	
  				p_SysParamId	= NULL, 
  				p_UserParamId	= NULL, 
  				p_MissParamId  	= NULL,	
  				p_MdEnv		= NULL
  		 	  )

VRGetCmpAttributes
	( p_retmsg, Product, (struct GRid *)p_ComponentId,CmpCptNum,
	  (struct GRid *)p_SysParamId, (struct GRid *) p_UserParamId,
	  (struct GRid *)p_MissParamId, (struct GRmd_env *)p_MdEnv )

#endomdef

/*********************************************************************************************/
/* Abstract :                                                                                */
/*	this macro is a private macro used to get dimension attributes from a collection     */
/*	a component or a component connect point.  					     */
/*	this macro is actually called in the sketch, the change attributes command objects   */
/*	and in the correction						  	 	     */
/*											     */
/*	Type			Name			Description			     */
/*											     */
/*	IGRlong		       	p_retmsg   		return code                          */
/*	IGRshort	 	Product			product name	                     */
/*	struct GRid	 	p_ComponentId   	component from witch the system is   */
/*							going to get dimension parameters    */
/*	IGRint			CmpCptNum               Component Connect Point from witch   */
/*							the system is going to get dimension */
/*							parameters			     */
/*	struct GRid	 	p_SysCollectionId	collection from witch the system is  */
/*							going to get dimension parameters    */
/*	union VRparam_attr	p_DimAttributes		result ( look VRpriv_attr.h )  	     */
/*	struct GRmd_env	 	p_MdEnv			Current moduleInfo  	       	     */
/*											     */
/*********************************************************************************************/

#omdef VR$GetDimensionAttributes( 	p_retmsg,
	 				Product,
	 				p_ComponentId     	= NULL ^
	 				p_SysCollectionId 	= NULL,
	 				CmpCptNum		= -1,
	 				p_DimAttributes,
	 				p_MdEnv	
	 		   	)

VRGetDimensionAttributes
	( p_retmsg, Product, (struct GRid *)p_ComponentId, CmpCptNum,
	  (struct GRid *)p_SysCollectionId, p_DimAttributes, p_MdEnv
	)

#endomdef


/******************************************************************************************/
/* Abstract :                                                                      	  */
/*											  */
/*	this macro is a private macro used to manipulate section in hvac.		  */
/*	this macro is only used in the sketch						  */
/*											  */
/*	Type		Name		Description					  */
/*											  */
/*	IGRlong		p_retmsg        return code                 			  */
/*    	IGRint		Operation	operation type ( VRprivdef.h )			  */
/*	IGRdouble	p_InPutSection  used with a given direction to get a new section  */
/*	struct GRid	p_ComponentId	get section from a given component		  */
/*	IGRint		CmpCptNum	given a component, get section on the given cpt   */
/*	IGRdouble	p_StartPt	start point of a given direction		  */
/*	IGRdouble	p_EndPt		end point of a given direction			  */
/*	IGRdouble	p_OutPutSection the result section				  */
/*	struct GRmd_env p_MdEnv   	current moduleInfo environnement or component one */
/*											  */
/******************************************************************************************/

#omdef VR$ModifyHvacSection	(	p_retmsg,
         				Operation	= VR_UPDATE_SECTION,
	 				p_InPutSection 	= NULL,
	 				p_StartPt	= NULL,
	 				p_EndPt		= NULL,
	 				p_ComponentId  	= NULL,
	 				CmpCptNum	= -1,
	 				p_OutPutSection,
	 				p_MdEnv		= NULL
	 			)

VRModifyHvacSection
	( p_retmsg, Operation, (IGRdouble *)p_InPutSection, (IGRdouble *) p_StartPt,
	  (IGRdouble *)p_EndPt, (struct GRid *)p_ComponentId, CmpCptNum,
	  p_OutPutSection, (struct GRmd_env *)p_MdEnv
	)

#endomdef

/******************************************************************************************/
/* Abstract :                                                                      	  */
/*											  */
/*	this macro is a private macro used to create segment planes depond of previous    */
/*	topology									  */
/*											  */
/*	Type		Name		Description					  */
/*											  */
/*	IGRlong		p_retmsg        return code                 			  */
/*    	IGRint		TopoFlag	gives infos about the previous topology.	  */
/*					( see. VRpriv_attr.h )   			  */
/*	IGRdouble	p_InPutPlanes   existing network planes to constrain with the     */
/*					new segment's planes.				  */
/*	IGRdouble	p_SegmentPt0	start point of the segment		  	  */
/*	IGRdouble	p_SegmentPt1	end point of the segment			  */
/*	IGRboolean	SharePlanes     inform about sharing planes or creating constrains*/
/*					TRUE means try to share Input and OutPut planes   */
/*					FALSE means constrain Input and OutPut planes     */
/*	IGRboolean	InPutPlanesType	TRUE means InPutPlanes are of a complex component */
/*	struct GRmd_env p_MdEnv   	current moduleInfo environnement		  */
/*											  */
/******************************************************************************************/

#omdef VR$DefineSegPlanes	(	p_retmsg,
					TopoFlag	= VR_NO_TOPO,
					p_InPutPlanes,
					p_SegmentPt0,
					p_SegmentPt1,
					SharePlanes	= TRUE,
					InPutPlanesType	= FALSE,
					p_MdEnv,
					p_OutPutPlanes
 				)

VRDefineSegPlanes
	( p_retmsg, TopoFlag, p_InPutPlanes, p_SegmentPt0, p_SegmentPt1,
	  SharePlanes, InPutPlanesType, p_MdEnv, p_OutPutPlanes
	)

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
/*      struct GRid             *p_cmpMissParamId       I   : component Missing
param id      */
/*											     */
/*********************************************************************************************/

/***
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
	     p_CmpMissParamId  
           )

#endomdef
***/

/*********************************************************************************************/
/*											     */
/* Abstract : this macro is a private macro. is called to place or replace an existing	     */
/*	      component given an item name, parameters, supports and instance information of */
/*	      this component								     */
/*											     */
/*	Type		Name				Description			     */
/*											     */
/*	IGRlong		 	p_retmsg		O   : return code		     */
/*	IGRshort	 	PlacementTime		I   : is a place or replace component*/
/*	IGRshort	 	Product			I   : product name 		     */
/*	IGRint		 	TopoParentsNum		I   : component templates number     */
/*	struct GRid	 	p_TopoParentsList	I   : component's templates  	     */
/*	IGRshort	 	CmpItemName		I   : component's Item Name	     */
/*	IGRshort	 	CmpJust			I   : component's placement justif.  */
/*	IGRshort	 	p_CmpIndexOnTopo	I   : component's index on its templ.*/
/*	IGRdouble	 	p_RelCmpOrient		I   : component's orientation	     */
/*							      relatively to its templates    */
/*							      direction 		     */
/*	IGRdouble	 	p_CmpAngle		I/O : component's orientation angle  */
/*							      if the component topology is   */
/*						              not completly defined	     */
/*	IGRdouble		p_CmpOrientSection	I   : not used in PIPING. component's*/
/*						              section orientation	     */
/*	IGRboolean	 	DisplayFlag		I   : TRUE ==> display component     */
/*						      	      after (re)place.		     */
/*	struct GRid	 	p_OldCmpId		I/O : if replace, this argument is   */
/*							      in input. in output is the new */
/*							      (re)placed component.          */
/*	struct GRmd_env		p_MdEnv			I   : module environnement	     */
/*	struct GRid	 	p_ActParamId		I   : system parameters grid 	     */
/*	struct GRid	 	p_BufParamId		I   : system parameters grid needed  */
/*							      for no symetric component      */
/*	struct GRid	 	p_UserParamId		I   : user parameters grid	     */
/*	struct GRid	 	p_MissParamId		I   : missing parameters grid	     */
/*	struct GRvg_construct	p_CmpCstList		I   : construction list		     */
/*											     */
/*********************************************************************************************/

#omdef VR$PlaceCmpByItemName
       ( p_retmsg,
         PlacementTime	   = VR_NEW_COMP,
         Product	   = VR_PIPING,  
         TopoParentsNum    = 0,          
         p_TopoParentsList = NULL,       
         CmpItemName	   = VR_DANGLING,
         CmpJust	   = VR_CENTER_JUST,
         p_CmpIndexOnTopo  = NULL,          
         p_RelCmpOrient    = NULL,          
         p_CmpAngle        = NULL,          
         p_CmpOrientSection= NULL,          
         DisplayFlag       = TRUE,          
         p_OldCmpId        = NULL,          
         p_MdEnv	   = NULL,          
         p_ActParamId      = NULL,          
         p_BufParamId      = NULL,          
         p_UserParamId     = NULL,          
         p_MissParamId     = NULL,          
         p_CmpCstList      = NULL )         


VRPlaceCmpByItemName
           ( p_retmsg, PlacementTime, Product, TopoParentsNum, 
	     (struct GRid *)p_TopoParentsList, CmpItemName, CmpJust,
	     (IGRshort *)p_CmpIndexOnTopo, (IGRshort *)p_RelCmpOrient,
             (IGRdouble *)p_CmpAngle, (IGRdouble *)p_CmpOrientSection,
	     DisplayFlag, (struct GRid *)p_OldCmpId, (struct GRmd_env *)p_MdEnv,
             (struct GRid *)p_ActParamId, (struct GRid *)p_BufParamId,
	     (struct GRid *)p_UserParamId,(struct GRid *) p_MissParamId,
			(struct GRvg_construct *)p_CmpCstList)

#endomdef

#endif

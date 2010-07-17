/* $Id: VRmacros.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:55  cvs
 *	Initial import to CVS
 *	
 * Revision 1.2  2000/02/15  18:11:22  pinnacle
 * Added the macro VR$AddUserAttribute
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/01/17  23:40:42  pinnacle
 * Replaced: vrinclude/VRmacros.h for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96   tlb		Corrected VRGetCptInfo prototype argument
 *	02/15/2000 Alwin	Added macro VR$AddUserAttribute
 *
 *************************************************************************/

#ifndef vrmacros_include
#define vrmacros_include

#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "VRstructs.h"
#include "ACrg_collect.h"
/***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VRGetCmpMatrix __(( 	IGRlong		*p_msg, 
				IGRdouble 	*p_Point, 
				struct GRid 	*p_SegmentId,
				IGRshort	SegEnd,
				struct GRid 	*p_ComponentId,
				IGRshort	CompCpt,
				IGRdouble	*p_Matrix,
				struct GRmd_env	*p_MdEnv	));

extern long VRMakeSource __(( 	IGRlong		*p_msg,
				struct GRid	*p_ComponentId,
				IGRshort	nCpNum,
				struct GRmd_env	*p_CompMdEnv,
				struct GRmd_env	*p_MdEnv,
				struct GRid	*p_ConnectorId		));


extern IGRint VREvaluateCmp __(( IGRlong		*p_msg,
				IGRint			Product,
				IGRchar			*AABBCCcode,
				IGRshort		ItemNum,
				IGRshort		SStatus,
				IGRdouble		Angle,
				IGRchar			*Number,
				IGRchar			*Notes,
				IGRchar			NoMtoFlg,
				IGRshort		*p_Option,
				struct GRsymbology	*Symbology,
				IGRchar			Representation,
				IGRint			*p_Type,
				IGRint			*p_NbCpts,
				struct	GRid		*p_SysParamId,
				struct	GRid		*p_UsrParamId,
				struct	GRid		*p_MissParamId,
				struct	GRid		*p_ComponentId,
				IGRint			*p_NbMissParams,
				struct	ACrg_coll	**p_AddrMissings,
				struct	GRmd_env	*p_MdEnv ));

extern	int VRPlaceComponent __(( IGRlong		*p_msg,
				struct	GRid		*p_ComponentId,
				IGRint			Type,
				IGRint			NbCpts,
				struct	GRid		*p_GraphicsId,
				struct	VRGenInfo	*p_Instance,
				IGRint			NbSegments,
				struct	GRid		*p_SegmentIds,
				IGRdouble		*p_Matrix,
				IGRdouble		Angle,
				struct	GRvg_construct	*p_CnstList,
				struct	GRmd_env	*p_MdEnv	));

extern	int VRReplace __(( 	IGRlong			*p_msg,
				struct	GRid		*p_OldCmpId,
				struct	GRid		*p_NewCmpId,
				IGRint			NewCmpType,
				struct	GRid		*p_NewGrId,
				IGRint			NbCpts, 
				struct	VRGenInfo	*p_NewInstance,
				IGRint			NbNewSegs,
				struct	GRid		*p_NewSegIds,
				IGRdouble		*p_Matrix,
				IGRdouble		Angle,
				struct	GRvg_construct	*p_CnstList,
				struct	GRmd_env	*p_MdEnv	));


extern	IGRint VRSetCompInstanceInfo __(( 
				IGRlong			*p_msg,
				IGRshort		CmpStatus,
				IGRchar			*CmpAABBCC_Code,
				IGRshort		CmpOption,
				IGRchar			*CmpNumber,
				IGRchar			*CmpNotes,
				IGRchar			CmpNoMtoFlg,
				IGRshort		NbAttrParents,
				IGRshort		NbTopoParents,
				IGRshort		CmpJust,
				IGRchar			CmpRepresentation,
				GRspacenum		MdEnvOsnum,
				struct	VRGenInfo	*p_CmpGenInfo	));

extern	IGRint  VRGetAttributes __((
				IGRlong			*p_retmsg,
				IGRshort		Product,
				IGRboolean		CloneFlag,
				struct	GRid		*p_ComponentId,
				IGRshort		CmpCptNum,
				struct	GRid		*p_SysParamId,
				struct	GRid		*p_UserParamId,
				struct	GRid		*p_MissParamId,
				struct	GRmd_env	*p_MdEnv	));


extern IGRint VRPlaceSegment __((
				IGRlong			*p_retmsg,
				IGRshort		Product,
				IGRshort		GivenAction,
				IGRdouble		*p_SegmentPt0,
				IGRdouble		*p_SegmentPt1,
				struct	GRid		*p_PrevSegId,
				struct	GRid		*p_CmpToConnectId,
				IGRshort		CmpCptNum,
				IGRdouble 		*p_CptCoord,
				struct	GRmd_env	*p_CmpMdEnv,
				struct	GRmd_env	*p_CurMdEnv,
				struct	GRid		*p_NewSegmentId ));

extern IGRint  VRComputeCorrection __((
				IGRlong			*p_retmsg,
				IGRshort		ComputeType,
				IGRshort		CorType,
				struct	GRid		*p_SegmentId,
				struct	GRmd_env	*p_MdEnv,
				struct	GRid		*p_CorId	));


extern int VRSplitSegment __(( 
				IGRlong			*p_retmsg,
				IGRboolean		SharePlanes,
				struct	GRid		*p_SegmentToSplitId,
				IGRdouble		*p_SplitPoint,
				struct	GRmd_env	*p_MdEnv,
				struct	GRid		*p_NewSegmentId ));

extern IGRint VRMergeSegments __(( 
				IGRlong			*p_retmsg,
				IGRint			SegNum,
				struct	GRid		*p_SegmentsId,
				struct	GRmd_env	*p_MdEnv	));

extern	IGRint VRSplitCorrection __(( 
				IGRlong			*p_retmsg,
				IGRshort		CorType,
				struct	GRid		*p_CorToSplit,
				struct	GRid		*p_SegId,
				struct	GRid		*p_CmpId,
				struct	GRmd_env	*p_MdEnv,
				IGRshort		NewCorType	));

extern	IGRint VRGetCptInfo __((	
				IGRlong			*p_retmsg,
				struct	GRid		*p_CmpId,
				IGRint			CmpCptNum,
				IGRdouble		*p_CptCoord,
				IGRdouble		*p_CptAxis,
				IGRdouble		*p_CptOrient,
				struct	VRcp_attr	*p_CptProp,
				struct	GRmd_env	*p_MdEnv	));

extern	int VROrientComp __((	IGRlong			*p_retmsg,
				struct	GRid		*p_CmpId,
				IGRint			Justif,
				IGRdouble		*Matrix,
				IGRdouble		Angle,
				struct	GRmd_env	*p_MdEnv,
				IGRint			ReverseFlag	));

#if defined(__cplusplus)
}
#endif

/***************************************************************************/

/************************************************************************/
/*									*/
/* Abstract :	applied to an input I/ROUTE object, this macro returns 	*/
/*		a network compatible default orientation matrix.	*/
/* Arguments :								*/
/*									*/
/* IGRlong     *p_msg		: returns MSFAIL if the specified 	*/
/*				  connect point is already connected.	*/
/* I IGRdouble *p_Point		: 3D point : will return the active	*/
/*				  coordinate system matrix at this point*/
/* I GRid      *p_SegmentID	: connection orientation matrix at the	*/
/*				  specified end point ( SegEnd = 0 | 1)	*/
/*				  of this segment.			*/
/* I GRid      *p_ComponentId	: orientation matrix of the component	*/
/*				  if CompCpt is not specified or,	*/
/*				  connection orientation matrix at the	*/
/*				  specified connect point.		*/
/* I IGRshort  SegEnd		: Segment's end point ( 0 or 1 ) ( only */
/*				  if p_SegmentId is specified.		*/
/* I IGRshort  CompCpt		: Component's connect point number (only*/
/*				  if p_ComponentId is specified.	*/
/* O IGRdouble *p_Matrix	: (4x4) orientation matrix.		*/
/* I GRmd_env  *p_MdEnv		: working module env.			*/
/************************************************************************/

#omdef VR$GetMatrix (	p_msg,
			p_Point = NULL ^
			p_SegmentId = NULL  ^
			p_ComponentId = NULL ,
			SegEnd = -1, CompCpt = -1,
			p_Matrix,
			p_MdEnv)

#if 	om$specified (p_SegmentId) && !om$specified (SegEnd)
#omerror "No end point specified for the segment"
#else

VRGetCmpMatrix( p_msg, (IGRdouble *)p_Point, (struct GRid *)p_SegmentId, SegEnd,
	     (struct GRid *)p_ComponentId, CompCpt, p_Matrix, p_MdEnv )
			
#endif
#endomdef

/************************************************************************/
/*									*/
/* Abstract :	applied to an input I/ROUTE component object,	 	*/
/*		VR$MakeSource returns an object ensuring the connection	*/
/*		between the component and a network (see also 		*/
/*		as$make_source). This object can be the component if	*/
/*		it already is in the right object space, or an object	*/
/*		an object managing the inter_OS connections.		*/
/* Arguments :								*/
/*									*/
/* IGRlong     *p_msg		: returns MSFAIL if the specified 	*/
/*				  connect point is already connected.	*/
/* I GRid      *p_ComponentId	: Component to which will be connected 	*/
/*			  	  the network.				*/
/* I IGRshort  nCpNum		: Component's connect point number.	*/
/* I GRmd_env  *p_CompMdEnv	: module env of the component.		*/
/* I GRmd_env  *p_MdEnv		: working module env.			*/
/* O GRid      *p_ConnectorId	: Object that will be connectable to a	*/
/*				  network.				*/
/************************************************************************/

#omdef VR$MakeSource (	p_msg,
			p_ComponentId,
			nCpNum,
			p_CompMdEnv,
			p_MdEnv,
			p_ConnectorId )

VRMakeSource( p_msg, p_ComponentId, nCpNum, p_CompMdEnv, p_MdEnv, p_ConnectorId)

#endomdef

#omdef VR$Evaluate(	p_msg,
			Product,
			AABBCCcode=NULL,
			ItemNum=0,
			SStatus,
			Angle=0.0,
			Number=NULL,
			Notes=NULL,
			NoMtoFlg=' ',
			p_Option,
			Symbology,
			Representation,
			p_Type,
			p_NbCpts,
			p_SysParamId,
			p_UsrParamId,
			p_MissParamId=NULL,
			p_ComponentId,
			p_NbMissParams,
			p_AddrMissings=NULL,
			p_MdEnv)

VREvaluateCmp(	( p_msg ), 	( Product ),	(IGRchar *) ( AABBCCcode ),
		( ItemNum ), 	( SStatus ),	(IGRdouble)Angle,
		( Number ),	( Notes ),	( NoMtoFlg ), 
		( p_Option ),	( Symbology ),	( Representation ), 
		p_Type, p_NbCpts, p_SysParamId, p_UsrParamId,
		(struct GRid *) p_MissParamId, p_ComponentId, p_NbMissParams,
		(struct ACrg_coll **)p_AddrMissings, p_MdEnv )

#endomdef

/************************************************************************/
/*									*/
/* Abstract :	Given as input an I/ROUTE component object, previously 	*/
/*		evaluated, and the networks supports objects (segments) */
/*		it places this component's in the network.		*/
/* Arguments :								*/
/*									*/
/* IGRlong     *p_msg		: returns MSFAIL if something went wrong*/
/* I GRid      *p_ComponentId	: Component which has to be placed 	*/
/* I IGRint    Type		: Geometric type of the	component	*/
/* I IGRint    NbCpts		: Number of connect points.		*/
/* I GRid      *p_GraphicsId	: Component's graphics symbol	 	*/
/* I VRGenInfo *p_Instance	: Generic component description.	*/
/* I IGRint    NbSegments	: Number of Segments.			*/
/* I GRid      *p_SegmentIds	: List of segments			*/
/* I IGRdouble *p_Matrix	: Orientation and position matrix.	*/
/* I IGRdouble Angle		: Rotation angle.			*/
/* I GRvg_construct *p_CnstList	: Symbology structure.			*/
/* I GRmd_env  *p_MdEnv		: working module env.			*/
/************************************************************************/

#omdef VR$Place (	p_msg,
			p_ComponentId,
			Type,
			NbCpts,
			p_GraphicsId=NULL,
			p_Instance,
			NbSegments,
			p_SegmentIds,
			p_Matrix=NULL,
			Angle=0.0,
			p_CnstList,
			p_MdEnv)

VRPlaceComponent( p_msg, p_ComponentId, Type, NbCpts, (struct GRid*)p_GraphicsId,
		  p_Instance, NbSegments, p_SegmentIds, (IGRdouble *) p_Matrix,
	  	  (IGRdouble)Angle, p_CnstList, p_MdEnv )

#endomdef

/********************************************************************************/
/*										*/
/* Abstract :	Given as input two I/ROUTE component objects, an old		*/
/*		connected to a network and a new (evaluated) one,		*/
/*		this macro replaces the old one by the new one.			*/
/* Arguments :									*/
/*										*/
/* IGRlong     		*p_msg		: returns MSFAIL if something went wrong*/
/* I GRid		*p_OldCmpId 	: Component to get ridde of.       	*/
/* I GRid		*p_NewCmpId 	: Component to substitute.         	*/
/* I IGRint		NewCmpType	: Component's type (returned by VR$Evaluate */
/* I IGRint		NbCpts		: Number of connection points.		*/
/* I GRid		*p_NewGrId	: New component's graphic		*/
/* I VRGenInfo		*p_NewInstance	: Temporary 				*/
/* I IGRint		NbNewSegs	: Number of segments to be added.	*/
/* I GRid		*NewSegIds	: List of new segments.			*/
/* I IGRdouble		*dMatrix	: Default Orientation and position matrix. */
/* I IGRdouble		dAngle		: Rotation angle around ??? 		*/
/* I GRvg_construct   	*p_CnstList;   	: construction list 			*/
/* I GRmd_env 		*p_MdEnv
/********************************************************************************/

#omdef VR$Replace (	p_msg,
			p_OldCmpId,
			p_NewCmpId,
			NewCmpType,
			p_NewGrId,
			NbCpts,
			p_NewInstance,
			NbNewSegs	= 0,
			p_NewSegIds	= NULL,
			p_Matrix	= NULL,
			Angle=0.0,
			p_CnstList,
			p_MdEnv)

VRReplace( p_msg, p_OldCmpId, p_NewCmpId, NewCmpType, p_NewGrId, NbCpts, 
           p_NewInstance, NbNewSegs, (struct GRid *) p_NewSegIds, p_Matrix,
	   (IGRdouble)Angle, p_CnstList, p_MdEnv )

#endomdef

/*********************************************************************************************/
/*											     */
/* Abstract : Given component's instances ( see. VRGeneric.S ) this macro build the 	     */
/*	      corresponding GenInfo structure fields                                         */
/*											     */
/*	Type			Name			Description			     */
/*											     */
/*	IGRlong			*p_retmsg		O : return code			     */
/*	IGRshort         	CmpStatus	    	I : component status   		     */
/*      IGRchar			*CmpAABBCC_Code		I : component AABBCC code            */
/*	IGRshort	        CmpOption	        I : component option                 */
/*      IGRshort		CmpNumber		I : component number                 */
/*      IGRchar			*CmpNotes		I : component notes                  */
/*      IGRchar			*CmpNoMtoFlg		I : component no mto flag            */
/*      IGRint   		NbAttrParents		I : number of attributes collections */
/*							    templates of the component       */
/*	IGRint         		NbTopoParents		I : number of topology supports      */
/*							    templates of the component       */
/*      IGRshort		CmpJust			I : component placement justification*/
/*      IGRchar			CmpRepresentation	I : component representatin	     */
/*      uword			MdEnvOsnum		I : Current OS num  	             */
/*  	struct VRGenInfo        *p_CmpGenInfo		O : component generic info structure */
/*											     */
/*********************************************************************************************/ 

#omdef VR$SetCompInstanceInfo(	p_msg,
         			CmpStatus	  = VR_SYSTEM,
         			CmpAABBCC_Code    = NULL,     
         			CmpOption	  = 1,        
         			CmpNumber	  = NULL, 
         			CmpNotes	  = NULL, 
         			CmpNoMtoFlg	  = ' ',  
         			NbAttrParents	  = 2,    
         			NbTopoParents     = 1,    
         			CmpJust	   	  = VR_CENTER_JUST,
         			CmpRepresentation = ' ',           
         			MdEnvOsnum	  = 0,
         			p_CmpGenInfo
			     )           	

VRSetCompInstanceInfo
           ( p_msg, CmpStatus, (IGRchar *)CmpAABBCC_Code, CmpOption,
             (IGRchar *)CmpNumber, (IGRchar *)CmpNotes, CmpNoMtoFlg, 
	     NbAttrParents, NbTopoParents, CmpJust, CmpRepresentation,
	     MdEnvOsnum, p_CmpGenInfo
           )

#endomdef

/*********************************************************************************************/
/*											     */
/* Abstract :                                                                                */
/*	this macro gets system and/or user, missing parameters GRid of a given component     */
/*      or gets system and/or user active parameters defined in I\ROUTE.      		     */
/*											     */
/*      Type			Name		Description				     */
/*								 			     */
/*	IGRlong			p_retmsg	return code                                  */
/*	IGRshort		Product		product name 			             */
/*	IGRbollean		CloneFlag	return a copy of asked collection(s)	     */
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

#omdef VR$GetAttributes(	p_retmsg,              
	 			Product		= VR_PIPING,
	 			CloneFlag	= FALSE,
	 			p_ComponentId	= NULL,
				CmpCptNum	= -1,
	 			p_SysParamId	= NULL,
	 			p_UserParamId	= NULL,
	 			p_MissParamId   = NULL,
	 			p_MdEnv
	 	       )

VRGetAttributes
	( p_retmsg, Product, CloneFlag, (struct GRid *)p_ComponentId,
	  CmpCptNum, (struct GRid *)p_SysParamId, (struct GRid *) p_UserParamId,
	  (struct GRid *)p_MissParamId, p_MdEnv
        )

#endomdef


/****************************************************************************************/
/* Abstract :                                                                         	*/
/*	given a previous segment ( automatic placement ) or a component ( manaul      	*/
/*      placment ) and a pair of points this macro create a new segment and place	*/
/*	network constrains 							      	*/
/*      				 					      	*/
/*	Type		Name				Description			*/
/*											*/
/*	IGRlong		*p_retmsg		return code				*/
/*	IGRshort	Product			product name				*/
/*	IGRshort	GivenAction		needed to constrain network		*/
/*						possible values :			*/
/*							- VR_SHARE_PLANE		*/
/*							- IS_AN_EXTEND			*/
/*	IGRdouble	*p_SegmentPt0		segment start point			*/
/*	IGRdouble	*p_SegmentPt1		segment end point			*/
/*	struct GRid	*p_PrevSegId		if not NULL, used to get needed planes  */
/*						to constrain network			*/
/*	struct GRid	*p_CmpToConnectId	to create a new segment, user can start	*/
/*						from an existing component with or not	*/
/*						free connect points.			*/
/*						if not NULL, used to get needed planes  */
/*						to constrain network			*/
/*	IGRint		CmpCptNum		given if we start from free 
/*							
/****************************************************************************************/

#omdef VR$PlaceSegment
       ( p_retmsg,                         	/* O : return code           		*/
	 Product,				/* I : product name			*/
	 GivenAction		= VR_SHARE_PLANES,
						/* I : share plane			*/
         p_SegmentPt0,				/* I : start segment point 		*/
         p_SegmentPt1,				/* I : end segment point 		*/
	 p_PrevSegId 		= NULL,		/* I : previous segment GRid            */
	 p_CmpToConnectId	= NULL,		/* I : component GRid		        */
	 CmpCptNum 		= 0,	        /* I : number of connect point          */
	 p_CptCoord		= NULL,       	/* I : connect poin coordinates		*/
	 p_CmpMdEnv		= NULL,		/* I : Compoent module info          	*/
	 p_CurMdEnv             = NULL,		/* I : Current moduleInfo		*/
	 p_NewSegmentId 	= NULL )	/* O : segment to create		*/


#if om$specified(p_CmpToConnectId) && !om$specified(p_CmpMdEnv)
			#omerror "No environement specified for the component"
#else
VRPlaceSegment( p_retmsg, Product, GivenAction, p_SegmentPt0, p_SegmentPt1,
                (struct GRid *)p_PrevSegId, (struct GRid *)p_CmpToConnectId,
	        CmpCptNum, (IGRdouble *)p_CptCoord, (struct GRmd_env *) p_CmpMdEnv,
                (struct GRmd_env *)p_CurMdEnv, (struct GRid *)p_NewSegmentId
	      )
#endif

#endomdef

/********************************************************************************************/
/* Abstract :                                                                         	    */
/*	create a new correction or update an existing one ( update graph of dependency      */
/*      and compute the correction   							    */
/*                                  							    */
/*	Type			Name			Description			    */
/*											    */
/*	IGRlong			*p_retmsg,      O : return code           		    */
/*      IGRshort		ComputeType	I : imediate, deffer or no compute of the   */
/*						    correction			 	    */
/*	IGRshort         	CorType		I : correction type. (FTF, ~FTF, VR_UNKNOWN)*/
/*	struct GRid	 	*p_SegmentId 	I : given a segment the system gets the     */
/*						    templates and the connect points to     */
/*						    adapte.				    */
/*	struct GRid	 	*p_ParentList	I : correction templates    	            */
/*	IGRint			NbParents	I : number of templates 		    */
/*	IGRint		 	*p_CptIndexList	I : corresponding connect point of each     */
/*						    given template			    */
/*	struct GRmd_env		*p_MdEnv	I : module environnement		    */
/*	struct GRid		*p_CorId	O : updated correction can be NULL	    */
/*											    */
/********************************************************************************************/

#omdef VR$ComputeCorrection
       ( p_retmsg,
         ComputeType    = VR_IMMEDIATE_COMPUTE,
         CorType        = VR_NO_FTF,   
	 p_SegmentId    = NULL,
	 p_MdEnv,
	 p_CorId	= NULL )

VRComputeCorrection
	( p_retmsg, ComputeType, CorType, (struct GRid *)p_SegmentId,
          p_MdEnv, (struct GRid *)p_CorId
        )

#endomdef


/****************************************************************************************/
/*											*/
/* Abstract :	split a given segment							*/
/*											*/
/*	Type		 Name				Description			*/
/*											*/
/*	IGRlong	 	 *p_retmsg		O : return code				*/
/*	IGRboolean	 SharePlanes		I : TRUE ==> share p_SegmentToSplitId	*/
/*						    end plane and p_NewSegmentId start  */
/*						    plane				*/
/*	struct GRid	 *p_SegmentToSplitId	I : segment to split			*/
/*	IGRdouble	 *p_SplitPoint		I : split point				*/
/*	struct GRmd_env  *p_MdEnv		I : module info				*/
/*	struct GRid	 *p_NewSegmentId	O : new segment id 			*/
/*											*/
/****************************************************************************************/

#omdef VR$SplitSegment	(	p_retmsg,
				SharePlanes = TRUE,
				p_SegmentToSplitId,
				p_SplitPoint,
				p_MdEnv,
				p_NewSegmentId
			)


VRSplitSegment( p_retmsg, SharePlanes, p_SegmentToSplitId, p_SplitPoint,
		p_MdEnv, p_NewSegmentId )

#endomdef


/****************************************************************************************/
/*											*/
/* Abstract :	merge segments								*/
/*											*/
/*	Type		Name				Description			*/
/*											*/
/*	IGRlong	 	*p_retmsg		O   : return code			*/
/*	IGRint		SegNum			I   : number of segments to merge	*/
/*	struct GRid	*p_SegmentsId		I/O : list of segment to merge. 	*/
/*						      the result is returned in 	*/
/*						      p_SegmentsId[0].			*/
/*	struct GRmd_env *p_MdEnv		I   : module environnement		*/
/*											*/
/****************************************************************************************/

#omdef VR$MergeSegments	(	p_retmsg,
				SegNum = 2,
				p_SegmentsId,
				p_MdEnv
			)

VRMergeSegments( p_retmsg, SegNum, p_SegmentsId, p_MdEnv );

#endomdef

/****************************************************************************************/
/*											*/
/* Abstract :	split a given correction						*/
/*											*/
/*	Type		 Name				Description			*/
/*											*/
/*	IGRlong	 	 *p_retmsg		O : return code				*/
/*	IGRboolean	 CorType		I : given correction type ( FTF or not )*/
/*	struct GRid	 *p_CorToSplitId	I : correction to split or		*/
/*	struct GRid	 *p_SegId		I : segment supporting correction templ.*/
/*	struct GRid	 *p_CmpId		I : if SegId is given p_CmpId is used   */
/*						    to get the correction to split. 	*/
/*						    if p_CorToSplitId is given p_CmpId 	*/
/*						    will stay template of the correction*/
/*						    after the split			*/
/*	struct GRmd_env  *p_MdEnv		I : module environnement		*/
/*	IGRboolean	 NewCorType		I : new correction type			*/
/*	struct GRid	 *p_NewCorId		O : new correction id. can be NULL	*/
/*											*/
/****************************************************************************************/

#omdef VR$SplitCorrection(	p_retmsg,
				CorType		= VR_UNKNOWN,
				p_CorToSplit	= NULL ^ p_SegId = NULL,
				p_CmpId,
				p_MdEnv,
				NewCorType	= VR_UNKNOWN
			)

VRSplitCorrection( p_retmsg, CorType, (struct GRid *)p_CorToSplit, 
		   (struct GRid *)p_SegId, p_CmpId, p_MdEnv, NewCorType
		 )

#endomdef

/****************************************************************************************/
/*											*/
/* Abstract :	merge corrections							*/
/*											*/
/*	Type		Name				Description			*/
/*											*/
/*	IGRlong		*p_retmsg		O   : return code			*/
/*	IGRint		CorNum			I   : number of corrections to merge	*/
/*	struct GRid	*p_CorsId		I/O : list of corrections to merge	*/
/*						      the result is returned in 	*/
/*						      p_CorsId[0].			*/
/*	struct GRmd_env	*p_MdEnv		I   : module environnement		*/
/*											*/
/****************************************************************************************/

#omdef VR$MergeCorrections(	p_retmsg,
				CorNum = 2,
				p_CorsId,
				p_MdEnv
			  )

VRMergeSegments( p_retmsg, CorNum, p_CorsId, p_Mdenv )

#endomdef

/****************************************************************************************/
/*											*/
/* Abstract :	get geometric and connection properties from component's connection	*/
/*		point									*/
/*											*/
/*	Type		 Name				Description			*/
/*											*/
/*	IGRlong		 *p_retmsg		O : return code	:			*/
/*						    MSFAIL if given connect poiont has	*/
/*						    not connexion proporties		*/
/*	struct GRid	 *p_CmpId		I : component identifier		*/
/*	IGRint		 CmpCptNum		I : component cpt number		*/
/*	IGRdouble	 *p_CptCoord		O : cpt XYZ coordinates			*/
/*	IGRdouble	 *p_CptAxis		O : cpt connexion axis			*/
/*	IGRdouble	 *p_CptOrient		O : cpt section orientation		*/
/*	struct VRcp_attr *p_CptProp		O : cpt connexion proporties		*/
/*	struct GRmd_env	 *p_MdEnv		I : module environnement		*/
/*											*/
/****************************************************************************************/

#omdef VR$GetCptInfo(	p_retmsg,
			p_CmpId,
			CmpCptNum,
			p_CptCoord  = NULL,
			p_CptAxis   = NULL,
			p_CptOrient = NULL,
			p_CptProp   = NULL,
			p_MdEnv
		    )

VRGetCptInfo( p_retmsg, p_CmpId, CmpCptNum, (IGRdouble *)p_CptCoord,
	      (IGRdouble *)p_CptAxis, (IGRdouble *)p_CptOrient,
	      (struct VRcp_attr *)p_CptProp, p_MdEnv )

#endomdef

/******************************************************************************/
/*											*/
/* Abstract :	Given a component orientation matrix, it's connect point and 		*/
/*		an angle of rotation around the X axis, the component is	*/
/*		reoriented.							*/
/*											*/
/*	Type		 Name				Description			*/
/*											*/
/*	IGRlong		 *p_retmsg		O   : return code			*/
/*	struct GRid	 *p_CmpId		I   : component Id			*/
/*	IGRint		 Justif 		I   : component cpt number		*/
/*	IGRmatrix	 Matrix			I   : component matrix			*/
/*	IGRdouble	 Angle			I   : angle of rotation			*/
/*	struct GRmd_env	 *p_MdEnv		I   : module environnement		*/
/*	IGRint		 ReverseFlag		I   : reverse z&x override       	*/
/*     											*/
/******************************************************************************/
 
#omdef VR$OrientComp(	p_retmsg,
			p_CmpId,
			Justif = VR_CENTER_JUST,
			Matrix,
			Angle = 0.0,
			p_MdEnv,
			ReverseFlag = FALSE
		    )

VROrientComp( p_retmsg, p_CmpId, Justif, Matrix, ( IGRdouble )Angle, p_MdEnv , (ReverseFlag))

#endomdef

/******************************************************************************/
/*										
* Abstract : Specified the Attribute Name, Type and Value, the function would
*		add/update it in the User Attribute Collector. If the Collector is 
*		shared by many components, then it creates separate collector and copies
*		the old attributes and appends the new attribute to it.
*										
*	Type		 Name				Description
*											
*	IGRlong		 *p_retmsg		O   : return code		
*	IGRchar		 *szAttrName	I   : Attribute Name
*	IGRint		  nType			I   : AC_ATTRIB_TEXT/AC_ATTRIB_DOUBLE
*	IGRchar		 *szAttrValue	I   : Attribute Value as "string"
*	struct GRid	  ComponentId	I   : Component Id
*     							
/******************************************************************************/

extern  IGRint  VRAddUserAttribute  __((    IGRlong     *msg,
                                            IGRchar     *szAttrName,
                                            IGRint      nType,
                                            IGRchar     *szAttrValue,
                                            struct GRid ComponentId
                                            ));

 
#omdef VR$AddUserAttribute(	p_retmsg,
							p_AttrName,
							Type,
							p_AttrValue,
							cmpId )

VRAddUserAttribute( p_retmsg, p_AttrName, Type, p_AttrValue, cmpId );

#endomdef

#endif

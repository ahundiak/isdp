/* $Id: VRPlace.I,v 1.4 2002/04/10 20:44:50 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRPlace.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlace.I,v $
 *	Revision 1.4  2002/04/10 20:44:50  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:18:02  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:25  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:32:30  pinnacle
# Created: route/vrtools/VRPlace.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/15  22:10:54  pinnacle
# Replaced: vrtools/VRPlace.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/19  10:32:46  pinnacle
# Replaced: vrtools/VRPlace.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/18  00:32:02  pinnacle
# Replaced: vrtools/VRPlace.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/17/96   tlb		Add prototypes, 
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
/*************************************************************/
/*	File 	: VRPlace.I
/*	Author	: B Demars ( ISDC, Paris )
/*	Date	: 23-DEC-91 Route release 1.4.3.17
/*
/*	* 07-JAN-92	1.4.3.18
/*		Bruno
/*		Add treatment for automatic components :
/*				no matrix is specified => orientation
/*							instances are 
/*							set to the right
/*							value.
/*	* 31-MAR-92	1.4.5.7
/*		Bruno
/*		Remove attributes collections from arguments.
/*
/*************************************************************/

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
#include <stdio.h>
#include <math.h>
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRstructs.h"
#include "VRmacros.h"
#include "VRMath.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include        "vrdbgmacros.h"
#include "AS_status.h"
#include "vrconcco_pto.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#define AS_DEBUG

/*-------------------------------------------------------------------*/
/*	function VRPlaceComponent
/*
/* 
/* Given the component object, its geometric supports and an orientation
/* and position coordinate system, it places this component on the network.
/* The component should have been evaluated before, using the VR$Evaluate
/* macro.
/* 
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

from VRGeneric	import	NDplace,
			VRSetInstance,
			VRGetParams,
			VRGetCptGeom;
from VRCnrlSeg	import	VRGetTopo,
			VRget_terminators,
			VRget_planes;
from GRgraphics	import	GRdelete,
			GRaddwrng;
from VRConcComp	import	VRAddPlanes;
from ACncpx	import	ACchange_feet;
from NDnode	import	NDs_compute_node;
from NDmacro	import	ACgive_structure;


IGRint VRPlaceComponent( msg, ComponentId, ComponentType, NbCpts, GraphicsId,
		CompStr, NbSegments, SegmentIds,
		dMatrix, dAngle,
		p_CnstList, md_env )
			       
IGRlong 		*msg ;         /* O : Return code, MSSUCC or MSFAIL.   */
struct GRid		*ComponentId ; /* I : Component to Place.              */
IGRint			ComponentType; /* I : Component's type (returned by VR$Evaluate */
IGRint			NbCpts;	       /* I : Number of connect points.        */
struct GRid		*GraphicsId ;  /* I : Component's graphic symbol.            */
struct VRGenInfo	*CompStr;      /* I : Temporary*/
IGRint			NbSegments;    /* I : Number of segment to  be attached to. */
struct GRid		*SegmentIds ;  /* I : List of segments.                */
IGRdouble		*dMatrix;      /* I : Default Orientation and position matrix. */
IGRdouble		dAngle;	       /* I : Rotation angle around ??? */
struct GRvg_construct   *p_CnstList;   /* I : construction list */
struct GRmd_env 	*md_env;

/*.VRPlaceComponent */
{
	IGRint		status,i;
	IGRlong		retmsg;
	struct GRas	assoc_list;
	struct GRid	ParentsList[4*VR_MAX_CPTS+VR_MAX_CPTS+1],/* maximum 3 planes and
								    one segment per cpt */
			TempList[3*VR_MAX_CPTS];
	IGRint		NbTemp=0;
	struct IGRplane	Plane;
	IGRdouble	dPoint[3], dNormal[3];
	IGRdouble	dOrig[3], dXaxis[3], dYaxis[3], dZaxis[3], dVect[3];
	IGRdouble	dAxes[3*VR_MAX_CPTS];
	IGRdouble	dXOrie, dYOrie;
	BSrc		rc;
	IGRshort	nXIndex, nYIndex;

        SetProc( Func_VRPlaceComponent ); Begin
        /*"angle = %f\n", dAngle */
	/*"md_env = %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */

	/* -- Initialize template list -- */

	for ( i=0; i<3*VR_MAX_CPTS; i++ )
	{
		TempList[i].objid = NULL_OBJID;

	}/* end initialize template list */

	/* -- Component's topology is already defined -- */
	if ( !dMatrix )	goto VR_PLACE_COMPONENT;

	/* ---------------------------------- */
	/* -- Defined component's topology -- */
	/* ---------------------------------- */

	Plane.point  = dPoint;
	Plane.normal = dNormal;

	/* -- Put matrix into usable format -- */

	dXaxis[0] = dMatrix[0]; dXaxis[1] = dMatrix[4]; dXaxis[2] = dMatrix[8];
	dYaxis[0] = dMatrix[1]; dYaxis[1] = dMatrix[5]; dYaxis[2] = dMatrix[9];
	dZaxis[0] = dMatrix[2]; dZaxis[1] = dMatrix[6]; dZaxis[2] = dMatrix[10];
	dOrig [0] = dMatrix[3]; dOrig[1]  = dMatrix[7]; dOrig[2]  = dMatrix[11];

	/*" Orig  : %f, %f, %f\n",dOrig[0] , dOrig[1] ,  dOrig[2] */
	/*" Xaxis : %f, %f, %f\n",dXaxis[0], dXaxis[1], dXaxis[2] */
	/*" Yaxis : %f, %f, %f\n",dYaxis[0], dYaxis[1], dYaxis[2] */
	/*" Zaxis : %f, %f, %f\n",dZaxis[0], dZaxis[1], dZaxis[2] */

	/* -- Compute the component's orientation instances -- */

	/*"Component Type = %d\n", ComponentType */

	/*"Component's justif : %d\n", CompStr->nJustif */

	if( ComponentType & VR_CONSTR_COMPONENT_TYPE )
	{
		IGRshort IndexTable[3*(VR_MAX_CPTS-1)];

		/* ---------------------------- */
		/*| -- Constrained component -- */
		/* ---------------------------- */

		/* it should be placed at the end of one segment */
/*		if ( NbSegments != 1 )
                 return OM_E_INVARG; */

		/*"NbSegments = %d\n", NbSegments */
		/*^
			for( i=0; i<NbSegments; i++ )
			 printf("SegId[%d] = %d\n", i, SegmentIds[i].objid );
		*/

		for ( i = 0 ; i<VR_MAX_CPTS; i++ )
		{
			CompStr->Attr.CComp.nIndex[i] = -1;
		}

		if ( GraphicsId )	
		for( i=0; i<NbCpts; i++ )
		{
			IGRint			retstatus;
			IGRint			j, Index=-1;
			IGRdouble		dCptCoord[3];
			struct	ret_struct	AttrSt;
			IGRchar			footname[20];

			VRCptEncode (i, footname, ":graphic");
			
			status = 
			om$send ( msg = message NDmacro.ACgive_structure 
						( &retstatus, &Index,
					 footname, &AttrSt, md_env ),
				  senderid = NULL_OBJID,
				  targetid = GraphicsId->objid,
				  targetos = GraphicsId->osnum );
			as$status ( action = RET_STATUS );

			for (j=0;j<3;j++)
				dCptCoord[j] = AttrSt.var.point_st.pt[j];

			/*"CptCood %d = %f %f %f \n", i,dCptCoord[0],dCptCoord[1],dCptCoord[2]*/

			/* -- Initialize position on segments -- */
			VRCompPosOnTopo ( NbSegments, SegmentIds, dCptCoord,
					  CompStr->Attr.CComp.nIndex, 
					  md_env );
		}

		/*^
			for( i=0; i<NbSegments; i++ )
			 printf("index[%d] = %d\n", i, CompStr->Attr.CComp.nIndex[i] );
		*/

                CompStr->Attr.CComp.dAngleToCommon = dAngle;

		/*"dangle = %f \n", dAngle */

		/* -- Get Planes Ids -- */
		for( i=0; i<NbSegments; i++ )
		{
		  status = om$send( msg = message VRCnrlSeg.VRget_planes
					  ( &retmsg,
			  		    &TempList[i*3],
			  		    &TempList[i*3+1],
			  		    CompStr->Attr.CComp.nIndex[i] ? NULL : &TempList[i*3+2],
			  		    CompStr->Attr.CComp.nIndex[i] ? &TempList[i*3+2] : NULL
					  ),
		  		    targetid = SegmentIds[i].objid,
				    targetos = SegmentIds[i].osnum,
				    senderid = NULL_OBJID );
		  as$status ( action = RET_STATUS );
                }

		status= om$send (
			msg = message VRGeneric.VRSetInstance (&retmsg, CompStr ),
			targetid = ComponentId->objid,
			targetos = ComponentId->osnum,
			senderid = NULL_OBJID );
		as$status ( action = RET_STATUS );

		/*| ----- KLUDGE : Attach graphic to be able to display component ----- */
		if( GraphicsId && GraphicsId->objid != NULL_OBJID )
		{
			status =
			om$send( msg      = message GRgraphics.GRaddwrng(&retmsg,md_env),
				 senderid = NULL_OBJID,
				 targetid = GraphicsId->objid,
				 targetos = GraphicsId->osnum );
			as$status ( );

			status =
			om$send( msg      = message ACncpx.ACchange_feet( 1, GraphicsId, md_env ),
		 	 	 senderid = NULL_OBJID,
		 	 	 targetid = ComponentId->objid,
		 	 	 targetos = ComponentId->osnum ) ;
			as$status ( );
		}

  		status = VRBuildTemp
			 ( &retmsg, ComponentId, 3*NbCpts, TempList, 3*(NbCpts-1),
		  	   IndexTable, md_env, &NbTemp );
  		as$status( action = RET_STATUS );

		status= om$send (
			msg = message VRConcComp.VRAddPlanes
				( &retmsg, 3*NbCpts, TempList, IndexTable, md_env ),
			targetid = ComponentId->objid,
			targetos = ComponentId->osnum,
			senderid = NULL_OBJID );
		as$status ( action = RET_STATUS );
		
	}/* end constrained component orientation definition */
	 /* ------------------------------------------------ */
	else
	{
		/* ----------------------- */
		/*| -- Simple component -- */
		/* ----------------------- */

		/*"NbSegments = %d\n", NbSegments */

	   if (NbSegments)
	   {

		for ( i = 0 ; i<VR_MAX_CPTS; i++ )
		{
			CompStr->Attr.Comp.nIndex[i] = -1;
		}

		/*| -- Initialize position on segments -- */
		VRCompPosOnTopo ( NbSegments, SegmentIds, dOrig,
				  CompStr->Attr.Comp.nIndex, 
				  md_env );

		/*| -- Get segment's axis -- */
		for ( i = 0 ; i<NbSegments; i++ )
		{
			/*"On Support %d Index = %d\n", i, CompStr->Attr.Comp.nIndex[i] */

			status= om$send (
				msg = message VRCnrlSeg.VRGetTopo
				(&retmsg, &dAxes[i*3], NULL, NULL, NULL, NULL, md_env),
				targetid = SegmentIds[i].objid,
				targetos = SegmentIds[i].osnum,
				senderid = NULL_OBJID );
			as$status ( action = RET_STATUS );

		}/* end loop on segments */

		VRSelectOrie ( 	NbSegments, dAxes,
				dXaxis, dYaxis, NULL,
				&nXIndex,
				&nYIndex,
				NULL,
				&dXOrie,
				&dYOrie,
				NULL);


		/* ----------------------------------------------- */
		/*| -- ERROR IF NEITHER X NOR Y HAS BEEN DEFINED -- */
		/* ----------------------------------------------- */

		if ( 	nXIndex == -1 && nYIndex == -1)
		{
                        End
			/*| NEITHER AXIS CAN BE DEFINED BY THE SEGMENTS */
			return OM_E_ABORT;
		}/* end topology does not match orientation */


		/* ----------------------------------------------------------- */
		/*| -- If one of the axes is not set, set the rotation angle -- */
		/* ----------------------------------------------------------- */

		if ( 	nXIndex == -1 && nYIndex != -1   )
		{
			/*| Compute angle for primary */
			status= om$send (
				msg = message VRCnrlSeg.VRGetTopo
			(&retmsg, NULL, NULL, &Plane, NULL, NULL, md_env),
			targetid = SegmentIds[nYIndex].objid,
			targetos = SegmentIds[nYIndex].osnum,
				senderid = NULL_OBJID );
			as$status ( action = RET_STATUS );

			/* compute rotation axis */
			BScrossp (&rc,  Plane.normal,
					dXaxis,
					dVect);

			dXOrie = dAngle;

		}/* end compute angle for primary */
		else if(nYIndex == -1 && nXIndex != -1  )
		{
			/*| Compute angle for secondary */

			status= om$send (
				msg = message VRCnrlSeg.VRGetTopo
				(&retmsg, NULL, NULL, &Plane, NULL, NULL, md_env),
				targetid = SegmentIds[nXIndex].objid,
				targetos = SegmentIds[nXIndex].osnum,
				senderid = NULL_OBJID );
			as$status ( action = RET_STATUS );

			/* compute rotation axis */
			BScrossp (&rc,  Plane.normal,
					dYaxis,
					dVect);

			dYOrie = dAngle;

		}/* end compute angle for secondary */

		/* -- Fill in structure -- */
		CompStr->Attr.Comp.Orientation.nPriIndex  = nXIndex;
		CompStr->Attr.Comp.Orientation.nSecIndex  = nYIndex;
		CompStr->Attr.Comp.Orientation.dPrimary   = dXOrie;
		CompStr->Attr.Comp.Orientation.dSecondary = dYOrie;


		/* KLUDGE : increment the Primary and Secondary index to take in account
			    the first templates ( attributes collections ) */
		if ( CompStr->Attr.Comp.Orientation.nPriIndex != -1 )
			CompStr->Attr.Comp.Orientation.nPriIndex += CompStr->nNbAttr;
		if ( CompStr->Attr.Comp.Orientation.nSecIndex != -1 )
			CompStr->Attr.Comp.Orientation.nSecIndex += CompStr->nNbAttr;

			/* DEBUG */

		/*^ printf ("\t Primary   : Num %d, Orie %f\n",
			CompStr->Attr.Comp.Orientation.nPriIndex,
			CompStr->Attr.Comp.Orientation.dPrimary);
		    printf ("\t Secondary : Num %d, Orie %f\n", 
			CompStr->Attr.Comp.Orientation.nSecIndex,
			CompStr->Attr.Comp.Orientation.dSecondary);
		    for (i=0; i<NbSegments; i++)
			printf ( " Cp %d on segment[%d]\n",
			CompStr->Attr.Comp.nIndex[i],i );
		*/

			/* END DEBUG */

	   }/* end topology specified (if (NbSegments) ) */
	   else
	   {

	   }/* end component placed in free space */

	}/* end Simple component orientation definition */

VR_PLACE_COMPONENT :

	/* -- Fill CompStr with missing info ( Temporary ) */

	CompStr->nNbTopo = NbSegments;

	/* -- Fill templates list -- */
	for (i=0; i<NbTemp; i++)	ParentsList[i]= TempList[i];
	for (i=0; i<NbSegments; i++) 	ParentsList[i+NbTemp]= SegmentIds[i];

	/* Give the graphics to the component */

/* WAIT FOR FULL ORIENTATION
	if (GraphicsId)
		CompStr->GraphicsId = *GraphicsId;
	else
 END WAIT FOR FULL ORIENTATION */

		CompStr->GraphicsId.objid = NULL_OBJID;


	/*| update assoc construction list */
	assoc_list.as_attr        = ( IGRchar * ) CompStr;
	assoc_list.num_parents    = NbTemp+NbSegments;
	assoc_list.go_objid.objid = NULL_OBJID;
	assoc_list.parents        = ParentsList;


/*
	printf (" Symbology passed : %d \n", (IGRint) p_CnstList);
	printf (" env_info         : %d \n", (IGRint) p_CnstList->env_info);
	printf (" display          : %d \n", (IGRint) p_CnstList->display);
	if (p_CnstList->env_info)
	{
	printf ("\t cst md_env.md_id : <%d, %d>\n", p_CnstList->env_info->md_id.objid,
						    p_CnstList->env_info->md_id.osnum );
	}
	else printf (" Module env not specified in cst \n");

	printf ("\t newflag	: %d\n", p_CnstList->newflag );
	printf ("\t level	: %d\n", p_CnstList->level );
	printf ("\t properties	: %d\n", p_CnstList->properties );
	if (p_CnstList->display)
	{
	printf ("\t color	: %d\n", p_CnstList->display->color );
	printf ("\t weight	: %d\n", p_CnstList->display->weight );
	printf ("\t style	: %d\n", p_CnstList->display->style );
	}
	else printf (" Display not specified \n");

*/
	/* -- Place the component with specified topology -- */

	/*"md_env = %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */
	status = om$send( msg	   = message VRGeneric.NDplace(
				&assoc_list, md_env, ( IGRchar * ) p_CnstList),
			  senderid = NULL_OBJID,
			  targetid = ComponentId->objid,
			  targetos = ComponentId->osnum ) ;
	as$status ( action = RET_STATUS );

/* WAIT FOR FULL ORIENTATION TO REMOVE THIS CODE */

	if( GraphicsId && GraphicsId->objid != NULL_OBJID )
	{
		struct GRmd_env HeadMdEnv;

		HeadMdEnv = *md_env;
		HeadMdEnv.md_id.objid = NULL_OBJID;

		/*" Delete graphics <%d, %d>\n",GraphicsId->objid,GraphicsId->osnum */

		om$send ( msg = message GRgraphics.GRdelete ( &retmsg, &HeadMdEnv ),
			targetid = GraphicsId->objid,
			targetos = GraphicsId->osnum,
			senderid = NULL_OBJID );


	}/* end delete previous graphics */
/* END WAIT FOR FULL ORIENTATION TO REMOVE THIS CODE */

	if (GraphicsId)	GraphicsId->objid = NULL_OBJID;

	{
        	IGRint		cn_type=ND_COMP;

		status =
		om$send( msg = message NDnode.NDs_compute_node ( &retmsg, cn_type, 
						         md_env ),
			senderid = NULL_OBJID,
			targetid = ComponentId->objid,
			targetos = ComponentId->osnum );
		as$status(action = RET_STATUS);
	}
	*msg = MSSUCC ;
        End
	return OM_S_SUCCESS ;

}/* end VRplaceComponent */

/* --------------------------------------------------------------------
/*
/* VRCompPosOnTopo computes, depending on the component's position, its
/*		   position ( 0 or 1 ) on each segment.
/*
/* -------------------------------------------------------------------- */

IGRint VRCompPosOnTopo ( NbSegments, SegmentIds, dOrig, nIndexList, md_env )

IGRint				NbSegments;	/* I Number of segments */
struct GRid			*SegmentIds;	/* I Segments' list */
IGRdouble			*dOrig;		/* I Position coordinates */
IGRshort			*nIndexList;	/* O Position on segments */
struct GRmd_env			*md_env;	/* */

/*.VRCompPosOnTopo*/
{
	IGRint		status,i;
	IGRlong		retmsg;
	IGRdouble	dLine[6], dVect[3];
	IGRdouble	BSlenvec();
	BSrc		rc;

        SetProc( Func_VRCompPosOnTopo ); Begin
		/*" Orig  : %f, %f, %f\n",dOrig[0], dOrig[1], dOrig[2] */


	for ( i=0; i<NbSegments; i++ )
	{
		/* ----------------------------------- */
		/*| -- check for position on segment -- */
		/* ----------------------------------- */
		status =om$send( msg      = message VRCnrlSeg.VRget_terminators
				( &retmsg, NULL, md_env, dLine, NULL ),
				senderid = NULL_OBJID,
				targetid = SegmentIds[i].objid,
				targetos = SegmentIds[i].osnum );
		as$status( action = RET_STATUS );

		/*" Segment[%d]\n",i */
		/*" Pt0  : %f, %f, %f\n",dLine[0], dLine[1], dLine[2] */
		/*" Pt1  : %f, %f, %f\n",dLine[3], dLine[4], dLine[5] */

                BSmkvec ( &rc, dVect, dLine, dOrig );
                if ( BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
                {
                        /*| End 0 of the segment */
                        nIndexList[i] = 0;
                }/* end position 0 */
                else
                {
                	BSmkvec ( &rc, dVect, &dLine[3], dOrig );
                        if ( BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
			{
                        	/*| End 1 of the segment */
                        	nIndexList[i] = 1;
			}
                }/* end position 1 */
	}/* end loop on segments */

        End
	return OM_S_SUCCESS;

}/* end VRCompPosOnTopo */

/* --------------------------------------------------------------------
/*
/* VRSelectOrie selects, among the given axes, wich one can be used 
/*		to build the specified X,Y and Z axes.
/*
/* -------------------------------------------------------------------- */


IGRint VRSelectOrie ( 	NbAxes, dAxes, dXaxis, dYaxis, dZaxis,
			nXIndex, nYIndex, nZIndex,
			dXOrie,  dYOrie,  dZOrie)

IGRint				NbAxes;		/* I Number of segments */
IGRdouble			*dAxes;		/* I Segments' list */
IGRdouble			*dXaxis;	/* I Orientation X */
IGRdouble			*dYaxis;	/* I Orientation Y */
IGRdouble			*dZaxis;	/* I Orientation Z */
IGRshort			*nXIndex;	/* O Axis used as X axis */
IGRshort			*nYIndex;	/* O Axis used as Y axis */
IGRshort			*nZIndex;	/* O Axis used as Z axis */
IGRdouble			*dXOrie;	/* O Orientation relative to segment */
IGRdouble			*dYOrie;	/* O Orientation relative to segment */
IGRdouble			*dZOrie;	/* O Orientation relative to segment */

/*.VRSelectOrie*/
{
	IGRint			i;
	IGRdouble		dVect[3];
	IGRdouble		BSlenvec(), BSdotp();
	BSrc			rc;
        SetProc( Func_VRSelectOrie ); Begin


	/* -- Initializes to Undefined the topology -- */
	if ( nXIndex ) *nXIndex = -1;
	if ( nYIndex ) *nYIndex = -1;
	if ( nZIndex ) *nZIndex = -1;

	/* -- look for segment that will be used as X and Y axis -- */

	for ( i=0; i<NbAxes; i++ )
	{

		/*" Axis[%d] : %f, %f, %f\n",i, dAxes[i*3], dAxes[i*3+1], dAxes[i*3+2] */

		/* ----------------- */
		/* -- X Axis test -- */
		/* ----------------- */

		if ( nXIndex && *nXIndex == -1 )
		{
			/*| Check for X axis */

			BScrossp( &rc, &dAxes[i*3], dXaxis, dVect);

			if ( 	BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
			{
				/*| X axis found */

				*nXIndex = i;

				/* set orientation */
				if ( dXOrie )
				{
					*dXOrie = BSdotp ( &rc, &dAxes[i*3], dXaxis );
					continue;

				}/* end compute orientation */

			}/* end set X axis */

		}/* end check against X */

		/* ----------------- */
		/* -- Y Axis test -- */
		/* ----------------- */

		if ( nYIndex && *nYIndex == -1 )
		{
			/*| Check for Y axis */

			BScrossp( &rc, &dAxes[i*3], dYaxis, dVect);
			if ( BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
			{
				/*| Y axis found */

				*nYIndex = i;

				/* set orientation */
				if ( dYOrie )
				{
					*dYOrie = BSdotp ( &rc, &dAxes[i*3], dYaxis );
					continue;
				}/* end compute orientation */

			}/* end set Y axis */

		}/* end check against Y */

		/* ----------------- */
		/* -- Z Axis test -- */
		/* ----------------- */

		if ( nZIndex && *nZIndex == -1 )
		{
			/*| Check for Z axis */

			BScrossp( &rc, &dAxes[i*3], dZaxis, dVect);
			if ( BSlenvec ( &rc, dVect ) < VRGetTol(VR_LENGTH_TOL) )
			{
				/*| Z axis found */

				*nZIndex = i;

				/* set orientation */
				if ( dZOrie )
				{
					*dZOrie = BSdotp ( &rc, &dAxes[i*3], dZaxis );
					continue;
				}/* end compute orientation */

			}/* end set Z axis */

		}/* end check against Z */

	}/* end loop on axes */

End
return OM_S_SUCCESS;

}/* end VRSelectOrie */

end implementation Root;

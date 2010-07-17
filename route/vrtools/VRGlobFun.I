/* $Id: VRGlobFun.I,v 1.4 2002/04/10 20:44:47 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRGlobFun.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGlobFun.I,v $
 *	Revision 1.4  2002/04/10 20:44:47  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:51  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:21  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:32:10  pinnacle
# Created: route/vrtools/VRGlobFun.I by lawaddel for Service Pack
#
# Revision 1.3  2000/03/15  19:01:36  pinnacle
# Replaced: vrtools/VRGlobFun.I for:  by apazhani for route
#
# Revision 1.2  1999/05/04  13:40:00  pinnacle
# Replaced: vrtools/VRGlobFun.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/04/15  22:11:16  pinnacle
# Replaced: vrtools/VRGlobFun.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/18  23:07:54  pinnacle
# Replaced: vrtools/VRGlobFun.I for:  by r240_int for route240
#
# Revision 1.2  1996/01/18  00:31:06  pinnacle
# Replaced: vrtools/VRGlobFun.I for:  by r240_int for route240
#
 *
 * History:
 *	11/08/91   B Demars	Creation: Route release 1.4.3.7
 *	11/20/92   momo		Added functions: release 1.4.3.25
 *	27 Sep 94  Manyam	2.3.1.18
 *					Added Function VRIsShXtionValid()
 *	22 Jun 92  Manyam	2.3.1.0
 *					New Functions VRIsEccentricComp() and
 *					VRIsCenterJustified()
 *	22-OCT-92		2.1.0.16
 *	16-DEC-91  Bruno	1.4.3.15	
 *					New function VRMakeSource added for 
 *					inter_OS connections functionality.
 *	30-DEC-91  Bruno	Route release 1.4.3.17
 *					New function VRGetMatrix.
 *	-91        Bruno 	Math functions
 *					IGRdouble  VRcompute_angle()
 *					IGRboolean bVRTestVect()
 *	2-01-1992  Momo		New Fucntion to set GenInfo structure to 
 *					place new component VRSetInsInfo()
 *	05-02-1991 Momo 	New Function to get attributes from 
 *					component. VRGetAttr()
 *      * -1991    Phil 	Function to init and get segment symbology
 *	01/17/96   tlb		Add prototypes
 *	01/18/96   tlb		Cast 2nd arg to BScoincdpts
 *				Change bVRTestVect to ANSII style
 *      05/04/99    Reddy       Doble value comparision corrected
 *      03/15/00    Alwin       Added function VRGetCorrectionFromLineSeg
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation Root;


#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ex.h"
#include "exmacros.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "bstypes.h"
#include "bserr.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "msdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "VRcsdef.h" 
#include "VRparamdef.h"
#include "VRattr_def.h"
#include "VRpriv_attr.h"
#include "VRact_params.h"
#include "AS_status.h"
#include "vrtools_pto.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bscoincdpts.h"
#include "vrdbgmacros.h"

#define AS_DEBUG

from 	GRowner		import	GRget_matrix;
from 	NDmacro		import	ACgive_structure;
from 	NDnode		import 	NDcopy, 
							ASreturn_go, 
							NDget_objects,
							NDdisplay, 
							NDs_compute_node;
from 	VRGeneric	import 	NDplace, 
							VRGetParams, 
							VRGetNextOnCpt, 
							VRGetCptProp,
							VRGetMatrix, 
							VRGetCptGeom, 
							VRGetSysType,
							VRGetCorrections;
from	VRCptIn		import	VRGetCptNum;

from 	VRCnrlSeg	import	VRGetTopo, 
							VRget_terminators, 
							VRsplit_segment,
							VRChgSegState,
							VRGetComponents;
from	NDnodein	import	NDchange_connect;
from	VRCorrection	import	VRSplit;

extern 	GRclassid	OPP_VRCptIn_class_id;

/*-------------------------------------------------------------------*/
/*	function VRMakeSource
/*
/* 
/* Given a component object, it returns an object to which a network
/* can get connect if the specified connect point is free.
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRlong	VRMakeSource ( msg, p_ComponentId, nCpNum, p_CompMdEnv, p_MdEnv, p_ConnectorId)
IGRlong		*msg;
struct GRid	*p_ComponentId;
IGRshort	nCpNum;
struct GRmd_env	*p_CompMdEnv;
struct GRmd_env	*p_MdEnv;
struct GRid	*p_ConnectorId;
/*.VRMakeSource*/
{
	struct GRid		PretendInId;
	IGRshort		nType;
	IGRint			status;
	IGRlong			retmsg;
	struct	GRas		assoc_list;
	struct	VRGenInfo	CmpStr;        /* component info              */
	struct	IGRdisplay	ActiveDisplay; /* Active Display              */
	struct	GRvg_construct  CnstList;

        SetProc( Func_VRMakeSource ); Begin
*msg = MSSUCC;

	/* -- Check whether the connect point is free or not -- */

	status =om$send (
		msg      = message VRGeneric.VRGetNextOnCpt
			(&retmsg, nCpNum, NULL, NULL, 0, NULL, NULL, NULL, p_MdEnv),
		senderid = NULL_OBJID,
		targetid = p_ComponentId->objid,
		targetos = p_ComponentId->osnum );
	as$status( action = RET_STATUS );

	/* -- if connect point already connected -- */
	if ( retmsg == MSSUCC )
	{
		/* -- KLUDGE for Dangles accross ref files -- */

		status =om$send (
			msg      = message VRGeneric.VRGetSysType
				(&retmsg, &nType),
			senderid = NULL_OBJID,
			targetid = p_ComponentId->objid,
			targetos = p_ComponentId->osnum );
		as$status( action = RET_STATUS );

		if ( 	nType != VR_DANGLING ||
			p_ComponentId->osnum == p_MdEnv->md_id.osnum )
		{
			/*" Connect point %d already connected\n",nCpNum */
			*msg = MSFAIL;
                        End
			return OM_S_SUCCESS;
		}
	}

	/* -- Check whether this component is in another OS --  */

	if ( p_ComponentId->osnum == p_MdEnv->md_id.osnum )
	{
		/*| Component in the right Object Space */
		*p_ConnectorId = *p_ComponentId;
                End
		return OM_S_SUCCESS;

	}/* end same object space */


	/* -------------------------------------- */
	/* -- Component is in a reference file -- */
	/* -------------------------------------- */


	/*" Connection requested : OS %d -> OS %d\n", p_CompMdEnv->md_id.osnum, p_MdEnv->md_id.osnum */

	/* -- Place an Assoc inter_OS connection object -- */

	/*| Call ASmake_source */
	status = as$make_source ( go_grid = *p_ComponentId,
				  mod_env = p_CompMdEnv,
				  as_os   = p_MdEnv->md_id.osnum,
				  as_grid = &PretendInId);
	as$status ( action = RET_STATUS );
	/*" Pretendin id = <%d,%d>\n",PretendInId.objid,PretendInId.osnum */

	/* -- Check on the existence of a VRCptIn -- */
	{
		register IGRint	i;
		IGRint		NbChild;
		GRclassid	ClassId;
		struct GRid	*buffer;

		/* -- Get children of the pretendin -- */
		status =
		om$send( msg      = message NDnode.NDget_objects
			( ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer,
			  0, OM_K_MAXINT, &NbChild ),
			senderid = NULL_OBJID,
  			targetid = PretendInId.objid,
  			targetos = PretendInId.osnum );
		as$status( action = RET_STATUS );
		for( i=0; i<NbChild; i++ )
		{
			/*"buffer[%d] = %d %d\n", i, buffer[i].objid, buffer[i].osnum */

			status =
			om$get_classid( osnum     = buffer[i].osnum,
					objid     = buffer[i].objid,
 					p_classid = &ClassId );
			as$status();

			if( om$is_ancestry_valid (
				subclassid   = ClassId,
        			superclassid = OPP_VRCptIn_class_id ) == OM_S_SUCCESS )
			{
				IGRshort nTmpCpNum;

				/* Get the Cpt it is assigned to */
				status =
				om$send( msg      = message VRCptIn.VRGetCptNum
					(&nTmpCpNum),
					senderid = NULL_OBJID,
		  			targetid = buffer[i].objid,
		  			targetos = buffer[i].osnum );
				as$status( action = RET_STATUS );

				if ( nTmpCpNum == nCpNum)
				{
					/*|CONNECTION ALREADY EXISTING */
					*p_ConnectorId = buffer[i];
                                        End
					return OM_S_SUCCESS;
				}/* end same cpt treatment */
      			}

		}/* end loop on pretend's children */

	}/* end find existing VRCptIn */

	/* -- Place an I/ROUTE connection object as a child of the Assoc object -- */

	p_ConnectorId->osnum = p_MdEnv->md_id.osnum;
	status =
	om$construct( 	classid = OPP_VRCptIn_class_id,
			p_objid = &p_ConnectorId->objid,
			osnum   = p_ConnectorId->osnum );
	as$status( action = RET_STATUS ); 

	/*| Initialize Route placement arguments (Dummy)*/

	/* not used yet */
	CmpStr.nStatus     	= 0;
	CmpStr.szAABBCC[0]	= 0;
	CmpStr.GraphicsId.objid	= NULL_OBJID;
	CmpStr.nOption    	= 1;
	CmpStr.szNumber[0]	= '\0';
	CmpStr.szNotes[0]	= '\0';
	CmpStr.cNoMtoFlg 	= ' ';
	CmpStr.nNbAttr   	= 0;
	CmpStr.nNbTopo   	= 0;
	CmpStr.cRep 		= 0;

	/* only two used */
	CmpStr.nJustif   	   = nCpNum;
	CmpStr.Attr.Comp.nIndex[0] = -1;

	/*| Initialize associative placement arguments */
	assoc_list.as_attr        = ( IGRchar * ) &CmpStr;
	assoc_list.num_parents    = 1;			/* only the pretendin */
	assoc_list.go_objid.objid = NULL_OBJID;
	assoc_list.parents        = &PretendInId;

	/*| Initialize graphics placement arguments */
	status = VRGetConstructionList
		( &retmsg, p_MdEnv, NULL, NULL, &ActiveDisplay, NULL, &CnstList);
	as$status( action = RET_STATUS );

	/*| Place VRCptIn object */
	status =om$send (
		msg      = message VRGeneric.NDplace
				(&assoc_list, p_MdEnv, 
				 ( IGRchar * ) &CnstList ),
		senderid = NULL_OBJID,
		targetid = p_ConnectorId->objid,
		targetos = p_ConnectorId->osnum );
	as$status( action = RET_STATUS );

        End
	return OM_S_SUCCESS;

}/* end VRMakeSource */


/*-------------------------------------------------------------------*/
/*	function VRGetPath
/*
/* USE THE VR$GetUnixPath macro INSTEAD OF CALLING THIS FUNCTION.
/*
/* Returns the Unix path to the product in which the specified file is
/* found. 
/* This function returns 	MSSUCC if specified file has been found,
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint	VRGetPath ( msg, szProductName, szFileInProduct, szProductPath, ProductPathLen )
IGRlong		*msg;			/* O	completion code */
IGRchar		*szProductName;		/* I	if specified, the file's existance
						will be check in this product dir,
						else the file will be looked for in
						the running product and the products
						it is depending on */
IGRchar		*szFileInProduct;	/* I	file path relative to Product */
IGRchar		*szProductPath;		/* O	if specified, returns the
						path to the Product directory */
IGRint		ProductPathLen;		/* I	size of the szProductPath
						buffer */

/*.VRGetPath*/
{
IGRint	k=0;
IGRchar szFullPath [256];
FILE *fp;

/* */
/* argument test */
/* */

if ( 	( !szFileInProduct && !szProductName )
	|| 
	!szProductPath
	||
	!ProductPathLen ) return OM_E_INVARG;

//
//    If productname specified, get this product's path
//


if ( szProductName )
{
  //
  // If product loaded on station (we get its directory).
  //

  if ( get_modtype_data(szProductName,NULL,NULL,NULL,NULL,szProductPath) )
  {
	//
	// If file specified, try to open it into the product directory
	//
	if ( szFileInProduct )
	{
		/*" Try to find %s in product : %s\n",szFileInProduct,szProductPath */

		/*"\t Trying in specified directory : %s\n",szProductPath */
		strcpy (szFullPath, szProductPath );
		strcat (szFullPath, szFileInProduct );

		fp = (FILE *) fopen ( szFullPath , "r");

		if ( fp )
		{
			/*|\t\t File Found */
			fclose (fp);
			*msg = MSSUCC;
			return OM_S_SUCCESS;
		}
	}
	else
	{
		/* Only product path is required */
		*msg = MSSUCC;
		return OM_S_SUCCESS;
		
	}
  }/* end looking in the specified product's directory */

}/* end product is specified */
else
{
	/* ---------------------------------------------- */
	/* -- Try in all running products' directories -- */
	/* ---------------------------------------------- */

	while(  ex$get_path( index=k++, path=szProductPath,len=ProductPathLen )	)
	{
		/*"\t %d - Trying in : %s\n",k,szProductPath */
		strcpy (szFullPath, szProductPath );
		strcat (szFullPath, szFileInProduct );

		fp = (FILE *) fopen ( szFullPath , "r");

		if ( fp )
		{
			/*|\t\t File Found */
			fclose (fp);
			*msg = MSSUCC;
			return OM_S_SUCCESS;
		}
	}

}/* end loop on products directories */

*msg = MSFAIL;
return OM_E_ABORT;

}/* end VRGetPath */


/*-------------------------------------------------------------------*/
/*	function VRGetCmpMatrix
/*
/* 
/* Given a geometry 
/*		3D point			--> Active CS
/*		Segment & End point		--> Orie on seg.
/*		Component & [Connect point]	--> Orie of comp
/*						    or Orie at Cpt.
/* this function returns a coordinate system's matrix.
/* 
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint VRGetCmpMatrix ( msg, dPoint, SegmentId, nSegEnd, ComponentId, nCompCpt,
			dMatrix, md_env )
			       
IGRlong 		*msg ;		/* O : Return code, MSSUCC or MSFAIL.   */
IGRdouble		*dPoint;	/* I : 3D point coordinates.		*/

struct GRid		*SegmentId ; 	/* I : Segment's Id.			*/
IGRshort		nSegEnd; 	/* I : Segment's end point (0 or 1).	*/

struct GRid		*ComponentId ; 	/* I : Component's Id.			*/
IGRshort		nCompCpt; 	/* I : Component's Cpt num		*/

IGRdouble		*dMatrix;	/* O : Default Orientation and position matrix. */
struct GRmd_env 	*md_env;

/*.VRGetMatrix */
{
	IGRint		status,i;
	IGRlong		retmsg;
	BSrc		rc;

	/* -- Initializes homogeneous matrix -- */

        SetProc( Func_VRGetCmpMatrix ); Begin
	dMatrix[12] = dMatrix[13] = dMatrix[14] = 0;
	dMatrix[15] = 1;

*msg = MSSUCC;

		/* -------------- */
		/* -- 3D Point -- */
		/* -------------- */

	if (dPoint)
	{
		/*| Get active CS matrix */
		printf ( " KLUDGE : NOT YET IMPLEMENTED \n");
	}/* end dPoint specified */

		/* ------------- */
		/* -- Segment -- */
		/* ------------- */

	else if (SegmentId)
	{
		struct IGRplane	Ortho;
		IGRdouble	dLine[6], dNormal[3], dPoint[3];

		Ortho.point 	= dPoint;
		Ortho.normal 	= dNormal;
                __DBGpr_obj("Segment Id",*SegmentId);
		/*| Get matrix from segment's end point */

		/* -- Get segment's end coordinates	=> Origine -- */

		status= om$send (
			msg = message VRCnrlSeg.VRget_terminators
				( &retmsg, NULL, md_env, dLine, NULL ),
			targetid = SegmentId->objid,
			targetos = SegmentId->osnum,
			senderid = NULL_OBJID );
		as$status ( action = RET_STATUS );

		dMatrix[3]  = dLine[3*nSegEnd];
		dMatrix[7]  = dLine[3*nSegEnd + 1 ];
		dMatrix[11] = dLine[3*nSegEnd + 2 ];

		/* -- Get segment's vector		=> X axis -- */
		/* -- Get segment's orthogonal plane 	=> Y axis -- */

		status= om$send (
			msg = message VRCnrlSeg.VRGetTopo
				(&retmsg, dLine, NULL, &Ortho,
				NULL, NULL, md_env),
			targetid = SegmentId->objid,
			targetos = SegmentId->osnum,
			senderid = NULL_OBJID );
		as$status ( action = RET_STATUS );

		if ( !nSegEnd )
		{
                    __DBGpr_com("Reversing X axis for cpt0 on seg");
			/* end point 0 => reverse axis */
			dLine[0] *= -1;
			dLine[1] *= -1;
			dLine[2] *= -1;
                    __DBGpr_vec("X vector",dLine);
		}/* end reverse X axis */

		/* -- Compute Z axis -- */

		BScrossp( &rc, dLine, Ortho.normal, &dLine[3]);
		if ( rc != BSSUCC )
                {
                   End
                   return OM_E_ABORT;
                }

		/* -- Fill matrix -- */
		for (i=0; i<3; i++ )
		{
			dMatrix [i*4     ] = dLine[i];		/* X axis */
			dMatrix [i*4 + 1 ] = Ortho.normal[i];	/* Y axis */
			dMatrix [i*4 + 2 ] = dLine[i + 3];	/* Z axis */
		}/* end fill matrix */
                 __DBGpr_mat("MODIFIED ORIENT",dMatrix);
	}/* end Segment specified */

		/* --------------- */
		/* -- Component -- */
		/* --------------- */

	else if (ComponentId)
	{

		GRclassid	CmpClassId;
		IGRboolean	bDumbGraphics;

		/*| Get matrix from component */
                __DBGpr_com(" No segment-use matrix on component");
		/* -- Get component class (dumb graphics or component) -- */

		om$get_classid( osnum     = ComponentId->osnum,
				objid     = ComponentId->objid,
				p_classid = &CmpClassId );

		bDumbGraphics = ( om$is_ancestry_valid( subclassid = CmpClassId,
				  superclassid = OPP_VRGeneric_class_id ) != OM_S_SUCCESS );

		if ( nCompCpt != VR_CENTER_JUST )
		{

			IGRdouble	dCoors[3], dConAxis[3], dOrientation[3], dZaxis[3];

			/*" Build matrix at connect point %d\n", nCompCpt */
			
			if (bDumbGraphics)
			{
				IGRchar 		footname[20];
				IGRint			Index=-1;
				struct ret_struct	AttrSt;


				/* -- Get coordinates foot -- */

				VRCptEncode (nCompCpt, footname, ":graphic");
				status = 
				om$send ( msg = message NDmacro.ACgive_structure 
						( (IGRint *) &retmsg, &Index,
						 footname, &AttrSt, md_env ),
					senderid = NULL_OBJID,
					targetid = ComponentId->objid,
					targetos = ComponentId->osnum );
				as$status ( action = RET_STATUS );

				for (i=0;i<3;i++)
					dCoors [i] = AttrSt.var.point_st.pt[i];

				/* -- Get X axis foot -- */

				VRCptEncode (nCompCpt, footname, ":axis");
				status = 
				om$send ( msg = message NDmacro.ACgive_structure 
						( (IGRint *) &retmsg, &Index,
						 footname, &AttrSt, md_env ),
					senderid = NULL_OBJID,
					targetid = ComponentId->objid,
					targetos = ComponentId->osnum );
				as$status ( action = RET_STATUS );

				for (i=0;i<3;i++)
					dConAxis [i] = AttrSt.var.point_st.pt[i];

				/* -- Get Y axis foot -- */

				VRCptEncode (nCompCpt, footname, ":yaxis");
				status = 
				om$send ( msg = message NDmacro.ACgive_structure 
						( (IGRint *) &retmsg, &Index,
						 footname, &AttrSt, md_env ),
					senderid = NULL_OBJID,
					targetid = ComponentId->objid,
					targetos = ComponentId->osnum );
				as$status ( action = RET_STATUS );

				for (i=0;i<3;i++)
					dOrientation [i] = AttrSt.var.point_st.pt[i];

			}/* end get from dumb graphics */
			else
			{
				status =om$send(
					msg = message VRGeneric.VRGetCptGeom
						( msg, nCompCpt,
						dCoors, dConAxis, dOrientation, md_env),
					senderid = NULL_OBJID,
					targetid = ComponentId->objid,
					targetos = ComponentId->osnum);
				as$status( action = RET_STATUS );

			}/* end get from component */
                        __DBGpr_vec("Xvec direct from VRGetCptGeom",dConAxis);
                        __DBGpr_vec("Yvec direct from VRGetCptGeom",dOrientation);

			/* -- Compute Z axis -- */

                        __DBGpr_com("NO REVERSAL of X or Z");
			BScrossp( &rc, dConAxis, dOrientation, dZaxis);
                        __DBGpr_vec("Zvec computed from X Y",dZaxis);
			if ( rc != BSSUCC )
                        {
                           End
                           return OM_E_ABORT;
                        }
                        __DBGpr_com("Building matrix at cpt0\n");

			/* -- Fill matrix -- */
			for (i=0; i<3; i++ )
			{
				dMatrix [i*4     ] = dConAxis[i];	/* X axis */
				dMatrix [i*4 + 1 ] = dOrientation[i];	/* Y axis */
				dMatrix [i*4 + 2 ] = dZaxis[i];		/* Z axis */
				dMatrix [i*4 + 3 ] = dCoors[i];		/* Origine */
			}/* end fill matrix */

		}/* end build matrix at cpt */
		else
		{
			IGRshort	nTmpType;

			/*| Return component's matrix */

			if (bDumbGraphics)
			{

				status = om$send(
					 msg = message GRowner.GRget_matrix ( msg,
					        &md_env->md_env.matrix_type,
					        md_env->md_env.matrix,
					        &nTmpType,
					        dMatrix ),
					 senderid  = NULL_OBJID,
					 targetid =  ComponentId->objid,
					 targetos =  ComponentId->osnum);
				as$status( action = RET_STATUS);

			}/* end get from dumb graphics */
			else
			{
__DBGpr_com("Calling VRGeneric.VRGetMatrix with senderid as NULL_OBJID");
__DBGpr_obj("ComponentId",*ComponentId);
				status =om$send(
					msg = message VRGeneric.VRGetMatrix
						( msg, 0, NULL, dMatrix, md_env),
					senderid = NULL_OBJID,
					targetid = ComponentId->objid,
					targetos = ComponentId->osnum);
				as$status( action = RET_STATUS );

			}/* end get form component */

		}/* end return component's matrix */

	}/* end Component specified */

	/*^
		{
			IGRint i, j, k;

			for( i=0; i<4; i++ )
			{
				for( j=0; j<4; j++ )
				{
					k = 4*i+j;
					printf("dMatrix[%d] = %2f ", k, dMatrix[k] );
				}
				printf("\n");
			}
		}
	*/

End
return OM_S_SUCCESS;

}/* end VRGetMatrix */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRSetCompInstanceInfo
	( p_msg, nStatus, szAABBCC, nOption, szNumber, szNotes, cNoMtoFlg, nNbAttr, nNbTopo,
	  nJustif, cRep, MdEnvOsnum, p_CmpGenInfoStr
  	)

IGRlong				*p_msg;           /* return code		  	*/
IGRshort			nStatus;	  /* component status 			*/
IGRchar 			*szAABBCC;	  /* component code 			*/
IGRshort 			nOption; 	  /* component option code 		*/
IGRchar 			*szNumber; 	  /* component number 			*/
IGRchar				*szNotes;	  /* component notes 			*/
IGRchar				cNoMtoFlg;	  /* no MTO flag 			*/
IGRshort 			nNbAttr;	  /* number of attribute templates 	*/
IGRshort 			nNbTopo; 	  /* number of topologic templates 	*/
IGRshort 			nJustif;	  /* placement connect point number 	*/
IGRchar 			cRep;		  /* vds representation 		*/
GRspacenum			MdEnvOsnum;	  /* module info osnum needed to get 	*/
  					  	  /* from VDS representation		*/
struct		VRGenInfo	*p_CmpGenInfoStr; /* Component generic info structure  	*/

/*.VRSetCompInstanceInfo */
{
  IGRlong			retcode=MSSUCC;
  struct 	GRid 		vdssymb_id;
  struct	VDSsymb		vdssymb;

  SetProc( Func_VRSetCompInstanceInfo ); Begin  
  *p_msg  = MSSUCC;

  p_CmpGenInfoStr->nStatus   = nStatus;
  p_CmpGenInfoStr->nOption   = nOption;
  p_CmpGenInfoStr->cNoMtoFlg = cNoMtoFlg;
  p_CmpGenInfoStr->nJustif   = nJustif;
  p_CmpGenInfoStr->nNbAttr   = nNbAttr;
  p_CmpGenInfoStr->nNbTopo   = nNbTopo;

  /*"status   = %d\n", p_CmpGenInfoStr->nStatus   */
  /*"option   = %d\n", p_CmpGenInfoStr->nOption   */
  /*"NoMtoFlg = %c\n", p_CmpGenInfoStr->cNoMtoFlg */
  /*"justif   = %d\n", p_CmpGenInfoStr->nJustif   */
  /*"nbattr   = %d\n", p_CmpGenInfoStr->nNbAttr   */
  /*"nbtopo   = %d\n", p_CmpGenInfoStr->nNbTopo   */

  if( szNumber ) strcpy( p_CmpGenInfoStr->szNumber, szNumber );
  else		 p_CmpGenInfoStr->szNumber[0] = '\0';
  
  /*"szNumber = %s\n", p_CmpGenInfoStr->szNumber */

  if( szNotes ) strcpy( p_CmpGenInfoStr->szNotes , szNotes  );
  else		p_CmpGenInfoStr->szNotes[0] = '\0';

  /*"szNotes = %s\n", p_CmpGenInfoStr->szNotes */

  if( szAABBCC ) strcpy( p_CmpGenInfoStr->szAABBCC, szAABBCC );
  else		 p_CmpGenInfoStr->szAABBCC[0] = '\0';

  /*"szAABBCC = %s\n", p_CmpGenInfoStr->szAABBCC */

  if( cRep == ' ' )
  {
    	/*| get the representation */
    	vdssymb_id.osnum = MdEnvOsnum;
    	vd$symbology(	msg	= &retcode,
  	      	  	symb_id	= &vdssymb_id,
	          	symb	= &vdssymb   );
    	as$status( sts = retcode, action = RET_STATUS );

    	p_CmpGenInfoStr->cRep = vdssymb.representation;
  }
  else p_CmpGenInfoStr->cRep = cRep;

  /*"rep = %c\n", p_CmpGenInfoStr->cRep */

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 util function used to get active attributs or attributs from a given component.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRGetAttributes( p_retmsg, Product, CloneFlag, p_CmpId, CmpCptNum, p_SysParamId, p_UserParamId,
		 p_MissParamId, p_MdEnv )

IGRlong			*p_retmsg;	/* return code				  	    */
IGRshort		Product;	/* the product				  	    */
IGRboolean		CloneFlag;	/* if TRUE we return a copy of the result 	    */
struct	GRid		*p_CmpId;	/* given component			  	    */
IGRshort		CmpCptNum;	/* dimension attributes can be overridden by values */
					/* of a given Cpt.				    */
struct	GRid		*p_SysParamId;  /* OutPut, system collection grid		    */
struct	GRid		*p_UserParamId; /* OutPut, user collection grid			    */
struct	GRid		*p_MissParamId; /* OutPut, missing collection grid		    */
struct	GRmd_env	*p_MdEnv;	/* module info					    */

/*.VRGetAttributes */
{
  IGRboolean			OverrideValue=FALSE;
  GRclassid			CmpClassId;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  union		VRparam_attr	CptParam;
  struct	GRid		RetCmpId, TmpObjectId;
  struct 	VRcp_attr 	ConProp;
  struct	GRmd_env	RetCmpMdEnv;

  SetProc( Func_VRGetAttributes ); Begin
  *p_retmsg    = MSSUCC;

  if( !p_SysParamId && !p_UserParamId && !p_MissParamId )
  {
     End
     return OM_E_INVARG;
  }
  
  if( p_CmpId )
  {
   	/*"CmpId = %d %d\n", p_CmpId->objid, p_CmpId->osnum */

	om$get_classid( osnum     = p_CmpId->osnum,
			objid     = p_CmpId->objid,
			p_classid = &CmpClassId );

	if( om$is_ancestry_valid( subclassid = CmpClassId,
				  superclassid = OPP_VRCptIn_class_id ) == OM_S_SUCCESS )
	{
		/*| Given component is a VRCptIn */

    		status = om$send( msg      = message NDnode.ASreturn_go
                               			( &RetCmpId, &RetCmpMdEnv.md_env.matrix_type,
					  	  RetCmpMdEnv.md_env.matrix
        					),
          	          	  senderid = NULL_OBJID,
	                          targetid = p_CmpId->objid,
	                          targetos = p_CmpId->osnum );
     		as$status( action = RET_STATUS );
      		as$status( sts = retcode, action = RET_STATUS );

   		/*"RetCmpId = %d %d\n", RetCmpId.objid, RetCmpId.osnum */
	}
	else RetCmpId = *p_CmpId;

  	/* get module objid */

  	RetCmpMdEnv.md_id.osnum = RetCmpId.osnum;
	status = ex$get_modid( mod_osnum  = RetCmpMdEnv.md_id.osnum,
                               mod_id     = &RetCmpMdEnv.md_id.objid );
  	as$status( action = RET_STATUS );

  	/*"RetMdEnv = %d %d\n", RetCmpMdEnv.md_id.objid, RetCmpMdEnv.md_id.osnum */

      	status = om$send( msg      = message VRGeneric.VRGetParams
                    			( &retcode, p_SysParamId, p_UserParamId, p_MissParamId ),
           	          senderid = NULL_OBJID,
                          targetid = RetCmpId.objid,
                          targetos = RetCmpId.osnum );
      	as$status( action = RET_STATUS );
      	as$status( sts = retcode, action = RET_STATUS );

	if( CmpCptNum != -1 )
	{
 		status = om$send( msg      = message VRGeneric.VRGetCptProp
                               		     ( &retcode, CmpCptNum, &ConProp, &RetCmpMdEnv ),
				  senderid = NULL_OBJID,
                     	          targetid = RetCmpId.objid,
                     		  targetos = RetCmpId.osnum );
   		as$status( action = RET_STATUS );

		if( retcode == MSSUCC )
		{
			OverrideValue = TRUE;
 		
			if( Product == VR_PIPING )
			{
				CptParam.piping_attr.G_diameter = ConProp.width;
				CptParam.piping_attr.R_diameter = ConProp.width;
			}
			else
			{
				CptParam.hvac_attr.G_width = ConProp.width;
				CptParam.hvac_attr.R_width = ConProp.width;
				CptParam.hvac_attr.G_depth = ConProp.depth;
				CptParam.hvac_attr.R_depth = ConProp.depth;
				CptParam.hvac_attr.shape   = ConProp.section_mask & VR_SHAPE;
			}
		}
	}
  }
  else
  {
      	if( p_SysParamId )
      	{
        	p_SysParamId->osnum = p_MdEnv->md_id.osnum;
        	VR$active_params( 	VRproduct    = Product,
                  			act_param_id = p_SysParamId,
	   	          		status       = retcode
				);
   	}

      	if( p_UserParamId )
      	{
        	p_UserParamId->osnum = p_MdEnv->md_id.osnum;
        	VR$active_params( 	VRproduct    = Product,
                        		mode         = VR_USER_MODE,
         	          		act_param_id = p_UserParamId,
	    	          		status       = retcode
				);
      	}

	if( p_MissParamId )
	{
		as$status( sts = OM_E_ABORT, msg = "p_MissParamsId is a bad argument" );
	}
		
  }

  if( CloneFlag || ( p_SysParamId &&  CmpCptNum != -1 ) )
  {
  	if( p_SysParamId )
  	{
		/*| Return a copy of the Sys collection */

		status = om$send( msg      = message NDnode.NDcopy
       					( &retcode, 0, &RetCmpMdEnv, p_MdEnv, &TmpObjectId ),
        	  	  senderid = NULL_OBJID,
    		  	  targetid = p_SysParamId->objid,
	    	  	  targetos = p_SysParamId->osnum );
     		as$status();

		*p_SysParamId = TmpObjectId;

  		if( CmpCptNum != -1 && OverrideValue )
		{
			/*| if CmpCptNum is specified we must update the collection */
			VRModifyParameterBox
			( &retcode, Product, &CptParam, p_SysParamId, p_SysParamId );
		}
	}

        if( p_UserParamId )
    	{
		/*| Return a copy of the Usr collection */

      		status = om$send( msg      = message NDnode.NDcopy
    	  	      	   	     	( &retcode, 0, &RetCmpMdEnv, p_MdEnv, &TmpObjectId ),
           	        	  senderid = NULL_OBJID,
	    		  	  targetid = p_UserParamId->objid,
		    	  	  targetos = p_UserParamId->osnum );
      		as$status();

		*p_UserParamId = TmpObjectId;
    	}

      	if( p_MissParamId )
      	{
		/*| Return a copy of the Mis collection */

      		status = om$send( msg      = message NDnode.NDcopy
    	  	       	   	     	( &retcode, 0, &RetCmpMdEnv, p_MdEnv, &TmpObjectId ),
           	        	  senderid = NULL_OBJID,
	    		  	  targetid = p_MissParamId->objid,
		    	  	  targetos = p_MissParamId->osnum );
      		as$status();

		*p_MissParamId = TmpObjectId;
    	}
  }

  End
  return OM_S_SUCCESS;

}

/***********************************************************************/

IGRdouble VRcompute_angle(v1, v2, vz)
	IGRdouble	*v1;
	IGRdouble	*v2;
	IGRdouble 	*vz;

{
IGRlong		retmsg;
IGRdouble	cosinus,sinus,angle,kz;
IGRdouble	normal[3];
extern	IGRdouble	modulo();

/* -- compute angle's ( cosinus * length ) -- */
cosinus = BSdotp ( &retmsg, v1, v2 );

/* -- compute angle's ( sinus * length ) -- */
BScrossp ( &retmsg, v1, v2, normal);

sinus = BSlenvec ( &retmsg, normal );

/* -- compute angle -- */
angle = atan2(sinus,cosinus);

if ( vz )
{
	/* angle or PI - angle depending upon vz value */

	kz = BSdotp ( &retmsg, normal, vz );

	/* -- if kz < 0 => take the complementary angle -- */
	if (kz < 0) angle = 2*M_PI - angle;
}

modulo( &angle, 2*M_PI ); 

return(angle);

}/* end function VRcompute_angle */

/***********************************************************************/

IGRboolean bVRTestVect ( IGRlong 	*msg,
			IGRdouble 	*dVect1,
			IGRdouble 	*dVect2,
			IGRshort 	nTest
			)
/*.bVRTestVect*/
{
	BSrc	rc;
	IGRdouble	dCos, dLenSq;

	*msg = MSSUCC;

	dLenSq  = BSlenvec (&rc, dVect1);
	dLenSq *= BSlenvec (&rc, dVect2);

	if ( dLenSq < VRGetTol(VR_SQRLEN_TOL) )
		return FALSE;

	dCos = BSdotp ( &rc, dVect1, dVect2 )/ dLenSq;

	/*C Fix for TR#179415609	: Manyam
	    Replaced VR_EPSILON by BSBASISVAL		*/
	if ( rc == BSSUCC )
	{
		switch ( nTest )
		{
		case VR_SAME :
		   /*| Test If same */
		   if ( dCos > (1 - VRGetTol(VR_DOTPROD_TOL)) ) return (TRUE);
			break;
		case VR_OPPOSITE :
		   /*| Test If Opposite */
		   if ( dCos < ( -1 + VRGetTol(VR_DOTPROD_TOL)) ) return (TRUE);
			break;
		case VR_COLINEAR :
		   /*| Test If Colinear */
		   if (fabs(dCos)>(1 - VRGetTol(VR_DOTPROD_TOL))) return (TRUE);
			break;
		default :
			/*| UNKNOWN TEST CASE */
			return (FALSE);
		}
	}/* end BSdotp succeeded */

/*| Test Failed */
return ( FALSE );

}/* end function bVRTestVect */
 
/********************************************************************************************/
/*
/*	This function is the implementation of VR$GetCptInfo macros.
/*
/**/

VRGetCptInfo( p_retmsg, p_CmpId, CmpCptNum, p_CptCoord, p_CptAxis, p_CptOrient, p_CptProp,
	      p_MdEnv )

IGRlong				*p_retmsg;
struct		GRid		*p_CmpId;
IGRint				CmpCptNum;
IGRdouble			*p_CptCoord;
IGRdouble			*p_CptAxis;
IGRdouble			*p_CptOrient;
struct 		VRcp_attr 	*p_CptProp;
struct		GRmd_env	*p_MdEnv;
{
  IGRlong	retcode=MSSUCC, status=OM_S_SUCCESS;
  SetProc( Func_VRGetCptInfo ); Begin
  
  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                             	( &retcode, CmpCptNum, p_CptCoord, p_CptAxis, p_CptOrient, 
                                  p_MdEnv
                                ),
		    senderid = NULL_OBJID,
                    targetid = p_CmpId->objid,
                    targetos = p_CmpId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /* VRGetCptProp return MSFAIL in p_retmsg if component has no connection properties on
  /* the given connect point
  /**/

  status = om$send( msg      = message VRGeneric.VRGetCptProp
                                 ( p_retmsg, CmpCptNum, p_CptProp, p_MdEnv ),
		    senderid = NULL_OBJID,
                    targetid = p_CmpId->objid,
                    targetos = p_CmpId->osnum );
  as$status( action = RET_STATUS );

  End
  return OM_S_SUCCESS;
  
}  
    
/*************************************************************

	Computes, based on two specified shapes ( possible 
	values are defined in the VRdef.h file ) it computes
	the resulting shape to be used for the transition.

*************************************************************/



VRMkTransShape ( Shape1, Shape2, TrShape )
	IGRint	Shape1,		/* I : Value for shape 1 */
		Shape2,		/* I : Value for shape 2 */
		*TrShape;	/* O : Value for transition shape */

/*.VRMkTransShape */
{
	if ( Shape1 == Shape2 ) 	*TrShape = Shape1;
	else if ( Shape1 > Shape2 ) 	*TrShape = (Shape1 << 4) + Shape2;
	else				*TrShape = (Shape2 << 4) + Shape1;

	/*"TrShape = %d\n", *TrShape */

	return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint VRSplitSegment( p_retmsg, SharePlanes, p_SegmentToSplitId, p_SplitPoint,
			 p_MdEnv, p_NewSegmentId )

IGRlong				*p_retmsg;         	/* return code        */
IGRboolean			SharePlanes;	   	/* segments will share*/
                                       	/* terminal planes        */
struct		GRid		*p_SegmentToSplitId; 	/* Segment to split       */
IGRdouble			*p_SplitPoint;       	/* the split point        */
struct		GRmd_env	*p_MdEnv;           	/* the module env.        */
struct		GRid		*p_NewSegmentId;     	/* New segment            */


/*.VRSplitSegment */
{
  IGRint		NbChildren;             /* segmentToSplit nb of cmps  */
  IGRlong		status=OM_S_SUCCESS;    /* return code                */
  IGRlong		retcode=MSSUCC;         /* return code                */
  IGRboolean		EvalConst;
  struct	GRid	ChildrenId[VR_NB_CMPS]; /* SegmentToSplit cmps        */
  
  *p_retmsg = MSSUCC;

  /*"seg to split = %d\n", p_SegmentToSplitId->objid */

  status =
  om$send( msg      = message VRCnrlSeg.VRsplit_segment
                               ( &retcode, SharePlanes, p_SplitPoint, p_MdEnv, p_NewSegmentId ),
           senderid = NULL_OBJID,
           targetid = p_SegmentToSplitId->objid,
           targetos = p_SegmentToSplitId->osnum );
  as$status( action = RET_STATUS );

  /*"seg to split = %d\n", p_NewSegmentId->objid */

  status =
  om$send( msg      = message NDnode.NDdisplay( 0, GRbd, p_MdEnv ),
           senderid = NULL_OBJID,
           targetid = p_NewSegmentId->objid,
           targetos = p_NewSegmentId->osnum );
  as$status( action = RET_STATUS );

  EvalConst = TRUE;

  status =
  om$send(  msg      = message VRCnrlSeg.VRChgSegState( VR_UNKNOWN, VR_EVALUATE_CONST ),
            senderid = NULL_OBJID,
            targetid = p_NewSegmentId->objid, 
            targetos = p_NewSegmentId->osnum );
  as$status();

  status =
  om$send( msg      = message VRCnrlSeg.VRget_terminators
                   		( &retcode, &NbChildren, p_MdEnv, NULL, ChildrenId ),
           senderid = NULL_OBJID,
           targetid = p_SegmentToSplitId->objid,
           targetos = p_SegmentToSplitId->osnum );
  as$status( action = RET_STATUS );

  /*^
      printf("VRsketch.VRsksplitseg : \t Cmp %d .. old parent %d .. new %d\n",
            ChildrenId[1].objid, p_SegmentToSplitId->objid, p_NewSegmentId->objid );
  */

  status =
  om$send( msg      = message NDnodein.NDchange_connect
					( 1, p_SegmentToSplitId, p_NewSegmentId ),
           senderid = NULL_OBJID,
           targetid = ChildrenId[1].objid,
           targetos = ChildrenId[1].osnum );
  as$status( action = RET_STATUS );

  /* compute cmp1 on the new support */
  status =
  om$send( msg      = message NDnode.NDs_compute_node( &retcode, 0, p_MdEnv ),
           senderid = NULL_OBJID,
           targetid = ChildrenId[1].objid,
           targetos = ChildrenId[1].osnum );
  as$status( action = RET_STATUS );

  return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRSplitCorrection(	p_retmsg, CorType, p_CorToSplit, p_SegId, 
			p_CmpId, p_MdEnv, NewCorType
       		 )

IGRlong				*p_retmsg;   
IGRshort			CorType;
struct		GRid		*p_CorToSplit;
struct		GRid		*p_SegId;
struct		GRid		*p_CmpId;
struct		GRmd_env	*p_MdEnv;
IGRshort			NewCorType;

/*.VRSplitCorrection */
{
  IGRlong		status=OM_S_SUCCESS, retcode=MSFAIL;
  struct	GRid	CorId, *p_CorId, MyCmpId, *p_MyCmpId;
  
  
  *p_retmsg = MSSUCC;

  if( p_CorToSplit )
  {
	/*| correction id is given */
  	p_CorId   = p_CorToSplit;
  	p_MyCmpId = p_CmpId;
  }
  else
  {
	/* segment support is given */
  	p_CorId   = &CorId;
  	p_MyCmpId = &MyCmpId;
  
  	status = VRGetCorrection( &retcode, p_SegId, p_CmpId, p_MdEnv, p_CorId, p_MyCmpId );
  	as$status( action = RET_STATUS );

	/*"CorId = %d\n", p_CorId->objid */

	if( !retcode&1 || p_CorId->objid == NULL_OBJID )
		return OM_S_SUCCESS;
  }
  
  status =
  om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, p_MdEnv ),
	   senderid = NULL_OBJID,
	   targetid = p_CorId->objid,
	   targetos = p_CorId->osnum );
  as$status();

  /* MyCmpId = %d will be used to update corrections' connection\n", p_MyCmpId->objid */
  status =
  om$send( msg      = message VRCorrection.VRSplit
                           ( &retcode, p_MyCmpId, CorType, NewCorType, p_MdEnv ),
	   senderid = NULL_OBJID,
	   targetid = p_CorId->objid,
	   targetos = p_CorId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  return OM_S_SUCCESS;
}

/*D
	Given a Component, this function decides whether it is an
	eccentric component or not. The domain is limited to
	components which have only two Cpts.
*/

from	VRGeneric	import	VRGetNumberOfCpts, VRGetOrigCoor;

IGRboolean	VRIsEccentricComp( pMsg, pCmpId , pMdEnv )

IGRlong 	*pMsg ;		/* O : Return code, MSSUCC or MSFAIL.   */
struct GRid	*pCmpId;	/* I : Componet GRid			*/
struct GRmd_env	*pMdEnv;	/* I : Module environment of the Cmp	*/

{ /* VRIsEccentricComp */
	IGRint			i, status = OM_S_SUCCESS;
	IGRlong			retmsg;
	IGRdouble		dCpt0Coord[3], dCpt1Coord[3],
				dCpt0Axis[3], dCpt1Axis[3];
	BSrc			rc;


	*pMsg = MSFAIL;

	if ( !pCmpId || !pMdEnv )
		return	FALSE;

	/*A get the number of Cpts and return FALSE if the number of
	    Cpts fall out of my domain					*/
	{
	IGRint		NbCpts;

	status =
	om$send( msg      = message VRGeneric.VRGetNumberOfCpts(
		&retmsg, &NbCpts, pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	if ( NbCpts != 2 ) { *pMsg = MSSUCC; return FALSE; }
	}

	/*A get Cpt0 & Cpt1 geometries	*/
	for ( i=0; i<2; i++ )
	{
	status =
	om$send( msg      = message VRGeneric.VRGetCptGeom(
		&retmsg, (IGRshort)i, ( i ) ? dCpt1Coord : dCpt0Coord, 
		( i ) ? dCpt1Axis : dCpt0Axis, NULL, pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );
	}

	/*C make sure that it is not an elbow or any other angular 
	   fitting							*/
	/*A test whether the two connection axes are parallel to each
	    other or not						*/
	{
	IGRdouble	dDotp, dVec[3];

	dDotp = BSdotp( &rc, dCpt0Axis, dCpt1Axis );
	/* "Dot Product = %f \n", dDotp */

	if ( rc == BSSUCC ) 
	{
		if ( fabs(1 - fabs( dDotp ) ) > VRGetTol(VR_DOTPROD_TOL) )
		{	
			*pMsg = MSSUCC;
			return	FALSE;
		}
	} else return FALSE;

	/*A test to decide whether the given component is eccentric
	    or not						*/
	BSmkvec( &rc, dVec, dCpt0Coord, dCpt1Coord );
	BSnorvec( &rc, dVec );

	dDotp = BSdotp( &rc, dCpt0Axis, dVec );
	/* "Dot Product = %f \n", dDotp */

	if ( rc == BSSUCC ) 
	{
		*pMsg = MSSUCC;
		if ( fabs(1 - fabs( dDotp ) ) > VRGetTol(VR_DOTPROD_TOL) )
			return	TRUE;
		else return FALSE;

	} else return FALSE;
		
	}/* end test of angle between the axis and cpt's Vector */
		
}/*end VRIsEccentricComp */


/*D
	Given an eccentric component, this function decides whether it has
	been placed by center justification or not.
*/


from	VRGeneric	import	VRGetIndex;

IGRboolean	VRIsCenterJustified( pCmpId , pSegId, pMdEnv )

struct GRid	*pCmpId;	/* I : Component GRid			*/
struct GRid	*pSegId;	/* I : Segment wrt which the test has to be
					made				*/
struct GRmd_env	*pMdEnv;	/* I : Module environment of the Cmp	*/

{ /* VRIsCenterJustified */
	IGRint		i, status = OM_S_SUCCESS;
	IGRlong		retmsg;	
	IGRdouble	dPnts[6];


	if ( !pCmpId || !pSegId || !pMdEnv || pSegId->objid == NULL_OBJID
		|| pCmpId->objid == NULL_OBJID )
			return	FALSE;

	{
	IGRshort	nIndex;
	IGRdouble	dEndPnts[6];

	/*A get the cmp's index on the control segment	*/
	status = 
	om$send( msg	 = message VRGeneric.VRGetIndex(
		&retmsg, pSegId, &nIndex),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status ( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	/*A get the segments end point			*/
	status = 
	om$send( msg	 = message VRCnrlSeg.VRget_terminators(
		&retmsg, NULL, pMdEnv, dEndPnts, NULL),
		senderid = NULL_OBJID,
		targetid = pSegId->objid,
		targetos = pSegId->osnum );
	as$status ( action = RET_STATUS );
	
	if ( (int)nIndex )
		for ( i=0; i<3; i++ )
			dPnts[i] = dEndPnts[i+3];
	else
		for ( i=0; i<3; i++ )
			dPnts[i] = dEndPnts[i];
	}

	/*A get the component's origin			*/
	status =
	om$send( msg      = message VRGeneric.VRGetOrigCoor(
		&retmsg, &dPnts[3], pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	/*A test whether the origin and segment's End are coincident	*/
	{
	IGRboolean	bCoincident=FALSE;
	BSrc		rc;

	BScoincdpts( 2, (IGRpoint *)dPnts, NULL, &bCoincident, &rc );

	if ( rc == BSSUCC && bCoincident )
		return TRUE;
	else return FALSE;

	}/* end test for coincidency */

} /* end VRIsCenterJustified */

/*D
	Given a Component, this function checks whether it is a
	Oval-Circular xtion or not. If it is a O-Cxtion, It checks
	whether the oval section's width and depth are equal or not.
	Returns FALSE if they are equal( Xtion is not valid )
	otherwise returns TRUE.
*/

IGRboolean	VRIsShXtionValid( pMsg, pCmpId , pMdEnv )

IGRlong 	*pMsg ;		/* O : Return code, MSSUCC or MSFAIL.   */
struct GRid	*pCmpId;	/* I : Component GRid			*/
struct GRmd_env	*pMdEnv;	/* I : Module environment of the Cmp	*/

{ /* VRIsShapeXtion */

	IGRint			status = OM_S_SUCCESS;
	IGRlong			retmsg;

	*pMsg = MSFAIL;

	if ( !pCmpId || !pMdEnv )
		return	TRUE;

	/*A get the number of Cpts and return FALSE if the number of
	    Cpts fall out of my domain					*/
	{
	IGRint		NbCpts;

	status =
	om$send( msg      = message VRGeneric.VRGetNumberOfCpts(
		&retmsg, &NbCpts, pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCmpId->objid,
		targetos = pCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retmsg, action = RET_STATUS );

	if ( NbCpts != 2 ) { *pMsg = MSSUCC; return TRUE; }
	}

	/*A get the Cpt	properties	*/
	{
		IGRdouble	dWidth0, dDepth0;
		IGRdouble	dWidth1, dDepth1;
		IGRshort	nSection0, nSection1;

		status =
		VRGetCptProp ( &retmsg, pCmpId, (short ) 0,
		&dWidth0, &dDepth0, &nSection0, NULL, NULL, NULL, pMdEnv );
		
		as$status( action = RET_STATUS );
		as$status( sts = retmsg, action = RET_STATUS );

		status =
		VRGetCptProp ( &retmsg, pCmpId, (short ) 1,
		&dWidth1, &dDepth1, &nSection1, NULL, NULL, NULL, pMdEnv );

		as$status( action = RET_STATUS );
		as$status( sts = retmsg, action = RET_STATUS );

		if ( nSection0 == VR_CIRC && nSection1 == VR_OVAL )
		{
			/*BILLA  Double value comparison problem */
			if ( fabs(dWidth1 - dDepth1) < VRGetTol(VR_DIST_TOL) )
				return	FALSE;
		}
		else if ( nSection0 == VR_OVAL && nSection1 == VR_CIRC )
		{
			if ( fabs(dWidth0 - dDepth0) < VRGetTol(VR_DIST_TOL) )
				return	FALSE;
		}

	}

	return	TRUE;
		
}/*end VRIsShXtionValid */

/* This function would get the Correction Entity Object given the Line Segment.
The Correction entity meaning, the one placed based on the Line Segment or
common to both the End Components. Alwin */
IGRlong VRGetCorrectionFromLineSeg( struct GRid lineSegId, struct GRid *CommonCorrId )
{
   IGRint       i, j;
   IGRint       NbCorrections_0, NbCorrections_1;
   IGRlong      msg, status;
   struct GRid  CompIds[2];
   struct GRid  CorrId_0[20], CorrId_1[20];

   SetProc( Fn VRGetCorrectionFromLineSeg ); Begin

   if( !CommonCorrId ) return OM_E_INVARG;

   CommonCorrId->objid = NULL_OBJID;

   status =
   om$send( msg = message VRCnrlSeg.VRGetComponents( &msg, NULL, CompIds ),
                    senderid = NULL_OBJID,
                    targetid = lineSegId.objid,
                    targetos = lineSegId.osnum );
   as$status();

   NbCorrections_0 = NbCorrections_1 = 0;

   status =
   om$send( msg = message VRGeneric.VRGetCorrections( &msg, 20, CorrId_0,
                                        &NbCorrections_0 ),
                    senderid = NULL_OBJID,
                    targetid = CompIds[0].objid,
                    targetos = CompIds[0].osnum );
   as$status();

   status =
   om$send( msg = message VRGeneric.VRGetCorrections( &msg, 20, CorrId_1,
                                        &NbCorrections_1 ),
                    senderid = NULL_OBJID,
                    targetid = CompIds[1].objid,
                    targetos = CompIds[1].osnum );
   as$status();

   for( i=0; i<NbCorrections_0; i++ )
   {
        for( j=0; j<NbCorrections_1; j++ )
        {
            if( ( CorrId_0[i].objid == CorrId_1[j].objid ) &&
                ( CorrId_0[i].osnum == CorrId_1[j].osnum ) )
            {
                *CommonCorrId = CorrId_0[i];
                End
                return status;
            }
        }
   }

   End
   return status;
}

end implementation Root;

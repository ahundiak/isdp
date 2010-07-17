/* $Id: VRCCompfunk.I,v 1.5 2002/04/10 15:13:54 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconccomp / VRCCompfunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCCompfunk.I,v $
 *	Revision 1.5  2002/04/10 15:13:54  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.4  2001/08/28 18:51:00  louis
 *	Fix the bad planes in construction of offset elbows for tr4724
 *	
 *	Revision 1.3  2001/02/20 01:12:54  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 15:49:58  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/23  22:34:16  pinnacle
# Created: route/vrconccomp/VRCCompfunk.I by lawaddel for Service Pack
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
# Revision 1.2  1996/01/16  21:52:18  pinnacle
# Replaced: vrconccomp/VRCCompfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/16/96   tlb		Add prototypes
 *      08/27/01   law          Getting planes from cpt instead of origin
 *      04/05/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation Root;


#include <math.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "AS_status.h"
#include "VRMath.h"
#include "vrdbgmacros.h"
#include "vrtools_pto.h"
#include "bscrossp.h"
#include "bsdotp.h"

#define AS_DEBUG	1

from	GRvg		import 	GRdetplane;
from	VRGeneric	import	VRGetCptGeom, VRGetPlanesOnCpt, VRGetNumberOfCpts;

/***********************************************************************/
/*
/*  the dimension of TopoIds should be greater than 3*NbCpts.
/*  the dimension of IndexTable should be greater than 3*(NbCpts-1).
/*  the caller has the responsibilite of memory allocation
/**/

VRBuildTemp( retmsg, CompId, TopoIdsSize, TopoIds, IndexTableSize, IndexTable,
	     md_env, NbPlanes )

IGRlong		*retmsg;
struct GRid 	*CompId;
IGRint		TopoIdsSize;
struct GRid 	*TopoIds;
IGRint		IndexTableSize;
IGRshort	*IndexTable;
struct GRmd_env	*md_env;
IGRint		*NbPlanes;

/*.VRBuildTemp */
{
  IGRint			NbCpts, Cpt, i, status;
  IGRlong			retcode;
  IGRdouble 			CptCoord[3], t_plan[18]; 
  struct 	IGRplane	n_planes[3]; 
  BSrc            rc;
  IGRdouble       dX[3], dY[3], dZ[3];
  SetProc( Root_VRBuildTemp ); Begin

  *retmsg = MSSUCC;

  if( TopoIds == NULL || IndexTable == NULL )
  {
	*retmsg = MSFAIL;
        End
	return OM_E_INVARG;
  }

  status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
						 ( &retcode, &NbCpts, md_env ),
	   	    senderid = NULL_OBJID,
		    targetid = CompId->objid,
		    targetos = CompId->osnum );
  as$status( action = RET_STATUS );

  /*"NbCpts = %d\n", NbCpts */

  if( TopoIdsSize < (3*NbCpts) || IndexTableSize < 3*(NbCpts-1) )
  {
	*retmsg = MSFAIL;
        End
	return OM_E_INVARG;
  }

  /* see if in the list we have 3 planes no NULL_OBJID */
  for( Cpt=-1, i=0; i<NbCpts; i++ )
  {
	if( TopoIds[3*i].objid != NULL_OBJID )
	{
		/*| planes found */
		Cpt = i;
		break;
	}
  }

  if( Cpt == -1 )
  {
	/*| no planes diff. than NULL_OBJID */

	Cpt = 0;
	status = VRBuildCompPlanes
			 ( &retcode, CompId, Cpt, md_env, &TopoIds[0], md_env );
	as$status( action = RET_STATUS );
  }

  /*"planes on Cpt%d = %d %d %d\n", Cpt, TopoIds[0].objid, TopoIds[1].objid, TopoIds[2].objid */

  /*| ---  get the normal of the input planes  --- */
  for( i=0; i<3; i++ )
  {
	n_planes[i].point  = &t_plan[6*i];
	n_planes[i].normal = &t_plan[6*i+3];
	status = om$send( msg      = message GRvg.GRdetplane
					( &retcode, &md_env->md_env.matrix_type,
				  	  md_env->md_env.matrix, &n_planes[i] ),
		 	  senderid = NULL_OBJID,
		 	  targetid = TopoIds[3*Cpt+i].objid,
		 	  targetos = TopoIds[3*Cpt+i].osnum );
	as$status( action = RET_STATUS );
	/*"normal %d %f %f %f\n", i, n_planes[i].normal[0],n_planes[i].normal[1],n_planes[i].normal[2] */
  }

  for( i=0; i<NbCpts; i++ )
  {
	if( TopoIds[3*i].objid == NULL_OBJID )
	{
//              printf("building planes for cpt %d\n",i);
		status = om$send( msg = message VRGeneric.VRGetCptGeom 
			 	     	( &retcode, i, CptCoord,dX, dY,
					  md_env
					),
				  senderid = NULL_OBJID,
				  targetid = CompId->objid,
				  targetos = CompId->osnum );
//              printf("CptCoord is %f %f %f\n",CptCoord[0],CptCoord[1],CptCoord[2]);
//              printf("dX vector   %f %f %f\n",dX[0],dX[1],dX[2]);
//              printf("dY vector   %f %f %f\n",dY[0],dY[1],dY[2]);
		as$status( action = RET_STATUS );
	/**** TR4724 - Build planes from CPT normals ******/ 		
                BScrossp (&rc,  dX, dY, dZ);
//              printf("dZ vector   %f %f %f\n",dZ[0],dZ[1],dZ[2]);
		cre_plan( CptCoord, dZ, md_env, &TopoIds[3*i] );
		cre_plan( CptCoord, dY, md_env, &TopoIds[3*i+1] );
		cre_plan( CptCoord, dX, md_env, &TopoIds[3*i+2] );

		/*"new planes = %d %d %d\n", TopoIds[3*i].objid, TopoIds[3*i+1].objid, TopoIds[3*i+2].objid */
	}
  }

  /*| match constrains */
  status = VRMatchConstPlanes( &retcode, NbCpts, TopoIds, IndexTable, md_env );
  as$status();

  /*^ for (i = 0; i<3*NbCpts; i++)
	printf ("Plane[%d]=<%d, %d>\n",i, TopoIds[i].objid, TopoIds[i].osnum);
   */

  *NbPlanes = 3*NbCpts;

  /*"nb planes = %d\n", *NbPlanes */

  End
  return OM_S_SUCCESS;

}

/*****************************************************************************/
/*
/* This function suppose that all Cpti, Cptj planes are perponducular two by two
/* and Cpti planes are orthogonal.
/**/

VRMatchConstPlanes( retmsg, NbCpts, TopoIds, IndexTable, md_env )

IGRlong			*retmsg;
IGRint			NbCpts;
struct	GRid		*TopoIds;
IGRshort		*IndexTable;
struct	GRmd_env	*md_env;

/*.VRMatchConstPlanes */
{
  IGRint			i, j, index, index1, status;
  IGRlong			retcode, bsretcode;
  IGRdouble 			dot_p, t_plan[36]; 
  struct 	IGRplane	n_planes[6]; 
  SetProc( Root_VRMatchConstPlanes ); Begin

  *retmsg = MSSUCC;

  /*"NbCpts = %d\n", NbCpts */

  for( i=0; i<6; i++ )
  {
	n_planes[i].point  = &t_plan[6*i];
	n_planes[i].normal = &t_plan[6*i+3];
  }

  /*| get the normal of the Cpt0 planes */
  for( i=0; i<3; i++ )
  {
	status = om$send( msg      = message GRvg.GRdetplane
					( &retcode, &md_env->md_env.matrix_type,
					  md_env->md_env.matrix, &n_planes[i] ),
	  		   senderid = NULL_OBJID,
	   	 	   targetid = TopoIds[i].objid,
	  	 	   targetos = TopoIds[i].osnum );
	as$status( action = RET_STATUS );

	/*"noraml[%d] = %f %f %f\n", i, n_planes[i].normal[0],  n_planes[i].normal[1],  n_planes[i].normal[2] */
  }

  /* for Cpt1 to Cptn get the Cpt planes and match them with Cpt0 planes */
  for( i=1; i<NbCpts; i++ )
  {
	/* get the normal of the Cpti planes */
  	for( j=0; j<3; j++ )
  	{
		status = om$send( msg      = message GRvg.GRdetplane
					     ( &retcode, &md_env->md_env.matrix_type,
				  	       md_env->md_env.matrix, &n_planes[j+3] ),
		 	  	  senderid = NULL_OBJID,
 	 	 	  	  targetid = TopoIds[3*i+j].objid,
	 	 	  	  targetos = TopoIds[3*i+j].osnum );
		as$status( action = RET_STATUS );

		/*"noraml[%d] = %f %f %f\n", j, n_planes[j+3].normal[0],  n_planes[j+3].normal[1],  n_planes[j+3].normal[2] */
	}

	/*" match Cpt0 and Cpt%d planes\n", i */
        __DBGpr_int("CPT number to match with cpt0",i);
	for( index=0; index<3; index++ )
	{
		for( index1=3; index1<6; index1++ )
		{
			/*"match plane %d and plane %d\n", index, index1 */
			/*"noraml[%d] = %f %f %f\n", index, n_planes[index].normal[0],  n_planes[index].normal[1],  n_planes[index].normal[2] */
			/*"noraml[%d] = %f %f %f\n", index1, n_planes[index1].normal[0],  n_planes[index1].normal[1],  n_planes[index1].normal[2] */

		     	dot_p = BSdotp( &bsretcode, n_planes[index].normal, 
				                    n_planes[index1].normal );

			/*"dot_p = %f\n", dot_p */

		     	if( ( 1 - fabs( dot_p ) ) < VRGetTol(VR_DOTPROD_TOL) )
			{
				IndexTable[3*(i-1)+index] = 3*i+index1-3;
				/*"IT[%d] = %d\n", 3*(i-1)+index, 3*i+index1-3 */
				break;
			}
		}
	}
  }
  End
  return OM_S_SUCCESS;
}

end implementation Root;

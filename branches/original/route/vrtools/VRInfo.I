/* $Id: VRInfo.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRInfo.I,v $
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
# Revision 1.2  1996/01/18  00:31:26  pinnacle
# Replaced: vrtools/VRInfo.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb	Add prototypes
 *
 *************************************************************************/
/*
/*	List of functions :
/*	
/*		- VRSelectClosestCpt
/*
/**/

class implementation Root;

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "bstypes.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "AS_status.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bslenvec.h"

from	IGEgragad	import	DPinrot;
from 	VRGeneric	import	VRGetTopo,VRGetSupOnCpt;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 CHANGE HISTORY:  Bruno 13-May-1990 : Design date


 DESCRIPTION  : This function returns the connection point number of
		the specified component the closest to the datapoint.

/*****************************************************************************/

double	VRSelectClosestCpt( bFree, pComponent, pWindow, pDataPoint, pCpt, pCptCoord, md_env )

IGRboolean			bFree;		/* I Tells if selected Cpt must be free */
struct		GRid		*pComponent;	/* I Specified component */
struct		GRid		*pWindow;	/* I Specified window  */
IGRdouble			*pDataPoint;	/* I Specified datapoint */
IGRshort			*pCpt;		/* O Selected Cpt number */
IGRdouble			*pCptCoord;	/* O Selected Cpt's coordinates */
struct		GRmd_env	*md_env;	/* I Specified component's module env	*/

{
  IGRint		NbCpt;
  register IGRint	i;
  IGRlong		retcode= MSSUCC, status= OM_S_SUCCESS;          
  IGRdouble		dDistanceMin = -1., dDistance=-1,
			dZwin[3], dCptCoord[3*VR_MAX_CPTS];

  /* -- initialization -- */
  *pCpt = -1;

  if ( !pWindow || !pComponent || !pDataPoint ) return dDistanceMin;

  {
    /* -- projection vector from the window -- */
    IGRmatrix win_matrix;

    status = om$send( 
		msg      = message IGEgragad.DPinrot( &retcode, win_matrix ),
		senderid = NULL_OBJID,
		targetid = pWindow->objid,
		targetos = pWindow->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    dZwin[0] = win_matrix[8];
    dZwin[1] = win_matrix[9];
    dZwin[2] = win_matrix[10];
    /* end get projection vector */
  }

  /* -- get the topology of the given component -- */
  status = om$send( msg      = message VRGeneric.VRGetTopo
                               ( &retcode, VR_MAX_CPTS, &NbCpt, NULL, dCptCoord,
		                 NULL, NULL, md_env ),
                    senderid = NULL_OBJID,
                    targetid = pComponent->objid,
                    targetos = pComponent->osnum ) ;
  as$status( action = RET_STATUS ) ;
  as$status( sts = retcode, action = RET_STATUS ) 

  for( i=0; i<NbCpt; i++ )
  {
    struct GRid		SegId;
    IGRdouble		dTmpVect[3], dLenVect[3]; 
    BSrc		bsretcode; 

    /* find out whether the closest connect point is free or not */
    status = om$send( msg      = message VRGeneric.VRGetSupOnCpt
                                         ( &retcode, i, &SegId, md_env ),
                      senderid = NULL_OBJID,
                      targetid = pComponent->objid,
                      targetos = pComponent->osnum ) ;

    if ( (bFree && SegId.objid == NULL_OBJID) || (!bFree) )
    {
      /* -- get the vector from the data point to CptPt -- */
      BSmkvec( &bsretcode, dTmpVect, pDataPoint, &dCptCoord[3*i] ) ;

      /* -- get the cross product of the two vectors -- */
      BScrossp( &bsretcode, dZwin, dTmpVect, dLenVect );

      /* -- find the length of the vector	-- */
      dDistance = BSlenvec( &bsretcode, dLenVect ) ;

      if( dDistance < dDistanceMin || dDistanceMin < 0 )
      {
        dDistanceMin = dDistance ;
        *pCpt  = i;
      }
    }
  }

  if ( *pCpt != -1 ) {
    /* -- output the coordinates if not NULL -- */
    if ( pCptCoord )	
     for ( i=0; i<3; i++) pCptCoord[i] =  dCptCoord[(*pCpt)*3+i];
    return dDistanceMin;
  }
  else return 0.0;
}

end implementation Root;

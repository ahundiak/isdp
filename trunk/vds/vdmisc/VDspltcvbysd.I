/* $Id: VDspltcvbysd.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDspltcvbysd.I
 *
 * Description:
 *		The function in this file see if the input curve intersect
 *		within a solid. When one or more times intersect a list
 *		of output curves will be generated and returned.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDspltcvbysd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/01/16  17:00:34  pinnacle
# Replaced: ./vdmisc/VDspltcvbysd.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/06/01  23:24:06  pinnacle
# Created: vdmisc/VDspltcvbysd.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/26/95	adz/yuhang	creation date
 ***************************************************************************/

class implementation GRcurve ;

#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igr.h"
#include "ex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "grio.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"

#include "emssfintdef.h"		/* EMSINT_TRIM_OUTPUT */
#include "emsdattyp.h"
#include "EMStypedef.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "emsinter.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"
#include "v_vecmxproto.h"
#include "vdrefmacros.h"
#include "refmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

from	GRlinear	import	GRgetpolyline;
from	EMSsolid	import	EMpoint_locate;
from	EMSsurface	import	EMcrvsrfint;

#define	VD_K_max_parms_value	2.0

#define EQPARMS( p1, p2 ) VD_zeroDist( fabs( (p1) - (p2) ) )

/****************************************************************************/
   
VD_splitCrvBySolid( msg, resCst, cvObj, slObj, resCount, resList ) 
IGRlong        		*msg ;		/* O return code		*/
struct GRvg_construct	*resCst;	/* I Local Construct Inf	*/
struct GRobj_env        *cvObj;		/* I curve objenv		*/
struct GRobj_env        *slObj;		/* I solid objenv		*/
IGRint                  *resCount;	/* O number of split curve	*/
struct GRobj_env        **resList;      /* O objenv of split curve	*/
{

		IGRint                  sts;
		int                     j;		/* loop index      */
		IGRlong                 intElmCount ;
		IGRint			outCount ;
		IGRdouble               PtOnCrv[3] ;
		struct GRobj_env        *outList;   /* Interal Output List   */ 
		struct GRid	        partCrv;    /* Partial Curve         */
		struct IGRbsp_curve	*cvGeom ;
		IGRushort               ptLocOptions = 0 ; /* Not Used.      */
		IGRulong                location;   /* Inside solid location */
		struct	GRmd_env	*cstEnv ;
		IGRlong			pntSlots = 0 ;
		IGRdouble               locU;
		struct GRparms          *parm ;     /* Parameter split curve */
		struct GRparms		staParm ,
					midParm ,
					endParm ;
		IGRint			pmCnt,k;
		struct GRid             locCrv,      /* Local Copy of Curve  */
					chkCrv ;

	SetProc( VD_splitCrvBySolid ); Begin

	sts = OM_S_SUCCESS ;
	cstEnv	= resCst->env_info ;

	*resCount	= 0 ;
	*resList	= NULL ;

        intElmCount	= 0 ;

	parm		= NULL ;

	outCount	= 0;
	outList		= NULL ;

	cvGeom		= NULL ;

	/*
	 * Copy the input Curve. This is needed when the GRsplit method
	 * goes oke. The input curve will be consumed as one part of the
	 * output.
	 */

	sts = 
        vd_$grCopy( msg    = msg, 
                    frEnv  = &cvObj->mod_env, 
                    frObj  = &cvObj->_grid, 
                    toEnv  = cstEnv, 
                    toObj  = &locCrv );
	__CheckRC( sts, *msg, "grCopy", wrapup );

	__DBGpr_obj(" Local Curve ", locCrv );

	chkCrv = locCrv ;

	/*
	 * Set the internal arguments structure for the intersect
	 * routine.
	 */
	sts =
	_VD_SEND_OBJN(	slObj->_grid,
			EMSsurface.EMcrvsrfint(	msg,
						resCst,
						&slObj->mod_env.md_env,
						NULL,
						&locCrv,
						&cstEnv->md_env,
						FALSE,
						&pntSlots,
						&intElmCount,
						NULL, /* &intElmList, */
						NULL,
						&parm,
						NULL, /* &cvPnts,  */
						NULL ));
	__CheckRC( sts, *msg, "EMSsurface.EMcrvsfint", wrapup );
						
	__DBGpr_int(" Number of Intersections ", intElmCount );

	/*
	 * Do nothing when no intersection found.
	 */

	if( ! intElmCount ){

		/*
		 * simulate the checking of the parameters list. We need to 
		 * determine if the object is totaly inside or outside.
		 */
		_FREE( parm );
		if( !( parm =  _MALLOC( 1, struct GRparms )))
			vd_$mem_fail();

		parm[0].u = 0.5 ;
		parm[0].v = 0.0 ;
		parm[0].polygon_inx = 0 ;	/* On CURVE */
		parm[0].leaf_id = locCrv ;

	}
	else{

          /*
           * Sort the u-paramters values in increming order to use partial
	   * split routine. Also sort the intersection (split) points in the
	   * identical order.
           */
  
	  pmCnt = 0;
          for( j=0; j<intElmCount; j++ ){
	    for( k=j; k<intElmCount; k++ )

		if( parm[k].u < parm[pmCnt].u ) {

			locU		= parm[k].u ;
			parm[k].u	= parm[pmCnt].u ;
			parm[pmCnt].u	= locU ;

		}

                if( ! pmCnt )		pmCnt++ ;
                else if( ! EQPARMS( parm[pmCnt].u , parm[pmCnt-1].u ))
					pmCnt++ ;
                else			parm[pmCnt].u = VD_K_max_parms_value ;
	  }
	}

	/* 
	 * split the input curve in parts, divided by the u-parameter.
	 * Take each time a part of the curve and construct the new object.
	 * This needed as result of invalid processing using composite
	 * curves or conic objects as input objects. These object will NOT
	 * return curves in proper sequence.
	 * Use the parm values of the objects and evaluate the projection
	 * point.
         */

	endParm = parm[0] ;
	endParm.u = 0 ;

	partCrv.osnum  = cstEnv->_MD_OS ;

	/*
         * Allocate memory for the following tasks.
	 *	- outList	: Number of splited curves.
         */
	if( !( outList = _MALLOC( intElmCount+1, struct GRobj_env )))
		vd_$mem_fail();

	for( j=0 ; j<=intElmCount ; j++ ){

		staParm	= endParm ;

		if( j==intElmCount )	endParm.u = 1.0 ;
		else			endParm = parm[j] ;

		midParm = staParm ;
		midParm.u = ( endParm.u + staParm.u ) * 0.5 ;
	
		__DBGpr_dbl(" Start POINT ", staParm.u );
		__DBGpr_dbl(" Mid   POINT ", midParm.u );
		__DBGpr_dbl(" End   POINT ", endParm.u );

		/* 
		 * find parameters structure for spliting curve. 
		 */
		sts =
		_VD_SEND_OBJN(	locCrv,
				GRcurve.EMpartofcv(	msg,
							&cstEnv->_MATRIX_TYPE,
							cstEnv->_MATRIX,
							resCst,
							&staParm,
							&midParm,
							&endParm,
							&partCrv.objid ));
		__CheckRC( sts, *msg, "GRcurve.EMpartofcv", wrapup );

		__DBGpr_obj(" Partial Curve ", partCrv );

		/*
		 * get geometry of input curve.
		 */
		vd_$get_geometry(	msg		= msg,
					grobjId		= &partCrv,
					grobjEnv	= cstEnv,
					geometry	= &cvGeom ) ;
		__CheckRC( 1, *msg, "vd_$get_geometry", wrapup ) ;

		BScveval( cvGeom, midParm.u, 0, PtOnCrv, msg );

		_FREE( cvGeom ); cvGeom = NULL ;

        	/*
		 * check if the split curve is in solid or not
		 */
        	sts =
		_VD_SEND_OBJN(	slObj->_grid,
				EMSsolid.EMpoint_locate(msg,
							&slObj->mod_env,
                                                	ptLocOptions,
							PtOnCrv,
							NULL,
							&location ));
		__CheckRC( sts, *msg, "EMSsolid.EMpoint_locate", wrapup );
          
        	if( location == EMS_S_INSOLID ) {

			__DBGpr_com(" Curve is INSOLID " );
			outList[outCount  ]._grid   = partCrv ;
			outList[outCount++].mod_env = *cstEnv ;
                }
		else{
			/* location == EMS_S_OUTSOLID */
			__DBGpr_com(" Curve is OUTSOLID " );
			vd_$bulk_delete(	count	= 1,
						grids	= &partCrv,
						theEnv  = cstEnv );
                }
	}  /* for( ... intElmCount+1 ) */

        __DBGpr_int("outCount ", outCount );

	/*
	 * Copy result to output list.
	 */

	if( outCount ){
		*resCount	= outCount ;
		*resList	= outList ;

		outCount	= 0 ;
		outList		= NULL ;
	}

	*msg = MSSUCC ;

wrapup:

	if( !( sts & *msg & 1 )){

		/*
		 * delete the resulted curves.
		 */
		vd_$bulk_delete(	count	= *resCount,
					objenvs	= *resList );
		vd_$bulk_delete(	count	= outCount,
					objenvs	= outList );
	}

	/*
	 * Check if anything happened with the input curve.
	 * When they are the same, nothing has happend to the input curve.
	 */
	if( IF_EQ_OBJID( locCrv.objid, chkCrv.objid )){

		__DBGpr_com(" DELETE COPIED CURVE " );
		vd_$bulk_delete(	count	= 1,
					grids	= & chkCrv,
					theEnv	= cstEnv );
	}

        /* free memory */

        _FREE( outList );
        _FREE( parm );		/* allocated by EMcrvsrfint */
	_FREE( cvGeom );

	End
        return  sts ;

} /* fct VD_splitCrvBySolid */

end implementation GRcurve ;

/*
	I/STRUCT
*/
class implementation NDnode ;

#include <stdio.h>		/* For NULL		*/
#include "bserr.h"
#include "bstypes.h"
#include "nddef.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bseig3x3.h"
#include "bseigval3x3.h"
#include "EMSwrmacros.h"
#include "vsbldrootcpx.h"
#include "vsvecmxproto.h"

/* 
 *
 * This file creates a Moment of Inertia Designator.
 *
 */
#define X	0
#define Y	1
#define Z	2

extern void	VSsetGRids() ;
/*----------------------------------------------------------------------------*/
long VSdiagInertiaMx( msg, imx, Jxyz, principalAxes )

long		*msg ;
double		imx[6] ;
double		Jxyz[3] ;
IGRvector	principalAxes[3] ; {

	long	sts ;
	double	MoImx[3][3] ;	/* Inertia tensor matrix	*/
	int	ecount ;	/* Count of eigenvalues		*/

	MoImx[X][X] = imx[0] ;
	MoImx[Y][Y] = imx[1] ;
	MoImx[Z][Z] = imx[2] ;
	MoImx[Y][X] = MoImx[X][Y] = - imx[3] ;
	MoImx[Z][Y] = MoImx[Y][Z] = - imx[4] ;
	MoImx[X][Z] = MoImx[Z][X] = - imx[5] ;

	if( principalAxes ) {
		BSeig3x3( MoImx, &ecount, Jxyz, principalAxes, msg ) ;
	} else {
		BSeigval3x3( MoImx, &ecount, Jxyz, msg ) ;
	}
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_BSerror	; sts = OM_W_ABORT ;
	} else {
		*msg = MSSUCC		; sts = OM_S_SUCCESS ;
	}

	return sts ;

} /* VSdiagInertiaMx */
/*----------------------------------------------------------------------------*/
long VSplaceMomentOfInertia( msg, cst, mp, moment )

long			*msg ;
VSintegral		*mp ;
struct GRvg_construct	*cst ;
struct GRid		*moment ; {

#define MAX	7

	long		sts ;
	struct GRid	MoIcmps[MAX] ;	/* Components of mass-designator*/
	IGRvector	evecs[3] ;	/* List of eigenvectors		*/
	double		points[6],	/* Point buffer			*/
			e, d,
			length[3],	/* Lengths of principal axes	*/
			evalues[3],	/* List of eigenvalues		*/
			slash[2] ;
	int		i, j,
			nbCmp ;		/* List of components		*/
	char		*names[MAX] ;	/* Names of components		*/

	VSsetGRids( cst->env_info->_MD_OS, MAX, MoIcmps ) ;

	sts = OM_W_ABORT ;

	nbCmp = 0 ;
	/*
	 * Construct centroid.
	 */
	EFplace_line_string(	NULL_OBJID,
				cst,
				1,
				mp->centroid,
				&MoIcmps[nbCmp].objid,
				msg ) ;
	if( !( *msg & 1 ) ) goto wrapup ;
	nbCmp++ ;

	sts = VSdiagInertiaMx( msg, mp->MofI.array, evalues, evecs ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Draw principal axes
	 */
	VSvccpy( points + 0, mp->centroid ) ;
	j = 3 ;

	for( i = 0 ; i < 3 ; i++ ) {
		/*
		 * Note: the eigenvectors are normalized.
		 */
		length[i] = 1. ;

		for( j = 0 ; j < 3 ; j++ ) {
			points[3+j] = points[0+j] + length[i] * evecs[i][j] ;
		}
		EFplace_line_string(	NULL_OBJID,
					cst,
					2,
					points,
					&MoIcmps[nbCmp].objid,
					msg ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		nbCmp++ ;
	}

	/*
	 * Now draw lines to differentiate between x, y and z axes.
	 * A "/" on y-axis and a "//" on z-axis.
	 */
	for( i = 0 ; i < 3 ; i++ ) {	
		d = mp->centroid[i] + 0.5 * length[Y] * evecs[Y][i] ;
		e = 0.2 * length[Y] * evecs[X][i] ;
		points[0 + i] = d - e ;
		points[3 + i] = d + e ;

	}
	EFplace_line_string(	NULL_OBJID,
				cst,
				2,
        			points,
        			&MoIcmps[nbCmp].objid,
        			msg ) ;
	if( !( *msg & 1 ) ) goto wrapup ;
	nbCmp++ ;

	slash[0] = 0.5 ; slash[1] = 0.7 ;

	for( j = 0 ; j < 2 ; j++ ) {
    		for( i = 0 ; i < 3 ; i++ ) {
			d = mp->centroid[i] + slash[j] * length[Z] * evecs[Z][i] ;
    			e = 0.2 * length[Z] * evecs[X][i] ;
	    		points[0 + i] = d - e ;
    			points[3 + i] = d + e ;
    		}

		EFplace_line_string(	NULL_OBJID,
					cst,
        				2,
	                        	points,
					&MoIcmps[nbCmp].objid,
					msg ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		nbCmp++ ;
	}

	/*
	 * Now build root complex bundling everybody together.
	 */
	names[0] = "centroid" ;
	names[1] = "XprincipalAxis" ;
	names[2] = "YprincipalAxis" ;
	names[3] = "ZprincipalAxis" ;
	names[4] = "Y_marker" ;
	names[5] = "Z_marker_1" ;
	names[6] = "Z_marker_2" ;

	moment->osnum = cst->env_info->_MD_OS ;
	sts = VSbuildRootComplex(	msg,
					VS_K_prMomOfInertiaCPX,
					MAX,
					MoIcmps,
					names,
					cst->env_info,
					cst->env_info->_MD_OS,
					&moment->objid ) ;

	/*
	 * We want this guy never to stay around !
	 */
	sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL ),
			senderid= moment->objid,
			targetid= moment->objid,
			targetos= moment->osnum ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	count	= MAX,
					grids	= MoIcmps,
					theEnv	= cst->env_info ) ;

			vs$bulk_delete(	grids	= moment,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSplaceMomentOfInertia */
/*----------------------------------------------------------------------------*/

end implementation NDnode ;

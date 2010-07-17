/* $Id: VSfndplbmjns.C,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSfndplbmjns.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSfndplbmjns.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.4  1998/03/27  13:59:56  pinnacle
 * Replaced: vsjoint/VSfndplbmjns.C for:  by manoj for struct
 *
 * Revision 1.3  1997/11/18  09:11:48  pinnacle
 * Replaced: vsjoint/VSfndplbmjns.C for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  13:13:14  pinnacle
 * Replaced: vsjoint/VSfndplbmjns.C for:  by svkadamb for struct
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 *	03/27/98	suresh		The both side welding option 
					is not handle.  Make modification 
					so that both sides welding is handled
 ***************************************************************************/
/*
	I/STRUCT
*/

#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "bserr.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vdsmacros.h"
#include "vsjoint.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vswelddef.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsgeom_cvsf.h"
#include "bsmdistsfsf.h"
#include "bssfsfint.h"
#include "bspl_pl.h"
#include "bssfeval.h"
#include "bssfnormal.h"
#include "vsocgrleaves.h"

extern void	VSfreeMatchList() ;
extern long	VSgetFaceFromSolid() ;

/*----------------------------------------------------------------------------*/
long VSisSfOnSf( msg, sfGeom0, sfGeom1, isSfOnSf )

long			*msg ;
struct IGRbsp_surface	*sfGeom0,
			*sfGeom1 ;
int			*isSfOnSf ; {

	/*
	 * Checks that a surface is partially or totally on another one.
	 */
	long		sts ;
	int		numMins ;
	double		*paruv0	= NULL,
			*paruv1	= NULL,
			dist ;
	IGRpoint	*sfpt0	= NULL,
			*sfpt1	= NULL ;
	IGRvector	normal0,
			normal1 ;

	/*
	 * Test for exactly coincident planes first since `BSmdistsfsf' may
	 * err in this case.
	 * NOTE: `BSsfnormal' returns BSFAIL is input surface is not planar.
	 */
	__DBGpr_int( "Sf 0 planar ?", sfGeom0->planar ) ;
	BSsfnormal( sfGeom0, normal0, msg ) ;
	__DBGpr_int( "BSsfnormal 0 *msg", *msg ) ;
	if( BSOKAY( *msg ) ) {
		BSsfnormal( sfGeom1, normal1, msg ) ;
		__DBGpr_int( "BSsfnormal 1 *msg", *msg ) ;
		if( BSOKAY( *msg ) ) {
			IGRpoint	pnt0,
					pnt1,
					q ;
			IGRvector	u ;
			int		flag ;

			BSsfeval( sfGeom0, 0.5, 0.5, 0,
				 (IGRpoint *) pnt0, msg ) ;
			BSsfeval( sfGeom1, 0.5, 0.5, 0,
				  (IGRpoint *) pnt1, msg ) ;

			BSpl_pl( pnt0, normal0, pnt1, normal1,
				 &flag, q, u, msg ) ;

			__DBGpr_int( "BSpl_pl *msg", *msg ) ;
			__DBGpr_int( "BSpl_pl flag", flag ) ;

			if( flag == BSCCOINCIDENT ) {
				__DBGpr_com( "Coincident planes" ) ;
				*isSfOnSf = TRUE ;
				*msg	= MSSUCC ;
				sts	= OM_S_SUCCESS ;
				goto wrapup ;
			}
		}
	}
	/*
	 * Commented out as the BSmdistsfsf doesn,t return the currectly if the
	 * surface are coincident, which is a very important return value for 
	 * this function
	 */
/*	
	BSmdistsfsf(	sfGeom0,
			sfGeom1,
			&numMins,
			&paruv0,
			&paruv1,
			&sfpt0,
			&sfpt1,
			&dist,
			msg ) ;
*/
	{
	struct BSgeom_bsp_curve        *xyz_cvs, *uv_cvs1, *uv_cvs2;
	IGRint                         i, numgrps,tnb_int, *num_int, *tnb_pts;
	BSrc                           rc;
	BSpair                         **tp_par1, 
					**tp_par2;
	IGRpoint                       **tpts;
	IGRshort                       cvscode;
	struct BSgeom_bsp_surf         pl_geom, sf_geom;



	tnb_int		= 0;
	numgrps        = 0;
	num_int        = NULL;
	tnb_pts        = NULL;
	tpts           = NULL;
	tp_par1        = NULL;         /* intermediate var for intersections */
	tp_par2        = NULL;
	xyz_cvs = NULL;
	uv_cvs1 = NULL;
	uv_cvs2 = NULL;

	sf_geom.type = BSGEN_BSP_SF;
	sf_geom.geom_prop = FALSE;
	sf_geom.bounded = TRUE;
	sf_geom.bspsf = sfGeom0;
	sf_geom.urange[0] = sfGeom0->u_knots[sfGeom0->u_order-1];
	sf_geom.urange[1] = sfGeom0->u_knots[sfGeom0->u_num_poles];
	sf_geom.vrange[0] = sfGeom0->v_knots[sfGeom0->v_order-1];
	sf_geom.vrange[1] = sfGeom0->v_knots[sfGeom0->v_num_poles];

	pl_geom.type = BSGEN_BSP_SF;
	pl_geom.geom_prop = FALSE;
	pl_geom.bounded = TRUE;
	pl_geom.bspsf = sfGeom1;
	pl_geom.urange[0] = sfGeom1->u_knots[sfGeom1->u_order-1];
	pl_geom.urange[1] = sfGeom1->u_knots[sfGeom1->u_num_poles];
	pl_geom.vrange[0] = sfGeom1->v_knots[sfGeom1->v_order-1];
	pl_geom.vrange[1] = sfGeom1->v_knots[sfGeom1->v_num_poles];

	BSsfsfint(&sf_geom, &pl_geom, &numgrps,
                &num_int,&tnb_pts,&tpts, &tp_par1, &tp_par2,&cvscode, &xyz_cvs,
                &uv_cvs1, &uv_cvs2, &rc);

	__DBGpr_int( "BSmdistsfsf rc", rc ) ;
	tnb_int = 0;
	for(i=0;i<numgrps;i++) tnb_int = tnb_int + num_int[i];
	__DBGpr_int(" Total num of inter", tnb_int );
	*msg = rc ;

	_FREE( tnb_pts );
	VDSfree(tnb_int,&tpts);
	VDSfree(tnb_int,&tp_par1);
	VDSfree(tnb_int,&tp_par2);

	if(xyz_cvs != NULL){
		for(i=0;i<tnb_int;i++){
			if(xyz_cvs[i].array1 != NULL){
				free(xyz_cvs[i].array1);
				xyz_cvs[i].array1=NULL;
				}
			if(xyz_cvs[i].bspcv != NULL){
				BSfreecv(&rc, xyz_cvs[i].bspcv);
				xyz_cvs[i].bspcv = NULL;
			}
		}
		free(xyz_cvs);xyz_cvs = NULL;
	}
	if(uv_cvs1 != NULL){
		for(i=0;i<tnb_int;i++){
			if(uv_cvs1[i].array1 != NULL){
				free(uv_cvs1[i].array1);
				uv_cvs1[i].array1=NULL;
			}
			if(uv_cvs1[i].bspcv != NULL){
				BSfreecv(&rc, uv_cvs1[i].bspcv);
				uv_cvs1[i].bspcv = NULL;
			}
        	}
        	free(uv_cvs1);uv_cvs1 = NULL;
	}
	if(uv_cvs2 != NULL){
		for(i=0;i<tnb_int;i++){
			if(uv_cvs2[i].array1 != NULL){
				free(uv_cvs2[i].array1);
				uv_cvs2[i].array1=NULL;
			}
			if(uv_cvs2[i].bspcv != NULL){
				BSfreecv(&rc, uv_cvs2[i].bspcv);
				uv_cvs2[i].bspcv = NULL;
			}
		}
		free(uv_cvs2);uv_cvs2 = NULL;
	}
	if(num_int   != NULL)          { free(num_int);   num_int = NULL; }


	}

	__DBGpr_int( "BSmdistsfsf rc", *msg ) ;

	if( *msg == BSCOINCIDENT ) {
		__DBGpr_com( "Coincident planes" ) ;
		*isSfOnSf = TRUE ;
	} else {

		if( BSERROR( *msg ) ) { vs$error( msgval = EMS_E_BSerror ) ; }

		*isSfOnSf = FALSE  ;

/* {
		double	distTol ;

		BSEXTRACTPAR( msg, BSTOLLENVEC, distTol ) ;
		__DBGpr_int( "NumMins", numMins ) ;
		__DBGpr_dbl( "Dist", dist ) ;
#ifdef vsDEBUG
{ int i ;
		for( i = 0 ; i < numMins ; i++ ) {
			__DBGpr_vec( "Sfpt0", sfpt0[i] ) ;
			__DBGpr_vec( "Sfpt1", sfpt1[i] ) ;
		}
}
#endif
		
		if( dist <= distTol && numMins == 0 ) {
			__DBGpr_com( "Surfaces touch !" ) ;
			*isSfOnSf = TRUE ;
		} else {
			*isSfOnSf = FALSE ;
		}
} */
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( paruv0 ) ; _FREE( paruv1 ) ;
		_FREE( sfpt0  ) ; _FREE( sfpt1  ) ;
		return sts ;

} /* VSisSfOnSf */
/*----------------------------------------------------------------------------*/
long VSfindPlateToBeamJoints( msg, plBot, plTop, bmSol, cst, weldSide, jnGroup )

long			*msg ;
struct GRobj_env	*plBot,		/* Bottom surface of plate 	*/
			*plTop,		/* Top    surface of plate 	*/
			*bmSol ;	/* Solid of beam		*/
struct GRvg_construct	*cst ;
int			weldSide ;
struct GRid		*jnGroup ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_surface	*plGeom[2],	/* Geoms of top & bottom*/
				*bmSfGeom ;	/* Geom of a solid's sf.*/
	struct GRid		*bmSfs ;	/* Surfaces of solid	*/
	struct GRobj_env	*plSfs[2],
				bmSf ;
	int			isSfOnSf,	/* Is surf. on surf. ?	*/
				nbBmSfs,	/* Count of solid's sfs	*/
				ip,		/* Loop-on-surfs index	*/
				ib,		/* Loop-on-surfs index	*/
				ovCount ;	/* Count of matches	*/
	VSmatchingEdges		*ovList ;	/* List of matches	*/

	SetProc( VSfindPlateToBeamJoints ) ; Begin

	bmSfs = NULL ; plGeom[0] = plGeom[1] = NULL ;

	/*
	 * The following two must be set before calling
	 * `vs$findEdgeSurfaceMatch'.
	 */
	ovCount = 0 ;  ovList = NULL ;

	plSfs[0] = plBot ; plSfs[1] = plTop ;
	for( ip = 0 ; ip < 2 ; ip++ ) {
		sts = vs$get_geometry(	msg	= msg,
					grobjId	= &plSfs[ip]->_grid,
					grobjEnv= &plSfs[ip]->mod_env,
					geometry= plGeom + ip ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
	}

	/*
	 * Find all surfaces making solid of beam.
	 */
	sts = VSgetLeavesOfOwnerCmpGraph(	msg,
						&bmSol->_grid,
						&nbBmSfs,
						&bmSfs ) ;
	__CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;

	bmSf.mod_env	= bmSol->mod_env ;

	for( ip = 0 ; ip < 2 ; ip++ ) {
		__DBGpr_obj( "Plate surf ", plSfs[ip]->_grid ) ;
		for( ib = 0 ; ib < nbBmSfs ; ib++ ) {
			__DBGpr_obj( "Beam surf #", bmSfs[ib] ) ;
			sts = vs$get_geometry(	msg	= msg,
						grobjId	= bmSfs + ib,
						grobjEnv= &bmSol->mod_env,
						geometry= &bmSfGeom ) ;
			__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
			
			VSisSfOnSf( msg, plGeom[ip], bmSfGeom, &isSfOnSf ) ;

			_FREE( bmSfGeom ) ;

			if( isSfOnSf ) {
				struct GRobj_env	leftFace,
							rightFace ;
				int			flag = 0;
				/*
				 * Try to find the edges of the beam surface
				 * which are on the plate surface.
				 */
				__DBGpr_obj( "Beam sf", bmSfs[ib] ) ;
				__DBGpr_obj( "... is on plate sf", plSfs[ip]->_grid ) ;
				VSfindLeftRightSurfaces( msg, 
							bmSol,
							plSfs,
							&leftFace,
							&rightFace,
							&flag );
				__DBGpr_int(" Found Left and Right ?", flag );
				if( flag ) {
					/*
					 * right and left faces are filled
					 */
					__DBGpr_com(" Retrieved left and right faces " );
					switch( weldSide ){
					    case VS_K_wldLeftSide  :
						__DBGpr_com("Left Side Weld");
						bmSf._grid  = leftFace._grid ;
						bmSf.mod_env= leftFace.mod_env ;
						break ;

					    case VS_K_wldRightSide :
						__DBGpr_com("Right Side Weld") ;
						bmSf._grid  = rightFace._grid ;
						bmSf.mod_env=rightFace.mod_env ;
						break ;
					    case VS_K_wldBothSides :
						__DBGpr_com("Weld Both Sides") ;
						bmSf._grid  = bmSfs[ib] ;

					    default :
						/*
						 * shouldn't come here
						 */
							break ;
					}
				} else {
				    GRname                  name ;
				    /*
				     * the surface matching must be a begin 
				     * or an end cap of the solid
				     */
				    switch ( weldSide ) {
					case VS_K_wldLeftSide  :
						__DBGpr_com("Weld Left Side" );
						DIstmcpy( name, 
							  VS_K_bmGrCmpName, 
							  VS_K_bmBody,
							  VS_K_nmWebL, 
							  NULL ) ;

						sts = VSgetFaceFromSolid( 
								  msg, 
								  bmSol, 
								  name, 
								  &bmSf._grid );
						break ;

					case VS_K_wldRightSide :
						__DBGpr_com("Weld Right Side" );
						DIstmcpy( name,
							  VS_K_bmGrCmpName,
							  VS_K_bmBody,
							  VS_K_nmWebR,
							  NULL ) ;

						sts = VSgetFaceFromSolid(
								msg,
								bmSol,
								name,
								&bmSf._grid ) ;
						break ;

					case VS_K_wldBothSides :
						__DBGpr_com("Weld Both Sides" );
						bmSf._grid = bmSfs[ib] ;
						break ;
				    }
				}
				__DBGpr_obj(" Beam surface", bmSf._grid );
				sts = vs$findEdgeSurfaceMatch(
						msg		= msg,
						sfForEdges	= &bmSf,
						surface		= plSfs[ip],
						matchCount	= &ovCount,
						matchList	= &ovList ) ;
				__CheckRC( sts, *msg, "vs$findEdgeSurfaceMatch", wrapup ) ;
				__DBGpr_int( "Count of matches", ovCount ) ;
				break ;
			}
		}
		__DBGpr_int( "Count of matches", ovCount ) ;
	}
	if(!( ovCount ) ) {
		struct GRobj_env	*plateSf  = NULL ;
		/*
		 * Beam might be penetrating the plate
		 */
		__DBGpr_int(" Weld Side ", weldSide );
		switch( weldSide ){
		    case VS_K_wldLeftSide  :
			__DBGpr_com(" Left Side Weld") ;
			plateSf = plBot ;
			break ;

		    case VS_K_wldRightSide :
			__DBGpr_com("Right Side Weld") ;
			plateSf = plTop ;
			break ;
		    default :
			/*
			 * It is the case of both sides welding. It is handled
			 * below in the else case 
			 */
			__DBGpr_com("Both Sides Weld") ;
			break ;
		}
		if( plateSf ) { 
			sts = VSgetJntFromInter( msg, plateSf, bmSol, cst, 
						&ovCount, &ovList );
			__CheckRC( sts, *msg, "VSgetJntFromInter", wrapup ) ;
		} else {
			plateSf = plBot ;

			sts = VSgetJntFromInter( msg, plateSf, bmSol, cst, 
						&ovCount, &ovList );
			/*
			 * do not check for return code
			 */

			plateSf = plTop ;

			sts = VSgetJntFromInter( msg, plateSf, bmSol, cst, 
						&ovCount, &ovList );
			/*
			 * do not check for return code
			 */
		}
	}
	if( ovCount ) {
		sts = VSprocessJntMatches( msg, ovCount, ovList, cst, jnGroup );
		__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;

		__DBGpr_obj( "Joint Group", *jnGroup ) ;
		
	} else vs$failure() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( bmSfs ) ; _FREE( plGeom[0] ) ; _FREE( plGeom[1] ) ;

		if( ovList ) VSfreeMatchList( ovList ) ;
		End
		return sts ;

} /* VSfindPlateToBeamJoints */
/*----------------------------------------------------------------------------*/
long VSfindPlateToStfnJoints( msg, plSide, bmFlg, cst, jnGroup )

long			*msg ;
struct GRobj_env	*plSide,	/* Side of plate stiffener is on*/
			*bmFlg ;	/* Flange of beam on plate	*/
struct GRvg_construct	*cst ;
struct GRid		*jnGroup ; {

	long			sts ;		/* OM return code	*/
	struct IGRbsp_surface	*sideGeom,	/* Geoms plate side	*/
				*flgGeom ;	/* Geom of beam flange	*/
	int			isSfOnSf ;	/* Is surf. on surf. ?	*/

	SetProc( VSfindPlateToStfnJoints ) ; Begin

	sideGeom = flgGeom = NULL ;

	__DBGpr_obj( "Plate side", plSide->_grid ) ;
	__DBGpr_obj( "Beam flange", bmFlg->_grid ) ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &plSide->_grid,
				grobjEnv= &plSide->mod_env,
				geometry= &sideGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts = vs$get_geometry(	msg	= msg,
				grobjId	= &bmFlg->_grid,
				grobjEnv= &bmFlg->mod_env,
				geometry= &flgGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	VSisSfOnSf( msg, sideGeom, flgGeom, &isSfOnSf ) ;

	if( !isSfOnSf ) {
		__DBGpr_com( "Beam flange not on plate side" ) ;
		vs$failure() ;
	}

	/*
	 * Try to find the edges of the beam's flange which are on the plate
	 * side.
	 */
	sts = VSfindSfToSfJoints(	msg,
					VS_K_TRY_EDGE_SF,
					bmFlg,
					plSide,
					cst,
					jnGroup ) ;
	__CheckRC( sts, *msg, "VSfindSfToSfJoints", wrapup ) ;

	if( *msg == EMS_I_NoSolution ) {
		__DBGpr_com( "No solution" ) ;
		vs$failure() ;
	}

	__DBGpr_obj( "Joint Group", *jnGroup ) ;

	wrapup :
		_FREE( sideGeom ) ; _FREE( flgGeom ) ;
		End
		return sts ;

} /* VSfindPlateToStfnJoints */
/*----------------------------------------------------------------------------*/


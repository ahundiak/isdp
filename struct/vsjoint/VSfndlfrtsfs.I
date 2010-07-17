/* $Id: VSfndlfrtsfs.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSfndlfrtsfs.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfndlfrtsfs.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:07:40  pinnacle
# Created: vsjoint/VSfndlfrtsfs.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
        I/STRUCT
*/
class implementation VSfeature ;

#include <stdio.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "EMSutlmacros.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bserr.h"
#include "bsmdistsfsf.h"

/*----------------------------------------------------------------------------*/
long VSgetFaceFromSolid( msg, bmSol, faceName, webFace )
long			*msg ;
struct GRobj_env	*bmSol ;
GRname			faceName;
struct GRid 		*webFace ; {

	long			sts ;
	OM_S_OBJECT_LINKAGE     owner ;
	OM_S_CHANSELECT         toOwner ;
	struct GRid		beam ;
	long			rc ;

	/*
	 * From the solid given get the structural beam object
	 */
 
	ems$make_chanselect(    chan_label      = GRconnector_to_owners,
				chan_selector   = &toOwner ) ;
 
	sts = om$get_channel_objects(   objid       = bmSol->_objid,
					osnum       = bmSol->_osnum,
					p_chanselect= &toOwner,
					list        = &owner,
					count       = (OMuint *) &rc,
					size        = 1 ) ;
	if( !( sts & 1 ) || !rc ) {
		*msg = EMS_E_NoSolution ;
		sts  = OM_W_ABORT ;
		goto wrapup ;
	}
 
	beam.objid   = owner.S_objid ;
	beam.osnum   = owner.osnum ;

	__DBGpr_obj("Beam Object ", beam );
	__DBGpr_str(" Beam Face", faceName );

	sts = om$send ( msg = message NDmacro.ACreturn_foot (
							msg, 
							faceName,
							webFace,
							NULL, NULL ),
			senderid = beam.objid ,
			targetid = beam.objid ,
			targetos = beam.osnum ) ;
	__CheckRC( sts, *msg, " NDmacro.ACreturn_foot", wrapup );
	__DBGpr_obj(" Face Object", *webFace );

wrapup :
	return sts ;

} /* long VSgetFaceFromSolid */
/*----------------------------------------------------------------------------*/
int VSbeginOrEndCap( struct GRid   	beam,
		     struct GRid	bmSf ) {

	int		match = FALSE;
	long		sts , msg ;
	struct GRid	endSf ;
	GRname		endCap, beginCap ;

	/*
	 * get the begin and end caps of the beam object
	 */
	sprintf( beginCap,"%s:%s",VS_K_bmGrCmpName,VS_K_bmBeginCap);
	__DBGpr_str( "Begin  Cap", beginCap ) ;

	sts = om$send ( msg = message NDmacro.ACreturn_foot (
							&msg, 
							beginCap,
							&endSf,
							NULL, NULL ),
				senderid = beam.objid ,
				targetid = beam.objid ,
				targetos = beam.osnum ) ;
	__CheckRC( sts, msg, " NDmacro.ACreturn_foot", wrapup );
	/*
	 * Check if the surface is matching with the beams begin or end cap
	 */
	if( IF_EQ_GRID( endSf, bmSf) ) {
		match = TRUE ;
		goto wrapup ;
	}

	sprintf( endCap, "%s:%s", VS_K_bmGrCmpName, VS_K_bmEndCap ) ;
	__DBGpr_str( "End  Cap", endCap ) ;

	sts = om$send ( msg = message NDmacro.ACreturn_foot (
							&msg, 
							endCap,
							&endSf,
							NULL, NULL ),
				senderid = beam.objid ,
				targetid = beam.objid ,
				targetos = beam.osnum ) ;
	__CheckRC( sts, msg, " NDmacro.ACreturn_foot", wrapup );

	/*
	 * Check if the surface is matching with the beams begin or end cap
	 */
	if( IF_EQ_GRID( endSf, bmSf ) ) {
		match = TRUE ;
	}

wrapup :
	return match ;	

}/* int VSbeginOrEndCap */
/*----------------------------------------------------------------------------*/
long VSfindLeftRightSurfaces( 	
			long			*msg ,
			struct GRobj_env	*bmSol, 
			struct GRobj_env	*plSfs[2], 
			struct GRobj_env	*leftFace, 
			struct GRobj_env	*rightFace,
			int			*flag  ) 	{

	long			sts ;
	struct GRid             beam, 
				*bmSfs ;        /* Surfaces of solid    */
	struct GRobj_env        lfSf, rtSf ;
	int                     isSfOnSf,       /* Is surf. on surf. ?  */
				nbBmSfs,        /* Count of solid's sfs */
				ip,             /* Loop-on-surfs index  */
				ib ;            /* Loop-on-surfs index  */
	 struct IGRbsp_surface  *plGeom[2],     /* Geoms of top & bottom*/
				*lfGeom,	/* left webs geomtry	*/
				*rtGeom,	/* right webs geometry	*/
				*srfGeom,	/* surface geometry	*/
                                *bmSfGeom ;     /* Geom of a solid's sf.*/
	long			rc ;

	SetProc( VSfindLeftRightSurfaces ) ; Begin
 
        lfGeom = NULL ; rtGeom = NULL ; srfGeom = NULL ;
	bmSfs = NULL ; plGeom[0] = plGeom[1] = NULL ;

	leftFace->_objid = NULL_OBJID ;
	rightFace->_objid = NULL_OBJID ;
 
        for( ip = 0 ; ip < 2 ; ip++ ) {
                sts = vs$get_geometry(  msg     = msg,
                                        grobjId = &plSfs[ip]->_grid,
                                        grobjEnv= &plSfs[ip]->mod_env,
                                        geometry= plGeom + ip ) ;
                __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
        }
 
        /*
         * Find all surfaces making solid of beam.
         */
        sts = VSgetLeavesOfOwnerCmpGraph(       msg,
                                                &bmSol->_grid,
                                                &nbBmSfs,
                                                &bmSfs ) ;
        __CheckRC( sts, *msg, "VSgetLeavesOfOwnerCmpGraph", wrapup ) ;

	/*
	 * get the original beam/stiffener which is owners channel
	 */
	{
	        OM_S_OBJECT_LINKAGE     owner ; 
		OM_S_CHANSELECT		toOwner ;
 
		ems$make_chanselect(  	chan_label      = GRconnector_to_owners,
					chan_selector   = &toOwner ) ;

		sts = om$get_channel_objects( 	objid 	    = bmSol->_objid,
						osnum 	    = bmSol->_osnum,
						p_chanselect= &toOwner,
						list        = &owner,
						count 	    = (OMuint *) &rc,
						size        = 1 ) ;
		if( !( sts & 1 ) || !rc ) {
			*msg = EMS_E_NoSolution ; 
			sts  = OM_W_ABORT ; 
			goto wrapup ;
		}
 
		beam.objid   = owner.S_objid ;
		beam.osnum   = owner.osnum ;
	}

        rtSf.mod_env = lfSf.mod_env    = bmSol->mod_env ;
 
        for( ip = 0 ; ip < 2 ; ip++ ) {
                __DBGpr_obj( "Plate surf ", plSfs[ip]->_grid ) ;
                for( ib = 0 ; ib < nbBmSfs ; ib++ ) {
                        __DBGpr_obj( "Beam surf #", bmSfs[ib] ) ;
			/*
			 * Get the geometry of the
			 */
                        sts = vs$get_geometry(  msg     = msg,
                                                grobjId = bmSfs + ib,
                                                grobjEnv= &bmSol->mod_env,
                                                geometry= &bmSfGeom ) ;
                        __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
 
                        VSisSfOnSf( msg, plGeom[ip], bmSfGeom, &isSfOnSf ) ;
 
			_FREE( bmSfGeom ) ;
 
                        if( isSfOnSf ) {
                                /*
                                 * Try to find the edges of the beam surface
                                 * which are on the plate surface.
                                 */
				__DBGpr_obj( "Beam sf", bmSfs[ib] ) ;	
				__DBGpr_obj( "... is on plate sf", 
							  plSfs[ip]->_grid ) ;
				/*
				 * This is not the first surface, Surface is in
				 * in the middle of the count
				 */
				if( ib ) {
					if( ib != nbBmSfs -1 && 
					    ib != nbBmSfs -2 ) {
						/*
						 * If the next surface is a 
						 * begin cap or an end cap 
						 * then the first surface 
						 * is to be taken
						 */
						lfSf._grid = bmSfs[ib - 1] ;
						if( ib == (nbBmSfs - 3) ) {
							rtSf._grid = bmSfs[0] ;
						} else {
							rtSf._grid =bmSfs[ib+1];
						}
						*flag = TRUE ;
					} else {
						*flag = FALSE ;
					}
				} else {
					/*
					 * Oops it is the first surface
					 * Take the next and the last surface 
					 * excluding the begin cap and end cap
					 */
					lfSf._grid = bmSfs[ib + 1] ;
					rtSf._grid = bmSfs[nbBmSfs -2];
					*flag = TRUE ;
				}
				break ;
			}
		}
	}
	if( *flag ) {
		GRname 			webR, webL;
		struct GRid		webLf, webRt ; 
		IGRboolean		assignedLeft = FALSE ,
					assignedRight = FALSE ;


		DIstmcpy( webR, VS_K_bmGrCmpName,
					VS_K_bmBody, VS_K_nmWebR, NULL ) ;
 
                __DBGpr_str( "Web Right", webR ) ;

		/*
		 * Sort the left and right surfaces so that they are close
		 * to the left and right web respectively.
		 */
		__DBGpr_obj("Beam Object ", beam );
		sts = om$send ( msg = message NDmacro.ACreturn_foot (
							msg, webR,
							&webRt,
							NULL, NULL ),
				senderid = beam.objid ,
				targetid = beam.objid ,
				targetos = beam.osnum ) ;
		if( !( sts & *msg & 1 ) )  {
			__DBGpr_com(" Web Right Evaluation FAILED ");
			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;
			leftFace->_grid 	= lfSf._grid ;
			leftFace->mod_env 	= lfSf.mod_env ;

			rightFace->_grid 	= rtSf._grid ;
			rightFace->mod_env 	= rtSf.mod_env ;
			goto wrapup ;
		}
		/*
		 * make sure that the surfaces are not the either web left 
		 * or web right surface. If they are same then the mininum
		 * distance algo may not give a distance of `zero`
		 */
		if( IF_EQ_GRID( webRt, lfSf._grid ) ) {
			/*
			 * Matching with web right
			 */
			 __DBGpr_com(" Matching with web right " );
			rightFace->_grid 	= lfSf._grid ;
			rightFace->mod_env 	= lfSf.mod_env ;
			assignedLeft		= TRUE ;
		} else if( IF_EQ_GRID( webRt, rtSf._grid ) ) {
			/*
			 * Matching with web right
			 */
			 __DBGpr_com(" Matching with web right " );
			rightFace->_grid 	= rtSf._grid ;
			rightFace->mod_env 	= rtSf.mod_env ;
			assignedRight		= TRUE ;
		}
			
		DIstmcpy( webL, VS_K_bmGrCmpName,
					VS_K_bmBody, VS_K_nmWebL, NULL ) ;
 
                __DBGpr_str( "Web Left", webL ) ;

		sts = om$send ( msg = message NDmacro.ACreturn_foot (
							msg, webL,
							&webLf,
							NULL, NULL ),
				senderid = beam.objid ,
				targetid = beam.objid ,
				targetos = beam.osnum ) ;
		if( !( sts & *msg & 1 ) )  {
			__DBGpr_com(" Web Left Evaluation FAILED ");
			/*
			 * check if the one surface is assigned, if so
			 * assign the other surface
			 */
			if( assignedLeft ) {
				rightFace->_grid  = rtSf._grid ;
				rightFace->mod_env= rtSf.mod_env ;
				assignedRight	  = TRUE ;
			}
			if( assignedRight ) {
				rightFace->_grid  = lfSf._grid ;
				rightFace->mod_env= lfSf.mod_env ;
				assignedLeft	  = TRUE ;
			}
			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;
			goto wrapup ;
		}
		if( IF_EQ_GRID( webLf, lfSf._grid ) ) {
			/*
			 * Matching with web left
			 */
			 __DBGpr_com(" Matching with web left " );
			leftFace->_grid 	= lfSf._grid ;
			leftFace->mod_env 	= lfSf.mod_env ;
			assignedLeft 		= TRUE ;
			/*
			 * you can exit successfully, the sorting is complete
			 */
			if( assignedRight ) goto wrapup ;
		} else if( IF_EQ_GRID( webLf, rtSf._grid ) ) {
			/*
			 * Matching with web left
			 */
			leftFace->_grid 	= rtSf._grid ;
			leftFace->mod_env 	= rtSf.mod_env ;
			assignedRight 		= TRUE ;
			/*
			 * you can exit successfully, the sorting is complete
			 */
			if( assignedLeft ) goto wrapup ;
		}
		/*
		 * if both not assigned then peace.
		 */
		if( (assignedLeft) & !(assignedRight) ) {
			if( leftFace->_objid == NULL_OBJID ) {
				leftFace->_grid   = rtSf._grid ;
				leftFace->mod_env = rtSf.mod_env ;
			} else if( rightFace->_objid == NULL_OBJID ) {
				rightFace->_grid   = rtSf._grid ;
				rightFace->mod_env = rtSf.mod_env ;
			}
		}
		if( !(assignedLeft) & (assignedRight) ) {
			if( leftFace->_objid == NULL_OBJID ) {
				leftFace->_grid   = lfSf._grid ;
				leftFace->mod_env = lfSf.mod_env ;
			} else if( rightFace->_objid == NULL_OBJID ) {
				rightFace->_grid   = lfSf._grid ;
				rightFace->mod_env = lfSf.mod_env ;
			}
		}
		__DBGpr_com(" Evaluating geometry of web left and web right\n");
		/*
		 * get the geometry of web left and web right surfaces
		 */
		vs$get_geometry(	msg	= msg ,
					grobjId	= &webLf,
					grobjEnv= &bmSol->mod_env,
					geometry= &lfGeom ) ;
		__CheckRC(1, *msg, "vs$get_geometry", wrapup ) ;

		vs$get_geometry(	msg	= msg ,
					grobjId	= &webRt,
					grobjEnv= &bmSol->mod_env,
					geometry= &rtGeom ) ;
		__CheckRC(1, *msg, "vs$get_geometry", wrapup ) ;

		vs$get_geometry(	msg	= msg ,
					grobjId	= &lfSf._grid,
					grobjEnv= &lfSf.mod_env,
					geometry= &srfGeom ) ;
		__CheckRC(1, *msg, "vs$get_geometry", wrapup ) ;
		
		{
		int             numMins ;
		double          *paruv0 = NULL,
				*paruv1 = NULL,
				leftDist, rightDist ;
		IGRpoint        *sfpt0  = NULL,
				*sfpt1  = NULL ;

		BSmdistsfsf( lfGeom, srfGeom, &numMins, &paruv0, &paruv1,
				&sfpt0, &sfpt1, &leftDist, &rc );
		_FREE( paruv0 ) ; _FREE( paruv1 ) ;
		_FREE( sfpt0  ) ; _FREE( sfpt1  ) ;

		if( BSERROR( rc ) ) { vs$error( msgval = EMS_E_BSerror ) ; }


		BSmdistsfsf( rtGeom, srfGeom, &numMins, &paruv0, &paruv1,
				&sfpt0, &sfpt1, &rightDist, &rc );
		_FREE( paruv0 ) ; _FREE( paruv1 ) ;
		_FREE( sfpt0  ) ; _FREE( sfpt1  ) ;

		if( BSERROR( rc ) ) { vs$error( msgval = EMS_E_BSerror ) ; }

		if( leftDist< rightDist ) {
			leftFace->_grid 	= lfSf._grid ;
			leftFace->mod_env= lfSf.mod_env ;

			rightFace->_grid  = rtSf._grid ;
			rightFace->mod_env= rtSf.mod_env ;
		} else {
			leftFace->_grid 	= rtSf._grid ;
			leftFace->mod_env= rtSf.mod_env ;

			rightFace->_grid  = lfSf._grid ;
			rightFace->mod_env= lfSf.mod_env ;
		}
		}
	}

wrapup :
	_FREE( bmSfGeom ); _FREE( lfGeom ) ; _FREE( rtGeom ) ;
	_FREE( bmSfs ) ; _FREE( plGeom[0] ) ; _FREE( plGeom[1] ) ;

	End
	return sts ;

}/* long VSfindLeftRightSurfaces */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

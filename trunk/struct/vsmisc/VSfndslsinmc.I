/*
 * I/STRUCT
 */
class implementation ACncpx ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetmacinfo.h"
#include "vsstrngproto.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
extern long	VSdrwIsSolidOrSurface() ;

from ACcpx_defn	import ACgive_name ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSfindSolidsSurfacesInMacro( msg, macId, macEnv, listOfSolSfs, 
			          countOfSolSfs )

long			*msg ;
struct GRid		*macId ;
struct GRmd_env		*macEnv ;
struct GRobj_env	**listOfSolSfs ;
int			*countOfSolSfs ; {

	long			sts ;		/* OM return code	*/
	struct GRid		macroDef ;	/* Id of macro def	*/
	struct myfeet		*feetInfo ;	/* Names of feet	*/
	int			nbFeet,		/* Count of feet	*/
				i,		/* Loop index		*/
				ftIndex ;	/* For ACgive_structure	*/
	struct GRobj_env	ftId ;		/* Id of one foot	*/
	IGRmatrix		ftMx ;		/* Matrix of one foot	*/
	short			ftMxType ;	/* Type of the above	*/
	struct ret_struct	ftInfo ;	/* Info about one foot	*/
	struct GRobj_env	**ssList ;
	int			*ssCount,
				totCount,
				sol1_surf0 ;

	*listOfSolSfs	= NULL ;
	*countOfSolSfs	= 0 ;
	ssList		= NULL ;
	ssCount		= NULL ;

	sts = om$send(	msg	= message ACcpx.find_macro( &macroDef ),
			senderid= NULL_OBJID,
			targetid= macId->objid,
			targetos= macId->osnum ) ;
	if( !( sts & 1 ) ) vs$inv_arg() ;

	sts = VSgetMacroInformation(	msg,
					NULL,
					&macroDef,
					NULL,
					NULL,
					NULL,
					&nbFeet,
					&feetInfo,
					NULL ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( !( ssList = _MALLOC( nbFeet, struct GRobj_env * ) ) )
		vs$mem_fail() ;
	if( !( ssCount= _MALLOC( nbFeet, int ) ) )
		vs$mem_fail() ;

	for( i = 0 ; i < nbFeet ; i++ ) {

		ssCount[i]	= 0 ;
		ssList[i]	= NULL ;
		ftIndex		= -1 ;

		sts = om$send(	msg	= message NDmacro.ACgive_structure(
							(int *) msg,
							&ftIndex,
							feetInfo[i].name,
							&ftInfo,
							macEnv ),
				senderid= NULL_OBJID,
				targetid= macId->objid,
				targetos= macId->osnum ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							feetInfo[i].name,
							&ftId._grid,
							&ftMxType,
							ftMx ),
				senderid= NULL_OBJID,
				targetid= macId->objid,
				targetos= macId->osnum ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		ftId.mod_env.md_id = macEnv->md_id ;
		VSmulmx( macEnv->_MATRIX, ftMx,
			 ftId._matrix, &ftId._matrix_type ) ;

		if( ftInfo.type & macro_generic ) {

			sts = VSfindSolidsSurfacesInMacro( msg,
							   &ftId._grid,
							   &ftId.mod_env,
							   ssList + i,
							   ssCount + i ) ;
			if( !( sts & 1 & *msg ) ) {
				ssList[i] = NULL ; ssCount[i] = 0 ;
			}
		} else if( ftInfo.type & other_generic ||
		           ftInfo.type & debug_type    ) {
		           	/* 'debug_type' is only for plane.
		           	   (Because of Robert Patience's need) */
			sts = VSdrwIsSolidOrSurface( msg,
				                     &ftId._grid,
				                     &ftId.mod_env,
				                     &sol1_surf0 ) ;
				                     
			if( *msg == MSSUCC ) {
				ssCount[i] = 1 ;
				ssList[i]  = (struct GRobj_env *)
						VSmemdup(
							&ftId,
							sizeof( struct GRobj_env ) );
				if( !( ssList[i] ) ) vs$mem_fail() ; 
			}
		}
	}

	totCount = 0 ;
	for( i = 0 ; i < nbFeet ; i++ ) {
		totCount += ssCount[i] ;
	}

	if( totCount ) {
		int	j,
			k ;

		if( !( *listOfSolSfs = _MALLOC( totCount, struct GRobj_env ) ) )
			vs$mem_fail() ;

		for( i = k = 0 ; i < nbFeet ; i++ ) {
			for( j = 0 ; j < ssCount[i] ; j++ ) {
				(*listOfSolSfs)[k++] = ssList[i][j] ;
			}
		}
		*countOfSolSfs = totCount ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( ssCount ) ;
		if( ssList ) {
			for( i = 0 ; i < nbFeet ; i++ ) {
				_FREE( ssList[i] ) ;
			}
			free( ssList ) ;
		}
		return sts ;

} /* VSfindSolidsSurfacesInMacro */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VSfindSolidsSurfacesInMacroSet( msg, macIds, macEnv, macCount,
				     listOfSolSfs, countOfSolSfs )

long			*msg ;
struct GRid		*macIds ;
struct GRmd_env		*macEnv ;
int			macCount ;
struct GRobj_env	**listOfSolSfs ;
int			*countOfSolSfs ; {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	**ssList ;
	int			*ssCount,
				totCount,
				i ;
	struct GRid		virtualId ;
	struct GRmd_env		virtualEnv ;

	*listOfSolSfs	= NULL ;
	*countOfSolSfs	= 0 ;
	ssList		= NULL ;
	ssCount		= NULL ;

	if( !( ssList = _MALLOC( macCount, struct GRobj_env * ) ) )
		vs$mem_fail() ;
	if( !( ssCount= _MALLOC( macCount, int ) ) )
		vs$mem_fail() ;

	for( i = 0 ; i < macCount ; i++ ) {
		
		ssCount[i]	= 0 ;
		ssList[i]	= NULL ;
		
		sts = VSgetVirtualInfo( msg,
					macIds + i,
					&virtualEnv,
					&virtualId ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		sts = VSfindSolidsSurfacesInMacro( msg,
						   &virtualId,
						   &virtualEnv,
						   ssList + i,
						   ssCount + i ) ;
		if( !( sts & 1 & *msg ) ) continue ;
	}

	totCount = 0 ;
	for( i = 0 ; i < macCount ; i++ ) {
		totCount += ssCount[i] ;
	}

	if( totCount ) {
		int	j,
			k ;

		if( !( *listOfSolSfs = _MALLOC( totCount, struct GRobj_env ) ) )
			vs$mem_fail() ;

		for( i = k = 0 ; i < macCount ; i++ ) {
			for( j = 0 ; j < ssCount[i] ; j++ ) {
				(*listOfSolSfs)[k++] = ssList[i][j] ;
			}
		}
		*countOfSolSfs = totCount ;
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( ssCount ) ;
		if( ssList ) {
			for( i = 0 ; i < macCount ; i++ ) {
				_FREE( ssList[i] ) ;
			}
			free( ssList ) ;
		}
		return sts ;

} /* VSfindSolidsSurfacesInMacroSet */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;

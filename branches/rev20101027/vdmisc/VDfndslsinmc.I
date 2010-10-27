/*
 * 	I/VDS	Copy
 */
class implementation ACncpx ;

#include <stdlib.h>
#include "EMSmsgdef.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_getmacinfo.h"
#include "v_strngproto.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"

extern long	VD_drwIsSolidOrSurface() ;

from ACcpx_defn	import ACgive_name ;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VD_findSolidsSurfacesInMacro( msg, macId, macEnv, listOfSolSfs, 
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
	if( !( sts & 1 ) ) vd_$inv_arg() ;

	sts = VD_getMacroInformation(	msg,
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
		vd_$mem_fail() ;
	if( !( ssCount= _MALLOC( nbFeet, int ) ) )
		vd_$mem_fail() ;

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
		VD_mulmx( macEnv->_MATRIX, ftMx,
			 ftId._matrix, &ftId._matrix_type ) ;

		if( ftInfo.type & macro_generic ) {

			sts = VD_findSolidsSurfacesInMacro( msg,
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
			sts = VD_drwIsSolidOrSurface( msg,
				                     &ftId._grid,
				                     &ftId.mod_env,
				                     &sol1_surf0 ) ;
				                     
			if( *msg == MSSUCC ) {
				ssCount[i] = 1 ;
				ssList[i]  = (struct GRobj_env *)
						VD_memdup(
							&ftId,
							sizeof( struct GRobj_env ) );
				if( !( ssList[i] ) ) vd_$mem_fail() ; 
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
			vd_$mem_fail() ;

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

} /* VD_findSolidsSurfacesInMacro */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VD_findSolidsSurfacesInMacroSet( msg, macIds, macEnv, macCount,
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
		vd_$mem_fail() ;
	if( !( ssCount= _MALLOC( macCount, int ) ) )
		vd_$mem_fail() ;

	for( i = 0 ; i < macCount ; i++ ) {
		
		ssCount[i]	= 0 ;
		ssList[i]	= NULL ;
		
		sts = VD_getVirtualInfo( msg,
					macIds + i,
					&virtualEnv,
					&virtualId ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		sts = VD_findSolidsSurfacesInMacro( msg,
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
			vd_$mem_fail() ;

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

} /* VD_findSolidsSurfacesInMacroSet */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;

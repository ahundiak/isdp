/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "DImacros.h"

/*
 * Profiles are cached in directories with path:
 *	struct:<material>:<family>:<part>
 * Composite profiles have a family name starting with '#'.
 */
#define	MAT	0
#define FAM	1
#define MAX	2
/*----------------------------------------------------------------------------*/
static long VSgetCmpPrflRdbDataFromDir( msg, osnum, dirs, p_count, p_entries )

OMuword	osnum ;
long	*msg ;
char	*dirs[MAX],
	***p_entries ;
int	*p_count ; {

	long	sts ;
	char	osName[DI_PATH_MAX],
		dir[DI_PATH_MAX],
		**entries,
		*p ;
	int	i,
		count,
		keepPounds,
		nbPounds ;

	count = *p_count = 0 ; entries = *p_entries = NULL ;

	sts = di$give_pathname(	osnum = osnum, 	pathname = osName ) ;
	if( !( sts & 1 ) ) vs$error( stsval = sts, msgval = EMS_E_DirName ) ;

	sts = DIstmcpy(	dir,
			osName,
			"struct",
			dirs[MAT],
			dirs[FAM],
			NULL ) ;
	if( !( sts & 1 ) ) vs$error( stsval = sts, msgval = EMS_E_DirName ) ;

	sts = di$find(	start_dir	= dir,
			lines		= &entries,
			ptr		= &count,
			max_level	= 1,
			options		= 0 ) ;
	if( !( sts & 1 ) ) {
		/*
		 * Directory does not exist ...
		 */
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	/*
	 * We only look here for families of composite profiles whose family
	 * name starts with '#'.
	 */
	keepPounds = dirs[MAT] && !dirs[FAM] ;
	for( nbPounds = i = 0 ; i < count ; i++ ) {
		p = strrchr( entries[i], DIR_G_car_dir ) + 1 ;

		if( keepPounds && *p == '#' ) nbPounds++ ;
		OM_BLOCK_MOVE(	/* From */ p,		
				/* To	*/ entries[i],		
				/* Bytes*/ ( 1 + strlen( p ) ) * sizeof *p ) ;
	}

	if( keepPounds ) {
		if( nbPounds ) {
			int	j ;
			char	**buf = NULL ;

			buf = _MALLOC( nbPounds, char * ) ;
			if( !buf ) vs$mem_fail() ;
			for( j = i = 0 ; i < count ; i++ ) {
				if( *entries[i] == '#' ) {
					buf[j++] = entries[i] ;
				} else {
					free( entries[i] ) ; entries[i] = NULL ;
				}
			}
			free( (char *) entries ) ;
			entries = buf ;
			count	= nbPounds ;
		} else {
			di$free( lines = entries, count = count ) ;
			count = 0 ; entries = NULL ;
		}
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	*p_count	= count ;
	*p_entries	= entries ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			di$free( lines = entries, count = count ) ;
		}
		return sts ;

} /* VSgetCmpPrflRdbDataFromDir */
/*----------------------------------------------------------------------------*/
long VSgetMatsInDir( msg, osnum, p_count, p_mats )

OMuword	osnum ;
long	*msg ;
char	***p_mats ;
int	*p_count ; {

	char	*dirs[MAX] ;

	dirs[MAT] = dirs[FAM] = NULL ;

	return VSgetCmpPrflRdbDataFromDir( msg, osnum, dirs, p_count, p_mats ) ;

} /* VSgetMatsInDir */
/*----------------------------------------------------------------------------*/
long VSgetCmpPrflFamsFromDir( msg, osnum, material, p_count, p_fams )

OMuword	osnum ;
long	*msg ;
char	*material,
	***p_fams ;
int	*p_count ; {

	char	*dirs[MAX] ;

	dirs[MAT] = material ;
	dirs[FAM] = NULL ;

	return VSgetCmpPrflRdbDataFromDir( msg, osnum, dirs, p_count, p_fams ) ;

} /* VSgetCmpPrflFamsFromDir */
/*----------------------------------------------------------------------------*/
long VSgetCmpPrflPrtsFromDir( msg, osnum, material, family, p_count, p_prts )

OMuword	osnum ;
long	*msg ;
char	*material,
	*family,
	***p_prts ;
int	*p_count ; {

	char	*dirs[MAX] ;

	dirs[MAT] = material ;
	dirs[FAM] = family ;

	return VSgetCmpPrflRdbDataFromDir( msg, osnum, dirs, p_count, p_prts ) ;

} /* VSgetCmpPrflPrtsFromDir */
/*----------------------------------------------------------------------------*/

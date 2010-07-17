/*
	I/STRUCT
*/ 
class implementation VSrflPlate ;

#include <string.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
long VSfindFindNameForRflElem( msg, elmInRef, rflElem )

long		*msg ;
struct GRid	*elmInRef,
		*rflElem ; {

	long		sts ;
	GRname		rflPath,
			rflRelDir,
			rflName,
			rflBasename,
			elmInRefNm,
			osName,
			tmp ;
	struct GRid	dir ;
	char		*p ;
	int		time,
			goOn ;

	sts = om$send(	msg	= message GRgraphics.GRgetname(
							msg, elmInRefNm ),
			senderid= NULL_OBJID,
			targetid= elmInRef->objid,
			targetos= elmInRef->osnum ) ;
	if( !( sts & 1 & *msg ) || !*elmInRefNm ) {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	__DBGpr_str( "Name of parent in ref. file", elmInRefNm ) ;

	/*
	 * Get base name of parent in reference file.
	 */
	if( p = strrchr( elmInRefNm, DIR_G_car_dir ) ) {
		strcpy( rflBasename, p + 1 ) ;
		__DBGpr_str( "Base name for rfl elem", rflBasename ) ;
	} else {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	for( time = 0, goOn = TRUE ; goOn ; ) {
		p = strrchr( elmInRefNm, DIR_G_car_dir ) ;

		if( !p )			goOn = FALSE ;
		else if( p == elmInRefNm )	break ;
		else				*p = '\0' ;

		*msg = di$translate(	objname	= elmInRefNm,
					p_objid	= &dir.objid,
					p_osnum	= &dir.osnum ) ;
		if( !( *msg & 1 ) ) {
			sts = OM_W_ABORT ; goto wrapup ;
		}

		if( vs$is_ancestry_valid(
					object	= &dir,
					classid = DIR_G_DIlink_clid ) ) {
			goOn = FALSE ;
		}

		if( time == 0 ) {
			*rflRelDir = '\0' ;
			time = 1 ;
		} else {

			if( time == 1 ) time = 2 ;

			strcpy( tmp, rflRelDir ) ;
			*rflRelDir = DIR_G_car_dir ;
			strcpy( rflRelDir + 1, p + 1 ) ;
			strcat( rflRelDir, tmp ) ;
		}
	}
	__DBGpr_str( "Rel dir", rflRelDir ) ;

	di$give_pathname(	osnum	= rflElem->osnum,
				pathname= osName ) ;
	__DBGpr_str( "OS name", osName ) ;

	if( *rflRelDir ) {

		DIstmcpy(rflPath,
			 osName,
			 rflRelDir + 1,	/* Begins with ':', skip it */
			 NULL ) ;

		if( rflRelDir[strlen(rflRelDir) - 1] != DIR_G_car_dir ) {
			strcat( rflPath, DIR_G_str_dir ) ;
		}
		__DBGpr_str( "di$mkpath of", rflPath ) ;
		*msg = di$mkpath( pathname = rflPath ) ;
		if( !( *msg & 1 ) && *msg != DIR_E_DIR_DUP ) {
			__DBGpr_com( "di$mkpath FAILED\n" ) ;
			sts = OM_W_ABORT ; goto wrapup ;
		}
	} else {
		/* 
		 * Directly under "usr".
		 */
		strcpy( rflPath, osName ) ;
	}

	VSbuildName( msg, rflPath, rflBasename, rflBasename ) ;

	DIstmcpy( rflName, rflPath, rflBasename, NULL ) ;
	__DBGpr_str( "Put name", rflName ) ;

	sts = om$send(	msg	= message GRgraphics.GRputname( msg, rflName ),
			senderid= NULL_OBJID,
			targetid= rflElem->objid,
			targetos= rflElem->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRputname", wrapup ) ;

	wrapup :
		return sts ;

} /* VSfindFindNameForRflElem */
/*----------------------------------------------------------------------------*/

end implementation VSrflPlate ;

/*
 	I/STRUCT
*/
class implementation VSmacpalCmd ;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <FI.h>
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "EMSmsgdef.h"
#include "palgo.h"
#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "vsglobalmsg.h"
#include "vsicondef.h"
#include "vsmacintdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "GRpallib.h"
#include "vsioproto.h"

extern struct palette	*GRpal_palettes ;
/*----------------------------------------------------------------------------*/
#define VS_K_MAX_MCLIBS	6

%safe
static struct {
	char				prefix	, loaded ;
} macLibLoaded[VS_K_MAX_MCLIBS] = {	{ 'G'	, FALSE },
					{ 'O'	, FALSE },
					{ 'E'	, FALSE },
					{ 'B'	, FALSE },
					{ 'C'	, FALSE },
					{ 'T'	, FALSE }
} ;
%endsafe
/*----------------------------------------------------------------------------*/
void VSresetMacLibsOfPalInterface __(( void )) {
	int	i ;

	/*
	 * To be called at file-startup time by a startup command.
	 */

	for( i = 0 ; i < VS_K_MAX_MCLIBS ; i++ ) {
		macLibLoaded[i].loaded = FALSE ;
	}
	
} /* VSresetMacLibsOfPalInterface */
/*----------------------------------------------------------------------------*/
static int VSisMacLibLoaded( prefix ) char prefix ; {

	int	i ;

	for( i = 0 ; i < VS_K_MAX_MCLIBS ; i++ ) {
		if( macLibLoaded[i].prefix == prefix ) {
			return macLibLoaded[i].loaded ;
		}
	}
	return FALSE ;

} /* VSisMacLibLoaded */

static void VSflagMacLibAsLoaded( prefix ) char prefix ; {

	int	i ;

	for( i = 0 ; i < VS_K_MAX_MCLIBS ; i++ ) {
		if( macLibLoaded[i].prefix == prefix ) {
			macLibLoaded[i].loaded = TRUE ;
		}
	}

} /* VSflagMacLibAsLoaded */
/*----------------------------------------------------------------------------*/
static void VSdeleteAllPalettes __(( void )) {

	struct palette		*p,
				*np ;

	if( GRpal_palettes ) {
		p = GRpal_palettes ;

		do {
			np = p->next ;
			GRpal_delete( p ) ;
		} while( p = np ) ;
	}

} /* VSdeleteAllPalettes */
/*----------------------------------------------------------------------------*/
method init( int type ; char *s ) {

	ex$message(	in_buff	= me->cmd_name,
			field	= MESSAGE_FIELD ) ;
	me->mytype = type ;
	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method execute(	int *response ; char *response_data ; int pos ) {

	typedef char	FILENAME[1+FILENAME_MAX] ;
	long		msg ;
	char		*prefix,
			libName[1+FILENAME_MAX],
			palName[1+FILENAME_MAX],
			*dirList = NULL ;
	FILENAME	*filList = NULL ;
	int		d,
			f,
			filCount,
			dirCount,
			l,
			found,
			loadMacLibs ;

	loadMacLibs = FALSE ;

	switch( me->mytype ) {

	/*
	 * "Load <topic> Library" commands.
	 */
	case VS_K_VSLdGCLb : prefix = "G" ; loadMacLibs = TRUE ; break ;
	case VS_K_VSLdOPLb : prefix = "O" ; loadMacLibs = TRUE ; break ;
	case VS_K_VSLdETLb : prefix = "E" ; loadMacLibs = TRUE ; break ;
	case VS_K_VSLdBRLb : prefix = "B" ; loadMacLibs = TRUE ; break ;
	case VS_K_VSLdCTLb : prefix = "C" ; loadMacLibs = TRUE ; break ;
	case VS_K_VSLdTRLb : prefix = "T" ; loadMacLibs = TRUE ; break ;

	/*
	 * "Activate <topic> Palette" commands.
	 */
	case VS_K_pfxGC	: prefix = VS_K_pfxGenCons		; break ;
	case VS_K_pfxGH	: prefix = VS_K_pfxGenHull		; break ;
	case VS_K_pfxGP	: prefix = VS_K_pfxGenPlate		; break ;
	case VS_K_pfxGS	: prefix = VS_K_pfxGenShape		; break ;

	case VS_K_pfxBR	: prefix = VS_K_pfxPlanarBracket	; break ;
	case VS_K_pfxBF	: prefix = VS_K_pfxFlangeBracket	; break ;
	case VS_K_pfxBC	: prefix = VS_K_pfxCompBracket		; break ;
	case VS_K_pfxBH : prefix = VS_K_pfxChockBracket		; break ;

	case VS_K_pfxOP	: prefix = VS_K_pfxOpenCutout		; break ;
	case VS_K_pfxOH	: prefix = VS_K_pfxOpenHole		; break ;
	case VS_K_pfxOS	: prefix = VS_K_pfxOpenScallops		; break ;
	case VS_K_pfxOC	: prefix = VS_K_pfxCutoutsOnShapes	; break ;
	case VS_K_pfxOB : prefix = VS_K_pfxHolesOnShapes	; break ;

	case VS_K_pfxET	: prefix = VS_K_pfxEndTreatment		; break ;
	case VS_K_pfxES	: prefix = VS_K_pfxEndSniped		; break ;
	case VS_K_pfxEC	: prefix = VS_K_pfxEndComposite		; break ;
	case VS_K_pfxEJ	: prefix = VS_K_pfxEndBeamJoint		; break ;
	case VS_K_pfxEL	: prefix = VS_K_pfxEndLapJoint		; break ;
	case VS_K_pfxEM	: prefix = VS_K_pfxEndMisc		; break ;

	case VS_K_pfxCT	: prefix = VS_K_pfxPlainCut		; break ;
	case VS_K_pfxCR	: prefix = VS_K_pfxReinfCut		; break ;
	case VS_K_pfxCW	: prefix = VS_K_pfxWaterCut		; break ;
	case VS_K_pfxCC	: prefix = VS_K_pfxCompCut		; break ;

	case VS_K_pfxTR	: prefix = VS_K_pfxLinearTran		; break ;
	case VS_K_pfxTB	: prefix = VS_K_pfxBendTran		; break ;
	case VS_K_pfxTD	: prefix = VS_K_pfxDiamondTran		; break ;
	case VS_K_pfxTF	: prefix = VS_K_pfxFlangeTran		; break ;
	default		: goto wrapup ;
	}

	/*
	 * MACROS
	 */
	if( loadMacLibs ) {

		if( VSisMacLibLoaded( *prefix ) ) {
			goto wrapup ;
		}
		sprintf( libName, "%s?%s*", prefix, VS_K_ifxMacLib ) ;

		VSfindDirsInPath( &msg, VS_K_stdMacDir, &dirCount, &dirList ) ;
		if( !( msg & 1 ) ) goto wrapup ;

		found = FALSE ;
		for( d = l = 0 ; d < dirCount ; d++ ) {
			VSlsRegFiles( &msg, dirList + l, libName,
					&filCount, &filList ) ;
			if( !( msg & 1 ) ) continue ;

			if( filCount ) {
				if( !found ) {
					found = TRUE ;
				}
			}

			for( f = 0 ; f < filCount ; f++ ) {

				ex$message(	msgnumb	= VS_gI_LoadingFile,
						type	= "%s",
						var	= `filList[f]`,
						time	= 1,
						field	= ERROR_FIELD ) ;
				ac$construct_path(	mode	= AC_ADD_PATH,
							name	= filList[f] ) ;


			}

			if( filCount ) _FREE( filList ) ;
			filCount = 0 ; filList = NULL ;

			l += 1 + strlen( dirList + l ) ;
		}

		_FREE( dirList ) ;

		if( !found ) {
			ex$message(	msgnumb	= VS_gW_UsrLibNotFound,
					time	= 2,
					field	= ERROR_FIELD ) ;
		} else {
			VSflagMacLibAsLoaded( *prefix ) ;
		}
	} else {
		/*
		 * PALETTES
		 */
		FILENAME	language ;
		char		palDir[1+MAXPATHLEN] ;

		ex$language( language = language ) ;
		sprintf( palDir , VS_K_stdPalDir, language ) ;

		sprintf( palName, "%s%s*", prefix, VS_K_ifxPalFil ) ;

		VSfindDirsInPath( &msg, palDir, &dirCount, &dirList ) ;
		if( !( msg & 1 ) ) goto wrapup ;

		found = FALSE ;
		for( d = l = 0 ; d < dirCount ; d++ ) {
			VSlsRegFiles( &msg, dirList + l, palName,
					&filCount, &filList ) ;
			if( !( msg & 1 ) ) continue ;

			if( filCount ) {
				if( !found ) {
					found = TRUE ;
					VSdeleteAllPalettes() ;
				}
			}

			for( f = 0 ; f < filCount ; f++ ) {
/*
			char 	*palFile;
			int	size;
				size = strlen(dirList) + strlen(filList[f]) + 1;
				palFile = (char *) malloc ( size * sizeof( char ) );
				if ( ! palFile ) {
					msg = EMS_E_NoDynamicMemory ; 
					goto wrapup ;
				}
				sprintf(palFile,"%s/%s",dirList,filList[f] );
*/
				GRpal_recreate( (int *) &msg, filList[f] ) ;
/*
				if ( palFile ) _FREE ( palFile );
*/
			}

			if( filCount ) _FREE( filList ) ;
			filCount = 0 ; filList = NULL ;

			l += 1 + strlen( dirList + l ) ;
		}

		_FREE( dirList ) ;

		if( !found ) {
			ex$message(	msgnumb	= VS_gW_UsrPalNotFound,
					time	= 2,
					field	= ERROR_FIELD ) ;
		}
	}

	wrapup :
		*response = TERMINATE ;
		return OM_S_SUCCESS ;

} /* method execute */
/*----------------------------------------------------------------------------*/

end implementation VSmacpalCmd ;


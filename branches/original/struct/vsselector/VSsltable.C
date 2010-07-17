/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "vsglobalmsg.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "VSslyacc.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsslcproto.h"
#include "vsstrngproto.h"


struct VS_s_KWdescr {
	/*
	 * We store the address of the global containing the message number
	 * and not the value of the message number since the compiler does
	 * not know its value at parse time. But storing the address of a
	 * global variable in a static variable is OK.
	 */
	long	*kwCode ;
	int	tokType ;
	char	*internalKw ;
} ;
typedef struct VS_s_KWdescr VSkwDescr ;

static VSkwDescr VS_GA_KWtable[] = {
/*
 *	Keyword code	          Yacc's token    Internal string for keyword
 */
	{ &VS_gI_kwIF		, VS_IF		, VS_K_internalIF	},
	{ &VS_gI_kwTHEN		, VS_THEN	, VS_K_internalTHEN	},
	{ &VS_gI_kwELSE		, VS_ELSE	, VS_K_internalELSE	},
	{ &VS_gI_kwENDIF	, VS_ENDIF	, VS_K_internalENDIF	},
	{ &VS_gI_kwNOT		, VS_NOT	, VS_K_internalNOT	},
	{ &VS_gI_kwAND		, VS_AND	, VS_K_internalAND	},
	{ &VS_gI_kwOR		, VS_OR		, VS_K_internalOR	},
	{ &VS_gI_kwOUTPUT	, VS_OUTPUT	, VS_K_internalOUTPUT	},
	{ &VS_gI_kwINPUT	, VS_INPUT	, VS_K_internalINPUT	},
	{ &VS_gI_kwBEAM		, VS_FUNCTION	, VS_K_internalBEAM	},
	{ &VS_gI_kwPLATE	, VS_FUNCTION	, VS_K_internalPLATE	},
	{ &VS_gI_kwDISTANCE	, VS_FUNCTION	, VS_K_internalDISTANCE	},
	{ &VS_gI_kwDSPREP	, VS_FUNCTION	, VS_K_internalDSPREP	},
	 /*
	  * End of list.
	  */
	{ NULL			, VS_ERROR	, NULL			}
} ;

/*----------------------------------------------------------------------------*/
int VSslcSearchKeyword( s, kw )

register char	*s ;
VS_TOKEN	*kw ; {

	int			rc ;
	register VSkwDescr	*kwTab ;

	rc = FALSE ;
	for( kwTab = VS_GA_KWtable ; kwTab->internalKw ; kwTab++ ) {
		if( !strcmp( s, kwTab->internalKw ) ) {
			kw->type = kwTab->tokType ;
			strcpy( kw->_sval, kwTab->internalKw ) ;
			rc = TRUE ;
			break ;
		}
	}

	return rc ;

} /* VSslcSearchKeyword */
/*----------------------------------------------------------------------------*/
int VSslcAddAlias( err, index, alias, table )

VSparseErr	*err ;
int		index ;
char		*alias ;
VSaliasTable	table ; {

	int	rc = FALSE ;

	if( index < VS_K_MAX_INPUT && index >= 0 ) {
		if( vs$searchAlias( table = table, alias = alias ) != -1 ) {

			VSslcSetParseErr( VS_ALIAS_MULT_DEF, alias, err ) ;

		} else if( !*table[index] ) {
			strcpy( table[index], alias ) ;
			rc = TRUE ;
		} else {
			VSslcSetParseErr( VS_ALIAS_REDEF, alias, err ) ;
		}
	} else {
		char buf[30] ;
		sprintf( buf, "%d", index ) ;
		VSslcSetParseErr( VS_INV_INPUT_INDEX, alias, err ) ;
	}

	return rc ;

} /* VSslcAddAlias */
/*----------------------------------------------------------------------------*/
int VSslcSearchAlias( table, alias ) VSaliasTable table ; char *alias ; {

	int	i,
		rc = -1 ;

	for( i = 0 ; i < VS_K_MAX_INPUT ; i++ ) {
		if( !strcmp( alias, table[i] ) ) { rc = i ; break ; }
	}

	return rc ;

} /* VSslcSearchAlias */
/*----------------------------------------------------------------------------*/
int VSslcTransKeyword( toOrFrom, inKw, outKw )

int	toOrFrom ; 
char	*inKw,
	*outKw ; {

	int			rc ;
	register VSkwDescr	*kwT ;

	rc = FALSE ;
	switch( toOrFrom ) {

	case VS_K_TO_INTERNAL :
		for( kwT = VS_GA_KWtable ; kwT->internalKw ; kwT++ ) {
			if( !strcmp( inKw, VSmsgkey2string( *kwT->kwCode ) ) ){
				strcpy( outKw, kwT->internalKw ) ;
				rc = TRUE ;
				break ;
			}
		}
		break ;
	
	case VS_K_TO_EXTERNAL :
		for( kwT = VS_GA_KWtable ; kwT->internalKw ; kwT++ ) {
			if( !strcmp( inKw, kwT->internalKw ) ) {
				strcpy(	outKw,
					VSmsgkey2string( *kwT->kwCode ) ) ;
				rc = TRUE ;
				break ;
			}
		}
		break ;
	}
	return rc ;

} /* VSslcTransKeyword * /
/*----------------------------------------------------------------------------*/

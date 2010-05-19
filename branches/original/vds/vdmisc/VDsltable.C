/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <string.h>
#include "v_globalmsg.h"
#include "v_slc.h"
#include "v_slcmacros.h"
#include "v_slyacc.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_ioproto.h"
#include "v_slcproto.h"
#include "v_strngproto.h"


struct VD_s_KWdescr {
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
typedef struct VD_s_KWdescr VD_kwDescr ;

static VD_kwDescr VD_GA_KWtable[] = {
/*
 *	Keyword code	          Yacc's token    Internal string for keyword
 */
	{ &VD_gI_kwIF		, VD_IF		, VD_K_internalIF	},
	{ &VD_gI_kwTHEN		, VD_THEN	, VD_K_internalTHEN	},
	{ &VD_gI_kwELSE		, VD_ELSE	, VD_K_internalELSE	},
	{ &VD_gI_kwENDIF	, VD_ENDIF	, VD_K_internalENDIF	},
	{ &VD_gI_kwNOT		, VD_NOT	, VD_K_internalNOT	},
	{ &VD_gI_kwAND		, VD_AND	, VD_K_internalAND	},
	{ &VD_gI_kwOR		, VD_OR		, VD_K_internalOR	},
	{ &VD_gI_kwOUTPUT	, VD_OUTPUT	, VD_K_internalOUTPUT	},
	{ &VD_gI_kwINPUT	, VD_INPUT	, VD_K_internalINPUT	},
	{ &VD_gI_kwBEAM		, VD_FUNCTION	, VD_K_internalBEAM	},
	{ &VD_gI_kwPLATE	, VD_FUNCTION	, VD_K_internalPLATE	},
	{ &VD_gI_kwDISTANCE	, VD_FUNCTION	, VD_K_internalDISTANCE	},
	{ &VD_gI_kwDSPREP	, VD_FUNCTION	, VD_K_internalDSPREP	},
	 /*
	  * End of list.
	  */
	{ NULL			, VD_ERROR	, NULL			}
} ;

/*----------------------------------------------------------------------------*/
int VD_slcSearchKeyword( s, kw )

register char	*s ;
VD_TOKEN	*kw ; {

	int			rc ;
	register VD_kwDescr	*kwTab ;

	rc = FALSE ;
	for( kwTab = VD_GA_KWtable ; kwTab->internalKw ; kwTab++ ) {
		if( !strcmp( s, kwTab->internalKw ) ) {
			kw->type = kwTab->tokType ;
			strcpy( kw->_sval, kwTab->internalKw ) ;
			rc = TRUE ;
			break ;
		}
	}

	return rc ;

} /* VD_slcSearchKeyword */
/*----------------------------------------------------------------------------*/
int VD_slcAddAlias( err, index, alias, table )

VD_parseErr	*err ;
int		index ;
char		*alias ;
VD_aliasTable	table ; {

	int	rc = FALSE ;

	if( index < VD_K_MAX_INPUT && index >= 0 ) {
		if( vd_$searchAlias( table = table, alias = alias ) != -1 ) {

			VD_slcSetParseErr( VD_ALIAS_MULT_DEF, alias, err ) ;

		} else if( !*table[index] ) {
			strcpy( table[index], alias ) ;
			rc = TRUE ;
		} else {
			VD_slcSetParseErr( VD_ALIAS_REDEF, alias, err ) ;
		}
	} else {
		char buf[30] ;
		sprintf( buf, "%d", index ) ;
		VD_slcSetParseErr( VD_INV_INPUT_INDEX, alias, err ) ;
	}

	return rc ;

} /* VD_slcAddAlias */
/*----------------------------------------------------------------------------*/
int VD_slcSearchAlias( table, alias ) VD_aliasTable table ; char *alias ; {

	int	i,
		rc = -1 ;

	for( i = 0 ; i < VD_K_MAX_INPUT ; i++ ) {
		if( !strcmp( alias, table[i] ) ) { rc = i ; break ; }
	}

	return rc ;

} /* VD_slcSearchAlias */
/*----------------------------------------------------------------------------*/
int VD_slcTransKeyword( toOrFrom, inKw, outKw )

int	toOrFrom ; 
char	*inKw,
	*outKw ; {

	int			rc ;
	register VD_kwDescr	*kwT ;

	rc = FALSE ;
	switch( toOrFrom ) {

	case VD_K_TO_INTERNAL :
		for( kwT = VD_GA_KWtable ; kwT->internalKw ; kwT++ ) {
			if( !strcmp( inKw, VD_msgkey2string( *kwT->kwCode ) ) ){
				strcpy( outKw, kwT->internalKw ) ;
				rc = TRUE ;
				break ;
			}
		}
		break ;
	
	case VD_K_TO_EXTERNAL :
		for( kwT = VD_GA_KWtable ; kwT->internalKw ; kwT++ ) {
			if( !strcmp( inKw, kwT->internalKw ) ) {
				strcpy(	outKw,
					VD_msgkey2string( *kwT->kwCode ) ) ;
				rc = TRUE ;
				break ;
			}
		}
		break ;
	}
	return rc ;

} /* VD_slcTransKeyword * /
/*----------------------------------------------------------------------------*/

/* $Id $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsselector/VSslfcnlib.C
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      11/08/00        Rama Rao        Added Header and Fixed TR#4109
 * -------------------------------------------------------------------*/

#include <stdio.h>
#include "OMprimitives.h"
#include "DIdef.h"
#include "msdef.h"
#include "vsdef.h"
#include "vsslc.h"
#include "vsslcmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsslcproto.h"

/*--SELECTOR'S FUNCTION LIBRARY-----------------------------------------------*/
int VSevalBeamLF( msg, argc, argv, res )

long		*msg ;
int		argc ;
VSexecRes	argv[],
		*res ; {

	/*
	 * Parse time or exec time: only check arity.
	 */
	*msg = argc == 1 ? *msg = MSSUCC : MSFAIL ;

	if( res && argv ) {
		/*
		 * Exec time: check argument type and then exec.
		 */
		if( argv[0].type != VS_object ) {
			*msg = MSINARG ;
		} else {
			VShasVStype( msg, &argv[0]._oval, VS_m_BEAM, res ) ;
		}
	}

	return *msg & 1 ;

} /* VSevalBeamLF */
/*----------------------------------------------------------------------------*/
int VSevalPlateLF( msg, argc, argv, res )

long		*msg ;
int		argc ;
VSexecRes	argv[],
		*res ; {

	/*
	 * Parse time or exec time: only check arity.
	 */
	*msg = argc == 1 ? *msg = MSSUCC : MSFAIL ;

	if( res && argv ) {
		/*
		 * Exec time: check argument type and then exec.
		 */
		if( argv[0].type != VS_object ) {
			*msg = MSINARG ;
		} else {
			VShasVStype( msg, &argv[0]._oval, VS_m_PLATE, res ) ;
		}
	}

	return *msg & 1 ;

} /* VSevalPlateLF */
/*----------------------------------------------------------------------------*/
int VSevalDistanceLF( msg, argc, argv, res )

long		*msg ;
int		argc ;
VSexecRes	argv[],
		*res ; {

	/*
	 * Parse time or exec time: only check arity.
	 */
	*msg = argc == 2 ? *msg = MSSUCC : MSFAIL ;

	if( res && argv ) {
		/*
		 * Exec time: check argument type and then exec.
		 */
		if( argv[0].type != VS_object || argv[1].type != VS_object ) {
			*msg = MSINARG ;
		} else {
			VSdistObjObj( msg, &argv[0]._oval, &argv[1]._oval, res );
		}
	}

	return *msg & 1 ;

} /* VSevalDistanceLF */
/*----------------------------------------------------------------------------*/
int VSevalRepresentationLF( msg, argc, argv, res )

long		*msg ;
int		argc ;
VSexecRes	argv[],
		*res ; {


	/*
	 * Parse time or exec time: only check arity.
	 */
	*msg = argc == 1 ? *msg = MSSUCC : MSFAIL ;

	if( res && argv ) {
		/*
		 * Exec time: check argument type and then exec.
		 */
		if( argv[0].type != VS_object ) {
			*msg = MSINARG ;
		} else {
			VSevalRepresentation( msg, &argv[0]._oval, res ) ;
		}
	}

	return *msg & 1 ;

} /* VSevalRepresentationLF */
/*----------------------------------------------------------------------------*/


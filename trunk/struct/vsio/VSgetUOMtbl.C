/*
	I/STRUCT
*/
#include <string.h> 
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMdef.h"
#include "UOM.h"
#include "UOMmacros.h"
#include "UOMerrordef.h"

/*
 * Includes of function prototypes.
 */
#include "vsgetUOMtabl.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSgetUOMtable(	OMuword		osnum,
			const char	*UOMtableName,
			UOM_TYPE	**UOMtable ) {
	/*
	 * Note the returned pointer `*UOMtable' is READ-ONLY data !
	 */
	long		sts ;
	char		typename[UOM_K_MAX_TYPE] ;
	UOM_TYPE	*type_table,
			*t ;

	*UOMtable = NULL ;

	/*
	 * `UOMtableName' is "UOM_<TABLE_NAME>", convert it to "<table_name>"
	 * (in lowercase with "UOM_" stripped ).
	 */
	VStoLOWER_Str( typename, UOMtableName + 4 ) ;

	/*
	 * Get circular list of all UOM tables.
	 */
	sts = uom$give_table( osnum = osnum, table = &type_table ) ;

	if( !( sts & 1 ) ) goto wrapup ;

	t	= type_table ;
	sts	= UOM_E_TYPE_NOT_FOUND ;

	/*
	 * And look for what you want.
	 */
	do {

		if( !strcmp( t->name, typename ) ) {
			*UOMtable	= t ;
			sts		= UOM_S_SUCCESS ;
			break ;
		}

		t = t->next ;

	} while( t != type_table ) ;			

	wrapup :
		return sts ;

} /* VSgetUOMtable */
/*----------------------------------------------------------------------------*/

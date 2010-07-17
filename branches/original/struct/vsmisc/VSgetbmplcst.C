/*
	I/STRUCT
*/
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "VDSsymb_def.h"
#include "vsRDBdef.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSgetBmOrPlCstDefaults( msg, symb_id, memberClass, matchKey, matchId,
				path, p_symb, p_level, p_display )
long			*msg ;
int			memberClass ;
struct GRid		symb_id,
			*matchId ;
char			*matchKey,
			*path ;
struct VDSsymb		*p_symb ;
short  			*p_level ;
struct IGRdisplay	*p_display ; {

	char	*n ;
	GRname	newMatchKey ;

	if( matchKey && matchId && path ) {
		switch( memberClass ) {
			default			:
			case VS_rdb_clUNDEFINED	: n = ""		; break;
			case VS_rdb_clPRIMARY	: n = "_primary"	; break;
			case VS_rdb_clSECONDARY	: n = "_secondary"	; break;
			case VS_rdb_clTERTIARY	: n = "_tertiary"	; break;
			case VS_rdb_clOTHER	: n = "_other"		; break;
		}

		sprintf( newMatchKey, "%s%s", matchKey, n  ) ;

		n = newMatchKey ;
	} else	n = NULL ;

	return vs$cnstDefaults(	   msg		= msg, 
				   symb_id	= symb_id,
				   matchKey	= n,
				   matchId	= matchId,
				   path		= path,
				   symb		= p_symb, 
				   level	= p_level, 
				   display	= p_display  ) ;

} /* VSgetBmOrPlCstDefaults */
/*----------------------------------------------------------------------------*/


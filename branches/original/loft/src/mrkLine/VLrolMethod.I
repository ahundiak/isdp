class implementation VLrolLine  ;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	I/VL: return type name and information of this object.

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include <stdio.h>
#include <string.h>
#include "exmacros.h"
#include "msmacros.h"
#include "vlrolline.h"
#include "v_miscmacros.h"

/*********************************** DEBUG flags        ***********************

#ifndef ROLLDEBUG
  #define ROLLDEBUG	1
  #define vsDEBUG         1
  #define vserrDEBUG      1
#endif

*********************************** end DEBUG flags    ***********************/

#include "vldbgmacros.h"

//----------------------------------------------------------------------------*

method GRgetobjinfo(	long			*msg ;
			struct GRobj_info	*info ) {

	int		sts = OM_E_INVARG;
        OMuword         actModOs ;              // Osnum of active mod.
        int             nchars = 0,             // Space to print type
			inAlen ;                // Length of "inA"
	char		inA[MS_MAX_MSG_LENGTH]; // In-macro message buf.


	if ( !msg || !info ) goto wrapup;

	ex$get_cur_mod( osnum = &actModOs );

	if( OM_Gw_current_OS != actModOs ) {
			inAlen = strlen( strcpy( inA, " [R]" ) ) ;
	} else  inAlen = 0 ;

	nchars = strlen( VLRolLnName ) + inAlen ;
	__DBGpr_int( "Nchars", nchars ) ;
	
        if( inAlen ) {
		sprintf( info->type, "%.*s ", nchars, VLRolLnName, inA ) ;
        } else {
		sprintf( info->type, "%.*s ", nchars, VLRolLnName ) ;
	}

	info->type[nchars] = '\0';

	__DBGpr_str( "Type", info->type ) ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

wrapup:
	return sts;

} // method GRgetobjinfo

//----------------------------------------------------------------------------*

end implementation VLrolLine  ;

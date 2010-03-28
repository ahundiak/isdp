class implementation COcidgnop ;

#include <stdio.h>
#include "exdef.h"
#include "exmacros.h"
/*----------------------------------------------------------------------------*/
method init( int type ; char *string ) {

	int rc ; OM_S_OBJID modid, id ; OMuword modos ;

/* -- Security: there may be an old super_ci in design file.
   -- */
	ex$get_cur_mod( id = &modid, osnum = &modos ) ;

	id = NULL_OBJID ;
	rc = ex$get_objid_from_NOD( NODname = "IGENOD",
				objname = "super_ci",
				pobjid = &id,
				modid = modid,
				mod_osnum = modos ) ;

	if( rc & SUCC ) {
		rc = ex$remove_name_from_NOD(	NODname		= "IGENOD",
						objname		= "super_ci",
						mod_osnum	= modos ) ;
#ifdef DEBUG
  printf( "COcidgnop.init: DELETING SUPER_CI !\n" ) ;
#endif
	}
	me^^super_cmd.mytype = type ;
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method execute( int *resp ; char *resp_data ; int pos ) {

#ifdef DEBUG
  printf( "COcidgnop.execute: ENTER, type = %d\n", me^^super_cmd.mytype ) ;
			fflush( stdout ) ;
#endif
	switch( me^^super_cmd.mytype ) {
		case EX_FINIT	:
#ifdef DEBUG
			printf( "Yes SIR a design file is being opened!\n" ) ;
			fflush( stdout ) ;
#endif
			SCIconstruct() ;

#ifdef DEBUG
			printf( "COcidgnop.execute: after SCIconstruct\n" ) ;
			fflush( stdout ) ;
#endif
			break ;
		case EX_FCREATE	:
			/* Unused at present ... */
#ifdef DEBUG
			printf( "Yes SIR a design file is being created!\n" ) ;
			fflush( stdout ) ;
#endif
			break ;
	}

	*resp = TERMINATE	;
#ifdef DEBUG
  printf( "COcidgnop.execute: EXIT\n" ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS	;

} /* method execute */
/*----------------------------------------------------------------------------*/
end implementation COcidgnop ;

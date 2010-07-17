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
#include "griodef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "acrepdef.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VScnstDefaults( p_msg, symb_id, matchKey, matchId,
				path, p_symb, p_level, p_display )

long			*p_msg ;
struct GRid		symb_id,
			*matchId ;
char			*matchKey,
			*path ;
struct VDSsymb		*p_symb ;
short  			*p_level ;
struct IGRdisplay	*p_display ; {
	
	/*
	 * Retrieve the Active representation ( level, display, symbology ).
	 */
	int 	size ,
		nret ;
	
	vd$symbology(	msg	= p_msg,
			symb_id	= &symb_id,
			symb	= p_symb ) ;

	switch( ( unsigned char )p_symb->representation & ~AC_SUB_REP ) {
		case AC_2D_REP	:
		case AC_3D_REP	:
		case AC_ENV_REP	: break ;
		default		:
			/*
			 * Unknown rep.
			 */
			 p_symb->representation = AC_2D_REP ;
			 break ;
	}

	if( matchKey && matchId && path ) {
		long 		sts ;
/**
		GRname          pwd1, pwdHome;
		GRspacenum      osNum ;
		int             status ;
**/

		/*
		 * Change the directory to home directory as the 
		 * VDSget_dir_and_sym will return the active symbology
		 * if the user is in the same directory of the 'path'
		 * of that command.
		 */
/***
		status = di$pwd( dirname = pwd1 );
		ex$get_cur_mod( osnum = &osNum );
		di$give_pathname( osnum = osNum, pathname = pwdHome );
		di$cd( dirname = pwdHome );
***/
		sts = VDSget_dir_and_symb(	p_msg,
						matchId,
						matchKey,
						NULL,
						path,
						p_level,
						p_display ) ;
		/* 
		 * Replace the directory with the old one
		 */
/**
		di$cd( dirname = pwd1 );
**/
		if( sts & 1 & *p_msg ) {
			goto wrapup ;
		}
	}
	/*
	 * `VDSget_dir_and_symb' failed: get things from ADPB.
	 */
	size = sizeof( short ) ;
			
	gr$get_active_level(	msg	= p_msg,
				sizbuf	= &size,
				nret	= &nret,
				buffer	= p_level ) ;

	size = sizeof( struct IGRdisplay ) ;
	
	gr$get_active_display(	msg	= p_msg,
				sizbuf	= &size,
				nret	= &nret,
				buffer	= p_display ) ;

	if( path ) di$pwd( dirname = path ) ;

	wrapup :
		return *p_msg & 1 ;

} /* VScnstDefaults */
/*----------------------------------------------------------------------------*/


/*
	I/STRUCT

Abstract
	Renames a part.
	Rename logic

	new name\old name	|	none	| some name
	------------------------+---------------+----------
		none		|	add	| add
		some name	|	rem	| chg

	add = add name
	chg = change name
	rem = remove name

Arguments
	OUT	long		*msg	completion code
	IN	struct GRmd_env	*myEnv my module environment (unused)
	IN	GRname		name	name for part

*/
class implementation VSfeature ;

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grerr.h"
#include "EMSmsgdef.h"
#include "vsdbgmacros.h"

extern int	DIunlink_dir __(( char*, int )) ;
/*----------------------------------------------------------------------------*/
method GRchgname(	long		*msg ;
			struct GRmd_env	*myEnv ;
			GRname		newName ) {

	long		rc,		/* DI return code		*/
			sts ;		/* OM return code		*/
	GRname		oldName ;	/* My name before change	*/
	int		haveName,	/* TRUE if I had a name before	*/
			nonNull ;	/* TRUE if new name not empty	*/

	/*
	 * If I am a name holder, chg-name is for me, else I forward it up
	 * till a part can carry it.
	 */
	sts = om$send(	msg	= message VSpart.VSisNameHolder(
							VS_K_WRITE_OMmsg ),
			targetid= my_id ) ;

	if( sts == OM_E_ABORT ) {
		/*
		 * Not allowed to change name
		 */
		sts  = OM_S_SUCCESS ;
		*msg = GR_E_INV_REQUEST ;

	} else if( sts != OM_I_STOP_SENDING ) {
		long		notUsed ;

		/*
		 * I cannot store the name ...
		 */
		sts = om$send(	msg 	= message NDmacro.ACbubble_up(
						&notUsed,
						"",
						VS_K_ConsumedIx,
						message VSpart.VSisNameHolder(
							VS_K_WRITE_OMmsg ),
						OPPmargs,
						OM_e_wrt_object ),
				targetid= my_id ) ;
	} else {

	  rc = di$untranslate(	objid	= my_id,
				osnum	= OM_Gw_current_OS,
				objname	= oldName ) ;

	  *msg = MSSUCC ; haveName = FALSE ;

	  switch( rc ) {
		case DIR_W_NAME_NOT_FOUND :
		case DIR_W_NO_NAME	  : haveName = FALSE ; break ;
		case DIR_S_SUCCESS	  : haveName = TRUE  ; break ;
		default			  : *msg = MSFAIL ;
	  }
	  __CheckRC( 1, *msg, "di$untranslate", wrapup ) ;

	  nonNull = newName && *newName ;

	  if( !haveName ) {
		/*
		 * I did not have a name before so use GRputname (whether my
		 * new name is empty or not since `VSfeature.GRputname' does
		 * not choke on empty names ! )
		 */
		sts = om$send(	msg	= message GRgraphics.GRputname(
								msg, newName),
				targetid= my_id ) ;
	  } else if( nonNull ) {
		/*
		 * I had a name before, my new name is non-empty, then this
		 * is a change-name.
		 */
		sts = om$send(	msg	= message ACncpx.GRchgname(
							msg, myEnv, newName ),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;
		__CheckRC( sts, *msg, "ACncpx.GRchgname", wrapup ) ;

	  } else {
		/*
		 * I had a name before and the new one is empty: this is a
		 * remove-entry.
		 */
		rc = DIunlink_dir( oldName, TRUE ) ;
		if( rc & 1 )	{ *msg	= MSSUCC ; sts = OM_S_SUCCESS	; }
		else		{ *msg	= MSFAIL ; sts = OM_W_ABORT	; }
	  }
	}
	
	wrapup :
		return sts ;

} /* method GRchgname */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;


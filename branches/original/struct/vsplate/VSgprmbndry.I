/*
	I/STRUCT
*/
class implementation VSgapPlate ;

#include <stdlib.h>
#ifndef emsdef_include
#	include "emsdef.h"
#endif
#ifndef EMSopt_include
#	include "EMSopt.h"
#endif
#include "EMSutlmacros.h"
#include "vsjntmacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

from	EMSsurface	import	EMdelete_boundary ;
from	EMSloopset	import	EMget_loops ;
/*----------------------------------------------------------------------------*/
long VSdelete_boundaries_if_any( msg, sfEnv, sfId, cpyEnv, cpyId, hadBdry )

long		*msg ;
struct GRmd_env *sfEnv, 	/* IN  : env. of input surface	*/
		*cpyEnv ;	/* OUT : env. of copy		*/
struct GRid	*sfId,		/* IN  : id of input surface	*/
		*cpyId ;	/* OUT : id of copy		*/
int		*hadBdry ; {	/* OUT : input surf. has bndry? */

/*
 * If input surface has boundaries, copy it and remove boundaries on copy
 * ( *hadBdry = TRUE ) else do nothing and return input surface as copy
 * ( *hadBdry = FALSE ).
 */

	long			sts ;		/* OM return code	*/
	OM_S_CHANSELECT 	toLoopSet ;	/* To-loopset channel	*/
	int			lsCount ;	/* Count of loop sets	*/

	VSsetGRids( cpyEnv->_MD_OS, 1, cpyId ) ;

	ems$make_chanselect( chan_label    = EMSsubbs_to_loopset,
			     chan_selector = &toLoopSet ) ;

	sts = om$get_channel_count(	objid		= sfId->objid,
					osnum		= sfId->osnum,
					p_chanselect	= &toLoopSet,
					count		= (OMuint *) &lsCount ) ;

	if( ( sts & 1 ) && lsCount ) {

		/*
		 * Has boundaries copy original before removing boundaries.
		 */
		sts = vs$grCopy(	msg	= msg,
					frEnv	= sfEnv,
					frObj	= sfId,
					toEnv	= cpyEnv,
					toObj	= cpyId ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		*hadBdry = TRUE ;

		/*
		 * In the following message NULL stands for the address of the
		 * module id for display. We set NULL since we don't want the
		 * method to erase the surface before removal, then redisplay
		 * it after removal.
		 */
		sts = om$send(	msg	= message EMSsurface.EMdelete_boundary(
									msg,
									cpyEnv,
									NULL,
									cpyId ),
				senderid= cpyId->objid,
				targetid= cpyId->objid,
				targetos= cpyId->osnum ) ;
		__CheckRC( sts, *msg, "EMSsurface.EMdelete_boundary", wrapup ) ;

	} else {
		*hadBdry = FALSE ;
		*cpyId	 = *sfId ;
		*msg	 = MSSUCC ;
		sts	 = OM_S_SUCCESS ;
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( *hadBdry ) {
				/*
				 * Delete copy since something failed.
				 */
				vs$bulk_delete( count	= 1,
						grids	= cpyId,
						theEnv	= cpyEnv ) ;
			}
		}
		return sts ;

} /* VSdelete_boundaries_if_any */
/*----------------------------------------------------------------------------*/
long VSdelete_inside_bdrs_if_any( msg, sfEnv, sfId, cpyEnv, cpyId, hadBdry )

long		*msg ;
struct GRmd_env *sfEnv, 	/* IN  : env. of input surface	*/
		*cpyEnv ;	/* OUT : env. of copy		*/
struct GRid	*sfId,		/* IN  : id of input surface	*/
		*cpyId ;	/* OUT : id of copy		*/
int		*hadBdry ; {	/* OUT : input surf. has bndry? */

/*
 * If input surface has inside boundaries, copy it and remove inside boundaries
 * on copy ( *hadBdry = TRUE ) else do nothing and return input surface as copy
 * ( *hadBdry = FALSE ).
 */

	long			sts ;	    /* OM return code.		      */
	int			depth,	    /* Depth in loop tree.	      */
				size,	    /* Size of buffer for EMget_loops.*/
				count ;     /* Count of loops found.	      */
	struct GRid		loopset ;   /* Loop set of surface.	      */
	GRobjid 		*frstLoop ; /* First loop of loopset.	      */
	OM_S_CHANSELECT 	to_inner ;  /* to-inner channel.	      */
	struct GRobj_env	objenv ;

	VSsetGRids( cpyEnv->_MD_OS, 1, cpyId ) ;
	*hadBdry = FALSE ;
	frstLoop = NULL ;

	/*
	 * Get loopset of input surface.
	 */
	objenv._grid	= *sfId ;
	objenv.mod_env	= *sfEnv ;
	sts = vs$getLoopset( msg	= msg,
			     surface	= &objenv,
			     loopset	= &loopset ) ;
	__CheckRC( sts, *msg, "vs$getLoopset", wrapup ) ;

	/*
	 * Get first loop of loopset.
	 */
	depth = 1 ;		/* First loop. */
	size  = 0 ;

	sts = om$send( msg	= message EMSloopset.EMget_loops( msg,
								  EMS_OPT_ALL,
								  &depth,
								  &frstLoop,
								  NULL,
								  &size,
								  &count ),
		       senderid = loopset.objid,
		       targetid = loopset.objid,
		       targetos = loopset.osnum ) ;

	__CheckRC( sts, *msg, "EMSloopset.EMget_loops", wrapup ) ;

	/*
	 * See if the first loop has inner loops ( loops for inside
	 * boundaries ). If there isn't inner loops return input surface as
	 * copy.
	 */
	ems$make_chanselect( chan_label    = EMSloop_to_inner,
			     chan_selector = &to_inner ) ;

	sts = om$get_channel_count( objid		= *frstLoop,
				    osnum		= sfId->osnum,
				    p_chanselect	= &to_inner,
				    count		= (OMuint *) &count ) ;

	__CheckRC( sts, 1, "om$get_channel_count", wrapup ) ;

	if( !count ) {
		*cpyId	 = *sfId ;
		*msg	 = MSSUCC ;
		sts	 = OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * Copy input surface.
	 */
	sts = vs$grCopy( msg	= msg,
			 frEnv	= sfEnv,
			 frObj	= sfId,
			 toEnv	= cpyEnv,
			 toObj	= cpyId ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	*hadBdry = TRUE ;

	/*
	 * Get loopset of copy.
	 */
	objenv._grid	= *cpyId ;
	objenv.mod_env	= *cpyEnv ;
	sts = vs$getLoopset( msg	= msg,
			     surface	= &objenv,
			     loopset	= &loopset ) ;
	__CheckRC( sts, *msg, "vs$getLoopset", wrapup ) ;

	/*
	 * Get first loop of loopset.
	 */
	_FREE( frstLoop ) ;
	frstLoop = NULL ;
	depth = 1 ;		/* First loop. */
	size  = 0 ;

	sts = om$send( msg	= message EMSloopset.EMget_loops( msg,
								  EMS_OPT_ALL,
								  &depth,
								  &frstLoop,
								  NULL,
								  &size,
								  &count ),
		       senderid = loopset.objid,
		       targetid = loopset.objid,
		       targetos = loopset.osnum ) ;

	__CheckRC( sts, *msg, "EMSloopset.EMget_loops", wrapup ) ;

	/*
	 * Remove inner loops of first loop.
	 */
	sts = om$send( msg	    = message Root.delete( 1 ),
		       senderid     = *frstLoop,
		       p_chanselect = &to_inner ) ;

	__CheckRC( sts, 1, "Root.delete", wrapup ) ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( *hadBdry ) {
				/*
				 * Delete copy since something failed.
				 */
				vs$bulk_delete( grids	= cpyId,
						theEnv	= cpyEnv ) ;
			}
		}
		_FREE( frstLoop ) ;
		return sts ;

} /* VSdelete_inside_bdrs_if_any */
/*----------------------------------------------------------------------------*/

end implementation VSgapPlate ;

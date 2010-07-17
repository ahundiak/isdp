/*
	I/STRUCT
*/
class implementation GRvg ;

#include <stdio.h>
#include <string.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#define GRint	IGRint
#define GRchar	IGRchar
#include "GRprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "exmacros.h"
#include "gr.h"
#include "DImacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "vspart.h"
#include "vsdirdef.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern OMuword	OPP_ACdb_info_class_id,
		OPP_ACncpx_class_id,
		OPP_DIrectory_class_id ;
/*----------------------------------------------------------------------------*/
long VSrdbDelCachedDefs() {

	long		sts,			/* DI return code	*/
			msg ;
	char		startDir[DI_PATH_MAX] ;	/* FIND's start dir.	*/
	DIgrid		*entries ;		/* Entries' ids		*/
	char		**lines ;		/* Entries' names	*/
	int		i,			/* Loop-on-entries index*/
			count ;			/* Count of entries	*/
	OMuword		classid ;		/* Of one entry		*/
	struct GRmd_env	env ;

	entries = NULL ; lines = NULL ; count = 0 ;

	ex$get_cur_mod(	osnum = &env._MD_OS ) ;

	/*
	 * MUST send module id to NULL_OBJID, since GRdelete will try to
	 * remove the cached sections from the R-tree, but they are not in it !
	 */
	env._MD_ID = NULL_OBJID ;

	MAidmx( &msg, env._MATRIX ) ; env._MATRIX_TYPE = MAIDMX ;

	di$give_pathname(	osnum	= env._MD_OS,
				pathname= startDir ) ;

	di$strcat(	to	= startDir,
			from	= VS_K_STRUCTdir ) ;

	sts = di$find(	start_dir	= startDir,
			grids		= &entries,
			ptr		= &count,
			lines		= &lines,
			options		= 0 ) ;
	if( sts == DIR_W_NAME_NOT_FOUND ) {
		/*
		 * No cache.
		 */
		return DIR_S_SUCCESS ;
	}

	/*
	 * We may be going to delete the CWD, so CD to a directory which will
	 * not be deleted, eg. "startDir".
	 */
	di$cd( dirname = startDir ) ;

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif
	for( i = count - 1 ; i >= 0 ; i-- ) {

		/*
		 * Do not remove lines containing a '#': it is supposed to be
		 * the '#' flagging families of composite profiles, and since
		 * composite profiles are not in the RDB but user-made in the
		 * design file, they cannot be regenerated.
		 */
		if( strchr( lines[i], '#' ) ) {
			continue ;
		}

		om$get_classid(	objid		= entries[i].objid,
				osnum		= entries[i].osnum,
				p_classid	= &classid ) ;

		/*
		 * Test for ACncpx first, since ACncpx objects are also
		 * ACdb_info objects.
		 */
		if( om$is_ancestry_valid(
				superclassid	= OPP_ACncpx_class_id,
				subclassid	= classid ) == OM_S_SUCCESS ) {

			sts = om$send(	msg	= message GRgraphics.GRdelete(
								&msg, &env ),

					senderid= entries[i].objid,
					targetid= entries[i].objid,
					targetos= entries[i].osnum ) ;

			nd$exec_batch() ;
		} else if( om$is_ancestry_valid(
				superclassid	= OPP_ACdb_info_class_id,
				subclassid	= classid ) == OM_S_SUCCESS ) {

			sts = di$rm_name(	regexp	= lines[i] ) ;

			sts = om$send(	msg	= message Root.delete( 0 ),
					senderid= entries[i].objid,
					targetid= entries[i].objid,
					targetos= entries[i].osnum ) ;
		} else if( om$is_ancestry_valid(
				superclassid	= OPP_DIrectory_class_id,
				subclassid	= classid ) == OM_S_SUCCESS ) {

			/*
			 * The following call may fail if directory is not
			 * empty because a line containing a '#' was skipped.
			 */
			sts = di$rmdir( dirname = lines[i] ) ;

		} /* Else
		   * We fall here into the members of ACncpx objects.
		   */
	}
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = "-" ) ;
#endif
	/*
	 * Now CD back to the previous CWD, if di$cd fails, it means that
	 * the previous CWD has been removed, then just keep sitting where you
	 * are.
	 */
	di$cd( dirname = "-" ) ;


	if( count ) {
		if( lines ) di$free( lines = lines, count = count ) ;
		if( entries ) free( entries ) ; 

	}

	return sts ;

} /* VSrdbDelCachedDefs */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;


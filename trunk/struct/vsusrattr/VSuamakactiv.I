/*
	I/STRUCT
*/
class implementation ACrg_collect ;

#include "OMmacros.h"
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
#include "DImacros.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsdirdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"

extern OMuword	OPP_ACrg_collect_class_id ;
/*----------------------------------------------------------------------------*/
long VSmakeActiveUsrAttr( msg, baseName, nbEntries, names, syntaxes,
			 p_activeUA )

/*
 * This function interfaced by macro vs$makeActiveUsrAttr.
 */
long		*msg ;
GRname		baseName ;
int		nbEntries ;
char		*names[],
		*syntaxes[] ;
struct GRid	*p_activeUA ; {

	long		sts ;		/* OM return code		*/
	struct GRid	oldActUA ;	/* Id of old active collection	*/
	GRname		UApathNm ;	/* Pathname of active collection*/
	int		i,		/* Loop index			*/
			noUA ;		/* No more active collection ?	*/
	struct GRmd_env actEnv ;
	int		sz, nb ;

	sz = sizeof actEnv ;

	gr$get_module_env(	msg	= msg,
				sizbuf	= &sz,
				buffer	= &actEnv,
				nret	= &nb ) ;
	/*
	 * No entries or all entries with empty names or syntaxes is taken
	 * to mean no active user attributes: in this case the active collection
	 * of attributes, if any, becomes unnamed, NULL_OBJID is returned and
	 * this function terminates with success.
	 */
	noUA = TRUE ;
	for( i = 0 ; i < nbEntries ; i++ ) {
		if( *names[i] && *syntaxes[i] ) {
			noUA  = FALSE ; break ;
		}
	}
#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
	gr$cg( groupname = VS_Ga_Group, passwd = VS_Ga_Passwd ) ;
#endif
	p_activeUA->objid = NULL_OBJID ;

	sts = vs$getActiveUsrAttr(	msg		= msg,
					basename	= baseName,
					p_activeUA	= &oldActUA ) ;

	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( IF_NULL_OBJID( oldActUA.objid ) ) {
		OM_S_OBJID	modId ;
		OMuword		modOs ;

		/*
		 * No active attributes before: create directories.
		 */
		sts = ex$get_cur_mod( id = &modId, osnum = &modOs ) ;
		if( !sts ) { *msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ; }


		sts = di$mkdir( osnum = modOs, dirname = VS_K_STRUCTdir ) ;

		if( sts != DIR_S_SUCCESS && sts != DIR_E_DIR_DUP ) {
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
		}
		p_activeUA->osnum = modOs ;
	} else {
		p_activeUA->osnum = oldActUA.osnum ;
	}

	if( !noUA ) {
		/*
		 * Create new user attributes.
		 */
		sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
					osnum	= p_activeUA->osnum,
					p_objid	= &p_activeUA->objid ) ;
		if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

		sts = om$send(	msg	= message ACdiowner.ACcreate( msg, "" ),
				senderid= p_activeUA->objid,
				targetid= p_activeUA->objid,
				targetos= p_activeUA->osnum ) ;

		__CheckRC( sts, *msg, "ACdiowner.ACcreate", wrapup ) ;

		for( i = 0 ; i < nbEntries ; i++ ) {
			/*
			 * Suppress empty names.
			 */
			if( !*names[i] ) continue ;

			sts = om$send(
				msg	= message ACdiowner.ACadd_attribute(
								msg,
								names[i],
								syntaxes[i] ),
				senderid= p_activeUA->objid,
				targetid= p_activeUA->objid,
				targetos= p_activeUA->osnum ) ;
			if( !( sts & 1 & *msg ) ) {
				/*
				 * There probably was a syntax error in an
				 * expression.
				 */

				goto wrapup ;
			}
		}
	}

	di$give_pathname( osnum = p_activeUA->osnum, pathname = UApathNm ) ;
	DIstmcat( UApathNm, VS_K_STRUCTdir, baseName, NULL ) ;

	if( !IF_NULL_OBJID( oldActUA.objid ) ) {

		int count ;

		/*
		 * Must first remove previous active user attributes.
		 */
		sts = DIunlink_dir( UApathNm, TRUE ) ;

		if( !( sts & 1 ) ) { *msg = MSFAIL ; goto wrapup ; }

		/*
		 * If collection has no children, delete it else tell it to
		 * go away should all its children have disconnected from it.
		 * This collection should not have children in a different
		 * OS, so NDnode.NDget_object which only gets children in the
		 * same OS is sufficent.
		 */
		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_CHILDREN,
							NULL,
							0,
							NULL,
							0,
							OM_K_MAXINT,
							&count ),
				senderid= oldActUA.objid,
				targetid= oldActUA.objid,
				targetos= oldActUA.osnum ) ;
		if( count ) {
			sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH, ND_DEL_NO_CH ),
					senderid= oldActUA.objid,
					targetid= oldActUA.objid,
					targetos= oldActUA.osnum ) ;
		} else {
			sts = om$send(	msg	= message NDnode.NDdelete(
								&actEnv ),
					senderid= oldActUA.objid,
					targetid= oldActUA.objid,
					targetos= oldActUA.osnum ) ;
		}
	}

	if( !noUA ) {
		/*
	 	 * Add new user attributes to directory system.
		 */
		sts = om$send(	msg	= message GRvg.GRchgname(
							msg, NULL, UApathNm ),
				senderid= p_activeUA->objid,
				targetid= p_activeUA->objid,
				targetos= p_activeUA->osnum ) ;
	} else {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ;
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( !IF_NULL_OBJID( p_activeUA->objid ) ) {

				vs$bulk_delete(	count	= 1,
						grids	= p_activeUA,
						theEnv	= &actEnv ) ;
			}
		}

#if 0
/* IN EMS 3.1 gr$cg no longer works properly ... */
		gr$cg( groupname = "-" ) ;
#endif
		return sts ;

} /* VSmakeActiveUsrAttr */
/*----------------------------------------------------------------------------*/

end implementation ACrg_collect ;

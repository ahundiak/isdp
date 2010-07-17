/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "nddef.h"
#include "expression.h"
#include "expmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
/*----------------------------------------------------------------------------*/
int VSplaceGapDetector( const struct GRid		*bmId,
			const struct GRmd_env		*bmEnv,
			double				maxAdmGap,
			struct GRvg_construct		*cst,
			struct GRid			*gdId ) {

	long			sts ;
	long			*msg = cst->msg ;
	struct GRvg_construct	locCst ;
	struct IGRdisplay	locDsp ;
	struct VScnst_list	vsargs ;
	int			number ;
	GRname			gapDirName ;
	GRname			basename ;
	GRname			pathName ;
	struct GRobj_env	parents[2] ;
#define RED 2

	parents[1]._objid = gdId->objid = NULL_OBJID ;

	/*
	 * Create directories where name of gap detector part is to be stored.
	 * Beware that to have di$mkpath make directories but not do a
	 * di$add_name at the end, the pathname input to it must end with the
	 * directory separator.
	 */
	di$give_pathname(	osnum	= cst->env_info->_MD_OS,
				pathname= pathName ) ;
	sprintf( gapDirName, "%s%cusr%cGapDetectors%c", pathName, DIR_G_car_dir,
			     DIR_G_car_dir, DIR_G_car_dir ) ;

	*msg = di$mkpath( pathname = gapDirName ) ;
	
	if( !( *msg & 1 ) && *msg != DIR_E_DIR_DUP ) goto wrapup ;

	VSbuildName( msg, gapDirName, "GDval1", basename ) ;
	sscanf( basename, "GDval%d", &number ) ;
	DIstmcpy( pathName, gapDirName, basename, NULL ) ;

	*msg = exp$create(	exp_name   = pathName,
				exp_value  = maxAdmGap,
				osnum      = cst->env_info->_MD_OS,
		     		p_exp_id   = &parents[1]._objid,
	        	        p_osnum    = &parents[1]._osnum ) ;
	if( !( *msg & 1 )  ) goto wrapup ;

	locDsp = *cst->display ;
	locDsp.weight = 1 ;
	locDsp.color  = RED ;

	parents[0]._grid	= *bmId ;
	parents[0].mod_env	= *bmEnv ;
	parents[1].mod_env	= *cst->env_info ;
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.representation	= AC_NO_REP ;
	vsargs.feature_att	= NULL ;

	/*
	 * Assign same number to gap detector as to gap expression
	 */
	sprintf( pathName, "GD%d", number ) ;
	VSbuildName( msg, gapDirName, pathName, basename ) ;

	DIstmcpy( pathName, gapDirName, basename, NULL ) ;

	vs$fill_cnst_list(	Msg		= cst->msg,
				Env_info	= cst->env_info,
				Level		= cst->level,
				Display		= &locDsp,
				Name		= pathName,
				Class_attr	= &vsargs,
				Cnst_list	= locCst ) ;

	gdId->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= OPP_VSgapDtector_class_id,
				osnum	= gdId->osnum,
				p_objid	= &gdId->objid,
				msg	= message GRvg.GRconstruct( &locCst )) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * Make parent expression support-only.
	 */
	sts = om$send(	msg	= message NDnode.NDchg_state(
						ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL ),
			senderid= NULL_OBJID,
			targetid= parents[1]._objid,
			targetos= parents[1]._osnum ) ;
				
	wrapup :
		if( !( *msg & 1 ) ) {
			vs$bulk_delete( objenvs = &parents[1] ) ;
		}
		return *msg & 1 ;
				
} /* VSplaceGapDetector */
/*----------------------------------------------------------------------------*/

end implementation VSgapDtector ;


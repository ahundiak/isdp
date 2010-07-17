/*
	I/STRUCT
*/
class implementation VSbeam ;

#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsbldrootcpx.h"
#include "vschgsymb.h"

extern void		VSsetGRids() ;
extern IGRboolean	ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
long VSmake_linear_beam_rep(	msg,
				profile,
				surface,
				axis,
				copyAxis,
				cst,
				linearRep )

long			*msg ;
struct GRobj_env	*surface,
			*axis ;
int			copyAxis ;
struct GRvg_construct	*cst ;
struct GRid  		*profile,
	  		*linearRep ; {

/*
 * This function interfaced by macro vs$make_linear_beam_rep.
 */

	long		sts ;		/* OM return code		*/
#	define MAX	4
	struct GRid	lRepCmps[MAX] ;	/* Components of linear rep.	*/
	char		*names[MAX] ;	/* Names of components		*/
	OM_S_OBJID	axisCpy ;	/* Copy of input axis		*/
	struct GRid	mergedPrfl ;	/* Result of merge on profile	*/
	IGRboolean	saveBroadcast ;

	names[0]= VS_K_bmLnRepAxis ;
	names[1]= VS_K_bmLnRepArw1 ;
	names[2]= VS_K_bmLnRepArw2 ;
	names[3]= VS_K_bmLnRepProf ;

	VSsetGRids( cst->env_info->_MD_OS, MAX, lRepCmps ) ;
	linearRep->objid = axisCpy = NULL_OBJID ;

	/*
	 *  Get arrows
	 */
	sts = OM_W_ABORT ;
	vs$cnstBeamArrowHeads(	msg		= msg,
				surface		= surface,
				axis		= axis,
				cnst_list	= cst,
				viewIndep	= TRUE,
				startArrow	= lRepCmps + 1,
				endArrow	= lRepCmps + 2 ) ;
	__CheckRC( 1, *msg, "vs$cnstBeamArrowHeads", wrapup ) ;

	if( copyAxis ) {
		struct GRid copy ;

	        saveBroadcast = ASbroadcast_in_progress ;
        	ASbroadcast_in_progress = TRUE ;

		sts = vs$grCopy(	msg	= msg,
					frEnv	= &axis->mod_env,
					frObj	= &axis->_grid,
					toEnv	= cst->env_info,
					toObj	= &copy ) ;
		ASbroadcast_in_progress = saveBroadcast ;

		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		axisCpy = copy.objid ;
	} else {
		if( axis->_osnum == cst->env_info->_MD_OS ) {
			axisCpy = axis->_objid ;
		} else	vs$inv_arg() ;
	}

	/*
	 * Merge profile (a composite curve) into a simple curve, using less
	 * space in design file.
	 */
	sts = vs$mergeCompCurve(	msg		= msg,
					ccId		= profile,
					ccEnv		= cst->env_info,
					cst		= cst,
					delInputCv	= TRUE,
					mergedCvId	= &mergedPrfl ) ;
	if( !( sts & 1 & *msg ) ) mergedPrfl = *profile ;
	
	/*
	 * Unite arrows and axis in an AC complex created in `root' mode.
	 */
	linearRep->osnum	= cst->env_info->_MD_OS ;
	lRepCmps[0].objid	= axisCpy ;
	lRepCmps[3].objid	= mergedPrfl.objid ;

        /*
         * Change the display and level of the copy of axis as well as the
         * properties (we don't know where this here baby comes from, it may
         * well be non-displayable, or in background color, etc.)
         */
        VSchgSymbAndProps(	msg,
        			&lRepCmps[0],
        			cst->level,
        			cst->display,
        			cst->properties ) ;

	sts = VSbuildRootComplex(	msg,
					VS_K_bmLinearRepCPX,
					MAX,
					lRepCmps,
					names,
					cst->env_info,
					cst->env_info->_MD_OS,
					&linearRep->objid ) ;
	 __CheckRC( sts, *msg, "VSbuildRootComplex", wrapup ) ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup : 
	if( !( sts & 1 & *msg ) ) {
		/*
		 * Something failed: get rid of everything
		 * (light complex has not been constructed).
		 */

		if( copyAxis ) {
			vs$bulk_delete(	count	= MAX,
					grids	= lRepCmps,
					theEnv	= cst->env_info ) ;
		} else {
			vs$bulk_delete(	count	= MAX - 1,
					grids	= lRepCmps + 1,
					theEnv	= cst->env_info ) ;
		}
	}
	return sts ;

} /* VSmake_linear_beam_rep */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;



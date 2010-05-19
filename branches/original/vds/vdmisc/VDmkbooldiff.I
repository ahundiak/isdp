/*
	I/VDS	Copy
*/
class implementation EMSslboolean ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "v_globalmsg.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_ioproto.h"

extern void	VD_resetObjidList() ;
extern long	VD_chgEMSseverity() ;

extern OMuword		OPP_EMSslboolean_class_id,
			OPP_EMSsubbs_class_id ;
extern IGRboolean	ASbroadcast_in_progress ;
/*----------------------------------------------------------------------------*/
long VD_make_boolean_difference(	msg,
				optrCount,
				optrList,
				operand,
				resCst,
				compress,
				oneAtATime,
				result )
/*
 * This function is interfaced by macro vd_$make_boolean_difference, #defined
 * in "v_geommacros.h".
 */

long			*msg ;
int			optrCount,
			compress,
			oneAtATime ;
struct GRobj_env	optrList[],
			*operand ;
struct GRvg_construct	*resCst ;
struct GRid		*result ; {

	int		i ;		/* Loop index			*/
	long		sts,		/* OM return code		*/
			rc ;		/* Return code of boolean op.	*/
	IGRboolean	saveBroadcast ;	/* Save-broadcast flag		*/
	OM_S_OBJID	*operator ;	/* List of operators		*/
	struct GRmd_env	*cstEnv	;	/* Unburdens compiler		*/
	struct GRsymbology
			symb ;
	int		nbSuccesses = 0 ;
	OMbyte		*successes  = NULL ;

	sts = OM_S_SUCCESS ;

	cstEnv = resCst->env_info ; result->objid = NULL_OBJID ;

	if(    !( operator  = _MALLOC( optrCount, OM_S_OBJID ) )
	    || !( successes = _CALLOC( optrCount, OMbyte ) ) ) {
		vd_$mem_fail() ;
	}
	VD_resetObjidList( optrCount, operator ) ;

	/*
	 * We have to copy the input solid since they will be absorbed by the
	 * boolean difference.
	 */
	for( i = 0 ; i < optrCount ; i++ ) {

		saveBroadcast = ASbroadcast_in_progress ;
		ASbroadcast_in_progress = TRUE ;

		sts = om$send(	msg     = message GRgraphics.GRcopy(
							msg,
							&optrList[i].mod_env,
							cstEnv,
							operator + i ),
				senderid= optrList[i]._objid,
				targetid= optrList[i]._objid,
				targetos= optrList[i]._osnum ) ;
		ASbroadcast_in_progress = saveBroadcast ;

		if( vd_$is_ancestry_valid(
					object	= &optrList[i]._grid,
					classid	= OPP_EMSsubbs_class_id ) ) {
			struct GRid	O ;

			/*
			 * If we have got a surface, we must put some topology
			 * on it (if it has none), otherwise its boundaries
			 * will be kept in the boolean difference.
			 */
			O.objid = operator[i] ;
			O.osnum = cstEnv->_MD_OS ;

			sts = vd_$make_natural_boundary(
					msg		= msg,
					surfaceEnv	= cstEnv,
					surfaceId	= &O ) ;
			__CheckRC( sts, *msg, "vd_$make_natural_boundary", wrapup ) ;
		}
	}

	if( oneAtATime ) {
		OM_S_OBJID	oprnd ;

		oprnd = operand->_objid ;

		for( i = 0 ; i < optrCount ; i++ ) {
			result->osnum = cstEnv->_MD_OS ;
			*msg = EMS_E_OMerror ;
			sts = om$construct(
				classid = OPP_EMSslboolean_class_id,
				osnum	= result->osnum,
				p_objid = &result->objid ) ;
			__CheckRC( sts, 1, "om$construct", wrapup ) ;

			sts = om$send(	msg     = message EMSslboolean.EMboolean(
 					&rc, 
					&cstEnv->_MATRIX_TYPE,
					cstEnv->_MATRIX,
		       			oprnd,
					1,
					operator + i,
		       			resCst,
					EMSbool_difference,
					EMSsfbool_opt_retryDisjoint,
					VDmsgkey2string( VD_gI_Processing ),
					NULL,
					NULL,
					NULL,
					NULL ),
				senderid= result->objid,
				targetid= result->objid,
				targetos= result->osnum ) ;

			/*
			 * Skip those which fails...
			 */
			*msg = VD_chgEMSseverity( rc ) ;
			if( sts & 1 & *msg ) {
				oprnd = result->objid ;
				successes[i] = TRUE ;
				nbSuccesses++ ;
			}
		}
		*msg = nbSuccesses ? MSSUCC : MSFAIL ;
		sts = OM_S_SUCCESS ;
	} else {

		result->osnum = cstEnv->_MD_OS ;
		*msg = EMS_E_OMerror ;
		sts = om$construct(	classid = OPP_EMSslboolean_class_id,
					osnum	= result->osnum,
					p_objid = &result->objid ) ;
		__CheckRC( sts, 1, "om$construct( EMSslboolean )", wrapup ) ;
	
		sts = om$send(	msg     = message EMSslboolean.EMboolean(
 					&rc, 
					&cstEnv->_MATRIX_TYPE,
					cstEnv->_MATRIX,
		       			operand->_objid,
					optrCount,
					operator,
		       			resCst,
					EMSbool_difference,
					EMSsfbool_opt_retryDisjoint,
					VDmsgkey2string( VD_gI_Processing ),
					NULL,
					NULL,
					NULL,
					NULL ),
				senderid= result->objid,
				targetid= result->objid,
				targetos= result->osnum ) ;
		*msg = VD_chgEMSseverity( rc ) ;
	}

	if( !( sts & 1 & *msg ) ) {
		/*
		 * Caution: result may have absorbed operand.
		 */
		if( rc & 1 ) {
			long	RC ;
			om$send(msg	= message GRconnector.GRdisconn(
								&RC, result ),
				senderid= operand->_objid,
				targetid= operand->_objid,
				targetos= operand->_osnum ) ;
		}
		*msg = EMS_E_BoolFail ;
		goto wrapup ;
	}

	if( compress ) {
		sts = om$send(	msg     = message EMSdpr.EMmake_primitive1(
							msg, cstEnv, result ),
				senderid= result->objid,
				targetid= result->objid,
				targetos= result->osnum );
		__CheckRC( sts, *msg, "EMSdpr.EMmake_primitive1", wrapup ) ;
	}

	/*
	 * For some reason, the intersection surfaces of the result of the
	 * boolean solid take the color of the input solids. So let's reset
	 * them.
	 */
	symb.level		= resCst->level ;
	symb.display_attr	= *resCst->display ;
	sts = om$send(	msg	= message GRvg.GRputsymb( msg, &symb ),
			senderid= result->objid,
			targetid= result->objid,
			targetos= result->osnum ) ;

	wrapup :	
	ex$message( msgnumb = VD_gI_EmptyMessage ) ;

	if( !( sts & 1 & *msg ) ) {
		/*
		 * Delete result if constructed.
		 */
		vd_$bulk_delete(	count	= 1,
				grids	= result,
				theEnv	= cstEnv ) ;
		if( operator ) {
			vd_$bulk_delete(	count	= optrCount,
					objids	= operator,
					theEnv	= cstEnv ) ;
		}
	} else {
		/*
		 * The parent solids will have been undisplayed when their
		 * copies are undisplayed, since they are at the same locations.
		 * Redisplay them.
		 */
		vd_$bulk_display(count	= optrCount,
				objenvs	= optrList,
				dpmode	= GRbd ) ;
		*msg = nbSuccesses == optrCount ? MSSUCC : EMS_I_Fail ;
		/*
		 * If we have partrly succeeded, delete the objects which
		 * have not beenn absorbed in the boolean difference.
		 */
		for( i = 0 ; i < optrCount ; i++ ) {
		  if( !successes[i] ) {
		      vd_$bulk_delete(	objids	= operator + i,
					theEnv	= cstEnv ) ;
		  }
		}
	}
	_FREE( operator  ) ;
	_FREE( successes ) ;

	return sts ;

} /* VD_make_boolean_difference */
/*----------------------------------------------------------------------------*/

end implementation EMSslboolean ;

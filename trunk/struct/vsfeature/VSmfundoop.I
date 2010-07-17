/*
	I/STRUCT
*/
class implementation VSmodFeature ;

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
/*----------------------------------------------------------------------------*/
method VSundoOperation(	long			*msg ;
			struct GRmd_env		*myEnv,
						*oprtrEnv ;
			struct GRid		*oprtrId ;
			struct GRobj_env	*visibleObj ; ) {

	long			sts ;		/* OM return code	*/
	VSopHistory		*history,	/* Hist. of located part*/
				*h,		/* Loop-on-results ptr.	*/
				*found,		/* Result to undo	*/
				*previous ;	/* Result before found	*/
	int			row,		/* Row index		*/
				opCount ;	/* Count of operators	*/
	VSoperator		*opList ;	/* List of operators	*/
	struct GRid		operator ;	/* Source of operator	*/
	int			wasDeleted ;

	/*
	 * NOTE: if visibleObj is NULL, we only check that the input operator
	 * is in the history, no undo takes place.
	 */
	history = NULL ;

	/*
	 * Get list of operations.
	 */
	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg, myEnv, &history ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	/*
	 * Check that located operator is in the history.
	 */
	previous = found = NULL ;

	for( row = 0, h = history ; h ; row++, previous = h, h = h->next ) {

		if( h && ( opCount = h->opCount ) && ( opList = h->opList ) ) {
			int o ;
			for( o = 0 ; o < opCount ; o++ ) {
				struct GRid	OP ;

				/*
				 * The operator is an associative object itself
				 * and not the graphic it owns.
				 */
				if(    opList[o].id == oprtrId->objid
				    && opList[o].os == oprtrId->osnum ) {
					found = h ;
					operator.objid = opList[o].id ;
					operator.osnum = opList[o].os ;
					goto UNDO ;
				}
				/*
				 * We have an AS header object: get owned
				 * graphic. Do not complain if message fails:
				 * we may have hit a non-graphic AS object,
				 * eg. a user or private attribute collection.
				 */
				sts = om$send(
					msg	= message NDmacro.ACreturn_foot(
							msg, "", &OP, NULL, NULL ),
					targetid= opList[o].id,
					targetos= opList[o].os ) ;

				if( !( sts & 1 ) ) {
					OP.objid = NULL_OBJID ;
					OP.osnum = (OMuword) -1 ;
				}

				if( IF_EQ_GRID( OP, *oprtrId ) ) {
					found = h ;
					operator.objid = opList[o].id ;
					operator.osnum = opList[o].os ;
					goto UNDO ;
				}
			}
		}
	}
	UNDO :

	if( !found ) {
		sts = OM_W_ABORT ; *msg	= MSINARG ; goto wrapup ;
	}

	if( !visibleObj ) {
		/*
		 * Check only, no undo.
		 */
		sts = OM_S_SUCCESS ; *msg = MSSUCC ; goto wrapup ;
	}

	/*
	 * Erase result.
	 */
	vs$bulk_display(	objids	= &my_id,
				theEnv	= myEnv,
				dpmode	= GRbe ) ;

	sts = om$send(	msg	= message VSmodFeature.VSremoveOperator(
							msg,
							&found->resultEnv,
							&operator,
							&wasDeleted ),
			targetid= found->resultId,
			targetos= found->resultOs ) ;
	__CheckRC( sts, *msg, "VSmodFeature.VSremoveOperator", wrapup ) ;

	/*
	 * Now find last result of history (the one that is visible
	 * to the user).
	 */
	if( !wasDeleted ) {
		visibleObj->_objid	= my_id ;
		visibleObj->_osnum	= OM_Gw_current_OS ;
		visibleObj->mod_env	= *myEnv ;
	} else {
		if(     IF_EQ_OBJID( my_id, found->resultId )
		    &&  OM_Gw_current_OS == found->resultOs ) {

			/*
			 * I'm deleted.
			 */
			visibleObj->_objid	= previous->resultId ;
			visibleObj->_osnum	= previous->resultOs ;
			visibleObj->mod_env	= previous->resultEnv ;
		} else {
			/*
			 * I'm not deleted.
			 */
			visibleObj->_objid	= my_id ;
			visibleObj->_osnum	= OM_Gw_current_OS ;
			visibleObj->mod_env	= *myEnv ;
		}
	}

	wrapup :
		VSfreeOpHistory( history ) ;
		return sts ;

} /* method VSundoOperation */
/*----------------------------------------------------------------------------*/

end implementation VSmodFeature ;


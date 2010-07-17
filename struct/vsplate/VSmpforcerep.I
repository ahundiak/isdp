/* $Id: VSmpforcerep.I,v 1.2 2001/01/17 00:00:00 ramarao Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:      vsplate/VSmpforcerep.I 
 *
 * Description:Forcing 2D rep for the parent of a plate in the cutout process 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmpforcerep.I,v $
 *      Revision 1.2  2001/01/17 00:00:00  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/04/28  20:30:08  pinnacle
# Created: struct/vsplate/VSmpforcerep.I by rchennup for Service Pack
#
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 04/28/00  Jayadev  changes made for process cutout command - always 
 *		      connect the  plate back to its parents even if the
 *		      parent compute fails 
 *************************************************************************/

/*
	I/STRUCT
*/
class implementation VSmodPlate ;

#include <stdlib.h>
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "ASsupport.h"
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method	VSforceParentRep(	long		*msg ;
				struct GRmd_env	*myEnv ;
				struct GRid	*parentId ;
				VSdspRep	badRep1,
						badRep2,
						repToSet1,
						repToSet2,
						*oldRep ) {

	long			sts ;		/* OM return code	*/
	int			parentCount ;	/* Count of my parents	*/
	struct GRid		*parentList,	/* List of my parents	*/
				virtual ;	/* "Virtual" parent	*/
	VSdspRep		parentRep,	/* Parent's rep.	*/
				cRep,
				newRep ;
	struct GRmd_env		parentEnv ;

	parentList = NULL ;

	/*
	 * Be careful with module environments : parent may be in another OS
	 * a reference file or a macro library...
	 */
	sts = VSgetVirtualInfo( msg, parentId, &parentEnv, &virtual ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &parentRep ),
			targetid= virtual.objid,
			targetos= virtual.osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	*oldRep = parentRep ;

	sts = om$send(	msg	= message VSfeature.VSgetConsumedRep( &cRep ),
			targetid= virtual.objid,
			targetos= virtual.osnum ) ;

	newRep = 0 ;
	if( ( parentRep & badRep1 ) || ( cRep & badRep1 ) ) {
		newRep = repToSet1 ;
	}
	if( ( parentRep & badRep2 ) || ( cRep & badRep2 ) ) {
		newRep = repToSet2 ;
	}
	if( parentRep == AC_2D_REP && repToSet1 == VS_m_2dWCompute ) {
		newRep = repToSet1 ;
	}

	if( newRep ) {
		struct GRid	*buffer,
				whoMustRecompute ;
	
		/*
		 * Undisplay parent (use VIRTUAL since REAL may be a pretend
		 * and does not understand display messages).
		 */
		vs$bulk_display(	grids	= &virtual,
					theEnv	= &parentEnv,
					dpmode	= GRbe ) ;

		/*
		 * Get parents then disconnect from them.
		 */
		sts = om$send(	msg	= message NDnode.NDget_objects(
							ND_ROOT | ND_IN_BUF,
							NULL, 0,
							&buffer,
							0, OM_K_MAXINT,
							&parentCount ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		parentList = (struct GRid *) VSmemdup(
					buffer,
					parentCount * sizeof( struct GRid ) ) ;
		if( !parentList ) vs$mem_fail() ;

		sts = om$send(	msg	= message NDnode.NDdisconnect( 0, NULL),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

		/*
		 * I want parent to recompute, but not myself, so I disconnect
		 * myself from parents and will reconnect after compute.
		 */
		sts = om$send(	msg	= message ACncpx.ACput_NV_rep( newRep ),
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, 1, "ACncpx.ACset_NV_rep", wrapup ) ;

		if( IF_EQ_GRID( virtual, *parentId ) ) {
			/*
			 * Parent is a not an output in a complex: my parent
			 * must recompute.
			 */
			 whoMustRecompute = *parentId ;
		} else {
			/*
			 * Either I am inside a macro definition and my parent
			 * is an input of that macro or parent is an output
			 * in a macro occurrence.
			 */
			ASget_as_owner( &virtual, &whoMustRecompute ) ;
			if( IF_NULL_OBJID( whoMustRecompute.objid ) ) {
				/*
				 * Parent is an input of a macro :
				 * "*parentid" is a pretend
				 * virtual     is the feature I want to
				 *             recompute
				 */
				whoMustRecompute = virtual ;
			} /* Else
			   * parent is a macro occurrence's output, this output
			   * cannot recompute so the occurrence must do it.
			   */
		}

		sts = om$send(	msg	= message VSfeature.VSputConsumedRep(
								newRep ),
				targetid= whoMustRecompute.objid,
				targetos= whoMustRecompute.osnum ) ;

		if( IF_NULL_OBJID( myEnv->_MD_ID ) ) {
			parentEnv._MD_ID = NULL_OBJID ;
		}

		/*
		 * Object must recompute in its natural world, ie. with the
		 * identity matrix.
		 */
		MAidmx( msg, parentEnv._MATRIX ) ;
		parentEnv._MATRIX_TYPE = MAIDMX ;
		sts = om$send(	msg	= message NDnode.NDs_compute_node(
							msg, 0, &parentEnv ),
				targetid= whoMustRecompute.objid,
				targetos= whoMustRecompute.osnum ) ;
		//__CheckRC( sts, *msg, "NDnode.NDcompute_node", wrapup ) ;
		if(!(sts&*msg&1)){
			printf("\n Parent[%d,%d] compute failed !!! \n",whoMustRecompute.objid,whoMustRecompute.osnum ) ;
		}

		/*
		 * Reconnect to parents.
		 */
		sts = om$send(	msg	= message NDnode.NDconnect(
								parentCount,
								parentList,
								NULL_GRID,
								ND_NEW ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;
		
	} else if( !cRep ) {
		sts = om$send(	msg	= message VSfeature.VSputConsumedRep( 
								parentRep ),
				targetid= virtual.objid,
				targetos= virtual.osnum ) ;
		__CheckRC( sts, 1, "VSfeature.VSputConsumedRep", wrapup ) ;
	}

	wrapup : _FREE( parentList ) ;
		 return sts ;

} /* method VSforceParentRep */
/*----------------------------------------------------------------------------*/

end implementation VSmodPlate ;

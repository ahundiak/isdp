/* $Id: VSsjputattr.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSsjputattr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSsjputattr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/06  22:14:24  pinnacle
# Placement Problems
#
# Revision 1.3  1997/12/19  04:00:20  pinnacle
# Replaced: vsjoint/VSsjputattr.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:16:14  pinnacle
# Replaced: vsjoint/VSsjputattr.I for:  by svkadamb for struct
#
 *
 *  History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *	      suresh  modification
 *  01/06/98  ah      Make sure VSfindCollection really finds an object 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSsrcJoint ;

#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsjoint.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsdatadef.h"
#include "vsdata.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes for function prototypes.
 */
#include "vsshdatproto.h"

extern struct GRid	NULL_GRID ;

from VSsharedData	import VSgetData ;
/*----------------------------------------------------------------------------*/
method GRputattr(	long	*msg ;
			char	*attr ) {

	long		sts ;			/* OM return code	*/
	VSpartAttr	*part ;			/* Part attributes	*/
	VSjointAttr	*joint ;		/* Joint attributes	*/
	unsigned long	toSet ;			/* Attributes to set	*/
	VSdataDesc	olist[VS_K_jnMAXDATA],	/* Old shared data list	*/
			nlist[VS_K_jnMAXDATA] ;	/* New shared data list	*/
	int		freeOlist,		/* OK to free olist ?	*/
			item2index[VS_K_jnMAXDATA] ;
						/* Map index -> item	*/
	struct GRid	oldData,		/* Previous private data*/
			newData ;		/* New privated data	*/

#define TO_SET( option ) ( ( toSet & (option) ) || ( toSet == VS_m_All ) )
#define SETstr( _i, _v ) \
	__DBGpr_int( "STR Item #", _i ) ;\
	__DBGpr_int( "STR Index", item2index[(_i)] ) ;\
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSstring ;\
	nlist[item2index[(_i)]].value.s	= (_v) ;
#define SETdbl( _i, _v ) \
	__DBGpr_int( "DBL Item #", _i ) ;\
	__DBGpr_int( "DBL Index", item2index[(_i)] ) ;\
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSdouble ;\
	nlist[item2index[(_i)]].value.d	= (_v) ;
#define SETint( _i, _v ) \
	__DBGpr_int( "INT Item #", _i ) ;\
	__DBGpr_int( "INT Index", item2index[(_i)] ) ;\
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSint ;\
	nlist[item2index[(_i)]].value.i	= (_v) ;

	SetProc( VSsrcJoint_GRputattr ) ; Begin ; __DBGpr_me() ;

	part		= (VSpartAttr *) attr ;
	joint		= (VSjointAttr *) part->specific ;
	toSet		= part->Iwant ;
	freeOlist	= FALSE ;

	/*
	 * Retrieve previous data if any.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &oldData ),
			targetid= my_id ) ;

	__DBGpr_obj( "My previous data", oldData ) ;

  /* It can happen that no errors are generated even though no
   * collection is found, check the actual objid to make sure
   */
	if((*msg & 1 & sts) && (oldData.objid != NULL_OBJID)) {
		int i ;

		for( i = 0 ; i < VS_K_jnMAXDATA ; i++ ) {
			olist[i].index = i ;
		}
		sts = om$send(	msg	= message VSsharedData.VSgetData(
						msg, VS_K_jnMAXDATA, olist ),
				targetid= oldData.objid,
				targetos= oldData.osnum ) ;
		__CheckRC( sts, *msg, "VSsharedData.VSgetData", wrapup ) ;

		freeOlist = TRUE ;
		for( i = 0 ; i < VS_K_jnMAXDATA ; i++ ) {
			item2index[olist[i].index]	= i ;
			nlist[i]			= olist[i] ;
		}
	} else {
		int i ;
		for( i = 0 ; i < VS_K_jnMAXDATA ; i++ ) {
			__DBGpr_int( "Setting item2index to", i ) ;
			item2index[i]	= i ;
		}
	}

/* -- Weld code			*/
	if( TO_SET( VS_m_WeldAttr ) ) {
		int	wa ;
		memcpy( &wa, &joint->weldAttr, sizeof( int ) ) ;
		SETint( VS_K_jnWeldAttr, wa ) ;
	}
/* -- Additional Weld attributes			*/
	if( TO_SET( VS_m_AddWeldAttr ) ) {
		int	addWa ;
		memcpy( &addWa, &joint->addWldAttr, sizeof( int ) ) ;
		SETint( VS_K_jnAddWeldAttr, addWa ) ;
	}

/* -- Allowance			*/
	if( TO_SET( VS_m_Allowance ) ) {
		SETdbl( VS_K_jnAllowance, joint->allowance ) ;
	}

/* -- Groove angle		*/
	if( TO_SET( VS_m_GrooveAngle ) ) {
		SETdbl( VS_K_jnGrooveAngle, joint->grooveAngle ) ;
	}

/* -- Pitch			*/
	if( TO_SET( VS_m_Pitch ) ) {
		SETdbl( VS_K_jnPitch, joint->pitch ) ;
	}

/* -- Length of increments	*/
	if( TO_SET( VS_m_IncrLength ) ) {
		SETdbl( VS_K_jnIncrLength, joint->incrLength ) ;
	}

/* --	Shrikage		*/
	if( TO_SET( VS_m_Shrinkage ) ) {
		SETdbl( VS_K_jnShrinkage, joint->shrinkage ) ;
	}
	
/* -- weld size			*/
	if( TO_SET( VS_m_Size ) ) {
		SETdbl( VS_K_jnSize, joint->size ) ;
	}

/* -- User symbol		*/
	if( TO_SET( VS_m_UsrSymbol ) ) {
		SETstr( VS_K_jnUsrSymbol, joint->usrSymbol ) ;
	}

#ifdef vsDEBUG
	VSdumpSharedData( VS_K_jnMAXDATA, nlist ) ;
#endif
	/*
	 * Now get a new data collection.
	 */
	newData.osnum = OM_Gw_current_OS ;
	sts = vs$getSharedData(	msg	= msg,
				osnum	= newData.osnum,
				count	= VS_K_jnMAXDATA,
				data	= nlist,
				p_objid	= &newData.objid ) ;
	__CheckRC( sts, *msg, "vs$getSharedData", wrapup ) ;

	__DBGpr_obj( "New data", newData ) ;

	if( IF_NULL_OBJID( oldData.objid ) ) {
		__DBGpr_com( "First time: connect" ) ;
		sts = om$send(	msg	= message NDnode.NDconnect(
						1, &newData, NULL_GRID, ND_ADD),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;
	} else if( !IF_EQ_GRID( oldData, newData ) ) {
		__DBGpr_com( "Change connect" ) ;
		sts = om$send(	msg	= message NDnode.NDchange_connect(
							1, &oldData, &newData ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;
	}

	/*
	 * Now put collection of user-attributes, if any.
	 */
	if( TO_SET( VS_m_UsrAttr ) ) {
		__DBGpr_obj( "User attr.", part->usrAttr ) ;
		sts = om$send(	msg	= message VSfeature.VSputUsrAttributes(
							msg, &part->usrAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSputUsrAttributes", wrapup ) ;
		
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		if( freeOlist ) VSfreeData( VS_K_jnMAXDATA, olist ) ;
		End
		return sts ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcJoint ;

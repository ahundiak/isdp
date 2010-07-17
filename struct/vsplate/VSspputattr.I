/*
	I/STRUCT
*/
class implementation VSsrcPlate ;

#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsplatmacros.h"
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

from VSsharedData	import	VSgetData ;
/*----------------------------------------------------------------------------*/
method GRputattr(	long	*msg ;
			char	*attr ) {

	long		sts ;			/* OM completion code	*/
	VSpartAttr	*part ;			/* Part attributes	*/
	VSplateAttr	*plate ;		/* Plate attributes	*/
	unsigned long	toSet ;			/* Attributes to set	*/
	VSdataDesc	olist[VS_K_plMAXDATA],	/* Old shared data list	*/
			nlist[VS_K_plMAXDATA] ;	/* New shared data list	*/
	int		freeOlist,		/* OK to free olist ?	*/
			item2index[VS_K_plMAXDATA] ;
						/* Map index -> item	*/
	struct GRid	oldData,		/* Previous private data*/
			newData ;		/* New privated data	*/
	double		cutoff,
			thickness ;

#define TO_SET( option ) ( ( toSet & (option) ) || ( toSet == VS_m_All ) )
#define SETstr( _i, _v ) \
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSstring ;\
	nlist[item2index[(_i)]].value.s	= (_v) ;
#define SETdbl( _i, _v ) \
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSdouble ;\
	nlist[item2index[(_i)]].value.d	= (_v) ;
#define SETint( _i, _v ) \
	nlist[item2index[(_i)]].index	= (_i) ;\
	nlist[item2index[(_i)]].type	= VSint ;\
	nlist[item2index[(_i)]].value.i	= (_v) ;

	part		= (VSpartAttr	*) attr ;
	plate		= (VSplateAttr	*) part->specific ;
	toSet		= part->Iwant ;
	freeOlist	= FALSE ;
	*msg		= MSFAIL ;

	/*
	 * Retrieve previous data if any.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &oldData ),
			targetid= my_id ) ;

	if( sts & 1 & *msg ) {
		int i ;

		for( i = 0 ; i < VS_K_plMAXDATA ; i++ ) olist[i].index = i ;

		sts = om$send(	msg	= message VSsharedData.VSgetData(
						msg, VS_K_plMAXDATA, olist ),
				targetid= oldData.objid,
				targetos= oldData.osnum ) ;
		__CheckRC( sts, *msg, "VSsharedData.VSgetData", wrapup ) ;

		thickness	= olist[VS_K_plThickness	].value.d ;
		cutoff		= olist[VS_K_plCutOff		].value.d ;

		freeOlist = TRUE ;
		for( i = 0 ; i < VS_K_plMAXDATA ; i++ ) {
			item2index[olist[i].index]	=  i ;
			nlist[i]			= olist[i] ;
		}
	} else {
		int i ;
		cutoff = thickness = 0. ;
		for( i = 0 ; i < VS_K_plMAXDATA ; i++ ) item2index[i] = i ;
	}

/* -- PDM/PDU family name	*/
	if( TO_SET( VS_m_PartFam ) ) {
		SETstr( VS_K_plPartFam, part->info.family ) ;
	}
/* -- PDM/PDU part number	*/
	if( TO_SET( VS_m_PartNum ) ) {
		SETstr( VS_K_plPartNum, part->info.partNum ) ;
	}
/* -- Material			*/
 	if( TO_SET( VS_m_MatType ) ) {
		SETstr( VS_K_plMatType, part->info.material ) ;
 	}
/* -- Grade of material		*/
	if( TO_SET( VS_m_MatGrade ) ) {
		SETstr( VS_K_plMatGrade, part->info.grade ) ;
 	}
/* -- Member class		*/
	if( TO_SET( VS_m_MbrClass ) ) {
		SETint( VS_K_plMbrClass, part->info.memberClass ) ;
	}
/* -- Member type		*/
	if( TO_SET( VS_m_MbrType ) ) {
		SETint( VS_K_plMbrType, part->info.memberType ) ;
	}
/* -- User comments		*/
	if( TO_SET( VS_m_Notes ) ) {
		SETstr( VS_K_plNotes, part->info.notes ) ;
	}
/* -- Source number		*/
	if( TO_SET( VS_m_MtoSrc ) ) {
		SETstr( VS_K_plMtoSrc, part->mto.source ) ;
	}
/* -- Stock number		*/
	if( TO_SET( VS_m_MtoStk ) ) {
		SETstr( VS_K_plMtoStk, part->mto.stock ) ;
	}
/* -- Change-request number	*/
	if( TO_SET( VS_m_ChgNum ) ) {
		SETint( VS_K_plMtoChgNum, part->mto.chgnum ) ;
	}
/* -- Fireproofing thickness	*/
	if( TO_SET( VS_m_FpThck ) ) {
		SETdbl( VS_K_plFpThck, part->info.fpthickness ) ;
	}
/* -- Approval status		*/
	if( TO_SET( VS_m_AppStat ) ) {
		SETstr( VS_K_plApprSts, part->info.apprvstat ) ;
	}
/* -- Construction status	*/
	if( TO_SET( VS_m_CstStat ) ) {
		SETstr( VS_K_plCnstSts, part->info.conststat ) ;
	}
/* -- Plate thickness		*/
	if( TO_SET( VS_m_Thickness ) ) {
		SETdbl( VS_K_plThickness, plate->thickness ) ;
		/*
		 * Do not allow cut-off < thickness !
		 */
		if( cutoff < plate->thickness && !TO_SET( VS_m_CutOff ) ) {
			cutoff = plate->thickness ;
			SETdbl( VS_K_plCutOff, cutoff ) ;
		}
		thickness = plate->thickness ;
	}
/* -- Plate cut-off thickness	*/
	if( TO_SET( VS_m_CutOff ) ) {
		/*
		 * Do not allow cut-off < thickness !
		 */
		if( plate->cut_off < thickness ) {
			cutoff 	= thickness ;
		} else {
			cutoff = plate->cut_off ;
		}
		SETdbl( VS_K_plCutOff, cutoff ) ;
	}
/* -- Offset from support	*/
	if( TO_SET( VS_m_Offset ) ) {
		SETdbl( VS_K_plOffset, plate->offset ) ;
	}
/* -- Orientation (natural/rev.)*/
	if( TO_SET( VS_m_Orientation ) ) {
		SETint( VS_K_plOrientation, plate->orientation ) ;
	}

	/*
	 * Now get a new data collection.
	 */
	newData.osnum = OM_Gw_current_OS ;
	sts = vs$getSharedData(	msg	= msg,
				osnum	= newData.osnum,
				count	= VS_K_plMAXDATA,
				data	= nlist,
				p_objid	= &newData.objid ) ;
	__CheckRC( sts, *msg, "vs$getSharedData", wrapup ) ;

	if( IF_NULL_OBJID( oldData.objid ) ) {

		sts = om$send(	msg	= message NDnode.NDconnect(
						1, &newData, NULL_GRID, ND_ADD),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;
	} else if( !IF_EQ_GRID( oldData, newData ) ) {

		sts = om$send(	msg	= message NDnode.NDchange_connect(
							1, &oldData, &newData ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;
	}

	/*
	 * Now put collection of user-attributes, if any.
	 */
	if( TO_SET( VS_m_UsrAttr ) ) {

		sts = om$send(	msg	= message VSfeature.VSputUsrAttributes(
							msg, &part->usrAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSfeature.VSputUsrAttributes", wrapup ) ;
	}

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup : 
		if( freeOlist ) VSfreeData( VS_K_plMAXDATA, olist ) ;

		return sts ;

} /* method GRputattr */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;

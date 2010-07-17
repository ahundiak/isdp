/*
	I/STRUCT
*/
#include <string.h>
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
#include "vsplatmacros.h"
/*----------------------------------------------------------------------------*/
long VSfillPlateAttr(	msg,
			mask,
			partFam,	/*  1 PDM/PDU family name	*/
			partNum,	/*  2 PDM/PDU part number	*/
			matType,	/*  3 Material			*/
			matGrade,	/*  4 Grade of material		*/
			mbrClass,	/*  5 Member class		*/
			mbrType,	/*  6 Member type		*/
			usrNotes,	/*  7 User comments		*/
			mtoSrc,		/*  8 Source number		*/
			mtoStk,		/*  9 Stock number		*/
			mtoChgNo,	/* 10 Change request number	*/
			FireProofing,	/* 11 Fireproofing thickness	*/
			apprvStat,	/* 12 Approval status		*/
			constStat,	/* 13 Construction status	*/
			usrAttr,	/* 14 Collection of user attr.	*/
			thickness,	/* 15 Plate thickness		*/
			cutOff,		/* 16 Plate cut-off thickness	*/
			offset,		/* 17 Offset from support	*/
			orientation,	/* 18 Orietation (natural/rev.)	*/
			part,
			plate )
long		*msg ;
int		mask ;
double		thickness,
		cutOff,
		offset,
		FireProofing ;
int		orientation,
		mbrClass,
		mbrType,
		mtoChgNo ;
char		*matType,
		*matGrade,
		*partFam,
		*partNum,
		*usrNotes,
		*mtoSrc,
		*mtoStk,
		*apprvStat,
		*constStat ;
struct GRid	*usrAttr ;
VSpartAttr	*part ;
VSplateAttr	*plate ; {

/*
 * This function interfaced by macro vs$fillPlateAttr
 */
		int		trunc,
				dataLoss = FALSE ;
		VSpartInfo	*info = &part->info ;

#define TO_SET( option ) ( ( mask & (option) ) || ( mask == VS_m_All ) )

	part->specific	= plate ;
	part->Iwant	= mask ;

	memset( &part->info	, 0, sizeof part->info	) ;
	memset( &part->mto	, 0, sizeof part->mto	) ;

/* -- PDM/PDU family name	*/
 	if( TO_SET( VS_m_PartFam ) ) {
		VSstrncpy( info->family, partFam, VS_K_FamilyLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- PDM/PDU part number	*/
	if( TO_SET( VS_m_PartNum ) ) {

		VSstrncpy( info->partNum, partNum, VS_K_PrtNumLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Material			*/
 	if( TO_SET( VS_m_MatType ) ) {
		VSstrncpy( info->material, matType, VS_K_MatTypLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Grade of material		*/
	if( TO_SET( VS_m_MatGrade ) ) {
		VSstrncpy( info->grade, matGrade, VS_K_MatGrdLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Member class		*/
	if( TO_SET( VS_m_MbrClass ) ) {
		info->memberClass = mbrClass ;
	}
/* -- Member type		*/
	if( TO_SET( VS_m_MbrType ) ) {
		info->memberType = mbrType ;
	}
/* -- User comments		*/
	if( TO_SET( VS_m_Notes ) ) {
		VSstrncpy( info->notes, usrNotes, VS_K_UsrNotLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Source number		*/
	if( TO_SET( VS_m_MtoSrc ) ) {
		VSstrncpy( part->mto.source , mtoSrc, VS_K_MTOSrcLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Stock number		*/
	if( TO_SET( VS_m_MtoStk ) ) {
		VSstrncpy( part->mto.stock  , mtoStk, VS_K_MTOStkLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Change-request number	*/
	if( TO_SET( VS_m_ChgNum ) ) {
		part->mto.chgnum = mtoChgNo ;
	}
/* -- Fireproofing thickness	*/
	if( TO_SET( VS_m_FpThck ) ) {
		info->fpthickness = FireProofing ;
	}
/* -- Approval status		*/
	if( TO_SET( VS_m_AppStat ) ) {
		VSstrncpy( info->apprvstat, apprvStat, VS_K_AppStsLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Construction status	*/
	if( TO_SET( VS_m_CstStat ) ) {
		VSstrncpy( info->conststat, constStat, VS_K_CstStsLen, &trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}
/* -- Collection of user attr.	*/
	if( TO_SET( VS_m_UsrAttr ) ) {

		part->usrAttr = *usrAttr ;
	}
/* -- Plate thickness		*/
	if( TO_SET( VS_m_Thickness ) ) {

		plate->thickness	= thickness ;
	}
/* -- Plate cut-off thickness	*/
	if( TO_SET( VS_m_CutOff ) ) {

		plate->cut_off		= cutOff ;
	}
/* -- Offset from support	*/
	if( TO_SET( VS_m_Offset ) ) {

		plate->offset		= offset ;
	}
/* -- Orietation (natural/rev.)	*/
	if( TO_SET( VS_m_Orientation ) ) {

		plate->orientation	= orientation ;
	}
	*msg	= dataLoss ? EMS_I_Fail : MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSfillPlateAttr */
/*----------------------------------------------------------------------------*/


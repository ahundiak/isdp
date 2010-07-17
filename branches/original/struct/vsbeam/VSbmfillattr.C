/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "OMerrordef.h"
#include "vspart.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vssectiondef.h"
#include "vsbeam.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSfillBeamAttr(	msg,
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
			mtoChgNo,	/* 10 Change-request number	*/
			FireProofing,	/* 11 Fireproofing thickness	*/
			apprvStat,	/* 12 Approval status		*/
			constStat,	/* 13 Construction status	*/
			usrAttr,	/* 14 Collection of user attr.	*/
			xOffset,	/* 15 X offset from beam axis	*/
			yOffset,	/* 16 Y offset from beam axis	*/
			RotAngle,	/* 17 Rot. angle wrt local CS	*/
			cardPnt,	/* 18 Cardinal point		*/
			symmetry,	/* 19 Symmetry wrt local CS	*/
			part,
			beam )
long				*msg ;
int				mask ;
double				xOffset,
				yOffset,
				RotAngle,
				FireProofing ;
enum VScardinal_point		cardPnt ;
enum VSsymmetry			symmetry ;
int				mbrClass,
				mbrType,
				mtoChgNo ;
char				*matType,
				*matGrade,
				*partFam,
				*partNum,
				*usrNotes,
				*mtoSrc,
				*mtoStk,
				*apprvStat,
				*constStat ;
struct GRid			*usrAttr ;
VSpartAttr			*part ;
VSbeamAttr			*beam ; {

/*
 * This function interfaced by macro vs$fillBeamAttr
 */
	int		trunc,
			dataLoss = FALSE ;
	VSpartInfo	*info = &part->info ;

#define TO_SET( option ) ( ( mask & (option) ) || ( mask == VS_m_All ) )

	memset( &part->info	, 0, sizeof part->info	) ;
	memset( &part->mto	, 0, sizeof part->mto	) ;

	part->specific	= (void *) beam ;
	part->Iwant	= mask ;


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
/* -- X offset from beam axis	*/
	if( TO_SET( VS_m_xOffset	) ) { beam->xoff  = xOffset ;	}

/* -- Y offset from beam axis	*/
	if( TO_SET( VS_m_yOffset	) ) { beam->yoff  = yOffset ;	}

/* -- Rot. angle wrt local CS	*/
	if( TO_SET( VS_m_RotAngle	) ) { beam->rotat = RotAngle ;	}

/* -- Cardinal point		*/
	if( TO_SET( VS_m_cardPnt	) ) { beam->card  = cardPnt ;	}

/* -- Symmetry wrt local CS	*/
	if( TO_SET( VS_m_Symmetry	) ) { beam->sym   = symmetry ;	}

	*msg	= dataLoss ? EMS_I_Fail : MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSfillBeamAttr */
/*----------------------------------------------------------------------------*/


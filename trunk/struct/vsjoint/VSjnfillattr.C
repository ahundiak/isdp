/* $Id: VSjnfillattr.C,v 1.1.1.1 2001/01/04 21:10:47 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsjoint/VSjnfillattr.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSjnfillattr.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:47  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/12/19  04:09:44  pinnacle
 * Replaced: vsjoint/VSjnfillattr.C for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  12:09:36  pinnacle
 * Replaced: vsjoint/VSjnfillattr.C for:  by svkadamb for struct
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/
/*
	I/STRUCT
*/
#include <stdio.h>		/* For NULL		*/
#include <string.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsjntmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSfillJointAttr(	msg,
			mask,
			allowance,
			grooveAngle,
			pitch,
			incrLength,
			weldAttr,
			addWldAttr,
			usrSymbol,
			size,
			shrinkage,
			usrAttr,
			part,
			joint )

long				*msg ;
int				mask ;
double				allowance,
				grooveAngle,
				pitch,
				incrLength,
				size,
				shrinkage ;
VSweldAttr			*weldAttr ;
VSaddWldAttr			*addWldAttr ;
char				*usrSymbol ;
struct GRid			*usrAttr ;
VSpartAttr			*part ;
VSjointAttr			*joint ; {

/*
 * This function interfaced by macro vs$fillJointAttr
 */
	int		trunc,
			dataLoss = FALSE ;

#define TO_SET( option ) ( ( mask & (option) ) || ( mask == VS_m_All ) )

	memset( &part->info	, 0, sizeof part->info	) ;
	memset( &part->mto	, 0, sizeof part->mto	) ;

	part->specific	= joint ;
	part->Iwant	= mask ;

/* -- Allowance			*/
	if( TO_SET( VS_m_Allowance ) ) {
		joint->allowance = allowance ;
	}

/* -- Groove angle		*/
	if( TO_SET( VS_m_GrooveAngle ) ) {
		joint->grooveAngle = grooveAngle ;
	}

/* -- Pitch			*/
	if( TO_SET( VS_m_Pitch ) ) {
		joint->pitch = pitch ;
	}

/* -- Length of increments	*/
	if( TO_SET( VS_m_IncrLength ) ) {
		joint->incrLength = incrLength ;
	}

/* -- Weld attributes		*/
	if( TO_SET( VS_m_WeldAttr ) ) {
		joint->weldAttr = *weldAttr ;
	}

/* -- Addtional Weld attributes		*/
	if( TO_SET( VS_m_AddWeldAttr ) ) {
		if( addWldAttr ) 
			joint->addWldAttr = *addWldAttr ;
	}
/* -- User symbol		*/
	if( TO_SET( VS_m_UsrSymbol ) ) {
		VSstrncpy(	joint->usrSymbol,
				usrSymbol,
				sizeof joint->usrSymbol,
				&trunc ) ;
		if( trunc ) dataLoss = TRUE ;
	}

/* -- Shrinkage			*/
	if( TO_SET( VS_m_Shrinkage ) ) {
                joint->shrinkage = shrinkage ;
        }

/* -- Size			*/
	if( TO_SET( VS_m_Size ) ) {
                joint->size = size ;
        }

/* -- Collection of user attr.	*/
	if( TO_SET( VS_m_UsrAttr ) ) {
		part->usrAttr = *usrAttr ;
	}
	*msg	= dataLoss ? EMS_I_Fail : MSSUCC ;

	return OM_S_SUCCESS ;

} /* VSfillJointAttr */
/*----------------------------------------------------------------------------*/

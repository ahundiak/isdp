/*
	I/STRUCT
*/

#ifndef vsdocvsovlap_include
#	define vsdocvsovlap_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsjoint_include
#	include "vsjoint.h"
#endif

/*+f
Function VSdoCurvesOverlap

Abstract
	Given two curves, finds out whether they overlap and if so, returns
	the list segments on which they overlap.
Arguments
	OUT	long			*msg	Completion code.
	IN	struct IGRbsp_curve	*cv0	First input curve.
	IN	struct IGRbsp_curve	*cv1	Second input curve.
	OUT	VSoverlapInfo		ovlInfo	Overlap information.
Keywords
	#curve#overlap#
Note
	`ovlInfo->code' may have the following values (#defined in vsjointdef.h)
		- VS_K_NO_OVERLAP	Curves do not overlap.
		- VS_K_COMMON_PORTION	Curves have common segments.
		- VS_K_0_COVERS_1	1st curve entirely covers 2nd curve.
		- VS_K_1_COVERS_0	2nd curve entirely covers 1st curve.
		- VS_K_TOTAL_MATCH	Curves are equal (within tolerance).
	`ovlInfo->count' is the count of overlaps.
	`ovlInfo->t0start[i]', `ovlInfo->t0end[i]', `ovlInfo->t1start[i]',
	`ovlInfo->t1end[i]', 0 <= i < ovlInfo->count contains the start and
	end parameters for the overlaps of the 1st and 2nd curve respectively.

	The memory allocated by this function must be released with:

		if( ovlInfo->count ) free( ovlInfo->t0start ) ;
-f*/
extern long
VSdoCurvesOverlap		__((	long			*msg,
					struct IGRbsp_curve	*cv0,
					struct IGRbsp_curve	*cv1,
					VSoverlapInfo		*ovlInfo )) ;

#endif

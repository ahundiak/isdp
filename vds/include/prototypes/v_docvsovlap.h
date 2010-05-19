/*
	I/VDS	Copy
*/

#ifndef v_docvsovlap_include
#	define v_docvsovlap_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/*+f
Function VD_doCurvesOverlap

Abstract
	Given two curves, finds out whether they overlap and if so, returns
	the list segments on which they overlap.
Arguments
	OUT	long			*msg	Completion code.
	IN	struct IGRbsp_curve	*cv0	First input curve.
	IN	struct IGRbsp_curve	*cv1	Second input curve.
	OUT	VD_overlapInfo		ovlInfo	Overlap information.
Keywords
	#curve#overlap#
Note
	`ovlInfo->code' may have the following values (#defined in v_jointdef.h)
		- VD_K_NO_OVERLAP	Curves do not overlap.
		- VD_K_COMMON_PORTION	Curves have common segments.
		- VD_K_0_COVERS_1	1st curve entirely covers 2nd curve.
		- VD_K_1_COVERS_0	2nd curve entirely covers 1st curve.
		- VD_K_TOTAL_MATCH	Curves are equal (within tolerance).
	`ovlInfo->count' is the count of overlaps.
	`ovlInfo->t0start[i]', `ovlInfo->t0end[i]', `ovlInfo->t1start[i]',
	`ovlInfo->t1end[i]', 0 <= i < ovlInfo->count contains the start and
	end parameters for the overlaps of the 1st and 2nd curve respectively.

	The memory allocated by this function must be released with:

		if( ovlInfo->count ) free( ovlInfo->t0start ) ;
-f*/

extern long
VD_doCurvesOverlap		__((	long			*msg,
					struct IGRbsp_curve	*cv0,
					struct IGRbsp_curve	*cv1,
					VD_overlapInfo		*ovlInfo )) ;

#endif

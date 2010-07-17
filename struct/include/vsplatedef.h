/* $Id: vsplatedef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	include/vsplatedef.h
 *
 * Description:
 *
 * Dependencies: acrepdef.h
 *
 * Revision History:
 *	$Log: vsplatedef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.3  2000/03/01  21:05:00  pinnacle
 * track point for VSsplPlate
 *
 * Revision 1.2  2000/02/04  22:58:20  pinnacle
 * Replaced: include/vsplatedef.h for:  by impd252 for struct
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/09/26  13:59:26  pinnacle
 * Impose Bound Limit
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		Raised Boundary Limit to 300
 *	02/04/00	ad		Rasied imposed cout-out list to 100
 *	02/25/00	mf		Add TrackPoint parent.
 ***************************************************************************/

#ifndef vsplatedef_include
#	define vsplatedef_include

/*
 * Sub-representations of plates.
 */
#define VS_m_2dWCompute	( (AC_2D_REP) | (AC_SUB_REP) )

/*
 * Base name of active collection of user attributes for plates.
 */
#	define VS_K_plateUA		"plateUA"

/*
 * Name of input graphics to one a source plate.
 */
#	define VS_K_plSuppSurf		"surface"

/*
 * Name of expression parent for parametric plate.
 */
#	define VS_K_vpThicknessExp	"thickness"

/*
 * Name of parent plate to be consumed for modified plates.
 */
#	define VS_K_mpParentPlate	"plate"

/*
 * Name of graphic component for all plates.
 */
#	define VS_K_plGrCmpName		"plate"

/*
 * Name of parent curve of split plate.
 */
#	define VS_K_cpSplitCurve	"splittingCurve"

/*
 * Name of parent track point of split plate.
 */
#	define VS_K_cpTrackPoint	"trackingPoint"

/*
 * Name of graphic components of split manager plate.
 */
#	define VS_K_cpGrCmpSurf0	"surface0"
#	define VS_K_cpGrCmpSurf1	"surface1"

/*
 * Name of parent splitting plate of split plate with a gap.
 */
#	define VS_K_cpSplittingPlate	"splittingPlate"

/*
 * (Path)names of bottom and top surfaces in graphic component.
 */
#	define VS_K_plTopSfName		"offset"
#	define VS_K_plBotSfName		"base"
#	define VS_K_plTopSfPath		"plate:offset"
#	define VS_K_plBotSfPath		"plate:base"

/*
 * (Path)names of bottom and top surfaces in graphic component to be used by
 * ACreturn_foot when :
 * - if top    is wanted but plate is reversed, return bottom
 * - if bottom is wanted but plate is reversed, return top
 * that is disregard plate orientation.
 */
#	define VS_K_plTopSfNameABS	"ABSoffset"
#	define VS_K_plBotSfNameABS	"ABSbase"
#	define VS_K_plTopSfPathABS	"plate:ABSoffset"
#	define VS_K_plBotSfPathABS	"plate:ABSbase"

/*
 * Maximum of boundaries for holed and maked plates.
 * 26 Sep 1997 Raised limit from 50 to 300
 */
#	define	VS_K_MAX_BOUNDARIES	300

/*
 * Maximum count of cut-outs allowed on one plate.
 */
#	define VS_K_bpMAX_NOTCHES	100

/*
 * Position of plate with respect to support surface.
 */
#	define	VS_K_PLATE_ON_TOP	0
#	define	VS_K_PLATE_ON_BOT	1
#	define	VS_K_PLATE_ON_MID	2
#	define	VS_K_USE_NAT_NORM	VS_K_PLATE_ON_TOP
#	define	VS_K_USE_REV_NORM	VS_K_PLATE_ON_BOT

/*
 *  Fast-data retrieval codes.
 */
#	define VS_K_fdGhOffSf	0
#	define VS_K_fdPlMsPps	1

/*
 * Indices of plate data in private collection.
 */
#	define VS_K_plMatGrade		0
#	define VS_K_plMatType		1
#	define VS_K_plNotes		2
#	define VS_K_plPartFam		3
#	define VS_K_plPartNum		4
#	define VS_K_plMtoSrc		5
#	define VS_K_plMtoStk		6
#	define VS_K_plMtoChgNum		7
#	define VS_K_plApprSts		8
#	define VS_K_plCnstSts		9
#	define VS_K_plFpThck		10
#	define VS_K_plMbrClass		11
#	define VS_K_plMbrType		12
#	define VS_K_plThickness		13
#	define VS_K_plCutOff		14
#	define VS_K_plOffset		15
#	define VS_K_plOrientation	16
#	define VS_K_plMAXDATA		17

/*
 * Plate attributes accessible to the user.
 */
#	define VS_K_plLengthAttr	"plate_length"
#	define VS_K_plWidthAttr		"plate_width"
#	define VS_K_plThcknsAttr	"plate_thk"

#endif

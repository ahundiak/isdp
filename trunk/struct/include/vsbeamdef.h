/* $Id: vsbeamdef.h,v 1.2 2001/03/01 17:49:15 ad Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/include/vsbeamdef.h
 *
 * Description:
 *
 * Dependencies: nmacro.h acrepdef.h
 *
 * Revision History:
 *      $Log: vsbeamdef.h,v $
 *      Revision 1.2  2001/03/01 17:49:15  ad
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/02/03  17:38:32  pinnacle
 * Replaced: include/vsbeamdef.h for:  by impd252 for struct
 *
 * Revision 1.2  2000/02/03  17:28:56  pinnacle
 * Replaced: include/vsbeamdef.h for:  by impd252 for struct
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/03/25  15:06:50  pinnacle
 * Tr179800336
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/25/98         Manoj           TR # 179800336 
 *					 Four beam attributes defined.
 *		02/03/00		adz				TR #179900970 -> Max coutout to 100.
 ***************************************************************************/

#ifndef vsbeamdef_include
#	define vsbeamdef_include

/*
 * Sub-representations of beams.
 */
#define VS_m_3dWFillet	( (AC_3D_REP) | (AC_SUB_REP) )
#define VS_m_2dSurface	( (AC_2D_REP) | (AC_SUB_REP) )

/*
 * Base name of active collection of user attributes for beams.
 *
#	define VS_K_beamUA		"beamUA"

/*
 * Name of graphic component for all beams.
 */
#	define VS_K_bmGrCmpName		"beam"

/*
 * Names of capping planes of beam and surface body in between.
 */
#	define VS_K_bmBeginCap		"beginCap"
#	define VS_K_bmEndCap		"endCap"
#	define VS_K_bmBody		"body"

/*
 * Name of root complex representing beam in linear (light) representation.
 */
#	define VS_K_bmLinearRepCPX	"Light Rep Of Beam"

/*
 * Name of feet of complex VS_K_bmLinearRepCPX.
 */
#	define	VS_K_bmLnRepProf	"xsec"
#	define	VS_K_bmLnRepArw1	"arrow_1"
#	define	VS_K_bmLnRepArw2	"arrow_2"
#	define	VS_K_bmLnRepAxis	"axis"

/*
 * Name of input graphics to a source beam.
 */
#	define VS_K_bmSuppSurf		"surface"
#	define VS_K_bmSuppAxis		"curve"

/*
 * Name of parent beam to be consumed for modified beams.
 */
#	define VS_K_mbParentBeam	"beam"

/*
 * Name of parent plate of a beam split by a plate.
 */
#	define VS_K_cbSplittingPlate	"plate"

/*
 * Name of parent points of a beam split by one or two points.
 */
#	define VS_K_dbSplittingPnt1	"splittingPoint1"
#	define VS_K_dbSplittingPnt2	"splittingPoint2"

/*
 * Name of graphic components of split manager beam.
 */
#	define VS_K_cbAxis0		"axis0"
#	define VS_K_cbAxis1		"axis1"

/*
 * Name of parent surface of extended-and-trimmed beam.
 */
#	define VS_K_xbTrimSurf		"trimSurf"

/*
 * Maximum count of cut-outs allowed on one beam.
 */
#	define VS_K_bbMAX_NOTCHES	100

/*
 * Fast-data retrieval codes.
 */
#	define VS_K_fdSectDef	0
#	define VS_K_fdFaceMap	1
#	define VS_K_fdBmMsPps	2

/*
 * Indices of beam data in private collection.
 */
#	define VS_K_bmMatGrade		0
#	define VS_K_bmMatType		1
#	define VS_K_bmNotes		2
#	define VS_K_bmPartFam		3
#	define VS_K_bmPartNum		4
#	define VS_K_bmMtoSrc		5
#	define VS_K_bmMtoStk		6
#	define VS_K_bmMtoChgNum		7
#	define VS_K_bmApprSts		8
#	define VS_K_bmCnstSts		9
#	define VS_K_bmFpThck		10
#	define VS_K_bmMbrClass		11
#	define VS_K_bmMbrType		12
#	define VS_K_bmCardPnt		13
#	define VS_K_bmSymmetry		14
#	define VS_K_bmXOffset		15
#	define VS_K_bmYOffset		16
#	define VS_K_bmRotAngle		17
#	define VS_K_bmMAXDATA		18

/*
 * Beam attributes accessible to the user.
 */
#	define VS_K_bmLengthAttr	"memb_cut_leng"
#	define VS_K_bmHeightAttr	"x_Height"
#	define VS_K_bmWidthAttr		"x_Width"
#	define VS_K_bmFlgThkAttr	"x_Flg_Thickness"
#	define VS_K_bmWebThkAttr	"x_Web_Thickness"
#	define VS_K_bmFltRadAttr	"x_Fillet_Radius"
#	define VS_K_bmOvrLen0Val	"__ValOfOverlength0"
#	define VS_K_bmOvrLen1Val	"__ValOfOverlength1"
#	define VS_K_bmOvrLen0Pos	"__PosOfOverlength0"
#	define VS_K_bmOvrLen1Pos	"__PosOfOverlength1"

/*
 * Keywords for ACgive_db_structure.
 */
#	define VS_K_bmEndTreatment0	"end_treatment0"
#	define VS_K_bmEndTreatment1	"end_treatment1"
#	define VS_K_bmEndTreatInfo0     "end_treatinfo0"
#	define VS_K_bmEndTreatInfo1     "end_treatinfo1"
#	define VS_K_bmEndTreatInfo1     "end_treatinfo1"
#	define VS_K_bmEndTreat0     	"end_treat0"
#	define VS_K_bmEndTreat1     	"end_treat1"
#	define VS_K_bmEndTreats     	"end_treats"

#	define VS_K_bmCmpsitAttr 	"composite"	/* Is beam composite ?*/

/*
 * Overlength attributes of beam 
 */

#define VS_K_OVRLENVAL0		"valofoverlength0"
#define VS_K_OVRLENVAL1		"valofoverlength1"
#define VS_K_OVRLENPOS0		"posofoverlength0"
#define VS_K_OVRLENPOS1		"posofoverlength1"

#endif


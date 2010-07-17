/* $Id: vswelddef.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vswelddef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vswelddef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/11/14  12:32:26  pinnacle
 * Replaced: include/vswelddef.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vswelddef.h
#	define vswelddef.h

/*
 * Weld types.
 */
#define VS_K_wldFillet		0  /* Fillet weld			*/
#define VS_K_wldPlugSlot	1  /* Plug or slot weld			*/
#define VS_K_wldSpotPrj		2  /* Spot or projection weld		*/
#define VS_K_wldSeam		3  /* Seam weld				*/
#define VS_K_wldGrvSqr		4  /* Groove weld ( square )		*/
#define VS_K_wldGrvV		5  /* Groove weld ( V )			*/
#define VS_K_wldGrvBvl		6  /* Groove weld ( bevel )		*/
#define VS_K_wldGrvU		7  /* Groove weld ( U )			*/
#define VS_K_wldGrvJ		8  /* Groove weld ( J )			*/
#define VS_K_wldGrvFlrV		9  /* Groove weld ( flare-V )		*/
#define VS_K_wldGrvFlrBvl	10 /* Groove weld ( flare-bevel )	*/
#define VS_K_wldBacking		11 /* Backing weld			*/
#define VS_K_wldSurfacing	12 /* Surfacing weld			*/
#define VS_K_wldFlgEdge		13 /* Flange weld ( edge )		*/
#define VS_K_wldFlgCorner	14 /* Flange weld ( corner )		*/
#define VS_K_MAX_WLD_TYPES	15 /* Update it if weld types added !	*/

/*
 * Welding processes.
 */
#define VS_K_wldUndefProc	0  /* Undefined process			*/
#define VS_K_wldCAW		1  /* Carbon-Arc welding		*/
#define VS_K_wldCW		2  /* Cold welding			*/
#define VS_K_wldDB		3  /* Dip Brazing			*/
#define VS_K_wldDFW		4  /* Diffusion Welding			*/
#define VS_K_wldEBW		5  /* Electron Beam Welding		*/
#define VS_K_wldEW		6  /* Electroslag Welding		*/
#define VS_K_wldEXW		7  /* Explosion Welding			*/
#define VS_K_wldFB		8  /* Furnace Brazing			*/
#define VS_K_wldFCAW		9  /* Flux Cored Arc Welding		*/
#define VS_K_wldFOW		10 /* Forge Welding			*/
#define VS_K_wldFRW		11 /* Friction Welding			*/
#define VS_K_wldFW		12 /* Flash Welding			*/
#define VS_K_wldGMAW		13 /* Gas Metal-Arc Welding		*/
#define VS_K_wldGTAW		14 /* Gas Tungsten-Arc Welding		*/
#define VS_K_wldIB		15 /* Induction Brazing			*/
#define VS_K_wldIRB		16 /* Infrared Brazing			*/
#define VS_K_wldIW		17 /* Induction Welding			*/
#define VS_K_wldLBW		18 /* Laser Beam Welding		*/
#define VS_K_wldOAW		19 /* Oxyacetylene Welding		*/
#define VS_K_wldOHFW		20 /* Oxyhydrogen Welding		*/
#define VS_K_wldPAW		21 /* Plasma-Arc Welding		*/
#define VS_K_wldPEW		22 /* Percussion Welding		*/
#define VS_K_wldPGW		23 /* Pressure Gas Welding		*/
#define VS_K_wldRB		24 /* Resistance Brazing		*/
#define VS_K_wldRPW		25 /* Projection Welding		*/
#define VS_K_wldRSEW		26 /* Resistance-Seam Welding		*/
#define VS_K_wldRSW		27 /* Resistance-Spot Welding		*/
#define VS_K_wldSAW		28 /* Submerged-Arc Welding		*/
#define VS_K_wldSMAW		29 /* Shielded Metal-Arc Welding	*/
#define VS_K_wldSW		30 /* Stud Welding			*/
#define VS_K_wldTB		31 /* Torch Brazing			*/
#define VS_K_wldTW		32 /* Thermal Welding			*/
#define VS_K_wldUSW		33 /* Ultrasonic Welding		*/
#define VS_K_wldUW		34 /* Upset Welding			*/
#define VS_K_MAX_WLD_PROCS	35 /* Update it if weld processes added */

/*
 * Weld info.
 */
#define VS_m_wldWeldAllAround		0x01
#define VS_m_wldFieldWeld		0x02
#define VS_m_wldMeltThru		0x04
#define VS_m_wldFlushContour		0x08
#define VS_m_wldConvexContour		0x10
#define VS_m_wldConcaveContour		0x20

/*
 * Weld sides can be either left, right or both sides
 * For plates left side is base surface side and right is offset surface side
 * For beams left side is web left side and right is web right surface side
 */
#define VS_K_wldArrowSide	0
#define VS_K_wldLeftSide	0
#define VS_K_wdlOtherSide	1
#define VS_K_wldRightSide	1
#define VS_K_wldBothSides	2

/*
 * Weld positions can be the following
 *      1. Floor        2. Horizontal   3. Ceiling      4. Vertical
 */
#define VS_K_wldFloorPos        0
#define VS_K_wdlHorzPos         1
#define VS_K_wldCeilPos         2
#define VS_K_wldVertPos         3

#endif	

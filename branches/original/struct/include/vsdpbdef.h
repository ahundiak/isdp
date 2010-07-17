/* $Id: vsdpbdef.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vsdpbdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsdpbdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.4  1997/12/19  14:37:22  pinnacle
 * WeldPos
 *
 * Revision 1.3  1997/12/04  08:23:18  pinnacle
 * Replaced: include/vsdpbdef.h for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  12:30:56  pinnacle
 * Replaced: include/vsdpbdef.h for:  by svkadamb for struct
 *
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *            suresh  modification 
 *  12/19/97  ah      Added VS_K_dpbActJnWeldPos
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vsdpbdef_include
#	define vsdpbdef_include

/*
 * Names of the members of the VDS representation collection for the beam and
 * plate sub-representations.
 */
#	define VS_K_Struct2dRep		"Struct2D"
#	define VS_K_FilletedBeamRep	"FilletedBeam"

#	define VS_K_dpbCollection	"dpbColl"
/*
 * Active Groove Angle for placement of a joint (double value).
 */
#	define VS_K_dpbActJnGrvAng	"JnGrvAng"
/*
 * Active Pitch for placement of a joint (double value).
 */
#	define VS_K_dpbActJnPitch	"JnPitch"
/*
 * Active Length Of Increment for placement of a joint (double value).
 */
#	define VS_K_dpbActJnIncrLn	"JnIncrLn"
/*
 * Active User Symbol for placement of a joint (character string value).
 */
#	define VS_K_dpbActJnUsrSym	"JnUsrSym"
/*
 * Active Mode automatic placement of joints in the "Split ..." commands
 * (double value interpreted as TRUE/FALSE).
 */
#	define VS_K_dpbActJnPlcMode	"JnPlcMode"
/*
 * Active Mode for placement of a stiffener (double value, TRUE: place stiffener
 * normal to side of plate / FALSE: use a surface of projection).
 */
#	define VS_K_dpbActStfnNrmlToSd	"StfnNrmlToSd"
/*
 * Active mode for gap detection between a stiffener placed using a surface of
 * projection (double value, TRUE: gap detection enabled / FALSE: gap detection
 * disabled).
 */
#	define VS_K_dpbActGapDetection	"GapDetection"
/*
 * Active value for the maximum admissible value for the gap in case of gap
 * detection (double value >= 0).
 */
#	define VS_K_dpbActMaxAdmGapVal	"MaxAdmGapVal"
/*
 * Active value for the shrinkage is 0.2
 */
#	define VS_K_dpbActJnShrkRatio "shrinkage"
#	define VS_K_dpbActJnWeldSize  "weldsize"
#	define VS_K_dpbActJnWeldPos   "position"

#endif

/* $Id: vsbmaxisdef.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */

/* $Id: vsbmaxisdef.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        include/vsbmaxisdef.h
 *
 * Description:
 *
 * Dependencies: nmacro.h
 *
 * Revision History:
 *      $Log: vsbmaxisdef.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1998/02/20  20:05:32  pinnacle
 * CR179800676
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/20/98  ah      CR179800676 - Allow axis to extend past edge of plate
 * 02/20/98  ah      CR179800677 - Option to force paramertization to follow
 *                                 parent support curve vice surface
 ***************************************************************************/

#ifndef vsbmaxisdef_include
#define vsbmaxisdef_include

/*
 * Name of input graphics to one a beam axis.
 */
#	define VS_K_baPlateSupp 	"Plate"
#	define VS_K_baSurfOrLine	"SurfaceOrLine"
#	define VS_K_baStartSurf 	"StartSurface"
#	define VS_K_baEndSurf		"EndSurface"

/*
 * Name of output graphic.
 */
#	define VS_K_baBmAxis		"BeamAxis"

/*
 * Constants defining on which side of plate beam axis was build originally and
 * to which it must stick, even if orientation of plate is reversed.
 */
#	define VS_K_baOnBotOfPlate	0
#	define VS_K_baOnTopOfPlate	1

/*
 * Constants defining which construction is used to construct the beam axis.
 */
#	define VS_K_baProjection	0	/* Beam axis result from a    */
						/* projection of a curve to   */
						/* the side of plate.	      */
#	define VS_K_baIntersection	1	/* Beam axis result from an   */
						/* intersection between a     */
						/* surface and side of plate. */
						
/*
 * Constant defining if axis should be extend such that the axis will go 
 * through the surfaces limits.
 *
 * Don't they teach hex anymore?
 * 
 * Something like this was being used to check for top of plate
 * if( (me->flagAttr & ~VS_K_baExtendAxis) == VS_K_baOnTopOfPlate )
 *
 * I guess it works but it makes adding more flags difficult
 * I added a method just to check for top of plate
 *
 * I decided to rename this constant (added AH)  just to make sure I caught all of the
 * above cases and converted them to this method
 * 
 */
#define VS_K_baExtendAxisAH		10

/* CR179800676
 * Should axis end be extended to meet surface limits
 */
#define VS_K_baExtend0 0x10
#define VS_K_baExtend1 0x20

/* CR179800677
 * Indicates if we should parameterize by the base surface
 * or by the support curve
 */
#define VS_K_baByCurve 0x40

/* No specific cr, just thought it might be useful 
 * Always carry a spare
 */
#define VS_K_baSpare 0x80

#endif







/*********************************************************************

Author	:	B Demars

Creation:	December 20th, 1990


		This file contains the definition of all
		VRconstants.
		
	
Change History :


		  date	|  name	|	modification's description
		--------+-------+-----------------------------------
		06/27/94 Manyam	 Added VRVALORTHOVEC parameter
		02/02/01 LAW	 TR4578-add alignment tolerance
		10/25/01 Anand	 Constants for VRtolerance.I

*********************************************************************/

#ifndef	vr_math_include
#define vr_math_include


/* USE OF BELOW CONSTANTS WILL BE DEPRECATED */
#define VR_ALIGN_TOL    (1.e-2)  /* test value for alignment tolerance */
#define VR_EPSILON	(1.e-10)

/*C
   a tolerance against which to test the absolute value of a dot products of
   two vectors to see if if they are orthogonal -- (dot_tol)

   Note : tolerance has been extended for I/ROUTE purpose
*/

#define	VRVALORTHOVEC		( 20 * BSVALORTHOVEC )
/* USE OF ABOVE CONSTANTS WILL BE DEPRECATED */

/* Test value for bVRTestVect function */

#define VR_SAME		0
#define VR_OPPOSITE	1
#define VR_COLINEAR	2

/* Added below values for tolerance. Call VRGetBaseTol with one of below values
 * as argument. */
#define VR_DEFAULT_TOL	0
#define VR_LENGTH_TOL	1
#define VR_DIST_TOL	2
#define VR_SQRLEN_TOL	3
#define VR_ANGULAR_TOL	4
#define VR_BENDRAD_TOL	5
#define VR_SKETCH_TOL	6
#define VR_DOTPROD_TOL	7
#define VR_ORTHO_TOL	8
#define VR_DELTA_TOL	9

#ifndef DONT_EXTERN_TOL_FUNC
extern	double	VRGetTol(int);
extern	void	VRSetRouteTol(double);
#endif

#endif

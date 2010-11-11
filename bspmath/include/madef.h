/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef madef_include
#define madef_include

#ifndef maerr_include
#include "maerr.h"
#endif

#define   PI  3.14159265358979323846

#define MAabsolute(x)  (((x) < 0)? -(x):(x))
#define MAmaximum(x,y) (((x) < (y))? (y):(x))
#define MAminimum(x,y) (((x) < (y))? (x):(y))

#define MAIDMX 2		/* Matrix type number for identity	*/

#define MAELPOLE_SIZE 7		/* number of poles in standard ellipse	*/
#define MAELKNOT_SIZE 10	/* number of knots in standard ellipse	*/
#define MABCSTRUCTSIZE 12	/* number of fields in MAbsp_curve	*/

/*
 *
 *  The following macros define the amount of storage necessary for 
 *  B-spline stroking function control structures.  The numbers returned
 *  indicate the number of IGRdouble locations required.
 *
 */

#define MAbezsize(msgptr,order,size) 			\
		 TRUE; *(msgptr) = MSSUCC; *(size) = 	\
		 5 + 4 * *(order)
#define MAactivesize(msgptr,order,size) 		\
		 TRUE; *(msgptr) = MSSUCC; *(size) = 	\
		 8 + MABCSTRUCTSIZE + 6 * *(order)
#define MAbcsize(msgptr,order,size) 			\
		 TRUE; *(msgptr) = MSSUCC; *(size) = 	\
		 5 + MABCSTRUCTSIZE + 6 * *(order) +	\
		 5 + 4 * *(order) + 			\
		 8 + MABCSTRUCTSIZE + 6 * *(order)
#define MAbbsize(msgptr,size) 				\
		 TRUE; *(msgptr) = MSSUCC; *(size) = 3

/*----
%DD%  DATA TYPE DECLARATIONS
----*/

/*
 *  Standard arc structure.
 */
#define MAarc IGRarc
#define MAbsp_curve IGRbsp_curve
#define MAbsp_surface IGRbsp_surface
#define MAcs_curve IGRcs_curve
#define MAcone IGRcone
#define MAellipse IGRellipse
#define MAline IGRline
#define MAline_seg IGRline_seg
#define MAplane IGRplane
#define MApolyline IGRpolyline
#define MApolygon IGRpolygon
#define MApointset IGRpointset

#endif /* madef_include */

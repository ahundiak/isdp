/*
 *	Copyright (c) 1988,1989,1990, Intergraph Corporation.
 *	All Rights Reserved.
 *
 *	THIS IS UNPUBLISHED, PROPRIETARY,  AND  CONFIDENTIAL SOURCE
 *	SOFTWARE  OF  INTERGRAPH.  Use, duplication, and disclosure
 *	is prohibited, except under the terms and conditions of the
 *	applicable software license agreement.
 */

#ident  "$Id: float.h,v 1.1.1.1 2001/12/17 22:40:14 hans Exp $ Copyright (c) 1986,1987,1988,1989,1990 by Intergraph Corp."

#ifndef _FLOAT_H
#define _FLOAT_H

/*
 * ANSI-C standard section 2.2.4.2
 */

/* 
 * Radix of exponent representation
 */
#define FLT_RADIX	2

/*
 * rounding mode for floating point addition:
 * 	 0: towards zero 
 *	 1: to nearest
 *	 2: toward +infinity
 * 	 3: toward -infinity
 *	-1: indeterminable
 */
#define FLT_ROUNDS	1	

#define FLT_MANT_DIG 	24
#define DBL_MANT_DIG    53
#define LDBL_MANT_DIG   53

#define FLT_DIG		 6
#define DBL_DIG		15
#define LDBL_DIG        15

#define FLT_MIN_EXP	 -125
#define DBL_MIN_EXP     -1021
#define LDBL_MIN_EXP    -1021

#define FLT_MIN_10_EXP   -37
#define DBL_MIN_10_EXP  -307
#define LDBL_MIN_10_EXP -307

#define FLT_MAX_EXP      128
#define DBL_MAX_EXP     1024
#define LDBL_MAX_EXP    1024

#define FLT_MAX_10_EXP   38
#define DBL_MAX_10_EXP  308
#define LDBL_MAX_10_EXP 308

#define FLT_MAX		3.4028234663852885e+38
#define DBL_MAX		1.7976931348623158e+308
#define LDBL_MAX        1.7976931348623158e+308

#define FLT_EPSILON	1.1920928955078125e-07
#define DBL_EPSILON     2.220446049250313e-16
#define LDBL_EPSILON    2.220446049250313e-16

#define FLT_MIN		1.1754943508222875e-38
#define DBL_MIN		2.2250738585072013e-308
#define LDBL_MIN        2.2250738585072013e-308

#endif  /* _FLOAT_H */

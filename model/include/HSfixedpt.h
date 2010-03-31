
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HSfixedpt_include
#define HSfixedpt_include 1

#define FIXED_POINT_SCALE	0x10000		/* 2^16 */
#define FIXED_POINT_ONE_HALF	0x8000		/* 2^15 */
#define FIXED_POINT_1_30_SCALE	0x40000000	/* 2^30 */

#define ROUND_16_16(x)		(((x) + FIXED_POINT_ONE_HALF) >> 16)
#define TRUNC_16_16(x)		((x) >> 16)
#define SHIFT_16_16(x)		((x) << 16)
#define REM_16_16(x)		((x) & 0x0000ffff)

typedef unsigned int FIXED_POINT_32;

#endif

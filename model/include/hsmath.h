
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsmath_include
#define hsmath_include 1

/*
 * hsmath.h contains all math macros and definitions needed by HSURF.
 */

#define MATRIX_MULT(a, b, c)	{						\
				int	i, j, k;				\
										\
				for( i=0; i<4; i++ ) for( j=0; j<4; j++ )	\
					{					\
					c[i][j] = 0.0;				\
										\
					for( k=0; k<4; k++ )			\
						c[i][j] += (a[i][k] * b[k][j]);	\
					}					\
				}

#define	CSHIFT(x)	(((x) < 0) | ((x) << 1))
#define MAX(x, y)	(((x) > (y)) ? (x) : (y))
#define	ROUND(x)	(((x) > 0) ? ((x) + 0.5) : ((x) - 0.5))
#define ROUND16(x)	(((x) + 32768) >> 16)
#define ABS(x)		(((x) > 0) ? (x) : (-(x)))
#define FABS(x)		(((x) > 0.0) ? (x) : (-(x)))

#define ACOS(x)		acos(x)
#define SIN(x)		sin(x)
#define SQRT(x)		sqrt(x)

#endif

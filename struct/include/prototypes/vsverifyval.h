/*
	I/STRUCT
*/

#ifndef vsverifyval_include
#	define vsverifyval_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

extern int
VSisDblPositive			__((	double	d,
					char	*args )) ;

extern int
VSisDblGreaterThan		__((	double	d,
					char	*toBeGreaterThan )) ;

#endif

/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef bsvalues_hp_include
#define bsvalues_hp_include

#ifndef MAXDOUBLE
#define MAXDOUBLE	1.7976931348623157e+308
#endif

#ifndef MAXFLOAT
#define MAXFLOAT	((float)3.40282346638528860e+38)
#endif

#ifdef __hp9000s800

#  ifndef MINDOUBLE
#  define	MINDOUBLE	(double)4.94065645841246544e-324
#  endif

#  ifndef MINFLOAT
#  define MINFLOAT        ((float)1.40129846432481707e-45)
#  endif

#else

#  ifndef MINDOUBLE
#  define MINDOUBLE       2.2250738585072014e-308
#  endif

#  ifndef MINFLOAT
#  define MINFLOAT        ((float)1.1754943508222875e-38)
#  endif

#endif  /* __hp9000s800 */

#endif /* bsvalues_hp_include */

/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsvalues_include
# define bsvalues_include

#define MAXINTEGER 2000000000

# ifdef VMS
#   ifndef bsvalues_vx_include
#     include "bsvalues_vx.h"
#   endif
#   define BSSMALLRELTO1  1.3877787807814457e-17
# endif

# ifdef CLIX
#   ifndef bsvalues_cl_include
#     include "bsvalues_cl.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# ifdef SUNOS
#   ifndef bsvalues_sn_include
#     include "bsvalues_sn.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# if defined(SUNOS5) || defined(LINUX)
#   ifndef bsvalues_sn_include
#     include "bsvalues_sn.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# ifdef IRIX
#   ifndef bsvalues_sg_include
#     include "bsvalues_sg.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# ifdef BOSX
#   ifndef bsvalues_ib_include
#     include "bsvalues_ib.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# ifdef HPUX
#   ifndef bsvalues_hp_include
#     include "bsvalues_hp.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

# ifdef NT
#   ifndef bsvalues_nt_include
#     include "bsvalues_nt.h"
#   endif
#   define BSSMALLRELTO1  2.2204460492503130e-16
# endif

#define MINDOUBLE_TEMP (MINDOUBLE / BSSMALLRELTO1)
#define MINFLOAT_TEMP (MINFLOAT / BSSMALLRELTO1)

#ifndef M_LN2
#define M_LN2   0.69314718055994530942
#endif

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#ifndef M_SQRT2
#define M_SQRT2 1.41421356237309504880
#endif

#ifndef M_SQRT1_2
#define M_SQRT1_2 0.70710678118654752440
#endif

#define M_NaN 0xffffffff

# endif /* bsvalues_include */

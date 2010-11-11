/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsiboolcvlp_include
# define bsiboolcvlp_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

typedef IGRint   BSinpair[2];
#define NUM_ELE 50

struct BSint_over
 {
   IGRpoint        pt;
   IGRdouble       par[2];
   IGRint          ind[2];
   IGRint          code;
 };

struct BSloop
 {
    IGRint      num;                     
    BSinpair    *lpind;
    BSpair      *par;

 };

# endif /* bsiboolcvlp_include */

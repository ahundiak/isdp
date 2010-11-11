/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bstypes_include
# define bstypes_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGRdouble IGRpoint */
# endif

# ifndef igr_include
#   include "igr.h" /* IGR structs */
# endif

# define BSPOINTSIZE (sizeof(IGRpoint)/sizeof(IGRdouble))

# define  MAX_ORDER  16       /* maximum order allowed        */

typedef IGRdouble BSpoly[MAX_ORDER][4];   /* to hold four-field        */
                        /* polynomial coefficients   */

typedef IGRdouble  BSmatrix[9];
typedef IGRdouble  BSmat[3][3];
typedef IGRdouble  BSmat2[2][3][3];

typedef long BSrc;              /* the type for return codes */

typedef char *BSaddr;
typedef IGRdouble BSpair[2];

/* new typedefs for BSsetigmem 10/18/96 */
/* PPL ci cannot handle these 01/08/97 */

#ifndef PPL
typedef void *(*new_fn_type)(long);
typedef void (*delete_fn_type)(void *, long);
#endif

# endif /* bstypes_include */

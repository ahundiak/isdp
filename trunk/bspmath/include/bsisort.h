/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsisort_include
# define bsisort_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGRint IGRdouble */
# endif

# ifndef bsicvcvint_include
#   include "bsicvcvint.h"
# endif

struct BSblock_point
{
    IGRint point_id;
    struct BScvcv_int_block_of_points *block_ptr;
};

union BSsort_element
{
    IGRdouble *d_ptr;
    struct BSblock_point block_point;
    struct BSblock_point block_overlap[2];
};

# endif /* bsisort_include */

/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsicvcvint_include
# define bsicvcvint_include

# ifndef bsdefs_include
#   include "bsdefs.h"
# endif

# ifndef bsstackalloc_include
#   include "bsstackalloc.h"
# endif

# define BSCCI_MAXPOINTS_PER_BSspnspnint     (MAX_ORDER * MAX_ORDER)
# define BSCCI_BLOCK_DIMENSION          (5 * BSCCI_MAXPOINTS_PER_BSspnspnint)

# define BSCCI_BLOCK_THRESHOLD    \
        (BSCCI_BLOCK_DIMENSION - BSCCI_MAXPOINTS_PER_BSspnspnint)

# define BSCCI_INTERSECTION   1
# define BSCCI_END            2
# define BSCCI_GARBAGE        3

# define BSCCI_BAD_INDEX -999

# define BSCCI_BORDER 20

struct BScvcv_int_block_of_points
{
    IGRint used;
    IGRint num_ints, num_ends;
    IGRpoint points[BSCCI_BLOCK_DIMENSION];
    IGRdouble parameters[2][BSCCI_BLOCK_DIMENSION];
    char kind[BSCCI_BLOCK_DIMENSION];
    struct BScvcv_int_block_of_points *next;
};

# define BSCCI_ALLOCATE_NEW_BLOCK(old_block)    \
{                                               \
    struct BScvcv_int_block_of_points *temp_block;  \
                                                    \
    temp_block = (struct BScvcv_int_block_of_points *)BSstackalloc    \
    ((unsigned)sizeof (struct BScvcv_int_block_of_points));             \
    if (NOT temp_block)         \
    {                           \
        *rc = BSNOSTKMEMORY;    \
    }                           \
    else                        \
    {                           \
        temp_block->used = 0;       \
        temp_block->num_ints = 0;   \
        temp_block->num_ends = 0;       \
        temp_block->next = old_block;   \
        old_block = temp_block;         \
    }                                   \
}

struct BSbezier_curve_space
{
    IGRvector unormal;
    IGRpoint poles[MAX_ORDER], unweighted_poles_array[MAX_ORDER];
    IGRdouble weights[MAX_ORDER];
    IGRdouble knots[MAX_ORDER+MAX_ORDER];
    struct BSmin_max_box minmax;
    IGRboolean planarity_tested;
    IGRdouble *unweighted_poles;
    struct IGRbsp_curve curve;
};

struct BSbezier_curve_space2
{
    IGRvector normal;
    IGRpoint poles[MAX_ORDER];
    IGRdouble weights[MAX_ORDER];
    IGRdouble knots[MAX_ORDER+MAX_ORDER];
    struct BSmin_max_box minmax;
    IGRint code;
    struct IGRbsp_curve curve;
};

struct BSbezier_info
{
    IGRpoint poles[MAX_ORDER];
    IGRdouble weights[MAX_ORDER];
    IGRdouble knots[MAX_ORDER+MAX_ORDER];
    IGRpoint  minmax[2];
    IGRint code;
    struct IGRbsp_curve curve;
};

struct BStree_ptrc
 {
    IGRboolean  over;
    IGRint      n_next;
    IGRpoint    rng[2];
    IGRint      next[2];
 };


# endif /* bsicvcvint_include */

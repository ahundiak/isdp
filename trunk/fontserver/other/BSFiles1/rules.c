




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************************************************************

    This module contains the logic for handling bitmap refinement rules.

 ***************************************************************************/


/****************************** R U L E S . C ******************************
 ********************* R E V I S I O N   H I S T O R Y *********************

 1)  12-Nov-86  jsc   Installed automatic cache clearing mechanism to clear the
                      cache and retry pixel allocation in case of cache overflow

 2)  14-Nov-86  jsc   Eliminated swap_ufix16() and swap_double() in favor of
                      in-line code in make_edge_list().

                      Eliminated unpack_prop_flag(), unpack_level_flag(),
                      unpack_cont_flag(), unpack_fn_flag() and unpack_min() in
                      favor of masks defined in mkbm.h to extract packed fields.

 3)  27-Nov-86  jsc   get_pixels() corrected to ensure correct interdimensional
                      scaling for P and T items.

 4)  30-Dec-86  jsc   Added nominal scale factors for x and y to arg list
                      of setup_trans().

                      Nominal x scale used for pixel allocation and cache selection

 5)  22-Mar-87  jsc   make_y_trans_list() updated to correct definition of
                      vertical position referenced to top of emsquare.

 6)   7-Apr-87  mby   fixed bugs in 'make_x_trans_table': 1) compound X trans
                      table should never be overwritten. 2) store real #s in
                      comp_x_pixel_tbl (which must be declared float).

 7)   8-Apr-87  mby   In get_pixels() change root zone rounding from .495 to .499

 8)   7-May-87  mby   In make_path_mask(), fix bug that occurs when 3 or more
                      zones are on the same level (change 'if' to 'while')

 8)  13-May-87  mby   Fix error in transformation functions when      
                      pointsize_x != pointsize_y

 ****************************************************************************/


#include "../hfiles/stdef.h"      /* Bitstream standard macros & definitions  */
#include "../hfiles/comp2_3.h"    /* data structures for compressed font */
#include "../hfiles/mkbm.h"               /* General definition for make_bmap */
#include "../hfiles/math.h"


/* this should be defined as a compilation argument */
/* #define  RULESDBG */         /* prints x & y transformation tables for debugging */


/***** STATIC VARIABLES *****/

static  cft_outl_str *cfontp;     /* pointer to compr font structure */
static  float   angle_rot;        /* rotation angle in degrees (clockwise)   */
static  float   angle_obl;        /* obliquing angle in degrees (clockwise)  */
static  float   outlres;          /* font outline resl/em in outline units */
static  ufix16 *pfirst_rec;       /* ptr to first outline data record in font */
static  float   pixperoru_h;      /* horizontal pixels per outline resolution unit */
static  float   pixperoru_v;      /* vertical pixels per outline resolution unit */
static  float   pixperoru_x;      /* x pixels per outline resolution unit */
static  float   pointsize_x;      /* x point size */
static  float   pointsize_y;      /* y point size */
static  float   x_distortion;     /* = pointsize_x / pointsize_y */
static  float   pix_inch_hor;     /* horizontal pixels per inch */
static  float   pix_inch_ver;     /* vertical pixels per inch */
static  float   sinrot, cosrot;   /* sine, cosine of rotation angle */
static  float   tanobl;           /* tangent of obliquing angle */
static  boolean cache_overflow;   /* Cache overflow flag */
static  boolean x_zone_data_valid; /* true if x zone data valid */
static  boolean y_zone_data_valid; /* true if y zone data valid */
static  float   x_pixels_per_em;  /* Number of pixels per em in char x dimension */
static  float   y_pixels_per_em;  /* Number of pixels per em in char y dimension */
static  ufix16  root_char_no;     /* Root character number */
static  ufix16  char_no;          /* Current character or sub-character number */
static  float   x_scale_nom, y_scale_nom; /* x and y nominal scale factors */
static  float   x_scale, y_scale; /* x and y scale factors */
static  float   x_pos, y_pos;     /* x and y offsets */
static  double  edges[MAX_ZONES_PER_DIM];
static  fix15   pixels[MAX_ZONES_PER_DIM];
static  boolean print_trans_data; /* Switch for printing generated trans data */
static  bool16  sw_fixed;         /* True if set width constrained */
static  float   xht_adj;          /* x-height adj factor (always 1.0) */


/* Storage for transformation data  for current character */
static fix15  no_xx_transforms;   /* No transforms for computing x from x */
static fix15  no_xy_transforms;   /* No transforms for computing x from y */
static double x_orus[MAX_ZONES_PER_DIM];        /* Original x coord list */
static fix15  x_pixels[MAX_ZONES_PER_DIM];      /* Transformed x coord list */
static double x_mult_tbl[MAX_ZONES_PER_DIM];    /* Transformation multiplier */
static double x_offset_tbl[MAX_ZONES_PER_DIM];  /* Transformation offset */
static double xx_mult;            /* coeff of x for computing x from x and y */
static double xy_mult;            /* coeff of y for computing x from x and y */
static double x_offset;           /* constant for computing x from x and y   */

static fix15  no_yx_transforms;   /* No transforms for computing y from x */
static fix15  no_yy_transforms;   /* No transforms for computing y from y */
static double y_orus[MAX_ZONES_PER_DIM];        /* Original x coord list */
static fix15  y_pixels[MAX_ZONES_PER_DIM];      /* Transformed x coord list */
static double y_mult_tbl[MAX_ZONES_PER_DIM];    /* Transformation multiplier */
static double y_offset_tbl[MAX_ZONES_PER_DIM];  /* Transformation offset */
static double yx_mult;            /* coeff of x for computing y from x and y */
static double yy_mult;            /* coeff of x for computing y from x and y */
static double y_offset;           /* constant for computing y from x and y   */

/* Compound character transformation data */
static fix15  no_comp_x_edges;
static float  comp_x_edge_tbl[MAX_ZONES_PER_COMP_DIM];
static float  comp_x_pixel_tbl[MAX_ZONES_PER_COMP_DIM];



FUNCTION void init_trans(cfont, char_nr,
                    psize_x, psize_y, res_hor, res_ver, rot_angle, obl_angle)
  cft_outl_str  *cfont;        /* ptr to compressed font structure          */
  fix31    char_nr;            /* Root character number offset     */
  float    psize_x;            /* x pointsize                               */
  float    psize_y;            /* y pointsize                               */
  float    res_hor;            /* horizontal pixels per inch                */
  float    res_ver;            /* vertical pixels per inch                  */
  float    rot_angle;          /* rotation angle in degrees (clockwise)     */
  float    obl_angle;          /* obliquing angle in degrees (clockwise)    */
/* Called before start of reading root character                            */
/* Initializes transformation data for current character.                   */
/* Clears cache if any parameter has changed to invalidate cached data      */
{
float x, y;
void     reinit_cache();                            /* Inits cache if pixel/em changes  */


/*****************************/

#ifdef RULESDBG
print_trans_data = TRUE;                /* debugging switch */
#endif

/****************************/

cfontp = cfont;
root_char_no = char_nr;
outlres = (float) cfont->fonthead.resl_per_em;
pointsize_x = psize_x;
pointsize_y = psize_y;
x_distortion = pointsize_x / pointsize_y;
pix_inch_hor = res_hor;
pix_inch_ver = res_ver;
angle_rot = rot_angle;
angle_obl = obl_angle;
pixperoru_h = pointsize_y * pix_inch_hor / (PTPERINCH * outlres);   /* this is NOT a bug */
pixperoru_v = pointsize_y * pix_inch_ver / (PTPERINCH * outlres);
sinrot = sin(angle_rot * PI / 180.);
cosrot = cos(angle_rot * PI / 180.);
tanobl = tan(angle_obl * PI / 180.);
x = pix_inch_hor * cosrot;
y = pix_inch_ver * sinrot;
pixperoru_x = (pointsize_x / (PTPERINCH * outlres)) * sqrt(x * x + y * y);
no_comp_x_edges = 0;

reinit_cache (psize_x, psize_y, res_hor, res_ver, rot_angle, obl_angle);
}


FUNCTION void setup_trans(no_char, scale_x_nom, scale_y_nom,
    scale_x, scale_y, pos_x, pos_y, compc)
ufix16 no_char;
float scale_x_nom;
float scale_y_nom;
float scale_x;
float scale_y;
float pos_x;
float pos_y;
comp_char_desc  *compc;         /* scan conversion parameters */
/* Called by char_scan_convert() at the start of the first curve in the       */
/* outline data for the root character and all sub_characters.                */
/* Sets up transformation data for specified scale factors and offsets in     */
/* both x and y using current values of point size in x and y, horizontal     */
/* and vertical resolution, rotation angle and obliquing angle.               */
{
fix15   direction;

close_put_cache_data();        /* Terminate reading zone data */

char_no = no_char;
x_scale_nom = scale_x_nom;
y_scale_nom = scale_y_nom;
x_scale = scale_x;
y_scale = scale_y;
x_pos = pos_x;
y_pos = pos_y;
xht_adj = compc->xht_adj;
sw_fixed = compc->sw_fixed;

#ifdef RULESDBG
if (print_trans_data)
    printf("\nTransformation data for char %d\n", char_no);
#endif

if (compc->bogus_mode)                 /* Ignore plaid data? */
    {
    x_zone_data_valid = FALSE;
    setup_xxy_trans();

    y_zone_data_valid = FALSE;
    setup_yxy_trans();
    }

else if (angle_rot == 0.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_hor / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_ver / PTPERINCH;

    y_zone_data_valid = TRUE;
    if (angle_obl == 0.0)
        {
        x_zone_data_valid = TRUE;
        direction = 1;
        setup_xx_trans(direction);
        }
    else
        {
        x_zone_data_valid = FALSE;
        setup_xxy_trans();
        }

    direction = 1;
    setup_yy_trans(direction);
    }

else if ((angle_rot + angle_obl) == 0.0  ||  (angle_rot + angle_obl) == 360.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_hor / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_ver / PTPERINCH;

    x_zone_data_valid = TRUE;
    direction = 1;
    setup_xx_trans(direction);

    y_zone_data_valid = FALSE;
    setup_yxy_trans();
    }

else if (angle_rot == 90.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_ver / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_hor / PTPERINCH;

    y_zone_data_valid = TRUE;
    direction = 1;
    setup_xy_trans(direction);

    if (angle_obl == 0.0)
        {
        x_zone_data_valid = TRUE;
        direction = -1;
        setup_yx_trans(direction);
        }
    else
        {
        x_zone_data_valid = FALSE;
        setup_yxy_trans();
        }
    }

else if ((angle_rot + angle_obl) == 90.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_ver / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_hor / PTPERINCH;

    y_zone_data_valid = FALSE;
    setup_xxy_trans();

    x_zone_data_valid = TRUE;
    direction = -1;
    setup_yx_trans(direction);
    }

else if (angle_rot == 180.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_hor / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_ver / PTPERINCH;

    y_zone_data_valid = TRUE;
    if (angle_obl == 0.0)
        {
        x_zone_data_valid = TRUE;
        direction = -1;
        setup_xx_trans(direction);
        }
    else
        {
        x_zone_data_valid = FALSE;
        setup_xxy_trans();
        }

    direction = -1;
    setup_yy_trans(direction);
    }

else if ((angle_rot + angle_obl) == 180.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_hor / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_ver / PTPERINCH;

    x_zone_data_valid = TRUE;
    direction = -1;
    setup_xx_trans(direction);

    y_zone_data_valid = FALSE;
    setup_yxy_trans();
    }

else if (angle_rot == 270.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_ver / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_hor / PTPERINCH;

    y_zone_data_valid = TRUE;
    direction = -1;
    setup_xy_trans(direction);

    if (angle_obl == 0.0)
        {
        x_zone_data_valid = TRUE;
        direction = 1;
        setup_yx_trans(direction);
        }
    else
        {
        x_zone_data_valid = FALSE;
        setup_yxy_trans();
        }
    }

else if ((angle_rot + angle_obl) == 270.0)
    {
    x_pixels_per_em = pointsize_x * pix_inch_ver / PTPERINCH;
    y_pixels_per_em = pointsize_y * pix_inch_hor / PTPERINCH;

    y_zone_data_valid = FALSE;
    setup_xxy_trans();

    x_zone_data_valid = TRUE;
    direction = 1;
    setup_yx_trans(direction);
    }

else
    {
    x_zone_data_valid = FALSE;
    setup_xxy_trans();

    y_zone_data_valid = FALSE;
    setup_yxy_trans();
    }

}


FUNCTION static setup_xx_trans(direction)
fix15  direction;
/* Called by setup_trans() to set up zoned transformation for x as a
   function of x only.
   Direction may be positive (+1) or negative (-1).                         */
{
double min, max;
fix15   n;
boolean alloc_pixels();
float do_comp_x_trans();

if (!alloc_pixels(char_no, X_DIMENSION))
    {
    if (!alloc_pixels(char_no, X_DIMENSION))
        {
        printf("Cache too small for X dimension\n");
        setup_xxy_trans();
        return;
        }
    }
make_edge_list(char_no, X_DIMENSION, x_scale_nom, &n);
make_x_trans_list (n, direction, x_orus, x_pixels);
make_trans_table (x_pixels_per_em, x_scale, x_pos, direction, x_orus, x_pixels,  n,
    x_mult_tbl, x_offset_tbl, &no_xx_transforms);
no_xy_transforms = -1;

#ifdef RULESDBG
print_x_trans_data();
#endif
}


FUNCTION static setup_xy_trans(direction)
fix15  direction;
/* Called by setup_trans() to set up zoned transformation for x as a
   function of y only.
   Direction may be positive (+1) or negative (-1).                         */
{
fix15   n;
boolean alloc_pixels();

if (!alloc_pixels(char_no, Y_DIMENSION))
    {
    if (!alloc_pixels(char_no, Y_DIMENSION))
        {
        printf("Cache too small for Y dimension\n");
        setup_xxy_trans();
        return;
        }
    }
make_edge_list(char_no, Y_DIMENSION, y_scale, &n);
make_y_trans_list (n, direction, x_orus, x_pixels);
make_trans_table (y_pixels_per_em, y_scale, y_pos, direction, x_orus, x_pixels,  n,
    x_mult_tbl, x_offset_tbl, &no_xy_transforms);
no_xx_transforms = -1;

#ifdef RULESDBG
print_x_trans_data();
#endif
}


FUNCTION static setup_xxy_trans()
/* Called by setup_trans() to set up general transformation for x as a
   function of both x and y.                                                 */
{
xx_mult = cosrot * x_distortion * x_scale * pixperoru_h;
xy_mult = (sinrot + cosrot * tanobl) * y_scale * pixperoru_h;
x_offset = (x_pos * cosrot + y_pos * (sinrot + cosrot * tanobl)) * pixperoru_h;
no_xx_transforms = -1;
no_xy_transforms = -1;

#ifdef RULESDBG
print_x_trans_data();
#endif
}


FUNCTION static setup_yx_trans(direction)
fix15  direction;
/* Called by setup_trans() to set up zoned transformation for y as a
   function of x only.
   Direction may be positive (+1) or negative (-1).                         */
{
fix15   n;
boolean alloc_pixels();

if (!alloc_pixels(char_no, X_DIMENSION))
    {
    if (!alloc_pixels(char_no, X_DIMENSION))
        {
        printf("Cache too small for X dimension\n");
        setup_yxy_trans();
        return;
        }
    }
make_edge_list(char_no, X_DIMENSION, x_scale_nom, &n);
make_x_trans_list (n, direction, y_orus, y_pixels);
make_trans_table (x_pixels_per_em, x_scale, x_pos, direction, y_orus, y_pixels, n,
    y_mult_tbl, y_offset_tbl, &no_yx_transforms);
no_yy_transforms = -1;

#ifdef RULESDBG
print_y_trans_data();
#endif
}


FUNCTION static setup_yy_trans(direction)
fix15  direction;
/* Called by setup_trans() to set up zoned transformation for y as a
   function of y only.
   Direction may be positive (+1) or negative (-1).                         */
{
double min, max;
fix15   n;
boolean alloc_pixels();

if (!alloc_pixels(char_no, Y_DIMENSION))
    {
    if (!alloc_pixels(char_no, Y_DIMENSION))
        {
        printf("Cache too small for Y dimension\n");
        setup_yxy_trans();
        return;
        }
    }
make_edge_list(char_no, Y_DIMENSION, y_scale, &n);
make_y_trans_list (n, direction, y_orus, y_pixels);
make_trans_table (y_pixels_per_em, y_scale, y_pos, direction, y_orus, y_pixels, n,
    y_mult_tbl, y_offset_tbl, &no_yy_transforms);
no_yx_transforms = -1;

#ifdef RULESDBG
print_y_trans_data();
#endif
}


FUNCTION static setup_yxy_trans()
/* Called by setup_trans() to set up general transformation for y as a
   function of both x and y.                                                 */
{
yx_mult = -sinrot * x_distortion * x_scale * pixperoru_v;
yy_mult = (cosrot - sinrot * tanobl) * y_scale * pixperoru_v;
y_offset = (y_pos * (cosrot - sinrot * tanobl) - x_pos * sinrot) * pixperoru_v;
no_yx_transforms = -1;
no_yy_transforms = -1;

#ifdef RULESDBG
print_y_trans_data();
#endif
}


FUNCTION static boolean alloc_pixels(char_num, dimension)
ufix16    char_num;     /* Character number */
fix15  dimension;   /* Dimension */
/* Called by setup_..._trans to compute and cache the pixel allocations for
   all zones in the specified dimension of the specified character.
   Returns TRUE if sufficient cache capacity to complete pixel allocation.
   If cache overflow occurs, the cache is cleared together with the cache
   overflow flag and FALSE is returned.                                      */
{
fix31   to, from;
ufix16  flags;
ufix16 *pfunct;
float   scale, base_orus, base_pixels;
float   fpixels_in_zone;
fix15   pixels_available, pixels_in_zone;
fix31   orus_in_zone, orus_available;
fix31   queue[32];
fix15   queue_put, queue_get;
fix15   i, no_zones;
fix15   more_zones;
fix15   get_pixels();
boolean cache_data();

cache_overflow = FALSE;       /* Initialize cache overflow flag */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec)) /* Ensure data in cache */
    {
    init_cache(x_pixels_per_em, y_pixels_per_em); /* Clear cache */
    return(FALSE);            /* Indicate pixel allocation not done */
    }

get_cache_no_zones(char_num, dimension, &no_zones);
if (no_zones == 0)            /* No zone data in this dimension? */
    return(TRUE);

/* Compute pixels in top level zone */
get_cache_data(char_num, dimension, 0, &from, &to, &flags, &pfunct);
orus_in_zone = to - from;
if (dimension == X_DIMENSION)
    {
    scale = x_scale_nom;
    base_pixels = x_pixels_per_em * x_scale;
    }
else
    {
    scale = y_scale;
    base_pixels = y_pixels_per_em * y_scale;
    }
base_orus = outlres;
fpixels_in_zone = (orus_in_zone / base_orus) * base_pixels;
cache_fpixels(char_num, dimension, 0, fpixels_in_zone, scale);
pixels_in_zone = get_pixels(char_num, dimension, 0, scale);
if (cache_overflow)
    {
    init_cache(x_pixels_per_em, y_pixels_per_em);
    cache_overflow = FALSE;
    return(FALSE);
    }

if (no_zones == 1)                      /* No child zone data in this dimension? */
    return(TRUE);

queue_put = queue_get = 0;    /* Set up empty queue */
queue[queue_put++] = orus_in_zone;
queue[queue_put++] = pixels_in_zone;
i = 1;
while (queue_get < queue_put)           /* Queue not yet empty? */
    {
    orus_available = queue[queue_get++];
    pixels_available = queue[queue_get++];
    more_zones = 1;                     /* Assume at least one zone */
    while (more_zones)
        {
        get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
        orus_in_zone = to - from;
        if ((flags & MASK_L_FLAG) &&
            ((dimension == Y_DIMENSION) || sw_fixed))     /* New level? */
            {
            base_pixels = (float)pixels_available;
            base_orus = (float)orus_available;
            }
        if (orus_in_zone == 0.0)
            fpixels_in_zone = 0.0;
        else
            fpixels_in_zone = (orus_in_zone / base_orus) * base_pixels;
        cache_fpixels(char_num, dimension, i, fpixels_in_zone, scale);
        pixels_in_zone = get_pixels(char_num, dimension, i, scale);
        if (cache_overflow)              /* Cache overflow? */
            {
            init_cache(x_pixels_per_em, y_pixels_per_em);
            cache_overflow = FALSE;
            return(FALSE);
            }
        orus_available -= orus_in_zone;
        pixels_available -= pixels_in_zone;
        if (flags & MASK_P_FLAG)         /* Parent zone? */
            {
            queue[queue_put++] = orus_in_zone;
            queue[queue_put++] = pixels_in_zone;
            }
        more_zones = flags & MASK_C_FLAG;
        i++;
        }
    }
if (i != no_zones)
    {
    fprintf(stderr, "alloc_pixels: inconsistent zone count in char number %d\n", char_num);
    }

return(TRUE);
}


FUNCTION static fix15 get_pixels(char_num, dimension, zone_no, scale)
ufix16 char_num;   /* Character number */
fix15 dimension;   /* Dimension */
fix15 zone_no;     /* Zone number */
float scale;       /* Scale factor */
/* Called by alloc_pixels(), get_pixels() and get_fpixels() to calculate the
   integral number of pixels allocated to the specified zone in the specified
   dimension of the specified character.
   Returns the number of pixels allocated.
   Sets cache_overflow TRUE if cache overflow occurs.                        */
{
fix15 pixls, min_pixels;
ufix16 new_char_no;
fix15  new_dimension, new_zone_no;
float *stack_pointer;
float fpixels, const;
float stack[10];
fix31 from, to;
fix31 x, y;
ufix16 flags, fn_flag, dimension_flag, op_code, term_flag;
ufix16 *pfunct;
fix15 is_c_p_item(), is_c_f_item(), is_c_t_item();
fix15 is_c_const_item(), is_c_op_item();
float get_fpixels();
float get_tpixels();
boolean cache_data();
boolean cached_pixels();


/* Check if pixels previously calculated for specified zone */
if (cached_pixels(char_num, dimension, zone_no, scale, &pixls))
    {
    return(pixls);
    }

/* Ensure that zone data is in the cache */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec)) /* Ensure data in cache */
    {
    cache_overflow = TRUE;
    return(0);
    }

get_cache_data(char_num, dimension, zone_no, &from, &to, &flags, &pfunct);
fn_flag = flags & MASK_FN_FLAG;
if (fn_flag == 0)                                        /* No constraint function? */
    {
    fpixels = get_fpixels(char_num, dimension, zone_no, scale);  /* Get float value for pixels */
    if (zone_no != 0)                                    /* Not root zone? */
        {
        pixls = fpixels + 0.5;                           /* Round to nearest whole number of pixels */
        }
    else
        {
        pixls = fpixels + 0.499;                         /* Prefer to round down for root zone */
        }
    }
else
    {
    stack_pointer = stack;                               /* Initialize function execution stack pointer */
    while(fn_flag)
        {
        if (fn_flag == FN_ONE_ITEM)                      /* One item in constraint function? */
            fn_flag = 0;                                 /* Exit after one cycle */

        if (is_c_p_item(&pfunct, &new_char_no, &dimension_flag, &new_zone_no)) /* P item? */
            {
            if (dimension_flag)                          /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    new_dimension = Y_DIMENSION;         /* Other dimension must be Y */
                    if (y_zone_data_valid)               /* Plaid valid in other dimension? */
                        {
                        pixls = get_pixels(new_char_no, new_dimension, new_zone_no, y_scale);
                        pixls = (pixls * x_pixels_per_em * x_scale_nom) /
                            (y_pixels_per_em * y_scale) +
                            0.5;
                        }
                    else
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        pixls = ((to - from) * x_pixels_per_em * x_scale_nom / outlres) + 0.5;
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    new_dimension = X_DIMENSION;         /* Other dimension must be X */
                    if (x_zone_data_valid)               /* Plaid valid in other dimension? */
                        {
                        pixls = get_pixels(new_char_no, new_dimension, new_zone_no, x_scale_nom);
                        pixls = (pixls * y_pixels_per_em * y_scale) /
                            (x_pixels_per_em * x_scale_nom) +
                            0.5;
                        }
                    else                                 /* Plaid not valid in other dimension? */
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        pixls = ((to - from) * y_pixels_per_em * y_scale / outlres) + 0.5;
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                pixls = get_pixels(new_char_no, dimension, new_zone_no, scale);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = pixls;                  /* Push rounded pixels onto execution stack */
            continue;
            }

        else if (is_c_f_item(&pfunct, &new_char_no, &dimension_flag, &new_zone_no)) /* F item? */
            {
            if (dimension_flag)                          /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    new_dimension = Y_DIMENSION;         /* Other dimension must be Y */
                    if (y_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        fpixels = get_fpixels(new_char_no, new_dimension, new_zone_no, y_scale);
                        fpixels = fpixels * x_pixels_per_em * x_scale_nom /
                            (y_pixels_per_em * y_scale);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        fpixels = ((to - from) * x_pixels_per_em * x_scale_nom) / outlres;
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    new_dimension = X_DIMENSION;         /* Other dimension must be X */
                    if (x_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        fpixels = get_fpixels(new_char_no, new_dimension, new_zone_no, y_scale);
                        fpixels = fpixels * y_pixels_per_em * y_scale /
                            (x_pixels_per_em * x_scale_nom);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        fpixels = ((to - from) * y_pixels_per_em * y_scale) / outlres;
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                fpixels = get_fpixels(new_char_no, dimension, new_zone_no, scale);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = fpixels;                /* Push unrounded pixels onto stack */
            continue;
            }

        else if (is_c_t_item(&pfunct, &new_char_no, &dimension_flag, &new_zone_no)) /* T item? */
            {
            if (dimension_flag)                          /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    new_dimension = Y_DIMENSION;         /* Other dimension must be Y */
                    if (y_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        fpixels = get_tpixels(new_char_no, new_dimension, new_zone_no, y_scale);
                        fpixels = (fpixels * x_pixels_per_em * x_scale_nom) /
                            (y_pixels_per_em * y_scale);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        fpixels = (to - from) * x_pixels_per_em * x_scale_nom / outlres;
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    new_dimension = X_DIMENSION;         /* Other dimension must be X */
                    if (x_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        fpixels = get_tpixels(new_char_no, new_dimension, new_zone_no, x_scale_nom);
                        fpixels = (fpixels * y_pixels_per_em * y_scale) /
                            (x_pixels_per_em * x_scale_nom);
                        }
                    else
                        {
                        get_cache_data(new_char_no, new_dimension, new_zone_no,
                            &from, &to, &flags, &pfunct);
                        fpixels = (to - from) * y_pixels_per_em * y_scale / outlres;
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                fpixels = get_tpixels(new_char_no, dimension, new_zone_no, scale);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = fpixels;                /* Push unrounded pixels onto execution stack */
            continue;
            }

        else if (is_c_const_item(&pfunct, &x, &y))       /* Constant item? */
            {
            if (y == 0) const = (float)x;
            else if (y == -1) const = x * 0.1;
            else if (y == -2) const = x * 0.01;
            else if (y == -3) const = x * 0.001;
            else if (y == -4) const = x * 0.0001;
            else if (y == -5) const = x * 0.00001;
            else if (y == -6) const = x * 0.000001;
            else
                {
                fprintf(stderr, "get_pixels: Constant used in char no %d out of range\n", char_num);
                const = 0.0;                                             
                }
            *(stack_pointer++) = const;                  /* Push constant onto stack */
            continue;                                         
            }

        else if (is_c_op_item(&pfunct, &op_code, &term_flag)) /* Operator item? */
            {
            if (term_flag)                               /* Terminating operator? */
                fn_flag = 0;                             /* Exit after this cycle */
            switch (op_code)
                {
            case 0:                                      /* NOP operator? */
                continue;

            case 1:                                      /* ADD operator? */
                do_add(&stack_pointer);                  /* Execute addition operator */ 
                continue;
 
            case 2:                                      /* SUB operator? */
                do_sub(&stack_pointer);                  /* Executute subtraction operator */
                continue;

            case 3:                                      /* MUL operator? */
                do_mul(&stack_pointer);                  /* Execute multiplication operator */
                continue;

            case 4:                                      /* DIV operator? */
                do_div(&stack_pointer);                  /* Execute division operator */
                continue;

            case 5:                                      /* PRINT operator? */
                do_print(&stack_pointer);                /* Execute PRINT operator */
                continue;

            case 6:                                      /* FIXR operator? */
                do_fixr(&stack_pointer);                 /* Execute FIXR operator */
                continue;

            case 7:                                      /* FIX operator */
                do_fix(&stack_pointer);                  /* Execute FIX operator */
                continue;

            case 8:                                      /* CO operator? */
                do_co(&stack_pointer);                   /* Execute CO operator */
                continue;

            case 9:                                      /* CF operator? */
                do_cf(&stack_pointer);                   /* Execute CF operator */
                continue;

            case 10:                                     /* RRFS operator? */
                do_rrfs(&stack_pointer);                 /* Execute RRFS operator */
                continue;

            case 11:                                     /* RRHS operator? */
                do_rrhs(&stack_pointer);                 /* Execute RRHS operator */
                continue;

            case 12:                                     /* RRFS1 operator? */
                do_rrfs1(&stack_pointer);                /* Execute RRFS1 operator */
                continue;

            case 13:                                     /* RRHS1 operator? */
                do_rrhs1(&stack_pointer);                /* Execute RRHS1 operator */
                continue;

            case 14:                                     /* BZON operator? */
                do_bzon(&stack_pointer);                 /* Execute BZON operator */
                continue;

            case 15:                                     /* BZON1 operator? */
                do_bzon1(&stack_pointer);                /* Execute BZON1 operator */
                continue;                     

            case 16:                                     /* LZON operator? */
                do_lzon(&stack_pointer);                 /* Execute LZON operator */
                continue;

            case 17:                                     /* LZON1 operator? */
                do_lzon1(&stack_pointer);                /* Execute LZON1 operator */
                continue;

            case 18:                                     /* CFFLB operator? */
                do_cfflb(&stack_pointer);                /* Execute CFFLB operator */
                continue;

            case 19:                                     /* CFFRB operator? */
                do_cffrb(&stack_pointer);                /* Execute CFFRB operator */
                continue;

            case 20:                                     /* CFSLB operator? */
                do_cfslb(&stack_pointer);                /* Execute CFSLB operator */
                continue;

            case 21:                                     /* CFSRB operator? */
                do_cfsrb(&stack_pointer);                /* Execute CFSRB operator */
                continue;

            case 22:                                     /* XHT_ADJ operator? */
                do_xht_adj(xht_adj, &stack_pointer);     /* Execute XHT_ADJ operator */
                continue;

            default:
                fprintf(stderr, "get_pixels: Illegal op code %d used in char no %d not recognized\n", op_code, char_num);
                continue;
                }
            }
        else
            {
            fprintf(stderr, "get_pixels: constraint function item %4x used in char no %d not recognized\n", *pfunct, char_num);
            }
        }
    pixls = *(--stack_pointer) + 0.5;                    /* Pop top of stack for result */
    if (stack_pointer != stack)                          /* Stack now empty? */
        {
        fprintf(stderr, "get_pixels: stack not empty at end of constraint function in char no %d\n", char_num);
        }
    }
min_pixels = flags & MASK_MIN;
if (pixls < min_pixels)                                  /* Result less than minimum? */
    pixls = min_pixels;                                  /* Use minimum for result */
cache_pixels(char_num, dimension, zone_no, pixls, scale); /* Cache pixels */
return(pixls);
}


FUNCTION static float get_fpixels(char_num, dimension, zone_no, scale)
ufix16 char_num;                      /* Character offset */
fix15 dimension;                      /* 0 if x zone, 1 if y zone */
fix15 zone_no;                        /* Zone number */
float scale; 
/* Returns the number of floating pixels allocated to the specified zone in 
   the specified character.                                                 
   Sets cache_overflow TRUE if cache overflow occurs.                         */
{
fix31 from, to;
ufix16 flags;
ufix16 *pfunct;
fix15 i;
fix31 queue[32];
fix15 queue_put, queue_get;
fix31 orus_in_zone, orus_available;
float base_orus, base_pixels;
float fpixels_in_zone;
fix15 pixels_available, pixels_in_zone;
fix15 more_zones;
boolean cached_fpixels();
float get_tpixels();
boolean cache_data();
boolean path_mask[MAX_ZONES_PER_DIM];

/* Check if fpixels previously calculated for specified zone */
if (cached_fpixels(char_num, dimension, zone_no, scale, &fpixels_in_zone))
    {
    return(fpixels_in_zone);
    }

/* Check if set width unconstrained */
if (!sw_fixed && (dimension == X_DIMENSION))       /* Width unconstrained? */
    {
    return(get_tpixels(char_num, dimension, zone_no, scale));
    }

/* Ensure that zone data is in the cache */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec))
    {
    cache_overflow = TRUE;
    return(0.0);
    }

/* Determine which zones need pixel values to be calculated */
make_path_mask(char_num, dimension, zone_no, path_mask);

/* Compute pixels in top level zone */
get_cache_data(char_num, dimension, 0, &from, &to, &flags, &pfunct);
orus_in_zone = to - from;
if (dimension == X_DIMENSION)
    {
    base_pixels = x_pixels_per_em * x_scale;
    }
else
    {
    base_pixels = y_pixels_per_em * y_scale;
    }
base_orus = outlres;

fpixels_in_zone = (orus_in_zone / base_orus) * base_pixels; /* Calculate floating pixels in root zone */

if (zone_no == 0)                                  /* Root zone is target zone? */
    {
    return(fpixels_in_zone);                       /* Return floating pixels in root zone */
    }
pixels_in_zone = get_pixels(char_num, dimension, 0, scale);
if (cache_overflow)                                /* Cache overflow? */
    return(0.0);

queue_put = queue_get = 0;                         /* Clear queue */
queue[queue_put++] = orus_in_zone;                 /* Add number of orus in top zone to queue */
queue[queue_put++] = pixels_in_zone;               /* Add number of pixels in top zone to queue */

i = 1;
while (queue_get < queue_put)                      /* While queue not empty ... */
    {
    orus_available = queue[queue_get++];           /* Get number of orus available from queue */
    pixels_available = queue[queue_get++];         /* Get number of pixels available from queue */
    more_zones = 1;                                /* Assume at least one zone */
    while (more_zones)                             /* For each daughter zone ... */
        {
        get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
        orus_in_zone = to - from;                  /* Get number of orus in zone */
        if (flags & MASK_L_FLAG)                   /* New level in hierarchy? */
            {
            base_pixels = (float)pixels_available;
            base_orus = (float)orus_available;
            }
        if (orus_in_zone == 0.0)
                fpixels_in_zone = 0.0;
            else
                fpixels_in_zone = (orus_in_zone / base_orus) * base_pixels; /* Calculate floating pixels in zone */
        if (i == zone_no)                          /* Target zone? */
            {
            cache_fpixels(char_num, dimension, i, fpixels_in_zone, scale); /* Save for possible future use */
            return(fpixels_in_zone);               /* Return floating number of pixels in target zone */
            }
        if (path_mask[i])                          /* This zone needs pixels calculated? */
            {
            cache_fpixels(char_num, dimension, i, fpixels_in_zone, scale); /* Save for possible future use */
            pixels_in_zone = get_pixels(char_num, dimension, i, scale); /* Calculate number of pixels in zone */
            if (cache_overflow)                    /* Cache overflow? */
                return(0.0);
            pixels_available -= pixels_in_zone;    /* Subtract from pixel budget */
            }                                                                
        orus_available -= orus_in_zone;            /* Subtract from oru budget */
        if (flags & MASK_P_FLAG)                   /* Parent zone? */
            {
            queue[queue_put++] = orus_in_zone;     /* Add number of orus in zone to queue */
            queue[queue_put++] = pixels_in_zone;   /* Add number of pixels in zone to queue */
            }
        more_zones = flags & MASK_C_FLAG; 
        i++;
        }
    }
fprintf(stderr, "get_fpixels: zone %d used in char %d not found\n", zone_no, char_num);
return(0.0);
}


FUNCTION  make_path_mask (char_num, dimension, zone_no, mask)
ufix16 char_num;   /* Character number */
fix15 dimension;   /* 0 if x zone, 1 if y zone */
fix15 zone_no;     /* Zone number */
boolean mask[];    /* mask[i] is true if pixel value required for zone i */
/* Finds a path from the root zone of the specified dimension of the specified
   character to the specified target zone.
   Each truth value in the updated mask array indicates if the number of pixels
   needs to be calculated for the corresponding zone in order to calculate
   the number of floating pixels in the target zone.
   The zone data for the specified dimension of the specified character is
   assumed to be in the cache.                                              */
{
fix15  i, j;
ufix16 queue_put, queue_get;
fix15  queue[32];
fix15  link[MAX_ZONES_PER_DIM];
fix15  prev_zone;
fix15  more_zones;
fix31  from, to;
ufix16 flags;
ufix16 *pfunct;

i = 0;                                          /* Start at root zone */
queue_put = queue_get = 0;                      /* Clear queue */
queue[queue_put++] = -1;                        /* Terminate reverse link chain */
while (queue_get < queue_put)                   /* More groups? */
    {
    prev_zone = queue[queue_get++];             /* Get link to previous zone from queue */
    more_zones = 1;                             /* Assume at least one zone */
    while (more_zones)                          /* More zones in this group? */
        {
        mask[i] = FALSE;                        /* Initialize mask array element */
        link[i] = prev_zone;                    /* Set up link to previous zone */
        get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
        if (i == zone_no)                       /* Target zone? */
            {
            while ((flags & MASK_L_FLAG) == 0)  /* Same level as previous zone? */
                {
                i--;                            /* Back up one zone */
                get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
                }
            while ((j = link[i]) >= 0)
                {
                mask[j] = TRUE;                 /* Mark pixel allocation required */
                get_cache_data(char_num, dimension, j, &from, &to, &flags, &pfunct);
                if ((flags & MASK_P_FLAG) &&
                    (((i - j) > 1) || ((flags & MASK_C_FLAG) == 0))) /* Zone j is parent? */
                    {
                    while ((flags & MASK_L_FLAG) == 0) /* Same level as prev zone? */
                        {
                        j--;                    /* Back up one zone */
                        get_cache_data(char_num, dimension, j, &from, &to, &flags, &pfunct);
                        }
                    }
                i = j;
                }
            return;
            }
        if (flags & MASK_P_FLAG)                /* Parent zone? */
            {
            queue[queue_put++] = i;             /* Queue link to this zone */
            }
        prev_zone = i;                          /* Save link to this zone */
        more_zones = flags & MASK_C_FLAG; 
        i++;                                    /* Next zone in sequence */
        }
    }
fprintf(stderr, "make_path_mask: zone %d not found in char %d, dimension %d\n", zone_no, char_num, dimension);
return;
}


FUNCTION static float get_tpixels(char_num, dimension, zone_no, scale)
ufix16 char_num;                      /* Character offset */
fix15 dimension;                      /* 0 if x zone, 1 if y zone */
fix15 zone_no;                        /* Zone number */
float scale; 
/* Returns the number of pixels allocated to the specified zone in the */
/* character whose root zone is at the specified character offset.  The rate of  */
/* exchange from outline resolution units to pixels is at the top level.         */
{
fix31 from, to;
ufix16 flags;
ufix16 *pfunct;
fix31 orus_in_zone;
float base_orus, base_pixels;
float fpixels_in_zone;
boolean cache_data();

/* Ensure that zone data is in the cache */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec))
    {
    cache_overflow = TRUE;
    return(0.0);
    }

get_cache_data(char_num, dimension, zone_no, &from, &to, &flags, &pfunct);
orus_in_zone = to - from;
base_orus = outlres;
if (dimension == X_DIMENSION)
    {
    base_pixels = x_pixels_per_em * x_scale_nom;
    }
else
    {
    base_pixels = y_pixels_per_em * y_scale;
    }
fpixels_in_zone = (orus_in_zone / base_orus) * base_pixels;
return(fpixels_in_zone);               /* Return number of pixels in target zone */
}


FUNCTION static make_edge_list(char_num, dimension, scale, pn)
ufix16 char_num;
fix15 dimension;
float scale;
fix15 *pn;
/* Called by setup_..._trans() to build a sorted list of zone edges and
   corresponding pixel allocations in edges[] and pixels[].
   Sets *pn to number of edges generated (zero if no zone data)       */
{
fix15 no_zones, i, j;
fix31 from, to, max_edge;
ufix16 flags;
ufix16 *pfunct;
boolean flag;
ufix16  temp_ufix16;
double  temp_double;
boolean cached_pixels();

/* Make list of zones and associated number of pixels */
get_cache_no_zones(char_num, dimension, &no_zones);
if (no_zones == 0)         /* No zone data? */
    {
    *pn = 0;
    return;
    }
j = 0;
for (i = 0; i < no_zones; i++)
    {
    get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
    if (i == 0)
        max_edge = to;
    if ((flags & MASK_P_FLAG) == 0)       /* Not parent zone? */
        {
        edges[j] = from;
        if (!cached_pixels(char_num, dimension, i, scale, &pixels[j]))
            fprintf(stderr, "make_edge_list: pixel value not in cache\n");
        if (to > max_edge)
            {
            max_edge = to;
            }
        j++;
        if ((j + 2) >= MAX_ZONES_PER_DIM)
            {
            fprintf(stderr, "make_edge_list: Too many zones\n");
            j--;
            }
        }
    }
edges[j] = max_edge;
pixels[j] = 0;
j++;
*pn = j;

/* Sort zones into ascending order */
flag = TRUE;
while (flag)
    {
    flag = FALSE;
    for (i = 1; i < j; i++)
        {
        if (edges[i] < edges[i - 1])
            {
            temp_double = edges[i];
            edges[i] = edges[i - 1];
            edges[i - 1] = temp_double;
            temp_ufix16 = pixels[i];
            pixels[i] = pixels[i - 1];
            pixels[i - 1] = temp_ufix16;
            flag = TRUE;
            }
        }
    j--;
    }
}


FUNCTION static make_x_trans_list(n, direction, a, b)
fix15 n;             /* Number of edges */
fix15 direction;     /* +1 indicated increasing pixel values, -1 decreasing values */
double a[];          /* Generated list of edge coordinates in outline resolution units */
fix15 b[];           /* Corresponding list of coordinates in pixel space */
/* Called by setup_xx_trans() and setup_yy_trans() to generate a list of outline
   x coordinates and their corresponding transformed pixel coordinates from
   edges[] and pixels[].                                                       */
{
fix15 i;
fix15 position;
float fposition;
float comp_edge;
float do_comp_x_trans();

if (n == 0)                    /* No zone data? */
    return;                    /* No transformation list needed */

/* Calculate pixel coordinate of first edge */
fposition = do_comp_x_trans(x_pos);
if (edges[0] >= 0.0)           /* First edge right of origin? */
    {
    fposition += edges[0] * x_pixels_per_em * x_scale / outlres;
    }
else                           /* First edge left of origin? */
    {
    for (i = 1; i < n; i++)
        {
        fposition -= pixels[i - 1];
        if (edges[i] >= 0.0)
            break;
        }
    if (i < n)                 /* Positive edge value found */
        {
        fposition += edges[i] * pixels[i - 1] / (edges[i] - edges[i - 1]);
        }
    else                       /* Positive edge value not found */
        {
        fposition += edges[n-1] * x_pixels_per_em * x_scale / outlres;
        }
    }
position = floor(fposition + 0.5);

/* Assign absolute coordinates in pixel space and update compound trans table */
for (i = 0; i < n; i++)
    {
    a[i] = edges[i];
    b[i] = direction * position;
    comp_edge = edges[i] * x_scale + x_pos;
    if ((no_comp_x_edges == 0) ||       /* nothing in comp trans table? */
         ((fposition >= comp_x_pixel_tbl[no_comp_x_edges - 1]) &&
            (comp_edge > comp_x_edge_tbl[no_comp_x_edges - 1])))
        {
        comp_x_edge_tbl[no_comp_x_edges] = comp_edge;
        comp_x_pixel_tbl[no_comp_x_edges] = fposition;
        no_comp_x_edges++;
        }
    fposition += pixels[i];
    position += pixels[i];
    }
#ifdef RULESDBG
if (print_trans_data)
    {
    printf("Compound Transformation table\n");
    for (i = 0; i < no_comp_x_edges; i++)
        {
        printf("%10.2f %4d\n", comp_x_edge_tbl[i], comp_x_pixel_tbl[i]);
        }
    }
#endif
}


FUNCTION static make_y_trans_list(n, direction, a, b)
fix15 n;             /* Number of edges */
fix15 direction;     /* +1 indicated increasing pixel values, -1 decreasing values */
double a[];          /* Generated list of edge coordinates in outline resolution units */
fix15 b[];           /* Corresponding list of coordinates in pixel space */
/* Called by setup_xy_trans() and setup_yy_trans() to generate a list of outline
   y coordinates and their corresponding transformed pixel coordinates from edges[]
   and pixels[].                                                                       */
{
fix15 i, org_i;
fix15 j;
fix15 pos, org_pos;
fix15 bottom, top, this_edge;
double fpos;
double best_edge;

if (n == 0)                    /* No zone data? */
    return;                    /* No transformation list needed */


/* Look for bottom or top of emsquare in list of edges */
bottom = floor(EM_BOT * (outlres / 8640) + 0.5);
top = floor(EM_TOP * (outlres / 8640) + 0.5);
for (i = 0; i < n; i++)
    {
    this_edge = floor(edges[i] + 0.5);
    if ((j = this_edge - bottom) == 0  ||  j == 1  ||  j == -1)
        {
        fpos = (edges[i] * y_scale + y_pos) * y_pixels_per_em / outlres;
        org_pos = floor(fpos + 0.5);
        org_i = i;
        goto finish;
        }
    if ((j = this_edge - top) <= 1  &&  j >= -1)
        {
        fpos = (bottom * y_scale + y_pos) * y_pixels_per_em / outlres;
        org_pos = floor(fpos + 0.5);
        org_pos += floor(y_scale * y_pixels_per_em + 0.499);
        org_i = i;
        goto finish;
        }
    }

/* If no edge at bottom or top, then look for edge nearest baseline */
org_i = 0;
best_edge = fabs(edges[0]);
for (i = 0; i < n; i++)
    {
    if (fabs(edges[i]) < best_edge)
        {
        best_edge = fabs(edges[i]);
        org_i = i;
        }
    }
fpos = (edges[org_i] * y_scale + y_pos) * y_pixels_per_em / outlres;
org_pos = floor(fpos + 0.5);

/* Fill in pixel addresses for each edge */
finish:
pos = org_pos;
for (i = org_i; i < n; i++)
    {
    a[i] = edges[i];
    b[i] = direction * pos;
    pos += pixels[i];
    }
pos = org_pos;
for (i = org_i - 1; i >= 0; i--)
    {
    pos -= pixels[i];
    a[i] = edges[i];
    b[i] = direction * pos;
    }
}


FUNCTION  static  make_trans_table (pixels_per_em, scale, pos, direction,
    orus_tbl, pixels_tbl, n, mult_tbl, offset_tbl, pno_transforms)
float  pixels_per_em;  /* pixels per em */
float  scale;          /* scale factor */
float  pos;            /* position */
fix15  direction;      /* +1 indicated increasing pixel values, -1 decreasing values */
double orus_tbl[];     /* table of oru values */
fix15  pixels_tbl[];   /* table of corresponding pixel values */
fix15  n;              /* number of entries in orus/pixels tables */
double mult_tbl[];     /* Transformation multiplier */
double offset_tbl[];   /* Transformation constants */
fix15 *pno_transforms; /* (output) number of multipliers/constants */

/* Called by setup_..._trans() to generate interpolation function coefficients
   from list of zone edge values and their corresponding unrounded pixel values.
                                                                             */

{
double prev_orus;
fix15  prev_pixels;
fix15  i, k;

if (n == 0)          /* No zone data? */
    {
    mult_tbl[0] = pixels_per_em * scale * direction / outlres;
    offset_tbl[0] = pos * pixels_per_em * direction / outlres;
    *pno_transforms = 0;
    return;
    }

if (n < 2)
    {
    fprintf(stderr, "make_trans_table: Illegal n value (%d)\n", n);
    return;
    }

if (orus_tbl[n - 1] < orus_tbl[0])
    {
    fprintf(stderr, "make_trans_table: Negative range\n");
    return;
    }

/* Generate coefficient table */
mult_tbl[0] = pixels_per_em * scale * direction / outlres;
offset_tbl[0] = (double)pixels_tbl[0] - (orus_tbl[0] * mult_tbl[0]);
prev_orus = orus_tbl[0];
prev_pixels = pixels_tbl[0];
k = 1;
for (i = 1; i < n; i++)
    {
    if (orus_tbl[i] > prev_orus)
        {
        orus_tbl[k] = orus_tbl[i];
        mult_tbl[k] = (double)(pixels_tbl[i] - prev_pixels) / (orus_tbl[i] - prev_orus);
        offset_tbl[k] = (double)pixels_tbl[i] - (orus_tbl[i] * mult_tbl[k]);
        prev_orus = orus_tbl[i];
        prev_pixels = pixels_tbl[i];
        k++;
        }
    }
orus_tbl[k] = orus_tbl[n - 1];
mult_tbl[k] = mult_tbl[0];
offset_tbl[k] = (double)pixels_tbl[n - 1] - (orus_tbl[n - 1] * mult_tbl[0]);
*pno_transforms = k;
}


FUNCTION  double  do_x_trans (x, y)
  real      x, y;

/* Executes x transformation function.                                        */
{
fix15 i;

if (no_xx_transforms >= 0)         /* x is a function of x only? */
    {
    for (i = 0; i < no_xx_transforms; i++)
        {
        if (x <= x_orus[i])
            {
            return (x * x_mult_tbl[i] + x_offset_tbl[i]);
            }
        }
    return (x * x_mult_tbl[no_xx_transforms] + x_offset_tbl[no_xx_transforms]);
    }

if (no_xy_transforms >= 0)          /* x is a function of y only? */
    {
    for (i = 0; i < no_xy_transforms; i++)
        {
        if (y <= x_orus[i])
            {
            return (y * x_mult_tbl[i] + x_offset_tbl[i]);
            }
        }
    return (y * x_mult_tbl[no_xy_transforms] + x_offset_tbl[no_xy_transforms]);
    }

return (x * xx_mult + y * xy_mult + x_offset);  /* x is a function of x and y? */
}


FUNCTION  double  do_y_trans (x, y)
  real      x, y;

/* Executes y transformation function.                                        */
{
fix15 i;

if (no_yy_transforms >= 0)      /* y is a function of y only? */
    {
    for (i = 0; i < no_yy_transforms; i++)
        {
        if (y <= y_orus[i])
            {
            return (y * y_mult_tbl[i] + y_offset_tbl[i]);
            }
        }
    return (y * y_mult_tbl[no_yy_transforms] + y_offset_tbl[no_yy_transforms]);
    }

if (no_yx_transforms >= 0)      /* y is a function of x only? */
    {
    for (i = 0; i < no_yx_transforms; i++)
        {
        if (x <= y_orus[i])
            {
            return (x * y_mult_tbl[i] + y_offset_tbl[i]);
            }
        }
    return (x * y_mult_tbl[no_yx_transforms] + y_offset_tbl[no_yx_transforms]);
    }

return (x * yx_mult + y * yy_mult + y_offset);  /* y is a function of x and y? */
}


FUNCTION  void  do_xy_trans (x, y, xtr, ytr)
  real      x, y;               /* (x, y) input arguments */
  real      *xtr, *ytr;         /* output arguments */

/* Executes x and y transformation functions.   */

    DECLARE
    register fix15  i;

    BEGIN
    if (no_xx_transforms >= 0)          /* x is a function of x only? */
        {
        for (i = 0; i < no_xx_transforms; i++)
            {
            if (x <= x_orus[i])
                {
                *xtr = x * x_mult_tbl[i] + x_offset_tbl[i];
                break;
                }
            }
        if (i == no_xx_transforms)
            *xtr = x * x_mult_tbl[i] + x_offset_tbl[i];
        }

    else if (no_xy_transforms >= 0)     /* x is a function of y only? */
        {
        for (i = 0; i < no_xy_transforms; i++)
            {
            if (y <= x_orus[i])
                {
                *xtr = y * x_mult_tbl[i] + x_offset_tbl[i];
                break;
                }
            }
        if (i == no_xy_transforms)
            *xtr = y * x_mult_tbl[i] + x_offset_tbl[i];
        }

    else
        {
        *xtr = x * xx_mult + y * xy_mult + x_offset;    /* x is a function of x and y. */
        }

    if (no_yy_transforms >= 0)          /* y is a function of y only? */
        {
        for (i = 0; i < no_yy_transforms; i++)
            {
            if (y <= y_orus[i])
                {
                *ytr = y * y_mult_tbl[i] + y_offset_tbl[i];
                break;
                }
            }
        if (i == no_yy_transforms)
            *ytr = y * y_mult_tbl[i] + y_offset_tbl[i];
        }

    else if (no_yx_transforms >= 0)      /* y is a function of x only? */
        {
        for (i = 0; i < no_yx_transforms; i++)
            {
            if (x <= y_orus[i])
                {
                *ytr = x * y_mult_tbl[i] + y_offset_tbl[i];
                break;
                }
            }
        if (i == no_yx_transforms)
            *ytr = x * y_mult_tbl[i] + y_offset_tbl[i];
        }

    else
        {
        *ytr = x * yx_mult + y * yy_mult + y_offset;    /* y is a function of x and y. */
        }

    return;
    END


FUNCTION float do_comp_x_trans(x)
float x;
/* Transforms x coordinate in oru space into x coordinate in pixel space.
   Used for x position and set width calculations                           */
{
fix15 i;
float new_x;

if (no_comp_x_edges != 0)
    {
    for (i = 0; i < no_comp_x_edges; i++)
        {
        if (x <= comp_x_edge_tbl[i]) 
            {
            if (i != 0)
                {
                new_x = comp_x_pixel_tbl[i-1] +
                    (x - comp_x_edge_tbl[i-1]) /
                    (comp_x_edge_tbl[i] - comp_x_edge_tbl[i-1]) *
                    (comp_x_pixel_tbl[i] - comp_x_pixel_tbl[i-1]);
                return(new_x);
                }
            else
                {
                new_x = comp_x_pixel_tbl[0] - (comp_x_edge_tbl[0] - x) *
                    pixperoru_x;
                return(new_x);
                }
            }
        }
    new_x = comp_x_pixel_tbl[no_comp_x_edges - 1] +
        (x - comp_x_edge_tbl[no_comp_x_edges - 1]) * pixperoru_x;
    return(new_x);
    }
else
    {
    new_x = x * pixperoru_x;
    return(new_x);
    }
}


#ifdef RULESDBG
FUNCTION static print_x_trans_data ()
/* Called by setup_trans() to print the transformation coefficients for the
   computation of transformed x values.
   For debugging purposes only.                                              */
{
fix15 i;
double  do_x_trans();

if (!print_trans_data)
    return;
if (no_xx_transforms >= 0)
    {
    printf("X transformation table calculated from X:\n");
    for (i = 0; i < no_xx_transforms; i++)
        {
        printf("%10.2f %12d %12.5f %12.5f %12.5f\n",
            x_orus[i], x_pixels[i], x_mult_tbl[i], x_offset_tbl[i],
            do_x_trans(x_orus[i], (double)0.0));
        }
    printf("                        %12.5f %12.5f\n",
        x_mult_tbl[no_xx_transforms], x_offset_tbl[no_xx_transforms]);
    return;
    }

if (no_xy_transforms >= 0)
    {
    printf("X transformation table calculated from Y:\n");
    for (i = 0; i < no_xy_transforms; i++)
        {
        printf("%10.2f %12d %12.5f %12.5f %12.5f\n",
            x_orus[i], x_pixels[i], x_mult_tbl[i], x_offset_tbl[i],
            do_x_trans((double)0.0, x_orus[i]));
        }
    printf("                        %12.5f %12.5f\n",
        x_mult_tbl[no_xy_transforms], x_offset_tbl[no_xy_transforms]);
    return;
    }

printf("X transformation table calculated from X and Y:\n");
printf("                         %12.5f %12.5f %12.5f\n", xx_mult, xy_mult, x_offset);
}
#endif


#ifdef RULESDBG
FUNCTION static print_y_trans_data ()
/* Called by setup_trans() to print the transformation coefficients for the
   computation of transformed y values.
   For debugging purposes only.                                              */
{
fix15 i;
double  do_y_trans();

if (!print_trans_data)
    return;
if (no_yy_transforms >= 0)
    {
    printf("Y transformation table calculated from Y:\n");
    for (i = 0; i < no_yy_transforms; i++)
        {
        printf("%10.2f %12d %12.5f %12.5f %12.5f\n",
            y_orus[i], y_pixels[i], y_mult_tbl[i], y_offset_tbl[i],
            do_y_trans((double)0.0, y_orus[i]));
        }
    printf("                        %12.5f %12.5f\n",
        y_mult_tbl[no_yy_transforms], y_offset_tbl[no_yy_transforms]);
    return;
    }

if (no_yx_transforms >= 0)
    {
    printf("Y transformation table calculated from X:\n");
    for (i = 0; i < no_yx_transforms; i++)
        {
        printf("%10.2f %12d %12.5f %12.5f %12.5f\n",
            y_orus[i], y_pixels[i], y_mult_tbl[i], y_offset_tbl[i],
            do_y_trans(y_orus[i], (double)0.0));
        }
    printf("                        %12.5f %12.5f\n",
        y_mult_tbl[no_yx_transforms], y_offset_tbl[no_yx_transforms]);
    return;
    }

printf("Y transformation table calculated from X and Y:\n");
printf("                      %12.5f %12.5f %12.5f\n", yx_mult, yy_mult, y_offset);
}
#endif

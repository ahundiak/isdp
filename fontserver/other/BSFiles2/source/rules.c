




/*****************************************************************************
*                                                                            *
*               Copyright 1987, Bitstream Inc., Cambridge, MA                *
*                            Patent No. 4,785,391                            *
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

 0)  28-Oct-86        Version 1.1

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

 9)  13-May-87  mby   Fix error in transformation functions when      
                      pointsize_x != pointsize_y

10)  19-Jul-87  mby   Corrected computation of x_pixels_per_em & pixperoru_x
                      for oblique + rotate = 0, 180.
                      Fixed x_offset, y_offset in setup_xxy_trans(), setup_yxy_trans()

11)  14 Oct 87  jsc   Modifications to correct cached pixel values when
                      squeeze or imported width in effect:

                      setup_trans() sets flags x_scale_adj and y_scale_adj
                          to indicate difference between nominal and actual
                          scale factors in x and y.

                      alloc_pixels() changed to clear cached fpixel and pixel
                          values in dimension with scale_adj flag set.

                      get_fpixels() changed to use nominal scale factors for
                          characters except character or sub_character being
                          imaged and to use actual scale factor for that char.

                      make_edge_list() changed to clear cached fpixel and
                          pixel values in dimension with scale_adj flag set.

                      some y_scale changed to y_scale_nom to allow for
                          possible future y scale adjustment

12)  10 Nov 87  jsc  Inline code used in get_pixels() to execute CO operator.

                     Faster sort in make_edge_list()

                     Parsing of constraint functions changed to use get_c_item().

                     Extraction of constant item changed to use table.

                     do_xy_trans() modified to start interval search from previous
                     successful search.

                     reset_trans() added.

                     init_trans() modified to include calculation of overall
                     transformation parameters, cache clearing on font or size
                     change.

                     setup_comp_trans() added to initialize at the start of
                     a new character.

13)  20 Nov 87  jsc  x_orus[] and y_orus[] changed from real to fix31.

                     First 2 arguments of do_xy_trans() changed from real to fix31.
                     
                     scale argument removed from
                              get_pixels()
                              get_fpixels()
                              get_tpixels()
                              make_edge_list()
                     Selection between main and scaled cache handled by calls
                     to cache_select()

14)  24 Nov 87  jsc  Changed all oru coordinates from fix31 to fix15

15)  18 Dec 87  jsc  Changed all transformation coefficients from real
                     to fix31 (16 bits integer, 16 bits fraction).
                     do_xy_trans() now returns transformed coordinates
                     in units of 1/16 pixels.

16)   4 Mar 88  jsc  do_xy_trans() modified to work correctly when no_xx_trans or
                     no_yy_trans = 0

17)  17 Mar 88  jsc  const changed to fconst in get_pixels() to avoid name clash
                     with MS C compiler 5.0
                     
                     xht_adj mechanism removed (operator always interpreted as
                     pushing 1.0 onto the execution stack.

18)  24 Mar 88  reh  do_xy_trans() modified so that it rounds results instead of
                     truncating them. 

19)  23 May 88  reh  code modified so that do_xy_trans can return arguments with
                     seven bits of accuracy when lines per em is below 
                     X_SCAN_THRESH

20)  03 Jun 88  reh  Fontwide extents determine adjusting to three fractional bits of
                     accuracy if pixel coordinates exceed +/- 2048. Allows
                     characters up to 4096 lpem.

21)  15 jun 88  reh  constants in mkbm.h changed so that do_xy_trans() returns
                     with six bit accuracy when lines_per_em is below X_SCAN_THRESH
      
22)  1  Jul 88  reh  do_comp_xy_trans converted to integer. The a, b, c, d arguments
                     set up in setup_trans as static fix31 variables a_mult_x,
                     b_mult_x, a_mult_y, b_mult_y. Added do_comp_xy_oru_trans() to
                     deal with oru_top, oru_bot transformations form convert.c
23)  21 Jul 88  reh  most functions in rules.c converted to fixed point from reals.
                     many variables are now unsigned 32 bit integers with 16 bits
                     decimal and 16 bits fractional. Scale is unsigned 16 bit with
                     4 bits decimal and 12 bits fractional. It is converted to 
                     32 bit integers in rules.c.

24)  05 Aug 88  reh  Sliding point implemented. Variables are assigned a fixed point
                     on the basis of the fontwide extents. A 6 line per em character
                     would have 4 bits decimal and 27 fractional while a 300 line
                     character would have 10 bits decimal and 21 fractional. 

25)  10 Aug 88  reh  Code tweaked to where difference in output characters from
                     previous version are less than 1 character in a thousand

26)  11 Aug 88  tpl  changed error reporting 'printf' and 'fprintf(stderr'
                     to 'report_error(...' function calls


 ****************************************************************************/


#include "stdef.h"              /* Bitstream standard macros & definitions  */
#include "comp2_3.h"            /* data structures for compressed font */
#include "mkbm.h"               /* General definition for make_bmap */
#include "errchk.h"
#include <math.h>
#include "error.h"

/* this should be defined as a compilation argument */

#if 0
#define  RULESDBG            /* Prints x & y transformation tables for debugging */
#endif

/***** STATIC VARIABLES *****/

static real    d65536 = 65536.0;
static boolean cache_undef;        /* T if cache is undefined              */
static char    cache_font_id[4];   /* ID of font in cache                  */
static real    cache_x_ppem;       /* Current pixels per em in X dimension */
static real    cache_y_ppem;       /* Current pixels per em in Y dimension */
static boolean cache_overflow;     /* Cache overflow flag                  */

static real    point_size_x;       /* x-point size (72.3 pts per inch)     */
static real    point_size_y;       /* y-point size (72.3 pts per inch)     */
static real    res_hor;            /* output device resolution, horizontal */
static real    res_ver;            /* output device resolution, vertical   */
static real    rot_angle;          /* rotation angle in degrees (clockwise = positive)  */
static real    obl_angle;          /* obliquing angle in degrees (clockwise = positive) */
static bool16  sw_fixed;           /* true if set width constrained        */
static bool16  bogus_mode;         /* True: plaid data to be ignored       */
      
static fix31    a_mult_x, b_mult_x; /* arguments in do_comp_xy_trans() */
static fix31    a_mult_y, b_mult_y; /* which are set in setup_trans() */

                                    /* Fixed point accuracy is used in rules.c which is 
                                       determined by the fontwide extents. The following
                                       static variables are set according to how many
                                       bits of accuracy can be used  */
static fix15    pix_shift;          /* number of bits of accuracy, how many places to shift */
static real     pix_acc;            /* number to multiply by to achieve pix_shift bits of accuracy */
static fix31    pix_add_25;         /* .25 multiplied by pix_acc, used to round down with threshold of .25 */
static fix31    pix_add_75;         /* .75 multiplied by pix_acc, used to round up with threshold of .75 */
static fix31    pix_round_down;     /* .499 multiplied by pix_acc, used to round down */
static fix31    pix_round;          /* .5 multiplied by pix_acc, used to round up */
static real     dpt5;               /* used to round reals after they have been divided by pix_acc */
                                    /* This has half the outline res added to offset the loss of */
                                    /* accuracy from dividing by the outline res */
static boolean  change_scale;       /* did scale change since last time done */

static fix15    save_shift;          
static fix31    save_x_pixels;
static fix31    save_y_pixels;

static cft_outl_str *cfontp;       /* pointer to compr font structure */
static ufix16  char_no;            /* Current character or sub-character number */
static fix15   edges[MAX_ZONES_PER_DIM];
static fix15   pixels[MAX_ZONES_PER_DIM];
static real    outlres;            /* font outline resl/em in outline units */
static fix31   fix_outlres;        /* integer font outline resl/em in outline units */
static fix31   fix_otlres_div_2; /* integer font outline resl/em in outline units divided by 2 */
static fix15   bot_edge;           /* Bottom edge of emsquare in orus       */
static fix15   top_edge;           /* Top edge of emsquare in orus          */
static ufix16 huge *pfirst_rec;    /* ptr to first outline data record in font */
static real    pixperoru_h;        /* horizontal pixels per outline resolution unit */
static real    pixperoru_v;        /* vertical pixels per outline resolution unit */
static real    pixperoru_x;        /* x pixels per outline resolution unit */
static real    x_distortion;       /* = point_size_x / point_size_y */
static boolean print_trans_data;   /* Switch for printing generated trans data */
static real    sinrot, cosrot;     /* sine, cosine of rotation angle */
static real    tanobl;             /* tangent of obliquing angle */
static fix31   x_pixels_per_em;    /* Number of pixels per em in char x dimension */
static fix31   y_pixels_per_em;    /* Number of pixels per em in char y dimension */

static fix31   hi_x_pxls_per_em;   /* Number of pixels per em in char x dimension */
static fix31   hi_y_pxls_per_em;   /* Number of pixels per em in char y dimension */
static fix31   lo_x_pxls_per_em;   /* Number of pixels per em in char x dimension */
static fix31   lo_y_pxls_per_em;   /* Number of pixels per em in char y dimension */

static fix31   x_pos, y_pos;       /* x and y offsets */
static fix31   x_scale_nom, y_scale_nom; /* x and y nominal scale factors */
static boolean x_scale_adj, y_scale_adj; /* Variance flags for actual and nominal scales */
static fix31   x_scale, y_scale;   /* x and y scale factors */
static boolean x_zone_data_valid;  /* true if x zone data valid */
static boolean y_zone_data_valid;  /* true if y zone data valid */
static fix15   x_trans_case;       /* 0 = f(x), 1 = f(y), 2 = f(x, y)       */
static fix15   y_trans_case;       /* 0 = f(y), 1 = f(x), 2 = f(x, y)       */
static fix15   x_trans_dir;        /* 1 = positive, -1 = negative           */
static fix15   y_trans_dir;        /* 1 = positive, -1 = negative           */  

/* Transformation coefficients for current character */
fix15          no_xx_transforms;   /* No transforms for computing x from x */
fix15          no_xy_transforms;   /* No transforms for computing x from y */
fix15          x_i;                /* Current index into x_orus table */
fix15          x_orus[MAX_ZONES_PER_DIM];        /* Original x coord list */
static fix15   x_pixels[MAX_ZONES_PER_DIM];      /* Transformed x coord list */
fix31          x_mult_tbl[MAX_ZONES_PER_DIM];    /* Transformation multiplier */
fix31          x_offset_tbl[MAX_ZONES_PER_DIM];  /* Transformation offset */
fix31          xx_mult;            /* coeff of x for computing x from x and y */
fix31          xy_mult;            /* coeff of y for computing x from x and y */
fix31          x_offset;           /* constant for computing x from x and y   */

fix15          no_yx_transforms;   /* No transforms for computing y from x */
fix15          no_yy_transforms;   /* No transforms for computing y from y */
fix15          y_i;                /* Current index into y_orus table */

fix15          y_orus[MAX_ZONES_PER_DIM];        /* Original x coord list */
fix15          y_pixels[MAX_ZONES_PER_DIM];      /* Transformed x coord list */
fix31          y_mult_tbl[MAX_ZONES_PER_DIM];    /* Transformation multiplier */
fix31          y_offset_tbl[MAX_ZONES_PER_DIM];  /* Transformation offset */
fix31          yx_mult;            /* coeff of x for computing y from x and y */
fix31          yy_mult;            /* coeff of x for computing y from x and y */
fix31          y_offset;           /* constant for computing y from x and y   */
static fix31   x_scan;             /* used to round entrys going into mult tables */

/* Compound character transformation data */
static fix15  no_comp_x_edges;
static fix31  comp_x_edge_tbl[MAX_ZONES_PER_COMP_DIM];
static fix31  comp_x_pixel_tbl[MAX_ZONES_PER_COMP_DIM];

/* Lookup table for constraint function constants */
static real   set_exp[8] = {1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001, 0.000001, 0.0000001};
static real   neg_exp[8];

FUNCTION reset_trans()

/*  Called by fw_reset() to reset plaid interpreter.
 */

{
cache_undef = TRUE;
}

FUNCTION void init_trans(compc)
comp_char_desc  *compc;     /* Pointer to scan conversion parameters structure */

/*  Called by convert.c to set or change font specifications for transformation 
 *  generation.
 *  compc -- pointer to structure containing scan conversion parameters.
 *   ->compf -- compressed font data structure
 *   ->point_size_x -- x point size
 *   ->point_size_y -- y point size
 *   ->res_hor -- horizontal pixels per inch
 *   ->res_ver -- vertical pixels per inch
 *   ->rot_angle -- rotation angle in degrees (clockwise)
 *   ->obl_angle -- obliquing angle in degrees (clockwise)
 *   ->whitewrite -- if true, generate bitmaps for whitewriters
 *   ->thresh -- scan-conversion threshold
 *   ->import_widths -- if true, use external width table
 *   ->clip.left -- clips min x at left of emsquare
 *   ->clip.right -- clips max x at right of emsquare
 *   ->clip.bottom -- clips min x at bottom of emsquare
 *   ->clip.top -- clips max x at top of emsquare
 *   ->squeeze.left -- squeezes min x at left of emsquare
 *   ->squeeze.right, .top, .bottom  &c
 *   ->sw_fixed -- if TRUE, match pixel widths to scaled outline widths
 *   ->bogus_mode -- ignore plaid data if TRUE
 *
 *  Clears cache if any parameter has changed to invalidate cached data.
 */

{
real x, y;
real norm_rot();
real norm_obl();
fix15     x_oru_min;        /* Min value of X in oru coords */
fix15     x_oru_max;        /* Max value of X in oru coords */
fix15     y_oru_min;        /* Min value of Y in oru coords */
fix15     y_oru_max;        /* Max value of Y in oru coords */
fix15     x_fpxl;           /* X in pixel coords */
fix15     y_fpxl;           /* Y in pixel coords */
fix15     x_fpxl_min;       /* Min value of X in pixel coords */
fix15     x_fpxl_max;       /* Max value of X in pixel coords */
fix15     y_fpxl_min;       /* Min value of Y in pixel coords */
fix15     y_fpxl_max;       /* Max value of Y in pixel coords */
fix15     pix_max, i;
real      real_x_ppem;
real      real_y_ppem;
fix31     pix_add_one;      /* fixed point number used to set pix variables */
                            /* later cast to real pix_acc */
                                                       
cfontp = compc->compf;
point_size_x = compc->point_size_x;
point_size_y = compc->point_size_y;
res_hor = compc->res_hor;
res_ver = compc->res_ver;
rot_angle = norm_rot(compc->rot_angle);
obl_angle = norm_obl(compc->obl_angle);
sw_fixed = TRUE;
change_scale = FALSE;
bogus_mode = compc->bogus_mode;


/*****************************/

#ifdef RULESDBG
print_trans_data = TRUE;                /* debugging switch */
#endif

/****************************/

outlres = (real) cfontp->fonthead.resl_per_em;
fix_outlres = (fix31)floor(outlres + 0.5); /* fixed point version on outline resolution */
fix_otlres_div_2 = fix_outlres >> 1;

bot_edge = (fix15)floor(EM_BOT * (outlres / 8640.0) + 0.5);
top_edge = (fix15)floor(EM_TOP * (outlres / 8640.0) + 0.5);
x_distortion = point_size_x / point_size_y;
pixperoru_h = point_size_y * res_hor / (PTPERINCH * outlres);   /* this is NOT a bug */
pixperoru_v = point_size_y * res_ver / (PTPERINCH * outlres);
if (rot_angle == 0.0)
    {
    sinrot = 0.0;
    cosrot = 1.0;
    pixperoru_x = (point_size_x * res_hor) / (PTPERINCH * outlres);
    }
else
    {
    sinrot = sin(rot_angle * PI / 180.);
    cosrot = cos(rot_angle * PI / 180.);
    x = res_hor * cosrot;
    y = res_ver * sinrot;
    pixperoru_x = (point_size_x / (PTPERINCH * outlres)) * sqrt(x * x + y * y);
    }
if (obl_angle == 0.0)
    tanobl = 0.0;
else
    tanobl = tan(obl_angle * PI / 180.);

a_mult_x = (fix31)floor(cosrot * x_distortion * pixperoru_h * d65536 + 0.5);
b_mult_x = (fix31)floor((sinrot + cosrot * tanobl) * pixperoru_h * d65536 + 0.5);
a_mult_y = (fix31)floor(-sinrot * x_distortion * pixperoru_v * d65536 + 0.5);
b_mult_y = (fix31)floor((cosrot - sinrot * tanobl) * pixperoru_v * d65536 + 0.5);
                

x_oru_min = (fix15)cfontp->fonthead.extent_x_min;   /* get fontwide extents */
x_oru_max = (fix15)cfontp->fonthead.extent_x_max;
y_oru_min = (fix15)cfontp->fonthead.extent_y_min;
y_oru_max = (fix15)cfontp->fonthead.extent_y_max;

do_comp_xy_trans(x_oru_min, y_oru_min, &x_fpxl_min, &y_fpxl_min); /* convert extents into */
do_comp_xy_trans(x_oru_max, y_oru_max, &x_fpxl_max, &y_fpxl_max); /* pixel space multiplied by 8 */

x_fpxl_min = ABS(x_fpxl_min);  /* get absolute value of extents in pixel space */
x_fpxl_max = ABS(x_fpxl_max);
y_fpxl_min = ABS(y_fpxl_min);
y_fpxl_max = ABS(y_fpxl_max);
                
/* find maximum extent */
if ((x_fpxl_max >= x_fpxl_min) && (x_fpxl_max >= y_fpxl_max) && (x_fpxl_max >= y_fpxl_min))
    pix_max = x_fpxl_max;
else if ((y_fpxl_max >= y_fpxl_min) && (y_fpxl_max >= x_fpxl_min))
    pix_max = y_fpxl_max;
else if (x_fpxl_min >= y_fpxl_min)
    pix_max = x_fpxl_min;
else
    pix_max = y_fpxl_min;

pix_max >>= 3;
                         
/* find bit position of highest digit and use the next higher bit for safety factor */
/* max bit positon of 12, as maximum character can be 2 to the 12th or 4096 pixels big */     
for (i = 2; i < 13; i++)
    {
    pix_max >>= 1;
    if (pix_max == 0) 
        break;
    }           
                   
save_shift = pix_shift = 31 - i;     /* subtract bit position from 31 to fix point in fix31 variables */
pix_add_one = ((fix31) 1) << pix_shift;  /* pix_add_one is the multiplier */ 
pix_acc = (real) pix_add_one;           /* pix_acc is the floating point multiplier */
pix_round = (pix_add_one >> 1) + fix_otlres_div_2; /* round up compensated for later divisions */
pix_round_down = (fix31) (pix_acc * 0.499); /* round down */
pix_add_25 = pix_add_one >> 2; /* round with threshold of .25 in fixed point space */
pix_add_75 = pix_round + pix_add_25; /* round with threshold of .75 in fixed point space */
dpt5 = 0.5 + ((real) fix_otlres_div_2 / pix_acc); /* round up for real (non fixed point space) */
                                                    /* compensated for divisions */

setup_funct(pix_acc, pix_shift, pix_round, pix_add_75, pix_add_25, dpt5); /* setup statics in do_funct.c */

for (i = 0; i < 7; i++) /* setup neg_exp numbers in fixed point space */
    neg_exp[i] = set_exp[i] * pix_acc;

if (bogus_mode)                       /* Ignore plaid data? */
    {
    x_zone_data_valid = FALSE;
    x_trans_case = 2;

    y_zone_data_valid = FALSE;
    y_trans_case = 2;
    }

else if (rot_angle == 0.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_hor * pix_acc / PTPERINCH + 0.5);
    y_pixels_per_em = (fix31)floor(point_size_y * res_ver * pix_acc / PTPERINCH + 0.5);

    if (obl_angle == 0.0)
        {
        x_zone_data_valid = TRUE;
        x_trans_case = 0;
        x_trans_dir = 1;
        }
    else
        {
        x_zone_data_valid = FALSE;
        x_trans_case = 2;
        }

    y_zone_data_valid = TRUE;
    y_trans_case = 0;
    y_trans_dir = 1;
    }

else if ((rot_angle + obl_angle) == 0.0  ||  (rot_angle + obl_angle) == 360.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_hor * ABS(cosrot) * pix_acc / PTPERINCH + 0.5);
    pixperoru_x *= ABS(cosrot);
    y_pixels_per_em = (fix31)floor(point_size_y * res_ver * pix_acc / PTPERINCH + 0.5);

    x_zone_data_valid = TRUE;
    x_trans_case = 0;
    x_trans_dir = 1;

    y_zone_data_valid = FALSE;
    y_trans_case = 2;
    }

else if (rot_angle == 90.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_ver * pix_acc / PTPERINCH + 0.5);
    y_pixels_per_em = (fix31)floor(point_size_y * res_hor * pix_acc / PTPERINCH + 0.5);

    y_zone_data_valid = TRUE;
    x_trans_case = 1;
    x_trans_dir = 1;

    if (obl_angle == 0.0)
        {
        x_zone_data_valid = TRUE;
        y_trans_case = 1;
        y_trans_dir = -1;
        }
    else
        {
        x_zone_data_valid = FALSE;
        y_trans_case = 2;
        }
    }

else if ((rot_angle + obl_angle) == 90.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_ver * ABS(sinrot) * pix_acc / PTPERINCH + 0.5);
    pixperoru_x *= ABS(sinrot);
    y_pixels_per_em = (fix31)floor(point_size_y * res_hor * pix_acc / PTPERINCH + 0.5);

    y_zone_data_valid = FALSE;
    x_trans_case = 2;

    x_zone_data_valid = TRUE;
    y_trans_case = 1;
    y_trans_dir = -1;
    }

else if (rot_angle == 180.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_hor * pix_acc / PTPERINCH + 0.5);
    y_pixels_per_em = (fix31)floor(point_size_y * res_ver * pix_acc / PTPERINCH + 0.5);

    if (obl_angle == 0.0)
        {
        x_zone_data_valid = TRUE;
        x_trans_case = 0;
        x_trans_dir = -1;
        }
    else
        {
        x_zone_data_valid = FALSE;
        x_trans_case = 2;
        }

    y_zone_data_valid = TRUE;
    y_trans_case = 0;
    y_trans_dir = -1;
    }

else if ((rot_angle + obl_angle) == 180.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_hor * ABS(cosrot) * pix_acc / PTPERINCH + 0.5);
    pixperoru_x *= ABS(cosrot);
    y_pixels_per_em = (fix31)floor(point_size_y * res_ver * pix_acc / PTPERINCH + 0.5);

    x_zone_data_valid = TRUE;
    x_trans_case = 0;
    x_trans_dir = -1;

    y_zone_data_valid = FALSE;
    y_trans_case = 2;
    }

else if (rot_angle == 270.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_ver * pix_acc / PTPERINCH + 0.5);
    y_pixels_per_em = (fix31)floor(point_size_y * res_hor * pix_acc / PTPERINCH + 0.5);

    y_zone_data_valid = TRUE;
    x_trans_case = 1;
    x_trans_dir = -1;

    if (obl_angle == 0.0)
        {
        x_zone_data_valid = TRUE;
        y_trans_case = 1;
        y_trans_dir = 1;
        }
    else
        {
        x_zone_data_valid = FALSE;
        y_trans_case = 2;
        }
    }

else if ((rot_angle + obl_angle) == 270.0)
    {
    x_pixels_per_em = (fix31)floor(point_size_x * res_ver * ABS(sinrot) * pix_acc / PTPERINCH + 0.5);
    pixperoru_x *= ABS(sinrot);
    y_pixels_per_em = (fix31)floor(point_size_y * res_hor * pix_acc / PTPERINCH + 0.5);

    y_zone_data_valid = FALSE;
    x_trans_case = 2;

    x_zone_data_valid = TRUE;
    y_trans_case = 1;
    y_trans_dir = 1;
    }
else
    {
    x_zone_data_valid = FALSE;
    x_trans_case = 2;

    y_zone_data_valid = FALSE;
    y_trans_case = 2;
    }

save_x_pixels = x_pixels_per_em;
save_y_pixels = y_pixels_per_em;

hi_x_pxls_per_em = (x_pixels_per_em & 0xffff0000) >> 12; /* x_pixels_per_em and y_pixels_per_em are */
hi_y_pxls_per_em = (y_pixels_per_em & 0xffff0000) >> 12; /* multiplied by a 12 bit accuracy scale variable */
lo_x_pxls_per_em = x_pixels_per_em & 0x0000ffff;         /* To do this x_pixels_per_em and y_pixels_per_em */
lo_y_pxls_per_em = y_pixels_per_em & 0x0000ffff;         /* are split in to high and low parts, multiplied */
                                                         /* separately and shifted appropriately and added */
                                                         /* together. This avoids overflow problems and */
                                                         /* allows integer multiplies and later integer */
                                                         /* divisions */ 
real_x_ppem =  (real) x_pixels_per_em / pix_acc;
real_y_ppem =  (real) y_pixels_per_em / pix_acc;
if (cache_undef)                                                                          
    {
    clear_cache();
    cache_font_id[0] = cfontp->fonthead.src_font_id[0];
    cache_font_id[1] = cfontp->fonthead.src_font_id[1];
    cache_font_id[2] = cfontp->fonthead.src_font_id[2];
    cache_font_id[3] = cfontp->fonthead.src_font_id[3];
    cache_x_ppem = real_x_ppem;
    cache_y_ppem = real_y_ppem;
    cache_undef = FALSE;
    return;
    }

if ((cfontp->fonthead.src_font_id[0] != cache_font_id[0]) ||
    (cfontp->fonthead.src_font_id[1] != cache_font_id[1]) ||
    (cfontp->fonthead.src_font_id[2] != cache_font_id[2]) ||
    (cfontp->fonthead.src_font_id[3] != cache_font_id[3])) /* Font change? */
    {
    clear_cache();
    cache_font_id[0] = cfontp->fonthead.src_font_id[0];
    cache_font_id[1] = cfontp->fonthead.src_font_id[1];
    cache_font_id[2] = cfontp->fonthead.src_font_id[2];
    cache_font_id[3] = cfontp->fonthead.src_font_id[3];
    cache_x_ppem = real_x_ppem;
    cache_y_ppem = real_y_ppem;
    return;
    }

if (x_zone_data_valid)                        /* X size change? */
    {
    if (ABS (real_x_ppem - cache_x_ppem) > .01)  
        {                                                           
        clear_x_cache();                      /* Clear cached data in X */
        cache_x_ppem = real_x_ppem;           /* Update main cache scale */
        }
    }

if (y_zone_data_valid)                        /* Y size change? */
    {
    if (ABS (real_y_ppem - cache_y_ppem) > .01)
        {
        clear_y_cache();                      /* Clear cached data in y */
        cache_y_ppem = real_y_ppem;           /* Update main cache scale */
        }
    }


}


FUNCTION  real  norm_rot (angle)
real      angle;       /* Rotation angle to be normalized */

/*  Normalizes rotation angle to a value between 0 and 360 degrees
 *  Returns the normalized rotation angle.
 */

    DECLARE
    BEGIN
    while (TRUE)
        {
        if (angle < 0.)
            angle += 360.;
        else if (angle >= 360.)
            angle -= 360.;
        else  break;
        }
    return (angle);
    END

FUNCTION  real  norm_obl (angle)
real      angle;       /* Obliquing angle to be normalized */

/*  First normalizes obliquing angle to a value between -90 and 90 degrees
 *  Then limits absolute values to less than 85 degrees.
 *  Returns the normalized obliquing angle.
 */

    DECLARE
    BEGIN
    while (TRUE)
        {
        if (angle <= -90.)
            angle += 180.;
        else if (angle > 90.)
            angle -= 180.;
        else  break;
        }
    if (angle > 85.)  angle = 85.;
    if (angle < -85.)  angle = -85.;
    return (angle);
    END

FUNCTION setup_comp_trans(root_char)
ufix16 root_char;      /* Root character to be scan converted */

/*  Called by fw_make_char() once per character to initialize the compound 
 *  transformation function.                                                   
 */

{
no_comp_x_edges = 0;
}

FUNCTION void setup_trans(no_char, scale_x_nom, scale_y_nom,
   scale_x, scale_y, scale_x_adj, scale_y_adj, pos_x, pos_y, rules_round)
ufix16  no_char;       /* Character or subcharacter to be transformed */
ufix16  scale_x_nom;   /* Nominal X scale factor (relative to full size) */
ufix16  scale_y_nom;   /* Nominal Y scale factor (relative to full size) */
ufix16  scale_x;       /* Actual X scale factor (relative to full size) */
ufix16  scale_y;       /* Actual Y scale factor (relative to full size) */
boolean scale_x_adj;   /* TRUE if actual and nominal X scale factors differ */
boolean scale_y_adj;   /* TRUE if actual and nominal Y scale factors differ */
fix15   pos_x;         /* X position in outline resolution units */
fix15   pos_y;         /* Y position in outline resolution units */
fix31   rules_round;

/*  Called by fw_make_char() at the start of the first curve in the           
 *  outline data for the root character and all sub_characters.                
 *  Sets up transformation data for specified scale factors and offsets in     
 *  both x and y using current values of point size in x and y, horizontal     
 *  and vertical resolution, rotation angle and obliquing angle.               
 */

{
fix15 n, i;
boolean alloc_pixels();
fix31 pix_add_one, scale_max;
real  temp_x_pixels;
real  temp_y_pixels;

char_no = no_char;
x_scale_nom = (fix31) scale_x_nom;
y_scale_nom = (fix31) scale_y_nom;
x_scale = (fix31) scale_x;
y_scale = (fix31) scale_y;
x_scale_adj = scale_x_adj;
y_scale_adj = scale_y_adj;
x_pos = (fix31) pos_x;
y_pos = (fix31) pos_y;
x_scan = rules_round;

#ifdef RULESDBG
if (print_trans_data)
    printf("\nTransformation data for char %d\n", char_no);
#endif
 
#if SCALE_1_PLUS
if ((x_scale_nom > 4096) || (y_scale_nom > 4096) || 
    (x_scale > 4096) || (y_scale > 4096))
    {                 
    clear_cache();
    if ((x_scale >= x_scale_nom) && (x_scale >= y_scale_nom) && (x_scale >= y_scale))
        scale_max = x_scale;
    else if ((y_scale >= y_scale_nom) && (y_scale >= x_scale_nom))
        scale_max = y_scale;
    else if (x_scale_nom >= y_scale_nom)
        scale_max = x_scale_nom;
    else
        scale_max = y_scale_nom;
                         
    scale_max >>= 12;

    for (i = 1; i < 5; i++)
        {
        scale_max >>= 1;
        if (scale_max == 0) 
            break;
        }           

    temp_x_pixels = (real)x_pixels_per_em / pix_acc;
    temp_y_pixels = (real) y_pixels_per_em / pix_acc;
                   
    save_shift -= i;     /* subtract bit position from 31 to fix point in fix31 variables */
    pix_add_one = ((fix31) 1) << pix_shift;  /* pix_add_one is the multiplier */ 
    pix_acc = (real) pix_add_one;           /* pix_acc is the floating point multiplier */
    pix_round = (pix_add_one >> 1) + fix_otlres_div_2; /* round up compensated for later divisions */
    pix_round_down = (fix31) (pix_acc * 0.499); /* round down */
    pix_add_25 = pix_add_one >> 2; /* round with threshold of .25 in fixed point space */
    pix_add_75 = pix_round + pix_add_25; /* round with threshold of .75 in fixed point space */
    dpt5 = 0.5 + ((real) fix_otlres_div_2 / pix_acc); /* round up for real (non fixed point space) */
                                                    /* compensated for divisions */

    setup_funct(pix_acc, pix_shift, pix_round, pix_add_75, pix_add_25, dpt5); /* setup statics in do_funct.c */

    for (i = 0; i < 7; i++) /* setup neg_exp numbers in fixed point space */
        neg_exp[i] = set_exp[i] * pix_acc;
                    
    x_pixels_per_em = (fix31) ((temp_x_pixels * pix_acc) + 0.5);
    y_pixels_per_em = (fix31) ((temp_y_pixels * pix_acc) + 0.5);
    hi_x_pxls_per_em = (x_pixels_per_em & 0xffff0000) >> 12; /* x_pixels_per_em and y_pixels_per_em are */
    hi_y_pxls_per_em = (y_pixels_per_em & 0xffff0000) >> 12; /* multiplied by a 12 bit accuracy scale variable */
    lo_x_pxls_per_em = x_pixels_per_em & 0x0000ffff;         /* To do this x_pixels_per_em and y_pixels_per_em */
    lo_y_pxls_per_em = y_pixels_per_em & 0x0000ffff;         /* are split in to high and low parts, multiplied */
                                                             /* separately and shifted appropriately and added */
                                                             /* together. This avoids overflow problems and */
                                                             /* allows integer multiplies and later integer */
                                                             /* divisions */
    change_scale = TRUE;
    }
else if (change_scale)
    {             
    clear_cache();
    pix_shift = save_shift;
    pix_add_one = ((fix31) 1) << pix_shift;  /* pix_add_one is the multiplier */ 
    pix_acc = (real) pix_add_one;           /* pix_acc is the floating point multiplier */
    pix_round = (pix_add_one >> 1) + fix_otlres_div_2; /* round up compensated for later divisions */
    pix_round_down = (fix31) (pix_acc * 0.499); /* round down */
    pix_add_25 = pix_add_one >> 2; /* round with threshold of .25 in fixed point space */
    pix_add_75 = pix_round + pix_add_25; /* round with threshold of .75 in fixed point space */
    dpt5 = 0.5 + ((real) fix_otlres_div_2 / pix_acc); /* round up for real (non fixed point space) */
                                                    /* compensated for divisions */

    setup_funct(pix_acc, pix_shift, pix_round, pix_add_75, pix_add_25, dpt5); /* setup statics in do_funct.c */

    for (i = 0; i < 7; i++) /* setup neg_exp numbers in fixed point space */
        neg_exp[i] = set_exp[i] * pix_acc;

    x_pixels_per_em = save_x_pixels;
    y_pixels_per_em = save_y_pixels;
    hi_x_pxls_per_em = (x_pixels_per_em & 0xffff0000) >> 12;
    hi_y_pxls_per_em = (y_pixels_per_em & 0xffff0000) >> 12;
    lo_x_pxls_per_em = x_pixels_per_em & 0x0000ffff;        
    lo_y_pxls_per_em = y_pixels_per_em & 0x0000ffff;        
    change_scale = FALSE;
    }
#endif
switch(x_trans_case)
    {
case 0:                       /* Xp = f(x) */
    cache_select(X_DIMENSION, x_scale_nom);     /* select full size or scaled cache */
    if (!alloc_pixels(char_no, X_DIMENSION))    /* alloc returns FALSE if cache overflow */
        {
        if (!alloc_pixels(char_no, X_DIMENSION)) /* Cache must have been flushed, this can't happen twice */
            {
            report_error (ERROR,ER_X_CHE_OVR_TWICE_XCSE0,TRUE,"");
            goto x_linear;
            }
        }
    make_edge_list(char_no, X_DIMENSION, &n);
    make_x_trans_list (n, x_trans_dir, x_orus, x_pixels);
    make_trans_table (x_pixels_per_em, x_scale, x_pos, x_trans_dir, x_orus,
                      x_pixels, n, x_mult_tbl, x_offset_tbl, &no_xx_transforms);
    x_i = no_xx_transforms >> 1;
    no_xy_transforms = -1;
    break;

case 1:                       /* Xp = f(y) */
    cache_select(Y_DIMENSION, y_scale_nom);
    if (!alloc_pixels(char_no, Y_DIMENSION))
        {
        if (!alloc_pixels(char_no, Y_DIMENSION))
            {
            report_error (ERROR,ER_Y_CHE_OVR_TWICE_XCSE1,TRUE,"");
            goto x_linear;
            }
        }
    make_edge_list(char_no, Y_DIMENSION, &n);
    make_y_trans_list (n, x_trans_dir, x_orus, x_pixels);
    make_trans_table (y_pixels_per_em, y_scale, y_pos, x_trans_dir, x_orus,
                      x_pixels, n, x_mult_tbl, x_offset_tbl, &no_xy_transforms);
    x_i = no_xy_transforms >> 1;
    no_xx_transforms = -1;
    break;

x_linear:
case 2:                       /* Xp = f(x, y) */
default:
    xx_mult = (fix31)floor(cosrot * x_distortion * (real) x_scale * pixperoru_h * 16.0 + 0.5);
    xy_mult = (fix31)floor((sinrot + cosrot * tanobl) * (real) y_scale * pixperoru_h * 16.0 + 0.5);
    x_offset = (fix31)floor(((real) x_pos * cosrot * x_distortion +
                   (real) y_pos * (sinrot + cosrot * tanobl)) * pixperoru_h * d65536 + (real) x_scan + 0.5);
    no_xx_transforms = -1;
    no_xy_transforms = -1;
    break;

    }

#ifdef RULESDBG
    print_x_trans_data();
#endif

switch(y_trans_case)
    {
case 0:                       /* Yp = f(y) */
    cache_select(Y_DIMENSION, y_scale_nom);
    if (!alloc_pixels(char_no, Y_DIMENSION))
        {
        if (!alloc_pixels(char_no, Y_DIMENSION))
            {
            report_error (ERROR,ER_Y_CHE_OVR_TWICE_YCSE0,TRUE,"");
            goto y_linear;
            }
        }
    make_edge_list(char_no, Y_DIMENSION, &n);
    make_y_trans_list (n, y_trans_dir, y_orus, y_pixels);
    make_trans_table (y_pixels_per_em, y_scale, y_pos, y_trans_dir, y_orus,
                      y_pixels, n, y_mult_tbl, y_offset_tbl, &no_yy_transforms);
    y_i = no_yy_transforms >> 1;
    no_yx_transforms = -1;
    break;

case 1:                       /* Yp = f(x) */
    cache_select(X_DIMENSION, x_scale_nom);
    if (!alloc_pixels(char_no, X_DIMENSION))
        {
        if (!alloc_pixels(char_no, X_DIMENSION))
            {
			report_error (ERROR,ER_X_CHE_OVR_TWICE_YCSE1,TRUE,"");
            goto y_linear;
            }
        }
    make_edge_list(char_no, X_DIMENSION, &n);
    make_x_trans_list (n, y_trans_dir, y_orus, y_pixels);
    make_trans_table (x_pixels_per_em, x_scale, x_pos, y_trans_dir, y_orus,
                      y_pixels, n, y_mult_tbl, y_offset_tbl, &no_yx_transforms);
    y_i = no_yx_transforms >> 1;
    no_yy_transforms = -1;
    break;

y_linear:
case 2:
default:                      /* Yp = f(x, y) */
    yx_mult = (fix31)floor(-sinrot * x_distortion * (real) x_scale * pixperoru_v * 16.0 + 0.5);
    yy_mult = (fix31)floor((cosrot - sinrot * tanobl) * (real) y_scale * pixperoru_v * 16.0 + 0.5);
    y_offset = (fix31)floor(((real) y_pos * (cosrot - sinrot * tanobl) -
                   (real) x_pos * sinrot * x_distortion) * pixperoru_v * d65536 + (real) x_scan + 0.5);
    no_yx_transforms = -1;
    no_yy_transforms = -1;
    break;

    }

#ifdef RULESDBG
    print_y_trans_data();
#endif
}

FUNCTION static boolean alloc_pixels(char_num, dimension)
ufix16    char_num;    /* Character number */
fix15  dimension;      /* Dimension */

/*  Called by setup_..._trans to compute and cache the pixel allocations for
 *  all zones in the specified dimension of the specified character.
 *  Returns TRUE if sufficient cache capacity to complete pixel allocation.
 *  If cache overflow occurs, the cache is cleared together with the cache
 *  overflow flag and FALSE is returned.                                     
 */

{
fix15   to, from;
ufix16  flags;
ufix16 *pfunct;
fix15   base_orus; 
fix31   base_pixels;
fix31   fpixels_in_zone;
fix15   pixels_available, pixels_in_zone;
fix15   orus_in_zone, orus_available;
fix15   queue[32];
fix15   queue_put, queue_get;
fix15   i, no_zones;
fix15   more_zones;

fix15   get_pixels();
boolean cache_data();

cache_overflow = FALSE;       /* Initialize cache overflow flag */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec)) /* Ensure data in cache */
    {
    clear_cache();            /* Clear cache */
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
    if (x_scale_adj)
        clr_pxls_cache(char_num, dimension);
    if (x_scale == 4096) /* if scale is equal to 4096 (= 1 with 12 bit accuracy) don't multiply */
        base_pixels = x_pixels_per_em;
    else
        base_pixels = (hi_x_pxls_per_em * x_scale) + (((lo_x_pxls_per_em * x_scale) + 2048) >> 12);
    }
else
    {
    if (y_scale_adj)
        clr_pxls_cache(char_num, dimension);
    if (y_scale == 4096) /* if scale is equal to 4096 (= 1 with 12 bit accuracy) don't multiply */
        base_pixels = y_pixels_per_em;
    else
        base_pixels = (hi_y_pxls_per_em * y_scale) + (((lo_y_pxls_per_em * y_scale) + 2048) >> 12);
    }
base_orus = fix_outlres;
fpixels_in_zone = orus_in_zone * (base_pixels / base_orus);
cache_fpixels(char_num, dimension, 0, fpixels_in_zone);
pixels_in_zone = get_pixels(char_num, dimension, 0);
if (cache_overflow)
    {
    clear_cache();
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
           (sw_fixed || (dimension != X_DIMENSION))) /* New level? */
            {
            base_pixels = (fix31) pixels_available << pix_shift;
            base_orus = orus_available;
            }
        if (orus_in_zone == 0)
            fpixels_in_zone = 0;
        else
            fpixels_in_zone = orus_in_zone * (base_pixels / base_orus);
        cache_fpixels(char_num, dimension, i, fpixels_in_zone);
        pixels_in_zone = get_pixels(char_num, dimension, i);
        if (cache_overflow)              /* Cache overflow? */
            {
            clear_cache();
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
    report_error (ERROR,ER_NOT_ALL_ZONES_PROCESSED,TRUE,"");
    }

return(TRUE);
}


FUNCTION static fix15 get_pixels(char_num, dimension, zone_no)
ufix16 char_num;       /* Character number */
fix15 dimension;       /* Dimension */
fix15 zone_no;         /* Zone number */

/*  Called by alloc_pixels(), get_pixels() and get_fpixels() to calculate the
 *  integral number of pixels allocated to the specified zone in the specified
 *  dimension of the specified character.
 *  Returns the number of pixels allocated.
 *  Sets cache_overflow TRUE if cache overflow occurs.                       
 */

{
fix31   pixls;
fix15   min_pixels;                                   
fix15   c_pixls;
fix15   total_pixls;
real   *stack_pointer;            
fix31   fixed_pixels;
fix31   frac;
real    fpixels;
real    fconst;
real    stack[10];
fix15   from, to;
ufix16  type, x, y, z;
ufix16  flags, fn_flag;
ufix16 *pfunct;
real    arg1;
real    arg2;
real    pixels_other;
real    fpixels_self;
real    threshold;
real    diff;

boolean cache_data();
boolean cached_pixels();
fix     get_cache_data();
fix31   get_fpixels();
fix31   get_tpixels();


/* Check if pixels previously calculated for specified zone */
if (cached_pixels(char_num, dimension, zone_no, &c_pixls))
    {
    return(c_pixls);
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
    fixed_pixels = get_fpixels(char_num, dimension, zone_no);  /* Get unrounded value for pixels */
                                                               /* in fixed point space */
    if (zone_no != 0)                                    /* Not root zone? */
        {
        pixls = (fixed_pixels + pix_round) >> pix_shift;                           /* Round to nearest whole number of pixels */
        }
    else
        {
        pixls = (fixed_pixels + pix_round_down) >> pix_shift;                         /* Prefer to round down for root zone */
        }
    }
else                                        
    {
    stack_pointer = stack;                               /* Initialize function execution stack pointer */
    while(fn_flag)
        {
        if (fn_flag == FN_ONE_ITEM)                      /* One item in constraint function? */
            fn_flag = 0;                                 /* Exit after one cycle */

        get_c_item(&pfunct, &type, &x, &y, &z);          /* Read next function item */
        switch (type)
            {
        case 1:                                          /* P item? */
            if (y)                                       /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    if (y_zone_data_valid)               /* Plaid valid in other dimension? */
                        {
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        pixls = get_pixels(x, Y_DIMENSION, z);
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        pixls = (pixls * (real) x_pixels_per_em * (real) x_scale_nom) /
                            ((real) y_pixels_per_em * (real) y_scale_nom) +
                            0.5;
                        }
                    else
                        {
                        get_cache_data(x, Y_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_x_pxls_per_em * x_scale_nom + (((lo_x_pxls_per_em * x_scale_nom) + 2048) >> 12);
                        pixls = (to - from) * (frac / fix_outlres);
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    if (x_zone_data_valid)               /* Plaid valid in other dimension? */
                        {
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        pixls = get_pixels(x, X_DIMENSION, z);
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        pixls = (pixls * (real) y_pixels_per_em * (real) y_scale_nom) /
                            ((real) x_pixels_per_em * (real) x_scale_nom) +
                            0.5;
                        }
                    else                                 /* Plaid not valid in other dimension? */
                        {
                        get_cache_data(x, X_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_y_pxls_per_em * y_scale_nom + (((lo_y_pxls_per_em * y_scale_nom) + 2048) >> 12);
                        pixls = (to - from) * (frac / fix_outlres);
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                pixls = (fix31) get_pixels(x, dimension, z);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = pixls << pix_shift;            /* Push rounded pixels onto execution stack */
            continue;

        case 2:                                          /* F item? */
            if (y)                                       /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    if (y_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        fpixels = (real) get_fpixels(x, Y_DIMENSION, z);
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        fpixels = fpixels * (real) x_pixels_per_em * (real) x_scale_nom /
                            ((real) y_pixels_per_em * (real) y_scale_nom);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(x, Y_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_x_pxls_per_em * x_scale_nom + (((lo_x_pxls_per_em * x_scale_nom) + 2048) >> 12);
                        fpixels = (to - from) * (frac / fix_outlres);
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    if (x_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        fpixels = (real) get_fpixels(x, X_DIMENSION, z);
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        fpixels = fpixels * (real) y_pixels_per_em * (real) y_scale_nom /
                            ((real) x_pixels_per_em * (real) x_scale_nom);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(x, X_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_y_pxls_per_em * y_scale_nom + (((lo_y_pxls_per_em * y_scale_nom) + 2048) >> 12);
                        fpixels = (to - from) * (frac / fix_outlres);
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                fpixels = (real) get_fpixels(x, dimension, z);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = fpixels;                /* Push unrounded pixels onto stack */
            continue;

        case 3:                                          /* T item? */
            if (y)                                       /* Zone refers to other dimension? */
                {
                if (dimension == X_DIMENSION)            /* This dimension is X? */
                    {
                    if (y_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        fpixels = (real) get_tpixels(x, Y_DIMENSION, z);
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        fpixels = (fpixels * (real) x_pixels_per_em * (real) x_scale_nom) /
                            ((real) y_pixels_per_em * (real) y_scale_nom);
                        }
                    else                                 /* Plaid data not valid in other dimension? */
                        {
                        get_cache_data(x, Y_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_x_pxls_per_em * x_scale_nom + (((lo_x_pxls_per_em * x_scale_nom) + 2048) >> 12);
                        fpixels = (to - from) * (frac / fix_outlres);
                        }
                    }
                else                                     /* This dimension is Y? */
                    {
                    if (x_zone_data_valid)               /* Plaid data valid in other dimension? */
                        {
                        cache_select(X_DIMENSION, (ufix16) x_scale_nom);
                        fpixels = (real) get_tpixels(x, X_DIMENSION, z);
                        cache_select(Y_DIMENSION, (ufix16) y_scale_nom);
                        fpixels = (fpixels * (real) y_pixels_per_em * (real) y_scale_nom) /
                            ((real) x_pixels_per_em * (real) x_scale_nom);
                        }
                    else
                        {
                        get_cache_data(x, X_DIMENSION, z, &from, &to, &flags, &pfunct);
                        frac = hi_y_pxls_per_em * y_scale_nom + (((lo_y_pxls_per_em * y_scale_nom) + 2048) >> 12);
                        fpixels = (to - from) * (frac / fix_outlres);
                        }
                    }
                }
            else                                         /* Zone refers to this dimension? */
                {
                fpixels = (real) get_tpixels(x, dimension, z);
                }
            if (cache_overflow)                          /* Cache overflow? */
                return(0);
            *(stack_pointer++) = fpixels;                /* Push unrounded pixels onto execution stack */
            continue;

        case 4:                                          /* Constant item? */ 
            fconst = x * neg_exp[y];
            *(stack_pointer++) = fconst;       /* Push constant onto stack */
            continue;                                         

        case 5:                                          /* Operator item? */
            if (y)                                       /* Terminating operator? */
                fn_flag = 0;                             /* Exit after this cycle */
            switch (x)
                {
            case 0:                                      /* NOP operator? */
                continue;

            case 1:                                      /* ADD operator? */
                arg2 = *(--(stack_pointer));
                arg1 = *(--(stack_pointer));
                *((stack_pointer)++) = arg1 + arg2;
                continue;
 
            case 2:                                      /* SUB operator? */
                arg2 = *(--(stack_pointer));
                arg1 = *(--(stack_pointer));
                *((stack_pointer)++) = arg1 - arg2;
                continue;

            case 3:                                      /* MUL operator? */
                arg2 = *(--(stack_pointer));
                arg1 = *(--(stack_pointer));
                *((stack_pointer)++) = (arg1 * arg2) / pix_acc; /* both args are multipled by pix_acc */
                continue;                                       /* so result must be divided by pix_acc */

            case 4:                                      /* DIV operator? */
                arg2 = *(--(stack_pointer));
                arg1 = *(--(stack_pointer));
                *((stack_pointer)++) = (arg1 / arg2) * pix_acc; /* division cancels accuracy so result */
                continue;                                       /* must be multiplied by pix_acc to restore */
                                                                /* accuracy */
            case 5:                                      /* PRINT operator? */
                continue;

            case 6:                                      /* FIXR operator? */
                arg1 = *(--(stack_pointer));       /* if argument less than 2 to the 31, operation can be */
                if (arg1 < TWO31)                  /* done with fixed point, else use reals */
                    arg1 = (real) (((((fix31) arg1) + pix_round) >> pix_shift) << pix_shift);
                else
                    arg1 = floor((arg1 / pix_acc) + dpt5) * pix_acc;
                *((stack_pointer)++) = arg1;
                continue;

            case 7:                                      /* FIX operator */
                arg1 = *(--(stack_pointer));
                if (arg1 < TWO31)
                    arg1 = (real) (((((fix31) arg1) + fix_otlres_div_2) >> pix_shift) << pix_shift);                      
                else
                    arg1 = floor(arg1 / pix_acc) * pix_acc;
                *((stack_pointer)++) = floor(arg1);
                continue;

            case 8:                                      /* CO operator? */
                pixels_other = *(--stack_pointer);
                fpixels_self = *(--stack_pointer);
                threshold = *(--stack_pointer);
                diff = fabs(fpixels_self - pixels_other) + fix_otlres_div_2;
                if (diff < threshold)
                    *(stack_pointer++) = pixels_other;
                else
                    {
                    if (fpixels_self < TWO31)
                        fpixels_self = (real) (((((fix31) fpixels_self) + pix_round) >> pix_shift) << pix_shift);
                    else
                        fpixels_self = floor((fpixels_self / pix_acc) + dpt5) * pix_acc;
                    *(stack_pointer++) = fpixels_self;
                    }
                continue;

            case 9:                                      /* CF operator? */
                do_cf(&stack_pointer);   /* Execute CF operator */
                continue;

            case 10:                                     /* RRFS operator? */
                do_rrfs(&stack_pointer);  /* Execute RRFS operator */
                continue;

            case 11:                                     /* RRHS operator? */
                do_rrhs(&stack_pointer);  /* Execute RRHS operator */
                continue;

            case 12:                                     /* RRFS1 operator? */
                do_rrfs1(&stack_pointer);       /* Execute RRFS1 operator */
                continue;

            case 13:                                     /* RRHS1 operator? */
                do_rrhs1(&stack_pointer);  /* Execute RRHS1 operator */
                continue;

            case 14:                                     /* BZON operator? */
                do_bzon(&stack_pointer); /* Execute BZON operator */
                continue;

            case 15:                                     /* BZON1 operator? */
                do_bzon1(&stack_pointer); /* Execute BZON1 operator */
                continue;                     

            case 16:                                     /* LZON operator? */
                do_lzon(&stack_pointer); /* Execute LZON operator */
                continue;

            case 17:                                     /* LZON1 operator? */
                do_lzon1(&stack_pointer); /* Execute LZON1 operator */
                continue;

            case 18:                                     /* CFFLB operator? */
                do_cfflb(&stack_pointer);       /* Execute CFFLB operator */
                continue;

            case 19:                                     /* CFFRB operator? */
                do_cffrb(&stack_pointer);       /* Execute CFFRB operator */
                continue;

            case 20:                                     /* CFSLB operator? */
                do_cfslb(&stack_pointer);       /* Execute CFSLB operator */
                continue;

            case 21:                                     /* CFSRB operator? */
                do_cfsrb(&stack_pointer);       /* Execute CFSRB operator */
                continue;

            case 22:                                     /* XHT_ADJ operator? */
                *(stack_pointer++) = pix_acc;            /* Execute XHT_ADJ operator */
                continue;

            default:
                report_error (ERROR,ER_UNDEFINED_OPERATOR,TRUE,"");
                continue;
                }
        default:
            report_error (ERROR,ER_UNDEFINED_FUNCTION_TYPE,TRUE,"");
            continue;
            }
        }                                                /* End of main while loop */ 
    /* pixls is in fixed point space so real division by pix_acc necessary to have result */
    /* pixel space */
    pixls = (fix31)floor((*(--stack_pointer)) / pix_acc + 0.5);        /* Pop top of stack for result */
    if (stack_pointer != stack)                          /* Stack now empty? */
        {
        report_error (ERROR,ER_DATA_LEFT_ON_STACK_AT_END,TRUE,"");
        }
    }
min_pixels = flags & MASK_MIN;
if ((fix15) pixls < min_pixels)                                  /* Result less than minimum? */
    pixls = min_pixels;                                  /* Use minimum for result */
cache_pixels(char_num, dimension, zone_no, (fix15) pixls);       /* Cache pixels */
return((fix15)pixls);                                                                   
}


FUNCTION static fix31 get_fpixels(char_num, dimension, zone_no)
ufix16 char_num;       /* Character offset */
fix15 dimension;       /* 0 if x zone, 1 if y zone */
fix15 zone_no;         /* Zone number */

/*  Returns the unrounded number of pixels allocated to the specified zone in 
 *  the specified character.                                                 
 *  Sets cache_overflow TRUE if cache overflow occurs.                        
 */

{
fix15 from, to;
ufix16 flags;
ufix16 *pfunct;
fix15 i;
boolean path_mask[MAX_ZONES_PER_DIM];
fix15 queue[32];
fix15 queue_put, queue_get;
fix15 orus_in_zone, orus_available;
fix15 base_orus;
fix31 base_pixels;
fix31 fpixels_in_zone;
fix15 pixels_available, pixels_in_zone;
fix15 more_zones;   
fix31 scale;
boolean cached_fpixels();
fix31   get_tpixels();
fix     get_cache_data();
boolean cache_data();

/* Check if fpixels previously calculated for specified zone */
if (cached_fpixels(char_num, dimension, zone_no, &fpixels_in_zone))
    {
    return(fpixels_in_zone);
    }

/* Check if set width unconstrained */
if (!sw_fixed && (dimension == X_DIMENSION)) 
    {
    return(get_tpixels(char_num, dimension, zone_no));
    }

/* Ensure that zone data is in the cache */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec))
    {
    cache_overflow = TRUE;
    return(0);
    }

/* Determine which zones need pixel values to be calculated */
make_path_mask(char_num, dimension, zone_no, path_mask);

/* Compute pixels in top level zone */
get_cache_data(char_num, dimension, 0, &from, &to, &flags, &pfunct);
orus_in_zone = to - from;
if (dimension == X_DIMENSION)
    {
    scale = (char_num == char_no) ? x_scale : x_scale_nom;
    if (scale == 4096)
        base_pixels = x_pixels_per_em;
    else
        base_pixels = (hi_x_pxls_per_em * scale) + (((lo_x_pxls_per_em * scale) + 2048) >> 12);
    }
else
    {
    scale = (char_num == char_no) ? y_scale : y_scale_nom;
    if (scale == 4096)
        base_pixels = y_pixels_per_em;
    else
        base_pixels = (hi_y_pxls_per_em * scale) + (((lo_y_pxls_per_em * scale) + 2048) >> 12);
    }
base_orus = fix_outlres;

fpixels_in_zone = orus_in_zone * (base_pixels / base_orus); /* Calculate unrounded pixels in root zone */

if (zone_no == 0)                                  /* Root zone is target zone? */
    {
    return(fpixels_in_zone);                       /* Return unrounded pixels in root zone */
    }
pixels_in_zone = get_pixels(char_num, dimension, 0);
if (cache_overflow)                                /* Cache overflow? */
    return(0);

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
            base_pixels = (fix31) pixels_available << pix_shift;
            base_orus = orus_available;
            }
        if (orus_in_zone == 0)
                fpixels_in_zone = 0;
            else
                fpixels_in_zone = orus_in_zone * (base_pixels / base_orus); /* Calculate unrounded pixels in zone */
        if (i == zone_no)                          /* Target zone? */
            {
            cache_fpixels(char_num, dimension, i, fpixels_in_zone); /* Save for possible future use */
            return(fpixels_in_zone);               /* Return unrounded number of pixels in target zone */
            }
        if (path_mask[i])                          /* This zone needs pixels calculated? */
            {
            cache_fpixels(char_num, dimension, i, fpixels_in_zone); /* Save for possible future use */
            pixels_in_zone = get_pixels(char_num, dimension, i); /* Calculate number of pixels in zone */
            if (cache_overflow)                    /* Cache overflow? */
                return(0);
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
report_error (ERROR,ER_QUEUE_OVERFLOW,TRUE,"");
return(0);
}


FUNCTION  make_path_mask (char_num, dimension, zone_no, mask)
ufix16 char_num;       /* Character number */
fix15 dimension;       /* 0 if x zone, 1 if y zone */
fix15 zone_no;         /* Zone number */
boolean mask[];        /* mask[i] is true if pixel value required for zone i */

/*  Finds a path from the root zone of the specified dimension of the specified
 *  character to the specified target zone.
 *  Each truth value in the updated mask array indicates if the number of pixels
 *  needs to be calculated for the corresponding zone in order to calculate
 *  the unrounded number of pixels in the target zone.
 *  The zone data for the specified dimension of the specified character is
 *  assumed to be in the cache.                                             
 */

{
fix15  i, j;
ufix16 queue_put, queue_get;
fix15  queue[32];
fix15  link[MAX_ZONES_PER_DIM];
fix15  prev_zone;
fix15  more_zones;
fix15  from, to;
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
report_error (ERROR,ER_QUEUE_OVERFLOW_MAKEPATH,TRUE,"");
return;
}


FUNCTION static fix31 get_tpixels(char_num, dimension, zone_no)
ufix16 char_num;       /* Character offset */
fix15 dimension;       /* 0 if x zone, 1 if y zone */
fix15 zone_no;         /* Zone number */

/*  Returns the number of pixels allocated to the specified zone in the 
 *  character whose root zone is at the specified character offset.  The rate of  
 *  exchange from outline resolution units to pixels is at the top level.        
 */

{
fix15 from, to;
ufix16 flags;
ufix16 *pfunct;
fix15 orus_in_zone;
fix15 base_orus;
fix31 base_pixels;
fix31 fpixels_in_zone;
boolean cache_data();

/* Ensure that zone data is in the cache */
if (!cache_data(char_num, dimension, cfontp, pfirst_rec))
    {
    cache_overflow = TRUE;
    return(0);
    }

get_cache_data(char_num, dimension, zone_no, &from, &to, &flags, &pfunct);
orus_in_zone = to - from;
base_orus = fix_outlres;
if (dimension == X_DIMENSION)
    {
    if (x_scale_nom == 4096)  /* if scale is equal to 4096 (= 1 with 12 bit accuracy) don't multiply */
        base_pixels = x_pixels_per_em;
    else
        base_pixels = (hi_x_pxls_per_em * x_scale_nom) 
                      + (((lo_x_pxls_per_em * x_scale_nom) + 2048) >> 12);
    }
else
    {
    if (y_scale_nom == 4096)  /* if scale is equal to 4096 (= 1 with 12 bit accuracy) don't multiply */
        base_pixels = y_pixels_per_em;
    else
        base_pixels = (hi_y_pxls_per_em * y_scale_nom) 
                      + (((lo_y_pxls_per_em * y_scale_nom) + 2048) >> 12);
    }
fpixels_in_zone = orus_in_zone * (base_pixels / base_orus);
return(fpixels_in_zone);               /* Return number of pixels in target zone */
}


FUNCTION static make_edge_list(char_num, dimension, pn)
ufix16 char_num;       /* Character number */
fix15 dimension;       /* 0 if X dimension, 1 if Y dimension */
fix15 *pn;             /* Number of edges in generated list */

/*  Called by setup_..._trans() to build a sorted list of zone edges and
 *  corresponding pixel allocations in edges[] and pixels[].
 *  Sets *pn to number of edges generated (zero if no zone data)      
 */

{
fix15   no_zones, i, j, n;
fix15   from, to, max_to;
ufix16  flags;
ufix16 *pfunct;
ufix16  start[2];
ufix16  temp_ufix16;
fix15   temp_fix15;
boolean flag;
boolean cached_pixels();

/* Make list of edges and associated number of pixels */
get_cache_no_zones(char_num, dimension, &no_zones);
if (no_zones == 0)         /* No zone data? */
    {
    *pn = 0;
    return;
    }

n = 0;
for (i = 0; i < no_zones; i++)
    {
    get_cache_data(char_num, dimension, i, &from, &to, &flags, &pfunct);
    if (i == 0)
        max_to = to;
    if ((flags & MASK_P_FLAG) == 0)       /* Not parent zone? */
        {
        edges[n] = from;
        if (!cached_pixels(char_num, dimension, i, &pixels[n]))
            report_error (ERROR,ER_DATA_NOT_IN_CACHE_MAKE_EDGE,TRUE,"");
        if (to > max_to)
            {
            max_to = to;
            }
        n++;
        }
    }

edges[n] = max_to;
*pn = n + 1;

/* Sort first n edges into ascending order (edge[n] is already in position) */
start[0] = (n & 0xfffe) - 1;
start[1] = (n - 1) & 0xfffe;
for (i = 0; TRUE; i++)
    {
    flag = TRUE;                       /* Flag order OK */
    for (j = start[i & 1]; j > 0; j -= 2)
        {
        if ((edges[j] < edges[j - 1]) || ((pixels[j] == 0) && (edges[j] == edges[j - 1])))
            {          
            temp_fix15 = edges[j];
            edges[j] = edges[j - 1];
            edges[j - 1] = temp_fix15;
            temp_ufix16 = pixels[j];
            pixels[j] = pixels[j - 1];
            pixels[j - 1] = temp_ufix16;
            flag = FALSE;              /* Flag order not OK */
            }
        }
    if (flag && (i > 0))               /* Finished if order OK and at least 2 cycles */
        break;
    }

#ifdef RULESDBG
flag = FALSE;
for (i = 1; i < *pn; i++)
    {
    if (edges[i] < edges[i - 1])
        {
        flag = TRUE;
        }
    }
if (flag)
    {
    printf("***** make_edge_list: incomplete sort\n");
    for (i = 0; i < *pn; i++)
        {
        printf("%d ", edges[i]);
        }
    printf("\n");
    }
#endif


if ((dimension == X_DIMENSION)? x_scale_adj: y_scale_adj)
    clr_pxls_cache(char_num, dimension);
}


FUNCTION static make_x_trans_list(n, direction, orus_tbl, pixels_tbl)
fix15 n;               /* Number of edges */
fix15 direction;       /* +1 indicated increasing pixel values, -1 decreasing values */
fix15 orus_tbl[];      /* Generated list of edge coordinates in outline resolution units */
fix15 pixels_tbl[];    /* Corresponding list of coordinates in pixel space */

/*  Called by setup_trans() to generate a list of outline
 *  X coordinates and their corresponding transformed pixel coordinates from
 *  edges[] and pixels[].                                                      
 */

{
fix15 i;
fix15 position;
fix31 fposition;
fix31 comp_edge;                                                       
fix31 frac, temp;
fix31 do_comp_x_trans();

if (n == 0)                    /* No zone data? */
    return;                    /* No transformation list needed */

/* Copy edge values into oru table */
for (i = 0; i < n; i++)
    {
    orus_tbl[i] = edges[i];
    }

/* Calculate pixel coordinate of first edge */
fposition = do_comp_x_trans(x_pos << 12, FALSE);
if (orus_tbl[0] >= 0)          /* First edge right of origin? */
    {                                               
    frac = ((hi_x_pxls_per_em * x_scale) + (((lo_x_pxls_per_em * x_scale) + 2048) >> 12))
              / fix_outlres;
    fposition += (orus_tbl[0] * frac);                     
    }
else                           /* First edge left of origin? */
    {
    for (i = 1; i < n; i++)    /* Look for first edge to right of origin */
        {
        fposition -= (fix31) pixels[i - 1] << pix_shift;
        if (orus_tbl[i] >= 0)
            break;
        }
    if (i < n)                 /* Positive edge value found */
        {
        fposition += (real)orus_tbl[i] * pixels[i - 1] * pix_acc /
                     (real)(orus_tbl[i] - orus_tbl[i - 1]);
        }
    else                       /* Positive edge value not found */
        {
        frac = ((hi_x_pxls_per_em * x_scale) + (((lo_x_pxls_per_em * x_scale) + 2048) >> 12))
                  / fix_outlres;
        fposition += (orus_tbl[n - 1] * frac);
        }
    }

position = (fix15) ((fposition + pix_round) >> pix_shift);
/* Assign absolute coordinates in pixel space and update compound trans table */
for (i = 0; i < n; i++)
    {
    pixels_tbl[i] = direction * position;
    comp_edge = ((fix31) orus_tbl[i] * (x_scale << 4)) + (x_pos << 16);
    if ((no_comp_x_edges == 0) ||       /* nothing in comp trans table? */
         ((fposition >= comp_x_pixel_tbl[no_comp_x_edges - 1]) &&
            (comp_edge > comp_x_edge_tbl[no_comp_x_edges - 1])))
        {
        comp_x_edge_tbl[no_comp_x_edges] = comp_edge;
        comp_x_pixel_tbl[no_comp_x_edges] = fposition;
        no_comp_x_edges++;
        }
    fposition += ((fix31) pixels[i]) << pix_shift;
    position += pixels[i];
    }
#ifdef RULESDBG
if (print_trans_data)
    {
    printf("Compound Transformation table\n");
    for (i = 0; i < no_comp_x_edges; i++)
        {
        printf("%10.2f %12.5f\n", (real) comp_x_edge_tbl[i] / d65536, (real) comp_x_pixel_tbl[i] / pix_acc);
        }
    }
#endif
}


FUNCTION static make_y_trans_list(n, direction, orus_tbl, pixels_tbl)
fix15 n;               /* Number of edges */
fix15 direction;       /* +1 indicated increasing pixel values, -1 decreasing values */
fix15 orus_tbl[];      /* Generated list of edge coordinates in outline resolution units */
fix15 pixels_tbl[];    /* Corresponding list of coordinates in pixel space */

/*  Called by setup_trans() to generate a list of outline
 *  Y coordinates and their corresponding transformed pixel coordinates from edges[]
 *  and pixels[].                                                                      
 */

{
fix15 i, org_i;
fix15 j;
fix15 pos, org_pos;
fix31 fpos;
fix15 this_edge, best_edge;
fix31 temp, frac;

if (n == 0)                    /* No zone data? */
    return;                    /* No transformation list needed */

/* Copy edge values into oru table */
for (i = 0; i < n; i++)
    {
    orus_tbl[i] = edges[i];
    }

/* Look for bottom or top of emsquare in list of edges */
for (i = 0; i < n; i++)
    {
    this_edge = orus_tbl[i];
    if ((j = this_edge - bot_edge) == 0  ||  j == 1  ||  j == -1)
        {
        fpos = ((((orus_tbl[i] * y_scale) + 2048) >> 12) + y_pos) * 
                   (y_pixels_per_em / fix_outlres);
        org_pos = (fix15) ((fpos + pix_round) >> pix_shift);
        org_i = i;
        goto finish;
        }
    if ((j = this_edge - top_edge) == 0  ||  j == 1  ||  j == -1)
        {                                                 
        fpos = ((((bot_edge * y_scale) + 2048) >> 12) + y_pos) * (y_pixels_per_em / fix_outlres);
        org_pos = (fix15) ((fpos + pix_round) >> pix_shift);
        temp = (hi_y_pxls_per_em * y_scale) + (((lo_y_pxls_per_em * y_scale) + 2048) >> 12);
        org_pos += (fix15) ((temp + pix_round_down) >> pix_shift);
        org_i = i;
        goto finish;
        }
    }

/* If no edge at bottom or top, then look for edge nearest baseline */
org_i = 0;
best_edge = ABS(orus_tbl[0]);
for (i = 1; i < n; i++)
    {
    if (ABS(orus_tbl[i]) < best_edge)
        {
        best_edge = ABS(orus_tbl[i]);
        org_i = i;
        }
    }
fpos = y_pixels_per_em / fix_outlres; 
fpos *=  (((orus_tbl[org_i] * y_scale) + 2048) >> 12) + y_pos;
org_pos = (fix15) ((fpos + pix_round) >> pix_shift);

/* Fill in pixel addresses for each edge */
finish:
pos = org_pos;
for (i = org_i; i < n; i++)
    {
    pixels_tbl[i] = direction * pos;
    pos += pixels[i];
    }
pos = org_pos;
for (i = org_i - 1; i >= 0; i--)
    {
    pos -= pixels[i];
    pixels_tbl[i] = direction * pos;
    }
}


FUNCTION  static  make_trans_table (pixels_per_em, scale, pos, direction,
    orus_tbl, pixels_tbl, n, mult_tbl, offset_tbl, pno_transforms)
fix31  pixels_per_em;  /* pixels per em */
fix31  scale;          /* scale factor */
fix31  pos;            /* position */         
fix15  direction;      /* +1 indicated increasing pixel values, -1 decreasing values */
fix15  orus_tbl[];     /* table of oru values */
fix15  pixels_tbl[];   /* table of corresponding pixel values */
fix15  n;              /* number of entries in orus/pixels tables */
fix31  mult_tbl[];     /* Transformation multiplier */
fix31  offset_tbl[];   /* Transformation constants */
fix15 *pno_transforms; /* (output) number of multipliers/constants */

/*  Called by setup_trans() to generate interpolation function coefficients
 *  from list of zone edge values and their corresponding integer pixel values.  
 */

{
fix15   i, j;
boolean comp_reqd;
fix15   delta_orus;
fix31   frac;
fix31   temp1, temp2;

if (n < 2)
    {
    if (n == 0)          /* No zone data? */
        {
        mult_tbl[0] = (fix31)floor((real) pixels_per_em * scale * direction * 16.0 / (outlres * pix_acc) + 0.5);
        offset_tbl[0] = (fix31)floor((real) pos * (real) pixels_per_em * direction * d65536 / (outlres * pix_acc) + (real) x_scan + 0.5);
        *pno_transforms = 0;
        return;
        }
    report_error (ERROR,ER_ONLY_ONE_ZONE_FOUND,TRUE,"");
    return;
    }

/* Generate table of transformation coefficients */
comp_reqd = FALSE;
for (i = 1; i < n; i++)
    {
    if ((delta_orus = orus_tbl[i] - orus_tbl[i - 1]) > 0)
        {
        mult_tbl[i] = 
            (((fix31)(pixels_tbl[i] - pixels_tbl[i - 1]) << 16) + (delta_orus >> 1)) / delta_orus;
        offset_tbl[i] = 
            (((fix31)pixels_tbl[i] << 16) - (orus_tbl[i] * mult_tbl[i]) + x_scan);
        }
    else
        {
        comp_reqd = TRUE;                    /* Flag presence of zero interval(s) */
        }
    }                                                     
frac = (((pixels_per_em & 0x0000ffff) * scale) + 2048) >> 12;
frac += (((pixels_per_em & 0xffff0000) >> 12) * scale);
temp1 = pix_shift - 16;       /* temps to make sure mult_tbl[0], mult_tbl[n] have 16 bit accuracy */
temp2 = ((fix31) 1) << (temp1 - 1); /* numbers appropriately rounded */
mult_tbl[n] = mult_tbl[0] = ((frac * direction / fix_outlres) + temp2) >> temp1;
offset_tbl[0] = (((fix31)pixels_tbl[0] << 16) - (orus_tbl[0] * mult_tbl[0]) + x_scan);
offset_tbl[n] = (((fix31)pixels_tbl[n - 1] << 16) - (orus_tbl[n - 1] * mult_tbl[0]) + x_scan);
*pno_transforms = n;

/* Remove duplicate oru values and compact lists if appropriate */
if (comp_reqd)
    {
    for (i = j = 1; i < n; i++)
        {
        if (orus_tbl[i] > orus_tbl[i - 1])   /* Non-zero interval? */
            {
            orus_tbl[j] = orus_tbl[i];
            pixels_tbl[j] = pixels_tbl[i];
            mult_tbl[j] = mult_tbl[i];
            offset_tbl[j] = offset_tbl[i];
            j++;
            }
        }
    mult_tbl[j] = mult_tbl[n];
    offset_tbl[j] = offset_tbl[n];
    *pno_transforms = j;
    }
}


FUNCTION do_comp_xy_trans(x, y, pnew_x, pnew_y)
fix15  x;               /* X coordinate in oru space */
fix15  y;               /* Y coordinate in oru space */
fix15 *pnew_x;          /* X coordinate in pixel space */
fix15 *pnew_y;          /* Y coordinate in pixel space */

/*  Transforms (x, y) position in oru space into the corresponding position
 *  in pixel space.  Used for extent calculations.
 */

{

*pnew_x = (fix15) ((a_mult_x * x + b_mult_x * y + 4096) >> 13);
*pnew_y = (fix15) ((a_mult_y * x + b_mult_y * y + 4096) >> 13);

}


FUNCTION do_comp_xy_offset(x, y, pnew_x, pnew_y)
fix15  x;               /* X coordinate in oru space */
fix15  y;               /* Y coordinate in oru space */
fix31 *pnew_x;          /* X coordinate in pixel space */
fix31 *pnew_y;          /* Y coordinate in pixel space */

/*  Transforms (x, y) position in oru space into the corresponding position
 *  in pixel space.  Used for extent calculations.
 */

{

*pnew_x = (a_mult_x * x + b_mult_x * y) >> 1;
*pnew_y = (a_mult_y * x + b_mult_y * y) >> 1;

}


FUNCTION fix31 do_comp_x_trans(x, decide)
fix31 x;        /* X coordinate in oru space */
boolean decide;

/*  Transforms x coordinate in oru space into X coordinate in pixel space.
 *  Returns transformed X position in pixel space.
 */

{
fix15 i;
fix31 new_x;
real  shifter;

shifter = (real) ((fix31) 1 << (pix_shift - 16));
x <<= 4;             
if (no_comp_x_edges != 0)
    {
    for (i = 0; i < no_comp_x_edges; i++)
        {
        if (x <= comp_x_edge_tbl[i]) 
            {
            if (i != 0)
                {
                new_x =  comp_x_pixel_tbl[i-1] + (fix31) 
                    (((real) (x - comp_x_edge_tbl[i-1]) /
                    (real) (comp_x_edge_tbl[i] - comp_x_edge_tbl[i-1])) *
                    (real) (comp_x_pixel_tbl[i] - comp_x_pixel_tbl[i-1]));
                goto end;
                }
            else
                {
                new_x = comp_x_pixel_tbl[0] - (fix31) ((real) (comp_x_edge_tbl[0] - x) 
                        * shifter * pixperoru_x);
                goto end;
                }
            }
        }
    new_x = comp_x_pixel_tbl[no_comp_x_edges - 1] +
        (fix31) ((real) (x - comp_x_edge_tbl[no_comp_x_edges - 1]) * pixperoru_x * shifter);
    goto end;
    }
else
    {
    new_x = (fix31) ((real) x * pixperoru_x * shifter);
    goto end;
    }        

end:          
if (decide)
    new_x >>= pix_shift - 16;

return(new_x);
}

#ifdef RULESDBG
FUNCTION static print_x_trans_data ()

/*  Called by setup_trans() to print the transformation coefficients for the
 *  computation of transformed x values.
 *  For debugging purposes only.                                             
 */

{
fix15   i;
fix15   xp, yp;

if (!print_trans_data)
    return;
if (no_xx_transforms >= 0)
    {
    printf("\nX transformation table calculated from X:\n");
    printf("Zone edges     x_pixels   x-mult tbl x-offset tbl      x-trans\n");
    printf("----------     --------   ---------- ------------      -------\n");
    for (i = 0; i < no_xx_transforms; i++)
        {
        do_xy_trans (x_orus[i], (fix15)0, &xp, &yp, 12);
        printf("%10d %12d %12.5f %12.5f %12.5f\n",
            x_orus[i], x_pixels[i], 
            (real)x_mult_tbl[i] / d65536, 
            (real)x_offset_tbl[i] / d65536, 
            (real)xp / 16.0);
        }
    printf("                        %12.5f %12.5f\n",
        (real)x_mult_tbl[no_xx_transforms] / d65536, 
        (real)x_offset_tbl[no_xx_transforms] / d65536);
    return;
    }

if (no_xy_transforms >= 0)
    {
    printf("\nX transformation table calculated from Y:\n");
    printf("Zone edges     x_pixels   x-mult tbl x-offset tbl      x-trans\n");
    printf("----------     --------   ---------- ------------      -------\n");
    for (i = 0; i < no_xy_transforms; i++)
        {
        do_xy_trans ((fix15)0, x_orus[i], &xp, &yp, 12);
        printf("%10d %12d %12.5f %12.5f %12.5f\n",
            x_orus[i], x_pixels[i], 
            (real)x_mult_tbl[i] /  d65536, 
            (real)x_offset_tbl[i] / d65536, 
            (real)xp / 16.0);
        }
    printf("                        %12.5f %12.5f\n",
        (real)x_mult_tbl[no_xy_transforms] / d65536, 
        (real)x_offset_tbl[no_xy_transforms] /  d65536);
    return;
    }

printf("X transformation table calculated from X and Y:\n");
printf("                      %12.5f %12.5f %12.5f\n", 
    (real)xx_mult / d65536, 
    (real)xy_mult / d65536, 
    (real)(x_offset - x_scan) / d65536);
}
#endif


#ifdef RULESDBG
FUNCTION static print_y_trans_data ()

/*  Called by setup_trans() to print the transformation coefficients for the
 *  computation of transformed y values.
 *  For debugging purposes only.                                            
 */

{
fix15   i;
fix15   xp, yp;

if (!print_trans_data)
    return;
if (no_yy_transforms >= 0)
    {
    printf("\nY transformation table calculated from Y:\n");
    printf("Zone edges     y_pixels   y-mult tbl y-offset tbl      y-trans\n");
    printf("----------     --------   ---------- ------------      -------\n");
    for (i = 0; i < no_yy_transforms; i++)
        {
        do_xy_trans ((fix15)0, y_orus[i], &xp, &yp, 12);
        printf("%10d %12d %12.5f %12.5f %12.5f\n",
            y_orus[i], y_pixels[i], 
            (real)y_mult_tbl[i] / d65536, 
            (real)y_offset_tbl[i] / d65536, 
            (real)yp / 16.0);
        }
    printf("                        %12.5f %12.5f\n",
        (real)y_mult_tbl[no_yy_transforms] / d65536, 
        (real)y_offset_tbl[no_yy_transforms] / d65536);
    return;
    }

if (no_yx_transforms >= 0)
    {
    printf("\nY transformation table calculated from X:\n");
    printf("Zone edges     y_pixels   y-mult tbl y-offset tbl      y-trans\n");
    printf("----------     --------   ---------- ------------      -------\n");
    for (i = 0; i < no_yx_transforms; i++)
        {
        do_xy_trans (y_orus[i], (fix15)0, &xp, &yp, 12);
        printf("%10d %12d %12.5f %12.5f %12.5f\n",
            y_orus[i], y_pixels[i], 
            (real)y_mult_tbl[i] / d65536, 
            (real)y_offset_tbl[i] / d65536, 
            (real)yp / 16.0);
        }
    printf("                        %12.5f %12.5f\n",
        (real)y_mult_tbl[no_yx_transforms] / d65536, 
        (real)y_offset_tbl[no_yx_transforms] / d65536);
    return;
    }

printf("Y transformation table calculated from X and Y:\n");
printf("                      %12.5f %12.5f %12.5f\n", 
    (real)yx_mult / d65536, 
    (real)yy_mult / d65536, 
    (real)(y_offset - x_scan) / d65536);
}
#endif

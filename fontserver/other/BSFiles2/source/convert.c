/*****************************************************************************
*                                                                            *
*            Copyright 1987, 1988, Bitstream Inc., Cambridge, MA             *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************** C O N V E R T . C *****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)  28-Oct-86        Version 1.1

 1)  30-Dec-86  jsc   char_scan_convert() modified to calculate adjusted
                      scale factors and offsets based on extents of root
                      character relative to the edges of the character cell,
                      and imported width if enabled.

 2)  20-Feb-87  mby   Implemented clip left right top bottom (edges of em-
                      square). Removed expand_raster_width. Relocated call to
                      new_subchar(). Deallocates arc to vector array memory.

 3)  19-Mar-87  mby   Rounds widths down if real value =  integer + .5

 4)   9-Apr-87  mby   Changed parameters for calling this module so that
                      no parameters are passed as external globals.

 5)  14-Apr-87  tpl   Call report_error if cannot alloc_bitmap().

 6)  22-Apr-87  mby   Change outline-filling algorithm to get rid of gaps in
                      lines with slope < 1 by scanning in both dimensions (up
                      to ~75 lpm). Changes to proc_vect() and convert_lists().

 7)  14-May-87  mby   Change convert_lists() to preserve white space
                      continuity

 8)  18-May-87  mby   New threshold of .05 pixels.
                      Force raster height, width to nonzero to keep bitmaps
                        from vanishing.
                      Round obliquing, rotatation angles to nearest .1 degree

 9)  14-Jul-87  mby   Fixed bug in proc_vect(). If additional free space was
          needed, free space pointer was allocated incorrectly. 'vectr' is no
          longer allocated dynamically because this can cause a crash. An arc
          can be split into at most 128 vectors (good to ~20000 lines per em!)

10)   8-Oct-87  mby   Fixed char_extent initialization (char_scan_convert).
          Fixed clear bitmap area bug if bitmap was > 32KB (convert_lists).

11)  23-Oct-87  mby   Removed get_comp_token(). It was unnecessary and
                      inefficient.

12)  30-Oct-87  mby   Added a switch to generate bitmaps for either black-
          writers or white-writers. The white-writer bitmaps are created with
          new filling algorithm. fatfill.c generates the intercept lists.
          Functions: char_scan_convert, add_intercept_ww

-----------------------------------------------------------------------------

13)   8 Nov 87  jsc   removed whitewriter support.
                      removed absolute outline format support

14)  14 Nov 87  jsc   Replaced arc splitting algorithm

15)  24 Nov 87  jsc   Changed oru coordinates to 16 bit arithmetic.

                      Character extents now set on two calls to get_rec()
                      instead of 4.

16)   8 Dec 87  jsc   Replaced intercept storage mechanism.

                      Eliminated 2D scan conversion.

                      Added banding mechanism for large characters.

17)  20 Dec 87  jsc   Replaced vector_to() to eliminate floating point
                      arithmetic.

-----------------------------------------------------------------------------

18)  17 Feb 88  reh   Removed excess additions in vector_to().

19)  10 Mar 88  reh   Add whitewrite option in vector_to(), moved most
                      of vector_to() into do_vector(). Algorithm adds half
                      a pixel to outline and uses do_vector() to do scan 
                      conversion. Implemented with floating point numbers.

20)  14 Mar 88  reh   Converted vector_to() to fixed point long integer
                      format. Handles up to 128 lines per em horizontally.

21)  15 Mar 88  reh   Twiddled whitewrite algorthm to handle up to 362 
                      lines per em vertically and removed restrictions
                      horizontally.

22)  17 Mar 88  jsc   Added to fw_set_specs() a check that the specified font 
                      has <= MAX_CHARS characters (including ghost chars)

23)  22 Mar 88  reh   Replaced square root approx. with better approx. which
                      slightly overestimates the actual value rather than 
                      underestimates it.

23)  24 Mar 88  reh   Scaled base error from .5 pixel to .1 pixel resulting in 
                      bitmaps almost identical to bfg_1.10. 

24)  29 Mar 88  reh   do_vector() changed to accomodate variable white writer
                      specs.

25)   3 Apr 88  jsc   add_intercept() modified to accept x value in sub-pixel
                      units
                      horizontal pixel catcher added to proc_intercepts().
                      bmap_xmin and bmap_xmax now are accumulated in sub-pixel
                      units during the first pass. They are converted to whole
                      pixels at the end of the first pass.

26)   3 Apr 88  reh   do_vector() modified to generate intercepts in units
                      of sub-pixels.

27)   4 Apr 88  jsc   2D scan conversion added. Affects the following functions:

28)   6 Apr 88  reh   x_scan_reqd dependent on X_SCAN_THRESH in mkbm.h to determine
                      whether 2D scan conversion is required.

29)   8 Apr 88  reh   changed vector_to() and do_vector into vector_to() which
                      handles blackwriter with calls to do_vector() for an x_scan,
                      and vector_ww() which handles whitewriter which uses 
                      do_vector for scan conversion.

30)  11 May 88  mby   round set width down at .5          

31)  17 May 88  reh   convert.c operates with seven bits of accuracy when 
                      lines per em is below X_SCAN_THRESH. Slows algorithm
                      by 4 to 10 percent.

32)  25 May 88  reh   Special case when vector crosses only one scan line.
                      vector_to and do_vector directly solves intercept.
                      Improvement of 3 to 7 percent which makes up for the
                      decrease in speed due to seven bits of accuracy.

33)  03 Jun 88  reh   Check fontwide extents and adjust to three fractional bits of 
                      accuracy if pixel coordinates exceed +/- 2048. Allows 
                      characters up to 4096 lpem.

34)  15 Jun 88  reh   convert.c operates with six bits of accuracy when
                      lines per em is below X_SCAN_THRESH. There is no 
                      discernable decrease in bitmap quality while speed
                      increased 3 to 4 percent.

35)  01 Jul 88  reh   x_fpxl, y_fpxl, x_fpxl_min, y_fpxl_min, x_fpxl_max, 
                      y_fpxl_max, converted from real to split integer with
                      16 bits integer, 16 bits fractional. Function do_comp_xy_trans()
                      converted from real arguments to fix31. Speed increase of
                      5 to 7 percent. No difference in bitmaps due to change.

36)  16 Jul 88  cdf   converted intercept list to be an array of structures with the
                      cdr being an actual pointer, rather than an array index.

 *****************************************************************************

    This module takes a character in a compressed outline font and generates
    a bitmap of the specified character.
    
    The entry points into this module are:

    fw_reset() 
    to reset all conditions.
    
    fw_set_specs(compc)
    comp_char_desc  *compc;  
    to set specifications for character generation.

    bool fw_make_char(root_char_nr)
    ufix16    root_char_nr;
    to generate a character in accordance with the current specifications.

    fw_make_char() calls three external functions:

        open_bitmap(width, xmin, xmax, ymin, ymax)
        fix15 width; Set width (whole pixels) 
        fix15 xmin;  Pixel boundary at left extent of bitmap character 
        fix15 xmax;  Pixel boundary at right extent of bitmap character
        fix15 ymin;  Pixel boundary of bottom extent of bitmap character
        fix15 ymax;  Pixel boundary of top extent of bitmap character 
        Allows memory to be initialized to receive the generated bitmap character.

        set_bitmap_bits (y, xbit1, xbit2)
        fix15 y;     Scan line (0 = first row above baseline) 
        fix15 xbit1; Pixel boundary where run starts 
        fix15 xbit2; Pixel boundary where run ends 
        Writes one row of pixels in the generated bitmap character.

        close_bitmap()
        Allows bitmap buffers to be flushed and bitmap writing
        process to be terminated.        

 ****************************************************************************/


#include "stdef.h"              /* Bitstream standard macros & definitions  */
#include "comp2_3.h"            /* Data structures for compressed font */
#include "mkbm.h"               /* General constants and data structures */
#include <math.h>
#include "errchk.h"
#include "error.h"

/* This should be defined as a compilation argument */
/* #define  CONVERTDBG          /* Prints gobs of debugging data */

#if WHITE_WRITER

fix15 theta[257][2] =           /* table to set up normal table for whitewriter */
{{512, 0},{511, 1},{511, 3},{511, 5},
{511, 7},{511, 9},{511, 11},{511, 13},
{511, 15},{511, 17},{511, 19},{511, 21},
{511, 23},{511, 25},{511, 27},{511, 29},
{511, 31},{510, 33},{510, 35},{510, 37},
{510, 39},{510, 41},{510, 43},{509, 45},
{509, 47},{509, 49},{509, 51},{509, 53},
{508, 55},{508, 57},{508, 59},{508, 61},
{508, 63},{507, 65},{507, 67},{507, 69},
{507, 71},{506, 72},{506, 74},{506, 76},
{505, 78},{505, 80},{505, 82},{504, 84},
{504, 86},{504, 88},{503, 90},{503, 92},
{503, 94},{502, 95},{502, 97},{502, 99},
{501, 101},{501, 103},{501, 105},{500, 107},
{500, 109},{499, 110},{499, 112},{499, 114},
{498, 116},{498, 118},{497, 120},{497, 121},
{496, 123},{496, 125},{495, 127},{495, 129},
{494, 130},{494, 132},{494, 134},{493, 136},
{493, 138},{492, 139},{492, 141},{491, 143},
{490, 145},{490, 146},{489, 148},{489, 150},
{488, 152},{488, 153},{487, 155},{487, 157},
{486, 159},{486, 160},{485, 162},{484, 164},
{484, 165},{483, 167},{483, 169},{482, 170},
{482, 172},{481, 174},{480, 175},{480, 177},
{479, 179},{479, 180},{478, 182},{477, 184},
{477, 185},{476, 187},{475, 188},{475, 190},
{474, 192},{473, 193},{473, 195},{472, 196},
{472, 198},{471, 199},{470, 201},{470, 203},
{469, 204},{468, 206},{468, 207},{467, 209},
{466, 210},{465, 212},{465, 213},{464, 215},
{463, 216},{463, 218},{462, 219},{461, 221},
{461, 222},{460, 223},{459, 225},{459, 226},
{458, 228},{457, 229},{456, 231},{456, 232},
{455, 233},{454, 235},{453, 236},{453, 238},
{452, 239},{451, 240},{451, 242},{450, 243},
{449, 244},{448, 246},{448, 247},{447, 248},
{446, 250},{445, 251},{445, 252},{444, 254},
{443, 255},{442, 256},{442, 258},{441, 259},
{440, 260},{439, 261},{439, 263},{438, 264},
{437, 265},{436, 266},{436, 268},{435, 269},
{434, 270},{433, 271},{433, 273},{432, 274},
{431, 275},{430, 276},{430, 277},{429, 278},
{428, 280},{427, 281},{427, 282},{426, 283},
{425, 284},{424, 285},{423, 287},{423, 288},
{422, 289},{421, 290},{420, 291},{420, 292},
{419, 293},{418, 294},{417, 295},{417, 296},
{416, 298},{415, 299},{414, 300},{414, 301},
{413, 302},{412, 303},{411, 304},{410, 305},
{410, 306},{409, 307},{408, 308},{407, 309},
{407, 310},{406, 311},{405, 312},{404, 313},
{404, 314},{403, 315},{402, 316},{401, 317},
{401, 318},{400, 319},{399, 320},{398, 321},
{397, 322},{397, 323},{396, 323},{395, 324},
{394, 325},{394, 326},{393, 327},{392, 328},
{391, 329},{391, 330},{390, 331},{389, 332},
{388, 332},{388, 333},{387, 334},{386, 335},
{385, 336},{385, 337},{384, 338},{383, 338},
{383, 339},{382, 340},{381, 341},{380, 342},
{380, 343},{379, 343},{378, 344},{377, 345},
{377, 346},{376, 347},{375, 347},{374, 348},
{374, 349},{373, 350},{372, 350},{372, 351},
{371, 352},{370, 353},{369, 354},{369, 354},
{368, 355},{367, 356},{367, 357},{366, 357},
{365, 358},{364, 359},{364, 359},{363, 360},
{362, 361}};

#endif

intrcpt_element near     nil_element = {0,(ufix16 near *)0,0};

/***** STATIC VARIABLES *****/

static  cft_outl_str  *cfontp;  /* pointer to compr font structure */
 boolean whitewrite;     /* TRUE if whitewriter bitmaps required */
static  bool16  import_widths;  /* T if import widths option on         */
static  boolean clip_left;      /* Clips min x at left of emsquare if true */
static  boolean clip_right;     /* Clips max x at right of emsquare if true */
static  boolean clip_top;       /* Clips max y at top of emsquare if true */
static  boolean clip_bottom;    /* Clips min y at bottom of emsquare if true */
static  boolean squeeze_left;   /* Squeezes min x into left of emsquare if true */
static  boolean squeeze_right;  /* Squeezes max x into right of emsquare if true */
static  boolean squeeze_top;    /* Squeezes max y into top of emsquare if true */
static  boolean squeeze_bottom; /* Squeezes min y into bottom of emsquare if true */
static  boolean font_ok;        /* TRUE if font suitable for scan conversion */
static  fix31   oru_top;        /* Top of emsquare in orus */
static  fix31   oru_bot;        /* Bottom of emsquare in orus */
static  boolean normal_char;    /* TRUE if rot angle = obl angle = 0 */
static  fix15   char_count;     /* Char or sub-char count */

        boolean first_pass;     /* TRUE if first pass through outline */
        fix15   x_oru, y_oru;   /* Current position in ORU space */
        fix15   frac_x_oru;     /* fraction oru error accumulators */
        fix15   frac_y_oru;
        fix15   x_spxl, y_spxl; /* Current position in pixel space (unrounded) */
        fix15   y_pxl;          /* Current y position in pixel space (rounded) */
        fix15   x_pxl;          /* Current x position in pixel space (rounded) */
        fix15   adj_dir;        /* Scan conversion edge adjustment direction:
                                    -1: Outside curve
                                     0: No hierarchy data, no adjustment
                                     1: Inside curve    */
static  fix31    depth_factor_tbl[10] =  /* Table of the squares of accuracy improvement ... */
{                               /* ... factors for each depth of split arc recursion */
1, 4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144
};
static  fix15   arc_error_tbl[MAX_ARC_DEPTH]; /* Table of arc error thresholds */
static  fix15   beta_tbl[MAX_ARC_DEPTH]; /* Table of successive beta values for recursion */
        fix15   scan_shift;     /* similar to charshift - used in vector_to */
        fix15   char_shift;     /* how many places to shift left or right depending on lpem */
        fix31   scan_round;     /* similar to charround - used in vector_to */
        fix15   char_round;     /* what to round a split integer number with depending on lpem */
        fix15   oru_shift;      /* use when using fractional oru's */
        fix15   oru_trunc;      /* use when using fractional oru's */
static  ufix32  char_and;       /* number to bitand with depending on lpem */
static  boolean char_normal;    /* TRUE if character is between X_SCAN_THRESH and 2048 lpem, FALSE otherwise */
        fix15   rules_shift;    /* number of bits that do_xy_trans in rules.c is supposed to shift by */
static  fix31   rules_round;    /* what to round the numbers in do_xy_trans by before they are shifted */

/* Intercept list data and structures */
static intrcpt_element near  incpt_list[MAX_INTERCEPTS];     /* Intercept list elements */
        fix15   bmap_xmin;      /* Min X intercept */
                                /*   sub-pixel units during first pass */
                                /*   converted to pixel units at end of first pass */
        fix15   bmap_xmax;      /* Max X intercept */
                                /*   sub-pixel units during first pass */
                                /*   converted to pixel units at end of first pass */
        fix15   bmap_ymin;      /* Min Y intercept in pixel units */
        fix15   bmap_ymax;      /* Max Y intercept in pixel units */
static  boolean x_scan_reqd;    /* TRUE if vertical sampling required */
        boolean x_scan_active;  /* TRUE if vertical sampling required */
static  fix15   no_y_lists;     /* Number of active Y intercept lists */
static  fix15   no_x_lists;     /* Number of active X intercept lists */
static  fix15   no_lists;       /* Number of total (X + Y) */
static  fix15   next_offset;    /* Index of next free list cell */
static  fix15   band_xmin;      /* Min X value in current band */
static  fix15   band_xmax;      /* Max X value in current band */
static  fix15   band_ymin;      /* Min Y value in current band */
static  fix15   band_ymax;      /* Max Y value in current band */
static  boolean intercept_oflow; /* TRUE if intercepts data lost */

static  boolean mode_2;         /* TRUE if in mode 2 : vector output */
static  real    divisor;        /* number to divide fixed point numbers by to give real pixels
                                   to vector output routines */
/* static variables used for vector_ww() */ 
static  fix31   old_dxdy;       /* slope of previous vector in vector_to() */
static  fix31   mod_xrs1, mod_yrs1; /* modified x and y positions from previous vector */
static  fix31   orig_xrs1, orig_yrs1; /* modified x and y positions of first vector in curve */
static  fix31   orig_dxdy;      /* slope of first vector in curve */
static  fix15   orig_x_spxl, orig_y_spxl; /* ending point for first vector under whitewrite */
static  fix15   pipe_count;     /* -1 for first vector, 1 for second, 0 for pipe full */
static  boolean finite;         /* true if slope finite for previous vector */
static  boolean orig_finite;    /* true if slope of first vector in curve finite */
static  fix15   mod_xs1, mod_ys1; /* endpoints of previous vector, start points of new vector */
static  fix15   inside_curve;   /* TRUE if inside curve */  
static  fix15   normal[257][2]; /* a table of normals for the white writer algorithm */


FUNCTION fw_reset()

/*  Fontware character generator call to reset all conditions
 */

{
reset_trans();
font_ok = FALSE;
}

FUNCTION fw_set_specs(compc)
comp_char_desc  *compc;  /* Pointer to scan conversion parameters structure */

/*  Fontware character generator call to set font specifications
 *  compc -- pointer to structure containing scan conversion parameters.
 *   ->compf -- compressed font data structure
 *   ->point_size_x -- x pointsize
 *   ->point_size_y -- y pointsize
 *   ->res_hor -- horizontal pixels per inch
 *   ->res_ver -- vertical pixels per inch
 *   ->rot_angle -- rotation angle in degrees (clockwise)
 *   ->obl_angle -- obliquing angle in degrees (clockwise)
 *   ->whitewrite -- if true, generate bitmaps for whitewriters
 *   ->thresh -- white writer scan-conversion threshold
 *   ->import_widths -- if true, use external width table
 *   ->clip.left -- clips min x at left of emsquare
 *   ->clip.right -- clips max x at right of emsquare
 *   ->clip.bottom -- clips min x at bottom of emsquare
 *   ->clip.top -- clips max x at top of emsquare
 *   ->squeeze.left -- squeezes min x at left of emsquare
 *   ->squeeze.right, .top, .bottom  &c
 *   ->bogus_mode -- ignore plaid data if TRUE
 */

{
fix15   i, ww_adj;
real    outlres;
real    point_size_x;   /* x-point size (72.3 pts per inch)     */
real    point_size_y;   /* y-point size (72.3 pts per inch)     */
real    res_hor;        /* output device resolution, horizontal */
real    res_ver;        /* output device resolution, vertical   */
real    point_size, res, base_error, resolution_ratio;
real    max_lpem;
real    realthresh;     /* whitewriter threshold in real pixels */
ufix16  mode;           /* mode of the bmap generator */

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
fix15     pix_max;
void      do_comp_xy_trans(); /* Top level transformation function */

                                        /* Copy passed font data to static storage */
cfontp = compc->compf;                  /* Pointer to the font structure */
mode = compc->mode;                     /* 0: Make nothing   1: Create Bitmap   2: Vector Output */
point_size_x = compc->point_size_x;     /* Point size in x direction */
point_size_y = compc->point_size_y;     /* Point size in y direction */
res_hor = compc->res_hor;               /* Horizontal (x) resolution */
res_ver = compc->res_ver;               /* Vertical (y) resolution */
whitewrite = compc->whitewrite;         /* Whitewriter 1==Yes  0==No */
realthresh = compc->thresh;             /* Whitewriter threshold    thickness added = .5 + thresh */
import_widths = compc->import_widths;   /* If there is an imported width table */
clip_left = compc->clip.left;           /* Clipping flags. Clip to left on em */
clip_right = compc->clip.right;         /* Clip to set width */
clip_top = compc->clip.top;             /* Clip to top of em */
clip_bottom = compc->clip.bottom;       /* Clip to bottom of em */
squeeze_left = compc->squeeze.left;     /* Squeeze flags.  Squeeze == Scale to fit left of em */
squeeze_right = compc->squeeze.right;   /* Scale to fit set width */
squeeze_top = compc->squeeze.top;       /* Scale to fit top of em */
squeeze_bottom = compc->squeeze.bottom; /* Scale to fit bottom of em */

switch (mode)               /* Based on mode, set some of these variables */
    {
    case 0:                 /* Null mode. Font "not OK", exit */
        {               
        font_ok = FALSE;
        return;                         
        }
    case 1:                 /* Bitmap mode. Font "OK", set "mode_2" to false */
        {
        font_ok = TRUE;
        mode_2 = FALSE; 
        break;
        }
    case 2:                 /* Fun vector mode. Font "OK" and "mode_2" flag true */
        {
        font_ok = TRUE;
        mode_2 = TRUE; 
        if (!VECT_OUT)      /* VECTOR MODE SELECTED AT COMPILE TIME TO SAVE CODE SPACE */
            {
            report_error (ERROR,ER_VECTOR_NOT_COMPILED,TRUE,"");
            mode_2 = FALSE;
            }
        break;
        }   
    default:
        {
        report_error (ERROR,ER_MODE_UNDEFINED,TRUE,"***** Unspecified mode \n");
        font_ok = FALSE;
        return;
        }
    }

if (cfontp->fonthead.outl_fmt_nr[1] != '2') /* Fontheader outline format number. Should be ASCII 2 */
    {
    report_error (ERROR,ER_NOT_FW_OUTLINE,TRUE,"****** Outline file is not standard Fontware outline\n");
    font_ok = FALSE;
    return;
    }

if (cfontp->chdir_hd.nr_recs > MAX_CHARS)   /* If Character directory header number of record is more */
    {                                       /* than we are allowed to process, signal error */
    report_error (ERROR,ER_2MANY_CHARS_IN_OUTL,TRUE,"****** Outline file contains too many characters\n");
    font_ok = FALSE;
    return;
    }

/* Are there value overflows? (we are limited to signed 16bit numbers) */
if (cfontp->fonthead.extent_x_min < -32000 || 
    cfontp->fonthead.extent_x_max > 32000  ||
    cfontp->fonthead.extent_y_min < -32000 || 
    cfontp->fonthead.extent_y_max > 32000)
    {
    report_error (ERROR,ER_EXTENTS_2BIG_4INTS,TRUE,"");
    font_ok = FALSE;
    return;
    }

outlres = (real) cfontp->fonthead.resl_per_em;      /* In ORU's */
oru_bot = (fix31)floor(EM_BOT * (outlres / 8640.0) + 0.5); /* Offsets for bottom and top from baseline in ORU's */
oru_top = (fix31)floor(EM_TOP * (outlres / 8640.0) + 0.5);
init_trans(compc);  /* Initialize transformation (in rules.c) */

if (!WHITE_WRITER && whitewrite)                    /* Double check that whitewriter code is compiled */
    {
    report_error (ERROR,ER_WW_NOT_COMPILED,TRUE,"");
    whitewrite = FALSE;
    }    

/* Normal means no rotation or oblique */
normal_char = ((compc->rot_angle == 0.0) && (compc->obl_angle == 0.0)); 

/* The following block of code determines:      */
/*          what fractional resolution to use   */
/*          whether to use 2D scanning          */

/* get these values for use below */
x_oru_min = (fix15)cfontp->fonthead.extent_x_min;
x_oru_max = (fix15)cfontp->fonthead.extent_x_max;
y_oru_min = (fix15)cfontp->fonthead.extent_y_min;
y_oru_max = (fix15)cfontp->fonthead.extent_y_max;

/* xfrom from ORU's to fractional pixels (sign 12 . 3) */
do_comp_xy_trans(x_oru_min, y_oru_min, &x_fpxl_min, &y_fpxl_min);
do_comp_xy_trans(x_oru_max, y_oru_max, &x_fpxl_max, &y_fpxl_max);

/* Of all of the "fpxl" values, find largest */

if ((x_fpxl_max >= x_fpxl_min) && (x_fpxl_max >= y_fpxl_max) && (x_fpxl_max >= y_fpxl_min))
    pix_max = x_fpxl_max;
else if ((y_fpxl_max >= y_fpxl_min) && (y_fpxl_max >= x_fpxl_min))
    pix_max = y_fpxl_max;
else if (x_fpxl_min >= y_fpxl_min)
    pix_max = x_fpxl_min;
else
    pix_max = y_fpxl_min;  

/* Round pix_max into integer pixels */
pix_max = (pix_max + 4) >> 3;

/* Find the minimum point size and the minimum resoltion */
point_size = (point_size_x < point_size_y)? point_size_x: point_size_y;
res = (res_hor < res_ver)? res_hor: res_ver;

/* determine whether two dimension scan conversion is required */
x_scan_reqd = (((point_size * res) / PTPERINCH) < (real)X_SCAN_THRESH) && !whitewrite; 

if (x_scan_reqd) 
    divisor = (real) (1 << SHIFT_VAR);

/* pix_max contains absolute largest fontwide extent in pixel space */

if (pix_max > 2047) /* if extent greater than 2047 use 3 bit accuracy in convert.c */
    {               /* ALSO: this is only used in 1D scan! */
    char_shift = 3;         /* Number of factional bits to shift off to make integer */
    char_round = 4;         /* .5 in this reprentation */
    scan_shift = 19;
    scan_round = 0x40000;
    char_and = 0xfff8;      /* AND mask to remove fractional bits */
    rules_shift = 13;       /* Passed to "do_xy_trans" to indicate fractional format */
    rules_round = 4096;     /* Passed to "setup_trans" to setup multiplication tables */
    divisor = 8.0;          /* Used by vector output. Converts split ints to reals */
    }
else                /* else set accuracy to 4 bits */
    {
    char_shift = 4;
    char_round = 8;   
    scan_shift = 20;
    scan_round = 0x80000;
    char_and = 0xfff0;    
    rules_shift = 12;  
    rules_round = 2048;
    divisor = 16.0;
    }           

if (pix_max > 4095) /* if extent is to big for program to handle, quit */
    {
    report_error (ERROR,ER_EXTENTS_2BIG_2PROCS,TRUE,"");
    font_ok = FALSE;
    return;
    }

if (whitewrite && (pix_max > 360))      /* 360 is the biggest character that ww fix works */
    {                                   /* (360 is kind of big to worry about ww anyway)  */
    whitewrite = FALSE;
    /*    report_error (ERROR,1058,TRUE,"");
     *    report_error (ERROR,1059,TRUE,"");
     */
    }

resolution_ratio = (outlres * 72.0) / (point_size * res);

if (resolution_ratio < 2.0) /* if we're rendering near or above oru resolution, use */
    {                        /* fractional oru's                                     */
    oru_shift = char_shift;
    oru_trunc = ~char_and;
    }
    else
    {
    oru_shift = 0;
    oru_trunc = 0;
    }

/* Setup arc splitting table */
/* base error hase something to do with a one tenth of a pixel curve fit to a vector */
base_error = (2.0 * ARC_ERROR_TOLERANCE * PTPERINCH * outlres) / (point_size * res); /* 0.1 pel accuracy */

if ((base_error < resolution_ratio) && (resolution_ratio < 1.0))
    base_error = resolution_ratio;

for (i = 0; i < MAX_ARC_DEPTH; i++)
    {
    arc_error_tbl[i] = (fix15)(base_error * (real)depth_factor_tbl[i] * 4.0);
    }

#if WHITE_WRITER
if (whitewrite) /* Build table of ww thickness normals indexed by slope */
    {                         
    ww_adj = 8 + ((realthresh < 0.0 ? -1 : 1) * ((fix15) ((16.0 * ABS(realthresh)) + 0.5)));
    for (i = 0; i < 257; i++)
       {
       normal[i][0] = ((theta[i][0] * ww_adj)>>7);
       normal[i][1] = ((theta[i][1] * ww_adj)>>7);
       } 
    }           
#endif
}

FUNCTION  bool fw_make_char(root_char_nr)
ufix16    root_char_nr;  /* Offset of character to be generated */

/*  Fontware call to generate one bitmap character (may be composite).
 *  Returns TRUE if valid bitmap is generated, FALSE if error
 */

    DECLARE 
    fix15     i;
    ufix16 huge *pfirst_rec;    /* ptr to first outline data record in font */
    ufix16 huge *pthis_rec;     /* outline data "program counter" */
    bool      getrec_more;      /* stay in loop that calls get_rec() */
    fix15     rec_type;         /* compressed font record type (get_rec) */
    ufix16    cur_char_no;      /* current char number */
    boolean   more_bands;       /* TRUE if more Y bands to process */
    fix15     band_size;        /* Current band size */
    boolean   non_blank_char;   /* TRUE if char has outline data */
    fix15     curve_count;      /* Curve count within char or sub_char */
    fix15     gx, gy;           /* get_rec() returned variables */
    fix15     gx1, gy1;         /* First part of divided gx, gy increment */
    fix15     gx2, gy2;         /* Second part of divided gx, gy increment */
    fix15     gx3, gy3;         /* Third part of divided gx, gy increment */
    fix15     beta;             /* get_rec() returned variable */
    fix15     ibeta;            /* integer version of beta */
    real      fbeta;            /* real version of beta */
    fix15     depth;            /* Arc split recursion depth required */
    fix15     arc_error;        /* Twice max vectorization error for each arc 2 bits fraction */
    fix15     x_oru_init, y_oru_init; /* Coords of start of current curve */
    fix15     hierarchy[64];    /* Array of char's hierarchy values */
    fix15     hier_count;       /* Number of hierarchy values in character */
    real      q1;           /* temps */                     
    fix31     fixer;        /* temps */
    fix15     stack_count;      /* depth of stack (0 to 16) */
    stack_frame stack[16];      /* up to 16 DOCHARS can be nested */
    stack_frame *pstack;        /* pointer to a stack frame */

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
    fix31     x_off;            /* stack[0].xoff in pixel coords */
    fix31     y_off;            /* stack[0].yoff in pixel coords */

    fix31     left_limit;       /* Left limit of character cell */
    fix31     right_limit;      /* Right limit of character cell */
    fix31     bottom_limit;     /* Bottom limit of character cell */
    fix31     top_limit;        /* Top limit of character cell */

    fix31     left_limit_adj;   /* Adjusted position of root char left limit */
    fix31     right_limit_adj;  /* Adjusted position of root char right limit */
    fix31     bottom_limit_adj; /* Adjusted position of root char bottom limit */
    fix31     top_limit_adj;    /* Adjusted position of root char top limit */
 
    boolean   x_scale_adj;      /* TRUE if x scale adjusted by squeeze or reqd width */
    boolean   y_scale_adj;      /* TRUE if y scale adjusted by squeeze */
    boolean   twoendchars;
    fix31     reqd_width;       /* Required width for character */
    fix15     set_width;        /* Transformed set width (whole pixels) */

    void      do_xy_trans();    /* Tranformation function */
    void      do_comp_xy_trans(); /* Top level transformation function */
    void      do_comp_xy_offset(); /* Top level transformation function */
    fix31     do_comp_x_trans(); /* Top level X transformation */
    fix31     get_required_width();  /* Gets imported width */
    void      init_rec_state(); /* initialize get_rec variables */
    void      setup_trans();    /* setup transformation data  */
    void      open_bitmap();    /* Open bitmap buffer */
    void      close_bitmap();   /* Close bitmap buffer */

#if VECT_OUT
    real      real_set_width;   /* Set width in real pixels */
    void      open_outline();   /* Open outline */
    void      close_outline();  /* Close outline */
    void      open_curve();     /* Open curve */
    void      close_curve();    /* Close curve */
#endif

    BEGIN
#ifdef CONVERTDBG
    printf("\nCharacter ID %d (offset %d)\n",
        cfontp->chdir_dat[root_char_nr].char_id, root_char_nr);
#endif
    if (!font_ok)   /* If font not ok, don't make a character! */
        {
        return(FALSE);
        }

    if (root_char_nr >= cfontp->fonthead.layout_size)
        {
        return(FALSE);  /* Character offset out of range */
        }

    setup_comp_trans(root_char_nr);

/* cache these values */

    x_oru_min = (fix15)cfontp->fonthead.extent_x_min;
    x_oru_max = (fix15)cfontp->fonthead.extent_x_max;
    y_oru_min = (fix15)cfontp->fonthead.extent_y_min;
    y_oru_max = (fix15)cfontp->fonthead.extent_y_max;

/* This is all for squeezing and clipping */
/* Limits are clip boundries and adjusts have to do with squeeze scaling */
    left_limit_adj = left_limit = 0;
    right_limit = right_limit_adj = cfontp->chdir_dat[root_char_nr].set_width;
    bottom_limit = (bottom_limit_adj = oru_bot) << 12;
    top_limit = (top_limit_adj = oru_top) << 12;
    x_scale_adj = y_scale_adj = FALSE;
    reqd_width = (right_limit << 12);       /* Requested width is right limit with 12 bit fraction */

/* For compound characters, there may be two endings. This flag is so that "empty_pipe" is called once */
    twoendchars = TRUE;

    x_scan_active = x_scan_reqd;             /* Turn on vertical sampling for first pass */
    if (x_scan_active)  /* if x_scan_active set variables according to constants in mkbm.h */
        {
        char_shift = SHIFT_VAR;
        char_round = ROUND_UP;
        scan_shift = 16;
        scan_round = 0x8000;
        rules_shift = SHIFT_RULES;
        rules_round = ROUND_RULES;
        }
/* This sets up pointer to font data */
    pfirst_rec = cfontp->outl_dat; 
    first_pass = TRUE;              /* We assume we can do a character in one pass (ie no banding) */
    more_bands = TRUE;              /* At least one Y band needed */
    while(more_bands)               /* Banding loop for processing outline data */
        {
        init_rec_state();           /* initialize GET_REC state */
        pthis_rec = cfontp->outl_dat + cfontp->chdir_dat[root_char_nr].outline_offs;

        stack_count = 0;            /* Initialize stack */
        pstack = stack;             /* scales are unsigned 16 bit integers with */
        stack[0].xoff = 0;          /* 12 bits of accuracy. In this space 1 is represented by */
        stack[0].yoff = 0;          /* the number 4096 */
        stack[0].xscale = stack[0].xscale_nom = 4096;
        stack[0].yscale = stack[0].yscale_nom = 4096;
        stack[1].xoff = 0;
        stack[1].yoff = 0;
        stack[1].xscale = stack[1].xscale_nom = 4096;
        stack[1].yscale = stack[1].yscale_nom = 4096;

/* If we are importing widths, get the imported width and change the appropriate variables */

        if (import_widths && (right_limit > 0))
            {
            reqd_width = (fix31) (get_required_width(cfontp, root_char_nr)) << 12;
            stack[0].xscale = stack[1].xscale = reqd_width / right_limit;
            x_scale_adj = TRUE;
            } 

        open_put_cache_data();      /* Prepare to read zone data */
/* If its a compound character - this counts the parts */
        char_count = 0;             /* Initialize character count */
/* Count the curves within each sub character */
        curve_count = 0;            /* Initialize curve count */
/* Inside or outside curve indicator */
        hier_count = 0;             /* Initialize hierarchy count */
/* Current sub character */
        cur_char_no = root_char_nr;
/* If its a blank character, just return the set width */
        non_blank_char = FALSE;
/* We still have records to get in this character */
        getrec_more = TRUE;
/* Pipe count controls whether the pipe for ww is filled */
        pipe_count = -1;

    /* The following loop processes 1 entire character, including
     *   DOCHARs and CALLs, if any.
     * get_rec() grabs tokens until the final (unnested) end-of-char token is found. */
        while (getrec_more)
            {

#ifdef CONVERTDBG
            /* Trap Call Repeated Sequence codes */
            if ((*pthis_rec & 0xFF00)  ==  0xE200)
                {
                printf("    Call Repeat     Called from %d    Count = %d    Source Address = %d\n",
                      pthis_rec - pfirst_rec, *pthis_rec & 0x00FF,  *(pthis_rec + 1) );
                }
#endif
            get_rec16(&pthis_rec, pfirst_rec, &rec_type, &gx, &gy, &beta);
     
            switch (rec_type)
                {
            case 1:         /* Initialize to start coordinate (gx, gy) */

#ifdef CONVERTDBG
                printf("\n    Move to     x = %4d    y = %4d\n", gx, gy);
#endif
                if (curve_count++ == 0)            /* First curve in outline data? */
                    {
                    twoendchars = FALSE;           /* If you're starting the char, this MUST be false */
                    non_blank_char = TRUE;         /* This means it's definitely a non-blank */
                    close_put_cache_data();        /* Terminate reading zone data */
                    /* Setup the static tables in RULES. Why is this on a stack? Who knows */
                    /* Note yscale_nom is not used */
                    setup_trans(cur_char_no,
                        (*pstack).xscale_nom, (*pstack).yscale,
                        (*pstack).xscale, (*pstack).yscale,
                        x_scale_adj, y_scale_adj,
                        (*pstack).xoff, (*pstack).yoff, rules_round);

                    if (char_count++ == 0)         /* First character? */
                        {
                        if (first_pass)            /* First pass? */
                            {
                            if (normal_char)       /* No rotate or oblique? */
                                {                  /* No rot. or obl.: Find normal extents */
                                do_comp_xy_trans(x_oru_min, y_oru_min, 
                                    &x_fpxl_min, &y_fpxl_min);
                                do_comp_xy_trans(x_oru_max, y_oru_max, 
                                    &x_fpxl_max, &y_fpxl_max);
                                }
                            else                   /* Rotate or oblique? */
                                {                  /* Rot. or Obl.: Need to check to find real extents */
                                do_comp_xy_trans(x_oru_min, y_oru_min, 
                                    &x_fpxl, &y_fpxl);
                                x_fpxl_max = x_fpxl;
                                x_fpxl_min = x_fpxl;
                                y_fpxl_max = y_fpxl;
                                y_fpxl_min = y_fpxl;
                                do_comp_xy_trans(x_oru_min, y_oru_max, 
                                    &x_fpxl, &y_fpxl);
                                if (x_fpxl > x_fpxl_max)
                                    x_fpxl_max = x_fpxl;
                                if (x_fpxl < x_fpxl_min)
                                    x_fpxl_min = x_fpxl;
                                if (y_fpxl > y_fpxl_max)
                                    y_fpxl_max = y_fpxl;
                                if (y_fpxl < y_fpxl_min)
                                    y_fpxl_min = y_fpxl;
                                do_comp_xy_trans(x_oru_max, y_oru_min, 
                                    &x_fpxl, &y_fpxl);
                                if (x_fpxl > x_fpxl_max)
                                    x_fpxl_max = x_fpxl;
                                if (x_fpxl < x_fpxl_min)
                                    x_fpxl_min = x_fpxl;
                                if (y_fpxl > y_fpxl_max)
                                    y_fpxl_max = y_fpxl;
                                if (y_fpxl < y_fpxl_min)
                                    y_fpxl_min = y_fpxl;
                                do_comp_xy_trans(x_oru_max, y_oru_max, 
                                    &x_fpxl, &y_fpxl);
                                if (x_fpxl > x_fpxl_max)
                                    x_fpxl_max = x_fpxl;
                                if (x_fpxl < x_fpxl_min)
                                    x_fpxl_min = x_fpxl;
                                if (y_fpxl > y_fpxl_max)
                                    y_fpxl_max = y_fpxl;
                                if (y_fpxl < y_fpxl_min)
                                    y_fpxl_min = y_fpxl;
                                }                       
                            /* Get subcharacter offset into em square */
                            do_comp_xy_offset(stack[0].xoff, stack[0].yoff, &x_off, &y_off);
                            /* set banding to cover entire character for now */
                            band_xmin = (fix15) (((fix31) x_fpxl_min * stack[0].xscale
                                               + x_off - 0x1ffff) >> 15);
                            band_xmax = (fix15) (((fix31) x_fpxl_max * stack[0].xscale
                                               + x_off + 0x1ffff) >> 15);
                            band_ymin = (fix15) (((fix31) y_fpxl_min * stack[0].yscale
                                               + y_off - 0x1ffff) >> 15);
                            band_ymax = (fix15) (((fix31) y_fpxl_max * stack[0].yscale
                                               + y_off + 0x1ffff) >> 15);
                            }
#if VECT_OUT
                        if (mode_2)
                            open_outline((real) (band_xmax - band_xmin));
                        else
#endif
                            init_intercepts(); /* Initialize intercept structure */
                        }
                    else            /* Not first character? */
                        {
#if VECT_OUT
                        if (mode_2)
                            start_new_char();
                        
#endif
                        }
                    }
                else                /* Not first curve in outline? */
                    {
                    /* Before we move, did we close the last curve? If not, signal an error */
                    if ((x_oru != x_oru_init) || (y_oru != y_oru_init))
                            {
                            report_error (ERROR,ER_CURVE_DIDNT_CLOSE,TRUE,"");
                            }
#if VECT_OUT
                    if (mode_2)
                        {
                        if (!whitewrite && !twoendchars)
                            close_curve();
                        }
#endif
#if WHITE_WRITER
                    if (whitewrite && !twoendchars) 
                        empty_pipe();
#endif
                    }       /* END OF FIRST CURVECOUNT TEST */
                /* Here curve_count is at least 1. If heir_count==0, no heir data pres */
                /* (also, curve>hier meaning heir. data stopped, but this never happens. Ever) */
                if ((i = curve_count) > hier_count) /* No hierarchy data present? */
                    {
                    adj_dir = 0;    /* This is used to keep track of stroke inside/outside info */
                                    /* Used for "vector output" (mode 2) and for ww fix         */
#if WHITE_WRITER
                    if (whitewrite)
                        {
                        whitewrite = FALSE;
                        report_error (ERROR,ER_CANT_WW_NO_HEIR_DATA,TRUE,"");
                        }
#endif
                    }
                else        /* Hierarchy data present? */
                    {       /* YES! Heir. data present */
                    adj_dir = 0;
                    while (i = hierarchy[i - 1])    /* Sort of a non-linear FOR that steps down */
                        {                           /* through the heirarchy table toggling adj_dir */
                        adj_dir ^= 1;               /* for each shell of heirarchy */
                        }
                    inside_curve = adj_dir;         /* Inside curve is actually used by vector and ww */
                    }
                /* Since this is an absolute move, we save the point because it's the start of a curve */
                x_oru_init = x_oru = gx;      
                y_oru_init = y_oru = gy;
                /* Transform ORU's to pixels using plaid tables and */
                /* specified split int format (rules_shft) */
                do_xy_trans(x_oru, y_oru, &x_spxl, &y_spxl, rules_shift,0);
                /* set up initial point with fractional bits depending on */
                /* lines per em (lpem). */
                y_pxl = (y_spxl + char_round) >> char_shift;
                x_pxl = (-x_spxl + char_round) >> char_shift; 
                
#if VECT_OUT
                if (mode_2 && !whitewrite)
                        start_curve(((real) x_spxl) / divisor, ((real) y_spxl) / divisor,
                                    !inside_curve);
#endif
                break;      /* End case 1 */

            case 2:         /* vector to coordinate (gx, gy) */
            case 3:         /* horizontal vector */
            case 4:         /* vertical vector */
                /* If intercept table full, and we're already banding, do more banding! */
                if (intercept_oflow && !first_pass) /* Abort pass? */
                    {
                    getrec_more = FALSE; /* This pops us out of the "getrec_more" while */
                    break;               /* into the "more_bands" while */
                    }

#ifdef CONVERTDBG
                printf("    Vector:    dx = %4d   dy = %4d\n", gx, gy);
#endif
                vector_to(gx, gy);       /* Bresenham routine. gx and gy are deltas in ORUs */
                break;      /* End case 2, 3, 4 */

            case 5:         /* Arc with coord deltas (gx, gy) and bulge factor beta */
                /* If intercept table full, and we're already banding, do more banding! */
                if (intercept_oflow && !first_pass) /* Abort pass? */
                    {
                    getrec_more = FALSE; /* This pops us out of the "getrec_more" while */
                    break;               /* into the "more_bands" while */
                    }
                frac_x_oru = frac_y_oru = 0;
                /* get the ABS of gx and gy */
                gx1 = (gx > 0) ? gx: -gx;
                gy1 = (gy > 0) ? gy: -gy;
                /* gx1 (is approx.)= hypotenuse of gx-gy triangle */
                gx1 = gx1 > gy1 ? (gx1 + (gy1>>1)) : (gy1 + (gx1>>1));
                /* Calculate arcane arc_error value to see if we need to subdivide the arc */
                arc_error = (fix15)(((fix31)gx1 * ((beta > 0)? beta: -beta)) 
                                        >> 14);
#ifdef CONVERTDBG 
                printf("    Arc:       dx = %4d   dy = %4d   beta = %f\n", 
                    gx, gy, (real)(beta / 65536.0));
#endif 
                gx = gx << oru_shift;
                gy = gy << oru_shift;

                if (arc_error < arc_error_tbl[0])    /* OK to replace arc with 1 vector? */
                    {
                    sub_oru_vector_to(gx, gy,oru_shift,oru_trunc);
                    break;
                    }
                /*we know we'll need at least two: so get deltas to midpoint on arc */
                gx1 = (gx - (((fix31)gy * beta) >> 16) + 1) >> 1;
                gy1 = (gy + (((fix31)gx * beta) >> 16) + 1) >> 1;

                if (arc_error < arc_error_tbl[1])    /* OK to replace arc with 2 vectors? */
                    {
                    sub_oru_vector_to(gx1, gy1, oru_shift,oru_trunc);
                    sub_oru_vector_to((fix15)(gx - gx1), (fix15)(gy - gy1), oru_shift,oru_trunc);
                    break;
                    }
                               
                if (arc_error < arc_error_tbl[3])    /* OK to replace arc with 4 vectors? */
                    {
                    /* Two subdivide the half-arcs, we need the half-arc beta */
                    beta = (beta + 1) >> 1;   /* 1 term next beta calc */
                    /* Get delta's to the midpoints of the half-arcs */
                    gx2 = (gx1 - (((fix31)gy1 * beta) >> 16) + 1) >> 1;
                    gy2 = (gy1 + (((fix31)gx1 * beta) >> 16) + 1) >> 1;
                    gx3 = ((gx - gx1) - (((fix31)(gy - gy1) * beta) >> 16) + 1) >> 1;
                    gy3 = ((gy - gy1) + (((fix31)(gx - gx1) * beta) >> 16) + 1) >> 1;
                    /* If this is true, the 4 is the limit */
                    if (arc_error < arc_error_tbl[2])
                        {
                        sub_oru_vector_to(gx2, gy2, oru_shift,oru_trunc);
                        sub_oru_vector_to((fix15)(gx1 - gx2), (fix15)(gy1 - gy2), oru_shift,oru_trunc);
                        sub_oru_vector_to((fix15)(gx3), (fix15)(gy3), oru_shift,oru_trunc);
                        sub_oru_vector_to((fix15)((gx - gx1) - gx3), (fix15)((gy - gy1) - gy3), oru_shift,oru_trunc);
                        }                                             
                    else /* otherwise, we need 8, so call recursively (one level) to split */
                        {/* each quarter arc into two eigth-arcs */
                        beta_tbl[0] =  (beta + 1) >> 1;   /* 1 term next beta calc */
                        arc_to(gx2, gy2, 0);
                        arc_to((fix15)(gx1 - gx2), (fix15)(gy1 - gy2), 0);
                        arc_to((fix15)(gx3), (fix15)(gy3), 0);
                        arc_to((fix15)((gx - gx1) - gx3), (fix15)((gy - gy1) - gy3), 0);
                        }                       
                    break;
                    }
  /* Here we know we need more than eight sub-arcs: */
                /* Determine depth of arc spliting required */
                for (i = 4; i < MAX_ARC_DEPTH; i++)
                    {
                    if (arc_error < arc_error_tbl[i])
                        { 
                        goto done;
                        }
                    }
                i = MAX_ARC_DEPTH - 1;
             done:
                depth = i - 2;
/* mby */       i = depth;      /* 3/21/88 - fixes compiler bug (?) */

                fbeta = (real)beta / 65536.0;
                /* Now that we have depth, calculate beta table for this arc */
/*mby,3/21/88*/ for (; i >= 0; i--)
                    {
                    fbeta = (sqrt(fbeta * fbeta + 1) - 1) / fbeta;
                    beta_tbl[i] = (fix15)floor(fbeta * 65536.0 + 0.5);
                    }

                arc_to(gx1, gy1, depth);
                arc_to((fix15)(gx - gx1), (fix15)(gy - gy1), depth);
                break;      /* End case 5 */                                         


            case 6:         /* Set scale factors to gx, gy (split ints, 12 bit fraction) */
            /* Put values on stack; does not take effect until the next DO CHAR. */
                (*(pstack+1)).xscale = (((*pstack).xscale * (fix31) gx) + 2048) >> 12;
                (*(pstack+1)).xscale_nom = (((*pstack).xscale_nom * (fix31) gx) + 2048) >> 12;
                (*(pstack+1)).yscale =  (((*pstack).yscale * (fix31) gy) + 2048) >> 12;
                (*(pstack+1)).yscale_nom = (((*pstack).yscale_nom * (fix31) gy) + 2048) >> 12;

#ifdef CONVERTDBG
                printf("    Set scale    x = %.2f   y = %.2f\n",
                    (real) ((*(pstack+1)).xscale) / 4096.0, (real) ((*(pstack+1)).yscale) / 4096.0);
#endif

                break;      /* End case 6 */

                                                                
            case 7:         /* Set new origin offsets to gx, gy.  */
            /* Put values on stack; does not take effect until the next DO CHAR. */
                (*(pstack+1)).xoff = (*pstack).xoff + (((*pstack).xscale * (fix31) gx + 2048) >> 12);
                (*(pstack+1)).yoff = (*pstack).yoff + (((*pstack).yscale * (fix31) gy + 2048) >> 12); 

#ifdef CONVERTDBG
                printf("    Set origin   x = %.2f   y = %.2f\n",
                    (real) (*(pstack+1)).xoff, (real) (*(pstack+1)).yoff);
#endif

                break;      /* End case 7 */


            case 12:        /* do char (gx) */
            /* Push old values of x and y scaling and offsets onto stack. Set */
            /* up new stack frame for next DOCHAR (DOCHAR's can be nested).   */
                (*pstack).pc = pthis_rec;   /* save pointer to outline data */
                stack_count++;
                if (stack_count >= 16)
                    {
                    report_error (ERROR,ER_DOCHAR_STACK_OVERFLOW,TRUE,"");
                    return(FALSE);      /* do not scan convert this character */
                    }

                pstack++;
                (*(pstack+1)).xoff = (*pstack).xoff;
                (*(pstack+1)).yoff = (*pstack).yoff;
                (*(pstack+1)).xscale = (*pstack).xscale;
                (*(pstack+1)).xscale_nom = (*pstack).xscale_nom;
                (*(pstack+1)).yscale = (*pstack).yscale;
                (*(pstack+1)).yscale_nom = (*pstack).yscale_nom;
               /* Set new pointer to outline data */
                pthis_rec = cfontp->chdir_dat[gx].outline_offs + pfirst_rec;
                open_put_cache_data();  /* prepare to read zone data  */
                curve_count = 0;        /* init curve count for sub-character */
                hier_count = 0;         /* init hierarchy count for sub-character */
                cur_char_no = gx;       /* new character offset number */

#ifdef CONVERTDBG
                printf("    Do sub char %ld,  xoff = ", gx);
                printf("%.2f  yoff = %.2f,   xscale = %.2f  yscale = %.2f\n",
                       (*pstack).xoff, (*pstack).yoff,
                       (real) (*pstack).xscale / 4096.0, (real) (*pstack).yscale / 4096.0);
#endif

                break;      /* End case 12 */

            case 0:         /* End of character */
                if (stack_count == 0)   /* if nothing on stack, character is done */
                    {

#ifdef CONVERTDBG
                    printf("    End char\n");
#endif
                    if (curve_count && ((x_oru != x_oru_init) || (y_oru != y_oru_init)))
                            {
                            report_error (ERROR,ER_CURVE_DIDNT_CLOSE_AT_ENDCHAR,TRUE,"");
                            }
                    /* We be done. Drop out of "get_rec" while into "more_band" while */
                    getrec_more = FALSE;
                    }
                else                    /* get old values back from the stack */
                    {
                    stack_count--;
                    pstack--;
                    (*(pstack+1)).xoff = (*pstack).xoff;
                    (*(pstack+1)).yoff = (*pstack).yoff;
                    (*(pstack+1)).xscale = (*pstack).xscale;
                    (*(pstack+1)).xscale_nom = (*pstack).xscale_nom;
                    (*(pstack+1)).yscale = (*pstack).yscale;
                    (*(pstack+1)).yscale_nom = (*pstack).yscale_nom;
                    pthis_rec = (*pstack).pc;

#ifdef CONVERTDBG
                    printf("    End sub char  xoff = ");
                    printf("%d  yoff = %d,   xscale = %.2f  yscale = %.2f\n",
                           (*pstack).xoff, (*pstack).yoff,
                           (real) (*pstack).xscale / 4096.0, (real) (*pstack).yscale / 4096.0);
#endif
                    }
#if VECT_OUT
                if (mode_2)
                    {
                    if (!non_blank_char)
                        {
                        do_comp_xy_trans((fix15) (cfontp->chdir_dat[root_char_nr].set_width),
                                                   0, &x_fpxl, &y_fpxl);
                        open_outline(((real) x_fpxl) / 8.0);
                        }
                    else if (!whitewrite && !twoendchars)
                        {
                        close_curve();
                        twoendchars = TRUE;
                        }
                    }
#endif
#if WHITE_WRITER
                if (whitewrite && !twoendchars)
                    {
                    empty_pipe();
                    twoendchars = TRUE;
                    }                       
#endif
                break;      /* End case 0 */
  

            case 8:         /* Set X extents (gx, gy) */
                if (stack_count == 0)
                    {
                    x_oru_min = gx;
                    x_oru_max = gy;
                    /* Squeeze character if enabled and character exceeds limits */
                    /* Set appropriate adjust variables */
                    if (squeeze_left && (x_oru_min < left_limit))
                        {
                        left_limit_adj = x_oru_min;
                        stack[0].xscale = stack[1].xscale = 
                            reqd_width / (right_limit_adj - left_limit_adj);
                        stack[0].xoff = stack[1].xoff = 
                            (fix15) ((real) ((left_limit - left_limit_adj) * stack[0].xscale) / 4096.0);
                        x_scale_adj = TRUE;
                        }
                    if (squeeze_right && (x_oru_max > right_limit))
                        {
                        right_limit_adj = x_oru_max;
                        stack[0].xscale = stack[1].xscale = 
                            reqd_width / (right_limit_adj - left_limit_adj);
                        stack[0].xoff = stack[1].xoff = 
                            (fix15) ((real) ((left_limit - left_limit_adj) * stack[0].xscale) / 4096.0);
                        x_scale_adj = TRUE;
                        }
                    }

#ifdef CONVERTDBG
                printf("    X extents: min = %d, max = %d\n", gx, gy);
#endif

                break;          /* End case 8 */

            case 10:            /* Set Y extents (gx, gy) */
                if (stack_count == 0)
                    {
                    y_oru_min = gx;
                    y_oru_max = gy;
                    /* Squeeze character if enabled and character exceeds limits */
                    /* Set appropriate adjust variables */
                    if (squeeze_bottom && ((((fix31) y_oru_min) << 12) < bottom_limit))
                        {
                        bottom_limit_adj = y_oru_min;
                        }
                    fixer = bottom_limit / bottom_limit_adj;
                    if (fixer < stack[0].yscale)
                        {
                        stack[0].yscale = stack[1].yscale = fixer;
                        y_scale_adj = TRUE;
                        }
                    if (squeeze_top && (((fix31) y_oru_max << 12) > top_limit))
                        {
                        top_limit_adj = y_oru_max;
                        }
                    fixer = top_limit / top_limit_adj;
                    if (fixer < stack[0].yscale)
                        {
                        stack[0].yscale = stack[1].yscale = (ufix16) fixer;
                        y_scale_adj = TRUE;
                        }
                    }

#ifdef CONVERTDBG
                    printf("    Y extents: min = %d, max = %d\n", gx, gy);
#endif

                break;      /* End case 10 */

            case 13:        /* Hierarchy value (gx) */
                hierarchy[hier_count++] = gx;
         
#ifdef CONVERTDBG
                printf("    Hierarchy: %d\n", gx);
#endif  

                break;      /* End case 13 */
                            
            case 14:        /* Plaid x zone data - gx = low edge, gy = high edge,
                               beta is P, L, C, function flags and minimum pixels */

#ifdef CONVERTDBG
                printf("    Plaid X zone data: From %5d to %5d PLC = %1d%1d%1d FN flag = %1d Min = %d\n",
                    gx,
                    gy,
                    ((beta >> 15) & 0x1),
                    ((beta >> 14) & 0x1),
                    ((beta >> 13) & 0x1),
                    ((beta >> 11) & 0x3),
                    (beta & 0xff));
#endif

                put_cache_data(cur_char_no, (fix15) X_DIMENSION, gx, gy, beta, pthis_rec);
                break;      /* End case 14 */

            case 15:        /* Plaid Y zone data - same format as X zone data */

#ifdef CONVERTDBG
                printf("    Plaid Y zone data: From %5d to %5d PLC = %1d%1d%1d FN flag = %1d Min = %d\n",
                    gx, 
                    gy,
                    ((beta >> 15) & 0x1),
                    ((beta >> 14) & 0x1),
                    ((beta >> 13) & 0x1),
                    ((beta >> 11) & 0x3),
                    (beta & 0xff));
#endif

                put_cache_data(cur_char_no, (fix15) Y_DIMENSION, gx, gy, beta, pthis_rec);
                break;      /* End case 15 */


            default:        /* snafu */
                report_error (ERROR,ER_UNDEFINED_REC_TYPE,TRUE,"");
                return(FALSE);      /* skip remainder of this character */

                }           /***   END OF    switch (rec_type)   ***/
            }           /***  END OF outline processing loop   ***/
/* Now we're back in "more_bands" loop */
#ifdef CONVERTDBG
    printf("\n");
#endif
#if VECT_OUT
        if (mode_2)              
            {
            real_set_width = (real) (do_comp_x_trans(right_limit_adj * stack[0].xscale + 
                                     ((fix31) stack[0].xoff << 12), TRUE)) / 65536.0;
/****/                       /* changed .5 to .499, mby 5/11/88 */
            close_outline(real_set_width);
            more_bands = FALSE;
            }
        else if (first_pass)             /* First pass? */
#else
        if (first_pass)             /* First pass? */
#endif
            {
            set_width = (do_comp_x_trans(right_limit_adj * stack[0].xscale + ((fix31) stack[0].xoff << 12), TRUE)
/****/          + 32702) >> 16;         /* changed .5 to .499, mby 5/11/88 */

            if (x_scan_active)          /* If x_scan active, these bmap values are split ints */
                {
                bmap_xmin = (bmap_xmin + ROUND_DOWN) >> SHIFT_VAR; /* Round to nearest whole pixel units */
                bmap_xmax = (bmap_xmax + ROUND_UP) >> SHIFT_VAR; /* Round to nearest whole pixel units */
                }
                else
                {
                bmap_xmax = (bmap_xmax + char_round) >> char_shift;
                bmap_xmin = bmap_xmin >> char_shift;
                }

            /* search for y limits in intercept list */
/* here's the clipping parts */
            if (non_blank_char && (bmap_xmax >= bmap_xmin))
                {
                if (clip_left && (bmap_xmin < 0))
                        bmap_xmin = 0;

                if (clip_right && (bmap_xmax > set_width))
                        bmap_xmax = set_width;

                if (clip_top)
                    {
                    do_comp_xy_trans(
                        0,
                        (fix15)oru_top,
                        &x_fpxl,
                        &y_fpxl);
                    y_fpxl = (y_fpxl + 4) >> 3;
                    if (bmap_ymax > (y_fpxl - 1))
                        bmap_ymax = (y_fpxl - 1);
                    if (bmap_ymin > y_fpxl) /* All data above em square? */
                        {
                        bmap_xmin = bmap_xmax = 0;
                        bmap_ymin = bmap_ymax = 0;
                        more_bands = FALSE;     /* Finish loop */
                        intercept_oflow = TRUE; /* Don't draw anything */
                        }
                    }
                if (clip_bottom)
                    {
                    do_comp_xy_trans(
                        0,
                        (fix15)oru_bot,
                        &x_fpxl,
                        &y_fpxl);
                    y_fpxl = (y_fpxl + 4) >> 3;
                    if (bmap_ymin < y_fpxl)
                        bmap_ymin = y_fpxl;
                    if (bmap_ymax < y_fpxl) /* All data below em square? */
                        {
                        bmap_xmin = bmap_xmax = 0;
                        bmap_ymin = bmap_ymax = 0;
                        more_bands = FALSE;     /* Finish loop */
                        intercept_oflow = TRUE; /* Don't draw anything */
                        }
                    }
#ifdef CONVERTDBG
                printf("Bitmap parameters:\n");
                printf("    set_width = %d\n", set_width);
                printf("    min x = %d, max x = %d\n", bmap_xmin, bmap_xmax);
                printf("    min y = %d, max y = %d\n", bmap_ymin, (fix15)(bmap_ymax + 1));
                if (intercept_oflow) printf("Intercept overflow on first pass\n");
#endif
                open_bitmap(
                    set_width, 
                    bmap_xmin, bmap_xmax,
                    bmap_ymin, (fix15)(bmap_ymax + 1));
                /* We're still in "first pass TRUE" */
                if (intercept_oflow)    /* Intercept overflow in first pass? */
                    {
                    band_ymax = bmap_ymax;/* First band is as far as we got on this pass */
                    if (x_scan_active)    /* Vertical scanning active during first pass? */
                        {/* turn off x scan start character over 1 dimensional */
                        band_size = bmap_ymax - bmap_ymin;
                        band_ymin = bmap_ymin;
                        x_scan_active = FALSE; /* Turn off vertical sampling */
                        char_shift = 4;
                        char_round = 8;
                        scan_shift = 20;
                        scan_round = 0x80000;
                        rules_shift = 12;                 
                        rules_round = 2048;
                        }
                    else
                        {/* start character over with banding */
                        band_size = (bmap_ymax - bmap_ymin + 2) >> 1;
                        band_ymin = band_ymax - band_size + 1;
                        }
                    first_pass = FALSE; /* Not first pass anymore */
                    } /* End of intercept overflow */
                else                    /* No intercept overflow in first pass? */
                    {
                    proc_intercepts();  /* Output bitmap data */
                    more_bands = FALSE; /* Finished */
                    }
                } /* End of Non-blank character */
            else                        /* Blank character? */
                {
                bmap_xmin = bmap_xmax = 0;
                bmap_ymin = bmap_ymax = 0;
                open_bitmap(
                    set_width, 
                    bmap_xmin, bmap_xmax,
                    bmap_ymin, bmap_ymax);
#ifdef CONVERTDBG
                printf("Bitmap parameters (blank character):\n");
                printf("  set_width = %d\n", set_width);
                printf("  min x = %d, max x = %d\n", bmap_xmin, bmap_xmax);
                printf("  min y = %d, max y = %d\n", bmap_ymin, bmap_ymax);
#endif
                more_bands = FALSE;     /* Finished */
                }
            } /* End of First Pass */
        else                            /* Not first pass? */
            {
            if (intercept_oflow)        /* Intercept overflow in banding pass? */
                {
                band_size = (band_size + 1) >> 1; /* Reduce band size */
                band_ymin = band_ymax - band_size + 1;
                }
            else                        /* No intercept overflow in banding pass? */
                {
                proc_intercepts();      /* Output bitmap data */
                band_ymax = band_ymin - 1;
                band_ymin = band_ymax - band_size + 1; /* Setup next band */
                if (band_ymin < bmap_ymin)
                    band_ymin = bmap_ymin;
                if (band_ymax < band_ymin) /* Next band is empty? */
                    more_bands = FALSE; /* Finished */
                }
            } /* end of NOT FIRST PASS condition */
        }                               /* End of banding loop */ 
if (!mode_2)
    close_bitmap();
    return(TRUE);
    END
                                                              

FUNCTION arc_to(dx, dy, depth)
fix15 dx;                /* X coordinate increment (orus) */
fix15 dy;                /* Y coordinate increment (orus) */
fix15 depth;             /* Number of remaining subdivisions required */

/*  Called by fw_make_char() to process an arc.
 *  Input arguments:
 *    dx -- X-increment in ORU space
 *    dy -- Y-increment in ORU space
 *    depth -- Number of recursive calls required
 *  Bulge factor for current depth has been pre-calculated in beta_tbl[depth]
 */

{
fix15 dx1, dy1;

dx1 = (dx - (((fix31)dy * beta_tbl[depth]) >> 16) + 1) >> 1;
dy1 = (dy + (((fix31)dx * beta_tbl[depth]) >> 16) + 1) >> 1;

if (depth)   /* Further arc subdivisions needed? */
    {
    depth--;
    arc_to(dx1, dy1, depth);
    arc_to((fix15)(dx - dx1), (fix15)(dy - dy1), depth);
    return;
    }
sub_oru_vector_to(dx1, dy1, oru_shift,oru_trunc);
sub_oru_vector_to((fix15)(dx - dx1), (fix15)(dy - dy1), oru_shift,oru_trunc);
}





FUNCTION init_intercepts()

/*  Called by fw_make_char() to initialize intercept storage data structure
 */

{
fix15 i;

#ifdef CONVERTDBG
printf("    Init intercepts (Y band from %d to %d)\n", band_ymin, band_ymax);
if (x_scan_active)
    printf("                    (X band from %d to %d)\n", band_xmin, band_xmax);
#endif 

intercept_oflow = FALSE;                /* Of course, because we're clearing the intercepts here */

no_y_lists = band_ymax - band_ymin + 1;                         /* Y lists is the number of y lines in band */
no_x_lists = (x_scan_active)? (band_xmax - band_xmin + 1): 0;   /* same for X, unless xscanning off         */
no_lists = no_x_lists + no_y_lists;                             /* Total lists is X + Y                     */
next_offset = no_lists;                                         /* allocate heads for each x and y line     */

if (no_lists >= MAX_INTERCEPTS)  /* Not enough room for list table? */
    {
#ifdef CONVERTDBG
printf("    Character too big to fit in intercept storage\n");
#endif
    no_lists = 0;
    band_ymin = band_ymax + 1;
    intercept_oflow = TRUE;
    } 

for (i = 0; i < no_lists; i++)
    {
    incpt_list[i].car = 0;
    incpt_list[i].cdr = (ufix16 near*)&nil_element;
    }

if (first_pass)             /* Not in banding mode? */
    {
    bmap_xmin = 32000;               /* ... then the sky's the limit */
    bmap_xmax = -32000;
    bmap_ymin = 32000;
    bmap_ymax = -32000;
    }
}

FUNCTION add_y_intercept(y, x)
fix15 y;       /* Y coordinate in pixel units (0 is first sample above baseline) */
fix15 x;       /* X coordinate of intercept in sub-pixel units */

/*  Called by do_vector() to add the X value of an intercept with a horizontal scan line
 *  at position Y into the intercept list structure
 */

{
fix15 i;
intrcpt_element near *cdr_ptr, near *n_ptr, near *h_ptr;

#ifdef CONVERTDBG
printf("    Add Y intercept, (y, x) = (%2d, %2d)\n", y, x);
#endif

if (first_pass)                /* First pass? */
    {
    if ((y > band_ymax) || (y < band_ymin))        /* Y value outside band range? */
        {
#ifdef CONVERTDBG
printf("    Intercept bands exceeded\n");
#endif
        intercept_oflow = TRUE;
        return;
        }
    }
else                           /* Banding pass? */
    {
    if ((y > band_ymax) || (y < band_ymin))         /* Y value outside band range? */
        return;
    }

if (intercept_oflow)           /* Intercept overflow? */
    return;


h_ptr = &incpt_list[y - band_ymin]; /* get pointer to head of list */
if (h_ptr->car++ != 0)              /* if number of list elements (now incremented) is not 0 */
    {
    for(cdr_ptr = (intrcpt_element near*)h_ptr->cdr;
        (cdr_ptr != &nil_element) &&
        (cdr_ptr->sub_char_num == char_count) &&
        (cdr_ptr->car < x);
        cdr_ptr = (intrcpt_element near*)h_ptr->cdr)
        h_ptr = cdr_ptr;
    }

n_ptr = &incpt_list[next_offset++];
/* Insert new item between head and cdr ("rest of") list (may be empty list) */
n_ptr->car = x;
n_ptr->cdr = h_ptr->cdr;
n_ptr->sub_char_num = char_count;
h_ptr->cdr = (ufix16 near*)n_ptr;

done:
if (next_offset >= MAX_INTERCEPTS) /* Intercept buffer full? */
    intercept_oflow = TRUE;
#ifdef CONVERTDBG
if (intercept_oflow) printf("    Overflow during Y insertion\n");
#endif
return;
                  
}

FUNCTION add_x_intercept(x, y)
fix15 x;       /* X coordinate in pixel units (0 is first sample to the right of
                  the left side bearing) */
fix15 y;       /* Y coordinate of intercept in sub-pixel units */

/*  Called by do_vector() to add the Y coordinate of an intercept with a vertical scan line
 *  at position X into the intercept list structure
 */

{
fix15 i, x_temp;
intrcpt_element near *cdr_ptr, near *h_ptr, near *n_ptr;


#ifdef CONVERTDBG
printf("    Add X intercept, (x, y) = (%2d, %2d)\n", x, y);
#endif

if (first_pass)                /* First pass? */
    {
    if (x > band_xmax)         /* X value outside band range? */
        {
        report_error (ERROR,ER_X_2BIG_4BAND,TRUE,"");
        intercept_oflow = TRUE;
        return;
        }
    if (x < band_xmin)         /* X value outside band range? */
        {
        report_error (ERROR,ER_X_2SMALL_4BAND,TRUE,"");
        intercept_oflow = TRUE;
        return;
        }
    }
else                           /* Banding pass? */
    {
    return;                    /* Ignore intercept */
    }

if (intercept_oflow)           /* Intercept overflow? */
    return;

h_ptr = &incpt_list[x + no_y_lists - band_xmin];

if (h_ptr->car++ != 0)              /* if number of list elements (now incremented) is not 0 */
    {
    for(cdr_ptr = (intrcpt_element near*)h_ptr->cdr;
        (cdr_ptr != &nil_element) &&
        (cdr_ptr->sub_char_num == char_count) &&
        (cdr_ptr->car < y);
        cdr_ptr = (intrcpt_element near*)h_ptr->cdr)
        h_ptr = cdr_ptr;
    }

n_ptr = &incpt_list[next_offset++];

/* Insert next item between car and cdr ("rest of") list (may be empty list) */
n_ptr->car = y;
n_ptr->cdr = h_ptr->cdr;
h_ptr->cdr = (ufix16 near*)n_ptr;
n_ptr->sub_char_num = char_count;

if (next_offset >= MAX_INTERCEPTS) /* Intercept buffer full? */
    intercept_oflow = TRUE;

#ifdef CONVERTDBG
if (intercept_oflow) printf("    Overflow during X insertion\n");
#endif
return;
}

#if WHITE_WRITER
FUNCTION vector_ww(dx, dy)
fix15 dx;                /* X coordinate increment (orus) */
fix15 dy;                /* Y coordinate increment (orus) */

/*  Called by main loop and arc_to() to scan convert one vector from the current
 *  point to a new point with the specified incremental coorinates.
 */

    DECLARE
    fix15     xs1, ys1;        /* Start of vector in pixel space (sub-pixels) */
    fix31     x, y;            /* half pixel thickening adjustments */
    fix31     dxdy;            /* slope dx/dy with 8 bits fractional */
    fix31     dxt, dyt;        
    fix31     xrs1, yrs1;      /* adjusted positions of x_spxl, y_spxl, 6 bits frac */
    fix31     mod_x_spxl, mod_y_spxl; /* modified endpoints after intersection calc */
    fix15     index;           /* index into half pixel adjustment table */
    fix15     y_max;

    BEGIN  
    xs1 = x_spxl;       /* X coord of start of vector in pixel space (sub-pixels) */
    ys1 = y_spxl;       /* Y coord of start of vector in pixel space (sub-pixels) */
    /* convert into transform coodinates */
    do_xy_trans((x_oru += dx), (y_oru += dy), &x_spxl, &y_spxl, rules_shift,0); 
    /* calculate some deltas */

    dxt = x_spxl - xs1;
    dyt = y_spxl - ys1;
    xrs1 = (fix31) ((x_spxl<<2)+normal[0][0]);  /* make xrs1 and yrs1 6 bits fractional */
    yrs1 = (fix31) ((y_spxl<<2)+normal[0][0]);

    if (dyt)                 /* if dyt or dxt is 0, no table lookup needed */
        {
        if (dxt)
            {
            dxdy = (dyt<<8) / dxt;       /* get slope */
            if (ABS(dxt) > ABS(dyt))
                 {                        /* read table based on slope */
                 index = ABS(dxdy); 
                 x = (fix31) normal[index][1];
                 y = (fix31) normal[index][0];
                 }
            else    /* slope > 1 so use 1/slope as index */
                 {
                 index = ABS((dxt<<8)/dyt);
                 x = (fix31) normal[index][0];
                 y = (fix31) normal[index][1];
                 } 
            } 
        else    /* dxt is 0, but dyt!=0 */
            {
            y = 0;
            x = (fix31) normal[0][0]; 
            }
        }
    else if (dxt)
        { /* dxt is not 0, but dyt is */
        x = dxdy = 0;
        y = (fix31) normal[0][0]; 
        } 
    else return; /* both dxt, dyt are 0 */

/* x and y are proper thickening adjustments now */

    if (inside_curve)             /* up or down */
        {
        xrs1 += (dyt > 0 ? x : -x); /* because its a normal, test dyt to determine x sign */
        yrs1 -= (dxt > 0 ? y : -y); /* because its a normal, test dxt to determine y sign */
        }
    else
        {
        xrs1 -= (dyt > 0 ? x : -x);
        yrs1 += (dxt > 0 ? y : -y);
        }

    if (!pipe_count)          /* if pipe_count is 0, then pipe is filled */
        { /* if pipe count is 0, we've set "finite" already */
        if (finite)             /* figure out intersection point based on this */
            {                   /* vector and previous vector */
                                /* when this is done, do previous vector and */
                                /* store data about current vector */
            if (dxt)
               {
               if (dxdy - old_dxdy)
                    {
                    mod_x_spxl = ((dxdy * xrs1 - old_dxdy * mod_xrs1 + ((mod_yrs1 - yrs1)<<8))
                           / (dxdy - old_dxdy));
                    mod_y_spxl = ((dxdy * (mod_x_spxl - xrs1))>>8) + yrs1;
                    } 
               else
                    {
                    mod_y_spxl = mod_yrs1;
                    mod_x_spxl = mod_xrs1;
                    }
               finite = TRUE;
               old_dxdy = dxdy;
               }
            else 
               { 
               mod_y_spxl = ((old_dxdy * (xrs1 - mod_xrs1))>>8) + mod_yrs1;
               mod_x_spxl = xrs1;
               finite = FALSE;
               }
            }
        else if (dxt)
            {
            mod_y_spxl =  ((dxdy * (mod_xrs1 - xrs1))>>8) + yrs1;
            mod_x_spxl =  mod_xrs1;
            finite = TRUE;
            old_dxdy = dxdy;
            } 
        else
            {
            mod_x_spxl =  mod_xrs1;
            mod_y_spxl =  mod_yrs1; 
            finite = FALSE;
            }
        mod_xrs1 = xrs1;             /* store adjusted points for intersection */
        mod_yrs1 = yrs1;             /* calc. on next vector */
        } 
    else /* pipe count is not 0. -1 is first vect, 1 is second */
        {                            /* start filling pipe */
        if (pipe_count < 0)          /* first vector, store adjusted points */
            {                        /* and slope */
            if (dxt)  /* if x delta not 0 */
                {
                orig_dxdy = dxdy;      /* store slope */
                finite = TRUE;         /* slope is finite */
                orig_finite = TRUE;    /* first in pipe is finite */
                }
            else      /* x delta is 0 so: */
                {
                finite = FALSE;         /* not finite */
                orig_finite = FALSE;    /* first vector is not finite either */
                }
            orig_xrs1 = xrs1;           /* store first vector xrs1 */
            orig_yrs1 = yrs1;           /* store first vector yrs1 */
            pipe_count = 1;             /* pipe count to next vector */
            return;
            } 
        else /* pipe count must be 1 here. Second vector */
            {                       /* more pipe filling with second vector */
            if (finite)             /* intersection point between first and */
                {                   /* second vector calc. stored for first */
                if (dxt)            /* full pipe line iteration */
                  { /* second vector is finite */
                  if (dxdy - orig_dxdy)
                    {/* because of vector movement, they don't meet head and tail anymore */
                     /* calculate meeting point here: */
                    mod_x_spxl = ((dxdy * xrs1 - orig_dxdy * orig_xrs1 + ((orig_yrs1 - yrs1)<<8))
                       / (dxdy - orig_dxdy));
                    mod_y_spxl = ((dxdy * (mod_x_spxl - xrs1))>>8) + yrs1;
                    }                  
                  else
                    { /* not finite has this intersect: */
                    mod_y_spxl = orig_yrs1;
                    mod_x_spxl = orig_xrs1;
                    }
                  finite = TRUE;   /* we know we're finite here */
                  old_dxdy = dxdy; /* save last dxdy */
                  }
                else /* second vector, not finite, but last vector was */
                  { 
                  mod_y_spxl = ((orig_dxdy * (xrs1 - orig_xrs1))>>8) + orig_yrs1;
                  mod_x_spxl = xrs1;
                  finite = FALSE;
                  }
                }
            else if (dxt) /* last vector was not finite, is this one? */
                { /* yes it is. Calculate intersection: */
                mod_y_spxl = ((dxdy * (orig_xrs1 - xrs1))>>8) + yrs1;
                mod_x_spxl = orig_xrs1;
                finite = TRUE;
                old_dxdy = dxdy;
                } 
              else /* both not finite */
                {
                mod_x_spxl = orig_xrs1;
                mod_y_spxl = orig_yrs1;
                finite = FALSE;
                }
           mod_xs1 = orig_x_spxl =  mod_x_spxl>>2;
           mod_ys1 = orig_y_spxl =  mod_y_spxl>>2;
           mod_xrs1 = xrs1;
           mod_yrs1 = yrs1;
           y_pxl = (mod_ys1 + 8) >> 4; /* Update y_pxl to end of vector */ 
           pipe_count = 0;             /* pipe full, start doing vectors on next */
                                       /* call to vector_to() */
#if VECT_OUT
           if (mode_2)
                start_curve(((real) orig_x_spxl) / divisor, 
                            ((real) orig_y_spxl) / divisor, !inside_curve);
#endif
           return;
           } /* end of pipe==1 */
        } /* end of pipe != 0  */

    mod_x_spxl >>= 2;                /* get points in 4 bit frac. format */
    mod_y_spxl >>= 2;                /* for call to do_vector() */
/* have we generated a really really sharp point? */
    if ((ABS(mod_x_spxl - xs1) > 80) || 
       (ABS(mod_y_spxl - ys1) > 80))
        {
        mod_x_spxl = xs1; /* if so, undo fix at this point */
        mod_y_spxl = ys1;
        }
#if VECT_OUT  
    if (mode_2)
        {
        line_to(((real) mod_x_spxl) / divisor, ((real) mod_y_spxl) / divisor);
        mod_xs1 = mod_x_spxl;            /* store end point for next vector's */
        mod_ys1 = mod_y_spxl;            /* start point */
        return;
        }   
#endif
    /* pipe is full, start doing vectors */
    y_pxl = (mod_y_spxl + char_round) >> char_shift; /* Update y_pxl to end of vector */ 
    y_max = y_pxl - 1;

 if (first_pass)                /* First pass? */
    {
    if (mod_x_spxl > bmap_xmax)         
        bmap_xmax = mod_x_spxl;
    if (mod_x_spxl < bmap_xmin)
        bmap_xmin = mod_x_spxl;
    if (y_max > bmap_ymax)
        bmap_ymax = y_max;
    if (y_pxl < bmap_ymin)
        bmap_ymin = y_pxl;
    }
    draw_vector_to(mod_xs1,mod_ys1, (fix15) mod_x_spxl, (fix15) mod_y_spxl, add_y_intercept);
    mod_xs1 = mod_x_spxl;            /* store end point for next vector's */
    mod_ys1 = mod_y_spxl;            /* start point */

    END

FUNCTION empty_pipe()
    {
    fix31   last_x, last_y, y_max;

    if (orig_finite)
        { 
        if (finite)
            {
            if (old_dxdy - orig_dxdy)
              {
              last_x =  ((old_dxdy * mod_xrs1 - orig_dxdy * orig_xrs1 + ((orig_yrs1 - mod_yrs1)<<8))
                           / (old_dxdy - orig_dxdy));
              last_y =  ((old_dxdy * (last_x - mod_xrs1))>>8) + mod_yrs1; 
              }
            else
              {
              last_y =  mod_yrs1;
              last_x =  mod_xrs1;
              } 
            }
        else 
            { 
            last_y =  ((orig_dxdy * (mod_xrs1 - orig_xrs1))>>8) + orig_yrs1;
            last_x =   mod_xrs1;
            }
        }
    else if (finite) 
        {
        last_y =  ((old_dxdy * (orig_xrs1 - mod_xrs1))>>8) + mod_yrs1;
        last_x =  orig_xrs1;
        } 
    else
        {
        last_x =  mod_xrs1;
        last_y =  mod_yrs1;
        }
    last_x >>= 2;
    last_y >>= 2; 
    if ((ABS(last_x - x_spxl) > 80) || 
       (ABS(last_y - y_spxl) > 80))
        {
        last_x = x_spxl;
        last_y = y_spxl;
        }  
#if VECT_OUT
    if (mode_2)
        {
        line_to(((real) last_x) / divisor, ((real) last_y) / divisor);
        line_to(((real) orig_x_spxl) / divisor, ((real) orig_y_spxl) / divisor);
        close_curve();
        pipe_count = -1;
        return;
        }   
#endif
    y_pxl = (last_y + char_round) >> char_shift; /* Update y_pxl to end of vector */ 
    y_max = y_pxl - 1;

 if (first_pass)                /* First pass? */
    {
    if (last_x > bmap_xmax)         
        bmap_xmax = last_x;
    if (last_x < bmap_xmin)
        bmap_xmin = last_x;
    if (y_max > bmap_ymax)
        bmap_ymax = y_max;
    if (y_pxl < bmap_ymin)
        bmap_ymin = y_pxl;
    }
    draw_vector_to(mod_xs1, mod_ys1, (fix15) last_x, (fix15) last_y, add_y_intercept);
    y_pxl = (orig_y_spxl + char_round) >> char_shift; /* Update y_pxl to end of vector */ 
    y_max = y_pxl - 1;

 if (first_pass)                /* First pass? */
    {
    if (orig_x_spxl > bmap_xmax)         
        bmap_xmax = orig_x_spxl;
    if (orig_x_spxl < bmap_xmin)
        bmap_xmin = orig_x_spxl;
    if (y_max > bmap_ymax)
        bmap_ymax = y_max;
    if (y_pxl < bmap_ymin)
        bmap_ymin = y_pxl;
    }
    draw_vector_to((fix15) last_x, (fix15) last_y, orig_x_spxl, orig_y_spxl, add_y_intercept);
    pipe_count = -1;
    }           
#endif

FUNCTION vector_to(dx, dy)
fix15 dx;                /* X coordinate increment (orus) */
fix15 dy;                /* Y coordinate increment (orus) */

/*  Called by vector_to() to scan convert one vector from the current
 *  point to a new point with the specified incremental coorinates.
 */

    DECLARE
    fix15     x0, y0, y_max;

    BEGIN 
#if WHITE_WRITER
    if (whitewrite)
        {
        vector_ww(dx, dy);
        return;
        }
#endif
    x0 = x_spxl;       /* X coord of start of vector in pixel space (sub-pixels) */
    y0 = y_spxl;       /* Y coord of start of vector in pixel space (sub-pixels) */
    /* get end coordinates */
    do_xy_trans((x_oru += dx), (y_oru += dy), &x_spxl, &y_spxl, rules_shift,0);

#if VECT_OUT
    if (mode_2)
        {
        line_to(((real) x_spxl) / divisor, ((real) y_spxl) / divisor);
        return;
        }   
#endif
    y_pxl = (y_spxl + char_round) >> char_shift; /* Update y_pxl to end of vector */ 
    y_max = y_pxl - 1;

 if (first_pass)                /* First pass? */
    {
    if (x_spxl > bmap_xmax)         
        bmap_xmax = x_spxl;
    if (x_spxl < bmap_xmin)
        bmap_xmin = x_spxl;
    if (y_max > bmap_ymax)
        bmap_ymax = y_max;
    if (y_pxl < bmap_ymin)
        bmap_ymin = y_pxl;
    }

    if (x_scan_active)
        {
        /* flip vector over, and do scan in y direction which turns out to be x direction and */
        /* tell it that it's NOT a white writer vector */
        x_pxl = (x_spxl + ROUND_UP) >> SHIFT_VAR; /* Update y_pxl to end of vector */ 
        draw_vector_to(y0, x0, y_spxl, x_spxl, add_x_intercept);
        }

    draw_vector_to(x0,y0,x_spxl,y_spxl,add_y_intercept);
}
  
FUNCTION sub_oru_vector_to(dx, dy, o_shift, o_trunc)
fix15 o_shift,o_trunc;
fix15 dx;                /* X coordinate increment (orus) */
fix15 dy;                /* Y coordinate increment (orus) */

/*  Called by vector_to() to scan convert one vector from the current
 *  point to a new point with the specified incremental coorinates.
 */

    DECLARE
    fix15     x0, y0, y_max;

    BEGIN 
    dx += frac_x_oru;
    dy += frac_y_oru;
    frac_x_oru = dx & o_trunc;
    frac_y_oru = dy & o_trunc;

#if WHITE_WRITER
    if (whitewrite)
        {
        vector_ww(dx >> o_shift, dy >> o_shift);
        return;
        }
#endif

    x0 = x_spxl;       /* X coord of start of vector in pixel space (sub-pixels) */
    y0 = y_spxl;       /* Y coord of start of vector in pixel space (sub-pixels) */
    x_oru += (dx >> o_shift);
    y_oru += (dy >> o_shift);

    /* get end coordinates */

    do_xy_trans((x_oru << o_shift) + frac_x_oru, 
                        (y_oru << o_shift) + frac_y_oru,
                        &x_spxl, &y_spxl, 
                        rules_shift, o_shift);
#if VECT_OUT
    if (mode_2)
        {
        line_to(((real) x_spxl) / divisor, ((real) y_spxl) / divisor);
        return;
        }   
#endif
    y_pxl = (y_spxl + char_round) >> char_shift; /* Update y_pxl to end of vector */ 
    y_max = y_pxl - 1;

 if (first_pass)                /* First pass? */
    {
    if (x_spxl > bmap_xmax)         
        bmap_xmax = x_spxl;
    if (x_spxl < bmap_xmin)
        bmap_xmin = x_spxl;
    if (y_max > bmap_ymax)
        bmap_ymax = y_max;
    if (y_pxl < bmap_ymin)
        bmap_ymin = y_pxl;
    }

    if (x_scan_active)
        {
        /* flip vector over, and do scan in y direction which turns out to be x direction and */
        /* tell it that it's NOT a white writer vector */
        x_pxl = (x_spxl + ROUND_UP) >> SHIFT_VAR; /* Update y_pxl to end of vector */ 
        draw_vector_to(y0, x0, y_spxl, x_spxl, add_x_intercept);
        }

    draw_vector_to(x0,y0,x_spxl,y_spxl,add_y_intercept);
}
FUNCTION proc_intercepts()

/*  Called by fw_make_char to output accumulated intercept lists
 *  Clips output to bmap_xmin, bmap_xmax, bmap_ymin, bmap_ymax boundaries
 *  bmap_xmin and bmap_xmax are in whole pixel units by the time 
 *  proc_intercepts() is called
 */

{
fix15 i;
intrcpt_element near *i_ptr, near *j_ptr, near *k_ptr, near *l_ptr;
fix15 first_i, last_i;
fix15 from_spxl, to_spxl; /* Start and end of run in sub_pixel units */
fix15 from, to;           /* Start and end of run in pixel units   
                             relative to left extent of bitmap */
fix15 first_y, last_y;
fix15 x, y;
fix15 scan_line;

void set_bitmap_bits();

#ifdef CONVERTDBG
printf("\nIntercept lists:\n");
#endif

if (x_scan_active)      /* If xscanning, we need to make sure we don't miss any important pixels */
    {
    first_i = bmap_xmin - band_xmin + band_ymax -  band_ymin + 1;        /* start of x lists */
    last_i = first_i +  bmap_xmax - bmap_xmin - 1;                          /* end of x lists   */
    for (i = first_i; i <= last_i; i++)             /* scan all xlists  */
        {
        j_ptr = (intrcpt_element near*)incpt_list[i].cdr;                  /* get first intercept in list */
        while (j_ptr != &nil_element)               /* loop until end of list     */
            {
            /* make sure intercepts come in pairs! */
            if ((k_ptr = (intrcpt_element near*)j_ptr->cdr) == &nil_element)
                {
                report_error (ERROR,ER_UNMATCHED_PAIR_IN_X,TRUE,"");
                break;
                }
#ifdef CONVERTDBG
            printf("    X = %2d: from = %2d to = %2d:\n", 
                i - first_i + bmap_xmin, 
                ((j_ptr->car + ROUND_UP) >> SHIFT_VAR), 
                ((k_ptr->car + ROUND_UP) >> SHIFT_VAR));
#endif                           
            if (((k_ptr->car - j_ptr->car) < MAX_DIFF) &&
                (((j_ptr->car + ROUND_UP) >> SHIFT_VAR) 
                        == ((k_ptr->car + ROUND_DOWN) >> SHIFT_VAR)) && 
                (k_ptr->car > j_ptr->car))
                {
                l_ptr = (intrcpt_element near*)k_ptr->cdr;
                y = ((j_ptr->car + k_ptr->car) >> DIVIDE_BY) - band_ymin;
#ifdef CONVERTDBG
                printf("Add run at y = %d from x = %d to x = %d\n",
                    y + band_ymin, (i - first_i + bmap_xmin), (i - first_i + bmap_xmin + 1));
#endif                           
                k_ptr->cdr = incpt_list[y].cdr;
                incpt_list[y].cdr = (ufix16 near*)j_ptr;
                k_ptr->car = (j_ptr->car = 
                       (i - first_i + bmap_xmin) << SHIFT_VAR) + MAX_DIFF - 1;
                j_ptr = l_ptr;
                } 
            else 
                {
                j_ptr = (intrcpt_element near*)k_ptr->cdr;
                }
            }
        }       /* end of list */
    }

if (first_pass)
    {
    first_y = bmap_ymax - band_ymin;
    last_y = bmap_ymin - band_ymin;
    scan_line = 0;
    }
else
    {
    first_y = band_ymax - band_ymin;
    last_y = 0;
    scan_line = bmap_ymax - band_ymax;
    }

for (y = first_y; y >= last_y; y--, scan_line++)
    {
    i_ptr = &incpt_list[y];
    while ((i_ptr = (intrcpt_element near*)i_ptr->cdr) != &nil_element)
        {
        from = ((from_spxl = i_ptr->car) + char_round) >> char_shift;
        if ((from -= bmap_xmin) < 0)
            from = 0;
        if ((i_ptr = (intrcpt_element near*)i_ptr->cdr) == &nil_element)
            {/* Intercepts have to come in ON/OFF pairs! */
            report_error (ERROR,ER_UNMATCHED_PAIR_IN_Y,TRUE,"");
            break;
            }
        to = ((to_spxl = i_ptr->car) + char_round) >> char_shift; 
        to = (to > bmap_xmax) ? (bmap_xmax - bmap_xmin) : (to - bmap_xmin);
#ifdef CONVERTDBG
        printf("    Y = %2d (scanline %2d): %2d %2d:\n", 
            y + band_ymin, scan_line, from, to);
#endif
        if (to > from)    /* At least one pixel in run? */
            {
            set_bitmap_bits(scan_line, from, to);
            }
        else if (to_spxl > from_spxl)  /* At least one sub-pixel in run? */
            {
            from = ((from_spxl + to_spxl) >> (char_shift + 1)) - bmap_xmin;
            to = from + 1;
            if ((from >= 0) && (to <= (bmap_xmax - bmap_xmin)))
                {
                set_bitmap_bits(scan_line, from, to);
                }
            }
        } /* end of while */
    } /* End of y scan line loop */
} /* End of Process Intercepts */

FUNCTION  fix31  get_required_width (cfont, char_offset)
cft_outl_str *cfont;     /* Pointer to outline font structure */
ufix16      char_offset; /* Offset of character whose width is required */

/*  GET_REQUIRED_WIDTH -- gets character width, either uses the nominal width or
 *                       gets the width from some other font
 *  Input arguments:
 *    cfont -- pointer to compressed font
 *    char_offset -- character offset sequence #
 *  Returns:
 *    character set width, long integer
 */

    DECLARE
    BEGIN
    return ((fix31)cfont->chdir_dat[char_offset].set_width);
    END

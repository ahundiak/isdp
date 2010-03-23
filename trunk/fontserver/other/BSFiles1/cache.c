




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************** C A C H E . C *******************************
 ********************* R E V I S I O N   H I S T O R Y *********************

 1)  02-Apr-86  mby   Added reinit_cache()

 2)  15-Apr-86  jsc   Added mechanism to keep list of character numbers with
                      zone data in cache. The list is updated as characters
                      are added to the cache. The list is used to clear the
                      unrounded and rounded pixel values of cached characters

 3)  12-Nov-86  jsc   cache_data() changed from void to boolean.

                      put_cache_data() changed to abandon loading data if
                      cache overflow occurs.

 4)  28-Nov-86  jsc   cache_fpixels() modified to set cached pixels of
                      zone to -1 to ensure recalculation.

 5)  03-Apr-87  mby   cache_fpixels() modified to store a value of 0 if the
                      argument is negative.

 ***************************************************************************

   This is the mechanism for caching zone data and the rounded and unrounded
   pixel values associated with each zone.                                   

 *****************************************************************************/


#include "../hfiles/stdef.h"      /* Bitstream standard macros  */
#include "../hfiles/comp2_3.h"    /* data structures for compressed font */
#include "../hfiles/mkbm.h"
#include "../hfiles/math.h"



/***** MODULE STATIC *****/

static fix15    cache_x_offsets[MAX_CHARS];    /* Offset to first zone in X dimension */
static fix15    cache_no_x_zones[MAX_CHARS];   /* Number of zones in X dimension */
static float    cache_x_scale;                 /* Current X dimension scale factor for scaled cache */
static float    cache_x_pixperem;              /* Current pixels per em in X dimension */
static fix15    cache_y_offsets[MAX_CHARS];    /* Offset to first zone in Y dimension */
static fix15    cache_no_y_zones[MAX_CHARS];   /* Number of zones in Y dimension */
static float    cache_y_scale;                 /* Current Y dimension scale factor for scaled cache */
static float    cache_y_pixperem;              /* Current pixels per em in Y dimension */
static fix15    next_cache_offset;             /* Offset to next empty character */

static fix31    from_cache[MAX_CACHE_ZONES];   /* Start coordinate of zone */
static fix31    to_cache[MAX_CACHE_ZONES];     /* End coordinate of zone */
static ufix16   flags_cache[MAX_CACHE_ZONES];  /* Zone flags as follows... */
                                               /*   Bit 15:     Propagate flag (parent zone) */
                                               /*   Bit 14:     Level flag */
                                               /*   Bit 13:     Continue flag */
                                               /*   Bits 12-11: Function flags */
                                               /*   Bits 7-0:   Minimum number of pixels */
static ufix16  *pfunct_cache[MAX_CACHE_ZONES]; /* Pointer to constraint function */
static fix15    pixels_cache[MAX_CACHE_ZONES]; /* Rounded number of pixels at full scale */
static fix15    scaled_pixels_cache[MAX_CACHE_ZONES]; /* Rounded number of pixels at cache_[xy]_scale */
static float    fpixels_cache[MAX_CACHE_ZONES]; /* Unrounded number of pixels at full scale */
static float    scaled_fpixels_cache[MAX_CACHE_ZONES]; /* Unrounded number of pixels at cache_[xy]_scale */

static fix15    put_cache_dimension;           /* Current dimension being written to cache */
static fix15    put_cache_char_no;             /* Current character being written to cache */
static fix15    put_cache_zone_no;             /* Current zone number */

static ufix16   cache_char_x_list[MAX_CHARS];  /* List of char numbers with X zone data in cache */
static fix15    cache_no_x_chars;              /* Number of characters with X zone data in cache */
static ufix16   cache_char_y_list[MAX_CHARS];  /* List of char numbers with Y zone data in cache */
static fix15    cache_no_y_chars;              /* Number of characters with Y zone data in cache */


FUNCTION init_cache (pixem_x, pixem_y)
float    pixem_x, pixem_y;         /* x, y pixels per em */
/* Called by main to initialize cache to empty condition before first use
   and after change of font                                                   */
{
fix15 i;

cache_no_x_chars = 0;             /* Clear list of chars with X zones in cache */
cache_no_y_chars = 0;             /* Clear list of chars with Y zones in cache */
next_cache_offset = 0;            /* Start at beginning of cache */
for (i = 0; i < MAX_CHARS; i++)
    {
    cache_x_offsets[i] = -1;      /* Mark character X zone data not in cache */
    cache_y_offsets[i] = -1;      /* Mark character Y zone data not in cache */
    }
cache_x_pixperem = pixem_x;       /* Set main cache scale */
cache_y_pixperem = pixem_y;
cache_x_scale = 1.0;              /* Reset scaled cache scale */
cache_y_scale = 1.0;
open_put_cache_data();
}


FUNCTION  void  reinit_cache (pointsize_x, pointsize_y,
                              res_hor, res_ver, arot, aobl)
  float    pointsize_x, pointsize_y;   /* x, y pointsizes */
  float    res_hor, res_ver;           /* resolution in x, y (dpi) */
  float    arot, aobl;                 /* rotation & obliquing angles */

  /*  Initializes cache if pixels per em (calculated from x & y pointsize and
   *  res_hor and res_ver) changes in either dimension. Pixels per em is
   *  checked only in a dimension in which the zone data is valid.
   *  1) orthogonal rotation, no obliquing:  x & y
   *  2) orthogonal rotation, obliquing:  y-dimension of the character
   *  3) nonorthogonal rotation, (obliquing + rotation) is orthogonal (within
   *      < .01 degrees):                                                   */

    DECLARE
    double qq, qqq;
    double rotplusobl;
    float  x_pem, y_pem;     /* character pixels per em in x, y dimensions */
    bool    x_check, y_check;
    fix     init_cache();

    BEGIN
    qq = arot / 360.;
    arot -= floor(qq) * 360.;
    qq = aobl / 180.;
    aobl -= floor(qq) * 180.;
    if (aobl > 90.)  aobl -= 180.;
    rotplusobl = arot + aobl;
    qq = 90. * floor((rotplusobl / 90.) + 0.5);
    qqq = qq - rotplusobl;
    if ((ABS(qqq)) < .01)           /* threshold of .01 degree */
        rotplusobl = qq;

    if (arot == 0.  ||  arot == 180.)       /* orthogonal rotation angle */
        {
        if (aobl == 0.)                     /* no obliquing */
            {
            x_pem = pointsize_x * res_hor / PTPERINCH;
            y_pem = pointsize_y * res_ver / PTPERINCH;
            x_check = TRUE;
            y_check = TRUE;
            }
        else                                /* with obliquing */
            {
            x_pem = pointsize_x * res_hor / PTPERINCH;
            y_pem = pointsize_y * res_ver / PTPERINCH;
            x_check = FALSE;
            y_check = TRUE;
            }
        }
    else if (arot == 90.  ||  arot == 270.)     /* orthogonal rotation angle */
        {
        if (aobl == 0.)                         /* no obliquing */
            {
            x_pem = pointsize_x * res_ver / PTPERINCH;
            y_pem = pointsize_y * res_hor / PTPERINCH;
            x_check = TRUE;
            y_check = TRUE;
            }
        else                                    /* with obliquing */
            {
            x_pem = pointsize_x * res_ver / PTPERINCH;
            y_pem = pointsize_y * res_hor / PTPERINCH;
            x_check = FALSE;
            y_check = TRUE;
            }
        }
    else                    /* nonorthogonal rotation angle */
        {
        if (rotplusobl == 0.  ||  rotplusobl == 180.  ||  rotplusobl == 360.)
            {
            x_pem = pointsize_x * res_hor / PTPERINCH;  /* obliquing cancels  */
            y_pem = pointsize_y * res_ver / PTPERINCH;  /* rotation in an up- */
            x_check = TRUE;                             /* down orientation   */
            y_check = FALSE;
            }
        else if (rotplusobl == 90.  ||  rotplusobl == 270.)
            {
            x_pem = pointsize_x * res_ver / PTPERINCH;  /* obliquing cancels  */
            y_pem = pointsize_y * res_hor / PTPERINCH;  /* rotation in a    */
            x_check = TRUE;                   /* left-right orientation   */
            y_check = FALSE;
            }
        else                        /* obliquing does not cancel rotation */
            {                       /* zone data cannot be used */
            x_check = FALSE;
            y_check = FALSE;
            }
        }

    if (x_check)
        {
        if (ABS (x_pem - cache_x_pixperem) > .01)
            {
            clear_x_cache();                /* Clear cached data in X */
            cache_x_pixperem = x_pem;       /* Update main cache scale */
            cache_x_scale = 1.0;            /* Reset scaled cache scale */
            }
        }
    if (y_check)
        {
        if (ABS (y_pem - cache_y_pixperem) > .01)
            {
            clear_y_cache();                /* Clear cached data in y */
            cache_y_pixperem = y_pem;       /* Update main cache scale */
            cache_y_scale = 1.0;            /* Reset scaled cache scale */
            }
        }

    return;
    END


FUNCTION open_put_cache_data()
/* Called by char_scan_convert() to prepare cache to accept zone data with
   put_cache_data() calls                                                    */
{
put_cache_dimension = -1;        /* Flag no dimension selected */
}





FUNCTION close_put_cache_data()
/* Called by setup_trans() to terminate input of zone data            
   Also called by put_cache_data() to terminate input of zone data in one
   dimension when change of dimension is detected                            */
{
if (put_cache_dimension == X_DIMENSION)
    {
    cache_x_offsets[put_cache_char_no] = next_cache_offset;
    cache_no_x_zones[put_cache_char_no] = put_cache_zone_no;
    next_cache_offset += put_cache_zone_no;
    cache_char_x_list[cache_no_x_chars++] = put_cache_char_no;
    }
else if (put_cache_dimension == Y_DIMENSION)
    {
    cache_y_offsets[put_cache_char_no] = next_cache_offset;
    cache_no_y_zones[put_cache_char_no] = put_cache_zone_no;
    next_cache_offset += put_cache_zone_no;
    cache_char_y_list[cache_no_y_chars++] = put_cache_char_no;
    }
}








FUNCTION put_cache_data(char_no, dimension, from, to, flags, pfunct)
ufix16 char_no;         /* Character offset */
fix15 dimension;        /* 0 if x zone, 1 if y zone */
fix31 from;             /* zone start coordinate */
fix31 to;               /* zone end coordinate */
ufix16 flags;           /* zone flags */
ufix16 *pfunct;         /* pointer to constraint function if any */
/* Called by char_scan_convert() to add zone data to cache                   */
{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    if (cache_x_offsets[char_no] >= 0)      /* Character already cached? */
        return;
    }
else
    {
    if (cache_y_offsets[char_no] >= 0)      /* Character already cached? */
        return;
    }

if (put_cache_dimension == -2)              /* Cache previously filled? */
    return;

if ((dimension != put_cache_dimension) ||
    (char_no != put_cache_char_no))         /* New character or dimension? */
    {
    close_put_cache_data();
    put_cache_dimension = dimension;
    put_cache_char_no = char_no;
    put_cache_zone_no = 0;
    }

offset = next_cache_offset + put_cache_zone_no;
if (offset >= MAX_CACHE_ZONES)              /* Cache full? */
    {
    put_cache_dimension = -2;               /* Flag cache overflow */
    return;
    }

from_cache[offset] = from;                  /* Copy from coordinate into cache */
to_cache[offset] = to;                      /* Copy to coordinate into cache */
flags_cache[offset] = flags;                /* Copy P L C flags and MIN into cache */
pfunct_cache[offset] = pfunct;              /* Save pointer to constraint fn in cache */
pixels_cache[offset] = -1;                  /* Mark pixels value not available */
scaled_pixels_cache[offset] = -1;           /* Mark scaled pixels value not available */
fpixels_cache[offset] = -1.0;               /* Mark fpixels value not available */
scaled_fpixels_cache[offset] = -1.0;        /* Mark scaled fpixels value not available */
put_cache_zone_no++;
}


FUNCTION boolean cache_data(char_no, dimension, cfont, pfirst_rec)
ufix16      char_no;      /* Character offset */
fix15       dimension;    /* 0 if x zone, 1 if y zone */
cft_outl_str  *cfont;     /* pointer to compressed font data structure  */
ufix16     *pfirst_rec;   /* pointer to first record in font outline data */
/* Called by get_pixels() and get_fpixels() to ensure that zone data for the
   specified dimension of the specified character is present in the cache.
   If not, the appropriate zone data is read and added to the cache.
   returns TRUE if the requested data is in the cache on exit.
   returns FALSE if the requested data cannot be loaded into the cache.   */
{
ufix16 *prec;
fix15 offset;
fix15 type;
fix31 from, to, beta;
void init_rec_state();
int get_rec();

if (dimension == X_DIMENSION) /* X dimension? */
    {
    if (cache_x_offsets[char_no] >= 0) /* X zone data already in cache? */
        return(TRUE);
    prec = cfont->outl_dat + cfont->chdir_dat[char_no].outline_offs;
    offset = next_cache_offset;
    init_rec_state(1);        /* Initialize get_rec state read stream 1 */
    for (;;)
        {
        get_rec(1, &prec, pfirst_rec, &type, &from, &to, &beta);
        if (type == 14)       /* Plaid X zone data? */
            {
            from_cache[offset] = from;
            to_cache[offset] = to;
            flags_cache[offset] = beta;
            pfunct_cache[offset] = prec;
            pixels_cache[offset] = -1;
            scaled_pixels_cache[offset] = -1;
            fpixels_cache[offset] = -1.0;
            scaled_fpixels_cache[offset] = -1.0;
            offset++;
            if (offset >= MAX_CACHE_ZONES)  /* Cache overflow? */
                {
                return(FALSE);
                }
            }
        if (type == 0)        /* End of character? */
            break;
        if (type == 1)        /* Start of outline data? */
            break;
        if (type == 13)       /* Outline hierarchy data? */
            break;
        }
    cache_x_offsets[char_no] = next_cache_offset;
    cache_no_x_zones[char_no] = offset - next_cache_offset;
    next_cache_offset = offset;
    cache_char_x_list[cache_no_x_chars++] = char_no;
    return(TRUE);
    }
else                          /* Y dimension? */
    {
    if (cache_y_offsets[char_no] >= 0) /* Y zone data already in cache? */
        return(TRUE);
    prec = cfont->outl_dat + cfont->chdir_dat[char_no].outline_offs;
    offset = next_cache_offset;
    init_rec_state(1);        /* Initialize get_rec state read stream 1 */
    for (;;)
        {
        get_rec(1, &prec, pfirst_rec, &type, &from, &to, &beta);
        if (type == 15)             /* Plaid Y zone data? */
            {
            from_cache[offset] = from;
            to_cache[offset] = to;
            flags_cache[offset] = beta;
            pfunct_cache[offset] = prec;
            pixels_cache[offset] = -1;
            scaled_pixels_cache[offset] = -1;
            fpixels_cache[offset] = -1.0;
            scaled_fpixels_cache[offset] = -1.0;
            offset++;
            if (offset >= MAX_CACHE_ZONES) /* Cache overflow? */
                {
                return(FALSE);
                }
            }
        if (type == 0)        /* End of character? */
            break;
        if (type == 1)        /* Start of outline data? */
            break;
        if (type == 13)       /* Outline hierarchy data? */
            break;
        }
    cache_y_offsets[char_no] = next_cache_offset;
    cache_no_y_zones[char_no] = offset - next_cache_offset;
    next_cache_offset = offset;
    cache_char_y_list[cache_no_y_chars++] = char_no;
    return(TRUE);
    }
}


FUNCTION cache_pixels(char_no, dimension, zone_no, pixels, scale)
ufix16 char_no;         /* Character offset */
fix15 dimension;        /* 0 if x zone, 1 if y zone */
fix15 zone_no;          /* Zone number */
fix15 pixels;           /* Number of pixels */
float scale;            /* Scale factor for dimension */
/* Called by get_pixels() to save a rounded number of pixels for the specified
   zone in the specified dimension of the specified character. If the scale
   factor is 1.0, the data is saved in the main cache.  If the scale factor is
   not 1.0, the data is saved in the auxiliary cache.  All other rounded and
   unrounded pixel values in the specified dimension of the auxiliary cache
   are cleared if the non-unity scale factor has changed from the currently
   prevailing value (cache_x_scale or cache_y_scale).                        */
{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];  
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (scale == 1.0)
            {
            pixels_cache[offset + zone_no] = pixels;
            }
        else if (scale == cache_x_scale)
            {
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        else
            {
            clear_scaled_x_cache();
            cache_x_scale = scale;
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        }
    else
        {
        fprintf(stderr, "cache_pixels:  X dimension of character number %d not loaded\n", char_no);
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (scale == 1.0)
            {
            pixels_cache[offset + zone_no] = pixels;
            }
        else if (scale == cache_y_scale)
            {
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        else
            {
            clear_scaled_y_cache();
            cache_y_scale = scale;
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        }
    else
        {
        fprintf(stderr, "cache_pixels:  Y dimension of character number %d not loaded\n", char_no);
        }
    }
}


FUNCTION cache_fpixels(char_no, dimension, zone_no, fpixels, scale)
ufix16 char_no;         /* Character offset */
fix15 dimension;        /* 0 if x zone, 1 if y zone */
fix15 zone_no;          /* Zone number */
float fpixels;          /* Unrounded number of pixels */
float scale;            /* Scale factor for dimension */
/* Called by alloc_pixels() and get_fpixels() to save an unrounded number of
   pixels for the specified zone in the specified dimension of the specified
   character. If the scale factor is 1.0, the data is saved in the main cache.
   If the scale factor is not 1.0, the data is saved in the auxiliary cache.
   All other rounded and unrounded pixel values in the specified dimension of
   the auxiliary cache are cleared if the non-unity scale factor has changed
   from the currently prevailing value (cache_x_scale or cache_y_scale).      */
{
fix15 offset;

if (fpixels < 0.) fpixels = 0.;
if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];  
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (scale == 1.0)
            {
            fpixels_cache[offset + zone_no] = fpixels;
            pixels_cache[offset + zone_no] = -1;
            }
        else if (scale == cache_x_scale)
            {
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            }
        else
            {
            clear_scaled_x_cache();
            cache_x_scale = scale;
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            scaled_pixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        fprintf(stderr, "cache_fpixels:  X dimension of character number %d not loaded\n", char_no);
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (scale == 1.0)
            {
            fpixels_cache[offset + zone_no] = fpixels;
            pixels_cache[offset + zone_no] = -1;
            }
        else if (scale == cache_y_scale)
            {
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            }
        else
            {
            clear_scaled_y_cache();
            cache_y_scale = scale;
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            scaled_pixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        fprintf(stderr, "cache_fpixels:  Y dimension of character number %d not loaded\n", char_no);
        }
    }
}


FUNCTION clear_x_cache()
/* Called by reinit_cache() to clear cached values of pixels and fpixels in
   X dimension.                                                              */
{
fix15 i, offset, no_zones, zone_no;
ufix16 char_no;

for (i = 0; i < cache_no_x_chars; i++)
    {
    char_no = cache_char_x_list[i];      /* Get next char with X zone data in cache */ 
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character cached? */
        {
        no_zones = cache_no_x_zones[char_no];
        for (zone_no = 0; zone_no < no_zones; zone_no++)
            {
            pixels_cache[offset + zone_no] = -1;
            fpixels_cache[offset + zone_no] = -1.0;
            }
        }
    else
        {
        fprintf(stderr, "clear_x_cache: cache_char_x_list contains uncached character\n");
        }
    }
}

FUNCTION clear_y_cache()
/* Called by reinit_cache() to clear cached values of pixels and fpixels in
   Y dimension.                                                              */
{
fix15 i, offset, no_zones, zone_no;
ufix16 char_no;

for (i = 0; i < cache_no_y_chars; i++)
    {
    char_no = cache_char_y_list[i];      /* Get next char with Y zone data in cache */ 
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character cached? */
        {
        no_zones = cache_no_y_zones[char_no];
        for (zone_no = 0; zone_no < no_zones; zone_no++)
            {
            pixels_cache[offset + zone_no] = -1;
            fpixels_cache[offset + zone_no] = -1.0;
            }
        }
    else
        {
        fprintf(stderr, "clear_y_cache: cache_char_y_list contains uncached character\n");
        }
    }
}


FUNCTION clear_scaled_x_cache()
/* Called by cache_pixels() and chace_fpixels() to clear scaled pixels and
   scaled fpixels cache in X dimension.                                      */
{
fix15 i, offset, no_zones, zone_no;
ufix16 char_no;

for (i = 0; i < cache_no_x_chars; i++)
    {
    char_no = cache_char_x_list[i];      /* Get next char with X zone data in cache */ 
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character cached? */
        {
        no_zones = cache_no_x_zones[char_no];
        for (zone_no = 0; zone_no < no_zones; zone_no++)
            {
            scaled_pixels_cache[offset + zone_no] = -1;
            scaled_fpixels_cache[offset + zone_no] = -1.0;
            }
        }
    else
        {
        fprintf(stderr, "clear_scaled_x_cache: cache_char_x_list contains uncached character\n");
        }
    }
}

FUNCTION clear_scaled_y_cache()
/* Called by cache_pixels() and chace_fpixels() to clear scaled pixels and
   scaled fpixels cache in Y dimension.                                      */
{
fix15 i, offset, no_zones, zone_no;
ufix16 char_no;

for (i = 0; i < cache_no_y_chars; i++)
    {
    char_no = cache_char_y_list[i];      /* Get next char with Y zone data in cache */ 
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character cached? */
        {
        no_zones = cache_no_y_zones[char_no];
        for (zone_no = 0; zone_no < no_zones; zone_no++)
            {
            scaled_pixels_cache[offset + zone_no] = -1;
            scaled_fpixels_cache[offset + zone_no] = -1.0;
            }
        }
    else
        {
        fprintf(stderr, "clear_scaled_y_cache: cache_char_y_list contains uncached character\n");
        }
    }
}


FUNCTION get_cache_no_zones(char_no, dimension, pno_zones)
ufix16 char_no;         /* Character offset */
fix15 dimension;        /* 0 if x zone, 1 if y zone */
fix15 *pno_zones;
/* Called by make_edge_list() and alloc_pixels() to get the number of zones
   in the specified dimension of the specified character. The zone data is
   assumed to be cached if it exists. If the specified character/dimension
   is not in the cache, it is concluded that no zone data exists.             */
{
if (dimension == X_DIMENSION)
    {
    if (cache_x_offsets[char_no] >= 0)
        {
        *pno_zones = cache_no_x_zones[char_no];
        return;
        }
    }
else
    {
    if (cache_y_offsets[char_no] >= 0)
        {
        *pno_zones = cache_no_y_zones[char_no];
        return;
        }
    }

/* Zone data for character/dimension not in cache */
*pno_zones = 0;    /* Assume character/dimension has no zone data */
}


FUNCTION get_cache_data(char_no, dimension, zone_no, pfrom, pto, pflags, ppfunct)
ufix16 char_no;         /* Character offset */
fix15 dimension;        /* 0 if x zone, 1 if y zone */
fix15 zone_no;          /* Zone number */
fix31 *pfrom;
fix31 *pto;
ufix16 *pflags;
ufix16 **ppfunct;
/* Called by make_edge_list(), alloc_pixels(), get_fpixels(), get_pixels() and
   find_path() to extract all zone data for the specified zone in the specified
   dimension of the specified character. The zone data is assumed to be in the
   cache.                                                                    */
{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    if (cache_x_offsets[char_no] >= 0)
        {
        if (zone_no < cache_no_x_zones[char_no])
            {
            offset = cache_x_offsets[char_no] + zone_no;
            *pfrom = from_cache[offset];
            *pto = to_cache[offset];
            *pflags = flags_cache[offset];
            *ppfunct = pfunct_cache[offset];
            }
        else
            fprintf(stderr, "get_cache_data: X zone %d in char %d out of range\n", zone_no, char_no);
        }
    else
        fprintf(stderr, "get_cache_data: X zones not cached\n");
    }
else
    {
    if (cache_y_offsets[char_no] >= 0)
        {
        if (zone_no < cache_no_y_zones[char_no])
            {
            offset = cache_y_offsets[char_no] + zone_no;
            *pfrom = from_cache[offset];
            *pto = to_cache[offset];
            *pflags = flags_cache[offset];
            *ppfunct = pfunct_cache[offset];
            }
        else
            fprintf(stderr, "get_cache_data: Y zone %d in char %d out of range\n", zone_no, char_no);
        }
    else
        fprintf(stderr, "get_cache_data: Y character not cached\n");
    }
}


FUNCTION boolean cached_pixels(char_no, dimension, zone_no, scale, ppixels)
ufix16 char_no;                       /* Character offset */
fix15 dimension;                      /* 0 if x zone, 1 if y zone */
fix15 zone_no;                        /* Zone number */
float scale;                          /* Scale factor */
fix15 *ppixels;
/* Called by make_edge_list() and get_pixels() to get cached value of
   rounded pixels for the specified zone in the specified dimension of the
   specified character. A returned value of false indicates that no value
   is in the cache.                                                          */
{
fix15 offset;
fix15 pixels;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (scale == 1.0)
            {
            pixels = pixels_cache[offset + zone_no];
            if (pixels >= 0)             /* Pixels cached for zone? */
                {
                *ppixels = pixels;
                return(1);
                }
            }
        else if (scale == cache_x_scale)
            {
            pixels = scaled_pixels_cache[offset + zone_no];
            if (pixels >= 0)             /* Scaled pixels cached for zone? */
                {
                *ppixels = pixels;
                return(1);
                }
            }
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (scale == 1.0)
            {
            pixels = pixels_cache[offset + zone_no];
            if (pixels >= 0)             /* Pixels cached for zone? */
                {
                *ppixels = pixels;
                return(1);
                }
            }
        else if (scale == cache_y_scale)
            {
            pixels = scaled_pixels_cache[offset + zone_no];
            if (pixels >= 0)             /* Scaled pixels cached for zone? */
                {
                *ppixels = pixels;
                return(1);
                }
            }
        }
    }

*ppixels = 0;           /* zone not in cache; returns 0 pixels */
return(0);
}


FUNCTION boolean cached_fpixels(char_no, dimension, zone_no, scale, pfpixels)
ufix16 char_no;                       /* Character offset */
fix15 dimension;                      /* 0 if x zone, 1 if y zone */
fix15 zone_no;                        /* Zone number */
float scale;                          /* Scale factor */
float *pfpixels;
/* Called by get_fpixels() to get cached value of unrounded pixels for the
   specified zone in the specified dimension of the specified character.
   A returned value of false indicates that no value is in the cache.         */
{
fix15 offset;
float fpixels;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (scale == 1.0)
            {
            fpixels = fpixels_cache[offset + zone_no];
            if (fpixels >= 0.0)             /* Pixels cached for zone? */
                {
                *pfpixels = fpixels;
                return(1);
                }
            }
        else if (scale == cache_x_scale)
            {
            fpixels = scaled_fpixels_cache[offset + zone_no];
            if (fpixels >= 0.0)             /* Scaled pixels cached for zone? */
                {
                *pfpixels = fpixels;
                return(1);
                }
            }
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (scale == 1.0)
            {
            fpixels = fpixels_cache[offset + zone_no];
            if (fpixels >= 0.0)             /* Pixels cached for zone? */
                {
                *pfpixels = fpixels;
                return(1);
                }
            }
        else if (scale == cache_y_scale)
            {
            fpixels = scaled_fpixels_cache[offset + zone_no];
            if (fpixels >= 0.0)             /* Scaled pixels cached for zone? */
                {
                *pfpixels = fpixels;
                return(1);
                }
            }
        }
    }
*pfpixels = 0.;         /* zone not in cache; returns 0. pixels */
return(0);
}






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

 6)  14 Oct 87  jsc   removed modification 4 above from cache_fpixels().
                      clr_pxls_cache() added.

 7)  20 Nov 87  jsc   scale argument removed from 
                          cache_pixels()
                          cache_fpixels()
                          cached_pixels()
                          cached_fpixels()
                          clr_pxls_cache()

                      cache_select() added to select which cache to be used
                      on subsequent calls.

 8)   24 Nov 87  jsc  Changed all oru coordinates from fix31 to fix15

 9)   16 Mar 88  jsc  Changed clear_cache() to not change which cache is
                      currently selected.
 
10)   20 May 88  reh  Found array index out of bounds which caused make_bmap
                      to crash after doing two bitmaps in a row (i.e. -l 6:10)
                      Error fixed by moving a test in cache_data()

11)   21 Jul 88  reh  Changed fpixel cache to fixed point, scale is in 16 bit
                      unsigned integers with 4 bits decimal and 12 bits fractional

12)   11 Aug 88  tpl  replaced printfs with report_error calls

 ***************************************************************************

   This is the mechanism for caching zone data and the rounded and unrounded
   pixel values associated with each zone.                                   

 *****************************************************************************/


#include "stdef.h"      /* Bitstream standard macros  */
#include "comp2_3.h"    /* data structures for compressed font */
#include "mkbm.h"
#include "errchk.h"
#include <math.h>
#include "error.h"


/***** STATIC VARIABLES *****/

static fix15    cache_x_offsets[MAX_CHARS];    /* Offset to first zone in X dimension */
static fix15    cache_no_x_zones[MAX_CHARS];   /* Number of zones in X dimension */
static ufix16   cache_x_scale;                 /* Current X dimension scale factor for scaled cache */
static boolean  cache_x_main;                  /* TRUE if main x cache currently selected */
static fix15    cache_y_offsets[MAX_CHARS];    /* Offset to first zone in Y dimension */
static fix15    cache_no_y_zones[MAX_CHARS];   /* Number of zones in Y dimension */
static ufix16   cache_y_scale;                 /* Current Y dimension scale factor for scaled cache */
static boolean  cache_y_main;                  /* TRUE if main y cache currently selected */
static fix15    next_cache_offset;             /* Offset to next empty character */

static fix15    from_cache[MAX_CACHE_ZONES];   /* Start coordinate of zone */
static fix15    to_cache[MAX_CACHE_ZONES];     /* End coordinate of zone */
static ufix16   flags_cache[MAX_CACHE_ZONES];  /* Zone flags as follows... */
                                               /*   Bit 15:     Propagate flag (parent zone) */
                                               /*   Bit 14:     Level flag */
                                               /*   Bit 13:     Continue flag */
                                               /*   Bits 12-11: Function flags */
                                               /*   Bits 7-0:   Minimum number of pixels */
static ufix16 huge *pfunct_cache[MAX_CACHE_ZONES];  /* Pointer to constraint function */
static fix15   pixels_cache[MAX_CACHE_ZONES];  /* Rounded number of pixels at full scale */
static fix15   scaled_pixels_cache[MAX_CACHE_ZONES]; /* Rounded number of pixels at cache_[xy]_scale */
static fix31   fpixels_cache[MAX_CACHE_ZONES]; /* Unrounded number of pixels at full scale */
static fix31   scaled_fpixels_cache[MAX_CACHE_ZONES]; /* Unrounded number of pixels at cache_[xy]_scale */

static fix15   put_cache_dimension;            /* Current dimension being written to cache */
static fix15   put_cache_char_no;              /* Current character being written to cache */
static fix15   put_cache_zone_no;              /* Current zone number */

static ufix16  cache_char_x_list[MAX_CHARS];   /* List of char numbers with X zone data in cache */
static fix15   cache_no_x_chars;               /* Number of characters with X zone data in cache */
static ufix16  cache_char_y_list[MAX_CHARS];   /* List of char numbers with Y zone data in cache */
static fix15   cache_no_y_chars;               /* Number of characters with Y zone data in cache */


FUNCTION clear_cache()

/*  Called on first invocation of init_trans()
 *  Called by rules if cache overflow occurs.
 *  Clears cache
 */

{
fix15 i;

cache_no_x_chars = 
    cache_no_y_chars = 0;            /* Clear lists of chars in cache */
next_cache_offset = 0;               /* Start at beginning of cache */
for (i = 0; i < MAX_CHARS; i++)
    {
    cache_x_offsets[i] =  
        cache_y_offsets[i] = -1;     /* Mark X & Y zone data not in cache */
    } 
}

FUNCTION open_put_cache_data()

/*  Called by fw_make_char() to prepare cache to accept zone data with
 *  put_cache_data() calls                                                   
 */

{
put_cache_dimension = -1;        /* Flag no dimension selected */
}





FUNCTION close_put_cache_data()

/*  Called by fw_make_char() to terminate input of zone data            
 *  Also called by put_cache_data() to terminate input of zone data in one
 *  dimension when change of dimension is detected. 
 */

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
put_cache_dimension = -1;        /* Flag no dimension selected */
}








FUNCTION put_cache_data(char_no, dimension, from, to, flags, pfunct)
ufix16   char_no;           /* Character offset */
fix15    dimension;         /* 0 if x zone, 1 if y zone */
fix15    from;              /* zone start coordinate */
fix15    to;                /* zone end coordinate */
ufix16   flags;             /* zone flags */
ufix16  huge *pfunct;       /* pointer to constraint function if any */

/*  Called by char_scan_convert() to add zone data to cache   
 */

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
fpixels_cache[offset] = -1;        /* Mark fpixels value not available */
scaled_fpixels_cache[offset] = -1; /* Mark scaled fpixels value not available */
put_cache_zone_no++;
}


FUNCTION boolean cache_data(char_no, dimension, cfont, pfirst_rec)
ufix16        char_no;      /* Character offset */
fix15         dimension;    /* 0 if x zone, 1 if y zone */
cft_outl_str *cfont;        /* pointer to compressed font data structure  */
ufix16 huge  *pfirst_rec;   /* pointer to first record in font outline data */

/*  Called by alloc_pixels(), get_pixels(), get_fpixels() and get_tpixels()
 *  to ensure that zone data for the specified dimension of the
 *  specified character is present in the cache. If not, the
 *  appropriate zone data is read and added to the cache.
 *  returns TRUE if the requested data is in the cache on exit.
 *  returns FALSE if the requested data cannot be loaded into the cache. 
 */

{
ufix16 huge *prec;
fix15 offset;
fix15 type;
fix15 from, to, beta;
void save_rec_state();
void restore_rec_state();
void init_rec_state();
void get_rec16();

if (dimension == X_DIMENSION) /* X dimension? */
    {
    if (cache_x_offsets[char_no] >= 0) /* X zone data already in cache? */
        return(TRUE);
    }
else 
    {
    if (cache_y_offsets[char_no] >= 0) /* Y zone data already in cache? */
        return(TRUE);
    }
prec = cfont->outl_dat + cfont->chdir_dat[char_no].outline_offs;
offset = next_cache_offset;
save_rec_state();         /* Save get_rec state */
init_rec_state();         /* Initialize get_rec state */
for (;;)
    {
    get_rec16(&prec, pfirst_rec, &type, &from, &to, &beta);
    if (type == ((dimension == X_DIMENSION) ? 14 : 15))       /* Plaid X zone data? */
        {
        if (offset >= MAX_CACHE_ZONES)  /* Cache overflow? */
            {
            restore_rec_state();
            return(FALSE);
            }
        from_cache[offset] = from;
        to_cache[offset] = to;
        flags_cache[offset] = beta;
        pfunct_cache[offset] = prec;
        pixels_cache[offset] = -1;
        scaled_pixels_cache[offset] = -1;
        fpixels_cache[offset] = -1;
        scaled_fpixels_cache[offset] = -1;
        offset++;
        }
    if ((type == 15) && (dimension == X_DIMENSION))       /* Y-zone data? */
        break;
    else if (type == 1)   /* Start of outline data? */
        break;
    else if (type == 13)  /* Outline hierarchy data? */
        break;
    else if (type == 0)   /* End of character? */
        break;
    }
restore_rec_state();
if (dimension == X_DIMENSION) /* X dimension? */
    {
    cache_x_offsets[char_no] = next_cache_offset;
    cache_no_x_zones[char_no] = offset - next_cache_offset;
    cache_char_x_list[cache_no_x_chars++] = char_no;
    }
else                          /* Y dimension? */
    {
    cache_y_offsets[char_no] = next_cache_offset;
    cache_no_y_zones[char_no] = offset - next_cache_offset;
    cache_char_y_list[cache_no_y_chars++] = char_no;
    }
next_cache_offset = offset;
return(TRUE);
}


FUNCTION cache_select(dimension, scale)
fix15  dimension;           /* 0 if x zone, 1 if y zone */
ufix16 scale;               /* Scale factor of sub character relative to full size */

/*  Select for the specified dimension whether the main or scaled cache should
 *  be used on calls to cache_pixels(), cache_fpixels(), cached_pixels() and
 *  cached_fpixels().                                                       
 */

{
if (dimension == X_DIMENSION)               /* X dimension? */
    {
    if (scale == 4096) /* Full scale? */
        {
        cache_x_main = TRUE;                /* Select main X cache */
        }
    else if (scale == cache_x_scale)        /* Back to scaled X cache scale? */
        {
        cache_x_main = FALSE;               /* Select scaled cache in X */
        }
    else                                    /* Change of scaled X cache scale? */
        {
        clear_scaled_x_cache();             /* Clear scaled X cache values */
        cache_x_scale = scale;              /* Update scaled X cache scale */
        cache_x_main = FALSE;               /* Select scaled cache in X */
        }
    }
else                                        /* Y dimension? */
    {
    if (scale == 4096) /* Full scale? */
        {
        cache_y_main = TRUE;                /* Select main Y cache */
        }
    else if (scale == cache_y_scale)        /* Back to scaled Y cache scale? */
        {
        cache_y_main = FALSE;               /* Select scaled cache in Y */
        }
    else                                    /* Change of scaled X cache scale? */ 
        {
        clear_scaled_y_cache();             /* Clear scaled Y cache values */
        cache_y_scale = scale;              /* Update scaled X cache scale */
        cache_y_main = FALSE;               /* Select scaled cache in Y */
        }
    }
}

FUNCTION cache_pixels(char_no, dimension, zone_no, pixels)
ufix16  char_no;            /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */
fix15   zone_no;            /* Zone number */
fix15   pixels;             /* Number of pixels */

/*  Called by get_pixels() to save a rounded number of pixels for the specified
 *  zone in the specified dimension of the specified character.
 *  The value is saved either in the main cache or the scaled cache depending upon
 *  the current value of cache_x_main or cache_y_main
 */

{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];  
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_x_main)
            {
            pixels_cache[offset + zone_no] = pixels;
            }
        else 
            {
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        }
    else
        {
        report_error (ERROR,ER_X_CHAR_NOT_LOADED,TRUE,"");
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_y_main)
            {
            pixels_cache[offset + zone_no] = pixels;
            }
        else
            {
            scaled_pixels_cache[offset + zone_no] = pixels;
            }
        }
    else
        {
        report_error (ERROR,ER_Y_CHAR_NOT_LOADED,TRUE,"");
        }
    }
}


FUNCTION cache_fpixels(char_no, dimension, zone_no, fpixels)
ufix16  char_no;            /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */
fix15   zone_no;            /* Zone number */
fix31   fpixels;            /* Unrounded number of pixels */

/*  Called by alloc_pixels() and get_fpixels() to save an unrounded number of
 *  pixels for the specified zone in the specified dimension of the specified
 *  character.
 *  The value is saved either in the main cache or the scaled cache depending upon
 *  the current value of cache_x_main or cache_y_main
 */

{
fix15 offset;

if (fpixels < 0) fpixels = 0;
if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];  
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_x_main)
            {
            fpixels_cache[offset + zone_no] = fpixels;
            }
        else
            {
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            }
        }
    else
        {
        report_error (ERROR,ER_X_CHAR_UNRND_NOT_LOADED,TRUE,"");
        }
    }
else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_y_main)
            {
            fpixels_cache[offset + zone_no] = fpixels;
            }
        else 
            {
            scaled_fpixels_cache[offset + zone_no] = fpixels;
            }
        }
    else
        {
        report_error (ERROR,ER_Y_CHAR_UNRND_NOT_LOADED,TRUE,"");
        }
    }
}


FUNCTION get_cache_no_zones(char_no, dimension, pno_zones)
ufix16  char_no;            /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */
fix15  *pno_zones;          /* Number of zones (output) */

/*  Called by make_edge_list() and alloc_pixels() to get the number of zones
 *  in the specified dimension of the specified character. The zone data is
 *  assumed to be cached if it exists. If the specified character/dimension
 *  is not in the cache, it is concluded that no zone data exists.            
 */

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
ufix16   char_no;           /* Character offset */
fix15    dimension;         /* 0 if x zone, 1 if y zone */
fix15    zone_no;           /* Zone number */
fix15   *pfrom;             /* From coordinate in orus (output) */
fix15   *pto;               /* To coordinate in orus (output) */
ufix16  *pflags;            /* P, L, C, FN flags and MIN value (output) */
ufix16 huge **ppfunct;      /* Pointer to constraint function (output) */

/*  Called by make_edge_list(), alloc_pixels(), get_fpixels(), get_pixels() and
 *  find_path() to extract all zone data for the specified zone in the specified
 *  dimension of the specified character. The zone data is assumed to be in the
 *  cache.                                                                   
 */

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
            report_error (ERROR,ER_X_CACHE_ZONE_2BIG,TRUE,"");
        }
    else
        report_error (ERROR,ER_X_CHAR_NOT_IN_CACHE,TRUE,"");
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
            report_error (ERROR,ER_Y_CACHE_ZONE_2BIG,TRUE,"");
        }
    else
        report_error (ERROR,ER_Y_CHAR_NOT_IN_CACHE,TRUE,"");
    }
}


FUNCTION boolean cached_pixels(char_no, dimension, zone_no, ppixels)
ufix16 char_no;             /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */
fix15   zone_no;            /* Zone number */
fix15  *ppixels;            /* Pixels in zone (output) */

/*  Called by make_edge_list() and get_pixels() to get cached value of
 *  rounded pixels for the specified zone in the specified dimension of the
 *  specified character. A returned value of false indicates that no value
 *  is in the cache.                                                         
 */

{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (cache_x_main)
            {
            if ((*ppixels = pixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        else 
            {
            if ((*ppixels = scaled_pixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        }
    }

else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (cache_y_main)
            {
            if ((*ppixels = pixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        else
            {
            if ((*ppixels = scaled_pixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        }
    }

*ppixels = 0;           /* zone not in cache; returns 0 pixels */
return(FALSE);
}


FUNCTION boolean cached_fpixels(char_no, dimension, zone_no, pfpixels)
ufix16 char_no;             /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */
fix15   zone_no;            /* Zone number */
fix31  *pfpixels;           /* Unrounded pixels in zone (output) */

/*  Called by get_fpixels() to get cached value of unrounded pixels for the
 *  specified zone in the specified dimension of the specified character.
 *  A returned value of FALSE indicates that no value is in the cache.        
 */

{
fix15 offset;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (cache_x_main)
            {
            if ((*pfpixels = fpixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        else 
            {
            if ((*pfpixels = scaled_fpixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        }
    }

else
    {
    offset = cache_y_offsets[char_no];
    if (offset >= 0)                     /* Character in offset table? */
        {
        if (cache_y_main)
            {
            if ((*pfpixels = fpixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        else
            {
            if ((*pfpixels = scaled_fpixels_cache[offset + zone_no]) >= 0)
                {
                return(TRUE);
                }
            }
        }
    }

*pfpixels = 0;         /* zone not in cache; returns 0. pixels */
return(FALSE);
}


FUNCTION clr_pxls_cache(char_no, dimension)
ufix16  char_no;            /* Character offset */
fix15   dimension;          /* 0 if x zone, 1 if y zone */

/*  Called by alloc_pixels(), get_fpixels() and make_edge_list() to clear 
 *  currently cached values of pixels and fpixels for the specified dimension 
 *  of the specified character.
 *  If the main cache is currently selected, all unrounded and rounded pixel values
 *  in the main cache are cleared.
 *  If the scaled cache is currently selected, all unrounded and rounded pixel values
 *  in the scaled cache are cleared.
 */

{
fix15 i; 
fix15 no_zones;
fix15 offset;

if (dimension == X_DIMENSION)
    {
    offset = cache_x_offsets[char_no];  
    no_zones = cache_no_x_zones[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_x_main)
            {
            for (i = 0; i < no_zones; i++)
                {
                fpixels_cache[offset + i] = -1;
                pixels_cache[offset + i] = -1;
                }
            }
        else 
            {
            for (i = 0; i < no_zones; i++)
                {
                scaled_fpixels_cache[offset + i] = -1;
                scaled_pixels_cache[offset + i] = -1;
                }
            }
        }
    else
        {
        report_error (ERROR,ER_X_CANT_CLR_NOT_LOADED,TRUE,"");
        }
    }
else
    {
    offset = cache_y_offsets[char_no];  
    no_zones = cache_no_y_zones[char_no];
    if (offset >= 0)                    /* Char/dim loaded? */
        {
        if (cache_y_main)
            {
            for (i = 0; i < no_zones; i++)
                {
                fpixels_cache[offset + i] = -1;
                pixels_cache[offset + i] = -1;
                }
            }
        else 
            {
            for (i = 0; i < no_zones; i++)
                {
                scaled_fpixels_cache[offset + i] = -1;
                scaled_pixels_cache[offset + i] = -1;
                }
            }
        }
    else
        {
        report_error (ERROR,ER_Y_CANT_CLR_NOT_LOADED,TRUE,"");
        }
    }
}


FUNCTION clear_x_cache()

/*  Called by init_trans() to clear cached values of:
 *     pixels
 *     fpixels
 *     scaled pixels
 *     scaled fpixels
 *  in the X dimension.                                                             
 */

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
            fpixels_cache[offset + zone_no] = -1;
            scaled_pixels_cache[offset + zone_no] = -1;
            scaled_fpixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        report_error (ERROR,ER_CLRX_CHAR_NOT_FOUND,TRUE,"");
        }
    }
cache_x_scale = 4096;                     /* Reset scaled cache scale */
}


FUNCTION clear_y_cache()

/*  Called by init_trans() to clear cached values of:
 *     pixels
 *     fpixels
 *     scaled pixels
 *     scaled fpixels
 *  in the Y dimension.                                                             
 */

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
            fpixels_cache[offset + zone_no] = -1;
            scaled_pixels_cache[offset + zone_no] = -1;
            scaled_fpixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        report_error (ERROR,ER_CLRY_CHAR_NOT_FOUND,TRUE,"");
        }
    }
cache_y_scale = 4096;                     /* Reset scaled cache scale */
}


FUNCTION clear_scaled_x_cache()

/*  Called by cache_select() to clear cached values of:
 *     scaled pixels
 *     scaled fpixels
 *  in the X dimension.                                     
 */

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
            scaled_fpixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        report_error (ERROR,ER_CLRXSC_CHAR_NOT_FOUND,TRUE,"");
        }
    }
}


FUNCTION clear_scaled_y_cache()

/*  Called by cache_select() to clear cached values of:
 *     scaled pixels
 *     scaled fpixels
 *  in the Y dimension.                                     
 */

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
            scaled_fpixels_cache[offset + zone_no] = -1;
            }
        }
    else
        {
        report_error (ERROR,ER_CLRYSC_CHAR_NOT_FOUND,TRUE,"");
        }
    }
}


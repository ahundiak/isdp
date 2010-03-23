




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************** C O N V E R T . C *****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

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

 *****************************************************************************

    This module takes a character in a compressed outline font and returns
    a bitmap to the calling program, which then decides what to do with it
    (e.g. make a bitmap font, display/print a single character).
    
    The entry point into this module is 'char_scan_convert'.

 ****************************************************************************/


#include "../hfiles/stdef.h"     /* Bitstream standard macros & definitions  */
#include "../hfiles/comp2_3.h"   /* data structures for compressed font */
#include "../hfiles/mkbm.h"
#include "../hfiles/polyfill.h"           /* scan conversion data structures */
#include "../hfiles/math.h"


/* this should be defined as a compilation argument */
/* #define  CONVERTDBG */       /* prints gobs of debugging data */


/***** DEFINITIONS *****/

/* Tokens returned by get_comp_token() */
#define   SNAFU         -1
#define   VECT           1
#define   ARC            2
#define   STARTCRV       3
#define   ENDCRV         4
#define   ENDCHAR        5
#define   ENDFILE        6
#define   SETSCALE       7
#define   SETORIG        8
#define   DOCHAR         9
#define   IGNORE        10
#define   XZONE         11
#define   YZONE         12
#define   PITEM         13
#define   FITEM         14
#define   CONST         15
#define   OPCODE        16
#define   TITEM         17
#define   X_MIN_EXTENT  18
#define   X_MAX_EXTENT  19
#define   Y_MIN_EXTENT  20
#define   Y_MAX_EXTENT  21

#define   FSPCT     4000


/***** STATIC VARIABLES *****/

static  bit8    bitmask[8] = { 0x80, 0x40, 0x20, 0x10, 8, 4, 2, 1, };
static  fix31   bsloff_y;       /* baseline (y=0) offset for scan conversion */
static  fix31   bsloff_x;       /* left s.b. (x=0) offset for scan conversion */
static  ext_grp  char_extent;   /* structure with 4 character extents */
static  cft_outl_str  *cfontp;  /* pointer to compr font structure */
static  fix31   free_space;     /* amount of list space available */
static  bool    increm_format;  /* T = incremental;  F = absolute */
static  fix31   nbr_scanl_x;    /* max # lines to scan convert any character */
static  fix31   nbr_scanl_y;    /* max # lines to scan convert any character */
static  float   outlres;        /* font outline resl/em in outline units */
static  ufix16 *pfirst_rec;     /* ptr to first outline data record in font */
static  ufix16 *plast_rec;      /* ptr following end of outline data in font */
static  ufix16 *pthis_rec;      /* outline data "program counter" */
static  bool    print_data;     /* print diagnostic switch */
static  bool16  scan_in_x;      /* X-dimension scan conversion switch */
static  fix     subchar_count;  /* # of character components (DOCHAR) */
static  xi_le **yslist[DCHRCT]; /* array of pointers to arrays of
                                     lists of x-intercepts on y-scan lines */
static  xi_le **xslist[DCHRCT]; /* ... for lists of y-intercepts on x-scan lines */


FUNCTION  bool  char_scan_convert (compc, pbitmap, bitmap_inf)
  comp_char_desc  *compc;
  bit8    **pbitmap;
  btminf   *bitmap_inf;

/* CHAR_SCAN_CONVERT -- Scan conversion routine for 1 character, returns a
 *                      pointer to a bitmap.
 * Input argument:
 *   compc -- pointer to structure containing scan conversion parameters.
 *     ->compf -- compressed font data structure
 *     ->choff -- root character number offset
 *     ->lines_per_em -- vertical # of scan lines per em square
 *     ->point_size_x -- x pointsize
 *     ->point_size_y -- y pointsize
 *     ->res_hor -- horizontal pixels per inch
 *     ->res_ver -- vertical pixels per inch
 *     ->rot_angle -- rotation angle in degrees (clockwise)
 *     ->obl_angle -- obliquing angle in degrees (clockwise)
 *     ->print_data -- if true, print diagnostic data
 *     ->import_widths -- if true, use external width table
 *     ->clip.left -- clips min x at left of emsquare
 *     ->clip.right -- clips max x at right of emsquare
 *     ->clip.bottom -- clips min x at bottom of emsquare
 *     ->clip.top -- clips max x at top of emsquare
 *     ->squeeze.left -- squeezes min x at left of emsquare
 *     ->squeeze.right, .top, .bottom  &c
 *     ->scanx -- if T, do scan conversion in 2 dimensions (low res bitmaps)
 *     ->bsloff_x, ->bsloff_y -- baseline offsets in x, y
 *     ->sw_fixed, ->bogus_mode, ->xht_adj -- passed by setup_trans() to rules.c
 * Output arguments:
 *   pbitmap -- a pointer to a block of memory that is allocated dynamically
 *          for the character bitmap. The bitmap is a minimum rectangle, of
 *          the same form as those in the Bitstream bitmap font format.
 *   bitmap_inf -- a structure containing the raster-height, raster-width,
 *          horizontal-offset, vertical offset, and set width. The offsets
 *          are from the pixel resting on the left edge of the baseline.
 * Returns:
 *   TRUE if valid bitmap is returned, FALSE if error
 * Called from:
 *   main module
 */

    DECLARE
    float     arc_spl_tol;      /* arc splitting tolerance in outline units */
    fix31     char_nr;          /* root character number offset */
    arc_type  coord;            /* arc data type, endpoint + bulge factor */
    ufix16    cur_char_no;      /* current char number */
    fix15     curve_count;      /* curve count within character oe sub_character */
    fix31     from, to;         /* zone start and end coordinates */
    ufix16    flags;            /* zone flags */
    ufix16    *pfunct;          /* zone constraint functions */
    xi_le    *fs_ptr;           /* free space pointer */
    fix15     ii, jj;           /* temps */
    fix31     m1, m2, m3, m4;   /* temps */
    float     q1, q2;           /* temps */
    fix15     stack_count;      /* depth of stack (0 to 16) */
    stack_frame  stack[16];     /* up to 16 DOCHARS can be nested */
    stack_frame *pstack;        /* pointer to a stack frame */
    vector_data *vectr;         /* pointer to arc splitting output (vectors) */
    fix31     vector_count;     /* # of vectors created by arc splitting */
    fix31     x1, y1, x2, y2;   /* coordinate pairs in RU space */
    real      x1p, y1p, x2p, y2p; /* coordinate pairs in pixel space */
    fix31     x1p_i, x2p_i;     /* x coords, integer, rounded values */
    fix31     y1p_i, y2p_i;     /* y coords, integer, rounded values */

    float     left_limit;       /* Left limit of character cell */
    float     right_limit;      /* Right limit of character cell */
    float     bottom_limit;     /* Bottom limit of character cell */
    float     top_limit;        /* Top limit of character cell */

    float     left_limit_adj;   /* Adjusted position of root char left limit */
    float     right_limit_adj;  /* Adjusted position of root char right limit */
    float     bottom_limit_adj; /* Adjusted position of root char bottom limit */
    float     top_limit_adj;    /* Adjusted position of root char top limit */

    float     reqd_width;       /* Required width for character */

    ufix8    *alloc();          /* allocate memory block */
    bool      dealloc();        /* deallocate memory block */
    bool      arc_to_vects();   /* converts arc to vectors by splitting */
    bool      convert_lists();  /* turns scan conversion list into bitmap */
    float     do_comp_x_trans(); /* compound x tranform operation */
    void      do_xy_trans();    /* scale, xlate, rotate, oblique xforms on points */
    fix       get_comp_token(); /* read token from compressed font */
    fix31     get_required_width();  /* Gets imported width */
    void      init_rec_state(); /* initialize get_rec variables */
    void      init_arec_state(); /* initialize abs get_rec variables */
    void      init_trans();     /* initialize character xform data */
    void      new_subchar();    /* allocate list pointers for new sub-character */
    real      norm_obl();       /* normalize obliquing angle, -90 to 90 */
    real      norm_rot();       /* normalize rotation angle, 0 to 360 */
    void      print_out();      /* print bitmap on stdout */
    void      proc_vect();      /* find x-intercepts for a vector crossing y-scan lines */
    void      setup_trans();    /* setup transformation data  */
    void      report_error();   /* error message reporting routine */


    BEGIN
    cfontp = compc->compf;
    char_nr = compc->choff;
    bsloff_x = compc->bsloff_x;
    nbr_scanl_x = 2 * bsloff_x;
    bsloff_y = compc->bsloff_y;
    nbr_scanl_y = 2 * bsloff_y;
    scan_in_x = compc->scanx;
    outlres = (float) cfontp->fonthead.resl_per_em;
    compc->rot_angle = floor(10. * compc->rot_angle + .5) / 10.;
    compc->obl_angle = floor(10. * compc->obl_angle + .5) / 10.; 
#ifdef CONVERTDBG
    print_data = compc->print_data;
#endif

    init_trans(cfontp, char_nr,
               (float)compc->point_size_x, (float)compc->point_size_y,
               (float)compc->res_hor, (float)compc->res_ver,
               (float)norm_rot(compc->rot_angle),
               (float)norm_obl(compc->obl_angle));
    pthis_rec = cfontp->outl_dat + cfontp->chdir_dat[char_nr].outline_offs;
    if (cfontp->fonthead.outl_fmt_nr[1] == '2')
        increm_format = TRUE;
    else
        increm_format = FALSE;

    char_extent.xmin = 1000000000;
    char_extent.xmax = -1000000000;
    char_extent.ymin = 1000000000;
    char_extent.ymax = -1000000000;

    left_limit_adj = left_limit = 0.0;
    right_limit_adj = right_limit = (float)cfontp->chdir_dat[char_nr].set_width;
    bottom_limit_adj = bottom_limit = EM_BOT * (outlres / 8640.0);
    top_limit_adj = top_limit = EM_TOP * (outlres / 8640.0);
    reqd_width = right_limit;

    subchar_count = 0;
    free_space = FSPCT;         /* allocate free space for x-intercept lists */
    assert((fs_ptr = (xi_le *)alloc((ufix32) (FSPCT * sizeof(xi_le))))  != NULL);

    init_rec_state((ufix16) 0);     /* initialize GET_REC variables */
#ifdef apollo                       /* only the apollo needs to support absolute format */
    init_arec_state((ufix16) 0);    /* initialize abs GET_REC variables */
#endif /* defined apollo */

    stack_count = 0;            /* initialize stack */
    pstack = stack;
    stack[0].xoff = 0.;
    stack[0].yoff = 0.;
    stack[0].xscale = stack[0].xscale_nom = 1.;
    stack[0].yscale = stack[0].yscale_nom = 1.;
    stack[1].xoff = 0.;
    stack[1].yoff = 0.;
    stack[1].xscale = stack[1].xscale_nom = 1.;
    stack[1].yscale = stack[1].yscale_nom = 1.;

    if (compc->import_widths && (right_limit > 0))
        {
        reqd_width = get_required_width(cfontp, char_nr);
        stack[0].xscale = stack[1].xscale = reqd_width / right_limit;
        }

    open_put_cache_data();      /* Prepare to read zone data */
    curve_count = 0;            /* Initialize curve count */
    cur_char_no = char_nr;

   /* The following loop processes 1 entire character, including        */
   /*   DOCHARs and CALLs, if any.                                      */
   /* 'get_comp_token' grabs tokens until the final (unnested) ENDCHAR  */
   /*   token is found; then a 'break' exits the loop.                  */
   /* 'get_comp_token' should never normally encounter an end of file.  */
#ifdef CONVERTDBG
    if (print_data)
        printf("\n");
#endif
    pfirst_rec = cfontp->outl_dat;
    if (strncmp (cfontp->outl_hd.block_id, "O2", 2) == 0)   /* > 64K wds? */
        m1 = ((fix31)cfontp->outl_hd.rec_size << 16) + cfontp->outl_hd.nr_data_wds;
    else
        m1 = cfontp->outl_hd.nr_data_wds;
    plast_rec = pfirst_rec + m1;
   /* Outline resolution units per pixel, h & v */
    q1 = outlres * PTPERINCH / (compc->res_hor * compc->point_size_x);
    q2 = outlres * PTPERINCH / (compc->res_ver * compc->point_size_y);
    arc_spl_tol = .1 * MIN(q1, q2);     /* error limit < .1 pixel */
    while ((ii = get_comp_token (&coord)) != ENDFILE)
        {
        if (ii == VECT)         /* get X,Y coordinates */
            {
            x1 = x2;            /* straight line from (x1, y1) to (x2, y2) */
            y1 = y2;            /*  in relative-unit space */
            x1p = x2p;          /* (x1p, y1p) & (x2p, y2p) in pixel space */
            y1p = y2p;
            x1p_i = x2p_i;      /* (xp_i, yp_i) -- integer values in pixel space */
            y1p_i = y2p_i;
            x2 = coord.xx;      /* (X,Y)  raw value */
            y2 = coord.yy;
          /* (X,Y) transformed to pixel coordinates */
            do_xy_trans ((real)x2, (real)y2, &x2p, &y2p);
            x2p_i = ROUND(x2p);   /* x pixel value rounded to integer */
            y2p_i = ROUND(y2p);   /* y pixel value rounded to integer */
#ifdef CONVERTDBG
            if (print_data)
                {
                printf("    Vector      x = %ld   y = %ld\n", x2, y2);
                printf("                x = %.2f   y = %.2f\n", x2p, y2p);
                }
#endif
           /* if y1p_i = y2p_i and x1p_i = x2p_i, then no scan line intercepts
              the vector in either dimension */
            if (scan_in_x)
                {
                if (y1p_i != y2p_i || x1p_i != x2p_i)
                    proc_vect (x1p, y1p, x2p, y2p,
                               x1p_i, x2p_i, y1p_i, y2p_i, &fs_ptr);
                }
            else        /* if y1p_i = y2p_i then no scan line intercepts the */
                {       /*  vector in the y-dimension. Ignore x-scan lines   */
                if (y1p_i != y2p_i)
                    proc_vect (x1p, y1p, x2p, y2p,
                               x1p_i, x2p_i, y1p_i, y2p_i, &fs_ptr);
                }
            }

        else if (ii == ARC)     /* get X,Y coordinates */
            {
            x1 = x2;            /* arc from (x1, y1) to (x2, y2) */
            y1 = y2;            /*  in relative-unit space */
            x1p = x2p;          /* (x1p, y1p) & (x2p, y2p) in pixel space */
            y1p = y2p;
            x1p_i = x2p_i;      /* (xp_i, yp_i) -- integer values in pixel space */
            y1p_i = y2p_i;
            x2 = coord.xx;      /* (X,Y)  raw value */
            y2 = coord.yy;
          
          /* 'arc_to_vects' takes an arc and approximates the arc by split-  */
          /* ting it into a sufficiently large number of vectors. They are   */
          /* returned in an array pointed to by 'vectr'. The number of       */
          /* vectors is returned in 'vector_count'. The vectors are then     */
          /* transformed to pixel coordinates in the usual way.              */
            if (!arc_to_vects(x1, y1, x2, y2, coord.bugfat,
                              arc_spl_tol, &vectr, &vector_count))
                {
                printf("***  ARC_TO_VECTS failure:  arc from (%ld, %ld) to (%ld, %ld)\n\n",
                       x1, y1, x2, y2);
                return (FALSE);
                }
#ifdef CONVERTDBG
            if (print_data)
                {
                do_xy_trans ((real)x2, (real)y2, &x2p, &y2p);
                printf("    Arc         x = %ld   y = %ld\n", x2, y2);
                printf("                x = %.2f   y = %.2f   beta = %.6f",
                       x2p, y2p, coord.bugfat/TWO32);
                printf("   ** arc ==> %ld vectors **\n", vector_count);
                }
#endif
            vectr[0].xx = x1p;
            vectr[0].yy = y1p;
            m2 = y1p_i;
            m1 = x1p_i;
            for (jj=1;  jj <= vector_count;  jj++)
                {
                do_xy_trans (vectr[jj].xx, vectr[jj].yy,
                             &vectr[jj].xx, &vectr[jj].yy);
                m4 = m2;
                m3 = m1;
                m2 = ROUND(vectr[jj].yy);
                m1 = ROUND(vectr[jj].xx);
                if (scan_in_x)
                    {
                    if (m2 != m4 || m1 != m3)
                        proc_vect (vectr[jj-1].xx, vectr[jj-1].yy,
                                   vectr[jj].xx, vectr[jj].yy,
                                   m3, m1, m4, m2, &fs_ptr);
                    }
                else
                    {
                    if (m2 != m4)
                        proc_vect (vectr[jj-1].xx, vectr[jj-1].yy,
                                   vectr[jj].xx, vectr[jj].yy,
                                   m3, m1, m4, m2, &fs_ptr);
                    }
                }
            x2p = vectr[vector_count].xx;
            y2p = vectr[vector_count].yy;
            y2p_i = m2;
            x2p_i = m1;
            dealloc ((ufix8 *)vectr);
            }

        else if (ii == STARTCRV)    /* initialize to start coordinate */
            {
          /* Set up transformation data */
            curve_count++;      /* Increment curve count */
            if (curve_count == 1)  /* First curve in outline data? */
                {
                new_subchar();
                setup_trans(cur_char_no,
                    (*pstack).xscale_nom, (*pstack).yscale_nom,
                    (*pstack).xscale, (*pstack).yscale,
                    (*pstack).xoff, (*pstack).yoff, compc);
                }
            x2 = coord.xx;      /* (X,Y)  raw value */
            y2 = coord.yy;
          /* (X,Y) transformed to pixel coordinates */
            do_xy_trans ((real)x2, (real)y2, &x2p, &y2p);
            y2p_i = ROUND(y2p);
            x2p_i = ROUND(x2p);
#ifdef CONVERTDBG
            if (print_data)
                {
                printf("\n    Start       x = %ld   y = %ld\n", x2, y2);
                printf("                x = %.2f   y = %.2f\n", x2p, y2p);
                }
#endif
            }

        else if (ii == ENDCRV)      /* obsolete, so just get next token */
            continue;

       /* Set new scaling factors in x, y. Put values on stack; does not  */
       /*  take effect until the next DO CHAR. */
        else if (ii == SETSCALE)
            {
            q1 = (float)coord.xx / 65536;
            (*(pstack+1)).xscale = (*pstack).xscale * q1;
            (*(pstack+1)).xscale_nom = (*pstack).xscale_nom * q1;
            q1 = (float)coord.yy / 65536;
            (*(pstack+1)).yscale =  (*pstack).yscale * q1;
            (*(pstack+1)).yscale_nom = (*pstack).yscale_nom * q1;
#ifdef CONVERTDBG
            if (print_data)
                printf("    Set scale    x = %.2f   y = %.2f\n",
                       (*(pstack+1)).xscale, (*(pstack+1)).yscale);
#endif
            }

       /* Set new origin offsets in x, y. Put values on stack; does not   */
       /*  take effect until the next DO CHAR. */
        else if (ii == SETORIG)     /* set new origin offset */
            {
            (*(pstack+1)).xoff = (*pstack).xoff + (*pstack).xscale * coord.xx;
            (*(pstack+1)).yoff = (*pstack).yoff + (*pstack).yscale * coord.yy; 
#ifdef CONVERTDBG
            if (print_data)
                printf("    Set origin   x = %.2f   y = %.2f\n",
                       (*(pstack+1)).xoff, (*(pstack+1)).yoff);
#endif
            }

        else if (ii == DOCHAR)
            {
        /* Push old values of x and y scaling and offsets onto a stack. Set */
        /* up new stack frame for next DOCHAR (DOCHAR's can be nested 16    */
        /* times) */
            (*pstack).pc = pthis_rec;   /* save pointer to outline data */
            stack_count++;
            if (stack_count >= 16)
                {
                printf("\n*** STACK OVERFLOW in \"char_scan_convert\" at font address = %ld\n",
                       (fix31)(pthis_rec - pfirst_rec));
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
            pthis_rec = cfontp->chdir_dat[coord.xx].outline_offs + pfirst_rec;                                

            open_put_cache_data();   /* prepare to read zone data  */
            curve_count = 0;         /* init curve count for sub-character */
            cur_char_no = coord.xx;  /* new character offset number */

#ifdef CONVERTDBG
            if (print_data)
                {
                printf("    DO CHAR  %ld,  xoff = ", coord.xx);
                printf("%.2f  yoff = %.2f,   xscale = %.2f  yscale = %.2f\n",
                       (*pstack).xoff, (*pstack).yoff,
                       (*pstack).xscale, (*pstack).yscale);
                }
#endif
            }

        else if (ii == ENDCHAR)     /* end character, OR pop stack frame */
            {
            if (stack_count == 0)   /* if nothing to pop, character is done */
                break;
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
                if (print_data)
                    {
                    printf("    END DO CHAR   xoff = ");
                    printf("%.2f  yoff = %.2f,   xscale = %.2f  yscale = %.2f\n",
                           (*pstack).xoff, (*pstack).yoff,
                           (*pstack).xscale, (*pstack).yscale);
                    }
#endif
                }
            }

        else if (ii == XZONE)       /* X zone; save data */
            {
            from = coord.xx;
            to = coord.yy;
            flags = coord.bugfat;
            pfunct = pthis_rec;
            put_cache_data(cur_char_no, (fix15) X_DIMENSION, from, to, flags, pfunct);
            }

        else if (ii == YZONE)       /* Y zone; save data  */
            {
            from = coord.xx;
            to = coord.yy;
            flags = coord.bugfat;
            pfunct = pthis_rec;
            put_cache_data(cur_char_no, (fix15) Y_DIMENSION, from, to, flags, pfunct);
            }

        else if (ii == PITEM)       /* P item; ignore */
            {
            }

        else if (ii == FITEM)       /* F item;  ignore */
            {
            }

        else if (ii == CONST)       /* Constant item; ignore */
            {
            }

        else if (ii == OPCODE)      /* Op code; ignore */
            {
            }

        else if (ii == TITEM)       /* T item; ignore */
            {
            }

        else if (ii == X_MIN_EXTENT)
            {
#ifdef CONVERTDBG
            if (print_data)
                printf("Left extent: %d\n", coord.xx);
#endif
            if (compc->squeeze.left && (coord.xx < left_limit) && stack_count == 0)
                {
                left_limit_adj = coord.xx;
                stack[0].xscale = stack[1].xscale = 
                    reqd_width / (right_limit_adj - left_limit_adj);
                stack[0].xoff = stack[1].xoff = 
                    (left_limit - left_limit_adj) * stack[0].xscale;
                }
            }

        else if (ii == X_MAX_EXTENT)
            {
#ifdef CONVERTDBG
            if (print_data)
                printf("Right extent: %d\n", coord.xx);
#endif
            if (compc->squeeze.right && (coord.xx > right_limit) && stack_count == 0)
                {
                right_limit_adj = coord.xx;
                stack[0].xscale = stack[1].xscale = 
                    reqd_width / (right_limit_adj - left_limit_adj);
                stack[0].xoff = stack[1].xoff = 
                    (left_limit - left_limit_adj) * stack[0].xscale;
                }
            }

        else if (ii == Y_MIN_EXTENT)
            {
#ifdef CONVERTDBG
            if (print_data)
                printf("Bottom extent: %d\n", coord.yy);
#endif
            if (compc->squeeze.bottom && (coord.yy < bottom_limit) && stack_count == 0)
                {
                bottom_limit_adj = coord.yy;
                }
            q1 = bottom_limit / bottom_limit_adj;
            if (q1 < stack[0].yscale)
                {
                stack[0].yscale = stack[1].yscale = q1;
                }
            }

        else if (ii == Y_MAX_EXTENT)
            {
#ifdef CONVERTDBG
            if (print_data)
                printf("Top extent: %d\n", coord.yy);
#endif
            if (compc->squeeze.top && (coord.yy > top_limit) && stack_count == 0)
                {
                top_limit_adj = coord.yy;
                }
            q1 = top_limit / top_limit_adj;
            if (q1 < stack[0].yscale)
                {
                stack[0].yscale = stack[1].yscale = q1;
                }
            }

        else if (ii == IGNORE)      /* just get next token */
            continue;

        else                        /* snafu */
            {
            printf("\n*** ILLEGAL CODE returned by \"get_comp_token\"\n");
            printf("    Halt at font address %ld\n", (fix31)(pthis_rec - pfirst_rec));
            return(FALSE);      /* skip remainder of this character */
            }
        }       /* end  WHILE ((ii = get_comp_token(...) ...  */
#ifdef CONVERTDBG
    if (print_data)
        printf("\n");
#endif

  /*  The set width is computed by 'do_comp_x_trans'. If the set width is
   *  unconstrained, the result of the function may actually be different from
   *  simply scaling ORU's to pixels. Set width is rounded down at int + .5  */
    bitmap_inf->set_width = (fix15) (do_comp_x_trans
        ((float)(stack[0].xoff + right_limit_adj * stack[0].xscale)) + 0.499);

    if (char_extent.ymax < char_extent.ymin)
        {                       /* no extents; must be a space character */
        char_extent.xmax = 0;
        char_extent.xmin = 0;
        char_extent.ymax = 0;
        char_extent.ymin = 0;
        }
    else
        {
       /* Clip the character extents, if clipping is in effect */
        if (compc->clip.right  &&  char_extent.xmax > bitmap_inf->set_width)
            char_extent.xmax = bitmap_inf->set_width;
        if (compc->clip.left  &&  char_extent.xmin < 0)
            char_extent.xmin = 0;
        if (compc->clip.bottom  ||  compc->clip.top)
            {
            /* m1 = # lines above baseline; m2 = # lines below baseline */
            m2 = floor ((double)-EM_BOT / EM_TOTAL * compc->lines_per_em + 0.5);
            m1 = (fix31)(floor (compc->lines_per_em + .499)) - m2;
            }
        if (compc->clip.top  &&  char_extent.ymax > m1)
            char_extent.ymax = m1;
        if (compc->clip.bottom  &&  char_extent.ymin < -m2)
            char_extent.ymin = -m2;

       /*  If raster width or height is zero, increase each extent
        *  by one to prevent rectangles < 1 pixel wide from vanishing */
        if (char_extent.xmin == char_extent.xmax)
            {
            char_extent.xmin--;
            char_extent.xmax++;
            }
        if (char_extent.ymin == char_extent.ymax)
            {
            char_extent.ymin--;
            char_extent.ymax++;
            }
        }
    bitmap_inf->raswid = char_extent.xmax - char_extent.xmin;
    bitmap_inf->rashgt = char_extent.ymax - char_extent.ymin;
    bitmap_inf->offhor = char_extent.xmin;
    bitmap_inf->offver = char_extent.ymin;

#ifdef CONVERTDBG
    if (print_data)
        print_out (pbitmap, bitmap_inf);
#endif

    if (!convert_lists (bitmap_inf, pbitmap))
        {
        report_error ("Cannot form bitmap for character %d", char_nr);
        return(FALSE);
        }

    return(TRUE);
    END


FUNCTION  static  void  proc_vect (xf1, yf1, xf2, yf2,
                                   xi1, xi2, yi1, yi2, fs_ptr)
  real      xf1, yf1, xf2, yf2;
  fix31     xi1, xi2, yi1, yi2;
  xi_le   **fs_ptr;

/*  PROC_VECT -- Fills x and y line intercept lists
 *  Input arguments:
 *    xf1, yf1 -- 1st endpoint of line segment (in pixel space)
 *    xf2, yf2 -- 2nd endpoint of line segment
 *    xi1, yi1 -- 1st endpoint of line segment (rounded to integer)
 *    xi2, yi2 -- 2nd endpoint of line segment
 *    fs_ptr -- ptr to free space pointer
 *  Output arguments:  fs_ptr modified
 *  Called from:  char_scan_convert
 *
 *  From a line segment in pixel coordinate space the intersections in x are
 *  calculated at half-integer y values for the y-intercept list, and the
 *  intersections in y are calculated at half-integer x values for the
 *  x-intercept list. The intersections in y are stored in linked lists sorted
 *  by x- or y-position. 'fs_ptr' points to a pool of free memory used by the
 *  linked lists.
 *  Data type xi_le defined in source file polyfill.h
 *  Globals used: 'yslist', 'xslist', 'free_space', 'subchar_count',
 *                 char_extent, scan_in_x
 */

    DECLARE
    real        alpha_x;        /* step size for computing x-intercepts */
    real        alpha_y;        /* step size for computing y-intercepts */
    fix31       alpha_xi;       /* fix-point vrsn of alpha_x, 16 frac bits */
    fix31       alpha_yi;       /* fix-point vrsn of alpha_y, 16 frac bits */
    xi_le      *fsp1;           /* free space pointer (fsp1 = *fs_ptr) */
    fix15       how_many_y;     /* # of intercepts at y = n + 1/2  */
    fix15       how_many_x;     /* # of intercepts at x = n + 1/2  */
    fix15       ii;             /* temp */
    real        q1, q2;         /* temps */
    real        xcept;          /* x-intercept */
    fix31       xcept_int;      /* fix pt. x-intercept, 16 fract bits */
    real        ycept;          /* y-intercept */
    fix31       ycept_int;      /* fix pt. y-intercept, 16 fract bits */
    xi_le     **yscan;          /* ptr to lists of x-intercepts */
    xi_le     **xscan;          /* ptr to lists of y-intercepts */
    fix15       y_start;        /* for each vector, lowest y-scan line */
    fix15       x_start;        /* for each vector, leftmost x-scan line */
    fix15       yscan_index;    /* index for yscan */
    fix15       xscan_index;    /* index for xscan */

    ufix8      *alloc();        /* allocate memory block */
    void        add_scan_list();  /* add element to scan conversion list */


    BEGIN
    if (yi1 <= yi2)
        {
        how_many_y = yi2 - yi1;
        y_start = yi1;
        }
    else
        {
        how_many_y = yi1 - yi2;
        y_start = yi2;
        }
    if (xi1 <= xi2)
        {
        how_many_x = xi2 - xi1;
        x_start = xi1;
        }
    else
        {
        how_many_x = xi1 - xi2;
        x_start = xi2;
        }

   /* Update the character extents */
    if (char_extent.ymin > y_start)
        char_extent.ymin = y_start;
    if (char_extent.ymax < y_start + how_many_y)
        char_extent.ymax = y_start + how_many_y;
    if (char_extent.xmin > x_start)
        char_extent.xmin = x_start;
    if (char_extent.xmax < x_start + how_many_x)
        char_extent.xmax = x_start + how_many_x;

   /* Make sure there will be enough free space and allocate more if necessary */
    if (!scan_in_x)
        how_many_x = 0;         /* this will skip all scan conversion in X */
    fsp1 = *fs_ptr;
    if (free_space < (ii = how_many_x + how_many_y))
        {
        assert(alloc((ufix32) MAX(FSPCT, ii) * sizeof(xi_le))  != NULL);
        free_space += MAX(FSPCT, ii);
        }

   /* Line segment goes from (xf1, yf1) to (xf2, yf2)
        (xi1, yi1) and (xi2, yi2) are these endpoints rounded to integers
      alpha_y is the slope of the line; alpha_x is the inverse slope
      xcept and ycept are not really explainable in words, but are derived
        from the equations for a line:  x = (1/s)(y - y1) + x1  and
        y = s(x - x1) + y1,  (s is the slope, (x1, y1) is a point on the line)
      alpha_xi, alpha_yi, xcept_int, ycept_int are fixed point numbers: the 16
        high-order bits are for the integer and the 16 low-order bits are
        for the fraction */
    q1 = xf2 - xf1;
    q2 = yf2 - yf1;
    if (how_many_y)
        {
        yscan = yslist[subchar_count - 1];      /* lists for current subcharacter */
        alpha_x = q1 / q2;      /* inverse slope of line */
        alpha_xi = floor(65536. * alpha_x + 0.5);
        xcept = xf1 + alpha_x * (((real)y_start - .5) - yf1);
        xcept_int = floor(65536. * xcept + 0.5);
       /* Start from the lowest scan line; go to the highest */
        yscan_index = y_start + bsloff_y;
        for (ii = 0;  ii < how_many_y;  ii++, yscan_index++)
            {
            xcept_int += alpha_xi;  /* intercept pt: (xcept_int, yscan_index + .5)  */
            fsp1->intc = xcept_int;
            add_scan_list (fsp1, yscan, yscan_index);
            fsp1++;
            }
        }
    if (how_many_x)
        {
        xscan = xslist[subchar_count - 1];
        alpha_y = q2 / q1;      /* slope of line */
        alpha_yi = floor(65536. * alpha_y + 0.5);
        ycept = yf1 + alpha_y * (((real)x_start - .5) - xf1);
        ycept_int = floor(65536. * ycept + 0.5);
        xscan_index = x_start + bsloff_x;
        for (ii = 0;  ii < how_many_x;  ii++, xscan_index++)
            {
            ycept_int += alpha_yi;  /* intercept pt: (ycept_int, xscan_index + .5)  */
            fsp1->intc = ycept_int;
            add_scan_list (fsp1, xscan, xscan_index);
            fsp1++;
            }
        }

    free_space -= (how_many_x + how_many_y);
    *fs_ptr = fsp1;                 /* update free space pointer */
    return;
    END


FUNCTION  void  add_scan_list (freesp, scan, scan_index)
  xi_le    *freesp;
  xi_le   **scan;
  fix15     scan_index;

/*  ADD_SCAN_LIST -- puts freesp into a linked list. The list is sorted in
 *      in ascending order by freesp->intc
 *  Input arguments:
 *    freesp -- free space pointer
 *    scan -- ptr to lists of x- or y-intercepts
 *    scan_index -- index for scan
 *  Output arguments:
 *  Called from:  proc_vect
 */

    DECLARE
    xi_le      *ex1;
    xi_le      *ex2;

    BEGIN
    ex1 = scan[scan_index];
    if (ex1 == 0)           /* null list */
        {
        freesp->int_next = 0;       /* create 1st list element */
        scan[scan_index] = freesp;
        }
    else if (freesp->intc <= ex1->intc) /* insert new value into the */
        {                               /*  list in the 1st position */
        freesp->int_next = ex1;
        scan[scan_index] = freesp;
        }
    else                    /* insert new x-value into the list */
        {
        while (TRUE)            /* loop until find a larger x in the */
            {                   /*   list or until reach end of list */
            ex2 = ex1->int_next;
            if (ex2 == 0)
                {
                freesp->int_next = 0;
                ex1->int_next = freesp;
                break;
                }
            else if (freesp->intc <= ex2->intc)
                {
                freesp->int_next = ex2;
                ex1->int_next = freesp;
                break;
                }
            else
                ex1 = ex2;
            }
        }
    END

#if m68000
#define INT_PART    0   /* high word of a four byte value on a 68000 type CPU */
#define FRACT_PART  1   /* low word   ""  */
#else
#define INT_PART    1   /* high word of a four byte value on a PDP11 type CPU */
#define FRACT_PART  0   /* low word   ""  */
#endif


FUNCTION  static  bool  convert_lists (bitmap_inf, char_bmap)
  btminf   *bitmap_inf;
  bit8    **char_bmap;

/*  CONVERT_LISTS -- Creates a bitmap from the scan-conversion lists
 *  Input arguments:
 *    bitmap_inf -- raster dimensions, offsets
 *  Output arguments:
 *    char_bmap -- pointer to character bitmap. Allocates memory for bitmap
 *                 and returns filled bitmap.
 *  Called from:  char_scan_convert
 *  Returns:  TRUE if all goes well
 *            FALSE if bitmap is too large or
 *                  if on any scan line the number of intercepts is odd
 *
 *  The bitmap starts at a byte boundary, beginning at the top scan line of
 *  the minimum rectangle, going left-to-right. There is no padding of bits at
 *  the end of each scan line.
 */

    DECLARE
    bit8       *aa;             /* character bitmap */
    fix15       bit1, bit2;     /* 1st bit on, last bit on */
    xi_le      *ex1;            /* x-, y-intercept list elements */
    fix15       ii, jj, kk;     /* temps */
    fix15       offhor;         /* hor. offset to minimum bitmap (from origin) */
    fix15       rhgt, rwid;     /* raster height, width of character */
    bool16      setbit_flag;    /* TRUE if bit filling happens */
    ufix32      size_bm;        /* size of bitmap in bytes */
    fix31       thresh_black;   /* threshold for dropping a thin stroke */
    fix31       thresh_white;   /* threshold for ignoring white space */
    fix31       onepix;         /* 1.0 pixels * 64K */
    xi_le     **xscan;          /* pointer to array of lists of y-intercepts */
    xi_le     **yscan;          /* pointer to array of lists of x-intercepts */
    fix15       xleft;          /* leftmost raster column of bitmap character */
    fix15       ytop;           /* top raster row of bitmap character */
    fix31       zz, zz1, zz2;   /* temps */
    fix15      *zzs;            /* ptr to 32-bit word so it can be read as 2 16-bit words */

    ufix8      *alloc_bitmap();
    void        convert_thresh();   /* decide which pixel to turn on, while attempting to preserve white space */
    void        set_bits();         /* sets bits in a bitmap scan line */
    void        report_error();     /* error message reporting routine */

    BEGIN
    rwid = bitmap_inf->raswid;
    rhgt = bitmap_inf->rashgt;
    offhor = bitmap_inf->offhor;
    size_bm = ((ufix32)rhgt * rwid + 7) / 8;
    if (size_bm < 1000000  &&  size_bm != 0)    /* allocate memory for bitmap */
        {        /* allocate memory for bitmap */
        if ((*char_bmap = (bit8 *)alloc_bitmap(size_bm)) == NULL)
            {
            report_error("Bitmap is too large to generate (%d x %d)",
                rwid, rhgt);
            return (FALSE);
            }
        }
    else
        {
        *char_bmap = NULL;
        return (TRUE);
        }
    aa = *char_bmap;
    for (ii=0; ii < size_bm;  ii++)     /* clear bitmap memory area */
        aa[ii] = 0;
    zzs = (fix15 *)(&zz);
    thresh_black = 3277;        /* .05 pixel threshold (.05 * 65536) */
    thresh_white = 3277;

    ytop = char_extent.ymax - 1 + bsloff_y;     /* top bitmap scan line */
    for (jj = 0; jj < subchar_count; jj++)  /* for each sub-character */
        {
        yscan = yslist[jj];
        for (ii = 0; ii < rhgt; ii++)
            {
           /* ex1 points to a list of x-intercepts for 1 y scan line */
            ex1 = yscan[ytop - ii];
            if (ex1 != 0)       /* if ex1 = 0, there's nothing in this row */
                {
                /*  The basic fill algorithm is that if the center of a pixel
                 *  is in the interior of the outline, that pixel is turned
                 *  on. Intercepts must come in pairs. Each one is a 32-bit
                 *  number with a 16-bit integer part and a 16-bit fractional
                 *  part, represented by zzs[INT_PART] and zzs[FRACT_PART].
                 *  If the first x- (y-) intercept is in the right (top) half
                 *  of the pixel, then the fractional part will be a negative
                 *  16-bit number. We don't want to include that pixel. If the
                 *  second x- (y-) intercept is in the left (bottom) half of the
                 *  pixel, then the fractional part will be a positive 16-bit
                 *  number. We don't want to include that pixel either. */
                while (TRUE)        /* list is not null */
                    {
                    zz = ex1->intc;     /* 1st intercept */
                    zz1 = zz;
                    bit1 = zzs[INT_PART];
                    if (zzs[FRACT_PART] < 0)  bit1++;

                    ex1 = ex1->int_next;  /* Next list element */
                    if (ex1 == 0)
                        {
                        printf("\n*** Odd number of intercepts at yscan = %d\n", ytop - ii);
                        return(FALSE);
                        }
                    zz = ex1->intc;     /* 2nd intercept */
                    bit2 = zzs[INT_PART];
                    if (zzs[FRACT_PART] >= 0)  bit2--;

                    if (bit2 >= bit1)   /* Is segment at least one pixel wide? */
                        {
                        if (bit1 < char_extent.xmin)    /* clipping */
                            bit1 = char_extent.xmin;
                        if (bit2 >= char_extent.xmax)
                            bit2 = char_extent.xmax - 1;
                        if (bit2 >= bit1)     /* This test IS necessary */
                            set_bits(*char_bmap, ii, rwid,
                                     bit1 - offhor, bit2 - offhor);
                        }
                    else
                        /* If a thin stroke does not include the center of any
                           pixel, then if the stroke width is greater than
                           the threshold, one pixel is turned on anyway.  */
                        {
                        if (zz - zz1  >  thresh_black)
                            {
                            convert_thresh (thresh_black, thresh_white,
                                            yscan[ytop - ii], ex1, *char_bmap,
                                            bitmap_inf, (fix31)ii, X_DIMENSION);
                            }
                        }

                    ex1 = ex1->int_next;
                    if (ex1 == 0)  break;       /* at the end of each list */
                    }           /* end WHILE (TRUE) {  */
                }
            }           /* end  FOR (II = 0; II < RHGT; II++)  { */
        }           /* end  FOR (JJ = 0; JJ < SUBCHAR_COUNT; JJ++)  { */

    if (!scan_in_x)
        return (TRUE);          /* don't bother with xscan lists */

    /* Now fill in the gaps by checking the xscan lists of y-intercepts. Ignore
       runs of > 1.0 pixel. If < 1.0 pixel add that pixel to the bitmap */
    xleft = char_extent.xmin + bsloff_x;        /* leftmost scan line */
    onepix = 65536L;            /* 1.0 pixels */
    for (jj = 0; jj < subchar_count; jj++)  /* for each sub-character */
        {
        xscan = xslist[jj];
        for (ii = 0; ii < rwid; ii++)
            {
            ex1 = xscan[xleft + ii];
            if (ex1 != 0)
                {
                while (TRUE)
                    {
                    zz1 = ex1->intc;        /* 1st y-intercept */
                    ex1 = ex1->int_next;
                    if (ex1 == 0)
                        {
                        printf("\n*** Odd number of intercepts at xscan = %d\n", xleft + ii);
                        return(FALSE);
                        }
                    zz2 = ex1->intc;        /* 2nd y-intercept */

                    if ((zz2 - zz1)  <  onepix)
                        {               /* < 1.0 pixel long */
                        zz = zz1;
                        bit1 = zzs[INT_PART];
                        if (zzs[FRACT_PART] < 0)  bit1++;
                        zz = zz2;
                        bit2 = zzs[INT_PART];
                        if (zzs[FRACT_PART] >= 0)  bit2--;
                        if (bit2 != bit1)
                            {           /* run is < 1.0 pixel; does not cover a pixel center */
                            if ((zz2 - zz1)  >  thresh_black)
                                {       /* run > threshold, so we can still use it */
                                convert_thresh (thresh_black, thresh_white,
                                                xscan[xleft + ii], ex1, *char_bmap,
                                                bitmap_inf, (fix31)ii, Y_DIMENSION);
                                }
                            }
                        }
                    ex1 = ex1->int_next;
                    if (ex1 == 0)  break;
                    }
                }
            }
        }

    return(TRUE);
    END


FUNCTION  static  void  convert_thresh (thresh_black, thresh_white, ex1, ex2,
                                        bmap, bitmap_inf, scanline, dimension)
  fix31     thresh_black;   /* threshold for narrowest stroke */
  fix31     thresh_white;   /* threshold for ignoring white space */
  xi_le    *ex1, *ex2;      /* beginning of list; match element */
  bit8     *bmap;           /* bitmap pointer */
  btminf   *bitmap_inf;     /* bitmap raster dimensions */
  fix31     scanline;       /* scan line in bitmap (0 = top) */
  fix       dimension;      /* 0=X, 1=Y */

    DECLARE
    xi_le  *ex1_this, *ex2_this;    /* current list pair */
    xi_le  *ex1_prev, *ex2_prev;    /* previous list pair (or 0) */
    xi_le  *ex1_next, *ex2_next;    /* n*ext list pair (or 0) */
    fix31   bit_set;                /* set this bit in bitmap if > 0  */
    fix31   bit, row;               /* bit, row in character bitmap */
    fix31   first_choice;           /* best bit to set by ctr of gravity */
    fix31   second_choice;          /* next-best bit */
    bool16  second_on;              /* use or don't use second_choice */
    fix31   nn;
    fix31   prev_edge;              /* right edge of prev list pair */
    fix31   next_edge;              /* left edge of next list pair */
    fix31   prev_length;            /* length of previous run */
    fix31   next_length;            /* length of next run */
    fix31   whitesp;                /* length of whitespace */
    fix31   zz, zz1, zz2;           /* temps */
    fix15  *zzs;        /* ptr to 32-bit word so it can be read as 2 16-bit words */

    void    set_1_bit();            /* sets  " "   */

    BEGIN
    ex1_prev = ex2_prev = 0;
    ex1_this = ex1;
    zzs = (fix15 *)(&zz);
    prev_edge = -10000;
    next_edge = 10000;
    bit_set = -10000;
    while (TRUE)
        {
        if (ex1_this == 0)
            goto error1;
        ex2_this = ex1_this->int_next;
        if (ex2_this == 0)
            goto error1;
        if (ex2 != ex2_this)
            {
            ex1_prev = ex1_this;
            ex2_prev = ex2_this;
            ex1_this = ex2_this->int_next;
            }
        else
            {
            ex1_next = ex2_this->int_next;
            if (ex1_next != 0)
                {
                ex2_next = ex1_next->int_next;
                if (ex2_next == 0)
                    ex1_next = 0;
                }
            if (ex1_prev != 0)
                {
                whitesp = ex1_this->intc - ex2_prev->intc;
                if (whitesp > thresh_white)
                    prev_edge = (ex2_prev->intc - 32768L) >> 16;
                else
                    ex1_prev = 0;
                }
            if (ex1_next != 0)
                {
                whitesp = ex1_next->intc - ex2_this->intc;
                if (whitesp > thresh_white)
                    next_edge = (ex1_next->intc + 32768L) >> 16;
                else
                    ex1_next = 0;
                }
            zz1 = ex1_this->intc;
            zz2 = ex2_this->intc;
            if ((zz = zz2 - zz1) < thresh_black  ||  zz > 65536L)
                goto error2;

            zz = (zz1 + zz2) / 2;
            first_choice = zzs[INT_PART];
            if (prev_edge < (first_choice - 1)  &&
                    next_edge > (first_choice + 1))
                {
                bit_set = first_choice;
                break;
                }

            /* if stroke is split between 2 pixels, and at < 4:1 ratio */
            nn = ((fix31)(ex2_this->intc -
                          ((ex2_this->intc + 32768L) & 0xFFFF0000))  <<  16) /
                 (ex2_this->intc - ex1_this->intc);
            if (nn >= 13107  &&  nn <= 52429)   /* 20%, 80% of 65536 */
                second_on = TRUE;
            else
                second_on = FALSE;

            if (second_on)
                {
                if (zzs[FRACT_PART] >= 0)
                    second_choice = first_choice - 1;
                else
                    second_choice = first_choice + 1;
                if (prev_edge < (second_choice - 1)  &&
                        next_edge > (second_choice + 1))
                    {
                    bit_set = second_choice;
                    break;
                    }
                }

            /* do not set bit if 1st, 2nd choices fail */
/*          bit_set = first_choice;      /* set bit if 1st, 2nd choices fail */
            break;
            }
        }

    if (bit_set != -10000)
        {
        if (dimension == X_DIMENSION)
            {
            bit_set -= char_extent.xmin;
            if (bit_set >= 0  &&  bit_set < bitmap_inf->raswid)
                set_1_bit (bmap, scanline, bit_set, (fix31)(bitmap_inf->raswid));
            }
        else
            {
            bit = scanline;
            row = char_extent.ymax - 1 - bit_set;
            if (row >= 0  &&  row < bitmap_inf->rashgt)
                set_1_bit (bmap, row, bit, (fix31)(bitmap_inf->raswid));
            }
        }
    return;


error1:     printf("\n*** convert_thresh: error1,  %X\n", ex2);
            return;
error2:     printf("\n*** convert_thresh: error2\n");
            return;
    END
        

FUNCTION  static  fix  get_comp_token (coord)
  arc_type     *coord;          /* arc data type, endpoint + bulge factor */

/*  Reads compressed outline data records using 'get_rec' or 'get_arec'
 *  Returns data in 'coord'
 */
    DECLARE
    fix15    ptype;
    fix31    x, y, beta;
    fix      get_rec();
    fix      get_arec();

    BEGIN
    if (pthis_rec >= plast_rec)
        return(ENDFILE);

/* Trap Call Repeated Sequence codes when in check mode */
#ifdef CONVERTDBG
    if (print_data)
        {
        if ((increm_format && (*pthis_rec & 0xFF00)  ==  0xE200)  ||
              (!increm_format && (*pthis_rec & 0xF000)  ==  0xC000) )
            {
            printf("    Call Repeat     Called from %d    Count = %d    Source Address = %d\n",
                   pthis_rec - pfirst_rec, *pthis_rec & 0x00FF,  *(pthis_rec + 1) );
            }
        }
#endif

    if (increm_format)              /* incremental format */
        get_rec((ufix16) 0, &pthis_rec, pfirst_rec, &ptype, &x, &y, &beta);
    else                            /* absolute format */
#ifdef apollo                       /* only the apollo needs to support absolute format */
        get_arec((ufix16) 0, &pthis_rec, pfirst_rec, &ptype, &x, &y, &beta);
#else
        fprintf(stderr,"\nUNSUPPORTED COMPRESSED FONT FORMAT\n");
#endif /* defined apollo */
    coord->xx = x;
    coord->yy = y;
    coord->bugfat = beta;
    if (ptype == 0)
        return (ENDCHAR);
    else if (ptype == 1)
        return (STARTCRV);
    else if (ptype >= 2  &&  ptype <= 4)
        return (VECT);
    else if (ptype == 5)
        return (ARC);
    else if (ptype == 6)
        return (SETSCALE);
    else if (ptype == 7)
        return (SETORIG);
    else if (ptype == 8)
        return (X_MIN_EXTENT);
    else if (ptype == 9)
        return (X_MAX_EXTENT);
    else if (ptype == 10)
        return (Y_MIN_EXTENT);
    else if (ptype == 11)
        return (Y_MAX_EXTENT);
    else if (ptype == 12)
        return (DOCHAR);
    else if (ptype == 13)           /* hierarchy data */
        return (IGNORE);
    else if (ptype == 14)
        return (XZONE);
    else if (ptype == 15)
        return (YZONE);
    else if (ptype == 16)
        return (PITEM);
    else if (ptype == 17)
        return (FITEM);
    else if (ptype == 18)
        return (CONST);
    else if (ptype == 19)
        return (OPCODE);
    else if (ptype == 20)
        return (TITEM);
    else
        return (SNAFU);
    END

#ifdef CONVERTDBG
FUNCTION  static  void  print_out (pbitmap, bitmap_inf)
  bit8    **pbitmap;            /* contains bitmap */
  btminf   *bitmap_inf;         /* raster dimensions, offsets, set width */

/* This is a diagnostic routine. It prints a character bitmap on stdout */

    DECLARE
    xi_le      *ex1;            /* peruses x-intercept list */
    fix31       ii, jj;         /* temps */
    fix31       n1;
    xi_le     **xscan;          /* pointer to array of lists of y-intercepts */
    xi_le     **yscan;          /* pointer to array of lists of x-intercepts */

    BEGIN

/*  print bitmap here (up to 100 lpm) */

    printf("Scan conversion in Y (baseline = 0):\n");
    for (ii=nbr_scanl_y-1; ii >= 0; ii--)
        {
        for (jj = 0; jj < subchar_count; jj++)
            {
            yscan = yslist[jj];
            ex1 = yscan[ii];
            if (ex1 != 0)
                {
                printf("%3ld:   ", ii - bsloff_y);
                n1 = 0;
                while (TRUE)
                    {
                    n1++;
                    printf("  %.3f", ex1->intc/65536.);
                    ex1 = ex1->int_next;
                    if (n1%16 == 0)  printf("\n");
                    if (ex1 == 0)
                        {
                        printf("\n");
                        break;
                        }
                    }
                }
            }
        }
    printf("\n");

    printf("Scan conversion in X (l.s.b. = 0):\n");
    for (ii=0; ii < nbr_scanl_x; ii++)
        {
        for (jj = 0; jj < subchar_count; jj++)
            {
            xscan = xslist[jj];
            ex1 = xscan[ii];
            if (ex1 != 0)
                {
                printf("%3ld:   ", ii - bsloff_x);
                n1 = 0;
                while (TRUE)
                    {
                    n1++;
                    printf("  %.3f", ex1->intc/65536.);
                    ex1 = ex1->int_next;
                    if (n1%16 == 0)  printf("\n");
                    if (ex1 == 0)
                        {
                        printf("\n");
                        break;
                        }
                    }
                }
            }
        }
    printf("\n");

    END
#endif

FUNCTION  static  void  new_subchar ()

    /* Allocate memory for scan conversion pointers
       A character is compounded of 1 or more subcharacters.
       This routine is called by char_scan_convert (start_curve) at the
       beginning of every character or subcharacter */

    DECLARE
    fix         jj;
    xi_le     **scanlist;       /* ptr to lists of x-intercepts */

    ufix8      *alloc();

    BEGIN
    assert((scanlist = (xi_le **)alloc ((ufix32) nbr_scanl_y * sizeof(pointr))) != NULL);
    yslist[subchar_count] = scanlist;
    for (jj = 0;  jj < nbr_scanl_y;  jj++)   /* initialize lists to 0 */
        scanlist[jj] = 0;

    if (scan_in_x)
        {
        assert((scanlist = (xi_le **)alloc ((ufix32) nbr_scanl_x * sizeof(pointr))) != NULL);
        xslist[subchar_count++] = scanlist;
        for (jj = 0;  jj < nbr_scanl_x;  jj++)   /* initialize lists to 0 */
            scanlist[jj] = 0;
        }
    else
        subchar_count++;

    return;
    END


FUNCTION  fix31  get_required_width (cfont, char_offset)
  cft_outl_str     *cfont;
  fix31     char_offset;

/* GET_REQUIRED_WIDTH -- gets character width, either uses the nominal width or
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


FUNCTION  real  norm_rot (angle)
  real      angle;

/*  Normalizes rotation angle to a value between 0 and 360 degrees */

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
  real      angle;

/*  First normalizes obliquing angle to a value between -90 and 90 degrees */
/*  Then clamps absolute values of greater than 85 degrees */

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

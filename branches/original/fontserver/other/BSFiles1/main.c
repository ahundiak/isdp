




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/******************************** M A I N . C ********************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  05-Jan-87  mby   Changed to support accessing character set file.
                      This version runs from djm's job file format

 2)  06-Mar-87  mby   Kerning code moved to 'kern.c'

 3)  13-Mar-87  tpl   Added PCWINDOWS compile flag to make the BFG
                      program compile with special options for PCFONTWARE
                      for Windows. 

                      Changed output for the PC to reduce scrolling

                      Fixed 16 bit run length encoding bug (Port problem)

                      Fixed BFG on the PC to generate run length encoded
                      characters by default. Run length encoding can be 
                      turned off on the PC (rle_on=FALSE)

                      Moved the function 'csd_ascii()' to this module.

 4)  13-Apr-87  tpl   Added the function report_error() that will be called
                      to report all error messages in the system.
                      added support for PC Fontware csd text files

 5)  21-Apr-87  mby   Force bmap_set_space_width to round down at mumble + .5

 6)  22-May-87  mby   Force tabular 1's to be same width as '0' in
                      convert_outlines(), write_bmapf()

 *****************************************************************************

   This is the top-level module. It reads the input arguments to set up the
   scan conversion parameters (font name, bitmap size, rotation angle, ...).
   Then the scan conversion routine is called for every character. Finally the
   generated bitmaps are inserted into a bitmap font.

 ****************************************************************************/


#include "../hfiles/stdef.h"              /* Bitstream standard macros */
#include "../hfiles/comp2_3.h"            /* data structures for compr'd font */
#include "../hfiles/bmap.h"               /* data structures for bmap fonts */
#include "../hfiles/math.h"
#include "../hfiles/mkbm.h"
#include "../hfiles/polyfill.h"      /* data structures for scan conversion */

/* #define  PCFONTWARE Define for PC Fontware. Jobfile Access, and bmap font name differ */
/* #define  PCWINDOWS  Define in addition to PCFONTWARE for PCFONTWARE with Windows */
/*
 * Description of all valid combinations compile flags that control Fontware source:
 *
 * PCFONTWARE   PCWINDOWS   MSDOS   apollo
 * ---          ---         ---     ---
 * NO           NO          NO      YES         = make_bmap on the Apollo
 * NO           NO          YES     NO          = make_bmap on the PC
 * YES          NO          NO      YES         = PC Fontware on the Apollo
 * YES          NO          YES     NO          = PC Fontware on the PC
 * YES          YES         YES     NO          = PC Fontware for Windows on the PC
 *
 * make_bmap:
 *     uses the Apollo style command line arguments and jobfile.
 *     optionally reads a text format Character Set Descriptor (CSD) file.
 *     This program exists on the PC and Apollo
 *     to build make_bmap, link with reader
 * PC Fontware:
 *     uses the PC style command line arguments and jobfile
 *     optionally reads a text format Character Set Descriptor (CSD) file.
 *     currently does not read a csd binary file on the Apollo.
 *     This program exists on the PC and Apollo. It is what we ship to OEM
 *     customers of PC Fontware.
 *     to build PC Fontware, link with readerpc, and jobacc
 * PC Fontware for Windows:
 *     uses the PC style command line arguments and jobfile
 *     currently reads a csd binary file or a csd text file.
 *     This program only works on the PC. It is bound with modules that may
 *     not be ported to the apollo.
 *     to build PC Fontware for Windows, link with readerpc, jobacc, and csdacc
 */


/***** GLOBALS *****/

cft_outl_str  cfont;            /* compressed font data structure       */
fix         cfont_fd;           /* compressed font file descriptor      */
char        cfont_name[100];    /* compressed font file name            */
FILE       *mfile_fp;           /* job control file descriptor          */
char        mfile_name[100];    /* job control file name                */
float       aspect_ratio;       /* aspect ratio (default = 1)           */
char        bmap_name_field[4]; /* bitmap font name name field          */
fix15       bmap_dev_field;     /* bitmap font name device field        */
fix15       bmap_rev_field;     /* bitmap font name revision field      */
bool16      bogus_mode;         /* True: plaid data to be ignored       */
boolean     clip_left;          /* Clips min x at left of emsquare if true */
boolean     clip_right;         /* Clips max x at right of emsquare if true */
boolean     clip_bottom;        /* Clips min y at bottom of emsquare if true */
boolean     clip_top;           /* Clips max y at top of emsquare if true */
bool16      import_flag;        /* T if import widths option on         */
char        import_name[100];   /* filename of font for importing widths*/
fix15       kerning_flag;       /* 0: no kerning, 1: all pairs, 2: use kerning table */
char        kerning_name[100];  /* pathname with list of kerning pairs  */
float       lines_per_em;       /* vertical # scan lines per em square  */
float       lines_per_emx;      /* horizontal # pixels per em space     */
float       point_size_x;       /* x-point size (72.3 pts per inch)     */
float       point_size_y;       /* y-point size (72.3 pts per inch)     */
float       resh;               /* output device resolution, horizontal */
float       resv;               /* output device resolution, vertical   */
bool16      rle_on = TRUE;      /* Flag allows run length encoding      */
float       rot_angle;          /* rotation angle in degrees (clockwise = positive)  */
float       obl_angle;          /* obliquing angle in degrees (clockwise = positive) */
bool16      setpoint=0;         /* user parameter is point size         */
bool16      setlines=0;         /* user parameter is lines per em       */
boolean     squeeze_left;       /* Squeezes min x into left of emsquare if true */
boolean     squeeze_right;      /* Squeezes max x into right of emsquare if true */
boolean     squeeze_bottom;     /* Squeezes min y into bottom of emsquare if true */
boolean     squeeze_top;        /* Squeezes max y into top of emsquare if true */
bool16      subset_flag;        /* True: subset chars from list of IDs  */
char        subset_name[100];   /* subset file name                     */
bool16      sw_fixed;           /* true if set width constrained        */
float       xht_adj;            /* x height adjustment                  */
char        temp_path[64]="";   /* directory for temporary files        */



/***** STATIC VARIABLES *****/

static bit8   bitmask[8] = { 0x80, 0x40, 0x20, 0x10, 8, 4, 2, 1, };
static bool   print_data = FALSE; /* T to print outline data            */
static struct
    {
    fix15   width48;
    fix15   width203;
    fix15   width2076;
    fix15   offs48;
    fix15   offs49;
    fix15   offs203;
    fix15   offs194;
    fix15   offs2076;
    fix15   offs2022;
    fix15   arr[3];
    } kludge;


FUNCTION  main (argc, argv)
  fix15     argc;
  char    **argv;

/*  This is the main loop of the Bitmap Font Generator.
 *  get_args (found in 'reader.c') reads parameters for making the bitmap font,
 *    e.g. font name, point size. A job control file can be used to make a
 *    collection of bitmap fonts in a single execution of the program. get_args
 *    can read arguments either from the command line or the job control file.
 *  create_bmapf creates a skeleton bitmap font.
 *  convert_outlines scan converts the desired characters in the compressed
 *    outline font and stores the bitmaps in memory.
 *  write_bmapf writes the complete bitmap font.
 */

    DECLARE
    char       bmap_name[256];    /* name of bitmap font file               */
    bmap_font_desc_t  bmfont;     /* ptr to bmap format 1.1 data structure  */

    void       alloc_reset();     /* resets globals for memory allocation   */
    fix        cft_load();        /* loads compressed font into data struct */
    bool       convert_outlines();   /* scan converts font layout           */
    bmap_font_desc_t  create_bmapf();   /* create bitmap font, format B1.1  */
    void       freealloc();       /* frees dynamic memory                   */
    bool       get_args();        /* pick up command line args              */
    void       initalloc();       /* initializes dynamic memory allocation  */
    void       messages();        /* lots of printf statements              */
    fix        init_cache();      /* initialize plaid cache                 */
    bool       write_bmapf();     /* write B1.1 font                        */
    void       report_error();    /* error reporting routine                */
#ifdef PCFONTWARE
    void       write_bmapname();  /* write bitmap file name to job file     */
    void       write_jobfile();   /* write job file                         */
#endif /* PCFONTWARE */

    BEGIN

/*    print_data = TRUE;  */      /* debugging tool */

#ifndef PCWINDOWS /* All except PC Fontware for Windows display copyright notice */
/*  printf("\n\n  BITSTREAM BITMAP FONT GENERATOR, VERSION 1.6, May 24, 1987\n\n");
    printf("  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA\n");
    printf("                            Patent Pending\n\n");
    printf("  These programs are the sole property of Bitstream Inc. and\n");
    printf("  contain its proprietary and confidential information.\n\n\n");
*/
    cfont_name[0] = '\0';
    mfile_name[0] = '\0';
#endif /* PCWINDOWS not defined */

    initalloc();                  /* initialize memory allocation */

    while (TRUE)        /* command mode loop - once per bitmap font */
        {
        if (!get_args (argc, argv))  break;
        if (lines_per_em < 5.501)
            {
            report_error ("Bitmap font is too small to generate (lines per em = %.2f)",
                lines_per_em);

            close (cfont_fd);
            continue;
            }

        init_cache (lines_per_emx, lines_per_em);
        alloc_reset();            /* reset memory allocation */
        if (cft_load (cfont_fd, &cfont) != 0)
            {
            close (cfont_fd);
            report_error("Can't load the compressed font \"%s\"",cfont_name);
            continue;
            }
#ifndef PCWINDOWS   /* All except PC Fontware for Windows display msgs. */
/*      messages();	*/
#endif /* PCWINDOWS */
        if (cfont.fonthead.outl_fmt_nr[1] == '1')
            bogus_mode = TRUE;      /* skip cache searching if absolute format */
        bmfont = create_bmapf (bmap_name);
        if (!convert_outlines (bmfont))
            {
            close (cfont_fd);
            printf("\n*** convert_outlines failure\n\n");
            continue;
            }
        if (write_bmapf (bmfont, bmap_name))
            {
#ifdef PCFONTWARE
            write_bmapname (bmap_name);
#endif /* PCFONTWARE */
#ifdef PCWINDOWS
            printf("\r                                                                             \n", bmap_name);
#else
/*          printf("\nFont \"%s\" written\n\n", bmap_name);	*/
#endif /* PCWINDOWS */
            }
        else
            report_error ("Unable to write font \"%s\"", bmap_name);
        close (cfont_fd);
        }
#ifdef PCFONTWARE
    write_jobfile ();
#endif /* PCFONTWARE */

    freealloc();

    END


FUNCTION  bmap_font_desc_t  create_bmapf(bmap_name)
  char     *bmap_name;

/*  Creates a bitmap font. Sets up the font header and font information
 *    records.
 *  Returns:  a pointer to a bitmap font data structure
 *  Arguments:  none
 *  Called from:  main
 */

    DECLARE
    bmap_font_desc_t  bmfont;   /* ptr to bmap format 1.1 data structure */
    fix         ii;
    fix31       lpm;            /* lines per em */
    fix31       fix_resv, fix_resh; /* resolution to circumvent a bug in MSC */
    char        s_dev[8];
    char        s_lpm[8];
    char        s_rev[8];

    bmap_font_desc_t  bmap_create_bmap();   /* create dummy bitmap font  */
    fix31       bmap_initiate();      /* init memory mgmt, bmap log file */
    fix31       bmap_set_below_baseline();  /* nbr lines below baseline  */
    fix31       bmap_set_bmap_name();       /* cccc.ffff_eee_000_2_1     */
    fix31       bmap_set_bmap_revision();   /* set bitmap rev. number    */
    fix31       bmap_set_bmap_sequence();   /* set bitmap device #       */
    fix31       bmap_set_em_resolution();   /* nbr lines per em          */
    fix31       bmap_set_horizontal_res();  /* pixels per inch           */
    fix31       bmap_set_vertical_res();    /* pixels per inch           */
    fix31       bmap_set_outline_id();      /* 4-digit outline id number */
    fix31       bmap_set_outline_name();    /* Bitstream outline name    */
    fix31       bmap_set_outline_revision(); /* set outline font rev. nr */
    fix31       bmap_set_point_size();      /* bitmap font point size    */
    fix31       bmap_set_space_width();     /* space width in pixels     */


    BEGIN
    bmap_initiate();
    bmfont = bmap_create_bmap();
    bmap_set_outline_id(bmfont, cfont.fonthead.src_font_id);
    bmap_set_outline_name(bmfont, cfont.fonthead.src_font_name);

    lpm = ROUND(lines_per_em - .001);       /* round down at integer + .5 */
    sprintf (s_lpm, "%3d", lpm);
    if (s_lpm[0] == ' ')  s_lpm[0] = '0';
    if (s_lpm[1] == ' ')  s_lpm[1] = '0';
    sprintf (s_rev, "%d", bmap_rev_field);
    sprintf (s_dev, "%3d", bmap_dev_field);
    if (s_dev[0] == ' ')  s_dev[0] = '0';
    if (s_dev[1] == ' ')  s_dev[1] = '0';

/* make output bmap font filename (dependant on the system and the program) */
#ifdef apollo
    sprintf(bmap_name, "%.4s.%.4s_%s_%s_%d_%s",
            bmap_name_field, cfont.fonthead.src_font_id, s_lpm, s_dev,
            cfont.fonthead.src_font_vrsn, s_rev);
#endif /* apollo */
#ifdef MSDOS
    sprintf(bmap_name, "f%4.4s%3.3s.bmp",cfont.fonthead.src_font_id, s_lpm);
#endif /* MSDOS */
#ifdef PCFONTWARE
    make_bmap_name(bmap_name); /* uses jobfile fields to make name if present */
#endif /* PCFONTWARE */
#ifdef IPRO
    sprintf(bmap_name, "%.4s.%.4s_%s",
            bmap_name_field, cfont.fonthead.src_font_id, s_lpm);
#endif /* interpro */

    bmap_set_bmap_name (bmfont, bmap_name);
    bmap_set_bmap_revision (bmfont, (fix31) bmap_rev_field);
    bmap_set_outline_revision (bmfont, (fix31)cfont.fonthead.src_font_vrsn);
    bmap_set_bmap_sequence (bmfont, (fix31) bmap_dev_field);
    bmap_set_em_resolution(bmfont, lpm);
    bmap_set_below_baseline (bmfont,
            (fix31) (ROUND ((float) -EM_BOT / EM_TOTAL * lines_per_em)));
    fix_resv = ROUND(resv);                     /* added (TPL) 08/13/86 */
    bmap_set_vertical_res (bmfont, fix_resv);
    fix_resh = ROUND(resh);                     /* added (TPL) 08/13/86 */
    bmap_set_horizontal_res (bmfont, fix_resh);
    bmap_set_point_size (bmfont, (fix31) (ROUND(point_size_y * 10.)));
    bmap_set_space_width (bmfont,
            (fix31) (cfont.fonthead.wordspace_width * lines_per_emx /
            cfont.fonthead.resl_per_em + .499));
    return(bmfont);
    END

FUNCTION  bool  write_bmapf (bmfont, bmap_name)
  bmap_font_desc_t   bmfont;       /* ptr to bmap format 1.1 data structure */
  char     *bmap_name;

/*  Writes complete bmap font data structure to a file
 *  Input argument:  bmfont, a pointer to a bitmap font data structure
 *  Called from:     main
 */

    DECLARE
    fix15   n1, n2;
    fix31   bmap_terminate();             /* close bmap log file  */
    bmap_font_desc_t  bmap_unload();      /* write bitmap font    */
    fix31   bmap_hierarchical_update();   /* make font consistent */
#ifdef apollo
    void    aplo_fname_bak();       /* checks for pre-existing pathname */
#endif /* apollo */
#ifdef IPRO
    void    ipro_fname_bak();       /* checks for pre-existing pathname */
#endif /* interpro */

    BEGIN
    bmap_hierarchical_update (bmfont);

    /* kludge to force tabular 1's in the bitmap font to be same width as
       other figures, if the outline widths are equal. char_scan_convert()
       may return a difference of + or - 1 because of double rounding     */
    if (cfont.fonthead.flag1 & F_CHARID)
        {
        n1 = 0;
        n2 = kludge.arr[n1];
        for (bmap_first_char (bmfont);
                bmap_this_char (bmfont) != 0; bmap_next_char (bmfont))
            {
            if (n2 <= 0)  break;
            if (bmfont->curr_ch->data->bs_nbr == n2)
                {
                if (n2 == 49)       /* '1' */
                    {
                    if (kludge.width48)
                        {
                        if (cfont.chdir_dat[kludge.offs48].set_width ==
                                cfont.chdir_dat[kludge.offs49].set_width)
                            bmfont->curr_ch->data->set_wid = kludge.width48;
                        }
                    }
                else if (n2 == 194)     /* superior 1 */
                    {
                    if (kludge.width203)
                        {
                        if (cfont.chdir_dat[kludge.offs203].set_width ==
                                cfont.chdir_dat[kludge.offs194].set_width)
                            bmfont->curr_ch->data->set_wid = kludge.width203;
                        }
                    }
                else if (n2 == 2022)    /* inferior 1 */
                    {
                    if (kludge.width2076)
                        {
                        if (cfont.chdir_dat[kludge.offs2076].set_width ==
                                cfont.chdir_dat[kludge.offs2022].set_width)
                            bmfont->curr_ch->data->set_wid = kludge.width2076;
                        }
                    }
                n1++;
                if (n1 >= 3)  break;
                n2 = kludge.arr[n1];
                }
            }
        }

#ifdef apollo
    aplo_fname_bak (bmap_name);
#endif /* apollo */
#ifdef IPRO
    ipro_fname_bak (bmap_name);
#endif /* interpro */
    if (bmap_unload (bmfont, bmap_name, (fix31) TRUE) != NULL)
        return (FALSE);
    bmap_terminate();
    return (TRUE);
    END


FUNCTION  bool  convert_outlines (bmfont)
  bmap_font_desc_t   bmfont;  /* ptr to bmap format 1.1 font data structure */

/* Procedure to read an entire compressed outline font, and scan-convert it
 *   into bitmaps. 'char_scan_convert' does the scan conversion for each
 *   character, returning a minimum-rectangle bitmap. These bitmaps are
 *   appended to a bitmap font data structure by 'bmap_attach_map'.
 *
 * Input argument:
 *    bmfont - pointer to bitmap font data structure with no bitmaps yet
 * Returns:
 *    TRUE if all outlines are successfully scan converted, else FALSE
 * Output argument:
 *    bmfont - pointer to bitmap font data structure w. complete character set
 */

    DECLARE
    fix31       below_bsl;      /* # pixels below baseline in bmap font */
    btminf      bitmap_inf;     /* raster height/width, horiz/vert offsets */
    bit8       *char_map_ptr;   /* beg'ng of character memory allocation */
    bit8       *char_bmap;      /* pointer to character bitmap */
    bit8       *char_run;       /* ptr to char run length encoded bitmap */
    fix31       choff;          /* character offset into compressed font */
    comp_char_desc  compchar;   /* structure of character attributes (mkbm.h) */
    bmap_char_desc_t  dir_desc;  /* ptr to character directory descriptor */
    fix         font_pos;
    float       foutlres;       /* font outline resl/em in outline units */
    bit8       *map;            /* pointer to character bitmap storage */
    fix15       nbr_bitm_chars; /* number of characters in compressed font */
    fix15       nchars;         /* number of characters scan converted */
    fix15       nloop;          /* number of times around loop */
    fix         n1;             /* temp */
    fix15       nprint;         /* prints message to stdout every nprint chars */
    bool        run8;           /* T -> 8-bit ; F -> 16-bit run-encoding */
    fix31       size_bm;        /* size of true bitmap - bytes */
    fix31       size_rle;       /* size of run length encoded bitmap in bytes */
    ufix16  subset_list[1024];  /* list of up to 1024 character ids */
    fix         subset_number;  /* number of ids in subset_list */

    ufix8      *alloc();        /* memory (de)allo-  */
    bool        dealloc();      /*  cation routines  */
    bool        dealloc_bitmap();  /* free memory used in character bitmap */
    void        bits_to_runs();    /* bitmap -> run length encoded */
    bool        char_scan_convert();  /* compressed char outline ==> bitmap */
    int         csd_ascii();
    void        do_kerning();   /* puts track and pair kerning information in bitmap font data structure */
    void        init_kludge();
    void        mbyte();
    void        reverse16();
    fix31       search_cid();   /* input: char id #, output: char offset #  */
    void        setup_char();   /* initial values ==> comp char descriptor */

    fix31       bmap_attach_map();
    fix31       bmap_below_baseline();
    bmap_char_desc_t   bmap_insert_dir_rec();
    bmap_char_desc_t   bmap_new_dir_rec();
    bit8       *bmap_new_map();
    fix31       bmap_set_char_bs_nbr();
    fix31       bmap_set_char_flags();
    fix31       bmap_set_char_horiz_offset();
    fix31       bmap_set_char_vert_offset();
    fix31       bmap_set_char_raster_height();
    fix31       bmap_set_char_raster_width();
    fix31       bmap_set_char_set_width();
    fix31       bmap_set_char_bitmap_bytes();
    void        report_error();    /* error reporting routine                */

    BEGIN
    setup_char(&compchar);
    init_kludge();
    nbr_bitm_chars = cfont.fonthead.layout_size;    /* # chars in layout */
    foutlres = (float)cfont.fonthead.resl_per_em;  /* units per emsquare */
    below_bsl = bmap_below_baseline (bmfont);      /* pixels below baseline */
#ifdef PCWINDOWS
    nprint = 10;                        /* print message every 10 characters */
#else
    nprint = 20;                        /* print message every 20 characters */
#endif
    nchars = 0;
    nloop = 0;
    font_pos = 0;
    if (subset_flag)
        {
        subset_number = csd_ascii(subset_name, subset_list, (fix)1024);
        }

    /* Loop to process all characters */
    while (TRUE)
        {
        if (!subset_flag)
            {
            if (nloop >= nbr_bitm_chars)
                break;
            choff = nloop++;
            }
        else
            {
            if (nloop >= subset_number)
                break;                      /* end of subset list */
            choff = search_cid ((fix31)subset_list[nloop++]);
            if (choff == -1)
                {
                report_error("Cannot find character id %4d", subset_list[nloop-1]);
                continue;
                }
            }
        char_map_ptr = (bit8 *)alloc(0L);   /* keeps track of place in memory where we started */
        compchar.choff = choff;
        if (!char_scan_convert (&compchar, &char_bmap, &bitmap_inf))
            {
            dealloc (char_map_ptr); /* deallocate all memory  */
            continue;       /* Most likely to happen if the bitmap is too large to generate */
            }

       /* create character directory record for the new character */
        dir_desc = bmap_new_dir_rec();
        bmap_insert_dir_rec (bmfont, dir_desc);

       /* Set bitmap character ID. If F_CHARID is true, it is a character */
       /*  ID from the compressed outline character directory, otherwise  */
       /*  it is a sequentially numbered character ID                     */
        if (cfont.fonthead.flag1  &  F_CHARID)
            {
            bmap_set_char_bs_nbr(bmfont, (fix31)cfont.chdir_dat[choff].char_id);
            if ((n1 = cfont.chdir_dat[choff].char_id) == 48)    /* '0' */
                {
                kludge.width48 = bitmap_inf.set_width;
                kludge.offs48 = choff;
                }
            else if (n1 == 203)      /* 0 superior */
                {
                kludge.width203 = bitmap_inf.set_width;
                kludge.offs203 = choff;
                }
            else if (n1 == 2076)     /* 0 inferior */
                {
                kludge.width2076 = bitmap_inf.set_width;
                kludge.offs2076 = choff;
                }
            else if (n1 == 49)       /* '1' */
                {
                kludge.offs49 = choff;
                kludge.arr[font_pos++] = 49;
                }
            else if (n1 == 194)      /* 1 superior */
                {
                kludge.offs194 = choff;
                kludge.arr[font_pos++] = 194;
                }
            else if (n1 == 2022)     /* 1 inferior */
                {
                kludge.offs2022 = choff;
                kludge.arr[font_pos++] = 2022;
                }
            }
        else
            bmap_set_char_bs_nbr (bmfont, choff+32);
       /* Set width */
        bmap_set_char_set_width (bmfont, (fix31) bitmap_inf.set_width);

       /* 'char_scan_convert' returns raster width/height and */
       /* horz/vert offsets in structure bitmap_inf           */
        bmap_set_char_raster_width (bmfont, (fix31) bitmap_inf.raswid);
        bmap_set_char_raster_height (bmfont, (fix31) bitmap_inf.rashgt);
        bmap_set_char_horiz_offset (bmfont, (fix31) bitmap_inf.offhor);
       /* In the bitmap font the vertical offset is from the bottom of */
       /* the em-square, not the baseline */
        if (bitmap_inf.rashgt != 0)
            bmap_set_char_vert_offset (bmfont, bitmap_inf.offver + below_bsl);
        else
            bmap_set_char_vert_offset (bmfont, 0L);

#ifdef apollo
       /* Convert the bitmap to a run-length encoded form. Allocate a 10K */
       /* byte buffer for this. Compare the bitmap and the run-length     */
       /* encoded characters. Use the smaller of the two.                 */
        assert((char_run = (bit8 *)alloc((ufix32) 10000)) != NULL);
        size_rle = 0;
        run8 = TRUE;
        for (n1 = 0; n1 < bitmap_inf.rashgt; n1++)   /* for every bitmap row */
            bits_to_runs (char_bmap, n1, bitmap_inf.raswid,
                          char_run, &size_rle, &run8);
        size_bm = (bitmap_inf.rashgt * bitmap_inf.raswid + 7) / 8;
        if (size_bm <= size_rle)        /* real bitmap */
            {
            bmap_set_char_bitmap_bytes (bmfont, size_bm);
            map = bmap_new_map(size_bm);
            mbyte (char_bmap, map, size_bm);
            bmap_set_char_flags (bmfont, (fix31) 0x1);
            }
        else                            /* run length encoded bitmap */
            {
            bmap_set_char_bitmap_bytes (bmfont, size_rle);
            if (run8)
                bmap_set_char_flags (bmfont, (fix31) 0);
            else
                {
                bmap_set_char_flags (bmfont, (fix31) 0x2);
                reverse16 (char_run, 0, size_rle / 2);    /* swap 16-bit wds */
                }
            map = bmap_new_map (size_rle);
            mbyte (char_run, map, size_rle);
            }
#endif /* apollo */
#ifdef MSDOS
        /* The following changes to bitmap generation code apply to the PC only:
         *      1) rle_on==FALSE suppresses run length encoding for bitmaps
         *         that are less than MAX_STORED_BMAP bytes (~16K)
         *         (a temporary fix to get around a bug in a format converter)
         *      2) no byte switching for run length encoding
         *      3) bitmap bytes are not copied to a buffer (for efficiency)
         *      4) bitmap memory allocation routines limit the maximum
         *         size of a bitmap to MAX_BMAP_BYTES (~32K) (Using a fixed buffer
         *         instead of malloc() or alloc() to avoid complications)
         */
        size_bm = ((ufix32)bitmap_inf.rashgt * bitmap_inf.raswid + 7) / 8;
        if ((size_bm <= MAX_STORED_BMAP) && (!rle_on))    /* real bitmap */
            {
            bmap_set_char_bitmap_bytes (bmfont, size_bm);
            map = char_bmap;
            bmap_set_char_flags (bmfont, (fix31) 0x1);
            }
        else                            /* run length encoded bitmap */
            {
            assert((char_run = (bit8 *)bmap_new_map((ufix32) 10000)) != NULL);
            size_rle = 0;
            run8 = TRUE;
            for (n1 = 0; n1 < bitmap_inf.rashgt; n1++)   /* for every bitmap row */
                bits_to_runs (char_bmap, n1, bitmap_inf.raswid,
                              char_run, &size_rle, &run8);
            if (size_bm <= size_rle)
                {
                bmap_set_char_bitmap_bytes (bmfont, size_bm);
                map = char_bmap;
                bmap_set_char_flags (bmfont, (fix31) 0x1);
                }
            else
                {
                bmap_set_char_bitmap_bytes (bmfont, size_rle);
                map = char_run;
                if (run8)
                    bmap_set_char_flags (bmfont, (fix31) 0);
                else
                    bmap_set_char_flags (bmfont, (fix31) 0x2);
                }
            }
#endif /* MSDOS */
#ifdef IPRO
       /* Convert the bitmap to a run-length encoded form. Allocate a 10K */
       /* byte buffer for this. Compare the bitmap and the run-length     */
       /* encoded characters. Use the smaller of the two.                 */
        assert((char_run = (bit8 *)alloc((ufix32) 10000)) != NULL);
        size_rle = 0;
        run8 = TRUE;
        for (n1 = 0; n1 < bitmap_inf.rashgt; n1++)   /* for every bitmap row */
            bits_to_runs (char_bmap, n1, bitmap_inf.raswid,
                          char_run, &size_rle, &run8);
        size_rle = (size_rle + 3) & (~0x3);	/* make it a multiple of 4 */

        size_bm = ((bitmap_inf.rashgt * bitmap_inf.raswid + 7) / 8) +
        	  3 & (~0x3);		/* make it a multiple of 4 */

        if (size_bm <= size_rle)        /* real bitmap */
            {
            bmap_set_char_bitmap_bytes (bmfont, size_bm);
            map = bmap_new_map(size_bm);
            mbyte (char_bmap, map, size_bm);
            bmap_set_char_flags (bmfont, (fix31) 0x1);
            }
        else                            /* run length encoded bitmap */
            {
            bmap_set_char_bitmap_bytes (bmfont, size_rle);
            if (run8)
                bmap_set_char_flags (bmfont, (fix31) 0);
            else
                {
                bmap_set_char_flags (bmfont, (fix31) 0x2);
                }
            map = bmap_new_map (size_rle);
            mbyte (char_run, map, size_rle);
            }
#endif /* interpro */

        bmap_attach_map (bmfont, map);
        dealloc_bitmap (char_bmap);     /* deallocate bitmap generated by BFG */
        dealloc (char_map_ptr);         /* deallocate all memory  */
        nchars++;
/**     if ((nchars) % nprint == 0)
#ifdef PCWINDOWS
            printf(".");
#else
            printf("  %3d characters generated\n", nchars);
#endif
**/     }

/** if (nchars % nprint != 0)
#ifdef PCWINDOWS
        printf(".");
#else
        printf("  %3d characters generated\n", nchars);
#endif
**/
/** if (nchars == 0)
#ifdef PCWINDOWS
        printf("\r  No characters generated");
#else
        printf("  No characters generated\n");
#endif
**/
    if (kerning_flag)
        do_kerning (bmfont, &cfont);
        
    return(TRUE);
    END


FUNCTION  fix31  search_cid (chr_id)
  fix31     chr_id;

/*  SEARCH_CID -- returns a character offset number.
 *  Input argument:  chr_id is a character id number.
 *  Returns:         character offset number. Set to -1 if no match found for
 *                     a character id number.
 */
    DECLARE
    char   *aa;
    fix31   char_off;
    fix31   ii;

    BEGIN
    char_off = -1;
    for (ii=0; ii < cfont.fonthead.layout_size; ii++)
        {
        if (chr_id == cfont.chdir_dat[ii].char_id)
            {
            char_off = ii;
            break;
            }
        }
    return (char_off);
    END


FUNCTION  void  bits_to_runs (char_bmap, scanline, rwid,
                                      char_run, size_rle, run8)
  bit8     *char_bmap;          /* pointer to character bitmap */
  fix       scanline;           /* scan line in bitmap (0 = top) */
  fix15     rwid;               /* raster width */
  bit8     *char_run;           /* pointer to character run length map */
  fix31    *size_rle;           /* size of character run length map */
  bool     *run8;               /* 8-bit numbers (T) or 16-bit (F) */

/*  BITS_TO_RUNS -- takes a scan line in a bitmap and converts it to
 *      run-length encoded form 'char_run'. The bitmap is in the format
 *      given by the Bitstream Guide to Bitmap Fonts. The main feature
 *      is that each scan line is exactly 'rwid' bits wide.
 *
 *  Input arguments:  char_bmap, size_rle, scanline, rwid
 *  Output arguments:  char_run and size_rle updated
 *       run8 set false if 16-bit words needed (if a run > 255 bits)
 */
    DECLARE
    ufix32  bit_start;
    ufix32  bit_pos;
    ufix32  end_pos;
    fix31   ii;
    bool    in_run;
    bit8   *run_map;
    ufix16 *run_map16;
    ufix32  start_position;
    void    run8to16();

    BEGIN
    run_map = char_run + *size_rle;
    run_map16 = (ufix16 *)run_map;
    if (*run8)  run_map[0] = 0;
    else       run_map16[0] = 0;
    bit_start = (ufix32)scanline * rwid;
    bit_pos = bit_start;
    end_pos = bit_pos + rwid;
    for (in_run = FALSE, ii = 1; bit_pos < end_pos; bit_pos++)
        {
        if (in_run)     /* We are in a "run" already */
            {
            if (char_bmap[bit_pos >> 3]  &  bitmask[bit_pos & 7])
                {
                if (*run8)  /* a bit is found, add 1 to run count */
                    {       /* if exceeds 255, then convert to 16-bit format */
                    if (run_map[ii + 1] < 255)
                        run_map[ii + 1]++;
                    else
                        {
                        run8to16(char_run, size_rle);
                        *run8 = FALSE;
                        run_map16 = (ufix16 *)(char_run + *size_rle);   /* because *size_rle changed (doubled) */
                        run_map16[ii + 1]++;
                        }
                    }
                else
                    run_map16[ii + 1]++;
                }
            else        /* end of a "run" */
                {
                in_run = FALSE;
                ii += 2;
                }
            }

        else if (char_bmap[bit_pos >> 3]  &  bitmask[bit_pos & 7])
            {                   /* begin a new "run" */
            in_run = TRUE;
            start_position = bit_pos - bit_start;
            if (*run8)
                {               /* 8-bit format */
                if (run_map[0] < 255  &&  start_position <= 255)
                    {
                    run_map[0]++;
                    run_map[ii] = (bit8) (start_position);
                    run_map[ii + 1] = 1;
                    }
                else            /* if > 255 runs, convert to 16-bit format */
                    {
                    run8to16(char_run, size_rle);
                    run_map16 = (ufix16 *)(char_run + *size_rle);   /* because *size_rle changed (doubled) */
                    *run8 = FALSE;
                    }
                }
            if (!(*run8))
                {
                run_map16[0]++;
                run_map16[ii] = (ufix16) (start_position);
                run_map16[ii + 1] = 1;
                }
            }
        }

    if (in_run)  ii += 2;
    if (*run8)   *size_rle += ii;
    else         *size_rle += 2 * ii;

    return;
    END

FUNCTION  void  run8to16 (char_run, run_size)
  bit8     *char_run;           /* pointer to character run length map */
  fix31    *run_size;           /* size of character run length map */

/*  RUN8TO16 takes a run-length encoded character that uses 8-bit encoding
 *  and converts to a format using 16-bit encoding
 */
    DECLARE
    fix31   ii;
    ufix16 *map16;
    fix31   size;
    ufix8  *tbuf;
    ufix8  *alloc();
    bool    dealloc();
    void    mbyte();

    BEGIN
    map16 = (ufix16 *)char_run;
    size = *run_size + char_run[*run_size] * 2 + 1;
    assert((tbuf = alloc((ufix32) size)) != NULL);
    mbyte(char_run, tbuf, size);
    for (ii=0; ii<size; ii++)
        map16[ii] = (ufix16)tbuf[ii];
    dealloc(tbuf);
    *run_size += *run_size;     /* times 2 */
    return;
    END


FUNCTION  void  setup_char(compchar)
  comp_char_desc   *compchar;   /* structure - character attributes (mkbm.h) */

    DECLARE
    double    cornermax;        /* maximum distance from origin to character envelope boundary */
    fix31     m1, m2, m3, m4;   /* temps */
    fix31     tmp_fix31;        /* needed to simplify calc. of cornermax */

    BEGIN
    compchar->compf = &cfont;
    compchar->lines_per_em = lines_per_em;
    compchar->point_size_y = point_size_y;
    compchar->point_size_x = point_size_x;
    compchar->res_hor = resh;
    compchar->res_ver = resv;
    compchar->rot_angle = rot_angle;
    compchar->obl_angle = obl_angle;
    compchar->import_widths = import_flag;
    compchar->print_data = print_data;
    compchar->clip.left = clip_left;
    compchar->clip.right = clip_right;
    compchar->clip.top = clip_top;
    compchar->clip.bottom = clip_bottom;
    compchar->squeeze.left = squeeze_left;
    compchar->squeeze.right = squeeze_right;
    compchar->squeeze.top = squeeze_top;
    compchar->squeeze.bottom = squeeze_bottom;
    m1 = cfont.fonthead.extent_x_min;
    m2 = cfont.fonthead.extent_x_max;
    m3 = cfont.fonthead.extent_y_min;
    m4 = cfont.fonthead.extent_y_max;
   /* Maximum distance to character envelope boundary in ORU's */
    tmp_fix31 = MAX (m1*m1 + m3*m3, m1*m1 + m4*m4);
    cornermax = sqrt ((double)MAX (tmp_fix31,
                                   MAX (m2*m2 + m3*m3, m2*m2 + m4*m4)));
    compchar->bsloff_x = (fix31)(cornermax * resh * point_size_x /
                         (PTPERINCH * cfont.fonthead.resl_per_em) + 3.0);
    compchar->bsloff_y = (fix31)(cornermax * resv * point_size_y /
                         (PTPERINCH * cfont.fonthead.resl_per_em) + 3.0);
    if ((lines_per_em * lines_per_emx) <= 5600.)    /*  74.8 ^ 2  */
        compchar->scanx = TRUE;
    else
        compchar->scanx = FALSE;
    compchar->sw_fixed = sw_fixed;
    compchar->bogus_mode = bogus_mode;
    compchar->xht_adj = xht_adj;
    END


FUNCTION  static  void  messages()

    DECLARE
    BEGIN
    printf("\n%.4s     %.70s (%d ORU's per em)\n",
            cfont.fonthead.src_font_id, cfont.fonthead.src_font_name,
            cfont.fonthead.resl_per_em);
    printf("compressed font   %s\n", cfont_name);
    printf("lines per em  %.2f \n", lines_per_em);
    printf("point size  %.2f\n", point_size_y);
    if (point_size_x != point_size_y)
        printf("point size width  %.2f\n", point_size_x);
    if (resh == resv)
        printf("resolution  %.2f\n", resh);
    else
        {
        printf("horizontal resolution  %.2f\n", resh);
        printf("vertical resolution  %.2f\n", resv);
        }
    if (aspect_ratio != 1.0)
        printf("aspect ratio  %.4f\n", aspect_ratio);
    if (rot_angle != 0.0)
        printf("rotate  %.2f\n", rot_angle);
    if (obl_angle != 0.0)
        printf("oblique  %.2f\n", obl_angle);
    if (subset_flag)
        printf("character set description file \"%s\"\n", subset_name);
    if (bogus_mode)
        printf("no plaid mode\n");
    if (!sw_fixed)
        printf("set width unconstrained\n");
    if (clip_left || clip_right || clip_top || clip_bottom)
        {
        printf("clip");
        if (clip_left)  printf(" left");
        if (clip_right)  printf(" right");
        if (clip_top)  printf(" top");
        if (clip_bottom)  printf(" bottom");
        printf("\n");
        }
    if (squeeze_left || squeeze_right || squeeze_top || squeeze_bottom)
        {
        printf("squeeze");
        if (squeeze_left)  printf(" left");
        if (squeeze_right)  printf(" right");
        if (squeeze_top)  printf(" top");
        if (squeeze_bottom)  printf(" bottom");
        printf("\n");
        }
    if (import_flag)
        printf("import widths from file \"%s\"\n", import_name);
    if (kerning_flag)
        printf("kerning pairs added to bitmap font");
    if (*kerning_name != 0)
        printf(" from control file %s", kerning_name);
    printf("\n");
    if (bmap_dev_field != 0)
        printf("device %d\n", bmap_dev_field);
    if (bmap_rev_field != 1)
        printf("revision %d\n", bmap_rev_field);
    if (xht_adj != 1.0)
        printf("x height adjustment  %.2f\n", xht_adj);
    printf("\n");
    END


FUNCTION  fix  csd_ascii(pname, pbuf, max)
  char   *pname;
  ufix16 *pbuf;
  int     max;

/*  CSD_ASCII -- loads ascii or binary character set description file.

    if the first 7 characters in the file are "$CSDTXT" then loads the
      file as a text file.
    otherwise, in Fontware for Windows only, if the first 4 characters are
      "$CSD" then loads the file with a call to csd_load(), which loads the
      file as a binary csd file, and loads bitstream character ids into the
      array.

    The text file format that this routine supports consists of
        '$CSDTXT'   Required first seven characters of first line
        [whitespace] device_char_num ':' bitmap_char_num comment (PC Fontware)
        [whitespace]                     bitmap_char_num comment (regular subset list)

    (NOTE: PC Fontware CSD text format is supported here to allow OEM
     customers to use PC Fontware CSD text files. The same CSD text files
     are required by the HP format converter that is shipped to some OEM
     customers.)

    Input arguments:
      pname -- name of character set descriptor file
      max -- max number of char ids permitted in csd file
    Output argument:
      pbuf -- loads character ids number into this array
    Returns:
      number of id's loaded if successful
      else, -1 if failure: 1) can't open file or 2) first line is not "$CSD"
        or 3) first line is not "$CSDTXT" (apollo or oem_fontware versions).
*/

    DECLARE

    char    buff[80];
    FILE   *fp;
    fix31   ii,jj;
    fix     num_chars;
    ufix16 *p;
    char    tag[7];

    BEGIN

    fp = fopen (pname, "r");
    if (fp == NULL)
        {
        perror(pname);
        return(-1);
        }

    /* is it a character set file of any sort? */
    if ((fread(tag,1,7,fp) != 7) || strncmp(tag,"$CSD",4))
        {
        fclose(fp);
        return(-1);
        }

    /* is it a binary csd file? (i.e. not text) */
    if (strncmp(tag,"$CSDTXT",7))
        {
        fclose(fp);
#ifndef PCWINDOWS
        return(-1);
#else
        if (csd_load(pname) == -1)
            return (-1);

        num_chars = csd_set(pbuf, max);
#endif
        }

    /* is it a text csd file? */
    else
        {
        num_chars = 0;
        while ((ii = getln (fp, buff, (fix15)80)) >= 0)
            {
            if ((sscanf (buff, "%ld:%ld", &jj, &ii) == 2) || /* number ':' bitmap_char_num comment */
                 (sscanf (buff, "%ld", &ii) == 1) )          /* or bitmap_char_num comment text */
                {
                if (ii < 0  ||  ii > 65535)
                    {
                    report_error ("Invalid character ID %d in CSD file \"%s\"", ii, pname);
                    fclose(fp);
                    return(-1);
                    }
                pbuf[num_chars++] = (ufix16)ii;
                }
            if (num_chars >= 1024  ||  num_chars >= max)
                break;
            }
        fclose(fp);
        }

    return(num_chars);
    END


FUNCTION void report_error (format,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9)
  char *format;
  int   a0,a1,a2,a3,a4,a5,a6,a7,a8,a9;

  DECLARE
  char message_buff[128];
  void error_log();

  BEGIN
  sprintf(message_buff,format,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9);

#ifdef PCFONTWARE
    error_log(message_buff);
#else
    fprintf(stderr,"\n*** %s\n",message_buff);
#endif /* PCFONTWARE */

  END


FUNCTION  static  void  init_kludge ()

    DECLARE
    BEGIN
    kludge.width48 = kludge.width203 = kludge.width2076 = 0;
    kludge.offs48 = kludge.offs203 = kludge.offs2076 = 0;
    kludge.offs49 = kludge.offs194 = kludge.offs2022 = 0;
    kludge.arr[0] = kludge.arr[1] = kludge.arr[2] = 0;
    END

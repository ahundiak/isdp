




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************** K E R N I N G . C *****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 0)   6-Mar-87  mby   

 1)  20-May-87  mby   1) generates all kerning pairs from outline font or
                      2) generates only those pairs from a kerning pair file


 *****************************************************************************

   Generates kerning pair and kerning track data for bitmap font

 ****************************************************************************/


#include "../hfiles/stdef.h"              /* Bitstream standard macros */
#include "../hfiles/comp2_3.h"            /* data structures for compr'd font */
#include "../hfiles/bmap.h"               /* data structures for bmap fonts */
#include "../hfiles/mkbm.h"



/***** EXTERNAL GLOBAL VARIABLES *****/

extern  fix15   kerning_flag;       /* 0: no kerning, 1: all pairs, 2: use kerning table */
extern  char    kerning_name[100];  /* pathname with list of kerning pairs  */
extern  float   lines_per_emx;      /* horizontal # pixels per em space     */
extern  float   point_size_y;       /* y-point size (72.3 pts per inch)     */
extern  float   resh;               /* output device resolution, horizontal */
extern  bool16  setpoint;           /* user parameter is point size         */





typedef
struct
     {
     ufix16    c1,            /* bs_nbr for character 1 */
               c2;            /* bs_nbr for character 2 */
     }
     char_id_pair_type;


typedef
struct
     {
     ufix32  c1c2;            /* pair #'s for c1 and c2 combined into 1 word */
     fix15   adj;             /* kerning adjustment value in relative units */
     }
     comp_pair_type;


FUNCTION  void  do_kerning (bmfont, cmfont)
  bmap_font_desc_t  bmfont;
  cft_outl_str     *cmfont;

/* DO_KERNING -- Adds track and pair kerning to bitmap font data structure
 *
 * Input arguments:
 *   bmfont -- ptr to bmap format 1.1 font data structure
 *   cmfont -- ptr to compressed font data structure
 * Called from:
 *   another module
 */

    DECLARE
    char_id_pair_type  *bitm_kern_table;    /* kerning pairs from kerning pair file */
    comp_pair_type  *comp_kern_table;   /* kerning pairs from outline font */
    fix8      chr_list1[256];    /* for char ids from 0 to 255; 1 = in bitmap font, 0 = absent */
    ufix16   *chr_list2;         /* list of char ids in font >= 256, unsorted */
    fix       comp_kt_size;
    fix31     char1, char2;
    fix31     ii;
    fix31     kern_value;
    bmap_pair_desc_t  kpr_desc;  /* ptr to kerning pair record */
    ufix16    n1, n2;            /* character id numbers from comp font */
    fix31     nbr_bitm_pairs;    /* # of kerning pairs from kerning pair file */
    fix31     num_outl_kprs;     /* number of kerning records in comp font */
    fix31     trk0, trk1, trk2;  /* track kerning adjustments */

    ufix8    *alloc();           /* allocate memory block */
    fix31     bmap_hierarchical_update();   /* make font consistent */
    bmap_pair_desc_t   bmap_insert_kern_rec();
    fix31     bmap_nbr_dir_rec();  /* number of characters in bitmap font */
    bmap_pair_desc_t   bmap_new_kern_rec();
    fix31     bmap_set_track();  /* track kerning value in pxls */
    bool      charid_match();    /* match kerning pair char id to bitmap font */
    bool      dealloc();
    bool      kern_match ();
    void      read_bitm_charids();  /* saves char ids from bitmap font */
    fix31     read_bitm_kerns();
    fix       read_comp_kerns();
    void      trackpix();        /* figures out track krn'g, converts to pxls */

    BEGIN
    if (setpoint)
        {               /* if point size is specified, do track kerning */
        trackpix (cmfont, &trk0, &trk1, &trk2);
        bmap_set_track (bmfont, trk0, (fix31) 0);
        bmap_set_track (bmfont, trk1, (fix31) 1);
        bmap_set_track (bmfont, trk2, (fix31) 2);
        }
    /* Note: if a font is specified with lines per em, then track kerning
       is not applicable */

    /* if no char ids in compressed font, then can't do kerning pairs */
    if ((cmfont->fonthead.flag1  &  F_KERNPR) == 0  ||
            (cmfont->fonthead.flag1  &  F_CHARID) == 0)
        return;

    /* Load and store character id's from bitmap font */
    bmap_hierarchical_update (bmfont);
    assert((chr_list2 =
        (ufix16 *)alloc((ufix32) ((bmap_nbr_dir_rec(bmfont) + 1) * sizeof(ufix16))))  != NULL);
    read_bitm_charids (bmfont, chr_list1, chr_list2);

    if (kerning_flag == 1)  /* include all valid kerning pairs from outline font */
        {
        num_outl_kprs = cmfont->knpr_hd.nr_recs;
        for (ii=0; ii < num_outl_kprs; ii++)
            {
            n1 = cmfont->chdir_dat[cmfont->knpr_dat[ii].char1].char_id;
            n2 = cmfont->chdir_dat[cmfont->knpr_dat[ii].char2].char_id;
            if (charid_match (n1, chr_list1, chr_list2)  &&
                    charid_match (n2, chr_list1, chr_list2))
                {
               /* A match. Convert from relative units to pixels */
                kern_value = ROUND (cmfont->knpr_dat[ii].adjustment *
                                    lines_per_emx / cmfont->fonthead.resl_per_em);
                if (kern_value == 0)
                    continue;
                kpr_desc = bmap_new_kern_rec ((fix31)n1, (fix31)n2, kern_value);
                bmap_insert_kern_rec (bmfont, kpr_desc);
                }
            }
        }

    else        /* file contains standard list of kerning pairs */
        {
        /* Read and store pairs from kerning pair file that match bitmap font */
        nbr_bitm_pairs = read_bitm_kerns (kerning_name, chr_list1, chr_list2,
                                          &bitm_kern_table);
        if (nbr_bitm_pairs > 0)
            {
            /* Organize table of compr. font kerning pairs */
            comp_kt_size = read_comp_kerns (cmfont, &comp_kern_table);
            for (ii=0; ii < nbr_bitm_pairs; ii++)
                {
                /* Try to match bitmap kerning pairs in bitm_kern_table
                   with kerning pairs in compressed font. When there is
                   a match, store the data in the bitmap font */
                if (kern_match (bitm_kern_table + ii, comp_kern_table,
                                comp_kt_size, &char1, &char2, &kern_value))
                    {
                    /* Convert from relative units to pixels */
                    kern_value = ROUND (kern_value * lines_per_emx / cmfont->fonthead.resl_per_em);
                    if (kern_value == 0)
                        continue;
                    kpr_desc = bmap_new_kern_rec (char1, char2, kern_value);
                    bmap_insert_kern_rec (bmfont, kpr_desc);
                    }
                }
            dealloc ((ufix8 *) comp_kern_table);
            }
        dealloc ((ufix8 *) bitm_kern_table);
        }

    dealloc ((ufix8 *) chr_list2);
    return;
    END


FUNCTION  static fix31  read_bitm_kerns (fname, chr_list1, chr_list2, bitm_kern_table)
  char                 *fname;
  fix8                 *chr_list1;
  ufix16               *chr_list2;
  char_id_pair_type   **bitm_kern_table;

/* READ_BITM_KERNS -- Opens and reads an ASCII text file (fname) that contains
 *      a list of bitmap kerning pairs (identified by character id number).
 *      The format of this file is "$KERN" on the first line, then 2 bitmap
 *      character ids per line; anything beyond that is treated as a comment.
 *      The character ids are saved in the table 'bitm_kern_table'. First,
 *      however, the ids in the kerning pair file are checked against the char
 *      ids of the bitmap font (charid_match() ). If a kerning pair has a
 *      character id that is not actually in the bitmap font, then that
 *      kerning pair is ignored.
 * Input arguments:
 *   fname -- file name of kerning list
 *   chr_list1 -- quick lookup if char id < 256
 *   chr_list2 -- search this array if char id >= 256
 * Output argument:
 *   bitm_kern_table -- pointer to kerning table (structure). Each element
 *                      has two bitmap character ids
 * Returns:
 *   number of valid kerning pairs from kerning file
 * Called from:
 *   do_kerning
 */

    DECLARE
    char    buff[80];
    FILE   *fp;                 /* file pointer */
    ufix16  kch1, kch2;         /* numbers read in by scanf */
    char_id_pair_type  *kern_table;   /* kerning table - array of kerning pairs */
    fix31   num_pairs;          /* return value */
    char    tag[5];

    ufix8  *alloc();            /* allocate memory block */
    bool    charid_match();     /* match kerning pair file char id to bitmap font */
    fix     getln();            /* get 1 line of text from file */

    BEGIN
    assert((kern_table =        /* allocates memory for maximum of 1024 pairs */
        (char_id_pair_type *)alloc((ufix32) (1024 * sizeof(char_id_pair_type))))  != NULL);
    *bitm_kern_table = kern_table;

    if ((fp = fopen (fname, "r")) == NULL)
        {
        perror(fname);
        return((fix31)-1);
        }
    if ((fread(tag,1,5,fp) != 5) || strncmp(tag,"$KERN",5))
        {                       /* is it a kerning pair file? */
        fclose(fp);
        printf ("\n*** File \"%s\" is not a kerning pair file\n", fname);
        return((fix31)-1);
        }
    
    /* This loop reads 1 line from the kerning pair file. It reads the first
       two numbers (character ids) from each line. If the bitmap font contains
       both of those character ids, then the kerning pair is added to the
       kerning table */
    num_pairs = 0;
    while (getln (fp, buff, (fix15)80) >= 0)
        {
        if (sscanf (buff, "%hu%hu", &kch1, &kch2) == 2)
            {
            if (charid_match (kch1, chr_list1, chr_list2)  &&
                   charid_match (kch2, chr_list1, chr_list2))
                {
                kern_table[num_pairs].c1 = kch1;
                kern_table[num_pairs++].c2 = kch2;
                }
            }
        if (num_pairs >= 1024)
            {
            printf("\n*** 1024 kerning pairs read from \"%s\".\n");
            printf("    That is the maximum allowed.\n", fname);
            break;
            }
        }
    fclose(fp);

    return (num_pairs);
    END


FUNCTION  static bool  charid_match (char1, chr_list1, chr_list2)
  ufix16    char1;
  fix8     *chr_list1;
  ufix16   *chr_list2;

/* CHARID_MATCH -- Takes a character id and returns TRUE if char id is in
 *      either chr_list1 or chr_list2.
 * Input arguments:
 *   char1 -- character id
 *   chr_list1 -- quick lookup if char1 < 256
 *   chr_list2 -- do linear search of this array if char1 >= 256
 * Returns:
 *   TRUE  or FALSE
 * Called from:
 *   do_kerning, read_bitm_kerns
 */

    DECLARE
    register fix    ii;
    register fix    nn;

    BEGIN
    if (char1 < 256)
        {
        if (chr_list1[char1] == 0)
            return (FALSE);
        }
    else
        {
        nn = *chr_list2++;      /* how many in chr_list2 */
        for (ii=1; ii<=nn; ii++)
            {
            if (char1 == *chr_list2++)
                break;
            }
        if (ii == nn+1)
            return (FALSE);
        }

    return (TRUE);
    END


FUNCTION  static void  read_bitm_charids (bmfont, chr_list1, chr_list2)
  bmap_font_desc_t  bmfont;
  fix8     *chr_list1;
  ufix16   *chr_list2;

/* READ_BITM_CHARIDS -- reads through bitmap font data structure, saves all
 *                      the character ids
 * Input argument:
 *   bmfont -- ptr to bmap format 1.1 font data structure
 * Output argument:
 *   chr_list1 -- array that stores char ids (0-255) from bitmap font
 *   chr_list2 -- array that stores char ids (> 255) from bitmap font
 *                chr_list2[0] = how many ids in chr_list2
 * Called from:
 *   do_kerning
 */

    DECLARE
    fix15   bnbr;               /* bitmap character id number */
    fix     ii;
    bmap_char_desc_t   bmap_first_char();
    bmap_char_desc_t   bmap_this_char();
    bmap_char_desc_t   bmap_next_char();

    BEGIN
    for (ii=0; ii<256; ii++)
        chr_list1[ii] = 0;
    chr_list2[0] = 0;
    for (bmap_first_char (bmfont);
            bmap_this_char (bmfont) != 0; bmap_next_char (bmfont))
        {
        bnbr = bmfont->curr_ch->data->bs_nbr;
        if (bnbr > 0  &&  bnbr < 256)
            chr_list1[bnbr] = 1;
        else
            {
            chr_list2[0]++;
            chr_list2[chr_list2[0]] = bnbr;
            }
        }
    END


FUNCTION  static fix  read_comp_kerns (cmfont, comp_kern_table)
  cft_outl_str     *cmfont;
  comp_pair_type  **comp_kern_table;

/* READ_COMP_KERNS -- Reads kerning pairs from compressed font. Converts
 *      identifier from character offset to character id. Returns character
 *      ids and adjustment in comp_kern_table.
 * Input argument:
 *   cmfont -- ptr to compressed font data structure
 * Output arguments:
 *   comp_kern_table -- pointer to compressed kerning table (structure)
 *                      .c1c2 -- 32-bit word, combines both char ids
 *                      .adj -- width adjustment in outline rel. units
 * Returns:
 *   number of kerning records from compressed outline 
 * Called from:
 *   do_kerning
 */

    DECLARE
    fix     ii;
    comp_pair_type  *kern_table;    /* kerning table - array of kerning pairs */
    fix     kct;                /* number of kerning records (returned) */
    fix31   n1, n2;
    ufix8  *alloc();            /* allocate memory block */

    BEGIN
    kct = cmfont->knpr_hd.nr_recs;
    assert((kern_table =
        (comp_pair_type *)alloc((ufix32) (kct * sizeof(comp_pair_type))))  != NULL);
    *comp_kern_table = kern_table;
    for (ii=0; ii<kct; ii++)
        {
        n1 = cmfont->chdir_dat[cmfont->knpr_dat[ii].char1].char_id;
        n2 = cmfont->chdir_dat[cmfont->knpr_dat[ii].char2].char_id;
        kern_table[ii].c1c2 = (n1 << 16) | n2;
        kern_table[ii].adj = cmfont->knpr_dat[ii].adjustment;
        }
    return (kct);
    END


FUNCTION  static bool  kern_match (kern_pair, comp_kern_table,
                                   comp_kt_size, char1, char2, value)
  char_id_pair_type *kern_pair;
  comp_pair_type    *comp_kern_table;
  register fix       comp_kt_size;
  fix31             *char1;
  fix31             *char2;
  fix31             *value;

/* KERN_MATCH -- Searches comp_kern_table for a match with a kerning pair
 *               from kerning file (kern_pair).
 * Input arguments:
 *   kern_pair -- structure with 2 character ids from kerning file
 *   comp_kern_table -- structure with 2 character ids (c1c2)
 *                      and adjustment (adj) in relative units.
 *   comp_kt_size -- number of elements in comp_kern_table
 * Output arguments:
 *   char1 -- 1st character id from kern_pair
 *   char2 -- 2nd character id from kern_pair
 *   value -- adjustment in outline relative units
 * Returns:
 *   TRUE (match found) or FALSE
 * Called from:
 *   do_kerning
 */

    DECLARE
    ufix32           compv;
    register fix     ii;

    BEGIN
    compv = (((ufix32)kern_pair->c1) << 16)  |  kern_pair->c2;
    for (ii=0; ii<comp_kt_size; ii++)
        {
        if (compv == comp_kern_table[ii].c1c2)
            {
            *char1 = kern_pair->c1;
            *char2 = kern_pair->c2;
            *value = comp_kern_table[ii].adj;
            return (TRUE);
            }
        }
    return (FALSE);
    END


FUNCTION  static void  trackpix (cmfont, track1, track2, track3)
  cft_outl_str *cmfont;
  fix31        *track1;
  fix31        *track2;
  fix31        *track3;

/* TRACKPIX -- calculates track kerning adjustment in pixels
 *
 * Input argument:
 *   cmfont -- ptr to compressed font data structure
 * Output arguments:
 *   track1, track2, track3 -- font tracking adjustments
 * Called from:
 *   do_kerning
 * Notes:
 *   When it is necessary to extrapolate a value, we assume that the track
 *   kerning adjustments are linear functions of the point size, with
 *   adjustment = 0 <==> point size 12.
 */
    DECLARE
    fix     ii;                 /* temp */
    real    q, q1;              /* temps */
    real    low_bound;          /* smallest point size in track table */
    real    upp_bound;          /* biggest point size in track table */
    real    point_y;            /* y point size */
    real    slope1;             /* slope of track 1 adjustment vs. point size */
    real    slope2;             /* slope of track 2 adjustment vs. point size */
    real    slope3;             /* slope of track 3 adjustment vs. point size */
    real    trk1_hp;            /* track 1 adjustment in 1/100 points */
    real    trk2_hp;            /* track 2 adjustment in 1/100 points */
    real    trk3_hp;            /* track 3 adjustment in 1/100 points */

    BEGIN
    low_bound = (real) cmfont->kntrk_dat[0].point_size;
    upp_bound = (real) cmfont->kntrk_dat[cmfont->kntrk_hd.nr_recs - 1].point_size;
    point_y = (real) point_size_y;
    /* Does point size fall within the point size table? */
    if (point_y >= low_bound  &&  point_y <= upp_bound)
        {
        for (ii=0;  ii < cmfont->kntrk_hd.nr_recs;  ii++)
            {
            if ((real)cmfont->kntrk_dat[ii].point_size == point_y)
                {           /* There is an exact match for point size */
                            /* Get the track adjustments from the table */
                trk1_hp = (real) cmfont->kntrk_dat[ii].track_1_adj;
                trk2_hp = (real) cmfont->kntrk_dat[ii].track_2_adj;
                trk3_hp = (real) cmfont->kntrk_dat[ii].track_3_adj;
                break;
                }
            if ((real)cmfont->kntrk_dat[ii].point_size > point_y)
                {           /* The track adjustments should be interpolated */
                q = (real)(cmfont->kntrk_dat[ii].point_size -
                            cmfont->kntrk_dat[ii-1].point_size);
                q1 = point_y - cmfont->kntrk_dat[ii].point_size;
                if (q > 0)
                    {
                    slope1 = (real)(cmfont->kntrk_dat[ii].track_1_adj -
                                    cmfont->kntrk_dat[ii-1].track_1_adj) / q;
                    slope2 = (real)(cmfont->kntrk_dat[ii].track_2_adj -
                                    cmfont->kntrk_dat[ii-1].track_2_adj) / q;
                    slope3 = (real)(cmfont->kntrk_dat[ii].track_3_adj -
                                    cmfont->kntrk_dat[ii-1].track_3_adj) / q;
                    trk1_hp = cmfont->kntrk_dat[0].track_1_adj + (q1 * slope1);
                    trk2_hp = cmfont->kntrk_dat[0].track_2_adj + (q1 * slope2);
                    trk3_hp = cmfont->kntrk_dat[0].track_3_adj + (q1 * slope3);
                    }
                else
                    {
                    slope1 = slope2 = slope3 = 0.;
                    }
                break;
                }
            }
        }
    else                /* The track adjustments should be extrapolated */
        {
        q = upp_bound - low_bound;
        if (q > 0)
            {
            slope1 = (real)(cmfont->kntrk_dat[cmfont->kntrk_hd.nr_recs - 1].track_1_adj -
                             cmfont->kntrk_dat[0].track_1_adj) / q;
            slope2 = (real)(cmfont->kntrk_dat[cmfont->kntrk_hd.nr_recs - 1].track_2_adj -
                             cmfont->kntrk_dat[0].track_2_adj) / q;
            slope3 = (real)(cmfont->kntrk_dat[cmfont->kntrk_hd.nr_recs - 1].track_3_adj -
                             cmfont->kntrk_dat[0].track_3_adj) / q;
            }
        else
            {
            slope1 = slope2 = slope3 = 0.;
            }
        trk1_hp = cmfont->kntrk_dat[0].track_1_adj +
                  (point_y - low_bound) * slope1;
        trk2_hp = cmfont->kntrk_dat[0].track_2_adj +
                  (point_y - low_bound) * slope2;
        trk3_hp = cmfont->kntrk_dat[0].track_3_adj +
                  (point_y - low_bound) * slope3;
        }

    /* Convert 100ths of points to pixels in x-dimension. */
    q = .01 * resh / PTPERINCH;
    if (cmfont->fonthead.flag1  &  F_KTRCK1)
        *track1 = (fix31) (ROUND (trk1_hp * q));
    else
        *track1 = 0;
    if (cmfont->fonthead.flag1  &  F_KTRCK2)
        *track2 = (fix31) (ROUND (trk2_hp * q));
    else
        *track2 = 0;
    if (cmfont->fonthead.flag1  &  F_KTRCK3)
        *track3 = (fix31) (ROUND (trk3_hp * q));
    else
        *track3 = 0;

    return;
    END

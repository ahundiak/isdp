/*  color_rgb:  entry points for HRinit_rgb and HRindex_rgb.
 *
 *    HRinit_rgb:  initializes the rgb-to-vlt-index lookup table and downloads
 *      an appropriate corresponding vlt, given the number of bit planes.
 *
 *    HRindex_rgb:  returns a vlt index, given x- & y-coordinates for a pixel
 *      and an rgb color value.
 *
 *  Author:  D. H. Holmes				Date:  3/7/88
 *
 *  Revised:  7/10/89 - does color compensation for non-linear DACs
 *  Revised:  8/14/89 - use of gamma correction for color calibration
 *  Revised:  8/17/89 - corrected menu color shuffling for GS machines
 */
#define	TRUE	1
#define	FALSE	0

#include	<tools.h>
#include	<stdio.h>

extern short *IGErgb_table;  /* 9-bit rgb to vlt color index lookup table */

static short rgb_table[512];  /* 9-bit rgb to vlt color index lookup table */
int IGEnum_shds;   /* no. of "base" shades for particular no. of planes */
static int num_intens = 0;      /* total number of "apparent" intensities    */

 /* for each primary for specified # planes */

static struct vlt_slot fixed_vlt[15];   /* space to hold original fixed VLT
                                         * for GX/GZ machines */


/*--------HRinit_rgb---------------------------------------------------------*/

/* Set up rgb_table and vlt to map rgb values to vlt entries for the	   */
/*   specified number of planes.					   */

void HRinit_rgb (num_planes)
    int num_planes;
    {
#define	MAXDIST 200000  /* larger than max. value for r*r + g*g + b*b */
#define	RLUM 299        /* luminance contributions for red, green, and    */
#define GLUM 587        /* blue as integer percentages (out of 1000);   */
#define BLUM 114        /* used to determine best match for menu colors */
    int vs_num;
    struct scr_info screen_info[MAX_SCREENS];
    struct vlt_slot vlt[512], tmp_slot;

    int i, j, k, red, grn, blu, /* loop indices */
        real_num_planes,        /* actual number of planes available */
        menu[16],       /* menu colors for the GX/GZ/Mark 1 or GS */
        m_priority[15]; /* menu color priorities */
    unsigned char base_shade[16];       /* "base" shades for a particular */

    /* number of planes */
    int slot_num,       /* index for current slot number */
        num_extras,     /* number of unused slots in vlt for a */
    /* particular number of planes */
        tot_menu_slots, /* total no. of menu slots */
        min_dist,       /* minimum "distance squared" between 2 colors */
        found,  /* Boolean to indicate a color index has been found */
        delta_red, delta_grn, delta_blu,        /* red, green, and blue
                                                 * deltas */
        dist,   /* "distance squared" between 2 colors */
        best_match = 0, /* index for "closest" color that matches */
        lum_true, lum_best, lum_j;      /* used to calculate closest match */

    /* based on luminance            */

    Inq_displayed_vs (&vs_num);

    /* Initialize */
    for (i = 0; i < 512; i++)
        rgb_table[i] = 0;

    if (num_planes < 8)
        {
        menu[0] = 0x000000;
        menu[1] = 0x00ba00;
        menu[13] = 0xbbbbbb;
        menu[14] = 0x888888;
        menu[15] = 0xddeeee;

        m_priority[0] = 14;
        m_priority[1] = 15;
        m_priority[2] = 13;
        m_priority[3] = 0;
        m_priority[4] = 1;
        }
    else
        {
        Readvlt (vs_num, fixed_vlt, 14, 1);
        menu[0] = 0x000000;
        menu[1] = 0xeeeeee;
        menu[2] = 0x888888;
        menu[3] = 0x000000;
        menu[4] = 0x00ffff;
        menu[5] = 0xaaaaaa;
        menu[6] = 0x555555;
        menu[7] = 0xffffff;
        menu[8] = 0x0000ff;
        menu[9] = 0x00ff00;
        menu[10] = 0xff0000;
        menu[11] = 0xbbffff;
        menu[12] = 0x0000dd;
        menu[13] = 0x00bb00;
        menu[14] = 0xcc0000;

        m_priority[0] = 6;
        m_priority[1] = 2;
        m_priority[2] = 11;
        m_priority[3] = 13;
        m_priority[4] = 1;
        m_priority[5] = 12;
        m_priority[6] = 5;
        m_priority[7] = 14;
        m_priority[8] = 0;
        m_priority[9] = 7;
        m_priority[10] = 3;
        m_priority[11] = 4;
        m_priority[12] = 8;
        m_priority[13] = 9;
        m_priority[14] = 10;
        }

    /* Determine number of planes, number of shades, and base shades. */
    Inq_screen_info (screen_info);
    real_num_planes = screen_info[vs_num].vsi_num_planes;
    if (num_planes > real_num_planes)
        num_planes = real_num_planes;
    if (num_planes < 3) /* not enough planes */
        return;
    else if (num_planes < 5)    /* num_planes = 3 or 4 */
        IGEnum_shds = 2;
    else if (num_planes == 5)
        {
        base_shade[1] = 0xba;
        IGEnum_shds = 3;
        }
    else if (num_planes < 8)    /* num_planes = 6 (or 7) */
        {
        base_shade[1] = 0x9b;
        IGEnum_shds = 4;
        base_shade[2] = 0xd4;
        }
    else if (num_planes == 8)
        {
        base_shade[1] = 0x7b;
        IGEnum_shds = 6;
        base_shade[2] = 0xa8;
        base_shade[3] = 0xca;
        base_shade[4] = 0xe6;
        }
    else
        {       /* num_planes = 9 (or more) */
        base_shade[1] = 0x69;
        IGEnum_shds = 8;
        base_shade[2] = 0x90;
        num_planes = 9;
        base_shade[3] = 0xad;
        base_shade[4] = 0xc6;
        base_shade[5] = 0xdb;
        base_shade[6] = 0xee;
        }
    base_shade[0] = 0x00;
    base_shade[IGEnum_shds - 1] = 0xff;

    /* Initialize vlt. */
    tmp_slot.v_slot = 0;
    tmp_slot.v_red = tmp_slot.v_green = tmp_slot.v_blue = 0x0000;
    for (i = 0; i < (1 << num_planes); i++)
        vlt[i] = tmp_slot;

    /* Calculate number of apparent intensities and number of unused slots. */
    num_intens = (16 * (IGEnum_shds - 1)) + 1;
    num_extras = (1 << num_planes) - (IGEnum_shds * IGEnum_shds * IGEnum_shds);  /* 1<<n=2^n */

    /* Build vlt, with 9-bit rgb value stored for the vlt slot number. */
    slot_num = num_extras;      /* start after "extra" slots for menu */
    for (blu = 0; blu < IGEnum_shds; blu++)
        for (grn = 0; grn < IGEnum_shds; grn++)
            for (red = 0; red < IGEnum_shds; red++)
                {
                vlt[slot_num].v_slot = (blu << 6) | (grn << 3) | red;
                vlt[slot_num].v_red = (base_shade[red] << 8) | base_shade[red];
                vlt[slot_num].v_green = (base_shade[grn] << 8) | base_shade[grn];
                vlt[slot_num].v_blue = (base_shade[blu] << 8) | base_shade[blu];
                slot_num++;
                }

    /* Place menu colors in unused vlt slots. */
    tot_menu_slots = ((num_planes < 8) ? (5) : (15));
    if (num_extras > tot_menu_slots)
        num_extras = tot_menu_slots;
    for (i = 0; i < num_extras; i++)
        {       /* note:  v_slot = 0 already */
        vlt[i].v_red = (menu[m_priority[i]] << 8) & 0xff00;
        vlt[i].v_green = (menu[m_priority[i]]) & 0xff00;
        vlt[i].v_blue = (menu[m_priority[i]] >> 8) & 0xff00;
        }

    /* Re-shuffle vlt to find best match for menu colors. */
    for (i = 0; i < tot_menu_slots; i++)
        {
        red = menu[m_priority[i]] & 0xff;
        grn = (menu[m_priority[i]] >> 8) & 0xff;
        blu = (menu[m_priority[i]] >> 16) & 0xff;
        min_dist = MAXDIST;
        for (j = 0; (j < ((1 << num_planes) - 1)) && (min_dist != 0); j++)
            {   /* start at beginning; exclude white at end */
            found = FALSE;
            for (k = 0; k < i; k++)
                if (j == m_priority[k])
                    found = TRUE;
            if (found == FALSE)
                {
                delta_red = (vlt[j].v_red >> 8) - red;
                delta_grn = (vlt[j].v_green >> 8) - grn;
                delta_blu = (vlt[j].v_blue >> 8) - blu;
                dist = (delta_red * delta_red) + (delta_grn * delta_grn) +
                    (delta_blu * delta_blu);
                if (dist < min_dist)
                    {
                    best_match = j;
                    min_dist = dist;
                    }
                else if (dist == min_dist)
                    {
                    lum_true = (RLUM * red) + (GLUM * grn) + (BLUM * blu);
                    lum_best = (RLUM * (vlt[best_match].v_red >> 8)) +
                        (GLUM * (vlt[best_match].v_green >> 8)) +
                        (BLUM * (vlt[best_match].v_blue >> 8));
                    lum_j = (RLUM * (vlt[j].v_red >> 8)) +
                        (GLUM * (vlt[j].v_green >> 8)) +
                        (BLUM * (vlt[j].v_blue >> 8));
                    lum_best = lum_best - lum_true;
                    if (lum_best < 0)
                        lum_best = -lum_best;
                    lum_j = lum_j - lum_true;
                    if (lum_j < 0)
                        lum_j = -lum_j;
                    if (lum_j < lum_best)
                        best_match = j;
                    }
                }
            }
        tmp_slot = vlt[m_priority[i]];
        vlt[m_priority[i]] = vlt[best_match];
        vlt[best_match] = tmp_slot;
        
        }

    /* Build 9-bit rgb to vlt_index map */
    for (i = 0; i < (1 << num_planes); i++)
        {
        if (vlt[i].v_slot > 0)
            {
            rgb_table[vlt[i].v_slot] = i;
            }
        vlt[i].v_slot = i;
        }

    Loadvlt (vs_num, vlt, (1 << num_planes));
    if (num_planes != real_num_planes)  /* be sure hilite is loaded */
        {
        vlt[0].v_slot = (1 << real_num_planes) - 1;
        vlt[0].v_red = vlt[0].v_green = vlt[0].v_blue = 0xffff;
        Loadvlt (vs_num, vlt, 1);
        }

#ifdef DEBUGVLT
    /* Debug print statements to reveal contents of rgb_table and vlt */
    printf ("\nrgb_table\n");
    printf ("----\n");
    for (i = 0; i < 128; i++)
        printf ("%3d:	%3d	%3d:	%3d	%3d:	%3d	%3d:	%3d\n",
                i, rgb_table[i], i + 128, rgb_table[i + 128], i + 256, rgb_table[i + 256], i + 384,
                rgb_table[i + 384]);
    printf ("\nvlt\n");
    printf ("---\n");
    for (i = 0; i < (1 << (num_planes - 1)); i++)
        printf ("%3d:	(%3d)	%3d/%3d/%3d	%3d:	(%3d)	%3d/%3d/%3d\n",
                i, vlt[i].v_slot, vlt[i].v_red >> 8, vlt[i].v_green >> 8, vlt[i].v_blue >> 8,
        i + (1 << (num_planes - 1)), vlt[i + (1 << (num_planes - 1))].v_slot,
                vlt[i + (1 << (num_planes - 1))].v_red >> 8,
                vlt[i + (1 << (num_planes - 1))].v_green >> 8,
                vlt[i + (1 << (num_planes - 1))].v_blue >> 8);
    printf ("\n");
#endif

    /*//\\*/

    IGErgb_table = (short *)malloc( 512 * sizeof( short ) );
    for( i=0; i<512; i++ )
    {    
    IGErgb_table[i] = rgb_table[i];
    }
    }   /* HRinit_rgb */

/*--------HRfinish_rgb---------------------------------------------------------*/

/* Re-load the fixed VLT on machines with 8 or more planes */

void HRfinish_rgb (num_planes)
    int num_planes;
    {
    int vs_num;

    if (num_planes > 8)
        {
        Inq_displayed_vs (&vs_num);
        Loadvlt (vs_num, fixed_vlt, 14);
        }
    }   /* HRfinish_rgb */

/*--------HRindex_rgb--------------------------------------------------------*/

/* Given the x- & y-coordinate of a pixel and an rgb color value (in the   */
/*   range [0..255]), return a vlt index.                                  */

int index_rgb (x, y, red, grn, blu)
    int x, y, red, grn, blu;
    {
        static int dither_mat[16] = {0, 8, 2, 10,       /* 4x4 ordered */
        12, 4, 14, 6,   /* dither    */
        3, 11, 1, 9,
        15, 7, 13, 5};
    register int dither_val;

    /* Scale to actual number of intensities allowed. */
    red = (red * num_intens) >> 8;
    grn = (grn * num_intens) >> 8;
    blu = (blu * num_intens) >> 8;

    /* Calculate dither value. */
    dither_val = dither_mat[((y & 3) << 2) | (x & 3)];

    /* Perform dithering to achieve halftones. */
    red = (((red & 15) > dither_val) ? ((red >> 4) + 1) : (red >> 4));
    grn = (((grn & 15) > dither_val) ? ((grn >> 4) + 1) : (grn >> 4));
    blu = (((blu & 15) > dither_val) ? ((blu >> 4) + 1) : (blu >> 4));

    /* Return vlt color index value which corresponds to calculated */
    /* 9-bit rgb dither value.                                    */
    return (rgb_table[(blu << 6) | (grn << 3) | red]);
    }   /* HRindex_rgb */

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

#include	<stdio.h>
#include	<wl.h>

static short	rgb_tbl[512];	/* 9-bit rgb to vlt color index lookup table */
static int	num_intens = 0;	/* total number of "apparent" intensities    */
				/*   for each primary for specified # planes */

/* space to hold original fixed VLT for GX/GZ machines */
static struct WLcmap_entry fixed_cmap[14]; 

#define	MAXDIST 200000	/* larger than max. value for r*r + g*g + b*b */
#define	RLUM 299	/* luminance contributions for red, green, and    */
#define GLUM 587	/*   blue as integer percentages (out of 1000);   */
#define BLUM 114	/*   used to determine best match for menu colors */

#define COPYCMAP( a, b ) \
   { \
   a.slot = b.slot; \
   a.red = b.red; \
   a.green = b.green; \
   a.blue = b.blue; \
   a.flags = b.flags; \
   }

/*--------init_rgb---------------------------------------------------------*/

/* Set up rgb_tbl and vlt to map rgb values to vlt entries for the	   */
/*   specified number of planes.					   */

void init_rgb (WLuint32 context_no, int num_planes)

   {
   struct WLcontext_info	context_info;
   struct WLcmap_entry		cmap[512], cmap_slot;
   WLuint16			screen_no;
   int				screen_type;

   int  delta_red, delta_grn, delta_blu;    /* red, green, and blue deltas */
   int  i, j, k, red, grn, blu;	    /* loop indices */
   int  real_num_planes;            /* actual number of planes available */
   int  menu[16];                   /* menu colors for the GX/GZ/Mark 1 or GS */
   int  m_priority[15];             /* menu color priorities */
   int  num_shds;                   /* no. of "base" shades for particular */
                                    /* no. of planes */
   int  slot_num;                   /* index for current slot number */
   int  num_extras;                 /* number of unused slots in vlt for a */
                                    /* particular number of planes */
   int  tot_menu_slots;             /* total no. of menu slots */
   int  min_dist;                   /* minimum "distance squared"  */
                                    /* between 2 colors */
   int  found;                      /* Boolean to indicate a color index 
                                    /* has been found */
   int  dist;                       /* "distance squared" between 2 colors */
   int  best_match = 0;             /* index for "closest" color that matches */
   int  lum_true, lum_best, lum_j;  /* used to calculate closest match */
                                    /* based on luminance            */
   unsigned char  base_shade[16];   /* "base" shades for a particular */
                                    /* number of planes */

   fprintf( stderr, "init_rgb: num_planes - %1d\n", num_planes );
   WLget_active_screen( &screen_no, &screen_type );

   /* Initialize */

   for (i = 0; i < 512; i++) rgb_tbl[i] = 0;


   if (num_planes < 8)
      {
      menu[ 0] = 0x000000;    
      menu[ 1] = 0x00ba00;
      menu[13] = 0xbbbbbb;    
      menu[14] = 0x888888;    
      menu[15] = 0xddeeee;

      m_priority[ 0] = 14;    
      m_priority[ 1] = 15;    
      m_priority[ 2] = 13;
      m_priority[ 3] =  0;    
      m_priority[ 4] =  1;
      }
   else
      {
      WLread_cmap_entries( context_no, 14, fixed_cmap );
      menu[ 0] = 0x000000;    
      menu[ 1] = 0xeeeeee;    
      menu[ 2] = 0x888888;
      menu[ 3] = 0x000000;    
      menu[ 4] = 0x00ffff;    
      menu[ 5] = 0xaaaaaa;
      menu[ 6] = 0x555555;    
      menu[ 7] = 0xffffff;    
      menu[ 8] = 0x0000ff;
      menu[ 9] = 0x00ff00;    
      menu[10] = 0xff0000;    
      menu[11] = 0xbbffff;
      menu[12] = 0x0000dd;    
      menu[13] = 0x00bb00;    
      menu[14] = 0xcc0000;

      m_priority[ 0] =  6;    
      m_priority[ 1] =  2;    
      m_priority[ 2] = 11;
      m_priority[ 3] = 13;    
      m_priority[ 4] =  1;    
      m_priority[ 5] = 12;
      m_priority[ 6] =  5;    
      m_priority[ 7] = 14;    
      m_priority[ 8] =  0;
      m_priority[ 9] =  7;    
      m_priority[10] =  3;    
      m_priority[11] =  4;
      m_priority[12] =  8;    
      m_priority[13] =  9;    
      m_priority[14] = 10;
      }

   /* Determine number of planes, number of shades, and base shades. */

   WLget_context_info( context_no, &context_info );
   real_num_planes = context_info.base_depth;

   if (num_planes > real_num_planes) num_planes = real_num_planes;

   if (num_planes < 3)	/* not enough planes */
      return;

   else 
   if (num_planes < 5)	/* num_planes = 3 or 4 */
      num_shds = 2;

   else 
   if (num_planes == 5)
      {
      base_shade[1] = 0xba;	
      num_shds = 3;
      }

   else 
   if (num_planes < 8)    /* num_planes = 6 (or 7) */
      {
      base_shade[1] = 0x9b;	
      num_shds = 4;
      base_shade[2] = 0xd4;
      }

   else 
   if (num_planes == 8)
      {
      base_shade[1] = 0x7b;	
      num_shds = 6;
      base_shade[2] = 0xa8;
      base_shade[3] = 0xca;
      base_shade[4] = 0xe6;
      }

   else    /* num_planes = 9 (or more) */
      {
      base_shade[1] = 0x69;	
      num_shds = 8;
      base_shade[2] = 0x90;   
      num_planes = 9;
      base_shade[3] = 0xad;
      base_shade[4] = 0xc6;
      base_shade[5] = 0xdb;
      base_shade[6] = 0xee;
      }

   base_shade[0] = 0x00;
   base_shade[num_shds - 1] = 0xff;

   /* Initialize vlt. */

   cmap_slot.slot = 0;
   cmap_slot.red = cmap_slot.green = cmap_slot.blue = 0x0000;

   for (i = 0; i < (1 << num_planes); i++)
      COPYCMAP( cmap[i], cmap_slot );

   /* Calculate number of apparent intensities and number of unused slots. */

   num_intens = (16 * (num_shds - 1)) + 1;
   num_extras = (1<<num_planes) - (num_shds*num_shds*num_shds); /* 1<<n=2^n */

   /* Build vlt, with 9-bit rgb value stored for the vlt slot number. */

   slot_num = num_extras;	/* start after "extra" slots for menu */

   for (blu = 0; blu < num_shds; blu++)
   for (grn = 0; grn < num_shds; grn++)
   for (red = 0; red < num_shds; red++)
      {
      cmap[slot_num].slot  = (blu << 6) | (grn << 3) | red;
      cmap[slot_num].red   = (base_shade[red] << 8) | base_shade[red];
      cmap[slot_num].green = (base_shade[grn] << 8) | base_shade[grn];
      cmap[slot_num].blue  = (base_shade[blu] << 8) | base_shade[blu];
      slot_num++;
      }

   /* Place menu colors in unused vlt slots. */

   tot_menu_slots = ((num_planes < 8) ? (5) : (15));

   if (num_extras > tot_menu_slots) num_extras = tot_menu_slots;

   for (i = 0; i < num_extras; i++)
      {		

      /* note:  slot = 0 already */

      cmap[i].red   = (menu[m_priority[i]] << 8) & 0xff00;
      cmap[i].green = (menu[m_priority[i]]) & 0xff00;
      cmap[i].blue  = (menu[m_priority[i]] >> 8) & 0xff00;
      }

   /* Re-shuffle vlt to find best match for menu colors. */

   for (i = 0; i < tot_menu_slots; i++)
      {
      red = menu[m_priority[i]] & 0xff;
      grn = (menu[m_priority[i]] >> 8) & 0xff;
      blu = (menu[m_priority[i]] >> 16) & 0xff;
      min_dist = MAXDIST;

      for (j = 0; (j < ((1 << num_planes) - 1)) && (min_dist != 0); j++)
         {		    

         /* start at beginning; exclude white at end */

         found = FALSE;

         for (k = 0; k < i; k++)
            if (j == m_priority[k])
               found = TRUE;

         if (found == FALSE)
            {
            delta_red = (cmap[j].red   >> 8) - red;
            delta_grn = (cmap[j].green >> 8) - grn;
            delta_blu = (cmap[j].blue  >> 8) - blu;
            dist = (delta_red * delta_red) + 
                   (delta_grn * delta_grn) + 
                   (delta_blu * delta_blu);

            if (dist < min_dist)
               {
               best_match = j;    
               min_dist = dist;
               }

            else 
            if (dist == min_dist)
               {
               lum_true = (RLUM * red) + (GLUM * grn) + (BLUM * blu);
               lum_best = (RLUM * (cmap[best_match].red >> 8)) + 
                          (GLUM * (cmap[best_match].green >> 8)) + 
                          (BLUM * (cmap[best_match].blue >> 8));
               lum_j = (RLUM * (cmap[j].red >> 8)) + 
                       (GLUM * (cmap[j].green >> 8)) + 
                       (BLUM * (cmap[j].blue >> 8));
               lum_best = lum_best - lum_true;

               if (lum_best < 0) lum_best = -lum_best;
                  lum_j = lum_j - lum_true;

               if (lum_j < 0) lum_j = -lum_j;
                  if (lum_j < lum_best) best_match = j;
               }
            }
         }

      COPYCMAP( cmap_slot, cmap[m_priority[i]] );
      COPYCMAP( cmap[m_priority[i]], cmap[best_match] );
      COPYCMAP( cmap[best_match], cmap_slot );
      }

   /* Build 9-bit rgb to vlt_index map */

   for (i = 0; i < (1 << num_planes); i++)
      {
      if (cmap[i].slot > 0) rgb_tbl[cmap[i].slot] = i;
         cmap[i].slot = i;
      }

   WLload_cmap_entries( context_no, (1 << num_planes), cmap );

   if (num_planes != real_num_planes)	/* be sure hilite is loaded */
      {
      cmap[0].slot = (1 << real_num_planes) - 1;
      cmap[0].red = cmap[0].green = cmap[0].blue = 0xffff;
      WLload_cmap_entries( context_no, 1, cmap );
      }

#  ifdef DEBUGVLT
   /* Debug print statements to reveal contents of rgb_tbl and vlt */
   printf ("\nrgb_tbl\n");
   printf ("----\n");
   for (i = 0; i < 128; i++)
      printf ("%3o:	%3d	%3o:	%3d	%3o:	%3d	%3o:	%3d\n",
         i,rgb_tbl[i],i+128,rgb_tbl[i+128],i+256,
         rgb_tbl[i+256],i+384, rgb_tbl[i+384]);
   printf ("\nvlt\n");
   printf ("---\n");
   for (i = 0; i < (1 << (num_planes-1)); i++)
      printf ("%3d:	(%3d)	%3d/%3d/%3d	%3d:	(%3d)	%3d/%3d/%3d\n",
         i,cmap[i].slot,cmap[i].red>>8,cmap[i].green>>8,cmap[i].blue>>8,
         i+(1<<(num_planes-1)),cmap[i+(1<<(num_planes-1))].slot,
         cmap[i+(1<<(num_planes-1))].red>>8,
         cmap[i+(1<<(num_planes-1))].green>>8,
         cmap[i+(1<<(num_planes-1))].blue>>8);
   printf ("\n");
#  endif

   }	/* init_rgb */

/*--------finish_rgb---------------------------------------------------------*/

/* Re-load the fixed VLT on machines with 8 or more planes */

void finish_rgb (WLuint32 context_no, int num_planes)

   {

   if ( num_planes > 8 )
      {
      WLload_cmap_entries( context_no, 14, fixed_cmap );
      }
   }	/* finish_rgb */

static int dither_mat[16] = {  0,  8,  2, 10,   /* 4x4 ordered */
                              12,  4, 14,  6,   /*   dither    */
                               3, 11,  1,  9,
                              15,  7, 13,  5 };

/*--------index_rgb--------------------------------------------------------*/

/* Given the x- & y-coordinate of a pixel and an rgb color value (in the   */
/*   range [0..255]), return a vlt index.                                  */

int index_rgb ( int x,  
                int y,  
                int red,  
                int grn,  
                int blu)

   {
   register int	dither_val;

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
   /*   9-bit rgb dither value.                                    */

   return (rgb_tbl[(blu << 6) | (grn << 3) | red]);

   }	/* index_rgb */

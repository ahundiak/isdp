 /*
 $Author: hans $
 $Revision: 1.1.1.1 $
 $Date: 2001/12/17 22:40:40 $
 $Locker:  $
 */


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
 *  Revised:  1/04/91 - added capability to used Save/Restore VLTs
 */


#define	TRUE	1
#define	FALSE	0

#include <stdio.h>
#include <stdlib.h>
#include "wl.h"

#if X11
#include "dpgraphics.h"
extern Colormap EXcolormap[];


struct vlt_slot
{
  unsigned long pixel;
  unsigned short red;
  unsigned short green;
  unsigned short blue;
  char flags;
  char pad;
};
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"

#include "HSpr_render.h"


static short	rgb_tbl[512];	/* 9-bit rgb to vlt color index lookup table */
static int	num_intens = 0;	/* total number of "apparent" intensities    */
				/*   for each primary for specified # planes */

static IGRboolean HRfixed_vlt_saved = FALSE;
static struct vlt_slot HRfixed_vlt[14]; /* space to hold original fixed VLT for GX/GZ machines */

static struct vlt_slot VLT[512]; /* space to hold the VLT */

/*--------HRget_rgb----------------------------------------------------------*/
/*	given the vlt slot return red, green, and blue values*/
/*	We are using 2 different structures for X and environ V.*/
/*	The VLT matrix is the lookup table saved in HRinit_rgb.*/
/*	This function is needed for comparisons with the color buffer*/
/*	where we are only given the slot number.  i.e. Check bright*/
/*	edges.*/
/*	This is for testing will be changed with Steve Roger's code*/

void HRget_rgb(  IGRint slot,
		 IGRuint *red,
		 IGRuint *green,
		 IGRuint *blue )
{
}

/*The HN is for NC.  This is used to update the NCshading variable active red,*/
/*green, and blue when ever the color changes.  This has room for optimization*/
/*like not using parameters and just setting the NCshading values*/

void HNget_rgb_from_logical_color( 
	 	 IGRuint logical_color,
		 IGRuint *red,
		 IGRuint *green,
		 IGRuint *blue )
{
	IGRuint	psuedo_color;

	psuedo_color=HSget_rgb_value( logical_color );
	*red=(psuedo_color >> 22) & 0xff;
	*green=(psuedo_color >> 12) & 0xff;
	*blue=(psuedo_color >> 2) & 0xff;
}

/*--------HRinit_rgb---------------------------------------------------------*/

/* Set up rgb_tbl and vlt to map rgb values to vlt entries for the	   */
/*   specified number of planes.					   */

void HRinit_rgb( int window,
		 int num_planes,
		 int vs_num,
		 int use_SRVLT )

  {
  }	/* HRinit_rgb */

/*--------HRfinish_rgb---------------------------------------------------------*/

/* Re-load the fixed VLT on machines with 7 or more planes */

	void HRfinish_rgb( int vs_num,
			   int num_planes )

  {
  }	/* HRfinish_rgb */

/*--------HRindex_rgb--------------------------------------------------------*/

/* Given the x- & y-coordinate of a pixel and an rgb color value (in the   */
/*   range [0..255]), return a vlt index.                                  */

	int HRindex_rgb( int x,
			 int y,
			 int red,
			 int grn,
			 int blu )
  {
    return (0);
  }	/* HRindex_rgb */


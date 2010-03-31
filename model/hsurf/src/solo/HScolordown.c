#include <stdio.h>
#include <sdl.h>
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpdef.h"
#include "igecolor.h"

#include "hsdef.h"
#include "hsurf.h" 
#include "hsmacdef.h"
#include "HStl_window.h"

#define	ROUND(x) x>0 ? (x + 0.5):(x - 0.5)

#define	MAX2( x, y )	x > y ? x : y
#define MAX( x, y, z )	MAX2( MAX2( x, y ), z )

#define SHIFTER	8

#define	BORDER		4
#define	X_ORIGIN	0
#define	Y_ORIGIN	0

#define DEBUG		0

static struct	vlt_slot	vlt[512];
static struct vlt_slot   base[20] = {
	  {  0, 0x0000, 0x0000, 0x0000 },
	  {  1, 0x0000, 0xffff, 0x0000 },
	  {  2, 0xffff, 0x0000, 0x0000 },
	  {  3, 0x0000, 0x0000, 0xffff },
	  {  4, 0xffff, 0xffff, 0x0000 },
	  {  5, 0xffff, 0x0000, 0xffff },
	  {  6, 0x0000, 0xffff, 0xffff },
	  {  7, 0xffff, 0xffff, 0xffff },
	  {  8, 0x7851, 0x1999, 0x0000 },
	  {  9, 0x7777, 0xffff, 0xffff },
	  { 10, 0xffff, 0x7777, 0xffff },
	  { 11, 0xffff, 0x7777, 0x7777 },
	  { 12, 0x0000, 0xffff, 0x7777 },
	  { 13, 0xffff, 0x7777, 0x0000 },
	  { 14, 0x7777, 0x7777, 0xffff },
	  { 15, 0x7777, 0x7777, 0x7777 },
	  { 16, 0x7777, 0x7777, 0x0000 },
	  { 17, 0x0000, 0x7777, 0xffff },
	  { 18, 0xffff, 0x0000, 0x7777 },
	  { 19, 0xffff, 0x0000, 0xffff } };
	
/*---download_colortable----------------------------------------------*/

int	download_colortable( IGRboolean using_ramps,
                             IGRint num_colors,
                             IGRint num_shades )

   {
   int      c, i, j, vs_num;
   double   dr, dg, db;

   Inq_displayed_vs (&vs_num);
   if( using_ramps )
      {
      c = 0;
      vlt[c++] = base[0];

      Readvlt (vs_num, vlt, num_colors * num_shades, 1);
      
      for( i=1; i<=num_colors; i++ )
         {
         dr = (double)base[i].v_red   / (double)num_shades;
         dg = (double)base[i].v_green / (double)num_shades;
         db = (double)base[i].v_blue  / (double)num_shades;

         vlt[c] = base[i];
         vlt[c].v_slot = c;
         c++;
         
         for( j=1; j<num_shades; j++, c++ )
            {
            vlt[c].v_slot  = c;
            vlt[c].v_red   = vlt[c-1].v_red   - dr;
            vlt[c].v_green = vlt[c-1].v_green - dg;
            vlt[c].v_blue  = vlt[c-1].v_blue  - db;
            }
         }

      Loadvlt( vs_num, vlt, num_colors * num_shades );
      }
   else
      {	
      c = 0;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
	
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
	
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
	
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x00ff;
	
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
	
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x0000;     vlt[c++].v_blue = 0x00ff;
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x0000;
      vlt[c].v_red = 0x0000;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
	
      vlt[c].v_red = 0x00ff;     vlt[c].v_green = 0x00ff;     vlt[c++].v_blue = 0x00ff;
      }

   return(0);/* function wasn't returning anything */
   }

int	HSget_rgb_value( color )

int	color;

	{
	int	rgb_value;
	int	r, g, b;

	r = vlt[color].v_red;
	g = vlt[color].v_green;
	b = vlt[color].v_blue;
	
	rgb_value = (r << 22) | (g << 12) | (b << 2);
	
	return( rgb_value );
	}



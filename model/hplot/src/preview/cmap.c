#include <stdio.h>
#include <string.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "preview.h"

#include "cmap.h"

#define	DEBUG	0

#define NUM_USER_COLORS	16

static int	colorslots[NUM_USER_COLORS];

static struct WLcmap_entry	colors[NUM_USER_COLORS] = {
	{  0, 0x0000, 0x0000, 0x0000, 0 },   /*  BLACK  */
	{  1, 0x0000, 0xffff, 0x0000, 0 },   /*  GREEN  */
	{  2, 0xffff, 0x0000, 0x0000, 0 },   /*  RED  */
	{  3, 0x0000, 0x0000, 0xffff, 0 },   /*  BLUE  */
	{  4, 0xffff, 0xffff, 0x0000, 0 },   /*  YELLOW  */
	{  5, 0x0000, 0xffff, 0xffff, 0 },   /*  CYAN  */
	{  6, 0xffff, 0x0000, 0xffff, 0 },   /*  MAGENTA  */
	{  7, 0xffff, 0xffff, 0xffff, 0 },   /*  WHITE  */
	{  8, 0xaaaa, 0xaaaa, 0xaaaa, 0 },   /*  GRAY  */
	{  9, 0x7777, 0xffff, 0x7777, 0 },   /*  LIGHTGREEN  */
	{ 10, 0xffff, 0x7777, 0x7777, 0 },   /*  LIGHTRED  */
	{ 11, 0x7777, 0x7777, 0xffff, 0 },   /*  LIGHTBLUE  */
	{ 12, 0xffff, 0xffff, 0x7777, 0 },   /*  LIGHTYELLOW  */
	{ 13, 0x7777, 0xffff, 0xffff, 0 },   /*  LIGHTCYAN  */
	{ 14, 0xffff, 0x7777, 0xffff, 0 },   /*  LIGHTMAGENTA  */
	{ 15, 0x7777, 0x7777, 0x7777, 0 } }; /*  LIGHTGRAY  */

/*---IGEcmap_color_to_index-----------------------------------*/

int IGEcmap_color_to_index ( WLuint32 context_no,
                             WLuint32 index,
                             WLuint32 red,
                             WLuint32 green,
                             WLuint32 blue,
                             WLuint32 flag,
                             WLuint32 *phy_index)

   {
   *phy_index = index;

   if (flag & WL_COLOR_RGB)
      {
      return (WL_ERROR);
      }
   else
      {
#     if ! defined( WIN32 )
         *phy_index = colorslots[index];
#     else
         switch (index)
            {
            case BLACK:     *phy_index = 0;  break;
            case RED:       *phy_index = 13; break;
            case GREEN:     *phy_index = 14; break;
            case BLUE:      *phy_index = 16; break;
            case YELLOW:    *phy_index = 15; break;
            case WHITE:     *phy_index = 19; break;
            /*case ORANGE:    *phy_index = 0;  break;*/
            case LIGHTGRAY: *phy_index = 0;  break;
            /*case DARKGRAY:  *phy_index = 0;  break;*/
            }
#     endif
      }

   return (WL_SUCCESS);
   }    

/*---IGEcmap_color_to_rgb--------------------------------------*/

int IGEcmap_color_to_rgb ( WLuint32 context_no,
                           WLuint32 index, 
                           WLuint32 red,
                           WLuint32 green,
                           WLuint32 blue,
                           WLuint32 flag,
                           WLuint32 *out_red,
                           WLuint32 *out_green,
                           WLuint32 *out_blue)

   {
   if (flag & WL_COLOR_RGB)
      {
      *out_red = red;
      *out_green = green;
      *out_blue = blue;
      }
   else
      {
      *out_red = colors[index].red;
      *out_green = colors[index].green;
      *out_blue = colors[index].blue;
      }

   return (WL_SUCCESS);
   }  

/*---IGEcmap_init----------------------------------------------*/

int IGEcmap_init ( WLuint32 context_no)

   {
   int sts;
   int index;
   int ii, lastslot;
   int num_hilite;
   int num_wm_colors, num_ingr_colors;

   struct WLcontext_info context_info;
   struct WLcmap_entry   *entries;
   struct WLcmap_entry   *wm_colors, *ingr_colors;

   sts = WLget_context_info (context_no, &context_info);
   /*WL_ERRCHK( sts );*/

   if ((context_info.base_cmap_type == WL_CMAP_INDEXED) &&
       !(context_info.flags & WL_COLORMAP_READ_ONLY))
      {
      if (context_info.hilite_used & WL_HILITE_USED)
         {
         num_hilite = 1 << context_info.base_depth;
         }
      else
         {
         num_hilite = 0;
         }

      wm_colors = ingr_colors = NULL;
      sts = WLget_wm_colors (context_no,
                             &num_wm_colors, &wm_colors,
                             &num_ingr_colors, &ingr_colors);

      index = 0;

      lastslot = 0;

      entries = (struct WLcmap_entry *)malloc ((
                         num_wm_colors + 
                         num_hilite + NUM_USER_COLORS) * 
                         sizeof (struct WLcmap_entry));

      for( ii=0; ii<num_wm_colors; ii++, index++ )
         {
         entries[index].slot  = wm_colors[ii].slot;
         entries[index].red   = wm_colors[ii].red;
         entries[index].green = wm_colors[ii].green;
         entries[index].blue  = wm_colors[ii].blue;
         entries[index].flags = wm_colors[ii].flags;
   
         if( wm_colors[ii].slot > lastslot && wm_colors[ii].slot < 255 ) 
            lastslot = wm_colors[ii].slot;
         }

      if (wm_colors) WLfree ((char *) wm_colors);
      if (ingr_colors) WLfree ((char *) ingr_colors);

      for( ii=0; ii<NUM_USER_COLORS; ii++, index++ )
         {
         entries[index].slot = colorslots[ii] = ++lastslot;
         entries[index].red = colors[ii].red;
         entries[index].green = colors[ii].green;
         entries[index].blue = colors[ii].blue;
         }

      for (ii = 0; ii < num_hilite; ii++)
         {
         entries[index].slot = (1 << context_info.base_depth) + ii;
         entries[index].red = 0xFFFF;
         entries[index].green = 0xFFFF;
         entries[index].blue = 0xFFFF;
         index++;
         }

/*
for( ii=0; ii<num_wm_colors; ii++ )
   printf( "%d %x %x %x %x\n", wm_colors[ii].slot, 
      wm_colors[ii].red, wm_colors[ii].green, wm_colors[ii].blue,
      wm_colors[ii].flags );
for( ii=0; ii<index; ii++ )
   printf( "%d %x %x %x %x\n", entries[ii].slot, 
      entries[ii].red, entries[ii].green, entries[ii].blue,
      entries[ii].flags );
*/

      sts = WLload_cmap_entries (context_no, index, entries);

      free ((char *) entries);
      }
   else if (context_info.base_cmap_type == WL_CMAP_TRUE_COLOR)
      {
      if (context_info.hilite_used & WL_HILITE_USED)
         {
         num_hilite = 1 << (context_info.base_depth / 3);
         }
      else
         {
         num_hilite = 0;
         }

      entries = (struct WLcmap_entry *)malloc (
                        ((1 << (context_info.base_depth / 3)) + num_hilite) * 
                        sizeof (struct WLcmap_entry));

      for (index = 0; index < 1 << (context_info.base_depth / 3); index++)
         {
         entries[index].slot  = index;
         entries[index].red   = index * 255;
         entries[index].green = index * 255;
         entries[index].blue  = index * 255;
         entries[index].flags = 0;
         }

      for (ii = 0; ii < num_hilite; ii++)
         {
         entries[index].slot  = (1 << (context_info.base_depth / 3)) + ii;
         entries[index].red   = 0xFFFF;
         entries[index].green = 0xFFFF;
         entries[index].blue  = 0xFFFF;
         entries[index].flags = 2;
         index++;
         }

      sts = WLload_cmap_entries (context_no, index, entries);

      free ((char *) entries);
      }


   return (WL_SUCCESS);

   }    /* cmap_init */

/*---IGEload_context----------------------------------------------*/

int IGEload_context (WLuint32 context_no, 
                     struct IGEcontext_info *context_info)

   {
   context_info->context_no = context_no;
   context_info->table_depth = preview.base_depth;
   context_info->num_win_mgr_colors = 0;
   context_info->win_mgr = NULL;
   context_info->num_ingr_res_colors = 14;
   context_info->ingr_res = NULL;
   context_info->num_bg_log_hl_colors = 0;
   context_info->bg_log_hl = NULL;
   context_info->rgb_table = NULL;
   context_info->cube_size = 5;
   context_info->user_cube_size = 5;
   context_info->num_ramp_colors = 20;
   context_info->num_ramp_shades = 12;
   context_info->using_ramp = 0;
   context_info->user_ramp_start_slot = 15;
   
   return 1;
   }

/*---IGEgetbasclrindx------------------------------------*/

int	IGEgetabsclrindx( WLuint32 context_no,
                          IGRshort log_color,
                          IGRshort *abs_color )

   {
   WLuint32	color;

   IGEcmap_color_to_index( context_no, log_color, 0, 0, 0, 0, &color );
   *abs_color = (IGRshort)color;
   
   return 1;
   }

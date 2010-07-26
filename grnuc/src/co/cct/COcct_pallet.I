class implementation COcctform;
/*
 *   Filename:   COcct_pallet.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   January 1989
 *
 *   This file contains the actions that manipulate the color pallet:
 *
 *   draw_color_block   - draws a color block on the pallet
 *
 *   highlight_color_block   - highlights a color block
 *
 *   draw_color_pallet   - draws the color pallet
 *
 *   (HRindex_hls)   - returns an index given hue, lum and sat
 *
 *   draw_lum_range   - draws the luminance range bar
 *
 *   draw_hue_sat_block   - draws the rainbow hue vs saturation block
 *
 *   draw_cross_hairs   - draw the cursor cross hairs
 *
 *   draw_lum_ptr   - draw the ptr to pct of luminance on the bar
 *
 *   map_to_hls   - maps a xy from the form to one of the areas drawn
 *
 *   toggle_compensation - changes the state of the compensation from 1.0 to 2.2 
 *                 for all guns.  This is overwritten for different values
 *            of gamma when on.
 *
 *   History:
 */

#include <stdio.h>
#include <math.h>

#include "cct.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "cm.h"

#ifdef X11
extern Colormap EXcolormap[];
#endif
   static IGRint old_x, old_y;
extern short *IGErgb_table;
#define MAX( x, y )   (x > y) ? (x) : (y)
/* this is borrowed from the intensity function and put into macro for efficiency.  It*/
/* also combines conversion into integer between 0 and 255.*/
#define INTENSITY( int1,  int2,  hue )  \
   (hue < 60.0) ? (int) ( (int1 + (((int2 - int1) * hue) / 60.0)) * 255.0 ) : \
      (hue < 180.0) ? (int) ( int2 * 255.0 ) : \
         (hue < 240.0) ? (int) ( (int1 + (((int2 - int1) * (240.0 - hue)) / 60.0)) * 255.0 ) : (int) ( int1 * 255.0 ) 

/*----- draw_color_block -----------------------------------------------------*/
method draw_color_block( long * sts )
/*
NAME
   COcctform.draw_color_block
DESCRIPTION
   This draws the solid color, dithered color and highlights and draws 
   the active color in pallet
PARAMETERS
   sts (out) - the status of the routine
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

{

   IGRint y_index;
   IGRchar color_char[16];
   IGRshort color_short[16];
   IGRboolean      within_tol;
   IGRint          matched_slot;
   IGRushort red, green, blue;
   IGRint   xpos, ypos;
   IGRint  x, y;
   IGRint   color;
   register IGRchar *buffer_ptr_char;
   register IGRshort *buffer_ptr_short;
   int  buff_size;
   struct WLraster_data *raster_data_ptr;
   WLcolorref   color_ref;
   struct WLrect    rect;
   IGRint width, height;
   struct IGEcontext_info      IGEcontext_info;
   IGRdouble  gamma[3];

   IGEload_context( me->context_no, &IGEcontext_info );
   WLget_raster_size( me->lwin_no, 1, 1, &buff_size);

   WLhide_cursor( me->lwin_no, TRUE );

   /* draw the block */
   red = (IGRushort) ( 255.0 *
         ( (IGRushort) ( (me->curr_red   * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) ) 
                  / (IGRdouble) (IGEcontext_info.cube_size - 1.0 ) ) );
   green = (IGRushort) (  255.0 *
         ( (IGRushort) ( (me->curr_green * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) )  
                  / (IGRdouble) (IGEcontext_info.cube_size - 1.0 ) ) );
   blue = (IGRushort) (  255.0 *
         ( (IGRushort) ( (me->curr_blue  * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) ) 
                  / (IGRdouble) (IGEcontext_info.cube_size - 1.0 ) ) );

   /* find out the physical slot of the cube */
   if ( (IGEcontext_info.using_ramp) && (me->curr_color != 0) && (me->curr_color < me->num_colors - 1))
   {
      if ((me->curr_color >= 1) && (me->curr_color <= IGEcontext_info.num_ramp_colors))
      {
         ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma);
         IGEload_ramp( IGEcontext_info.bg_log_hl[me->curr_color].phys_slot, 
            (IGRushort)(me->curr_red * 65535.0), (IGRushort)(me->curr_green * 65535.0), 
            (IGRushort)(me->curr_blue * 65535.0), gamma, &IGEcontext_info);
         WLpack_index_colorref( me->curr_color, &color_ref, FALSE );
      }
      else
      {
         IGEcalc_best_match((IGRushort)(me->curr_red * 65535.0), (IGRushort)(me->curr_green * 65535.0), 
            (IGRushort)(me->curr_blue * 65535.0), &within_tol, 1.0,
            VLT_RAMP_BASE_COLOR_SLOT, VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
            1 << IGEcontext_info.table_depth, &matched_slot);
         WLpack_index_colorref( matched_slot, &color_ref, TRUE );
      }
   }
   else
   {
      WLpack_index_colorref( IGErgb_to_index( me->context_no, 2, 1, red, green, blue), &color_ref, TRUE );
   }
   WLset_active_symbology( me->lwin_no, color_ref, 0, 0, 1, WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT ); 
   rect.x = me->solid_color_x + 2;
   rect.y = me->solid_color_y + 2;
   rect.width = me->solid_color_width - 2;
   rect.height = me->solid_color_height - 2;
   WLdraw_rectangle( me->lwin_no, &rect, TRUE );

   red = (IGRushort) (me->curr_red * 255.0);
   green = (IGRushort) (me->curr_green * 255.0);
   blue = (IGRushort) (me->curr_blue * 255.0);

#if defined ( DEBUG_CCT )
   /* this prints out one 4x4 dithered array of the active color */
   printf("COcctform:draw_color_block color_ref %X r %d g %d b %d\n",color_ref,red,green,blue);
   for (y=0;y<4;y++) {for (x=0;x<4;x++) printf("\t%d",IGErgb_to_index( me->context_no, x, y, red, green, blue)); printf("\n");}
#endif
   COget_raster_data_struct( DITHERED_COLOR, &raster_data_ptr );

   width = me->dithered_color_x + me->dithered_color_width;
   height = me->dithered_color_y + me->dithered_color_height;
   switch (buff_size)
   {
      case 1:
         buffer_ptr_char = raster_data_ptr->buffer;
         for (y = 0; y < 4; y ++) 
         {
            for (x = 0; x < 4; x++)
            { 
               /* set up specific dithered matrix */
               color_char[(y * 4) + x] = (IGRchar) IGErgb_to_index( me->context_no, x, y, red, green, blue);
            }
         }
         for (y = me->dithered_color_y + 2, y_index = (y % 4) * 4; y < height; y++, y_index = (y % 4) * 4)
         {
            for (x = me->dithered_color_x + 2; x < width; x++)
            {
               *buffer_ptr_char++ = color_char[y_index + (x % 4)];
            }
         }
         break;
      case 2:
         buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
         for (y = 0; y < 4; y ++) 
         {
            for (x = 0; x < 4; x++)
            { 
               /* set up specific dithered matrix */
               color_short[(y * 4) + x] = (IGRshort) IGErgb_to_index( me->context_no, x, y, red, green, blue);
            }
         }
         for (y = me->dithered_color_y + 2, y_index = (y % 4) * 4; y < height; y++, y_index = (y % 4) * 4)
         {
            for (x = me->dithered_color_x + 2; x < width; x++)
            {
              *buffer_ptr_short++ = color_short[y_index + (x % 4)];
            }
         }
         break;
   }

   WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );

   if ((((me->curr_color - 1) / 64) == me->curr_color_page) ||
      (me->curr_color == 0) || 
      (me->curr_color == me->num_colors - 1) )
   {
      if (me->curr_color >= me->num_colors - 1)
      {
         /* highlight */
         color = 66;
      }
      else
      {
         if (me->curr_color == 0)
         {
            /* background */
            color = 65;
         }
         else
         {
            color = ((me->curr_color - 1) % 64) + 1;
         }
      }

      xpos = me->log_col_gad[color].x;
      ypos = me->log_col_gad[color].y;

      COget_raster_data_struct( LOGICAL_COLOR, &raster_data_ptr );

      width = xpos + me->log_col_gad[0].width;
      height = ypos + me->log_col_gad[0].height;
   
      switch (buff_size)
      {
         case 1:
            buffer_ptr_char = raster_data_ptr->buffer;
            for (y = ypos + 2; y < height; y++)
            {
               for (x = xpos + 2; x < width; x++)
               {
                  *buffer_ptr_char++ = (IGRchar) IGErgb_to_index( me->context_no, x, y, red, green, blue);
               }
            }
            break;
         case 2:
            buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
            for (y = ypos + 2; y < height; y++)
            {
               for (x = xpos + 2; x < width; x++)
               {
                  *buffer_ptr_short++ = (IGRshort) IGErgb_to_index( me->context_no, x, y, red, green, blue);
               }
            }
            break;
      }
      raster_data_ptr->x = xpos + 2;
      raster_data_ptr->y = ypos + 2;
      WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );

      /* highlight the new active color */
      om$send( msg      = message COcctform.highlight_color_block
                        ( me->curr_color, me->last_color ),
               targetid = my_id );   
   }
      
   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );
   return( OM_S_SUCCESS);
}

/*----- highlight_color_block ------------------------------------------------*/
method highlight_color_block( int logical_color_to_highlight; int logical_color_to_dehighlight )
{
/*
NAME
   COcctform.highlight_color_block
DESCRIPTION
   this highlights the color block in the active pallet and dehighlights 
   the previous one
PARAMETERS
   logical_color_to_highlight (in) - highlights this block in pallet
   logical_color_to_dehighlight (in) - dehighlights this block in pallet
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   int   xpos, ypos;
   struct WLrect    rect;

   WLhide_cursor( me->lwin_no, TRUE );

   /* dehighlight the block */
   if ((((logical_color_to_dehighlight - 1) / 64) == me->curr_color_page) ||
      (logical_color_to_dehighlight == 0) || 
      (logical_color_to_dehighlight == me->num_colors - 1) )
   {
      if (logical_color_to_dehighlight == me->num_colors - 1)
      {
         logical_color_to_dehighlight = 66;
      }
      else
      {
         if (logical_color_to_dehighlight == 0)
         {
            logical_color_to_dehighlight = 65;
         }
         else
         {
            logical_color_to_dehighlight = ((logical_color_to_dehighlight - 1) % 64) + 1;
         }
      }
      xpos = me->log_col_gad[logical_color_to_dehighlight].x;
      ypos = me->log_col_gad[logical_color_to_dehighlight].y;
   
      WLset_active_symbology( me->lwin_no, me->menu_bg, 0, 0, 1, 
         WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
      rect.x = xpos;
      rect.y = ypos;
      rect.width = me->log_col_gad[logical_color_to_dehighlight].width + 1;
      rect.height = me->log_col_gad[logical_color_to_dehighlight].height + 1;
      WLdraw_rectangle( me->lwin_no, &rect, FALSE );
   }
      
   /* highlight the block */
   if ((((logical_color_to_highlight - 1) / 64) == me->curr_color_page) ||
      (logical_color_to_highlight == 0) || 
      (logical_color_to_highlight == me->num_colors - 1) )
   {
      if (logical_color_to_highlight == me->num_colors - 1)
      {
         logical_color_to_highlight = 66;
      }
      else
      {
         if (logical_color_to_highlight == 0)
         {
            logical_color_to_highlight = 65;
         }
         else
         {
            logical_color_to_highlight = ((logical_color_to_highlight - 1) % 64) + 1;
         }
      }
      xpos = me->log_col_gad[logical_color_to_highlight].x;
      ypos = me->log_col_gad[logical_color_to_highlight].y;
   
      WLset_active_symbology( me->lwin_no, me->menu_hl, 0, 0, 1, 
         WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
      rect.x = xpos;
      rect.y = ypos;
      rect.width = me->log_col_gad[logical_color_to_highlight].width + 1;
      rect.height = me->log_col_gad[logical_color_to_highlight].height + 1;
      WLdraw_rectangle( me->lwin_no, &rect, FALSE );
   }
   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );

   return( OM_S_SUCCESS);
}

/*----- draw_color_pallet ----------------------------------------------------*/

method draw_color_pallet ( long * sts )
/*
NAME
   COcctform.draw_color_pallet
DESCRIPTION
   this draws the 8 x 8 color pallet with the correct page
PARAMETERS
   sts (out) - the status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
{
   IGRint y_index;
   IGRchar color_char[16];
   IGRshort color_short[16];
   IGRint i, index,block_x,block_y,color_pos;
   int   xpos, ypos;
   IGRint x, y, width, height;
   IGRushort redu, greenu, blueu;
   IGRint red, green, blue;
   IGRint start_color, end_color;
   struct WLrect    rect;
   register IGRchar *buffer_ptr_char;
   register IGRshort *buffer_ptr_short;
   int  buff_size;
   struct WLraster_data *raster_data_ptr;

   struct IGEcontext_info      IGEcontext_info;  IGEload_context( me->context_no, &IGEcontext_info );
   WLget_raster_size( me->lwin_no, 1, 1, &buff_size);

   WLhide_cursor( me->lwin_no, TRUE );

   start_color = (me->curr_color_page * 64) + 1;
   end_color = (me->curr_color_page * 64) + 64;
   if ( end_color > (me->num_colors - 2 ) ) 
   {
      /* erasing unused rectangle gadgets */
      end_color = me->num_colors - 2;
      WLset_active_symbology( me->lwin_no, me->menu_fg, 0, 0, 1, 
         WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT ); 
      block_x = (end_color - 1) % 8;
      block_y = ((end_color - 1) % 64) / 8;
      color_pos = ((end_color - 1) % 64) + 2;

      /* erase remainder in row */
      if ( block_x < 7 )
      {
         rect.x = me->log_col_gad[color_pos].x;
         rect.y = me->log_col_gad[color_pos].y;
         rect.width = me->log_col_gad[8].width + me->log_col_gad[8].x - rect.x + 2;
         rect.height = me->log_col_gad[color_pos].height + 2;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );
      }
      /* erase remaining rows */
      if ( block_y < 7 )
      {
         rect.x = me->log_col_gad[0].x;
         rect.y = me->log_col_gad[color_pos + 8].y;
         rect.width = me->log_col_gad[8].width + me->log_col_gad[8].x - rect.x + 2;
         rect.height = me->log_col_gad[64].height + me->log_col_gad[64].y - rect.y + 2;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );
      }
   }

   for ( i = -2; i <= end_color - start_color; i++ )
   {
      switch (i)
      {
         case -2:
            /* background */
            index = 0;
            block_x = 0;
            block_y = 8;
            color_pos = 65;
            break;
         case -1:
            /* highlight */
            index = me->num_colors - 1;
            block_x = 4;
            block_y = 8;
            color_pos = 66;
            break;
         default:
            index = i + start_color;
            block_x = i % 8;
            block_y = i / 8;
            color_pos = i + 1;
            break;
      }
      xpos = me->log_col_gad[color_pos].x;
      ypos = me->log_col_gad[color_pos].y;

      CLunpack_colors( me->modified_ctbl[index], &redu, &greenu, &blueu );
      red   = redu   >> 8;
      green = greenu >> 8;
      blue  = blueu  >> 8;

      COget_raster_data_struct( LOGICAL_COLOR, &raster_data_ptr );

      width = xpos + me->log_col_gad[0].width;
      height = ypos + me->log_col_gad[0].height;

      switch (buff_size)
      {
         case 1:
            buffer_ptr_char = raster_data_ptr->buffer;
            for (y = 0; y < 4; y ++) 
            {
               for (x = 0; x < 4; x++)
               { 
                  /* set up specific dithered matrix */
                  color_char[(y * 4) + x] = (IGRchar) IGErgb_to_index( me->context_no, x, y, red, green, blue);
               }
            }
            for (y = ypos + 2, y_index = (y % 4) * 4; y < height; y++, y_index = (y % 4) * 4)
            {
               for (x = xpos + 2; x < width; x++)
               {
                  *buffer_ptr_char++ = color_char[y_index + (x % 4)];
               }
            }
            break;
         case 2:
            buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
            for (y = 0; y < 4; y ++) 
            {
               for (x = 0; x < 4; x++)
               { 
                  /* set up specific dithered matrix */
                  color_short[(y * 4) + x] = (IGRshort) IGErgb_to_index( me->context_no, x, y, red, green, blue);
               }
            }
            for (y = ypos + 2, y_index = (y % 4) * 4; y < height; y++, y_index = (y % 4) * 4)
            {
               for (x = xpos + 2; x < width; x++)
               {
                  *buffer_ptr_short++ = color_short[y_index + (x % 4)];
               }
            }
            break;
      }
      raster_data_ptr->x = xpos + 2;
      raster_data_ptr->y = ypos + 2;
      WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );

      /* draw block around color */
      WLset_active_symbology( me->lwin_no, me->menu_bg, 0, 0, 1, 
         WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
      rect.x = xpos;
      rect.y = ypos;
      rect.width = me->log_col_gad[color_pos].width + 1;
      rect.height = me->log_col_gad[color_pos].height + 1;
      WLdraw_rectangle( me->lwin_no, &rect, FALSE );
   }

   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );
   return( OM_S_SUCCESS );
}

IGRint HRindex_hls(
   WLuint32 context_no,
   IGRint x,
   IGRint y,
   IGRdouble hue,
   IGRdouble luminance,
   IGRdouble saturation)
{
/*
NAME
   HRindex_hls
DESCRIPTION
   This returns a physical index of the color cube given a hue, 
   luminance and saturation.
PARAMETERS
   context_no (in) - the context to find index in
   x (in) - used for dithering  color selection
   y (in) - used for dithering color selection
   hue (in) - the hue value to use 0.0-359.99
   luminance (in) - the luminance value to use 0.0-1.0
   saturation (in) - the saturation value to use 0.0-1.0
RETURN VALUES
   the physical index
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRdouble r,g,b;

   rgb_from_hls(&r,&g,&b,hue,luminance,saturation);
   return(IGErgb_to_index( context_no, x, y, (IGRint) (r*255), (IGRint) (g*255), (IGRint) (b*255)));
}

method draw_lum_range(long * sts)
{
/*
NAME
   COcctform.draw_lum_range
DESCRIPTION
   this draws the luminance range next to the hueXsat block.  This needs to change with every
   different hue or saturation value.
PARAMETERS
   sts (out) - the status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRdouble x_mind;
   IGRdouble y_mind;
   IGRdouble x_maxd;
   IGRdouble y_maxd;
   IGRdouble y_difd;
   IGRdouble yd; 
   IGRdouble context_no;
   IGRdouble sat1, sat2;
   IGRdouble curr_hue, curr_saturation;
   IGRint ri, gi, bi;
   IGRint x, y;
   IGRint x_min,y_min,x_max,y_max;
   register IGRchar *buffer_ptr_char;
   register IGRshort *buffer_ptr_short;
   int  buff_size;
   struct WLraster_data *raster_data_ptr;
   IGRdouble l;
   register int dither_val;
   static int   dither_mat[16] = {  0,  8,  2, 10,  
                                   12,  4, 14,  6,  
                                    3, 11,  1,  9,
                                   15,  7, 13,  5 };
   int num_intens;
   struct IGEcontext_info      IGEcontext_info;  

   IGEload_context( me->context_no, &IGEcontext_info );
   num_intens = ((IGEcontext_info.cube_size-1)*16)+1;

   WLget_raster_size( me->lwin_no, 1, 1, &buff_size);
   
   x_mind = me->lum_range_x + 2.0;
   x_maxd = me->lum_range_x + me->lum_range_width - 1.0;
   y_mind = me->lum_range_y + 2.0;
   y_maxd = me->lum_range_y + me->color_height - 1.0;
   y_difd = me->color_height - 3.0;
   x_min = (IGRint) x_mind;
   x_max = (IGRint) x_maxd;
   y_min = (IGRint) y_mind;
   y_max = (IGRint) y_maxd;
   context_no = me->context_no;

   WLhide_cursor( me->lwin_no, TRUE );
   rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
      &me->curr_hue, &me->curr_luminance, &me->curr_saturation );
   curr_hue = me->curr_hue;
   curr_saturation = me->curr_saturation;
   COget_raster_data_struct( LUM_RANGE, &raster_data_ptr );
   switch (buff_size)
   {
      case 1:
         buffer_ptr_char = raster_data_ptr->buffer;
         for (y = y_min, yd = y_mind; y <= y_max; y++, yd += 1.0)
         {
            /* l = (y_max - y) / (y_max - y_min) */
            l = (y_maxd - yd) / y_difd;
            for (x = x_min; x <= x_max; x++)
            {
               if (l <= 0.5)
               {
                  sat2 = l * (curr_saturation + 1.0);
               }
               else
               {
                  sat2 = l + curr_saturation - (l * curr_saturation);
               }
            
               sat1 = (2.0 * l) - sat2;
         
               if (curr_hue < 240.0) 
               {
                  ri = INTENSITY( sat1, sat2, (curr_hue + 120.0) );
               } 
               else 
               {
                  ri = INTENSITY( sat1, sat2, (curr_hue - 240.0) );
               }
               gi = INTENSITY( sat1, sat2, curr_hue );
               if (curr_hue >= 120.0) 
               {
                  bi = INTENSITY( sat1, sat2, (curr_hue - 120.0) );
               } 
               else 
               {
                  bi = INTENSITY( sat1, sat2, (curr_hue + 240.0) );
               }
               IGERGB_TO_INDEX( *buffer_ptr_char, x, y, ri, gi, bi);
               buffer_ptr_char++;
            }
         }
         break;
      case 2:
         buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
         for (y = y_min, yd = y_mind; y <= y_max; y++, yd += 1.0)
         {
            /* l = (y_max - y) / (y_max - y_min) */
            l = (y_maxd - yd) / y_difd;
            for (x = x_min; x <= x_max; x++)
            {
               if (l <= 0.5)
               {
                  sat2 = l * (curr_saturation + 1.0);
               }
               else
               {
                  sat2 = l + curr_saturation - (l * curr_saturation);
               }
            
               sat1 = (2.0 * l) - sat2;
         
               if (curr_hue < 240.0) 
               {
                  ri = INTENSITY( sat1, sat2, (curr_hue + 120.0) );
               } 
               else 
               {
                  ri = INTENSITY( sat1, sat2, (curr_hue - 240.0) );
               }
               gi = INTENSITY( sat1, sat2, curr_hue );
               if (curr_hue >= 120.0) 
               {
                  bi = INTENSITY( sat1, sat2, (curr_hue - 120.0) );
               } 
               else 
               {
                  bi = INTENSITY( sat1, sat2, (curr_hue + 240.0) );
               }
               IGERGB_TO_INDEX( *buffer_ptr_short, x, y, ri, gi, bi);
               buffer_ptr_short++;
            }
         }
         break;
   }

   WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );
   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );
   return( *sts = TRUE );
}

method draw_hue_sat_block(long * sts; IGRboolean recompute_raster )
{
/*
NAME
   COcctform.draw_hue_sat_block
DESCRIPTION
   This draws the rainbow hue X saturation block on the form.  It will
   reuse the buffer if recompute_raster is false.  You need to redo the 
   raster when gamma_compensation is switched because the color cube slots
   may change
PARAMETERS
   sts (out) - the status of method
   recompute_raster (in) - whether to redo the raster data of block
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   register int dither_val;
   static int   dither_mat[16] = {  0,  8,  2, 10,   /* 4x4 ordered */
                                   12,  4, 14,  6,   /*   dither    */
                                    3, 11,  1,  9,
                                   15,  7, 13,  5 };
   register int num_intens;
   register IGRchar *buffer_ptr_char;
   register IGRshort *buffer_ptr_short;
   register IGRdouble xd;
   register IGRdouble yd;
   register IGRint x;
   register IGRint y;
   register IGRint ri;
   register IGRint gi;
   register IGRint bi;
   register IGRint ri_tmp;
   register IGRint gi_tmp;
   register IGRint bi_tmp;
   register IGRdouble s;
   register IGRdouble h;
   register IGRdouble sat1;
   register IGRdouble sat2;
   IGRdouble y_mind;
   IGRdouble x_maxd;
   IGRdouble y_maxd;
   IGRdouble x_difd;
   IGRdouble y_dif2d;
   IGRdouble h_facd;
   IGRint x_min, y_min, x_max, y_max;
   int  buff_size;
   struct WLraster_data *raster_data_ptr;
   struct IGEcontext_info      IGEcontext_info;  
   
   IGEload_context( me->context_no, &IGEcontext_info );
   WLget_raster_size( me->lwin_no, 1, 1, &buff_size);

   COget_raster_data_struct( HUE_SAT_BLOCK, &raster_data_ptr );
   if (recompute_raster)
   {
#if defined ( DEBUG_CCT )
      printf("COcctform:draw_hue_sat_block filling in whole buffer block\n");
#endif
      /* Compute number of perceived intensities */
      num_intens = ((IGEcontext_info.cube_size - 1) * 16) + 1;
      
      /* compute the mins, maxs and differences in x and y */
      x_maxd = me->hue_sat_block_x + me->hue_sat_block_width - 1.0;
      y_mind = me->hue_sat_block_y + 2.0;
      y_maxd = me->hue_sat_block_y + me->color_height - 1.0;
      x_difd = me->hue_sat_block_width - 3.0;

      /* reduce the number of type conversions by having both doubles and ints */
      x_min = (IGRint) (me->hue_sat_block_x + 2.0);
      y_min = (IGRint) y_mind;
      x_max = (IGRint) x_maxd;
      y_max = (IGRint) y_maxd;

      /* 2 times the difference in y.  This removes one multiply by 0.5 when computing */
      /* sat1 and sat2 below */
      y_dif2d = (me->color_height - 3.0) * 2.0;
      /* remove a divide from the loop with this hue factor*/
      h_facd = 359.99 / x_difd;

      switch (buff_size)
      {
         case  1:
            /* buffer size is a 1 byte character. (8 planes or less) */
            /* this code has been highly optimized since it is a large */
            /* percentage of total time to draw form */
            
            /* set up buffer_ptr to point to raster buffer */
            buffer_ptr_char = raster_data_ptr->buffer;
            
            for (yd = y_mind, y = y_min; yd <= y_maxd; yd = yd + 1.0, y++)
            {
               /* s = (y_max - y) / (y_max - y_min) */
               s = (y_maxd - yd) / y_dif2d;
               /*since luminance is 0.5 always, s was divided by 2 and we don't have to */
               /*multiply twice by 0.5 below thus eliminating a multiply.*/
               sat1 = 0.5 - s;
               sat2 = 0.5 + s;
               
               for (xd = 0.0, x = x_min; xd <= x_difd; xd += 4.0, x += 4)
               {
                  /* remove a divide from loop by computing the hue factor above and eliminate*/
                  /* a subtraction by making x_mind = 0.*/
                  /* h = 359.99 * (x - x_min) / (x_max - x_min); */
                  h = h_facd * xd;
                  
                  /* removed a check out of INTENSITY macro to make sure it is within the range of*/
                  /* 0 to 359.99.  Here we know that it is within that range and can send in a value*/
                  /* in that range to get the red, green, and blue intensity level.*/
                  if (h < 240.0) 
                  {
                     ri = INTENSITY( sat1, sat2, (h + 120.0) );
                  } 
                  else 
                  {
                     ri = INTENSITY( sat1, sat2, (h - 240.0) );
                  }
                  gi = INTENSITY( sat1, sat2, h );
                  if (h >= 120.0) 
                  {
                     bi = INTENSITY( sat1, sat2, (h - 120.0) );
                  } 
                  else 
                  {
                     bi = INTENSITY( sat1, sat2, (h + 240.0) );
                  }

                  /* find which level of intensity with number of perceived intensities */       
                  ri = (ri * num_intens) >> 8;                                           
                  gi = (gi * num_intens) >> 8;                                           
                  bi = (bi * num_intens) >> 8;                                           

                  /* For efficiency do 4 pixels at a time with the same rgb.  Do the correct
                     number for each row (if not evenly divisable by 4). */
                  switch (x_max - x + 1)
                  {
                     default:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | (x & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_char++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 3:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 1) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_char++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 2:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 2) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_char++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 1:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 3) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_char++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
                  }
               }
            }
            break;
            
         case 2:
            /* buffer size is a 2 byte short. (9 planes) */
            /* this code has been highly optimized since it is a large */
            /* percentage of total time to draw form */
            
            /* set up buffer_ptr to point to raster buffer */
            buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
            
            for (yd = y_mind, y = y_min; yd <= y_maxd; yd = yd + 1.0, y++)
            {
               /* s = (y_max - y) / (y_max - y_min) */
               s = (y_maxd - yd) / y_dif2d;
               /*since luminance is 0.5 always, s was divided by 2 and we don't have to */
               /*multiply twice by 0.5 below thus eliminating a multiply.*/
               sat1 = 0.5 - s;
               sat2 = 0.5 + s;

               for (xd = 0.0, x = x_min; xd <= x_difd; xd += 4.0, x += 4)
               {  
                  /* remove a divide from loop by computing the hue factor above and eliminate*/
                  /* a subtraction by making x_mind = 0.*/
                  /* h = 359.99 * (x - x_min) / (x_max - x_min); */
                  h = h_facd * xd;

                  /* removed a check out of INTENSITY macro to make sure it is within the range of*/
                  /* 0 to 359.99.  Here we know that it is within that range and can send in a value*/
                  /* in that range to get the red, green, and blue intensity level.*/
                  if (h < 240.0) 
                  {
                     ri = INTENSITY( sat1, sat2, (h + 120.0) );
                  } 
                  else 
                  {
                     ri = INTENSITY( sat1, sat2, (h - 240.0) );
                  }
                  gi = INTENSITY( sat1, sat2, h );
                  if (h >= 120.0) 
                  {
                     bi = INTENSITY( sat1, sat2, (h - 120.0) );
                  } 
                  else 
                  {
                     bi = INTENSITY( sat1, sat2, (h + 240.0) );
                  }

                  /* find which level of intensity with number of perceived intensities */       
                  ri = (ri * num_intens) >> 8;                                           
                  gi = (gi * num_intens) >> 8;                                           
                  bi = (bi * num_intens) >> 8;                                           

                  /* For efficiency do 4 pixels at a time with the same rgb.  Do the correct
                     number for each row (if not evenly divisable by 4). */
                  switch (x_max - x + 1)
                  {
                     default:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | (x & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_short++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 3:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 1) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_short++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 2:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 2) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_short++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
      
                     case 1:
                        /* Calculate dither value. */                                      
                        dither_val = dither_mat[((y & 3) << 2) | ((x + 3) & 3)];                 
                                                                            
                        /* Perform dithering to achieve halftones. */                      
                        ri_tmp = (((ri & 15) > dither_val) ? ((ri >> 4) + 1) : (ri >> 4));     
                        gi_tmp = (((gi & 15) > dither_val) ? ((gi >> 4) + 1) : (gi >> 4));     
                        bi_tmp = (((bi & 15) > dither_val) ? ((bi >> 4) + 1) : (bi >> 4));     
                                                                            
                        /* Return vlt color index value which corresponds to calculated */ 
                        /*   9-bit rgb dither value.                                    */ 
                        *(buffer_ptr_short++) = IGErgb_table[(bi_tmp << 6) | (gi_tmp << 3) | ri_tmp] ;      
                  }
               }
            }
            break;
      }
   }
   
   WLhide_cursor( me->lwin_no, TRUE );
   WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );

   /* these are statics for draw_cross_hairs to not have to erase cross hairs */
   old_x = -1;
   old_y = -1;

   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );
   *sts = TRUE;

   return( TRUE );
}

method draw_cross_hairs( long * sts )
{
/*
NAME
   COcctform.draw_cross_hairs
DESCRIPTION
   this draws the cross hairs on the hue X sat block.  It redraws the complete
   block before hand to erase the previous cross hairs.
PARAMETERS
   sts (out) - the status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRint i;
   IGRint x = 0, y = 0, new_x = 0, new_y = 0;
   IGRint x_min,y_min,x_max,y_max;
   IGRint offset = 4,size = 5,half_width = 1; /*width=half_width*2+1*/
   IGRint far_l,far_r,far_u,far_d;
   IGRint near_l,near_r,near_u,near_d;
   IGRint off_l,off_r,off_u,off_d;
   struct WLrect    rect;
   struct WLraster_data *raster_data_ptr;
#if defined ( COMPUTE_CROSS_HAIR_RASTER )
   IGRint ru, rl;
   register IGRchar *buffer_ptr_char;
   register IGRshort *buffer_ptr_short;
   int  buff_size;
   struct IGEcontext_info      IGEcontext_info;  IGEload_context( me->context_no, &IGEcontext_info );
   WLget_raster_size( me->lwin_no, 1, 1, &buff_size);
#endif

   x_min = me->hue_sat_block_x + 2;
   x_max = me->hue_sat_block_x + me->hue_sat_block_width - 1;
   y_min = me->hue_sat_block_y + 2;
   y_max = me->hue_sat_block_y + me->color_height - 1;

   for ( i = 0; i < 2; i++ )
   {
      if ( i==0 )
      {
         /* this is for erasing the previous cross hairs */
         rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
            &me->curr_hue, &me->curr_luminance, &me->curr_saturation );
         /* new_x = ((x_max - x_min) * h / 359.99) + x_min */
         new_x = (IGRint)( (me->hue_sat_block_width - 3) * me->curr_hue / 359.99) + me->hue_sat_block_x + 2;
         /* new_y = y_max - (s * (y_max - y_min)) */
         new_y = me->hue_sat_block_y + me->color_height - 1 - (IGRint)(me->curr_saturation * (me->color_height - 3));
         x = old_x;
         y = old_y;
         if ((old_x == new_x) && (old_y == new_y))
         {
            /* drawing the same value, just return */
            return(TRUE);
         }
         else
         {
            WLhide_cursor( me->lwin_no, TRUE );
         }

         if (old_x == -1)
         {
            /* first time... don't draw raster data (it's undefined) */
            COget_raster_data_struct( CROSS_HAIRS, &raster_data_ptr );
            i=1;
         }
         else
         {
            /* go through twice once to erase and once to draw */
            i=0;
         }
      }
      if ( i==1 )
      {
         /* this is for drawing the new cross hairs */
         x = new_x;
         y = new_y;
         old_x = x;
         old_y = y;
      }
      if ((far_l = x - (offset + size))<x_min) far_l = x_min;
      if ((far_r = x + (offset + size) + 1)>x_max) far_r = x_max;
      if ((far_u = y - (offset + size))<y_min) far_u = y_min;
      if ((far_d = y + (offset + size) + 1)>y_max) far_d = y_max;
      if ((near_l = x - half_width)<x_min) near_l = x_min;
      if ((near_r = x + half_width)>x_max) near_r = x_max;
      if ((near_u = y - half_width)<y_min) near_u = y_min;
      if ((near_d = y + half_width)>y_max) near_d = y_max;
      if ((off_l = x - offset)<x_min) off_l = x_min;
      if ((off_r = x + offset + 1)>x_max) off_r = x_max;
      if ((off_u = y - offset)<y_min) off_u = y_min;
      if ((off_d = y + offset + 1)>y_max) off_d = y_max;
   
      if ( i==0 )
      {
         /* erase the previous cross hair by drawing the block */
         COget_raster_data_struct( CROSS_HAIRS, &raster_data_ptr );
#if defined ( COMPUTE_CROSS_HAIR_RASTER )
         ru = far_u;
         rl = far_l;
         switch (buff_size)
         {
            case 1:
               buffer_ptr_char = raster_data_ptr->buffer;
               for (y = ru; y <= ru + 18; y++)
               {
                  /* s = (y_max - y) / (y_max - y_min) */
                  s = (IGRdouble)(me->hue_sat_block_y + me->color_height - 1 - y) / (IGRdouble)(me->color_height - 3);
                  for (x = rl; x <= rl + 18; x++)
                  {
                     /* h = 359.99 * (x - x_min) / (x_max - x_min); */
                     h = (359.99 * (IGRdouble)(x - (me->hue_sat_block_x + 2)) / (IGRdouble)(me->hue_sat_block_width - 3)) ;
                     *buffer_ptr_char = (IGRchar) HRindex_hls( me->context_no, x, y, me->curr_hue, l, me->curr_saturation );   
                     buffer_ptr_char++;
                  }
               }
               break;
            case 2:
               buffer_ptr_short = (IGRshort *) raster_data_ptr->buffer;
               for (y = ru; y <= ru + 18; y++)
               {
                  /* s = (y_max - y) / (y_max - y_min) */
                  s = (IGRdouble)(me->hue_sat_block_y + me->color_height - 1 - y) / (IGRdouble)(me->color_height - 3);
                  for (x = rl; x <= rl + 18; x++)
                  {
                     /* h = 359.99 * (x - x_min) / (x_max - x_min); */
                     h = (359.99 * (IGRdouble)(x - (me->hue_sat_block_x + 2)) / (IGRdouble)(me->hue_sat_block_width - 3)) ;
                     *buffer_ptr_short = (IGRshort) HRindex_hls( me->context_no, x, y, me->curr_hue, l, me->curr_saturation );   
                     buffer_ptr_short++;
                  }
               }
               break;
         }
         raster_data_ptr->x = rl;
         raster_data_ptr->y = ru;
#endif
         WLput_raster_data( me->lwin_no, me->context_no, raster_data_ptr );
      }
      else
      {
         raster_data_ptr->x = far_l;
         raster_data_ptr->y = far_u;
         WLget_raster_data( me->lwin_no, me->context_no, raster_data_ptr );
         /* draw the cross hairs */
         WLset_active_symbology( me->lwin_no, me->menu_bg, 0, 0, 1, 
            WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
         /* top part */
         rect.x = near_l;
         rect.y = far_u;
         rect.width = near_r - near_l + 1;
         rect.height = off_u - far_u;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );
         /* bottom part */
         rect.x = near_l;
         rect.y = off_d;
         rect.width = near_r - near_l + 1;
         rect.height = far_d - off_d;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );
         /* left part */
         rect.x = far_l;
         rect.y = near_u;
         rect.width = off_l - far_l;
         rect.height = near_d - near_u + 1;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );
         /* right part */
         rect.x = off_r;
         rect.y = near_u;
         rect.width = far_r - off_r;
         rect.height = near_d - near_u + 1;
         WLdraw_rectangle( me->lwin_no, &rect, TRUE );

         WLshow_cursor( me->lwin_no );
         WLflush( me->lwin_no );
      }
   }
   return(TRUE);
}

method draw_lum_ptr( long * sts )
{
/*
NAME
   COcctform.draw_lum_ptr
DESCRIPTION
   this erases the previous ptr and draws a new one
PARAMETERS
   sts (out) - the status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRint x, y, offset = 3,size = 7;
   struct WLrect    rect;
   struct WLpoint points[3];
   
   rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
      &me->curr_hue, &me->curr_luminance, &me->curr_saturation );

   x = me->lum_range_x + me->lum_range_width + offset;
   /* y = y_max - (l * (y_max - y_min)) */
   y = ( (me->lum_range_y + me->color_height - 1) - (IGRint) (me->curr_luminance * (me->color_height - 3)) );

   WLhide_cursor( me->lwin_no, TRUE );
   
   /* erase the pointer */
   WLset_active_symbology( me->lwin_no, me->menu_fg, 0, 0, 1, 
      WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
   rect.x = x;
   rect.y = me->lum_range_y + 2 - size;
   rect.width = size + 1;
   rect.height = me->color_height - 1 + (2 * size);
   WLdraw_rectangle( me->lwin_no, &rect, TRUE );

   WLset_active_symbology( me->lwin_no, me->menu_hl, 0, 0, 1, WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
   points[0].x = x;
   points[0].y = y;
   points[1].x = x + size;
   points[1].y = y - size;
   points[2].x = x + size;
   points[2].y = y + size;
   WLdraw_polygon( me->lwin_no, 3, points, TRUE );
   WLset_active_symbology( me->lwin_no, me->menu_bg, 0, 0, 1, WL_SYMB_CHANGE_COLOR | WL_SYMB_CHANGE_WEIGHT); 
   WLdraw_polygon( me->lwin_no, 3, points, FALSE );

   WLshow_cursor( me->lwin_no );
   WLflush( me->lwin_no );
   return( *sts = TRUE );
}

method map_to_hls(long * sts,x,y)
{
/*
NAME
   COcctform.map_to_hls
DESCRIPTION
   This is used to intercept button presses and act accordingly if areas
   on the form are drawn on.
PARAMETERS
   sts (out) - the status of the method
   x (in) - the x position relative to the form window
   y (in) - the y position relative to the form window
RETURN VALUES
   TRUE = was on one of our drawn objects
   FALSE = was NOT on one of our drawn objects
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/

   IGRint i;
   int    color;
   int   xpos, ypos, color_pos, width, height;
   int   block_x, block_y;
   struct IGEcontext_info      IGEcontext_info;
   IGRboolean  hue_sat_x, hue_sat_y;
   IGRboolean  lum_range_x, lum_range_y;
   IGRboolean  solid_x, solid_y;
   IGRboolean  pallet_x, pallet_y;
   IGRboolean      within_tol;
   IGRint          matched_slot;
   IGRushort redu, greenu, blueu;

   /* set up booleans if within x and y of the area */
   hue_sat_x = (x >= me->hue_sat_block_x + 2) && (x <= me->hue_sat_block_x + me->hue_sat_block_width - 1);
   hue_sat_y = lum_range_y = (y >= me->hue_sat_block_y + 2) && (y <= me->hue_sat_block_y + me->color_height - 1);
   /* add 10 to right of bar so you can grab on to the ptr */
   lum_range_x = (x >= me->lum_range_x + 2) && (x < me->lum_range_x + me->lum_range_width + 10);
   solid_x = (x >= me->solid_color_x) && (x < me->solid_color_x + me->solid_color_width);
   solid_y = (y >= me->solid_color_y) && (y < me->solid_color_y + me->solid_color_height);
   pallet_x = (x >= me->log_col_gad[0].x) && (x < me->log_col_gad[64].x + me->log_col_gad[64].width);
   pallet_y = (y >= me->log_col_gad[0].y) && (y < me->log_col_gad[65].y + me->log_col_gad[65].height);

   if (hue_sat_x && hue_sat_y)
   {
      rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
         &me->curr_hue, &me->curr_luminance, &me->curr_saturation );
      /* h = 359.99 * (x - x_min) / (x_max - x_min); */
      me->curr_hue = ( 359.99 * (IGRdouble)(x - (me->hue_sat_block_x + 2)) / (IGRdouble)(me->hue_sat_block_width - 3)) ;
      /* s = (y_max - y) / (y_max - y_min) */
      me->curr_saturation = (IGRdouble)(me->hue_sat_block_y + me->color_height - 1 - y) / 
         (IGRdouble) (me->color_height - 3);
      rgb_from_hls( &me->curr_red, &me->curr_green, &me->curr_blue, 
         me->curr_hue, me->curr_luminance, me->curr_saturation );
      om$send( msg      = message COcctform.update_active_color_display( sts ),
               targetid = my_id );
      *sts = HUE_SAT_BLOCK;
      return(TRUE);
   }
   else if (lum_range_x && lum_range_y)
   {
      rgb_to_hls( me->curr_red, me->curr_green, me->curr_blue, 
         &me->curr_hue, &me->curr_luminance, &me->curr_saturation );
      /* l = (y_max - y) / (y_max - y_min) */
      me->curr_luminance = (IGRdouble) (me->lum_range_y + me->color_height - 1 - y) / (IGRdouble)(me->color_height - 3);
      rgb_from_hls( &me->curr_red, &me->curr_green, &me->curr_blue, 
         me->curr_hue, me->curr_luminance, me->curr_saturation );
      om$send( msg      = message COcctform.update_active_color_display( sts ),
               targetid = my_id );
      *sts = LUM_RANGE;
      return(TRUE);
   }
   else if (solid_x && solid_y)
   {
      IGEload_context( me->context_no, &IGEcontext_info );
      if ( (IGEcontext_info.using_ramp) && (me->curr_color != 0) && (me->curr_color < me->num_colors - 1))
      {
         if (me->curr_color > IGEcontext_info.num_ramp_colors)
         {
            IGEcalc_best_match((IGRushort)(me->curr_red * 65535.0), (IGRushort)(me->curr_green * 65535.0), 
               (IGRushort)(me->curr_blue * 65535.0), &within_tol, 1.0,
               VLT_RAMP_BASE_COLOR_SLOT, VLT_SPECIAL_AREA_SLOT | VLT_HILITE_SLOT,
               1 << IGEcontext_info.table_depth, &matched_slot);
            for (i = 1; i <= IGEcontext_info.num_ramp_colors; i++)
            {
               /* search through and find which logical color it matched to, give it that value */
               if (IGEcontext_info.bg_log_hl[i].phys_slot == matched_slot)
               {
                  CLunpack_colors( me->modified_ctbl[i], &redu, &greenu, &blueu );
                  me->curr_red = (IGRdouble) ( redu / 65535.0 );
                  me->curr_green = (IGRdouble) ( greenu / 65535.0 );
                  me->curr_blue = (IGRdouble) ( blueu / 65535.0 );
                  /* found it, break out of the loop */
                  i = IGEcontext_info.num_ramp_colors + 1;
               }
            }
         }
      }
      else
      {
         me->curr_red = (IGRdouble) ( 
            ( (IGRint) ( (me->curr_red   * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) ) 
                     / (IGRdouble) (IGEcontext_info.cube_size - 1.0) ) );
         me->curr_green = (IGRdouble) ( 
            ( (IGRint) ( (me->curr_green * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) )  
                     / (IGRdouble) (IGEcontext_info.cube_size - 1.0) ) );
         me->curr_blue = (IGRdouble) ( 
            ( (IGRint) ( (me->curr_blue  * (IGRdouble) (IGEcontext_info.cube_size - 1.0) + 0.5) ) 
                     / (IGRdouble) (IGEcontext_info.cube_size - 1.0) ) );
      }

      om$send( msg      = message COcctform.update_active_color_display( sts ),
               targetid = my_id );
      *sts = SOLID_COLOR;
      return(TRUE);
   }
   else if (pallet_x && pallet_y)
   {
      for ( i = -1; i <= 64; i++ )
      {
         switch ( i )
         {
            case 0:
               /* background */
               color = 0;
               block_x = 0;
               block_y = 8;
               color_pos = 65;
               break;
            case -1:
               /* highlight */
               color = me->num_colors - 1;
               block_x = 4;
               block_y = 8;
               color_pos = 66;
               break;
            default:
               color = i + (me->curr_color_page * 64);
               block_x = (i - 1) % 8;
               block_y = ((i - 1) % 64) / 8;
               color_pos = i;
               break;
         }
         xpos = me->log_col_gad[color_pos].x;
         ypos = me->log_col_gad[color_pos].y;

         width = xpos + me->log_col_gad[color_pos].width - 4;
         height = ypos + me->log_col_gad[color_pos].height - 4;
         if ((x >= xpos) && (x <= width) && (y >= ypos) && (y <= height))
         {
            if ( (color <= me->num_colors - 2) ||
               ( (color == me->num_colors - 1) && (block_y == 8) ) )
            {
               om$send(msg = message COcctform.set_current_color( TRUE, color, TRUE ),
                  targetid = my_id );
               om$send(msg = message COcctform.update_active_color_display( sts ),
                  targetid = my_id );
               *sts = LOGICAL_COLOR;
               return(TRUE);
            }
            else
            {
               /* was in a block area, but on last page and no color in this block area */
               return( *sts = FALSE );
            }
         }
      }
   }
   /* not within any of the areas */
   return( *sts = FALSE );
}

method toggle_compensation ( long * msg )
{
/*
NAME
   COcctform.toggle_compensation
DESCRIPTION
   this toggles the compensation of all contexts and reconfigures there
   color tables
PARAMETERS
   msg (out) - the status of the method
RETURN VALUES
   TRUE = SUCCESS
   FALSE = failure
GLOBALS USED
   none
HISTORY
   01/19/93   Joel D. Underwood
      Mass changes for new IGEcolor2 object for Psuedo-True 
      color scheme
*/
   int sts;
   IGRdouble  gamma[3];

   sts = ige$set_inq_colortable_parameters( inq0_set1 = 0, gamma_correction = gamma);
   if ( gamma[0]!=1.0 || gamma[1]!=1.0 || gamma[2]!=1.0 )
   {
      /* gamma compensation was on now turn off */
      gamma[0]=gamma[1]=gamma[2]=1.0;
   }
   else 
   {
      /* gamma compensation was off now turn on */
      gamma[0]=gamma[1]=gamma[2]=2.2;
   }
   sts = ige$set_inq_colortable_parameters( inq0_set1 = 1, gamma_correction = gamma);

   /* reconfigure all of the contexts */
   sts = ige$configure_color_table( context_no = WL_DEFAULT_CONTEXT );
   
   return( sts );
}

end implementation COcctform;


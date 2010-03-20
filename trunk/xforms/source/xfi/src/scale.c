#include "FImin.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#define FI_MAXSYMBOLS 255
#define FI_MAXSYMBSIZE 255

#define FI_MAX_BITMAP_SIZE 32718

/****************************** replaced JAJ:03/15/91 ***************
#define FI_MAX_BITMAP_SIZE ((int) ((MAX_SCREEN_WIDTH / 2 + 7) / 8 \
 * (MAX_SCREEN_HEIGHT / 2)) + 10) == 32718

I replaced this formula with the actual number, because if EnvironV ever
changes MAX_SCREEN_WIDTH or MAX_SCREEN_HEIGHT, then this number will
change, which will mess up the existing alignment of libforms_s.
 (I actually changed this number temporarily, as an experiment, and
found this out.) -- JAJ/03/06/91
***********************************************************************/

/* local variables */

static char FI_newbitmap[FI_MAX_BITMAP_SIZE];


/****
 X11-5/10/90-Translate the bitmap data into XImage data and draw it to the
 screen
****/

/*********************************************************************
static int _FI_drawbitmap (Window        win,
                           int           xpos,
                           int           ypos,
                           unsigned int  width,
                           unsigned int  height,
                           char         *data)
{
   Pixmap bit_pix;

   if (! width || ! height)
	  return (-1);

   bit_pix = XCreateBitmapFromData (_FI_display, win, data, width, height);

   if (bit_pix != None)
   {
	  XCopyPlane (_FI_display, bit_pix, win, _FI_gc, 0, 0, width, height, xpos, ypos, 0x00000001);
	  XFreePixmap (_FI_display, bit_pix);
   }

  return ( 0 );
}
*********************************************************************/


/****************************************************************/
/* Scale symbol UP in X direction and UP in Y direction. */
/****************************************************************/

void _FI_sym_scale_up_x_up_y (Window                  window_no,
                              struct FIsym_instance  *symbol_ptr,
                              double                  scale_factor_x,
                              double                  scale_factor_y,
                              int                     font_id)
{
   int scale_int_x;
   int scale_int_y;
   double scale_fract;
   char *scale_pattern_x;
   char *scale_pattern_y;
   char *y_pattern_ptr;
   char *x_pattern_ptr;
   int new_bitmap_size;
   unsigned char old_mask;
   char new_mask;
   int old_byte;
   int new_byte;
   int row, col;
   int new_sym_width_addition;
   int new_sym_height_addition;
   int temp;
   int new_width;
   int extra_one;
   char * unscaled_bitmap;
   Pixmap bit_pix;

   unscaled_bitmap = _FI_symbols[font_id].sym_slot[symbol_ptr->sym_index].bitmap;

   /*** If the new symbol will be too large for the ***/
   /*** pre-malloc'ed space that the form system has, then ***/
   /*** find scale factors small enough so that it can be ***/
   /*** drawn. ***/

   for (;;)
   {
	  new_bitmap_size = (int)(((double)symbol_ptr->sym_width * scale_factor_x + 7.0) / 8.0 * (double)symbol_ptr->sym_height * scale_factor_y);
	  new_bitmap_size += new_bitmap_size & 1;

	  if (new_bitmap_size <= FI_MAX_BITMAP_SIZE)
		 break;

	  scale_factor_x -= 0.10;
	  scale_factor_y -= 0.10;
   }

   /*** figure out the scaling patterns ***/
   scale_int_x = scale_factor_x;
   scale_fract = scale_factor_x - scale_int_x;

   _FI_sym_get_pattern (scale_fract, &scale_pattern_x, 0);

   scale_int_y = scale_factor_y;
   scale_fract = scale_factor_y - scale_int_y;

   _FI_sym_get_pattern (scale_fract, &scale_pattern_y, 0);

   /*** clear out the memory for the new symbol ***/
   memset (FI_newbitmap, 0, new_bitmap_size);

   /*** calculate the scaled bitmap for the symbol ***/
   old_mask = 1;
   old_byte = 0;
   new_mask = 1;
   new_byte = 0;
   new_sym_width_addition = 0;
   new_sym_height_addition = 0;
   y_pattern_ptr = scale_pattern_y;

   for (row = 0; row < (int)symbol_ptr->sym_height; row++)
   {
	  x_pattern_ptr = scale_pattern_x;

	  for (col = 0; col < (int)symbol_ptr->sym_width; col++)
	  {
		 if (old_mask == 0)
		 {
			old_mask = 1;
			old_byte++;
		 }

		 if (new_mask == 0)
		 {
			new_mask = 1;
			new_byte++;
		 }

         /*** copy the bit setting ***/
		 if (old_mask & unscaled_bitmap[old_byte])
		 {
			FI_newbitmap[new_byte]|= new_mask;
		 }

         /*** see if this bit needs to be copied an extra ***/
         /*** time in order to fractionally stretch ***/
         /*** the symbol horizontally ***/
		 if (*x_pattern_ptr == '1')
			extra_one = 1;
		 else
			extra_one = 0;

         /*** loop an integer amount of times, copying ***/
         /*** this bit ***/
		 for (temp = 0; temp < scale_int_x - 1 + extra_one; temp++)
		 {
			new_mask <<= 1;

			if (new_mask == 0)
			{
			   new_mask = 1;
			   new_byte++;
			}

			if (old_mask & unscaled_bitmap[old_byte])
			{
			   FI_newbitmap[new_byte]|= new_mask;
			}

            /*** only count the new width once ***/
			if (row == 0)
			   new_sym_width_addition++;
		 }

		 if (! *(++x_pattern_ptr))
			x_pattern_ptr = scale_pattern_x;

		 old_mask <<= 1;
		 new_mask <<= 1;

	  }

	  old_mask = 1;
	  old_byte++;
	  new_mask = 1;
	  new_byte++;

	  new_width = (int)(((int)symbol_ptr->sym_width + new_sym_width_addition + 7) / 8);

      /*** see if this line of bits needs to be copied ***/
      /*** an extra time in order to fractionally ***/
      /*** stretch the symbol vertically ***/
	  if (*y_pattern_ptr == '1')
		 extra_one = 1;
	  else
		 extra_one = 0;

	  for (temp = 0; temp < scale_int_y - 1 + extra_one; temp++)
	  {
		 memcpy (&FI_newbitmap[new_byte], &FI_newbitmap[new_byte - new_width], new_width);

		 new_byte += new_width;

		 new_sym_height_addition++;
	  }

	  if (! *(++y_pattern_ptr))
		 y_pattern_ptr = scale_pattern_y;

   }

   /*** display the new scaled symbol ***/

/*
   xpos += (symbol_ptr->xoff * scale_factor_x) / 2;
   ypos += (symbol_ptr->yoff * scale_factor_y) / 2;

   _FI_drawbitmap (window_no, xpos, ypos, 
         (unsigned int) ((int) symbol_ptr->sym_width + new_sym_width_addition),
         (unsigned int) ((int) symbol_ptr->sym_height + new_sym_height_addition),
         FI_newbitmap);
*/

   {
      int width, height;

      width = (int) ((int)symbol_ptr->sym_width + new_sym_width_addition);
      height =(int) ((int)symbol_ptr->sym_height + new_sym_height_addition);


      if (!width || !height)
         return;
      else
      {
          bit_pix = XCreateBitmapFromData (_FI_display, window_no, FI_newbitmap,
                                           width, height);

          symbol_ptr->pixmap = bit_pix;
      }
   }
}



/****************************************************************/
/* Scale symbol DOWN in X direction and DOWN in Y direction. */
/****************************************************************/
void _FI_sym_scale_down_x_down_y (Window                  window_no,
                                  struct FIsym_instance  *symbol_ptr,
                                  double                  scale_factor_x,
                                  double                  scale_factor_y,
                                  int                     font_id)
{
   char *scale_pattern_x;
   char *scale_pattern_y;
   char *x_pattern_ptr;
   char *y_pattern_ptr;
   int new_height;
   int new_width;
   char counted_new_width;
   unsigned char old_mask;
   char new_mask;
   int old_byte;
   int new_byte;
   int row, col;
   char * unscaled_bitmap;
   Pixmap bit_pix;

   unscaled_bitmap = _FI_symbols[font_id].sym_slot[symbol_ptr->sym_index].bitmap;

   /*** figure out the shrinking patterns ***/
   _FI_sym_get_pattern (scale_factor_x, &scale_pattern_x, 1);
   _FI_sym_get_pattern (scale_factor_y, &scale_pattern_y, 1);

   /* clear out the memory for the new symbol ***/

   memset (FI_newbitmap, 0, FI_MAX_BITMAP_SIZE);

   /******************************** JAJ:03/15/91 *********************
   This will give a memory fault for large symbols!!!!!
   memset (FI_newbitmap, 0,
   (int) symbol_ptr->sym_width * (int) symbol_ptr->sym_height);
   *********************************************************************/

   /*** calculate the scaled bitmap for the symbol ***/

   old_mask = 1;
   old_byte = 0;
   new_mask = 1;
   new_byte = 0;
   new_width = 0;
   new_height = 0;
   y_pattern_ptr = scale_pattern_y;
   counted_new_width = 0;

   for (row = 0; row < (int)symbol_ptr->sym_height; row++)
   {
      /*** only copy this line if it's in the reduction pattern ***/
	  if (*y_pattern_ptr == '1')
	  {
		 new_height++;
	  }

	  x_pattern_ptr = scale_pattern_x;

	  for (col = 0; col < (int)symbol_ptr->sym_width; col++)
	  {
		 if (old_mask == 0)
		 {
			old_mask = 1;
			old_byte++;
		 }

         /*** only copy this bit if it's in the ***/
         /*** reduction pattern ***/

		 if (*y_pattern_ptr == '1' && *x_pattern_ptr == '1')
		 {
            /*** only count this once ***/
			if (! counted_new_width)
			   new_width++;

			if (new_mask == 0)
			{
			   new_mask = 1;
			   new_byte++;
			}

            /*** copy the bit setting ***/
			if (old_mask & unscaled_bitmap[old_byte])
			{
			   FI_newbitmap[new_byte]|= new_mask;
			}

			new_mask <<= 1;
		 }

		 if (! *(++x_pattern_ptr))
			x_pattern_ptr = scale_pattern_x;

		 old_mask <<= 1;
	  }

	  old_mask = 1;
	  old_byte++;

	  if (*y_pattern_ptr == '1')
	  {
		 new_mask = 1;
		 new_byte++;
	  }

	  if (! *(++y_pattern_ptr))
		 y_pattern_ptr = scale_pattern_y;

	  if (new_width)
		 counted_new_width = 1;
   }

   /*** display the new scaled symbol ***/

/*
   xpos -= (symbol_ptr->xoff * scale_factor_x) / 2;
   ypos -= (symbol_ptr->yoff * scale_factor_y) / 2;

   _FI_drawbitmap (window_no, xpos, ypos, new_width, new_height, FI_newbitmap);
*/

   if (!new_width || !new_height)
      return;
   else
   {
       bit_pix = XCreateBitmapFromData (_FI_display, window_no, FI_newbitmap,
                                        new_width, new_height);

       symbol_ptr->pixmap = bit_pix;
   }
}


/****************************************************************/
/* Scale symbol DOWN in X direction and UP in Y direction. */
/****************************************************************/

void _FI_sym_scale_down_x_up_y (Window                  window_no,
                                struct FIsym_instance  *symbol_ptr,
                                double                  scale_factor_x,
                                double                  scale_factor_y,
                                int                     font_id)
{
   int scale_int_y;
   double scale_fract;
   char *scale_pattern_x;
   char *scale_pattern_y;
   char *y_pattern_ptr;
   char *x_pattern_ptr;
   int new_bitmap_size;
   unsigned char old_mask;
   char new_mask;
   int old_byte;
   int new_byte;
   int row, col;
   int new_width;
   int new_width_in_bytes;
   int new_sym_height_addition;
   int temp;
   int extra_one;
   char counted_new_width;
   char * unscaled_bitmap;
   Pixmap bit_pix;

   unscaled_bitmap = _FI_symbols[font_id].sym_slot[symbol_ptr->sym_index].bitmap;


   /*** If the new symbol will be too large for the ***/
   /*** pre-malloc'ed space that the form system has, then ***/
   /*** find scale factors small enough so that it can be ***/
   /*** drawn. ***/

   for (;;)
   {
	  new_bitmap_size = (int)(((double)symbol_ptr->sym_width * scale_factor_x + 7.0) / 8.0 * (double)symbol_ptr->sym_height * scale_factor_y);
	  new_bitmap_size += new_bitmap_size & 1;

	  if (new_bitmap_size <= FI_MAX_BITMAP_SIZE)
		 break;

	  scale_factor_y -= 0.10;
   }

   /*** figure out the scaling patterns ***/
   _FI_sym_get_pattern (scale_factor_x, &scale_pattern_x, 1);

   scale_int_y = scale_factor_y;
   scale_fract = scale_factor_y - scale_int_y;

   _FI_sym_get_pattern (scale_fract, &scale_pattern_y, 0);

   /*** clear out the memory for the new symbol ***/
   memset (FI_newbitmap, 0, new_bitmap_size);

   /*** calculate the scaled bitmap for the symbol ***/
   old_mask = 1;
   old_byte = 0;
   new_mask = 1;
   new_byte = 0;
   new_width = 0;
   new_sym_height_addition = 0;
   counted_new_width = 0;
   y_pattern_ptr = scale_pattern_y;

   for (row = 0; row < (int)symbol_ptr->sym_height; row++)
   {
	  x_pattern_ptr = scale_pattern_x;

	  for (col = 0; col < (int)symbol_ptr->sym_width; col++)
	  {
		 if (old_mask == 0)
		 {
			old_mask = 1;
			old_byte++;
		 }

         /*** only copy this bit if it's in the ***/
         /*** reduction pattern ***/

		 if (*x_pattern_ptr == '1')
		 {
            /*** only count this once ***/
			if (! counted_new_width)
			   new_width++;

			if (new_mask == 0)
			{
			   new_mask = 1;
			   new_byte++;
			}

            /*** copy the bit setting ***/
			if (old_mask & unscaled_bitmap[old_byte])
			{
			   FI_newbitmap[new_byte]|= new_mask;
			}

			new_mask <<= 1;
		 }

		 if (! *(++x_pattern_ptr))
			x_pattern_ptr = scale_pattern_x;

		 old_mask <<= 1;
	  }

	  old_mask = 1;
	  old_byte++;
	  new_mask = 1;
	  new_byte++;

	  if (new_width)
		 counted_new_width = 1;

      /*** see if this line of bits needs to be copied ***/
      /*** an extra time in order to fractionally ***/
      /*** stretch the symbol vertically ***/
	  if (*y_pattern_ptr == '1')
		 extra_one = 1;
	  else
		 extra_one = 0;

	  new_width_in_bytes = (new_width + 7) / 8;

	  for (temp = 0; temp < scale_int_y - 1 + extra_one; temp++)
	  {
		 memcpy (&FI_newbitmap[new_byte], &FI_newbitmap[new_byte - new_width_in_bytes], new_width_in_bytes);

		 new_byte += new_width_in_bytes;

		 new_sym_height_addition++;
	  }

	  if (! *(++y_pattern_ptr))
		 y_pattern_ptr = scale_pattern_y;

   }

   /*** display the new scaled symbol ***/

/*
   xpos -= (symbol_ptr->xoff * scale_factor_x) / 2;
   ypos += (symbol_ptr->yoff * scale_factor_y) / 2;

   _FI_drawbitmap (window_no, xpos, ypos, new_width, 
                   symbol_ptr->sym_height + new_sym_height_addition, 
                   FI_newbitmap);
*/

   if (!new_width || !(symbol_ptr->sym_height + new_sym_height_addition))
      return;
   else
   {
       bit_pix = XCreateBitmapFromData (_FI_display, window_no, FI_newbitmap,
                                        new_width,
                             symbol_ptr->sym_height + new_sym_height_addition); 

       symbol_ptr->pixmap = bit_pix;
   }
}



/****************************************************************/
/* Scale symbol UP in X direction and DOWN in Y direction. */
/****************************************************************/

void _FI_sym_scale_up_x_down_y (Window                  window_no,
                                struct FIsym_instance  *symbol_ptr,
                                double                  scale_factor_x,
                                double                  scale_factor_y,
                                int                     font_id)
{
   int scale_int_x;
   double scale_fract;
   char *scale_pattern_x;
   char *scale_pattern_y;
   char *y_pattern_ptr;
   char *x_pattern_ptr;
   int new_bitmap_size;
   unsigned char old_mask;
   char new_mask;
   int old_byte;
   int new_byte;
   int row, col;
   int new_height;
   int temp;
   int extra_one;
   int new_sym_width_addition;
   char counted_new_sym_width_addition;
   char * unscaled_bitmap;
   Pixmap bit_pix;

   unscaled_bitmap = _FI_symbols[font_id].sym_slot[symbol_ptr->sym_index].bitmap;

   /*** If the new symbol will be too large for the ***/
   /*** pre-malloc'ed space that the form system has, then ***/
   /*** find scale factors small enough so that it can be ***/
   /*** drawn. ***/

   for (;;)
   {
	  new_bitmap_size = (int)(((double)symbol_ptr->sym_width * scale_factor_x + 7.0) / 8.0 * (double)symbol_ptr->sym_height * scale_factor_y);
	  new_bitmap_size += new_bitmap_size & 1;

	  if (new_bitmap_size <= FI_MAX_BITMAP_SIZE)
		 break;

	  scale_factor_x -= 0.10;
   }

   /*** figure out the scaling patterns ***/
   _FI_sym_get_pattern (scale_factor_y, &scale_pattern_y, 1);

   scale_int_x = scale_factor_x;
   scale_fract = scale_factor_x - scale_int_x;

   _FI_sym_get_pattern (scale_fract, &scale_pattern_x, 0);

   /*** clear out the memory for the new symbol ***/
   memset (FI_newbitmap, 0, new_bitmap_size);

   /*** calculate the scaled bitmap for the symbol ***/
   old_mask = 1;
   old_byte = 0;
   new_mask = 1;
   new_byte = 0;
   new_sym_width_addition = 0;
   counted_new_sym_width_addition = 0;
   new_height = 0;
   y_pattern_ptr = scale_pattern_y;

   for (row = 0; row < (int)symbol_ptr->sym_height; row++)
   {
      /*** only copy this line if it's in the reduction pattern ***/
	  if (*y_pattern_ptr == '1')
	  {
		 new_height++;

		 x_pattern_ptr = scale_pattern_x;

		 for (col = 0; col < (int)symbol_ptr->sym_width; col++)
		 {
			if (old_mask == 0)
			{
			   old_mask = 1;
			   old_byte++;
			}

			if (new_mask == 0)
			{
			   new_mask = 1;
			   new_byte++;
			}

            /*** copy the bit setting ***/
			if (old_mask & unscaled_bitmap[old_byte])
			{
			   FI_newbitmap[new_byte]|= new_mask;
			}

            /*** see if this bit needs to be copied an extra ***/
            /*** time in order to fractionally stretch ***/
            /*** the symbol horizontally ***/
			if (*x_pattern_ptr == '1')
			   extra_one = 1;
			else
			   extra_one = 0;

            /*** loop an integer amount of times, copying ***/
            /*** this bit ***/
			for (temp = 0; temp < scale_int_x - 1 + extra_one; temp++)
			{
			   new_mask <<= 1;

			   if (new_mask == 0)
			   {
				  new_mask = 1;
				  new_byte++;
			   }

			   if (old_mask & unscaled_bitmap[old_byte])
			   {
				  FI_newbitmap[new_byte]|= new_mask;
			   }

               /*** only count the new width once ***/
			   if (! counted_new_sym_width_addition)
				  new_sym_width_addition++;
			}

			new_mask <<= 1;

			if (! *(++x_pattern_ptr))
			   x_pattern_ptr = scale_pattern_x;

			old_mask <<= 1;

		 }

		 old_mask = 1;
		 old_byte++;
		 new_mask = 1;
		 new_byte++;

		 if (new_sym_width_addition)
			counted_new_sym_width_addition = 1;

	  }
	  else	/** Advance ptr to original symbol to skip over this row **/
	  {
		 old_byte = old_byte + (int)(((double)symbol_ptr->sym_width + 7.0) / 8.0);
	  }

	  if (! *(++y_pattern_ptr))
		 y_pattern_ptr = scale_pattern_y;
   }

   /*** display the new scaled symbol ***/

/*
   xpos += (symbol_ptr->xoff * scale_factor_x) / 2;
   ypos -= (symbol_ptr->yoff * scale_factor_y) / 2;

   _FI_drawbitmap (window_no, xpos, ypos, 
                   symbol_ptr->sym_width + new_sym_width_addition - 1,
                   new_height - 1, FI_newbitmap);
*/

   if (!(symbol_ptr->sym_width + new_sym_width_addition - 1) || !(new_height - 1))
      return;
   else
   {
       bit_pix = XCreateBitmapFromData (_FI_display, window_no, FI_newbitmap,
                             symbol_ptr->sym_width + new_sym_width_addition - 1,
                             new_height - 1);

       symbol_ptr->pixmap = bit_pix;
   }
}



/****************************************************************/
/* Determine how a symbol is to be shrunk or enlarged, by */
/* indicating which of the pixels on each line of the symbol */
/* are to be duplicated extra times (for enlarging) or left */
/* out (for shrinking).*/
/****************************************************************/
/* int shrinking_flag;	** 1 => shrinking; 0 => enlarging */

void _FI_sym_get_pattern (double   scale_factor,
                          char   **pattern,
                          int      shrinking_flag)
{
   if (scale_factor >= 0.95)
   {
	  *pattern = "11111111110111111111";
   }
   else if (scale_factor >= 0.90)
   {
	  *pattern = "1111101111";
   }
   else if (scale_factor >= 0.85)
   {
	  *pattern = "11110111110111101111";
   }
   else if (scale_factor >= 0.80)
   {
	  *pattern = "11011";
   }
   else if (scale_factor >= 0.75)
   {
	  *pattern = "1101";
   }
   else if (scale_factor >= 0.67)
   {
	  *pattern = "101";
   }
   else if (scale_factor >= 0.6)
   {
	  *pattern = "10101";
   }
   else if (scale_factor >= 0.5)
   {
	  *pattern = "10";
   }
   else if (scale_factor >= 0.4)
   {
	  *pattern = "01010";
   }
   else if (scale_factor >= 0.3333)
   {
	  *pattern = "010";
   }
   else if (scale_factor >= 0.25)
   {
	  *pattern = "0100";
   }
   else if (scale_factor >= 0.20)
   {
	  *pattern = "00100";
   }
   else if (scale_factor >= 0.1666)
   {
	  *pattern = "001000";
   }
   else if (scale_factor >= 0.10)
   {
	  *pattern = "0000010000";
   }
   else if (shrinking_flag)
   {
	  *pattern = "000000010000000";
   }
   else	/* enlarging, but not by really any amount */
   {
	  *pattern = "0";
   }
}


/********************************************************/
/* Load into memory a symbol so that it may be scaled. */
/********************************************************/

int _FI_sym_load (char                   *symbol_file,
                  struct FIgadget_obj    *gadget,
                  struct FIsym_instance  *symbol_ptr)
{
   int fontID;
   int status = 0;
   int index;

   /** X11-5/9/90-KLUDGE-A gadget group does not make any sense **/

   if (gadget->FIgadget.type == FI_GROUP)
   {
	  fprintf (stderr , "_FI_sym_load: Can't load a symbol for a group\n");
	  return (1);
   }

   /** X11-4/23/90-Load in the symbol file **/

   status = _FI_symbol_available (symbol_file, &fontID, FI_data);

   if (fontID == -1)
      return (1);

   /**********************************************/
   /*                                            */
   /* Locate the symbol_data for the symbol file */
   /*                                            */
   /**********************************************/

   index = symbol_ptr->sym_index;

   symbol_ptr->total_width = _FI_symbols[fontID].sym_slot[index].total_width;
   symbol_ptr->total_height = _FI_symbols[fontID].sym_slot[index].total_height;
   symbol_ptr->sym_width = _FI_symbols[fontID].sym_slot[index].sym_width;
   symbol_ptr->sym_height = _FI_symbols[fontID].sym_slot[index].sym_height;
   symbol_ptr->xoff = _FI_symbols[fontID].sym_slot[index].xoff;
   symbol_ptr->yoff = _FI_symbols[fontID].sym_slot[index].yoff;

   return (FI_SUCCESS);
}

/**********************************************/
/* Figure out which scaling function to call. */
/**********************************************/

/* GMD 3/9/92   Added screen parameter */
/* dmb:10/10/92:Change floats to doubles for ANSI */
void _FI_sym_draw (Window                  window_no,
                   int                     xpos,
                   int                     ypos,
                   Font                    font_id,
                   struct FIsym_instance  *symbol_ptr,
                   double                  scale_factor_x,
                   double                  scale_factor_y,
                   int                     screen)
{
   int		index;
   XGCValues	gc_values;


   /* dmb:09/27/91: typecast */
   if (font_id == (Font) -1)  /* Bad Font id */
      return;                                /* GMD 4/9/91  */

   if (_FI_symbols[font_id].sym_slot[symbol_ptr->sym_index].bitmap == 0)
       return;  /* No symbol in slot */


   if ((scale_factor_x < 1.05) && (scale_factor_x > .95) && (scale_factor_y < 1.05) && (scale_factor_y > .95))
   {

      /**********************************************************/
      /*  If no pixmap has been created for this symbol slot,	*/
      /*  then create one now, since it is being demanded.      */
      /**********************************************************/

      index = symbol_ptr->sym_index;

      if ( _FI_symbols[font_id].sym_slot[index].bitmap != 0 )  /* symbol in slot */
      {
         if (_FI_symbols[font_id].sym_slot[index].pixmap[screen] == 0)
            _FI_symbols[font_id].sym_slot[index].pixmap[screen] = 
               XCreateBitmapFromData (_FI_display, window_no,
                                   _FI_symbols[font_id].sym_slot[index].bitmap,
                                   symbol_ptr->sym_width, symbol_ptr->sym_height);

         /*************************************************************/
         /*  No scaling is enabled; use XCopyPlane to draw the pixmap */
         /*************************************************************/

         gc_values.clip_mask = _FI_symbols[font_id].sym_slot[index].pixmap[screen];
         gc_values.clip_x_origin = xpos;
         gc_values.clip_y_origin = ypos;
         XChangeGC (_FI_display, _FI_gc, GCClipXOrigin |
                                         GCClipYOrigin |
                                         GCClipMask, &gc_values);

         XCopyPlane (_FI_display,
			_FI_symbols[font_id].sym_slot[index].pixmap[screen], 
			window_no, _FI_gc, 0, 0,
			symbol_ptr->sym_width, symbol_ptr->sym_height,
			xpos, ypos, (unsigned long) 1 );

	 XSetClipMask (_FI_display, _FI_gc, None);
      }


   }
   	/* If scaled pixmap exists, then display it.  */
  else if ( symbol_ptr->pixmap )
	{
		Window pixmap_root, window_no_root;
		int root_x, root_y;
		unsigned int root_width, root_height, border_width, depth;


        /****************************************************/
        /* sml:10-11-94                                     */
        /*  Get the root window of symbol_ptr->pixmap and   */
        /*  window_no.  If they aren't the same, create a   */
        /*  new symbol_ptr->pixmap for window_no's root     */
        /*  window.  That way the XCopyPlane call will      */
        /*  work correctly.                                 */
        /*                                                  */
        /*  The root windows will be different when the     */
        /*  form is first displayed on one screen and then  */
        /*  on another.                                     */
        /****************************************************/

         XGetGeometry(_FI_display, symbol_ptr->pixmap, 
			&pixmap_root, &root_x, & root_y, &root_width,
			&root_height, &border_width, &depth);

		 window_no_root = RootWindow(_FI_display, screen);

		 if (pixmap_root != window_no_root)
		 {
			index = symbol_ptr->sym_index;


			/***************************************************/
			/* If this pixmap of depth 1 (bitmap) is tied to a */
			/* different screen, blow it away and build        */
			/* another.                                        */
			/***************************************************/

			if (_FI_symbols[font_id].sym_slot[index].pixmap[screen])
			{
			  XFreePixmap(_FI_display,
				_FI_symbols[font_id].sym_slot[index].pixmap[screen]);
			}

            _FI_symbols[font_id].sym_slot[index].pixmap[screen] = 
               XCreateBitmapFromData (_FI_display, window_no,
                 _FI_symbols[font_id].sym_slot[index].bitmap,
                 symbol_ptr->sym_width, symbol_ptr->sym_height);


			/*************************************************/
			/* Free symbol's current pixmap and create a new */
			/* scaled version for this screen/root window.   */
			/*************************************************/

			XFreePixmap(_FI_display, symbol_ptr->pixmap);

			if (scale_factor_x < 1.0 && scale_factor_y < 1.0)
			{
			  _FI_sym_scale_down_x_down_y (window_no,
                                   symbol_ptr, 
                                   (double) scale_factor_x, 
                                   (double) scale_factor_y, font_id);
			}
			else if (scale_factor_x >= 1.0 && scale_factor_y >= 1.0)
			{
			  _FI_sym_scale_up_x_up_y (window_no,
                               symbol_ptr, 
                               (double) scale_factor_x, 
                               (double) scale_factor_y, font_id);
			}
			else if (scale_factor_x < 1.0 && scale_factor_y >= 1.0)
			{
			  _FI_sym_scale_down_x_up_y (window_no,
                                 symbol_ptr, 
                                 (double) scale_factor_x, 
                                 (double) scale_factor_y, font_id);
			}
			else /* if (scale_factor_x >= 1.0 && scale_factor_y < 1.0) */
			{
			  _FI_sym_scale_up_x_down_y (window_no,
                                 symbol_ptr, 
                                 (double) scale_factor_x, 
                                 (double) scale_factor_y, font_id);
			}
		 }

	 gc_values.clip_mask = symbol_ptr->pixmap;
         gc_values.clip_x_origin = xpos;
         gc_values.clip_y_origin = ypos;
         XChangeGC (_FI_display, _FI_gc, GCClipXOrigin |
                                         GCClipYOrigin |
                                         GCClipMask, &gc_values);

         XCopyPlane (_FI_display, symbol_ptr->pixmap, 
                  window_no, _FI_gc, 0, 0,
                  (int)(symbol_ptr->sym_width * scale_factor_x),
                  (int)(symbol_ptr->sym_height * scale_factor_y),
                  xpos, ypos, 1);
	 XSetClipMask (_FI_display, _FI_gc, None);
	}


/*******************************************************************
   else if (scale_factor_x < 1.0 && scale_factor_y < 1.0)
   {
      _FI_sym_scale_down_x_down_y (window_no, plane_mask,
                                   xpos, ypos, symbol_ptr, 
                                   (double) scale_factor_x, 
                                   (double) scale_factor_y, font_id);
   }
   else if (scale_factor_x >= 1.0 && scale_factor_y >= 1.0)
   {
      _FI_sym_scale_up_x_up_y (window_no, plane_mask, 
                               xpos, ypos, symbol_ptr, 
                               (double) scale_factor_x, 
                               (double) scale_factor_y, font_id);
   }
   else if (scale_factor_x < 1.0 && scale_factor_y >= 1.0)
   {
      _FI_sym_scale_down_x_up_y (window_no, plane_mask, 
                                 xpos, ypos, symbol_ptr, 
                                 (double) scale_factor_x, 
                                 (double) scale_factor_y, font_id);
   }
   else	/ * if (scale_factor_x >= 1.0 && scale_factor_y < 1.0) * /
   {
      _FI_sym_scale_up_x_down_y (window_no, plane_mask, 
                                 xpos, ypos, symbol_ptr, 
                                 (double) scale_factor_x, 
                                 (double) scale_factor_y, font_id);
   }
*******************************************************************/

}

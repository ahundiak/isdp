#include "FImin.h"

#include "FItext.h"
#include "FIbtn.h"
#include "FIfield.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern short _FI_widest_wcharacter;
extern char _FI_widest_character;

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

/* GMD -- added code to determine the difference between 16 bit fonts */
/* and 8 bit fonts. Previously 8 bit fonts were being treated */
/* like 16 bit fonts causing characters to be dropped. 2/7/91 */

int _FI_mlt_get_token (unsigned char *text,
                       int           *offset,
                       int           *num_chars,
                       int           font_type)
{
   *offset = 0;
   *num_chars = 0;

   if (*text == (unsigned char) NULL)
   {
      /* NULL STRING */

	  return (1);
   }
   else
   {
      /* Check for a new line at beginning of text */

	  if (*text == RETURN)
	  {
		 (*num_chars) ++;
		 return (0);
	  }
	  else
	  {
         /* non new line - search until
         eoln or new line is found */

		 for (;;)
		 {
            /* CHUNN -- changed for 7/16 bit fonts. 
            12-14-89 */

			if (sbitset(*text) && (font_type == FI_FS_7_OR_16_BIT_FONT_TYPE))
			{
			   text++;
			   (*offset) ++;
			}

			text++;
			(*offset) ++;

			(*num_chars) ++;



            /* if eoln or new line
            break and decrement offset */

			if (*text == (unsigned char) NULL)
			{
			   (*offset) --;
			   break;
			}

			if (*text == RETURN)
			{
			   if (*offset == 0)
			   {
				  (*offset) --;
				  break;
			   }
			   else if (*(text - 1) != '\\')
			   {
				  (*offset) --;
				  break;
			   }
			}
		 }
	  }
   }

   return (0);
}

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

void _FI_mlt_get_lines (unsigned char *text,
                        int           *num_lines,
                        int           *largest_width,
                        int           font_id,
                        int           font_type)
{
   int check_width = *largest_width;
   int width;
   int dummy;

printf("_FI_mlt_get_lines 1\n");


   *num_lines = 0;
   *largest_width = 0;

   if ((! text) || (*text == (unsigned char) NULL))
	  return;
   else
   {
	  int line_check = 0;
	  int offset = 0;
	  int num_chars = 0;
	  int status;

	  for (;;)
	  {
         /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */
         /* GMD -- added font_type support 2/7/91 */

		 status = _FI_mlt_get_token (text, &offset, &num_chars, font_type);
		 if (status)
			break;

		 line_check = 1;

		 if (*text == RETURN)
		 {
			(*num_lines) ++;
		 }
		 else if (check_width)
		 {
            /* Check width of current string */

            /* CHUNN -- changed for 7/16 bit fonts. 
            12-14-89 */

            /* CHUNN NEW FONT */

			FI_calc_text (font_id, (char *)text, num_chars,
              &dummy, &width, &dummy, font_type);

			if (width > *largest_width)
			   *largest_width = width;
		 }

		 text += ++offset;
	  }

	  if (line_check)
		 (*num_lines) ++;

   }
printf("_FI_mlt_get_lines 2\n");

   return;
}

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

static void _FI_g_draw_effect (struct FIgadget_obj *gadget,
                               int                 xlo,
                               int                 ylo,
                               unsigned char       *text,
                               int                 text_length,
                               int                 font_height,
                               int                 font_id,
                               int                 erase_flag)
{
   int dummy;
   Window window = XWINDOW(gadget);
   int lower_color;
   int upper_color;

   if (gadget->FIgadget.effect == FI_EMBOSSED)
   {
	  lower_color = FI_BLACK;
	  upper_color = FI_GLINT;
   }
   else if (gadget->FIgadget.effect == FI_INCISED)
   {
	  lower_color = FI_GLINT;
	  upper_color = FI_BLACK;
   }
   else if (gadget->FIgadget.effect == FI_SHADOWED)
   {
	  lower_color = OFF_COLOR(gadget);
	  upper_color = ON_COLOR(gadget);
   }
  else
   {
	return;	/*** JAJ:08/31/91 ***/
   }

   /* draw the effect */

   if (! erase_flag)
	  XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(gadget) , lower_color));


   /* CHUNN NEW FONT */

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo + FI_EFFECT_WIDTH, ylo, font_height, &dummy, &dummy,
     (int)gadget->FIgadget.font_type);

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo + FI_EFFECT_WIDTH, ylo + FI_EFFECT_WIDTH, font_height,
     &dummy, &dummy, (int)gadget->FIgadget.font_type);

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo, ylo + FI_EFFECT_WIDTH, font_height, &dummy, &dummy,
     (int)gadget->FIgadget.font_type);

   if (! erase_flag)
	  XSetForeground (_FI_display, _FI_gc, FI_translate_color (XSCREEN(gadget) , upper_color));

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo - FI_EFFECT_WIDTH, ylo, font_height, &dummy, &dummy,
     (int)gadget->FIgadget.font_type);

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo - FI_EFFECT_WIDTH, ylo - FI_EFFECT_WIDTH, font_height,
     &dummy, &dummy, (int)gadget->FIgadget.font_type);

   FI_draw_text (window, font_id, (char *)text, text_length,
     xlo, ylo - FI_EFFECT_WIDTH, font_height, &dummy, &dummy,
     (int) gadget->FIgadget.font_type);
}


/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

/* int borders; ** Button and toggle gadgets */
/* int erase_flag; ** if set then dont use fgcolor */

void _FI_g_draw_text (struct FIgadget_obj *gadget,
                      int                 xlo,
                      int                 ylo,
                      int                 xhi,
                      int                 yhi,
                      unsigned char       *text,
                      int                 num_lines,
                      int                 font_height,
                      int                 borders,
                      int                 erase_flag)
{
   int line_height = (num_lines * font_height);

   int center_x = xlo + (xhi - xlo) / 2;
   int center_y = ylo + (yhi - ylo) / 2;
   int new_y = ylo;
   int just = gadget->FIgadget.justification;
   int font_id = gadget->FIgadget.font_id;
   Window window = XWINDOW(gadget);
   int line_space = font_height - (font_height / MLT_DIVISOR);
   int offset = 0;
   int text_length = 0;
   int font_width, dummy, new_x;

	char widest_str[10];

   /* if NULL text pointer or NULL string return */


   if ( !text || (text[0]== (unsigned char) NULL))
     {
	  return;
     }

	/* sml:08-11-92	use widest character as set up in
					FI_define_widest_/w/char() funcs
	*/
	if (gadget->FIgadget.font_type == 2)
 	{
	  widest_str[0] = _FI_widest_wcharacter;
	  widest_str[1] = _FI_widest_wcharacter >> 8;
	  widest_str[2] = '\0';
	  widest_str[3] = '\0';
    }
    else
    {
	  widest_str[0] = _FI_widest_character;
	  widest_str[1] = '\0';
	}
   FI_calc_text (font_id,  /*"M"*/widest_str, 1, &font_height, &font_width, &line_space, gadget->FIgadget.font_type);

   line_height += (int)(line_height * YOFFSET_MULTIPLIER );

   line_space -= (line_space / MLT_DIVISOR);

	/*** If the gadget is a button or toggle then	***/
	/*** set new_y to be center but text use ylo.	***/

   if (borders)
     {
	  new_y = center_y - (line_height / 2);
     }

   /* Loop and draw strings from "text" */

   for (;;)
   {
      /* Get the token and offset to end of token */

      /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */
      /* GMD -- added font_type support 2/7/91 */

	  if (_FI_mlt_get_token (text, &offset, &text_length, gadget->FIgadget.font_type))
	    {
		 break;
	    }

	  if ((text_length == 1) && (*text == RETURN))
	  {
         /* Increment new_y to location of next 
         line in the multi line string */

		 new_y += line_space;
	  }
	  else
	  {
         /* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

		 unsigned char *ptr = text;
		 int ptr_set = 0;

         /* If the string contains a RETURN 
         then change this to "\n" */

		 if (text_length > 2)
		 {
			int x;

			for (x = 0; x != text_length; x++)
			{
			   if ((*ptr == '\\') && (*(ptr + 1) == RETURN))
			   {
				  *ptr = ' ';
				  ptr_set = 1;
				  break;
			   }

			   ptr++;
			}
		 }

         /* Adjust coordinates based on justification */

		 if (just == FI_LEFT_JUSTIFIED)
		 {
			new_x = xlo;

			if (borders)
			   new_x += MLT_SIDE_SPACE;
		 }
		 else if (just == FI_CENTER_JUSTIFIED)
		 {
            /* CHUNN NEW FONT */

			FI_calc_text (font_id, (char *)text, text_length,
              &font_height, &font_width, &dummy,
              (int)gadget->FIgadget.font_type);


			new_x = center_x - (font_width / 2);
		 }
		 else
		 {
            /* CHUNN NEW FONT */

			FI_calc_text (font_id, (char *)text, text_length,
              &font_height, &font_width, &dummy,
              (int) gadget->FIgadget.font_type);

			new_x = xhi - font_width;

			if (borders)
			   new_x -= MLT_SIDE_SPACE;
		 }

         /* Draw the text string normally if effect not
         set of if the gadgets is hilited */

		 if ((! gadget->FIgadget.effect) || (IT_IS_HILITED(gadget)))
		 {
            /* CHUNN NEW FONT */
			FI_draw_text (window, font_id, (char *)text, text_length,
              new_x, new_y, font_height, &dummy, &dummy,
              (int)gadget->FIgadget.font_type);
		 }
		 else
		 {
			_FI_g_draw_effect (gadget, new_x, new_y, text, text_length, font_height, font_id, erase_flag);
		 }

         /* Set the character back to a "\" */

		 if (ptr_set)
			*ptr = '\\';

	  }

      /* Increment text pointer to beginning of next token */

	  text += (offset + 1);
   }
}

/* dmb:10/10/92:Change floats to doubles for ANSI */
void _FI_g_change_text (struct FIgadget_obj *gadget,
                        double               delta_y)
{
   float actual_bodysize;
   int status;
   int dummy;

printf("_FI_g_change_text 1\n");

   /* dmb:10/10/92:Added casts for ANSI */
   gadget->FIgadget.bodysize = (float)((double)gadget->FIgadget.bodysize * delta_y);


   /* load in new font */

   /* CHUNN NEW FONT STUFF */
printf("_FI_g_change_text 2\n");

   status = FI_find_font_id (  gadget->FIgadget.fontname,
			     (double)gadget->FIgadget.bodysize,
			     (Font *)& gadget->FIgadget.font_id,
			     & actual_bodysize, gadget->FIgadget.type,
			     & gadget->FIgadget.font_type );

printf("_FI_g_change_text 3\n");
   if ( status != FI_SUCCESS )
     {
printf("_FI_g_change_text 4 failed\n");
	  return;
     }

   if (! gadget->FIgadget.text)
     {
printf("_FI_g_change_text 5 has null text\n");
	  return;
     }

   /* CHUNN NEW FONT */

   /***************************************************************/
   /*  sml:07-30-93                                               */
   /*    if gadget has no text, give it some dummy text and dummy */
   /*    text length, so you can get a valid height and width     */
   /***************************************************************/
printf("_FI_g_change_text 6\n");

   if ( strcmp((char *)gadget->FIgadget.text, "") == 0)
   {
printf("_FI_g_change_text 6a\n");
     FI_calc_text ( gadget->FIgadget.font_id, 
		"m", 1,
		& gadget->FIgadget.font_height,
		& gadget->FIgadget.font_width,
		& dummy, gadget->FIgadget.font_type);
printf("_FI_g_change_text 6b\n");
   }
   else
   {

	/*****************************************************/
	/* sml:11-02-94 NO TR                                */
	/*  Text on dynamically created gadgets is           */
	/*  sometimes not displayed.                         */
	/*  That happens because gadget->FIgadget.text_length*/
	/*  is not set (at least sometimes) for dynamically  */
	/*  created gadgets.                                 */
	/*****************************************************/

	if (gadget->FIgadget.text_length == 0) /* zero, but text not null */
	{
	  /* set the text length before calculating text params */
	  gadget->FIgadget.text_length = 
		FI_strlen ( (char *)gadget->FIgadget.text,
			gadget->FIgadget.font_type );
	}
printf("_FI_g_change_text 7\n");
     FI_calc_text ( gadget->FIgadget.font_id, 
		(char *)gadget->FIgadget.text, gadget->FIgadget.text_length,
		& gadget->FIgadget.font_height,
		& gadget->FIgadget.font_width,
		& dummy, gadget->FIgadget.font_type);
printf("_FI_g_change_text 8\n");
   }
 printf("_FI_g_change_text 9 done\n");

}




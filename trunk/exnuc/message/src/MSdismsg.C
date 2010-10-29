#include "exsysdep.h"
#include <stdio.h>
#include <stdlib.h>
#include "string.h"

#include "FI.h"

#ifdef ENV5
#include "tools.h"
#include "FIproto_pub.h"
#elif defined(X11)
#include "XFIproto_pub.h"
#elif defined (NT)
#include "shampub.h"
#else
#error Unknown GUI
#endif

#include "igrtypedef.h"
#include "msdef.h"
#include "exms.h"
#include "msmacros.h"
#include "execmsg.h"

#ifndef NT
#ifdef X11
#include "FSX.h"
#include "FSXBmap.h"
#include "FSXOutl.h"
#else
#include "FS.h"
#include "FSBmap.h"
#include "FSOutl.h"
#endif
#include "femacros.h"
#endif
 
#include "exlocale.h"
#include "exlocaledef.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "exmacros.h"
#include "exproto.h"


#ifdef X11
#if defined (CLIX) || defined (IRIX5)
#include <X11/Xlibint.h>
#endif
#include <X11/Xlib.h>
#endif

static Msg_strip_buffer_size = 0;
static int current_msg_line = 0;


#if defined (X11) || defined (NT)
#define MESSAGE_STRIP_HEIGHT 54 /*this is defined in tools.h*/
/* store values statically so they only have to be calculated once */

static int form_x_decor = -1, form_y_decor = -1;
static int form_x_adjustment = -1, form_y_adjustment = -1;

#endif


#define TOP_HORZ_LINE		100
#define MIDDLE_HORZ_LINE	105
#define BOTTOM_HORZ_LINE	102
#define LEFT_VERT_LINE		101
#define MIDDLE_VERT_LINE	104
#define RIGHT_VERT_LINE		103

#define UP_BUTTON      		 17
#define DOWN_BUTTON     	 18
#define INVISIBLE_FIELD 	 19

#define HORIZ_GAP            4   /* How much space to leave on LEFT and  */
                                 /* RIGHT justified text.                */
#define MAX_MESSAGE_BUFFER  15   /* How many messages to buffer in       */
                                 /* msg field 12 before discarding the   */
                                 /* oldest entry.                        */

#define is_sjis(c) (c&128 ? 1 : 0)



#ifdef X11
static Font English_id;
#elif defined(ENV5)
static int English_id;
#elif defined(NT)
static int English_id;
#else
#error Unknown GUI
#endif


static int English_font_type;



static IGRint sixteen_bit_active;
static char status_buffer[128];
static char font_file[15];
static int status_just;
static int need_to_update_status = FALSE;
static int have_form = 0;
static int bk_screen = 0;
static int front_screen = 0;
static int front_white_vlt_slot = 0;
static int front_black_vlt_slot = 0;
static int back_white_vlt_slot = 0;
static int back_black_vlt_slot = 0;
static int back_virtual_screen = 0;
static float bodysize;
extern int EX_batch_mode;
extern int EX_Gf_defmsgfont;
extern Form EX_msg_form;
extern Form EX_msg_form_left;
extern int EX_two_message_strips;
#ifdef X11
extern Display *EXdisplay;
#endif

#if defined( __STDC__ )
int MS_update_msg_strip ( int field_no, int just, char *message )
#else
int MS_update_msg_strip (field_no, just, message)
int field_no;
int just;
char *message;
#endif
{
int	height, width, line_spacing;
int	form_xsize, form_ysize;
int	x_base, y_base, x_top;
int	x_pos, y_pos;
#ifdef X11
Font	font_id;
#elif defined (NT)
int     font_id;
#elif defined(ENV5)
int	window;
int	font_id;
int	SRmode,SRwno,SRno_area,current_vs;
#else
#error Unknown GUI
#endif
int font_type;


int nbytes;

   /****************************************/
   /*                                      */
   /* Calculate width and height of string */
   /*                                      */
   /****************************************/

    font_type = English_font_type;
    font_id = English_id;
    nbytes = strlen(message);
#ifndef NT
    if ( sixteen_bit_active )
     {
     font_type = 2;
     nbytes = (*FI_strlen)(message,font_type);
     }
#endif
#ifdef X11
    if (sixteen_bit_active) /*FI does not work for 16 bit*/
       IGE_calc_text (font_id, message, nbytes , &height, &width,
                  &line_spacing, font_type);
    else
       FI_calc_text (font_id, message, nbytes , &height, &width,
                  &line_spacing, font_type);
#elif defined NT
       FI_calc_text (font_id, message, nbytes , &height, &width,
                  &line_spacing, font_type);
#elif defined(ENV5)
    IGE_calc_text (font_id, message, nbytes , &height, &width,
                  &line_spacing, font_type);
#else
#error Unknown GUI
#endif
   /*************************************/
   /*                                   */
   /* Calculate where to place the text */
   /*                                   */
   /*************************************/

   field_no += 10;

   if ((field_no == 11) || (field_no == 12))
      y_base = 1;
   else
      y_base = 28;

   y_pos = y_base + ((28 - line_spacing) / 2);

   FIf_get_size (EX_msg_form, &form_xsize, &form_ysize);

   if ((field_no == 11) || (field_no == 13))
   {
      x_base = 1;
      x_top = form_xsize / 2;
   }
   else
   {
      x_base = form_xsize / 2;
      x_top = form_xsize;
   }

   if (field_no == 12)   /* Take scroll buttons into account */
      x_top -= 40;

   if (just == FI_LEFT_JUSTIFIED)
     {
      x_pos = x_base + HORIZ_GAP;
     }
   else if (just == FI_CENTER_JUSTIFIED)
     {
      x_pos = x_base + (((x_top - x_base) - width) / 2);
     }
   else if (just == FI_RIGHT_JUSTIFIED)
     {
      x_pos = x_top - width - HORIZ_GAP;
     }
   else
     {
      x_pos = x_base + (((x_top - x_base) - width) / 2);
     }
   if ( (field_no == 11 || field_no == 13) && x_pos < 0 )
     {
     x_pos = 2;
     }

   if ( (field_no == 12 || field_no == 14) && x_pos < (form_xsize/2) )
     {
     x_pos = form_xsize/2 + 2;
     }
   /*******************************************************************/
   /*                                                                 */
   /* Clipboxes are optional.  You should not need them unless a font */
   /* bodysize greater than 30 is requested.                          */
   /*                                                                 */
   /*******************************************************************/


#ifdef ENV5
   FIf_get_window (EX_msg_form, &window);
   clipbox (window, x_base + HORIZ_GAP, y_base, x_top - HORIZ_GAP, y_base + 25);

   Inq_displayed_vs ( &current_vs );
   Inq_SR_active ( &SRmode, &SRwno, &SRno_area );

   if ( current_vs == front_screen )
     {
      if ( SRmode )
       {
         FIg_set_erase_color ( EX_msg_form, field_no,
					10000 + front_black_vlt_slot );
         FIg_set_off_color   ( EX_msg_form, field_no,
					10000 + front_white_vlt_slot );

         }
       else
        {
          FIg_set_erase_color ( EX_msg_form, field_no, FI_BLACK);
          FIg_set_off_color   ( EX_msg_form, field_no, FI_WHITE);
        }
       FIg_activate	( EX_msg_form, field_no );

      }
#endif
   FIg_erase (EX_msg_form, field_no);
   FIg_set_text (EX_msg_form, field_no, message);
   FIg_set_location (EX_msg_form, field_no, x_pos, y_pos);
   FIg_display (EX_msg_form, field_no);
#if defined (X11) || defined (NT)
   if ( field_no == 12 )
    {
    FIg_display(EX_msg_form,DOWN_BUTTON);
    FIg_display(EX_msg_form,UP_BUTTON);
    }
#elif defined(ENV5)
   clipbox (window, 0, 0, form_xsize - 1, form_ysize - 1);
   if (EX_two_message_strips)
    {
     FIf_get_window (EX_msg_form_left, &window);

     clipbox (window, x_base + HORIZ_GAP, y_base,
                               x_top - HORIZ_GAP, y_base + 25);

     if ( back_virtual_screen )
      {
        if ( current_vs == bk_screen )
         {    
   	      if ( SRmode )
	       {
	         FIg_set_erase_color ( EX_msg_form_left, field_no,
						10000 + back_black_vlt_slot );
	         FIg_set_off_color   ( EX_msg_form_left, field_no,
						10000 + back_white_vlt_slot );
	       }
	     else
	      {
	      FIg_set_erase_color ( EX_msg_form_left, field_no, FI_BLACK);
	      FIg_set_off_color   ( EX_msg_form_left, field_no, FI_WHITE);
	      }
	    FIg_activate	( EX_msg_form_left, field_no );
        }
      }

     FIg_erase (EX_msg_form_left, field_no);

     FIg_set_text (EX_msg_form_left, field_no, message);
     FIg_set_location (EX_msg_form_left, field_no, x_pos, y_pos);
     FIg_display (EX_msg_form_left, field_no);
     clipbox (window, 0, 0, form_xsize - 1, form_ysize - 1);
   }
#else
#error Unknown GUI
#endif

  return 1;
}



void MS_store_status(form,message)
Form form;
char *message;
{
int nbytes;

   /******************************************************************/
   /*                                                                */
   /* If the field_no is 12, save the line to the buffer discarding  */
   /* the oldest entry if necessary.                                 */
   /*                                                                */
   /******************************************************************/
    
    nbytes = strlen(message);
    if (nbytes)
     {      
      if (Msg_strip_buffer_size < MAX_MESSAGE_BUFFER)
      {

          FIfld_set_text (form, INVISIBLE_FIELD, 
                         Msg_strip_buffer_size, 0, message, 0);
          Msg_strip_buffer_size++;
          current_msg_line = Msg_strip_buffer_size - 1;
      } 
      else
      {
         /**************************************************/
         /*                                                */
         /* Delete top row.  All others will be shifted up */
         /*                                                */
         /**************************************************/
        
         FIfld_delete_rows (form, INVISIBLE_FIELD, 0, 1);
         FIfld_set_text (form, INVISIBLE_FIELD,
                         MAX_MESSAGE_BUFFER - 1, 0, message, 0);
         current_msg_line = MAX_MESSAGE_BUFFER - 1; 
      }
   }
}


/*--------------------------------------------------------------------------*/

/**************************************************************/
/*                                                            */
/* Notification routine used to process the scroll buttons.   */
/*                                                            */
/**************************************************************/
#argsused
int EX_fi_message_strip (
int form,
int label,
double value,
Form M_form)
{
int dummy;
char t_str[500];

  if (label == UP_BUTTON)
  {
     if (current_msg_line > 0)
     {
        current_msg_line--;
        FIfld_get_text (EX_msg_form, INVISIBLE_FIELD, current_msg_line,
                        0, 200, (unsigned char *)t_str, &dummy, &dummy);
        MS_update_msg_strip (2, FI_CENTER_JUSTIFIED, t_str);
     }
     FIg_set_state_off (M_form, UP_BUTTON);
  }

  if (label == DOWN_BUTTON)
  {
     if (current_msg_line < (Msg_strip_buffer_size - 1))
     {
        current_msg_line++;
        FIfld_get_text (EX_msg_form, INVISIBLE_FIELD, current_msg_line,
                        0, 200, (unsigned char *)t_str, &dummy, &dummy);
        MS_update_msg_strip (2, FI_CENTER_JUSTIFIED, t_str);
     }
     FIg_set_state_off (M_form, DOWN_BUTTON);
  }
  need_to_update_status = TRUE;
return (1);
}
#argsused
int MS_display_message (field, justification, string, MS_msg, delay_time, seconds)
IGRint field;
IGRint justification;
IGRchar *string;
struct MS_sd_msg *MS_msg;
IGRint delay_time;
{

 if ( !EX_batch_mode )
  {
    MS_update_msg_strip(field,justification,string);
    if ( field != 2 )
     {
      if ( need_to_update_status )
       {
       need_to_update_status = FALSE;
       current_msg_line = Msg_strip_buffer_size - 1;
       MS_update_msg_strip(2,status_just,status_buffer);
       }
     }
  else
     {
      strncpy(status_buffer,string,127);
      status_buffer[127] = 0;
      status_just = justification;
      MS_store_status(EX_msg_form,string);
     }
#ifdef ENV5
    if (delay_time == MS_SYSTEM_TIME) {
        Wait_timer (MS_SLEEP_TIME * 60);
    }
    else if (delay_time) {
        Wait_timer (delay_time * 60);
    }
    else if (seconds == MS_SYSTEM_TIME) {
        Wait_timer (MS_SYSTEM_TIME * 60);
    }
    else if (seconds) {
        Wait_timer (seconds);
    }
#endif
  }
return (1);  
}

/*
    This function will download the fonts needed by the message subsystem.
*/
static char local_title[128];
    
MSgetfont()
{

#ifndef NT
    IGRlong msg;
    struct EX_locale_var var_list;
    IGRint number_entries;
    struct EX_fonts *fonts;
    IGRint  ii ;

#endif
    int num_screens;
    float actual_body_size;
    int xdits;
    int status;


#ifdef ENV5
    struct vlt_slot   vlt[4];
    int		vs_no;
    int           num_planes, fixed_vlt_size, num_screen;
#endif
    int intergraph_server;
    int workstation_icon_width;


if ( !EX_batch_mode )
  {
   if ( !have_form )  
   {
   ex$message(msgnumb=EX_P_NoticeTitle,buff = local_title);
   have_form = 1;
   workstation_icon_width = 105;
   intergraph_server = 1; /*intergraph hardware*/
#ifdef X11
   //status = strncmp ( EXdisplay->vendor , "Intergraph" , 10);		//HF:04/04/2001
   status = strncmp ( ServerVendor(EXdisplay) , "Intergraph" , 10);
   if ( status )
      {
       intergraph_server = 0; /*sun hardware*/
       workstation_icon_width = 0;
      }
#endif
   ige$inq_term_info (
                      x_extent = &xdits);

   /*you are interactive create forms*/
   status = FIf_new(100,"EX_msg_strip",EX_fi_message_strip,&EX_msg_form);
   if ( status != FI_SUCCESS )
     {
     printf ( "Could not find form EX_msg_strip\n");
     exit( status);
     }
   FIf_set_resize_on(EX_msg_form);


   ige$inq_term_info ( screen_no = IGE_RIGHT_SCREEN,
                             vs_no = &front_screen);

   FIf_set_screen(EX_msg_form,FI_RIGHT_SCREEN);
   FIg_set_off_color(EX_msg_form,11,FI_WHITE);
   FIg_set_off_color(EX_msg_form,12,FI_WHITE);
   FIg_set_off_color(EX_msg_form,13,FI_WHITE);
   FIg_set_off_color(EX_msg_form,14,FI_WHITE);
   front_white_vlt_slot = FI_translate_color ( front_screen, FI_WHITE );
   front_black_vlt_slot = FI_translate_color ( front_screen, FI_BLACK );
   EX_two_message_strips = FALSE;
   ige$get_num_screens(	num_of_screens = &num_screens );
   if ( num_screens == 2 )
     {
      FIf_new(100,"EX_msg_strip",EX_fi_message_strip,&EX_msg_form_left);
      FIf_set_resize_on(EX_msg_form_left);
      EX_two_message_strips = TRUE;
      ige$get_num_phy_screens(	num_phy_screens = &num_screens );
      if ( num_screens == 2 )
          {
           back_virtual_screen = 0;
           FIf_set_screen(EX_msg_form_left,FI_LEFT_SCREEN);
         }
       else
         {
         /*two virtual*/
         back_virtual_screen = 1;
         ige$inq_term_info ( screen_no = IGE_LEFT_SCREEN,
                             vs_no = &bk_screen);
         FIf_set_screen(EX_msg_form_left,FI_BACK_SCREEN);
         back_white_vlt_slot = FI_translate_color ( bk_screen, FI_WHITE );
         back_black_vlt_slot = FI_translate_color ( bk_screen, FI_BLACK );
         }
      FIg_set_off_color(EX_msg_form_left,11,FI_WHITE);
      FIg_set_off_color(EX_msg_form_left,12,FI_WHITE);
      FIg_set_off_color(EX_msg_form_left,13,FI_WHITE);
      FIg_set_off_color(EX_msg_form_left,14,FI_WHITE);

     }/*end if 2 screens*/
    
     FIf_set_size (EX_msg_form, xdits - workstation_icon_width,
						MESSAGE_STRIP_HEIGHT + 1);
     FIg_set_location (EX_msg_form, MIDDLE_VERT_LINE,
			(xdits - workstation_icon_width) / 2, 0);
     FIg_set_size (EX_msg_form, MIDDLE_HORZ_LINE,
				xdits - workstation_icon_width, 0);
     FIg_set_size (EX_msg_form, TOP_HORZ_LINE,
				xdits - workstation_icon_width, 0);
     FIg_set_size (EX_msg_form, BOTTOM_HORZ_LINE,
				xdits - workstation_icon_width, 0);
#if defined (X11) || defined (NT)
     if ( !intergraph_server )
       {
        int x,y;
        EXget_form_decoration(&x, &y);
        FIf_set_size (EX_msg_form, xdits - 2*x,
						MESSAGE_STRIP_HEIGHT + 1);
        FIg_set_location (EX_msg_form, RIGHT_VERT_LINE,
			xdits - x, 0);
        FIg_set_location (EX_msg_form, MIDDLE_VERT_LINE,
			(xdits - 2*x) / 2, 0);

        FIg_set_location (EX_msg_form, DOWN_BUTTON, xdits - 
                                          32, 2);
        FIg_set_location (EX_msg_form, UP_BUTTON, xdits - 
                            52, 2);
       }
     else
       {
        FIg_set_location (EX_msg_form, RIGHT_VERT_LINE,
			xdits - (workstation_icon_width + 1), 0);

        FIg_set_location (EX_msg_form, DOWN_BUTTON, xdits - 
                                         (workstation_icon_width + 26), 2);
        FIg_set_location (EX_msg_form, UP_BUTTON, xdits - 
                           (workstation_icon_width + 46), 2);

       }

     FIg_set_location (EX_msg_form, BOTTOM_HORZ_LINE,
				       0, 54);
    EXposition_form(EX_msg_form, EX_TOP_EDGE | EX_RIGHT_EDGE );
#elif defined(ENV5)
     FIg_set_location (EX_msg_form, RIGHT_VERT_LINE, xdits -
                                     (workstation_icon_width + 1) , 0);
     FIg_set_location (EX_msg_form, DOWN_BUTTON, xdits - 127, 2);
     FIg_set_location (EX_msg_form, UP_BUTTON, xdits - 147, 2);
#else
#error Unknown GUI
#endif

     if ( EX_two_message_strips)
         {
            FIf_set_size (EX_msg_form_left,
    		xdits - workstation_icon_width , MESSAGE_STRIP_HEIGHT + 1);

            FIg_set_location (EX_msg_form_left, MIDDLE_VERT_LINE,
			(xdits - workstation_icon_width) / 2, 0);
            FIg_set_location (EX_msg_form_left, RIGHT_VERT_LINE,
			xdits - 106, 0);
            FIg_set_size (EX_msg_form_left, MIDDLE_HORZ_LINE,
			xdits - workstation_icon_width, 0);
            FIg_set_size (EX_msg_form_left, TOP_HORZ_LINE,
			xdits - workstation_icon_width, 0);
            FIg_set_size (EX_msg_form_left, BOTTOM_HORZ_LINE,
			xdits - workstation_icon_width, 0);

            FIg_set_location (EX_msg_form_left, DOWN_BUTTON,
						xdits - 127, 2);
            FIg_set_location (EX_msg_form_left, UP_BUTTON,
						xdits - 147, 2);

      }

#ifdef ENV5
  vlt[0].v_slot = 0;
  vlt[0].v_red = 0;
  vlt[0].v_green = 0;
  vlt[0].v_blue = 0;


  vlt[1].v_slot = 7;
  vlt[1].v_red = 0xff00;
  vlt[1].v_green =0xff00 ;
  vlt[1].v_blue = 0xff00;

  vlt[2].v_slot = 13;
  vlt[2].v_red = 0xbb00 ;
  vlt[2].v_green =0xbb00 ;
  vlt[2].v_blue = 0xbb00 ;

  vlt[3].v_slot = 14;
  vlt[3].v_red = 0x8800 ;
  vlt[3].v_green =0x8800 ;
  vlt[3].v_blue = 0x8800 ;

  Inq_displayed_vs(&vs_no);

  ige$inq_term_info(num_of_planes = &num_planes, fixed_vlt_size = &fixed_vlt_size);
  if( !fixed_vlt_size )
  {  
     ige$get_num_screens( num_of_screens = &num_screen);
     ige$inq_term_info( screen_no = IGE_RIGHT_SCREEN,  vs_no = &vs_no);
     Loadvlt( vs_no, vlt, 4 );
     if( num_screen == 2 )
     {
         ige$inq_term_info( screen_no = IGE_LEFT_SCREEN,  vs_no = &vs_no);
         Loadvlt( vs_no, vlt, 4 );
     }         

  }
#endif


    if (EX_two_message_strips)
      {
       FIf_display(EX_msg_form_left);
       FIf_set_resize_off(EX_msg_form_left);
      }
    FIf_display(EX_msg_form);
    FIf_set_resize_off(EX_msg_form);


    }/*end if already have form*/

    sixteen_bit_active = 0;
#ifndef NT    
    if ( !EX_Gf_defmsgfont )
    {
    /*get om param for fast symbol file or FS font*/
    var_list.var = EX_number_alias;
    var_list.var_ptr = (char *)&number_entries;

    ex$inq_locale (msg = &msg,
                   var = &var_list,
                   identifier = "default_message");

    fonts = (struct EX_fonts *) 
                 malloc ((sizeof (struct EX_fonts) * number_entries));

    var_list.var = EX_alias_fonts;
    var_list.var_ptr = (char *)fonts;

    ex$inq_locale (msg = &msg,
                   var = &var_list,
                   flags = EX_Logical_Name | EX_Message,
                   identifier = "default_message");



    for (ii = 0; ii < number_entries; ii++) {
/*
 *	There should be a maximum of two fonts for the message subsystem.
 *	Currently there is an active font for display of 7 bit messages
 *	and an active font, if requested, for 16 bit messages.
 */

        if (fonts[ii].properties & EX_Sixteen_Bit) {

            sixteen_bit_active = 1;

/*
 *	Set these defaults so that when the kanji font is downloded
 *	it can be shared between the text subsystem and the message
 *	subsystem.
 */

#ifdef X11
 
  /******************************************************************
  Xforms requires set font for every gadget that might use 16 bit
  Iforms does not
  ******************************************************************/
         bodysize = fonts[ii].body_size;
         strncpy (font_file,fonts[ii].ff,14);
         font_file[14] = 0;
         FIg_set_font(EX_msg_form,11,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,12,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,13,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,14,fonts[ii].ff,bodysize);
         if (EX_two_message_strips)
          {
           FIg_set_font(EX_msg_form_left,11,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,12,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,13,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,14,fonts[ii].ff,bodysize);

          }
#endif

        }
        else {
         bodysize = fonts[ii].body_size;
         strncpy (font_file,fonts[ii].ff,14);
         font_file[14] = 0;
         FIg_set_font(EX_msg_form,11,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,12,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,13,fonts[ii].ff,bodysize);
         FIg_set_font(EX_msg_form,14,fonts[ii].ff,bodysize);
         if (EX_two_message_strips)
          {
           FIg_set_font(EX_msg_form_left,11,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,12,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,13,fonts[ii].ff,bodysize);
           FIg_set_font(EX_msg_form_left,14,fonts[ii].ff,bodysize);

          }
#ifdef X11
        FI_find_font_id(fonts[ii].ff,bodysize,&English_id,
                                      &actual_body_size,FI_TEXT,
                                      &English_font_type);
#elif defined(ENV5)
        IGE_find_font_id(fonts[ii].ff,bodysize,&English_id,
                                      &actual_body_size,FI_TEXT,
                                      &English_font_type);
#else
#error Unknown GUI
#endif
        }

        }
    if (fonts) {
        free (fonts);
    }
   }/*end if EX_Gf_defmsgfont*/
  else
   {
#endif    
         bodysize = (float)18.;
         FIg_set_font(EX_msg_form,11,"swiss742",bodysize);
         FIg_set_font(EX_msg_form,12,"swiss742",bodysize);
         FIg_set_font(EX_msg_form,13,"swiss742",bodysize);
         FIg_set_font(EX_msg_form,14,"swiss742",bodysize);
#ifndef NT         
         if (EX_two_message_strips)
          {
           FIg_set_font(EX_msg_form_left,11,"swiss742",bodysize);
           FIg_set_font(EX_msg_form_left,12,"swiss742",bodysize);
           FIg_set_font(EX_msg_form_left,13,"swiss742",bodysize);
           FIg_set_font(EX_msg_form_left,14,"swiss742",bodysize);

          }
#endif
#if defined (X11) || defined (NT)
        FI_find_font_id("swiss742",bodysize,&English_id,
                                      &actual_body_size,FI_TEXT,
                                      &English_font_type);
#elif defined(ENV5)
        IGE_find_font_id("swiss742",bodysize,&English_id,
                                      &actual_body_size,FI_TEXT,
                                      &English_font_type);
#else
#error Unknown GUI
#endif
#ifndef NT
   }
#endif   
  
  }/*end if batch mode*/
  return(1);
}
/*

	NAME
	EX_error_box - display an error message in a save/restore box
				with title

	SYNOPSIS
	EX_error_box(screen_no,msg,title)
	int	screen_no;
	char	*msg;
	char	*title;

*/


#argsused
#if defined( __STDC__ )
int EX_error_box ( int	screen_no, char	*msg, char *title )
#else
int EX_error_box (screen_no,msg,title)
int	screen_no;
char	*msg;
char	*title;
#endif
{
   char *c, *m;
   char font[15], *p_font;
   double bodys;

  if ( ex$is_batch())
   {
   fprintf(stderr,"%s","-------------BATCH MODE ERROR BOX----------------------------------------\n");
   fprintf(stderr,"%s\n",msg);
   fprintf(stderr,"%s","-------------------------------------------------------------------------\n");

   }
  else
   {      
     /* replace "\n" strings with '\n' character */
        m = msg;
        while (c = strstr(m, "\\n")) /* must use \\ to signify a single \ */
        {
            *c = ' ';
            *(++c) = '\n';
            m = ++c;
        }

        if (sixteen_bit_active)
        {
            strncpy(font,font_file,14);
            font[14] = 0;
            p_font = font;
            bodys = bodysize;
        }
        else
        {
            p_font = "swiss742b";
            bodys = 24.0;
        }

        FI_message_box2 (FI_CURRENT_SCREEN, -1, -1, title , FI_BLACK,
                         p_font, bodys, msg, FI_BLACK, p_font, bodys,
                         FI_CENTER_JUSTIFIED, 40);
   }

  return 1;
}

/*--------------------------------------------------------------------*/


/*this code is to be used if EX_err_box is ready to be called*/
#argsused
#if defined( __STDC__ )
int MSerrbox ( IGRint field, IGRint justification, IGRchar *message,
               struct MS_sd_msg *MS_msg )
#else
int MSerrbox (field, justification, message, MS_msg)
IGRint field;
IGRint justification;
IGRchar *message;
struct MS_sd_msg *MS_msg;
#endif
{
  EX_error_box (FI_CURRENT_SCREEN,MS_msg->out_msg,local_title);
  return(1);
}



#if defined( __STDC__ )
int MS_paint_area( void )
#else
int MS_paint_area()
#endif
{
#ifdef ENV5
  if ( back_virtual_screen )
    {
     FIf_paint_area(EX_msg_form_left,0,0,MAX_SCREEN_WIDTH,55);
     FIf_paint_area(EX_msg_form,0,0,MAX_SCREEN_WIDTH,55);
    }
#endif

  return 1;
}

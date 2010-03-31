#ifndef FIfld_included
#define FIfld_included 1


#include "FIgadget.h"
#include "FIscroll.h"
#include "FIbtn.h"

#define CHAR_LT_SYM 			'\036'
#define CHAR_RT_SYM 			'\037'
#define FIELD_BEZEL			2
#define ROLL_THROUGH_SYM_WIDTH		15

#define sbitset(c) 			( (c) & 128 ? 1 : 0 )

extern void _FI_fld_add_to_line();		/** In field.c	   **/
extern void _FI_fld_add_hscrl();		/** In field.c	   **/
extern void _FI_fld_add_vscrl();		/** In field.c	   **/
extern void _FI_fld_change_text();		/** In field.c	   **/
extern int  _FI_fld_display();			/** In field.c	   **/
extern void _FI_fld_draw_bezel();		/** In field.c	   **/
extern void _FI_fld_draw_sym_area();		/** In field.c	   **/
extern void _FI_fld_refresh_data();		/** In field.c	   **/
extern void _FI_fld_set_buffer();		/** In field.c	   **/
extern void _FI_fld_set_defaults();		/** In field.c	   **/
extern void _FI_fld_set_erase_color();		/** In field.c     **/
extern void _FI_fld_set_vscrl();		/** In field.c	   **/

extern void _FI_fld_adjust_row_col();		/** In field2.c    **/
extern void _FI_fld_draw_cursor();		/** In field2.c    **/
extern void _FI_fld_get_xy();			/** In field2.c    **/
extern void _FI_fld_justify_data();		/** In field2.c    **/
extern void _FI_fld_refresh_row();		/** In field2.c    **/
extern void _FI_fld_select_row();		/** In field2.c    **/
extern void _FI_fld_un_select_row();		/** In field2.c    **/
extern void _FI_fld_process_displayed_list();	/** In field2.c    **/

extern int  _FI_strlen16();			/** In field3.c    **/
extern int  _FI_locate_16char_start_byte();	/** In field3.c    **/

extern int  _FI_fld_add_CR();			/** In fieldAdd.c  **/
extern void _FI_fld_insert_str();		/** In fieldAdd.c  **/
extern void _FI_fld_shift_buffer_down();	/** In fieldAdd.c  **/

extern int  _FI_fld_back_space();		/** In fieldDel.c  **/
extern void _FI_fld_delete_char();		/** In fieldDel.c  **/
extern void _FI_fld_delete_eol();		/** In fieldDel.c  **/
extern void _FI_fld_delete_line();		/** In fieldDel.c  **/
extern void _FI_fld_erase_to_eol();		/** In fieldDel.c  **/
extern void _FI_fld_set_kill_buffer();		/** In fieldDel.c  **/
extern void _FI_fld_shift_buffer_up();		/** In fieldDel.c  **/
extern int  _FI_fld_undelete();		/** In fieldDel.c  **/

extern int  _FI_fld_back();			/** In fieldMove.c **/
extern void _FI_fld_bol();			/** In fieldMove.c **/
extern int  _FI_fld_eol();			/** In fieldMove.c **/
extern int  _FI_fld_forward();			/** In fieldMove.c **/
extern int  _FI_fld_next();			/** In fieldMove.c **/
extern int  _FI_fld_previous();		/** In fieldMove.c **/

extern void _FI_fld_scrl_back();		/** In fieldScrl.c **/
extern void _FI_fld_scrl_forward();		/** In fieldScrl.c **/
extern void _FI_fld_scrl_next();		/** In fieldScrl.c **/
extern void _FI_fld_scrl_previous();		/** In fieldScrl.c **/

extern void _FI_fld_track_hscrl();		/** In fieldTrack.c **/
extern int  _FI_fld_track_keyboard();		/** In fieldTrack.c **/
extern int  _FI_fld_track_keyboard2();		/** In fieldTrack.c **/
extern int  _FI_fld_track_kbd();		/** In fieldTrack.c **/
extern int  _FI_fld_track_mouse();		/** In fieldTrack.c **/

extern void _FI_fld_add_word_to_start_of_line();  /** In fieldWrap.c **/
extern void _FI_fld_calc_remaining_space();	  /** In fieldWrap.c **/
extern void _FI_fld_get_first_word_of_line();	  /** In fieldWrap.c **/
extern void _FI_fld_refresh_wrap_data();	  /** In fieldWrap.c **/
extern void _FI_fld_remove_first_word_from_line();/** In fieldWrap.c **/
extern void _FI_fld_remove_last_word_from_line(); /** In fieldWrap.c **/
extern void _FI_fld_reshuffle_down();		  /** In fieldWrap.c **/
extern void _FI_fld_reshuffle_up();		  /** In fieldWrap.c **/


struct FI_fld_flags
{
  unsigned int uds :1;	  	/* up/down scrolling		*/
  unsigned int lrs :1;	  	/* left/right scrolling		*/
  unsigned int roll_thru :1;	/* roll through			*/
  unsigned int wrap :1;	  	/* wrap if doesn't fit display	*/
  unsigned int draw_vscrl :1;	/* draw vert scroll bar		*/
  unsigned int draw_hscrl :1;	/* draw hort scroll bar		*/
  unsigned int clear :1;	/* clear on selection		*/
  unsigned int no_echo :1;	/* no echo			*/
  unsigned int by_line :1;	/* notify line by line		*/
  unsigned int ascii_only :1;	/* restrict to ascii input	*/
  unsigned int is_a_list :1;	/* this IS the list		*/
  unsigned int popup_list :1;	/* list is NOT always displayed	*/
  unsigned int dismiss :1;	/* dismiss list on selection	*/
  unsigned int valid_list :1;	/* validate with list		*/
  unsigned int is_a_col :1;	/* this IS part of mcf		*/
  unsigned int required:1;	/* required field		*/

/* Hebrew 30-07-90 */
  unsigned int right_to_left:1; /* Hebrew language direction flag */
/* Hebrew 8/6/90 */
  unsigned int reverse_input:1;
  unsigned int reverse_output:1;
};


struct FI_buf_st
{
  unsigned char *line;
  short		 sel;
  char		 broken_word;
  char		 paragraph;
  int	 	 color;
};


struct FIfield_instance
{
  short	field_type;
  short	mode;

  short	ar;			/* currently active row		*/
  short	ac;			/* currently active character in row */

  short	nr;			/* max # of rows - 0 infinite	*/
  short	nvr;			/* # of visible rows		*/

  short	roff;			/* row display offset		*/
  short	nc;			/* max # of chars - 0 infinite	*/

  short	nvc;			/* # of visible chars		*/
  short	coff;			/* char display offset		*/

  short	buffer_size;		/* # of rows of actual data	*/
  short	default_size;		/* # of default rows of data	*/

  int	line_height;		/* ht of each line including spacing */

  int (*validation)();		/* user defined validate func	*/
  int (*format)();		/* user defined format func	*/

  double min;			/* minimum value		*/
  double max;			/* maximum value		*/

  char  *fmt;			/* format specification		*/

  struct FI_buf_st *buffer;	/* actual data			*/
  struct FI_buf_st *defaults;	/* default data			*/

  struct FIfld_obj  *list_id;	/* associated list obj ptr	*/
  struct FIscrl_obj *vscrl_id;  /* vertical scroll bar obj ptr	*/
  struct FIbtn_obj  **hscrl;    /* horizontal scroll btns	*/

  struct FI_fld_flags flags;	/* field flags			*/

  int		alloc_size;

  short		prev_sel;	/* previously selected row index */
};



struct FIfld_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIfield_instance	FIfield;
};


#endif

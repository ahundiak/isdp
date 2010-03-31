#ifndef FIgadget_included
#define FIgadget_included 1


#include "FIrange.h"
#include "FIform.h"


struct FIsym_instance
{
  unsigned char total_width;	/* total width of symbol	*/
  unsigned char	total_height;	/* total height of symbol	*/

  unsigned char	xoff;	    /* x offset of real symbol from start pnt */
  unsigned char	yoff;	    /* y offset of real symbol from start pnt */

  unsigned char	sym_height;	/* height of symbol itself */
  unsigned char	sym_width; 	/* width  of symbol itself */

  unsigned char	orig_font_height; /* original height of symbol itself */
  unsigned char	orig_font_width;  /* original  width of symbol itself */

  char * bitmap; 		/* definition of symbol pixel pattern */

  unsigned char	sym_index;	/* index of symbol into symbol file   */
};


struct FIgadget_instance
{
  unsigned 	char  type;

  char 	displayed;

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int	label;    	/* user-assigned gadget label */

  float xlo;		/* upper left  x-position of gadget */
  float ylo;		/* upper left  y-position of gadget */
  float xhi;		/* lower right x-position of gadget */
  float yhi;		/* lower right y-position of gadget */

  float orig_xsize;	/* original width  - used for scaling icons */
  float orig_ysize;	/* original height - used for scaling icons */

  int		font_id;

  int		font_width;
  int		font_height;

  int		on_font_width;
  int		on_font_height;

  int 	 	text_length;

  int    	attr_mask;
  int    	default_attr_mask;

  double  	value;
  double  	default_value;

  float 	bodysize;
  float		sym_width_scale_factor;
  float		sym_height_scale_factor;

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int		next_in_seq;

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int		prev_in_seq;

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

  unsigned    char 	*text;

  char 		*help_topic;
  char	 	*command;
  char  	*fontname;

  char		*user_pointer;
  char		*menu_user_pointer;  /* Used by the menu interface MI */

  int	 	erase_color;
  int 		off_color;
  int		on_color;
  int		off_color2;
  int 	 	on_color2;

  unsigned char effect;
  unsigned char justification;

	/*** Changed from short to int--JAJ:09/28/90 ***/
  int		pass_label;

  unsigned int	num_lines;       /* num_lines in text string */
  unsigned int	largest_width;   /* largest width in string   */

  struct 	FIgroup_obj * group;
  struct 	FIform_obj  * form;

	/*** Changed from array to single struct -- JAJ:06/12/91 ***/
  struct	FIsym_instance symbol_ptr;
  struct 	FIsym_instance on_symbol_ptr;

  int		font_type;
};


struct FIgroup_instance
{
  unsigned short   size;  /* How many slots currently allocated	   */

  char	dont_pass_on;  	  /* flag: 0 => DO pass on all functions   */
			  /*   	      to gadgets in the group	   */
			  /*      1 => DON'T pass on all functions */
			  /*   	     to gadgets in the group	   */

  char	single_select;    /* flag: Group keeps only one member active */

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int	current_active_gadget;

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int	last_active_gadget;

  struct FIgadget_obj	**gadgets;	/* Ptrs to gadgets in group */

  unsigned short begin_slot;    	/* Start looking for next */
			        	/* available slot here    */
};


struct FIgroup_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIgroup_instance	FIgroup;
};


struct FIgadget_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIrange_instance	FIrange;  /* Slider & Dial common */
};


#endif

#ifndef FIform_included
#define FIform_included		1

#include "FI.h"
#include "FIgadget.h"

#define	FI_WITHDRAWN	0x40000000

/*
#define FORM_BEZEL_WIDTH	4

    Had to change this because of Jeff's changes to box size.
              GMD 4/3/91
*/

#define FORM_BEZEL_WIDTH	5

/*** JAJ:02/12/92 - incremented form version to 6, for new      ***/
/***                meaning of "screen."                        ***/

#define FI_CURRENT_FORM_VERSION    6



struct  FIh_data
{
  Form   parentForm;	 /* Parent form pointer    		*/
  Form  *childForm;	 /* Array of child form pointers	*/
  int    childCount;	 /* Number of child forms		*/
  int    childAlloc;	 /* Child array allocated length	*/
  int ( *replyFunc )();  /* Process data from children		*/
};


struct FIform_obj
{
  int		(*initial_notification_routine)();
  int		(*intercept_routine)();
  int		(*notification_routine)();
  int		(*window_event_routine)();
  int		(*window_icon_routine)();
  int		(*button_event_routine)();

  int		attr_mask;

  long		plane_mask;

  int		form_label;

  int		level;

  int		creation_date;

  short		orig_xlo;
  short		orig_ylo;

  short		orig_xsize;
  short		orig_ysize;

  short		min_xsize;
  short		min_ysize;

  short		max_xsize;
  short		max_ysize;

  short		xlo;
  short		ylo;
  short		xhi;
  short		yhi;

  short		screen_width; /* Size of screen form first defined on */
  short		screen_height;

  short		collapse_icon_xpos;
  short		collapse_icon_ypos;    

  unsigned char	bgcolor;
  unsigned char	collapse_icon_index;

  char		collapse_pos_not_set;

  char		activated;

  char		screen;    /* This is one of the following:      */
                       /*   FI_CURRENT_SCRN                  */
                       /*   FI_DEFAULT_SCRN                  */
                       /*   FI_HARDCODED_SCRN                */

  char		initial_creation;  /* Used to determine if need to    */
				   /*   store current screen size in  */
			           /*   form instance.                */
  short		seq_off;
    
  char		* collapse_icon_file;
  char		* name;
  char		* user_pointer;

  char		* menu_user_pointer;   /* Used by menu subsystem to   */
				       /* determine types of menus MS */

  struct FIh_data *child_node;         /* Used for hierarchical code */

  char		* person;	       /* Node name and user name. */

  struct FIgroup_obj * group;

  char		 ** description;

  Window	Xwindow;	/* X11-4/13/90-New window definition   */
  int		Xscreen;	/*	       New screen definition       */
                        /* This is the actual X-screen # that  */
                        /* the for's window occupies.          */

  GC		Xgc;		/* Graphics context		      */
  GC		Xgc_text;   /* Graphics context for text  */

  char		builder_mode;

  char		adjusted_size;

  int		seq_label;	/* Gadget to begin sequencing after */
				/* form is displayed.		    */

  short		num_desc;

  unsigned short cmd_os;    /* "Object space number" of the EXNUC     */
			    /*  command object controlling the form.  */
  unsigned int   cmd_oid;   /* "Object id" of the EXNUC		      */
			    /*  command object controlling the form.  */

  int   begin_label;		/* Label to begin search for	      */
				/* next available gadget label.       */
  int   begin_neg_label;

  int	displayed;
  int initial_form_display;
};



#endif

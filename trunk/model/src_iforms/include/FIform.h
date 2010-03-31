#ifndef FIform_included
#define FIform_included	1


#include "FI.h"
#include "FIgadget.h"

#define FORM_BEZEL_WIDTH         4

#define FI_CURRENT_FORM_VERSION		5



struct FIform_obj
{
  int  (*initial_notification_routine)();
  int  (*intercept_routine)();
  int  (*notification_routine)();
  int  (*window_event_routine)();
  int  (*window_icon_routine)();
  int  (*button_event_routine)();

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

  char		screen;

  char		initial_creation;  /* Used to determine if need to   */
    				   /*   store current screen size in */
				   /*   form instance 		    */
  short 	seq_off;
    
  char        * collapse_icon_file;
  char        * name;
  char	      * user_pointer;

  char	      * menu_user_pointer; /* Used by menu subsystem to   */
				   /* determine types of menus MS */

  struct FIh_data *child_node;	/* Used for hierarchical code */

  char	      * person;		/* machine node name and user */

  struct FIgroup_obj * group;

  char	     ** description;

  char		win_no;
  char 	    	vs_no;

  char		builder_mode;

  /*** char	adjusted_size;	*** >>> MAC: NOT USED NOW <<<  ***/

		/*** Changed from short to int--JAJ:09/28/90 ***/
  int		seq_label;	/* Gadget to begin seq after */
				/* form is displayed */

  short		num_desc;

  unsigned short cmd_os;    /* Osnum of IGE cmd obj controlling form */
  unsigned int   cmd_oid;   /* Objid of IGE cmd obj controlling form */

  int		begin_label;	/* Label to begin search for	*/
				/* next available gadget label	*/
  int		begin_neg_label;

					  /*** JAJ:11/14/90 ***/
  struct vlt_slot *	SR_vlt;		  /*** Form's SR vlt array ***/
					  /*** Defaults to 0       ***/
  int			num_SR_vlt_slots;
  int			num_SR_vlt_allocated_slots;

};



struct	FIh_data
{
  struct FIform_obj *  parentForm;  /* Parent form pointer	      */
  struct FIform_obj ** childForm;   /* Array of child form pointers   */
  int	 childCount;		    /* Number of child forms	      */
  int	 childAlloc;		    /* Child array allocated length   */
  void	( *replyFunc )();	    /* Process data from children     */
};


#endif

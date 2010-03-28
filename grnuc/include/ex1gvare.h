/*  ex1gvare.h
 *
 *  This file contains the externed declarations of the 
 *  global variables declared by ex1gvar.h.  Any file
 *  needing to reference the globals may include this
 *  file as long as FI.h, FIdyn.h, and ex1.h have been
 *  include first.  This file does not check for its
 *  dependancies.  For more information on these variables
 *  see ex1gvar.h.
 */
/*
extern Form wall_design;
extern int wall_window;
extern int wall_created;
extern int wall_displayed;

extern Form acc_design;
extern int acc_window;
extern int acc_created;

extern struct wall_info wall;

extern Gadget material_field;
extern Gadget material_group;
extern Gadget supplier_field;
extern Gadget supplier_group;
extern Gadget action_group;
extern Gadget lock_group;
extern Gadget door_group;
extern Gadget window_group;

extern char key_buf[];



extern int design_mode;
extern struct styles door_styles[MAX_DOOR_STYLES];
extern int door_style;
extern struct styles window_styles[MAX_WINDOW_STYLES];
extern int window_style;
*/
struct standard_st std_var;

extern struct vlt_slot vlt[];



extern int exit_flag;
extern char 
	unix_info[5], 
	uom_info[5], 
	window_info[5], 
	sview_info[5], 	
	drawsheet_info[5],
	element_info[5], 
	zero_info[5], 
	text_info[5], 
	font_info[5], 
	screen_mode[5], 
	verbose_mode[5], 

	batch_command[128], 
	design_file_name[128], 
	output_file[128], 
	app_name[80];

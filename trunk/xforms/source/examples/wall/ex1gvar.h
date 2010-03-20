/*  ex1gvar.h
 *
 *  This file contains all the global variables
 *  form the ex1 application.  This file is included
 *  by main.c and may not be included by any other
 *  file.  To reference the globals, include the
 *  file ex1gvare.h which contains the same variables
 *  only declared externally.
 */

/*
 *  Global variables and flags for the wall design form.
 */
Form wall_design;
int wall_window;
int wall_created;
int wall_displayed;

/*
 *  Global variables for the accessories design form.
 */
Form acc_design;
int acc_window;
int acc_created = FALSE;

/*
 *  This is the structure (defined in ex1.h) which we
 *  will use to store all the parameters for our wall
 *  and will update each time a gadgets value changes.
 */
struct wall_info wall = {
  "my wall", 25.0, 8.0, 0, 0, 0, 0, 1,
  {
  "supplier 1",
  "supplier 2",
  "supplier 3",
  "supplier 4",
  "supplier 5"
  }
};

/*
 *  Some gadget variables for a few gadgets and groups
 *  which will be defined dynamically.
 */
Gadget material_field;
Gadget material_group;
Gadget supplier_field;
Gadget supplier_group;
Gadget action_group;
Gadget lock_group;
Gadget door_group;
Gadget window_group;

/*
 *  This buffer will hold keyboard data, though we
 *  aren't doing anything with it.
 */
char key_buf[256];

/*
 *  This is the global exit flag.  When this flag
 *  goes to TRUE, main will exit its loop.
 */
int exit_flag = FALSE;

/*
 *  This is the current design mode.  It may be
 *  DESIGN_DOOR or DESIGN_WINDOW.
 */
int design_mode = DESIGN_DOOR;

/*
 *  This array defines the door styles.  It contains
 *  a description or title string along with the
 *  index of the symbol representing that style.  This
 *  array will be cycled trough by the user pressing
 *  the right and left style buttons when in door
 *  design mode.
 */
struct styles door_styles[MAX_DOOR_STYLES] = {
  { "door style 1", 9 },
  { "double style 1", 10 },
  { "door style 2", 11 },
  { "double style 2", 12 },
  { "door style 3", 13 },
  { "double style 3", 14 },
  { "door style 4", 15 },
  { "double style 4", 16 },
  { "door style 5", 17 },
  { "double style 5", 18 } };

/*
 *  This is the current door style.
 */
int door_style = 0;
  
/*
 *  This array defines the window styles.  It contains
 *  a description or title string along with the
 *  index of the symbol representing that style.  This
 *  array will be cycled trough by the user pressing
 *  the right and left style buttons when in window
 *  design mode.
 */
struct styles window_styles[MAX_WINDOW_STYLES] = {
  { "window style 1", 19 },
  { "window style 2", 20 },
  { "window style 3", 21 },
  { "window style 4", 22 },
  { "window style 5", 23 } };

/*
 *  This is the current window style.
 */
int window_style = 0;

/*
 *  Define a standard variables structures and set some default values.
 *  In case we don't get around to setting every field (when dynamically
 *  defining gadgets), we won't have crazy values in it.
 */
struct standard_st std_var =
{
  0,                 /* upper left  x-position of gadget                 */
  0,                 /* upper left  y-position of gadget                 */
  100,               /* lower right x-position of gadget                 */
  100,               /* lower right y-position of gadget                 */
  FI_TEXT_GADGET,    /* sets the attr_mask and the default_attr_mask     */
  0.0,               /* sets the value/state and the default value/state */
  15.0,              /* bodysize of the font                             */
  NULL,              /* text string to be displayed                      */
  NULL,              /* Help topic to set                                */
  NULL,              /* Command on queue                                 */
  NULL,              /* Name of font                                     */
  NULL,              /* User pointer                                     */
  FI_BLACK,          /* off color                                        */
  FI_BLACK,          /* on color                                         */
  FI_BLACK,          /* off color 2                                      */
  FI_BLACK,          /* on color 2                                       */
  0,                  /* symbol index                                     */
  0,		     /* Future						 */
  0 		     /* Next in sequence				 */
};


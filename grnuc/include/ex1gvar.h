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
 *  Define a standard variables structures and set some default values.
 *  In case we don't get around to setting every field (when dynamically
 *  defining gadgets), we won't have crazy values in it.
 */
#ifndef NT
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
  0,                 /* symbol index                                     */
  0,		     /* Future						 */
  0 		     /* Next in sequence				 */
};
#else
struct standard_st std_var =
{
  0.0,               /* sets the value/state and the default value/state */
  15.0,              /* bodysize of the font                             */
  FI_TEXT_GADGET,    /* sets the attr_mask and the default_attr_mask     */
  0, 		     /* Next in sequence				 */
  NULL,              /* text string to be displayed                      */
  NULL,              /* Help topic to set                                */
  NULL,              /* Command on queue                                 */
  NULL,              /* Name of font                                     */
  NULL,              /* User pointer                                     */
  FI_BLACK,          /* off color                                        */
  FI_BLACK,          /* on color                                         */
  FI_BLACK,          /* off color 2                                      */
  FI_BLACK,          /* on color 2                                       */
  0,                 /* upper left  x-position of gadget                 */
  0,                 /* upper left  y-position of gadget                 */
  100,               /* lower right x-position of gadget                 */
  100,               /* lower right y-position of gadget                 */
  0,                 /* symbol index                                     */
  0		     /* Future						 */
};
#endif

/*
 *  We must set our own vlt up so we know in which positions
 *  the colors needed by the Forms System reside.  The Forms
 *  System requests an index into this table for a particular
 *  by calling our routine FEI_translate_color which merely
 *  passes back the correct index.
 */
struct vlt_slot vlt[] = {	{ 0,      0,      0,      0 },	
				{ 1, 0xEE00, 0xEE00, 0xEE00 },
				{ 2, 0x8800, 0x8800, 0x8800 },
				{ 3, 0x0000, 0x0000, 0x0000 },
				{ 4, 0xFF00, 0xFF00, 0x0000 },
				{ 5, 0xA000, 0xA000, 0xA000 },
				{ 6, 0x5500, 0x5500, 0x5500 },
				{ 7, 0xFF00, 0xFF00, 0xFF00 },
				{ 8, 0xFF00, 0x0000, 0x0000 },
				{ 9, 0x0000, 0xFF00, 0x0000 },
				{ 10, 0x0000, 0x0000, 0xFF00 },
				{ 11, 0xFF00, 0xFF00, 0xBB00 },
				{ 12, 0xDD00, 0x0000, 0x0000 },
				{ 13, 0x0000, 0xBB00, 0x0000 },
				{ 14, 0x0000, 0x0000, 0xCC00 }
			};




char	unix_info[5], 
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

/*  ex2gvar.h
 *
 *  This file contains all the global variables
 *  form the ex2 application.  This file is included
 *  by main.c and may not be included by any other
 *  file.  To reference the globals, include the
 *  file ex2gvare.h which contains the same variables
 *  only declared externally.
 */
 
/*
 *  Variable for our form and flags to indicate whether
 *  the form has been created or not and whether it is
 *  displayed or not.
 */

Form ex2_form;
char form_created = 0;
char form_displayed = 0;

/*
 *  Gadget variables for all of our dynamically created gadgets.
 */
Gadget field_gadget;
Gadget check_gadget;
Gadget text_gadget;
Gadget sym_gadget;
Gadget button_gadget;
Gadget toggle_gadget;
Gadget dial_gadget;
Gadget slider_gadget;
Gadget line_gadget;
Gadget bezel_gadget;
Gadget gauge_gadget;
Gadget mcf_gadget;
Gadget scroll_gadget;
Gadget gadget_group;

/*
 *  These are flags which indicate whether the gadget
 *  has been defined or not.  We will use this to
 *  make sure we don't try to create them twice.
 */
int field_defined = FALSE;
int check_defined = FALSE;
int text_defined = FALSE;
int sym_defined = FALSE;
int button_defined = FALSE;
int toggle_defined = FALSE;
int dial_defined = FALSE;
int slider_defined = FALSE;
int line_defined = FALSE;
int bezel_defined = FALSE;
int gauge_defined = FALSE;
int mcf_defined = FALSE;
int scroll_defined = FALSE;
int cbar_defined = FALSE;

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
  NULL,              /* text string                                      */
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


/*
 *  This buffer will hold keyboard data, though we
 *  aren't doing anything with it.
 */
char key_buf[256];

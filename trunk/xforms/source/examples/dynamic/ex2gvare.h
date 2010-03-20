/*  ex2gvare.h
 *
 *  This file contains the externed declarations of the 
 *  global variables declared by ex2gvar.h.  Any file
 *  needing to reference the globals may include this
 *  file as long as FI.h, FIdyn.h, and ex2.h have been
 *  include first.  This file does not check for its
 *  dependancies.  For more information on these variables
 *  see ex2gvar.h.
 */
extern char form_created;
extern char form_displayed;
extern Form ex2_form;

extern Gadget field_gadget;
extern Gadget check_gadget;
extern Gadget text_gadget;
extern Gadget sym_gadget;
extern Gadget button_gadget;
extern Gadget toggle_gadget;
extern Gadget dial_gadget;
extern Gadget slider_gadget;
extern Gadget line_gadget;
extern Gadget bezel_gadget;
extern Gadget gauge_gadget;
extern Gadget mcf_gadget;
extern Gadget scroll_gadget;
extern Gadget gadget_group;

extern int field_defined;
extern int check_defined;
extern int text_defined;
extern int sym_defined;
extern int button_defined;
extern int toggle_defined;
extern int dial_defined;
extern int slider_defined;
extern int line_defined;
extern int bezel_defined;
extern int gauge_defined;
extern int mcf_defined;
extern int scroll_defined;
extern int cbar_defined;

extern struct standard_st std_var;


/*

Name
  FIdirform.S

Description
 This is the spec file for the class of the 
 directory commnad form.

Notes


 */

class specification FIdirform (1:0) of CEO;

#include "OMminimum.h"
#include "DItypedef.h"
#include "DIdef.h"

/*
 *  Gadgets for the DIrectory command form
 */
#define EXIT_BUTTON             1
#define WINDOW_BUTTON           5
#define HELP_BUTTON             6
#define BOTTOM_LINE_FIELD      10
#define CURRENT_DIR_TITLE      12
#define DASH_BUTTON            13
#define DIR_WINDOW             14
#define CD_BUTTON              15
#define SORT_TOGGLE            16
#define EVENT_BUTTON           18
#define RMDIR_BUTTON           19
#define MKDIR_BUTTON           22
#define EDIT_FIELD             14
#define ADD_BUTTON             17
#define CURRENT_DIR_FIELD      25
#define START_DIR_FIELD        27
#define START_DIR_TITLE        28
#define DELETE_BUTTON          29
#define INITIAL_VALUES_BUTTON  30
#define PICK_EXPRESSION_BUTTON 32
#define REPORT_BUTTON          34
#define INNER_WINDOW           35

/*
 * Gadgets for the pop-up form (mkdir, rmdir and report)
 */
#define TITLE                 11
#define NAME_FIELD            20
#define PROMPT                12

struct FormPackInfo
{
    int  count;
    char title   [DI_PATH_MAX],
	 command [DI_PATH_MAX],
	 **list;
};

instance FIdirform
{
    struct FormPackInfo info;
    int                 last_icon	/* last icon that was poked	  */;
};


message update ();
message do_form ( long *msg; int form_label; int gadget_label; double value );
message set_gadgets ();
message init_form ();

end specification FIdirform;

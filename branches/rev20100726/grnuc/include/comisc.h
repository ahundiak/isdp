/*
Abstract 
        This file contains #defines that are needed by command objects.

Dependencies
        exnuc/include/exdef.h

History
        11/16/89  scw  created
        10/25/91  mrm  added definitions for aligning forms
        10/08/92  mrm  changed GRposition_form definitions to refer to EXNUC
                       versions
        08/11/93  mrm  added form type masks
        08/25/93  mrm  added menu path info stuff
        11/24/93  mrm  added delay button masks
*/

#ifndef comisc_include
#define comisc_include 1

#include "exdef.h"

/* definitions used by COnpt.display_active_parms action */

#define CO_STATUS_FORM  0x00000001
#define CO_ACTIVE_ANGLE 0x00000002
#define CO_APPARENT     0x00000004
#define CO_ABSOLUTE     0x00000008
#define CO_CLOCKWISE    0x00000010
#define CO_XH_SP_ANG    0x00000020
#define CO_ACTIVE_CELL  0x00000040
#define CO_COORD_TYPE   0x00000080
#define CO_COORD_NAME   0x00000100

/*
        These definitions are used with the function GRposition_form,
        which is used to align a form along one or two edges of the
        screen.

        Note: the GRposition_form function has been replaced by an EXNUC
        version, EXposition_form, which was cloned from the original.
        GRposition_form and the following definitions remain to prevent
        application impact.  GRposition_form now simply calls EXposition_form.
*/

#define TOP_EDGE        EX_TOP_EDGE
#define RIGHT_EDGE      EX_RIGHT_EDGE
#define BOTTOM_EDGE     EX_BOTTOM_EDGE
#define LEFT_EDGE       EX_LEFT_EDGE

/*
 * For command object forms referenced in COnpt's form_init method. 
 * 1 = Generate Matrix of Points
 * 2 = Generate Polar Array of Points
 * 3 = Associative Copy
 * [Shelley Heard 01/11/92]
 */
#define  GR_GenMtrxPts      (1)
#define  GR_GenPolarPts     (2)
#define  GR_AutoConstr      (3)  /* not used by GRNUC; for EMS overrides */

/*
 * The following masks define what constraints should be automaticaly placed.
 * They are only used in MODEL but they are referenced in dummy methods in
 * several GRNUC wireframe commands which are overridden at the MODEL level.
 * (Shelley Heard 01/11/92)
 */
#define SK_AUTO_HORIZONTAL 0x001
#define SK_AUTO_PARALLEL   0x002
#define SK_AUTO_TANGENT    0x004
#define SK_AUTO_NORMAL     0x008
#define SK_AUTO_EQUALITY   0x010
#define SK_AUTO_GROUND     0x020
#define SK_AUTO_SINGLE     0x040
#define SK_AUTO_ANGULAR    0x080
#define SK_AUTO_LASTONE    0x100
#define SK_AUTO_GEOMETRIC  (SK_AUTO_HORIZONTAL | SK_AUTO_PARALLEL | SK_AUTO_TANGENT | \
                            SK_AUTO_NORMAL | SK_AUTO_EQUALITY)
/*
 *  Masks used for suppressing non-applicable constraints on wireframe elements
 *  The bits set are those that do NOT apply to the given class.
 */
#define SK_SUPPRESS_NOTHING (0)

#define SK_SUPPRESS_POINT   ( SK_AUTO_HORIZONTAL | \
                             SK_AUTO_PARALLEL    | \
                             SK_AUTO_TANGENT     | \
                             SK_AUTO_NORMAL      | \
                             SK_AUTO_EQUALITY    | \
                             SK_AUTO_SINGLE      | \
                             SK_AUTO_ANGULAR )

#define SK_SUPPRESS_LINE    (SK_AUTO_PARALLEL    | \
			     SK_AUTO_TANGENT     | \
		             SK_AUTO_EQUALITY    | \
                             SK_AUTO_SINGLE      | \
                             SK_AUTO_ANGULAR )

#define SK_SUPPRESS_ARC     (SK_AUTO_HORIZONTAL | \
			     SK_AUTO_PARALLEL   | \
			     SK_AUTO_NORMAL     | \
			     SK_AUTO_EQUALITY   | \
                             SK_AUTO_SINGLE     | \
                             SK_AUTO_ANGULAR )

#define SK_SUPPRESS_CIRCLE   SK_SUPPRESS_ARC

/*
   These definitions are used in GRmonkey_with_forms to specify which forms
   should be sent to the callback.
*/

#define GR_FI_FORM_TYPE                    0x00000001
#define GR_FI_BAR_MENU_TYPE                0x00000002
#define GR_FI_PANEL_MENU_TYPE              0x00000004
#define GR_FI_POCKET_MENU_TYPE             0x00000008
#define GR_FI_TEAR_OFF_BAR_MENU_TYPE       0x00000010
#define GR_FI_TEAR_OFF_PANEL_MENU_TYPE     0x00000020
#define GR_NON_DISPLAYED_FORMS             0x00000040

/*
   The following definitions and structures are used in conjunction with
   GRfind_menu_paths to obtain information about the menu path to a command.
*/

#define MAX_BUTTON_DEPTH        6
#define MAX_MENU_PATHS          16
#define CMDKEY_LEN              16
#define SYMBOL_FILE_LEN         16

typedef struct
{
    char symbol_file[SYMBOL_FILE_LEN];
    int off_symbol, on_symbol;
}   GRmenu_button_info;

typedef struct
{
    int nbuttons;
    int is_duplicate;
    int has_duplicate;
    char task[CMDKEY_LEN];
    GRmenu_button_info button[MAX_BUTTON_DEPTH];
}   GRbutton_path;

typedef struct
{
    char cmdkey[CMDKEY_LEN];
    int npaths;
    GRbutton_path path[MAX_MENU_PATHS];
}   GRmenu_path_info;

/*
   These definitions are used as arguments to GRdelay_button to color the
   Update Associative Element button on the menu bar to reflect the status of
   the batch queue.
*/

#define GR_DELAY_UNKNOWN        -1
#define GR_DELAY_OFF            0
#define GR_DELAY_ON             1
#define GR_DELAY_PENDING        2
#define GR_DELAY_UPDATE         3

#endif

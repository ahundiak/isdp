/***************************************************************************

  This header file contains the command key definitions that are
  stored in the PANEL_MENU and BAR_MENU.

  The "standard" convention for building command keys is as follows:

    The command key can be no longer than 10 characters in total
    length.

    The first two characters denote the product, e.g., "NF".  This
    guarantees uniqueness with other workstation products.

    The verb and each significant noun in the command string is
    abbreviated with the first letter capitalized and all other
    letters are lower-case.

    Each key MUST be unique within the product.

  NOTE:  It is important to note that the use of command keys is
         supported in various software systems in generating
         documentation and on-line help.  Any changes to the command
         key definitions in either the PANEL_MENU or BAR_MENU outline
         files MUST be reflected in this header file AND the appropriate
         person(s) generating documentation and building the help files
         be notified.

****************************************************************************/

#define WFF_M_LOGIN_TO_ENVIRONMENT               "NFWfLgIn"
#define WFF_M_LOGOUT_FROM_ENVIRONMENT            "NFWfLgOut"
#define WFF_M_DEFINE_CLIENT_DEBUG_MODE           "NFDfClDbMd"
#define WFF_M_DEFINE_SERVER_DEBUG_MODE           "NFDfSrDbMd"
#define WFF_M_DISPLAY_LIST_OF_WORKFLOWS          "NFDsLsWkFl"
#define WFF_M_DISPLAY_LIST_OF_ACLS               "NFDsWkACLs"
#define WFF_M_DISPLAY_LIST_OF_CLASSES            "NFDsLsCls"
#define WFF_M_DISPLAY_LIST_OF_STATES             "NFDsLsSt"
#define WFF_M_DISPLAY_LIST_OF_TRANSITIONS        "NFDsLsTrns"
#define WFF_M_DISPLAY_LIST_OF_CLASS_ACCESS       "NFDsLsClAc"
#define WFF_M_REVIEW_WFLOW                       "NFRvWkFw"
#define WFF_M_ADD_WORKFLOW                       "NFAddWf"
#define WFF_M_LOAD_WORKFLOW                      "NFLdWkfw"
#define WFF_M_DELETE_WORKFLOW                    "NFDelWf"
#define WFF_M_CHANGE_WORKFLOW                    "NFChgWf"
#define WFF_M_ADD_COMMANDS                       "NFAddCmds"
#define WFF_M_DELETE_COMMANDS                    "NFDelCmds"
#define WFF_M_DISPLAY_LIST_OF_COMMANDS           "NFDsLsCmds"
#define WFF_M_DUMP_WORKFLOW                      "NFDumpWf"

/*  Commands that are selected only from the persistent form.
    These need not be only 10 characters long as they are
    not stored in either outline file.                         */

#define WFF_M_DISPLAY_WORKFLOWS_SHORT            "NFDsLsWFS"
#define WFF_M_DISPLAY_CLASSES_SHORT              "NFDsLsClS"

/*  Commands that exist only on the BAR_MENU  */

#define WFF_M_HELP                               "NFHlp"
#define WFF_M_EXIT                               "NFExt"

/*  Commands that have been recently added  */


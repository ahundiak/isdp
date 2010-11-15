/* Do not alter this SPC information: $Revision: 1.1.29.1 $ */
/********************************************************************
Name:				gcodbg.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Debug Gui Functions

Revision History:

********************************************************************/
#include <windows.h>
#include "resource.h"

/* debug control panel constants */

/* default dialog box definitions */
#define DEF_BUTTON	(BS_DEFPUSHBUTTON|WS_TABSTOP|WS_CHILD)

/* standard dialog box definitions */
#define STD_FRAME		(SS_BLACKFRAME|WS_CHILD)
#define STD_CHECKBOX	(BS_CHECKBOX|WS_TABSTOP|WS_CHILD)
#define STD_BUTTON		(BS_PUSHBUTTON|WS_TABSTOP|WS_CHILD)
#define STD_RADIO		(BS_RADIOBUTTON|WS_TABSTOP|WS_CHILD)
#define STD_EDITFIELD	(WS_BORDER|WS_TABSTOP|WS_CHILD|ES_AUTOHSCROLL)


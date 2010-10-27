/* $Id: VDCmdDirFrm.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / VDCmdDirFrm.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDirFrm.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * Define for command object Display Directory Command.
 * 
 * 03/10/94 adz 	The version of this command in I/EMS 2.2 has been
 *			made private for I/VDS.
 */
#ifndef VDCmdDirFrm_include

#define VDCmdDirFrm_include

#define EXIT_BUTTON            1
#define WINDOW_BUTTON          5
#define HELP_BUTTON            6
#define BOTTOM_LINE_FIELD     10
#define CURRENT_DIR_TITLE     12
#define DASH_BUTTON           13
#define CD_BUTTON             15
#define MKDIR_BUTTON          16
#define RMDIR_BUTTON          17
#define EVENT_BUTTON          18
#define DOTDOT_BUTTON         19
#define REMOVE_BUTTON         20
#define RENAME_BUTTON         21
#define HILIGHT_BUTTON        22
#define EDIT_FIELD_TITLE      23
#define CURRENT_DIR_FIELD     25
#define EDIT_FIELD            26
#define REGULAR_EXP_FIELD     27
#define START_DIR_FIELD       27
#define START_DIR_TITLE       28
#define SLIDER_BAR            33
#define REPORT_BUTTON         34
#define INNER_WINDOW          35

struct FormPackInfo
{
    int  count;
    char title   [DI_PATH_MAX],
	 command [DI_PATH_MAX],
	 **list;
};


#endif


/* Do not alter this SPC information: $Revision: 1.5.27.1 $ */
/*
**	NAME:							xevent.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <X11/Xlib.h>
#include "gui.h"
#include "riscom.h"
#include "risver.h"
#include "risprods.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define xevent_c
#include "comdebug.prt"
#include "comgtdir.prt"
#include "compath.prt"
#include "fi_xwin.prt"
#include "guierror.prt"
#include "sys.prt"
#include "xevent.prt"
#include "xwin.prt"

/*
**	VARIABLES
*/
Display *RISdisplay;
static int	ris_development;
static char ris_dir[256] = "";
#if defined(sun) || defined(__Sol2__) || defined(Soli)
static char *xterm_location = "/usr/openwin/bin/xterm";
#elif defined(unix)
static char *xterm_location = "/usr/bin/X11/xterm";
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_event_loop(
	int (* form_displayed)())
{
    unsigned int trans = 0;
    XEvent event;

	GUI_DBG(("RISgui_event_loop()\n"));

	if (!form_displayed)
	{
		GUI_DBG(("RISgui_event_loop:no function pointer: returning\n"));
		return;
	}

	while(form_displayed())
	{
    	XNextEvent(RISdisplay, &event);
    	FI_process_event(&event, trans);
	}

	GUI_DBG(("RISgui_event_loop:returning\n"));
}

/******************************************************************************/

extern void RISgui_hourglass_cursor(
	Form fp)
{
	GUI_DBG(("RISgui_hourglass_cursor(fp:0x%x)\n", fp));
	GUI_DBG(("RISgui_hourglass_cursor:returning\n"));
}

/******************************************************************************/

extern void RISgui_default_cursor(
	Form fp)
{
	GUI_DBG(("RISgui_default_cursor(fp:0x%x)\n",fp));
	GUI_DBG(("RISgui_default_cursor:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_ris()
{
	int					sts;
	static char			path[258] = "";

	GUI_DBG(("RISgui_start_ris()\n"));

	if (!path[0])
	{
		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(path, ris_dir, ris_development, "risutl",
			"xrisgui");

		strcat(path, " &");
	}
	system(path);

	GUI_DBG(("RISgui_start_ris:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_rismgr()
{
	int					sts;
	static char			path[258] = "";

	GUI_DBG(("RISgui_start_rismgr()\n"));

	if (!path[0])
	{
		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(path, ris_dir, ris_development, "risutl",
			"xrismgr");

		strcat(path, " &");
	}
	system(path);

	GUI_DBG(("RISgui_start_rismgr:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_rislod()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_rislod()\n"));

	if (!cmd[0])
	{
		ptr = cmd;

		ptr += sprintf(ptr, "%s -T \"RIS Loader\" -e ", xterm_location);
		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}

		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"rislod");

		strcat(cmd, " &");
	}
	system(cmd);
	GUI_DBG(("RISgui_start_rislod:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risunlod()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risunlod()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Unloader\" -e ", xterm_location);

		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risunlod");

		strcat(cmd, " &");
	}

	system(cmd);
	GUI_DBG(("RISgui_start_risunlod:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risrecrd()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risrecrd()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Record\" -e ", xterm_location);

		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risrecrd");

		strcat(cmd, " &");
	}

	system(cmd);

	GUI_DBG(("RISgui_start_risrecrd:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risplbck()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risplbck()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Playback\" -e ", xterm_location);

		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risplbck");

		strcat(cmd, " &");
	}

	system(cmd);
	GUI_DBG(("RISgui_start_risplbck:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risclnsr()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risclnsr()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Clean Server\" -e ", xterm_location);

		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risclnsr");

		strcat(cmd, " &");
	}

	system(cmd);

	GUI_DBG(("RISgui_start_risclnsr:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risdcode()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risdcode()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Decode\" -e ", xterm_location);
		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risdcode");

		strcat(cmd, " &");
	}

	system(cmd);
	GUI_DBG(("RISgui_start_risdcode:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risdtype()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";

	GUI_DBG(("RISgui_start_risdtype()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
		ptr += sprintf(ptr, "%s -T \"RIS Data Types\" -e ", xterm_location);

		if (!ris_dir[0])
		{
			sts = RIScom_get_risdir(RIS_UTILITIES_PRODUCT, RIS_version_maj,
				RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
				0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
			if (sts != 0)
			{
				RISgui_errhandle(sts, 0);
				return;
			}
		}

		RIScom_generate_local_exe_path(ptr, ris_dir, ris_development, "risutl",
			"risdtype");

		strcat(cmd, " &");
	}

	system(cmd);

	GUI_DBG(("RISgui_start_risdtype:returning\n"));
}

/******************************************************************************/

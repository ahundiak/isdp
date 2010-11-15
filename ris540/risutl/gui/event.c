/* Do not alter this SPC information: $Revision: 1.2.51.1 $ */
/*
**	NAME:							event.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(__clipper__)
#include <tools.h>
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif
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
#define event_c
#include "compath.prt"
#include "comgtdir.prt"
#include "comdebug.prt"
#include "event.prt"
#include "env5.prt"
#include "fi.prt"
#if defined(__clipper__)
#include "fi_env5.prt"
#elif defined(WIN32)
#include "fi_winnt.prt"
#else
ERROR -- NO CODE
#endif
#include "guierror.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
#if defined(WIN32)
static HCURSOR hCursor = 0;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

static int	ris_development;
static char ris_dir[256] = "";

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISgui_event_loop(
	int (* form_displayed)())
{
#if defined(__clipper__)
	int event;
#elif defined(WIN32)
	MSG event;
#else
ERROR -- NO CODE
#endif
	GUI_DBG(("RISgui_event_loop()\n"));

	if (!form_displayed)
	{
		GUI_DBG(("RISgui_event_loop:no function pointer: returning\n"));
		return;
	}

	while(form_displayed())
	{
#if defined(__clipper__)
		Wait_for_next(FI_EVENT_MASK, &event);	
		if (!FI_process_event(event))
		{
			FI_clear_event(event);
		}
#elif defined(WIN32)
		GetMessage(&event, NULL, 0, 0);
		FI_process_event(&event);
#else
ERROR -- NO CODE
#endif
	}

	GUI_DBG(("RISgui_event_loop:returning\n"));
}

/******************************************************************************/

extern void RISgui_hourglass_cursor(
	Form fp)
{
#if defined(__clipper__)
	int wno;

	static int hotspotx = 7;
	static int hotspoty = 13;
	static long enable_pattern[] =
	{
		0x00007fff, 0x00007fff, 0x00007fff, 0x00003ffe,
		0x00003ffe, 0x00003ffe, 0x00003ffe, 0x00003ffe,
		0x00003ffe, 0x00001ffc, 0x00000ff8, 0x000007f0,
		0x000003e0, 0x000003e0, 0x000003e0, 0x000007f0,
		0x00000ff8, 0x00001ffc, 0x00003ffe, 0x00003ffe,
		0x00003ffe, 0x00003ffe, 0x00003ffe, 0x00003ffe,
		0x00007fff, 0x00007fff, 0x00007fff, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000
	};
	static long data_pattern[] =
	{
		0x00000000, 0x00000000, 0x00001ffc, 0x00000000,
		0x00000ff8, 0x00000ff8, 0x00000df8, 0x00000aa8,
		0x00000d58, 0x000006b0, 0x00000360, 0x000001c0,
		0x00000080, 0x00000080, 0x00000080, 0x000001c0,
		0x000003e0, 0x00000770, 0x00000ff8, 0x00000f78,
		0x00000eb8, 0x00000d58, 0x00000aa8, 0x00000000,
		0x00001ffc, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000
	};
#elif defined(WIN32)
	static HCURSOR hHourglass = 0;
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_hourglass_cursor(fp:0x%x)\n", fp));

#if defined(__clipper__)
	FIf_get_window(fp, &wno);
	if (wno >= 0)
	{
		defcursor(wno, enable_pattern, data_pattern, hotspotx, hotspoty);
	}
#elif defined(WIN32)
	if (hHourglass == 0)
	{
		hHourglass = LoadCursor(NULL, IDC_WAIT);
	}
	hCursor = SetCursor(hHourglass);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_hourglass_cursor:returning\n"));
}

/******************************************************************************/

extern void RISgui_default_cursor(
	Form fp)
{
#if defined(__clipper__)
	int wno;

	static int hotspotx = 1;
	static int hotspoty = 1;

	static long enable_pattern[] =
	{
		0x00000003, 0x0000000f, 0x0000003e, 0x000000fe,
		0x000003fc, 0x00000ffc, 0x00003ff8, 0x0000fff8,
		0x0003fff0, 0x000ffff0, 0x003fffe0, 0x00ffffe0,
		0x03ffffc0, 0x0fffffc0, 0x3fffff80, 0x7fffff80,
		0x3fffff00, 0x0001ff00, 0x0001fe00, 0x0001fe00,
		0x0001fc00, 0x0001fc00, 0x0001f800, 0x0001f800,
		0x0001f000, 0x0001f000, 0x0001e000, 0x0001e000,
		0x0001c000, 0x0001c000, 0x00008000, 0x00000000
	};

	static long data_pattern[] =
	{
		0x00000000, 0x00000002, 0x00000004, 0x00000018,
		0x00000078, 0x000001f0, 0x000007f0, 0x00001fe0,
		0x00007fe0, 0x0001ffc0, 0x0007ffc0, 0x001fff80,
		0x007fff80, 0x01ffff00, 0x07ffff00, 0x1ffffe00,
		0x0000fe00, 0x0000fc00, 0x0000fc00, 0x0000f800,
		0x0000f800, 0x0000f000, 0x0000f000, 0x0000e000,
		0x0000e000, 0x0000c000, 0x0000c000, 0x00008000,
		0x00008000, 0x00000000, 0x00000000, 0x00000000
	};
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_default_cursor(fp:0x%x)\n",fp));

#if defined(__clipper__)
	FIf_get_window(fp, &wno);
	if (wno >= 0)
	{
		defcursor(wno, enable_pattern, data_pattern, hotspotx, hotspoty);
	}
#elif defined(WIN32)
	if (hCursor)
	{
		SetCursor(hCursor);
	}
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_default_cursor:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_ris()
{
	int					sts;
	static char			path[258] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

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
			"risgui");

#if defined(__clipper__)
		strcat(path, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(path);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	CreateProcess(NULL, path, NULL, NULL, FALSE, DETACHED_PROCESS, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_ris:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_rismgr()
{
	int					sts;
	static char			path[258] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

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
			"rismgr");

#if defined(__clipper__)
		strcat(path, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(path);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	CreateProcess(NULL, path, NULL, NULL, FALSE, DETACHED_PROCESS, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_rismgr:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_rislod()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_rislod()\n"));

	if (!cmd[0])
	{
		ptr = cmd;

#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Loader\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Loader";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_rislod:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risunlod()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risunlod()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Unloader\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Unloader";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;
	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risunlod:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risrecrd()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risrecrd()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Record\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Record";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risrecrd:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risplbck()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risplbck()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Playback\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Playback";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risplbck:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risclnsr()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risclnsr()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Clean Server\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Clean Server";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risclnsr:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risdcode()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risdcode()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Decode\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Decode";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risdcode:returning\n"));
}

/******************************************************************************/

extern void RISgui_start_risdtype()
{
	int sts;
	char *ptr;
	static char cmd[300] = "";
#if defined(WIN32)
	STARTUPINFO			si;
	PROCESS_INFORMATION	pi;
#elif defined(__clipper__)
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risdtype()\n"));

	if (!cmd[0])
	{
		ptr = cmd;
#if defined(__clipper__)
		ptr += sprintf(ptr, "vterm -T \"RIS Data Types\" -x ");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

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

#if defined(__clipper__)
		strcat(cmd, " &");
#elif defined(WIN32)
#else
ERROR -- NO CODE
#endif

	}

#if defined(__clipper__)
	system(cmd);
#elif defined(WIN32)
    memset(&pi, '\0', sizeof(PROCESS_INFORMATION));
	memset (&si, 0, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.lpTitle = "RIS Data Types";
	si.dwXCountChars = 80;
	si.dwYCountChars = 250;
	si.dwFlags = STARTF_USECOUNTCHARS;

	CreateProcess(NULL, cmd, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, 	
	  	NULL, &si, &pi);
#else
ERROR -- NO CODE
#endif

	GUI_DBG(("RISgui_start_risdtype:returning\n"));
}

/******************************************************************************/

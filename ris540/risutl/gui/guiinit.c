/* Do not alter this SPC information: $Revision: 1.6.3.1 $ */
/*
**	NAME:							guiinit.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/90
**	ABSTRACT:
**		The code to process the initialization of RIS forms.
**	
**	REVISION HISTORY:
**
**	11/94:	Added message for INTERNATIONALIZATION.  Rick Kramer
**      6/96:   Fix for TR 439601389 Ashley 6/20/96 
**              WINNT 3.51 does not like double backslashes in help file names.
*/
 
/*
**	INCLUDES
*/
#define DEFINE_GUI_GLOBALS
#include "riscom.h"
#include "gui.h"
#include "risver.h"
#include "risprods.h"
#include "risstjmp.h"

/*
**	FUNCTION PROTOTYPES
*/
#define guiinit_c
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comjmp.prt"
#include "comlang.prt"
#include "fi.prt"
#include "guierror.prt"
#include "guiinit.prt"
#if defined(WIN32)
#include "guihelp.prt"
#elif defined(unix)
#else
ERROR -- NO CODE
#endif
#include "ris.prt"
#include "sys.prt"
#include "ucodebug.prt"
#include "ucoumsg.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/
extern int RISgui_initialize()
{
	int		sts;
	int		lang_code;
	int		development;
	char	*lang_dir;
	char	dir[256];
	char	form_path[256];
	char	symbol_path[256];
#if defined(WIN32)
	char	help_path[256];
#endif

	GUI_DBG(("RISgui_initialize()\n"));

	if (RIS_gui_initialized)
	{
		CLEAR_ERROR;
		return RIS_SUCCESS;
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		RISgui_errhandle(sts, 0);
		return RIS_gui_error.error;
	}

	RISuco_initialize_debug(RIS_gui_debug_info, RIS_gui_debug_count);
	RISuco_initialize_ums(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE);

	RESETJMP();

	sts = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_version_maj,
		RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
		0, RISCONFIG_FILE, dir, &development, 0);
	if (sts != 0)
	{
		RISgui_errhandle(sts, 0);
		return RIS_gui_error.error;
	}

/*
**      Passing RIS_LANGUAGE environment variable to RISinitialize
**      to fix TR# 249406609. RAJU 10/07/94
*/
	RISinitialize(getenv("RIS_LANGUAGE"));
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		return RIS_gui_error.error;
	}

 	RISint_get_language_code(&lang_code);
	lang_dir = RIScom_ris_lang_dir(lang_code);
	if (development)
	{
#if defined(WIN32)
		sprintf(form_path,"%s\\risutl\\config\\%s\\forms\\nt\\v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s\\risutl\\config\\%s\\icons", dir, lang_dir);
		sprintf(help_path,"%s\\risutl\\config\\%s\\help", dir, lang_dir);
#elif defined(unix)
		sprintf(form_path,"%s/risutl/config/%s/forms/unix/v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s/risutl/config/%s/icons", dir, lang_dir);
#endif
	}
	else
	{
#if defined(WIN32)
		sprintf(form_path,"%s\\config\\%s\\forms\\v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s\\config\\%s\\icons", dir, lang_dir);
/* Fix for TR 439601389 Ashley 6/20/96 
   WINNT 3.51 does not like double backslashes in help file names.

   Fix for TR#439601759,60
   Because RIScom_get_risdir() routine is modified and it's stripping
   the ending backslash, we need to add the backslash again. Krishna(08/14/96)
*/
		sprintf(help_path,"%s\\config\\%s\\help", dir, lang_dir);
#elif defined(unix)
		sprintf(form_path,"%s/config/%s/forms/v5forms", dir, lang_dir);
		sprintf(symbol_path,"%s/config/%s/icons", dir, lang_dir);
#endif
	}

	sts = FI_append_form_path(form_path);
	if (sts)
	{
		RISgui_errhandle(RISUTL_E_APPEND_FORM_PATH, sts);
		return RIS_gui_error.error;
	}
	sts = FI_append_symbol_path(symbol_path);
	if (sts)
	{
		RISgui_errhandle(RISUTL_E_APPEND_SYMBOL_PATH, sts);
		return RIS_gui_error.error;
	}
	
#if defined(WIN32)
	RISgui_append_help_path(help_path);
#endif
	if (lang_code != 0) /* english */
	{
		lang_dir = RIScom_ris_lang_dir(0);
		if (development)
		{
#if defined(WIN32)
			sprintf(form_path,"%s\\risutl\\config\\%s\\forms\\nt\\v5forms",dir,lang_dir);
			sprintf(symbol_path,"%s\\risutl\\config\\%s\\icons", dir, lang_dir);
			sprintf(help_path,"%s\\risutl\\config\\%s\\help", dir, lang_dir);
#elif defined(unix)
			sprintf(form_path,"%s/risutl/config/%s/forms/unix/v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s/risutl/config/%s/icons", dir, lang_dir);
#endif
		}
		else
		{
#if defined(WIN32)
			sprintf(form_path,"%s\\config\\%s\\forms\\v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s\\config\\%s\\icons", dir, lang_dir);
			sprintf(help_path,"%s\\config\\%s\\help", dir, lang_dir);
#elif defined(unix)
			sprintf(form_path,"%s/config/%s/forms/v5forms", dir, lang_dir);
			sprintf(symbol_path,"%s/config/%s/icons", dir, lang_dir);
#endif
		}

		sts = FI_append_form_path(form_path);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_APPEND_FORM_PATH, sts);
			return RIS_gui_error.error;
		}
		sts = FI_append_symbol_path(symbol_path);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_APPEND_SYMBOL_PATH, sts);
			return RIS_gui_error.error;
		}
#if defined(WIN32)
		RISgui_append_help_path(help_path);
#endif
	}

	RIS_gui_initialized = 1;

	GUI_DBG(("RISgui_initialize returning RIS_SUCCESS\n"));
	CLEAR_ERROR;
	return RIS_SUCCESS;
}

/******************************************************************************/

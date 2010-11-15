/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							hlpdsply.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					3/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <helpif.h>
#include "riscom.h"
#include "risstjmp.h"
#include "risprods.h"
#include "risver.h"
#include "ris_err.h"
#include "utl_err.h"

/*
**	DEFINES
*/
#define HLP_DBG(s)	if (RIShlp_debug) {RIScom_output_debug s;}
#define STRING(s)	((s)?(s):"NULL")

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define hlpdsply_c
#include "comgtdir.prt"
#include "comjmp.prt"
#include "comlang.prt"
#include "comdebug.prt"
#include "hlpdsply.prt"
#include "hlp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
extern int RIShlp_debug;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIShlp_display_help()
{
	int						active;
	int						status;
	int						ris_lang_code;
	int						ris_development;
	char					*tok;
	char					*language;
	char					*ris_lang_dir;
	char					s[256];
	char					ris_dir[RIS_MAX_PATH_SIZE];
	FILE					*fp;
	struct HP_doc_id_struct	doc;

	HLP_DBG(("RIShlp_display_help()\n"));

	/*
	**	Get ris dir
	*/
	status = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_version_maj,
		RIS_version_min, RIS_version_rel, MATCH_COMPATIBLE,
		0, RISCONFIG_FILE, ris_dir, &ris_development, 0);
	if (status != 0)
	{
		LONGJMP(status);
	}
	HLP_DBG(("ris_dir:<%s> ris_development:%d\n", ris_dir, ris_development));

	/*
	**	get lang dir
	*/
	if (ris_development)
	{
		sprintf(s, "%s/riscom/config", ris_dir);
	}
	else
	{
		sprintf(s, "%s/config", ris_dir);
	}
	RIScom_initialize_langs(s);

#if defined(unix) || defined(DOS)
	/*
	**  Get language
	*/
	if ((language = getenv("RIS_LANGUAGE")) == NULL)
	{
		language = RIScom_default_ris_langname();
	}
#endif
#if defined(WIN32)
	language = RIScom_default_ris_langname();
#endif
	if ((ris_lang_code = RIScom_ris_lang_code(language)) == -1)
	{
		LONGJMP(RIS_E_INVALID_LANG);
	}
	ris_lang_dir = RIScom_ris_lang_dir(ris_lang_code);
	HLP_DBG(("ris_lang_dir:<%s>\n", STRING(ris_lang_dir)));

	/*
	**	setup helpinfo
	*/
	if (ris_development)
	{
		sprintf(s, "%s/risutl/config/%s/help/online/HELPINFO", ris_dir,
			ris_lang_dir);
	}
	else
	{
		sprintf(s, "%s/config/%s/help/online/HELPINFO", ris_dir,
			ris_lang_dir);
	}
	HLP_DBG(("s:<%s>\n", STRING(s)));

	if ((fp = fopen(s, "r")) == NULL)
	{
		LONGJMP(RISUTL_E_UNABLE_TO_OPEN_HELPINFO);
	}
	if (fgets(s, 256, fp) == NULL)
	{
		LONGJMP(RISUTL_E_INV_HELPINFO_FILE);
	}
	fclose(fp);
	
	if ((tok = strtok(s, ":\n")) == NULL)
	{
		LONGJMP(RISUTL_E_INV_HELPINFO_FILE);
	}
	doc.logical_name = tok;
	HLP_DBG(("HELPINFO logical_name:%s\n", STRING(doc.logical_name)));

	if ((tok = strtok(NULL, ":\n")) == NULL)
	{
		LONGJMP(RISUTL_E_INV_HELPINFO_FILE);
	}
	doc.language = tok;
	HLP_DBG(("HELPINFO language:%s\n", STRING(doc.language)));

	if ((tok = strtok(NULL, ":\n")) == NULL)
	{
		LONGJMP(RISUTL_E_INV_HELPINFO_FILE);
	}
	doc.version = tok;
	HLP_DBG(("HELPINFO version:%s\n", STRING(doc.version)));

	if ((status = Help_document(&doc)) != HP_SUCCESS)
	{
		LONGJMP(RISUTL_E_NO_DOCUMENT);
	}
	HLP_DBG(("Help_document returned HP_SUCCESS\n"));

	if ((status = SETJMP()) != 0)
	{
		RESETJMP();
		Help_kill();
		LONGJMP(status);
	}

	if ((status = Help_toc()) != HP_SUCCESS)
	{
		LONGJMP(RISUTL_E_HELP_TOC_FAILED);
	}
	HLP_DBG(("Help_toc returned HP_SUCCESS\n"));

	while(1)
	{
		Help_active(&active);
		if (!active) break;
		sleep(1);
	}
	RESETJMP();

	Help_kill();

	HLP_DBG(("RIShlp_display_help:returning\n"));
}

/******************************************************************************/

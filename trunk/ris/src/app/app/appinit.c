/*
**	NAME:							appinit.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**				Initializes ris-application global stuff, retrieve version 
**				information, gets language stuff, reads parameters file etc ..
**	REVISION HISTORY:
**				sets language info  	-- Hitesh 4/93
**				retrieves version info 	-- Hitesh 7/93
**				added check for code page -- Ashley 4/17/96
**					
*/
 
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "risapp.h"
#include "risnet.h"
#include "risver.h"
#include "riscom.h"
#include "rismem.h"
#include "rispath.h"
#include "risprods.h"
#include "risums.h"
#include "ris_err.h"
#include "risdebug.h"

static void init_globals(void);
static void verify_language(char *language_name);

static int tracex = 0;

/******************************************************************************/
/* Gets called when the PDM loging form is checked off
 */
extern void RISapp_initialize(char *language_name)
{
	int  status;
	char langs_filepath[RIS_MAX_PATH_SIZE];

	APP_DBG(("RISapp_initialize(language_name:<%s>)\n", STRING(language_name)));

  if (tracex) printf("RISapp_initialize(language_name:<%s>)\n", language_name);

	SET_APPLICATION;

	/*
	**	Check for debug file
	*/
	if (!RIS_mem)
	{
		RIScom_initialize_debug();
		NET_set_debug_handler(RIScom_output_debug);
		ARC_set_debug_handler(RIScom_output_debug);
	}
  RISapp_debug = 1;
  
	if (!RIS_mem)
	{
		if( (status = SETJMP()) != 0 )
		{
			RESETJMP();
			RISapp_terminate();
			LONGJMP(status);
		}

		/*
		**	Initialize application globals
		*/
		init_globals();

		/*
		**	Get RISDP version information
		*/
		status = RISapp_init_version();
		if (status != RIS_SUCCESS)
		{
			LONGJMP(status);
		}
	  if (tracex) printf("RIS VER %s\n",RIS_app_version);

		/*
		**	Initialize RIS_dir
		*/
		status = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, 
					RIS_app_version_maj, RIS_app_version_min, 
					RIS_app_version_rel, MATCH_COMPATIBLE, 0,
					RISCONFIG_FILE, RIS_dir, 
					&RIS_development, dbca);
		if (status)
		{
			LONGJMP(status);
		}

		/*
		**	Make sure that required structures are 8 byte aligned.
		*/
		RISapp_check_alignment();

		/*
		**	Initialize memory management
		*/
		RIScom_get_mem();

    	if (RIS_development)
    	{
    		sprintf(langs_filepath, "%s%criscom%cconfig", RIS_dir, PATH_CHAR, 
				PATH_CHAR);
    	}
    	else
    	{
    		sprintf(langs_filepath, "%s%cconfig", RIS_dir, PATH_CHAR);
		}

		/*
		**  Initialize language config file. 
		*/
		RIScom_initialize_langs(langs_filepath);

		/*
		**  Initialize language ums file. 
		**	For non-NT systems, initialize to language passed -- if not default.
		**	For NT systems, initialize to default language always.
		*/
#if defined(unix) || defined(DOS)
		RIS_lang_code_used = 
			RIScom_init_ums_msg(RIS_UMS_FILE, RIS_dir, RIS_development, 
			language_name);
#endif
#if defined(WIN32)
		RIS_lang_code_used =
			RIScom_init_ums_msg(RIS_UMS_FILE, RIS_dir, RIS_development, 0);
#endif

		/*
		** verify the language passed against was it currently set to
		*/
		verify_language(language_name);

		/*
		**	get parameters from parameters file
		*/
		RISapp_read_parms_file();

		RIS_max_dict_stmts = RIS_MAX_DICT_STMTS; /* not required */

		RIS_max_secondary_stmts =  /* not required */
				RIS_parms.max_user_stmts * RIS_parms.max_secondary_schemas;

		/*
		**	Maximum stmts allowed is now configurable i.e.,	only max primary 
		**	stmts on application side; dict_stmts and secondary_stmts are not 
		**	required
		*/
		RIS_max_stmts =	RIS_parms.max_user_stmts;
		APP_DBG(("RISapp_initialize: RIS_max_stmts: %d\n",RIS_max_stmts));

		/*
		** Allocate memory for RIS_stmts array (size of RIS_max_stmts)
		*/
		RIS_stmts = ALLOCNP(ris_app_stmt *, RIS_max_stmts);

		RESETJMP();
	}
	else
	{
		/*
		** This code-segment is required to verify that same language is being
		** used by the application even after a sequence of RISterminate() and
		** RISinitialize() calls
		*/
		verify_language(language_name);
	}

	APP_DBG(("RISapp_initialize: complete\n"));
}

/******************************************************************************/

static void init_globals(void)
{

	RIS_client_died	= 0;
	RIS_def_schname[0] = '\0';
	RIS_parms_filename[0] = '\0';

	memset(&RIS_client_parms, 0, sizeof(RIS_client_parms));
	memset(&RIS_schfile_parms, 0, sizeof(RIS_schfile_parms));

	RIS_stmt = 0;

	RIS_static_stmt_cnt = 0;

	RIS_net = 0;
	RIS_net_finish_mode = DEALLOCATE;
	RIS_read = 0;
	RIS_write = 0;
	RIS_save_read = 0;
	RIS_save_write = 0;

	memset(&RISsuperschema_error, 0, sizeof(RISsuperschema_error));
}

/******************************************************************************/

static void verify_language(
	char *language_name)
{
    int lang_code;

	/*
	** If language_name not set, set it to RIS_DEFAULT_LANGUAGE
	*/
    if( !language_name )
    {
       	language_name = RIScom_default_ris_langname();
    }

	/*
	** RIS_language_code is initialized to -1
	*/
   	if( (lang_code = RIScom_ris_lang_code(language_name)) == -1 )
	{
		LONGJMP(RIS_E_INVALID_LANG);
	}
	APP_DBG(("verify_lang - RIS_language_code = <%d>, code_page = <%d>\n",
		  RIS_language_code, RIScom_get_code_page(RIS_language_code)));
	APP_DBG(("verify_lang - lang_code = <%d>, code_page = <%d>\n",
		  lang_code, RIScom_get_code_page(lang_code)));
	if( lang_code != RIS_language_code )
	{
	/* map language ID to code page.  As long as the ANSI code
	** pages are the same then the languages character sets are
	** compatible. Fix for TR 439600180 Ashley 4/9/96
	**/
	if (RIScom_get_code_page(RIS_language_code) !=
		    RIScom_get_code_page(lang_code))

	       	/* Fix TR#249407459 - kmreddy - Misspelled RIS error message */ 
       		LONGJMP(RIS_E_INCOMPATIBLE_LANGS);
	}
}

/******************************************************************************/

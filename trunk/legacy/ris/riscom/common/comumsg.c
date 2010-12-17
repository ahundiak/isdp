/*
**	NAME:							comumsg.c
**	AUTHORS:						Jin Jing
**	CREATION DATE:					8/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**				Add delimiter check -- Hitesh R. Patel 1/28/93
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "ums.h"
#include "pums_pub.h"
#include "riscom.h"
#include "risums.h"
#include "risdebug.h"
#include "rispath.h"
#include "risstjmp.h"
#include "ris_err.h"


/*
**	DEFINES
*/
#define LOAD_COMO_MEMORY (UMS_KEY | UMS_MESSAGE)

/*
**	TYPES
*/
typedef struct error_info_s
{
	int		errcode;
	char	*name;
	char	*message;
} error_info_s;

/*
**	FUNCTION PROTOTYPES
*/
#define comumsg_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "comlang.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static  int RIS_umsg_initialized[LAST_FILE_TYPE+1];
static  char RIS_umsg_msg_path[LAST_FILE_TYPE+1][RIS_MAX_PATH_SIZE];
static char	message_type[] = { 'W', 'S', 'E', 'I', 'F', 'P', 'M' };
	
/*
**	The following are errors which can occur before UMS is initialized.
**	This information will be used only when one of these error occurs and
**	UMS is NOT initialized.  If UMS is initialized, the message file will
**	be used.
*/
static error_info_s error_info[] =
{
	{
		(int)RIS_E_CANT_GET_RISDIR,
		"RIS_E_CANT_GET_RISDIR",
		"An error occurred while reading the risdir file."
	},
	{
		(int)RIS_E_CANT_OPEN_INGRCONFIG,
		"RIS_E_CANT_OPEN_INGRCONFIG",
		"Unable to open \"/usr/ip32/ingrconfig\"."
	},
	{
		(int)RIS_E_CANT_OPEN_RISCONFIG,
		"RIS_E_CANT_OPEN_ETC_RISCONFIG",
		"Unable to open \"/etc/risconfig\"."
	},
	{
		(int)RIS_E_CANT_FIND_PRODUCT,
		"RIS_E_CANT_FIND_PRODUCT",
		"Could not find RIS product in \"/usr/ip32/ingrconfig\"."
	},
	{
		(int)RIS_E_CANT_FIND_RISCLI_PRODUCT,
		"RIS_E_CANT_FIND_RISCLI_PRODUCT",
		"Could not find RISCLI product in \"/etc/risconfig\"."
	},
	{
		(int)RIS_E_CANT_FIND_RISDP_PRODUCT,
		"RIS_E_CANT_FIND_RISDP_PRODUCT",
		"Could not find RISDP product in \"/etc/risconfig\"."
	},
	{
		(int)RIS_E_CANT_FIND_REG_PRODUCT,
		"RIS_E_CANT_FIND_REG_PRODUCT",
		"Could not find RIS product in registry."
	},
	{
		(int)RIS_E_NO_PRO_DD_RIS,
		"RIS_E_NO_PRO_DD_RIS",
		"Could not translate PRO_DD_RIS."
	},
	{
		(int)RIS_E_INV_PRO_DD_RIS,
		"RIS_E_INV_PRO_DD_RIS",
		"Invalid value in PRO_DD_RIS. Missing trailing dot."
	},
	{
		(int)RIS_E_INV_PRO_DD_RIS,
		"RIS_E_INV_PRO_DD_RIS",
		"Invalid value in PRO_DD_RIS. Missing trailing dot."
	},
	{
		(int)RIS_E_INTERNAL_ERROR,
		"RIS_E_INTERNAL_ERROR",
		"RIS internal error."
	},
	{
		(int)RIS_E_INVALID_LANG,
		"RIS_E_INVALID_LANG",
		"Invalid ris language name."
	},
	{
		(int)RIS_E_UMS_INIT_MSG_FAILED,
		"RIS_E_UMS_INIT_MSG_FAILED",
		"Unable to initialize UMS message file."
	},
	{
		(int)RIS_E_CANT_OPEN_LANGCONFIG_FILE,
		"RIS_E_CANT_OPEN_LANGCONFIG_FILE",
		"Unable to open ris language config file."
	},
	{
		(int)RIS_E_ERROR_FROM_LOCALE,
		"RIS_E_ERROR_FROM_LOCALE",
		"Unable to get LOCALE information."
	},
	{
		(int)RIS_E_LANGCONFIG_LINE_TOO_LONG,
		"RIS_E_LANGCONFIG_LINE_TOO_LONG",
		"A line in the ris language config file exceeds the maximum length of 512 characters."
	},
	{
		(int)RIS_E_NON_ASCII_IN_LANGCONFIG,
		"RIS_E_NON_ASCII_IN_LANGCONFIG",
		"Found a non-ascii character in the ris language config file."
	},
	{
		(int)RIS_E_EXCEED_LANGNAME_SIZE,
		"RIS_E_EXCEED_LANGNAME_SIZE",
		"RIS or OS language name exceeds RIS_MAX_LANGNAME_SIZE."
	},
	{
		(int)RIS_E_EXCEED_DIRNAME_SIZE,
		"RIS_E_EXCEED_DIRNAME_SIZE"
		"RIS language directory exceeds RIS_MAX_DIRNAME_SIZE."
	},
	{
		(int)RIS_E_MISSING_RIS_LANG_ID,
		"RIS_E_MISSING_RIS_LANG_ID",
		"Missing ris language id in ris language config file."
	},
	{ /* Ashley 5-3-96 */
		(int)RIS_E_MISSING_CODE_PAGE,
		"RIS_E_MISSING_CODE_PAGE",
		"Missing ris code page in ris language config file."
	},
	{
		(int)RIS_E_MISSING_RIS_LANG_NAME,
		"RIS_E_MISSING_RIS_LANG_NAME",
		"Missing ris language name in ris language config file."
	},
	{
		(int)RIS_E_MISSING_CONFIG_DIR,
		"RIS_E_MISSING_CONFIG_DIR",
		"Missing ris language directory in ris language config file."
	},
	{
		(int)RIS_E_MISSING_OS_LANG_ID,
		"RIS_E_MISSING_OS_LANG_ID",
		"Missing os language id in ris language config file."
	},
	{
		(int)RIS_E_MISSING_OS_LANG_NAME,
		"RIS_E_MISSING_OS_LANG_NAME",
		"Missing os language name in ris language config file."
	},
	{
		(int)RIS_E_LANGCONFIG_NOT_INITIALIZED,
		"RIS_E_LANGCONFIG_NOT_INITIALIZED",
		"RIS language config file not initialized."
	},
};

static int error_count = sizeof(error_info)/sizeof(error_info_s);

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern int RIScom_init_ums_msg(
	int		file_type,
	char	*dir,
	int		development,
	char	*lang_name)
{
	int		status;
	int		lang_code;
	char	*lang_dir;
	char	langs_path[RIS_MAX_PATH_SIZE];
	char	*ptr, *savptr;
	int		lang_used;

	COM_DBG(("RIScom_init_ums_msg(file_type:%d dir:<%s> development:%d lang_name:<%s>)\n", file_type, STRING(dir), development, STRING(lang_name)));

	if (file_type < FIRST_FILE_TYPE || file_type > LAST_FILE_TYPE)
	{
		COM_DBG(("RIScom_init_ums_msg: invalid file_type:%d\n", file_type));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	if (RIS_umsg_initialized[file_type])
	{
		COM_DBG(("RIScom_init_ums_msg: already initialized: returning\n"));
		/*
		** This happens when app layer does but utl layer has already done.
		*/
		return -1;
	}

	/*
	** Generate the full path for langs config file
	*/
	if (development)
	{
		sprintf(langs_path, "%s%criscom%cconfig", dir, PATH_CHAR, PATH_CHAR);
	}
	else
	{
		sprintf(langs_path, "%s%cconfig", dir, PATH_CHAR);
	}

	/*
	** Initialize langs file
	*/
	RIScom_initialize_langs(langs_path);

	/*
	** Generate the full path for ums msg file
	*/
	ptr = RIS_umsg_msg_path[file_type];

	ptr += sprintf(ptr, "%s", dir);

	if (development)
	{
		switch(file_type)
		{
			case RIS_UMS_FILE:
				ptr += sprintf(ptr, "%criscom", PATH_CHAR);
			break;
			case UTL_UMS_FILE:
				ptr += sprintf(ptr, "%crisutl", PATH_CHAR);
			break;
			case NET_UMS_FILE:
				ptr += sprintf(ptr, "%criscom", PATH_CHAR);
			break;
			default:
				COM_DBG(("RIScom_init_ums_msg: unknown file_type:%d\n",
					file_type));
				LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}

	ptr += sprintf(ptr, "%cconfig", PATH_CHAR);

	/*
	** Get the language dir name
	*/
	if (lang_name == NULL)
	{
        lang_name = RIScom_default_ris_langname();
	}
	if ((lang_code = RIScom_ris_lang_code(lang_name)) == -1)
	{
		COM_DBG(("RIScom_init_ums_msg: Invalid lang_name:<%s>\n",
			STRING(lang_name)));
		LONGJMP(RIS_E_INVALID_LANG);
	}
	lang_used = lang_code;
	if ((lang_dir = RIScom_ris_lang_dir(lang_code)) == NULL)
	{
		COM_DBG(("RIScom_init_ums_msg: Invalid lang_code:<%d>\n", lang_code));
		LONGJMP(RIS_E_INVALID_LANG);
	}
	COM_DBG(("RIScom_init_ums_msg: lang_dir:<%s>\n", lang_dir));

	savptr = ptr;
	ptr += sprintf(ptr, "%c%s", PATH_CHAR, lang_dir);

	switch(file_type)
	{
		case RIS_UMS_FILE:
			ptr += sprintf(ptr, "%cmessages%cris.msg", PATH_CHAR, PATH_CHAR);
		break;
		case UTL_UMS_FILE:
			ptr += sprintf(ptr, "%cmessages%cutl.msg", PATH_CHAR, PATH_CHAR);
		break;
		case NET_UMS_FILE:
			ptr += sprintf(ptr, "%cmessages%cnet.msg", PATH_CHAR, PATH_CHAR);
		break;
		default:
			COM_DBG(("RIScom_init_ums_msg: unknown file_type:%d\n", file_type));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	COM_DBG(("RIScom_init_ums_msg: RIS_umsg_msg_path[file_type:%d]:<%s>\n",
		file_type, RIS_umsg_msg_path[file_type]));
	status = UMSInitMsg(RIS_umsg_msg_path[file_type], LOAD_COMO_MEMORY);
	if (status == UMS_S_SUCCESS)
	{
		RIS_umsg_initialized[file_type] = 1;
	}
	/*
	** If fails Then Try to use default lang "english"
	**    Note:  the 0th row in the langs file is english
	*/
	else
	{
		lang_used = 0;
		if ((lang_dir = RIScom_ris_lang_dir(0)) == NULL)
		{
			COM_DBG(("RIScom_init_ums_msg: Invalid lang_code:<%d>\n",
					 0));
			LONGJMP(RIS_E_INVALID_LANG);
		}
		COM_DBG(("RIScom_init_ums_msg: lang_dir:<%s>\n", lang_dir));
		savptr += sprintf(savptr, "%c%s", PATH_CHAR, lang_dir);
		switch(file_type)
		{
		  case RIS_UMS_FILE:
		   savptr += sprintf(savptr,"%cmessages%cris.msg",PATH_CHAR,PATH_CHAR);
		   break;
		  case UTL_UMS_FILE:
		   savptr += sprintf(savptr,"%cmessages%cutl.msg",PATH_CHAR,PATH_CHAR);
		   break;
		  case NET_UMS_FILE:
		   savptr += sprintf(savptr,"%cmessages%cnet.msg",PATH_CHAR,PATH_CHAR);
		   break;
		  default:
		   COM_DBG(("RIScom_init_ums_msg: unknown file_type:%d\n",file_type));
		   LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		COM_DBG(("RIScom_init_ums_msg: RIS_umsg_msg_path[file_type:%d]:<%s>\n",
				 file_type, RIS_umsg_msg_path[file_type]));
		status = UMSInitMsg(RIS_umsg_msg_path[file_type], LOAD_COMO_MEMORY);
		if (status == UMS_S_SUCCESS)
		{
			RIS_umsg_initialized[file_type] = 1;
		}
		else
		{
			COM_DBG(("RIScom_init_ums_msg: UMSInitMsg() failed: status:%d\n",
					 status));
			LONGJMP(RIS_E_UMS_INIT_MSG_FAILED);
		}
	}
	if (file_type == RIS_UMS_FILE)
	{
		/*
		**  Initialize RIS_language_code
		*/
		RIS_language_code = lang_code;
	}

	COM_DBG(("RIScom_init_ums_msg: returning\n"));
	return lang_used;
}

/******************************************************************************/

extern char *RIScom_umsg(
	int	errcode)
{
	int i;
	int	status;
	int	file_type = 0;
	static  char	ums_msg[RIS_MAX_ERROR_MSG];

	COM_DBG(("RIScom_umsg(errcode:0x%x)\n", errcode));

	status = 0;
	switch((errcode & 0x07ff0000) >> 16)
	{
		case RIS_BASE_NUMBER:
			file_type = RIS_UMS_FILE;
		break;
		case UTL_BASE_NUMBER:
			file_type = UTL_UMS_FILE;
		break;
		case NET_BASE_NUMBER:
			file_type = NET_UMS_FILE;
		break;
		default:
			sprintf(ums_msg,"Message not found for 0x%x", errcode);
			COM_DBG(("RIScom_umsg: returning <%s>\n", ums_msg));
			return ums_msg;
	}

	if (!RIS_umsg_initialized[file_type])
	{
		for (i = 0; i < error_count; i++)
		{
			if (errcode == error_info[i].errcode)
			{
				strcpy(ums_msg, error_info[i].message);
				break;
			}
		}
		if (i == error_count)
		{
			sprintf(ums_msg,"Message file not initialized for 0x%x", errcode);
		}

		COM_DBG(("RIScom_umsg: returning <%s>\n", ums_msg));
		return ums_msg;
	}

	/*
	**	get the ums messages for this error
	*/
  	status = UMSGetByNum (ums_msg, errcode & 0x7fffffff, NULL);
	if (status != UMS_S_SUCCESS)
	{
		sprintf(ums_msg,"Message not found for 0x%x", errcode);
		COM_DBG(("RIScom_umsg: returning <%s>\n", ums_msg));
		return ums_msg;
	}
	
	/*
	** '@' serves a delimiter.
	** If the first character is '@', it will be replaced by a blank.
	*/
	if (ums_msg[0] == '@')
	{
		ums_msg[0] = ' ';
	}

	COM_DBG(("RIScom_umsg: returning <%s>\n", STRING(ums_msg)));
	return ums_msg;
}

/******************************************************************************/

extern char *RIScom_umsg_by_key(
	char *errkey)
{
	int	status;
	int	file_type = 0;
	char *return_sts = NULL;
	static  char	ums_msg[RIS_MAX_ERROR_MSG];

	COM_DBG(("RIScom_umsg_by_key(errkey:<%s>)\n", STRING(errkey)));

	status = 0;
	if (!strncmp(errkey, "RISUTL", 6))
	{
		file_type = UTL_UMS_FILE;
	}
	else if (!strncmp(errkey, "RIS", 3))
	{
		file_type = RIS_UMS_FILE;
	}
	else if (!strncmp(errkey, "NET", 3))
	{
		file_type = NET_UMS_FILE;
	}
	else
	{
		status = -1;
	}
	if (!status)
	{
		status = !RIS_umsg_initialized[file_type];
	}
	if (!status)
	{
		/*
		**	get the ums messages for this error
		*/
  		if ((status = UMSGetByKey (ums_msg, errkey, NULL)) == UMS_S_SUCCESS)
		{
			/*
			** '@' serves a delimiter.
			** If the first character is '@', it should be
			** replaced by a blank.
			*/
			if (ums_msg[0] == '@')
			{
				ums_msg[0] = ' ';
			}
			return_sts = ums_msg;
		}
	}
	
	COM_DBG(("RIScom_umsg_by_key: returning <%s>\n", STRING(return_sts)));
	return return_sts;
}

/******************************************************************************/

extern char *RIScom_error_code(
	int	errcode)
{
	int			i;
	int			status;
	int			file_type = 0;
	char		*ptr;
	char		temp_key[100];
	static  char	ums_key[100];

	COM_DBG(("RIScom_error_code(errcode:0x%x)\n", errcode));

	switch((errcode & 0x07ff0000) >> 16)
	{
		case RIS_BASE_NUMBER:
			file_type = RIS_UMS_FILE;
		break;
		case UTL_BASE_NUMBER:
			file_type = UTL_UMS_FILE;
		break;
		case NET_BASE_NUMBER:
			file_type = NET_UMS_FILE;
		break;
		default:
			sprintf(ums_key,"Error name not found for 0x%x", errcode);
			COM_DBG(("RIScom_error_code: returning ums_key:<%s>\n", ums_key));
			return ums_key;
	}

	if (!RIS_umsg_initialized[file_type])
	{
		for (i = 0; i < error_count; i++)
		{
			if (errcode == error_info[i].errcode)
			{
				strcpy(ums_key, error_info[i].name);
				break;
			}
		}
		if (i == error_count)
		{
			sprintf(ums_key,"Message file not initialized for 0x%x", errcode);
		}

		COM_DBG(("RIScom_error_code: returning ums_key:<%s>\n", ums_key));
		return ums_key;
	}

	COM_DBG(("RIScom_error_code: search in UMS msgs file.\n"));
	/*
	**	get the ums key for this error
	*/
  	status = UMSGetKeyByNum (temp_key, 0, errcode & 0x7fffffff);
	if (status != UMS_S_SUCCESS)
	{
		sprintf(ums_key,"Error name not found for 0x%x", errcode);
		COM_DBG(("RIScom_error_code: returning ums_key:<%s>\n", ums_key));
		return ums_key;
	}
	if ((ptr = strchr(temp_key, ':')) == NULL)
	{
		COM_DBG(("RIScom_error_code: no colon found in key.\n"));
		strcpy(ums_key, temp_key);
	}
	else
	{
		*ptr++ = '\0';
		sprintf(ums_key, "%s_%c_%s", temp_key,
			message_type[errcode & 0x00000007], ptr);
	}
	
	COM_DBG(("RIScom_error_code: returning ums_key:<%s>\n", ums_key));
	return ums_key;
}

/******************************************************************************/

extern void RIScom_clear_ums_msg(
	int		file_type)
{
	int	status;

	COM_DBG(("RIScom_clear_ums_msg()\n"));

	if (file_type < FIRST_FILE_TYPE || file_type > LAST_FILE_TYPE)
	{
		COM_DBG(("RIScom_clear_ums_msg: invalid file_type:%d\n", file_type));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	if (!RIS_umsg_initialized[file_type])
	{
		return;
	}
	COM_DBG(("RIScom_clear_ums_msg: RIS_umsg_msg_path[file_type:%d]:<%s>\n",
			file_type, RIS_umsg_msg_path[file_type]));
	status = UMSClearMsg(RIS_umsg_msg_path[file_type]);
	if (status == UMS_S_SUCCESS)
	{
		RIS_umsg_initialized[file_type] = 0;
		memset(RIS_umsg_msg_path, '\0', RIS_MAX_PATH_SIZE);
	}
	else
	{
		COM_DBG(("RIScom_clear_ums_msg: UMSClearMsg Error:%d.\n", status));
	}
	COM_DBG(("RIScom_clear_ums_msg:complete\n"));
}

/******************************************************************************/

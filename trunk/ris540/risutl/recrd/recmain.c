/* Do not alter this SPC information: $Revision: 1.8.3.1 $ */
/*
**	NAME:							recmain.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**	 Ashley  7/9/96 Fix for 439402027 
*/
 
#define VERSION_4_BACKWARDS_KLUDGE

/*
**	INCLUDES
*/

#if defined(WIN32)
#  include <windows.h>
#elif defined(unix) || defined(DOS)
#else
ERROR -- NO CODE
#endif

#if defined(WIN32S)
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#if !defined(WIN32S)
#include <stdio.h>
#endif

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#if defined(unix)
# include <unistd.h>
#endif

#include "risver.h"
#include "risutl.h"
#include "risrap.h"
#include "risstjmp.h"
#include "rislimit.h"
#include "utl_err.h"
#include "utl_inf.h"

#if defined(WIN32S)
#include "prog32s.h"
#endif 


/*
**	DEFINES
*/
#define EXE	"risrecrd"

#if defined(unix)
#define DEFAULT_OUTPUT_PATH "/usr/tmp/risrap.$$"
#elif defined(WIN32)
#define DEFAULT_OUTPUT_FILENAME "risrap.$$"
#elif defined(DOS)
#define DEFAULT_OUTPUT_FILENAME "risrap.out"
#else
ERROR -- NO CODE
#endif
#if defined(WIN32S)
#include "btcerrbx.prt"
#endif

#define TURN_OFF	0
#define TURN_ON		1
#define QUERY		2
#define INTERACTIVE	3

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define recmain_c
#include "recmain.prt"
#if defined(unix)
#  include "compd.prt"
#elif defined(WIN32) || defined(DOS)
#  include "ucogtopt.prt"
#else
ERROR -- NO CODE
#endif
#include "comrap.prt"
#include "ucofgets.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ucodebug.prt"
#include "ucoerrbx.prt"
#include "ucoumsg.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
extern int optind;
extern char *optarg;
#if defined(DOS) || defined(WIN32)
static char DEFAULT_OUTPUT_PATH[RIS_MAX_PATH_SIZE];
#elif defined(unix)
#else
ERROR -- NO CODE
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void DoUsage()
{
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_1));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_2));
	PRINTF(MSG(RISUTL_I_5RECRD_USAGE_3));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_4));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_5));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_6));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_7));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_8));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_9));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_10));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_11));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_12));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_13));
	PRINTF(MSG(RISUTL_I_RECRD_USAGE_14));
}

/******************************************************************************/

static void DoVersion()
{
	/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
	/* 1996.03.12:Alan Barksdale:TR439600483 */
	PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
	PRINTF(" ");
	PRINTF(COPYRIGHTYEAR);
	PRINTF(", ");
	PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
	PRINTF(MSG(RISUTL_I_RECRD_UTILITY), RIS_version);
}

/******************************************************************************/

static void output_options(
	ris_rap_options *rap)
{
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_1));
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_2), rap->filename);
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_3), rap->command_time ? "YES" : "NO");
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_4), rap->delay_time ? "YES" : "NO");
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_5), rap->total_time ? "YES" : "NO");
	PRINTF(MSG(RISUTL_I_RECRD_OPTIONS_6), rap->overwrite_file ? "YES" : "NO");
}

/******************************************************************************/

static void get_new_options(
	ris_rap_options *def,
	ris_rap_options *new)
{
	int command_time;
	int delay_time;
	int total_time;
	int overwrite_file;
	char filename[256];
	char response[256];

	if (def && def->filename[0])
	{
		strcpy(filename, def->filename);
	}
	else
	{
		strcpy(filename, DEFAULT_OUTPUT_PATH);
	}
	PRINTF(MSG(RISUTL_I_RECRD_NEW_1), filename);
#if defined(WIN32S)
	GETS(response);
#else
	RISuco_fgets(response, 256, stdin);
#endif
	if (!response[0])
	{
		strcpy(new->filename, filename);
	}
	else
	{
		strcpy(new->filename, response);
	}

	if (def)
	{
		command_time = def->command_time;
	}
	else
	{
		command_time = 1;
	}
	PRINTF(MSG(RISUTL_I_RECRD_NEW_2), command_time ? 'y' : 'n');
#if defined(WIN32S)
	GETS(response);
#else
	RISuco_fgets(response, 256, stdin);
#endif
	if (!response[0])
	{
		new->command_time = command_time;
	}
	else if (!strcmp(response, "y") || !strcmp(response, "Y"))
	{
		new->command_time = 1;
	}
	else
	{
		new->command_time = 0;
	}


	if (def)
	{
		delay_time = def->delay_time;
	}
	else
	{
		delay_time = 1;
	}
	PRINTF(MSG(RISUTL_I_RECRD_NEW_3), delay_time ? 'y' : 'n');
#if defined(WIN32S)
	GETS(response);
#else
	RISuco_fgets(response, 256, stdin);
#endif
	if (!response[0])
	{
		new->delay_time = delay_time;
	}
	else if (!strcmp(response, "y") || !strcmp(response, "Y"))
	{
		new->delay_time = 1;
	}
	else
	{
		new->delay_time = 0;
	}

	if (def)
	{
		total_time = def->total_time;
	}
	else
	{
		total_time = 1;
	}
	PRINTF(MSG(RISUTL_I_RECRD_NEW_4), total_time ? 'y' : 'n');
#if defined(WIN32S)
	GETS(response);
#else
	RISuco_fgets(response, 256, stdin);
#endif
	if (!response[0])
	{
		new->total_time = total_time;
	}
	else if (!strcmp(response, "y") || !strcmp(response, "Y"))
	{
		new->total_time = 1;
	}
	else
	{
		new->total_time = 0;
	}

	if (def)
	{
		overwrite_file = def->overwrite_file;
	}
	else
	{
		overwrite_file = 1;
	}
	PRINTF(MSG(RISUTL_I_RECRD_NEW_5), overwrite_file ? 'y' : 'n');
#if defined(WIN32S)
	GETS(response);
#else
	RISuco_fgets(response, 256, stdin);
#endif
	if (!response[0])
	{
		new->overwrite_file = overwrite_file;
	}
	else if (!strcmp(response, "y") || !strcmp(response, "Y"))
	{
		new->overwrite_file = 1;
	}
	else
	{
		new->overwrite_file = 0;
	}
}

/******************************************************************************/

static int turn_recording_on(
	ris_rap_options	*rap)
{
#if defined(unix) || defined(DOS)
	char			filename[80];
	FILE			*fp;
#if defined(unix)
	uid_t			uid = getuid();
	mode_t			old_umask;
	char			str[38];
# endif	

# if defined(VERSION_4_BACKWARDS_KLUDGE)
#if defined(unix)
	sprintf(filename, RISRAP_FILENAME_FORMAT_VERSION4, uid);
#  elif defined(DOS)
	sprintf(filename, RISRAP_FILENAME_FORMAT_VERSION4);
#  endif		

#if defined(unix)
	old_umask = umask(S_IRWXO|S_IRWXG|S_IXUSR);
#  endif
	if ((fp = fopen(filename, "w")) != NULL)
	{
#if defined(unix)
		sprintf(str, "%d", uid);
		RIScom_rap_pd(str, str);
		FPRINTF(fp, "%s\n", str);
#  endif
		FPRINTF(fp, "%s%s\n", OUTPUT_COLON, rap->filename);
		if (!rap->command_time) FPRINTF(fp, "%s\n", NO_COMMAND_TIME);
		if (!rap->delay_time) FPRINTF(fp, "%s\n", NO_DELAY_TIME);
		if (!rap->total_time) FPRINTF(fp, "%s\n", NO_ELAPSED_TIME);

		fclose(fp);
	}
#if defined(unix)
	umask(old_umask);
#  endif
# endif /* VERSION_4_BACKWARDS_KLUDGE */

#if defined(unix)
	sprintf(filename, RISRAP_FILENAME_FORMAT, uid);
# elif defined(DOS)
	sprintf(filename, RISRAP_FILENAME_FORMAT);
# endif		

#if defined(unix)
	old_umask = umask(S_IRWXO|S_IRWXG|S_IXUSR);
# endif
	if ((fp = fopen(filename, "w")) == NULL)
	{
		PRINTF(MSG(RISUTL_E_UNABLE_TO_OPEN), EXE, filename);
#if defined(unix)
		umask(old_umask);
# endif
		return 1;
	}

#if defined(unix)
	sprintf(str, "%d", uid);
	RIScom_rap_pd(str, str);
	FPRINTF(fp, "%s\n", str);
# endif
	FPRINTF(fp, "%s%s\n", OUTPUT_COLON, rap->filename);
	if (!rap->command_time) FPRINTF(fp, "%s\n", NO_COMMAND_TIME);
	if (!rap->delay_time) FPRINTF(fp, "%s\n", NO_DELAY_TIME);
	if (!rap->total_time) FPRINTF(fp, "%s\n", NO_ELAPSED_TIME);
	if (!rap->overwrite_file) FPRINTF(fp, "%s\n", NO_OVERWRITE_FILE);

	fclose(fp);

#if defined(unix)
	umask(old_umask);
# endif			
#elif defined(WIN32)
	int		value;
	HKEY	hKey;


	if (RegCreateKey(HKEY_CURRENT_USER, RISRAP_KEY, &hKey) != ERROR_SUCCESS)
	{
		return 1;
	}

	if (RegSetValueEx(hKey, OUTPUT_VALUE_NAME, 0, OUTPUT_VALUE_TYPE,
		rap->filename, strlen(rap->filename) + 1) != ERROR_SUCCESS)
	{
		return 1;
	}

	value = rap->delay_time;
	if (RegSetValueEx(hKey, DELAY_VALUE_NAME, 0, DELAY_VALUE_TYPE,
		(unsigned char *)&value, sizeof(value)) != ERROR_SUCCESS)
	{
		return 1;
	}

	value = rap->total_time;
	if (RegSetValueEx(hKey, ELAPSED_VALUE_NAME, 0, ELAPSED_VALUE_TYPE,
		(unsigned char *)&value, sizeof(value)) != ERROR_SUCCESS)
	{
		return 1;
	}

	value = rap->command_time;
	if (RegSetValueEx(hKey, COMMAND_VALUE_NAME, 0, COMMAND_VALUE_TYPE,
		(unsigned char *)&value, sizeof(value)) != ERROR_SUCCESS)
	{
		return 1;
	}

	value = rap->overwrite_file;
	if (RegSetValueEx(hKey, OVERWRITE_VALUE_NAME, 0, OVERWRITE_VALUE_TYPE,
		(unsigned char *)&value, sizeof(value)) != ERROR_SUCCESS)
	{
		return 1;
	}

	RegCloseKey(hKey);
#else
ERROR -- NO CODE
#endif

	return 0;
}

/******************************************************************************/

extern int turn_recording_off(
	void)
{
#if defined(unix) || defined(DOS)
#if defined(unix)
	uid_t			uid = getuid();
# endif	
	char			filename[80];

# if defined(VERSION_4_BACKWARDS_KLUDGE)
#if defined(unix)
	sprintf(filename, RISRAP_FILENAME_FORMAT_VERSION4, uid);
#  elif defined(DOS)
	sprintf(filename, RISRAP_FILENAME_FORMAT_VERSION4);
#  endif
	remove(filename);
# endif /* VERSION_4_BACKWARDS_KLUDGE */

#if defined(unix)
	sprintf(filename, RISRAP_FILENAME_FORMAT, uid);
# elif defined(DOS)
	sprintf(filename, RISRAP_FILENAME_FORMAT);
# endif
	if (remove(filename) == -1)
	{
		PRINTF(MSG(RISUTL_E_UNABLE_TO_REMOVE), EXE, filename, strerror(errno));
		return 1;
	}
#elif defined(WIN32)
	if (RegDeleteKey(HKEY_CURRENT_USER, RISRAP_KEY) != ERROR_SUCCESS)
	{
		return 1;
	}
#else
ERROR -- NO CODE
#endif
	return 0;
}

/******************************************************************************/

static int interactive()
{
	int				rap_on;
	int				choice;
	char 			response[80];
	ris_rap_options cur;
	ris_rap_options new;

	while(1)
	{
		rap_on = RIScom_read_rap_file(&cur, 0);
		if (rap_on)
		{
			PRINTF(MSG(RISUTL_I_RECRD_ON));
			output_options(&cur);

			PRINTF(MSG(RISUTL_I_RECRD_ON_MENU_1));
			PRINTF(MSG(RISUTL_I_RECRD_ON_MENU_2));
			PRINTF(MSG(RISUTL_I_RECRD_ON_MENU_3));
			PRINTF(MSG(RISUTL_I_RECRD_ON_MENU_4));

#if defined(WIN32S)
	GETS(response);
#else
			fgets(response, 80, stdin);
/* Ashley  7/9/96 Fix for 439402027 */
#if defined(unix)
			if (feof(stdin))
				exit(0);   
#endif
#endif
			choice = atoi(response);
			if (choice == 1)
			{
				if (turn_recording_off())
				{
					return 1;
				}
			}
			else if (choice == 2)
			{
				get_new_options(&cur, &new);
				turn_recording_on(&new);
			}
			else if (choice == 3)
			{
#if defined(WIN32S)
				PRINTF(MSG(RISUTL_I_RECRD_OFF));
				DestroyWindow(winio_current());
				winio_end();
#endif
				break;
			}
		}
		else
		{
			PRINTF(MSG(RISUTL_I_RECRD_OFF));
			PRINTF(MSG(RISUTL_I_RECRD_OFF_MENU_1));
			PRINTF(MSG(RISUTL_I_RECRD_OFF_MENU_2));
			PRINTF(MSG(RISUTL_I_RECRD_OFF_MENU_3));
#if defined(WIN32S)
	GETS(response);
#else
			fgets(response, 80, stdin);
/* Ashley  7/9/96 Fix for 439402027 */
#if defined(unix)
			if (feof(stdin))
				exit(0);   
#endif
#endif
			choice = atoi(response);
			if (choice == 1)
			{
				get_new_options(NULL, &new);
				turn_recording_on(&new);
			}
			else if (choice == 2)
			{
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#endif
				break;
			}

		}
	}
	return 0;
}

/******************************************************************************/

extern int main(
	int		argc,
	char	*argv[])
{
	int				c;
	int				aflag = 0;
	int				Vflag = 0;
	int				mode = 0;
	int				rap_on;
	int				status;
	ris_rap_options new;
	ris_rap_options cur;
#if defined(DOS) || defined(WIN32)
	int				len;
	char			*dir;
#elif defined(unix)
#else
ERROR -- NO CODE
#endif
#if defined(WIN32S)
	char about[128];
#endif

	if (RISload_dll())
	{
#if defined(WIN32S)
		DestroyWindow(winio_current());
		winio_end();
#endif
		return(1);
	}
	status = SETJMP();
	if (status)
	{
		RESETJMP();
#if defined(WIN32S)
		RIS32s_file_error_box(RISUTL_I_RECRD_ERROR, 0,status,NULL,0,1);
#else
		RISuco_file_error_box(stdout, RISUTL_I_RECRD_ERROR, 0,status,NULL,0,1);
#endif
		PRINTF(CHECK_UNINIT_MSG(RISUTL_I_RECRD_COULD_NOT_INIT,
			"RIS Record Utility could not initialize... Bye\n"));
 		return(1);
	}
        /* Melania M Stewart - TR#439602049 - No RAP logging if debug is on */
	RISuco_initialize_debug_noRAP(NULL, 0);

	RISuco_initialize_ums(INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE);

	RESETJMP();
#if defined(WIN32S)
	winio_setfont(winio_current(),ANSI_FIXED_FONT);
	sprintf(about,MSG(RISUTL_I_RECRD_UTILITY), RIS_version);
	winio_about(about);
#endif

#if defined(DOS) || defined(WIN32)
	if ((dir = getenv("TMP")) == NULL)
	{
		if ((dir = getenv("TEMP")) == NULL)
		{
			dir = "\\";
		}
	}
	strcpy(DEFAULT_OUTPUT_PATH, dir);

	len = strlen(DEFAULT_OUTPUT_PATH);
	if (DEFAULT_OUTPUT_PATH[len - 1] != '\\')
	{
		DEFAULT_OUTPUT_PATH[len++] = '\\';
	}
	strcpy(DEFAULT_OUTPUT_PATH + len, DEFAULT_OUTPUT_FILENAME);
#elif defined(unix)
#else
ERROR -- NO CODE
#endif



	memset(&new, 0, sizeof(ris_rap_options));
	memset(&cur, 0, sizeof(ris_rap_options));

	while((c = getopt(argc, argv, "cdtaV?")) != -1)
	{
		switch(c)
		{
			case 'c':
				if (new.command_time)
				{
					DoUsage();
					return 1;
				}
				new.command_time = 1;
				break;

			case 'd':
				if (new.delay_time)
				{
					DoUsage();
					return 1;
				}
				new.delay_time = 1;
				break;

			case 't':
				if (new.total_time)
				{
					DoUsage();
					return 1;
				}
				new.total_time = 1;
				break;

			case 'a':
				if (aflag)
				{
					DoUsage();
					return 1;
				}
				aflag = 1;
				break;

			case 'V':
				if (Vflag)
				{
					DoUsage();
					return 1;
				}
				Vflag = 1;
				break;

			case '?':
				DoUsage();
				return 0;

			default:
				DoUsage();
				return 1;
		}
	}

	if (Vflag)
	{
		if (optind != argc || new.command_time || new.delay_time ||
			new.total_time || aflag)
		{
			DoUsage();
			return 1;
		}
		DoVersion();
		return 0;
	}

	if (optind == argc)
	{
		if (new.command_time || new.delay_time || new.total_time || aflag)
		{
			DoUsage();
			return 1;
		}
		mode = INTERACTIVE;
	}
	else if (optind == argc - 1)
	{
		if (!strcmp(argv[optind], "off"))
		{
			if (new.command_time || new.delay_time || new.total_time || aflag)
			{
				DoUsage();
				return 1;
			}
			mode = TURN_OFF;
		}
		else if (!strcmp(argv[optind], "query"))
		{
			if (new.command_time || new.delay_time || new.total_time || aflag)
			{
				DoUsage();
				return 1;
			}
			mode = QUERY;
		}
		else
		{
			DoUsage();
			return 1;
		}
	}
	else if (optind == argc - 2)
	{
		if (!strcmp(argv[optind], "on"))
		{
			optind++;
			strcpy(new.filename, argv[optind]);
			mode = TURN_ON;
		}
		else
		{
			DoUsage();
			return 1;
		}
	}
	else
	{
		DoUsage();
		return 1;
	}
	new.overwrite_file = !aflag;

	switch(mode)
	{
		case TURN_ON:
			/*
			**	Turn recording on
			*/
			rap_on = RIScom_read_rap_file(&cur, 0);
			if (rap_on)
			{
#if defined(WIN32S)
			MessageBox(winio_current(),"RIS recording is already on","RISRECRD",MB_OK);
			DestroyWindow(winio_current());
			winio_end();
			return 1;
#else
				PRINTF("RIS recording is already on.\n");
				return 1;
#endif
			}

			if (turn_recording_on(&new))
			{
				return 1;
			}
#if defined(WIN32S)
			MessageBox(winio_current(),"RIS recording has been turned on","RISRECRD",MB_OK);
			DestroyWindow(winio_current());
			winio_end();
#endif
			break;

		case TURN_OFF:
			/*
			**	Turn recording off
			*/
			rap_on = RIScom_read_rap_file(&cur, 0);
			if (!rap_on)
			{
#if defined(WIN32S)
			MessageBox(winio_current(),"RIS recording is already off","RISRECRD",MB_OK);
			DestroyWindow(winio_current());
			winio_end();
			return 1;
#else
				PRINTF("RIS recording is already off.\n");
				return 1;
#endif
			}

			if (turn_recording_off())
			{
				return 1;
			}
#if defined(WIN32S)
			MessageBox(winio_current(),"RIS recording has been turned off","RISRECRD",MB_OK);
			DestroyWindow(winio_current());
			winio_end();
#endif

			break;

		case QUERY:
			rap_on = RIScom_read_rap_file(&cur, 0);
			if (rap_on)
			{
				PRINTF("RIS recording is on.\n");
				output_options(&cur);
			}
			else
			{
				PRINTF("RIS recording is off.\n");
			}
			break;

		case INTERACTIVE:
			if (interactive())
			{
				return 1;
			}
			break;
	}
#if defined(WIN32S)
	winio_end();
#endif

	return 0;
}

/******************************************************************************/

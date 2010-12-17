/*
**	NAME:							plbmain.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
** 	Ashley 7/9/96 - fix for 439402027 
*/
 
#define DEFINE_GLOBALS

/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <ctype.h>
#include "plbck.h"
#include "risutl.h"
#include "risver.h"
#include "risrap.h"
#include "risstjmp.h"
#include "utl_err.h"
#include "utl_inf.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 
#include "comisfn.prt"
/*
**	DEFINES
*/
#define BATCH		0
#define INTERACTIVE	1

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define plbmain_c
#include "plbexec.prt"
#include "plbmain.prt"
#include "plbids.prt"
#include "plbmisc.prt"
#include "plbprint.prt"
#include "plbread.prt"
#include "ucopath.prt"
#include "comrap.prt"
#include "comjmp.prt"
#include "comumsg.prt"
#include "ucodebug.prt"
#include "ucoerrbx.prt"
#include "ucoumsg.prt"
#if defined(WIN32) || defined(DOS)
#include "comstcmi.prt"
#include "ucogtopt.prt"
#endif
#include "ris.prt"
#include "sys.prt"
#if defined(WIN32S)
#include "btcerrbx.prt"
#endif

/*
**	VARIABLES
*/
static int	mode;
extern int	optind;
extern char	*optarg;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void handler(
int sig)
{
	sig = sig;
}

/******************************************************************************/


static void DoUsage()
{
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_1));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_2));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_3));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_4));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_5));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_6));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_7));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_8));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_14));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_9));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_10));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_11));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_12));
	PRINTF(MSG(RISUTL_I_PLBCK_USAGE_13));
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
	PRINTF(MSG(RISUTL_I_PLBCK_UTILITY), RIS_version);
}

/******************************************************************************/

static int recording_overwrite()
{
	char			record_path[RIS_MAX_PATH_SIZE];
	char			playback_path[RIS_MAX_PATH_SIZE];
	ris_rap_options	options;

	int rap_on;

	rap_on = RIScom_read_rap_file(&options, 1);
	if (rap_on)
	{
		RISuco_get_full_path(options.filename, record_path);
		RISuco_get_full_path(in_filename, playback_path);
#if defined(unix)
		if (!strcmp(record_path, playback_path))
#elif defined(WIN32) || defined(DOS)
		if (!RIScom_strcmp_ic(record_path, playback_path))
#endif
		{
			return 1;
		}
	}

	return 0;
}

/******************************************************************************/

static char *get_expected_name(
	int	r)
{
	switch(r)
	{
		case EXPECTED_SUCCESS:
			return("SUCCESS");

		case EXPECTED_END_OF_DATA:
			return("END_OF_DATA");

		case EXPECTED_ERROR:
			return("ERROR");
	}
	return("UNKNOWN");
}

/******************************************************************************/

static char *get_got_name(
int	r)
{
	switch(r)
	{
		case GOT_SUCCESS:
			return("SUCCESS");

		case GOT_END_OF_DATA:
			return("END_OF_DATA");

		case GOT_ERROR:
			return("ERROR");
	}
	return("UNKNOWN");
}

/******************************************************************************/

static char *get_action_name(
int	a)
{
	switch(a)
	{
		case CONTINUE:
			return("CONTINUE");

		case STOP:
			return("STOP");

		case RETRY:
			return("RETRY");
	}
	return("UNKNOWN");
}

/******************************************************************************/

static int playback()
{
	command_info_s	cmd;
	delay_info_s	delay;
	system_info_s	sys;

	GET_NEXT_LINE(EOF_ERROR, DROP_NL);
	if (read_header())
	{
		return 1;
	}

	while (1)
	{
		GET_NEXT_LINE(EOF_OK, DROP_NL);
		if (p == NULL)
		{
			break;
		}

		if (!strncmp(p, "RIS VERSION:", 12))
		{
			if (report_errors == 0)
			{
				report_errors = 1;
				error_msg(MSG(RISUTL_I_PROCESS_CONT), p);
			}
			if (read_header())
			{
				return 1;
			}
		}
		else if (!strncmp(p, "COMMAND:", 8))
		{
			if (report_errors == 0)
			{
				report_errors = 1;
				error_msg(MSG(RISUTL_I_PROCESS_CONT), p);
			}

			memset(&cmd, 0, sizeof(cmd));
			p += 8;
			cmd.number = atoi(p);

			if (read_command(&cmd))
			{
				continue;
			}

			if (verbose)
			{
				print_command(&cmd);
			}

			if (no_action)
			{
				continue;
			}

			switch(execute_command(&cmd))
			{
				case CONTINUE:
					break;

				case STOP:
					return 1;

				case RETRY:
					FPRINTF(out_fp, "RETRY\n");
					if (execute_command(&cmd) != CONTINUE)
					{
						return 1;
					}
					break;
			}
		}
		else if (!strncmp(p, "DELAY:", 6))
		{
			if (report_errors == 0)
			{
				report_errors = 1;
				error_msg(MSG(RISUTL_I_PROCESS_CONT), p);
			}

			memset(&delay, 0, sizeof(delay));
			if (read_delay(&delay))
			{
				continue;
			}

			if (verbose)
			{
				print_delay(&delay);
			}

			if (no_action || immediate_playback)
			{
				continue;
			}

			execute_delay(&delay);
		}
		else if (!strncmp(p, "SYSTEM:", 7))
		{
			if (report_errors == 0)
			{
				report_errors = 1;
				error_msg(MSG(RISUTL_I_PROCESS_CONT), p);
			}

			memset(&sys, 0, sizeof(sys));
			if (read_system(&sys))
			{
				continue;
			}

			if (verbose)
			{
				print_system(&sys);
			}

			if (!no_action)
			{
				execute_system(&sys);
			}

			if (sys.cmd)
			{
				free(sys.cmd);
			}
		}
		else
		{
			error_msg(MSG(RISUTL_I_EXPECTED_CDS), p);
			report_errors = 0;
		}
	}

	return 0;
}
/******************************************************************************/

static int get_prompts(
	char *output_filename,
	char *input_filename)
{
	int i,j,k,x;
	char wrk[255],wrk1[255],desc[40];
	char pick;
	static char expected[3][40] = {
		"SUCCESS    ",
		"END_OF_DATA",
		"ERROR      "};

	static char got[3][40] = {
		"SUCCESS    ",
		"END_OF_DATA",
		"ERROR      "};

	while (1)
	{
		PRINTF("\n\n");

		PRINTF(" 1) Just read and validate the file.............................");
		if (no_action ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 2) Immediate playback mode.  Ignore any delays.................");
		if (immediate_playback ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 3) Calculate and evaluate command times........................");
		if (compare_command_times ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 4) Calculate and evaluate delay times..........................");
		if (compare_delay_times ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 5) Calculate and evaluate total elapsed time...................");
		if (compare_total_times ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 6) Fetch blob/text files into same files as recorded session...");
		if (fetch_blob_same_files ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 7) Verbose mode................................................");
		if (verbose ==0)
			PRINTF("[n]\n");
		else
			PRINTF("[y]\n");

		PRINTF(" 8) Write all output to ........................................");
		PRINTF("[%s]\n",output_filename);

		PRINTF(" 9) Input filename..............................................");
		PRINTF("[%s]\n\n",input_filename);

		PRINTF("10) Modify actions\n");
#if 0
		PRINTF("     Recorded Results Playback Results Actions\n\n");
		for(k=0; k<3;k++)
			for (x=0;x<3;x++)
		{
			if (action[k][x] == CONTINUE)
				strcpy(desc,"CONTINUE");
			else if (action[k][x] == STOP)
				strcpy(desc,"STOP");
			else
				strcpy(desc,"RETRY");
			PRINTF("     %s      %s      [%s]\n",expected[k], got[x],desc);
		}
#endif

		PRINTF("11) Execute Program\n");
		PRINTF("12) Exit program\n");
		PRINTF("\n   Enter your choice (1-12): ");
#if defined(WIN32S)
		GETS(wrk);
#else
		gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if (feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
		i = atoi(wrk);
		if (i == 12)
		{
			return(1);
		}
		if (i == 11)
		{
			if (strcmp(input_filename,"")==0)
			{
				PRINTF("No input file named.\n");
			}
			else
			{
				return(0);
			}
		}
		PRINTF("\n\n");

		switch (i)
		{
			case 1:
				while (1)
				{
					if (no_action == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Just read and validate the file (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);

						if (wrk[0] == 'y')
						{
							no_action = 1;
							break;
						}
						else if (wrk[0]=='n')
						{
							no_action = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 2:
				while (1)
				{	
					if (immediate_playback == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Immediate playback mode.  Ignore any delays(y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);

						if (wrk[0] == 'y')
						{
							immediate_playback = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							immediate_playback = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 3:
				while (1)
				{	
					if (compare_command_times == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Calculate and evaluate command times. (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);

						if (wrk[0] == 'y')
						{
							compare_command_times = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							compare_command_times = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 4:
				while (1)
				{	
					if (compare_delay_times == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Calculate and evaluate delay times. (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);

						if (wrk[0] == 'y')
						{
							compare_delay_times = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							compare_delay_times = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 5:
				while (1)
				{	
					if (compare_total_times == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Calculate and evaluate total elapsed time. (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);
						if (wrk[0] == 'y')
						{
							compare_total_times = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							compare_total_times = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 6:
				while (1)
				{	
					if (fetch_blob_same_files == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Fetch blob/text files into same files as recorded session. (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);
						if (wrk[0] == 'y')
						{
							fetch_blob_same_files = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							fetch_blob_same_files = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;


			case 7:
				while (1)
				{	
					if (verbose == 0)
						strcpy(wrk,"n");
					else
						strcpy(wrk,"y");
					sprintf(wrk1,"Verbose mode. (y/n)[%s]: ",wrk);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);
						if (wrk[0] == 'y')
						{
							verbose = 1;
							break;
						}
						else if (wrk[0] == 'n')
						{
							verbose = 0;
							break;
						}
						else
						{
							PRINTF("Valid responses are 'y' or 'n'\n");
						}
					}
					else
						break;
				}/* while */
				break;

			case 8:
					sprintf(wrk1,"Write all output to[%s]: ",output_filename);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						strcpy(output_filename,wrk);
					}
					else
						break;
				break;

			case 9:
					sprintf(wrk1,"Input filename [%s]: ",input_filename);
					PRINTF("%s",wrk1);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					if (strcmp(wrk,"")!=0)	
					{
						strcpy(input_filename,wrk);
					}
					else
						break;
				break;

			case 10:
				PRINTF("        Recorded Results Playback Results Actions\n\n");
				while (1)
				{
					j = 1;
					for(k=0; k<3;k++)
						for (x=0;x<3;x++)
						{
							if (action[k][x] == CONTINUE)
								strcpy(desc,"CONTINUE");
							else if (action[k][x] == STOP)
								strcpy(desc,"STOP");
							else
								strcpy(desc,"RETRY");
							PRINTF("%2d)     %s      %s      [%s]\n",j,expected[k], got[x],desc);
							j++;
						}
					PRINTF("10) Return to main menu\n\n");
					PRINTF("\n   Enter your choice: ");
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
					j = atoi(wrk);
					if (j ==10)
						break;
					else if (j <1 || j >9)
						PRINTF("Invalid choice\n");
					else
					{
						while (1)
						{
								switch (j)
								{
									case 1:
										x = action[EXPECTED_SUCCESS][GOT_SUCCESS];
										break;
									case 2:
										x = action[EXPECTED_SUCCESS][GOT_END_OF_DATA];
										break;
									case 3:
										x = action[EXPECTED_SUCCESS][GOT_ERROR];
										break;
									case 4:
										x = action[EXPECTED_END_OF_DATA][GOT_SUCCESS];
										break;
									case 5:
										x = action[EXPECTED_END_OF_DATA][GOT_END_OF_DATA];
										break;
									case 6:
										x = action[EXPECTED_END_OF_DATA][GOT_ERROR];
										break;
									case 7:
										x = action[EXPECTED_ERROR][GOT_SUCCESS];
										break;
									case 8:
										x = action[EXPECTED_ERROR][GOT_END_OF_DATA];
										break;
									case 9:
										x = action[EXPECTED_ERROR][GOT_ERROR];
										break;
								}
								if (x == CONTINUE)
									pick = 'c';
								else if (x == STOP)
									pick = 's';
								else
									pick = 'r';

							PRINTF("Enter action <c>ontinue <s>top <r>etry :[%c]",pick);
#if defined(WIN32S)
					GETS(wrk);
#else
					gets(wrk);
	/* Ashley 7/9/96 - fix for 439402027 */
        /* this is may not be valid for international code */
        /* but rislod/unlod is not internationalized on unix */
#if defined(unix)
                 if ( feof(stdin)) /* was control-D hit */
                      exit(0);
#endif
#endif
							if (strcmp(wrk,"")==0)	
								break;
							if (RIScom_isupper(wrk[0])) wrk[0] = RIScom_tolower(wrk[0]);
							if (wrk[0] == 'c' || wrk[0] == 's' || wrk[0] == 'r')
							{
								if (wrk[0] == 'c')
										x = CONTINUE;
								else if (wrk[0] == 's')
										x = STOP;
								else
										x = RETRY;
								switch (j)
								{
									case 1:
										action[EXPECTED_SUCCESS][GOT_SUCCESS] = x;
										break;
									case 2:
										action[EXPECTED_SUCCESS][GOT_END_OF_DATA] = x;
										break;
									case 3:
										action[EXPECTED_SUCCESS][GOT_ERROR] = x;
										break;
									case 4:
										action[EXPECTED_END_OF_DATA][GOT_SUCCESS] = x;
										break;
									case 5:
										action[EXPECTED_END_OF_DATA][GOT_END_OF_DATA] = x;
										break;
									case 6:
										action[EXPECTED_END_OF_DATA][GOT_ERROR] = x;
										break;
									case 7:
										action[EXPECTED_ERROR][GOT_SUCCESS] = x;
										break;
									case 8:
										action[EXPECTED_ERROR][GOT_END_OF_DATA] = x;
										break;
									case 9:
										action[EXPECTED_ERROR][GOT_ERROR] = x;
										break;

								}
								break;
							}
							else
							{
								PRINTF("Invalid action code\n");
							}
						}
					}
				}
				break;

		}/* switch */
	}/* while */
}
/******************************************************************************/

extern int main(
	int argc,
	char *argv[])
{
	int		c,x;
	int		status;
	char	input_filename[255];
	char	output_filename[255];
	char	action_filename[255];
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
		RIS32s_file_error_box(RISUTL_I_PLBCK_ERROR, 0,status,NULL,0,1);
#else
		RISuco_file_error_box(stdout, RISUTL_I_PLBCK_ERROR, 0,status,NULL,0,1);
#endif
		PRINTF(CHECK_UNINIT_MSG(RISUTL_I_PLBCK_COULD_NOT_INIT,
			"RIS Playback Utility could not initialize... Bye\n"));
 		return(1);
	}

	RISuco_initialize_debug(NULL, 0);

	RISuco_initialize_ums(INIT_UTL_UMS_FILE);

	RESETJMP();
#if defined(WIN32S)
	winio_setfont(winio_current(),ANSI_FIXED_FONT);
	sprintf(about,MSG(RISUTL_I_PLBCK_UTILITY), RIS_version);
	winio_about(about);
#endif

	strcpy(action_filename,"");
	strcpy(output_filename,"");
	strcpy(input_filename,"");

	while((c = getopt(argc, argv, "nicdtvfVo:a:?")) != -1)
	{
		switch(c)
		{
			case 'n':
				if (no_action)
				{
					DoUsage();
					return(1);
				}
				no_action = 1;
				break;

			case 'i':
				if (immediate_playback)
				{
					DoUsage();
					return(1);
				}
				immediate_playback = 1;
				break;

			case 'c':
				if (compare_command_times)
				{
					DoUsage();
					return(1);
				}
				compare_command_times = 1;
				break;

			case 'd':
				if (compare_delay_times)
				{
					DoUsage();
					return(1);
				}
				compare_delay_times = 1;
				break;

			case 't':
				if (compare_total_times)
				{
					DoUsage();
					return(1);
				}
				compare_total_times = 1;
				break;

			case 'v':
				if (verbose)
				{
					DoUsage();
					return(1);
				}
				verbose = 1;
				break;

			case 'f':
				if (fetch_blob_same_files)
				{
					DoUsage();
					return(1);
				}
				fetch_blob_same_files = 1;
				break;

			case 'V':
				if (version)
				{
					DoUsage();
					return(1);
				}
				version = 1;
				break;

			case 'o':
				if (output_filename[0])
				{
					DoUsage();
					return(1);
				}
				strcpy(output_filename, optarg);
				break;

			case 'a':
				if (action_filename[0])
				{
					DoUsage();
					return(1);
				}
				strcpy(action_filename, optarg);
				break;

			case '?':
				DoUsage();	
				return(0);

			default:
				DoUsage();	
				return(1);
		}
	}

#if defined(WIN32)
	/*
	** The if statements were added to fix TR # 439502826.
	** The version and usage option was added. GBF (9/27/95)
	*/
	if (argc == 2)
	{
		if (!strcmp(argv[1],"/V"))
		{
			if (version)
			{
				DoUsage();
				return(1);
			}
			version = 1;
		} 
		else if (!strcmp(argv[1],"/?"))
		{
			DoUsage();
			return(0);
		} 
	}
#endif

	if (version)
	{
		if (no_action || immediate_playback || compare_command_times ||
			compare_delay_times || compare_total_times || verbose ||
			fetch_blob_same_files || output_filename[0] || action_filename[0] ||
			optind != argc)
		{
			DoUsage();
			return(1);
		}

		DoVersion();
		return 0;
	}

	if (argc == 1)
	{
		mode = INTERACTIVE;
		for (c=0; c<3;c++)
		{
			for (x=0; x<3; x++)
			{
				action[c][x] = CONTINUE;
			}
		}
	}
	else
	{
		mode = BATCH;
	}

again:
	if (mode == INTERACTIVE)
	{
			if (get_prompts(output_filename,input_filename) ==1)
			{
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#else
				Exit(1);
#endif
			}
	}
	else
	{
		if (optind == argc - 1)
			strcpy(input_filename,argv[optind]);
	}

	if (strcmp(action_filename,"")!=0)
	{
		line = 0;
		in_filename = action_filename;
		if ((in_fp = fopen(action_filename, "r")) == NULL)
		{
			error_msg(MSG(RISUTL_I_CANT_OPEN_ACTION), strerror(errno));
			if (mode == INTERACTIVE)
			{
				goto again;
			}
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#else
			Exit(1);
#endif
		}
		line = 0;
		if (mode == BATCH)
			read_actions();

		fclose(in_fp);
	}

	line = 0;
	in_filename = input_filename;
	if (no_action == 0 && recording_overwrite())
	{
		error_msg(MSG(RISUTL_I_REC_OVERWRITE));
		if (mode == INTERACTIVE)
		{
				fclose(in_fp);
				goto again;
		}
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#else
		Exit(1);
#endif
	}
	if ((in_fp = fopen(input_filename, "r")) == NULL)
	{
		error_msg(MSG(RISUTL_I_CANT_OPEN_INPUT), strerror(errno));
		if (mode == INTERACTIVE)
		{
				goto again;
		}
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#else
		Exit(1);
#endif
	}

	if (strcmp(output_filename,"") !=0)
	{
		if ((out_fp = fopen(output_filename, "w")) == NULL)
		{
			PRINTF(MSG(RISUTL_I_CANT_OPEN_OUTPUT), output_filename,
				strerror(errno));
			if (mode == INTERACTIVE)
			{
					fclose(in_fp);
					goto again;
			}
#if defined(WIN32S)
				DestroyWindow(winio_current());
				winio_end();
#else
			Exit(1);
#endif
		}
	}
	else
	{
#if defined(WIN32S)
#else
		out_fp = stdout;
#endif
	}

	if (verbose)
	{
		int expected;
		int got;

		FPRINTF(out_fp, MSG(RISUTL_I_PLBCK_ACTION_HEADER));
		FPRINTF(out_fp,"--------------------------------\n");

		for (expected = 0; expected < 3; expected++)
		{
			for (got = 0; got < 3; got++)
			{
				FPRINTF(out_fp, "%-12s%-12s%-12s\n",
					get_expected_name(expected), 
					get_got_name(got), 
					get_action_name(action[expected][got]));
			}
		}
		FPRINTF(out_fp,"--------------------------------\n");
	}

#if defined(unix)
	sigset(SIGALRM, handler);
#endif
	
	initialize_ids();

	playback();

	fclose(in_fp);

	fflush(out_fp);
	if (strcmp(output_filename,"")!=0)
		fclose(out_fp);

	if (mode == INTERACTIVE)
		goto again;
	if (strcmp(output_filename,"")==0)
		fclose(out_fp);

	delete_tempfiles();
#if defined(WIN32S)
	winio_end();
#endif
	return(0);
}



/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							btcmain.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					1/14/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
*/

/*
**	DEFINES
*/
#define EDIT_GLOBAL_DEFINE
#define BATCH_GLOBAL_DEFINE

#if defined(WIN32S)
#define UTL_REPORT_ERROR(status) \
if (status == RISUTL_E_RIS_ERROR)\
{\
 if (RISutl_ris_error[0])\
 {\
  RISutl_output_ris_error(RISutl_ris_error);\
  RISutl_clear_ris_error();\
 }\
 if (RISutl_ss_error.primary.schname[0])\
 {\
  RISutl_output_ss_error(&RISutl_ss_error);\
  RISutl_clear_ss_error();\
 }\
}\
else\
{\
RIS32s_file_error_box(RISUTL_I_BATCH_ERROR,0,status,RISutl_line,0,1);\
}
#else
#define UTL_REPORT_ERROR(status) \
if (status == RISUTL_E_RIS_ERROR)\
{\
 if (RISutl_ris_error[0])\
 {\
  RISutl_output_ris_error(RISutl_ris_error);\
  RISutl_clear_ris_error();\
 }\
 if (RISutl_ss_error.primary.schname[0])\
 {\
  RISutl_output_ss_error(&RISutl_ss_error);\
  RISutl_clear_ss_error();\
 }\
}\
else\
{\
RISuco_file_error_box(outfp,RISUTL_I_BATCH_ERROR,0,status,RISutl_line,0,1);\
}
#endif
/*
**	INCLUDES
*/
#include <errno.h>
#include "batch.h"
#include "risver.h"
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#include "prog32s.h"
#endif

#if defined (WIN32)
#include <locale.h>
#endif
/*
**	FUNCTION PROTOTYPES
*/
#define btcmain_c
#include "utlprint.prt"
#include "btccmd.prt"
#include "btcmain.prt"
#include "btcinit.prt"
#include "btcterm.prt"
#include "comumsg.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "ucodebug.prt"
#include "ucoerrbx.prt"
#if defined(WIN32) || defined(DOS)
#include "ucogtopt.prt"
#endif
#include "ucoumsg.prt"
#include "utlerror.prt"
#include "utloutpt.prt"
#include "utlread.prt"
#include "ris.prt"
#include "sys.prt"
#if defined(WIN32S)
#include "btcerrbx.prt"
#endif
/*
**	VARIABLES
*/
static FILE *outfp;
extern char	*optarg;
extern int	optind;


/*
**	FUNCTIONS
*/

/******************************************************************************/
extern int main(
	int argc,
	char *argv[])
{
	int 	c;
	int		status;
	int 	oflag = 0;
	int 	iflag = 0;
	int		Vflag = 0;
	char	*debug_str = 0;
	char	inputfile[RIS_MAX_PATH_SIZE];
	char	outputfile[RIS_MAX_PATH_SIZE];
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

#if defined(WIN32S)
	outfp = NULL;
	RISbtc_outmode =0;
#else
	outfp = stdout;
	RISutl_init_printf(outfp);
#endif

	status = SETJMP();
	if (status)
	{
		RESETJMP();

		UTL_REPORT_ERROR(status);
		RISutl_printf(CHECK_UNINIT_MSG(RISUTL_I_BATCH_COULD_NOT_INIT,
			"RIS Batch Utility could not initialize... Bye\n"));
		return(1);
	}

	RISuco_initialize_debug(RISbtc_debug_info, RISbtc_debug_count);
	RISuco_initialize_ums(
		INIT_UTL_UMS_FILE|INIT_RIS_UMS_FILE|INIT_NET_UMS_FILE);

#if defined(WIN32S)
	winio_setfont(winio_current(),ANSI_FIXED_FONT);
	sprintf(about,MSG(RISUTL_I_BATCH_UTILITY), RIS_version);
	winio_about(about);
#endif
	if (argc == 1)
	{
		RISbtc_mode = INTERACTIVE_MODE;
	}
	else
	{
		RISbtc_mode = BATCH_MODE;
	}

    while((c = getopt(argc, argv, "i:o:Vtd:?")) != -1)
    {
		BTC_DBG(("main: received argument '%c'\n", c));
        switch(c)
        {
            case 'i':
                if (iflag)
                {
                    DoUsage();
					return(1);
                }
                iflag = 1;
				strcpy(inputfile,optarg);
				break;

            case 'o':
                if (oflag)
                {
                    DoUsage();
					return(1);
                }
                oflag = 1;
				strcpy(outputfile,optarg);
                break;

			case 'V':
				if (Vflag)
				{
                    DoUsage();
					return(1);
				}
				Vflag = 1;
				break;

            case 't': /* undocumented */
                RISutl_testbed_output = 1;
                break;

			case 'd': /* undocumented */
				debug_str = optarg;
				break;

            case '?':
			default:
                DoUsage();
				return(1);
        }
    }

	if (optind < argc)
    {
        DoUsage();
		return(1);
    }

	if (Vflag)
	{
		if (iflag || oflag)
		{
        	DoUsage();
			return(1);
		}
		DoVersion();
		return(1);
	}

	/*
	** Open outputfile
	*/
	if (oflag)
	{
		open_output_file(outputfile);
	}

	/*
	** Initial RIS and some util structures
	*/
	RISbtc_init();

#if defined(WIN32S)
		if ((RISbtc_mode == BATCH_MODE) && (RISbtc_outmode ==1))
		{
			/*PRINTF(MSG(RISUTL_I_COPYRIGHT));*/
			/* 1996.03.12:Alan Barksdale:TR439600483 */
			PRINTF(MSG(RISUTL_I_BEGIN_COPYRIGHT));
			PRINTF(" ");
			PRINTF(COPYRIGHTYEAR);
			PRINTF(", ");
			PRINTF(MSG(RISUTL_I_END_COPYRIGHT));
			PRINTF(MSG(RISUTL_I_BATCH_UTILITY), RIS_version);
			PRINTF("\n");
		}
#endif

/*
	** Open inputfile
	*/
	if (iflag)
	{
		RISutl_read(inputfile);
	}

	/*
	**	Process debug string
	*/
	if (debug_str)
	{
		RISint_process_debug_no_output(debug_str);
	}
#if defined (WIN32)
/* mms - TR#439503878 - To Unicode */
	setlocale (LC_ALL, "") ;
#endif
	RESETJMP();

	status = SETJMP();
    while(1)
    {
        if (status)
        {
            if (RISutl_file_tos->next && !RISutl_ignore_errors_flag)
            {
                RISutl_stop_read(STOP_READ_ERROR);
            }

            UTL_REPORT_ERROR(status);

            status = 0;
        }

#if defined(WIN32S)
		if (RISbtc_mode == INTERACTIVE_MODE && RISutl_file_tos->file == NULL)
		{
			PRINTF("%s",PROMPT1);
		}
#else
		if (RISbtc_mode == INTERACTIVE_MODE && RISutl_file_tos->file == stdin)
		{
			RISutl_printf("%s",PROMPT1);
		}
#endif

		if( iflag && !RISutl_file_tos->next )
		{
			/*
			** That is if input file found then donot process redirected stdin
			*/
			break;
		}
       	RISbtc_command();
    }

	RESETJMP();

    RISutl_terminate();

	BTC_DBG(("main(): returning.\n"));
#if defined(WIN32S)
	if (RISbtc_outmode ==1)
		DestroyWindow(winio_current());
	winio_end();
#endif
	return(0);
}
/******************************************************************************/

static void open_output_file(
	char *name)
{
	FILE *fp;

	BTC_DBG(("open_output_file(name:<%s>)\n", name));
	if ((fp = fopen(name, "w")) == NULL)
	{
		LONGJMP(RISUTL_E_CANT_OPEN_OUTPUT_FILE);
	}

	outfp = fp;
	RISutl_init_printf(outfp);
#if defined(WIN32S)
	RISbtc_outmode =1;
#endif
	BTC_DBG(("open_output_file: returning\n"));
}

/******************************************************************************/

extern void RISutl_close_files()
{
	for (; RISutl_file_tos; RISutl_file_tos = RISutl_file_tos->next)
	{
		if (RISutl_file_tos->file)
		{
			fclose(RISutl_file_tos->file);
		}
	}
#if defined(WIN32S)
		fclose(outfp);
#else
	if (outfp && outfp != stdout)
	{
		fclose(outfp);
	}
#endif
}

/******************************************************************************/

static void DoVersion()
{
	/*RISutl_printf(MSG(RISUTL_I_COPYRIGHT));*/
	/* 1996.03.12:Alan Barksdale:TR439600483 */
	RISutl_printf(MSG(RISUTL_I_BEGIN_COPYRIGHT));
	RISutl_printf(" ");
	RISutl_printf(COPYRIGHTYEAR);
	RISutl_printf(", ");
	RISutl_printf(MSG(RISUTL_I_END_COPYRIGHT));
	RISutl_printf(MSG(RISUTL_I_BATCH_UTILITY), RIS_version);

}

/******************************************************************************/

extern void DoUsage()
{
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_1));
	PRINTF("\n");
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_2));
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_3));
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_4));
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_5));
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_6));
	RISutl_printf(MSG(RISUTL_I_BATCH_USAGE_7));
}

/******************************************************************************/

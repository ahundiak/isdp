/* Do not alter this PINNACLE information:  $Revision: 1.3.28.1 $ */
/*
**      NAME:                                                   comdebug.c
**      AUTHORS:                                                Terry McIntyre
**      CREATION DATE:                                  12/91
**      ABSTRACT:
**              
**      
**      REVISION HISTORY:
**		Sept 1993	GEO		Add RIScom_voutput_debug to support exported
**							function in RIS static library for utilities
**							to use. 
**
**		TDM:11/10/93:		Added ODBC debug
**
**
**		June 1994	Jin 	Add RIScom_backup_and_reset_flags() and
**							RIScom_restore_flags()
*/
 
/*
**      INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <unistd.h>

#include "riscom.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "risdebug.h"
#include "risarch.h"
#include "risnet.h"

#if defined(unix)
# define DEBUG_DIR      "/usr/tmp/"
#endif
#if defined(vms)
# define DEBUG_DIR      "pro_dd_ris:[bin]"
#endif
#if defined(WIN32) || defined(DOS)
# define DEBUG_DIR      "c:\\tmp\\"
#endif

#define APP_DEBUG_INPUT_FILE            "risapp"
#define APP_DEFAULT_OUTPUT_FILE         "risapp.out"

#define CLI_DEBUG_INPUT_FILE            "riscli"
#define CLI_DEFAULT_OUTPUT_FILE         "riscli.out"

#define SRV_DEBUG_INPUT_FILE            "rissrv"
#define SRV_DEFAULT_OUTPUT_FILE         "rissrv.out"

#define CPP_DEBUG_INPUT_FILE            "riscpp"
#define CPP_DEFAULT_OUTPUT_FILE         "riscpp.out"

#define TCPSRV_DEBUG_INPUT_FILE         "ristcpsr"
#define TCPSRV_DEFAULT_OUTPUT_FILE      "ristcpsr.out"

#define DEFAULT_OUTPUT_FILE				"ris.out"

#ifdef DEBUG
# undef DEBUG
#endif

#define OUTPUT                  "OUTPUT:"
#define OUTPUT_SIZE             (sizeof(OUTPUT)-1)

#define DEBUG                   "DEBUG:"
#define DEBUG_SIZE              (sizeof(DEBUG)-1)

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32)
#define SLEEP                   "SLEEP:"
#define SLEEP_SIZE              (sizeof(SLEEP)-1)
#endif

#define SKIP_WHITE_SPACE(ptr)   while(RIScom_isspace(*(ptr))) (ptr)++;

/*
**      TYPES
*/
typedef struct flag_info_s
{
	char    *name;
	int      len;
	int      bit_mask;
	int     *flag;
	int      application;
	int      client;
	int      server;
	int      display; /* Display this flag in RIScom_output_debug_flags */
	int      str;     /* Can this flag be turned on and off by a debug string */
	int      str_off; /* Can this flag be turned off by "off" in a debug str */
	int      on_flag; /* Is this flag turned on before invoking RIScom_trun_off_client_flags() */
} flag_info_s;

	/*
	**      This structure contains info about debug flags.  The flags in
	**      this structure will be affected by a debug string, including
	**      the 'debug off' command.
	*/
int RIS_clnsr_flag;

static flag_info_s debug_info[] =
{
 { "app",    3, APP_DBG_BIT,     &RISapp_debug,     1, 0, 0, 1, 1, 1, 0 },
 { "arc",    3, ARC_DBG_BIT,     &ARC_debug,        1, 1, 1, 1, 1, 1, 0 },
 { "buf",    3, BUF_DBG_BIT,     &RISbuf_debug,     1, 1, 1, 1, 1, 1, 0 },
 { "cco",    3, CCO_DBG_BIT,     &RIScco_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "cli",    3, CLI_DBG_BIT,     &RIScli_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "com",    3, COM_DBG_BIT,     &RIScom_debug,     1, 1, 1, 1, 1, 1, 0 },
 { "dbs",    3, DBS_DBG_BIT,     &RISdbs_debug,     0, 0, 1, 1, 1, 1, 0 },
 { "dds",    3, DDS_DBG_BIT,     &RISdds_debug,     0, 0, 1, 1, 1, 1, 0 },
 { "dic",    3, DIC_DBG_BIT,     &RISdic_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "fil",    3, FIL_DBG_BIT,     &RISfil_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "int",    3, INT_DBG_BIT,     &RISint_debug,     1, 0, 0, 1, 1, 1, 0 },
 { "jmp",    3, JMP_DBG_BIT,     &RISjmp_debug,     1, 1, 1, 1, 1, 1, 0 },
 { "net",    3, NET_DBG_BIT,     &NET_debug,        1, 1, 1, 1, 1, 1, 0 },
 { "par",    3, PAR_DBG_BIT,     &RISpar_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "sql",    3, SQL_DBG_BIT,     &RISsql_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "srv",    3, SRV_DBG_BIT,     &RISsrv_debug,     0, 0, 1, 1, 1, 1, 0 },
 { "stmt",   4, STMT_DBG_BIT,    &RISstmt_debug,    1, 1, 0, 1, 1, 1, 0 },
 { "tree",   4, TREE_DBG_BIT,    &RIStree_debug,    1, 1, 1, 1, 1, 1, 0 },
 { "trn",    3, TRN_DBG_BIT,     &RIStrn_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "usr",    3, USR_DBG_BIT,     &RISusr_debug,     0, 1, 0, 1, 1, 1, 0 },
 { "tcpsrv", 6, TCPSRV_DBG_BIT,  &RIStcpsrv_debug,  0, 0, 0, 0, 1, 1, 0 },
 { "cpp",    3, CPP_DBG_BIT,     &RIScpp_debug,     0, 0, 0, 0, 1, 1, 0 },
 { "remote", 6, REMOTE_BIT, 	 &RIS_remote_test,  0, 1, 0, 1, 1, 0, 0 },
 { "upgrade",7, UPGRADE_BIT,	 &RIS_upgrade_flag, 1, 1, 1, 0, 1, 1, 0 },
 { "upg",    3, UPG_DBG_BIT,     &RISupg_debug,     1, 0, 0, 0, 1, 1, 0 },
#if defined(WIN32)
 { "odbc",   4, ODBC_DBG_BIT,    &RISodbc_debug,    1, 0, 0, 1, 1, 1, 0 },
#endif
 { "clnsr",  5, CLNSR_BIT,	 &RIS_clnsr_flag,   0, 0, 1, 0, 1, 1, 0 },
};
static  int debug_count = sizeof(debug_info)/sizeof(flag_info_s);

static  char debug_output_device[RIS_MAX_PATH_SIZE] = "";
static  FILE     *debug_fp = NULL;

/*
**      FUNCTIONS
*/

/******************************************************************************/

extern void RIScom_initialize_debug(
	void)
{
	char    *ptr;
	char    buf[RIS_MAX_PATH_SIZE];
	FILE    *fp;

	if (debug_output_device[0])
	{
		return;
	}

	if (APPLICATION
#if defined(WIN32)
		|| ODBCDLL
#endif
	)
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR,
			APP_DEFAULT_OUTPUT_FILE);
		sprintf(buf, "%s%s", DEBUG_DIR, APP_DEBUG_INPUT_FILE);
	}
	else if (CLIENT)
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR,
			CLI_DEFAULT_OUTPUT_FILE);
		sprintf(buf, "%s%s", DEBUG_DIR, CLI_DEBUG_INPUT_FILE);
	}
	else if (SERVER)
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR,
			SRV_DEFAULT_OUTPUT_FILE);
		sprintf(buf, "%s%s", DEBUG_DIR, SRV_DEBUG_INPUT_FILE);
	}
	else if (PREPROCESSOR)
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR,
			CPP_DEFAULT_OUTPUT_FILE);
		sprintf(buf, "%s%s", DEBUG_DIR, CPP_DEBUG_INPUT_FILE);
	}
	else if (TCPSERVER)
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR,
			TCPSRV_DEFAULT_OUTPUT_FILE);
		sprintf(buf, "%s%s", DEBUG_DIR, TCPSRV_DEBUG_INPUT_FILE);
	}
	else
	{
		sprintf(debug_output_device, "%s%s", DEBUG_DIR, DEFAULT_OUTPUT_FILE);
		return;
	}

	if ((fp = RIScom_fopen(buf, "r")) == NULL)
	{
		return;
	}

	while(RIScom_fgets(buf, sizeof(buf), fp))
	{
		if ((ptr = strrchr(buf, '\n')) != NULL)
		{
			*ptr = '\0';
		}

		if (!strncmp(buf, OUTPUT, OUTPUT_SIZE))
		{
			ptr = buf + OUTPUT_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RIScom_get_output_device_name(ptr, debug_output_device);
		}
		else if (!strncmp(buf, DEBUG, DEBUG_SIZE))
		{
			ptr = buf + DEBUG_SIZE;
			SKIP_WHITE_SPACE(ptr);
			RIScom_debug_flags(ptr, 0, 0, 0);
		}
#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32)
		else if (!strncmp(buf, SLEEP, SLEEP_SIZE))
		{
			int seconds;

			ptr = buf + SLEEP_SIZE;
			SKIP_WHITE_SPACE(ptr);
			if ((seconds = atoi(ptr)) > 0)
			{
#if defined(WIN32)
				Sleep(seconds*1000);
#else
				sleep(seconds);				
#endif
			}
		}
#endif /* unix (!sco), vms, win32 */
	}
	RIScom_fclose(fp);
}

/******************************************************************************/

extern void RIScom_set_debug_output_device(
	char    *output_device)
{
	strcpy(debug_output_device, output_device);
}

/******************************************************************************/

extern char *RIScom_debug_flags(
	char    *s,
	int             *applicationp,
	int             *clientp,
	int             *serverp)
{
	int     i;
	int toggle = 1;
	int application = 0;
	int client = 0;
	int server = 0;

	while (*s)
	{
		if (RIScom_isspace(*s))
		{
			++s;
		}
		else if (*s == '+')
		{
			toggle = 1;
			++s;
		}
		else if (*s == '-')
		{
			toggle = 0;
			++s;
		}
		else if (strncmp(s, "off", 3) == 0)
		{
			for (i = 0; i < debug_count; i++)
			{
				if (debug_info[i].str_off)
				{
					*debug_info[i].flag = 0;
				}
			}
			application = 1;
			client = 1;
			server = 1;
			s += 3;
		}
		else
		{
			/*
			**      Check for debug flags
			*/
			for (i = 0; i < debug_count; i++)
			{
				if (debug_info[i].str)
				{
					if (!strncmp(s, debug_info[i].name, debug_info[i].len))
					{
						*debug_info[i].flag = toggle;
						if (debug_info[i].application) application = 1;
						if (debug_info[i].client) client = 1;
						if (debug_info[i].server) server = 1;
						s += debug_info[i].len;
						break;
					}
				}
			}
			if (i == debug_count)
			{
				/*
				**      It wasn't a debug flag, return an error.
				*/
				if (applicationp) *applicationp = application;
				if (clientp) *clientp = client;
				if (serverp) *serverp = server;
				return s;
			}
		}
	}

	if (applicationp) *applicationp = application;
	if (clientp) *clientp = client;
	if (serverp) *serverp = server;
	return NULL;
}

/******************************************************************************/

extern unsigned int RIScom_debug_flags_to_mask(
	void)
{
	int i;
	unsigned int mask = 0;

	for (i = 0; i < debug_count; i++)
	{
		if (*debug_info[i].flag)
		{
			mask |= debug_info[i].bit_mask;
		}
	}

	return mask;
}

/******************************************************************************/

/*
**      This routine will set or clear the flags as indicated by the mask
*/
static void set_and_clear_mask_to_flags(
	unsigned int mask)
{
	int i;

	for (i = 0; i < debug_count; i++)
	{
		*debug_info[i].flag = debug_info[i].bit_mask & mask;
	}
}

/******************************************************************************/

/*
**      This routine will only set the flags as indicated by the mask.  This
**      is used to set new flags and at the same time leave previously set
**      flags still set.
*/
static void set_only_mask_to_flags(
	unsigned int mask)
{
	int i;

	for (i = 0; i < debug_count; i++)
	{
		if (debug_info[i].bit_mask & mask)
			*debug_info[i].flag = 1;
	}
}

/******************************************************************************/

extern int RIScom_debug_mask_to_flags(
	unsigned int    mask,
	unsigned int    mode)
{
	int	status;

	switch(mode)
	{
		case SET_ONLY:
			set_only_mask_to_flags(mask);
			status = 0;
			break;

		case SET_AND_CLEAR:
			set_and_clear_mask_to_flags(mask);
			status = 0;
			break;

		default:
			status = RIS_E_INTERNAL_ERROR;
			break;
	}
	return(status);
}

/******************************************************************************/

extern void RIScom_get_debug_flags(
	char *s)
{
	int	i;
	char *sp;

	sp = s;

	for (i = 0; i < debug_count; i++)
	{
		if (*debug_info[i].flag)
		{
			sp += sprintf(sp, "%s", debug_info[i].name);
		}
	}
	*sp = '\0';
}

/******************************************************************************/

extern void RIScom_output_debug_flags(
	int     (* output_func)(const char *, ...))
{
	int		i;
	char    need_newline = 0;

	for (i = 0; i < debug_count; i++)
	{
		if (debug_info[i].display)
		{
			output_func("          %-6s:%-3s", debug_info[i].name,
				*debug_info[i].flag ? "ON" : "OFF");
			if (i % 3 == 2)
			{
				output_func("\n");
				need_newline = 0;
			}
			else
			{
				need_newline = 1;
			}
		}
	}

	if (need_newline)
	{
		output_func("\n");
	}
}

/******************************************************************************/

extern void RIScom_get_output_device_name(
	char *input,
	char *output_device)
{
	char *ptr;
#if defined(__clipper__) || defined(__hpux__) 
	struct utmp *data;


	if (!strcmp(input, "/dev/console"))
	{
		strcpy(output_device, "/dev/console");
	}
	else if (!strncmp(input, "/dev/", sizeof("/dev/") - 1))
	{
		while ((data = RIScom_getutent()) != NULL)
		{
			if ((data->ut_type == USER_PROCESS ||
				data->ut_type == LOGIN_PROCESS) &&
				!strcmp(data->ut_line, input + sizeof("/dev/") - 1) &&
				data->ut_exit.e_termination == 0 &&
				data->ut_exit.e_exit == 0)
			{
				break;
			}
		}
		if (data)
		{
			strcpy(output_device, input);
		}
		else
		{
			output_device[0] = '\0';
		}
	}
	else
#endif
	{
		ptr = output_device;
		while (*input && !RIScom_isspace(*input))
		{
			if (*input == '$' && *(input+1) == '$')
			{
				ptr += sprintf(ptr, "%d", getpid());
				input += 2;
			}
			else
			{
				*ptr++ = *input++;
			}
		}
		*ptr = '\0';
	}
}

/******************************************************************************/

extern int RIScom_output_debug(
	const char *fmt,
	...)
{
	int                     sts;
	va_list         args;
	static  int      already_tried = 0;

	if (!debug_fp)
	{
		if (!debug_output_device[0] || already_tried)
		{
			return 0;
		}
		if ((debug_fp = RIScom_fopen(debug_output_device,"w")) == NULL)
		{
			already_tried = 1;
			return 0;
		}
	}

	va_start(args, fmt);
	sts = vfprintf(debug_fp, fmt, args);
	fflush(debug_fp);
	va_end(args);

	return sts;
}

/******************************************************************************/

extern int RIScom_voutput_debug(
	const char *fmt,
	va_list		args)
{
	int                     sts;
	static  int      already_tried = 0;

	if (!debug_fp)
	{
		if (!debug_output_device[0] || already_tried)
		{
			return 0;
		}
		if ((debug_fp = RIScom_fopen(debug_output_device,"w")) == NULL)
		{
			already_tried = 1;
			return 0;
		}
	}

	sts = vfprintf(debug_fp, fmt, args);
	fflush(debug_fp);

	return sts;
}

/******************************************************************************/

extern void RIScom_backup_and_reset_flags(
	int		application,
	int		client,
	int		server)
{
	int		i;

	for (i = 0; i < debug_count; i++)
	{
		if ((debug_info[i].application && application ||
			debug_info[i].client && client ||
			debug_info[i].server && server) && *debug_info[i].flag)
		{
			*debug_info[i].flag = 0;
			debug_info[i].on_flag = 1;
		}
	}
}

/******************************************************************************/

extern void RIScom_restore_flags()
{
	int		i;

	for (i = 0; i < debug_count; i++)
	{
		if (debug_info[i].on_flag)
		{
			debug_info[i].on_flag = 0;
			*debug_info[i].flag = 1;
		}
	}
}

 

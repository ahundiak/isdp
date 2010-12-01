/*
**	NAME:							appparmf.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**
**	REVISION HISTORY:
**
**		Jan. 94, Added version spec. stuff - Sanju.
**		Feb. 94, Modified for interoperability - Sanju.
**		Apr. 94, Modified for interoperability - Sanju.
**		Jun. 96, Modified for handling of path names has spaces - Ashley
**		Aug. 96, Modified for handling of path names has spaces - Surjit
*/

/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <fcntl.h>

#include "risapp.h"
#include "riscom.h"
#include "rispath.h"
#include "risdebug.h"
#include "ris_err.h"

#include "riscom_macro.h"
#include "risapp.h"

#include "risnet_shmem.h"

// #include "netshmem.h"

#define RISEXPORT

/*
**	DEFINES
*/

#define DISKLESS_PARMS_DIR		    "/var/ingr/ris"
#define DISKLESS_PARMS_FILENAME		"/var/ingr/ris/parms"

#define READ_MODE   0
#define WRITE_MODE  1

#define MAX_LOCAL_SERVERS		"MAX_LOCAL_SERVERS"
#define MAX_LOCAL_SERVERS_SIZE		(sizeof(MAX_LOCAL_SERVERS)-1)
#define MAX_LOCAL_SERVERS_SPEC		"%d"
#define MAX_LOCAL_SERVERS_MIN		  1
#define MAX_LOCAL_SERVERS_MAX		 24
#define MAX_LOCAL_SERVERS_DEFAULT	8

#define MAX_ROWS			"MAX_ROWS"
#define MAX_ROWS_SIZE			(sizeof(MAX_ROWS)-1)
#define MAX_ROWS_SPEC			"%d"
#define MAX_ROWS_MIN			1
#define MAX_ROWS_MAX			(((NET_BLOCK_SIZE * 65535) + NET_DATA_SIZE) / 8)

#define MAX_ROWS_DEFAULT		100

#define MAX_BUFFER_SIZE			"MAX_BUFFER_SIZE"
#define MAX_BUFFER_SIZE_SIZE		(sizeof(MAX_BUFFER_SIZE)-1)
#define MAX_BUFFER_SIZE_SPEC		"%d"
#define MAX_BUFFER_SIZE_MIN		66552 
#define MAX_BUFFER_SIZE_MAX		((NET_BLOCK_SIZE * 65535) + NET_DATA_SIZE)
#define MAX_BUFFER_SIZE_DEFAULT		66552

#define MAX_STATIC_STMTS		"MAX_STATIC_STMTS"
#define MAX_STATIC_STMTS_SIZE		(sizeof(MAX_STATIC_STMTS)-1)
#define MAX_STATIC_STMTS_SPEC		"%d"
#define MAX_STATIC_STMTS_MIN		0
#define MAX_STATIC_STMTS_MAX		RIS_MAX_STMTS-RIS_MAX_DICT_STMTS
#define MAX_STATIC_STMTS_DEFAULT	10


#define MAX_USER_STMTS			"MAX_USER_STMTS"
#define MAX_USER_STMTS_SIZE		(sizeof(MAX_USER_STMTS)-1)
#define MAX_USER_STMTS_SPEC		"%d"
#define MAX_USER_STMTS_MIN		1
#define MAX_USER_STMTS_MAX		RIS_MAX_STMTS-RIS_MAX_DICT_STMTS
#define MAX_USER_STMTS_DEFAULT		40


#define MAX_SECONDARY_SCHEMAS		"MAX_SECONDARY_SCHEMAS"
#define MAX_SECONDARY_SCHEMAS_SIZE	(sizeof(MAX_SECONDARY_SCHEMAS)-1)
#define MAX_SECONDARY_SCHEMAS_SPEC	"%d"
#define MAX_SECONDARY_SCHEMAS_MIN	0
#define MAX_SECONDARY_SCHEMAS_MAX	RIS_MAX_SECONDARY_SCHEMAS
#define MAX_SECONDARY_SCHEMAS_DEFAULT	0	

#define MAX_TRANSACTIONS		"MAX_TRANSACTIONS"
#define MAX_TRANSACTIONS_SIZE		(sizeof(MAX_TRANSACTIONS)-1)
#define MAX_TRANSACTIONS_SPEC		"%d"
#define MAX_TRANSACTIONS_MIN		1
#define MAX_TRANSACTIONS_MAX		RIS_MAX_TRANSACTIONS	
#define MAX_TRANSACTIONS_DEFAULT	1

#define MAX_TABLES_IN_MEM		"MAX_TABLES_IN_MEM"
#define MAX_TABLES_IN_MEM_SIZE		(sizeof(MAX_TABLES_IN_MEM)-1)
#define MAX_TABLES_IN_MEM_SPEC		"%u"
#define MAX_TABLES_IN_MEM_MIN		1
#define MAX_TABLES_IN_MEM_MAX		RIS_MAX_TAB_IN_MEM
#define MAX_TABLES_IN_MEM_DEFAULT	50

/*****************************************************************************/

#define TIMESTAMP_INTERVAL            "TIMESTAMP_INTERVAL"
#define TIMESTAMP_INTERVAL_SIZE       (sizeof(TIMESTAMP_INTERVAL)-1)
#define TIMESTAMP_INTERVAL_SPEC       "%d"
#define TIMESTAMP_INTERVAL_MIN		  RIS_TIMESTAMP_INTERVAL_MIN
#define TIMESTAMP_INTERVAL_MAX		  RIS_TIMESTAMP_INTERVAL_MAX
#define TIMESTAMP_INTERVAL_DEFAULT    0

#define INITIAL_TIMEOUT            "INITIAL_TIMEOUT"
#define INITIAL_TIMEOUT_SIZE       (sizeof(INITIAL_TIMEOUT)-1)
#define INITIAL_TIMEOUT_SPEC       "%d"
#define INITIAL_TIMEOUT_MIN		  RIS_INITIAL_TIMEOUT_MIN
#define INITIAL_TIMEOUT_MAX		  RIS_INITIAL_TIMEOUT_MAX
#define INITIAL_TIMEOUT_DEFAULT    12

#define TIMESTAMP_TOLERANCE            "TIMESTAMP_TOLERANCE"
#define TIMESTAMP_TOLERANCE_SIZE       (sizeof(TIMESTAMP_TOLERANCE)-1)
#define TIMESTAMP_TOLERANCE_SPEC       "%d"
#define TIMESTAMP_TOLERANCE_MIN		  RIS_TIMESTAMP_TOLERANCE_MIN
#define TIMESTAMP_TOLERANCE_MAX		  RIS_TIMESTAMP_TOLERANCE_MAX
#define TIMESTAMP_TOLERANCE_DEFAULT    5

#define BUFFER_FULL_SIZE            "BUFFER_FULL_SIZE"
#define BUFFER_FULL_SIZE_SIZE       (sizeof(BUFFER_FULL_SIZE)-1)
#define BUFFER_FULL_SIZE_SPEC       "%d"
#define BUFFER_FULL_SIZE_MIN		  RIS_BUFFER_FULL_SIZE_MIN
#define BUFFER_FULL_SIZE_MAX		  RIS_BUFFER_FULL_SIZE_MAX
#define BUFFER_FULL_SIZE_DEFAULT    64

#define BUFFER_FULL_TIMEOUT            "BUFFER_FULL_TIMEOUT"
#define BUFFER_FULL_TIMEOUT_SIZE       (sizeof(BUFFER_FULL_TIMEOUT)-1)
#define BUFFER_FULL_TIMEOUT_SPEC       "%d"
#define BUFFER_FULL_TIMEOUT_MIN		  RIS_BUFFER_FULL_TIMEOUT_MIN
#define BUFFER_FULL_TIMEOUT_MAX		  RIS_BUFFER_FULL_TIMEOUT_MAX
#define BUFFER_FULL_TIMEOUT_DEFAULT    12

/*****************************************************************************/

#define SF_PROTOCOL				"SCHEMA_FILE_PROTOCOL"
#define SF_PROTOCOL_SIZE		(sizeof(SF_PROTOCOL)-1)
#define SF_PROTOCOL_SPEC		"%c"
#define SF_PROTOCOL_DEFAULT		'M'

#define SF_ADDRESS				"SCHEMA_FILE_ADDRESS"
#define SF_ADDRESS_SIZE			(sizeof(SF_ADDRESS)-1)
#define SF_ADDRESS_SPEC			"%s"
#define SF_ADDRESS_DEFAULT		""

#define SF_USERNAME				"SCHEMA_FILE_USERNAME"
#define SF_USERNAME_SIZE		(sizeof(SF_USERNAME)-1)
#define SF_USERNAME_SPEC		"%s"
#define SF_USERNAME_DEFAULT		""

#define SF_PASSWORD				"SCHEMA_FILE_PASSWORD"
#define SF_PASSWORD_SIZE		(sizeof(SF_PASSWORD)-1)
#define SF_PASSWORD_SPEC		"%s"
#define SF_PASSWORD_DEFAULT		""

#define SF_FILENAME				"SCHEMA_FILE_NAME"
#define SF_FILENAME_SIZE		(sizeof(SF_FILENAME)-1)
#define SF_FILENAME_SPEC		"%s"
#define SF_FILENAME_DEFAULT		"schemas"

#define LOCK_FILE_RETRY			"LOCK_FILE_RETRY"
#define LOCK_FILE_RETRY_SIZE	(sizeof(LOCK_FILE_RETRY)-1)
#define LOCK_FILE_RETRY_SPEC	"%d"
#define LOCK_FILE_RETRY_DEFAULT	25

#define CL_PROTOCOL				"CLIENT_PROTOCOL"
#define CL_PROTOCOL_SIZE		(sizeof(CL_PROTOCOL)-1)
#define CL_PROTOCOL_SPEC		"%c"

#if 1
#define CL_PROTOCOL_DEFAULT   'M'
#define CL_ADDRESS_DEFAULT		""
#define CL_USERNAME_DEFAULT		""
#define CL_PASSWORD_DEFAULT		""
#endif

#if 0
#define CL_PROTOCOL_DEFAULT   'T'
#define CL_ADDRESS_DEFAULT		"lpd"
#define CL_USERNAME_DEFAULT		"nfmadmin"
#define CL_PASSWORD_DEFAULT		"something"
#endif

#define CL_ADDRESS				"CLIENT_ADDRESS"
#define CL_ADDRESS_SIZE			(sizeof(CL_ADDRESS)-1)
#define CL_ADDRESS_SPEC			"%s"
	
#define CL_USERNAME				"CLIENT_USERNAME"
#define CL_USERNAME_SIZE		(sizeof(CL_USERNAME)-1)
#define CL_USERNAME_SPEC		"%s"
	
#define CL_PASSWORD				"CLIENT_PASSWORD"
#define CL_PASSWORD_SIZE		(sizeof(CL_PASSWORD)-1)
#define CL_PASSWORD_SPEC		"%s"

#define CL_VERSION				"CLIENT_VERSION"
#define CL_VERSION_SIZE			(sizeof(CL_VERSION)-1)
#define CL_VERSION_SPEC			"%s"
#define CL_VERSION_DEFAULT		"0.0"
#define CL_MAJOR_DEFAULT		0
#define CL_FEATURE_DEFAULT	0

#define MAX_SIZE				MAX_SECONDARY_SCHEMAS_SIZE
	
#define SHARED_MEMORY_BIT         0x00000001
#define MAX_LOCAL_SERVERS_BIT     0x00000002
#define MAX_ROWS_BIT			        0x00000004
#define MAX_BUFFER_SIZE_BIT       0x00000008
#define MAX_STATIC_STMTS_BIT      0x00000010
#define MAX_TRANSACTIONS_BIT      0x00000020
#define MAX_TABLES_IN_MEM_BIT     0x00000040
#define SF_PROTOCOL_BIT           0x00000080
#define SF_ADDRESS_BIT            0x00000100
#define SF_USERNAME_BIT           0x00000200
#define SF_PASSWORD_BIT           0x00000400
#define SF_FILENAME_BIT           0x00000800
#define LOCK_FILE_RETRY_BIT       0x00001000
#define CL_PROTOCOL_BIT           0x00002000
#define CL_ADDRESS_BIT            0x00004000
#define CL_USERNAME_BIT           0x00008000
#define CL_PASSWORD_BIT           0x00010000
#define TIMESTAMP_INTERVAL_BIT	  0x00020000
#define INITIAL_TIMEOUT_BIT       0x00040000
#define TIMESTAMP_TOLERANCE_BIT   0x00080000
#define BUFFER_FULL_SIZE_BIT      0x00100000
#define BUFFER_FULL_TIMEOUT_BIT   0x00200000
#define MAX_USER_STMTS_BIT        0x00400000
#define MAX_SECONDARY_SCHEMAS_BIT 0x00800000
#define CL_VERSION_BIT            0x01000000

#define NEW_PARMS_MASK \
	(CL_VERSION_BIT)

#if defined(WIN32) || defined(DOS)
#define UMASK(mask) _umask(mask);
#endif
#if defined(unix)
#define UMASK(mask) umask((mode_t)mask);
#endif

typedef struct parm_info_s
{
	int	bit;
	int error;
} parm_info;

static ris_parms_s         save_parms;
static ris_client_parms_s  save_client_parms;
static ris_schfile_parms_s save_schfile_parms;

/* flag to test if the parms file needs to be rewritten as v4 compatible
    parms file or v5 parms file after reading  */
static int generate_v4comp_file = 1;

/* the following structure is not used because we do not error out
 * if we don't see a parameter in version 5 

static parm_info info[] = 
{
	{	SHARED_MEMORY_BIT,		RIS_E_NO_SHARED_MEMORY_PARM		},
	{	MAX_LOCAL_SERVERS_BIT,	RIS_E_NO_MAX_LOCAL_SERVERS_PARM	},
	{	MAX_ROWS_BIT,			RIS_E_NO_MAX_ROWS_PARM				},
	{	MAX_BUFFER_SIZE_BIT,	RIS_E_NO_MAX_BUFFER_SIZE_PARM		},
	{	MAX_STATIC_STMTS_BIT,	RIS_E_NO_MAX_STATIC_STMTS_PARM		},
	{	MAX_TRANSACTIONS_BIT,	RIS_E_NO_MAX_TRANSACTIONS_PARM		},
	{	MAX_TABLES_IN_MEM_BIT,	RIS_E_NO_MAX_TABLES_IN_MEM_PARM	},
	{	TIMESTAMP_INTERVAL_BIT,	RIS_E_NO_TIMESTAMP_INTERVAL_PARM	},
	{	INITIAL_TIMEOUT_BIT,	RIS_E_NO_INITIAL_TIMEOUT_PARM		},
	{	TIMESTAMP_TOLERANCE_BIT,RIS_E_NO_TIMESTAMP_TOLERANCE_PARM	},
	{	BUFFER_FULL_SIZE_BIT,	RIS_E_NO_BUFFER_FULL_SIZE_PARM	},
	{	BUFFER_FULL_TIMEOUT_BIT,RIS_E_NO_BUFFER_FULL_TIMEOUT_PARM	},
	{	SF_PROTOCOL_BIT,		RIS_E_NO_SCHFILE_PROTOCOL_PARM		},
	{	SF_ADDRESS_BIT,			RIS_E_NO_SCHFILE_ADDRESS_PARM		},
	{	SF_USERNAME_BIT,		RIS_E_NO_SCHFILE_USERNAME_PARM		},
	{	SF_PASSWORD_BIT,		RIS_E_NO_SCHFILE_PASSWORD_PARM		},
	{	SF_FILENAME_BIT,		RIS_E_NO_SCHFILE_NAME_PARM			},
	{	LOCK_FILE_RETRY_BIT,	RIS_E_NO_LOCK_FILE_RETRY_PARM		},
	{	CL_PROTOCOL_BIT,		RIS_E_NO_CLIENT_PROTOCOL_PARM		},
	{	CL_ADDRESS_BIT,			RIS_E_NO_CLIENT_ADDRESS_PARM		},
	{	CL_USERNAME_BIT,		RIS_E_NO_CLIENT_USERNAME_PARM		},
	{	CL_PASSWORD_BIT,		RIS_E_NO_CLIENT_PASSWORD_PARM		},
	{	CL_VERSION_BIT,			RIS_E_NO_CLIENT_VERSION_PARM		},
	{	MAX_USER_STMTS_BIT,			RIS_E_NO_MAX_USER_STMTS_PARM			},
	{	MAX_SECONDARY_SCHEMAS_BIT,	RIS_E_NO_MAX_SECONDARY_SCHEMAS_PARM	},
};
*
*
*/

/* parm_count commented out because of stuff deleted later
static int parm_count = sizeof(info)/sizeof(parm_info);
*/

/******************************************************************************/
/*  Chances are that the src string passed in will be a multi-byte string
**  and must be converted to a wide_char string since operations such as
**  RIScom_isspace and pointer incrementing will not work with multibyte
*/
static int copy_string_data(
	int		max_len,
	char	*src,
	char	*dst)
{
	int		len = 0;
#if defined(WIN32)
	wchar_t *tmp_src, *tmp_dst;
#else
	char    *tmp_src = src;
	char    *tmp_dst = dst;
#endif

#if defined(WIN32)
	/* 
	** convert mb source string to wide_char string
	*/
	RIScom_multiwide(&RISwide_ptr, 
					 &src, 
					 &RISwide_size, 
					 MULTITOWIDE,
					 0);
	tmp_src = RISwide_ptr;
	tmp_dst = tmp_src;
#endif

	/*
	** Ashley - a file name can have spaces in it 
	** while(*tmp_src && !ISSPACE(*tmp_src) )
	** while( *tmp_src && *tmp_src != WIDECHAR('\n') )
	** Surjit - fixing TR# 439601755 - PDS problem
	*/
	while (*tmp_src &&
		   (!ISSPACE(*tmp_src) ||
			*tmp_src == WIDECHAR(' ') ||
			*tmp_src == WIDECHAR('\t')))
	{
		tmp_dst[len] = *tmp_src++;
		if (++len >= max_len)
			return 1;
	}

	tmp_dst[len] = WIDECHAR('\0');

#if defined(WIN32)
	/*
	** convert the wchar string back to a multibyte string
	*/
	RIScom_wcstombs(dst, tmp_dst, max_len); 
#endif

	return 0;
}

/******************************************************************************/

static void get_parms_filename()
{
	char	*ptr;
	char 	parms_file[RIS_MAX_PATH_SIZE];

	APP_DBG(("get_parms_filename()\n"));

	if ((ptr = getenv("RIS_PARAMETERS")) != NULL)
	{
		APP_DBG(("get_parms_filename:RIS_PARAMETERS is defined as:<%s>\n",
			ptr));
		strcpy(RIS_parms_filename, ptr);
	}
	else
	{
		APP_DBG(("get_parms_file: RIS_PARAMETERS is not defined\n"));
		APP_DBG(("get_parms_file: testing if diskless machine\n"));
		if (RIScom_access(DISKLESS_PARMS_DIR, 00) == 0)
		{
			/*
			**	Diskless machine
			*/
			APP_DBG(("get_parms_file: diskless machine\n"));
			strcpy(RIS_parms_filename, DISKLESS_PARMS_FILENAME);
		}
		else
		{
			/*
			**	Not a diskless machine
			*/
			APP_DBG(("get_parms_file: not a diskless machine\n"));
			strcpy(parms_file, RIS_dir);

#if defined(unix) || defined(DOS)
			if (!RIS_development)
			{
				/*
				** For non-development, chop of the riscli or risccu or risscu
				** basename
				*/
            	if ((ptr = strrchr(parms_file, PATH_CHAR)) != NULL) /* itbokic - path */
				{
					*ptr = '\0';
				}
				else
				{
					APP_DBG(("get_parms_file:Invalid RIS_dir:<%s>\n",RIS_dir));
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}
			}
#endif
			/*
			** Default filename is "parms"
			*/
			sprintf(RIS_parms_filename,"%s%c%s", parms_file, PATH_CHAR, 
					"parms");
		}
	}
	APP_DBG(("get_parms_file: RIS_parms_filename:<%s>\n",RIS_parms_filename));
}

/******************************************************************************/

static FILE *open_parms_file(
	int		mode)
{
	FILE	*fp = NULL;

	APP_DBG(("open_parms_file(mode:%s)\n", mode == READ_MODE ? "READ":"WRITE"));

	if (!RIS_parms_filename[0])
	{
		get_parms_filename();
	}

	if (mode == READ_MODE)
	{
		APP_DBG(("open_parms_file: testing the existence of <%s>\n",
			RIS_parms_filename));
		if (RIScom_access(RIS_parms_filename, 00) == 0)
		{
			/* The file exists */
			APP_DBG(("open_parms_file: <%s> exists, opening to read\n",
				RIS_parms_filename));
			if ((fp = RIScom_fopen(RIS_parms_filename, "r")) == NULL)
			{
				APP_DBG(("open_parms_file:fopen failed:%s\n",
					strerror(errno)));
				RIScom_syserr(errno, dbca);
				sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_THE_PARAMETERS_FILE_IS),
					RIS_parms_filename);
				LONGJMP(RIS_E_CANT_GET_PARMS);
			}
		}
		else
		{
			APP_DBG(("open_parms_file: <%s> doesn't exist\n",
				RIS_parms_filename));
		}
	}
	else
	{
		int pre_umask;

		APP_DBG(("open_parms_file: opening <%s> to write\n",
			RIS_parms_filename));
        pre_umask = UMASK(0);
		if ((fp = RIScom_fopen(RIS_parms_filename, "w")) == NULL)
		{
			APP_DBG(("open_parms_file:fopen failed:%s\n",
				strerror(errno)));
			RIScom_syserr(errno, dbca);
			sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_THE_PARAMETERS_FILE_IS),
				RIS_parms_filename);
            UMASK(pre_umask);
			LONGJMP(RIS_E_CANT_GET_PARMS);
		}
        UMASK(pre_umask);
	}

	APP_DBG(("open_parms_file: returning fp:0x%x\n", fp));
	return fp;
}

/******************************************************************************/

static void load_defaults()
{
	APP_DBG(("load_defaults()\n"));
	RIS_parms.shm_seg_size = SHARED_MEMORY_DEFAULT;
	RIS_parms.max_locals = MAX_LOCAL_SERVERS_DEFAULT;
	RIS_parms.max_rows = MAX_ROWS_DEFAULT;
	RIS_parms.max_buf_size = MAX_BUFFER_SIZE_DEFAULT;
	RIS_parms.max_static_stmts = MAX_STATIC_STMTS_DEFAULT;
	RIS_parms.max_user_stmts = MAX_USER_STMTS_DEFAULT;
	RIS_parms.max_secondary_schemas = MAX_SECONDARY_SCHEMAS_DEFAULT;
	RIS_parms.max_transactions = MAX_TRANSACTIONS_DEFAULT;
	RIS_parms.max_tab_in_mem = MAX_TABLES_IN_MEM_DEFAULT;

	RIS_schfile_parms.protocol = SF_PROTOCOL_DEFAULT;
	strcpy(RIS_schfile_parms.address, SF_ADDRESS_DEFAULT);
	strcpy(RIS_schfile_parms.username, SF_USERNAME_DEFAULT);
	strcpy(RIS_schfile_parms.password, SF_PASSWORD_DEFAULT);
	strcpy(RIS_schfile_parms.filename, SF_FILENAME_DEFAULT);
	RIS_schfile_parms.lock_file_retry = LOCK_FILE_RETRY_DEFAULT;

	RIS_client_parms.protocol = CL_PROTOCOL_DEFAULT;
	strcpy(RIS_client_parms.address, CL_ADDRESS_DEFAULT);
	strcpy(RIS_client_parms.username, CL_USERNAME_DEFAULT);
	strcpy(RIS_client_parms.password, CL_PASSWORD_DEFAULT);
	RIS_client_parms.major = CL_MAJOR_DEFAULT;
	RIS_client_parms.feature = CL_FEATURE_DEFAULT;

    RIS_timestamp.timestamp_interval  = TIMESTAMP_INTERVAL_DEFAULT;
    RIS_timestamp.initial_timeout     = INITIAL_TIMEOUT_DEFAULT;
    RIS_timestamp.timestamp_tolerance = TIMESTAMP_TOLERANCE_DEFAULT;
    RIS_timestamp.buffer_full_size    = BUFFER_FULL_SIZE_DEFAULT;
    RIS_timestamp.buffer_full_timeout = BUFFER_FULL_TIMEOUT_DEFAULT;
    RIS_timestamp.response_interval   = 0;

	APP_DBG(("load_defaults:returning\n"));
}

/******************************************************************************/

extern void RISapp_read_parms_file()
{
	int				sts;
	int				line;
	int				read_mask = 0;
	char			*ptr;
	char			buf[512];
	static  FILE	*parms_fp = NULL; /* static to keep its value during LONGJMP */
	char			client_version[6];

	APP_DBG(("RISapp_read_parms_file()\n"));

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (parms_fp != NULL)
		{
			RIScom_fclose(parms_fp);
			parms_fp = NULL;
		}
		LONGJMP(sts);
	}

	/*
	**	Load the default values into the global structures.
	*/
	memset(&RIS_parms, 0, sizeof(ris_parms_s));
	memset(&RIS_client_parms, 0, sizeof(ris_client_parms_s));
	memset(&RIS_schfile_parms, 0, sizeof(ris_schfile_parms_s));
	load_defaults();

	/*
	**	Open the parms file for reading
	*/
	parms_fp = open_parms_file(READ_MODE);
	if (parms_fp == NULL)
	{
		/*
		** the parameters file doesn't exist, so create it
		*/
		generate_v4comp_file = 1;
		RISapp_write_parms_file();
	        parms_fp = open_parms_file(READ_MODE); /*try again! */

		/* couldn't read _or_ create */
	        if (parms_fp == NULL)
                {
			LONGJMP(RIS_E_BAD_PARM);
                }
	}
	if (parms_fp != NULL)
	{
		/*
		**	read the file
		*/
		line = 0;
		while(RIScom_fgets(buf, sizeof(buf), parms_fp))
		{
			line++;
			ptr = buf;

			if (*ptr == '#')
			{
				continue;
			}

			ptr = RIScom_skipwhitespace(ptr);
			if (*ptr == '\0')
			{
				continue;
			}
			
			APP_DBG(("RISapp_read_parms_file: ptr:<%s>\n", ptr));

			if (!strncmp(ptr, SHARED_MEMORY, SHARED_MEMORY_SIZE))
			{
				read_mask |= SHARED_MEMORY_BIT;

				ptr += SHARED_MEMORY_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, SHARED_MEMORY_SPEC, &RIS_parms.shm_seg_size);

				if (RIS_parms.shm_seg_size < SHARED_MEMORY_MIN ||
					RIS_parms.shm_seg_size > SHARED_MEMORY_MAX)
				{
					sprintf(RIS_ERRMSGC,
					RIScom_umsg(RIS_E_SHARED_MEMORY_MUST_BETWEEN),
						SHARED_MEMORY_MIN, SHARED_MEMORY_MAX);
					LONGJMP(RIS_E_INV_SHARED_MEMORY_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_LOCAL_SERVERS, MAX_LOCAL_SERVERS_SIZE))
			{
				read_mask |= MAX_LOCAL_SERVERS_BIT;

				ptr += MAX_LOCAL_SERVERS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_LOCAL_SERVERS_SPEC, &RIS_parms.max_locals);

				if (RIS_parms.max_locals < MAX_LOCAL_SERVERS_MIN ||
					RIS_parms.max_locals > MAX_LOCAL_SERVERS_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_LOCAL_SERVERS_MUST_BETWEEN) ,
						MAX_LOCAL_SERVERS_MIN, MAX_LOCAL_SERVERS_MAX);
					LONGJMP(RIS_E_INV_MAX_LOCAL_SERVERS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_ROWS, MAX_ROWS_SIZE))
			{
				read_mask |= MAX_ROWS_BIT;

				ptr += MAX_ROWS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_ROWS_SPEC, &RIS_parms.max_rows);

				if (RIS_parms.max_rows < MAX_ROWS_MIN ||
					RIS_parms.max_rows > MAX_ROWS_MAX)
				{
					sprintf(RIS_ERRMSGC,
					RIScom_umsg(RIS_E_MAX_ROWS_MUST_BETWEEN) ,
						MAX_ROWS_MIN, MAX_ROWS_MAX);
					LONGJMP(RIS_E_INV_MAX_ROWS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_BUFFER_SIZE, MAX_BUFFER_SIZE_SIZE))
			{
				read_mask |= MAX_BUFFER_SIZE_BIT;

				ptr += MAX_BUFFER_SIZE_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_BUFFER_SIZE_SPEC, &RIS_parms.max_buf_size);

           		if ((RIS_parms.max_buf_size < MAX_BUFFER_SIZE_MIN) ||
				    (RIS_parms.max_buf_size > MAX_BUFFER_SIZE_MAX))
           		{
					RIS_parms.max_buf_size = MAX_BUFFER_SIZE_DEFAULT;	
					APP_DBG(("RIS_parms.max_buf_size %d:\n",
						RIS_parms.max_buf_size));
           		}
			}
			else if (!strncmp(ptr, MAX_STATIC_STMTS, MAX_STATIC_STMTS_SIZE))
			{
				read_mask |= MAX_STATIC_STMTS_BIT;

				ptr += MAX_STATIC_STMTS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);


				sscanf(ptr, MAX_STATIC_STMTS_SPEC, &RIS_parms.max_static_stmts);

				if (RIS_parms.max_static_stmts < MAX_STATIC_STMTS_MIN ||
					RIS_parms.max_static_stmts > MAX_STATIC_STMTS_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_STATIC_STMTS_MUST_BETWEEN) ,
						MAX_STATIC_STMTS_MIN, MAX_STATIC_STMTS_MAX);
					LONGJMP(RIS_E_INV_MAX_STATIC_STMTS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_USER_STMTS, MAX_USER_STMTS_SIZE))
			{
				read_mask |= MAX_USER_STMTS_BIT;

				ptr += MAX_USER_STMTS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_USER_STMTS_SPEC, &RIS_parms.max_user_stmts);

				if (RIS_parms.max_user_stmts < MAX_USER_STMTS_MIN ||
					RIS_parms.max_user_stmts > MAX_USER_STMTS_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_USER_STMTS_MUST_BETWEEN) ,
						MAX_USER_STMTS_MIN, MAX_USER_STMTS_MAX);
					LONGJMP(RIS_E_INV_MAX_USER_STMTS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_SECONDARY_SCHEMAS, MAX_SECONDARY_SCHEMAS_SIZE))
			{
				read_mask |= MAX_SECONDARY_SCHEMAS_BIT;

				ptr += MAX_SECONDARY_SCHEMAS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_SECONDARY_SCHEMAS_SPEC, &RIS_parms.max_secondary_schemas);

				if (RIS_parms.max_secondary_schemas < MAX_SECONDARY_SCHEMAS_MIN ||
					RIS_parms.max_secondary_schemas > MAX_SECONDARY_SCHEMAS_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_STATIC_STMTS_MUST_BETWEEN) ,
						MAX_SECONDARY_SCHEMAS_MIN, MAX_SECONDARY_SCHEMAS_MAX);
					LONGJMP(RIS_E_INV_MAX_SECONDARY_SCHEMAS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_TRANSACTIONS, MAX_TRANSACTIONS_SIZE))
			{
				read_mask |= MAX_TRANSACTIONS_BIT;

				ptr += MAX_TRANSACTIONS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_TRANSACTIONS_SPEC, &RIS_parms.max_transactions);

				if (RIS_parms.max_transactions < MAX_TRANSACTIONS_MIN ||
					RIS_parms.max_transactions > MAX_TRANSACTIONS_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_TRANSACTIONS_MUST_BETWEEN) ,
						MAX_TRANSACTIONS_MIN, MAX_TRANSACTIONS_MAX);
					LONGJMP(RIS_E_INV_MAX_TRANSACTIONS_PARM);
				}
			}
			else if (!strncmp(ptr, MAX_TABLES_IN_MEM, MAX_TABLES_IN_MEM_SIZE))
			{
				read_mask |= MAX_TABLES_IN_MEM_BIT;

				ptr += MAX_TABLES_IN_MEM_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, MAX_TABLES_IN_MEM_SPEC, &RIS_parms.max_tab_in_mem);

				if (RIS_parms.max_tab_in_mem < MAX_TABLES_IN_MEM_MIN ||
					RIS_parms.max_tab_in_mem > MAX_TABLES_IN_MEM_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_MAX_TABLES_IN_MEM_MUST_BETWEEN) ,
						MAX_TABLES_IN_MEM_MIN, MAX_TABLES_IN_MEM_MAX);
					LONGJMP(RIS_E_INV_MAX_TABLES_IN_MEM_PARM);
				}
			}
			else if (!strncmp(ptr, TIMESTAMP_INTERVAL, TIMESTAMP_INTERVAL_SIZE))
			{
				read_mask |= TIMESTAMP_INTERVAL_BIT;

				ptr += TIMESTAMP_INTERVAL_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, TIMESTAMP_INTERVAL_SPEC,
					&RIS_timestamp.timestamp_interval);

				if ((int)RIS_timestamp.timestamp_interval <
					TIMESTAMP_INTERVAL_MIN ||
					(int)RIS_timestamp.timestamp_interval >
					TIMESTAMP_INTERVAL_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_TIMESTAMP_INTERVAL_MUST_BETWEEN) ,
						TIMESTAMP_INTERVAL_MIN, TIMESTAMP_INTERVAL_MAX);
					LONGJMP(RIS_E_INV_TIMESTAMP_INTERVAL_PARM);
				}
			}
			else if (!strncmp(ptr, INITIAL_TIMEOUT, INITIAL_TIMEOUT_SIZE))
			{
				read_mask |= INITIAL_TIMEOUT_BIT;

				ptr += INITIAL_TIMEOUT_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, INITIAL_TIMEOUT_SPEC,
					&RIS_timestamp.initial_timeout);

				if ((int)RIS_timestamp.initial_timeout < INITIAL_TIMEOUT_MIN ||
					(int)RIS_timestamp.initial_timeout > INITIAL_TIMEOUT_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_INITIAL_TIMEOUT_MUST_BETWEEN) ,
						INITIAL_TIMEOUT_MIN, INITIAL_TIMEOUT_MAX);
					LONGJMP(RIS_E_INV_INITIAL_TIMEOUT_PARM);
				}
			}
			else if (!strncmp(ptr, TIMESTAMP_TOLERANCE, TIMESTAMP_TOLERANCE_SIZE))
			{
				read_mask |= TIMESTAMP_TOLERANCE_BIT;

				ptr += TIMESTAMP_TOLERANCE_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, TIMESTAMP_TOLERANCE_SPEC,
					&RIS_timestamp.timestamp_tolerance);

				if ((int)RIS_timestamp.timestamp_tolerance <
					TIMESTAMP_TOLERANCE_MIN ||
					(int)RIS_timestamp.timestamp_tolerance >
					TIMESTAMP_TOLERANCE_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_TIMESTAMP_TOLERANCE_MUST_BETWEEN),
						TIMESTAMP_TOLERANCE_MIN, TIMESTAMP_TOLERANCE_MAX);
					LONGJMP(RIS_E_INV_TIMESTAMP_TOLERANCE_PARM);
				}
			}
			else if (!strncmp(ptr, BUFFER_FULL_SIZE, BUFFER_FULL_SIZE_SIZE))
			{
				read_mask |= BUFFER_FULL_SIZE_BIT;

				ptr += BUFFER_FULL_SIZE_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, BUFFER_FULL_SIZE_SPEC, &RIS_timestamp.buffer_full_size);

				if (RIS_timestamp.buffer_full_size < BUFFER_FULL_SIZE_MIN ||
					RIS_timestamp.buffer_full_size > BUFFER_FULL_SIZE_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_BUFFER_FULL_SIZE_MUST_BETWEEN) ,
						BUFFER_FULL_SIZE_MIN, BUFFER_FULL_SIZE_MAX);
					LONGJMP(RIS_E_INV_BUFFER_FULL_SIZE_PARM);
				}
			}
			else if (!strncmp(ptr, BUFFER_FULL_TIMEOUT, BUFFER_FULL_TIMEOUT_SIZE))
			{
				read_mask |= BUFFER_FULL_TIMEOUT_BIT;

				ptr += BUFFER_FULL_TIMEOUT_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, BUFFER_FULL_TIMEOUT_SPEC,
					&RIS_timestamp.buffer_full_timeout);

				if ((int)RIS_timestamp.buffer_full_timeout <
					BUFFER_FULL_TIMEOUT_MIN ||
					(int)RIS_timestamp.buffer_full_timeout >
					BUFFER_FULL_TIMEOUT_MAX)
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_BUFFER_FULL_TIMEOUT_MUST_BETWEEN),
						BUFFER_FULL_TIMEOUT_MIN, BUFFER_FULL_TIMEOUT_MAX);
					LONGJMP(RIS_E_INV_BUFFER_FULL_TIMEOUT_PARM);
				}
			}
			else if (!strncmp(ptr, SF_PROTOCOL, SF_PROTOCOL_SIZE))
			{
				read_mask |= SF_PROTOCOL_BIT;

				ptr += SF_PROTOCOL_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, SF_PROTOCOL_SPEC, &RIS_schfile_parms.protocol);

				if (ISLOWER(RIS_schfile_parms.protocol))
				{
					RIS_schfile_parms.protocol =
						(char)RIScom_toupper(RIS_schfile_parms.protocol);
				}
				if (!VALID_PROTOCOL(RIS_schfile_parms.protocol))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_EXPECTED_M_X_T_D) ,
						RIScom_isprint(RIS_schfile_parms.protocol) ?
						RIS_schfile_parms.protocol:' ');
					LONGJMP(RIS_E_INV_SCHFILE_PROTOCOL_PARM);
				}
			}
			else if (!strncmp(ptr, SF_ADDRESS, SF_ADDRESS_SIZE))
			{
				read_mask |= SF_ADDRESS_BIT;

				ptr += SF_ADDRESS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				if (copy_string_data(RIS_MAX_NODE_SIZE, ptr,
					RIS_schfile_parms.address))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_ADDRESS_CAN_NOT_LONGER) ,
						RIS_MAX_NODE_SIZE - 1);
					LONGJMP(RIS_E_INV_SCHFILE_ADDRESS_PARM);
				}
			}
			else if (!strncmp(ptr, SF_USERNAME, SF_USERNAME_SIZE))
			{
				read_mask |= SF_USERNAME_BIT;

				ptr += SF_USERNAME_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				if (copy_string_data(RIS_MAX_ID_SIZE, ptr,
					RIS_schfile_parms.username))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_USERNAME_CAN_NOT_LONGER) ,
						RIS_MAX_ID_SIZE - 1);
					LONGJMP(RIS_E_INV_SCHFILE_USERNAME_PARM);
				}
			}
			else if (!strncmp(ptr, SF_PASSWORD, SF_PASSWORD_SIZE))
			{
				read_mask |= SF_PASSWORD_BIT;

				ptr += SF_PASSWORD_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, SF_PASSWORD_SPEC, RIS_schfile_parms.password);
			}
			else if (!strncmp(ptr, SF_FILENAME, SF_FILENAME_SIZE))
			{
				read_mask |= SF_FILENAME_BIT;

				ptr += SF_FILENAME_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				if (copy_string_data(RIS_MAX_PATH_SIZE, ptr,
					RIS_schfile_parms.filename))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_FILENAME_CAN_NOT_LONGER) ,
						RIS_MAX_PATH_SIZE - 1);
					LONGJMP(RIS_E_INV_SCHFILE_NAME_PARM);
				}
			}
			else if (!strncmp(ptr, LOCK_FILE_RETRY, LOCK_FILE_RETRY_SIZE))
			{
				read_mask |= LOCK_FILE_RETRY_BIT;

				ptr += LOCK_FILE_RETRY_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, LOCK_FILE_RETRY_SPEC,
					&RIS_schfile_parms.lock_file_retry);
			}
			else if (!strncmp(ptr, CL_PROTOCOL, CL_PROTOCOL_SIZE))
			{
				read_mask |= CL_PROTOCOL_BIT;

				ptr += CL_PROTOCOL_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, CL_PROTOCOL_SPEC, &RIS_client_parms.protocol);
				if (RIScom_islower(RIS_client_parms.protocol))
				{
					RIS_client_parms.protocol =
						(char)RIScom_toupper(RIS_client_parms.protocol);
				}
				if (!VALID_PROTOCOL(RIS_client_parms.protocol))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_EXPECTED_M_X_T_D) ,
						RIScom_isprint(RIS_schfile_parms.protocol) ?
						RIS_schfile_parms.protocol:' ');
					LONGJMP(RIS_E_INV_CLIENT_PROTOCOL_PARM);
				}
			}
			else if (!strncmp(ptr, CL_ADDRESS, CL_ADDRESS_SIZE))
			{
				read_mask |= CL_ADDRESS_BIT;

				ptr += CL_ADDRESS_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				if (copy_string_data(RIS_MAX_NODE_SIZE, ptr,
					RIS_client_parms.address))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_ADDRESS_CAN_NOT_LONGER) ,
						RIS_MAX_NODE_SIZE - 1);
					LONGJMP(RIS_E_INV_CLIENT_ADDRESS_PARM);
				}
			}
			else if (!strncmp(ptr, CL_USERNAME, CL_USERNAME_SIZE))
			{
				read_mask |= CL_USERNAME_BIT;

				ptr += CL_USERNAME_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				if (copy_string_data(RIS_MAX_ID_SIZE, ptr,
					RIS_client_parms.username))
				{
					sprintf(RIS_ERRMSGC,
						RIScom_umsg(RIS_E_USERNAME_CAN_NOT_LONGER) ,
						RIS_MAX_ID_SIZE - 1);
					LONGJMP(RIS_E_INV_CLIENT_USERNAME_PARM);
				}
			}
			else if (!strncmp(ptr, CL_PASSWORD, CL_PASSWORD_SIZE))
			{
				read_mask |= CL_PASSWORD_BIT;

				ptr += CL_PASSWORD_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

				sscanf(ptr, CL_PASSWORD_SPEC, RIS_client_parms.password);
			}
			else if (!strncmp(ptr, CL_VERSION, CL_VERSION_SIZE))
			{
				generate_v4comp_file = 0;
				read_mask |= CL_VERSION_BIT;
			APP_DBG(("RISapp_read_parms_file:CL_VERSION ---- ptr:%s\n",ptr));

				ptr += CL_VERSION_SIZE;
				ptr = RIScom_skipwhitespace(ptr);

			APP_DBG(("RISapp_read_parms_file:CL_VERSION ---- ptr:%s\n",ptr));
			APP_DBG(("RISapp_read_parms_file:CL_VERSION ---- ptr---length:%d\n",
				strlen(ptr)));

				if (strlen(ptr) > 6)
				{
					LONGJMP(RIS_E_VERSION_CAN_NOT_LONGER);
				}
				else
				{
					strncpy(client_version, ptr, (strlen(ptr)-1)); /*itbokic */
					client_version[strlen(ptr)-1]='\0';
				}
			APP_DBG(("RISapp_read_parms_file:client_version :%s\n",client_version));
				if ((RIS_client_parms.major =
						RIScom_ver_str_to_number(strtok(client_version, ".")) /* itbokic - version string */
					) == -2)
				{
			APP_DBG(("RIS_client_parms.major::%d\n",RIS_client_parms.major));
					LONGJMP(RIS_E_READ_INVALID_CLIENT_VERSION);
				}
				if ((RIS_client_parms.feature =
						RIScom_ver_str_to_number(strtok((char *) 0, "."))) == -2) /* itbokic - version string */
				{
					LONGJMP(RIS_E_READ_INVALID_CLIENT_VERSION);
				}
				if (strtok((char *) 0, ".")) /* itbokic - version string */
				{
					LONGJMP(RIS_E_READ_INVALID_CLIENT_VERSION);
				}
			APP_DBG(("RISapp_read_parms_file:RIS_client_parms.major :%d\n",
				RIS_client_parms.major));
			APP_DBG(("RISapp_read_parms_file:RIS_client_parms.feature :%d\n",
				RIS_client_parms.feature));
			}
			
#ifdef OLD
			/*
			**	Donot error out for interoperability - Sanju
			*/
			else
			{
				sprintf(RIS_ERRMSGC,
					RIScom_umsg(RIS_E_THE_BAD_PARAMETER_WAS_ON_LINE) , line);
				LONGJMP(RIS_E_BAD_PARM);
			}
#endif
		}
		RESETJMP();

		RIScom_fclose(parms_fp);
		parms_fp = NULL;

		/*
		** Also, modify read_mask so it appears as if the new fields were read.
		*/

		APP_DBG(("RISapp_read_parms_file:read_mask:0x%x NEW_PARMS_MASK:0x%x\n",
			read_mask, NEW_PARMS_MASK));
		if ((read_mask & NEW_PARMS_MASK) == 0)
		{
			read_mask |= NEW_PARMS_MASK;
            		/*
            		**  Fill in the default values for the new entries.
            		*/
            		RIS_client_parms.major = CL_MAJOR_DEFAULT;
            		RIS_client_parms.feature = CL_FEATURE_DEFAULT;
			APP_DBG(("RISapp_read_parms_file:adjusted read_mask:0x%x\n",
				read_mask));
		}

		/*
		** The following is commented out because we want the version 5
		** application to be able to proceed even if any parameter is missing.
		*/
		/*
		**	Check if all parms were read
		{
			int	i;
			for (i = 0; i < parm_count; i++)
			{
				if ((read_mask & info[i].bit) == 0)
				{
					APP_DBG(("RISapp_read_parms_file: missing parameter\n"));
					LONGJMP(info[i].error);
				}
			}
		}
		*/

        	/*
        	**  max_secondary_schemas should be less than max_transactions
        	**  max_transactions should atleast be 1 (primary) + max_secondary
        	*/
        	if( RIS_parms.max_transactions < (1 + RIS_parms.max_secondary_schemas) )
        	{
			LONGJMP(RIS_E_INV_TRANS_N_SECONDARY_SCHS);
        	}

		/*
		**	validate schema spec.
		*/
		RISapp_validate_schfile_spec(RIS_schfile_parms.protocol,
			RIS_schfile_parms.address, RIS_schfile_parms.username,
			RIS_schfile_parms.password, RIS_schfile_parms.filename);

		/*
		**	validate client spec.
		*/
		RISapp_validate_client_spec(RIS_client_parms.protocol,
			RIS_client_parms.address, RIS_client_parms.username,
			RIS_client_parms.password, RIS_client_parms.major);



		if (RISapp_debug)
		{
			RIScom_output_debug("RISapp_read_parms_file: sf_protocol:<%c>\n",
				RIS_schfile_parms.protocol);
			RIScom_output_debug("RISapp_read_parms_file: sf_address:<%s>\n",
				RIS_schfile_parms.address);
			RIScom_output_debug("RISapp_read_parms_file: sf_username:<%s>\n",
				RIS_schfile_parms.username);
			RIScom_output_debug("RISapp_read_parms_file: sf_filename:<%s>\n",
				RIS_schfile_parms.filename);

			RIScom_output_debug("RISapp_read_parms_file: lock_file_retry:%d\n",
				RIS_schfile_parms.lock_file_retry);

			RIScom_output_debug("RISapp_read_parms_file: cl_protocol:<%c>\n",
				RIS_client_parms.protocol);
			RIScom_output_debug("RISapp_read_parms_file: cl_address:<%s>\n",
				RIS_client_parms.address);
			RIScom_output_debug("RISapp_read_parms_file: cl_username:<%s>\n",
				RIS_client_parms.username);
			RIScom_output_debug("RISapp_read_parms_file: cl_major:<%d>\n",
				RIS_client_parms.major);
			RIScom_output_debug("RISapp_read_parms_file: cl_feature:<%d>\n",
				RIS_client_parms.feature);

			RIScom_output_debug("RISapp_read_parms_file: shm_seg_size:0x%x\n",
				RIS_parms.shm_seg_size);
			RIScom_output_debug("RISapp_read_parms_file: max_locals:%d\n",
				RIS_parms.max_locals);
			RIScom_output_debug("RISapp_read_parms_file: max_rows:%d\n",
				RIS_parms.max_rows);
			RIScom_output_debug("RISapp_read_parms_file: max_buf_size:%d\n",
				RIS_parms.max_buf_size);
			RIScom_output_debug("RISapp_read_parms_file: max_static_stmts:%d\n",
				RIS_parms.max_static_stmts);
			RIScom_output_debug("RISapp_read_parms_file: max_user_stmts:%d\n",
				RIS_parms.max_user_stmts);
			RIScom_output_debug("RISapp_read_parms_file: max_secondary_schemas:%d\n",
				RIS_parms.max_secondary_schemas);
			RIScom_output_debug("RISapp_read_parms_file: max_transactions:%d\n",
				RIS_parms.max_transactions);
			RIScom_output_debug("RISapp_read_parms_file: max_tab_in_mem:%d\n",
				RIS_parms.max_tab_in_mem);

            RIScom_output_debug("RISapp_read_parms_file: timestamp_interval:%d\n",
				RIS_timestamp.timestamp_interval);
            RIScom_output_debug("RISapp_read_parms_file: initial_timeout:%d\n",
				RIS_timestamp.initial_timeout);
            RIScom_output_debug("RISapp_read_parms_file: timestamp_tolerance:%d\n",
				RIS_timestamp.timestamp_tolerance);
            RIScom_output_debug("RISapp_read_parms_file: buffer_full_size:%d\n",
				RIS_timestamp.buffer_full_size);
            RIScom_output_debug("RISapp_read_parms_file: buffer_full_timeout:%d\n",
				RIS_timestamp.buffer_full_timeout);
		}
	}

	APP_DBG(("RISapp_read_parms_file: complete\n"));
}

/******************************************************************************/

static void write_comment(
	FILE	*fp,
	char	*name)
{
	int		i;
	int		len;
	int		offset = 0;
	char	*ptr;
	char	s[82];
    char    *ums_txt;
    char    msg_key[48];

	memset(s, '#', 80);
	s[80] = '\n';
	s[81] = '\0';
	RIScom_fputs(s, fp);

	len = strlen(name);
	if (len) {
		offset = (80 - len)/2 - 1;
		ptr = s + offset;
		*ptr++ = ' ';
		memcpy(ptr, name, len);
		ptr += len;
		*ptr++ = ' ';
	}
	RIScom_fputs(s, fp);

	if (len)
	{
		memset(s + offset, '#', len + 2);
	}
	RIScom_fputs(s, fp);

	RIScom_fputs("#\n", fp);

    i = 1;
    sprintf(msg_key, "RIS:%s_%d", name, i++);
    while ((ums_txt = RIScom_umsg_by_key(msg_key)) != 0)
    {
        fprintf(fp, "# %s\n", ums_txt);
        sprintf(msg_key, "RIS:%s_%d", name, i++);
    }

	RIScom_fputs("#\n", fp);

}

/******************************************************************************/

extern void RISapp_write_parms_file()
{
	int		sts;
	char cli_major[3];
	char cli_feature[3];
	char cli_version[6];


	static  FILE	*parms_fp = NULL; /* static to keep its value during LONGJMP */

	APP_DBG(("RISapp_write_parms_file()\n"));

	if (RISapp_debug)
	{
		RIScom_output_debug("RISapp_write_parms_file: sf_protocol:<%c>\n",
			RIS_schfile_parms.protocol);
		RIScom_output_debug("RISapp_write_parms_file: sf_address:<%s>\n",
			RIS_schfile_parms.address);
		RIScom_output_debug("RISapp_write_parms_file: sf_username:<%s>\n",
			RIS_schfile_parms.username);
		RIScom_output_debug("RISapp_write_parms_file: sf_filename:<%s>\n",
			RIS_schfile_parms.filename);

		RIScom_output_debug("RISapp_write_parms_file: lock_file_retry:%d\n",
			RIS_schfile_parms.lock_file_retry);

		RIScom_output_debug("RISapp_write_parms_file: cl_protocol:<%c>\n",
			RIS_client_parms.protocol);
		RIScom_output_debug("RISapp_write_parms_file: cl_address:<%s>\n",
			RIS_client_parms.address);
		RIScom_output_debug("RISapp_write_parms_file: cl_username:<%s>\n",
			RIS_client_parms.username);
		RIScom_output_debug("RISapp_write_parms_file: cl_major:<%d>\n",
			RIS_client_parms.major);
		RIScom_output_debug("RISapp_write_parms_file: cl_feature:<%d>\n",
			RIS_client_parms.feature);

		RIScom_output_debug("RISapp_write_parms_file: shm_seg_size:0x%x\n",
			RIS_parms.shm_seg_size);
		RIScom_output_debug("RISapp_write_parms_file: max_locals:%d\n",
			RIS_parms.max_locals);
		RIScom_output_debug("RISapp_write_parms_file: max_rows:%u\n",
			RIS_parms.max_rows);
		RIScom_output_debug("RISapp_write_parms_file: max_buf_size:%u\n",
			RIS_parms.max_buf_size);
		RIScom_output_debug("RISapp_read_parms_file: max_user_stmts:%d\n",
			RIS_parms.max_user_stmts);
		RIScom_output_debug("RISapp_read_parms_file: max_secondary_schemas:%d\n",
			RIS_parms.max_secondary_schemas);

		RIScom_output_debug("RISapp_write_parms_file: timestamp_interval:%d\n",
			RIS_timestamp.timestamp_interval);
		RIScom_output_debug("RISapp_write_parms_file: initial_timeout:%d\n",
			RIS_timestamp.initial_timeout);
		RIScom_output_debug("RISapp_write_parms_file: timestamp_tolerance:%d\n",
			RIS_timestamp.timestamp_tolerance);
		RIScom_output_debug("RISapp_write_parms_file: buffer_full_size:%d\n",
			RIS_timestamp.buffer_full_size);
		RIScom_output_debug("RISapp_write_parms_file: buffer_full_timeout:%d\n",
			RIS_timestamp.buffer_full_timeout);
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (parms_fp != NULL)
		{
			RIScom_fclose(parms_fp);
			parms_fp = NULL;
		}
		LONGJMP(sts);
	}

	parms_fp = open_parms_file(WRITE_MODE);

	/*
	**	SHARED_MEMORY
	*/
	write_comment(parms_fp, "SHARED_MEMORY");
	fprintf(parms_fp, "# %s minimum: 0x%x\n", SHARED_MEMORY, SHARED_MEMORY_MIN);
	fprintf(parms_fp, "# %s maximum: 0x%x\n", SHARED_MEMORY, SHARED_MEMORY_MAX);
	fprintf(parms_fp, "# %s default: 0x%x\n", SHARED_MEMORY,
		SHARED_MEMORY_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SHARED_MEMORY);
	fprintf(parms_fp, SHARED_MEMORY_SPEC, RIS_parms.shm_seg_size);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_LOCAL_SERVERS
	*/
	write_comment(parms_fp, "MAX_LOCAL_SERVERS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_LOCAL_SERVERS,
		MAX_LOCAL_SERVERS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_LOCAL_SERVERS,
		MAX_LOCAL_SERVERS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_LOCAL_SERVERS,
		MAX_LOCAL_SERVERS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_LOCAL_SERVERS);
	fprintf(parms_fp, MAX_LOCAL_SERVERS_SPEC, RIS_parms.max_locals);
	RIScom_fputs("\n#\n", parms_fp);
	
	/*
	**	MAX_ROWS
	*/
	write_comment(parms_fp, "MAX_ROWS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_ROWS, MAX_ROWS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_ROWS, MAX_ROWS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_ROWS, MAX_ROWS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_ROWS);
	fprintf(parms_fp, MAX_ROWS_SPEC, RIS_parms.max_rows);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_BUFFER_SIZE
	*/
		write_comment(parms_fp, "MAX_BUFFER_SIZE");
		fprintf(parms_fp, "# %s minimum: %d\n", MAX_BUFFER_SIZE,
			MAX_BUFFER_SIZE_MIN);
		fprintf(parms_fp, "# %s maximum: %d\n", MAX_BUFFER_SIZE,
			MAX_BUFFER_SIZE_MAX);
		fprintf(parms_fp, "# %s default: %d\n", MAX_BUFFER_SIZE,
			MAX_BUFFER_SIZE_DEFAULT);
		RIScom_fputs("#\n", parms_fp);
		fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_BUFFER_SIZE);
		fprintf(parms_fp, MAX_BUFFER_SIZE_SPEC, RIS_parms.max_buf_size);
		RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_STATIC_STMTS
	*/
	write_comment(parms_fp, "MAX_STATIC_STMTS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_STATIC_STMTS,
		MAX_STATIC_STMTS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_STATIC_STMTS,
		MAX_STATIC_STMTS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_STATIC_STMTS,
		MAX_STATIC_STMTS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_STATIC_STMTS);
	fprintf(parms_fp, MAX_STATIC_STMTS_SPEC, RIS_parms.max_static_stmts);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_USER_STMTS
	*/
	write_comment(parms_fp, "MAX_USER_STMTS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_USER_STMTS,
		MAX_USER_STMTS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_USER_STMTS,
		MAX_USER_STMTS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_USER_STMTS,
		MAX_USER_STMTS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_USER_STMTS);
	fprintf(parms_fp, MAX_USER_STMTS_SPEC, RIS_parms.max_user_stmts);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_SECONDARY_SCHEMAS
	*/
	write_comment(parms_fp, "MAX_SECONDARY_SCHEMAS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_SECONDARY_SCHEMAS,
		MAX_SECONDARY_SCHEMAS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_SECONDARY_SCHEMAS,
		MAX_SECONDARY_SCHEMAS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_SECONDARY_SCHEMAS,
		MAX_SECONDARY_SCHEMAS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_SECONDARY_SCHEMAS);
	fprintf(parms_fp, MAX_SECONDARY_SCHEMAS_SPEC, RIS_parms.max_secondary_schemas);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_TRANSACTIONS
	*/
	write_comment(parms_fp, "MAX_TRANSACTIONS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_TRANSACTIONS,
		MAX_TRANSACTIONS_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_TRANSACTIONS,
		MAX_TRANSACTIONS_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_TRANSACTIONS,
		MAX_TRANSACTIONS_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_TRANSACTIONS);
	fprintf(parms_fp, MAX_TRANSACTIONS_SPEC, RIS_parms.max_transactions);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	MAX_TABLES_IN_MEM
	*/
	write_comment(parms_fp, "MAX_TABS");
	fprintf(parms_fp, "# %s minimum: %d\n", MAX_TABLES_IN_MEM,
		MAX_TABLES_IN_MEM_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", MAX_TABLES_IN_MEM,
		MAX_TABLES_IN_MEM_MAX);
	fprintf(parms_fp, "# %s default: %d\n", MAX_TABLES_IN_MEM,
		MAX_TABLES_IN_MEM_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, MAX_TABLES_IN_MEM);
	fprintf(parms_fp, MAX_TABLES_IN_MEM_SPEC, RIS_parms.max_tab_in_mem);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**  NETWORK VERIFICATION PARAMETERS
	*/
	write_comment(parms_fp, "NET_VERIFY");

	fprintf(parms_fp, "# %s minimum: %d\n", TIMESTAMP_INTERVAL,
		TIMESTAMP_INTERVAL_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", TIMESTAMP_INTERVAL,
		TIMESTAMP_INTERVAL_MAX);
	fprintf(parms_fp, "# %s default: %d\n", TIMESTAMP_INTERVAL,
		TIMESTAMP_INTERVAL_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "# %s minimum: %d\n", INITIAL_TIMEOUT,
		INITIAL_TIMEOUT_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", INITIAL_TIMEOUT,
		INITIAL_TIMEOUT_MAX);
	fprintf(parms_fp, "# %s default: %d\n", INITIAL_TIMEOUT,
		INITIAL_TIMEOUT_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "# %s minimum: %d\n", TIMESTAMP_TOLERANCE,
		TIMESTAMP_TOLERANCE_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", TIMESTAMP_TOLERANCE,
		TIMESTAMP_TOLERANCE_MAX);
	fprintf(parms_fp, "# %s default: %d\n", TIMESTAMP_TOLERANCE,
		TIMESTAMP_TOLERANCE_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "# %s minimum: %d\n", BUFFER_FULL_SIZE,
		BUFFER_FULL_SIZE_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", BUFFER_FULL_SIZE,
		BUFFER_FULL_SIZE_MAX);
	fprintf(parms_fp, "# %s default: %d\n", BUFFER_FULL_SIZE,
		BUFFER_FULL_SIZE_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "# %s minimum: %d\n", BUFFER_FULL_TIMEOUT,
		BUFFER_FULL_TIMEOUT_MIN);
	fprintf(parms_fp, "# %s maximum: %d\n", BUFFER_FULL_TIMEOUT,
		BUFFER_FULL_TIMEOUT_MAX);
	fprintf(parms_fp, "# %s default: %d\n", BUFFER_FULL_TIMEOUT,
		BUFFER_FULL_TIMEOUT_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, TIMESTAMP_INTERVAL);
	fprintf(parms_fp, TIMESTAMP_INTERVAL_SPEC, 
		RIS_timestamp.timestamp_interval);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, INITIAL_TIMEOUT);
	fprintf(parms_fp, INITIAL_TIMEOUT_SPEC, RIS_timestamp.initial_timeout);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, TIMESTAMP_TOLERANCE);
	fprintf(parms_fp, TIMESTAMP_TOLERANCE_SPEC, 
		RIS_timestamp.timestamp_tolerance);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, BUFFER_FULL_SIZE);
	fprintf(parms_fp, BUFFER_FULL_SIZE_SPEC, RIS_timestamp.buffer_full_size);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, BUFFER_FULL_TIMEOUT);
	fprintf(parms_fp, BUFFER_FULL_TIMEOUT_SPEC, 
		RIS_timestamp.buffer_full_timeout);
	RIScom_fputs("\n#\n", parms_fp);

	/*
	**	LOCK_FILE_RETRY
	*/
	write_comment(parms_fp, "LOCK_FILE_RETRY");
	fprintf(parms_fp, "# %s default: %d\n", LOCK_FILE_RETRY,
		LOCK_FILE_RETRY_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, LOCK_FILE_RETRY);
	fprintf(parms_fp, LOCK_FILE_RETRY_SPEC, RIS_schfile_parms.lock_file_retry);
	RIScom_fputs("\n#\n", parms_fp);


	/*
	**	SCHEMA FILE LOCATION
	*/
	write_comment(parms_fp, "SCHEMA_FILE");
	fprintf(parms_fp, "# %-20s default: %c\n", SF_PROTOCOL,
		SF_PROTOCOL_DEFAULT);
	fprintf(parms_fp, "# %-20s default: %s\n", SF_ADDRESS,
		SF_ADDRESS_DEFAULT);
	fprintf(parms_fp, "# %-20s default: %s\n", SF_USERNAME,
		SF_USERNAME_DEFAULT);
	fprintf(parms_fp, "# %-20s default: %s\n", SF_PASSWORD,
		SF_PASSWORD_DEFAULT);
	fprintf(parms_fp, "# %-20s default: %s\n", SF_FILENAME,
		SF_FILENAME_DEFAULT);
	RIScom_fputs("#\n", parms_fp);
	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SF_PROTOCOL);
	fprintf(parms_fp, SF_PROTOCOL_SPEC, RIS_schfile_parms.protocol);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SF_ADDRESS);
	fprintf(parms_fp, SF_ADDRESS_SPEC, RIS_schfile_parms.address);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SF_USERNAME);
	fprintf(parms_fp, SF_USERNAME_SPEC, RIS_schfile_parms.username);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SF_PASSWORD);
	if (*RIS_schfile_parms.password)
	{
		fprintf(parms_fp, SF_PASSWORD_SPEC, RIS_schfile_parms.password);
	}
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, SF_FILENAME);
	fprintf(parms_fp, SF_FILENAME_SPEC, RIS_schfile_parms.filename);
	RIScom_fputs("\n#\n", parms_fp);


	/*
	**	CLIENT LOCATION
	*/
	write_comment(parms_fp, "CLIENT_LOCATION");
	fprintf(parms_fp, "# %-15s default: %c\n", CL_PROTOCOL,
		CL_PROTOCOL_DEFAULT);
	fprintf(parms_fp, "# %-15s default: %s\n", CL_ADDRESS,
		CL_ADDRESS_DEFAULT);
	fprintf(parms_fp, "# %-15s default: %s\n", CL_USERNAME,
		CL_USERNAME_DEFAULT);
	fprintf(parms_fp, "# %-15s default: %s\n", CL_PASSWORD,
		CL_PASSWORD_DEFAULT);
    fprintf(parms_fp, "# %-15s default: %s\n", CL_VERSION,
        CL_VERSION_DEFAULT);
	RIScom_fputs("#\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_PROTOCOL);
	fprintf(parms_fp, CL_PROTOCOL_SPEC, RIS_client_parms.protocol);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_ADDRESS);
	fprintf(parms_fp, CL_ADDRESS_SPEC, RIS_client_parms.address);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_USERNAME);
	fprintf(parms_fp, CL_USERNAME_SPEC, RIS_client_parms.username);
	RIScom_fputs("\n", parms_fp);

	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_PASSWORD);
	if (*RIS_client_parms.password)
	{
		fprintf(parms_fp, CL_PASSWORD_SPEC, RIS_client_parms.password);
	}
    RIScom_fputs("\n", parms_fp);

	if (!generate_v4comp_file)
	{
    	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_VERSION);
    	RIScom_ver_number_to_str(RIS_client_parms.major, cli_major);
    	RIScom_ver_number_to_str(RIS_client_parms.feature, cli_feature);
    	sprintf(cli_version, "%s.%s", cli_major, cli_feature);
    	APP_DBG(("RISapp_write_parms_file cli_version : <%s>\n", cli_version));
    	fprintf(parms_fp, CL_VERSION_SPEC, cli_version);
    	RIScom_fputs("\n", parms_fp);
	}
	else
	{
		fprintf(parms_fp, "# ");
    	fprintf(parms_fp, "%-*s", MAX_SIZE + 1, CL_VERSION);
    	RIScom_ver_number_to_str(RIS_client_parms.major, cli_major);
    	RIScom_ver_number_to_str(RIS_client_parms.feature, cli_feature);
    	sprintf(cli_version, "%s.%s", cli_major, cli_feature);
    	APP_DBG(("RISapp_write_parms_file cli_version : <%s>\n", cli_version));
    	fprintf(parms_fp, CL_VERSION_SPEC, cli_version);
     	RIScom_fputs("\n", parms_fp);
	}

 
	RIScom_fputs("#\n", parms_fp);


	RESETJMP();

	RIScom_fclose(parms_fp);
	parms_fp = NULL;

	APP_DBG(("RISapp_write_parms_file: complete\n"));
}

/******************************************************************************/

extern void RISapp_save_parameters()
{
	APP_DBG(("RISapp_save_parameters()\n"));

	memcpy(&save_parms, &RIS_parms, sizeof(ris_parms_s));
	memcpy(&save_client_parms, &RIS_client_parms, sizeof(ris_client_parms_s));
	memcpy(&save_schfile_parms, &RIS_schfile_parms,sizeof(ris_schfile_parms_s));

	APP_DBG(("RISapp_save_parameters:complete\n"));
}

/******************************************************************************/

extern void RISapp_restore_parameters()
{
	APP_DBG(("RISapp_restore_parameters()\n"));

	memcpy(&RIS_parms, &save_parms, sizeof(ris_parms_s));
	memcpy(&RIS_client_parms, &save_client_parms, sizeof(ris_client_parms_s));
	memcpy(&RIS_schfile_parms, &save_schfile_parms,sizeof(ris_schfile_parms_s));

	APP_DBG(("RISapp_restore_parameters:complete\n"));

}

/******************************************************************************/

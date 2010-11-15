/*
**	NAME:							filglob.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**  REVISION HISTORY:
**
**  1. MAB, 22 Feb 94. Changed WIN32PATHCHR to '/' since '\' will NOT
**     work with ftp.
**     
**  2. MAB, 22 Feb 94. In update_globals, changed error 
**     checking to allow for NET_E_GET_FILE_ERROR, since this is
**     normal if the file does not exist on a given system due to
**     differences in path strings.
**
**  3. Radha 12/09/94: hardcoded the string comparison for "/" since
**     using WIN32PATHCHR is not appropriate in that context.
**
**  4. Radha, 12/14/94: changed the nt part of the code so that when
**     a full pathname is provided there is no check to see if the 
**     client is present in the remote machine, as this is not 
**     necessary. When only a filename is provided, the presence
**     of the client in the remote machine is checked to find a 
**     default location to place the schema file.
**
**  5. Radha 02/03/95
**     The code to check for the schema file on a remote NT machine
**     has been changed so that we can look at the registry of the
**     remote NT machine and determine where the RIS client is on
**     that machine so that we can place the schema file relative to
**     that RIS client (in the case when only a filename is provided).
**     The way we do this is to connect to the RIStcpsrService on the
**     remote machine and send a dtype(Z) across to tell it to check
**     the registry for the information we need. When we get the info
**     (the path of the RIS client on the remote machine) we can use
**     that to construct the path of the schema  file location. This
**     is only a fix in a small area of the schema file  location code.
**     We need to get away from the FTP mechanism (NET_get_file) for
**     remote files and instead have a remote schema server.
*/

#define FILE_GLOBAL_DEFINE
#define FILE_NET_ERR_CHK(net, error)                         \
if (net->error_code != NET_SUCCESS)                         \
{                                                           \
    LONGJMP(error);                                         \
}

 
/*
**	INCLUDES
*/
#include <sys/types.h>

#if defined (unix) 
#include <dirent.h>
#endif 

#if defined (WIN32)
#include <io.h>
#include <sys/stat.h>
#endif

#include <malloc.h>
#include "risver.h"
#include "risprods.h"
#include "file.h"

/*
**	DEFINES
*/

#define	WIN32PATHCHR '\\'
#define	UNIXPATHCHR	'/'
#define	UNIXPATHCHRSTR	"/"
#define UNIX_FILENAME_LEN 10
#define WIN32_FILENAME_LEN 8

#if defined(unix) 
#define	LOCPATHCHR	'/'
#define	LOCPATHCHRSTR	"/"
#define	LOCAL_FILENAME_LEN	UNIX_FILENAME_LEN
#define CHECK_LOCAL_FILENAME_LEN	check_unix_filename_len
#elif defined(WIN32)
#define	LOCPATHCHR	'\\'
#define	LOCPATHCHRSTR	"\\"
#define	LOCAL_FILENAME_LEN	WIN32_FILENAME_LEN
#define CHECK_LOCAL_FILENAME_LEN	check_win32_filename_len
#endif

#define FTP_RISCONFIG_FILE "/etc/risconfig"
#define FTP_RISDEVDIR_FILE "/usr/ip32/ris/risdir"

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define filglob_c
#include "comuni.prt"
#include "ccoerror.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comsqlca.prt"
#include "comstrcp.prt"
#include "comwrap.prt"
#include "filglob.prt"
#include "netgnerc.prt"
#include "sys.prt"



/*
**	VARIABLES
*/
static net_s			save_file_net;
static net_connect_s	save_file_connect;
static char				save_file[RIS_MAX_PATH_SIZE];
static char				save_lock_file[RIS_MAX_PATH_SIZE];
static char				save_id_file[RIS_MAX_PATH_SIZE];
static int				save_lock_file_retry;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void check_win32_filename_len(
	char *name)
{
	if (strlen(name) > WIN32_FILENAME_LEN)
	{
		sprintf(RIS_ERRMSGC,
			"A schema file name can not be longer than 8 characters.");
		LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);
	}
}

/******************************************************************************/

static void check_unix_filename_len(
	char *name)
{
	if (strlen(name) > UNIX_FILENAME_LEN)
	{
		sprintf(RIS_ERRMSGC,
			"A schema file name can not be longer than 10 characters.");
		LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);
	}
}

/******************************************************************************/

static void check_vms_filename_len(
	char *name,
	char *type)
{
	if (type)
	{
		if (strlen(type + 1) > 39)
		{
			sprintf(RIS_ERRMSGC,
				"A VMS schema file type can not be longer than 39 characters.");
			LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);
		}
		*type = '\0';
		if (strlen(name) > 39)
		{
			sprintf(RIS_ERRMSGC,
				"A VMS schema file name can not be longer than 39 characters.");
			LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);
		}
		*type = '.';
	}
	else if (strlen(name) > 39)
	{
		sprintf(RIS_ERRMSGC,
			"A VMS schema file name can not be longer than 39 characters.");
		LONGJMP(RIS_E_INV_SCHEMA_FILE_NAME);
	}
}

/******************************************************************************/

static void remote_address_err_msg()
{
	switch(RIS_file_net.protocol)
	{
		case XNS:
			sprintf(RIS_ERRMSGC,
				"The RIS schema file machine XNS nodename/address is '%s'.",
				RIS_file_connect.xns.address);
			break;
		case TCP:
			sprintf(RIS_ERRMSGC,
				"The RIS schema file machine TCP nodename/address is '%s'.",
				RIS_file_connect.tcp.address);
			break;
		case DNP:
			sprintf(RIS_ERRMSGC,
				"The RIS schema file machine DNP nodename/address is '%s'.",
				RIS_file_connect.dnp.node_name);
			break;

		default:
			break;
	}
}

/******************************************************************************/

extern void RISfil_begin_globals_transaction()
{
	FIL_DBG(("RISfil_begin_globals_transaction()\n"));

	memcpy(&save_file_net, &RIS_file_net, sizeof(save_file_net));
	memcpy(&save_file_connect, &RIS_file_connect, sizeof(save_file_connect));
	memcpy(save_file, RIS_file, sizeof(save_file));
	memcpy(save_lock_file, RIS_lock_file,sizeof(save_lock_file));
	memcpy(save_id_file, RIS_id_file, sizeof(save_id_file));
	save_lock_file_retry = RIS_lock_file_retry;

	FIL_DBG(("RISfil_begin_globals_transaction:complete\n"));
}

/******************************************************************************/

extern void RISfil_globals_rollback()
{
	FIL_DBG(("RISfil_globals_rollback()\n"));

	memcpy(&RIS_file_net, &save_file_net, sizeof(RIS_file_net));
	memcpy(&RIS_file_connect, &save_file_connect, sizeof(RIS_file_connect));
	memcpy(RIS_file, save_file, sizeof(RIS_file));
	memcpy(RIS_lock_file, save_lock_file, sizeof(RIS_lock_file));
	memcpy(RIS_id_file, save_id_file, sizeof(RIS_id_file));
	RIS_lock_file_retry = save_lock_file_retry;

	FIL_DBG(("RISfil_globals_rollback:complete\n"));
}

/******************************************************************************/

extern void RISfil_globals_commit()
{
	FIL_DBG(("RISfil_globals_commit()\n"));
	/*
	**	Nothing to do
	*/
	FIL_DBG(("RISfil_globals_commit:complete\n"));
}

/******************************************************************************/

static void update_globals(
	ris_schfile_parms_s *sf,
	int					mode)
{
	int		sts;
	char	*cp;
	char	*file_name;
    char    path[RIS_MAX_PATH_SIZE];
	char	*file_type;
#if defined (WIN32)
	char	temp[MAX_PATH];
	char	temp2[MAX_PATH];
	long    status;  
#else
	char	temp[L_tmpnam];
	char	temp2[L_tmpnam];
#endif
	char	risdir[RIS_MAX_PATH_SIZE];
	int		ret = 0;
	int 	len;

	FIL_DBG(("update_globals(sf:0x%x mode:0x%x)\n"
		"\tprotocol:%c address:<%s>\n\tusername:<%s> password:<%s>\n"
		"\tfilename:<%s> lock_file_retry:%d\n", sf, mode, sf->protocol,
		sf->address, sf->username, sf->password, sf->filename,
		sf->lock_file_retry));

	RIS_file_net.error_handler = RIScco_net_errhandle;

	if (mode & UPDATE_SCHFILE_LOCATION)
	{
		switch(sf->protocol)
		{
			case 'M':
				RIS_file_net.protocol = SHMEM;
				break;

			case 'T':
				RIS_file_net.protocol = TCP;
				strcpy(RIS_file_connect.tcp.address, sf->address);
				strcpy(RIS_file_connect.tcp.username, sf->username);
				RIScom_depd(sf->password, RIS_file_connect.tcp.password);
				break;

			case 'X':
				RIS_file_net.protocol = XNS;
				strcpy(RIS_file_connect.xns.address, sf->address);
				strcpy(RIS_file_connect.xns.username, sf->username);
				RIScom_depd(sf->password, RIS_file_connect.xns.password);
				break;

			case 'D':
				RIS_file_net.protocol = DNP;
				strcpy(RIS_file_connect.dnp.node_name, sf->address);
				strcpy(RIS_file_connect.dnp.userid, sf->username);
				RIScom_depd(sf->password, RIS_file_connect.dnp.password);
				break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
				break;
		}

		if (!RIScom_tmpnam(temp)) LONGJMP(RIS_E_CREATE_TEMP_FILE);
		if (!RIScom_tmpnam(temp2)) LONGJMP(RIS_E_CREATE_TEMP_FILE);

		if ((sts = SETJMP()) != 0)
		{
			RESETJMP();
			if (*temp && !RIScom_access(temp, 00)) RIScom_remove(temp);
			if (*temp2 && !RIScom_access(temp2, 00)) RIScom_remove(temp2);
			LONGJMP(sts);
		}

		if (RIS_file_net.protocol == SHMEM)
		{
			/*
			**	Schema file is on local machine
			*/
			FIL_DBG(("update_globals: schfile on local system\n"));

			/*
			**	check for path preceding file name
			*/
			if (file_name = RIScom_strrchr(sf->filename,LOCPATHCHR))
			{
				/*
				** full path was provided
				*/
				FIL_DBG(("update_globals: full path provided\n"));

				/*
				** get dir from full path and verify that dir exists 
				*/
				GetDirFromPath(sf->filename, path, LOCPATHCHR);
				FIL_DBG(("Path = %s,  file = %s\n",path, file_name));
#if defined(unix) 
				if (opendir(path) == NULL)
#elif defined(WIN32)
				if (status = _access(path, 0))
#else
				ERROR -- NO CODE
#endif
				{
					FIL_DBG(("RIS_E_DIR_DOES_NOT_EXIST\n"));
					LONGJMP(RIS_E_DIR_DOES_NOT_EXIST);
				}

				/*
				**	check if file name is too long
				*/
				file_name++;
				CHECK_LOCAL_FILENAME_LEN(file_name);

				/*
				**	copy path and file name to file global
				**	set global variable indicating full path was provided
				*/
				strcpy(RIS_file, sf->filename);
			}
			else
			{
				/*
				**	Just a filename was provided
				*/
				FIL_DBG(("update_globals: filename provided\n"));

				/*
				**	check if file name is too long
				*/
				FIL_DBG(("update_globals: filename1 %s\n", sf->filename));

				CHECK_LOCAL_FILENAME_LEN(sf->filename);

				FIL_DBG(("update_globals: filename2 %s\n", sf->filename));

				/*
				**	get path where ris is installed
				*/
#if defined (WIN32)
				ret = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT,
					RIS_version_maj, RIS_version_min,
					RIS_version_rel, MATCH_COMPATIBLE, 0,
					RISCONFIG_FILE, risdir, 0, dbca);

				FIL_DBG(("update_globals: ret %s\n", ret));
#else
				ret = RIScom_get_risdir(RIS_CLIENT_ALL_PLATFORMS,
					RIS_version_maj, RIS_version_min,
					RIS_version_rel, MATCH_COMPATIBLE, 0,
					RISCONFIG_FILE, risdir, 0, dbca);
#endif
				if (ret)
				{
					if (*temp && !RIScom_access(temp, 00)) RIScom_remove(temp);
					if (*temp2 && !RIScom_access(temp2, 00)) RIScom_remove(temp2);
					LONGJMP(ret);
				}
				cp = RIScom_strrchr(risdir, LOCPATHCHR);/*itbokic 3/30 */
				if (cp)
				{
					if ((strcmp("risccu",cp+1) == 0) ||
						(strcmp("riscli",cp+1) == 0) ||
						(strcmp("riscsu",cp+1) == 0))
					{
						*cp = '\0';
					}
				}
				else
				{
					if (*temp && !RIScom_access(temp, 00)) RIScom_remove(temp);
					if (*temp2 && !RIScom_access(temp2, 00)) RIScom_remove(temp2);
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}
				FIL_DBG(("update_globals: risdir:<%s>\n", risdir));

				/*
				**	copy path and file name to file global
				**	set global variable indicating just a filename was provided
				*/
				cp = RIS_file;
				cp += RIScom_strcpy(cp, risdir);
				cp += RIScom_strcpy(cp, LOCPATHCHRSTR);
				strcpy(cp, sf->filename);
			}

			/*
			**	copy path and file name to lock file global
			*/
			cp = RIS_lock_file;
			cp += RIScom_strcpy(cp, RIS_file);
			strcpy(cp, ".LCK");

			/*
			**	copy path and file name to id file global
			*/
			cp = RIS_id_file;
			cp += RIScom_strcpy(cp, RIS_file);
			strcpy(cp, ".ID");
		}
		else
		{
			/*
			**	Schema file is on a remote machine
			*/

			/*
			**  check for FTP_RISCONFIG_FILE first and if not found
			**	check for FTP_RISDEVDIR_FILE indicating a unix system
			*/
			if ((NET_get_file(&RIS_file_net, &RIS_file_connect,
					FTP_RISCONFIG_FILE, temp) == NET_SUCCESS) ||
			    (NET_get_file(&RIS_file_net, &RIS_file_connect,
					FTP_RISDEVDIR_FILE, temp) == NET_SUCCESS))

			{
				/*
				**	Remote machine is unix
				*/
				FIL_DBG(("update_globals: remote unix system\n"));

				/*
				**	check for path preceding file name
				*/
				if (file_name = strrchr(sf->filename, UNIXPATHCHR))/*itbokic 3/30 */
				{
					/*
					**	full path was provided
					*/
					FIL_DBG(("update_globals: full path provided\n"));

					/*
					**	check if file name is too long
					*/
					file_name++;
					check_unix_filename_len(file_name);

					/*
					**	copy path and file name to file global
					*/
					strcpy(RIS_file, sf->filename);
				}
				else
				{
					/*
					**	Just a filename was provided
					*/
					FIL_DBG(("update_globals: filename provided\n"));

					/*
					**	check if file name is too long
					*/
					check_unix_filename_len(sf->filename);

					/*
					**	get path where ris is installed
					*/
					if (NET_get_file(&RIS_file_net, &RIS_file_connect,
						"/usr/ip32/ris/risdir", temp2))
					{
						temp2[0] = '\0';
					}
					ret = RIScom_get_risdir(RIS_CLIENT_ALL_PLATFORMS,
							RIS_version_maj, RIS_version_min,
							RIS_version_rel, MATCH_COMPATIBLE, temp2,
							temp, risdir, 0,dbca);
					if (ret)
					{
						if (*temp && !RIScom_access(temp, 00))
						   RIScom_remove(temp);
						if (*temp2 && !RIScom_access(temp2, 00))
						   RIScom_remove(temp2);
						LONGJMP(ret);
					}
					cp = strrchr(risdir,UNIXPATHCHR);/*itbokic 3/30 */
					if (cp)
					{
						if (
						(strcmp("risccu",cp+1) == 0) ||
						(strcmp("riscli",cp+1) == 0) ||
						(strcmp("riscsu",cp+1) == 0)
						   )
						{
							*cp = '\0';
						}

					}
					else
					{
						if (*temp && !RIScom_access(temp, 00))
						   RIScom_remove(temp);
						if (*temp2 && !RIScom_access(temp2, 00))
						   RIScom_remove(temp2);
						LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					FIL_DBG(("update_globals: risdir:<%s>\n",risdir));

					/*
					**	copy path and file name to file global
					*/
					cp = RIS_file;
					cp += RIScom_strcpy(cp, risdir);
					cp += RIScom_strcpy(cp, UNIXPATHCHRSTR);
					strcpy(cp, sf->filename);
				}

				/*
				**	copy path and file name to lock file global
				*/
				cp = RIS_lock_file;
				cp += RIScom_strcpy(cp, RIS_file);
				strcpy(cp, ".LCK");

				/*
				**	copy path and file name to id file global
				*/
				cp = RIS_id_file;
				cp += RIScom_strcpy(cp, RIS_file);
				strcpy(cp,".ID");
			}
			else
			{

				if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND &&
					RIS_file_net.error_code != NET_E_GET_FILE_ERROR)
				{
					/*
					**	there was an error other than file not found
					*/
 
					remote_address_err_msg();
					if (*temp && !RIScom_access(temp, 00))
					   RIScom_remove(temp);
					if (*temp2 && !RIScom_access(temp2, 00))
					   RIScom_remove(temp2);

					LONGJMP(RIS_E_CANT_LOCATE_RIS);
				}

				/*
				**	/usr/ip32/ingrconfig was not found, so we must be
				**	on a vax, so ignore the NET error and clear the dbca
				*/
				RIScom_clear_sqlca(dbca);

				/*
				**	Schema file is on a remote machine
				**	check for pro_dd_ris:[bin]risinstall.com indicating
				**	a vms system
				*/

				if (NET_get_file(&RIS_file_net, &RIS_file_connect,
						"pro_dd_ris:[bin]risinstall.com", temp) == NET_SUCCESS)
				{
					/*
					**	remote machine is a vms system
					*/
					FIL_DBG(("update_globals: remote vms system\n"));

					file_type = strrchr(sf->filename,'.');/*itbokic 3/30 */
					file_name = strrchr(sf->filename,']');/*itbokic 3/30 */

					/*
					**	check for path preceding file name
					*/
					if (file_name)
					{
						/*
						**	full path was provided
						*/
						FIL_DBG(("update_globals:full path provided\n"));

						/*
						**	check if file name is too long
						*/
						file_name++;
						check_vms_filename_len(file_name, file_type);

						/*
						**	copy path and file name to file global
						*/
						strcpy(RIS_file,sf->filename);
					}
					else
					{
						/*
						**	just a filename was provided
						*/
						FIL_DBG(("update_globals: filename provided\n"));

						file_name = sf->filename;

						/*
						**	check if file name is too long
						*/
						check_vms_filename_len(file_name, file_type);

						/*
						**	copy path and file name to file global
						*/
						cp = RIS_file;
						cp += RIScom_strcpy(cp, "pro_dd_ris:[bin]");
						strcpy(cp, sf->filename);
					}

					/*
					**	copy path and file name to lock file global
					*/
					cp = RIS_lock_file;
					cp += RIScom_strcpy(cp, RIS_file);
					if (file_type = strrchr(RIS_lock_file, '.'))/*itbokic 3/30 */
					{
						cp = file_type;
					}
					strcpy(cp, ".LCK");

					/*
					**	copy path and file name to id file global
					*/
					cp = RIS_id_file;
					cp += RIScom_strcpy(cp, RIS_file);
					if (file_type = strrchr(RIS_id_file, '.'))/*itbokic 3/30 */
					{
						cp = file_type;
					}
					strcpy(cp, ".ID");
				}
				else
				{
					if (RIS_file_net.error_code != NET_E_FILE_NOT_FOUND &&
						RIS_file_net.error_code != NET_E_GET_FILE_ERROR)
					{
						/*
						**	there was an error other than file not found
						*/
						remote_address_err_msg();
						if (*temp && !RIScom_access(temp, 00))
							RIScom_remove(temp);
						if (*temp2 && !RIScom_access(temp2, 00))
							RIScom_remove(temp2);
						LONGJMP(RIS_E_CANT_LOCATE_RIS);
					}

					/*
					**	pro_dd_ris:[bin]risinstall.com was not found, so
					**	remote must be an NT, so ignore the NET error and
					**	clear the dbca
					*/
					RIScom_clear_sqlca(dbca);

					/*
					**	Schema file is on a remote machine check for
					**	c:\win32app\ingr\share\ris0X.0X\config\langs
					**	indicating a NT system only if the full pathname 
					**	was not provided. Radha 12/13/94
					*/

						/*
						**	check for path preceding file name
						*/
            		if ((file_name = RIScom_strchr(sf->filename, ':')) && 
						((file_name = RIScom_strrchr(sf->filename, WIN32PATHCHR)) ||/*itbokic 3/30 */
              			(file_name = RIScom_strrchr(sf->filename,'/'))))/*itbokic 3/30 */
						{
							/*
							**	full path was provided
							*/
							FIL_DBG(("update_globals: "
									 "NT full path provided\n"));

							/*
							**	check if file name is too long
							*/
							file_name++;
							check_win32_filename_len(file_name);

							/*
							**	copy path and file name to file global
							*/
							strcpy(RIS_file, sf->filename);
							/*
							**	copy path and file name to lock file global
							*/
							cp = RIS_lock_file;
							cp += RIScom_strcpy(cp, RIS_file);
							strcpy(cp, ".LCK");
							FIL_DBG(("update_globals RISlock %s\n",RIS_lock_file));

							/*
							**	copy path and file name to id file global
							*/
							cp = RIS_id_file;
							cp += RIScom_strcpy(cp, RIS_file);
							strcpy(cp,".ID");
							FIL_DBG(("update_globals RISid %s\n",RIS_id_file));
						}
						else
						{
							int 	length;
							char 	buffer[8];
							char 	remote_filename[RIS_MAX_PATH_SIZE] = "";

							/*
							**	Just a filename was provided
							*/
							FIL_DBG(("update_globals: NT filename provided\n"));

							/*
							** The code to check for the schema file
							** on a remote NT machine has been changed.
							** Details in REVISION HISTORY  - Radha 02/03/95  
							*/

							(&RIS_file_net)->cs_flag = CLIENT_FLAG;
							(&RIS_file_connect)->tcp.port = 
											RIS_TCP_SERVICE_NUMBER;
							len = sizeof((&RIS_file_connect)->tcp.address);
							NET_address(&RIS_file_net,
								(&RIS_file_connect)->tcp.address,
								(&RIS_file_connect)->tcp.address, &len);
							NET_connect(&RIS_file_net, &RIS_file_connect); 
							FILE_NET_ERR_CHK((&RIS_file_net), 
								RIS_E_RIS_NOT_INSTALLED);
							length = 8;
							buffer[0] = (char)0;
							buffer[1] = (char)0;
							buffer[2] = (char)0;
							buffer[3] = (char)MATCH_COMPATIBLE;
							buffer[4] = 'Z';
							buffer[5] = (char)RIS_version_maj;
							buffer[6] = (char)RIS_version_min;
							buffer[7] = (char)0;
							FIL_DBG(("update_globals:write_no_len contents\n"
								"\tbuffer[4]:<%c>\n"
								"\tbuffer[5]:<%d>\n"
								"\tbuffer[6]:<%d>\n"
								"\tRIS_version_maj:<%d>\n"
								"\tRIS_version_min:<%d>\n",
								buffer[4], buffer[5], buffer[6], 
								RIS_version_maj,
								RIS_version_min));
							NET_write_no_len(&RIS_file_net, buffer, 
									&length, BLOCKING);
							FILE_NET_ERR_CHK((&RIS_file_net), 
										RIS_E_RIS_NOT_INSTALLED);
							length = sizeof(remote_filename);
							NET_read_no_len(&RIS_file_net,remote_filename ,
									&length , BLOCKING);
							FILE_NET_ERR_CHK((&RIS_file_net), 
										RIS_E_RIS_NOT_INSTALLED);
							FIL_DBG(("update_global: remote_filename <%s>\n",
											remote_filename));
							if  ( (strcmp(remote_filename,"") != 0) &&
									(strcmp(remote_filename,
									"Cannot find RIS in the registry") != 0) )
							{
								/* strip last slash - TR# 439601662 -surjit */
								length = strlen(remote_filename) - 1;
								if (remote_filename[length] == '\\')
								{
									remote_filename[length] = '\0';
								}
								cp = RIS_file;
								cp += RIScom_strcpy(cp, remote_filename);
								cp += RIScom_strcpy(cp, "\\");
								strcpy(cp, sf->filename);
								FIL_DBG(("RIS_file: %s\n", RIS_file));

								/*
								**	copy path and file name to lock file global
								*/
								cp = RIS_lock_file;
								cp += RIScom_strcpy(cp, RIS_file);
								strcpy(cp, ".LCK");
								FIL_DBG(("RIS_lock_file: %s\n", RIS_lock_file));

								/*
								**	copy path and file name to id file global
								*/
								cp = RIS_id_file;
								cp += RIScom_strcpy(cp, RIS_file);
								strcpy(cp,".ID");
								FIL_DBG(("RIS_id_file: %s\n", RIS_id_file));
							}
							else
							{
								remote_address_err_msg();
								if (*temp && !RIScom_access(temp, 00))
									RIScom_remove(temp);
								if (*temp2 && !RIScom_access(temp2, 00))
									RIScom_remove(temp2);
								LONGJMP(RIS_E_CANT_LOCATE_RIS);
							} /* could not locate remote NT RIS client  */
						} /* on NT but only filename was provided */
				} /* couldn't get risinstall.com */
			} /* schema file is on a vax */
		} /* schema file is on a remote machine; */

		RESETJMP();

		if (*temp && !RIScom_access(temp, 00)) RIScom_remove(temp);
		if (*temp2 && !RIScom_access(temp2, 00)) RIScom_remove(temp2);
	}

	if (mode & UPDATE_LOCK_FILE_RETRY)
	{
		RIS_lock_file_retry = sf->lock_file_retry;
	}

	FIL_DBG(("update_globals:complete\n"
		"\tRIS_file:<%s>\n"
		"\tRIS_lock_file:<%s>\n"
		"\tRIS_id_file:<%s>\n"
		"\tRIS_lock_file_retry:%d\n",
		RIS_file, RIS_lock_file, RIS_id_file,
		RIS_lock_file_retry));
}

/******************************************************************************/

extern void RISfil_update_globals(
	ris_schfile_parms_s *sf)
{
	update_globals(sf, UPDATE_ALL);
}

/******************************************************************************/

extern void RISfil_locate_schfile(
	ris_schfile_parms_s *sf)
{
	FIL_DBG(("RISfil_locate_schfile: calling update_globals\n"));
	update_globals(sf, UPDATE_SCHFILE_LOCATION);
	FIL_DBG(("RISfil_locate_schfile: complete\n"));
}

/******************************************************************************/

extern void RISfil_get_filename(
	char **filenamep)
{
	int len;

	FIL_DBG(("RISfil_get_filename(filenamep:0x%x)\n", filenamep));

	len = strlen(RIS_file) + 1;
	(*filenamep) = (char *)ALLOCB(len);
	memcpy((*filenamep), RIS_file, len);

	FIL_DBG(("RISfil_get_filename:complete\n"));
}


/******************************************************************************
 * this function separates full_path into path and filename
 *****************************************************************************/

static void GetDirFromPath(char *full_path, char *path, char path_char)
{
   char *filename;
   int pathlen;

   filename =  RIScom_strrchr(full_path,path_char);/*itbokic 3/30 */
   pathlen = strlen(full_path) - strlen(filename);

   strncpy(path, full_path, pathlen);/*itbokic 3/30 */

   path[pathlen] = '\0'; 
   FIL_DBG(("GetDirFromPath: path=%s\n", path));
}

/*
**	NAME:							APPcli.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**					Jan. 94, Added version specification stuff -- Sanju
*/

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <signal.h>

#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "rispath.h"
#include "risprods.h"
#include "risapp.h"
#include "risdebug.h"
#include "ris_err.h"

#define INVALID_FLAG	0
#define OPTIONAL_FLAG	1
#define REQUIRED_FLAG	2

static  char stopping_client = 0;
static  int match_flag;

extern void RISapp_start_client()
{
	int				sts;
	int				len;
	int				lang_code;
#if defined(unix) || defined(WIN32)
	int				development;
#endif
	net_connect_s	net_connect;
    char ums_filepath[RIS_MAX_PATH_SIZE];
#if defined(unix) || defined(WIN32)
    char client_risdir[RIS_MAX_PATH_SIZE];
#endif
	short client_major = RIS_app_version_maj;
	short client_feature = RIS_app_version_min;

	APP_DBG(("RISapp_start_client()\n"));

	RIS_client_died = 0;


	
	/*
	**	version on checking is done here before we do anything else. -- SK
    */
    match_flag = MATCH_COMPATIBLE;
    if (RIS_client_parms.major == 0)
    {
        client_major = RIS_app_version_maj;
    APP_DBG(("RISapp_start_client(): client_major %d\n", client_major));
    APP_DBG(("RISapp_start_client(): RIS_app_version_maj %d\n", 
		RIS_app_version_maj));
    }
    else
    {
        if (RIS_app_version_maj > RIS_client_parms.major)
        {
            LONGJMP(RIS_E_APPCLI_INCOMPATIBLE);
        }
        else
        {
            client_major = (int)RIS_client_parms.major;
    APP_DBG(("RISapp_start_client(): client_major %d\n", client_major));
        }
    }
    if (RIS_client_parms.feature == 0)
    {
        client_feature = RIS_app_version_min;
    APP_DBG(("RISapp_start_client(): client_feature %d\n", client_feature));
    }
    else
    {
        client_feature = (int)RIS_client_parms.feature;
    	APP_DBG(("RISapp_start_client(): client_feature %d\n", client_feature));
        match_flag = MATCH_MAJOR_FEATURE;
    }


	/*
	** initialize the network
	*/
	stopping_client = 0;
	memset(&net_connect, 0, sizeof(net_connect));

	RIS_net = ALLOCTP(net_s);
	RIS_arc = ALLOCTP(arc_s);
	RIS_net->cs_flag = CLIENT_FLAG;
	RIS_net->error_handler = RISapp_net_errhandle;
	RIS_arc->error_handler = RISapp_arc_errhandle;

    /*
    **  Initialize NET langauge parameters
    */
	if (RIS_lang_code_used >= 0)
	{
		/* Default to english language other than what was asked for */
		lang_code = RIS_lang_code_used;
	}
	else
	{
		/* Default to the language asked for */
		lang_code = RIS_language_code;
	}

    if (RIS_development)
    {
    	sprintf(ums_filepath, "%s%criscom%cconfig%c%s%cmessages%cnet.msg", 
			RIS_dir, PATH_CHAR, PATH_CHAR, PATH_CHAR, 
			RIScom_ris_lang_dir(lang_code), PATH_CHAR, PATH_CHAR);
    }
    else
    {
    	sprintf(ums_filepath, "%s%cconfig%c%s%cmessages%cnet.msg", 
			RIS_dir, PATH_CHAR, PATH_CHAR, 
			RIScom_ris_lang_dir(lang_code), PATH_CHAR, PATH_CHAR);
	}
    NET_init_lang(RIS_net, ums_filepath);

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();

		RISapp_cleanup_client();

		LONGJMP(sts);
	}

	switch(RIS_client_parms.protocol)
	{
		case 'M':
#if defined(DOS)
            /*
            **  For DOS, shared memory is not valid. 
            */
            LONGJMP(RIS_E_INV_CLIENT_PROTOCOL_PARM);
#endif
#if defined(unix) || defined(WIN32)
			RIS_net->protocol = SHMEM;

			net_connect.shmem.shmem_info.shm_seg_size = RIS_parms.shm_seg_size;
			net_connect.shmem.shmem_info.shm_key = RIS_SHM_KEY;
			net_connect.shmem.shmem_info.shm_access = SHM_SEG_ACCESS;
			net_connect.shmem.shmem_info.sem_cnt = RIS_parms.max_locals;
			net_connect.shmem.shmem_info.sem_key = RIS_SEM_KEY;
			net_connect.shmem.shmem_info.sem_access = SEM_SET_ACCESS;

            sts = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, 
						client_major, client_feature, 
						RIS_app_version_rel, match_flag, 0,
						RISCONFIG_FILE,
						client_risdir, &development, dbca);
			if( sts )
			{
				LONGJMP(sts);
			}

            RIScom_generate_local_exe_path(net_connect.shmem.path, 
				client_risdir, development, "riscli", RIS_CLIENT_PROGRAM);
            net_connect.shmem.arg1[0] = 'M';
            break;
#endif

		case 'T':
			RIS_net->protocol = TCP;
			len = sizeof(net_connect.tcp.address);
			NET_address(RIS_net,RIS_client_parms.address,
				net_connect.tcp.address, &len);
			net_connect.tcp.port = RIS_TCP_SERVICE_NUMBER;
			break;

		case 'X':
#if defined(clipper) || defined(__clipper__)
			RIS_net->protocol = XNS;
			len = sizeof(net_connect.xns.address);
			NET_address(RIS_net,RIS_client_parms.address,
				net_connect.xns.address, &len);
			strcpy(net_connect.xns.username, RIS_client_parms.username);
			RIScom_depd(RIS_client_parms.password,net_connect.xns.password);
			sprintf(net_connect.xns.server_name,
				"/usr/ip32/ris/links/riscli.%d_%d_X X", client_major, 
				client_feature);
			net_connect.xns.server_num = 0;
			break;
#elif defined(unix) || defined(WIN32) || defined(DOS)
            /*
            **  For SUN, NT and DOS, XNS is not valid. 
            */
            LONGJMP(RIS_E_INV_CLIENT_PROTOCOL_PARM);
#endif

		case 'D':
#if defined(clipper) || defined(__clipper__) 
			RIS_net->protocol = DNP;
			len = sizeof(net_connect.dnp.node_name);
			NET_address(RIS_net, RIS_client_parms.address,
				net_connect.dnp.node_name, &len);
			strcpy(net_connect.dnp.userid, RIS_client_parms.username);
			RIScom_depd(RIS_client_parms.password,net_connect.dnp.password);
			sprintf(net_connect.dnp.task_name, "RISC_%d_%d_X",
				client_major, client_feature);
			net_connect.dnp.object_nbr = 0;
			break;
#elif defined(unix) || defined(WIN32) || defined(DOS)
            /*
            **  For SUN, NT and DOS, DNP is not valid. 
            */
            LONGJMP(RIS_E_INV_CLIENT_PROTOCOL_PARM);
#endif

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
	}

	RIS_save_read_size = RIS_read_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_save_write_size = RIS_write_size = RIS_INITIAL_BUFFER_SIZE;

	if ((RIS_read = (ris_cliapp_buf *)NET_alloc(RIS_read_size)) == NULL)
	{
		APP_DBG(("RISapp_start_client:Unable to alloc RIS_read buffer\n"));
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}
	RIS_save_read = RIS_read;

	if ((RIS_write = (ris_appcli_buf *)NET_alloc(RIS_write_size)) == NULL)
	{
		APP_DBG(("RISapp_start_client:Unable to alloc RIS_read buffer\n"));
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}
	RIS_save_write = RIS_write;

	NET_connect(RIS_net, &net_connect);

	/*
	**	The connection has been established
	*/
	RIS_net_finish_mode = DETACH;

	if (RIS_net->protocol == TCP)
	{
		/*
		**	If the remote client process is connected by TCP, we didn't
		**	really kick off riscli, we kicked off ristcpsrv, so send
		**	it one byte to tell it which process to fork.
		**
		**	Send 'C' to tell ristcpsrv to kick off riscli
		*/
		int		length;
		char	buffer[8];

		length = 8;
		buffer[0] = (char)0;
		buffer[1] = (char)0;
		buffer[2] = (char)0;
        buffer[3] = (char)match_flag;
		buffer[4] = 'C';
        buffer[5] = (char)client_major;
        buffer[6] = (char)client_feature;
        buffer[7] = (char)RIS_app_version_rel;

        APP_DBG(("RISapp_start_client: dtype:%c maj:%d min:%d rel:%d\n match_flag:%d\n", buffer[4], buffer[5], buffer[6], buffer[7] , buffer[3]));

		NET_write_no_len(RIS_net, buffer, &length, BLOCKING);
	}

	sts = SETJMP();
	if (!sts)
	{
		RISapp_init_signal();
		RISapp_check_client(RIS_net);
		RIScom_send_architecture(RIS_net, RIS_arc, TO_BACKEND);
	
		RIScom_rec_architecture(RIS_net, RIS_arc, FROM_BACKEND, BLOCKING);
		RISapp_restore_signal();
		RESETJMP();
	}
	else
	{
		RESETJMP();
		RISapp_restore_signal();
		LONGJMP(sts);
	}

	/*
	**	Initialize the client: send parameters, debug, etc.
	*/
	RISapp_client_init_to_buf();
	RISapp_send_rec();

	RESETJMP();

	APP_DBG(("RISapp_start_client: complete\n"));
}

/******************************************************************************/

extern void RISapp_stop_client()
{
	net_finish_s	net_finish;
	APP_DBG(("RISapp_stop_client()\n"));

	stopping_client = 1;

    if (RIS_def_schname[0])
    {
        RIS_def_schname[0] = '\0';
    }

	if (RIS_net)
	{
		RISapp_opcode_to_buf(RISCLI_TERM_CODE, SYNC_MODE);
		if (!SETJMP()) RISapp_send_rec();
		RESETJMP();
	}

	if (RIS_read)
	{
		APP_DBG(("RISapp_stop_client: RIS_read 0x%x\n", RIS_read));
		NET_free((char *)RIS_read);
		RIS_read = (ris_cliapp_buf *)0;
	}
	if (RIS_write)
	{
		APP_DBG(("RISapp_stop_client: RIS_write 0x%x\n", RIS_write));
		NET_free((char *)RIS_write);
		RIS_write = (ris_appcli_buf *)0;
	}
	/*
	**  Took out code to free RIS_save_read and RIS_save_write
	**  because this code resulted in freeing the same pointer twice.
	*/
	if (RIS_net)
	{
		if (!SETJMP()) NET_close(RIS_net);
		RESETJMP();

		net_finish.memory_mode = RIS_net_finish_mode;	
		if (!SETJMP()) NET_finish(RIS_net, &net_finish);
		RESETJMP();

		RIS_net = 0;
	}

	RIS_client_died = 0;

	stopping_client = 0;

	APP_DBG(("RISapp_stop_client:complete\n"));
}

/******************************************************************************/

/*
**	This routine is called any time the client died abnormally
*/

extern void RISapp_cleanup_client()
{
	net_finish_s	net_finish;
	
	APP_DBG(("RISapp_cleanup_client()\n"));

	if (stopping_client)
	{
		APP_DBG(("RISapp_cleanup_client:already stopping client:returning\n"));
		return;
	}

	RISapp_push_risca_dbca();

	if (RIS_read)
	{
		NET_free((char *)RIS_read);
		RIS_read = (ris_cliapp_buf *)0;
	}
	if (RIS_write)
	{
		NET_free((char *)RIS_write);
		RIS_write = (ris_appcli_buf *)0;
	}
	if (RIS_net)
	{
		net_finish.memory_mode = DEALLOCATE;	
		if (!SETJMP()) NET_finish(RIS_net, &net_finish);
		RESETJMP();

		RIS_net = 0;
	}

	RIS_client_died = 1;

	RISapp_pop_risca_dbca();

	APP_DBG(("RISapp_cleanup_client:complete\n"));
}

/******************************************************************************/

extern void RISapp_validate_client_spec(
	char	protocol,
	char	*address,
	char	*username,
	char	*password,
	short	parms_cli_major)

{
	char	prot;
	char	address_flag = 0;
	char	username_flag = 0;
	char	password_flag = 0;
	char	version_flag = 0;

	APP_DBG(("RISapp_validate_client_spec(protocol:%c address:<%s> "
		"username:<%s>) parms_cli_major:<%d>\n", protocol, address,
		username, parms_cli_major));

	if (RIScom_islower(protocol))
	{
		prot = (char)RIScom_toupper(protocol);
	}
	else
	{
		prot = protocol;
	}

	if (!VALID_PROTOCOL(prot))
	{
		sprintf(RIS_ERRMSGC, RIScom_umsg(RIS_E_EXPECTED_M_X_T_D),
			RIScom_isprint(prot)?prot:' ');
		LONGJMP(RIS_E_INV_CLIENT_PROTOCOL);
	}

	version_flag = REQUIRED_FLAG;

	switch(prot)
	{
		case 'M':
			address_flag = INVALID_FLAG;
			username_flag = INVALID_FLAG;
			password_flag = INVALID_FLAG;
			break;

		case 'X':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = OPTIONAL_FLAG;
			break;

		case 'T':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = OPTIONAL_FLAG;
			break;

		case 'D':
			address_flag = REQUIRED_FLAG;
			username_flag = REQUIRED_FLAG;
			password_flag = OPTIONAL_FLAG;
			break;
	}

	if (address && *address)
	{
		if (address_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_ADDRESS_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}

		if (strlen(address) >= RIS_MAX_NODE_SIZE)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_ADDRESS_CAN_NOT_LONGER), 
				RIS_MAX_NODE_SIZE - 1);
			LONGJMP(RIS_E_INV_CLIENT_ADDRESS);
		}
	}
	else /* no address */
	{	
		if (address_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_ADDRESS), prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}
	}

	if (username && *username)
	{
		if (username_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_USERNAME_PROTOCOL), prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}
		if (strlen(username) >= RIS_MAX_ID_SIZE)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_USERNAME_CAN_NOT_LONGER) , 
				RIS_MAX_ID_SIZE - 1);
			LONGJMP(RIS_E_INV_CLIENT_USERNAME);
		}
	}
	else /* no username */
	{	
		if (username_flag == REQUIRED_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_ADDRESS) , prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}
	}

	if (password && *password)
	{
		if (password_flag == INVALID_FLAG)
		{
			sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_SPECIFYING_PASSWORD_PROTOCOL) , prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}
		if (strlen(password) > RIS_MAX_PASSWD_SIZE)
		{
            sprintf(RIS_ERRMSGC,
                RIScom_umsg(RIS_E_PASSWORD_CAN_NOT_LONGER) ,
                RIS_MAX_ID_SIZE);
			LONGJMP(RIS_E_INV_CLIENT_PASSWORD);
		}
	}
	else /* no password */
	{	
		if (password_flag == REQUIRED_FLAG)
		{
            sprintf(RIS_ERRMSGC,
				RIScom_umsg(RIS_E_PROTOCOL_REQUIRES_ADDRESS) , prot);
			LONGJMP(RIS_E_INV_CLIENT_SPEC);
		}
	}

	/* version checking of the version of the client in parameters file   */
	/* at this point we just compare the major part of the versions       */
	/* version falg is never INVALID_FLAG or OPTIONAL_FLAG                */

	if ((parms_cli_major != 0) && (RIS_app_version_maj > parms_cli_major))
    {
        LONGJMP(RIS_E_APPCLI_INCOMPATIBLE);
    }


	APP_DBG(("RISapp_validate_client_spec: complete\n"));
}

/******************************************************************************/

extern void RISapp_update_client_spec(
	char	protocol,
	char	*address,
	char	*username,
	char	*password,
	short	parms_cli_major,
	short	parms_cli_feature)
{
	APP_DBG(("RISapp_update_client_spec(protocol:%c address:<%s> "
		"username:<%s> client_major:<%d> client_feature:<%d> )\n", 
		protocol, address, username, parms_cli_major, parms_cli_feature));

	if (RIScom_islower(protocol))
	{
		RIS_client_parms.protocol = (char)RIScom_toupper(protocol);
	}
	else
	{
		RIS_client_parms.protocol = protocol;
	}

	if (address && *address)
	{
		strcpy(RIS_client_parms.address, address);	
	}
	else
	{
		RIS_client_parms.address[0] = '\0';	
	}

	if (username && *username)
	{
		strcpy(RIS_client_parms.username, username);	
	}
	else
	{
		RIS_client_parms.username[0] = '\0';	
	}

	if (password && *password)
	{
		strcpy(RIS_client_parms.password, password);	
	}
	else
	{
		RIS_client_parms.password[0] = '\0';	
	}

	RIS_client_parms.major = parms_cli_major;
	RIS_client_parms.feature = parms_cli_feature;

	APP_DBG(("RISapp_update_client_spec: complete\n"));
}

/******************************************************************************/

extern void RISapp_check_client(struct net_s * net)
{
#if defined(WIN32) || defined(DOS)
    APP_DBG(("RISapp_check_client(net:0x%x)\n", net));
    APP_DBG(("RISapp_check_client: complete\n"));
#endif
#if defined(unix)
	char path[sizeof("/proc/00000")];
	int status;
#if defined(clipper) || defined(__clipper__)
	struct stat buf;
#endif

	APP_DBG(("RISapp_check_client(net:0x%x)\n", net));

	if (net->protocol == SHMEM)
	{
		sprintf(path,"/proc/%d",net->id.shmem.pid);
		
		APP_DBG(("looking for client with pid = %d\n",net->id.shmem.pid));

#if defined(clipper) || defined(__clipper__)
    	status = (int)RIScom_stat(path,&buf);

	APP_DBG(("status = %d errno = %d process size = %d\n",status,errno,
		status ? 0 : buf.st_size));

/* the client is dead if process doesn't exist or is a zombie */

    	if ((status && errno == ENOENT) || (!status && !buf.st_size))
		{
			RISapp_cleanup_client();
			LONGJMP(RIS_E_CLIENT_DIED);
		}
#else /* all other unix */
	status = kill ((pid_t)net->id.shmem.pid, 0);
	APP_DBG(("status = %d errno = %d \n",status,errno));

/* the client is dead if process doesn't exist or is a zombie */
	if (status && (errno == ESRCH))
	{
		RISapp_cleanup_client();
		LONGJMP(RIS_E_CLIENT_DIED);
	}

#endif /* all other unix */
	}

	APP_DBG(("RISapp_check_client: complete\n"));
#endif /* unix */
}

/******************************************************************************/

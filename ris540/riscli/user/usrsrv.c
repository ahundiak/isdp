/*
**	NAME:							usrsrv.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/86
**	ABSTRACT:
**		Contains the functions that do the server management.
**	
**	REVISION HISTORY:
**      Changed fieldname 'usr' to 'schowner' in ris_schema_info
**      and risschema structures
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**	1995.07.18:TR439502928:Alan Barksdale:Made initial request for server
**	architecture in start_server use INITIAL_TIMEOUT from the parms file as
**	a timeout if TIMESTAMP_INTERVAL is greater than 0, which indicates that
**      the user does want the client to check server status periodically and
**	not wait forever for responses.  Added a special error message if the
**	request timed out.  These changes were made in response to an urgent
**	request from Sarah Byram in the E911 group.  They had found that when
**	their database server machine didn't respond to
**	RIScom_rec_architecture, their database client process hung.  I added
**	the selective blocking capability only at this point to minimize
**	impacts, though it probably would make sense to do it elsewhere.
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "risver.h"
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "risprods.h"
#include "arch.h"
#include "net.h"
#include "user.h"

/*
**	FUNCTION PROTOTYPES
*/
#define usrsrv_c
#include "ccoerror.prt"
#include "ccosqlca.prt"
#include "comdebug.prt"
#include "comalloc.prt"
#include "comarch.prt"
#include "comgtdir.prt"
#include "comjmp.prt"
#include "compath.prt"
#include "compd.prt"
#include "comwrap.prt"
#include "dicclsch.prt"
#include "netgnerc.prt"
#include "usrdb.prt"
#include "usrerror.prt"
#include "usrkill.prt"
#include "usrsndrc.prt"
#include "usrsrv.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static int initializing = 0;

/*
**	FUNCTIONS
*/



extern void RISusr_server(
	risschema	*schema,
	int			code,
	int			options_flag)
{
	int				i;
	int				status;
	int				send_code;
	int 			nullcount;
	int 			val;
	char			proto_str[RIS_MAX_PROTOCOLS];
	char			*str = 0;
	char			*xns_addr;
	char			*tcp_addr;
	char			*dnp_addr;
	net_connect_s	connect;
    risschema       *sch;
    risschema       *chosen_sch;
	static int		loc_srv_count; /* Added this variable to keep track of
									local server count. RAJU */

	USR_DBG(("RISusr_server(schema:0x%x code:%d options_flag:%d)\n"
		"RISusr_server: dbname:<%s> addr:<%s> schowner:<%s> dbid:%d\n"
		"RISusr_server: major:<%d> feature:<%d>\n",
		schema, code, options_flag, schema->db->dbname,
		schema->db->pathways[0].netaddr, schema->schowner, schema->dbid,
		schema->major, schema->feature));

	if (initializing)
	{
		/* error if we're already initializing */
		LONGJMP(RIS_E_CANT_START_SERVER);
	}
	initializing = 1;

	status = SETJMP();
	if (status)
	{
		USR_DBG(("RISusr_server 0x%x: error handler got status: %d\n",
			schema, status));

		RESETJMP();

		RIScco_push_risca_dbca();

		if (!SETJMP())
		{
			RISusr_kill_srv(schema, CLOSE_SCHEMA|CLEAR_SCHEMA|CLOSE_NET,
				SYNC_MODE);
		}
		RESETJMP();

		initializing = 0;

		RIScco_pop_risca_dbca();

		LONGJMP(status);
	}

	if (code)
	{
		send_code = code;
	}
	else
	{
		send_code = RIS_OPEN_SCHEMA_CODE;
	}

	/* 
	** get the password of the schema from risdclrschema for secure schema
	*/
	/*
	if (!(strlen(schema->passwd)))
	{
		dschema = RISdic_lookup_risdclrsch(schema->schname);
		if (dschema)
		{
			strcpy(schema->passwd, dschema->schuserpd);
		}
		else
		{
		}
	}
	*/
	/* insert schema in server list */
	schema->next = RIS_srvs;
	RIS_srvs = schema;

	if (!schema->net)
	{
		schema->net = ALLOCTS(schema->schid,net_s);
	}
	if (!schema->arc)
	{
		schema->arc = ALLOCTS(schema->schid,arc_s);
	}

	schema->net->error_handler = RISusr_net_errhandle;
	schema->arc->error_handler = RIScco_arc_errhandle;

	schema->cli_to_srv_buf_size = RIS_INITIAL_BUFFER_SIZE;
	schema->srv_to_cli_buf_size = RIS_INITIAL_BUFFER_SIZE;

	schema->net->cs_flag = CLIENT_FLAG;

	init_net_info(schema, &connect, 0);

/* cleanup any deadbeat servers that have died */

	RISusr_check_deadbeat_srvs();

/* attempt to start the new server */

	if (schema->net->protocol == SHMEM)
	{
		if (status = SETJMP())
		{
			/*
			**	can not start a server locally
			*/
			RESETJMP();
			loc_srv_count = 0;
/*
**		Added condition for status != RIS_E_SERVER_OVERFLOW to force
**		the client to kick off server remotely or close the schema
**		which does not have a statement pending. RAJU 11/01/94
**		This is a fix for TR# 249407177.
*/
			if (schema->net->error_code != NET_E_NO_AVAIL_SEM &&
				status != RIS_E_SERVER_OVERFLOW)
			{
				 LONGJMP(status);
			}
            else
            {
                chosen_sch = 0;
                for (sch = RIS_srvs; sch ; sch = sch->next)
                {
                    if ((sch != RIS_default) &&
                        (sch != schema) &&
                        (sch->superschema_flag == REGULAR_SCHEMA) &&
                        (!sch->ref_by_crnt_stmt) &&
                        (sch->net->protocol == SHMEM) &&
                        no_pending_stmt(sch))
                    {
                        chosen_sch = sch;
						USR_DBG(("chosen_sch: %s\n",chosen_sch->schname));
                    }
                }

                if (chosen_sch)
                {
                    RISdic_close_schema(chosen_sch->schname, SYNC_MODE);
                    start_server(schema, &connect);
                }
                else
                {
                    /*
                    **  try starting remotely
                    */
                    init_net_info(schema, &connect, 1);
                    if (schema->net->protocol == SHMEM) LONGJMP(status);

                    start_server(schema, &connect);
                }
            }
		}
		else
		{
			loc_srv_count++;
/*
**	Added LONGJMP if loc_srv_count exceeds MAX_LOCAL_SERVER parameter.
**	This fixes TR# 249405995 RAJU. 09/06/94
*/ 
			if (loc_srv_count >= RIS_parms.max_locals)
				LONGJMP(RIS_E_SERVER_OVERFLOW);
			start_server(schema, &connect);
			RESETJMP();
		}
	}
	else
	{
		start_server(schema, &connect);
	}

	USR_DBG(("RISusr_server: child init'd... sending open/create code\n"));

	RIS_sdp->schema = schema;
	RIS_sdp->misc = (unsigned int *)options_flag;
	RISusr_send_rec((char)send_code, RIS_sdp, SYNC_MODE);

	if (code)
	{
		if (code == RIS_CRE_SCH_GET_GRANTEES_CODE ||
			code == RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE ||
			code == RIS_OPEN_SCHEMA_CODE)
		{
			if (schema->net->protocol == SHMEM)
			{
				xns_addr = RIS_local_xns_addr;
				tcp_addr = RIS_local_tcp_addr;
				dnp_addr = RIS_local_dnp_addr;
			}
			else
			{
				xns_addr = RIS_remote_xns_addr;
				tcp_addr = RIS_remote_tcp_addr;
				dnp_addr = RIS_remote_dnp_addr;
			}

			/* Fill in as many network addresses as possible. */

			USR_DBG(("*****************************************\n"));
			for (i=0;i<RIS_MAX_PROTOCOLS;i++)
			{
				if (strncmp(schema->db->pathways[i].netaddr, "NULL", 4) == 0)
				{
					if (schema->db->pathways[i].protocol == 'X')
					{
						strcpy(schema->db->pathways[i].netaddr, "NULLXNS");
					}
					else if (schema->db->pathways[i].protocol == 'T')
					{
						strcpy(schema->db->pathways[i].netaddr, "NULLTCP");
					}
					else if (schema->db->pathways[i].protocol == 'D')
					{
						strcpy(schema->db->pathways[i].netaddr, "NULLDNP");
					}
				}
				USR_DBG(("\t\tprotocol[%d]:<%c> netaddr:<%s>\n", i,
					schema->db->pathways[i].protocol,
					schema->db->pathways[i].netaddr));
			}
			USR_DBG(("*****************************************\n"));

			memset(proto_str,0,sizeof(proto_str));
			for (i = 0;
				 i < RIS_MAX_PROTOCOLS &&
				 schema->db->pathways[i].protocol &&
				 (strncmp(schema->db->pathways[i].netaddr,"NULL", 4) != 0);
				 i++)
			{
				proto_str[i] = schema->db->pathways[i].protocol;
				switch(schema->db->pathways[i].protocol)
				{
					case 'X':
						str = xns_addr;
					break;
					case 'T':
						str = tcp_addr;
					break;
					case 'D':
						str = dnp_addr;
					break;
					default:
						LONGJMP(RIS_E_INTERNAL_ERROR);
					break;
				}
				USR_DBG(("RISusr_server: protocol:%c\n schema addr:<%s>\n "
					" server addr:<%s>\n",
					schema->db->pathways[i].protocol,
					schema->db->pathways[i].netaddr, str));

/* the server is responsible for checking that the addresses match */

				if (strcmp(schema->db->pathways[i].netaddr,str) != 0)
				{
					LONGJMP(RIS_E_INCONSISTENT_ADDRS);
				}
			}
/*
** Make sure that you put in the protocols for all NULLiefied addresses
*/
			for (val=0; val<RIS_MAX_PROTOCOLS; val++)
			{
				if (strncmp(schema->db->pathways[val].netaddr,"NULLXNS",7)==0 &&
				 	!schema->db->pathways[val].protocol)
				{
					schema->db->pathways[val].protocol = 'X';
				}
				if (strncmp(schema->db->pathways[val].netaddr,"NULLTCP",7)==0 &&
				 	!schema->db->pathways[val].protocol)
				{
					schema->db->pathways[val].protocol = 'T';
				}
				if (strncmp(schema->db->pathways[val].netaddr,"NULLDNP",7)==0 &&
				 	!schema->db->pathways[val].protocol)
				{
					schema->db->pathways[val].protocol = 'D';
				}
			}
			nullcount = i;
			if (!strchr(proto_str,'X') && xns_addr[0])
			{
				if (strncmp(schema->db->pathways[nullcount].netaddr,
					"NULLXNS", 7) != 0)
				{
					schema->db->pathways[i].protocol = 'X';
					strcpy(schema->db->pathways[i].netaddr,xns_addr);
					USR_DBG(("RISusr_server:protocol[%d]:%c schema addr:<%s>\n",
						i,
						schema->db->pathways[i].protocol,
						schema->db->pathways[i].netaddr));
				}
				else
				{
					schema->db->pathways[i].protocol = 'X';
					USR_DBG(("protocol[%d] <%c> nullcount %d\n", i,
						schema->db->pathways[i].protocol, nullcount));
					nullcount++;
				}
				i++;
			}
			if (!strchr(proto_str,'T') && tcp_addr[0])
			{
				if (strncmp(schema->db->pathways[nullcount].netaddr,
					"NULLTCP", 7) != 0)
				{
					schema->db->pathways[i].protocol = 'T';
					strcpy(schema->db->pathways[i].netaddr,tcp_addr);
					USR_DBG(("RISusr_server:protocol[%d]:%c schema addr:<%s>\n",
						i,
						schema->db->pathways[i].protocol,
						schema->db->pathways[i].netaddr));
					i++;
				}
				else
				{
					schema->db->pathways[i].protocol = 'T';
					USR_DBG(("protocol[%d] %c nullcount %d\n", i,
						schema->db->pathways[i].protocol, nullcount));
					nullcount++;
				}
			}
			if (!strchr(proto_str,'D') && dnp_addr[0])
			{
				if (strncmp(schema->db->pathways[nullcount].netaddr,
					"NULLDNP", 7) != 0)
				{
					schema->db->pathways[i].protocol = 'D';
					strcpy(schema->db->pathways[i].netaddr,dnp_addr);
					USR_DBG(("RISusr_server:protocol[%d]:%c schema addr:<%s>\n",
						i,
						schema->db->pathways[i].protocol,
						schema->db->pathways[i].netaddr));
					i++;
				}
				else
				{
					schema->db->pathways[i].protocol = 'D';
					USR_DBG(("protocol[%d] %c nullcount %d\n", i,
						schema->db->pathways[i].protocol, nullcount));
				}
			}
			/*
			** Make sure you put back the string "NULL" so that that's
			** what get's written back to the schema file.
			*/
			USR_DBG(("Putting back the null string where necessary\n"));
			for (i=0; i < RIS_MAX_PROTOCOLS; i++)
			{
				if (strncmp(schema->db->pathways[i].netaddr, "NULL", 4) == 0)
				{
					strcpy(schema->db->pathways[i].netaddr,"NULL");
				}
				USR_DBG(("protocol[%d] %c addr:<%s>\n", i,
					schema->db->pathways[i].protocol,
					schema->db->pathways[i].netaddr));
			}
		}
	}
	RESETJMP();
	initializing = 0;

	USR_DBG(("RISusr_server:complete\n"));
}

/******************************************************************************/

static void start_server(
	risschema		*schema,
	net_connect_s	*connect)
{
	int	status;

	USR_DBG(("start_server(schema:0x%x(%s) connect:0x%x)\n",
		schema, schema->schname, connect));
/*
** Make sure that we do not get a signal from a server that couldn't start
** until we are done with the connect.
*/
	NET_connect(schema->net, connect);

	if (schema->net->protocol == TCP)
	{
		/*
		** Special case for TCP/IP protocol
		**
		** When using tcp/ip we actually started a very small
		** program called "ristcpsr" on the remote machine. We now
		** have to tell it which database server to start by
		** sending "ristcpsr" a 8 byte value.
		*/

		int length;
		char buffer[8];
		int	match_flag = MATCH_COMPATIBLE;

		length = 8;
		buffer[0] = (char)0;
		buffer[1] = (char)0;
		buffer[2] = (char)0;
		buffer[4] = schema->db->dtype;
		if (schema->major == -1)
		{
			buffer[5] = (char)RIS_version_maj;
		}
		else
		{
			buffer[5] = (char)schema->major;
		}
		if (schema->feature == -1)
		{
			buffer[6] = (char)RIS_version_min;
		}
		else
		{
			buffer[6] = (char)schema->feature;
			match_flag = MATCH_MAJOR_FEATURE;
		}
		buffer[7] = (char)0;
		buffer[3] = (char)match_flag;

		USR_DBG(("start_server: sending remote tcp server; "
				 "dtype:%c maj:%d min:%d rel:%d match_flag:%d\n",
				 buffer[4], buffer[5], buffer[6], buffer[7], buffer[3]));

		/*
		** NET_write_no_len(schema->net, buffer, &length, BLOCKING);
		**
		** We are doing a NET_write and NOT a NET_write_no_len only
		** for compatibility with version 3.2.1 (where we do the same.
		** because potentially, a 3.2.1 client may invoke a 4.* ristcpsrv.
		** Sunil 10/16/92
		*/

		/*
		** NET_write(schema->net, buffer, &length, BLOCKING);
		**
		** In version 5, we are using the 3rd byte to send the match_flag
		** information. So go back to using NET_write_no_len.
		*/
		NET_write_no_len(schema->net, buffer, &length, BLOCKING);
	}

	/*
	** The standard after connecting to any network is to
	** determine what the remote architecture is. We need
	** to know this before any data is sent, so we can properly
	** do datatype conversions for machines with different
	** architectures.
	**
	** The proper protocol is for the controlling process
	** to send its architecture, and then receive the slave's
	** architectures. (client sends - server receives, then
	** server sends - client receives)
	*/

	/*
	** SPECIAL NOTE:
	** We must perform this architecture definition after
	** the connection phase because of the special requirements
	** of the tcp/ip section above.
	*/

	RIScom_send_architecture(schema->net, schema->arc, TO_BACKEND);

	status = SETJMP();
	if(status)
	{
		RESETJMP();
		if(NET_E_TIMEOUT == schema->net->error_code)
		{
			USR_DBG(("%s,%d:timeout trying to connect to server the first time\n",
				__FILE__, __LINE__));
			LONGJMP(RIS_E_SERVER_ARCH_TIMEOUT);
		}
		else
		{
			LONGJMP(status);
		}
	}
	else
	{
		USR_DBG(("%s,%d:start_server:timestamp_interval = %d, initial_timeout = %d\n",
			__FILE__, __LINE__, RIS_timestamp.timestamp_interval,
             	   RIS_timestamp.initial_timeout));
		if(0 == RIS_timestamp.timestamp_interval)
		{
			RIScom_rec_architecture(schema->net, schema->arc, FROM_BACKEND, BLOCKING);
		}
		else
		{
			RIScom_rec_architecture(schema->net, schema->arc, FROM_BACKEND, RIS_timestamp.initial_timeout);
		}
		RESETJMP();
	}

	USR_DBG(("start_server:complete\n"));
}

/******************************************************************************/

static void init_net_info(
	risschema *schema,
	net_connect_s *connect,
	int	remote_flag)
{
	short 	prognum = 0;
	int		development;
	char	risdir[RIS_MAX_PATH_SIZE];
	risdb	*db;
	int		ret = 0;
	int		index = 0;

	int		server_major, server_feature, match_flag;

/* added by goverdhan    6/9 */
#ifdef WIN32
	char		tmp_orapath[RIS_MAX_PATH_SIZE];
#endif

	USR_DBG(("init_net_info(schema:0x%x connect:0x%x remote_flag:%d)\n",
		schema, connect, remote_flag));

	/*
	**
	*/
	match_flag = MATCH_COMPATIBLE;
	if (schema->major == -1)
	{
		server_major = RIS_version_maj;
	}
	else
	{
		server_major = (int)schema->major;
	}
	if (schema->feature == -1 && RIS_version_maj != 5 )
	{
		server_feature = RIS_version_min;
	}
	else
	{
        	server_feature = (server_major == 5) ? 0 : (int)schema->feature;
		match_flag = MATCH_MAJOR_FEATURE;
	}

	db = schema->db;
/*
** This is only in 4.0.*.
*/
    switch (db->dtype)
    {
        case 'O':   /* oracle */
            prognum = 1;
            break;
        case 'I':   /* ingres */
            prognum = 2;
            break;
        case 'R':   /* rdb */
            prognum = 5;
            break;
        default:
            break;
    }

	if (RIS_remote_test || remote_flag ||
		RISusr_db_on_remote_machine(db, &index))
	{
		switch (db->pathways[index].protocol)
		{
			case 'D':	/* DNP (dec net) */
				schema->net->protocol = DNP;
				break;

			case 'T':	/* tcp */
				schema->net->protocol = TCP;
				break;

			case 'X':	/* xns */
                /*
                ** Only for 4.0.*
                */
                prognum += 30;
				schema->net->protocol = XNS;
				break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
				break;
		}
	}
	else
	{
		schema->net->protocol = SHMEM;
	}

	memset(connect, 0, sizeof(net_connect_s));

	switch(schema->net->protocol)
	{
		case SHMEM:
        	connect->shmem.shmem_info.shm_seg_size = RIS_parms.shm_seg_size;
        	connect->shmem.shmem_info.shm_key = RIS_SHM_KEY;
        	connect->shmem.shmem_info.shm_access = SHM_SEG_ACCESS;
        	connect->shmem.shmem_info.sem_cnt = RIS_parms.max_locals;
        	connect->shmem.shmem_info.sem_key = RIS_SEM_KEY;
        	connect->shmem.shmem_info.sem_access = SEM_SET_ACCESS;
			switch(db->dtype)
			{
				case 'X':
					/*
					** if RISXCNET (RISXSNET) is found, use it, 
					** otherwise use RISXC (RISXS)
					*/
					ret = RIScom_get_risdir(RISXNET_PRODUCT,
							server_major,
							server_feature,
							0, 
							match_flag, 0, RISCONFIG_FILE, risdir, &development,
							dbca);
					if (!ret)
					{
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISXNET_PROGRAM);
/* added by goverdhan           6/9 */
#ifdef WIN32
						strcpy(tmp_orapath,connect->shmem.path);
						strcat(tmp_orapath,".exe");
						if (RIScom_access(tmp_orapath,0))
#else
						if (RIScom_access(connect->shmem.path,0))
#endif
						{
							ret = RIScom_get_risdir(RISX_PRODUCT,
									server_major,
									server_feature,
									0,
									match_flag, 0,
									RISCONFIG_FILE, risdir, &development, dbca);
							if (ret)
							{
								LONGJMP(ret);
							}
							RIScom_generate_local_exe_path(connect->shmem.path,
								risdir, development, "rissrv", RISX_PROGRAM);
						}
					}
					else
					{
						ret = RIScom_get_risdir(RISX_PRODUCT,
								server_major,
								server_feature,
								0,
								match_flag, 0, RISCONFIG_FILE,
								risdir, &development, dbca);
						if (ret)
						{
							LONGJMP(ret);
						}
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISX_PROGRAM);
					}
					break;

				case 'O':
					/* 
					** if RISOCNET (RISOSNET) is found, use it, 
					** otherwise use RISOC (RISOS) 
					*/
					ret = RIScom_get_risdir(RISONET_PRODUCT,
							server_major,
							server_feature,
							0,
							match_flag, 0, RISCONFIG_FILE, risdir, &development,
							dbca);
					if (!ret)
					{
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISONET_PROGRAM);
/* added by goverdhan           6/9 */
#ifdef WIN32
						strcpy(tmp_orapath,connect->shmem.path);
						strcat(tmp_orapath,".exe");
						if (RIScom_access(tmp_orapath,0))
#else
						if (RIScom_access(connect->shmem.path,0))
#endif
						{
							ret = RIScom_get_risdir(RISO_PRODUCT,
									server_major,
									server_feature,
									0,
									match_flag, 0,
									RISCONFIG_FILE, risdir, &development, dbca);
							if (ret)
							{
								LONGJMP(ret);
							}
							RIScom_generate_local_exe_path(connect->shmem.path,
								risdir, development, "rissrv", RISO_PROGRAM);
						}
					}
					else
					{
						ret = RIScom_get_risdir(RISO_PRODUCT,
								server_major,
								server_feature,
								0,
								match_flag, 0, RISCONFIG_FILE,
								risdir, &development, dbca);
						if (ret)
						{
							LONGJMP(ret);
						}
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISO_PROGRAM);
					}
					break;

				case 'I':
					/* 
					** if RISICNET (RISISNET) is found, use it, 
					** otherwise use RISIC (RISIS) 
					*/
					ret = RIScom_get_risdir(RISINET_PRODUCT,
							server_major,
							server_feature,
							0,
							match_flag, 0, RISCONFIG_FILE, risdir, &development,
							dbca);
					if (!ret)
					{
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISINET_PROGRAM);
						if (RIScom_access(connect->shmem.path,0))
						{
							ret = RIScom_get_risdir(RISI_PRODUCT,
									server_major,
									server_feature,
									0,
									match_flag, 0,
									RISCONFIG_FILE, risdir, &development, dbca);
							if (ret)
							{
								LONGJMP(ret);
							}
							RIScom_generate_local_exe_path(connect->shmem.path,
								risdir, development, "rissrv", RISI_PROGRAM);
						}
					}
					else
					{
						ret = RIScom_get_risdir(RISI_PRODUCT,
								server_major,
								server_feature,
								0,
								match_flag, 0, RISCONFIG_FILE,
								risdir, &development, dbca);
						if (ret)
						{
							LONGJMP(ret);
						}
						RIScom_generate_local_exe_path(connect->shmem.path,
							risdir, development, "rissrv", RISI_PROGRAM);
					}
					break;

				case 'D':
					ret = RIScom_get_risdir(RISD_PRODUCT,
							server_major,
							server_feature,
							0,
							match_flag, 0, RISCONFIG_FILE, risdir,
							&development, dbca);
					if (ret)
					{
						LONGJMP(ret);
					}
					RIScom_generate_local_exe_path(connect->shmem.path,
						risdir, development, "rissrv", RISD_PROGRAM);
					break;

               case '4':
                    ret = RIScom_get_risdir(RISOS4DS_PRODUCT,
                            server_major,
                            server_feature,
                            0,
                            match_flag, 0, 0, risdir, &development, dbca);
                    if (ret)
                    {
                        LONGJMP(ret);
                    }
                    RIScom_generate_local_exe_path(connect->shmem.path,
                        risdir, development, "rissrv", RISOS4DS_PROGRAM);
                    break;

				case 'S': /* SQLDS */
					LONGJMP(RIS_E_NOT_LOCAL_SERVER);
					break;

				case 'R': /* RDB */
					LONGJMP(RIS_E_NOT_LOCAL_SERVER);
					break;

				case 'Y': /* SYBASE */
#if defined(__clipper__)
					LONGJMP(RIS_E_NOT_LOCAL_SERVER);
#elif defined (unix) || defined(WIN32)
					ret = RIScom_get_risdir(RISY_PRODUCT,
							server_major,
							server_feature,
							0,
							match_flag, 0, RISCONFIG_FILE, risdir,
							&development, dbca);
					if (ret)
					{
						LONGJMP(ret);
					}
					RIScom_generate_local_exe_path(connect->shmem.path,
						risdir, development, "rissrv", RISY_PROGRAM);
#endif 
					break;

				case 'M': /* MSSQL */
#if defined(unix)
					LONGJMP(RIS_E_NOT_LOCAL_SERVER);
#elif defined(WIN32)
					ret = RIScom_get_risdir(RISMSSQL_PRODUCT,
							server_major,
							server_feature,
							0,
							match_flag, 0, RISCONFIG_FILE, risdir,
							&development, dbca);
					if (ret)
					{
						LONGJMP(ret);
					}
					RIScom_generate_local_exe_path(connect->shmem.path,
						risdir, development, "rissrv", RISMSSQL_PROGRAM);
#endif 
					break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;
			}
			connect->shmem.arg1[0] = 'M';
            USR_DBG(("init_net_info: connect to SHMEM server: path:<%s> "
				"arg1:<%s>\n", connect->shmem.path, connect->shmem.arg1));
			break;

		case XNS:
			strcpy(connect->xns.address,db->pathways[index].netaddr);
			switch(db->dtype)
			{
				case 'X':
					strcpy(connect->xns.username,schema->schowner);
					if (*schema->passwd)
					{
						RIScom_depd(schema->passwd, connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}
					sprintf(connect->xns.server_name,
						"/usr/ip32/ris/links/risinfds.%d_%d_X X",
						server_major,
						server_feature);
					connect->xns.server_num = 0;
					break;

				case 'O':
					if (!db->parms.ora.osuser[0])
					{
						LONGJMP(RIS_E_NO_OSUSER);
					}
					strcpy(connect->xns.username, db->parms.ora.osuser);
					if (*db->parms.ora.ospass)
					{
						RIScom_depd(db->parms.ora.ospass,
							connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}

					switch(db->ostype)
					{
						case 'V': /* VMS */
							/* For 4.0.x, we want to start up the old way
							** because the links mechanism does not work on
							** the VAX
							*/
							connect->xns.server_num = prognum;
							break;
						case 'U': /* UNIX */
							sprintf(connect->xns.server_name,
								"/usr/ip32/ris/links/risorads.%d_%d_X X",
								server_major,
								server_feature);
							connect->xns.server_num = 0;
							break;
						default:
							USR_DBG(("init_net_info: Invalid OSTYPE\n"));
							LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					break;

				case 'I':
					strcpy(connect->xns.username,schema->schowner);
					if (*schema->passwd)
					{
						RIScom_depd(schema->passwd, connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}

					switch(db->ostype)
					{
						case 'V': /* VMS */
							/* For 4.0.x, we want to start up the old way
							** because the links mechanism does not work on
							** the VAX
							*/
							connect->xns.server_num = prognum;
							break;
						case 'U': /* UNIX */
							sprintf(connect->xns.server_name,
								"/usr/ip32/ris/links/risingds.%d_%d_X X",
								server_major,
								server_feature);
							connect->xns.server_num = 0;
							break;
						default:
							USR_DBG(("init_net_info: Invalid OSTYPE\n"));
							LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					break;

				case 'D':
					if (!db->parms.db2.osuser[0])
					{
						LONGJMP(RIS_E_NO_OSUSER);
					}
					strcpy(connect->xns.username, db->parms.db2.osuser);
					if (*db->parms.db2.ospass)
					{
						RIScom_depd(db->parms.db2.ospass,connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}

					switch(db->ostype)
					{
						case 'U': /* UNIX */
							sprintf(connect->xns.server_name,
								"/usr/ip32/ris/links/risdb2ds.%d_%d_X X",
								server_major,
								server_feature);
							connect->xns.server_num = 0;
							break;
						default:
							USR_DBG(("init_net_info: Invalid OSTYPE\n"));
							LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					break;

                case '4':
                    if (!db->parms.os400.osuser[0])
                    {
                        LONGJMP(RIS_E_NO_OSUSER);
                    }
                    strcpy(connect->xns.username, db->parms.os400.osuser);
                    if (*db->parms.os400.ospass)
                    {
                       	RIScom_depd(db->parms.os400.ospass,connect->xns.password);
                    }
                    else
                    {
                        connect->xns.password[0] = '\0';
                    }
                    sprintf(connect->xns.server_name,
                        "/usr/ip32/ris/links/ris400ds.%d_%d_X X",
                        server_major,
                        server_feature);
                    connect->xns.server_num = 0;
                    break;

				case 'S':
					strcpy(connect->xns.username,schema->schowner);
					if (*schema->passwd)
					{
						RIScom_depd(schema->passwd, connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}
					sprintf(connect->xns.server_name,
						"/usr/ip32/ris/links/rissc.%d_%d_X X",
						server_major,
						server_feature);
					connect->xns.server_num = 0;
					break;

				case 'R':
					strcpy(connect->xns.username,schema->schowner);
					if (*schema->passwd)
					{
						RIScom_depd(schema->passwd, connect->xns.password);
					}
					else
					{
						connect->xns.password[0] = '\0';
					}

					switch(db->ostype)
					{
						case 'V': /* VMS */
							/* For 4.0.x, we want to start up the old way
							** because the links mechanism does not work on
							** the VAX
							*/
							connect->xns.server_num = prognum;
							break;
						default:
							USR_DBG(("init_net_info: Invalid OSTYPE\n"));
							LONGJMP(RIS_E_INTERNAL_ERROR);
					}
					break;

				case 'Y':
					USR_DBG(("init_net_info: XNS invalid for sybase\n"));
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;

				case 'M':
					USR_DBG(("init_net_info: XNS invalid for MSSQL\n"));
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;
			}
            USR_DBG(("init_net_info: connect to XNS server: addr:<%s> "
				"schowner:<%s> server_num:%d server_name:<%s>\n",
				connect->xns.address, connect->xns.username,
				connect->xns.server_num, STRING(connect->xns.server_name)));
			break;

		case TCP:
			strcpy(connect->tcp.address,db->pathways[index].netaddr);
			connect->tcp.port = RIS_TCP_SERVICE_NUMBER;
            USR_DBG(("init_net_info: connect to TCP server: addr:<%s> "
				"port:<%d>\n", connect->tcp.address,connect->tcp.port));
			break;

		case DNP:
        	strcpy(connect->dnp.node_name, db->pathways[index].netaddr);
        	connect->dnp.object_nbr = 0;
            strcpy(connect->dnp.userid, schema->schowner);
			if (*schema->passwd)
			{
				RIScom_depd(schema->passwd, connect->dnp.password);
			}
			else
			{
				connect->dnp.password[0] = '\0';
			}
			switch(db->dtype)
			{
				case 'X':
					sprintf(connect->dnp.task_name, "RISX_%d_%d_X",
						server_major,
						server_feature);
					break;

				case 'O':
					sprintf(connect->dnp.task_name, "RISO_%d_%d_X",
						server_major,
						server_feature);
                    /* for oracle we have to login on the */
                    /* default decnet account */
                    connect->dnp.userid[0] = '\0';
                    connect->dnp.password[0] = '\0';
					break;

				case 'I':
					sprintf(connect->dnp.task_name, "RISI_%d_%d_X",
						server_major,
						server_feature);
					break;

				case 'D':
					sprintf(connect->dnp.task_name, "RISD_%d_%d_X",
						server_major,
						server_feature);
                    /* for DB2 we have to login on the */
                    /* default decnet account */
                    connect->dnp.userid[0] = '\0';
                    connect->dnp.password[0] = '\0';
					break;

				case 'S':
					sprintf(connect->dnp.task_name, "RISS_%d_%d_X",
						server_major,
						server_feature);
					break;

				case 'R':
					sprintf(connect->dnp.task_name, "RISR_%d_%d_X",
						server_major,
						server_feature);
					break;

				case 'Y':
					USR_DBG(("init_net_info: DNP invalid for sybase\n"));
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;

				case 'M':
					USR_DBG(("init_net_info: DNP invalid for MSSQL\n"));
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;

				default:
					LONGJMP(RIS_E_INTERNAL_ERROR);
					break;
			}
            USR_DBG(("RISusr_start_remote: connect to DNP server: nodename:<%s>"
				" userid:<%s> task_name:<%s>\n", connect->dnp.node_name,
				connect->dnp.userid, connect->dnp.task_name));
 
			break;

		case LU62:
			break;

		default:
			USR_DBG(("init_net_info: invalid schema->net->protocol:%d\n",
				schema->net->protocol));
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	USR_DBG(("init_net_info: complete\n"));
}

/******************************************************************************/

/*
** Determines if any statements are prepared for a schema.
** Note that these may be dynamic or static statements.
** We would like to ignore static statements if we could someday.
*/

static int no_pending_stmt(
    risschema * schema)
{
    unsigned int i;

    USR_DBG(("no_pending_stmt: schema = 0x%x\n", schema);)

    for (i=0;i < RIS_max_stmts;i++)
    {
        if (RIS_stmts[i] &&
            RIS_stmts[i]->sql &&
            RIS_stmts[i]->sql->schema == schema)
        {
            return(0);
        }
    }

    return(1);
}

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.5.9.1 $ */
/*
**	NAME:							climain.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		11/94:	Added locale information for INTERNATIONALIZATION.
**				Dianne
*/
 
/*
**	INCLUDES
*/
#include <signal.h>
#include <errno.h>
#include "risver.h"
#include "riscom.h"
#include "risdict.h"
#include "rismem.h"
#include "risprods.h"
#include "client.h"
#include "clicnv.h"
#include "net.h"
#if defined(WIN32)
#include <locale.h>
#endif

/*
**	DEFINES
*/
#define CLIENT_TIMEOUT	10
#if defined(WIN32)
#define OUT_FILE		"c:\tmp\riscli.out"
#endif
#if defined(unix) 
#define OUT_FILE		"/usr/tmp/riscli.out"
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define climain_c
#include "arcgnerc.prt"
#include "ccoerror.prt"
#include "clierbuf.prt"
#include "clicnv.prt"
#include "climain.prt"
#include "clisndrc.prt"
#include "clisig.prt"
#include "cliterm.prt"
#include "comalloc.prt"
#include "comarch.prt"
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comjmp.prt"
#include "commem.prt"
#include "comsqlca.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
#if defined(WIN32)
extern HANDLE	hMapObject, hEventC, hEventS;
extern int		client_died;
extern SOCKET	asd, closesd;
#endif

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void main(
	int		argc,
	char	*argv[])
{
	int				status;
	static char		opcode = 0;
	int ret = 0;

#if defined(__hpux__)
         mallopt(M_GRAIN,8);
#endif /* __HPUX__*/

#if defined(__clipper__) || defined (sco)
	/*
	** C2 security setup.  Required.  Immediately.
	*/
	set_auth_parameters(argc,argv);
#endif
#if defined(WIN32)
	DWORD           excepttype=0;
	PEXCEPTION_POINTERS exceptinfo=0;
	PVOID           exceptaddr=0;
__try {
#endif
	risca = &RIS_risca;
	memset(risca, 0, sizeof(rissqlca));
	risca->sqlstmt = RIS_risstmt;

	dbca = &RIS_dbca;
	memset(dbca, 0, sizeof(rissqlca));
	dbca->sqlstmt = RIS_dbstmt;

	status = SETJMP();
	if (status)
	{
		CLI_DBG(("%s,%d:main of risclient:got error %d, exiting\n",__FILE__,__LINE__,status));
		exit(-1);
	}

	SET_CLIENT;

	/*
	**	Initialize debug
	*/
	RIScom_initialize_debug();
#if defined(WIN32)
/* added for unicode support 8/26/94 -= dianne */
	if (!setlocale(LC_ALL,"")) 
	{
		CLI_DBG(("Cannot set Locale for client machine\n"));
		LONGJMP(RIS_E_ERROR_FROM_LOCALE);
        }
#endif
	/*
	**	stop process group signals from being passed to the client process
	*/
#if defined(unix) 
	setpgrp();
#endif

	/*
	**	Initialize signals
	*/
#if defined(unix) 
	RIScli_init_signal();
#endif

	/*
	**	Init RIS_dir
	*/
	ret = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_version_maj,
			RIS_version_min, RIS_version_rel, MATCH_MAJOR_MINOR_RELEASE,
			0, RISCONFIG_FILE, RIS_dir, &RIS_development, dbca);
	if (ret)
	{
		LONGJMP(ret);
	}

	/*
	**	Initialize RIS_app_net
	*/
	RIS_app_net = (net_s *)SYS_CALLOC(1, sizeof(net_s));
	RIS_app_net->cs_flag = SERVER_FLAG;
	RIS_app_net->error_handler = RIScco_net_errhandle;
	if (!strcmp(argv[1],"X"))
		RIS_app_net->protocol = XNS;
	else if (!strcmp(argv[1],"T"))
	{
		RIS_app_net->protocol = TCP;
#if defined(WIN32)
		closesd = (SOCKET)atoi(argv[2]);
		asd = (SOCKET)atoi(argv[3]);
#endif
	}
	else if (!strcmp(argv[1],"D"))
		RIS_app_net->protocol = DNP;
	else if (!strcmp(argv[1],"L"))
		RIS_app_net->protocol = LU62;
	else if (!strcmp(argv[1],"M"))
	{
		RIS_app_net->protocol = SHMEM;
#if defined(WIN32)
		hMapObject = (HANDLE)atoi(argv[2]);
		hEventC = (HANDLE)atoi(argv[3]);
		hEventS = (HANDLE)atoi(argv[4]);
#endif
	}
	else
		RIS_app_net->protocol = DNP;

	NET_set_debug_handler(RIScom_output_debug);
	NET_accept(RIS_app_net);
	NET_ERROR_CHECK(RIS_app_net, RIS_E_NET_INIT_ERROR);

	/*
	**	Allocate application network buffers
	*/
	RIS_app_read_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_app_read = (ris_appcli_buf *)NET_alloc(RIS_app_read_size);
	if (RIS_app_read == NULL)
	{
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}

	RIS_app_write_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_app_write = (ris_cliapp_buf *)NET_alloc(RIS_app_write_size);
	if (RIS_app_write == NULL)
	{
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}

	/*
	**	Allocate server network buffers
	*/
	RIS_save_srv_read_size = RIS_srv_read_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_srv_read = (ris_srvcli_buf *)NET_alloc(RIS_srv_read_size);
	if (RIS_srv_read == NULL)
	{
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}
	RIS_save_srv_read = RIS_srv_read;

	RIS_save_srv_write_size = RIS_srv_write_size = RIS_INITIAL_BUFFER_SIZE;
	RIS_srv_write = (ris_clisrv_buf *)NET_alloc(RIS_srv_write_size);
	if (RIS_srv_write == NULL)
	{
		LONGJMP(RIS_E_NET_ALLOC_ERROR);
	}
	RIS_save_srv_write = RIS_srv_write;

	ARC_set_debug_handler(RIScom_output_debug);
	/*
	** Initialize RIS_app_arc
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
	RIS_app_arc = (arc_s *)SYS_CALLOC(1, sizeof(arc_s));
	RIScom_rec_architecture (RIS_app_net, RIS_app_arc, FROM_FRONTEND, BLOCKING);
	RIScom_send_architecture (RIS_app_net, RIS_app_arc, TO_FRONTEND);
	RIS_app_arc->error_handler = RIScco_arc_errhandle;


	/*
	**	Check alignment
	*/
	check_alignment();

	/*
	**	Init Memory
	*/
	RIScom_get_mem();


	CLI_DBG(("risclient: initialized: looping for command\n"));

	RESETJMP();

	status = SETJMP();
	if (status)
	{
		CLI_DBG(("risclient: got error %d; errno:%d\n", status, errno));

		RIScli_err_to_buf(status);

		ERROR_TO_NET(RIS_app_arc, &RIS_app_write->buf.error);
		ARC_CONVERT_INTEGER(RIS_app_arc, TO_NET, &RIS_app_write->status);

		NET_write(RIS_app_net, (char *)RIS_app_write, &RIS_app_write_len,
			BLOCKING);
		if (RIS_app_net->error_code != NET_SUCCESS)
		{
			if (RIScli_debug)
			{
				RIScom_output_debug(
					"risclient: NET_write failed sending error to app.\n");
				RIScom_output_debug("\tnet->error_code:%d\n", 
					RIS_app_net->error_code);
				RIScom_output_debug("\tnet->error_string:<%s>\n",
					RIS_app_net->error_string);
				RIScom_output_debug("\tnet->net_error_code:%d\n",
					RIS_app_net->net_error_code);
				RIScom_output_debug("\tnet->net_error_string:<%s>\n",
					RIS_app_net->net_error_string);
			}
			RIScli_terminate(-1);
		}

		if (opcode == RISCLI_INIT_CODE)
		{
			RIScli_terminate(-1);
		}

		status = 0;
	}


	while (1)
	{
		opcode = 0;
		RIScom_clear_sqlca(risca);
		RIScom_clear_sqlca(dbca);

		RIS_test_completion_flag = 1; /* If this flag is set, an error is
										considered a test completion error.
										RISusr_send_rec will clear this
										once the read has successfully 
										completed. NOTE: this only applies to
										async. statements. */

		while(1)
		{
			NET_read(RIS_app_net, (char *)RIS_app_read, &RIS_app_read_len,
				CLIENT_TIMEOUT);

			if (NET_TIMEOUT_CHECK(RIS_app_net))
			{
#if defined(unix) 
				if (getppid() == 1)
				{
					CLI_DBG(("risclient:Parent died:call RIScli_terminate\n"));
					RIScli_terminate(-1);
				}
#endif
#if defined(WIN32)
				if (client_died)
				{
					CLI_DBG(("risclient:Parent died:call RIScli_terminate\n"));
					RIScli_terminate(-1);
				}
#endif

				/*
				**	Ignoring the timeout, so clear dbca
				*/
				RIScom_clear_sqlca(dbca);
			}
			else
			{
				NET_ERROR_CHECK(RIS_app_net, RIS_E_NET_READ_APP_ERROR);
				break;
			}
		}

		opcode = RIS_app_read->opcode;

		CLI_DBG(("risclient: got opcode %d (%s)...\n", opcode,
			RIS_cli_codes[opcode]));

		CLI_DBG(("risclient: RIS_default: <%s>\n",
			RIS_default ? RIS_default->schname : "NULL"));

		RIScli_send_rec(opcode);

		CLI_DBG(("risclient: done processing opcode %d (%s)... \n",
			opcode, RIS_cli_codes[opcode]));

		NET_write(RIS_app_net, (char *)RIS_app_write, &RIS_app_write_len,
			BLOCKING);
		NET_ERROR_CHECK(RIS_app_net, RIS_E_NET_WRITE_APP_ERROR);

		if (opcode == RISCLI_TERM_CODE)
			break;
	}

	CLI_DBG(("risclient: Calling RIScli_terminate\n"));
	RIScli_terminate(0);
#if defined(WIN32)
}
__except (excepttype = GetExceptionCode(),
		exceptinfo = GetExceptionInformation(),
		exceptaddr = exceptinfo->ExceptionRecord->ExceptionAddress,
		EXCEPTION_EXECUTE_HANDLER ) {
	CLI_DBG(("risclient: EXCEPTION: 0x%x caught\n", GetExceptionCode()));
	CLI_DBG(("risclient: if bad the Addr is 0x%x: \n", exceptaddr));
	CLI_DBG(("risclient: Calling RIScli_terminate\n"));
	RIScli_terminate(-1);
}
#endif
}

/******************************************************************************/

static void check_alignment()
{
	int appcli_exec_data;
	int clisrv_pddo_data;
	int clisrv_pe_data;
	int clisrv_exec_data;
	int clisrv_open_data;

	CLI_DBG(("check_alignment()\n"));
	
	appcli_exec_data = (int)&(((ris_appcli_buf *)0)->buf.exec.data);
	if (appcli_exec_data % 8)
	{
		CLI_DBG(("check_alignment: (ris_appcli_buf *)->buf.exec.data:%d is not 8 byte aligned.\n", appcli_exec_data));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	Make sure the data fields of the application buffer and the client
	** 	buffer align.
	*/

	/*
	** pddo
	*/
	clisrv_pddo_data = (int)&(((ris_clisrv_buf *)0)->buf.pddo.data);
	if (clisrv_pddo_data != appcli_exec_data)
	{
		CLI_DBG(("check_alignment: (ris_clisrv_buf *)->buf.pddo.data:%d != (ris_appcli_buf *)->buf.exec.data:%d\n", clisrv_pddo_data, appcli_exec_data));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	pe
	*/
	clisrv_pe_data = (int)&(((ris_clisrv_buf *)0)->buf.pe.data);
	if (clisrv_pe_data != appcli_exec_data)
	{
		CLI_DBG(("check_alignment: (ris_clisrv_buf *)->buf.pe.data:%d != (ris_appcli_buf *)->buf.exec.data:%d\n", clisrv_pe_data, appcli_exec_data));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	exec
	*/
	clisrv_exec_data = (int)&(((ris_clisrv_buf *)0)->buf.exec.data);
	if (clisrv_exec_data != appcli_exec_data)
	{
		CLI_DBG(("check_alignment: (ris_clisrv_buf *)->buf.exec.data:%d != (ris_appcli_buf *)->buf.exec.data:%d\n", clisrv_exec_data, appcli_exec_data));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	**	open
	*/
	clisrv_open_data = (int)&(((ris_clisrv_buf *)0)->buf.open.data);
	if (clisrv_open_data != appcli_exec_data)
	{
		CLI_DBG(("check_alignment: (ris_clisrv_buf *)->buf.open.data:%d != (ris_appcli_buf *)->buf.exec.data:%d\n", clisrv_open_data, appcli_exec_data));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CLI_DBG(("check_alignment: returning\n"));
}

/******************************************************************************/

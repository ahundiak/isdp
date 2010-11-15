/* Do not alter this SPC information: $Revision: 1.12.3.1 $ */
/*
**	NAME:							netl62.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					7/89
**	ABSTRACT:
**		Various routines for sending and receiving message buffers
**		across the LU6.2 network interface.
**	
**	REVISION HISTORY:
**		1/95 ported to 32 bit Windows using CPI-C -- David Michal
*/
 
/*
**	INCLUDES
*/
#if defined(unix)
# include <stdio.h>
# include <malloc.h>
# include <sys/types.h>
# include <sys/utsname.h>
#endif

#if defined(WIN32)
# include <windef.h>
# define READABLE_MACROS	/* required to use CPI-C function name macros */
# include "wincpic.h"
#endif

#include "net.h"
#include "sralarm.prt"

/*
**	DEFINES
*/
#if defined(unix)
# ifdef OLD
# define CLIENT_TRACE_FILENAME	"/usr/tmp/lu62client.trc"
# define SERVER_TRACE_FILENAME	"/usr/tmp/lu62server.trc"
# endif
#endif

#if defined(WIN32)
#define DEF_SYM_DEST_NAME "        " /* this indicates no name is used */
#define WIN_CPIC_VERSION 0x0201 /* this is the version of Windows CPIC used */
#define LOCAL_TP_NAME "SLAVE3" /* The TP name that NET_accept will use */

/* Microsoft seems to have forgotten to define this one */
#define Extract_Conversation_State(v1,v2,v3)	cmecs(v1,v2,v3)

#define NET_PROFILE_FUNC(index,func,func_name,parms) \
{ \
	long begin_time; \
	long end_time; \
	long elapsed_time; \
\
	if (NET_debug) \
	{ \
		begin_time = timeGetTime(); \
	} \
\
	func parms ; \
\
	if (NET_debug) \
	{ \
		end_time = timeGetTime(); \
		elapsed_time = end_time - begin_time; \
		total_receive_count[index]++; \
		total_receive_time[index] += elapsed_time; \
	} \
	NET_DBG(("%-34s cnt %5d tim %6d tot %8d avg %6d\n", \
	 func_name, total_receive_count[index], elapsed_time, total_receive_time[index], \
	 total_receive_time[index] / total_receive_count[index])); \
}

#define NET_PROFILE_FUNC_RETURN(index,func,func_name,parms,return_value) \
{ \
	long begin_time; \
	long end_time; \
	long elapsed_time; \
\
	if (NET_debug) \
	{ \
		begin_time = timeGetTime(); \
	} \
\
	return_value = func parms ; \
\
	if (NET_debug) \
	{ \
		end_time = timeGetTime(); \
		elapsed_time = end_time - begin_time; \
		total_receive_count[index]++; \
		total_receive_time[index] += elapsed_time; \
	} \
	NET_DBG(("%-34s cnt %5d tim %6d tot %8d avg %6d\n", \
	 func_name, total_receive_count[index], elapsed_time, total_receive_time[index], \
	 total_receive_time[index] / total_receive_count[index])); \
}

#define NET_INITIALIZE_CONVERSATION(parms) \
	NET_PROFILE_FUNC(0,Initialize_Conversation,"Initialize_Conversation",parms)
#define NET_SET_CONVERSATION_TYPE(parms) \
	NET_PROFILE_FUNC(1,Set_Conversation_Type,"Set_Conversation_Type",parms)
#define NET_SET_MODE_NAME(parms) \
	NET_PROFILE_FUNC(2,Set_Mode_Name,"Set_Mode_Name",parms)
#define NET_SET_PARTNER_LU_NAME(parms) \
	NET_PROFILE_FUNC(3,Set_Partner_LU_Name,"Set_Partner_LU_Name",parms)
#define NET_SET_TP_NAME(parms) \
	NET_PROFILE_FUNC(4,Set_TP_Name,"Set_TP_Name",parms)
#define NET_SET_RETURN_CONTROL(parms) \
	NET_PROFILE_FUNC(5,Set_Return_Control,"Set_Return_Control",parms)
#define NET_SET_SYNC_LEVEL(parms) \
	NET_PROFILE_FUNC(6,Set_Sync_Level,"Set_Sync_Level",parms)
#define NET_SET_CONVERSATION_SECURITY_TYPE(parms) \
	NET_PROFILE_FUNC(7,Set_Conversation_Security_Type,"Set_Conversation_Security_Type",parms)
#define NET_SET_CONVERSATION_SECURITY_USER_ID(parms) \
	NET_PROFILE_FUNC(8,Set_Conversation_Security_User_ID,"Set_Conversation_Security_User_ID",parms)
#define NET_SET_CONVERSATION_SECURITY_PASSWORD(parms) \
	NET_PROFILE_FUNC(9,Set_Conversation_Security_Password,"Set_Conversation_Security_Password",parms)
#define NET_ALLOCATE(parms) \
	NET_PROFILE_FUNC(10,Allocate,"Allocate",parms)
#define NET_FLUSH(parms) \
	NET_PROFILE_FUNC(11,Flush,"Flush",parms)
#define NET_DEALLOCATE(parms) \
	NET_PROFILE_FUNC(12,Deallocate,"Deallocate",parms)
#define NET_SET_DEALLOCATE_TYPE(parms) \
	NET_PROFILE_FUNC(13,Set_Deallocate_Type,"Set_Deallocate_Type",parms)
#define NET_ACCEPT_CONVERSATION(parms) \
	NET_PROFILE_FUNC(14,Accept_Conversation,"Accept_Conversation",parms)
#define NET_WINCPICSTARTUP(parms,return_value) \
	NET_PROFILE_FUNC_RETURN(15,WinCPICStartup,"WinCPICStartup",parms,return_value)
#define NET_SET_SEND_TYPE(parms) \
	NET_PROFILE_FUNC(16,Set_Send_Type,"Set_Send_Type",parms)
#define NET_REQUEST_TO_SEND(parms) \
	NET_PROFILE_FUNC(17,Request_To_Send,"Request_To_Send",parms)
#define NET_PREPARE_TO_RECEIVE(parms) \
	NET_PROFILE_FUNC(18,Prepare_To_Receive,"Prepare_To_Receive",parms)
#define NET_SEND_DATA(parms) \
	NET_PROFILE_FUNC(19,Send_Data,"Send_Data",parms)
#define NET_RECEIVE(parms) \
	NET_PROFILE_FUNC(20,Receive,"Receive",parms)
#define NET_EXTRACT_CONVERSATION_STATE(parms) \
	NET_PROFILE_FUNC(21,Extract_Conversation_State,"Extract_Conversation_State",parms)
#define NET_SPECIFY_LOCAL_TP_NAME(parms) \
	NET_PROFILE_FUNC(22,Specify_Local_TP_Name,"Specify_Local_TP_Name",parms)
#define NET_WAIT_FOR_CONVERSATION(parms) \
	NET_PROFILE_FUNC(23,Wait_For_Conversation,"Wait_For_Conversation",parms)
#define NET_WINCPICCLEANUP(return_value) \
	NET_PROFILE_FUNC_RETURN(24,WinCPICCleanup,"WinCPICCleanup",(),return_value)

#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define netl62_c
#include "netgnerc.prt"
#include "netlen.prt"
#include "netumsg.prt"
#include "netwrap.prt"
#include "net_sys.prt"
#include"netl62.prt"

/*
**	VARIABLES
*/
#if defined(unix)
static char		commlink[MAX_PATH_SIZE];
static short	attach_count = 0;
static short	conversation_count = 0;
extern int errno;
extern char *sys_errlist[];
#endif

#if defined (WIN32)
static int started = 0;
static long total_receive_count[25] = {0};
static long total_receive_time[25] = {0};
#endif


/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_connect for LU6.2.
** It is intended for establishing connections over LU6.2 to IBM AS/400s and 
** Mainframes.  It is implemented using CPI-C.
**
** Note that the following fields in the connect structure ar NOT used:
** char    lluname [MAX_LU_NAME_SIZE];     	local LU name
** short   llutype;        		local LU type (0 = local;1 = fully-qualified)
** short   rlutype;        		remote LU type (0 = local;1 = fully-qualified)
** char    ltpn [MAX_TRANS_PROG_NAME_SIZE]; local trans program name
** char    debug;
** char    dbtype;
** char    os;
*/

#if defined(WIN32)
extern void NET_connect_lu62(
    net_s			*net,				/* info used by all net calls */
	net_connect_s	*connect_info)		/* info used to make a connection */
{
	long return_code;					/* return code var for CPI-C calls */
	long conversation_type;				/* indicates BASIC or MAPPED */
	long return_control;				/* indicates IMMEDIATE or ALLOCATED */
	long sync_level;					/* indicates NONE or CONFIRM */
	long conversation_security_type;    /* NONE, PROGRAM or SAME */
	long length;						/* length of string parameters */
	unsigned char * conversation_ID;	/* this is used by all CPI-C calls */
	WCPICDATA CPICData;					/* CPIC version information */
	int deallocate_type;				/* ABEND, CONFIRM, FLUSH, SYNC_LEVEL */

	NET_DBG(("NET_connect_lu62(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

/* if not already started, start CPIC */

	if (!started)
	{
		NET_DBG(("calling WINCPICStartup(wVersionRequired:0x%x CPICData:0x%x)\n",
		 WIN_CPIC_VERSION,&CPICData));

		NET_WINCPICSTARTUP((WIN_CPIC_VERSION,&CPICData),return_code);
		if (return_code)
		{
			NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_STARTUP_ERROR,
			 return_code,0);

			NET_DBG(("NET_connect_lu62: failed\n"));

			return;
		}

		started = 1;

		NET_DBG(("CPIC version = %d description =\"%s\"\n",
		 CPICData.wVersion,CPICData.szDescription));
	}

/* allocate space for conversation ID */

	conversation_ID = (unsigned char *)NET_alloc(8);
	if (!conversation_ID)
	{
		NET_error_lu62(net,NET_E_OUT_OF_MEMORY,0,0,0);
		goto connect_error;
	}

/* get a conversation ID */

	NET_DBG(("calling Intialize_Conversation(conversation_ID:0x%x sym_dest_name:\"%8s\" return_code:0x%x)\n",
	 conversation_ID,DEF_SYM_DEST_NAME,&return_code));

	NET_INITIALIZE_CONVERSATION((conversation_ID,DEF_SYM_DEST_NAME,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_INIT_CONV_ERROR,
		 return_code,0);

/* must free ID before branching to connect_error */

		NET_free(conversation_ID);
		conversation_ID = 0;

		goto connect_error;
	}

/* set conversation attributes */

	conversation_type = CM_MAPPED_CONVERSATION;

	NET_DBG(("calling Set_Conversation_Type(conversation_ID:\"%8s\" conversation_type:%d return_code:0x%x)\n",
	 conversation_ID,conversation_type,&return_code));

	NET_SET_CONVERSATION_TYPE((conversation_ID,&conversation_type,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_CONV_ERROR,
		 return_code,0);
		goto connect_error;
	}

	length = strlen(connect_info->lu62.mode_name);

	NET_DBG(("calling Set_Mode_Name(conversation_ID:\"%8s\" mode_name:\"%s\" length:%d return_code:0x%x)\n",
	 conversation_ID,connect_info->lu62.mode_name,length,&return_code));

	NET_SET_MODE_NAME((conversation_ID,connect_info->lu62.mode_name,&length,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_MODE_ERROR,
		 return_code,0);
		goto connect_error;
	}

	length = strlen(connect_info->lu62.rluname);

	NET_DBG(("calling Set_Partner_LU_Name(conversation_ID:\"%8s\" partner_LU_name:\"%s\" length:%d return_code:0x%x)\n",
	 conversation_ID,connect_info->lu62.rluname,length,&return_code));

	NET_SET_PARTNER_LU_NAME((conversation_ID, connect_info->lu62.rluname,&length,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_LU_ERROR,
		 return_code,0);
		goto connect_error;
	}

	length = strlen(connect_info->lu62.rtpn);

	NET_DBG(("calling Set_TP_Name(conversation_ID:\"%8s\" TP_name:\"%s\" length:%d return_code:0x%x)\n",
	 conversation_ID,connect_info->lu62.rtpn,length,&return_code));

	NET_SET_TP_NAME((conversation_ID,connect_info->lu62.rtpn,&length,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_PROG_ERROR,
		 return_code,0);
		goto connect_error;
	}

	return_control = CM_WHEN_SESSION_ALLOCATED;

	NET_DBG(("calling Set_Return_Control(conversation_ID:\"%8s\" return_control:%d return_code:0x%x)\n",
	 conversation_ID,return_control,&return_code));

	NET_SET_RETURN_CONTROL((conversation_ID,&return_control,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_RETURN_ERROR,
		 return_code,0);
		goto connect_error;
	}

	sync_level = CM_NONE;

	NET_DBG(("calling Set_Sync_Level(conversation_ID:\"%8s\" sync_level:%d return_code:0x%x)\n",
	 conversation_ID,sync_level,&return_code));

	NET_SET_SYNC_LEVEL((conversation_ID,&sync_level,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_SYNC_ERROR,
		 return_code,0);
		goto connect_error;
	}

/* set conversation security if a user was specified */

	if (*connect_info->lu62.userid)
	{

/*
** The CPI-C manual defines CM_SECURITY_PROGRAM but the include file only has
** XC_SECURITY_PROGRAM.
*/

		conversation_security_type = XC_SECURITY_PROGRAM;
	}
	else
	{

/*
** The CPI-C manual defines CM_SECURITY_NONE but the include file only has
** XC_SECURITY_NONE.
*/

		conversation_security_type = XC_SECURITY_NONE;
	}

	NET_DBG(("calling Set_Conversation_Security_Type(conversation_ID:\"%8s\" conversation_security_type:%d return_code:0x%x)\n",
	 conversation_ID,conversation_security_type,&return_code));

	NET_SET_CONVERSATION_SECURITY_TYPE((conversation_ID,&conversation_security_type,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_SEC_ERROR,
		 return_code,0);
		goto connect_error;
	}

	if (conversation_security_type == XC_SECURITY_PROGRAM)
	{
		length = strlen(connect_info->lu62.userid);

		NET_DBG(("calling Set_Conversation_Security_User_ID(conversation_ID:\"%8s\" user_ID:\"%s\" length:%d return_code:0x%x)\n",
		 conversation_ID,connect_info->lu62.userid,length,&return_code));

		NET_SET_CONVERSATION_SECURITY_USER_ID((conversation_ID,connect_info->lu62.userid,
		 &length,&return_code));
		if (return_code != CM_OK)
		{
			NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_USERID_ERROR,
			 return_code,0);
			goto connect_error;
		}

		length = strlen(connect_info->lu62.password);

/* Not displaying password in debug for security reasons */

		NET_DBG(("calling Set_Conversation_Security_Password(conversation_ID:\"%8s\" password:\"%s\" length:%d return_code:0x%x)\n",
		 conversation_ID,"********",length,&return_code));

		NET_SET_CONVERSATION_SECURITY_PASSWORD((conversation_ID,
		 connect_info->lu62.password,&length,&return_code));
		if (return_code != CM_OK)
		{
			NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_SET_PASSWORD_ERROR,
			 return_code,0);
			goto connect_error;
		}
	}

/* start conversation */

	NET_DBG(("calling Allocate(conversation_ID:\"%8s\" return_code:0x%x)\n",
	 conversation_ID,&return_code));

        RISsrv_enable_lu62_alarm_system();

	NET_ALLOCATE((conversation_ID,&return_code));

        RISsrv_disable_lu62_alarm_system();
	 
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_ALLOCATE_ERROR,
		 return_code,0);
		goto connect_error;
	}

/* flush the buffer to force the allocation request to be sent to the host */

	NET_DBG(("calling Flush(conversation_ID:\"%8s\" return_code:0x%x)\n",
	 conversation_ID,&return_code));

	NET_FLUSH((conversation_ID,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_CPIC_FLUSH_ERROR,
		 return_code,0);
		goto connect_error;
	}

/* record conversation ID in net structure */

	net->id.lu62.lcbp = conversation_ID;

	NET_DBG(("conversation_ID = \"%8s\"\n",conversation_ID));

	NET_DBG(("NET_connect_lu62: complete\n"));

	return;

connect_error:

/* deallocate ID and free memory, assumes if ID != 0 then it is allocated */

	if (conversation_ID)
	{
		deallocate_type = CM_DEALLOCATE_ABEND;

		NET_DBG(("calling Set_Deallocate_Type(conversation_ID:\"%8s\" deallocate_type:%d return_code:0x%x)\n",
		 conversation_ID,deallocate_type,&return_code));

		NET_SET_DEALLOCATE_TYPE((conversation_ID,&deallocate_type,&return_code));

		NET_DBG(("Set_Deallocate_Type return code = %d\n",return_code));

		if (return_code == CM_OK)
		{

			NET_DBG(("calling Deallocate(conversation_ID:\"%8s\" return_code:0x%x)\n",
			 conversation_ID,&return_code));

			NET_DEALLOCATE((conversation_ID,&return_code));

			NET_DBG(("Deallocate return code = %d\n",return_code));
		}
		NET_free(conversation_ID);
	}

	NET_DBG(("NET_connect_lu62: failed\n"));
}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
extern void NET_connect_lu62(
    net_s			*net,
	net_connect_s	*connect_info)
{
	int		sts;
	lu62lcb *lcbp;

	/*
	** Note that these are static because we need them every time but
	** only initialize them for a new connection.
	*/
	static atchstr atblock;
	static lu62lcb lcb;
	static lu62crb crb;
	static SEC_DATA a, b;
	static SEC_DATA *userid = &a, *passwrd = &b;
	static PIP pip;

	static int commlink_set = 0;
	static int control_block_initialized = 0;

	char	tracefile[25];

	NET_DBG(("NET_connect_lu62(net:0x%x connect_info:0x%x)\n",
		net, connect_info));

    NET_DBG(("NET_connect_lu62: attach_count:%d conversation_count:%d\n",
		attach_count, conversation_count));

	if (net->misc_flag == START_CONNECTION)
	{
		NET_DBG(("NET_connect_lu62: Starting a connection\n"));
		/*
		** set COMMLINK environment variable for SSI lu6.2 software
		*/
		if (!commlink_set)
		{
			NET_DBG(("NET_connect_lu62: Need to set commlink\n"));
			NET_set_commlink(net);
			NET_ERRCHK(net);
			commlink_set = 1;
		}

		if (attach_count == 0)
		{
			NET_DBG(("NET_connect_lu62: Need to attach\n"));
			/* set up attach control block for lu62attch() */

			atblock.name = connect_info->lu62.ltpn;
			atblock.namelen = strlen(atblock.name);

			NET_DBG(("NET_connect_lu62: ltpn: %s\n", atblock.name));

			atblock.mgrname = NULL;
			atblock.mgrlen = 0;

			if (connect_info->lu62.llutype == LOCALLY_KNOWN)
			{
				atblock.luname = connect_info->lu62.lluname;
				atblock.lunlen = strlen(atblock.luname);
				atblock.fqlname = NULL;
				atblock.fqllen = 0;
			}
			else /* Fully-qualified */
			{
				atblock.luname = NULL;
				atblock.lunlen = 0;
				atblock.fqlname = connect_info->lu62.lluname;
				atblock.fqllen = strlen(atblock.fqlname);
			}
			NET_DBG(("NET_connect_lu62: local lu_name:<%s> full lu name:<%s>\n",
				atblock.luname ? atblock.luname : "NULL",
				atblock.fqlname ? atblock.fqlname : "NULL"));

		/*
		** 01/14 JP
		** Modified the trace o/p to use the pid, to avoid overwriting
		** of trace files.
		** Remember to use _getpid for NET builds before merging into SPC
		*/

			if (NET_debug)
			{
				atblock.trcon = 1;
				sprintf(tracefile,"/usr/tmp/appc_%hd.trc",getpid());
        		atblock.trflen = strlen(atblock.trfname = tracefile);
			}
			else
			{
				atblock.trcon = 0;
				atblock.trfname = NULL;
			}
#ifdef OLD
			atblock.trfname = CLIENT_TRACE_FILENAME;
			atblock.trflen = strlen(CLIENT_TRACE_FILENAME);
#endif

			atblock.aeflag = 1;

			atblock.func = 0;

			NET_DBG(("NET_connect_lu62: calling LU62ATTCH\n",net));

			sts = LU62ATTCH(&atblock);
			if (sts != STARTED)
			{	/* must be started locally */
				NET_error_lu62(net,NET_E_CONNECT_ERROR,NET_E_LU62_ATTACH_ABEND,
					sts,0);
				return;
			}
			NET_DBG(("NET_connect_lu62: attached to lu62 manager\n"));
			attach_count++;
		}
		else
		{
			NET_DBG(("NET_connect_lu62: process already attached\n"));
		}
	}

	if (! control_block_initialized)
	{
		NET_DBG(("NET_connect_lu62: Need to initialize control block\n"));
		/* initialize control block */

		crb.luname.string = connect_info->lu62.rluname;
		crb.luname.len = strlen(crb.luname.string);
		if (connect_info->lu62.rlutype == LOCALLY_KNOWN)
			crb.lunmtyp = NAME_LC;
		else
			crb.lunmtyp = NAME_FQ;
	
		NET_DBG(("NET_connect_lu62: remote lu name: %s\n", crb.luname.string));
	
		crb.snamode.string = connect_info->lu62.mode_name;
		crb.snamode.len = strlen(crb.snamode.string);
	
		NET_DBG(("NET_connect_lu62: mode name:<%s>\n", crb.snamode.string));
	
		crb.tpn.string = connect_info->lu62.rtpn;
		crb.tpn.len = strlen(crb.tpn.string);
	
	    NET_DBG(("NET_connect_lu62: rtpn:<%s>\n", crb.tpn.string));
		
		crb.rcntrl = SS_ALLOC;
#ifdef OLD
		crb.syn_lvl = CM_CNFM;
#endif
		crb.syn_lvl = CM_SY0;

/* if a userid was provided then set security */

	    if (*connect_info->lu62.userid)
	    {
			crb.sec_typ = SEC_PGM;
		
			userid->sec_id  = SEC_UID;
			userid->sec_len = strlen(userid->sec_dat = 
			 connect_info->lu62.userid);
			crb.security[0] = userid;
		
			NET_DBG(("NET_connect_lu62: user id:<%s>\n",
			 crb.security[0]->sec_dat));
		
			passwrd->sec_id = SEC_PSWD;
			passwrd->sec_len = strlen(passwrd->sec_dat=
			 connect_info->lu62.password);
			crb.security[1] = passwrd;
		}
		else
		{
			crb.sec_typ = SEC_NONE;
	    	crb.security[0] = (SEC_DATA *)0;
	    	crb.security[1] = (SEC_DATA *)0;
		}
	    crb.security[2] = (SEC_DATA *)0;
	
		pip.pipc = 2;
		pip.trunc = 0;
		pip.pips[0].piplen  = 1;
		pip.pips[0].pipdatp = &connect_info->lu62.dbtype;
		pip.pips[1].piplen  = 1;
		pip.pips[1].pipdatp = &connect_info->lu62.debug;
	
			/*
			** 01/14 JP
			** For AS400 connections we should not pass the PIP data.
			** The OS400 db is identified by a '4'. However when we 
			** connect to IBM mainframe for Db2 connections we still need
			** to pass PIP data
			*/

		if (connect_info->lu62.dbtype == '4')
		{
			crb.pipdat = NULL;
		}
		else
		{
			crb.pipdat = &pip;
	    	NET_DBG(("NET_connect_lu62: pip db type:%c pip debug: 0x%x\n",
				*crb.pipdat->pips[0].pipdatp, *crb.pipdat->pips[1].pipdatp));
		}
	
		NET_DBG(("NET_connect_lu62: calling MALLOC: partner prog <%s>\n",
			crb.tpn.string));

		/* alloc space for local conversation block */

		net->id.lu62.lcbp = NULL;
		lcbp = (lu62lcb *)NET_alloc(sizeof(lu62lcb));
		net->id.lu62.lcbp = (char *)lcbp;
		control_block_initialized = 1;
	}	

	/*
	** in generic.c, net->id.* gets zapped every time we go through connect.
	*/
	net->id.lu62.lcbp = (char *)&lcb;
	lcbp = (lu62lcb *)net->id.lu62.lcbp;
	sts = MALLOC_wrapper(&crb,lcbp);
	if (sts)
	{
		NET_error_lu62(net, NET_E_CONNECT_ERROR, NET_E_LU62_MALLOC_ABEND, sts, 0);
		return;
	}
	if (lcbp->lu62rc1 != OK)
	{
		NET_error_lu62(net, NET_E_CONNECT_ERROR, NET_E_LU62_MALLOC_ERROR,
			lcbp->lu62rc1, lcbp->lu62rc2);
		return;
	}

	conversation_count++;

        NET_DBG(("NET_connect_lu62: server started: attach_count:%d conversation_count:%d\n", attach_count, conversation_count));

	NET_DBG(("NET_connect_lu62: complete\n"));
}
#endif /* unix */

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_accept for LU6.2.
** It is intended for accepting connections over LU6.2 from NT SNA Server
** machines.  It is intended for testing purposes only. It is implemented using
** CPI-C.
**
** Note that there are several ways for the back-end portion of an LU6.2 to get
** started.  Since this function has been designed for testing purposes it only
** supports the operator-started mechanism.  It is necessary to create the 
** appropriate entires int the registry in order for this function to operate
** correctly.
*/

#if defined(WIN32)
extern void NET_accept_lu62(
    net_s	*net)						/* info used by all net calls */
{
	long return_code;					/* return code var for CPI-C calls */
	unsigned char * conversation_ID;	/* this is used by all CPI-C calls */
	WCPICDATA CPICData;					/* CPIC version information */
	long length;						/* length of string parameters */
	long conversation_return_code;		/* return code var for CPI-C calls */

	NET_DBG(("NET_accept_lu62(net:0x%x)\n",net));

/* if not already started, start CPIC */

	if (!started)
	{
		NET_DBG(("calling WINCPICStartup(wVersionRequired:0x%x CPICData:0x%x)\n",
		 WIN_CPIC_VERSION,&CPICData));

		NET_WINCPICSTARTUP((WIN_CPIC_VERSION,&CPICData),return_code);

		NET_DBG(("WinCPICStartup return code = %d\n",return_code));

		if (return_code)
		{
			NET_error_lu62(net,NET_E_ACCEPT_ERROR,NET_E_CPIC_STARTUP_ERROR,
			 return_code,0);

			NET_DBG(("NET_accept_lu62: failed\n"));

			return;
		}

		started = 1;

		NET_DBG(("CPIC version = %d description =\"%s\"\n",
		 CPICData.wVersion,CPICData.szDescription));
	}

/*
** Specify the TP Name that this program will service.  This name must match a
** TP entry in the registry of the server machine.  The name is defined using
** the macro LOCAL_TP_NAME which is defined at the top of this file.
*/

	length = strlen(LOCAL_TP_NAME);

	NET_DBG(("calling Specify_Local_TP_Name(TP_name:\"%s\" length:%d return_code:0x%x)\n",
	 LOCAL_TP_NAME,length,&return_code));

	NET_SPECIFY_LOCAL_TP_NAME((LOCAL_TP_NAME,&length,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_ACCEPT_ERROR,NET_E_CPIC_SPECIFY_TP_ERROR,
		 return_code,0);
		goto accept_error;
	}

/* allocate space for conversation ID */

	conversation_ID = (unsigned char *)NET_alloc(8);
	if (!conversation_ID)
	{
		NET_error_lu62(net,NET_E_OUT_OF_MEMORY,0,0,0);
		goto accept_error;
	}

/* accept conversation and get a conversation ID */

	NET_DBG(("calling Accept_Conversation(conversation_ID:0x%x return_code:0x%x)\n",
	 conversation_ID,&return_code));

	NET_ACCEPT_CONVERSATION((conversation_ID,&return_code));
	if (return_code != CM_OK && return_code != CM_OPERATION_INCOMPLETE)
	{
		NET_error_lu62(net,NET_E_ACCEPT_ERROR,NET_E_CPIC_ACCEPT_CONV_ERROR,
		 return_code,0);
		goto accept_error;
	}

	NET_DBG(("calling Wait_For_Conversation(conversation_ID:\"%8s\" conversation_return_code:0x%x return_code:0x%x)\n",
	 conversation_ID,&conversation_return_code,&return_code));

/*
**  Accept is done asynchronously if Specify_Local_TP_Name is used so we must
**  wait for it to complete.
*/

	NET_WAIT_FOR_CONVERSATION((conversation_ID,&conversation_return_code,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_ACCEPT_ERROR,NET_E_CPIC_WAIT_CONV_ERROR,
		 return_code,0);
		goto accept_error;
	}
	if (conversation_return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_ACCEPT_ERROR,NET_E_CPIC_ACCEPT_CONV_ERROR,
		 conversation_return_code,0);
		goto accept_error;
	}

/* record conversation ID in net structure */

	net->id.lu62.lcbp = conversation_ID;

	NET_DBG(("conversation_ID = \"%8s\"\n",conversation_ID));

	NET_DBG(("NET_accept_lu62: complete\n"));

	return;

accept_error:

/* free memory */

	if (conversation_ID)
	{
		NET_free(conversation_ID);
	}

	NET_DBG(("NET_accept_lu62: failed\n"));
}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
extern void NET_accept_lu62(
	net_s	*net)
{
#ifdef NOTYET
	int sts;
	atchstr atblock;
	lu62lcb *lcbp;


	NET_DBG(("NET_accept_lu62(net:0x%x)\n",net));

	net->id.lu62.lcbp = (char *)0;

	/* set up attach control block for lu62attch() */

	atblock.name = (char *)0;		atblock.namelen = 0;
	atblock.mgrname = (char *)0;	atblock.mgrlen = 0;
	atblock.luname = (char *)0;		atblock.lunlen = 0;
	atblock.fqlname = (char *)0;	atblock.fqllen = 0;

	atblock.trcon = 1;
	atblock.trfname = SERVER_TRACE_FILENAME;
	atblock.trflen = strlen(SERVER_TRACE_FILENAME);

	atblock.aeflag = 1;
	atblock.func = 0;

	NET_DBG(("NET_accept_lu62: calling LU62ATTCH\n"));

	sts = LU62ATTCH(&atblock);
	if (sts != ATTACHED)
	{	/* must be started remotely */
		NET_DBG(("NET_accept_lu62: LU62ATTCH error:abend code:#%d\n",sts));
		NET_error_lu62(net, NET_E_CONNECT_ERROR, NET_E_LU62_ATTACH_ABEND, sts, 0);
		return;
	}

	/* alloc space for local conversation block */
	lcbp = (lu62lcb *)NET_alloc(sizeof(lu62lcb));
	net->id.lu62.lcbp = (char *)lcbp;

    sts = LU62CVCT(lcbp,(PIP *)0,(char *)0,0);
	if (sts)
	{
		NET_DBG(("NET_accept_lu62: LU62CVCT error: abend code #%d\n",sts));
		NET_error_lu62(net, NET_E_CONNECT_ERROR, NET_E_LU62_CVCT_ABEND, sts, 0);
		return;
	}
    if (lcbp->lu62rc1 != OK)
	{
		NET_DBG(("NET_accept_lu62: LU62CVCT error: rc1:%d rc2:%d\n",
			lcbp->lu62rc1, lcbp->lu62rc2));
		NET_error_lu62(net, NET_E_CONNECT_ERROR, NET_E_LU62_CVCT_ERROR,
			lcbp->lu62rc1, lcbp->lu62rc2);
		return;
	}
	NET_DBG(("NET_accept_lu62: complete\n"));
#else /* NOTYET */
	net = net;	/* shut up the compiler */
#endif /* NOTYET */
}
#endif /* unix */

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_write for LU6.2.
** It is intended for sending data over LU6.2 to IBM AS/400s and 
** Mainframes.  It is implemented using CPI-C.
** Note that non-blocking writes are not supported.
*/

#if defined(WIN32)
extern void NET_write_lu62(
    net_s	*net,						/* info used by all net calls */
	char	*user_buffer,				/* ptr to buffer containing user data */
	int		*user_lenp,					/* in:user length out:length written */
	int		blocking,					/* 0=block -1=non-block >1=timeout */
	int		send_length_flag)			/* !=0 length + data ==0 data only */
{
	unsigned char * conversation_ID;	/* this is used by all CPI-C calls */
	long return_code;					/* return code var for CPI-C calls */
	int bytes_written;					/* number of bytes written */
	int bytes_to_write;					/* number of bytes to write */
	char *data;							/* ptr to data to be written */
	net_buffer_s *buffer;				/* temporary net buffer ptr */
	long request_to_send_received;		/* send status received from partner */
	int length;							/* size of chunk to be sent */
	int conversation_state;				/* the state of the conversation */
	int received_length;				/* number of bytes actually received */
	int data_received;					/* indicates if data was received */
	int status_received;				/* change in conversation status */
	long send_type;						/* BUFFER, FLUSH, CONFIRM, ... */

	NET_DBG(("NET_write_lu62(net:0x%x user_buffer:0x%x *user_lenp:%d blocking:%d send_length_flag:%d)\n",
	 net, user_buffer, *user_lenp, blocking, send_length_flag));

	conversation_ID = net->id.lu62.lcbp;

/* get conversation state */

	NET_DBG(("calling Extract_Conversation_State(conversation_ID:\"%8s\" conversation_state:0x%x return_code:0x%x)\n",
	 conversation_ID,&conversation_state,&return_code));

	NET_EXTRACT_CONVERSATION_STATE((conversation_ID,&conversation_state,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_WRITE_ERROR,NET_E_CPIC_EXTRACT_STATE_ERROR,
		 return_code,0);

		NET_DBG(("NET_write_lu62: failed\n"));

		return;
	}

/*
** If in the RECEIVE state then change to SEND.  Otherwise leave the
** state alone.  If the state isn't SEND then Send_Data will fail.
** Ideally this will not ever occur.  The state should have changed to 
** SEND_PENDING after the last receive in NET_read.  If this didn't happen then
** we have to call receive again.
*/

	if (conversation_state == CM_RECEIVE_STATE)
	{

		NET_DBG(("We shouldn't have to do this.  Why are we here?\n"));
/*
** The partner program must change to the receive state.  When that it is done
** it will notify us.  In order to get this notification we must call receive.
** The state change is indicated by the status_received parameter.
*/

		length = 0;

		NET_DBG(("calling Receive(conversation_ID:\"%8s\" buffer:0x%x request_length:%d data_received:0x%x received_length:0x%x status_received:0x%x request_to_send_received:0x%x return_code:0x%x)\n",
		 conversation_ID,(char *)0,length,&data_received,&received_length,
		 &status_received,&request_to_send_received,&return_code));

        	RISsrv_enable_lu62_alarm_system();

		NET_RECEIVE((conversation_ID,(char *)0,&length,&data_received,
		 &received_length,&status_received,&request_to_send_received,
		 &return_code));

        	RISsrv_disable_lu62_alarm_system();

		if (return_code != CM_OK)
		{
			NET_error_lu62(net,NET_E_WRITE_ERROR,NET_E_CPIC_RECEIVE_ERROR,
			 return_code,0);

			NET_DBG(("NET_write_lu62: failed\n"));

			return;
		}
		NET_DBG(("data_received = %d, received_length = %d\n",
		 data_received,received_length));
		NET_DBG(("status received = %d, request_to_send_received = %d\n",
		 status_received, request_to_send_received));
	}

/* initialize data ptr and length */

	if (send_length_flag)
	{
		bytes_to_write = *user_lenp + NET_LEN_FIELD_SIZE;
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
	    NET_put_len(buffer->len, bytes_to_write);
	    data = (char *)buffer->len;
    }
	else
	{
		bytes_to_write = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_written = 0;

	NET_DBG(("data:0x%x (actual)bytes_to_write:%d\n", data, bytes_to_write));

/* return error if async request made */

	if (blocking != 0)
	{
		NET_error_lu62(net,NET_E_ASYNC_NOT_IMPLEMENTED,0,0,0);

		NET_DBG(("NET_write_lu62: failed\n"));

		return;
	}

/* make sure send type is SEND_AND_FLUSH */

	send_type = CM_SEND_AND_FLUSH;

	NET_DBG(("calling Set_Send_Type(conversation_ID:\"%8s\" send_type:%d return_code:0x%x)\n",
	 conversation_ID,send_type,&return_code));

	NET_SET_SEND_TYPE((conversation_ID,&send_type,&return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_WRITE_ERROR,NET_E_CPIC_SET_SEND_ERROR,
		 return_code,0);

		NET_DBG(("NET_write_lu62: failed\n"));

		return;
	}

/* send data in chunks */

	while(bytes_written < bytes_to_write)
	{

/* send a chunk of data */
        /* August 1996 - TR# 439601891 - mms - CICS has a limitation of 24000 - at Sonya Zaremba's request
		length = MIN(MAX_LU62_BUFFER_SIZE, bytes_to_write - bytes_written);
	 */
		length = MIN(24000, bytes_to_write - bytes_written);

		NET_DBG(("send data length:%d\n", length));

/* if this is the last send_data then change type to SEND_AND_PREP_TO_RECEIVE */

		if (bytes_written + length >= bytes_to_write)
		{
			send_type = CM_SEND_AND_PREP_TO_RECEIVE;

			NET_DBG(("calling Set_Send_Type(conversation_ID:\"%8s\" send_type:%d return_code:0x%x)\n",
			 conversation_ID,send_type,&return_code));

			NET_SET_SEND_TYPE((conversation_ID,&send_type,&return_code));
			if (return_code != CM_OK)
			{
				NET_error_lu62(net,NET_E_WRITE_ERROR,NET_E_CPIC_SET_SEND_ERROR,
				 return_code,0);

				NET_DBG(("NET_write_lu62: failed\n"));

				return;
			}

		}

		NET_DBG(("calling Send_Data(conversation_ID:\"%8s\" buffer:0x%x send_length:%d request_to_send_received:0x%x return_code:0x%x)\n",
		 conversation_ID, data + bytes_written, length, &request_to_send_received, &return_code));

		NET_SEND_DATA((conversation_ID, data + bytes_written, &length,
		 &request_to_send_received, &return_code));
		if (return_code != CM_OK)
		{
			NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_CPIC_SEND_ERROR,
				return_code, 0);

			NET_DBG(("NET_write_lu62: failed\n"));

			return;
		}

		NET_DBG(("request_to_send_received = %d\n",request_to_send_received));

		bytes_written += length;
	}


/* set user length pointer to indicate amount written */

	if (send_length_flag)
	{
		*user_lenp = bytes_written - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_written;
	}

	NET_DBG(("bytes_written = %d\n", *user_lenp));

	NET_DBG(("NET_write_lu62: complete\n"));
}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
extern void NET_write_lu62(
	net_s	*net,
	char	*user_buffer,
	int		*user_lenp,
	int		blocking,
	int		send_length_flag)
{
	int				sts;
	int				length;
	int 			bytes_written;
	int				bytes_to_write;
	char			*data;
	net_buffer_s	*buffer;
	lu62lcb			*lcbp;

	NET_DBG(("NET_write_lu62(net:0x%x user_buffer:0x%x *user_lenp:%d blocking:%d send_length_flag:%d)\n", net, user_buffer, *user_lenp, blocking, send_length_flag));


	lcbp = (lu62lcb *)net->id.lu62.lcbp;
	if (lcbp->lu62cvst == CVS_RECV)
	{
		/*
		**	IF STATE = RECEIVE THEN RECEIVE SEND INDICATOR
		*/
		NET_DBG (("In NET_write.\n")) ;
		NET_request_send_ind(net, 0); /* 0 -> deallocated state unacceptable */
		NET_ERRCHK(net);
	}

	NET_DBG (("Continuing in NET_write\n")) ;
	if (send_length_flag)
	{
		bytes_to_write = *user_lenp + NET_LEN_FIELD_SIZE;
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		NET_put_len(buffer->len, bytes_to_write);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_write = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_written = 0;

	NET_DBG(("NET_write_lu62: data:0x%x (actual)bytes_to_write:%d\n",
		data, bytes_to_write));

	while(bytes_written < bytes_to_write)
	{
		/*
		**	SEND DATA
		*/
        /* August 1996 - TR# 439601891 - mms - CICS has a limitation of 24000 - at Sonya Zaremba's request
		length = MIN(MAX_LU62_BUFFER_SIZE, bytes_to_write - bytes_written);  */
		
		length = MIN(24000, bytes_to_write - bytes_written); 
		NET_DBG(("NET_write_lu62: calling MSEND: length:%d\n", length));
		sts = MSEND(lcbp, data + bytes_written, length, (char *)0, 0);
		if (sts)
		{
			NET_DBG(("NET_write_lu62: MSEND error: abend code #%d\n", sts));
			NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MSEND_ABEND, sts, 0);
			return;
		}
		if (lcbp->lu62rc1 != OK)
		{
			NET_DBG(("NET_write_lu62: MSEND error: rc1 = %d, rc2 = %d\n",
				lcbp->lu62rc1, lcbp->lu62rc2));
			NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MSEND_ERROR,
				lcbp->lu62rc1, lcbp->lu62rc2);
			return;
		}
		bytes_written += length;
	}

	/*
	** flush the buffer
	** and cause the lu62 manager to put us in the receive state
	*/
	NET_DBG(("NET_write_lu62: flushing buffer - going to receive state\n"));
	sts = MPPTRC_wrapper (lcbp) ;
	if (sts)
	{
		NET_DBG(("NET_write_lu62: MPPTRC error: abend code #%d\n", sts));
		NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MPPTRC_ABEND, sts, 0);
		return;
	}
	if (lcbp->lu62rc1 != OK)
	{
		NET_DBG(("NET_write_lu62: MPPTRC error: rc1 = %d, rc2 = %d\n",
			lcbp->lu62rc1,lcbp->lu62rc2));
		NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MPPTRC_ERROR,
			lcbp->lu62rc1, lcbp->lu62rc2);
		return;
	}

	if (send_length_flag)
	{
		*user_lenp = bytes_written - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_written;
	}
	NET_DBG(("NET_write_lu62: *user_lenp:%d\nNET_write_lu62:returning\n",
		*user_lenp));
}
#endif /* unix */

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_read for LU6.2.
** It is intended for receiving data over LU6.2 from IBM AS/400s and 
** Mainframes.  It is implemented using CPI-C.
** Note that non-blocking reads are not supported.
*/

#if defined(WIN32)
extern void NET_read_lu62(
    net_s	*net,						/* info used by all net calls */
	char	*user_buffer,				/* ptr to buffer to put user data */
	int		*user_lenp,					/* in:buffer length out:length read */
	int		blocking,					/* 0=block -1=non-block >1=timeout */
	int		receive_length_flag)		/* !=0 length + data ==0 data only */
{
	int				bytes_read;			/* number of bytes read */
	int				bytes_to_read;		/* number of bytes to be read */
	unsigned char * conversation_ID;	/* this is used by all CPI-C calls */
	long return_code;					/* return code var for CPI-C calls */
	char *data;							/* ptr to data to be read */
	net_buffer_s *buffer;				/* temporary net buffer ptr */
	long request_to_send_received;		/* send status received from partner */
	int length;							/* size of chunk to be sent */
	int received_length;				/* number of bytes actually received */
	int data_received;					/* indicates if data was received */
	int status_received;				/* change in conversation status */
	int conversation_state;				/* the state of the conversation */

	NET_DBG(("NET_read_lu62(net:0x%x user_buffer:0x%x user_lenp:0x%x blocking:%d receive_length_flag:%d)\n",
	 net, user_buffer, user_lenp, blocking, receive_length_flag));

	conversation_ID = net->id.lu62.lcbp;

/* get conversation state */

	NET_DBG(("calling Extract_Conversation_State(conversation_ID:\"%8s\" conversation_state:0x%x return_code:0x%x)\n",
	 conversation_ID,&conversation_state,&return_code));

	NET_EXTRACT_CONVERSATION_STATE((conversation_ID,&conversation_state,
	 &return_code));
	if (return_code != CM_OK)
	{
		NET_error_lu62(net,NET_E_READ_ERROR,NET_E_CPIC_PREPARE_RECEIVE_ERROR,
		 return_code,0);

		NET_DBG(("NET_read_lu62: failed\n"));

		return;
	}

/*
** If in one of the SEND states then change to RECEIVE.  Otherwise leave the
** state alone.  If the state isn't RECEIVE then Receive will fail.
** Ideally this shouldn't ever be necessary.  The last send should have changed
** the state to RECEIVE.
*/

	if (conversation_state == CM_SEND_STATE || 
	 conversation_state == CM_SEND_PENDING_STATE)
	{

		NET_DBG(("We shouldn't have to do this.  Why are we here?\n"));

/* set state to RECEIVE */

		NET_DBG(("calling Prepare_To_Receive(conversation_ID:\"%8s\" return_code:0x%x)\n",
		 conversation_ID,&return_code));

		NET_PREPARE_TO_RECEIVE((conversation_ID,&return_code));
		if (return_code != CM_OK)
		{
			NET_error_lu62(net,NET_E_READ_ERROR,
			 NET_E_CPIC_PREPARE_RECEIVE_ERROR, return_code,0);

			NET_DBG(("NET_read_lu62: failed\n"));

			return;
		}
	}

/* initialize data ptr and length */

	if (receive_length_flag)
	{
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
                /* mms - Sept 1996 - TR#439602061 */
		bytes_to_read = MIN(buffer->size, MAX_LU62_BUFFER_SIZE-2048);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_read = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_read = 0;

	NET_DBG(("data:0x%x bytes_to_read:%d\n", data, bytes_to_read));

/* return error if async request made */

	if (blocking != 0)
	{
		NET_error_lu62(net,NET_E_ASYNC_NOT_IMPLEMENTED,0,0,0);

		NET_DBG(("NET_read_lu62: failed\n"));

		return;
	}

/* read a chunk */

	length = bytes_to_read;

	NET_DBG(("calling Receive(conversation_ID:\"%8s\" buffer:0x%x request_length:%d data_received:0x%x received_length:0x%x status_received:0x%x request_to_send_received:0x%x return_code:0x%x)\n",
	 conversation_ID,data,length,&data_received,&received_length,
	 &status_received,&request_to_send_received,&return_code));

        RISsrv_enable_lu62_alarm_system();

	NET_RECEIVE((conversation_ID, data, &length, &data_received, &received_length,
	 &status_received, &request_to_send_received, &return_code));

        RISsrv_disable_lu62_alarm_system();
	 
	if (return_code != CM_OK && return_code != CM_DEALLOCATED_NORMAL)
	{
		NET_error_lu62(net,NET_E_READ_ERROR,NET_E_CPIC_RECEIVE_ERROR,
		 return_code,0);

		NET_DBG(("NET_read_lu62: failed\n"));

		return;
	}

	NET_DBG(("data_received = %d, received_length = %d\n",
	 data_received,received_length));
	NET_DBG(("status received = %d, request_to_send_received = %d\n",
	 status_received, request_to_send_received));

	if (data_received == CM_NO_DATA_RECEIVED)
	{
		NET_error_lu62(net,NET_E_READ_ERROR,NET_E_CPIC_RECEIVE_ERROR,
		 return_code,0);

		NET_DBG(("NET_read_lu62: failed\n"));

		return;
	}
	bytes_read = received_length;

/* if we received a length flag then keep reading until we have all data */

	if (receive_length_flag)
	{
		NET_get_len(buffer->len, &bytes_to_read);

		NET_DBG(("(actual)bytes_to_read:%d\n", bytes_to_read));

		if (bytes_to_read - NET_LEN_FIELD_SIZE > buffer->size)
		{
			NET_error_lu62(net, NET_E_READ_BUFFER_TOO_SMALL, 0, 0, 0);

			NET_DBG(("NET_read_lu62: failed\n"));

			return;
		}

		while(bytes_read < bytes_to_read)
		{
                        /* mms - Sept 1996 - TR# 439602061 */
			length = MIN(bytes_to_read - bytes_read, MAX_LU62_BUFFER_SIZE-2048);

			NET_DBG(("calling Receive(conversation_ID:\"%8s\" buffer:0x%x request_length:%d data_received:0x%x received_length:0x%x status_received:0x%x request_to_send_received:0x%x return_code:0x%x)\n",
			 conversation_ID,data,length,&data_received,&received_length,
			 &status_received,&request_to_send_received,&return_code));

                        RISsrv_enable_lu62_alarm_system();
	 
			NET_RECEIVE((conversation_ID, data, &length, &data_received, &received_length,
			 &status_received, &request_to_send_received, &return_code));

                        RISsrv_disable_lu62_alarm_system();
                        
			if (return_code != CM_OK && return_code != CM_DEALLOCATED_NORMAL)
			{
				NET_error_lu62(net,NET_E_READ_ERROR,NET_E_CPIC_RECEIVE_ERROR,
				 return_code,0);

				NET_DBG(("NET_read_lu62: failed\n"));

				return;
			}

			NET_DBG(("data_received = %d, received_length = %d\n",
			 data_received,received_length));
			NET_DBG(("status received = %d, request_to_send_received = %d\n",
			 status_received, request_to_send_received));

			if (data_received == CM_NO_DATA_RECEIVED)
			{
				NET_error_lu62(net,NET_E_READ_ERROR,NET_E_CPIC_RECEIVE_ERROR,
				 return_code,0);

				NET_DBG(("NET_read_lu62: failed\n"));

				return;
			}
			bytes_read += received_length;
		}

/* set to actual bytes read */
	
		*user_lenp = bytes_read - NET_LEN_FIELD_SIZE;
	}
	else
	{

/* set to actual bytes read */

		*user_lenp = bytes_read;
	}

	NET_DBG(("bytes_read = %d\n", *user_lenp));

	NET_DBG(("NET_read_lu62: complete\n"));
}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
/*
**	NOTE: non-blocking has not been implemented yet for LU62.
*/

extern void NET_read_lu62(
	net_s	*net,
	char	*user_buffer,
	int		*user_lenp,
	int		blocking,
	int		receive_length_flag)
{
	int				sts;
	int				length;
	int				bytes_read;
	int				bytes_to_read;
	char			*data;
	net_buffer_s	*buffer = 0;
	lu62lcb			*lcbp;

	NET_DBG(("NET_read_lu62(net:0x%x user_buffer:0x%x user_lenp:0x%x blocking:%d receive_length_flag:%d)\n", net, user_buffer, user_lenp, blocking, receive_length_flag));

	lcbp = (lu62lcb *)net->id.lu62.lcbp;

	if (receive_length_flag)
	{
		buffer = (net_buffer_s *)(user_buffer - NET_BUFFER_OFFSET);
		bytes_to_read = MIN(buffer->size, MAX_LU62_BUFFER_SIZE);
		data = (char *)buffer->len;
	}
	else
	{
		bytes_to_read = *user_lenp;
		data = user_buffer;
	}
	*user_lenp = 0;
	bytes_read = 0;

	NET_DBG(("NET_read_lu62: data:0x%x bytes_to_read:%d\n", data,
		bytes_to_read));

	length = bytes_to_read;
	NET_DBG(("NET_read_lu62: calling MRCVWT, expecting data, length:%d\n",
		length));

        sts = MRCVWT_wrapper(lcbp, data, &length) ;

	NET_DBG (("NET_read_lu62 : MRCVWT status %d\n",  sts))  ;
	if (sts)
	{
		NET_DBG(("NET_read_lu62: MRCVWT error: abend code #%d\n", sts));
		NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_DATA_ABEND,
			sts, 0);
		return;
	}
	if (lcbp->lu62rc1 != OK)
	{
		NET_DBG(("NET_read_lu62: MRCVWT error: rc1:%d, rc2:%d\n",
			lcbp->lu62rc1, lcbp->lu62rc2));
		NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_DATA_ERROR,
			lcbp->lu62rc1, lcbp->lu62rc2);
		return;
	}
	/* mms - TR#439601527 - DA_INCP was not being checked and was accounted as
	   an error condition. DA_INCP means imcomplete buffers, so not all the
	   bytes were retrieved, and we need to loop until all data is received. */
	if ( !(	lcbp->lu62prts == 0 &&
			lcbp->lu62wtrc == LU62DATA &&
			(lcbp->rcv_typ.lu62data == DA_CMPL ||
			 lcbp->rcv_typ.lu62data == DA_INCP)))
	{
		NET_DBG(("NET_read_lu62: MRCVWT error: prts:%d wtrc:%d rcv_typ:%d\n",
			lcbp->lu62prts, lcbp->lu62wtrc, lcbp->rcv_typ.lu62data));
		NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_BAD_DATA,
			lcbp->lu62wtrc, lcbp->rcv_typ.lu62data);
		return;
	}
	bytes_read = length;

	if (receive_length_flag)
	{
		NET_get_len(buffer->len, &bytes_to_read);
		NET_DBG(("NET_read_lu62: (actual)bytes_to_read:%d\n", bytes_to_read));
		if (bytes_to_read - NET_LEN_FIELD_SIZE > buffer->size)
		{
			NET_DBG(("NET_read_lu62: error: buffer->size:%d bytes_to_read:%d\n",
				buffer->size, bytes_to_read - NET_LEN_FIELD_SIZE));
			NET_error_lu62(net, NET_E_READ_BUFFER_TOO_SMALL, 0, 0, 0);
			return;
		}

		while(bytes_read < bytes_to_read)
		{
			length = MIN(bytes_to_read - bytes_read, MAX_LU62_BUFFER_SIZE);

			NET_DBG(("NET_read_lu62: calling MRCVWT,expecting data\n"));
			sts = MRCVWT_wrapper(lcbp, data + bytes_read, &length);
			NET_DBG (("NET_read_lu62 : MRCVWT_wrapper returning %d\n",  sts))
			if (sts)
			{
				NET_DBG(("NET_read_lu62: MRCVWT error: abend code #%d\n", sts));
				NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_DATA_ABEND,
					sts, 0);
				return;
			}
			if (lcbp->lu62rc1 != OK)
			{
				NET_DBG(("NET_read_lu62: MRCVWT error: rc1:%d, rc2:%d\n",
					lcbp->lu62rc1, lcbp->lu62rc2));
				NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_DATA_ERROR,
					lcbp->lu62rc1, lcbp->lu62rc2);
				return;
			}
			if ( !(	lcbp->lu62prts == 0 &&
					lcbp->lu62wtrc == LU62DATA &&
                			(lcbp->rcv_typ.lu62data == DA_CMPL ||
		                	 lcbp->rcv_typ.lu62data == DA_INCP)))
			{
				NET_DBG(("NET_read_lu62:MRCVWT error: prts:%d wtrc:%d rcv_typ:%d\n",lcbp->lu62prts, lcbp->lu62wtrc, lcbp->rcv_typ.lu62data));
				NET_error_lu62(net, NET_E_READ_ERROR, NET_E_LU62_MRCVWT_BAD_DATA,
					lcbp->lu62wtrc, lcbp->rcv_typ.lu62data);
				return;
			}

			bytes_read += length;
		}
		*user_lenp = bytes_read - NET_LEN_FIELD_SIZE;
	}
	else
	{
		*user_lenp = bytes_read;
	}

	NET_DBG(("NET_read_lu62: *user_lenp:%d\nNET_read_lu62: returning\n",
		*user_lenp));
}
#endif /* unix */

/******************************************************************************/

#if defined(WIN32)
/*
** This is the 32 bit Windows implementation of NET_close for LU6.2.
** It is intended for closing connections over LU6.2 to IBM AS/400s and 
** Mainframes.  It is implemented using CPI-C.
** Note that the assumption is made that close in general should not return
** errors.  It merely attempts to do the best that it can to clean things up.
*/

extern void NET_close_lu62(
    net_s *net)							/* info used by all net calls */
{
	long return_code;					/* return code var for CPI-C calls */
	unsigned char * conversation_ID;	/* this is used by all CPI-C calls */
	int deallocate_type;				/* how to perform deallocation */
	int conversation_state;				/* the state of the conversation */

	NET_DBG(("NET_close_lu62(net:0x%x)\n", net));

/* retrieve conversation ID from net structure */

	conversation_ID = net->id.lu62.lcbp;

/*
** If there is no conversation_ID pointer then assume that close has already
** called, so just return.
*/

	if (!conversation_ID)
	{

		NET_DBG(("conversation_ID is null, must already be closed\n"));

		NET_DBG(("NET_close_lu62:complete\n"));

		return;
	}

/* attempt to perform normal deallocation */

/* check conversation state */

	NET_DBG(("calling Extract_Conversation_State(conversation_ID:\"%8s\" conversation_state:0x%x return_code:0x%x)\n",
	 conversation_ID,&conversation_state,&return_code));

	NET_EXTRACT_CONVERSATION_STATE((conversation_ID,&conversation_state,
	 &return_code));
	switch(return_code)
	{

/* got conversation state */

		case CM_OK:

			switch(conversation_state)
			{
				case CM_RECEIVE_STATE:

/*
**  conversation is in RECEIVE state, we need it to be in SEND state for a
**  normal deallocation.  Thus we have to do an abnormal deallocate.
*/

					NET_DBG(("conversation is in RECEIVE state\n"));

					goto abnormal_end;
				break;

				case CM_SEND_STATE:
				case CM_SEND_PENDING_STATE:

					NET_DBG(("conversation is in SEND state\n"));

/* deallocate conversation ID */

					NET_DBG(("calling Deallocate(conversation_ID:\"%8s\" return_code:0x%x)\n",
					 conversation_ID,&return_code));

					NET_DEALLOCATE((conversation_ID,&return_code));
					if (return_code != CM_OK)
					{
						goto abnormal_end;
					}

					NET_DBG(("conversation deallocated normally\n"));

				break;

/* conversation is in some other state, so attempt an abort */

				default:

					NET_DBG(("conversation is in %d state\n",
					 conversation_state));

					goto abnormal_end;
				break;
			}
		break;

/*
** This occurs when the conversation has been set to RESET.  Errors occuring in
** some functions can cause this.  The deallocate has essentially already been
** done so all that we need to do here is clean up the variables.
*/

		case CM_PROGRAM_PARAMETER_CHECK:

		NET_DBG(("conversation_ID is invalid. Must have gone to reset state\n"));

		break;

		default:

/* Things appear to be really screwed up so try to abort */

			NET_DBG(("got product specific error %d will attempt to abort\n",
			 return_code));

			goto abnormal_end;
		break;
	}

/* free memory */

	NET_free(conversation_ID);

/* clear out conversation ID from NET structure */

	net->id.lu62.lcbp = 0;

	NET_DBG(("NET_close_lu62:complete\n"));

	return;


/* attempt to do an abnormal deallocation if all else failed */

abnormal_end:

	NET_DBG(("Attempting to abort conversation\n"));

/* set deallocate type to abort */

	deallocate_type = CM_DEALLOCATE_ABEND;

	NET_DBG(("calling Set_Deallocate_Type(conversation_ID:\"%8s\" deallocate_type:%d return_code:0x%x)\n",
	 conversation_ID,deallocate_type,&return_code));

	NET_SET_DEALLOCATE_TYPE((conversation_ID,&deallocate_type,&return_code));
	if (return_code != CM_OK)
	{
		NET_DBG(("set deallocate type failed with code %d\n",return_code));
	}
	else
	{

/* deallocate conversation ID */

		NET_DBG(("calling Deallocate(conversation_ID:\"%8s\" return_code:0x%x)\n",
		 conversation_ID,&return_code));

		NET_DEALLOCATE((conversation_ID,&return_code));
		if (return_code != CM_OK)
		{
			NET_DBG(("deallocate failed with code %d\n",return_code));
		}
	}

/* free memory */

	NET_free(conversation_ID);

/* clear out conversation ID from NET structure */

	net->id.lu62.lcbp = 0;

	NET_DBG(("NET_close_lu62:complete\n"));

}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
extern void NET_close_lu62(
	net_s *net)
{
	int		sts;
	int		type;
	lu62lcb *lcbp;

	NET_DBG(("NET_close(net:0x%x)\n", net));

	lcbp = (lu62lcb *)net->id.lu62.lcbp;

	NET_DBG(("NET_close_lu62 0x%x: conversation state = %d\n  attach_count: %d, conversation_count: %d\n",net,lcbp->lu62cvst, attach_count, conversation_count));

	if (lcbp->lu62cvst != CVS_REST)    /* if not in reset state */
	{
		if (conversation_count > 0)
		{
			if (lcbp->lu62cvst == CVS_RECV)
			{
				/* IF STATE = RECEIVE THEN RECEIVE SEND INDICATOR */
					/*
					** Being in a deallocated state because the IBM side
					** has already deallocated is okay in this case,
					** as indicated by the 1.
					*/
				NET_DBG (("IN NET_close.\n")) ;
				NET_request_send_ind(net,1);
				if (net->error_code)
				{
					NET_DBG (("Return.")) ;
					return;
				}
			}

			if (lcbp->lu62cvst == CVS_DEAL)
				/*
				** if we are currently in the deallocate state
				** then we can only do a local deallocate
				*/
				type = DA_LOCAL;
			else
				/* otherwise, we want to tell the remote lu
				** to deallocate
				*/
				type = DA_SYNC;

			NET_DBG(("NET_close_lu62: Calling MDEALC type:%d\n",type));
			sts = MDEALC(lcbp,type);
			if (sts)
			{
				NET_DBG(("NET_close_lu62: MDEALC error: abend code #%d\n",sts));
				NET_error_lu62(net, NET_E_CLOSE_ERROR, NET_E_LU62_MDEALC_ABEND,
					sts, 0);
				return;
			}
			if (lcbp->lu62rc1 != OK)
			{
				NET_DBG(("NET_close_lu62: MDEALC error: rc1:%d rc2:%d\n",
					lcbp->lu62rc1,lcbp->lu62rc2));
				NET_error_lu62(net, NET_E_CLOSE_ERROR, NET_E_LU62_MDEALC_ERROR,
					lcbp->lu62rc1, lcbp->lu62rc2);
				return;
			}
			conversation_count-- ;
		}
	}

	if (net->misc_flag == STOP_CONNECTION)
	{
		if (--attach_count <= 0)
		{
			LU62DETCH();
			attach_count = 0;
		}
	}


	NET_DBG(("NET_close_lu6: conversation_state:%d attach_count:%d conversation_count: %d\n", lcbp->lu62cvst, attach_count, conversation_count));

	NET_DBG(("NET_close_lu62:complete\n"));
}
#endif /* unix */

/******************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_addr_lu62(
	net_s	*net,				/* info used by all net calls */
	char	*netaddr,			/* output string containing network address */
	char	*nodename,			/* input string containing node name */
	int		*len)				/* netaddr string buffer length */
{
	NET_DBG(("NET_addr_lu62(net:0x%x netaddr:0x%x nodename:\"%s\" *len:%d)\n",
		net, netaddr, nodename, *len));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_addr_lu62: failed\n"));
}

/******************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_node_lu62(
	net_s	*net,				/* info used by all net calls */
	char	*nodename,			/* output string containing node name */
	int		*len)				/* nodename string buffer length */
{
	NET_DBG(("NET_node_lu62(net:0x%x nodename:0x%x *len:%d)\n",
		net, nodename, *len));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_node_lu62: failed\n"));
}

/*************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_get_file_lu62(
	net_s			*net,			/* info used by all net calls */
	net_connect_s	*connect_info,	/* info for connecting to remote node */
	char			*remote_file,	/* remote file name */
	char			*local_file)	/* local file name */
{
	NET_DBG(("NET_get_file_lu62(net:0x%x connect_info:0x%x remote_file:\"%s\" local_file:\"%s\"\n",
	 connect_info,remote_file,local_file));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_get_file_lu62: failed\n"));
}

/*************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_put_file_lu62(
	net_s			*net,			/* info used by all net calls */
	net_connect_s	*connect_info,	/* info for connecting to remote node */
	char			*remote_file,	/* remote file name */
	char			*local_file)	/* local file name */
{
	NET_DBG(("NET_put_file_lu62(net:0x%x connect_info:0x%x remote_file:\"%s\" local_file:\"%s\"\n",
	 connect_info,remote_file,local_file));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_put_file_lu62: failed\n"));
}

/*************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_get_lock_file_lu62(
	net_s			*net,			/* info used by all net calls */
	net_connect_s	*connect_info,	/* info for connecting to remote node */
	char			*remote_file)	/* remote file name */
{
	NET_DBG(("NET_get_lock_file_lu62(net:0x%x connect_info:0x%x remote_file:\"%s\"\n",
	 connect_info,remote_file));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_get_lock_file_lu62: failed\n"));
}

/*************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_put_lock_file_lu62(
	net_s			*net,			/* info used by all net calls */
	net_connect_s	*connect_info,	/* info for connecting to remote node */
	char			*remote_file)	/* remote file name */
{
	NET_DBG(("NET_put_lock_file_lu62(net:0x%x connect_info:0x%x remote_file:\"%s\"\n",
	 connect_info,remote_file));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_put_lock_file_lu62: failed\n"));
}

/*************************************************************************/

/* This function has not been implemnted for LU 6.2 */

extern void NET_remove_file_lu62(
	net_s			*net,			/* info used by all net calls */
	net_connect_s	*connect_info,	/* info for connecting to remote node */
	char			*remote_file)	/* remote file name */
{
	NET_DBG(("NET_remove_file_lu62(net:0x%x connect_info:0x%x remote_file:\"%s\"\n",
	 connect_info,remote_file));

	net->error_code = NET_E_NOT_IMPLEMENTED;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_remove_file_lu62: failed\n"));
}

/******************************************************************************/

#if defined(unix)
static void NET_request_send_ind(
 	net_s *net,
	int	  dealloc_ok)	/* set if we can accept being in a dealloc state */
{
	int sts;
	int i_len;
	lu62lcb *lcbp;

	NET_DBG(("NET_request_send_ind(net:0x%x dealloc_ok:%d)\n", net,dealloc_ok));

	lcbp = (lu62lcb *)net->id.lu62.lcbp;
	i_len = 0;

	NET_DBG(("NET_request_send_ind: calling MRCVWT, expecting indicator\n"));
	sts = MRCVWT_wrapper(lcbp, (char*)0, &i_len);
	NET_DBG (("NET_request_send_ind : MRCVWT returning %d\n", sts)) ;
	if (sts)
	{
		NET_DBG(("NET_request_send_ind: MRCVWT error: abend code #%d\n",sts));
		NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MRCVWT_IND_ABEND, sts,
			0);
		return;
	}
		/*
		** If the IBM side has already deallocated, we can accept
		** being in a deallocated state, but only if this occurs
		** while we are trying to close the session, (i.e.,
		** dealloc_ok is set to true.  See its use in NET_close_lu62.
		*/

	if ((lcbp->lu62rc1 == RC_DANML) && dealloc_ok) {
		NET_DBG (("IBM side has already deallocated. Return.\n")) ;
		return;
	}
	
	if (lcbp->lu62rc1 != OK)
	{
		NET_DBG(("NET_request_send_ind: MRCVWT error: rc1:%d rc2:%d\n",
			lcbp->lu62rc1,lcbp->lu62rc2));
		NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MRCVWT_IND_ERROR,
			lcbp->lu62rc1, lcbp->lu62rc2);
		return;
	}

	if ( !(	lcbp->lu62prts == 0 &&
			lcbp->lu62wtrc == LU62IND &&
			lcbp->rcv_typ.lu62ind == IND_SEND) )
	{
		NET_DBG(("NET_request_send_ind: MRCVWT error: prts:%d wtrc:%d rcv_typ:%d\n", lcbp->lu62prts, lcbp->lu62wtrc, lcbp->rcv_typ.lu62data));
		NET_error_lu62(net, NET_E_WRITE_ERROR, NET_E_LU62_MRCVWT_BAD_IND,
			lcbp->lu62wtrc, lcbp->rcv_typ.lu62ind);
		return;
	}

	NET_DBG(("NET_request_send_ind: complete\n"));
}
#endif /* unix */

/*************************************************************************/

#if defined(unix)
static char *abend_error_msg(
	int code)
{
	int i;

	static char default_msg[40];
	static struct abend_error_st
	{
		int code;
		char *msg;
	} abend_error[] = {
		{ A_MGPIPE,	"A_MGPIPE: Could not open pipe to manager"},
		{ A_MYPIPE,	"A_MYPIPE: Could make and open return pipe"},
		{ A_NOMGR,	"A_NOMGR: Manager not reading input pipe"},
		{ A_MYLU,	"A_MYLU: LU in LU62ATTCH undefined or not enabled"},
		{ A_UNATCH,	"A_UNATCH: Program not attached"},
		{ A_MYNAME,	"A_MYNAME: Invalid local program name specified"},
		{ A_CVID,	"A_CVID: Invalid resource id specified"},
		{ A_CVTYP,	"A_CVTYP: Invalid conversation type specified"},
		{ A_SYNLVL,	"A_SYNLVL: Invalid sync level specified"},
		{ A_LUNAM,	"A_LUNAM: Invalid logical unit name length"},
		{ A_TPSVC,	"A_TPSVC: Invalid privelege to invoke a service program"},
		{ A_SNAMG,	"A_SNAMG: SNASVCMG specified by non service program"},
		{ A_INVSEC,	"A_INVSEC: Invalid security data"},
		{ A_PATPN,	"A_PATPN: Invalid partner program specified"},
		{ A_INRCTL,	"A_INRCTL: Invalid return control specified on allocate verb"},
		{ A_INVPC,	"A_INVPC: Invalid pip number specified."},
		{ A_INVPL,	"A_INVPL: Invalid pip length specified."},
		{ A_NOPIP,	"A_NOPIP: Pip data missing"},
		{ A_LLCHK,	"A_LLCHK: Logical record not sent"},
		{ A_LENER,	"A_LENER: Invalid length specified"},
		{ A_STCHK,	"A_STCHK: State check for this verb"},
		{ A_NOCFM,	"A_NOCFM: CONFIRM requested when sync level set to NONE"},
		{ A_IPCER,	"A_IPCER: API inter-process communication error"},
		{ A_DATYP,	"A_DATYP: Invalid type specified parameter on deallocate verb"},
		{ A_PPLOCK,	"A_PPLOCK: Invalid lock paramter specified on PP_TO_REC"},
		{ A_PPTYP,	"A_PPTYP: Invalid type parameter specified on PP_TO_REC"},
		{ A_ATTCH,	"A_ATTCH: LU62ATTCH called a second time"},
		{ A_NOTRMT,	"A_NOTRMT: LU62CVCT issued by local program"},
		{ A_INVPP,	"A_INVPP: Remote sent invalid pip data"},
		{ A_POSTYP,	"A_POSTYP: Invalid type specified on post verb"},
		{ A_SETYP,	"A_SETYP: Invalid type specified on send-error verb"},
		{ A_NOFMH,	"A_NOFMH: Remote did not send expected fmh7"},
		{ A_TESTYP,	"A_TESTYP: Invalid test parameter specified"},
		{ A_LOGID,	"A_LOGID: Invalid log id specified."},
		{ A_RCVLN,	"A_RCVLN: Invalid receive len error"},
		{ A_PLUNAM,	"A_PLUNAM: Invalid partner lu name type"},
		{ A_BDMPN,	"A_BDMPN: Invalid map name"},
		{ A_FILL,	"A_FILL: Invalid fill parameter"},
		{ A_BDSNS,	"A_BDSNS: Unrecognized sense code in fmh7"},
		{ A_BDBRK,	"A_BDBRK: LU62BRK was called and API could not successfully break out of verb"},
		{ A_SECRTY,	"A_SECRTY: Security PGM not supported"},
		{ A_MAPNSP,	"A_MAPNSP: MAP not supported"},
		{ A_FMHNSP,	"A_FMHNSP: FMH not supported"},
		{ A_RSFAIL,	"A_RSFAIL: lu6.2 manager could not allocate resource"}};

	static int abend_error_count = sizeof(abend_error)/sizeof(struct abend_error_st);


	for (i = 0; i < abend_error_count; i++)
		if (abend_error[i].code == code)
			return(abend_error[i].msg);

	sprintf(default_msg,"Unknown ABEND code: %d",code);
	return(default_msg);
}
#endif /* unix */

/******************************************************************************/

#if defined(unix)
static char *get_return_code_name(
	int rc)
{
	switch(rc)
	{
		case PARM_ERR:	return("PARM_ERR: parameter error");
		case RC_ABPGM:	return("RC_ABPGM: deallocate error - deallocate abend");
		case RC_ABSVC:	return("RC_ABSVC: deallocate error - deallocate SVC");
		case RC_ABTIM:	return("RC_ABTIM: deallocate error - deallocate timer");
		case RC_ALCER:	return("RC_ALCER: allocation error");
		case RC_BACK:	return("RC_BACK: backed out");
		case RC_BREAK:	return("RC_BREAK: LU62BRK was called and broke out of a pended read");
		case RC_DANML:	return("RC_DANML: deallocate normal");
		case RC_FMHNS:	return("RC_FMHNS: FMH data not supported");
		case RC_MAPEX:	return("RC_MAPEX: map execution failed");
		case RC_MAPNF:	return("RC_MAPNF: map not found");
		case RC_MAPNS:	return("RC_MAPNS: mapping not supported");
		case RC_PGNTR:	return("RC_PGNTR: program error - no trunc");
		case RC_PGPUR:	return("RC_PGPUR: program error - purging");
		case RC_PGTRC:	return("RC_PGTRC: program error - truncated");
		case RC_PSNAC:	return("RC_PSNAC: posting not active");
		case RC_RFAIL:	return("RC_RFAIL: resource failure - no retry");
		case RC_RFTRY:	return("RC_RFTRY: resource failure - retry");
		case RC_SVNTR:	return("RC_SVNTR: SVC error - no trunc");
		case RC_SVPUR:	return("RC_SVPUR: SVC error - purging");
		case RC_SVTRC:	return("RC_SVTRC: SVC error - truncated");
		case RC_UNSCS:	return("RC_UNSCS: unsucessful");
		default:		return("Unknown return code");
	}
}
#endif /* unix */

/******************************************************************************/

#if defined(unix)
static char *get_reason_code_name(
	int rs)
{
	switch(rs)
	{
		case NORMAL:	return("NORMAL: normal TP outage");
		case RS_RETRY:	return("RS_RETRY: retry");
		case RS_NOTRY:	return("RS_NOTRY: no retry");
		case RS_SYLVL:	return("RS_SYLVL: synchronization level");
		case RS_BIDLIM:	return("RS_BIDLIM: bid limit exceeded");
		case RS_TPNR:	return("RS_TPNR: TP program not recognized"); 
		case RS_PIPNA:	return("RS_PIPNA: PIP not allowed"); 
		case RS_PIPNC:	return("RS_PIPNC: PIP not specified correctly"); 
		case RS_CVMIS:	return("RS_CVMIS: conversation type mismatch"); 
		case RS_SYLNS:	return("RS_SYLNS: synchronization level not supported");
		case RS_RCLNS:	return("RS_RCLNS: reconnect level not supported");
		case RS_TPNAN:	return("RS_TPNAN: TP not available - no retry");
		case RS_TPNAR:	return("RS_TPNAR: TP not available - retry");
		case RS_SECNV:	return("RS_SECNV: security not valid");
		case RS_LIMIT:	return("RS_LIMIT: some limit has been exceeded");
		case RS_NOTDA:	return("RS_NOTDA: something other that data was received");
		case RS_DATA:	return("RS_DATA: data is received");
		default:		return("Unknown reason code");
	}
}
#endif /* unix */

/******************************************************************************/

#if defined(unix)
	/*
	**	Look for the file $RISDIR/commlink.  If there is such a file,
	**  read the COMMLINK directory value from it.  If there is no such file,
	**	use a default.
	**	Set the environment variable COMMLINK to this directory.
	*/

#define COMMLINK_CONFIG_FILE		"/commlink"
#define DEFAULT_COMMLINK	"/usr/ip32/ibm"

extern void NET_set_commlink(
	net_s	*net)
{
	FILE	*fp;
	char	file_name[MAX_PATH_SIZE];
	char	buffer[MAX_PATH_SIZE];
	char 	*status;
	char	*p;
	char	*commlink_value;

	NET_DBG(("NET_set_commlink(net:0x%x)\n", net));

	strcpy(commlink, "COMMLINK=");
	commlink_value = commlink + sizeof("COMMLINK=") - 1;
	

		/*
		** Look for the file $RISDIR/commlink ; 
		** if it is not there, use the default
		*/

	while (1)	/* we will only do this once */
	{
		extern char RIS_dir[];

		sprintf(file_name,"%s/%s", RIS_dir, COMMLINK_CONFIG_FILE);

		if ((fp = NET_fopen(file_name, "r")) == NULL)
		{
			strcpy(commlink_value, DEFAULT_COMMLINK);
			break;
		}

			/*
			** If the file is there, read one line;
			** it must be a complete directory pathname;
			** (begin with /)
			*/
		
		status = NET_fgets(buffer, MAX_PATH_SIZE, fp);
		NET_fclose(fp);

		if (!status)
		{
			strcpy(commlink_value, DEFAULT_COMMLINK);
			break;
		}

		p = buffer;

			/*
			** skip leading whitespace
			*/

		while ((*p == ' ') || (*p == '\t'))
			++p;

			/*
			** it must begin with '/'
			*/

		if (*p != '/')
		{
				/*
				** if not, use the default commlink
				*/
			strcpy(commlink_value, DEFAULT_COMMLINK);
			break;
		}

		strcpy(commlink_value, p);
		p = commlink_value;
		p += strlen(commlink_value);
		--p;

			/*
			**  strip trailing whitespace
			*/

		while ( (p > commlink_value) && 
			((*p == ' ') || (*p == '\n') || (*p == '\t')))
			--p;

			/*
			** but do not back up beyond the beginning of the buffer
			*/

		if (p>=commlink_value)
		{
			++p;
			strcpy(p, COMMLINK_CONFIG_FILE);
		}
		else
		{
			strcpy(commlink_value, DEFAULT_COMMLINK);
		}
		break;
	}
		
	NET_DBG(("NET_set_commlink: commlink:<%s>\n",commlink));
	if (putenv(commlink))
	{
		NET_DBG(("NET_set_commlink: putenv error: errno:%d", errno));
		NET_error_lu62(net, NET_E_PUTENV_ERROR, 0, 0, 0);
		return;
	}

	NET_DBG(("NET_set_commlink: complete\n"));
}

#ifdef OLD
	/*
	**	Search the Intergraph Configuration file for the LU6.2 product.
	**	Extract the directory that the LU6.2 product was installed in.
	**	Replace the lowest level directory with "ibm". (This is required
	**	because the SSI software has 3 products, and we need to use the
	**	"ibm" directory for the environment variable COMMLINK.)
	**	Set the environment variable COMMLINK to this derived directory.
	*/

extern void NET_set_commlink(
	net_s	*net)
{
	FILE	*fp;
	char	*file_name;
	char	buffer[MAX_PATH_SIZE];
	char	*temp;
	char	*ssi_product;
	int		index;
	char	*dir;

	NET_DBG(("NET_set_commlink(net:0x%x)\n", net));

	/*
	**	The Intergraph Configuration file is always located in "/usr/ip32"
	**	and its name is "ingrconfig"
	*/

	dir = "";
	file_name = "/usr/ip32/ingrconfig";

	if ((fp = NET_fopen(file_name, "r")) == NULL)
	{
		NET_DBG(("NET_set_commlink: can't open \"%s\"\n", file_name));
		NET_error_lu62(net, NET_E_CANT_OPEN_INGRCONFIG, 0, 0, 0);
		return;
	}

	/*
	**	The SSI LU6.2 product number is
	*/
	ssi_product = "SS01151";

	/*
	**	The Intergraph Configuration file has a line format as follows:
	**	number#abbreviation#title#revision#date#installed_directory#
	*/
	while (NET_fgets(buffer, MAX_PATH_SIZE, fp) )
	{
		if (strncmp(buffer,ssi_product,strlen(ssi_product)) == 0)
		{
			temp=buffer;

			/* skip to the directory part */
			for(index=0;index<5;index++)
			{
				temp=strchr(temp,'#');
				temp++;
			}

			/* extract the directory part */
			dir=temp;

			/* delete the last portion of the buffer */
			temp=strchr(temp,'#');
			*temp='\0';

			/* find the last node of the directory path */
			temp=strrchr(dir,'/');
			*temp='\0';
			break;
		}
	}
	NET_fclose(fp);
	if (*dir == '\0')
	{
		NET_DBG(("NET_set_commlink: LU62 is not installed\n"));
		NET_error_lu62(net, NET_E_LU62_NOT_INSTALLED, 0, 0, 0);
		return;
	}

	strcpy(commlink, "COMMLINK=");
	strcat(commlink, dir);
	NET_DBG(("NET_set_commlink: commlink:<%s>\n",commlink));
	if (putenv(commlink))
	{
		NET_DBG(("NET_set_commlink: putenv error: errno:%d", errno));
		NET_error_lu62(net, NET_E_PUTENV_ERROR, 0, 0, 0);
		return;
	}

	NET_DBG(("NET_set_commlink: complete\n"));
}
#endif /* OLD */
#endif /* unix */

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_error for LU6.2.
** It is intended for setting information in the net structure related to the
** error that has occured.  It is implemented using CPI-C.
*/

#if defined (WIN32)
extern void NET_error_lu62(
	net_s	*net,				/* info used by all net calls */
	int		netcode,			/* generic network error code */
	int		lu62netcode,		/* LU 6.2 specific error code */
	int		return_code,		/* return code from CPI-C function */
	int		unused)				/* not used by NT implementation */
{
	char *return_code_msg;		/* CPI-C return code message string */
	int	size;					/* size of string buffer */

	static unsigned int cpic_ext_ret_code_msg_nums[]={
		NET_E_CPIC_WCPICALREADY,
		NET_E_CPIC_WCPICINVALID,
		NET_E_CPIC_WCPICCANCEL,
		NET_E_CPIC_WCPICSYSNOTREADY,
		NET_E_CPIC_WCPICVERNOTSUPPORTED};

	static unsigned int cpic_ret_code_msg_nums[]={
		NET_E_CPIC_OK,                        
		NET_E_CPIC_ALLOC_FAIL_NO_RETRY,
		NET_E_CPIC_ALLOC_FAIL_RETRY,
		NET_E_CPIC_CONV_TYPE_MISMATCH,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_PIP_NOT_SPECD_CORRECTLY,
		NET_E_CPIC_SECURITY_NOT_VALID,
		NET_E_CPIC_SYNC_LVL_NOT_SUPPORTED_LU,
		NET_E_CPIC_SYNC_LVL_NOT_SUPPORTED_PGM,
		NET_E_CPIC_TPN_NOT_RECOGNIZED,
		NET_E_CPIC_TP_NOT_AVAILABLE_NO_RETRY,
		NET_E_CPIC_TP_NOT_AVAILABLE_RETRY,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_DEALLOCATED_ABEND,
		NET_E_CPIC_DEALLOCATED_NORMAL,
		NET_E_CPIC_PARAMETER_ERROR,
		NET_E_CPIC_PRODUCT_SPECIFIC_ERROR,
		NET_E_CPIC_PROGRAM_ERROR_NO_TRUNC,
		NET_E_CPIC_PROGRAM_ERROR_PURGING,
		NET_E_CPIC_PROGRAM_ERROR_TRUNC,
		NET_E_CPIC_PROGRAM_PARAMETER_CHECK,
		NET_E_CPIC_PROGRAM_STATE_CHECK,
		NET_E_CPIC_RESOURCE_FAIL_NO_RETRY,
		NET_E_CPIC_RESOURCE_FAIL_RETRY,
		NET_E_CPIC_UNSUCCESSFUL,
		NET_E_CPIC_UNKNOWN,
		NET_E_CPIC_DEALLOCATED_ABEND_SVC,
		NET_E_CPIC_DEALLOCATED_ABEND_TIMER,
		NET_E_CPIC_SVC_ERROR_NO_TRUNC,
		NET_E_CPIC_SVC_ERROR_PURGING,
		NET_E_CPIC_SVC_ERROR_TRUNC,
		NET_E_CPIC_OPERATION_INCOMPLETE,
		NET_E_CPIC_SYSTEM_EVENT,
		NET_E_CPIC_OPERATION_NOT_ACCEPTED};

	NET_DBG(("NET_error_lu62(net:0x%x: netcode:%d lu62netcode:%d return_code:%d unused:%d\n",
	 net,netcode,lu62netcode,return_code,unused));

/* fill in generic error and message */

	net->error_code = netcode;

/* assumes that error_string buffer is big enough */

	strcpy(net->error_string,NET_error_msg(net->error_code));

/*
** if there is a CPI-C return code then fill in the network specific error and
** message.
*/

	if (return_code)
	{
		net->net_error_code = return_code;

/* determine size of net_error_string buffer */

		size = sizeof(net->net_error_string) - 1;

/* if there is an LU 6.2 specific error then get its corresponding string */

		if (lu62netcode)
		{

/* assumes that error_string buffer is big enough */

			strcpy(net->net_error_string,NET_error_msg(lu62netcode));
			size -= strlen(net->net_error_string);

/* add a space if there is room */

			if (size >= 1)
			{
				strcat(net->net_error_string," ");
				size--;
			}
		}

/* return codes for Windows extensions to CPIC all have first 4 bits set */

		if (return_code & 0xF000)
		{
			if (return_code & 0x0FFF >= sizeof(cpic_ext_ret_code_msg_nums)/
			 sizeof(char *))
			{
				return_code_msg = NET_error_msg(NET_E_CPIC_UNKNOWN);
			}
			else
			{
				return_code_msg = NET_error_msg(
			  	 cpic_ext_ret_code_msg_nums[return_code & 0x0FFF]);
			}
		}
		else
		{
			if (return_code >= sizeof(cpic_ret_code_msg_nums)/
			 sizeof(char *))
			{
				return_code_msg = NET_error_msg(NET_E_CPIC_UNKNOWN);
			}
			else
			{
				return_code_msg = NET_error_msg(
			  	 cpic_ret_code_msg_nums[return_code]);
			}
		}

/* add as much of the return code message as will fit */

		strncat(net->net_error_string,return_code_msg,size);
	}

	NET_DBG(("error_string = \"%s\"\n", net->error_string));
	NET_DBG(("net_error_string = \"%s\"\n", net->net_error_string));

	NET_DBG(("NET_error_lu62: complete\n"));
}
#endif /* WIN32 */

/******************************************************************************/

#if defined(unix)
extern void NET_error_lu62(
	net_s	*net,
	int		netcode,
	int		lu62netcode,
	int		arg1,
	int		arg2)
{
	char *ptr;

	NET_DBG(("NET_error_lu62(net:0x%x: netcode:%d lu62netcode:%d arg1:%d arg2:%d\n",net,netcode,lu62netcode,arg1,arg2));

	/* fill in protocol_specific error info */
	ptr = net->net_error_string;
	switch(lu62netcode)
	{
			/*
			** The first case is nasty kludge stuff.
			** With DB2, the attach is equivalent to a DBMS_OPEN, so instead
			** of handling attach errors as a generic broken network problem,
			** we have to get back to the open_db() function so we can return
			** a typical dbs connect error.
			** We do that by longjump'ing back to where we were.
			*/
			
		case NET_E_LU62_ATTACH_ABEND:
		case NET_E_LU62_MALLOC_ABEND:
		case NET_E_LU62_CVCT_ABEND:
		case NET_E_LU62_MSEND_ABEND:
		case NET_E_LU62_MRCVWT_DATA_ABEND:
		case NET_E_LU62_MRCVWT_IND_ABEND:
		case NET_E_LU62_MDEALC_ABEND:
			sprintf(ptr,"%s.", abend_error_msg(arg1));
			net->net_error_code = arg1;
			break;

		case NET_E_LU62_MALLOC_ERROR:
		case NET_E_LU62_CVCT_ERROR:
		case NET_E_LU62_MSEND_ERROR:
		case NET_E_LU62_MRCVWT_DATA_ERROR:
		case NET_E_LU62_MRCVWT_IND_ERROR:
		case NET_E_LU62_MDEALC_ERROR:
			sprintf(ptr,"Return code %s. Reason code %s.",
				get_return_code_name(arg1),
				get_reason_code_name(arg2));
				net->net_error_code = arg1;
			break;

		case NET_E_LU62_MRCVWT_BAD_DATA:
		case NET_E_LU62_MRCVWT_BAD_IND:
			switch(arg1)
			{
				case LU62DATA:
					sprintf(ptr,"Received data type %d",arg2);
					break;

				case LU62IND:
					sprintf(ptr,"Received indicator type %d",arg2);
					break;

				default:
					sprintf(ptr,"wtrc = %d, rcv_typ = %d",arg1,arg2);
					break;
			}
			net->net_error_code = arg1;
			break;

		default:
			break;
	}
	switch(netcode)
	{
		case NET_E_PUTENV_ERROR:
		case NET_E_CANT_OPEN_INGRCONFIG:
			net->net_error_code = errno;
			strcpy(ptr, sys_errlist[errno]);
			break;
	}

	/* fill in generic error info */
	net->error_code = netcode;
	strcpy(net->error_string,NET_error_msg(net->error_code));

	NET_DBG(("NET_error_lu62: net->error_string:<%s>\n", net->error_string));
	NET_DBG(("NET_error_lu62: net->net_error_string:<%s>\n",
		net->net_error_string));
	NET_DBG(("NET_error_lu62: complete\n"));
}
#endif /* unix */

/******************************************************************************/

/*
** This is the 32 bit Windows implementation of NET_cleanup for LU6.2.
** It is intended for freeing up all CPIC resources.
*/

#if defined(WIN32)
extern void NET_cleanup_lu62(
	void)
{
	long return_code;					/* return code var for CPI-C calls */

	NET_DBG(("Net_cleanup_lu62()\n"));

	if (started)
	{

		NET_DBG(("calling WinCPICCleanup()\n"));

		NET_WINCPICCLEANUP(return_code);

		NET_DBG(("WinCPICCleanup return value = %d\n",return_code));

		started = 0;
	}

	NET_DBG(("Net_cleanup_lu62: complete\n"));
}
#endif /* WIN32 */

#if defined(unix)
extern int MRCVWT_wrapper (
	lu62lcb			*lcbp, 
	char			*data, 
	int			*length)
{
	int		sts;

	NET_DBG(("Entering MRCVWT_wrapper\n"));

	RISsrv_enable_lu62_alarm_system();

	sts = MRCVWT(lcbp, data, length);

	RISsrv_disable_lu62_alarm_system();

	NET_DBG(("Exiting MRCVWT_wrapper : returning %d\n",  sts));
	return (sts);
}

extern int MALLOC_wrapper(
    lu62crb *crb, 
    lu62lcb *lcbp)
{
    int sts;
    
	NET_DBG(("Entering MALLOC_wrapper\n"));

	RISsrv_enable_lu62_alarm_system();

	sts = MALLOC(crb,lcbp);

	RISsrv_disable_lu62_alarm_system();

	NET_DBG(("Exiting MALLOC_wrapper : returning %d\n",  sts));
	return (sts);
}

extern int MPPTRC_wrapper(
    lu62lcb *lcbp)
{
    int sts;

	NET_DBG(("Entering MPPTRC_wrapper\n"));

	RISsrv_enable_lu62_alarm_system();

	sts = MPPTRC(lcbp,PP_FLUSH,0);

	RISsrv_disable_lu62_alarm_system();

	NET_DBG(("Exiting MPPTRC_wrapper : returning %d\n",  sts));
	return (sts);
}
#endif /* unix */

/******************************************************************************/

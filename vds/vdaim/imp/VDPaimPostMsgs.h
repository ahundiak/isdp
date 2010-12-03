#ifndef VDPaimPostMsgs_h_
#define VDPaimPostMsgs_h_



static ascii_char *MsgOrigins [] = {			/* message originations */

#define		MOID_NO_MSG					0		
		"",

#define		MOID_ACCEPT_SOC					1
		"Accepting Socket",

#define		MOID_BIND_SOC					2
		"Binding Socket",

#define		MOID_CALLING_POSTMAN				3
		"Sending Message To DM2",

#define		MOID_CANT_READ_FULL				4
		"Cannot Read Full Socket Buffer",

#define		MOID_CANT_WRITE_FULL				5
		"Cannot Write Full Socket Buffer",

#define		MOID_CHECKING					6
		"Checking",

#define		MOID_CLIENT					7
		"ClInitialize",

#define		MOID_CONN_SOC					8
		"Connecting Socket",			

#define		MOID_LOWERR_INIT				9
		"Doing low_err_init",

#define		MOID_OPEN_SOC					10
		"Opening Socket",			

#define		MOID_PACK_BUFF					11
		"Packing Buffer",

#define		MOID_READ_BUFSIZE				12
		"Reading TCP Buffersize",

#define		MOID_READ_INIT					13
		"Reading Init Requst From Clix",

#define		MOID_READ_SOC					14
		"Reading Socket",

#define		MOID_READ_SYNC					15
		"Reading Sync Packet",

#define		MOID_REALLOC_MALLOC				16
		"Realloc/Malloc",

#define		MOID_SELECT_SOC					17
		"Selecting On Socket",

#define		MOID_SPAWN_POST					18
		"Spawning "POSTMANFORUSER,

#define		MOID_START_TCP					19
		"Starting Tcp/Ip",

#define		MOID_UNPACK_BUFF				20
		"Unpacking Buffer",

#define		MOID_WRITE_SOC					21
		"Writing Socket",

#define		MOID_WRITE_SYNC					22
		"Writing Sync Packet",

	};

	static ascii_char *Msgs [] = {				/* MESSAGES */

#define		MSGID_NOMSG					0
		"",

#define		MSGID_ACTUAL_READ				1
		"Actual Bytes Read %d",

#define		MSGID_BAD_MSG_CALL				2
		"BAD Internal Call To NTmsg, Code %",

#define		MSGID_BAD_SERVER_CALL				3
		"Bad call/return to/from server",

#define		MSGID_BUF_TOO_BIG				4
		"Buffer Size Too Big; needed %d, allowed %d",

#define		MSGID_CLIENT_INIT_ERR				5
		"Cannot Initialize Client",

#define		MSGID_CLIX_ADDRESS				6
		" Clix Address = %s",

#define		MSGID_CLIX_NAME					7
		" Clix Host    = %s",

#define		MSGID_DM2_ALREADY_UP				8
		"DM2/"POSTMANFORUSER" Already Initialized",

#define		MSGID_DM2_NOT_INITIALIZED			9
		POSTMANFORUSER" and/or DM2 Not Initialized",

#define		MSGID_INETD_DAEMON				10
		" Unconnected "POSTMANFORUSER" Inetd Daemon",

#define		MSGID_INVALID_BUF				11
		"Received Invalid Buffer",

#define		MSGID_KILLME					12
		"...Ctrl-C To Kill Me ......",

#define		MSGID_LOW_ERR_INIT_PROBLEM			13
		"Cannot low_err_init "POSTMANFORUSER,

#define		MSGID_LOW_ERR_INIT_STAT				14
	        "low_err_init returned dstat = %d",

#define		MSGID_NOSYS_MSG					15
		"No System Error Message",

#define		MSGID_NOT_ENUF_FIELDS				16
		"Incorrect Buffer Format - Not Enough Fields",

#define		MSGID_NO_NT_C_MSG				17
		"No NT Message - C RunTime Error %",

#define		MSGID_NO_NT_SOC_MSG				18
		"No NT Message - Socket Error %",

#define		MSGID_NO_NT_WINAPI_MSG				19
		"No NT Message - WinApi Error %",

#define		MSGID_OTHER_CLOSED				20
		"Connection Closed By Other Side",

#define		MSGID_POSTMAN_PORTNO				21
		"("POSTMANFORUSER" Portno %d) %s",

#define		MSGID_PROC_ID					22
		" Process Id   = %d\n Started At   = %s",

#define		MSGID_PROC_INFO					23
		" ---- Process Information ----",

#define		MSGID_PROXY_UNDEFINED				24
		"Env Variable "PROXY_CLIENT_ADDRESS" Not Found",

#define		MSGID_SEE_SOURCE_FILE				25
		"See postman.c Main Functions For Options",

#define		MSGID_SERVER_TAG				26
		" "POSTMANFORUSER" Server Connected To Clix Host",

#define		MSGID_SOC_TIMED_OUT				27
		"Socket Read Request Timed Out",

#define		MSGID_TCPIP_BAD_VERSION				28
		"Tcp/Ip Version Mismatch",

#define		MSGID_TERMINATE_ALL				29
		"Please Terminate All "BINARY_NAME" Processes",

#define		MSGID_TOO_SHORT_BUF				30
		"Buffer Lenght Too Short",
	};

#endif

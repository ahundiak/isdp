/*
**	NAME:							schfile.h
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**		Contains macros that are used in the schemas file.
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
*/

#ifdef TIMESTAMP
# undef TIMESTAMP
#endif

#define TIMESTAMP			"TIMESTAMP:"
#define TIMESTAMP_SIZE		(sizeof(TIMESTAMP) - 1)
#define SCHNAME				"SCHNAME="
#define SCHNAME_SIZE		(sizeof(SCHNAME) - 1)
#define SECURE				"SECURE="
#define SECURE_SIZE			(sizeof(SECURE) - 1)
#define DICTOWNER			"DICTOWNER="
#define DICTOWNER_SIZE		(sizeof(DICTOWNER) - 1)
#define SCHOWNER			"SCHOWNER="
#define SCHOWNER_SIZE		(sizeof(SCHOWNER) - 1)
#define SCHOWNPASS			"SCHOWNPASS="
#define SCHOWNPASS_SIZE		(sizeof(SCHOWNPASS) - 1)
#define DBID				"DBID="
#define DBID_SIZE			(sizeof(DBID) - 1)
#define BEGIN_DEFAULT_USER		"BEGIN_DEFAULT_USER"
#define BEGIN_DEFAULT_USER_SIZE	(sizeof(BEGIN_DEFAULT_USER) - 1)
#define END_DEFAULT_USER		"END_DEFAULT_USER"
#define END_DEFAULT_USER_SIZE	(sizeof(END_DEFAULT_USER) - 1)
#define BEGIN_GRANTEES		"BEGIN_GRANTEES"
#define BEGIN_GRANTEES_SIZE	(sizeof(BEGIN_GRANTEES) - 1)
#define END_GRANTEES		"END_GRANTEES"
#define END_GRANTEES_SIZE	(sizeof(END_GRANTEES) - 1)

#define SERVER_VERSION		"SERVER_VERSION="
#define SERVER_VERSION_SIZE	(sizeof(SERVER_VERSION) - 1)

#define DTYPE				"DTYPE="
#define DTYPE_SIZE			(sizeof(DTYPE) - 1)
#define DBNAME				"DBNAME="
#define DBNAME_SIZE			(sizeof(DBNAME) - 1)
#define RIS_DICT_DBNAME		"RIS_DICT_DBNAME="
#define RIS_DICT_DBNAME_SIZE	(sizeof(RIS_DICT_DBNAME) - 1)
#define PROTOCOL			"PROTOCOL="
#define PROTOCOL_SIZE		(sizeof(PROTOCOL) - 1)
#define NETADDR				"NETADDR="
#define NETADDR_SIZE		(sizeof(NETADDR) - 1)

#if defined(WIN32) || defined(vms)
/* 
**
** DIR is not a good choice for a macro name under Solaris 2.x and perhaps 
** other platforms, namely, CLIX also chokes on it.
** 
*/

#define DIR					"DIR="
#define DIR_SIZE			(sizeof(DIR) - 1)

#elif defined(unix)
#define SCHFILE_DIR				"DIR="
#define DIR_SIZE			(sizeof(SCHFILE_DIR) - 1)

#else
ERROR -- NO CODE

#endif

#define OSTYPE				"OSTYPE="
#define OSTYPE_SIZE			(sizeof(OSTYPE)-1)
#define OSUSER				"OSUSER="
#define OSUSER_SIZE			(sizeof(OSUSER)-1)
#define OSPASS				"OSPASS="
#define OSPASS_SIZE			(sizeof(OSPASS)-1)

#ifdef ACCEPT_VERSION_2_SCHEMA_FILES
#define RIS21_MAX_ID_SIZE       19
#define RIS21_MAX_PASSWD_SIZE   24

#define PARMS					"PARMS="
#define PARMS_SIZE				(sizeof(PARMS) - 1)
#define NEWDATABASE				"NEWDATABASE"
#define NEWDATABASE_SIZE		(sizeof(NEWDATABASE) - 1)
#define NEWUSER					"NEWUSER"
#define NEWUSER_SIZE			(sizeof(NEWUSER) - 1)
#define NEWRESOURCEUSER			"NEWRESOURCEUSER"
#define NEWRESOURCEUSER_SIZE	(sizeof(NEWRESOURCEUSER) - 1)
#define NEWDBAUSER				"NEWDBAUSER"
#define NEWDBAUSER_SIZE			(sizeof(NEWDBAUSER) - 1)
#endif

/* INFORMIX stuff */
#define SQLEXEC				"SQLEXEC="
#define SQLEXEC_SIZE		(sizeof(SQLEXEC) - 1)
#define DBTEMP				"DBTEMP="
#define DBTEMP_SIZE			(sizeof(DBTEMP) - 1)
#define TBCONFIG			"TBCONFIG="
#define TBCONFIG_SIZE		(sizeof(TBCONFIG) - 1)

/* SYBASE stuff  && MSSQL */
#define DSQUERY				"DSQUERY="
#define DSQUERY_SIZE		(sizeof(DSQUERY) - 1)
#define FILENAME			"FILENAME="
#define FILENAME_SIZE		(sizeof(FILENAME) - 1)

/* DB2 stuff */
#define ARCH				"ARCH="
#define ARCH_SIZE			(sizeof(ARCH)-1)
#define OS					"OS="
#define OS_SIZE				(sizeof(OS)-1)
#define ENV					"ENV="
#define ENV_SIZE			(sizeof(ENV)-1)
#define NET_PROTOCOL		"NET_PROTOCOL="
#define NET_PROTOCOL_SIZE	(sizeof(NET_PROTOCOL)-1)
#define HOST_PROGRAM		"HOST_PROGRAM="
#define HOST_PROGRAM_SIZE	(sizeof(HOST_PROGRAM)-1)
#define RIS_LU				"RIS_LU="
#define RIS_LU_SIZE			(sizeof(RIS_LU)-1)
#define HOST_LU				"HOST_LU="
#define HOST_LU_SIZE		(sizeof(HOST_LU)-1)
#define MODE				"MODE="
#define MODE_SIZE			(sizeof(MODE)-1)
#define GROUP				"GROUP="
#define GROUP_SIZE			(sizeof(GROUP)-1)
#define NODE				"NODE="
#define NODE_SIZE			(sizeof(NODE)-1)
#define PORT				"PORT="
#define PORT_SIZE			(sizeof(PORT)-1)

#define CHECKSUM			"CHECKSUM:"
#define CHECKSUM_SIZE		(sizeof(CHECKSUM)-1)

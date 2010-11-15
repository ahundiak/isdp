/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							riscom.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:

TDM:11/10/93:	Added ODBC flag to RIS_process

**		
**	
**	REVISION HISTORY:
*/

#ifndef RISCOM_H
#define RISCOM_H

#ifndef COM_EXTERN
# ifdef COM_GLOBAL_DEFINE
#  define COM_EXTERN
# else
#  define COM_EXTERN extern
# endif
#endif

#ifndef COM_INITIAL
# ifdef COM_GLOBAL_DEFINE
#  define COM_INITIAL(value) = value
# else
#  define COM_INITIAL(value)
# endif
#endif

 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "rislang.h"

/*
**	DEFINES
*/

/* Values for RIS_process */
#define SET_APPLICATION			RIS_process |= 0x1
#define APPLICATION				(RIS_process & 0x1)
#define SET_CLIENT				RIS_process |= 0x2
#define CLIENT					(RIS_process & 0x2)
#define SET_SERVER				RIS_process |= 0x4
#define SERVER					(RIS_process & 0x4)
#define SET_PREPROCESSOR		RIS_process |= 0x8
#define PREPROCESSOR			(RIS_process & 0x8)
#define SET_TCPSERVER			RIS_process |= 0x10
#define TCPSERVER				(RIS_process & 0x10)
#if defined(WIN32)
#define SET_ODBCDLL				RIS_process |= 0x20
#define ODBCDLL					(RIS_process & 0x20)
#endif

/* Modes for RIScom_get_risdir() */
#define MATCH_MAJOR					1	/* 3.x.x.x & < Appli/Client 		*/
#define MATCH_MAJOR_MINOR			2	/* 3.x.x.x & < Client/Server 		*/
#define MATCH_MAJOR_MINOR_RELEASE	3	/* 3.x.x.x & < ? 					*/
#define MATCH_HIGHEST				4	/* UMS msg files 					*/
#define MATCH_COMPATIBLE			5	/* 4.x.x.x & > Appli/Client/Server 	*/
#define MATCH_MAJOR_FEATURE         6   /* 5.x.x.x & > Appli/Client/Server */

/* Starting V5 we have two types of schemas. "Secure schemas" and
** "Standard schemas". JP 12/08/93
*/

#define SECURE_SCHEMA 		1
#define STANDARD_SCHEMA 	0

/* Access macros */
#define ACC_SELECT		0
#define ACC_INSERT		1
#define ACC_DELETE		2
#define ACC_UPDATE		3
#define ACC_CONNECT		4
#define ACC_RESOURCE	5
#define ACC_DBA			6

#define ACC_SIZE		7

#define NO_ACCESS		"-------"
#define SELECT_ACCESS	"s------"
#define INSERT_ACCESS	"-i-----"
#define DELETE_ACCESS	"--d----"
#define UPDATE_ACCESS	"---u---"
#define GRANTABLE_SELECT_ACCESS	"S------"
#define GRANTABLE_INSERT_ACCESS	"-I-----"
#define GRANTABLE_DELETE_ACCESS	"--D----"
#define GRANTABLE_UPDATE_ACCESS	"---U---"

#define ALL_ACCESS				"sidu---"
#define GRANTABLE_ALL_ACCESS	"SIDU---"

#define ANY_ACCESS				"****---"

/*
** Added for V5: JP 12/10/93
*/

#define DICTIONARY_ADMIN_PRIV   'D'
#define SCHEMA_ADMIN_PRIV       'S'
#define CONNECT_PRIV            'C'
#define RESOURCE_PRIV           'R'

/* dtime defines */
#define DT_SECOND		0
#define DT_MINUTE		1
#define DT_HOUR			2
#define DT_DAY			3
#define DT_MONTH		4
#define DT_YEAR			5
#define DT_COUNT		6

/*
**	TYPES
*/
typedef struct dtime_s
{
	unsigned int	data[DT_COUNT];
} dtime;

/*
**	VARIABLES
*/
COM_EXTERN  int          RIS_app_cli_version   COM_INITIAL(0);

COM_EXTERN  int          RIS_language_code   COM_INITIAL(-1);

COM_EXTERN  int			RIS_process								COM_INITIAL(0);
COM_EXTERN  short		RIS_current_stmt_id						COM_INITIAL(-1);

COM_EXTERN  int			RIS_development							COM_INITIAL(0);
COM_EXTERN  char			RIS_dir[RIS_MAX_PATH_SIZE]				COM_INITIAL("");

COM_EXTERN  char         RIS_local_xns_addr[RIS_MAX_NODE_SIZE]	COM_INITIAL("");
COM_EXTERN  char         RIS_local_tcp_addr[RIS_MAX_NODE_SIZE]	COM_INITIAL("");
COM_EXTERN  char         RIS_local_dnp_addr[RIS_MAX_NODE_SIZE]	COM_INITIAL("");
COM_EXTERN  char         RIS_local_lu62_addr[RIS_MAX_NODE_SIZE]	COM_INITIAL("");

#endif /* RISCOM_H */

/* Do not alter this SPC information: $Revision: 1.2.34.1 $ */
/*
**	NAME:							risdebug.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:

TDM:11/10/93:	Added ODBC debug

**	
**	REVISION HISTORY:
*/

#ifndef RIS_DEBUG_H
#define RIS_DEBUG_H

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
/*#include <stdio.h>*/
/*
**	DEFINES
*/
#ifdef NO_APP_DBG
#define APP_DBG(s)
#else
#define APP_DBG(s)	if (RISapp_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_BUF_DBG
#define BUF_DBG(s)
#else
#define BUF_DBG(s)	if (RISbuf_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_CLI_DBG
#define CLI_DBG(s)
#else
#define CLI_DBG(s)	if (RIScli_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_CCO_DBG
#define CCO_DBG(s)
#else
#define CCO_DBG(s)	if (RIScco_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_COM_DBG
#define COM_DBG(s)
#else
#define COM_DBG(s)	if (RIScom_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_DBS_DBG
#define DBS_DBG(s)
#else
#define DBS_DBG(s)	if (RISdbs_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_DDS_DBG
#define DDS_DBG(s)
#else
#define DDS_DBG(s)	if (RISdds_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_DIC_DBG
#define DIC_DBG(s)
#else
#define DIC_DBG(s)	if (RISdic_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_FIL_DBG
#define FIL_DBG(s)
#else
#define FIL_DBG(s)	if (RISfil_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_INT_DBG
#define INT_DBG(s)
#else
#define INT_DBG(s)	if (RISint_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_JMP_DBG
#define JMP_DBG(s)
#else
#define JMP_DBG(s)	if (RISjmp_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_PAR_DBG
#define PAR_DBG(s)
#else
#define PAR_DBG(s)	if (RISpar_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_SQL_DBG
#define SQL_DBG(s)
#else
#define SQL_DBG(s)	if (RISsql_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_SRV_DBG
#define SRV_DBG(s)
#else
#define SRV_DBG(s)	if (RISsrv_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_STMT_DBG
#define STMT_DBG(s)
#else
#define STMT_DBG(s)	if (RISstmt_debug){RIScom_output_debug s;}
#endif

#ifdef NO_TREE_DBG
#define TREE_DBG(s)
#else
#define TREE_DBG(s)	if (RIStree_debug){RIScom_output_debug s;}
#endif

#ifdef NO_TRN_DBG
#define TRN_DBG(s)
#else
#define TRN_DBG(s)	if (RIStrn_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_USR_DBG
#define USR_DBG(s)
#else
#define USR_DBG(s)	if (RISusr_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_TCPSRV_DBG
#define TCPSRV_DBG(s)
#else
#define TCPSRV_DBG(s)	if (RIStcpsrv_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_CPP_DBG
#define CPP_DBG(s)
#else
#define CPP_DBG(s)	if (RIScpp_debug) {RIScom_output_debug s;}
#endif

#ifdef NO_UPG_DBG
#define UPG_DBG(s)
#else
#define UPG_DBG(s)  if (RISupg_debug) {RIScom_output_debug s;}
#endif

#if defined(WIN32)
#ifdef NO_ODBC_DBG
#define ODBC_DBG(s)
#else
#define ODBC_DBG(s)	if (RISodbc_debug) {RIScom_output_debug s;}
#endif
#endif

/* debug bit masks */
#define REMOTE_BIT		        0x00000001
#define UPGRADE_BIT		        0x00000002
#define UPG_DBG_BIT                     0x00000004

#define ARC_DBG_BIT			0x00000010
#define NET_DBG_BIT			0x00000020

#define APP_DBG_BIT			0x00000100
#define BUF_DBG_BIT			0x00000200
#define CLI_DBG_BIT			0x00000400
#define COM_DBG_BIT			0x00000800
#define DBS_DBG_BIT			0x00001000
#define DDS_DBG_BIT			0x00002000
#define DIC_DBG_BIT			0x00004000
#define FIL_DBG_BIT			0x00008000
#define INT_DBG_BIT			0x00010000
#define JMP_DBG_BIT			0x00020000
#define PAR_DBG_BIT			0x00040000
#define SQL_DBG_BIT			0x00080000
#define SRV_DBG_BIT			0x00100000
#define STMT_DBG_BIT		        0x00200000
#define TREE_DBG_BIT		        0x00400000
#define TRN_DBG_BIT			0x00800000
#define USR_DBG_BIT			0x01000000
#define CCO_DBG_BIT			0x02000000
#define TCPSRV_DBG_BIT		        0x04000000
#define CPP_DBG_BIT			0x08000000
#if defined(WIN32)
#define ODBC_DBG_BIT		        0x10000000
#endif
#define CLNSR_BIT                       0x20000000

/* Modes for RIScom_debug_mask_to_flags() */
#define SET_ONLY	0
#define SET_AND_CLEAR	1

#ifndef STRING
#define STRING(s)	((s)?(s):"NULL")
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/* Misc. flags */

COM_EXTERN  int	RIS_remote_test;
COM_EXTERN  int RIS_upgrade_flag;
COM_EXTERN  int RIS_clnsr_flag;

/* Debug flags */

COM_EXTERN  int	RISapp_debug;
COM_EXTERN  int	RISbuf_debug;
COM_EXTERN  int	RIScco_debug;
COM_EXTERN  int	RIScli_debug;
COM_EXTERN  int	RIScom_debug;
COM_EXTERN  int	RISdbs_debug;
COM_EXTERN  int	RISdds_debug;
COM_EXTERN  int	RISdic_debug;
COM_EXTERN  int	RISfil_debug;
COM_EXTERN  int	RISint_debug;
COM_EXTERN  int	RISjmp_debug;
COM_EXTERN  int	RISpar_debug;
COM_EXTERN  int	RISsql_debug;
COM_EXTERN  int	RISsrv_debug;
COM_EXTERN  int	RISstmt_debug;
COM_EXTERN  int	RIStree_debug;
COM_EXTERN  int	RIStrn_debug;
COM_EXTERN  int	RISusr_debug;
COM_EXTERN  int	RIStcpsrv_debug;
COM_EXTERN  int	RIScpp_debug;
COM_EXTERN  int  RISupg_debug;
#if defined(WIN32)
COM_EXTERN  int	RISodbc_debug;
#endif

#endif

/*
**	NAME:							dldint.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	DEFINES
*/
#if defined(unix) || defined(DOS)
#endif
#if defined(WIN32)
//For NT on currently
#define VERSION_4_ONLY
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdarg.h> 
#if defined(unix)
#if defined(VERSION_4_ONLY)
#include "xc/dload.h"
#endif
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#endif
#include "risapi.h"
#include "risver.h"
#include "dload.h"

/*
**	FUNCTION PROTOTYPES
*/
#define dldint_c
#if defined(VERSION_4_ONLY)
#include "dldmain.prt"
#include "dlderror.prt"
#include "dldgtdir.prt"
#include "sys.prt"
#else
#include "sys.prt"
#include "intatod.prt"
#include "intcksum.prt"
#include "intclear.prt"
#include "intclose.prt"
#include "intdebug.prt"
#include "intdscrb.prt"
#include "intdtoa.prt"
#include "interror.prt"
#include "intexec.prt"
#include "inteximm.prt"
#include "intfetch.prt"
#include "intgetss.prt"
#include "intglerr.prt"
#include "intgtasy.prt"
#include "intgtfil.prt"
#include "intgtflg.prt"
#include "intgtlng.prt"
#include "intgtnme.prt"
#include "intgtpcl.prt"
#include "intgtprm.prt"
#include "intgttrn.prt"
#include "intgtver.prt"
#include "intinit.prt"
#include "intlocfl.prt"
#include "intlocli.prt"
#include "intparms.prt"
#include "intprep.prt"
#include "intrperr.prt"
#include "intshapp.prt"
#include "intshcli.prt"
#include "intslct.prt"
#include "intsmgr.prt"
#include "intsserr.prt"
#include "intterm.prt"
#include "inttest.prt"
#include "inttypes.prt"
#endif
#if defined(WIN32)
#include "dlddebug.prt"
#endif

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern char *RISascii_to_datetime(
	datetime *date,
	char *buffer,
	char *format)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_ascii_to_datetime)
					(date,buffer,format));
#else
	return((char *) RISXascii_to_datetime
					(date,buffer,format));
#endif
}

/******************************************************************************/

extern void RISrestore_schema_file_checksum(
	void) 
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_restore_schema_file_checksum)();
#else
	RISXrestore_schema_file_checksum();
#endif
}

/******************************************************************************/

extern void RISint_clear(
	short *stmt_id,
	int *async_id,
	unsigned char execute_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_clear)(stmt_id,async_id,execute_mode);
#else
	RISXint_clear(stmt_id,async_id,execute_mode);
#endif
}

/******************************************************************************/

extern void RISint_clear_async(
	int *async_id)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_clear_async)(async_id);
#else
	RISXint_clear_async(async_id);
#endif
}

/******************************************************************************/
 
extern void RISint_close(
	short stmt_id,
	int *async_id,
	unsigned char execute_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_close)(stmt_id,async_id,execute_mode);
#else
	RISXint_close(stmt_id,async_id,execute_mode);
#endif
}

/******************************************************************************/
 
extern void RISint_process_debug(
	char *s)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_process_debug)(s);
#else
	RISXint_process_debug(s);
#endif
}

/******************************************************************************/
 
extern void RISint_process_debug_noRAP(
	char *s)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_process_debug_noRAP)(s);
#else
	RISXint_process_debug_noRAP(s);
#endif
}

/******************************************************************************/

extern void RISint_process_debug_no_output(
	char *s)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_process_debug_no_output)(s);
#else
	RISXint_process_debug_no_output(s);
#endif
}

/******************************************************************************/

extern void RISint_process_debug_no_output_noRAP(
	char *s)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_process_debug_no_output_noRAP)(s);
#else
	RISXint_process_debug_no_output_noRAP(s);
#endif
}

/******************************************************************************/
 
extern void RISint_describe(
	short stmt_id,
	sqlda *data,
	int in_out)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_describe)(stmt_id,data,in_out);
#else
	RISXint_describe(stmt_id,data,in_out);
#endif
}

/******************************************************************************/
 
extern int RISdatetime_to_ascii(
	datetime *date,
	char *buffer,
	char *format)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_datetime_to_ascii)(date,buffer,format));
#else
	return(RISXdatetime_to_ascii(date,buffer,format));
#endif
}

/******************************************************************************/
 
extern int RISint_error_msg(
	int errcode,
	char *buf,
	char *errname)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(0);
	} 
	return(FUNCTION_ADDRESS(DLD_int_error_msg)(errcode,buf,errname));
#else
	return(RISXint_error_msg(errcode,buf,errname));
#endif
}

/******************************************************************************/

extern void RISint_term_error_msg()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_term_error_msg)();
#else
	RISXint_term_error_msg();
#endif
}

/******************************************************************************/

extern void RISint_set_error(
	int status)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_set_error)(status);
#else
	RISXint_set_error(status);
#endif
}

/******************************************************************************/

extern void RISint_clear_error()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_clear_error)();
#else
	RISXint_clear_error();
#endif
}

/******************************************************************************/
 
extern void RISint_execute(
	short *stmt_id,
	int *async_id,
	sqlda *in_sqlda,
	unsigned char execute_mode,
	int clear_flag,
	int static_flag)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_execute)
		(stmt_id,async_id,in_sqlda,execute_mode,clear_flag,static_flag);
#else
	RISXint_execute
		(stmt_id,async_id,in_sqlda,execute_mode,clear_flag,static_flag);
#endif
}

/******************************************************************************/
 
extern void RISint_execute_immediate(
	short *stmt_id,
	int *async_id,
	char *query,
	sqlda *in_sqlda,
	int execute_mode,
	int clear_flag,
	int static_flag)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_execute_immediate)
		(stmt_id,async_id,query,in_sqlda,execute_mode,clear_flag,static_flag);
#else
	RISXint_execute_immediate
		(stmt_id,async_id,query,in_sqlda,execute_mode,clear_flag,static_flag);
#endif
}

/******************************************************************************/
 
extern void RISint_fetch(
	short stmt_id,
	int *async_id,
	sqlda *output,
	int one_row_only,
	unsigned char execute_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_fetch)
		(stmt_id,async_id,output,one_row_only,execute_mode);
#else
	RISXint_fetch
		(stmt_id,async_id,output,one_row_only,execute_mode);
#endif
}

/******************************************************************************/
 
extern void RISget_superschema_names(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_superschema_names)(buffer,countp);
#else
	RISXget_superschema_names(buffer,countp);
#endif
}

/******************************************************************************/

extern void RISget_superschema_definition(
	char *ss_name,
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_superschema_definition)(ss_name,buffer,countp);
#else
	RISXget_superschema_definition(ss_name,buffer,countp);
#endif
}

/******************************************************************************/
 
extern void RISget_async_stmts(
	int *buffer,
	int *countp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_async_stmts)(buffer,countp);
#else
	RISXget_async_stmts(buffer,countp);
#endif
}

/******************************************************************************/
 
extern void RISget_schema_info(
	char *schname,
	ris_schema_info **schemap,
	ris_db_info **dbp,
	ris_grantee_info **granteep)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_schema_info)(schname,schemap,dbp,granteep);
#else
	RISXget_schema_info(schname,schemap,dbp,granteep);
#endif
}

/******************************************************************************/

extern void RISget_db_info(
	int dbid,
	ris_db_info **dbp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_db_info)(dbid,dbp);
#else
	RISXget_db_info(dbid,dbp);
#endif
}

/******************************************************************************/

extern void RISget_schema_file(
	char **schema_filenamep,
	ris_db_info **dblistp,
	ris_schema_info **schlistp,
	ris_grantee_info **granteep)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_schema_file)
		(schema_filenamep,dblistp,schlistp,granteep);
#else
	RISXget_schema_file
		(schema_filenamep,dblistp,schlistp,granteep);
#endif
}

/******************************************************************************/
 
extern void RISint_get_flags(
	int *ansi_mode,
	int *enable_dbms,
	int *verify_mode,
	int *blankstrip_mode,
	int *autocommit,
	int *autorename)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_get_flags)
		(ansi_mode,enable_dbms,verify_mode,blankstrip_mode, autocommit, autorename);
#else
	RISXint_get_flags
		(ansi_mode,enable_dbms,verify_mode,blankstrip_mode, autocommit, autorename);
#endif
}

/******************************************************************************/

extern void RISint_upgrade_parms_file()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_upgrade_parms_file)();
#else
	RISXint_upgrade_parms_file();
#endif
}

/******************************************************************************/

extern void RISget_ansi_mode(
	int *ansi_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_ansi_mode)(ansi_mode);
#else
	RISXget_ansi_mode(ansi_mode);
#endif
}

/******************************************************************************/

extern void RISget_enabled_databases(
	int *enable_dbms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_enabled_databases)(enable_dbms);
#else
	RISXget_enabled_databases(enable_dbms);
#endif
}

/******************************************************************************/

extern void RISget_verify_mode(
	int *verify_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_verify_mode)(verify_mode);
#else
	RISXget_verify_mode(verify_mode);
#endif
}

/******************************************************************************/

extern void RISget_blankstrip_mode(
	int *blankstrip_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_blankstrip_mode)(blankstrip_mode);
#else
	RISXget_blankstrip_mode(blankstrip_mode);
#endif
}

/******************************************************************************/

extern void RISget_autocommit_mode(
	int *autocommit)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_autocommit_mode)(autocommit);
#else
	RISXget_autocommit_mode(autocommit);
#endif
}

/******************************************************************************/

extern void RISget_autorename_mode(
	int *autorename)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_autorename_mode)(autorename);
#else
	RISXget_autorename_mode(autorename);
#endif
}

/******************************************************************************/
 
extern void RISget_schema_names(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_schema_names)(buffer,countp);
#else
	RISXget_schema_names(buffer,countp);
#endif
}

/******************************************************************************/

extern void RISget_default_schema_name(
	char buffer[RIS_MAX_ID_SIZE])
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_default_schema_name)(buffer);
#else
	RISXget_default_schema_name(buffer);
#endif
}

/******************************************************************************/

extern void RISget_current_stmt_schema_name(
	char buffer[RIS_MAX_ID_SIZE])
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_current_stmt_schema_name)(buffer);
#else
	RISXget_current_stmt_schema_name(buffer);
#endif
}

/******************************************************************************/
 
extern void RISget_parameters(
	ris_parameters *parameters)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_parameters)(parameters);
#else
	RISXget_parameters(parameters);
#endif
}

/******************************************************************************/
 
extern void RISget_schema_transactions(
	char (*buffer)[RIS_MAX_ID_SIZE],
	int *countp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_schema_transactions)(buffer,countp);
#else
	RISXget_schema_transactions(buffer,countp);
#endif
}

/******************************************************************************/
 
extern void RISget_app_version(
	int *maj,
	int *min,
	int *rel)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_app_version)(maj,min,rel);
#else
	RISXget_app_version(maj,min,rel);
#endif
}

/******************************************************************************/
 
extern void RISinitialize(
	char *language_name)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_initialize)(language_name);
#else
	RISXinitialize(language_name);
#endif
}

/******************************************************************************/

extern void RISstart_client(
	void) 
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_start_client)();
#else
	RISXstart_client();
#endif
}

/******************************************************************************/
 
extern void RISlocate_schema_file(
	schema_file_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_locate_schema_file)(parms);
#else
	RISXlocate_schema_file(parms);
#endif
}

/******************************************************************************/

extern void RISget_schema_file_location(
	schema_file_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_schema_file_location)(parms);
#else
	RISXget_schema_file_location(parms);
#endif
}

/******************************************************************************/
 
extern void RISlocate_client(
	client_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_locate_client)(parms);
#else
	RISXlocate_client(parms);
#endif
}

/******************************************************************************/

extern void RISget_client_location(
	client_parms *parms)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_client_location)(parms);
#else
	RISXget_client_location(parms);
#endif
}

/******************************************************************************/
 
extern void RISint_prepare(
	short *stmt_id,
	char *query,
	int clear_flag,
	int static_flag)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_prepare)(stmt_id,query,clear_flag,static_flag);
#else
	RISXint_prepare(stmt_id,query,clear_flag,static_flag);
#endif
}

/******************************************************************************/
 
extern void RISint_report_error(
	int *async_id,
	char **ptrp)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		RISdld_report_error(ptrp);
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_report_error)(async_id,ptrp);
#else
	RISXint_report_error(async_id,ptrp);
#endif
}

/******************************************************************************/
 
extern void RISint_show_app_memory(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_app_memory)(output_func);
#else
	RISXint_show_app_memory(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_app_stmts(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_app_stmts)(output_func);
#else
	RISXint_show_app_stmts(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_async_stmts(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_async_stmts)(output_func);
#else
	RISXint_show_async_stmts(output_func);
#endif
}

/******************************************************************************/
 
extern void RISint_show_cli_memory(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_cli_memory)(output_func);
#else
	RISXint_show_cli_memory(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_cli_stmts(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_cli_stmts)(output_func);
#else
	RISXint_show_cli_stmts(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_cli_hash_table(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_cli_hash_table)(output_func);
#else
	RISXint_show_cli_hash_table(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_cli_servers(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_cli_servers)(output_func);
#else
	RISXint_show_cli_servers(output_func);
#endif
}

/******************************************************************************/

extern void RISint_show_cli_struct_mgrs(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_show_cli_struct_mgrs)(output_func);
#else
	RISXint_show_cli_struct_mgrs(output_func);
#endif
}

/******************************************************************************/
 
extern void RISint_select(
	short *stmt_id,
	int *async_id,
	char *query,
	sqlda *in_sqlda,
	sqlda *out_sqlda,
	unsigned char execute_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_select)
		(stmt_id,async_id,query,in_sqlda,out_sqlda,execute_mode);
#else
	RISXint_select
		(stmt_id,async_id,query,in_sqlda,out_sqlda,execute_mode);
#endif
}

/******************************************************************************/
 
extern void RISint_schema_mgr(
	char mode,
	char *data,
	char *str)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_schema_mgr)(mode,data,str);
#else
	RISXint_schema_mgr(mode,data,str);
#endif
}

/******************************************************************************/
 
extern void RISint_report_superschema_error(
	char *ss_name)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_report_superschema_error)(ss_name);
#else
	RISXint_report_superschema_error(ss_name);
#endif
}

/******************************************************************************/
 
extern void RISterminate(
	void) 
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_terminate)();
#else
	RISXterminate();
#endif
}

/******************************************************************************/

extern void RISstop_client(
	void) 
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_stop_client)();
#else
	RISXstop_client();
#endif
}

/******************************************************************************/
 
extern void RISint_test_completion(
	sqlda *desc,
	int wait_flag)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_test_completion)(desc,wait_flag);
#else
	RISXint_test_completion(desc,wait_flag);
#endif
}

/******************************************************************************/

extern void RISint_get_debug_flags(
	char *s)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_get_debug_flags)(s);
#else
	RISXint_get_debug_flags(s);
#endif
}

/******************************************************************************/

extern void RISint_set_sqlcode(
	int status)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_set_sqlcode)(status);
#else
	RISXint_set_sqlcode(status);
#endif
}

/******************************************************************************/

extern int RISget_sqlcode()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_get_sqlcode)());
#else
	return(RISXget_sqlcode());
#endif
}

/******************************************************************************/

extern rissqlca *RISget_risca()
{
#if defined(VERSION_4_ONLY)
	static rissqlca risca;
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		risca.sqlcode = RIS_E_DYNAMIC_LOADING_FAILED;
		strcpy(risca.sqlerrm.sqlerrmc,
			"Dynamic Loading of RIS objects/DLL has failed.");
		risca.sqlerrm.sqlerrml = 
			strlen("Dynamic Loading of RIS objects/DLL has failed.");
		risca.sqlstmt = NULL;
		return((rissqlca *)&risca);
	} 
	return((rissqlca *)FUNCTION_ADDRESS(DLD_get_risca)());
#else
	return((rissqlca *)RISXget_risca());
#endif
}

/******************************************************************************/

extern rissqlca *RISget_dbca()
{
#if defined(VERSION_4_ONLY)
	static rissqlca dbca;
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		dbca.sqlcode = RIS_E_DYNAMIC_LOADING_FAILED;
		strcpy(dbca.sqlerrm.sqlerrmc,
			"Dynamic Loading of RIS objects/DLL has failed.");
		dbca.sqlerrm.sqlerrml = 
			strlen("Dynamic Loading of RIS objects/DLL has failed.");
		dbca.sqlstmt = NULL;
		return((rissqlca *)&dbca);
	} 
	return((rissqlca *)FUNCTION_ADDRESS(DLD_get_dbca)());
#else
	return((rissqlca *)RISXget_dbca());
#endif
}

/******************************************************************************/

extern ris_superschema_error_info *RISget_superschema_error()
{
#if defined(VERSION_4_ONLY)
	int    i;
	static ris_superschema_error_info super_schema_error;
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		super_schema_error.primary.schname[0] = '\0';
		/* risca */
		super_schema_error.primary.schrisca.sqlcode = RIS_E_DYNAMIC_LOADING_FAILED;
		strcpy(super_schema_error.primary.schrisca.sqlerrm.sqlerrmc,
			"Dynamic Loading of RIS objects/DLL has failed.");
		super_schema_error.primary.schrisca.sqlerrm.sqlerrml = 
			strlen("Dynamic Loading of RIS objects/DLL has failed.");
		super_schema_error.primary.schrisca.sqlstmt = NULL;
		/* dbca */
		super_schema_error.primary.schdbca.sqlcode = RIS_E_DYNAMIC_LOADING_FAILED;
		strcpy(super_schema_error.primary.schdbca.sqlerrm.sqlerrmc,
			"Dynamic Loading of RIS objects/DLL has failed.");
		super_schema_error.primary.schdbca.sqlerrm.sqlerrml = 
			strlen("Dynamic Loading of RIS objects/DLL has failed.");
		super_schema_error.primary.schdbca.sqlstmt = NULL;
		for( i = 0; i < 9; i++ )
		{
			super_schema_error.secondary[i].schname[0] = '\0';
			/* risca */
			super_schema_error.secondary[i].schrisca.sqlcode = 
				RIS_E_DYNAMIC_LOADING_FAILED;
			strcpy(super_schema_error.secondary[i].schrisca.sqlerrm.sqlerrmc,
				"Dynamic Loading of RIS objects/DLL has failed.");
			super_schema_error.secondary[i].schrisca.sqlerrm.sqlerrml = 
			strlen("Dynamic Loading of RIS objects/DLL has failed.");
			super_schema_error.secondary[i].schrisca.sqlstmt = NULL;
			/* dbca */
			super_schema_error.secondary[i].schdbca.sqlcode = 
				RIS_E_DYNAMIC_LOADING_FAILED;
			strcpy(super_schema_error.secondary[i].schdbca.sqlerrm.sqlerrmc,
				"Dynamic Loading of RIS objects/DLL has failed.");
			super_schema_error.secondary[i].schdbca.sqlerrm.sqlerrml = 
				strlen("Dynamic Loading of RIS objects/DLL has failed.");
			super_schema_error.secondary[i].schdbca.sqlstmt = NULL;
		}
		return((ris_superschema_error_info *)&super_schema_error);
	} 
	return((ris_superschema_error_info *)
		FUNCTION_ADDRESS(DLD_get_superschema_error)());
#else
	return((ris_superschema_error_info *)
		RISXget_superschema_error());
#endif
}

/******************************************************************************/

extern int RISget_superschema_warning()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_get_superschema_warning)());
#else
	return(RISXget_superschema_warning());
#endif
}

/******************************************************************************/

extern void RISint_get_language_code(
	int *code)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_get_language_code)(code);
#else
	RISXint_get_language_code(code);
#endif
}

/******************************************************************************/

extern void RISget_language_name(
	char *name)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_language_name)(name);
#else
	RISXget_language_name(name);
#endif
}

/******************************************************************************/

extern void RISint_get_client_addresses(
	char *xns_addr,
	char *tcp_addr,
	char *lu62_addr,
	char *dnp_addr)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_int_get_client_addresses)
		(xns_addr,tcp_addr,lu62_addr,dnp_addr);
#else
	RISXint_get_client_addresses
		(xns_addr,tcp_addr,lu62_addr,dnp_addr);
#endif
}

/******************************************************************************/

extern void RISget_ris_sqltype_code(
	int  *code,
	char *str)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_ris_sqltype_code)(code,str);
#else
	RISXget_ris_sqltype_code(code,str);
#endif
}

/******************************************************************************/

extern void RISget_ris_sqltype_string(
	char *str,
	int  code)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_get_ris_sqltype_string)(str,code);
#else
	RISXget_ris_sqltype_string(str,code);
#endif
}

/******************************************************************************/

extern int RISload_dll()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return -1;
	} 
	return 0;
#else
	return 0;
#endif
}

/******************************************************************************/

extern void RISfree_memory(
	int type,
	...)
{
	va_list	args;

	va_start(args, type);
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_free_memory)(type, args);
#else
	RISXfree_memory(type, args);
#endif
	va_end(args);
}

/*****************************************************************************

	SYNOPSIS 

	extern void RISfree_memory_malloc(
		int	type,
		...)
        
    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----            --------------------------------------------------------

        type		(I)	Type of RIS structure to free:
					RIS_FREE_SCHEMA_INFO_MEMORY (from RISget_schema_info)
					RIS_FREE_DB_INFO_MEMORY (from RISget_db_info)
					RIS_FREE_SCHEMA_FILE_MEMORY (from RISget_schema_file)
					RIS_FREE_REPORT_ERROR_MEMORY
        ...		(I)	Variable list of thing[s] to free.  Pass NULL
				if the structure or string was not allocated.
					RIS_FREE_SCHEMA_INFO_MEMORY:
						ris_schema_info*
						ris_db_info*
						ris_grantee_info*
					RIS_FREE_DB_INFO_MEMORY:
						ris_db_info*
					RIS_FREE_SCHEMA_FILE_MEMORY:
						char*
						ris_db_info*
						ris_schema_info*
						ris_grantee_info*
					RIS_FREE_REPORT_ERROR_MEMORY:
						char*
        
    RETURN VALUE

	void
        
    DESCRIPTION

	This function frees several different types of RIS structures and
	strings in cases where the memory was malloc'ed.
        
    CHANGE HISTORY

        1996.09.17	See RISfree_memory_extended in
			risapp\intrface\intgtfil.c.  (TR439601965)  (Alan
			Barksdale)

******************************************************************************/

extern void RISfree_memory_malloc(
	int type,
	...)
{
	va_list	args;

	va_start(args, type);
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_free_memory_malloc)(type, args);
#else
	RISXfree_memory_malloc(type, args);
#endif
	va_end(args);
}

/******************************************************************************/


extern int RISlicense_bypass(
           char *pass_number)
{
           int number1 = 0,number2 = 0,number3 = 0;

           int i;

           char license_key[40];


           /* Generate bypass keys on the fly   */
           /* No need to go through all of them */
           /* jet when we get a hit             */

           for (i=0; i < 100; i++)		
             {				        
                  number1 = (300 + 30000 + 30000 + 300000 + (534 + (i*i) * 4));
                  number2 = (20 + 200 + 20000 + 200000 + (222 + (i*i) * 6));
                  number3 = (40 + 400 + 40000 + 400000 + (444 + (i*i) * 10));

                  sprintf(license_key,"%x%ob%08x",number1,number2,number3); 


                  if (strcmp(pass_number,license_key) == 0)
                     {
#if defined(VERSION_4_ONLY)
	                 if( RISdld_is_dload_done() ) 
	                   { 
		              SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		              return -1;
	                   } 
	                 FUNCTION_ADDRESS(DLD_setbypass)();
	                 return(0);
#else
                         RISXsetbypass();
                         return(0);
#endif
                     } 
              }

            return(-1); 
      
}

/********************************************************************************/


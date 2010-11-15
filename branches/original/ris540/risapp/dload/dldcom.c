/* Do not alter this SPC information: $Revision: 1.4.4.1 $ */
/*
**	NAME:							dldcom.c
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
#include <wchar.h>
#endif
#if defined(DOS)
#endif
#include "risapi.h"
#include "risver.h"
#include "risstjmp.h"
#include "risrap.h"
#include "dload.h"

/*
**	FUNCTION PROTOTYPES
*/
#define dldcom_c
#if defined(VERSION_4_ONLY)
#include "dldmain.prt"
#include "dlderror.prt"
#include "dldgtdir.prt"
#include "sys.prt"
#else
#include "comdll.prt"
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

extern void RIScom_clear_sqlca(
    rissqlca *sqlca)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_clear_sqlca)(sqlca);
#else
	RISXcom_clear_sqlca(sqlca);
#endif
}

/******************************************************************************/

extern void RIScom_depd(
	char *crpt,
	char *decrpt)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;	
	} 
	FUNCTION_ADDRESS(DLD_com_depd)(crpt,decrpt);
#else
	RISXcom_depd(crpt,decrpt);
#endif
}

/******************************************************************************/

extern char *RIScom_error_code(
	int errcode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_error_code)(errcode));
#else
	return((char *) RISXcom_error_code(errcode));
#endif
}

/******************************************************************************/

extern int RIScom_fclose(
	FILE *stream)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(EOF);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_fclose)(stream));
#else
	return((int) RISXcom_fclose(stream));
#endif
}

/******************************************************************************/

extern char *RIScom_fgets(
	char *st,
	int n,
	FILE *fd)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) NULL);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_fgets)(st,n,fd));
#else
	return((char *) RISXcom_fgets(st,n,fd));
#endif
}

/******************************************************************************/

extern FILE *RIScom_fopen(
	char *fname,
	char *type)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((FILE *) NULL);
	} 
	return((FILE *) FUNCTION_ADDRESS(DLD_com_fopen)(fname,type));
#else
	return((FILE *) RISXcom_fopen(fname,type));
#endif
}

/******************************************************************************/

extern void RIScom_generate_local_exe_path(
	char *path,
	char *risdir,
	int development,
	char *subdir,
	char *exe)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_generate_local_exe_path)
		(path,risdir,development,subdir,exe);
#else
	RISXcom_generate_local_exe_path
		(path,risdir,development,subdir,exe);
#endif
}

/******************************************************************************/

extern char *RIScom_get_execute_mode_name(
	unsigned char execute_mode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_get_execute_mode_name)
					(execute_mode));
#else
	return((char *) RISXcom_get_execute_mode_name
					(execute_mode));
#endif
}

/******************************************************************************/

extern void RIScom_get_output_device_name(
	char *input,
	char *output_device)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_get_output_device_name)(input,output_device);
#else
	RISXcom_get_output_device_name(input,output_device);
#endif
}

/******************************************************************************/

extern int RIScom_get_risdir(
	char *prodname,
	int version_maj,
	int version_min,
	int version_rel,
	int mode,
	char *risdir_file,
	char *config_file,
	char *risdir,
	int *developmentp,
	rissqlca *dbcap)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_get_risdir)
		(prodname,version_maj,version_min,version_rel,mode,risdir_file,
		config_file,risdir,developmentp,dbcap));
#else
	return((int) RISXcom_get_risdir
		(prodname,version_maj,version_min,version_rel,mode,risdir_file,
		config_file,risdir,developmentp,dbcap));
#endif
}

/******************************************************************************/

extern int RIScom_init_ums_msg(
    int     file_type,
    char    *dir,
    int     development,
    char    *lang_name)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_init_ums_msg)
		(file_type,dir,development,lang_name));
#else
	return((int) RISXcom_init_ums_msg
		(file_type,dir,development,lang_name));
#endif
}

/******************************************************************************/

extern int RIScom_isalpha(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_isalpha)(c));
#else
	return((int) RISXcom_isalpha(c));
#endif
}

/******************************************************************************/

extern int RIScom_isdigit(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_isdigit)(c));
#else
	return((int) RISXcom_isdigit(c));
#endif
}
/******************************************************************************/

extern int RIScom_islower(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_islower)(c));
#else
	return((int) RISXcom_islower(c));
#endif
}
/******************************************************************************/

extern int RIScom_isspace(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_isspace)(c));
#else
	return((int) RISXcom_isspace(c));
#endif
}

/******************************************************************************/

extern int RIScom_isupper(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_isupper)(c));
#else
	return((int) RISXcom_isupper(c));
#endif
}

/******************************************************************************/

extern void RIScom_longjmp(
	int st,
	char *file,
	int line)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_longjmp)(st,file,line);
#else
	RISXcom_longjmp(st,file,line);
#endif
}
/******************************************************************************/

extern int RIScom_lower_strcpy(
	char * dst,
	char * src)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_lower_strcpy)(dst,src));
#else
	return((int) RISXcom_lower_strcpy(dst,src));
#endif
}
/******************************************************************************/

extern void RIScom_output_db_info(
	int (* output_func)(const char *, ...),
	void *ptr,
	int indent)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_output_db_info)(output_func,ptr,indent);
#else
	RISXcom_output_db_info(output_func,ptr,indent);
#endif
}
/******************************************************************************/

extern int RIScom_output_debug(
	const char *fmt,
	...) 
{
	int		status;
	va_list args;

#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	va_start(args, fmt);
	status = FUNCTION_ADDRESS(DLD_com_voutput_debug)(fmt, args);
	va_end(args);
#else
	va_start(args, fmt);
	status = RISXcom_voutput_debug(fmt, args);
	va_end(args);
#endif
	return(status);
}

/******************************************************************************/

extern void RIScom_output_debug_flags(
	int (* output_func)(const char *, ...))
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_output_debug_flags)(output_func);
#else
	RISXcom_output_debug_flags(output_func);
#endif
}

/******************************************************************************/

extern void RIScom_output_schema_info(
    int             (* output_func)(const char *, ...),
    void    *ptr,
    int             indent)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_output_schema_info)(output_func,ptr,indent);
#else
	RISXcom_output_schema_info(output_func,ptr,indent);
#endif
}

/******************************************************************************/

extern void RIScom_output_sqlvar(
	int (* output_func)(const char *, ...),
	void *ptr,
	int indent)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_output_sqlvar)(output_func,ptr,indent);
#else
	RISXcom_output_sqlvar(output_func,ptr,indent);
#endif
}

/******************************************************************************/

#if defined(WIN32)
extern int RIScom_parse_command_line(
	HANDLE hInst,
	char *cline,
	char ***argv)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_parse_command_line)
					(hInst,cline,argv));
#else
	return((int) RISXcom_parse_command_line
					(hInst,cline,argv));
#endif
}
#endif

/******************************************************************************/

extern int RIScom_read_rap_file(
	ris_rap_options *rap_options,
	int expand_pid_flag)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_read_rap_file)
					(rap_options,expand_pid_flag));
#else
	return((int) RISXcom_read_rap_file
					(rap_options,expand_pid_flag));
#endif
}

/******************************************************************************/

extern void RIScom_resetjmp(
	char *file,
	int line)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_resetjmp)(file,line);
#else
	RISXcom_resetjmp(file,line);
#endif
}

/******************************************************************************/

extern char *RIScom_ris_lang_dir(
	int code)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_ris_lang_dir)(code));
#else
	return((char *) RISXcom_ris_lang_dir(code));
#endif
}

/******************************************************************************/

extern void RIScom_set_debug_output_device(
	char *output_device)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLD_com_set_debug_output_device)(output_device);
#else
	RISXcom_set_debug_output_device(output_device);
#endif
}

/******************************************************************************/

extern jmp_buf *RIScom_setjmp(
	char *file,
	int line)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((jmp_buf *) NULL);
	} 
	return((jmp_buf *) FUNCTION_ADDRESS(DLD_com_setjmp)(file,line));
#else
	return((jmp_buf *) RISXcom_setjmp(file,line));
#endif
}

/******************************************************************************/

extern int RIScom_stat(
    char *path,
    struct stat *buffer)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(EOF);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_stat)(path,buffer));
#else
	return((int) RISXcom_stat(path,buffer));
#endif
}

/******************************************************************************/

extern int RIScom_strcmp_ic(
	char *s1,
	char *s2)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_strcmp_ic)(s1,s2));
#else
	return((int) RISXcom_strcmp_ic(s1,s2));
#endif
}

/******************************************************************************/

extern int RIScom_strncmp_ic(
	char *s1,
	char *s2,
	int n)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_strncmp_ic)(s1,s2,n));
#else
	return((int) RISXcom_strncmp_ic(s1,s2,n));
#endif
}

/******************************************************************************/

extern int RIScom_strncpy(
	char *s1,
	char *s2,
	int n)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_strncpy_ic)(s1,s2,n));
#else
	return((int) RISXcom_strncpy_ic(s1,s2,n));
#endif
}

/******************************************************************************/

extern char *RIScom_substr_ic(
	char *string,
	char *substring)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) NULL);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_substr_ic)(string,substring));
#else
	return((char *) RISXcom_substr_ic(string,substring));
#endif
}

/******************************************************************************/

extern char *RIScom_tmpnam(
	char *st)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) NULL);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_tmpnam)(st));
#else
	return((char *) RISXcom_tmpnam(st));
#endif
}

/******************************************************************************/

extern int RIScom_tolower(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_tolower)(c));
#else
	return((int) RISXcom_tolower(c));
#endif
}

/******************************************************************************/

extern int RIScom_toupper(
	int c)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int) NULL);
	} 
	return((int) FUNCTION_ADDRESS(DLD_com_toupper)(c));
#else
	return((int) RISXcom_toupper(c));
#endif
}

/******************************************************************************/

extern char *RIScom_umsg(
	int errcode)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) NULL);
	} 
	return((char *) FUNCTION_ADDRESS(DLD_com_umsg)(errcode));
#else
	return((char *) RISXcom_umsg(errcode));
#endif
}

/******************************************************************************/
#if defined(WIN32)
extern int RISget_platform()
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_get_platform)());
#else
	return(RISXcom_get_platform());
#endif
}

/******************************************************************************/
extern int RIScom_multiwide(
    wchar_t **wide,
    char    **multi,
    int     *current_size,
    int     flag,
    int     num)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLD_com_multiwide)(wide,multi,current_size,flag,num));
#else
	return(RISXcom_multiwide(wide,multi,current_size,flag,num));
#endif
}
/******************************************************************************/
extern size_t RIScom_wcstombs(
        char    *multi_string,
        wchar_t *wide_string,
        int     size)
{
#if defined(VERSION_4_ONLY)
	if( RISdld_is_dload_done() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((size_t) NULL);
	} 
	return((size_t)FUNCTION_ADDRESS(DLD_com_wcstombs)(multi_string,wide_string,size));
#else
	return((size_t)RISXcom_wcstombs(multi_string,wide_string,size));
#endif
}
#endif


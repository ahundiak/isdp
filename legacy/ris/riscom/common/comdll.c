/* Do not alter this PINNACLE information: $Revision: 1.4.4.1 $ */
/*
**	NAME:							comdll.c
**	AUTHORS:						Grace Oliver
**	CREATION DATE:					8/93
**	ABSTRACT:	Wrapper for common functions which RISUTL uses in order to
**				provide exported copies and not to break RISCLI and RISSRVs
**				and RISAPP (Interface) which will continue to link with 
**				riscom objects versus using ris.dll like RISUTL must.
**
**	REVISION HISTORY:
**
**		11/94:	Added functions for INTERNATIONALIZATION.  Rick.
*/
 
/*
**	DEFINES
*/

/*
**	INCLUDES
*/
#include "risapi.h"
#if defined(WIN32)
#include <windows.h>
#include <wchar.h>
#include "risdebug.h"
#include "commacro.h"
#endif
#include "ris.h"
#include "risrap.h"

/*
**	FUNCTION PROTOTYPES
*/
#define comdll_c
#include "comsqlca.prt"
#include "compd.prt"
#include "comumsg.prt"
#include "comwrap.prt"
#include "compath.prt"
#include "comexmod.prt"
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comstrcp.prt"
#include "comoutpt.prt"
#if defined(WIN32)
#include "comparcl.prt"
#include "complat.prt"
#include "comuni.prt"
#endif
#include "comlang.prt"
#include "comstcmi.prt"
#include "comrap.prt"
#include "comsusti.prt"

#ifdef Soli
#include "sys.prt"
#endif

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*****************************************************************************/

extern void RISAPI RISXcom_clear_sqlca(
    rissqlca *sqlca)
{
	RIScom_clear_sqlca(sqlca);
}

/*****************************************************************************/

extern void RISAPI RISXcom_depd(
	char *crpt,
	char *decrpt)
{
	RIScom_depd(crpt,decrpt);
}

/*****************************************************************************/

extern char * RISAPI RISXcom_error_code(
	int errcode)
{
	return((char *) RIScom_error_code(errcode));
}

/*****************************************************************************/

extern int RISAPI RISXcom_fclose(
	FILE *stream)
{
	return((int) RIScom_fclose(stream));
}

/*****************************************************************************/

extern char * RISAPI RISXcom_fgets(
	char *st,
	int n,
	FILE *fd)
{
	return((char *) RIScom_fgets(st,n,fd));
}

/*****************************************************************************/

extern FILE * RISAPI RISXcom_fopen(
	char *fname,
	char *type)
{
	return((FILE *) RIScom_fopen(fname,type));
}

/*****************************************************************************/

extern void RISAPI RISXcom_generate_local_exe_path(
	char *path,
	char *risdir,
	int development,
	char *subdir,
	char *exe)
{
	RIScom_generate_local_exe_path
		(path,risdir,development,subdir,exe);
}

/*****************************************************************************/

extern char * RISAPI RISXcom_get_execute_mode_name(
	unsigned char execute_mode)
{
	return((char *) RIScom_get_execute_mode_name
					(execute_mode));
}

/*****************************************************************************/

extern void RISAPI RISXcom_get_output_device_name(
	char *input,
	char *output_device)
{
	RIScom_get_output_device_name(input,output_device);
}

/*****************************************************************************/

extern int RISAPI RISXcom_get_risdir(
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
	return((int) RIScom_get_risdir
		(prodname,version_maj,version_min,version_rel,mode,risdir_file,
		config_file,risdir,developmentp,dbcap));
}

/*****************************************************************************/

extern void RISAPI RISXcom_init_ums_msg(
    int     file_type,
    char    *dir,
    int     development,
    char    *lang_name)
{
	RIScom_init_ums_msg
		(file_type,dir,development,lang_name);
}

/*****************************************************************************/

extern int RISAPI RISXcom_isalpha(
	int c)
{
	return((int) RIScom_isalpha(c));
}

/*****************************************************************************/

extern int RISAPI RISXcom_isdigit(
	int c)

{
	return((int) RIScom_isdigit(c));
}
/*****************************************************************************/

extern int RISAPI RISXcom_islower(
	int c)
{
	return((int) RIScom_islower(c));
}
/*****************************************************************************/

extern int RISAPI RISXcom_isspace(
	int c)
{
	return((int) RIScom_isspace(c));
}

/*****************************************************************************/

extern int RISAPI RISXcom_isupper(
	int c)
{
	return((int) RIScom_isupper(c));
}

/*****************************************************************************/

extern void RISAPI RISXcom_longjmp(
	int st,
	char *file,
	int line)
{
	RIScom_longjmp(st,file,line);
}
/*****************************************************************************/

extern int RISAPI RISXcom_lower_strcpy(
	char * dst,
	char * src)
{
	return((int) RIScom_lower_strcpy(dst,src));
}
/*****************************************************************************/

extern void RISAPI RISXcom_output_db_info(
	int (* output_func)(const char *, ...),
	void *ptr,
	int indent)
{
	RIScom_output_db_info(output_func,ptr,indent);
}
/*****************************************************************************/

extern int RISAPI RISXcom_voutput_debug(
	const char *fmt,
	va_list		args) 
{
	return((int)RIScom_voutput_debug(fmt,args));
}

/*****************************************************************************/

extern void RISAPI RISXcom_output_debug_flags(
	int (* output_func)(const char *, ...))
{
	RIScom_output_debug_flags(output_func);
}

/*****************************************************************************/

extern void RISAPI RISXcom_output_schema_info(
    int     (* output_func)(const char *, ...),
    void    *ptr,
    int     indent)
{
	RIScom_output_schema_info(output_func,ptr,indent);
}

/*****************************************************************************/

extern void RISAPI RISXcom_output_sqlvar(
	int (* output_func)(const char *, ...),
	void *ptr,
	int indent)
{
	RIScom_output_sqlvar(output_func,ptr,indent);
}

/*****************************************************************************/

#if defined(WIN32)
extern int RISAPI RISXcom_parse_command_line(
	HANDLE hInst,
	char  *cline,
	char  ***argv)
{
	return((int) RIScom_parse_command_line
					(hInst,cline,argv));
}
#elif defined(unix) || defined(DOS) || defined (vms)

#else
ERROR -- NO CODE
#endif 


/*****************************************************************************/

extern int RISAPI RISXcom_read_rap_file(
	ris_rap_options *rap_options,
	int expand_pid_flag)
{
	return((int) RIScom_read_rap_file
			(rap_options,expand_pid_flag));
}

/*****************************************************************************/

extern void RISAPI RISXcom_resetjmp(
	char *file,
	int line)
{
	RIScom_resetjmp(file,line);
}

/*****************************************************************************/

extern char * RISAPI RISXcom_ris_lang_dir(
	int code)
{
	return((char *) RIScom_ris_lang_dir(code));
}

/*****************************************************************************/

extern void RISAPI RISXcom_set_debug_output_device(
	char *output_device)
{
	RIScom_set_debug_output_device(output_device);
}

/*****************************************************************************/

extern jmp_buf * RISAPI RISXcom_setjmp(
	char *file,
	int line)
{
	return((jmp_buf *) RIScom_setjmp(file,line));
}

/*****************************************************************************/

extern int RISAPI RISXcom_stat(
    char *path,
#if defined(WIN32)
    struct _stat *buffer)
#else
    struct stat *buffer)
#endif
{
	return((int) RIScom_stat(path,buffer));
}

/*****************************************************************************/

extern int RISAPI RISXcom_strcmp_ic(
	char *s1,
	char *s2)
{
	return((int) RIScom_strcmp_ic(s1,s2));
}

/*****************************************************************************/

extern int RISAPI RISXcom_strncmp_ic(
	char *s1,
	char *s2,
	int n)
{
	return((int) RIScom_strncmp_ic(s1,s2,n));
}
/*****************************************************************************/

extern int RISAPI RISXcom_strncpy_ic(
	char *s1,
	char *s2,
	int n)
{
	return((int) RIScom_strncpy(s1,s2,n));
}
/*****************************************************************************/

extern char * RISAPI RISXcom_substr_ic(
	char *string,
	char *substring)
{
	return((char *) RIScom_substr_ic(string,substring));
}

/*****************************************************************************/

extern char * RISAPI RISXcom_tmpnam(
	char *st)
{
	return((char *) RIScom_tmpnam(st));
}

/*****************************************************************************/

extern int RISAPI RISXcom_tolower(
	int c)
{
	return((int) RIScom_tolower(c));
}

/*****************************************************************************/

extern int RISAPI RISXcom_toupper(
	int c)
{
	return((int) RIScom_toupper(c));
}

/*****************************************************************************/

extern char * RISAPI RISXcom_umsg(
	int errcode)
{
	return((char *) RIScom_umsg(errcode));
}

/*****************************************************************************/
#if defined(WIN32)
extern int RISAPI RISXget_platform()
{
	return((int) RIScom_get_platform());
}

extern int RISAPI RISXcom_multiwide(
    wchar_t **wide,
    char    **multi,
    int     *current_size,
    int     flag,
    int     num)
{
	return ((int) RIScom_multiwide(wide,multi,current_size,flag,num));

}

extern size_t RISAPI RISXcom_wcstombs(
        char    *multi_string,
        wchar_t *wide_string,
        int     size)
{
	return ((size_t) RIScom_wcstombs(multi_string,wide_string,size));

}
#endif



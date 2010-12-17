/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */

/*
**	NAME:							dloadfrm.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 

#ifndef RIS_DLOAD_H
#define RIS_DLOAD_H

#ifdef DLD_GLOBAL_DEFINE
# define DLD_EXTERN
# define DLD_INIT(value) = value
#else
# define DLD_EXTERN extern
# define DLD_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "ris.h"
#include "rislimit.h"
#include "ris_err.h"

/*
**	DEFINES
*/

/*
** The following defines corresponds to each RIS interface call.
*/
/*EXPORTS MACRO BEGIN*/
#define DLDfrm_initialize							1
#define DLDfrm_set_pre_notification_routine	2
#define DLDfrm_set_post_notification_routine	3
#define DLDfrm_set_form_init_routine			4
#define DLDfrm_set_form_exec_routine			5
#define DLDfrm_set_error_handler_routine		6
#define DLDfrm_schema_mgr_form_displayed		7

#define DLDfrm_display_schema_mgr_form			8
#define DLDfrm_schema_info_form_displayed		9
#define DLDfrm_display_schema_info_form		10
#define DLDfrm_erase_schema_info_form			11
#define DLDfrm_create_schema_form_displayed	12
#define DLDfrm_display_create_schema_form		13
#define DLDfrm_erase_create_schema_form		14
#define DLDfrm_drop_schema_form_displayed		15
#define DLDfrm_display_drop_schema_form		16
#define DLDfrm_erase_drop_schema_form			17
#define DLDfrm_schema_definition_form_displayed	18
#define DLDfrm_display_schema_definition_form		19
#define DLDfrm_erase_schema_definition_form			20
#define DLDfrm_schpass_form_displayed			21
#define DLDfrm_display_schpass_form				22
#define DLDfrm_erase_schpass_form				23
#define DLDfrm_node_info_form_displayed		24
#define DLDfrm_display_node_info_form			25
#define DLDfrm_erase_node_info_form				26
#define DLDfrm_include_form_displayed			27
#define DLDfrm_display_include_form				28
#define DLDfrm_erase_include_form				29
#define DLDfrm_db2pass_form_displayed			30
#define DLDfrm_display_db2pass_form				31
#define DLDfrm_erase_db2pass_form				32
#define DLDfrm_data_def_form_displayed			33
#define DLDfrm_display_data_def_form			34
#define DLDfrm_erase_data_def_form				35
#define DLDfrm_table_info_form_displayed		36
#define DLDfrm_display_table_info_form			37
#define DLDfrm_erase_table_info_form			38
#define DLDfrm_create_table_form_displayed	39
#define DLDfrm_display_create_table_form		40
#define DLDfrm_erase_create_table_form			41
#define DLDfrm_drop_table_form_displayed		42
#define DLDfrm_display_drop_table_form			43
#define DLDfrm_erase_drop_table_form			44
#define DLDfrm_alter_table_form_displayed		45
#define DLDfrm_display_alter_table_form		46
#define DLDfrm_erase_alter_table_form			47
#define DLDfrm_schema_file_form_displayed		48
#define DLDfrm_display_schema_file_form		49
#define DLDfrm_erase_schema_file_form			50
#define DLDfrm_set_form_displayed				51
#define DLDfrm_display_set_form					52
#define DLDfrm_erase_set_form						53
#define DLDfrm_ris_dbs_form_displayed			54
#define DLDfrm_display_ris_dbs_form				55
#define DLDfrm_erase_ris_dbs_form				56
#define DLDfrm_get_ris_forms_error				57
#define DLDfrm_generate_error_box				58
#define DLDfrm_enable_debug_form					59
#define DLDfrm_get_RISfrm_debug_addr			60
#define DLDfrm_erase_schema_mgr_form			61
#define DLDfrm_locate_client_form_displayed	62
#define DLDfrm_display_locate_client_form		63
#define DLDfrm_erase_locate_client_form		64
#define DLDfrm_error_box		        65
#define DLDfrm_dict_access_form_displayed	66
#define DLDfrm_display_dict_access_form		67
#define DLDfrm_erase_dict_access_form		68
#define DLDfrm_schema_access_form_displayed	69
#define DLDfrm_display_schema_access_form		70
#define DLDfrm_erase_schema_access_form		71
#define DLDfrm_exclude_form_displayed			72
#define DLDfrm_display_exclude_form				73
#define DLDfrm_erase_exclude_form				74

/*EXPORTS MACRO END*/

/* DLOAD errors */
#define	RIS_COULD_NOT_GET_REGISTRY	1
#define	RIS_COULD_NOT_LOAD_RIS_DLL	2
#define	RIS_COULD_NOT_FIND_RIS_FUNC 3

#define DLOADCODE RISdldFRM_errcode	// Error Code if Dynamic Loading Fails

#define DLD_DBG(s) if(RISdldFRM_debug) {RISdldFRM_output_debug s;}

#define SET_RISCA(status) { DLOADCODE = status; }
#define RIS_RETURN() { return; }

#if defined(unix)
#define RIS_OBJECT_NAME "risforms.o" 
#endif
#if defined(WIN32)
#define RIS_OBJECT_NAME "i9risfm6.dll"
#endif

#if defined(unix)
#define DYNAMIC_LOAD_FUNCION(objects)	dload(objects, TEXTREDEF) 
#endif
#if defined(WIN32)
#define	DYNAMIC_LOAD_FUNCTION(objects)	LoadLibrary(objects)
#endif

#if defined(unix)
#define	GET_FUNCTION_ADDRESS(name) \
	(int (*)() )dload_address_lookup(name) 
#endif
#if defined(WIN32)
#define	GET_FUNCTION_ADDRESS(name) \
	GetProcAddress(handle, name)
#endif

#if defined(unix)
#define FUNCTION_ADDRESS(func) (*func_info[func].address)
#endif
#if defined(WIN32)
#define FUNCTION_ADDRESS(func) (func_info[func].address)
#endif

#ifndef STRING
#define STRING(s) ((s)?(s):"NULL")
#endif

/* Modes for RISdld_get_risdir() */
#define MATCH_MAJOR					1
#define MATCH_MAJOR_MINOR			2
#define MATCH_MAJOR_MINOR_RELEASE	3
#define MATCH_HIGHEST				4
#define MATCH_COMPATIBLE			5

#if defined(__clipper__)
# define PLATFORM "c100"
#elif  defined(__hpux__)
# define PLATFORM "hpux"
#elif defined(Soli)
# define PLATFORM "Soli"
#elif defined(__Sol2__)
# define PLATFORM "Sol2"
#elif defined(sun)
# define PLATFORM "sun"
#elif defined(sco)
# define PLATFORM "sco"
#elif defined(WIN32)
# define PLATFORM "nt"
#elif defined(DOS)
# define PLATFORM "dos"
#endif

/*
**	TYPES
*/
typedef struct func_info_s
{
	char	*name;
#if defined(unix)
	int		(*address)();
#endif
#if defined(WIN32)
	FARPROC	address;
#endif
} func_info_s;


/*
**	VARIABLES
*/

/* Variables available to applications */
DLD_EXTERN	int	RISdldFRM_errcode	DLD_INIT(RIS_SUCCESS);
DLD_EXTERN	int	RISdldFRM_debug 	DLD_INIT(0);

#endif /* RIS_DLOAD_H */

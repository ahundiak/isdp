/*
**	NAME:							dldmain.c
**	AUTHORS:						Terrence McIntyre,Rick Kramer
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		Added functions for dictionary access and secure schema access
**		two forms by Linda Wang 03/94.
**
**		changed RISfrm_error_box() so that it will access index number 68 instead
**		of DLDfrm_error_box which is set to 65.  All other forms seem to be 
**		working OK so I choose to change it here instead of forms.h to lessen
**		the chances of additional problems. This is related to a fix done for
**		TR 439600179. 
**
** 		Changed the ordering of the functions in func_info[].  The order 
** 		did not match what was in dldform.h.  I also put back RISfrm_error_box()
**		index to 65 since the reordering of the functions solved this problem also.
**		TR 439503203
** 		Ashley 4/25/96
*/

#define DLD_GLOBAL_DEFINE
/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(__clipper__) || defined(sun)
#if defined(VERSION_4_ONLY)
#include "xc/dload.h"
#endif
#endif
#if defined(WIN32)
#include <windows.h>
#endif
#if defined(DOS)
#endif
#include "risver.h"
#include "dloadfrm.h"
#include "forms.h"

/*
**	DEFINES
*/
#if defined(WIN32)
//For NT on currently
#define VERSION_4_ONLY
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define dldmain_c
#if defined(VERSION_4_ONLY)
#include "dlderror.prt"
#include "dldgtdir.prt"
#else
#endif
#include "dldmain.prt"
#if defined(WIN32)
#include "dlddebug.prt"
#endif

#include "frmaltab.prt"
#include "frmcrsch.prt"
#include "frmcrtab.prt"
#include "frmdadef.prt"
#include "frmdb2ps.prt"
#include "frmdbs.prt"
#include "frmdicac.prt"
#include "frmdrsch.prt"
#include "frmdrtab.prt"
#include "frmerror.prt"
#include "frminit.prt"
#include "frmincl.prt"
#include "frmexcl.prt"
#include "frmlocli.prt"
#include "frmnodin.prt"
#include "frmschac.prt"
#include "frmschdf.prt"
#include "frmschfl.prt"
#include "frmschin.prt"
#include "frmschmg.prt"
#include "frmschps.prt"
#include "frmset.prt"
#include "frmtabin.prt"
#include "frmutil.prt"
/*
**	VARIABLES
*/


/** Changed the ordering of the functions in the structure below.  The order 
*** did not match what was in dldform.h
*** Ashley 4/16/96
***/

#if defined(VERSION_4_ONLY)
/*STATIC STRUCT BEGIN*/
static func_info_s func_info[] = 
{
	{ 0, 0 },
	{ "RISXfrm_initialize", 0 },
	{ "RISXfrm_set_pre_notification_routine", 0 },
	{ "RISXfrm_set_post_notification_routine", 0 },
	{ "RISXfrm_set_form_init_routine", 0 },
	{ "RISXfrm_set_form_exec_routine", 0 },
	{ "RISXfrm_set_error_handler_routine", 0 },
	{ "RISXfrm_schema_mgr_form_displayed", 0 },
	{ "RISXfrm_display_schema_mgr_form", 0},
	{ "RISXfrm_schema_info_form_displayed", 0},
	{ "RISXfrm_display_schema_info_form", 0},
	{ "RISXfrm_erase_schema_info_form", 0},
	{ "RISXfrm_create_schema_form_displayed", 0},
	{ "RISXfrm_display_create_schema_form", 0},
	{ "RISXfrm_erase_create_schema_form", 0},
	{ "RISXfrm_drop_schema_form_displayed", 0},
	{ "RISXfrm_display_drop_schema_form", 0},
	{ "RISXfrm_erase_drop_schema_form", 0},
	{ "RISXfrm_schema_definition_form_displayed", 0},
	{ "RISXfrm_display_schema_definition_form", 0},
	{ "RISXfrm_erase_schema_definition_form", 0},
	{ "RISXfrm_schpass_form_displayed", 0},
	{ "RISXfrm_display_schpass_form", 0},
	{ "RISXfrm_erase_schpass_form", 0},
	{ "RISXfrm_node_info_form_displayed", 0},
	{ "RISXfrm_display_node_info_form", 0},
	{ "RISXfrm_erase_node_info_form", 0},
	{ "RISXfrm_include_form_displayed", 0},
	{ "RISXfrm_display_include_form", 0},
	{ "RISXfrm_erase_include_form", 0},
	{ "RISXfrm_db2pass_form_displayed", 0},
	{ "RISXfrm_display_db2pass_form", 0},
	{ "RISXfrm_erase_db2pass_form", 0},
	{ "RISXfrm_data_def_form_displayed", 0},
	{ "RISXfrm_display_data_def_form", 0},
	{ "RISXfrm_erase_data_def_form", 0},
	{ "RISXfrm_table_info_form_displayed", 0},
	{ "RISXfrm_display_table_info_form", 0},
	{ "RISXfrm_erase_table_info_form", 0},
	{ "RISXfrm_create_table_form_displayed", 0},
	{ "RISXfrm_display_create_table_form", 0},
	{ "RISXfrm_erase_create_table_form", 0},
	{ "RISXfrm_drop_table_form_displayed", 0},
	{ "RISXfrm_display_drop_table_form", 0},
	{ "RISXfrm_erase_drop_table_form", 0},
	{ "RISXfrm_alter_table_form_displayed", 0},
	{ "RISXfrm_display_alter_table_form", 0},
	{ "RISXfrm_erase_alter_table_form", 0},
	{ "RISXfrm_schema_file_form_displayed", 0},
	{ "RISXfrm_display_schema_file_form", 0},
	{ "RISXfrm_erase_schema_file_form", 0},
	{ "RISXfrm_set_form_displayed", 0},
	{ "RISXfrm_display_set_form", 0},
	{ "RISXfrm_erase_set_form", 0},
	{ "RISXfrm_ris_dbs_form_displayed", 0},
	{ "RISXfrm_display_ris_dbs_form", 0},
	{ "RISXfrm_erase_ris_dbs_form", 0},
	{ "RISXfrm_get_ris_forms_error", 0},
	{ "RISXfrm_generate_error_box", 0},
	{ "RISXfrm_enable_debug_form", 0},
	{ "RISXfrm_get_RISfrm_debug_addr", 0},
	{ "RISXfrm_erase_schema_mgr_form", 0},
	{ "RISXfrm_locate_client_form_displayed", 0},
	{ "RISXfrm_display_locate_client_form", 0},
	{ "RISXfrm_erase_locate_client_form", 0},
	{ "RISXfrm_error_box", 0},
	{ "RISXfrm_dict_access_form_displayed", 0},
	{ "RISXfrm_display_dict_access_form", 0},
	{ "RISXfrm_erase_dict_access_form", 0},
	{ "RISXfrm_schema_access_form_displayed", 0},
	{ "RISXfrm_display_schema_access_form", 0},
	{ "RISXfrm_erase_schema_access_form", 0},
	{ "RISXfrm_exclude_form_displayed", 0}, 
	{ "RISXfrm_display_exclude_form", 0}, 
	{ "RISXfrm_erase_exclude_form", 0}, 
};
/*STATIC STRUCT END*/

static int func_count =	sizeof(func_info)/sizeof(func_info_s); 
#endif

/*
**	FUNCTIONS
*/
#if defined(unix)
	char *handle; 
#elif defined(WIN32)
	HANDLE handle;
#endif

/******************************************************************************/

#if defined(VERSION_4_ONLY)
static int IsRISDynamicLoadDone()
{

	int 		index;
	static int	called_but_failed = 0;
	static int	dynamic_loaded = 0;
	char 		ris_objects[RIS_MAX_PATH_SIZE]; 
	char		RIS_dir[RIS_MAX_PATH_SIZE];
	int			RIS_development = 0;


	if(called_but_failed)
	{
		DLD_DBG(("IsRISDynamicLoadDone: called but failed\n"));
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	}

	if(!dynamic_loaded)
	{ 

		RISdldFRM_initialize_debug();
		if (RISdldFRM_get_risdir("RIS", RIS_version_maj, RIS_version_min, 
						RIS_version_rel, MATCH_COMPATIBLE, RIS_dir, 
						&RIS_development, 0))
		{
			called_but_failed = 1;
//			RISdldFRM_error_msg_box(RIS_COULD_NOT_GET_REGISTRY,RISDP_VERSION_STR);
			RISdldFRM_error_msg_box(RIS_COULD_NOT_GET_REGISTRY,RIS_version);
			DLD_DBG(("IsRISDynamicLoadDone: RISdldFRM_get_risdir failed\n"));
			return(RIS_E_DYNAMIC_LOADING_FAILED);
		}

		RISdldFRM_generate_path(ris_objects, RIS_dir, RIS_development);
		DLD_DBG(("IsRISDynamicLoadDone: Loading <%s>\n", STRING(ris_objects)));

		handle = DYNAMIC_LOAD_FUNCTION(ris_objects);
		if( !handle ) 
		{ 
			DLD_DBG(("IsRISDynamicLoadDone: LoadLibrary return:%d\n",
					GetLastError()));
			called_but_failed = 1;
			RISdldFRM_error_msg_box(RIS_COULD_NOT_LOAD_RIS_DLL,ris_objects);
			return(RIS_E_DYNAMIC_LOADING_FAILED); 
		} 

		DLD_DBG(("IsRISDynamicLoadDone: functions:%d\n", func_count-1));
		for( index = 1; index < func_count; index++ ) 
		{ 
			DLD_DBG(("IsRISDynamicLoadDone: func_info[%d].name = <%s>\n", 
				index, STRING(func_info[index].name)));
			func_info[index].address =  
				GET_FUNCTION_ADDRESS(func_info[index].name);
			if(!func_info[index].address) 
			{ 
#if defined(WIN32)
				FreeLibrary(handle);
#endif
				DLD_DBG(("IsRISDynamicLoadDone: GetProcAddress return:%d\n",
						GetLastError()));
				called_but_failed = 1;
				RISdldFRM_error_msg_box(RIS_COULD_NOT_FIND_RIS_FUNC,
					func_info[index].name);
				return(RIS_E_DYNAMIC_LOADING_FAILED); 
			} 
			DLD_DBG(("IsRISDynamicLoadDone: func_info[%d].address = 0x%x\n", 
				index, func_info[index].address));
		} 
		dynamic_loaded = 1; 
		DLD_DBG(("IsRISDynamicLoadDone: returning SUCCESS\n"));
		return(0);
	} 
	else
	{
		DLD_DBG(("IsRISDynamicLoadDone: already dloaded.\n"));
		return(0);
	}
}
#endif



extern int RISfrm_initialize(
	RISfrm_init_parms	*init_parms)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_initialize)(init_parms));
#else
	return RISXfrm_initialize(init_parms);
#endif
}

extern int RISfrm_set_pre_notification_routine(
	void	(*pre_notification_routine)())
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return RIS_E_DYNAMIC_LOADING_FAILED;
	} 
	return FUNCTION_ADDRESS(DLDfrm_set_pre_notification_routine)(pre_notification_routine);
#else
	return RISXfrm_set_pre_notification_routine(pre_notification_routine);
#endif
}

extern int RISfrm_set_post_notification_routine(
	void	(*post_notification_routine)())
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return RIS_E_DYNAMIC_LOADING_FAILED;
	} 
	return FUNCTION_ADDRESS(DLDfrm_set_post_notification_routine)(post_notification_routine);
#else
	return RISXfrm_set_post_notification_routine(post_notification_routine);
#endif
}

extern int RISfrm_set_form_init_routine(
	int		form_label,
	void	(*form_init_routine)())
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return RIS_E_DYNAMIC_LOADING_FAILED;
	} 
	return FUNCTION_ADDRESS(DLDfrm_set_form_init_routine)(form_label,form_init_routine);
#else
	return RISXfrm_set_form_init_routine(form_label, form_init_routine);
#endif
}

extern int RISfrm_set_form_exec_routine(
	int	form_label,
	int	(*form_exec_routine)())
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return RIS_E_DYNAMIC_LOADING_FAILED;
	} 
	return FUNCTION_ADDRESS(DLDfrm_set_form_exec_routine)(form_label,form_exec_routine);
#else
	return RISXfrm_set_form_exec_routine(form_label, form_exec_routine);
#endif
}

extern int RISfrm_set_error_handler_routine(
	int	(*error_handler_routine)())
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return RIS_E_DYNAMIC_LOADING_FAILED;
	} 
	return FUNCTION_ADDRESS(DLDfrm_set_error_handler_routine)(error_handler_routine);
#else
	return RISXfrm_set_error_handler_routine(error_handler_routine);
#endif
}

extern int RISfrm_schema_mgr_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schema_mgr_form_displayed)());
#else
	return RISXfrm_schema_mgr_form_displayed();
#endif
}

extern int RISfrm_display_schema_mgr_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schema_mgr_form)());
#else
	return RISXfrm_display_schema_mgr_form();
#endif
}

extern int RISfrm_schema_info_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schema_info_form_displayed)());
#else
	return RISXfrm_schema_info_form_displayed();
#endif
}

extern int RISfrm_display_schema_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schema_info_form)());
#else
	return RISXfrm_display_schema_info_form();
#endif
}

extern int RISfrm_erase_schema_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schema_info_form)());
#else
	return RISXfrm_erase_schema_info_form();
#endif
}

extern int RISfrm_dict_access_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_dict_access_form_displayed)());
#else
	return RISXfrm_dict_access_form_displayed();
#endif
}

extern int RISfrm_display_dict_access_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_dict_access_form)());
#else
	return RISXfrm_display_dict_access_form();
#endif
}

extern int RISfrm_erase_dict_access_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_dict_access_form)());
#else
	return RISXfrm_erase_dict_access_form();
#endif
}

extern int RISfrm_schema_access_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schema_access_form_displayed)());
#else
	return RISXfrm_schema_access_form_displayed();
#endif
}

extern int RISfrm_display_schema_access_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schema_access_form)());
#else
	return RISXfrm_display_schema_access_form();
#endif
}

extern int RISfrm_erase_schema_access_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schema_access_form)());
#else
	return RISXfrm_erase_schema_access_form();
#endif
}

extern int RISfrm_create_schema_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_create_schema_form_displayed)());
#else
	return RISXfrm_create_schema_form_displayed();
#endif
}

extern int RISfrm_display_create_schema_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_create_schema_form)());
#else
	return RISXfrm_display_create_schema_form();
#endif
}

extern int RISfrm_erase_create_schema_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_create_schema_form)());
#else
	return RISXfrm_erase_create_schema_form();
#endif
}

extern int RISfrm_drop_schema_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_drop_schema_form_displayed)());
#else
	return RISXfrm_drop_schema_form_displayed();
#endif
}

extern int RISfrm_display_drop_schema_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_drop_schema_form)());
#else
	return RISXfrm_display_drop_schema_form();
#endif
}

extern int RISfrm_erase_drop_schema_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_drop_schema_form)());
#else
	return RISXfrm_erase_drop_schema_form();
#endif
}

extern int RISfrm_schema_definition_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schema_definition_form_displayed)());
#else
	return RISXfrm_schema_definition_form_displayed();
#endif
}

extern int RISfrm_display_schema_definition_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schema_definition_form)());
#else
	return RISXfrm_display_schema_definition_form();
#endif
}

extern int RISfrm_erase_schema_definition_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schema_definition_form)());
#else
	return RISXfrm_erase_schema_definition_form();
#endif
}

extern int RISfrm_schpass_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schpass_form_displayed)());
#else
	return RISXfrm_schpass_form_displayed();
#endif
}

extern int RISfrm_display_schpass_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schpass_form)());
#else
	return RISXfrm_display_schpass_form();
#endif
}

extern int RISfrm_erase_schpass_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schpass_form)());
#else
	return RISXfrm_erase_schpass_form();
#endif
}

extern int RISfrm_node_info_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_node_info_form_displayed)());
#else
	return RISXfrm_node_info_form_displayed();
#endif
}

extern int RISfrm_display_node_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_node_info_form)());
#else
	return RISXfrm_display_node_info_form();
#endif
}

extern int RISfrm_erase_node_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_node_info_form)());
#else
	return RISXfrm_erase_node_info_form();
#endif
}

extern int RISfrm_db2pass_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_db2pass_form_displayed)());
#else
	return RISXfrm_db2pass_form_displayed();
#endif
}

extern int RISfrm_display_db2pass_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_db2pass_form)());
#else
	return RISXfrm_display_db2pass_form();
#endif
}

extern int RISfrm_erase_db2pass_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_db2pass_form)());
#else
	return RISXfrm_erase_db2pass_form();
#endif
}

extern int RISfrm_data_def_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_data_def_form_displayed)());
#else
	return RISXfrm_data_def_form_displayed();
#endif
}

extern int RISfrm_display_data_def_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_data_def_form)());
#else
	return RISXfrm_display_data_def_form();
#endif
}

extern int RISfrm_erase_data_def_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_data_def_form)());
#else
	return RISXfrm_erase_data_def_form();
#endif
}

extern int RISfrm_table_info_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_table_info_form_displayed)());
#else
	return RISXfrm_table_info_form_displayed();
#endif
}

extern int RISfrm_display_table_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_table_info_form)());
#else
	return RISXfrm_display_table_info_form();
#endif
}

extern int RISfrm_erase_table_info_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_table_info_form)());
#else
	return RISXfrm_erase_table_info_form();
#endif
}

extern int RISfrm_create_table_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_create_table_form_displayed)());
#else
	return RISXfrm_create_table_form_displayed();
#endif
}

extern int RISfrm_display_create_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_create_table_form)());
#else
	return RISXfrm_display_create_table_form();
#endif
}

extern int RISfrm_erase_create_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_create_table_form)());
#else
	return RISXfrm_erase_create_table_form();
#endif
}

extern int RISfrm_drop_table_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_drop_table_form_displayed)());
#else
	return RISXfrm_drop_table_form_displayed();
#endif
}

extern int RISfrm_display_drop_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_drop_table_form)());
#else
	return RISXfrm_display_drop_table_form();
#endif
}

extern int RISfrm_erase_drop_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_drop_table_form)());
#else
	return RISXfrm_erase_drop_table_form();
#endif
}

extern int RISfrm_alter_table_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_alter_table_form_displayed)());
#else
	return RISXfrm_alter_table_form_displayed();
#endif
}

extern int RISfrm_display_alter_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_alter_table_form)());
#else
	return RISXfrm_display_alter_table_form();
#endif
}

extern int RISfrm_erase_alter_table_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_alter_table_form)());
#else
	return RISXfrm_erase_alter_table_form();
#endif
}

extern int RISfrm_schema_file_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_schema_file_form_displayed)());
#else
	return RISXfrm_schema_file_form_displayed();
#endif
}

extern int RISfrm_display_schema_file_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_schema_file_form)());
#else
	return RISXfrm_display_schema_file_form();
#endif
}

extern int RISfrm_erase_schema_file_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schema_file_form)());
#else
	return RISXfrm_erase_schema_file_form();
#endif
}

extern int RISfrm_set_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_set_form_displayed)());
#else
	return RISXfrm_set_form_displayed();
#endif
}

extern int RISfrm_display_set_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_set_form)());
#else
	return RISXfrm_display_set_form();
#endif
}

extern int RISfrm_erase_set_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_set_form)());
#else
	return RISXfrm_erase_set_form();
#endif
}

extern int RISfrm_ris_dbs_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_ris_dbs_form_displayed)());
#else
	return RISXfrm_ris_dbs_form_displayed();
#endif
}

extern int RISfrm_display_ris_dbs_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_ris_dbs_form)());
#else
	return RISXfrm_display_ris_dbs_form();
#endif
}

extern int RISfrm_erase_ris_dbs_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_ris_dbs_form)());
#else
	return RISXfrm_erase_ris_dbs_form();
#endif
}

extern ris_forms_error_info *RISfrm_get_ris_forms_error(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		static ris_forms_error_info error;

		memset(&error, '\0', sizeof(error));
		error.error = RIS_E_DYNAMIC_LOADING_FAILED; 
		strcpy(error.error_name, "RIS_E_DYNAMIC_LOADING_FAILED"); 
		strcpy(error.error_message, 
			"Dynamic Loading of RIS Forms DLL has failed.");

		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(&error);
	} 
	return((ris_forms_error_info *)FUNCTION_ADDRESS(DLDfrm_get_ris_forms_error)());
#else
	return (ris_forms_error_info *)RISXfrm_get_ris_forms_error();
#endif
}

extern char * RISfrm_generate_error_box(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((char *) RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((char *)FUNCTION_ADDRESS(DLDfrm_generate_error_box)());
#else
	return (char *)RISXfrm_generate_error_box();
#endif
}

extern void RISfrm_enable_debug_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLDfrm_enable_debug_form)();
#else
	RISXfrm_enable_debug_form();
#endif
}

extern int * RISfrm_get_RISfrm_debug_addr(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return((int *)RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return((int *)FUNCTION_ADDRESS(DLDfrm_get_RISfrm_debug_addr)());
#else
	return (int *)RISXfrm_get_RISfrm_debug_addr();
#endif
}

extern int RISfrm_erase_schema_mgr_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_schema_mgr_form)());
#else
	return RISXfrm_erase_schema_mgr_form();
#endif
}

extern int RISfrm_locate_client_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_locate_client_form_displayed)());
#else
	return RISXfrm_locate_client_form_displayed();
#endif
}

extern int RISfrm_display_locate_client_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_locate_client_form)());
#else
	return RISXfrm_display_locate_client_form();
#endif
}

extern int RISfrm_erase_locate_client_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_locate_client_form)());
#else
	return RISXfrm_erase_locate_client_form();
#endif
}

extern int RISfrm_include_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_include_form_displayed)());
#else
	return RISXfrm_include_form_displayed();
#endif
}

extern int RISfrm_display_include_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_include_form)());
#else
	return RISXfrm_display_include_form();
#endif
}

extern int RISfrm_erase_include_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_include_form)());
#else
	return RISXfrm_erase_include_form();
#endif
}

/*
 mms - TR#439406445 *
 Comment this if statement so this functions are known in risforms.*
 #if 0
*/

extern int RISfrm_exclude_form_displayed(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_exclude_form_displayed)());
#else
	return RISXfrm_exclude_form_displayed();
#endif
}

extern int RISfrm_display_exclude_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_display_exclude_form)());
#else
	return RISXfrm_display_exclude_form();
#endif
}

extern int RISfrm_erase_exclude_form(
	void)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return(RIS_E_DYNAMIC_LOADING_FAILED);
	} 
	return(FUNCTION_ADDRESS(DLDfrm_erase_exclude_form)());
#else
	return RISXfrm_erase_exclude_form();
#endif
}

/*
 mms - TR#439406445 *
 Comment this if statement so this functions are known in risforms.*
 #endif
*/
extern void RISfrm_error_box(
	char *ptr)
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
	{ 
		SET_RISCA(RIS_E_DYNAMIC_LOADING_FAILED); 
		return;
	} 
	FUNCTION_ADDRESS(DLDfrm_error_box)(ptr);
#else
	RISXfrm_error_box(ptr);
#endif
}

/******************************************************************************/

extern int RISfrm_load_dll()
{
#if defined(VERSION_4_ONLY)
	if( IsRISDynamicLoadDone() ) 
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

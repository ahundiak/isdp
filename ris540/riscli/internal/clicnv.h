/* Do not alter this SPC information: $Revision: 1.2.53.1 $ */
/*
**	NAME:							clicnv.h
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					12/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef RIS_CLICNV_H
#define RIS_CLICNV_H
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/

#define NET_TO_INIT(arc, init) 								\
if (arc->remote_arch != LOCAL_ARCH) 						\
{															\
	RIScli_net_to_init(arc, init);							\
}

#define NET_TO_DEBUG(arc, debug) 							\
if (arc->remote_arch != LOCAL_ARCH) 						\
{															\
	RIScli_net_to_debug(arc, debug);						\
}

#define NET_TO_LOCATE_SCHEMA_FILE(arc, locate_schfile)		\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_net_to_locate_schema_file(arc, locate_schfile);	\
}

#define STRING_TO_NET(arc, string)							\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_string_to_net(arc, string);						\
}

#define NET_TO_PREPARE(arc, prep)							\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_net_to_prepare(arc, prep);						\
}

#define PREPARE_TO_NET(arc, prep)							\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_prepare_to_net(arc, prep);						\
}

#define NET_TO_EXECUTE(arc, sql, exec)						\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_net_to_execute(arc, sql, exec);					\
}

#define EXECUTE_TO_NET(arc, exec)							\
if (arc->remote_arch != LOCAL_ARCH)             			\
{                                               			\
	RIScli_execute_to_net(arc, exec);						\
}

#define NET_TO_FETCH_BLOB(arc, fetch_blob)                  \
if (arc->remote_arch != LOCAL_ARCH)                         \
{                                                           \
	RIScli_net_to_fetch_blob(arc, fetch_blob);              \
}

#define FETCH_BLOB_TO_NET(arc, fetch_blob)                  \
if (arc->remote_arch != LOCAL_ARCH)                         \
{                                                           \
	RIScli_fetch_blob_to_net(arc, fetch_blob);              \
}

#define NET_TO_FETCH_4(arc, fetch) 							\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_net_to_fetch_4(arc, fetch);						\
}

#define FETCH_TO_NET(arc, stmt, fetch)						\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_fetch_to_net(arc, stmt, fetch);					\
}

#define CLOSE_TO_NET(arc, close)							\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_close_to_net(arc, close);						\
}

#define NET_TO_CLEAR(arc, clear) 							\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_net_to_clear(arc, clear);						\
}

#define CLEAR_TO_NET(arc, clear) 							\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_clear_to_net(arc, clear);						\
}

#define GET_FLAGS_TO_NET(arc, get_flags)					\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_get_flags_to_net(arc, get_flags);				\
}

#define REPORT_SS_ERROR_TO_NET(arc, report_ss_error)		\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_report_ss_error_to_net(arc, report_ss_error);	\
}

#define GET_SS_NAMES_TO_NET(arc, get_ss_names)				\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_get_ss_names_to_net(arc, get_ss_names);			\
}

#define GET_SCH_IN_TRANS_TO_NET(arc, get_sch_names)			\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_get_sch_in_trans_to_net(arc, get_sch_names);		\
}
/********   BLOB ***************/
#define NET_TO_BLOB_EXECUTE(arc, blob_exec)            		\
if (arc->remote_arch != LOCAL_ARCH)                         \
{                                                           \
    RIScli_net_to_blob_execute(arc, blob_exec);        		\
}

#define NET_TO_DEFERRED_EXECUTE(arc, sql, deferred_exec)    \
if (arc->remote_arch != LOCAL_ARCH)                         \
{                                                           \
    RIScli_net_to_deferred_execute(arc, sql, deferred_exec);\
}

#define NET_TO_FETCH(arc, fetch)                        \
if (arc->remote_arch != LOCAL_ARCH)                         \
{                                                           \
    RIScli_net_to_fetch(arc, fetch);                    \
}


/********   BLOB ***************/
#define GET_SS_DEF_TO_NET(arc, get_ss_def)					\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_get_ss_def_to_net(arc, get_ss_def);				\
}

#define ERROR_TO_NET(arc, error)							\
if (arc->remote_arch != LOCAL_ARCH)							\
{															\
	RIScli_error_to_net(arc, error);						\
}

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif

/* Do not alter this SPC information: $Revision: 1.2.54.1 $ */
/*
**	NAME:							app.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
#ifndef RIS_APP_H
#define RIS_APP_H

/*
**	INCLUDES
*/
#include "risapp.h"
#include "risdebug.h"
#include "ris_err.h"
#include "risstjmp.h"
#include "riswarn.h"

/*
**	DEFINES
*/
#define VALID_PROTOCOL(p) ((p) == 'M' || (p) == 'X' || (p) == 'T' || (p) == 'D')

/*
**	TYPES
*/

/*
**	VARIABLES
*/

/*
**  DEFINES
*/

/*
** To the network
*/
#define INIT_TO_NET(arc, init) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_init_to_net(arc, init);

#define DEBUG_TO_NET(arc, debug) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_debug_to_net(arc, debug);

#define LOCATE_SCH_FILE_TO_NET(arc, locate_schfile) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_locate_sch_file_to_net(arc, locate_schfile);

#define PREPARE_TO_NET(arc, prepare) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_prepare_to_net(arc, prepare);

#define EXECUTE_TO_NET(arc, sqlda, execute) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_execute_to_net(arc, sqlda, execute);

/***   BLOB  ****/
#define FETCH_TO_NET(arc, fetch_buf) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_fetch_buf_to_net(arc, fetch_buf);

#define FETCH_BLOB_TO_NET(arc, fetch_blob) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_fetch_blob_to_net(arc, fetch_blob);

#define NET_TO_FETCH_BLOB(arc, fetch_blob) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_net_to_fetch_blob(arc, fetch_blob);

#define BLOB_STRUCT_TO_NET(arc, blob) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_blob_struct_to_net(arc, blob);
/***   BLOB  ****/

#define CLEAR_TO_NET(arc, clear) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_clear_to_net(arc, clear);

#define GROW_BUF_TO_NET(arc, grow_buf) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_grow_buf_to_net(arc, grow_buf);

/****       BLOB 	*****/
#define EXECUTE_BLOB_TO_NET(arc, execute_blob) \
if (arc->remote_arch != LOCAL_ARCH) \
RISapp_execute_blob_to_net(arc, execute_blob);

#define EXECUTE_DEFERRED_TO_NET(arc, sqlda, execute_deferred) \
if (arc->remote_arch != LOCAL_ARCH) \
RISapp_execute_deferred_to_net(arc, sqlda, execute_deferred);
/*         BLOB *****/

/*
** From the network
*/
#define GROW_BUF_FROM_NET(arc, grow_buf) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_grow_buf_from_net(arc, grow_buf);

#define PREPARE_FROM_NET(arc, prep) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_prepare_from_net(arc, prep);

#define EXECUTE_FROM_NET(arc, execute) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_execute_from_net(arc, execute);

/*** BLOB ****/
#define FETCH_FROM_NET(arc, stmt, fetch) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_fetch_from_net(arc, stmt, fetch);

#define FETCH_BLOB_FROM_NET(arc, stmt, fetch_blob) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_fetch_blob_from_net(arc, stmt, fetch_blob);

#define CLOSE_FROM_NET(arc, close) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_close_from_net(arc, close);

#define CLEAR_FROM_NET(arc, clear) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_clear_from_net(arc, clear);

#define STRING_FROM_NET(arc, string) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_string_from_net(arc, string);

#define GET_FLAGS_FROM_NET(arc, get_flags) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_get_flags_from_net(arc, get_flags);

#define REPORT_SS_ERR_FROM_NET(arc, error) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_report_ss_error_from_net(arc, error);

#define GET_SS_NAMES_FROM_NET(arc, get_ss_names) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_get_ss_names_from_net(arc, get_ss_names);

#define GET_SS_DEF_FROM_NET(arc, get_ss_def) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_get_ss_def_from_net(arc, get_ss_def);

#define GET_SCH_IN_TRANS_FROM_NET(arc, get_sch_in_trans) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_get_sch_in_trans_from_net(arc, get_sch_in_trans);

#define ERROR_FROM_NET(arc, error) \
if (arc->remote_arch != LOCAL_ARCH) RISapp_error_from_net(arc, error);

#endif /* RIS_APP_H */

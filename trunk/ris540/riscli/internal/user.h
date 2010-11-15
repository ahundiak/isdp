/* Do not alter this SPC information: $Revision: 1.2.53.1 $ */
/*
**	NAME:							user.h
**	AUTHORS:						David Michal
**	CREATION DATE:					9/7/88
**	ABSTRACT:
**		Describes global stuff for user directory.
**	
**	REVISION HISTORY:
*/
 
#ifdef USER_GLOBAL_DEFINE
# define USER_EXTERN
# define USER_INITIAL(value) = value
#else
# define USER_EXTERN extern
# define USER_INITIAL(value)
#endif

/*
**	INCLUDES
*/
#include "risdebug.h"
#include "rislimit.h"
#include "risstjmp.h"
#include "ris_err.h"

/*
**	DEFINES
*/

/* Transaction states */
#define NO_TRANSACTION			0
#define READ_ONLY_TRANSACTION	1
#define READ_WRITE_TRANSACTION	2

#define PDDO_TO_NET(arc, sql, pddo) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_pddo_to_net(arc, sql, pddo);

#define PE_TO_NET(arc, sql, pe) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_pe_to_net(arc, sql, pe);

#define OPEN_TO_NET(arc, sql, open) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_open_to_net(arc, sql, open);

#define EXEC_TO_NET(arc, sql, exec) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_exec_to_net(arc, sql, exec);

#define GET_ACCESS_TO_NET(arc, get_access) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_get_access_to_net(arc, get_access);

#define CREATE_TABLE_TO_NET(arc, cr_tab) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_create_table_to_net(arc, cr_tab);

#define CREATE_VIEW_TO_NET(arc, cr_view) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_create_view_to_net(arc, cr_view);

#define ALTER_TABLE_TO_NET(arc, alt_tab) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_alter_table_to_net(arc, alt_tab);

#define CREATE_SCHEMA_TO_NET(arc, schema) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_create_schema_to_net(arc, schema);

#define SCHEMA_DB_TO_NET(arc, schema_db) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_schema_db_to_net(arc, schema_db);

#define UPD_ACCESS_TO_NET(arc, upd_access) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_upd_access_to_net(arc, upd_access);

#define LOAD_RISDBS_TO_NET(arc, dbs) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_load_risdbs_to_net(arc, dbs);

#define LOAD_RISSCHEMAS_TO_NET(arc, schemas) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_load_risschemas_to_net(arc, schemas);

#define NET_TO_GET_TAB(arc, get_tab) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_get_tab(arc, get_tab);

#define NET_TO_GET_ACCESS(arc, get_access) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_get_access(arc, get_access);

#define NET_TO_GET_GRANTEES(arc, grantees) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_get_grantees(arc, grantees);

#define NET_TO_CRE_SCH_GET_GRANTEES(arc, grantees) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_cre_sch_get_grantees(arc, grantees);

#define NET_TO_ERROR(arc, error) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_error(arc, error);

/*******   BLOB          ******/
#define NET_TO_FETCH_BUF(arc, stmt, fetch) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_fetch_buf(arc, stmt, fetch);

#define FETCH_BLOB_TO_NET(arc, fetch_blob) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_fetch_blob_to_net(arc, fetch_blob);

#define NET_TO_FETCH_BLOB(arc, fetch_blob) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_net_to_fetch_blob(arc, fetch_blob);

#define EB_TO_NET(arc,  eb) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_eb_to_net(arc, eb);

#define PEDE_TO_NET(arc, sql, pede) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_pede_to_net(arc, sql, pede);

#define EXECDE_TO_NET(arc, sql, execde) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_execde_to_net(arc, sql, execde);

#define FETCH_TO_NET(arc, fetch) \
if (arc->remote_arch != LOCAL_ARCH) RISusr_fetch_to_net(arc, fetch);
/*******   BLOB          ******/

/*
**	TYPES
*/

/*
**  Structure holding schemas in transaction 
**  Also, the allowable tables in the transaction.
*/
typedef struct transact_schemas
{
	struct risschema *schema;
    struct ristablist   *tablist;
} transact_schemas;


/*
**	VARIABLES
*/


USER_EXTERN char RIS_remote_xns_addr[RIS_MAX_NODE_SIZE];
USER_EXTERN char RIS_remote_tcp_addr[RIS_MAX_NODE_SIZE];
USER_EXTERN char RIS_remote_dnp_addr[RIS_MAX_NODE_SIZE];
USER_EXTERN char RIS_remote_lu62_addr[RIS_MAX_NODE_SIZE];
USER_EXTERN transact_schemas  *RISusr_transact_schemas;


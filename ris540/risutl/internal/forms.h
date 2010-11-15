/* Do not alter this SPC information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							forms.h
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added RISfrm_need_system_font variable for INTERNATINALIZATION.  Rick
** 		6/96:   Ashley - fix for 439601283  make TCP the default 
*/
 
#ifndef INTERNAL_FORMS_H
#define INTERNAL_FORMS_H

#include <stdio.h>
#include <FI.h>
#include "ris.h"
#include "rislimit.h"
#include "risforms.h"
#include "risutl.h"
#include "risapi.h"
#include "utl_err.h"
#include "utl_inf.h"

#ifdef ris_forms_error
#undef ris_forms_error
#endif

/*
**	Internal defines
*/
#define INFORMIX_DB	0
#define ORACLE_DB	1
#define INGRES_DB	2
#define DB2_DB		3
#define RDB_DB		4
#define SYBASE_DB	5
#define OS400_DB	6
#define MSSQL_DB    7
#define DB_COUNT	8
#define VALID_DBTYPE(dbtype)	((dbtype) >= 0 && (dbtype) < DB_COUNT)

#define INFORMIX_CHAR   	'X'
#define ORACLE_CHAR		'O'
#define INGRES_CHAR		'I'
#define DB2_CHAR		'D'
#define RDB_CHAR		'R'
#define SYBASE_CHAR		'Y'
#define OS400_CHAR		'4'
#define MSSQL_CHAR		'M'

#define INFORMIX_NAME	"Informix"
#define ORACLE_NAME		"Oracle"
#define INGRES_NAME		"Ingres"
#define DB2_NAME		"DB2"
#define RDB_NAME		"RDB"
#define SYBASE_NAME		"SYBASE"
#define OS400_NAME		"OS400"
#define MSSQL_NAME		"MSSQL"

/* Ashley 6/20/96 - fix for 439601283  make TCP the default */
#define TCP_PROT	0
#define XNS_PROT	1
#define DNP_PROT	2
#define ISO_PROT	3
#define PROT_COUNT	4

#define UNIX_NAME		"UNIX"
#define VMS_NAME		"VMS"
#define NT_NAME			"WINDOWS NT"

#define IBM_LU62_PROT	0
#define IBM_TCP_PROT	1
#define IBM_PROT_COUNT	2
#define VALID_IBMPROT(ibmprot)	((ibmprot) >= 0 && (ibmprot) < IBM_PROT_COUNT)

#define IBM_LU62_NAME	"lu6.2"
#define IBM_TCP_NAME	"tcp"

#define OS400_APPC_PROT		0
#define OS400_PROT_COUNT	1
#define VALID_OS400PROT(os400prot) ((os400prot) >= 0 && (os400prot) < OS400_PROT_COUNT)

#define OS400_APPC_NAME	   "APPC"

#define SM_FORM_MSG		0		/* Schema Manager Form		*/
#define SI_FORM_MSG		1		/* Schema Information Form	*/
#define CS_FORM_MSG		2		/* Create Schema Form		*/
#define DS_FORM_MSG		3		/* Drop Schema Form			*/
#define SD_FORM_MSG		4		/* Schema Definition Form	*/
#define RD_FORM_MSG		5		/* RIS Databases Form		*/
#define DD_FORM_MSG		6		/* Data Definition Form		*/
#define TI_FORM_MSG		7		/* Table Information Form	*/
#define CT_FORM_MSG		8		/* Create Table Form		*/
#define DT_FORM_MSG		9		/* Drop Table Form			*/
#define AT_FORM_MSG		10		/* Alter Table Form			*/
#define SF_FORM_MSG		11		/* Schema File Form			*/
#define SP_FORM_MSG		12		/* Schema Password Form		*/
#define NI_FORM_MSG		13		/* Schema Node Info Form	*/
#define DP_FORM_MSG		15		/* DB2 Password	Form		*/
#define SE_FORM_MSG		16		/* Set Form					*/
#define CI_FORM_MSG		17		/* Create Index Form		*/
#define LC_FORM_MSG		18		/* Locate Client Form		*/
#define DA_FORM_MSG		19		/* Dictionary Access Form	*/
#define SA_FORM_MSG		20		/* secure schema Access Form*/
#define IN_FORM_MSG		21		/* include form */
#define EX_FORM_MSG		22		/* exclude form */
#define OS_FORM_MSG		23		/* os user password form */

#define FORM_MSG_COUNT	24

/* Debug form */
#define SM_DEBUG_BUTTON	22
#define DB_FORM			99
#define DB_FORM_FILE	"risdebug.frm"

/*	Internal group definitions	*/
#define SI_OSUSER_GROUP				69

#define CT_TYPE_GROUP				45
#define CT_BUTTON_GROUP				46
#define CT_COLUMN_GROUP				44
#define CT_DISABLE_GROUP			41

#define AT_TYPE_GROUP				45
#define AT_DISABLE_GROUP			41

#define TI_DISABLE_GROUP			20

#define SF_BUTTON_GROUP				16
#define SF_CHECK_GROUP				20
#define SF_LOCATE_GROUP				31
#define SF_CHECKSUM_GROUP			0

#define DP_DISABLE_GROUP			18

#define FRM_MAX_PROT_SIZE	5
#define FRM_MAX_LOCATION_SIZE	(FRM_MAX_PROT_SIZE + RIS_MAX_NODE_SIZE + 1)

#define CALLED_BY_SCHEMA_MGR	0
#define CALLED_BY_USER			1
#define DISPLAY_ENABLED			0
#define DISPLAY_DISABLED		1

#define UPDATE					0
#define EXECUTE_UPDATE			1
#define DECLARE_EXECUTE_UPDATE	2

#define LC_BUTTON_GROUP				16
#define LC_CHECK_GROUP				20
#define LC_LOCATE_GROUP				31

/*
**	Object types
*/
#define TABLE_CHAR				'T'
#define VIEW_CHAR				'V'
#define INDEX_CHAR				'I'
#define RIS_NAME				0
#define DBMS_NAME				1

#define TIMESTAMP_STRING		"timestamp"

#ifdef NO_FRM_DBG
#define FRM_DBG(s)
#else
#define FRM_DBG(s)	if (RISfrm_debug) {RIScom_output_debug s;}
#endif

#define CLEAR_ERROR memset(&RIS_forms_error, '\0', sizeof(RIS_forms_error));

#if defined(unix)
#define DISPLAY_HELP_BUTTON(form) \
{ if (RISfrm_display_help_buttons) FIg_display(form, FI_HELP); \
else FIg_erase(form, FI_HELP);  }
#endif
#if defined(WIN32)
#define DISPLAY_HELP_BUTTON(form) \
{ if (RISfrm_display_help_buttons) FIg_display(form, FI_HELP); \
else FIg_disable(form, FI_HELP);  }
#endif

#define VALID_FORM_CHECK(x) if (!x) { return; }

/*
**	This structure uniquely identifies a database
*/
typedef struct RISfrm_db_id_s
{
	char	type[RIS_MAX_ID_SIZE];
	char	name[RIS_MAX_PATH_SIZE];
	char	location[FRM_MAX_LOCATION_SIZE];
} RISfrm_db_id;

/*
**	This structure defines an object (table/view/index)
*/
typedef struct RISfrm_object_s
{
	char					name[RIS_MAX_ID_SIZE];
	char					dbms_name[RIS_MAX_ID_SIZE];
	char					type;
	struct RISfrm_object_s	*next;
} RISfrm_object;

/*
**	This structure defines users
*/
typedef struct RISfrm_users_s
{
	char					user[RIS_MAX_ID_SIZE];
	char					privilege;
	struct RISfrm_users_s	*next;
} RISfrm_user;

/*
**	Message
*/
typedef struct RISfrm_msg_s
{
	int		count;
	int		label[16];
	char	str[512];
	int		msg_fld_label;
	Form	fp;
} RISfrm_msg;


/*
**	Process gadget struct
*/
typedef struct RISfrm_label_function_s
{
	int		label;
	void	(*function_ptr)();
} RISfrm_label_function;

#ifdef EXTERN
#undef EXTERN
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef DEFINE_FRM_GLOBALS
# define EXTERN
# define INIT(x)	= x
#else
# define EXTERN		extern
# define INIT(x)
#endif

EXTERN	 int				RISfrm_need_system_font					INIT(0);
EXTERN	 int				RISfrm_debug							INIT(0);
EXTERN	 int				RISfrm_debug_enabled					INIT(0);
EXTERN	 int				RISfrm_initialized						INIT(0);

EXTERN	 int				RISfrm_file_info_up_to_date				INIT(0);
EXTERN	 int				RISfrm_dbs_cnt							INIT(0);
EXTERN	 int				RISfrm_schemas_cnt						INIT(0);
EXTERN	 ris_db_info		*RISfrm_dbs								INIT(NULL);
EXTERN	 ris_schema_info	*RISfrm_schemas							INIT(NULL);

EXTERN	 int				RISfrm_object_list_up_to_date			INIT(0);
EXTERN	 int				RISfrm_objects_cnt						INIT(0);
EXTERN	 RISfrm_object	**RISfrm_objects						INIT(NULL);

EXTERN	 int				RISfrm_dbms_obj_list_up_to_date			INIT(0);
EXTERN	 char			RISfrm_dbms_obj_owner[RIS_MAX_ID_SIZE]  INIT("");
EXTERN	 char			RISfrm_dbms_obj_schname[RIS_MAX_ID_SIZE]  INIT("");
EXTERN	 int				RISfrm_dbms_objs_cnt					INIT(0);
EXTERN	 RISfrm_object	**RISfrm_dbms_objs						INIT(NULL);

EXTERN	 int				RISfrm_access_user_list_up_to_date		INIT(0);
EXTERN	 int				RISfrm_access_users_cnt					INIT(0);
EXTERN	 RISfrm_user		**RISfrm_access_users					INIT(NULL);

EXTERN	 int				RISfrm_user_list_up_to_date				INIT(0);
EXTERN	 int				RISfrm_users_cnt						INIT(0);
EXTERN	 RISfrm_user		**RISfrm_users							INIT(NULL);

EXTERN	 int				RISfrm_dbms_user_list_up_to_date		INIT(0);
EXTERN	 char			RISfrm_dbms_user_schname[RIS_MAX_ID_SIZE] INIT("");
EXTERN	 int				RISfrm_dbms_users_cnt					INIT(0);
EXTERN	 RISfrm_user		**RISfrm_dbms_users						INIT(NULL);

EXTERN	 RISfrm_msg		RISfrm_msgs[FORM_MSG_COUNT];

EXTERN	 void			(*RISfrm_pre_notification)()			INIT(NULL);
EXTERN	 void			(*RISfrm_post_notification)()			INIT(NULL);

EXTERN	 void			(*RISfrm_user_init_sm_form)()			INIT(NULL);

EXTERN	 void			(*RISfrm_user_init_sd_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_dd_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_sf_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_lc_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_se_form)()			INIT(NULL);

EXTERN	 void			(*RISfrm_user_init_si_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_cs_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_ds_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_sa_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_da_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_sp_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_ni_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_dp_form)()			INIT(NULL);

EXTERN	 void			(*RISfrm_user_init_rd_form)()			INIT(NULL);

EXTERN	 void			(*RISfrm_user_init_ti_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_ct_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_dt_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_at_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_in_form)()			INIT(NULL);
EXTERN	 void			(*RISfrm_user_init_ex_form)()			INIT(NULL);

EXTERN	 int				(*RISfrm_user_exec_se_form)()			INIT(NULL);

EXTERN	 int				(*RISfrm_user_exec_cs_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_ds_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_sa_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_da_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_sp_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_ni_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_ie_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_dp_form)()			INIT(NULL);

EXTERN	 int				(*RISfrm_user_exec_ct_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_at_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_dt_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_in_form)()			INIT(NULL);
EXTERN	 int				(*RISfrm_user_exec_ex_form)()			INIT(NULL);

EXTERN	 int				(*RISfrm_user_error_handler)()			INIT(NULL);

EXTERN	 char			RISfrm_display_help_buttons				INIT(0);

EXTERN	 ris_forms_error_info	RIS_forms_error;
EXTERN	 ris_forms_error_info	*ris_forms_error INIT(&RIS_forms_error);

#endif
typedef struct modes_s
{
        int ansi;
	int verify;
	int blankstrip;
	int autocommit;
        int autorename;
        int enable_dbms;
} modes_s;

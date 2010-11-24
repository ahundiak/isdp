/* Do not alter this SPC information: $Revision: 1.3.29.1 $ */
/*
**	NAME:							riscl_sr.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:


	. New opcodes added for blob support.  

     	RIS_EXEC_DEFERRED_CODE              
     	RIS_PREP_EXEC_DEFERRED_CODE         
     	RIS_EXEC_BLOB_CODE                  
     	RIS_FETCH_BLOB_CODE                 


	. New data strucutures added 

		ris_clisrv_exec_blob
		ris_clisrv_exec_deferred
		ris_clisrv_fetch_blob

		ris_srvcli_buf_pe_deferred
		ris_srvcli_buf_exec_blob
		ris_srvcli_fetch_blob
		

	.In order to allow more than 15 types, the nullable bit is moved from 
	 5th bit to 8th bit. The macros :  ALLOW_NULLS, NULLS_ALLOWED, 
	 ATTR_TYPE and ATTR_FLAG are modified accordingly 
	
										 
												James Chang 6/93

	JP/Jin_Jing		08/93

		Some of the old opcodes and the related structures have changed
		between V4 and V5. For interoperability reasons, the old opcodes 
		have been tagged as ...._4 and the new opcodes continue to have the 
		old names. 
		eg RIS_OPEN_SCHEMA_CODE_4 and RIS_OPEN_SCHEMA_CODE
		New opcodes added for V5 support are
			RIS_GRANT_SCHEMA_CODE
			RIS_GRANT_CONNECT_CODE
			RIS_GRANT_RESOURCE_CODE
			RIS_REVOKE_SCHEMA_CODE
			RIS_REVOKE_CONNECT_CODE
			RIS_REVOKE_RESOURCE_CODE

   Shiva 11/10/93

       added three fields dict_dbusr, schown_dbusr and login_dbusr
       to ris_srvcli_buf_create_schema and ris_srvcli_buf_open_schema
       to enable server to send back Sybase aliases (and potentially
       for other databases also)
	

   Jin 11/29/93

       Changed the field name "force_flag" to "options_flag" in
       ris_clisrv_buf_create_schema. This field will be used to
       pass both force parameter and include/exclude parameter
       to server. Two micros CRE_SCH_FORCE_FLAG and CRE_SCH_EXCLUDE_FLAG
       are defined to identify these parameters with bit operations.


	New opcodes added for V4 -> V5 interoperability problem causing
	by the new internal_sqlvar 

		RIS_ALT_SCHEMA_EXCLUDE_CODE
		RIS_ALT_SCHEMA_INCLUDE_CODE
		RIS_CREATE_INDEX_CODE
		RIS_CREATE_TABLE_CODE
		RIS_CREATE_VIEW_CODE

	Shiva 2/27/94  Moved ris_schema_info_4 from riscom/include/ris.h
		to this file

		Also, copied ris_schema_info definition to a new internal
		structure ris_sch_intern_info. The original ris_schema_info
		is to be used only to pass info to the application

	

*************************************/

#ifndef RISCL_SR_H
#define RISCL_SR_H
 
#ifdef CLISRV_GLOBAL_DEFINE
#define CLISRV_EXTERN
#define CLISRV_INIT(value) = value
#else
#define CLISRV_EXTERN extern
#define CLISRV_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "rislimit.h"
#include "risinsql.h"
#include "ris.h"

/*
**	DEFINES
*/
/* Micros for options_flag in ris_clisrv_buf_create_schema */

#define CRE_SCH_FORCE_FLAG 0x01
#define CRE_SCH_EXCLUDE_FLAG 0x02
#define CRE_SCH_USING_FLAG 0x04

/* New macro for  risattr_2 and ris_attr_info_2  */

#define ALLOW_NULLS(atype)      atype |= 0x80
#define NULLS_ALLOWED(atype)   (atype & 0x80)
#define ATTR_TYPE(atype)       (atype & 0x1f)
#define ATTR_FLAG(atype) ((int)(atype & 0x80) >> 7)

/* Keep those macros for old client and apps.  */
#define ALLOW_NULLS_4(atype)      atype |= 0x10
#define NULLS_ALLOWED_4(atype)    (atype & 0x10)
#define ATTR_TYPE_4(atype)        (atype & 0xf)
#define ATTR_FLAG_4(atype)        ((atype & 0x10) >> 4)

#define RIS_CLISRV_HDR_SIZE     ((int)&(((ris_clisrv_buf *)0)->buf))
#define RIS_SRVCLI_HDR_SIZE     ((int)&(((ris_srvcli_buf *)0)->buf))

/* client server codes */

#define UNUSED_SRV_CODE_0					0
#define UNUSED_SRV_CODE_1					1

/* schema codes */

#define RIS_OPEN_SCHEMA_CODE_4					2
#define RIS_CLOSE_SCHEMA_CODE					3
#define RIS_CRE_SCH_GET_GRANTEES_CODE_4			4
#define RIS_DROP_SCHEMA_CODE					5
#define RIS_NEW_SCHPASS_CODE					6
#define RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE_4 	7
#define RIS_CREATE_USER_CODE					8

/* ddl codes */

#define RIS_ALTER_TABLE_CODE_4					9
#define RIS_CREATE_TABLE_CODE_4					10
#define RIS_DROP_TABLE_CODE_4			   		11
#define RIS_CREATE_VIEW_CODE_4					12
#define RIS_DROP_VIEW_CODE_4		   			13
#define RIS_CREATE_INDEX_CODE_4					14
#define RIS_DROP_INDEX_CODE_4			    	15
#define RIS_UPD_ACCESS_CODE						16
#define RIS_ALT_SCHEMA_EXCLUDE_CODE_4			17
#define RIS_ALT_SCHEMA_INCLUDE_CODE_4			18



/* dml codes */

#define RIS_EXEC_NOW_CODE						19
#define RIS_PREP_EXEC_CODE						20
#define RIS_EXEC_CODE							21
#define RIS_PREP_DESC_DECL_OPEN_CODE			22
#define RIS_OPEN_CODE							23
#define RIS_FETCH_BUF_CODE_4					24
#define RIS_CLOSE_CODE							25
#define RIS_CLEANUP_CODE						26

/* locking codes */

#define RIS_LOCK_TABLES_CODE					27	

/* transaction codes */

#define RIS_COMMIT_WORK_CODE					28	
#define RIS_ROLLBACK_WORK_CODE					29	
#define RIS_AUTOCOMMIT_ON_CODE					30
#define RIS_AUTOCOMMIT_OFF_CODE					31

/* schema information codes */

#define RIS_GET_ALL_ACCESS_CODE_4				32
#define RIS_GET_ACCESS_CODE_4					33
#define RIS_GET_TAB_CODE_4						34
#define RIS_GET_TAB_NOVERIFY_CODE_4				35		
#define RIS_GET_TABTYPE_CODE_4					36	
#define RIS_GET_SCHEMA_GRANTORS_CODE			37	
#define RIS_GET_SCHEMA_GRANTEES_CODE			38	

/* dictionary table codes */

#define RIS_LOAD_RISDBS_CODE					39	
#define RIS_LOAD_RISSCHEMAS_CODE_4				40

/* misc. codes */

#define RIS_GROW_CLI_TO_SRV_BUF_CODE		41
#define RIS_GROW_SRV_TO_CLI_BUF_CODE		42
#define RIS_DBG_CODE						43	
#define RIS_ALTER_RACF_PWD_CODE_4			44	

#define RIS_BLANKSTRIP_ON_CODE				45	
#define RIS_BLANKSTRIP_OFF_CODE				46	

/* IMPORTATNT *********
 In order to accommodate old client any new opcde added should be 
 placed in the bottom 
*/ 

#define RIS_CRE_SCH_GET_GRANTEES_CODE       47
#define RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE 48
#define RIS_OPEN_SCHEMA_CODE                49
#define RIS_GET_TAB_CODE                    50
#define RIS_GET_TAB_NOVERIFY_CODE           51
#define RIS_GET_TABTYPE_CODE                52
#define RIS_ALT_SCHEMA_INCLUDE_CODE         53
#define RIS_ALT_SCHEMA_EXCLUDE_CODE         54
#define RIS_GET_ALL_ACCESS_CODE             55
#define RIS_GET_ACCESS_CODE 				56 
#define RIS_LOAD_RISSCHEMAS_CODE   			57

#define RIS_GRANT_SCHEMA_CODE               58
#define RIS_GRANT_CONNECT_CODE              59
#define RIS_GRANT_RESOURCE_CODE             60
#define RIS_REVOKE_SCHEMA_CODE              61
#define RIS_REVOKE_CONNECT_CODE             62
#define RIS_REVOKE_RESOURCE_CODE            63

#define RIS_EXEC_DEFERRED_CODE             	64
#define RIS_PREP_EXEC_DEFERRED_CODE        	65
#define RIS_EXEC_BLOB_CODE                 	66
#define RIS_FETCH_BLOB_CODE                	67
#define RIS_FETCH_BUF_CODE                	68
#define RIS_ALT_SCHEMA_SECURE_CODE			69 
#define RIS_ALTER_TABLE_CODE				70
#define RIS_CREATE_INDEX_CODE				71
#define RIS_CREATE_TABLE_CODE				72
#define RIS_CREATE_VIEW_CODE				73
#define RIS_DROP_TABLE_CODE                 74
#define RIS_DROP_VIEW_CODE                  75
#define RIS_DROP_INDEX_CODE                 76
#define RIS_ALTER_RACF_PWD_CODE				77

#define RIS_LAST_SRV_CODE                   78


/*
**	Status returned by server to client if server doesn't support
**	network verification. (Used to be 202 in riserror.h).
*/
#define RIS_UNSUPPORTED		99

/*
**	TYPES
*/

#define uint unsigned int
#define ushort unsigned short
#define uchar unsigned char
#define offset unsigned int

/* following structures mimic dictionary database information */

	/*
	** For all structures that have changed between V4 and V5, for 
	** interoperability reasons, we have maintained the old structure 
	** definitions as it is and tagged them all, with an _4 at the end, 
	** and the new structures will continue to use the old names.
	*/


typedef struct ris_access_info_4
{
	char				schname[RIS_MAX_ID_SIZE];
	char				relname[RIS_MAX_ID_SIZE];
	char				colname[RIS_MAX_ID_SIZE];
	char				grantor[RIS_MAX_ID_SIZE];
	char				grantee[RIS_MAX_ID_SIZE];
	char				auth[RIS_AUTH_SIZE];
	char				insert_flag;	/* temp flag to send to server */
} ris_access_info_4;

typedef struct ris_access_info
{
    char                schname[RIS_MAX_ID_SIZE];
    char                relowner[RIS_MAX_ID_SIZE];
    char                relname[RIS_MAX_ID_SIZE];
    int                 relid;
    char                colname[RIS_MAX_ID_SIZE];
    char                grantor[RIS_MAX_ID_SIZE];
    char                grantee[RIS_MAX_ID_SIZE];
    char                auth[RIS_AUTH_SIZE];
    char                insert_flag;    /* temp flag to send to server */
    char                pad[3];
} ris_access_info;

	
typedef struct ris_attr_info_4
{
    char                attrname[RIS_MAX_ID_SIZE];
    uchar               atype;
    uchar               pad[1];
    short   dbsqltype;  /* db sql data type of input or output parameter    */
    uint    dbsqllen;   /* db length of input or output data buffer         */
    union
    {
        ushort          len;
        struct
        {
#if defined(sun) || defined(__Sol2__) || defined(__hpux__)
            uchar       prec;
            uchar       scale;
#elif defined(__clipper__) || defined(sco) || defined(WIN32) || defined(DOS) || defined(vms) || defined(Soli)
            uchar       scale;
            uchar       prec;
#else
ERROR - NO CODE
#endif
        } dec;
    } asize;
    short               pad2;
} ris_attr_info_4;

typedef struct ris_attr_info
{
	char				attrname[RIS_MAX_ID_SIZE];
	char      			extern_attrname[RIS_MAX_ID_SIZE];
	uchar				atype;
	uchar				pad[1];
	short   dbsqltype;	/* db sql data type of input or output parameter	*/
	uint	dbsqllen;	/* db length of input or output data buffer			*/
	union
	{
		uint			len;
		struct
		{
#if defined(sun) || defined(__Sol2__) || defined(__hpux__)
			uchar		dum1;
			uchar		dum2;
			uchar		prec;
			uchar		scale;
#elif defined(__clipper__) || defined(sco) || defined(WIN32) || defined(DOS) || defined(vms) || defined(Soli)
			uchar		scale;
			uchar		prec;
			uchar		dum1;
			uchar		dum2;
#else
ERROR - NO CODE
#endif
		} dec;
	} asize;
	int				pad2;
} ris_attr_info;

typedef struct ris_schema_info_4
{
    char                    schname[32];
    char                    usr[32];
    char                    passwd[38];
    unsigned short          dbid;
    struct  ris_schema_info_4 *next;
} ris_schema_info_4;

typedef struct ris_sch_intern_info
{
    char                    schname[32];
    char                    schowner[32];
    char                    passwd[38];
    char                    login[32];
    char                    dictowner[32];
    unsigned short          schtype;
    unsigned short          dbid;
	short                   major;
	short                   feature;
    char                    pad[2];
    struct  ris_sch_intern_info *next;
} ris_sch_intern_info;

typedef struct ris_clisrv_buf
{
	uchar	opcode;				/* current opcode */
	char	response_flag;
	short	stmt_id;			/* current stmt_id */
	uint	timestamp_interval;
	union
	{
		/* RIS_PREP_DESC_DECL_OPEN_CODE */
		struct ris_clisrv_buf_pddo
		{
			offset 		in_data;		/* offset to input data */
			offset 		in_sqlvar;		/* offset to input sqlvars */
			offset 		out_sqlvar;		/* offset to output sqlvars */
			offset 		query;			/* offset to query string */
			uint		in_count;		/* # of input sqlvars */
			uint		out_count;		/* # of output sqlvars */
			uint		query_len;		/* len of query string */
			uchar		stmt_type;		/* statement type */
			uchar		pad[3];
			char		data[1];		/*	VERY IMPORTANT: if this data field
											is moved, the pad field in the
											struct ris_appcli_buf_exec must
											be modified to reflect the change.
											The data fields must in the two
											structures must be in the same 
											position. */
		} pddo;

		/* RIS_PREP_EXEC_CODE */
       	/* RIS_PREP_EXEC_DEFERRED_CODE */
		struct ris_clisrv_buf_pe
		{
			offset 		in_data;		/* offset to input data */
			offset 		in_sqlvar;		/* offset to input sqlvars */
			offset 		query;			/* offset to guery string */
			uint		in_count;		/* # of input sqlvars */
			uint		query_len;		/* length of query string */
			uchar		stmt_type;		/* statement type  */
			uchar		pad[11];		/* make sure data starts on 32nd byte */
			char		data[1];		/*	VERY IMPORTANT: if this data field
											is moved, the pad field in the
											struct ris_appcli_buf_exec must
											be modified to reflect the change.
											The data fields must in the two
											structures must be in the same 
											position. */
		} pe;


		/***********  BLOB  ********************/


        /* RIS_EXEC_BLOB_CODE */
        struct ris_clisrv_buf_exec_blob
        {
			uint        xfcount;  	 /* The length of blob for this transfer */
			short		blob_col_pos;/* The position of blob sqlvar in the 
										list */
            uchar       more_to_follow;
            uchar       file_used;
            uchar       pad[24];    /*  32 byte aligned */
            char        data[1];     /* The area holding  blob data 
										or blob filenames */
        } exec_blob;



		/* RIS_FETCH_BLOB_BUF_CODE  */
        struct ris_clisrv_fetch_blob
        {
            short       blob_col_pos;    /* The position of blob sqlvar */
            uchar       file_used;
        } fetch_blob;


		/***********  BLOB  ********************/

		/* RIS_OPEN_CODE */
		struct ris_clisrv_buf_open
		{
			offset	 	in_data;		/* offset to input data */
			void		*dbms;			/* dbms info */
			short		old_stmt_id;	/* old statement identifier */
			uchar		pad[22];		/* make sure data starts on 32nd byte */
			char		data[1];		/*	VERY IMPORTANT: if this data field
											is moved, the pad field in the
											struct ris_appcli_buf_exec must
											be modified to reflect the change.
											The data fields must in the two
											structures must be in the same 
											position. */
		} open;

        /* RIS_EXEC_DEFERRED_CODE */
		/* RIS_EXEC_CODE */
		struct ris_clisrv_buf_exec
		{
			offset	 	in_data;		/* offset to input data */
			void		*dbms;			/* dbms info */
			short		old_stmt_id;	/* old statement identifier */
			uchar		pad[22];		/* make sure data starts on 32nd byte */
			char		data[1];		/*	VERY IMPORTANT: if this data field
											is moved, the pad field in the
											struct ris_appcli_buf_exec must
											be modified to reflect the change.
											The data fields must in the two
											structures must be in the same 
											position. */
		} exec;

		/* RIS_FETCH_BUF_CODE */
        /********         BLOB      ********/
		        /* RISCLI_FETCH_BUF_CODE */
		struct ris_clisrv_buf_fetch
        {
            offset      out_data;    /* offset to info of blob struct in data */
            offset      file_names;  /* offset to output file_names in data */
            uint        row_count;  /* number of rows expected */
            short       blob_count;  /* num of blob columns involved  */
			short		old_stmt_id; 	/* old statement identifier */
			void		*dbms;			/* dbms info */
            uchar       pad[12];
            char        data[1];    
        } fetch;

        /********         BLOB      ********/

        /* RIS_FETCH_BUF_CODE_4 */
        struct ris_clisrv_buf_fetch_4
        {
            void    *dbms;              /* dbms info */
            uint    row_count;          /* number of rows expected */
            short   old_stmt_id;        /* old statement identifier */
        } fetch_4;

		/* RIS_GET_TAB_CODE_4 */
		/* RIS_GET_TAB_NOVERIFY_CODE_4 */
		/* RIS_GET_TABTYPE_CODE */
		struct ris_clisrv_buf_get_tab_4
		{
			char tabname[RIS_MAX_ID_SIZE];		/* table name */
		} get_tab_4;

		/* RIS_GET_TAB_CODE */
        /* RIS_GET_TAB_NOVERIFY_CODE */
        /* RIS_GET_TABTYPE_CODE */
        struct ris_clisrv_buf_get_tab
        {
            char tabuser[RIS_MAX_ID_SIZE];      /* table owner */
            char tabname[RIS_MAX_ID_SIZE];      /* table name */
        } get_tab;


		/* RIS_GET_SCHEMA_GRANTORS_CODE  formerly RIS_INQUIRE_SCHREF_CODE */
		struct ris_clisrv_buf_get_schema_grantors
		{
			char schname[RIS_MAX_ID_SIZE];		/* schema name */
		} get_schema_grantors;

		/* RIS_ALT_SCHEMA_INCLUDE_CODE_4 */
		/* RIS_ALT_SCHEMA_EXCLUDE_CODE_4 */
		struct ris_clisrv_buf_alt_schema_4
		{
			char tabtype;						/* table, view, index */
			char tabname[RIS_MAX_ID_SIZE];		/* table name */
		} alt_schema_4;

        /* RIS_ALT_SCHEMA_INCLUDE_CODE */
		/* RIS_ALT_SCHEMA_EXCLUDE_CODE */
        struct ris_clisrv_buf_alt_schema
        {
            char tabtype;                       /* table, view, index */
            char tabowner[RIS_MAX_ID_SIZE];      /* table owner */
            char tabname[RIS_MAX_ID_SIZE];      /* table name */
            char extern_tabname[RIS_MAX_ID_SIZE];   /* table name */
            char pad[3];
            uint col_count;                     /* # of sqlvars */
            char pad1[16];                      /* future usages */
            char data[1];                       /* place to hold the sqlnames
                                                   one for each column
                                                   specified */
        } alt_schema;

		/* RIS_DROP_TABLE_CODE_4 */
        /* RIS_DROP_VIEW_CODE_4 */
        /* RIS_DROP_INDEX_CODE_4 */

        struct ris_clisrv_buf_drop_4
        {
            offset  query;                  /* offset to query string */
            char    name[RIS_MAX_ID_SIZE];  /* table/view/index name */
            char    data[1];
        } drop_4;

		/* RIS_DROP_TABLE_CODE */
		/* RIS_DROP_VIEW_CODE */
		struct ris_clisrv_buf_drop
		{
			char    ris_relname[RIS_MAX_ID_SIZE];   /* table/view/index name */
			char    ext_relname[RIS_MAX_ID_SIZE];   /* table/view/index name */
			char    relowner[RIS_MAX_ID_SIZE];  /* table/view/index name */
		} drop;

		/* RIS_DROP_INDEX_CODE */
        struct ris_clisrv_buf_drop_index
        {
            char    ris_idxname[RIS_MAX_ID_SIZE];
        } drop_idx;

		/* RIS_GET_ACCESS_CODE_4 */
		/* RIS_GET_ALL_ACCESS_CODE_4 */
		struct ris_clisrv_buf_get_access_4
		{
			ris_access_info_4	data;				/* access structure */
		} get_access_4;

		/* RIS_GET_ACCESS_CODE */
        /* RIS_GET_ALL_ACCESS_CODE */
        struct ris_clisrv_buf_get_access
        {
            ris_access_info data;               /* access structure */
        } get_access;


		/* RIS_CREATE_TABLE_CODE_4 */
		struct ris_clisrv_buf_create_table_4
		{
			offset		col_sqlvar;		/* offset to sqlvars */
			offset		def_string;		/* offset to def_string */
			uint		col_count;		/* # of sqlvars */
			uchar		pad[4];
			uchar		data[1];
		} create_table_4;

		/* RIS_CREATE_TABLE_CODE */
		struct ris_clisrv_buf_create_table
		{
			offset		col_sqlvar;		/* offset to sqlvars */
			offset		def_string;		/* offset to def_string */
			uint		col_count;		/* # of sqlvars */
			char		ris_relname[RIS_MAX_ID_SIZE];
			char		ext_relname[RIS_MAX_ID_SIZE];
			uchar		pad[12];		/* future usage */
			uchar		data[1];
		} create_table;

		/* RIS_CREATE_INDEX_CODE */
		struct ris_clisrv_buf_create_index
		{
			offset		def_string;		/* offset to def_string */
			offset      int_col_names;  /* offset to list of intternal cols*/
			uint        col_count;
			char		ris_index_name[RIS_MAX_ID_SIZE];
			char        ext_index_name[RIS_MAX_ID_SIZE];
			char		ris_table_name[RIS_MAX_ID_SIZE];
			char        index_type;
			uchar		pad[11];		/* future usage */
			uchar		data[1];
		} create_index;

		/* RIS_CREATE_INDEX_CODE_4 */
		struct ris_clisrv_buf_create_index_4
		{
			offset		def_string;		/* offset to def_string */
			uchar		pad[4];
			uchar		data[1];
		} create_index_4;

		/* RIS_CREATE_VIEW_CODE_4 */
		struct ris_clisrv_buf_create_view_4
		{
			offset		col_sqlvar;		/* offset to column sqlvars */
			offset		dbms_string;	/* offset to dbms string */
			offset		ris_string;		/* offset to ris string */
			uint		col_count;		/* # of sqlvars */
			uchar		data[1];
		} create_view_4;

		/* RIS_CREATE_VIEW_CODE */
		struct ris_clisrv_buf_create_view
		{
			offset		col_sqlvar;		/* offset to column sqlvars */
			offset		dbms_string;	/* offset to dbms string */
			offset		ris_string;		/* offset to ris string */
			uint		col_count;		/* # of sqlvars */
			char		ris_relname[RIS_MAX_ID_SIZE];	/* ris view name */
			char		ext_relname[RIS_MAX_ID_SIZE];	/* extern view name */
			uchar		data[1];
		} create_view;


        /* RIS_ALTER_TABLE_CODE */
        struct ris_clisrv_buf_alter_table
        {
            struct internal_sqlvar col_sqlvar;
                    /* 1 sqlvar - definition of column */
            offset          def_string; /* offset to def_string */
            uchar           data[1];
        } alter_table;

        /* RIS_ALTER_TABLE_CODE_4 */
        struct ris_clisrv_buf_alter_table_4
        {
            struct internal_sqlvar_4 col_sqlvar;
                    /* 1 sqlvar - definition of column */
            offset          def_string; /* offset to def_string */
            uchar           data[1];
        } alter_table_4;


		/* RIS_EXEC_NOW_CODE */
		struct ris_clisrv_buf_exec_now
		{
			offset		string;			/* offset to exec now string */
			uchar		stmt_type;		/* statement type */
			uchar		pad[3];
			uchar		data[1];
		} exec_now;

		/* RIS_LOCK_TABLES_CODE */
		struct ris_clisrv_buf_lock_tables
		{
			offset		string;			/* offset to lock_tables string */
			uchar		pad[4];
			uchar		data[1];
		} lock_tables;

		/* RIS_CRE_SCH_GET_GRANTEES_CODE_4 */
		struct ris_clisrv_buf_create_schema_4
		{
                /* INIT */
            uint    max_rows;
            uint    max_buf_size;
            uint    debug;
            uchar   maj;
            uchar   min;
            uchar   rel;
            uchar   lang;
                /* CREATE_SCHEMA */
            ris_schema_info_4	schema;         /* schema info */
            ris_db_info		db;             /* db info */
			char			schpass[RIS_MAX_PASSWD_SIZE];
            uchar			force_flag;
            uchar			autocommit_flag;/* autocommit ON/OFF */
            uchar			blankstrip_flag;/* blankstrip_flag ON/OFF */
                /* GET_GRANTEES */
		} create_schema_4;

		/* RIS_CRE_SCH_GET_GRANTEES_CODE */
        struct ris_clisrv_buf_create_schema
        {
                /* INIT */
            uint    max_rows;
            uint    max_buf_size;
            uint    debug;
            uchar   maj;
            uchar   min;
            uchar   rel;
            uchar   lang;
                /* CREATE_SCHEMA */
            ris_sch_intern_info   schema;         /* schema info */
            ris_db_info     db;             /* db info */
            char            schpass[RIS_MAX_PASSWD_SIZE];
            uchar           options_flag;
            uchar           autocommit_flag;/* autocommit ON/OFF */
            uchar           blankstrip_flag;/* blankstrip_flag ON/OFF */
                /* GET_GRANTEES */
        } create_schema;

		/* RIS_CREATE_USER_CODE */
		struct ris_clisrv_buf_create_user
		{
            uchar access;   /* 'D' or 'R' */
            uchar data[RIS_MAX_ID_SIZE];    /* new user name */
		}create_user;

		/* RIS_OPEN_SCHEMA_CODE_4 */
        /* RIS_ALTER_RACF_PWD_CODE_4 */
		/* RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE_4 */
		struct ris_clisrv_buf_schema_db_4
		{
            /************* INIT ******/
            uint    max_rows;
            uint    max_buf_size;
            uint    debug;
            uchar   maj;
            uchar   min;
            uchar   rel;
            uchar   lang;

            /**************************/
            ris_schema_info_4 schema;         /* schema info */
            ris_db_info		db;             /* db info */
			char			schpass[RIS_MAX_PASSWD_SIZE];
            char			newpasswd[RIS_MAX_PASSWD_SIZE]; /* for db2 */
            uchar			autocommit_flag;/* autocommit ON/OFF */
			uchar			blankstrip_flag;/* blankstrip ON/OFF */
            uchar			pad[2];
		} schema_db_4;

		/* RIS_OPEN_SCHEMA_CODE */
        /* RIS_ALTER_RACF_PWD_CODE */
        /* RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE */
        struct ris_clisrv_buf_schema_db
        {
            /************* INIT ******/
            uint    max_rows;
            uint    max_buf_size;
            uint    debug;
            uchar   maj;
            uchar   min;
            uchar   rel;
            uchar   lang;

            /**************************/
            ris_sch_intern_info   schema;         /* schema info */
            ris_db_info     db;             /* db info */
            char            schpass[RIS_MAX_PASSWD_SIZE];
            char            newpasswd[RIS_MAX_PASSWD_SIZE]; /* for db2 */
            uchar           autocommit_flag;/* autocommit ON/OFF */
            uchar           blankstrip_flag;/* blankstrip ON/OFF */
            uchar           pad[2];
        } schema_db;

		
		/* RIS_DBG_CODE */
		struct ris_clisrv_buf_debug
		{
			uint data;					/* debug flags */
		}debug;

		/* RIS_GROW_SRV_TO_CLI_BUF_CODE */
		/* RIS_GROW_CLI_TO_SRV_BUF_CODE */
		struct ris_clisrv_buf_grow
		{
			uint new_size;				/* new buffer size */
		}grow;

		/* RIS_NEW_SCHPASS_CODE */
		struct ris_clisrv_buf_new_schpass
		{
			uchar data[RIS_MAX_PASSWD_SIZE];	 /* new schema password */
		}new_schpass;

		/* RIS_UPD_ACCESS_CODE */
		struct ris_clisrv_buf_upd_access
		{
			offset	 	acc;			/* offset to access structures */
			uint		count;			/* # of access structures */
			uchar		delete_flag;	/* delete the current rows ? */
			uchar		more_to_follow;	/* are more access to follow ? */
			uchar		pad[6];
			uchar		data[1];
		} upd_access;

		/* RIS_LOAD_RISDBS_CODE */
		struct ris_clisrv_buf_load_risdbs
		{
			offset		dbs;				/* offset to db data */
			uint		db_count;			/* number of rows of data */
			uchar		delete_flag;		/* delete the current rows ? */
			uchar		more_to_follow;		/* are more dbs to follow ? */
			uchar		pad[6];
			uchar		data[1];
		}load_risdbs;

		/* RIS_LOAD_RISSCHEMAS_CODE */
		struct ris_clisrv_buf_load_risschemas
		{
			offset		schemas;			/* offset to schema data */
			uint		schema_count;		/* number of rows of data */
			uchar		delete_flag;		/* delete the current rows ? */
			uchar		more_to_follow;		/* are more schemas to follow ? */
			uchar		pad[6];
			uchar		data[1];
		}load_risschemas;

		/* RIS_DROP_SCHEMA_CODE */
		struct ris_clisrv_buf_drop_schema
		{
			uchar		force_flag;	
		} drop_schema;

		/* RIS_CLOSE_CODE */
		struct ris_clisrv_buf_close
		{
			short old_stmt_id;
		} close;

		/* RIS_CLEANUP_CODE */
		struct ris_clisrv_buf_cleanup
		{
			short old_stmt_id;
		} cleanup;

		/* RIS_GRANT_SCHEMA_CODE */
        /* RIS_GRANT_CONNECT_CODE */
        /* RIS_GRANT_RESOURCE_CODE */
        /* RIS_REVOKE_SCHEMA_CODE */
        /* RIS_REVOKE_CONNECT_CODE */
        /* RIS_REVOKE_RESOURCE_CODE */
        struct ris_clisrv_buf_grant_revoke
        {
            char login[RIS_MAX_ID_SIZE];    /* login */
        } grant_revoke;

		/* These code require no additional space */
		/* RIS_CLOSE_SCHEMA_CODE */
		/* RIS_AUTOCOMMIT_ON_CODE */
		/* RIS_AUTOCOMMIT_OFF_CODE */
		/* RIS_COMMIT_WORK_CODE */
		/* RIS_ROLLBACK_WORK_CODE */
		/* RIS_GET_SCHEMA_GRANTEES  formerly INQUIRE_DEPENDENT_SCHEMAS */
	} buf;
} ris_clisrv_buf;

typedef struct ris_srvcli_buf
{
	uint	status;				/* return status */
	uint	timestamp_count;
	union
	{

		/* RIS_FETCH_BUF_CODE */
        /* RIS_FETCH_BUF_CODE_4 */
		/* We use one byte of the pad field for the blob_to_follow flag */
		struct ris_srvcli_buf_fetch
		{
			uint		row_count;		/* # of rows */
			uchar		more_to_follow;	/* are more buffers to follow ? */
			uchar		blob_to_follow;	/* blob data to follow ? */
			uchar		pad[2];
			uchar		data[1];
		} fetch;


			/* NOTE: JP 09/93
			** Earlier this structure had a pad[4] in place where we have
			** the "tabid" now. For version 5 the server needs to return the
			** table_id on this opcode and to return this the pad[4] has been
			** used instead of adding a new structure. The V4 client is anyway
			** not going to look at this field.
			** If anybody adds anything new to this structure, then inform 
			** the server development people. Or else things might get 
			** screwed up.
			*/

        /* RIS_GET_TAB_CODE_4 */
        /* RIS_GET_TAB_NOVERIFY_CODE_4 */
        struct ris_srvcli_buf_get_tab_4
        {
            uint        count;          /* # of attr structures */
            int         tabid;
            uchar       data[1];
        } get_tab_4;

        /* RIS_GET_TAB_CODE */
        /* RIS_GET_TAB_NOVERIFY_CODE */
        struct ris_srvcli_buf_get_tab
        {
            uint        count;          /* # of attr structures */
            int         tabid;
            char        extern_relname[RIS_MAX_ID_SIZE];
            char        tabowner[RIS_MAX_ID_SIZE];      /* table owner */
            uchar       pad[16];        /* future usage , 8 byte aligned */
            uchar       data[1];
        } get_tab;

		/* RIS_GET_TABTYPE_CODE */
		struct ris_srvcli_buf_get_tabtype
		{
			uchar		data;
		} get_tabtype;

		/* RIS_GET_ACCESS_CODE */
		/* RIS_GET_ALL_ACCCESS_CODE */
		/* RIS_GET_SCHEMA_GRANTORS_CODE */

		struct ris_srvcli_buf_get_access
		{
			uint		count;			/* # of access structures */
			uchar		more_to_follow;	/* are more buffers to follow ? */
			uchar		pad[3];
			uchar		data[1];
		} get_access;

		/* RIS_GET_SCHEMA_GRANTEES_CODE */
		struct ris_srvcli_buf_get_grantees
		{
			uint		count;			/* # of schema names */
			uchar		more_to_follow;	/* are more buffers to follow ? */
			uchar		pad[3];
			uchar		data[1];
		} get_grantees;

		/* RIS_PREP_DESC_DECL_OPEN_CODE */
		struct ris_srvcli_buf_pddo
		{
			void	*dbms;				/* dbms info */
		} pddo;


		/* RIS_PREP_EXEC_CODE */
		struct ris_srvcli_buf_pe
		{
			void	*dbms;				/* dbms info */
		} pe;

		/***********  BLOB  ********************/

		/* RIS_FETCH_BLOB_CODE */
		struct ris_srvcli_fetch_blob
		{
			uint		xfercount;		/* The size of blob fetched */
			uchar		more_to_follow;	/* are more blob data to follow ? */
			uchar		pad[3];
			uchar		data[1];
		} fetch_blob;

        /* RIS_PREP_EXEC_DEFERRED_CODE */
        struct ris_srvcli_buf_pe_deferred
        {
            void    *dbms;              /* dbms info */
        } pe_deferred;

        /* RIS_EXEC_BLOB_CODE */
        struct ris_srvcli_buf_exec_blob
        {
           int x_fercount;        /* The size of the data inserted */ 
        } exec_blob;

		/***********  BLOB  ********************/

		/* RIS_CRE_SCH_GET_GRANTEES_CODE_4 */
		/* RIS_CRE_DBASE_GET_GRANTEES_CODE_4 */
		struct ris_srvcli_buf_create_schema_4
		{
			int		pid;
			uchar	pad1[2];
			char	warning;
			char	xns_addr[RIS_MAX_NODE_SIZE];
			char	tcp_addr[RIS_MAX_NODE_SIZE];
			char	dnp_addr[RIS_MAX_NODE_SIZE];
			char	lu62_addr[RIS_MAX_NODE_SIZE];

            /* GET_SCHEMA_GRANTEES */
            uint        count;          /* # of schema names */
            uchar       more_to_follow; /* are more buffers to follow ? */
            uchar       pad2[3];
            uchar       data[1];
		} create_schema_4;

		 	/* RIS_CRE_SCH_GET_GRANTEES_CODE */
            /* RIS_CRE_DBASE_GET_GRANTEES_CODE */
        struct ris_srvcli_buf_create_schema
        {
            int     pid;
            uchar   pad1[2];
            char    warning;
            char    xns_addr[RIS_MAX_NODE_SIZE];
            char    tcp_addr[RIS_MAX_NODE_SIZE];
            char    dnp_addr[RIS_MAX_NODE_SIZE];
            char    lu62_addr[RIS_MAX_NODE_SIZE];
            
            /* DB_user for login */
            char    dict_dbusr[RIS_MAX_ID_SIZE];
            char    schown_dbusr[RIS_MAX_ID_SIZE];
            char    login_dbusr[RIS_MAX_ID_SIZE];
            uchar   pad3[1];

            /* GET_SCHEMA_GRANTEES */
            uint        count;          /* # of schema names */
            uchar       more_to_follow; /* are more buffers to follow ? */
            char        privilege;   /* version 5--for returning privilege */
            uchar       pad2[2];
            uchar       data[1];
        } create_schema;

		/* RIS_OPEN_SCHEMA_CODE_4 */
		struct ris_srvcli_buf_open_schema_4
		{
			int		pid;
			char	warning;
			char	xns_addr[RIS_MAX_NODE_SIZE];
			char	tcp_addr[RIS_MAX_NODE_SIZE];
			char	dnp_addr[RIS_MAX_NODE_SIZE];
			char	lu62_addr[RIS_MAX_NODE_SIZE];
			char	schpass[RIS_MAX_PASSWD_SIZE];
		} open_schema_4;

		/* RIS_OPEN_SCHEMA_CODE */
        struct ris_srvcli_buf_open_schema
        {
            int     pid;
            char    warning;
            char    xns_addr[RIS_MAX_NODE_SIZE];
            char    tcp_addr[RIS_MAX_NODE_SIZE];
            char    dnp_addr[RIS_MAX_NODE_SIZE];
            char    lu62_addr[RIS_MAX_NODE_SIZE];
            char    schpass[RIS_MAX_PASSWD_SIZE];
            /* DB_user for login */
            char    dict_dbusr[RIS_MAX_ID_SIZE];
            char    schown_dbusr[RIS_MAX_ID_SIZE];
            char    login_dbusr[RIS_MAX_ID_SIZE];
            char    privilege;      /*  version 5--for returning privilege */
        } open_schema;

        /* RIS_ALTER_RACF_PWD_CODE */
		/* RIS_ALTER_RACF_PWD_CODE_4 */
		struct ris_srvcli_buf_schema_db
		{
			char	warning;
		} schema_db;

		/* ERROR */
		struct ris_srvcli_buf_error
		{
			int			dbstmt_len;	/* length of db stmt */
			rissqlca	dbca;		/* db sqlca */
			void		*dbms;		/* dbms info */
			uchar		rollback;	/* did a rollback occur */
			uchar		data[1];	/* variable length */
		} error;
	} buf;
} ris_srvcli_buf;

/*
**	Variables
*/

CLISRV_EXTERN  char *RIS_srv_codes[RIS_LAST_SRV_CODE]

#ifdef CLISRV_GLOBAL_DEFINE
= {
/*  0 */	"UNUSED SRV CODE 0",
/*  1 */	"UNUSED SRV CODE 1",

/*  2 */	"RIS_OPEN_SCHEMA_CODE_4",
/*  3 */	"RIS_CLOSE_SCHEMA_CODE",
/*  4 */	"RIS_CRE_SCH_GET_GRANTEES_CODE_4",
/*  5 */	"RIS_DROP_SCHEMA_CODE",
/*  6 */	"RIS_NEW_SCHPASS_CODE",
/*  7 */	"RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE_4",
/*  8 */	"RIS_CREATE_USER_CODE",

/*  9 */	"RIS_ALTER_TABLE_CODE_4",
/* 10 */	"RIS_CREATE_TABLE_CODE_4",
/* 11 */	"RIS_DROP_TABLE_CODE_4",
/* 12 */	"RIS_CREATE_VIEW_CODE_4",
/* 13 */	"RIS_DROP_VIEW_CODE_4",
/* 14 */	"RIS_CREATE_INDEX_CODE_4",
/* 15 */	"RIS_DROP_INDEX_CODE_4",
/* 16 */	"RIS_UPD_ACCESS_CODE",
/* 17 */	"RIS_ALT_SCHEMA_EXCLUDE_CODE_4",
/* 18 */	"RIS_ALT_SCHEMA_INCLUDE_CODE_4",

/* 19 */	"RIS_EXEC_NOW_CODE",
/* 20 */	"RIS_PREP_EXEC_CODE",
/* 21 */	"RIS_EXEC_CODE",
/* 22 */	"RIS_PREP_DESC_DECL_OPEN_CODE",
/* 23 */	"RIS_OPEN_CODE",
/* 24 */	"RIS_FETCH_BUF_CODE_4",
/* 25 */	"RIS_CLOSE_CODE",
/* 26 */	"RIS_CLEANUP_CODE",

/* 27 */	"RIS_LOCK_TABLES_CODE",

/* 28 */	"RIS_COMMIT_WORK_CODE",
/* 29 */	"RIS_ROLLBACK_WORK_CODE",
/* 30 */	"RIS_AUTOCOMMIT_ON_CODE",
/* 31 */	"RIS_AUTOCOMMIT_OFF_CODE",

/* 32 */	"RIS_GET_ALL_ACCESS_CODE_4",
/* 33 */	"RIS_GET_ACCESS_CODE_4",
/* 34 */	"RIS_GET_TAB_CODE_4",
/* 35 */	"RIS_GET_TAB_NOVERIFY_CODE_4",
/* 36 */	"RIS_GET_TABTYPE_CODE_4",
/* 37 */	"RIS_GET_SCHEMA_GRANTORS_CODE",
/* 38 */	"RIS_GET_SCHEMA_GRANTEES_CODE",

/* 39 */	"RIS_LOAD_RISDBS_CODE",
/* 40 */	"RIS_LOAD_RISSCHEMAS_CODE_4",

/* 41 */	"RIS_GROW_CLI_TO_SRV_BUF_CODE",
/* 42 */	"RIS_GROW_SRV_TO_CLI_BUF_CODE",
/* 43 */	"RIS_DBG_CODE",
/* 44 */	"RIS_ALTER_RACF_PWD_CODE_4",
/* 45 */	"RIS_BLANKSTRIP_ON_CODE",
/* 46 */	"RIS_BLANKSTRIP_OFF_CODE",
/* 47 */    "RIS_CRE_SCH_GET_GRANTEES_CODE",
/* 48 */    "RIS_CRE_DBASE_SCH_GET_GRANTEES_CODE",
/* 49 */    "RIS_OPEN_SCHEMA_CODE",
/* 50 */    "RIS_GET_TAB_CODE",
/* 51 */    "RIS_GET_TAB_NOVERIFY_CODE",
/* 52 */    "RIS_GET_TABTYPE_CODE",
/* 53 */    "RIS_ALT_SCHEMA_INCLUDE_CODE",
/* 54 */    "RIS_ALT_SCHEMA_EXCLUDE_CODE",
/* 55 */    "RIS_GET_ALL_ACCESS_CODE",
/* 56 */    "RIS_GET_ACCESS_CODE",
/* 57 */    "RIS_LOAD_RISSCHEMAS_CODE",
/* 58 */    "RIS_GRANT_SCHEMA_CODE",
/* 59 */    "RIS_GRANT_CONNECT_CODE",
/* 60 */    "RIS_GRANT_RESOURCE_CODE",
/* 61 */    "RIS_REVOKE_SCHEMA_CODE",
/* 62 */    "RIS_REVOKE_CONNECT_CODE",
/* 63 */    "RIS_REVOKE_RESOURCE_CODE",
/* 64 */    "RIS_EXEC_DEFERRED_CODE",
/* 65 */    "RIS_PREP_EXEC_DEFERRED_CODE",
/* 66 */    "RIS_EXEC_BLOB_CODE",
/* 67 */    "RIS_FETCH_BLOB_CODE",
/* 68 */    "RIS_FETCH_BUF_CODE",
/* 69 */    "RIS_ALT_SCHEMA_SECURE_CODE",          
/* 70 */  	"RIS_ALTER_TABLE_CODE",
/* 71 */    "RIS_CREATE_INDEX_CODE",
/* 72 */  	"RIS_CREATE_TABLE_CODE",
/* 73 */  	"RIS_CREATE_VIEW_CODE",
/* 74 */    "RIS_DROP_TABLE_CODE",
/* 75 */    "RIS_DROP_VIEW_CODE",
/* 76 */    "RIS_DROP_INDEX_CODE",
/* 77 */    "RIS_ALTER_RACF_PWD_CODE",
}
#endif
;

#undef uint
#undef ushort
#undef uchar
#undef offset

#endif

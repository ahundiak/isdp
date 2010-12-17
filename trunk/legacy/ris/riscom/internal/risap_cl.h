/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/* 
**	NAME:							risap_cl.h 
**	AUTHORS:						Terry McIntyre 
**	CREATION DATE:					8/91 
**	ABSTRACT: 
**	
**	REVISION HISTORY: 

	New opcodes added: 
		RISCLI_EXEC_DEFERRED_CODE           
		RISCLI_EXEC_BLOB_CODE             
		RISCLI_FETCH_BLOB_CODE          
		RISCLI_FETCH_2_CODE			

	New structures added:
       	ris_appcli_buf_exec_blob
		ris_appcli_buf_fetch_2
		ris_appcli_fetch_blob

       	ris_cliapp_buf_exec_deferred
       	ris_cliapp_buf_exec_blob
       	ris_cliapp_buf_fetch_blob
       	ris_cliapp_buf_fetch_2
											James Chang 6/93
*/

#ifndef RISAP_CL_H
#define RISAP_CL_H

#ifdef APPCLI_GLOBAL_DEFINE
#define APPCLI_EXTERN
#define APPCLI_INIT(value) = value
#else
#define APPCLI_EXTERN extern
#define APPCLI_INIT(value)
#endif
 
/*
**	INCLUDES
*/
#include <time.h>
#include "rislimit.h"
#include "ris.h"

/*
**	DEFINES
*/
#define RIS_ERRCODE	(risca->sqlcode)
#define RIS_ERRPOS	(risca->sqlerrd[4])
#define RIS_ERRMSGC	(risca->sqlerrm.sqlerrmc)
#define RIS_ERRMSGL	(risca->sqlerrm.sqlerrml)
#define RIS_ERRSTMT	(risca->sqlstmt)

#define	RISCLI_UNUSED_CODE					0
#define	RISCLI_INIT_CODE					1
#define	RISCLI_CLEAR_CODE					2
#define	RISCLI_TERM_CODE					3
#define	RISCLI_CLOSE_CODE					4
#define	RISCLI_DEBUG_CODE					5
#define	RISCLI_EXECUTE_CODE					6
#define	RISCLI_FETCH_CODE_4					7
#define	RISCLI_PREPARE_CODE					8
#define	RISCLI_UNUSED_9						9
#define	RISCLI_CHECKSUM_SCHEMA_FILE_CODE	10
#define	RISCLI_LOCATE_SCHEMA_FILE_CODE		11
#define	RISCLI_GET_SCHEMA_FILE_CODE			12
#define	RISCLI_SHOW_HASH_TABLE_CODE			13
#define	RISCLI_SHOW_MEMORY_CODE				14
#define	RISCLI_SHOW_SERVERS_CODE			15
#define	RISCLI_SHOW_STMTS_CODE				16
#define RISCLI_DICT_ROLLBACK_CODE			17
#define RISCLI_SCHEMA_MGR_CODE				18
#define RISCLI_GET_FLAGS_CODE				19
#define	RISCLI_SHOW_STRUCT_MGRS_CODE		20
#define	RISCLI_GROW_APP_TO_CLI_BUF_CODE		21
#define	RISCLI_GROW_CLI_TO_APP_BUF_CODE		22
#define	RISCLI_REPORT_SS_ERROR_CODE			23
#define	RISCLI_GET_SS_NAMES_CODE			24
#define	RISCLI_GET_SS_DEF_CODE				25
#define	RISCLI_GET_SCH_IN_TRANS_CODE		26
#define RISCLI_EXEC_DEFERRED_CODE           27
#define RISCLI_EXEC_BLOB_CODE               28
#define RISCLI_FETCH_BLOB_CODE            	29
#define RISCLI_FETCH_CODE					30 


#define	RISCLI_LAST_CODE				    31


#define RIS_APPCLI_HDR_SIZE		((int)&(((ris_appcli_buf *)0)->buf))
#define RIS_CLIAPP_HDR_SIZE		((int)&(((ris_cliapp_buf *)0)->buf))

/*
**	Values for RISapp_clear()
*/
#define DONT_SET_SQLCODE		0
#define SET_SQLCODE				1
#define DONT_CLEAR_CLIENT		0
#define CLEAR_CLIENT			1


/*
**	TYPES
*/
#define uint unsigned int
#define ushort unsigned short
#define uchar unsigned char
#define offset unsigned int

/*
**	Client process parms
*/
typedef struct ris_client_parms_s
{
    char			protocol;
    char			address[RIS_MAX_NODE_SIZE];
    char			username[RIS_MAX_ID_SIZE];
    char			password[RIS_MAX_PASSWD_SIZE];
} ris_client_parms_s;

/*
**	Schema file parms
*/
typedef struct ris_schfile_parms_s
{
    char			protocol;
    char			address[RIS_MAX_NODE_SIZE];
    char			username[RIS_MAX_ID_SIZE];
    char			password[RIS_MAX_PASSWD_SIZE];
    char			filename[RIS_MAX_PATH_SIZE];
    int				lock_file_retry;
} ris_schfile_parms_s;

/*
**	Misc. parms
*/
typedef struct ris_parms_s
{
    int	shm_seg_size;
    int	max_locals;
    int	max_rows;
    int	max_buf_size;
	int	max_static_stmts;
	int	max_user_stmts;
	int	max_secondary_schemas;
	int	max_transactions;
	int	max_tab_in_mem;
} ris_parms_s;

typedef struct risnetvstate
{
	time_t start_net_v_time;
	time_t start_buff_full_time;
	uint buffer_full_flag;
	uint buffer_empty_flag;
	uint actual_timestamp_count;
} risnetvstate;

typedef struct ristimestamp
{
    uint timestamp_interval;
    uint initial_timeout;
    uint timestamp_tolerance;
    uint buffer_full_size;
    uint buffer_full_timeout;
     int response_interval;
} ristimestamp;


/*	Application to client buffer */

typedef struct ris_appcli_buf
{
	uchar	opcode;
	uchar	execute_mode;
	short	stmt_id;
	uchar	pad[4];
	union
	{
		/* RISCLI_INIT_CODE */
		struct ris_appcli_buf_client_init
		{
			ris_schfile_parms_s	schfile_parms;
			ris_client_parms_s	client_parms;
			ris_parms_s			parms;
			ristimestamp        timestamp_parms;
			uint				debug;
			uchar				lang;
			uchar				maj;
			uchar				min;
			uchar				rel;
		} client_init;

		/* RISCLI_DEBUG_CODE */
		struct ris_appcli_buf_debug
		{
			int		server_flag;
			uint	data;
		} debug;

		/* RISCLI_LOCATE_SCHEMA_FILE_CODE */
		struct ris_appcli_buf_locate_schfile
		{
			ris_schfile_parms_s	parms;
		}locate_schfile;

		/* RISCLI_PREPARE_CODE */
		struct ris_appcli_buf_prep
		{
			int			query_len;
			char		data[1];
		} prep;

		/* RISCLI_EXECUTE_CODE */
        /* RISCLI_EXEC_DEFERRED_CODE */
		struct ris_appcli_buf_exec
		{
			char		pad[32];	/*	VERY IMPORTANT: This pad must be the
										same size as all fields before the
										data field in the structure
										ris_clisrv_buf_pddo. This way the data
										fields are in the same position. */
			char		data[1];	/* 	Should be 8 byte aligned */
		} exec;

		/*******         BLOB ********/
		
       /* RISCLI_EXEC_BLOB_CODE */

       	struct ris_appcli_buf_exec_blob
        {
            uint        xfcount;     /* The length of blob for this transfer */
            short		blob_col_pos;    /* The position of blob sqlvar */
            uchar       more_to_follow;
            uchar       file_used;
			char        pad[24];     /* 32 byte aligned. It is not necessary
										but good to have.   */
            char        data[1];     /* The area holding  blob data
                                        or blob filenames */
        } exec_blob;
	

        /* RISCLI_FETCH_BUF_CODE */
        struct ris_appcli_buf_fetch_4
        {
            uint    row_count;          /* number of rows expected */
        } fetch_4;

  
		/********         BLOB 		********/

		/* RISCLI_FETCH_BUF_CODE */
		struct ris_appcli_buf_fetch
		{
			offset   	out_data;   /* offset to blob structures in data */   
			offset   	file_names; /* offset to output file_names in data */   
		   	uint		row_count;	/* number of rows expected */
		   	short       blob_count;  /* num of blob columns involved  */    
  			uchar       pad[18];  		
           	char        data[1];   	/*  32 byte aligned */
		} fetch;

		/********          BLOB ********/

		struct ris_appcli_fetch_blob
		{
            short		blob_col_pos;    /* The position of blob sqlvar */
            uchar       file_used;
		} fetch_blob;


		/* RISCLI_CLEAR_BUF_CODE */
		struct ris_appcli_buf_clear
		{
			int		set_sqlcode;		/* set_sqlcode for superschema */
		} clear;

		/* RISCLI_SCHEMA_MGR_CODE */
		struct ris_appcli_buf_schema_mgr
		{
			char	mode;
			char	data[RIS_MAX_ID_SIZE];
			char	str[RIS_MAX_PASSWD_SIZE];
		} schema_mgr;

		/* RISCLI_GROW_APP_TO_CLI_BUF_CODE */
		/* RISCLI_GROW_CLI_TO_APP_BUF_CODE */
		struct ris_appcli_buf_grow_buf
		{
			int	new_size;
		} grow_buf;

		/* RISCLI_GET_SS_DEF_CODE */
		struct ris_appcli_buf_get_ss_def
		{
			char	ss_name[RIS_MAX_ID_SIZE];
		} get_ss_def;

		/* RISCLI_REPORT_SS_ERROR_CODE */
		struct ris_appcli_buf_report_ss_error
		{
			char	ss_name[RIS_MAX_ID_SIZE];
		} report_ss_error;
	} buf;
}ris_appcli_buf;

/*
**	Client to application buffer
*/
typedef struct ris_cliapp_buf
{
	int		status;
	char	warning;
	char	pad[3];
	union
	{
		/* RISCLI_INIT_CODE */
		struct ris_cliapp_buf_init
		{
			char xns_addr[RIS_MAX_NODE_SIZE];
			char tcp_addr[RIS_MAX_NODE_SIZE];
			char dnp_addr[RIS_MAX_NODE_SIZE];
			char lu62_addr[RIS_MAX_NODE_SIZE];
		} init;

		/* RISCLI_PREPARE_CODE */
		struct ris_cliapp_buf_prep
		{
			offset		in_sqlvars;
			offset		out_sqlvars;
			offset		tab_list;
			int			in_count;
			int			out_count;
			int			tab_count;
			int			in_len;
			int			out_len;
			int			fetch_buf_size;
			int			write_buf_size;
			char		schname[RIS_MAX_ID_SIZE];
			char		stmt_type;
			char		pad[3];
			char		data[1];
		} prep;

		/* RIS_EXEC_CODE */
       /* RIS_EXEC_DEFERRED_CODE */
		struct ris_cliapp_buf_exec
		{
			offset  eot_schname_list;
			offset  clear_stmt_list;
			int		eot_schname_count;
			int		clear_stmt_count;
			char	RIS_def_schname[RIS_MAX_ID_SIZE];
			char	data[1];
		} exec;


        /* RIS_EXEC_BLOB_CODE */
        struct ris_cliapp_buf_exec_blob
        {
           int x_fercount;        /* The size of the data inserted */
        } exec_blob;

		
        /* RIS_FETCH_BLOB_CODE */
        struct ris_cliapp_fetch_blob
        {
            uint       	xfercount; 	/* The size of blob data fetched */
            uchar       more_to_follow; /* are more blob data to follow ? */
            uchar       pad[3];
            uchar       data[1];
        } fetch_blob;

		/* RIS_FETCH_BUF_CODE */
       	/* RIS_FETCH_BUF_CODE_4 */
		struct ris_cliapp_buf_fetch
		{
			uint		row_count;		/* # of rows */
			uchar		more_to_follow;	/* are more buffers to follow ? */
			uchar		blob_to_follow; /* blob data to follow ? */
		   	uchar       pad[2];          	
			uchar		data[1];
		} fetch;

		/* RIS_CLOSE_CODE */
		struct ris_cliapp_buf_close
		{
			int		eot_schname_count;
			char	data[1];
		} close;

		/* RIS_CLEAR_CODE */
		struct ris_cliapp_buf_clear
		{
			int		eot_schname_count;
			char	data[1];
		} clear;

		struct ris_cliapp_buf_string
		{
			int			len;
			char		more_to_follow;
			char		data[1];	/* variable length */
		} string;

		/* RIS_SCHEMA_MGR_CODE */
		struct ris_cliapp_buf_schema_mgr
		{
			char	RIS_def_schname[RIS_MAX_ID_SIZE];
		} schema_mgr;

		/* RISCLI_GET_FLAGS_CODE */
		struct ris_cliapp_buf_get_flags
		{
			int		ansi_mode;
			int		enable_dbms;
			int		verify_mode;
			int		blankstrip_mode;
			int		autocommit;
			int		autorename;
		} get_flags;

		/* RISCLI_REPORT_SS_ERROR */
		struct ris_cliapp_buf_report_ss_error
		{
			rissqlca	risca;
			rissqlca	dbca;
			offset		risstmt;
			offset		dbstmt;
			int			risstmt_len;
			int			dbstmt_len;
			char		ss_name[RIS_MAX_ID_SIZE];
			char		more_to_follow;
			char 		data[1];	/* variable length */
		} report_ss_error;

		/* RISCLI_GET_SS_NAMES_CODE */
		struct ris_cliapp_buf_get_ss_names
		{
			int		ss_count;
			char	data[1];
		} get_ss_names;

		/* RISCLI_GET_SS_DEF_CODE */
		struct ris_cliapp_buf_get_ss_def
		{
			int		ss_count;
			char	data[1];
		} get_ss_def;

		/* RISCLI_GET_SCH_IN_TRANS_CODE */
		struct ris_cliapp_buf_get_sch_in_trans
		{
			int		sch_count;
			char	data[1];
		} get_sch_in_trans;

		/* error */
		struct ris_cliapp_buf_error
		{
			rissqlca	risca;
			rissqlca	dbca;
			offset		risstmt;
			offset		dbstmt;
			offset		eot_schname_list;
			offset		clear_stmt_list;
			int			clear_stmt_count;
			int			eot_schname_count;
			int			risstmt_len;
			int			dbstmt_len;
			int			test_completion;
			char 		data[1];	/* variable length */
		} error;
	} buf;
}ris_cliapp_buf;


/*
**	VARIABLES
*/
APPCLI_EXTERN  ris_parms_s		RIS_parms;
APPCLI_EXTERN  ristimestamp      RIS_timestamp;
APPCLI_EXTERN  uint				RIS_max_stmts;
APPCLI_EXTERN  uint				RIS_max_dict_stmts;
APPCLI_EXTERN  uint				RIS_max_secondary_stmts;

APPCLI_EXTERN  char *RIS_cli_codes[RISCLI_LAST_CODE]
#ifdef APPCLI_GLOBAL_DEFINE
= {
	"RISCLI_UNUSED_CODE",
	"RISCLI_INIT_CODE",
	"RISCLI_CLEAR_CODE",
	"RISCLI_TERM_CODE",
	"RISCLI_CLOSE_CODE",
	"RISCLI_DEBUG_CODE",
	"RISCLI_EXECUTE_CODE",
	"RISCLI_FETCH_CODE_4",
	"RISCLI_PREPARE_CODE",
	"RISCLI_UNUSED_9",
	"RISCLI_CHECKSUM_SCHEMA_FILE_CODE",
	"RISCLI_LOCATE_SCHEMA_FILE_CODE",
	"RISCLI_GET_SCHEMA_FILE_CODE",
	"RISCLI_SHOW_HASH_TABLE_CODE",
	"RISCLI_SHOW_MEMORY_CODE",
	"RISCLI_SHOW_SERVERS_CODE",
	"RISCLI_SHOW_STMTS_CODE",
	"RISCLI_DICT_ROLLBACK_CODE",
	"RISCLI_SCHEMA_MGR_CODE",
	"RISCLI_GET_FLAGS_CODE",
	"RISCLI_SHOW_STRUCT_MGRS_CODE",
	"RISCLI_GROW_APP_TO_CLI_BUF_CODE",
	"RISCLI_GROW_CLI_TO_APP_BUF_CODE",
	"RISCLI_REPORT_SS_ERROR_CODE",
	"RISCLI_GET_SS_NAMES_CODE",
	"RISCLI_GET_SS_DEF_CODE",
	"RISCLI_GET_SCH_IN_TRANS_CODE",
    "RISCLI_EXEC_DEFERRED_CODE",
    "RISCLI_EXEC_BLOB_CODE",
    "RISCLI_FETCH_BLOB_CODE",
	"RISCLI_FETCH_BUF_CODE", 
}
#endif
;

#undef uint
#undef ushort
#undef uchar
#undef offset

#endif

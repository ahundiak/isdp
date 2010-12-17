/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							riscl_pa.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:

			The risattr->asize->len is changed from type ushort to type 
			unint to accommodate the length of BLOB.

			Conseqeutly,  ristab, ristree and risaccess are also changed.
			We put in extra three words for each structure for possible
			future usage.


													James Chang
													    6/93

           changed fieldname 'usr' to 'schowner' in risschema
           structure to reflect correct meaning : Shiva 11/10/93
           added fields to risschema structure to store DBMS user
           names corresponding to the login (now useful in Sybase)
*/
 
#ifndef RISCL_PA_H
#define RISCL_PA_H

/*
**	INCLUDES
*/
#include "rislimit.h"
#include "risap_cl.h"
#include "risinsql.h"
#include "net.h"
#include "arch.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

#define uint unsigned int
#define ushort unsigned short
#define uchar unsigned char
#define offset unsigned int

typedef struct rissql
{
	char				*query;
	struct internal_sqlda		*input;
	struct internal_sqlda		*output;
	struct risschema	*schema;
	uint				*misc;
	uint				*dbms;
	uint				input_len;
	uchar				rollback;
	uchar				stmt_type;
	char				schname[RIS_MAX_ID_SIZE];
    char                ris_relname[RIS_MAX_ID_SIZE];
    char                ext_relname[RIS_MAX_ID_SIZE];
    char                relowner[RIS_MAX_ID_SIZE];
    uchar               reltype;
    char                relname[RIS_MAX_ID_SIZE];/* Area to store ris table
													name for CREATE INDEX */
} rissql;

typedef struct risgrantee
{
	char				schname[RIS_MAX_ID_SIZE];
	struct risgrantee	*next;
} risgrantee;

typedef struct risaccess
{
	char				schname[RIS_MAX_ID_SIZE];
	char				relowner[RIS_MAX_ID_SIZE];
	char				relname[RIS_MAX_ID_SIZE];
	int					relid;
	char				colname[RIS_MAX_ID_SIZE];
	char				grantor[RIS_MAX_ID_SIZE];
	char				grantee[RIS_MAX_ID_SIZE];
	char				auth[RIS_AUTH_SIZE];
	char				insert_flag;	/* temp flag to send to server */
	char				flag;			/* which value in ptr union is valid */
	struct risaccess	*next;
	union
	{
		struct ristab	*tab;
		struct risattr	*attr;
	} ptr;
} risaccess;

typedef struct risstmtstat
{
	char			schname[RIS_MAX_ID_SIZE];
	short			stmt_id;
	char			state;
    struct rissqlca *risca;
    struct rissqlca *dbca;
} risstmtstat;

typedef struct risattr
{
	char				attrname[RIS_MAX_ID_SIZE];
  	char                extern_attrname[RIS_MAX_ID_SIZE];
	uchar				atype;
	union asize
	{
		uint			len;
		struct
		{
#if defined (sun) || defined(__Sol2__) || defined(__hpux__)
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
ERROR -- NO CODE
#endif
		} dec;
	} asize;
	short	dbsqltype;	/* db sql data type of input or output parameter */
	uint	dbsqllen;	/* db length of input or output data buffer      */
	struct ristab		*tab;
	struct risaccess	*acc;
	struct risattr		*next;
} risattr;

typedef struct risifxparms_s
{
	char	dir[RIS_MAX_PATH_SIZE];
	char	sqlexec[RIS_MAX_PATH_SIZE];
	char	dbtemp[RIS_MAX_PATH_SIZE];
	char	tbconfig[RIS_MAX_PATH_SIZE];
	char	new_database;
	char	new_user;
	char	new_resource_user;
	char	new_dba_user;
} risifxparms;

typedef struct rissybparms_s
{
	char	osuser[RIS_MAX_ID_SIZE];
	char	ospass[RIS_MAX_PASSWD_SIZE];
	char	dir[RIS_MAX_PATH_SIZE];
	char	dsquery[RIS_MAX_ID_SIZE];
	char	sybifile[RIS_MAX_ID_SIZE];
} rissybparms;

typedef struct rismssqlparms_s
{
    char    osuser[RIS_MAX_ID_SIZE];
    char    ospass[RIS_MAX_PASSWD_SIZE];
    char    dir[RIS_MAX_PATH_SIZE];
    char    dsquery[RIS_MAX_ID_SIZE];
    char    mssqlifile[RIS_MAX_ID_SIZE];
} rismssqlparms;


typedef struct risigsparms_s
{
	char	dir[RIS_MAX_PATH_SIZE];				/* II_SYSTEM value */
} risigsparms;

typedef struct risoraparms_s
{
	char	dir[RIS_MAX_PATH_SIZE];			/* init.ora parms */
	char	osuser[RIS_MAX_ID_SIZE];
	char	ospass[RIS_MAX_PASSWD_SIZE];
} risoraparms;

typedef struct risdb2parms_s
{
	char	osuser[RIS_MAX_ID_SIZE];					/* TCP and LU6.2 */
	char	ospass[RIS_MAX_PASSWD_SIZE];				/* TCP and LU6.2 */
	char	arch[RIS_MAX_ID_SIZE];						/* TCP and LU6.2 */
	char	os[RIS_MAX_ID_SIZE];						/* TCP and LU6.2 */
	char	net_protocol[RIS_MAX_ID_SIZE];				/* TCP and LU6.2 */
	char	env[RIS_MAX_ID_SIZE];						/*         LU6.2 */
	char	host_program[RIS_MAX_HOST_PROGRAM_SIZE];	/*         LU6.2 */
	char	ris_lu[RIS_MAX_ID_SIZE];					/*         LU6.2 */
	char	host_lu[RIS_MAX_ID_SIZE];					/*         LU6.2 */
	char	mode[RIS_MAX_ID_SIZE];						/*         LU6.2 */
	char	group[RIS_MAX_GROUP_SIZE];					/* TCP and LU6.2 */

/* Added for tcp support */
	char	node[RIS_MAX_ID_SIZE];						/* TCP           */
	ushort	port;										/* TCP           */

	char	pad[4]; /* critical for client-server buffer structure */
} risdb2parms;

typedef struct risos400parms_s
{
    char    osuser[RIS_MAX_ID_SIZE];                    /* TCP and LU6.2 */
    char    ospass[RIS_MAX_PASSWD_SIZE];                /* TCP and LU6.2 */
    char    net_protocol[RIS_MAX_ID_SIZE];              /* TCP and LU6.2 */
    char    host_program[RIS_MAX_OS400_HOST_PROGRAM_SIZE];  /*  OS/400 */
    char    ris_lu[RIS_MAX_ID_SIZE];                    /*         LU6.2 */
    char    host_lu[RIS_MAX_ID_SIZE];                   /*         LU6.2 */
    char    mode[RIS_MAX_ID_SIZE];                      /*         LU6.2 */
    char    group[RIS_MAX_GROUP_SIZE];                  /* TCP and LU6.2 */

/* Added for tcp support */
    char    node[RIS_MAX_ID_SIZE];                      /* TCP           */
    char    ris_dict_dbname[RIS_MAX_OS400_DIC_DBNAME_SIZE];	/* DICT_DBANME	*/
    char    pad1[1];                                    /* 2 byte alignment */
    ushort  port;                                       /* TCP           */
    char    pad[4]; /* critical for client-server buffer structure */
} risos400parms;

typedef struct risrdbparms_s
{
	char	eat_me;
} risrdbparms;

typedef struct risdb
{
	ushort	dbid;
	uchar	dtype;
	char	dbname[RIS_MAX_PATH_SIZE];
	struct
	{
		uchar	protocol;
		char	netaddr[RIS_MAX_NODE_SIZE];
	} pathways[RIS_MAX_PROTOCOLS];
	union
	{
		risifxparms ifx;
		risigsparms igs;
		risoraparms ora;
		risdb2parms db2;
		risrdbparms rdb; 
		rissybparms syb;
    	risos400parms os400;
		rismssqlparms mssql;
	} parms;
	uchar	ostype;
	struct risdb * next;
} risdb;

typedef struct risschema
{
	char				schname[RIS_MAX_ID_SIZE];
	char				schpass[RIS_MAX_PASSWD_SIZE];
	char				dictowner[RIS_MAX_ID_SIZE];
	char				schowner[RIS_MAX_ID_SIZE];
	char				passwd[RIS_MAX_PASSWD_SIZE];
	char				login[RIS_MAX_ID_SIZE];
	char				loginpd[RIS_MAX_PASSWD_SIZE];
	char				dict_dbusr[RIS_MAX_ID_SIZE];
	char				schown_dbusr[RIS_MAX_ID_SIZE];
	char				login_dbusr[RIS_MAX_ID_SIZE];
	char				secure;
	char				privilege;
	uint				cli_to_srv_buf_size;
	uint				srv_to_cli_buf_size;
	uint				srv_pid;
	long				risdbs_timestamp;
	long				risschemas_timestamp;
	struct net_s		*net;
	struct arc_s		*arc;
	struct risdb		*db;
	struct rissql		*sql;
	struct risschema	*next;
	struct risgrantee	*grantee;
	ushort				dbid;
	ushort				ref_by_crnt_stmt;/* It is set to 1, if the schema is
											   referenced by the current 
											   statement.  Otherwise, it is set
											   to 0. */
    char                superschema_flag;/* 0  regular schema
                                            1  primary schema of a superschema
                                            2  secondary schema of a superschema
                                            3  superschema */
    struct risschema    *sub_schp;
    struct rissuperschema    *super_schp;
    struct ristimestamp timestamp;
	struct risnetvstate netvstate;
	short				schid;
	char				srv_busy;
	short				major;
	short				feature;
} risschema;

typedef struct risdclrschema
{
    char				schname[RIS_MAX_ID_SIZE];
    char				schpass[RIS_MAX_PASSWD_SIZE];
	char                schuser[RIS_MAX_ID_SIZE];
	char                schuserpd[RIS_MAX_PASSWD_SIZE];
	char                osuser[RIS_MAX_ID_SIZE];
	char                osuserpd[RIS_MAX_PASSWD_SIZE];
    struct risdclrschema	*next;
} risdclrschema;

typedef struct rissuperschema
{
    char                    schname[RIS_MAX_ID_SIZE];
    short                   ssid;
    short                   stmt_count;
    struct risschema        *sub_schp;
    struct risstmtstat      *stmtstat[RIS_MAX_SECONDARY_SCHEMAS+1];
    struct rissuperschema   *next;
	short					primary_id;
} rissuperschema;

typedef struct ristab
{
	char				tabname[RIS_MAX_ID_SIZE];
	char                extern_tabname[RIS_MAX_ID_SIZE];
	char                tabowner[RIS_MAX_ID_SIZE];
	int					tabid;
	char				tabtype;
	int					ref_count;
	struct risaccess	*acc;
	struct risschema	*schema;
	struct ristab		*tab;
	struct risattr		*attr;
	struct ristab		*next;
} ristab;

typedef struct ristree
{
	ushort			tok;				/* token code			*/
	ushort			pos;				/* query token position	*/
	struct ristree	*lhs;				/* left-hand side		*/
	struct ristree	*rhs;				/* right-hand side		*/
	struct ristree	*next;
	union
	{
		struct internal_sqlvar	*data;			/* for PARAMETER tokens		 */
		struct risaccess		*access;		/* for ACCESS tokens		 */
		struct risattr			*attr;			/* for ATTR tokens			 */
		struct risdb			*db;			/* for DATABASE tokens		 */
		struct risschema		*schema;		/* for SCHEMA tokens		 */
		struct rissuperschema   *sschema;       /* for SUPERSCHEMA tokens    */
		struct ristab			*tab;			/* for TABLE tokens			 */
		char					*val;			/* for all other tokens		 */
	}info;
} ristree;

typedef struct macro_list_node
{
	int ident;
	char * name;
	char * value;
	struct macro_list_node * next;
} macro_list_node;


/*
**	VARIABLES
*/

#undef uint
#undef ushort
#undef uchar
#undef offset

#endif

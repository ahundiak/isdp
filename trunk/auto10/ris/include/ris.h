/* Do not alter this SPC information: $Revision: 1.3.21.1 $ */
/*
** Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  NAME:                           ris.h
**  AUTHORS:                        Database Environment Group
**  CREATION DATE:                  8/88
**  ABSTRACT:
**      ANSI/ISO Standard SQL structures and data types.
**
**  REVISION HISTORY:
*/

#ifndef SQL_H
#define SQL_H

/*
**  TYPES
*/

typedef struct ris_blob
{
  char         *filename;     /* pointer to the name of file holding blob data */
  char         *array;        /* pointer to the char array holding blob data  */
  unsigned int  array_size;   /* the size of the char array, if it is used */
  unsigned int  input_len;    /* the total length of the blob data inserted,
                                 returned by server. */
  unsigned int  output_len;   /* the total length of the blob data retrieved,
                                 returned by server */
  unsigned int  file_offset;  /* retrieval only, the offset of the file
                                 where blob is to be appended;
                                 0 if the file is to be over written */
  unsigned char file_used  ;  /* the flag to indicate if a file is used */
  char pad[11];
} ris_blob;

typedef struct ris_text
{
    char    *filename;      /* pointer to the name of file holding text data */
    char    *array;         /* pointer to the char array holding text data */
    unsigned int  array_size; /* the size of the char array, if it is used */
    unsigned int  input_len; /* the total length of the blob data inserted,
                                 returned by server. */
    unsigned int  output_len; /* the total length of the blob data retrieved,
                                 returned by server */
    unsigned int  file_offset; /* retrieval only, the offset of the file
                                  where text is to be appended;
                                  0 if the file is to be over written */
    unsigned char file_used  ; /* the flag to indicate if a file is used */
    char pad[11];
}ris_text;

typedef struct sqlvar       /* structure representing input or output parm  */
{
    char    *sqldata;       /* pointer to input or output data buffer       */
    long    *sqlind;        /* pointer to null indicator data buffer        */
    short   sqltype;        /* sql data type of input or output parameter   */
    short   sqlnull;        /* nulls allowed or sqlind set (see document)   */
    short   sqllen;         /* length of input or output data buffer        */
    short   sqlscale;       /* precision and scale for decimal data type    */
    struct
    {
        short   sqlnamel;       /* length of string in sqlnamec             */
        char    sqlnamec[34];   /* column name (NOT null terminated)        */
    } sqlname;
} sqlvar;

#ifdef RIS_SERVER
typedef struct ris_sqlda
#else
typedef struct sqlda
#endif
{
    short   sqln;       /* number of sqlvar structs pointed to by sqlvar    */
    short   sqld;       /* number of input or output sqlvars in statement   */
    sqlvar  *sqlvar;    /* array of input or output sqlvar structures       */
}
#ifdef RIS_SERVER
ris_sqlda;
#else
sqlda;
#endif

typedef struct rissqlca
{
    char    sqlcaid[8];     /* "SQLCAxxx" aid for reading memory dumps      */
    long    sqlabc;         /* length in bytes of rissqlca structure        */
    long    sqlcode;        /* most recent error code                       */
    struct
    {
        char sqlerrmc[512]; /* sql error message corresponding to sqlcode   */
        short sqlerrml;     /* length of sqlerrmc                           */
        short pad;
    } sqlerrm;
    char    sqlerrp[8];     /* currently unused                             */
    long    sqlerrd[8];     /* internal use only                            */
    char    sqlwarn[8];     /* warning flags                                */
    char    sqlext[8];      /* currently unused                             */
    char    *sqlstmt;       /* pointer to internal SQL statement buffer     */
} rissqlca;

typedef struct datetime
{
    unsigned int    second;
    unsigned int    minute;
    unsigned int    hour;
    unsigned int    day;
    unsigned int    month;
    unsigned int    year;
} datetime;

typedef struct schema_file_parms
{
    char protocol;
    char address[29];
    char username[32];
    char password[38];
    char filename[241];
} schema_file_parms;

typedef struct client_parms
{
    char protocol;
    char address[29];
    char username[32];
    char password[38];
    short major;
    short feature;
} client_parms;

typedef struct ris_ifx_info
{
    char    dir[241];
    char    sqlexec[241];
    char    dbtemp[241];
    char    tbconfig[241];
} ris_ifx_info;

typedef struct ris_igs_info
{
    char    dir[241];
} ris_igs_info;

typedef struct ris_ora_info
{
    char    osuser[32];
    char    ospass[38];
    char    dir[241];
} ris_ora_info;

typedef struct ris_db2_info
{
    char    osuser[32];
    char    ospass[38];
    char    arch[32];
    char    os[32];
    char    net_protocol[32];
    char    env[32];
    char    host_program[5];
    char    ris_lu[18];
    char    host_lu[18];
    char    mode[9];
    char    group[9];
    char    node[32];
    char    pad[1];
    unsigned short  port;
} ris_db2_info;

typedef struct ris_os400_info
{
    char    osuser[32];
    char    ospass[38];
    char    net_protocol[32];
    char    host_program[22];
    char    ris_lu[18];
    char    host_lu[18];
    char    mode[9];
    char    group[9];
    char    node[32];
    char    ris_dict_dbname[11];
    char    pad;
    unsigned short  port;
} ris_os400_info;

typedef struct ris_rdb_info
{
    char dummy;
}  ris_rdb_info;

typedef struct ris_syb_info
{
    char    osuser[32];
    char    ospass[38];
    char    dir[241];
    char    dsquery[32];
    char    sybifile[32];
} ris_syb_info;

typedef struct ris_mssql_info
{
    char    osuser[32];
    char    ospass[38];
    char    dir[241];
    char    dsquery[32];
    char    mssqlifile[32];
} ris_mssql_info;

typedef struct ris_db_info
{
    unsigned short  dbid;
    unsigned char   dtype;
    char            dbname[241];
    struct
    {
        unsigned char   protocol;
        char            netaddr[29];
    } pathways[4];
    union
    {
        ris_ifx_info ifx;
        ris_igs_info igs;
        ris_ora_info ora;
        ris_db2_info db2;
        ris_rdb_info rdb;
        ris_syb_info syb;
        ris_os400_info os400;
        ris_mssql_info mssql;
    } info;
    unsigned char   ostype;
    char    pad[3];
    struct ris_db_info *next;
} ris_db_info;

typedef struct ris_schema_info
{
    char                    schname[32];
    char                    schowner[32];
    char                    schownpass[40];
    char                    dictowner[32];
    unsigned short          secure;
    unsigned short          dbid;
    unsigned short          server_version_major;
    unsigned short          server_version_feature;
    struct  ris_schema_info *next;
} ris_schema_info;


typedef struct ris_schema_error_info
{
    char            schname[32];
    struct rissqlca schrisca;
    struct rissqlca schdbca;
} ris_schema_error_info;

typedef struct ris_superschema_error_info
{
    struct ris_schema_error_info    primary;
    struct ris_schema_error_info    secondary[9];
} ris_superschema_error_info;


typedef struct ris_grantee_info
{
    char                    schname[32];
    char                    grantee[32];
    struct ris_grantee_info *next;
} ris_grantee_info;

typedef struct ris_parameters       /* structure representing parms of parameters file  */
{
    int     shared_memory;
    int     max_local_servers;
    int     max_rows;
    int     max_buffer_size;
    int     max_static_stmts;
    int     max_user_stmts;
    int     max_secondary_schemas;
    int     max_transactions;
    int     max_tables_in_memory;
    int     timestamp_interval;
    int     initial_timeout;
    int     timestamp_tolerance;
    int     buffer_full_size;
    int     buffer_full_timeout;
    char    schema_file_protocol;
    char    schema_file_address[29];
    char    schema_file_username[32];
    char    schema_file_password[38];
    char    schema_file_filename[241];
    int     lock_file_retry;
    char    client_protocol;
    char    client_address[29];
    char    client_username[32];
    char    client_password[38];
    short   client_major;
    short   client_feature;
} ris_parameters;

/*
**  The following are defined strictly for Interoperability.  Any platform
**  that does not have a version 4 should not have the following list defined.
*/
#if defined(__clipper__) || defined(sunx) || defined(vms) || defined(sco)
#define UNKNOWN_TYPE        RIS_UNKNOWN_TYPE
#define CHARACTER           RIS_CHARACTER
#define NUMERIC             RIS_NUMERIC
#define DECIMAL             RIS_DECIMAL
#define INTEGER             RIS_INTEGER
#define SMALLINT            RIS_SMALLINT
#define FLOAT               RIS_FLOAT
#define REAL                RIS_REAL
#define DOUBLE_PRECISION    RIS_DOUBLE
#define DOUBLE              RIS_DOUBLE
#define DATETIME            RIS_DATETIME
#define TIMESTAMP           RIS_TIMESTAMP
#define INTERVAL            RIS_INTERVAL
#define NATIONAL_CHARACTER  RIS_NATIONAL_CHARACTER
#define CHARACTER_VARYING   RIS_CHARACTER_VARYING
#define NATIONAL_CHARACTER_VARYING  RIS_NATIONAL_CHARACTER_VARYING
#define UNSUPPORTED         RIS_UNSUPPORTED_TYPE
#define SQL_MAX_TYPES       RIS_MAX_TYPES
#endif

#define RIS_UNKNOWN_TYPE                0
#define RIS_CHARACTER                   1
#define RIS_NUMERIC                     2   /* Currently Unsupported        */
#define RIS_DECIMAL                     3
#define RIS_INTEGER                     4
#define RIS_SMALLINT                    5
#define RIS_FLOAT                       6   /* Currently Unsupported        */
#define RIS_REAL                        7
#define RIS_DOUBLE                      8
#define RIS_DATETIME                    9
#define RIS_TIMESTAMP                   9
#define RIS_INTERVAL                    10  /* Currently Unsupported        */
#define RIS_NATIONAL_CHARACTER          11  /* Currently Unsupported        */
#define RIS_CHARACTER_VARYING           12  /* Currently Unsupported        */
#define RIS_NATIONAL_CHARACTER_VARYING  13  /* Currently Unsupported        */
#define RIS_UNSUPPORTED_TYPE            14
#define RIS_BLOB                        15
#define RIS_TEXT                        16
#define RIS_MAX_TYPES                   17

#define RIS_FREE_SCHEMA_INFO_MEMORY		0
#define RIS_FREE_DB_INFO_MEMORY			1
#define RIS_FREE_SCHEMA_FILE_MEMORY		2
#define RIS_FREE_REPORT_ERROR_MEMORY 	3


/******************************************************************************

                    SQL Datatypes and Equivalences
===============================================================================

RIS/SQL string     INFORMIX     ORACLE       INGRES     DB2
------------------ ------------ ------------ ---------- ----------------
char[acter](n)     char(n)      char(n)      varchar(n) varchar(n)
int[eger]          integer      number(10,0) integer4   int
smallint           smallint     number(5,0)  integer2   smallint
real               real         float        float4     real
double [precision] float        real         float8     double precision
decimal(p,s)       decimal(p,s) number(p,s)  float8     decimal(p,s)
timestamp          datetime     date         date       timestamp
ris_blob           byte         long raw     varchar(2000) unsupported
ris_text           text         long raw     varchar(2000) unsupported


RIS/SQL string     RDB
------------------ ----------------
char[acter](n)     varchar(n)
int[eger]          integer
smallint           smallint
real               real
double [precision] double precision
decimal(p,s)       decimal(p,s)
timestamp          date
ris_blob           varchar(16383)
ris_text           varchar(16383)


RIS/SQL code       INFORMIX    ORACLE   INGRES          DB2       SYBASE
------------       ----------  ------   -------------   -------   ----------
RIS_CHARACTER      SQLCHAR       5      IISQ_VCH_TYPE   460/461   SYBVARCHAR
RIS_INTEGER        SQLINT        3      IISQ_INT_TYPE   496/497   SYBINT4
RIS_SMALLINT       SQLSMINT      3      IISQ_INT_TYPE   500/501   SYBINT2
RIS_REAL           SQLSMFLOAT    4      IISQ_FLT_TYPE   480/481   SYBREAL
RIS_DOUBLE         SQLFLOAT      4      IISQ_FLT_TYPE   480/481   SYBFLT8
RIS_DECIMAL        SQLDECIMAL    1      IISQ_FLT_TYPE   484/485   SYBFLT8
RIS_TIMESTAMP      SQLDTIME      12     IISQ_DTE_TYPE   392/393   SYBDATETIME

RIS/SQL code       RDB           MSSQL
------------       ------        -----
RIS_CHARACTER      37          SYBVARCHAR
RIS_INTEGER        8           SYBINT4
RIS_SMALLINT       7           SYBINT2
RIS_REAL           10          SYBREAL
RIS_DOUBLE         27          SYBFLT8
RIS_DECIMAL        7,8,9       SYBFLT8
RIS_TIMESTAMP      35          SYBDATETIME


******************************************************************************/

/*
**   Set Mode Enabled Database bit mask
*/
#define RIS_ENABLE_INFORMIX     0x1         /* Informix */
#define RIS_ENABLE_ORACLE       0x2         /* ORACLE */
#define RIS_ENABLE_INGRES       0x4         /* Ingres */
#define RIS_ENABLE_DB2          0x8         /* DB2 */
#define RIS_ENABLE_RDB          0x10        /* Rdb */
#define RIS_ENABLE_SYBASE       0x20        /* Sybase */
#define RIS_ENABLE_SQLDS        0x40        /* SQL/DS */
#define RIS_ENABLE_ADABAS       0x80        /* ADABAS */
#define RIS_ENABLE_OS400        0x100       /* OS/400 */
#define RIS_ENABLE_MSSQL        0x200       /* MS SQLSR */
#define RIS_ENABLE_RIS          0x80000000  /* RIS */

#define RIS_ENABLE_ALL          0xffffffff  /* all bits */

#define IS_INFORMIX_ENABLED(mask)   ((mask) & RIS_ENABLE_INFORMIX)
#define IS_ORACLE_ENABLED(mask)     ((mask) & RIS_ENABLE_ORACLE)
#define IS_INGRES_ENABLED(mask)     ((mask) & RIS_ENABLE_INGRES)
#define IS_DB2_ENABLED(mask)        ((mask) & RIS_ENABLE_DB2)
#define IS_RDB_ENABLED(mask)        ((mask) & RIS_ENABLE_RDB)
#define IS_SYBASE_ENABLED(mask)     ((mask) & RIS_ENABLE_SYBASE)
#define IS_SQLDS_ENABLED(mask)      ((mask) & RIS_ENABLE_SQLDS)
#define IS_ADABAS_ENABLED(mask)     ((mask) & RIS_ENABLE_ADABAS)
#define IS_OS400_ENABLED(mask)      ((mask) & RIS_ENABLE_OS400)
#define IS_MSSQL_ENABLED(mask)     ((mask) & RIS_ENABLE_MSSQL)

/*
**   Warning bit mask
*/
#define RIS_WARNING             0x1         /* if any warning bit set */
#define RIS_WARNING1            0x2         /* currently unused */
#define RIS_WARNING2            0x4         /* currently unused */
#define RIS_ILICENSE_WARNING    0x8         /* I_LICENSE expiry warning */
#define RIS_WARNING4            0x10        /* currently unused */
#define RIS_WARNING5            0x20        /* currently unused */
#define RIS_PRIM_SCH_WARNING    0x40        /* primary schema died */
#define RIS_SEC_SCH_WARNING     0x80        /* secondary schema died */

#define IS_RIS_WARNING(mask)                ((mask) & RIS_WARNING)
#define IS_RIS_WARNING1(mask)               ((mask) & RIS_WARNING1)
#define IS_RIS_WARNING2(mask)               ((mask) & RIS_WARNING2)
#define IS_RIS_ILICENSE_WARNING(mask)       ((mask) & RIS_ILICENSE_WARNING)
#define IS_RIS_WARNING4(mask)               ((mask) & RIS_WARNING4)
#define IS_RIS_WARNING5(mask)               ((mask) & RIS_WARNING5)
#define IS_RIS_PRIM_SCH_WARNING(mask)       ((mask) & RIS_PRIM_SCH_WARNING)
#define IS_RIS_SEC_SCH_WARNING(mask)        ((mask) & RIS_SEC_SCH_WARNING)


#define RIS_SUCCESS                 0

#define END_OF_DATA                 100
#define STATEMENT_NOT_COMPLETE      200
#define STATEMENT_FAILED            201

#endif

/*
**  VARIABLES
*/
#ifndef RIS_SERVER
# if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
#  define RIS_superschema_warning       superschema_warning
#  define RIS_superschema_error         superschema_error
# endif
# if defined(unix) || defined(vms) || defined(DOS)
   extern int                           SQLCODE;
   extern int                           superschema_warning;
   extern rissqlca                      *risca;
   extern rissqlca                      *dbca;
   extern ris_superschema_error_info    *superschema_error;
# endif
# if defined(WIN32)
#  if defined(RIS_INTERNAL)
    extern int                          SQLCODE;
    extern int                          superschema_warning;
    extern rissqlca                     *risca;
    extern rissqlca                     *dbca;
    extern ris_superschema_error_info   *superschema_error;
#  else
    extern int                          RISget_sqlcode();
    extern int                          RISget_superschema_warning();
    extern rissqlca                     *RISget_risca();
    extern rissqlca                     *RISget_dbca();
    extern ris_superschema_error_info   *RISget_superschema_error();
#   define SQLCODE                      RISget_sqlcode()
#   define superschema_warning          RISget_superschema_warning()
#   define risca                        RISget_risca()
#   define dbca                         RISget_dbca()
#   define superschema_error            RISget_superschema_error()
#  endif
# endif
#endif

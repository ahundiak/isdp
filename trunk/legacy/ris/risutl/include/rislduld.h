/* Do not alter this SPC information: $Revision: 1.2.39.1 $ */
/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**  NAME:                           rislduld.h
**  AUTHORS:                        RIS Utilities Group
**  CREATION DATE:                  5/91
**  ABSTRACT:
**      It has structure definition which is required for
**      embedded programming of risload utility.
**
**  REVISION HISTORY:
*/

#ifndef RISLDULD_H
#define RISLDULD_H

/*
**  INCLUDES
*/
#include "rislimit.h"
#include <stdio.h>

/*
**  DEFINES
*/

/*
**  TYPES
*/

/* Loader */
typedef struct risloddes
{
    /* Input Fields */
    int     nonansimode;                    /* ansi(0) or non ansi(1) mode */
    int     preserve_blanks;                /* 1 - blanks preserved
                                               0 - blanks stripped  */
    char    filemode;                       /* File mode of output files w, a or e */
    char    mainfile[RIS_MAX_PATH_SIZE];    /* Input file name */
    char    logfile[RIS_MAX_PATH_SIZE];     /* log file name */
    char    badfile[RIS_MAX_PATH_SIZE];     /* bad file name */
    char    delimiter;                      /* delimiter for char data */
    int     commit_interval                 /* commit interval for table data */;
    int     dbs_count;                      /* # of databases enforced */
    struct  risloddbs   *dbs;               /* pointer to array of rislodbs structs */
    int     schema_count;                   /* # of schemas */
    struct rislodsch    *schemas;           /* pointer to array of rislodsch structs */

    /* Output Fields */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risloddes;


/* Enforce databases */
typedef struct risloddbs
{
    char    dbsname[RIS_MAX_KEYWORD_SIZE]; /* database name */
} risloddbs;


/* Load a schema */
typedef struct rislodsch
{
    /* Input Fields */
    char    schname[RIS_MAX_ID_SIZE];       /* schema name */
    char    schpass[RIS_MAX_ID_SIZE];       /* optional schema password */
    char    osname[RIS_MAX_ID_SIZE];        /* optional os user name  - secure*/
    char    ospass[RIS_MAX_ID_SIZE];        /* optional os user password */
    char    username[RIS_MAX_ID_SIZE];      /* optional user name (for declare schema) */
    char    userpass[RIS_MAX_ID_SIZE];      /* optional user password */
    char    new_schname[RIS_MAX_ID_SIZE];   /* optional newschema(transfer to)*/
    char    new_schpass[RIS_MAX_ID_SIZE];   /* optional newschema password */
    char    new_user[RIS_MAX_ID_SIZE];      /* required for secure schema only */
    char    new_userpass[RIS_MAX_ID_SIZE];  /* required for secure schema only */
    char    select_mode;                    /* ALL('a') or SOME('s') */
    /*
    **  if ALL('a') then following fields in *info struct become
    **  output fields
    **  else if SOME('s') or NONE('n') then they become input fields
    */
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in tabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         with_data;              /* 1 or 0 */
        int         ignore_create_error;    /* 1 or 0 */
        int         clear_exist_data;       /* 1 or 0 */
        int         table_count;            /* # of tables */
        struct rislodtab    *tables;        /* pointer to array of rislodtab structs */
    } tabinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in viewinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         view_count;             /* # of views */
        struct rislodview   *views;         /* pointer to array of rislodview structs */
    } viewinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in indxtabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         indxtab_count;          /* # of tables */
        struct rislodindx   *indxtabs;      /* pointer ot array of rislodindx structs */
    } indxtabinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in granttabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         granttab_count;         /* # of relations */
        struct rislodgrant  *granttabs;     /* pointer to array of privilege structs */
    } granttabinfo;

    /* Output Fields */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} rislodsch;


/* Load a table */
typedef struct rislodtab
{
    /* Input Fields */
    char    tabname[RIS_MAX_ID_SIZE];       /* table name */

    /* Output Fields */
    int     rows_loaded;                    /* # of rows loaded */
    int     err_rows;                       /* # of error rows */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} rislodtab;


/* Load a view */
typedef struct rislodview
{
    /* Input Fields */
    char    viewname[RIS_MAX_ID_SIZE];      /* view name */

    /* Output Fields */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} rislodview;


/* Load indexes for a table */
typedef struct rislodindx
{
    /* Input Fields */
    char    tabname[RIS_MAX_ID_SIZE];       /* table name */

    /* Output Fields */
    int     indexes_loaded;                 /* # of indexes loaded */
    int     err_indexes;                    /* # of error indexes */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} rislodindx;


/* Load grants for a table */
typedef struct rislodgrant
{
    /* Input Fields */
    char    table_owner[RIS_MAX_ID_SIZE];   /* schema who owns the table */
    char    tabname[RIS_MAX_ID_SIZE];       /* table or view name */

    /* Output Fields */
    int     grants_loaded;                  /* # of grants loaded */
    int     err_grants;                     /* # of error grants */
    long    lod_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} rislodgrant;




/*
**
**  RIS Unload Descriptors
**
*/


/* Unloader */
typedef struct risulddes
{
    /* Input Fields */
    int     preserve_blanks;                /* 1 - blanks preserved
                                               0 - blanks stripped  */
    char    filemode;                       /* File mode of output files w, a or e */
    char    mainfile[RIS_MAX_PATH_SIZE];    /* Output file name */
    int     schema_count;                   /* # of schemas */
    struct risuldsch    *schemas;           /* pointer to array of risuldsch structs */

    /* Output Fields */
    long    uld_err_code;                   /* unloader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risulddes;


/* Unload a schema */
typedef struct risuldsch
{
    /* Input Fields */
    char    schname[RIS_MAX_ID_SIZE];  /* schema name */
    char    schpass[RIS_MAX_ID_SIZE];  /* optional schema password */
    char    osname[RIS_MAX_ID_SIZE];   /* OS user name - for secure schemas */
    char    ospass[RIS_MAX_ID_SIZE];   /* OS password - for secure schemas */
    char    dbname[RIS_MAX_ID_SIZE];   /* database user name - secure schemas */
    char    dbpass[RIS_MAX_ID_SIZE];   /* database password - secure schemas */
    char    select_mode;                    /* ALL('a') or SOME('s') */
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in tabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         with_data;              /* 1 or 0 */
        int         separate_dfile;         /* 1 or 0 */
        int         variable_data_format;   /* 1 or 0 */
        int         table_count;            /* # of tables */
        struct risuldtab    *tables;        /* pointer to array of risuldtab structs */
    } tabinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in viewinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         view_count;             /* # of views */
        struct risuldview   *views;         /* pointer to array of risuldview structs */
    } viewinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in indxtabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         indxtab_count;          /* # of tables */
        struct risuldindx   *indxtabs;      /* pointer ot array of risuldindx structs */
    } indxtabinfo;
    struct
    {
        char        select_mode;            /* ALL('a'), SOME('s') or NONE('n') */
        /*
        **  if ALL('a') then following fields in granttabinfo struct become
        **  output fields
        **  else if SOME('s') or NONE('n') then they become input fields
        */
        int         granttab_count;         /* # of tables */
        struct risuldgrant  *granttabs;     /* pointer to array of privilege structs */
    } granttabinfo;

    /* Output Fields */
    long    uld_err_code;                   /* unloader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risuldsch;


/* Unload a table */
typedef struct risuldtab
{
    /* Input Fields */
    char    tabname[RIS_MAX_ID_SIZE];       /* table name */
    char    *whereclause;                   /* optional where clause */

    /* Output Fields */
    int     rows_unloaded;                  /* # of rows unloaded */
    int     err_rows;                       /* # of error rows */
    char    data_filename[RIS_MAX_PATH_SIZE];/* separate data filename */
    long    uld_err_code;                   /* unloader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risuldtab;


/* Unload a view */
typedef struct risuldview
{
    /* Input Fields */
    char    viewname[RIS_MAX_ID_SIZE];      /* view name */

    /* Output Fields */
    long    uld_err_code;                   /* loader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risuldview;


/* Unload indexes for a table */
typedef struct risuldindx
{
    /* Input Fields */
    char    tabname[RIS_MAX_ID_SIZE];       /* table name */

    /* Output Fields */
    int     indexes_unloaded;               /* # of indexes unloaded */
    int     err_indexes;                    /* # of error indexes */
    long    uld_err_code;                   /* unloader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risuldindx;


/* Unload grants for a table */
typedef struct risuldgrant
{
    /* Input Fields */
    char    table_owner[RIS_MAX_ID_SIZE];   /* schema who owns the table */
    char    tabname[RIS_MAX_ID_SIZE];       /* table or view name */

    /* Output Fields */
    int     grants_unloaded;                /* # of grants unloaded */
    int     err_grants;                     /* # of error grants */
    long    uld_err_code;                   /* unloader error code */
    long    ris_err_code;                   /* ris error code */
    long    db_err_code;                    /* underlying dbms error code */
    char    sqlwarnings[8];                 /* ris sql warnings */
} risuldgrant;

/*
**  FUNCTION PROTOTYPES
*/
#ifdef __STDC__
extern int RIS_loader(risloddes *risloddes_ptr);
extern int RIS_unloader(risulddes *risulddes_ptr);
extern void RISlod_print_risloddes(risloddes *risloddes_ptr);
extern void RISuld_print_risulddes(risulddes *risulddes_ptr);
extern void RISlod_fprint_risloddes(FILE *fp, risloddes *risloddes_ptr);
extern void RISuld_fprint_risulddes(FILE *fp, risulddes *risulddes_ptr);
extern int RISlduld_load_dll();
#else
extern int RIS_loader();
extern int RIS_unloader();
extern void RISlod_print_risloddes();
extern void RISuld_print_risulddes();
extern void RISlod_fprint_risloddes();
extern void RISuld_fprint_risulddes();
extern int RISlduld_load_dll();
#endif

/*
**  VARIABLES
*/

#endif

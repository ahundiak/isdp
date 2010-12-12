/* 
 * File:   risx.h
 * Author: impd
 *
 * Created on December 12, 2010, 11:47 AM
 */

#ifndef RISX_H
#define	RISX_H

#include <glib.h>
#include <stdlib.h>
#include <string.h>

/* rislimit.h */
#define RIS_MAX_ID_SIZE   32
#define RIS_MAX_NODE_SIZE 29

/* risflags.c */
#define RIS_STATIC_STMT      1
#define RIS_DONT_CLEAR_FLAG  1

/* ris.h */
#define RIS_SUCCESS 0
#define RIS_E_FAIL  1

/* ===============================================
 * This is what gets sent out to the server
 */
#define	RISCLI_PREPARE_CODE 8

/*      modes for execute_mode flag */
#define START_MODE    0x01
#define FINISH_MODE   0x02
#define BLOCKING_MODE 0x04

#define SYNC_MODE        (START_MODE|FINISH_MODE|BLOCKING_MODE)
#define ASYNC_START_MODE (START_MODE)
#define ASYNC_TEST_MODE  (FINISH_MODE)
#define ASYNC_WAIT_MODE  (FINISH_MODE|BLOCKING_MODE)

typedef struct ris_appcli_buf
{
  guchar opcode;
  guchar execute_mode;
  gshort stmt_id;
  guchar pad[4];
  union
  {
    /* RISCLI_PREPARE_CODE */
    struct ris_appcli_buf_prep
    {
      int  query_len;
      char data[1];
    } prep;
  } buf;
} ris_appcli_buf;

typedef struct ris_cliapp_buf
{
  int  status;
  char warning;
  char pad[3];
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
      guint  in_sqlvars;  // Offsets
      guint  out_sqlvars;
      guint  tab_list;

      int    in_count;
      int    out_count;
      int    tab_count;

      int    in_len;
      int    out_len;
      int    fetch_buf_size;
      int    write_buf_size;
      char   schname[RIS_MAX_ID_SIZE];
      char   stmt_type;
      char   pad[3];
      char   data[1];
    } prep;
  } buf;
}ris_cliapp_buf;

/* Types */
typedef struct sqlvar    /* structure representing input or output parm  */
{
  char  *sqldata;        /* pointer to input or output data buffer       */
  long  *sqlind;         /* pointer to null indicator data buffer        */
  short  sqltype;        /* sql data type of input or output parameter   */
  short  sqlnull;        /* nulls allowed or sqlind set (see document)   */
  short  sqllen;         /* length of input or output data buffer        */
  short  sqlscale;       /* precision and scale for decimal data type    */
  struct
  {
    short sqlnamel;       /* length of string in sqlnamec             */
    char  sqlnamec[34];   /* column name (NOT null terminated)        */
  } sqlname;
} sqlvar;

typedef struct sqlda
{
  short   sqln;      /* number of sqlvar structs pointed to by sqlvar    */
  short   sqld;      /* number of input or output sqlvars in statement   */
  sqlvar *sqlvar;    /* array of input or output sqlvar structures       */
} sqlda;

typedef struct ris_app_stmt
{
  char  *query;
  int    input_len;
  int    output_len;
  int    fetch_buf_size;
  int    write_buf_size;

  struct sqlda *input;
  struct sqlda *output;

  int   tab_count;
  char (*tab_list)[RIS_MAX_ID_SIZE];

//ris_cliapp_buf *fetch_buf;
  int   row_count;
  int   end_of_data;
  char *row;
  char  prep_def_schname[RIS_MAX_ID_SIZE]; /* the default schema at prepare time */
  char           schname[RIS_MAX_ID_SIZE]; /* the schema the stmt accesses */
  
  char   stmt_type;
  short *stmt_id_addr;
  guint  timestamp;
  
  // struct risasync	*async;
} ris_app_stmt;

/* Global variables */
extern char RIS_def_schname[RIS_MAX_ID_SIZE];
extern int  SQLCODE;

extern int RIS_client_died ;
extern int RIS_mem;
extern int RIS_net;

#ifdef	__cplusplus
extern "C" {
#endif

extern void  RISint_prepare(short *stmt_id, char *query, int clear_flag, int static_flag);

extern short RISapp_new_stmt(int clear_flag, int static_flag);

extern int  RISget_sqlcode();
extern void RISint_set_sqlcode(int code);


#ifdef	__cplusplus
}
#endif

#endif	/* RISX_H */


/******************************************************************************

Doc:    BLvars.h

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLvars.h

Author: Rob Whitesell

Date:   03-SEPTEMBER-1991

Description:
        This include file contains the global variables used by the bulkloader.

History:
  09/18/91  wrw  -added vars 'mirror_count' and 'mirror_okay' for mirror arch.
  09/20/91  wrw  -added var 'ris_fn' for ris pre-load option.
  02/02/92  wrw  -changed the way .blk records are stored.

******************************************************************************/

extern FILE *dbgfile;
extern FILE *bulkload;
extern FILE *results;
extern FILE *reload;
extern FILE *stsfile;
extern FILE *timerfile;

extern char  fn_bulkload[MAX_ASCII_LINE_LEN];
extern char  fn_results[MAX_ASCII_LINE_LEN];
extern char  fn_reload[MAX_ASCII_LINE_LEN];
extern char  fn_sts[MAX_ASCII_LINE_LEN];

extern char  on_node[MAX_ASCII_LINE_LEN];

extern char  server[MAX_ATTRIBUTE_LEN];
extern char  n_environ[MAX_ATTRIBUTE_LEN];
extern char  user[MAX_ATTRIBUTE_LEN];
extern char  password[MAX_ATTRIBUTE_LEN];
extern char  bulk_fn[MAX_ASCII_LINE_LEN];
extern char  ris_fn[MAX_ASCII_LINE_LEN];

extern long  s_flag;
extern long  e_flag;
extern long  u_flag;
extern long  p_flag;
extern long  b_flag;

extern struct attr_type
            *attributes;
extern long  num_of_attributes;
extern long  num_of_attr_alloc;

extern struct flags_type
             flags;

extern struct params_type
             parameters;

extern struct count_type
             T_count;

extern char  PARAM_DELIMIT;

extern char **sa_names;
extern int   max_sa;

extern long  data_div_pos;

extern long  mirror_count;
extern long  mirror_okay;

extern FILE *errlog;
extern FILE *DEBUG;

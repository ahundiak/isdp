/* $Revision: 1.1 $ */
#ifndef RPT_H
#define RPT_H

#include "dba.def"

char *dba_p[6];

double *dba_fuzz;

int dba_last_rptlin, dba_skip_compile, 
 *dba_line, *dba_page, *dba_occnum, 
 *dba_parnum, *dba_reuse, *dba_schema, *dba_entnum, *dba_null, *dba_eof, 
 *dba_lastinput, *dba_top, dba_tmp_output, dba_no_join_query,
 dba_no_formfeed, dba_select_distinct;

long dba_report_memory;

struct dba_ent *dba_rent, *dba_rptent;

struct dba_file *dba_ffile, *dba_lfile;

struct dba_key *dba_fkey, *dba_lkey;

struct dba_user *dba_fsystem, *dba_lsystem, *dba_fuser, *dba_luser;

#endif

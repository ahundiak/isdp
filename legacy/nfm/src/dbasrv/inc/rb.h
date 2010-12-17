/* $Revision: 1.1 $ */
#ifndef RB_H
#define RB_H

#include "dba.def"

int dba_rtb_off, dba_dspace, dba_deloff, dba_curoff, dba_curcol;

struct dba_line *dba_cline, *dba_dline, *dba_sline,
 *dba_fline, *dba_lline, *dba_fsline, *dba_lsline;

struct dba_field *dba_cfield, *dba_dfield, *dba_pfield,
 *dba_nfield, *dba_sfield, *dba_sfield;

#endif

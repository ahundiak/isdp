/* $Revision: 1.1 $ */
#ifndef RISDVW_H
#define RISDVW_H

char dba_modnam[10], dba_help_key[30], dba_arrent_txt[80], dba_selkey_txt[80];

int dba_srtlin, dba_srtoff, dba_rptoff, dba_pb_rows, dba_pb_columns, 
  dba_modnum, dba_template_lines, dba_insert_mode,
  dba_first_srtlin, dba_last_srtlin, dba_first_rptlin, 
  dba_first_codlin, dba_last_codlin, dba_first_attlin, dba_last_attlin,
  dba_dbe_off, dba_codoff, dba_codlin, dba_clrscr, dba_arrow, dba_advance;

struct dba_ent *dba_dent;

struct dba_att *dba_datt;

struct dba_library *dba_text_lib;

struct dba_wind *dba_fwind, *dba_lwind;

#endif

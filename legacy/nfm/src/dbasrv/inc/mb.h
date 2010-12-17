/* $Revision: 1.1 $ */
#ifndef MB_H
#define MB_H

#include "dba.def"
#include "max_gadg.def"

char *dba_user_format, *dba_def_ptr, dba_fontname[32];

double dba_minval, dba_maxval;

float dba_bodysize;

int dba_form_color, dba_data_type, dba_off_color, dba_on_color, dba_cr_mode,
 dba_text_style, dba_text_just, dba_field_just, dba_line_weight, dba_line_style,
 dba_line_depth, dba_bezel_mode, dba_group_edit, dba_attr, dba_fld_mode,
 dba_gadget_label, dba_list_attr, dba_list_mode, dba_grid, dba_numcols,
 dba_menu_x, dba_menu_y, dba_menu_width, dba_menu_height, dba_header_gadg,
 dba_list_attr, dba_list_mode, dba_list_x, dba_list_y, dba_list_rows,
 dba_new_flag, dba_vis_rows, dba_list_chars;

unsigned long dba_def_size, dba_font_mask, dba_user_size;

struct dba_gadget *dba_mb_gadg, *dba_ggadget, *dba_mcf_gadget, *dba_mcf_curcol;

int dba_gt_type[MAX_GADG_TYPE], dba_gt_itype[MAX_GADG_TYPE]; 
char dba_gt_text[MAX_GADG_TYPE][21], dba_gt_itext[MAX_GADG_TYPE][11]; 

#endif

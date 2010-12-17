/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

extern char *dba_errtxt, *dba_stext, dba_opt_name[], dba_opt_desc[],
 dba_fontname[], dba_menu_cell[];
extern float dba_bodysize;
extern int dba_off_color, dba_on_color, dba_cr_mode,
  dba_line_style, dba_line_weight, dba_line_depth, 
  dba_lines_per_page, dba_columns_per_page, 
  dba_field_just, dba_text_just, 
  dba_grid, dba_text_size, dba_text_style, 
  dba_verbose_active,
  dba_menu_x, dba_menu_y, dba_menu_width, dba_menu_height;
extern long dba_verify_mode, dba_verbose_mode;
extern unsigned long dba_st_size, dba_font_mask;

/* Function:	dba_load_options */
int dba_load_options (library, template)
char *library, *template;
{
  char tic_text[151], *tic;
  int status, type, retstat=0;
  struct dba_library *templib;

  status = dba_load_template (library, template, OPTIONS, &templib);
  if (status) return (status);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Type %d", &type);
  if (type != OPTIONS)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NOT_OPTIONS_TEMP, "%s", 79,
      template, NP));
    retstat = 99;  goto load_error; }

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "Template_Name %s", dba_opt_name);
  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  tic_text[0] = 0;
  status = sscanf (dba_stext, "Template_Description '%[^']'", tic_text);
  dba_code_to_tic (tic_text);
  strcpy (dba_opt_desc, tic_text);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  tic = strchr (dba_stext, 39);
  if (tic) {
    strcpy (dba_fontname, dba_parse_tics (&tic));
    status = sscanf (tic, "%s", dba_menu_cell);
  }
  else
    status = sscanf (dba_stext, "%s %s", dba_fontname, dba_menu_cell);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, "%f", &dba_bodysize);

  status = dba_get_record (templib, &dba_stext, &dba_st_size, NP, 0);
  status = sscanf (dba_stext, 
"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %ld %ld", 
    &dba_grid, &dba_off_color, 
    &dba_line_style, &dba_line_weight, &dba_line_depth, 
    &dba_cr_mode, &dba_field_just, &dba_text_just, &dba_text_style,
    &dba_lines_per_page, &dba_columns_per_page, &dba_text_size, &dba_on_color,
    &dba_verbose_active, &dba_verbose_mode,
    &dba_menu_x, &dba_menu_y, &dba_menu_width, &dba_menu_height,
    &dba_verify_mode, &dba_font_mask);

load_error:
  dba_lib_close (templib);

  return (retstat);
}

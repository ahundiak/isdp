/* $Revision: 1.1 $ */
#include "dba.ext"

extern char *dba_lib, *dba_lib_list, *dba_errtxt, *dba_support,
  dba_path_separator;
extern int dba_forms_mode;

/*
    Function:	dba_lookup_key_from_libs
    Author:	Tim A. Thompson
    Date:	18-FEB-91

    Revisions:
	9-25-92  -- Added time_val argument.
*/

int dba_lookup_key_from_libs (key, lib, time_val)
char *key, *lib;
time_t *time_val;
{
  int status;
  char *char_ptr, lib_spec[100], text[250];
  struct dba_library *lookup_lib;

  status = dba_get_template (dba_lib, key, &lookup_lib, SCRIPT, 1, time_val);
  if (!status) { 
    if (lib) strcpy (lib, dba_lib);
    return (1); 
  }

  if (dba_lib_list[0] != 0) {
    char_ptr = dba_lib_list;
    while (status && dba_parse_string (&char_ptr, lib_spec, ' ', 1)) {
      status = dba_get_template (lib_spec, key, &lookup_lib, SCRIPT, 1, 
          time_val);
      if (!status) { 
        if (lib) strcpy (lib, lib_spec);
        return (1);
      }
    }
  }

  for (char_ptr=dba_support;;) {
    status = dba_parse_string (&char_ptr, text, dba_path_separator, 1);
    if (!status) break;

    if (dba_forms_mode) sprintf (lib_spec, "%s/dba.lib", text);
    else sprintf (lib_spec, "%s/dba.tlb", text);

    status = dba_get_template (lib_spec, key, &lookup_lib, SCRIPT, 1, time_val);
    if (!status) {
      if (lib) strcpy (lib, lib_spec);
      return (1);
    }
  }

  return (0);
}

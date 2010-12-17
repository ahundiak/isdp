/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>

extern char *dba_lib, *dba_lib_list, *dba_errtxt, *dba_support,
  dba_path_separator;
extern int dba_forms_mode;

/* Function:	dba_load_template */
int dba_load_template (library, template, type, templib)
char *library, *template;
int type;
struct dba_library **templib;
{
  char *char_ptr, lib_spec[100], saved_error[250], text[250], tempnam[21];
  int status, load;

  if (!template || strlen (template) == 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_TEMPLATE_NAME, "%s", 0,
      template, NP));
    return (99); }

  if (!library) library = dba_lib;

  strncpy (tempnam, template, 20);
  tempnam[20] = 0;
  
  load = dba_load_from_library (library, tempnam, type, templib);
  if (load)
    { strcpy (saved_error, dba_errtxt);
    if (dba_lib_list[0] != 0)
      { char_ptr = dba_lib_list;
      while (dba_parse_string (&char_ptr, lib_spec, ' ', 1))
        { load = dba_load_from_library (lib_spec, tempnam, type, templib);
        if (!load) break; } } }

  if (load)
    { for (char_ptr=dba_support;;)
      { status = dba_parse_string (&char_ptr, text, dba_path_separator, 1);
      if (!status) break;

      if (dba_forms_mode) sprintf (lib_spec, "%s/dba.lib", text);
      else sprintf (lib_spec, "%s/dba.tlb", text);

      load = dba_load_from_library (lib_spec, tempnam, type, templib);
      if (!load) break; } }

  if (load)
    strcpy (dba_errtxt, saved_error);

  return (load);
}
/* Function:	dba_load_from_library */
int dba_load_from_library (library, template, type, templib)
char *library, *template;
int type;
struct dba_library **templib;
{
  int status;

  dba_init_error ();

  while (template[strlen (template) - 1] == ' ') 
    template[strlen (template) - 1] = 0;

  status = dba_get_template (library, template, templib, type, 0, NP);
  return (status);
}
/* Function:	dba_get_template */
int dba_get_template (library, template, templib, type, check, time_val)
char *library, *template;
struct dba_library **templib;
int type, check;
time_t *time_val;
{
  char ctype[20], text[50];
  int exist_key=0;
  
  *templib = dba_lib_open (library, "r");
  if (!*templib)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "library", library, errno));
    return (99); }

  exist_key = dba_lookup_key (*templib, template, type, time_val);
  if (exist_key != 1)
    { dba_template_type_from_number (ctype, type);
    sprintf (text, "%s template \"%s\"", ctype, template);
    strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_TEMPLATE, "%s%s", 0, 
      text, library));
    dba_lib_close (*templib);
    return (99); }

  if (check) 
    { dba_get_record (NP, NP, NP, NP, 2);
    dba_lib_close (*templib); }

  return (0);
}

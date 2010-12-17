/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>
#include <string.h>
#include "dbadev.h"

extern char *dba_lib, *dba_stext, *dba_errtxt;

/* Function:    dba_insert_template */
int dba_insert_template (library, filename, replace)
char *library, *filename;
int replace;
{
  char *text_ptr, *new_line, in_name[50], atype[20], text[40];
  int exist_key, type, retstat=0;
  struct dba_library *in_lib=0;
  FILE *in_file=0;

  if (!library) library = dba_lib;
  in_lib = dba_lib_open (library, "r+");
  if (!in_lib) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
      "template library", library, errno));
    return (99);
  }
  in_file = fopen (filename, "r");
  if (!in_file) {
    sprintf (dba_errtxt, "%s\n", dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d",
      0, "file", filename, errno));
    retstat = 99;
    goto done;
  }
  text_ptr = fgets (dba_stext, 2002, in_file);
  sscanf (dba_stext, "Template_Type %d", &type);
  text_ptr = fgets (dba_stext, 2002, in_file);
  sscanf (dba_stext, "Template_Name %s", in_name);
  fseek (in_file, 0, 0);

  dba_template_type_from_number (atype, type);
  sprintf (text, "%s template \"%s\"", atype, in_name);

  exist_key = dba_lookup_key (in_lib, in_name, type, NP);
  if (exist_key) {
    if (!replace) {
      sprintf (dba_errtxt, "%s\n", dba_get_msg (DBA_E_TEMP_NOT_REPLACED, "%s%s",
        0, text, library));
      retstat = 99;
      goto done;
    }
    else {
      sprintf (dba_errtxt, "%s\n", dba_get_msg (DBA_E_TEMP_REPLACED, "%s%s", 0,
        text, library));
      dba_delete_key (in_lib, in_name, type, 1);
    }
  }
  else
    sprintf (dba_errtxt, "%s\n", dba_get_msg (DBA_E_TEMP_INSERTED, "%s%s", 0,
      text, library));

  dba_insert_key (in_lib, in_name, 0, type);

read_temp:
  text_ptr = fgets (dba_stext, 2002, in_file);
  if (text_ptr) {
    new_line = strchr (text_ptr, '\n');
    if (new_line) *new_line = 0;
    dba_put_record (in_lib, dba_stext, 0);
    goto read_temp;
  }
  dba_put_end (in_lib, NP, 0);

done:
  if (in_file)
    fclose (in_file);
  if (in_lib)
    dba_lib_close (in_lib);

  return (retstat);
}

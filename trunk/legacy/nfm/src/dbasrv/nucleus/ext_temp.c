/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dbadev.h"
#include <errno.h>

extern char *dba_lib, *dba_stext, *dba_errtxt;
extern unsigned long dba_st_size;

/* Function:    dba_extract_template */
int dba_extract_template (library, template, type, filename)
char *library, *template, *filename;
int type;
{
  int status;
  struct dba_library *ext_lib;
  FILE *out_file;

  if (!library) library = dba_lib;
  ext_lib = dba_lib_open (library, "r");
  if (!ext_lib) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "library", library, errno));
    return (99);
  }
  out_file = fopen (filename, "w");
  if (!out_file) {
    sprintf (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "dump file", filename, errno));
    return (99);
  }
  status = dba_extract_template_records (library, ext_lib, template, 
    out_file, type);
  if (status) return (99);
 
  fclose (out_file);

  dba_lib_close (ext_lib);

  return (0);
}
/* Function:	dba_extract_template_records */
int dba_extract_template_records (library, ext_lib, name, out_file, type)
char *library, *name;
struct dba_library *ext_lib;
FILE *out_file;
int type;
{
  char atype[20], text[40];
  int status, exist_key;

  exist_key = dba_lookup_key (ext_lib, name, type, NP);
  if (exist_key != 1) {
    dba_template_type_from_number (atype, type);
    sprintf (text, "%s template \"%s\"", atype, name);
    strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_TEMPLATE, "%s%s", 0, 
      text, library));
    return (99);
  }
read_temp:
  status = dba_get_record (ext_lib, &dba_stext, &dba_st_size, NP, 0);
  if (status == 1) {
    fprintf (out_file, "%s\n", dba_stext);
    goto read_temp;
  }
  return (0);
}



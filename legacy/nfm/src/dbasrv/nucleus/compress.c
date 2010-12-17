/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>
#include "dbadev.h"
#include "keys.def"

#if defined __SUN__ || defined sco
#define _access access
#endif

extern char *dba_errtxt, *dba_stext, dba_text[], *dba_lib;
extern unsigned long dba_st_size;

/*
    Function:	dba_compress_library
    Author:	Brian Potter

    Revisions:
	11-11-93 -- Added 'lib' argument.
*/
int dba_compress_library (lib)
char *lib;
{
  char filename[MAX_FILESPEC];
  int status, retstat=0, count, exist_key;
  int (*func)();
  long total;
  unsigned long lng;
  struct dba_library *new_lib, *templib;
  struct dba_template *temp_list, *temp_ptr;

  if (!lib)
    lib = dba_lib;
  if (_access (lib, 2))
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_WRITE_FILE, "%s%d", 0, lib,errno));
    return (99); }

  func = dba_inq_service (DBA_PRINT_MSG);
  if (func)
    (*func) (dba_get_msg (DBA_M_PROCWAIT, NP,0,NP,NP));

  status = dba_list_library (lib, 100, &temp_list, &total);
  if (status) return (99);
  if (!total)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_TEMP, "%s", 0, lib, NP));
    return (99); }

  dba_tmpnam (filename);
  retstat = dba_create_library (filename, 0);
  if (retstat) return (99);
  new_lib = dba_lib_open (filename, "r+");
  if (!new_lib)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0, 
      "template library", filename, errno));
    return (99); }
  templib = dba_lib_open (lib, "r");
  for (count=0, temp_ptr=temp_list; count<total; ++count, ++temp_ptr)
    { exist_key = dba_lookup_key (templib, temp_ptr->name, temp_ptr->type, NP);
    if (!exist_key) continue;
    dba_insert_key (new_lib, temp_ptr->name, temp_ptr->time_val,temp_ptr->type);
  read_temp:
    status = dba_get_record (templib, &dba_stext, &dba_st_size, &lng, 0);
    if (status == 1)
      { dba_put_record (new_lib, dba_stext, lng);  goto read_temp; }
    dba_put_end (new_lib, NP, 0); }
  dba_dfree (temp_list);
  dba_lib_close (templib);
  dba_lib_close (new_lib);

  status = dba_move_file (lib, filename);
  return status;
}

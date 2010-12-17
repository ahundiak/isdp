/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dbadev.h"
#include <stdio.h>
#include <errno.h>

extern char *dba_lib, *dba_errtxt;

/* Function:	dba_undelete_template */
int dba_undelete_template (lib, temp_ptr, replace)
char *lib;
struct dba_template *temp_ptr;
int replace;
{
  char atype[20], text[40], name[23];
  int status, exist_key, k_byte, s_byte, key_lng;
  long k_block, s_block;
  struct dba_library *lib_ptr;

  if (!lib) lib = dba_lib;

  lib_ptr = dba_lib_open (lib, "r+");
  if (!lib_ptr)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
      "library", lib, errno));
    return (99); }

  dba_template_type_from_number (atype, temp_ptr->type);
  sprintf (text, "%s template \"%s\"", atype, temp_ptr->name);

  strcpy (name, temp_ptr->name);
  dba_pad_string (name, 20, ' ');
  sprintf (&name[20], "%2d", temp_ptr->type);

  exist_key = dba_lookup_key (lib_ptr, name, temp_ptr->type, NP);
  if (exist_key) { 
    if (!replace) { 
      strcpy (dba_errtxt, dba_get_msg (DBA_E_TEMP_NOT_REPLACED, "%s%s",
        0, text, lib));
      return (99); 
    }
    else { 
      strcpy (dba_errtxt, dba_get_msg (DBA_E_TEMP_REPLACED, "%s%s", 0,
        text, lib));
      dba_delete_key (lib_ptr, name, temp_ptr->type, 1); 
    } 
  }
  else
    strcpy (dba_errtxt, dba_get_msg (DBA_E_TEMP_UNDELETED, "%s%s", 0,
      text, lib));

  if (lib_ptr->top_i_bl) 
    status = dba_get_index (lib_ptr, name, &key_lng, &k_block, &k_byte, 
      &s_block, &s_byte);
  else { 
    k_block = dba_add_block (lib_ptr);
    k_byte = 12;
    lib_ptr->top_i_bl = k_block;
    dba_update_hdr (lib_ptr); 
  }
  dba_update_index (lib_ptr, name, temp_ptr->block, k_block, k_byte);
  ++lib_ptr->num_mod;
  dba_update_hdr (lib_ptr);

  dba_mark_deleted_template (lib_ptr, temp_ptr->block);

  dba_lib_close (lib_ptr);

  return (0);
}
/* Function:	dba_mark_deleted_template */
int dba_mark_deleted_template (lib_ptr, block)
struct dba_library *lib_ptr;
long block;
{
  int status;
  long index_block, data_block;
  short index_byte;
  unsigned long bytes;
  
  index_block = lib_ptr->top_s_bl;
  index_byte = 0;

  for (;;) { 
    index_byte += 4;
    if (index_byte == 512) {
      bytes = (index_block - 1) * 512;
      status = fseek (lib_ptr->ptr, bytes, 0);
      if (status) return (0);
      status = fread (&index_block, 4, 1, lib_ptr->ptr);
      index_byte = 4;
    }
    bytes = (index_block - 1) * 512 + index_byte;
    status = fseek (lib_ptr->ptr, bytes, 0);
    status = fread (&data_block, 4, 1, lib_ptr->ptr);
    if (data_block == block) {
      status = fseek (lib_ptr->ptr, -4, 1);
      if (status) return (0);
      data_block = -1;
      status = fwrite (&data_block, 4, 1, lib_ptr->ptr);
    }
    if (!data_block) break;
  }
  return (0);
}

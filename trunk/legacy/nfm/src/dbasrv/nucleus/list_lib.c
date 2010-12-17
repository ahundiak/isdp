/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>
#include "dbadev.h"
#include "dmalloc.def"

extern char *dba_lib, *dba_errtxt, *dba_stext;
extern int dba_first_turbo;
extern unsigned long dba_st_size;

/*
   Function:	dba_temptype_match
   Author:	Tim A. Thompson
   Date:	09-NOV-93
*/

int dba_temptype_match (mask, type)
long mask, type;
{
  mask &= ~DBA_TEMPLATE_MASK;
  switch (type) {
    case DATBAS:	return mask & DBA_DATABASE_RPT_MASK;
    case USERDATA:	return mask & DBA_USERDATA_RPT_MASK;
    case ASCII:		return mask & DBA_ASCII_RPT_MASK;
    case UD_S:		return mask & DBA_USERDATA_STRUCTURE_MASK;
    case ASC_S:		return mask & DBA_ASCII_STRUCTURE_MASK;
    case MENU:		return mask & DBA_MENU_MASK;
    case SQL_TEMPLATE:	return mask & DBA_SQL_MASK;
    case QUERY:		return mask & DBA_QUERY_MASK;
    case SCRIPT:	return mask & DBA_SCRIPT_MASK;
    case OPTIONS:	return mask & DBA_OPTIONS_MASK;
    case BINARY:	return mask & DBA_BINARY_RPT_MASK;
    case BIN_S:		return mask & DBA_BINARY_STRUCTURE_MASK;
    case OBJECT:	return mask & DBA_OBJECT_MASK;
    case APPLICATION:	return mask & DBA_APPLICATION_MASK;
    case PALETTE:	return mask & DBA_PALETTE_MASK;
    case TOOLBAR:	return mask & DBA_TOOLBAR_MASK;
    case STATUSBAR:	return mask & DBA_STATUSBAR_MASK;
    case BITMAP:	return mask & DBA_BITMAP_MASK;    
    case RELATIONS:	return mask & DBA_RELATION_MASK;
  }
  return 0;
}

/* Function:  dba_list_library
   Author:    Brian Potter
   Date:      04-NOV-90

   Revisions:
	11-9-93  -- Modified so a template mask can be sent in for
		    'template_type' (TAT for template librarian)
	11-19-93 -- Made "template_type" argument long instead of int for pc.
*/

int dba_list_library (library, template_type, template_list, list_count)
char *library;
long template_type;
struct dba_template **template_list;
long *list_count;
{
  char tic_text[151];
  int temp_type, status, cnt;
  struct dba_library *lib_ptr;
  struct dba_lib_index *index;
  struct dba_template *list_ptr;
  unsigned long bytes, size, time_val;
  static long list_size;
  
  if (!library) library = dba_lib;
  lib_ptr = dba_lib_open (library, "r");
  if (!lib_ptr)
    { strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
      "template library", library, errno));
    return (99); }
  *list_count = 0;
  list_size = 0;

  if (lib_ptr->rebuild) dba_get_lib_index (lib_ptr);

  for (cnt=0; cnt < lib_ptr->num_mod; ++cnt)
    { index = lib_ptr->temps + cnt;
    bytes = (index->data_block - 1) * 512 + index->data_byte + 14;
    if (index->data_byte >= 494) bytes += 6;
    status = fseek (lib_ptr->ptr, bytes, 0);
    status = fread (&time_val, 4, 1, lib_ptr->ptr);
    dba_int_swap_bytes (&time_val);

    dba_first_turbo = 1;
    dba_get_record (NP,NP,NP,NP,1);

    dba_get_record (lib_ptr, &dba_stext, &dba_st_size, NP, 0);
    if (strcmp (dba_stext, "Names") == 0)
      dba_get_record (lib_ptr, &dba_stext, &dba_st_size, NP, 0);
    status = sscanf (dba_stext, "Template_Type %d", &temp_type);
    if (!status) { temp_type = DATBAS;  goto get_name; }
    dba_get_record (lib_ptr, &dba_stext, &dba_st_size, NP, 0);
  get_name:
    if (template_type & DBA_TEMPLATE_MASK)
    {
      if (!dba_temptype_match (template_type, temp_type))
        continue;
    }
    else if (!template_type && temp_type > ASCII && temp_type != BINARY) 
      continue;
    else if (template_type == ALL_STR
      && temp_type != ASC_S && temp_type != BIN_S && temp_type != UD_S)
      continue;
    else if (template_type && template_type != 100 && template_type != ALL_STR
      && template_type != temp_type) 
      continue;
    ++(*list_count);
    size = sizeof (struct dba_template);
    if (list_size == 0)
      { list_size = 100 * size;
      *template_list 
        = (struct dba_template *) dba_dmalloc (list_size, DM_OTHER); }
    if (*list_count * size > list_size)
      { list_size += size * 100;
      *template_list =
        (struct dba_template *) dba_drealloc (*template_list, list_size); }
    list_ptr = *template_list + (*list_count - 1);
    strncpy (list_ptr->name, index->key, 20);
    list_ptr->name[20] = 0;
    while (list_ptr->name[strlen (list_ptr->name)-1] == ' ')
      list_ptr->name[strlen (list_ptr->name)-1] = 0;
    list_ptr->type = temp_type;
    list_ptr->time_val = time_val;
    dba_get_record (lib_ptr, &dba_stext, &dba_st_size, NP, 0);
    if (strncmp (dba_stext, "User_Action_Mode", 16) == 0)
      dba_get_record (lib_ptr, &dba_stext, &dba_st_size, NP, 0);
    status = sscanf (dba_stext, "Template_Description '%[^']'", tic_text);
    if (status == 1)
      { dba_code_to_tic (tic_text);
      strcpy (list_ptr->description, tic_text); }
    else strcpy (list_ptr->description, " "); }

  dba_lib_close (lib_ptr);
  dba_first_turbo = 0;

  return (0);
}

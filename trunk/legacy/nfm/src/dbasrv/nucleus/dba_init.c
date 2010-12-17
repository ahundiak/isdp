/* $Revision: 1.1 $ */
#include "dba.ext"
#include <stdlib.h>
#include "dmalloc.def"

extern char *dba_script_fldval, *dba_support, *dba_datbas, dba_menu_name[],
  *dba_schema_list, *dba_raster, *dba_da_file, *dba_errtxt, *dba_mem_ptr, 
  *dba_stext, *dba_fldval, *dba_last_keyin, *dba_lib, *dba_lib_list, 
  *dba_delcond, *dba_prodname, *dba_root_dir, *dba_error_log, 
  dba_path_delimiter, dba_path_separator, dba_version[], dba_rel_name[],
  dba_find_name[], dba_script_name[][21], dba_str_nam[], dba_opt_name[],
  dba_sql_name[];
extern int dba_type, dba_no_read_lock, dba_slow_read, dba_graphic_mode,
  dba_dde, dba_no_blocking;
extern long dba_verify_mode;
extern unsigned long dba_script_fv_size, dba_st_size, dba_mem_size, dba_fv_size,
  dba_dcond_lng;
extern union dba_mixed *dba_value;

/* Function:	dba_getenv */
char *dba_getenv (shell_var)
char *shell_var;
{
  char *ptr, *char_ptr;
  int lng;

  ptr = dba_dmalloc (101, DM_OTHER);
  ptr[0] = 0;

  char_ptr = getenv (shell_var);
  if (char_ptr) 
    { lng = strlen (char_ptr);
    if (lng > 100) ptr = dba_drealloc (ptr, lng+1);
    strcpy (ptr, char_ptr); }

  return (ptr);
}

/* Function:	dba_init 

Description: 	malloc and set global variables, open text library, and read
		environment symbols

Author:         Brian Potter
*/
int dba_init ()
{
  char *char_ptr, path[100], full_path[100], token[100];
  int status, found_lib=0, lib_status=0, length, mode, shift;
  static int built=0;
  FILE *file_ptr;

  if (built) return (0);
  built = 1;

  strcpy (dba_version, "05.00");

  dba_type = DATBAS;
#if defined (__WIN16__) || defined (__WIN32__)
  dba_path_separator = ';';
  dba_path_delimiter = '\\';
#elif defined (_MAC_)
  dba_path_separator = ';';
  dba_path_delimiter = ':';
#else
  dba_path_separator = ':';
  dba_path_delimiter = '/';
#endif

  if (!dba_root_dir) {
    dba_root_dir = dba_dmalloc (260, DM_OTHER);
    dba_root_dir[0] = 0;
    if (dba_prodname) {
      sprintf (path, "/usr/bin/%s", dba_prodname);
      file_ptr = fopen (path, "r");
      if (file_ptr) {
        fscanf (file_ptr, "# %s", dba_root_dir);
        fclose (file_ptr); 
      }
    } 
  }
  char_ptr = getenv ("DBA_SUPPORT");
  if (char_ptr) dba_support = (char *) strdup (char_ptr);
  if (!dba_support && strlen (dba_root_dir)) {
    sprintf (path, "%s%csupport", dba_root_dir, dba_path_delimiter);
    dba_support = (char *) strdup (path); 
  }
  if (!dba_support) {
    strcpy (dba_errtxt, "The DBA_SUPPORT variable is not assigned.");
    return (99); 
  }
  for (char_ptr=dba_support;;)
    { status = dba_parse_string (&char_ptr, path, (int)dba_path_separator, 1);
    if (!status) break;
    strcpy(full_path, path); 
    length = strlen(full_path);
    full_path[length] = dba_path_delimiter;
    full_path[length + 1] = 0;
    strcat(full_path, "dba.msg");
    lib_status = UMSInitMsg (full_path, UMS_INDEX);
    if (lib_status == UMS_S_SUCCESS || lib_status == UMS_I_DUPINIT) 
      { found_lib = 1;  break; } }

  if (!found_lib)
    { sprintf (dba_errtxt, "Error opening message file \"%s\" (UMS Error 0x%x)",
      full_path, lib_status);
    return (99); }

  dba_st_size = 2002;
  dba_stext = dba_dmalloc (dba_st_size, DM_GLOBAL);
  if (!dba_stext)
    { strcpy (dba_errtxt, (char *)dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return (99); }

  dba_value = dba_dmalloc (sizeof (union dba_mixed), DM_GLOBAL);
  if (!dba_value)
    { strcpy (dba_errtxt, (char *)dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return (99); }

  dba_mem_size = 1000;
  dba_mem_ptr = dba_dmalloc (dba_mem_size, DM_GLOBAL);
  if (!dba_mem_ptr)
    { strcpy (dba_errtxt, (char *)dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return (99); }

  dba_fv_size = 1000;
  dba_fldval = dba_dmalloc (dba_fv_size, DM_GLOBAL);
  if (!dba_fldval)
    { strcpy (dba_errtxt, (char *)dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return (99); }
  dba_fldval[0] = 0;
  dba_last_keyin = dba_fldval;

  dba_script_fv_size = 100;
  dba_script_fldval = dba_dmalloc (dba_script_fv_size, DM_GLOBAL);
  if (!dba_script_fldval)
    { strcpy (dba_errtxt, (char *)dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return (99); }
  dba_script_fldval[0] = 0;

  dba_dcond_lng = 1;
  dba_delcond = dba_dmalloc (1, DM_GLOBAL);

  dba_lib = dba_getenv ("DBA_LIB");

  dba_lib_list = dba_getenv ("DBA_LIB_LIST");

  char_ptr = getenv ("DBA_MENU");
  if (char_ptr)
    { strncpy (dba_menu_name, char_ptr, 20);  dba_menu_name[20] = 0; }

  dba_raster = dba_getenv ("DBA_RASTER");
  if (strlen (dba_raster)) dba_graphic_mode = 2;

  dba_da_file = getenv ("DBA_DAP_FILE");

  dba_error_log = dba_getenv ("DBA_ERROR_LOG");

  char_ptr = getenv ("DBA_DDE");
  if (char_ptr) dba_dde = 1;

  char_ptr = getenv ("DBA_NO_READ_LOCK");
  if (char_ptr) dba_no_read_lock = 1;

  char_ptr = getenv ("DBA_SLOW_READ");
  if (char_ptr) dba_slow_read = 1;

  char_ptr = getenv ("DBA_NO_BLOCKING");
  if (char_ptr) dba_no_blocking = 1;

  dba_schema_list = dba_getenv ("DBA_SCHEMA_LIST");

  dba_datbas = dba_getenv ("DBA_SCHEMA");

  char_ptr = getenv ("DBA_VERIFY_MODE");
  if (char_ptr)
    for (;;)
      { status = dba_parse_string (&char_ptr, token, ' ', 1);
      if (!status) break;
      status = sscanf (token, "%d", &shift);
      if (status == 1) 
        { mode = 1 << shift - 1;
        dba_verify_mode |= mode; } }

  dba_set_template_names ();

  return (0);
}
/* Function:	dba_set_template_names */
int dba_set_template_names ()
{
  strcpy (dba_rel_name, "RELATION");
/* batch report errors 8/13/94. blp
  strcpy (dba_find_name, "QUERY");
*/
  strcpy (dba_script_name[0], "SCRIPT");
  strcpy (dba_script_name[1], "SCRIPT");
  strcpy (dba_script_name[2], "SCRIPT");
  strcpy (dba_str_nam, "STRUCTURE");
  strcpy (dba_opt_name, "OPTIONS");
  strcpy (dba_sql_name, "SQL");

  return (0);
}

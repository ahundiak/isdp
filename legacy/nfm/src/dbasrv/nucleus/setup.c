/* $Revision: 1.1 $ */
#include "dba.h"
#include "keys.def"
#include <locale.h>

extern char *dba_stext, *dba_prodname, *dba_lib, *dba_errtxt, dba_server_node[];
extern Form dba_form[];

/* Function:	dba_setup */
int dba_setup (argc, argv, ms_flag, errmsg)
int argc;
char *argv[], *errmsg;
int ms_flag;
{
  char *char_ptr, *getenv();
  int status;
  int (*func)();
  extern char *optarg;
  extern int optind;

  dba_errtxt = errmsg;

  status = dba_init ();
  if (status) return (status);

  if (ms_flag) {
    if (dba_graphic_mode == 2) 
      dba_graphic_mode = 3;
    else 
      dba_graphic_mode = 1;
  }
  if (argc) {
    if (ms_flag) {
      optind = 2;
      optarg = argv[2];
    }  
    if (!dba_prodname || strcmp (dba_prodname, "templib"))
      dba_get_opt (argc, argv);
  }
  dba_register_service (DBA_ADD_ERROR, dba_stderr_add_error);
  dba_register_service (DBA_DMALLOC, (int (*)())dba_dmalloc_ex);
  dba_register_service (DBA_DREALLOC, (int (*)())dba_drealloc);  
  dba_register_service (DBA_GET_TYPED_TEMPLATES, dba_get_typed_templates);
  dba_register_service (DBA_PUT_END, dba_put_end);
  dba_register_service (DBA_PUT_RECORD, dba_put_record);
  dba_register_service (DBA_PUT_CHUNK, dba_put_chunk);
  dba_register_service (DBA_GET_CHUNK, dba_get_chunk);  
  dba_register_service (DBA_TIC_TO_CODE, (int (*)())dba_tic_to_code);
  dba_register_service (DBA_WRITE_TEMPLATE, dba_write_template);
  dba_register_service (DBA_STEXT, (int (*)())dba_stext);
  dba_register_service (DBA_LIB, (int (*)())dba_lib);
  dba_register_service (DBA_FORM, (int (*)())dba_form);  
  dba_register_service (DBA_DFREE, (int (*)())dba_dfree);
  dba_register_service (DBA_SORT, dba_sort);
  dba_register_service (DBA_REG_DEFAULT_VERBOSE_ON,
      (int (*)())dba_reg_default_verbose_on);
  dba_register_service (DBA_REG_DEFAULT_VERBOSE_OFF,
      (int (*)())dba_reg_default_verbose_off);
  dba_register_service (DBA_REG_FUNC_START, (int (*)())dba_reg_func_start);
  dba_register_service (DBA_REG_ARG_START, (int (*)())dba_reg_arg_start);
  dba_register_service (DBA_REG_SET_ARG_TYPE, (int (*)())dba_reg_set_arg_type);
  dba_register_service (DBA_REG_SET_ARG_INDIR,
      (int (*)())dba_reg_set_arg_indir);
  dba_register_service (DBA_REG_ARG_END, (int (*)())dba_reg_arg_end);
  dba_register_service (DBA_REG_FUNC_END, (int (*)())dba_reg_func_end);
  dba_register_service (DBA_LOOKUP_KEY, dba_lookup_key);
  dba_register_service (DBA_INSERT_KEY, dba_insert_key);
  dba_register_service (DBA_GET_RECORD, dba_get_record);
  dba_register_service (DBA_LIB_OPEN, (int (*)())dba_lib_open);
  dba_register_service (DBA_LIB_CLOSE, dba_lib_close);
  dba_register_service (DBA_DELETE_KEY, dba_delete_key);
  dba_register_service (DBA_LOAD_TEMPLATE, dba_load_template);  
  
  dba_editor_labels[0] = FORM_EDIT_SCRIPT0;
  dba_editor_labels[1] = FORM_EDIT_SCRIPT1;
  dba_editor_labels[2] = FORM_EDIT_SCRIPT2;

  dba_init_all ();

#if defined __WIN32__
  if (strlen (dba_server_node) != 0) {
    /* Connect to the DBAccess Server */
    func = dba_inq_service (DBA_NET_CONNECT);
    if (func) {
      if ((*func) (dba_server_node)) {
        sprintf (dba_errtxt, "Failed to connect to DB Access Server %s, Error=%d", 
          dba_server_node, status);
        func = dba_inq_service (DBA_ERROR_BOX);
        if (func)
          (*func) (dba_errtxt);
        else
          dba_printf ("%s\n", dba_errtxt);
        dba_exit();
      }
    }
  }
#endif

  if (char_ptr = getenv ("DBA_OPTIONS"))
    dba_load_options (dba_lib, char_ptr);

#if defined __WIN32__
  setlocale (LC_ALL, "");
#endif
  
  return (0);
}

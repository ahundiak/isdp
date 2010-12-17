/* $Revision: 1.1 $ */
/*	Function:	script_dummy */
extern char *dba_errtxt;

int dba_process_script (script)
char *script;
{
  if (!script || script[0] == 0) return (0);

  strcpy (dba_errtxt, "This executable was not linked with script.o");
  dba_add_error (dba_errtxt);

  return (99);
}

int dba_process_menu_script (script)
char *script;
{
  if (!script || script[0] == 0) return (0);

  strcpy (dba_errtxt, "This executable was not linked with script.o");
  dba_add_error (dba_errtxt);

  return (99);
}

int dba_compile_report_script (script) 
char *script;
{
  if (!script || script[0] == 0) return (0);

  strcpy (dba_errtxt, "This executable was not linked with script.o");
  dba_add_error (dba_errtxt);

  return (99);
}
int dba_run_report_script (script) 
char *script;
{
  if (!script || script[0] == 0) return (0);

  strcpy (dba_errtxt, "This executable was not linked with script.o");
  dba_add_error (dba_errtxt);

  return (99);
}
int dba_create_global_variable () {return (-1);}
int dba_delete_global_variable () { return (99); }
int dba_init_script () { return (0); }
int dba_exec_initial_script () { return (0); }
int dba_init_async () { return (0); }

int dba_script_error () { return (0); }

/*
int dba_run_script_error () { return (0); }
*/
int dba_process_realtime () { return (0); }
int dba_reset_global_variable () { return (0); }
int dba_get_int_from_global_by_name () { return (0); }

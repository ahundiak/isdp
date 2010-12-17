/* $Revision: 1.20 $ */
#include "dba.ext"
#include "keys.def"

extern char *dba_errtxt, *dba_exit_script_func;
extern int dba_use_server_flag;

/* Function:	dba_exit */
void dba_exit ()
{
  int (*exit_func)();
  static int been_called;

  if (been_called) return;
  been_called = 1;

  if (dba_exit_script_func) {
    exit_func = dba_inq_service (DBA_PROCESS_SCRIPT);
    if (exit_func) (*exit_func) (dba_exit_script_func);
  }

#if !defined __WIN32__
  exit_func = dba_inq_service (DBA_EXIT_RASTER);
  if (exit_func) (*exit_func) ();
#endif
  exit_func = dba_inq_service (DBA_ADMIN_SAVE_ALL);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_AUDIT);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (VI_FREE);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_GUI);
  if (exit_func) (*exit_func) ();
#if defined __WIN32__
  exit_func = dba_inq_service (DBA_EXIT_RASTER);
  if (exit_func) (*exit_func) ();
#endif
  exit_func = dba_inq_service (DBA_EXIT_NFM);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_RISDVW);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_USTN);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_REPORT);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_CFORMS);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_SCRIPT);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_DBNUC);
  if (exit_func) (*exit_func) ();

  dba_free_globals ();
  
#if defined __WIN16__
  dba_net_exit ();
  dba_net_close ();
  FIfm_unload_fonts ();
  dba_unload_dll_list ();
  PostQuitMessage (0);
#endif


#if defined __WIN32__
  exit_func = dba_inq_service (DBA_NET_EXIT);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_NET_CLOSE);
  if (exit_func) (*exit_func) ();

  dba_unhook_blocking ();
  
  ExitProcess (0);
#endif

  exit (0);
}

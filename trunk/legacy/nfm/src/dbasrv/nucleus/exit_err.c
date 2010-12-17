/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern char *dba_errtxt;

/* Function:	dba_exit_with_error */
void dba_exit_with_error ()
{
  int (*exit_func)();
  static int been_called;

  if (been_called) return;
  been_called = 1;

  exit_func = dba_inq_service (DBA_EXIT_GUI);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_NFM);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_RASTER);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_RISDVW);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_USTN);
  if (exit_func) (*exit_func) ();
  exit_func = dba_inq_service (DBA_EXIT_CFORMS);
  if (exit_func) (*exit_func) ();

#if !defined __WIN16__ && !defined __WIN32__
  printf ("\n   %s\n\n", dba_errtxt);  
  exit ();
#else
  dba_message_box ("%s", dba_errtxt);
#endif

#if defined __WIN16__
  dba_net_exit ();
  dba_net_close ();
  FIfm_unload_fonts ();
  dba_unload_dll_list ();
  PostQuitMessage (0);
#endif

#if defined __WIN32__
  ExitProcess (0);
#endif
}

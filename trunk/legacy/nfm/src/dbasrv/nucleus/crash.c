/* $Revision: 1.1 $ */
#include <stdio.h>
#include <signal.h>

/* Function:	dba_sigset */
void dba_sigset ()
{
  void dba_crash_sigbus(), dba_crash_sigemt(),
    dba_crash_sigsegv(), dba_crash_sigill(), dba_interrupt();

#if !defined __WIN16__ && !defined __WIN32__
  sigset (SIGBUS, dba_crash_sigbus);
  sigset (SIGEMT, dba_crash_sigemt);
  sigset (SIGSEGV, dba_crash_sigsegv);
  sigset (SIGILL, dba_crash_sigill);
  sigset (SIGINT, dba_interrupt);
#endif

}

/* Function:	dba_crash_sigbus */
void dba_crash_sigbus ()
{
  printf ("Bus Error\n");
  dba_dump_scr_callstack();
  dba_exit ();
}
/* Function:	dba_crash_sigemt */
void dba_crash_sigemt ()
{
  printf ("EMT Instruction\n");
  dba_dump_scr_callstack();
  dba_exit ();
}
/* Function:	dba_crash_sigsegv */
void dba_crash_sigsegv ()
{
  printf ("Segmentation Violation\n");
  dba_dump_scr_callstack();
  dba_exit ();
}
/* Function:	dba_crash_sigill */
void dba_crash_sigill ()
{
  printf ("Illegal Instruction\n");
  dba_dump_scr_callstack();
  dba_exit ();
}

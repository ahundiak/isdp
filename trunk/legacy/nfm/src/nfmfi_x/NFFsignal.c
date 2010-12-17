
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <signal.h>
#include <sys/signal.h>
#include <errno.h>
#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFsetup_signals ()
  {
    static  char *fname = "_NFFsetup_signals";

    _NFIdebug ((fname, "entering ...\n"));


    if ((signal (SIGINT, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGINT - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGINT", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGILL, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGILL - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGILL", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGTRAP, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGTRAP - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGTRAP", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGIOT, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGIOT - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGIOT", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGEMT, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGEMT - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGEMT", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGFPE, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGFPE - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGFPE", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGBUS, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGBUS - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGBUS", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGSEGV, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGSEGV - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGSEGV", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGSYS, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGSYS - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGSYS", errno);
        return (NFI_E_SIGNAL);
      }

    if ((signal (SIGTERM, _NFFsignal)) == SIG_ERR)
      {
        _NFIdebug ((fname, "SIGTERM - errno = <%d>\n", errno));
        ERRload_struct (NFI, NFI_E_SIGNAL, "%s%d", "SIGTERM", errno);
        return (NFI_E_SIGNAL);
      }


    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFsignal (type)
  int    type;
  {
    fprintf (stderr, "A signal was trapped -- ");

    switch (type)
      {
        case SIGINT:
            fprintf (stderr, "Interrupt (rubout)\n");
            break;

        case SIGILL:
            fprintf (stderr, "Illegal instruction\n");
            break;

        case SIGTRAP:
            fprintf (stderr, "Trace Trap\n");
            break;

        case SIGIOT:
            fprintf (stderr, "IOT instruction\n");
            break;

        case SIGEMT:
            fprintf (stderr, "EMT instruction\n");
            break;

        case SIGFPE:
            fprintf (stderr, "Floating point exception\n");
            break;

        case SIGBUS:
            fprintf (stderr, "Bus error\n");
            break;

        case SIGSEGV:
            fprintf (stderr, "Segmentation violation\n");
            break;

        case SIGSYS:
            fprintf (stderr, "Bad argument to system call\n");
            break;

        case SIGTERM:
            fprintf (stderr, "Software termination from kill\n");
            break;
      }

    fprintf (stderr, "Abnormal termination\n");
    _NFFexit (type);
  }

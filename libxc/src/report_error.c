#if defined(__STDC__)
#include <stdarg.h>
#else  /* K&R "C" */
#include <varargs.h>
#endif
#include <stdio.h>
#include <strings.h>
#include <stdlib.h>
#include "error.h"

extern int    errno;
static void (*trap_fn) () = ERR_DFLT;
static char   message[256];

static char *syserrs[] = {

    "Unexpected end of file.\n",     /* we use "errno" == 0 to mean this */
    "Not owner of the file.\n",
    "File does not exist.\n",
    "No such process.\n",
    "Interrupted system call.\n",
    "Physical I/O error.\n",
    "No such device or address.\n",
    "Argument list is too long.\n",
    "Bad magic:  cannot execute.\n",
    "Bad file number.\n",
    "Cannot wait:  no child processes.\n",
    "Reached process limit or process table full.\n",
    "Out of memory.\n",
    "Permission denied.\n",
    "Fault in system call:  bad argument.\n",
    "File is not a block device.\n",
    "Device or resource busy.\n",
    "File already exists.\n",
    "File is on another device.\n",
    "No such device.\n",
    "File is not a directory.\n",
    "File is a directory.\n",
    "Invalid argument to system function.\n",
    "System file table is full.\n",
    "Too many open files.\n",
    "File is not a character device.\n",
    "File is currently busy.\n",
    "File exceeded maximum file size.\n",
    "Disk is full.\n",
    "Illegal seek.\n",
    "File is on a read-only file system.\n",
    "File has too many links.\n",
    "Broken pipe.\n",
    "Argument is not within function domain.\n",
    "Result too large.\n",
    "No message of specified type.\n",
    "Identifier removed.\n",
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    "Deadlock was detected and avoided.\n"
};


void (*trap_errors (function)) ()

void (*function) ();
{
  void (*temp) ();

  temp    = trap_fn;
  trap_fn = function;
  return temp;
}


void report_syserr ()
{
}


#if defined(__STDC__)
void report_error (ERRDESCR *Estruct, int msg_id,
                                       int severity, void (*cleanup_fn)(), ...)
{
#else  /* K&R "C" */
void report_error (va_alist)

va_dcl
{
  ERRDESCR  *Estruct;
  int        msg_id;
  int        severity;
  void     (*cleanup_fn) ();
#endif
  va_list    args;

  /* get the arguments */

#if defined(__STDC__)
  va_start (args, cleanup_fn);
#else  /* K&R "C" */
  va_start (args);
  Estruct    = va_arg (args, ERRDESCR *);
  msg_id     = va_arg (args, int);
  severity   = va_arg (args, int);
  cleanup_fn = (void (*)())va_arg (args, char *);
#endif

  /* format the error message */

  if (Estruct->prefix[severity] != NULL)
    strcpy (message, Estruct->prefix[severity]);
  else message[0] = '\0';
  vsprintf (message + strlen (message), Estruct->msgtbl[msg_id], args);

  /* print the message; or, if there is a trap, call the trap function
     instead */

  if (trap_fn == ERR_DFLT)
    fprintf (stderr, "%s", message);
  else trap_fn (message, severity);

  /* now call the cleanup function if one was specified */

  if (cleanup_fn != ERR_DFLT)
    if (cleanup_fn != report_syserr)
      cleanup_fn ();
    else {

      /* report system error */

      if (Estruct->sysprefix != NULL) {
        strcpy (message, Estruct->sysprefix);
        strcat (message, syserrs[errno]);
      }
      else strcpy (message, syserrs[errno]);
      if (trap_fn == ERR_DFLT)
        fprintf (stderr, message);
      else trap_fn (message, severity);
    }

  /* call user-specified handler if he has set up one, otherwise perform the
     default action */

  if (Estruct->handler[severity] != ERR_DFLT)
    Estruct->handler[severity] ();
  else
    switch (severity) {
      case ERR_INFO   :
      case ERR_WARNING:
      case ERR_ERROR  : return;
      case ERR_FATAL  : exit (msg_id);
    }
}

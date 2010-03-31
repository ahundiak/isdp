/*
  FILE DESCRIPTION

    This file contains the declaration and definition of the system variable 
    that holds the file-pointer to the error log-file. The default is NO log
    file, that is, all error is printed solely to stderr. But if a log file
    has been specified, then error messages (and trace) are also printed to
    the log file.
*/

#include <stdio.h>
#include <string.h>

#include "PWminimum.h"

static FILE *ErrLogFile = (FILE *) NULL;
static char ErrLogFilename[PW_K_MaxCharFilename+1];

/*
  This function returns the file-pointer to the error log file if one has
  been established. If no such file exists then this function returns NULL.
*/

FILE *pwGetErrLogFile
(
)
{
  return (ErrLogFile);
}

/*
    This function is used to set the error log file to a particular file.
    All errors and/or traces will be recorded in this file. The file can
    be opened either for an initial write or for an append to an existing
    file.
*/
PWboolean pwSetErrLogFile 
(
  char *filename,
  PWboolean append
)
{
  ErrLogFile = (FILE *) NULL;

  if (strlen (filename) > PW_K_MaxCharFilename ||
      !(ErrLogFile = fopen (filename, (append ? "a" : "w"))))
  {
    return (FALSE);
  }
  else 
  {
    strcpy (ErrLogFilename, filename);
    return (TRUE);
  }
}

/*
    This function is called when the error log file has to be closed. It
    can also be called to reset the error log file to plain, old stderr.
    If there was an error log file open, this function closes it and sets
    the error log file to NULL (or stderr).
*/
void pwResetErrLogFile 
(
)
{
  if (ErrLogFile)
    fclose (ErrLogFile);

  ErrLogFile = (FILE *) NULL;
}

/*
    If there is an error log file open, this function can be used to return
    the name of the file. The function returns TRUE if the name is being
    returned.
*/
PWboolean pwGetErrLogFilename 
(
  char *filename
)
{
  PWboolean retval;

  if (ErrLogFile)
  {
    if (strcpy (filename, ErrLogFilename))
      retval = TRUE;
    else
      retval = FALSE;
  }
  else
  {
    retval = FALSE;
  }

  return (retval);
}

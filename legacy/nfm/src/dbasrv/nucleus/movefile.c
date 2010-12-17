/* $Revision: 1.1 $ */
#include "dba.ext"
#include <errno.h>

extern char *dba_errtxt;

#if defined __SUN__ || defined sco
#define _access access
#endif

/*
    Function:	move_file (STATIC)
    Author:	Tim A. Thompson
    Date:	11-15-93
*/

static int move_file (dest, source)
char *dest, *source;
{
  FILE *in, *out;
  int rcount, wcount, status=0;
  char *buf[512];

  in = fopen (source, "rb");
  if (!in) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
        "input file", source, errno));
    return (99);
  }
  out = fopen (dest, "wb");
  if (!out) {
    fclose (in);
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
        "output file", dest, errno));
    return (99);
  }
  while (!feof(in)) {
    rcount = fread (buf, 1, 512, in);
    wcount = fwrite (buf, 1, rcount, out);
    if (wcount != rcount)
      status = 99;
  }
  fclose (in);
  fclose (out);
  if (!status)
    remove (source);
  return (status);
}


/*
    Function:	dba_move_file
    Author:	Tim A. Thompson
    Date:	11-15-93
*/

int dba_move_file (dest, source)
char *dest, *source;
{
  int status;

  if (_access (source, 4)) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
        "input file", source, errno));
    return (99);
  }
  if (_access (dest, 2)) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
        "output file", dest, errno));
    return (99);
  }
  if (remove (dest)) {
    strcpy (dba_errtxt, dba_open_msg (DBA_E_OPEN_FILE, "%s%s%d", 0,
        "output file", dest, errno));
    return (99);
  }
  else
#ifndef __clipper
    /* This is commented out for clipper since rename in libPW.a is
       broken... can be replaced if they ever fix it */
    if (rename (source, dest))
#endif
      status = move_file (dest, source);
#ifndef __clipper
    else
      status = 0;
#endif
  return (status);
}

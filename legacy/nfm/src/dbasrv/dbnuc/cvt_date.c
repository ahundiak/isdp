/* $Revision: 1.1 $ */
#include "dba.ext"

#if defined RIS4
#include "sql.h"
#include "rislimit.h"
#include "ris.prt"
#elif defined RIS5
#include "ris.h"
#include "rislimit.h"
#include "ris.prt"
#else
#include "sql.h"
#include "RISlimits.h"
#include "RISprototype.h"
#endif

extern char *dba_errtxt, *dba_timestamp_format;

/* Function:	dba_convert_date */
int dba_convert_date (out, in)
char *in, *out;
{
  char text[200];
  char *error;
  datetime date;

  if (strcmp (in, "NULL") == 0) return (0);
  if (strlen (in) == 0) { strcpy (out, "NULL");  return (0); }

  strcpy (text, in);
  dba_upper (text);

  if (strncmp (text, "CURRENT", 7) == 0)
    { strcpy (out, "current_timestamp");  return (0); }

  error = RISascii_to_datetime (&date, in, dba_timestamp_format);
  if (error)
    { strcpy (out, "NULL");
    strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_DATE, "%s", 0, 
      dba_timestamp_format, NP));
    return (99); }

  sprintf (out, "timestamp '%04ld-%02ld-%02ld:%02ld:%02ld:%02ld'",
    date.year, date.month, date.day, date.hour, date.minute, date.second);

  return (0);
}

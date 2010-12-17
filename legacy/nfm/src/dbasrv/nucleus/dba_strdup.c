/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_strdup */
void dba_strdup (in, out, lng)
char *in, **out;
unsigned long *lng;
{
  int in_lng;

  if (!in) {
    if (!out) return;
    in = "";
  }
  in_lng = strlen (in);
  if (in_lng + 1 > *lng) { 
    *lng = in_lng + 1;
    *out = dba_drealloc (*out, *lng); 
  }
  strcpy (*out, in);

  return;
}

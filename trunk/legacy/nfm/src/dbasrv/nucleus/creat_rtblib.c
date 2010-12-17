/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

#if defined __SUN__ || defined sco
#define _access access
#endif

extern char *dba_errtxt;

/* Function:	dba_create_library */
int dba_create_library (library, confirm)
char *library;
int confirm;
{
  char text[100];
  int status;
  int (*func)();
  FILE *file_ptr;
  static char header[60] = { 
    4, 1, 0, 0, -127, 37, -20, 13, 3, 0, 0, 0, 23, 86, 65, 88,
    45, 49, 49, 32, 76, 105, 98, 114, 97, 114, 105, 97, 110, 32, 86, 48,
    52, 45, 48, 48, 0, 0, 0, 0, 0, 0, 0, 0, 32, -51, -25, -34,
    61, 69, -111, 0, 32, -51, -25, -34, 61, 69, -111, 0 
  }, header1[512]; 

  if (!library || strlen (library) == 0)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_INV_LIB_NAME, NP, 0, NP, NP));
    return (99); }

  strcpy (text, library);
  if (confirm) { 
    func = dba_inq_service (DBA_YES_NO);
    if (func) {
      if (_access (text, 0))
        status = (*func) (DBA_M_NO_TEMPLATE_LIB, text, 0);
      else
        status = (*func) (DBA_M_REPLACE_TEMPLATE, text, 0);
      if (!status) return (1);
      if (status == 99) { 
        strcpy (dba_errtxt, dba_get_msg (DBA_E_INVALID_RESPONSE, NP,0,NP,NP));
        return (99); 
      } 
    } 
  }
  file_ptr = fopen (text, "w");  if (!file_ptr) goto cre_err;
  memset (header1, 0, 512);
  header1[16] = 3;
  header1[22] = 3;
  header1[26] = 1;
  header1[30] = 2;
  header1[34] = 2;
  header1[64] = 20;
  header1[136] = 5;
  header1[138] = 21;
  status = fwrite (header, 60, 1, file_ptr);
  if (status != 1) goto cre_err;
  status = fwrite (header1, 452, 1, file_ptr);
  if (status != 1) goto cre_err; 
  memset (header1, 0, 150);
  status = fwrite (header1, 512, 1, file_ptr);
  if (status != 1) goto cre_err; 
  fclose (file_ptr);
/* 2/13/93 blp
  strcpy (dba_lib, text);
*/
  return (0);

cre_err:
  strcpy (dba_errtxt, dba_get_msg (DBA_E_CREATE_TEMPLATE_LIB, "%s", 0, 
    text, NP));
  return (99);
}

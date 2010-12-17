/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_get_msg 
Description: 	returns the text string from the message file "dba.msg"
		associated with the specified key
Author: 	Brian Potter */

char *dba_get_msg (msgnum, msgfmt, maxlng, ptr1, ptr2)
long msgnum;
char *msgfmt;
int maxlng;
void *ptr1, *ptr2;
{
  char *fmt1, *fmt2, str1[100], str2[100];
  static char *s1_ptr;
  static int status;
  static unsigned long s1_size=0;

  DBACODE = msgnum;

  if (!s1_size) { s1_size = 200;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }
  if (maxlng > 0 && maxlng + 1 > s1_size)
    { s1_size = maxlng + 1;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }

  if (msgfmt)
    { fmt1 = strstr (msgfmt, "%s");
    if (fmt1) 
      { if (fmt1 == msgfmt)
        { dba_expand_backslash ((char *)ptr1, str1);
        ptr1 = str1;
        fmt1 += 2;
        fmt2 = strstr (fmt1, "%s");
        if (fmt2) 
          { dba_expand_backslash ((char *)ptr2, str2);
          ptr2 = str2; } }
      else
        { dba_expand_backslash ((char *)ptr2, str2);
        ptr2 = str2; } } }
      
  status = UMSGetByNum (s1_ptr, msgnum, msgfmt, ptr1, ptr2);
  if (status == UMS_E_NOTFND)
    sprintf (s1_ptr, "Message number 0x0%x is not in message file.", msgnum);

  if (maxlng) s1_ptr[maxlng] = 0;

  return (s1_ptr);
}

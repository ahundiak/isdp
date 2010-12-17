/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_open_msg
Description: 	returns the text string from the message file "dba.msg"
		associated with the specified key
Author: 	Brian Potter */

char *dba_open_msg (msgnum, msgfmt, maxlng, ptr1, ptr2, ptr3)
long msgnum;
char *msgfmt;
int maxlng;
void *ptr1, *ptr2, *ptr3;
{
  char str2[100];
  static char *s1_ptr;
  static int status;
  static unsigned long s1_size=0;

  DBACODE = msgnum;

  if (!s1_size) { 
    s1_size = 200;
    s1_ptr = dba_dmalloc (s1_size, DM_STATIC); 
  }
  if (maxlng > 0 && maxlng + 1 > s1_size) { 
    s1_size = maxlng + 1;
    s1_ptr = dba_drealloc (s1_ptr, s1_size); 
  }
  dba_expand_backslash ((char *)ptr2, str2);
  ptr2 = str2; 

  status = UMSGetByNum (s1_ptr, msgnum, msgfmt, ptr1, ptr2, ptr3);
  if (status == UMS_E_NOTFND)
    sprintf (s1_ptr, "Message number 0x0%x is not in message file.", msgnum);

  if (maxlng) s1_ptr[maxlng] = 0;

  return (s1_ptr);
}

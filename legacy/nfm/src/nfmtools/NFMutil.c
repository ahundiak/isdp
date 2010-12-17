#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"

long _NFMfind_column_offset (buffer, attrname, offset)
     MEMptr     buffer;
     char       *attrname;
     int        *offset;
{
  static char *fname = "_NFMfind_column_offset" ;
  int   i;
  char  **column;

  *offset = -1 ;

  column = (char **) buffer->column_ptr;

  _NFMdebug ((fname, "buffer columns  = <%d>  ", buffer->columns  ));

  for (i = 0; i < buffer->columns; ++i)
    {
      if ((strcmp (column[i], attrname)) == 0)
        {
          *offset = i;
          break;
        }
    }
  if (i == buffer->columns ) return (NFM_E_FAILURE) ;
  else return (NFM_S_SUCCESS) ;
}


int _NFMinsert_in_place(str,position, value)
     char *str ;      /* o - i - MEM string to insert value in position */
     int position ;   /* i     - position (1 - n) */
     char *value ;    /* i     - string to insert */
{
  static char *fname = "_NFMinsert_in_place" ;
  char s1[200] ;
  int pos ;
  int t, y, i ;

  pos = 1;
  t=0 ;
  do {
    if (position == pos) {
      for (i=0; i<t; i++) s1[i] = str[i] ;
      s1[i] = 0 ;
      strcat (s1,value) ;
      strcat (s1, &str[t]) ;
      break ;
    }

    if (str[t] == 0) break ;

    while (str[t] != 0) {
      if (str[t++] == '\001') {
        ++pos ;
        break ;
      }
    }
  } while (1) ;

  if ( (str[t] == 0) && (pos != position))  
    {
      return (NFM_E_FAILURE) ;
    }
  strcpy (str,s1) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}




#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <io.h>
#include "CLIerrordef.h"
#include "CLIstruct.h"
#include "CLIextern.h"
#include "NFMerrordef.h"
#include "NETstruct.h"
#include "proto.h"
#include "pc.h"
#include <memcheck.h>
extern char *buffer;

long _NFMget_server_response (err_no, err_message, returned_string)
     long err_no ;
     char *err_message ;
     char *returned_string ;
{
  long atol();
  long *src ;
  short *sizes_array, *size_of_block ;
  char *data, s_error [20] ;
  long rows, columns ;
  short	   i;

  returned_string [0] = 0 ;
  src = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *src ; src ++ ;  
  columns = *src ; src ++ ;
  size_of_block = (short *) src ;
/** it must have only one row **/
/*
  for (i=1; i<=((short) rows); i++)
    { 
*/
      sizes_array = (short *) ((long)src + sizeof (short)) ;
/** first column - message no **/
      data = (char *) ((long) sizes_array + columns * sizeof (short)) ;
      memcpy (s_error, data, sizes_array[0]) ;
      err_no = atol (s_error) ;

/** second column - message string **/
      data = (char *) (data + sizes_array [0]) ;
      memcpy (err_message, data, sizes_array[1]) ;

/** third column - value from server **/
      data = (char *) (data + sizes_array[1]) ;
      memcpy (returned_string, data, sizes_array [2]) ;

/*
      fprintf( CLIout_file, "*** %s <0x%.8lx>\n", err_message, err_no ) ;
      printf ("*** %s <0x%.8lx>\n", err_message, err_no ) ;
*/
      if (strlen (returned_string))
	{
	  fprintf( CLIout_file, "server sent -> %s\n", returned_string) ;
	}
/*      
      size_of_block= (short *) ((long) size_of_block + (long)(*size_of_block));

    }
*/
  return (NFM_S_SUCCESS) ;
}

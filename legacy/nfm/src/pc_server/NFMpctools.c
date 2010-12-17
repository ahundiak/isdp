#include "machine.h"
#include <stdio.h>
#include "ERR.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMpcproto.h" 

long NFMvalidate_pc_filename (filename)
     char *filename ;
{
  static char *fname = "NFMcheck_pc_filename" ;
  long status ;
  char *ptr, *ptr_ptr ;
  long len1 ;

  ptr = (char *) strchr (filename, '.') ;
  if (ptr == NULL)
    { /* no . in filename */
      if (strlen (filename) > 8)
	{
	  _NFMdebug ((fname, "filename is the form <greater than 8>\n")) ;
	  return (NFM_E_FAILURE) ;
	}
      return (NFM_S_SUCCESS) ;
    }
  else
    { /* . in filename */
      len1 = ptr - filename ;
      if (len1 > 8)
	{
	  _NFMdebug ((fname, "filename is the form <greater than 8>.<something>\n")) ;
	  return (NFM_E_FAILURE) ;
	}
      len1 = strlen (filename) - (len1+1) ;
      if (len1 > 3)
	{
	  _NFMdebug ((fname, "filename is the form <less than 8>.<greater than 3>\n"));
	  return (NFM_E_FAILURE) ;
	}
      ptr++ ;
      ptr_ptr = (char *) strchr (ptr, '.') ;
      if (ptr_ptr != NULL)
	{
	  _NFMdebug ((fname, "filename has more than one .\n"));
	  return (NFM_E_FAILURE) ;
	}
      return (NFM_S_SUCCESS) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}








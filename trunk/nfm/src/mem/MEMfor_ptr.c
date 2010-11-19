/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Builds the format array for the memory structure *
*                                                                   *
* Arguements       long MEMformat_list (list, offset)               *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Count the number of columns malloc space for the *
*                  pointer to these format array and load the       *
*                  address of the format of the buffer in the       *
*                  array.                                           *
*                                                                   *
* Return Status    MEM_E_MALLOC  : Failure                          *
*                  MEM_S_SUCCESS : SUCCESS                          *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See                                                          *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "ERR.h"
#include "MEM.h"
#include "DEBUG.h"
           
long MEMformat_list (MEMptr list, long offset)
{
  static char *fname= "MEMformat_list";
  long    status;
  char    **format;
  long    i, col_no;

  i = offset + MEM_HEADER_END + 1;
   
  if (list -> format_ptr) free (list -> format_ptr);

  list -> format_ptr = NULL;

  // Do nothing if no columns
  if (! list -> columns) return (MEM_S_SUCCESS);

  // Allocate array of pointers
  format = (char **) malloc (sizeof (char *) * list -> columns);
  g_assert(format);

  for (col_no = 0; col_no < list -> columns; ++col_no)
  {
    while (list -> buffer_ptr [i] != '\1') i++; i++;

    format [col_no] = list -> buffer_ptr + i;

    while (list -> buffer_ptr [i] != '\1') i++; i++;      	
  }
  g_return_val_if_fail(list->buffer_ptr[i] == '\n',MEM_E_CORRUPTED_BUFFER);

  list -> format_ptr = (char *) format;

  return (MEM_S_SUCCESS);
}

/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Builds the column array for the memory structure *
*                                                                   *
* Arguements       long MEMcolumn_list (list, offset)               *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Count the number of columns malloc space for the *
*                  pointer to these column array and load the       *
*                  address of the column names of the buffer in the *
*                  array.                                           *
*                                                                   *
* Return Status    MEM_E_MALLOC  : failure                          *
*                  MEM_S_SUCCESS : Success.                         *
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
#include <glib.h>

#include "ERR.h"
#include "MEM.h"
#include "DEBUG.h"
           
long MEMcolumn_list (MEMptr list, long offset)
{
  long    status;
  char    **column;
  long    i, col_no;
  static  char *fname = "MEMcolumn_list";

  i = offset + MEM_HEADER_END + 1; 

  // Init the column pointer
  if (list -> column_ptr) free (list -> column_ptr);
     
  list -> column_ptr = NULL;

  // No columns is okay
  if (! list -> columns) return (MEM_S_SUCCESS);

  // Allocate array
  column = (char **) malloc (sizeof (char *) * list -> columns);
  g_assert(column);

  for (col_no = 0; col_no < list -> columns; ++col_no)
  {
    column [col_no] = list -> buffer_ptr + i;

    while (list -> buffer_ptr [i] != '\1') i++; i++;        
    while (list -> buffer_ptr [i] != '\1') i++; i++;      	
  }
  g_return_val_if_fail(list->buffer_ptr[i] == '\n',MEM_E_CORRUPTED_BUFFER);

  list -> column_ptr = (char *) column;

  return (MEM_S_SUCCESS);
}

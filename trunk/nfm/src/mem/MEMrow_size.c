/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the structure information of the buffer.    *
*                                                                   *
* Arguments        long MEMrow_size (list, offset)                  *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Calculate the number of columns for the buffer.  *
*                  Load the format and column information for the   *
*                  buffer and get the row size. Next calculate the  *
*                  number of rows and load the data information.    *
*                                                                   *
* Return Status    MEM_S_SUCCESS     : SUCCESS.                     *
*                  MEM_E_NULL_LIST   : FAILURE.                     *
*                  MEM_E_NULL_BUFFER : FAILURE.                     *
*                  MEM_E_DAT_TYPE    : FAILURE.                     *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMformat_list ()                                *
*                  MEMcolumn_list ()                                *
*                  MEMdata_list ()                                  *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added call to ERRload_struct()   *
*                                  for non-success status.          *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : If format is timestamp, set j =  *
*                                  21. Previously set to 20.        *
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

long MEMrow_size (MEMptr list, long offset)
{
  long   status;
  long   j, y;
  char   temp [25];
  char   **format;
  static char *fname = "MEMrow_size";

  // Arg check
  g_return_val_if_fail(list,            MEM_E_NULL_LIST);
  g_return_val_if_fail(list->buffer_ptr,MEM_E_NULL_BUFFER);

  status = MEMno_columns (list, offset);
  g_return_val_if_fail(status == MEM_S_SUCCESS,status);

  status = MEMformat_list (list, offset);
  g_return_val_if_fail(status == MEM_S_SUCCESS,status);

  format = (char **) list -> format_ptr;

  list -> row_size = 1;

  for (y = 0; y < list -> columns; ++y)
  {
         if (!strcmp  (format [y], "integer" ))   j = 15;
    else if (!strcmp  (format [y], "smallint"))   j = 15;
    else if (!strcmp  (format [y], "double"  ))   j = 50;
    else if (!strcmp  (format [y], "real"    ))   j = 50;
    else if (!strcmp  (format [y], "decimal" ))   j = 15;
    else if (!strcmp  (format [y], "date"    ))   j = 15;
    else if (!strcmp  (format [y], "timestamp"))  j = 21;
    else if (!strncmp (format [y], "char",  4))
    {
      sscanf (format [y], "%5s%d", temp, &j);
   
      g_return_val_if_fail(j > 0,MEM_E_DATA_TYPE);
      j = j + 2;
    }
    else g_return_val_if_fail(0,MEM_E_DATA_TYPE);

    list -> row_size = list -> row_size + j;
  }
  return (MEM_S_SUCCESS);
}
